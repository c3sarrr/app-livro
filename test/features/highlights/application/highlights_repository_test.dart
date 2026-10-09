// G19.2 — o repositório da tela 25: as anotações vivas e as camadas delas (relidas a cada escrita), a busca FTS5,
// apagar o cartão inteiro com as camadas (D-193) e desfazer, trocar a cor no lugar e a nota (D-131/D-138).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/highlights/application/highlights_repository.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../support/ordem_do_livro.dart';

void main() {
  late AppDatabase db;
  late HighlightsRepository repo;
  final m = mundoReferencia;
  final livro = m.domCasmurro.id;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    await UserBooksDao(db).upsert(m.domCasmurro);
    for (final l in m.camadas) {
      await InkLayersDao(db).upsert(l);
    }
    for (final a in m.anotacoes) {
      await AnnotationsDao(db).upsert(a);
    }
    repo = HighlightsRepository(
      db: db,
      versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoB')),
      owner: () async => m.usuarioId,
    );
  });
  tearDown(() => db.close());

  test(
    'lê os 12 itens do livro na ordem do livro e as 4 camadas deles',
    () async {
      final r = await repo.read(livro);
      expect(r.items.map((a) => a.id), itensDoMundo().map((a) => a.id));
      expect(r.layers.keys.toSet(), {
        for (final a in r.items)
          if (a.inkLayerId != null) a.inkLayerId!,
      });
      expect(r.layers, hasLength(4));
    },
  );

  /// Espera (até 2 s) a condição [ok] valer.
  Future<void> ate(bool Function() ok) async {
    for (var i = 0; i < 200 && !ok(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test(
    'observa: lê agora e de novo depois de cada escrita nas duas tabelas',
    () async {
      final vistos = <int>[];
      final sub = repo.watch(livro).listen((r) => vistos.add(r.items.length));
      await ate(() => vistos.isNotEmpty);
      expect(vistos, [12]);
      await repo.deleteGroup(
        livro,
        itemDoMundo(3, AnnotationKind.highlight).groupId,
      );
      await ate(() => vistos.last == 11);
      expect(vistos.last, 11);
      final n = vistos.length;
      await InkLayersDao(db).upsert(m.camadas.first);
      await ate(() => vistos.length > n);
      expect(vistos.length, greaterThan(n));
      await sub.cancel();
    },
  );

  test('busca: sem acento e sem caixa; a nota à mão não tem texto próprio; só brancos = sem busca', () async {
    final elipse = itemDoMundo(159, AnnotationKind.drawing);
    expect(await repo.search(livro, 'ressaca'), {elipse.id});
    expect(await repo.search(livro, 'É O LIVRO'), {
      itemDoMundo(6, AnnotationKind.note).id,
    });
    expect(await repo.search(livro, 'opera'), {
      itemDoMundo(41, AnnotationKind.highlight).id,
    });
    expect(await repo.search(livro, 'zzzz'), isEmpty);
    expect(await repo.search(livro, '   '), isNull);
  });

  test('apagar o cartão 7: as duas anotações e as duas camadas, numa vez; desfazer traz tudo', () async {
    final elipse = itemDoMundo(159, AnnotationKind.drawing);
    final mao = itemDoMundo(159, AnnotationKind.handwriting);
    final r = await repo.deleteGroup(livro, elipse.groupId);
    expect(r!.annotations.map((a) => a.id).toSet(), {elipse.id, mao.id});
    expect(r.layers.map((l) => l.id).toSet(), {
      elipse.inkLayerId,
      mao.inkLayerId,
    });
    final depois = await repo.read(livro);
    expect(depois.items.where((a) => a.groupId == elipse.groupId), isEmpty);
    expect(depois.layers.containsKey(elipse.inkLayerId), isFalse);
    final linhaApagada = await AnnotationsDao(db).byId(elipse.id);
    expect(linhaApagada!.meta.isDeleted, isTrue);
    expect(
      linhaApagada.meta.version.compareTo(elipse.meta.version),
      greaterThan(0),
    );

    await repo.restore(r);
    final volta = await repo.read(livro);
    expect(volta.items.map((a) => a.id), itensDoMundo().map((a) => a.id));
    expect(volta.layers, hasLength(4));
    final viva = await AnnotationsDao(db).byId(elipse.id);
    expect(viva!.meta.isDeleted, isFalse);
    expect(
      viva.meta.version.compareTo(linhaApagada.meta.version),
      greaterThan(0),
    );
  });

  test('apagar um grupo que não existe: nada', () async {
    expect(
      await repo.deleteGroup(livro, '0199a7c4-2f00-7a10-8b20-000000000999'),
      isNull,
    );
  });

  test('trocar a cor: no lugar, com versão nova; grifo apagado ou que não é grifo: false', () async {
    final p3 = itemDoMundo(3, AnnotationKind.highlight);
    expect(await repo.recolor(p3.id, '#B6ACE4'), isTrue);
    final novo = await AnnotationsDao(db).byId(p3.id);
    expect(novo!.color, '#B6ACE4');
    expect(novo.anchor, p3.anchor);
    expect(novo.meta.version.compareTo(p3.meta.version), greaterThan(0));
    await repo.deleteGroup(livro, p3.groupId);
    expect(await repo.recolor(p3.id, '#FED170'), isFalse);
    expect(
      await repo.recolor(itemDoMundo(6, AnnotationKind.note).id, '#FED170'),
      isFalse,
    );
    expect(
      await repo.recolor('0199a7c4-2f00-7a10-8b20-000000000999', '#FED170'),
      isFalse,
    );
  });

  test(
    'a nota: cria no grupo do grifo, edita a mais antiga, vazia apaga',
    () async {
      final p3 = itemDoMundo(3, AnnotationKind.highlight);
      await repo.saveNote(livro, p3.id, '  nova  ');
      var itens = (await repo.read(livro)).items;
      final criada = itens.singleWhere(
        (a) => a.kind == AnnotationKind.note && a.parentId == p3.id,
      );
      expect(
        (criada.noteText, criada.groupId, criada.refPage, criada.meta.userId),
        ('nova', p3.groupId, 3, m.usuarioId),
      );

      final p6 = itemDoMundo(6, AnnotationKind.highlight);
      await repo.saveNote(livro, p6.id, 'outra');
      itens = (await repo.read(livro)).items;
      expect(itens.singleWhere((a) => a.parentId == p6.id).noteText, 'outra');

      await repo.saveNote(livro, p6.id, '');
      itens = (await repo.read(livro)).items;
      expect(itens.where((a) => a.parentId == p6.id), isEmpty);

      await repo.saveNote(livro, p6.id, '');
      expect((await repo.read(livro)).items.length, 12);
    },
  );
}

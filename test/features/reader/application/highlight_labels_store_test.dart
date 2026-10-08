// G17 (D-40, D-177) — os rótulos das cores do marca-texto e as contagens: ler dá os rótulos vivos por cor e os grifos
// vivos de todos os livros do usuário por cor; salvar muda o rótulo que mudou (a mesma linha, versão nova), apaga o
// que ficou vazio (só espaços conta como vazio), cria o que não existia (na ordem das cores) e não regrava o igual.
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_label.dart';
import 'package:app_leitura/features/reader/application/highlight_labels_store.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late HighlightLabelsStore store;
  var agora = DateTime.utc(2026, 10, 8, 10);

  setUp(() {
    agora = DateTime.utc(2026, 10, 8, 10);
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    store = HighlightLabelsStore(
      db,
      LocalVersioning(
        db,
        HlcClock(
          deviceId: 'aparelhoA',
          nowMs: () => agora.millisecondsSinceEpoch,
        ),
      ),
    );
  });
  tearDown(() => db.close());

  HighlightLabel rotulo(int n, String cor, String texto, {int ordem = 0}) =>
      HighlightLabel(
        id: idTeste(n),
        meta: metaTeste(),
        color: cor,
        label: texto,
        sort: ordem,
      );

  test('ler: os rótulos vivos por cor e os grifos vivos de todos os livros por cor', () async {
    final dao = HighlightLabelsDao(db);
    await dao.upsert(rotulo(1, '#FED170', 'lindo'));
    await dao.upsert(rotulo(2, '#FFC1C6', 'personagem', ordem: 1));
    await dao.upsert(
      HighlightLabel(
        id: idTeste(3),
        meta: metaTeste(apagado: true),
        color: '#ABCF82',
        label: 'apagado',
      ),
    );
    final notas = AnnotationsDao(db);
    for (final (n, cor, livro) in [
      (10, '#FED170', 1),
      (11, '#FED170', 2),
      (12, '#FFC1C6', 1),
    ]) {
      await notas.upsert(grifoTeste(n, livro: idTeste(livro), cor: cor));
    }
    await notas.upsert(
      grifoTeste(13, livro: idTeste(1), cor: '#FED170', apagado: true),
    );
    await notas.upsert(
      grifoTeste(14, livro: idTeste(1), cor: '#FED170', dono: idTeste(99)),
    );
    final d = await store.load(usuarioTeste);
    expect(d.labels, {'#FED170': 'lindo', '#FFC1C6': 'personagem'});
    expect(d.counts, {'#FED170': 2, '#FFC1C6': 1});
  });

  test('salvar: muda, apaga, cria e não regrava o igual', () async {
    final dao = HighlightLabelsDao(db);
    final amarelo = rotulo(1, '#FED170', 'lindo');
    final rosa = rotulo(2, '#FFC1C6', 'personagem', ordem: 1);
    final lavanda = rotulo(4, '#B6ACE4', 'pro clube', ordem: 3);
    for (final r in [amarelo, rosa, lavanda]) {
      await dao.upsert(r);
    }
    agora = DateTime.utc(2026, 10, 8, 11);
    await store.save(usuarioTeste, const {
      '#FED170': '  lindo demais ',
      '#FFC1C6': '   ',
      '#ABCF82': 'ideia',
      '#B6ACE4': 'pro clube',
    });
    final linhas = {
      for (final r in await dao.forUser(usuarioTeste)) r.color: r,
    };
    expect(linhas.keys, unorderedEquals(['#FED170', '#ABCF82', '#B6ACE4']));
    final a = linhas['#FED170']!;
    expect((a.id, a.label, a.sort), (amarelo.id, 'lindo demais', 0));
    expect(a.meta.updatedAt, DateTime.utc(2026, 10, 8, 11));
    expect(a.meta.createdAt, amarelo.meta.createdAt);
    expect(a.meta.version > amarelo.meta.version, isTrue);
    final v = linhas['#ABCF82']!;
    expect((v.label, v.sort, v.meta.userId), ('ideia', 2, usuarioTeste));
    expect(v.meta.createdAt, DateTime.utc(2026, 10, 8, 11));
    expect(linhas['#B6ACE4'], lavanda, reason: 'igual: não regrava');
    // o rosa: a linha apagada (tombstone), com versão nova
    final todas = await db.select(db.highlightLabels).get();
    final r = todas.singleWhere((x) => x.id == rosa.id);
    expect(r.deletedAt, DateTime.utc(2026, 10, 8, 11));
    expect((await store.load(usuarioTeste)).labels, {
      '#FED170': 'lindo demais',
      '#ABCF82': 'ideia',
      '#B6ACE4': 'pro clube',
    });
  });

  test('o rótulo vai cortado em 24 (contando como o banco)', () async {
    await store.save(usuarioTeste, {'#FED170': '${'é' * 30}  '});
    expect((await store.load(usuarioTeste)).labels['#FED170'], 'é' * 24);
  });

  test('nenhum rótulo, nenhum grifo: tudo vazio', () async {
    final d = await store.load(usuarioTeste);
    expect(d.labels, isEmpty);
    expect(d.counts, isEmpty);
  });
}

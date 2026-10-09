// G19.2 — o controlador da tela 25: o livro, a posição, os cartões e as entradas, as contagens e a fileira de cores;
// os filtros; a busca com espera (a última tecla vence); apagar com Desfazer; a cor e a nota; a exportação; os erros.

import 'dart:async';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/highlights/application/card_text_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_club_source.dart';
import 'package:app_leitura/features/highlights/application/highlights_controller.dart';
import 'package:app_leitura/features/highlights/application/highlights_file_sink.dart';
import 'package:app_leitura/features/highlights/application/highlights_repository.dart';
import 'package:app_leitura/features/highlights/domain/card_filters.dart';
import 'package:app_leitura/features/highlights/domain/highlight_card.dart';
import 'package:app_leitura/features/highlights/domain/list_entries.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:drift/drift.dart'
    show QueryExecutor, QueryInterceptor, ApplyInterceptor;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../support/ordem_do_livro.dart';

final class _Fonte implements CardTextSource {
  _Fonte({this.orfaos = const {}});
  final Set<String> orfaos;
  int pedidos = 0;
  @override
  Future<CardTexts> textsFor(List<HighlightCard> cards) async {
    pedidos++;
    final r = await const AnchorOnlyCardTextSource().textsFor(cards);
    return CardTexts(r.byGroup, orfaos);
  }
}

/// Segura a próxima consulta da busca (FTS) que tiver [palavra] até [soltar]: a busca fica "no ar".
final class _Portao extends QueryInterceptor {
  String? palavra;
  final Completer<void> _solta = Completer<void>();
  int presas = 0;

  void soltar() => _solta.complete();

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    final p = palavra;
    if (p != null &&
        statement.contains('MATCH') &&
        args.any((a) => a is String && a.contains(p))) {
      palavra = null;
      presas++;
      await _solta.future;
    }
    return executor.runSelect(statement, args);
  }
}

final class _Clube implements HighlightsClubSource {
  @override
  Future<ClubChip?> clubOf(String id) async =>
      id == mundoReferencia.clube.postCompartilhadoId
      ? (
          clubId: mundoReferencia.clube.id,
          name: 'Leitoras de Capitu',
          replies: 3,
        )
      : null;
}

final class _Arquivos implements HighlightsFileSink {
  final List<(String, String, String)> feitos = [];
  bool falhar = false;
  @override
  Future<void> share({
    required String fileName,
    required String content,
    required String mimeType,
  }) async {
    if (falhar) throw StateError('disco cheio');
    feitos.add((fileName, content, mimeType));
  }
}

void main() {
  late AppDatabase db;
  late HighlightsController c;
  late List<Object> erros;
  late _Arquivos arquivos;
  late _Fonte fonte;
  late _Portao portao;
  final m = mundoReferencia;
  final livro = m.domCasmurro.id;
  final cartoes = buildCards(itensDoMundo());

  Future<void> ate(bool Function() ok) async {
    for (var i = 0; i < 300 && !ok(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  HighlightsController novo({UserBook? book, Set<String> orfaos = const {}}) {
    fonte = _Fonte(orfaos: orfaos);
    return HighlightsController(
      userBookId: book?.id ?? livro,
      deps: HighlightsDeps(
        db: db,
        repository: HighlightsRepository(
          db: db,
          versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoB')),
          owner: () async => m.usuarioId,
        ),
        textSourceFor: (_) async => fonte,
        club: _Clube(),
        now: () => DateTime.utc(2026, 10, 9, 15),
        utcOffsetAt: (_) => m.fuso,
        files: arquivos,
        onError: (e, _) => erros.add(e),
        searchDelay: const Duration(milliseconds: 60),
      ),
    );
  }

  setUp(() async {
    erros = [];
    arquivos = _Arquivos();
    portao = _Portao();
    db = AppDatabase(
      NativeDatabase.memory().interceptWith(portao),
      withSyncQueue: false,
    );
    await UserBooksDao(db).upsert(m.domCasmurro);
    await ReadingPositionsDao(db).upsert(m.posicao(Slugs.domCasmurro));
    for (final l in m.camadas) {
      await InkLayersDao(db).upsert(l);
    }
    for (final a in m.anotacoes) {
      await AnnotationsDao(db).upsert(a);
    }
    c = novo();
    await c.load();
    await ate(() => !c.state.loading);
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  List<String> curto() => [
    for (final e in c.state.entries)
      switch (e) {
        PageMark(:final page, :final here) => 'p$page${here ? '*' : ''}',
        CardItem(:final card, :final orphan) =>
          'c${cartoes.indexWhere((x) => x.groupId == card.groupId) + 1}${orphan ? '~' : ''}',
        OrphanMark() => '~',
      },
  ];

  test(
    'carrega o livro, a posição, os 8 cartões, as contagens e as 5 cores',
    () {
      final s = c.state;
      expect(
        (s.title, s.author, s.physical, s.herePage),
        ('Dom Casmurro', 'Machado de Assis', false, 159),
      );
      expect(s.items, hasLength(12));
      expect(s.layers, hasLength(4));
      expect(s.cards.map((x) => x.groupId), cartoes.map((x) => x.groupId));
      expect(curto(), [
        'p3',
        'c1',
        'p6',
        'c2',
        'p41',
        'c3',
        'p121',
        'c4',
        'p152',
        'c5',
        'p159*',
        'c6',
        'c7',
        'c8',
      ]);
      expect(
        (
          s.counts.highlights,
          s.counts.notes,
          s.counts.handwriting,
          s.counts.drawings,
        ),
        (6, 2, 1, 3),
      );
      expect(s.colors.map((x) => x.key), [
        'yellow',
        'pink',
        'green',
        'lavender',
        'coral',
      ]);
      expect(s.texts, hasLength(8));
      expect(s.clubs.keys, [m.clube.postCompartilhadoId]);
      expect(s.visibleCards, 8);
      expect(s.empty, isFalse);
      expect(erros, isEmpty);
    },
  );

  test('filtros: tipo, cor (marca e desmarca), clube e limpar', () {
    c.setType(TypeFilter.notes);
    expect(curto(), ['p6', 'c2', 'p152', 'c5', 'p159*']);
    c.setType(TypeFilter.all);
    c.toggleColor('#FF552E');
    expect(curto(), ['p159*', 'c7', 'c8']);
    c.toggleColor('#FFC1C6');
    expect(c.state.filters.colors, {'#FF552E', '#FFC1C6'});
    c.toggleColor('#FF552E');
    expect(c.state.filters.colors, {'#FFC1C6'});
    c.setClubOnly(true);
    expect(c.state.visibleCards, 0);
    c.clearFilters();
    expect(c.state.filters.isDefault, isTrue);
    expect(c.state.visibleCards, 8);
  });

  test('busca: espera; a última tecla vence; vazia volta a todos', () async {
    c.setQuery('ressaca');
    expect(c.state.filters.query, 'ressaca');
    expect(
      c.state.visibleCards,
      8,
      reason: 'antes da espera, a lista não muda',
    );
    c.setQuery('ópera');
    await ate(() => c.state.visibleCards == 1);
    expect(curto(), ['p41', 'c3', 'p159*']);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(curto(), [
      'p41',
      'c3',
      'p159*',
    ], reason: 'a busca de "ressaca" foi cancelada');
    c.setQuery('');
    expect(c.state.visibleCards, 8);
    c.setQuery('zzzz');
    await ate(() => c.state.visibleCards == 0);
    expect(c.state.visibleCards, 0);
    c.clearFilters();
    expect(c.state.visibleCards, 8);
  });

  test(
    'busca: os achados de uma busca velha que chegam atrasados não valem',
    () async {
      portao.palavra = 'ressaca';
      c.setQuery('ressaca');
      await ate(() => portao.presas == 1);
      c.setQuery('ópera');
      await ate(() => c.state.visibleCards == 1);
      portao.soltar();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(curto(), ['p41', 'c3', 'p159*']);
    },
  );

  test('busca: "Limpar filtros" com a busca no ar fica com todos', () async {
    portao.palavra = 'ressaca';
    c.setQuery('ressaca');
    await ate(() => portao.presas == 1);
    c.clearFilters();
    expect(c.state.visibleCards, 8);
    portao.soltar();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(c.state.visibleCards, 8);
    expect(c.state.filters.isDefault, isTrue);
  });

  test(
    'o banco muda duas vezes e a 1ª leitura chega depois: fica a 2ª',
    () async {
      c.setQuery('opera');
      await ate(() => c.state.visibleCards == 1);
      final p41 = itemDoMundo(41, AnnotationKind.highlight);
      Annotation nota(String fim) => Annotation(
        id: '0199a7c4-2f00-7a10-8b20-000000000$fim',
        meta: p41.meta,
        userBookId: livro,
        kind: AnnotationKind.note,
        parentId: p41.id,
        groupId: p41.groupId,
        anchor: p41.anchor,
        refPage: 41,
        chapterIndex: p41.chapterIndex,
        noteText: 'nota $fim',
      );
      portao.palavra = 'opera';
      await AnnotationsDao(db).upsert(nota('777'));
      await ate(() => portao.presas == 1);
      await AnnotationsDao(db).upsert(nota('778'));
      await ate(() => c.state.items.length == 14);
      portao.soltar();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(c.state.items, hasLength(14));
      expect(c.state.cards[2].notes, hasLength(2));
    },
  );

  test(
    'a releitura do banco com uma busca que já foi apagada: fica a lista toda',
    () async {
      c.setQuery('opera');
      await ate(() => c.state.visibleCards == 1);
      final p41 = itemDoMundo(41, AnnotationKind.highlight);
      portao.palavra = 'opera';
      await AnnotationsDao(db).upsert(
        Annotation(
          id: '0199a7c4-2f00-7a10-8b20-000000000779',
          meta: p41.meta,
          userBookId: livro,
          kind: AnnotationKind.note,
          parentId: p41.id,
          groupId: p41.groupId,
          anchor: p41.anchor,
          refPage: 41,
          chapterIndex: p41.chapterIndex,
          noteText: 'nota nova',
        ),
      );
      await ate(() => portao.presas == 1);
      c.setQuery('');
      expect(c.state.visibleCards, 8);
      portao.soltar();
      await ate(() => c.state.items.length == 13);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(c.state.filters.query, '');
      expect(c.state.visibleCards, 8);
    },
  );

  test('cartão com 2 grifos e a nota no 2º: editar a nota grava nela (não cria outra no 1º)', () async {
    final p6 = cartoes[1].highlight!;
    final p3 = itemDoMundo(3, AnnotationKind.highlight);
    final antes = Annotation(
      id: '0199a7c4-2f00-7a10-8b20-000000000780',
      meta: p3.meta,
      userBookId: livro,
      kind: AnnotationKind.highlight,
      groupId: p6.groupId,
      source: p3.source,
      anchor: p3.anchor,
      refPage: p3.refPage,
      chapterIndex: p3.chapterIndex,
      color: p3.color,
      style: p3.style,
      fillHeight: p3.fillHeight,
    );
    await AnnotationsDao(db).upsert(antes);
    await ate(() => c.state.items.length == 13);
    final cartao = c.state.cards.firstWhere((x) => x.groupId == p6.groupId);
    expect(cartao.highlight!.id, antes.id, reason: 'o 1º grifo do cartão');
    expect(await c.saveNote(cartao, 'editada'), isTrue);
    await ate(
      () => c.state.cards
          .firstWhere((x) => x.groupId == p6.groupId)
          .notes
          .any((n) => n.noteText == 'editada'),
    );
    final notas = c.state.cards
        .firstWhere((x) => x.groupId == p6.groupId)
        .notes;
    expect(notas, hasLength(1));
    expect((notas.single.parentId, notas.single.noteText), (p6.id, 'editada'));
  });

  test('apagar o cartão 7 com Desfazer; dispensar', () async {
    await c.deleteCard(cartoes[6]);
    await ate(() => c.state.visibleCards == 7);
    expect(c.state.undo!.annotations, hasLength(2));
    expect(c.state.items, hasLength(10));
    await c.undo();
    await ate(() => c.state.visibleCards == 8);
    expect(c.state.undo, isNull);
    await c.undo();
    await c.deleteCard(cartoes[0]);
    expect(c.state.undo, isNotNull);
    c.dismissUndo();
    expect(c.state.undo, isNull);
  });

  test(
    'cor de todos os grifos do cartão; a mesma cor não muda nada; a nota',
    () async {
      expect(await c.recolor(cartoes[1], '#FED170'), isTrue);
      await ate(() => c.state.cards[1].highlight!.color == '#FED170');
      expect(c.state.cards[1].highlight!.color, '#FED170');
      expect(await c.recolor(c.state.cards[1], '#FED170'), isFalse);
      expect(await c.recolor(cartoes[7], '#FED170'), isFalse);
      await c.saveNote(cartoes[0], 'minha nota');
      await ate(() => c.state.cards[0].notes.isNotEmpty);
      expect(c.state.cards[0].notes.single.noteText, 'minha nota');
      await c.saveNote(cartoes[7], 'sem grifo');
      expect(erros, isEmpty);
    },
  );

  test('sem lugar: os grupos da fonte vão para o fim', () async {
    c.dispose();
    c = novo(orfaos: {cartoes[3].groupId});
    await c.load();
    await ate(() => !c.state.loading);
    expect(curto(), [
      'p3',
      'c1',
      'p6',
      'c2',
      'p41',
      'c3',
      'p152',
      'c5',
      'p159*',
      'c6',
      'c7',
      'c8',
      '~',
      'c4~',
    ]);
  });

  test(
    'a lista se refaz quando o banco muda por fora; a busca ativa roda de novo',
    () async {
      c.setQuery('opera');
      await ate(() => c.state.visibleCards == 1);
      final p41 = itemDoMundo(41, AnnotationKind.highlight);
      final nota = Annotation(
        id: '0199a7c4-2f00-7a10-8b20-000000000777',
        meta: p41.meta,
        userBookId: livro,
        kind: AnnotationKind.note,
        parentId: p41.id,
        groupId: p41.groupId,
        anchor: p41.anchor,
        refPage: 41,
        chapterIndex: p41.chapterIndex,
        noteText: 'ópera de novo',
      );
      await AnnotationsDao(db).upsert(nota);
      await ate(() => c.state.items.length == 13);
      expect(c.state.visibleCards, 1);
      expect(fonte.pedidos, greaterThanOrEqualTo(2));
    },
  );

  test(
    'exportar: Markdown e CSV do livro todo; nada para exportar; erro do disco',
    () async {
      c.setType(TypeFilter.drawings);
      expect(c.exportable, 8);
      expect(await c.export(ExportFormat.markdown), isTrue);
      expect(await c.export(ExportFormat.csv), isTrue);
      final (nome, conteudo, tipo) = arquivos.feitos.first;
      expect((nome, tipo), ('dom-casmurro-grifos-e-notas.md', 'text/markdown'));
      expect(
        conteudo,
        startsWith(
          '# Dom Casmurro — grifos e notas\nMachado de Assis · exportado em 09/10/2026\n',
        ),
      );
      expect(
        conteudo,
        contains('## pág. 3'),
        reason: 'ignora o filtro de Desenhos',
      );
      final (nomeCsv, csv, tipoCsv) = arquivos.feitos.last;
      expect(
        (nomeCsv, tipoCsv),
        ('dom-casmurro-grifos-e-notas.csv', 'text/csv'),
      );
      expect(csv, startsWith('﻿pagina;'));
      arquivos.falhar = true;
      expect(await c.export(ExportFormat.csv), isFalse);
      expect(erros.single, isA<StateError>());
    },
  );

  test('livro sem nada: vazio, e a exportação não tem o que levar', () async {
    c.dispose();
    final outro = m.livro(Slugs.alienista);
    await UserBooksDao(db).upsert(outro);
    c = novo(book: outro);
    await c.load();
    await ate(() => !c.state.loading);
    expect(c.state.empty, isTrue);
    expect(c.state.entries, isEmpty);
    expect(c.exportText(ExportFormat.markdown), isNull);
    expect(await c.export(ExportFormat.markdown), isFalse);
  });

  test('livro que não está na estante: termina sem título; o erro do banco é relatado', () async {
    c.dispose();
    c = novo(book: m.livro(Slugs.senhora).copyWith());
    await db.close();
    await c.load();
    expect(c.state.loading, isFalse);
    expect(erros, isNotEmpty);
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
  });
}

// G03 — semântica de valor das entidades: igualdade, hash coerente e copyWith que muda só o pedido
// (as entidades viram chaves de Set/Map e estado do Riverpod — hash errado = bug silencioso).
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/model/json_value.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/library/domain/reading_goals.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation_stats.dart';
import 'package:app_leitura/features/reader/annotations/domain/highlight_label.dart';
import 'package:app_leitura/features/reader/annotations/domain/ink_layer.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

/// [a] == [igual] (mesmo hash) e cada um de [diferentes] é distinto dos outros.
void valor<T>(T a, T igual, List<T> diferentes) {
  expect(a, igual);
  expect(a.hashCode, igual.hashCode);
  final todos = {a, igual, ...diferentes};
  expect(todos, hasLength(1 + diferentes.length));
}

void main() {
  final livro = idTeste(1);
  final depois = metaTeste(contador: 1);

  test('UserBook', () {
    final b = livroTeste(1);
    valor(b, livroTeste(1), [
      b.copyWith(meta: depois),
      b.copyWith(editionId: Nullable(idTeste(99))),
      b.copyWith(authorDisplay: 'M. de Assis'),
      b.copyWith(contentSha256: const Nullable(null)),
      b.copyWith(fileBytes: const Nullable(1)),
      b.copyWith(storageObjectPath: const Nullable('u/1.epub')),
      b.copyWith(refPagesTotal: const Nullable(255)),
      b.copyWith(refPageVersion: const Nullable(2)),
      b.copyWith(chaptersTotal: const Nullable(147)),
      b.copyWith(coverRef: const Nullable('capa')),
      b.copyWith(rating: const Nullable(5)),
      b.copyWith(addedAt: DateTime.utc(2026, 1, 1)),
      b.copyWith(startedAt: Nullable(DateTime.utc(2026, 1, 2))),
    ]);
    expect(b.copyWith().editionId, b.editionId);
  });

  test('ReadingGoals, ReaderSettings, PenPresets, HighlightLabel', () {
    final g = ReadingGoals(id: usuarioTeste, meta: metaTeste());
    valor(g, ReadingGoals(id: usuarioTeste, meta: metaTeste()), [
      g.copyWith(meta: depois),
      g.copyWith(badgeTargetDays: 14),
    ]);
    final r = ReaderSettings(id: usuarioTeste, meta: metaTeste());
    valor(r, ReaderSettings(id: usuarioTeste, meta: metaTeste()), [
      r.copyWith(meta: depois),
      r.copyWith(fontFamily: ReaderFontFamily.lora),
      r.copyWith(lineSpacing: ReaderLineSpacing.solto),
      r.copyWith(margins: ReaderMargins.larga),
    ]);
    expect(ReaderFontFamily.fromCode('atkinson'), ReaderFontFamily.atkinson);
    expect(ReaderPaper.fromCode('sepia'), ReaderPaper.sepia);
    expect(ReaderLineSpacing.fromCode('justo'), ReaderLineSpacing.justo);
    expect(ReaderMargins.fromCode('estreita'), ReaderMargins.estreita);
    final p = PenPresets(id: usuarioTeste, meta: metaTeste());
    valor(p, PenPresets(id: usuarioTeste, meta: metaTeste()), [
      p.copyWith(meta: depois),
      p.copyWith(penTip: PenTip.brush),
      p.copyWith(penWidthMm: 2.5),
      p.copyWith(favoriteColors: const ['#000000']),
      p.copyWith(strokeSize: StrokeSize.thick),
      p.copyWith(highlighterStyle: HighlightStyle.wavy),
      p.copyWith(highlighterHeight: FillHeight.high),
      p.copyWith(highlighterColor: '#ABCF82'),
    ]);
    expect(PenTip.fromCode('fountain'), PenTip.fountain);
    expect(StrokeSize.fromCode('thin'), StrokeSize.thin);
    final h = HighlightLabel(
      id: idTeste(5),
      meta: metaTeste(),
      color: '#FED170',
      label: 'lindo',
    );
    valor(
      h,
      HighlightLabel(
        id: idTeste(5),
        meta: metaTeste(),
        color: '#FED170',
        label: 'lindo',
      ),
      [
        h.copyWith(meta: depois),
        h.copyWith(color: '#FFC1C6'),
        h.copyWith(sort: 2),
      ],
    );
  });

  test('ReadingPosition, ReadingSession, Bookmark', () {
    final pos = posicaoTeste(livro);
    valor(pos, posicaoTeste(livro), [
      pos.copyWith(meta: depois),
      pos.copyWith(locator: localizadorTeste(pagina: 160)),
      pos.copyWith(chapterIndex: 32),
      pos.copyWith(progression: 0.7),
    ]);
    final s = sessaoTeste(
      10,
      livro: livro,
      inicio: DateTime.utc(2026, 9, 20, 12),
    );
    valor(
      s,
      sessaoTeste(10, livro: livro, inicio: DateTime.utc(2026, 9, 20, 12)),
      [
        s.copyWith(meta: depois),
        s.copyWith(endedAt: DateTime.utc(2026, 9, 20, 13)),
        s.copyWith(activeSeconds: 61),
        s.copyWith(refPageFrom: const Nullable(1)),
        s.copyWith(refPageTo: const Nullable(2)),
        s.copyWith(pagesViewed: const Nullable(3)),
        s.copyWith(source: SessionSource.manual),
        s.copyWith(deviceId: const Nullable('outro')),
      ],
    );
    expect(SessionSource.fromCode('timer'), SessionSource.timer);
    final m = marcadorTeste(20, livro: livro);
    valor(m, marcadorTeste(20, livro: livro), [
      m.copyWith(meta: depois),
      m.copyWith(locator: localizadorTeste(pagina: 3)),
      m.copyWith(refPage: 3),
      m.copyWith(chapterIndex: 0),
    ]);
  });

  test('Annotation e InkLayer', () {
    final a = grifoTeste(30, livro: livro);
    valor(a, grifoTeste(30, livro: livro), [
      a.copyWith(meta: depois),
      a.copyWith(parentId: Nullable(idTeste(31))),
      a.copyWith(groupId: idTeste(32)),
      a.copyWith(source: AnnotationSource.ink),
      a.copyWith(anchor: ancoraTeste(inicio: 9)),
      a.copyWith(refPage: 158),
      a.copyWith(chapterIndex: 30),
      a.copyWith(style: const Nullable(HighlightStyle.underline)),
      a.copyWith(fillHeight: const Nullable(FillHeight.low)),
      a.copyWith(inkLayerId: Nullable(idTeste(33))),
    ]);
    expect(AnnotationKind.fromCode('drawing'), AnnotationKind.drawing);
    expect(AnnotationSource.fromCode('ink'), AnnotationSource.ink);
    expect(HighlightStyle.fromCode('wavy'), HighlightStyle.wavy);
    expect(FillHeight.fromCode('high'), FillHeight.high);
    final l = camadaTeste(40, livro: livro);
    valor(l, camadaTeste(40, livro: livro), [
      l.copyWith(meta: depois),
      l.copyWith(anchor: ancoraTeste(inicio: 300, exato: '')),
      l.copyWith(spaceLines: 4),
      l.copyWith(strokesB64: 'QkZLMQ=='),
      l.copyWith(strokeCount: 2),
      l.copyWith(codecVersion: 2),
    ]);
    expect(InkLayerKind.fromCode('over_text'), InkLayerKind.overText);
  });

  test('Locator/TextAnchor: formatos quase válidos viram Raw* (nunca lançam, nunca perdem campo)', () {
    final sha = shaTeste;
    for (final quase in <Map<String, Object?>>[
      {
        'v': 1,
        'sha': sha,
        'spine': 1,
        'offset': 0,
        'refPage': 1,
        'progression': 0.5,
        'quote': 'x',
      },
      {
        'v': 1,
        'sha': sha,
        'spine': 1,
        'offset': 0,
        'refPage': 0,
        'progression': 0.5,
      },
      {
        'v': 1,
        'sha': 'curto',
        'spine': 1,
        'offset': 0,
        'refPage': 1,
        'progression': 0.5,
      },
      {
        'v': 2,
        'sha': sha,
        'spine': 1,
        'offset': 0,
        'refPage': 1,
        'progression': 0.5,
      },
      {
        'v': 1,
        'sha': sha,
        'spine': 1,
        'offset': 0,
        'refPage': 1,
        'progression': 1.5,
      },
    ]) {
      final l = Locator.fromJson(quase);
      expect(l, isA<RawLocator>(), reason: '$quase');
      expect(l.toJson(), quase);
      expect(l.hashCode, Locator.fromJson(quase).hashCode);
    }
    final quote = {'prefix': '', 'exact': 'x', 'suffix': ''};
    for (final quase in <Map<String, Object?>>[
      {
        'v': 1,
        'sha': sha,
        'spine': 1,
        'start': 5,
        'end': 4,
        'quote': quote,
        'refPage': 1,
      },
      {
        'v': 1,
        'sha': sha,
        'spine': 1,
        'start': 0,
        'end': 1,
        'quote': quote,
        'refPage': 1,
        'x': 1,
      },
    ]) {
      expect(TextAnchor.fromJson(quase), isA<RawAnchor>(), reason: '$quase');
    }
    final e = ancoraTeste();
    expect(e.hashCode, ancoraTeste().hashCode);
    expect({
      localizadorTeste(),
      localizadorTeste(),
      localizadorTeste(pagina: 3),
    }, hasLength(2));
    expect(
      () => EpubLocator(
        sha: sha,
        spine: 1,
        offset: 0,
        refPage: 1,
        progression: double.nan,
      ),
      throwsArgumentError,
    );
  });

  test('igualdade profunda de JSON (o Postgres reformata o texto)', () {
    expect(
      jsonEquals(
        {
          'a': [1, 2.0],
        },
        {
          'a': [1.0, 2],
        },
      ),
      isTrue,
    );
    expect(
      jsonHash({
        'a': [1, 2.0],
      }),
      jsonHash({
        'a': [1.0, 2],
      }),
    );
    expect(jsonHash({'a': 1, 'b': 2}), jsonHash({'b': 2, 'a': 1}));
    expect(jsonEquals({'a': 1}, {'a': 1, 'b': 2}), isFalse);
    expect(jsonEquals({'a': 1}, {'b': 1}), isFalse);
    expect(jsonEquals([1, 2], [1]), isFalse);
    expect(jsonEquals([1, 2], [1, 3]), isFalse);
    expect(jsonEquals('x', 'x'), isTrue);
  });

  test('marcas do sumário: valor, texto e âncora desconhecida (sem posição) primeiro', () {
    const s = MarkSymbol(AnnotationKind.highlight, '#FED170');
    expect(s.toString(), 'MarkSymbol(highlight, #FED170)');
    final cor = [
      '#FED',
      '170',
    ].join(); // instância não constante: testa o == de verdade
    final outro = MarkSymbol(AnnotationKind.highlight, cor);
    expect(identical(s, outro), isFalse);
    expect(outro, s);
    expect(outro.hashCode, s.hashCode);
    const m = ChapterMarks(count: 1, symbols: [s]);
    expect(m, const ChapterMarks(count: 1, symbols: [s]));
    expect(m.hashCode, const ChapterMarks(count: 1, symbols: [s]).hashCode);
    expect(m == const ChapterMarks(count: 2, symbols: [s]), isFalse);
    final semPosicao = grifoTeste(
      50,
      livro: livro,
      cor: '#B6ACE4',
    ).copyWith(anchor: RawAnchor(const {'page': 1}));
    final comPosicao = grifoTeste(51, livro: livro, inicio: 10);
    final marcas = AnnotationStats.chapterMarks([
      comPosicao,
      semPosicao,
    ], chapterIndex: 31);
    expect(
      marcas.symbols.first,
      const MarkSymbol(AnnotationKind.highlight, '#B6ACE4'),
    );
    expect(
      const AnnotationKindCounts(
        highlights: 1,
        notes: 2,
        handwriting: 3,
        drawings: 4,
      ).all,
      10,
    );
  });

  test('HLC: hash e texto estáveis para um aparelho com id de UUID', () {
    final h = Hlc(1, 2, '0192f6c1-8a00-7b3c-8d2e-1f0a9b8c7d6e');
    expect(Hlc.parse(h.toString()), h);
  });
}

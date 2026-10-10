import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/home/application/formatters.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/home/presentation/sections/recently_added_section.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/home_mock_repository.dart';
import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/text_lines.dart';

/// Todos os textos da seção, na ordem da tabela "Linhas de texto" da F10.
const _textIds = [
  'recent.title',
  'recent.libraryLink',
  'recent.row0.title',
  'recent.row0.subtitle',
  'recent.row0.tag',
  'recent.row1.title',
  'recent.row1.subtitle',
  'recent.row1.tag',
  'recent.row2.title',
  'recent.row2.subtitle',
  'recent.row2.tag',
];

/// Linhas da tabela da F10 (relativas à seção): texto, baseline, início, fim e largura.
const _tableLines = <String, List<(String, double, double, double, double)>>{
  'recent.title': [('Recém-chegados', 29.92, 0, 195.47, 195.47)],
  'recent.libraryLink': [('Biblioteca', 26.9, 263.81, 328, 64.19)],
  'recent.row0.title': [('Frankenstein', 98.95, 72, 160.51, 88.51)],
  'recent.row0.subtitle': [('Mary Shelley · EPUB', 118.05, 72, 188.78, 116.78)],
  'recent.row0.tag': [('Quero ler', 107.2, 222.54, 274, 51.46)],
  'recent.row1.title': [('O Alienista', 182.15, 72, 147.34, 75.34)],
  'recent.row1.subtitle': [
    ('Machado de Assis ·', 201.25, 72, 183.81, 111.81),
    ('PDF', 216.85, 72, 95.7, 23.7),
  ],
  'recent.row1.tag': [
    ('Quero', 191, 225.83, 260.28, 34.45),
    ('ler', 205.4, 225.83, 239.98, 14.15),
  ],
  'recent.row2.title': [('Senhora', 280.95, 72, 128.88, 56.88)],
  'recent.row2.subtitle': [
    ('José de Alencar · EPUB', 300.05, 72, 207.37, 135.37),
  ],
  'recent.row2.tag': [('Novo', 289.2, 244.56, 274, 29.44)],
};

Offset _sectionOrigin(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(const ValueKey('recent')));

List<AppText> _textWidgets(WidgetTester tester, String id) => tester
    .widgetList<AppText>(
      find.descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(AppText),
        matchRoot: true,
      ),
    )
    .toList();

/// Texto puro do único `AppText` sob [id].
String _textOf(WidgetTester tester, String id) =>
    _textWidgets(tester, id).single.span.toPlainText();

List<RenderAppText> _rendersOf(WidgetTester tester, String id) => [
  for (final e
      in find
          .descendant(
            of: find.byKey(ValueKey<String>(id)),
            matching: find.byType(AppText),
            matchRoot: true,
          )
          .evaluate())
    e.renderObject! as RenderAppText,
];

/// Dados que a seção lê (o mesmo `homeSnapshotProvider` do app montado).
List<RecentItem> _recentData(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(RecentlyAddedSection)),
  listen: false,
).read(homeSnapshotProvider).recent;

String _f(double v) => v.toStringAsFixed(3);

/// F10 — camada 4 (texto) da seção `recent`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F10 texto: quebras, baselines e extensões dos 11 textos da seção (13 linhas: "Machado de Assis ·"/"PDF" e "Quero"/"ler" em 2 linhas)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final id in _textIds) {
        expectTextLines(tester, id);
        reportTextLines(tester, id);
      }
      // Só dois textos têm 2 linhas: o subtítulo e o selo da linha "O Alienista" (D-12).
      final two = [
        for (final id in _textIds)
          if (kRefLayout[id]!.lines.length == 2) id,
      ];
      expect(two, ['recent.row1.subtitle', 'recent.row1.tag']);
      expect([for (final id in _textIds) ...kRefLayout[id]!.lines].length, 13);
      expect(
        kEllipsized.where((id) => id.startsWith('recent.')),
        isEmpty,
        reason: 'nenhum texto da seção é truncado com "…"',
      );
    },
  );

  testWidgets(
    'a tabela "Linhas de texto" da F10 (relativa à seção) é a mesma referência — e o Flutter fica a ≤ 0,05 px dela',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      // Origem da seção na especificação (x=20, y=1881,16) = retângulo `recent` do JSON do arquivo.
      final refOrigin = kRefLayout['recent']!.rect.topLeft;
      expect(refOrigin, const Offset(20, 1881.16));
      final origin = _sectionOrigin(tester);
      expect(origin.dx, 20);
      expect(origin.dy, moreOrLessEquals(1881.16, epsilon: 1e-3));
      expect(_tableLines.keys.toList(), _textIds);
      var worst = ('', 0.0);
      for (final MapEntry(key: id, value: lines) in _tableLines.entries) {
        final ref = kRefLayout[id]!.lines;
        final renders = _rendersOf(tester, id)
          ..sort(
            (a, b) => a
                .localToGlobal(Offset.zero)
                .dy
                .compareTo(b.localToGlobal(Offset.zero).dy),
          );
        final got = [for (final r in renders) ...r.debugLines()];
        expect(got, hasLength(lines.length), reason: id);
        expect(ref, hasLength(lines.length), reason: id);
        for (final (i, (text, baseline, left, right, width)) in lines.indexed) {
          // Tabela da fase = JSON do arquivo menos a origem da seção (2 casas decimais nos dois).
          expect(ref[i].text, text, reason: '$id L${i + 1}');
          expect(
            ref[i].baseline - refOrigin.dy,
            moreOrLessEquals(baseline, epsilon: 1e-6),
            reason: '$id L${i + 1} baseline (tabela)',
          );
          expect(
            ref[i].left - refOrigin.dx,
            moreOrLessEquals(left, epsilon: 1e-6),
            reason: '$id L${i + 1} início (tabela)',
          );
          expect(
            ref[i].right - refOrigin.dx,
            moreOrLessEquals(right, epsilon: 1e-6),
            reason: '$id L${i + 1} fim (tabela)',
          );
          expect(
            right - left,
            moreOrLessEquals(width, epsilon: 0.011),
            reason: '$id L${i + 1} largura (tabela)',
          );
          expect(got[i].text, text, reason: '$id L${i + 1}');
          final deltas = [
            ('baseline', got[i].baseline - origin.dy - baseline),
            ('início', got[i].left - origin.dx - left),
            ('fim', got[i].right - origin.dx - right),
            ('largura', got[i].right - got[i].left - (right - left)),
          ];
          debugPrint(
            '[tabela] $id L${i + 1} "$text": '
            '${deltas.map((d) => 'Δ ${d.$1} ${_f(d.$2)}').join(' | ')}',
          );
          for (final (what, d) in deltas) {
            if (d.abs() > worst.$2.abs()) worst = ('$id L${i + 1} $what', d);
            // O gate da §7 é ±0,5 (expectTextLines, 1º teste); aqui o desvio medido, bem menor.
            expect(
              d.abs(),
              lessThanOrEqualTo(0.05),
              reason: '$id L${i + 1} $what',
            );
          }
        }
      }
      debugPrint('[tabela] maior desvio: ${worst.$1} = ${_f(worst.$2)}');
    },
  );

  testWidgets(
    'strings exatas do arquivo, derivadas dos dados; um trecho por AppText, nada de "\\n"; só o subtítulo e o selo da linha 2 quebram (2 linhas), sem reticências',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final recent = _recentData(tester);
      final expected = {
        'recent.title': 'Recém-chegados',
        'recent.libraryLink': 'Biblioteca',
        'recent.row0.title': 'Frankenstein',
        'recent.row0.subtitle': 'Mary Shelley · EPUB',
        'recent.row0.tag': 'Quero ler',
        'recent.row1.title': 'O Alienista',
        'recent.row1.subtitle': 'Machado de Assis · PDF',
        'recent.row1.tag': 'Quero ler',
        'recent.row2.title': 'Senhora',
        'recent.row2.subtitle': 'José de Alencar · EPUB',
        'recent.row2.tag': 'Novo',
      };
      expect(expected.keys.toList(), _textIds);
      for (final MapEntry(key: id, value: text) in expected.entries) {
        final widgets = _textWidgets(tester, id);
        expect(widgets, hasLength(1), reason: id);
        final span = widgets.single.span as TextSpan;
        expect(span.children, isNull, reason: id);
        expect(span.text, text, reason: id);
        expect(span.text!.contains('\n'), isFalse, reason: id);
        expect(
          (widgets.single.maxLines, widgets.single.ellipsis),
          (null, false),
          reason: id,
        );
        final render = _rendersOf(tester, id).single;
        // Quebras só onde o CSS quebra (flex-shrink da linha 2).
        final wraps = id == 'recent.row1.subtitle' || id == 'recent.row1.tag';
        expect(render.debugLines(), hasLength(wraps ? 2 : 1), reason: id);
        expect(render.debugDidExceedMaxLines, isFalse, reason: id);
      }

      // Derivados dos dados pelos formatadores (F02): título, subtítulo e selo de cada linha.
      for (final (i, item) in recent.indexed) {
        expect(_textOf(tester, 'recent.row$i.title'), item.book.title);
        expect(
          _textOf(tester, 'recent.row$i.subtitle'),
          HomeFormatters.recentSubtitle(item),
        );
        expect(
          _textOf(tester, 'recent.row$i.tag'),
          HomeFormatters.recentStatusLabel(item.status),
        );
      }
      // "·" = U+00B7 com espaços dos dois lados.
      final dot = String.fromCharCode(0x00B7);
      for (var i = 0; i < 3; i++) {
        expect(_textOf(tester, 'recent.row$i.subtitle'), contains(' $dot '));
      }
    },
  );

  testWidgets(
    '10.5 linha 2 (D-12): o subtítulo quebra DEPOIS do "·" ("Machado de Assis ·" / "PDF") e o selo em "Quero" / "ler", alinhados à esquerda do bloco/selo; 2 linhas de 15,6 e de 14,4',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final subtitle = _rendersOf(tester, 'recent.row1.subtitle').single;
      final lines = subtitle.debugLines();
      expect([for (final l in lines) l.text], ['Machado de Assis ·', 'PDF']);
      expect(subtitle.size.height, moreOrLessEquals(2 * 15.6, epsilon: 1e-3));
      expect(
        lines[1].baseline - lines[0].baseline,
        moreOrLessEquals(15.6, epsilon: 1e-3),
      );
      expect(lines[0].left, lines[1].left);
      final tag = _rendersOf(tester, 'recent.row1.tag').single;
      final tagLines = tag.debugLines();
      expect([for (final l in tagLines) l.text], ['Quero', 'ler']);
      expect(tag.size.height, moreOrLessEquals(2 * 14.4, epsilon: 1e-3));
      expect(
        tagLines[1].baseline - tagLines[0].baseline,
        moreOrLessEquals(14.4, epsilon: 1e-3),
      );
      expect(tagLines[0].left, tagLines[1].left);
      // A largura de layout do texto do selo é a do selo menos o padding: 68,17 − 20 = 48,17 < 51,46.
      expect(tag.size.width, moreOrLessEquals(48.17, epsilon: 0.05));
      expect(tag.size.width, lessThan(51.46));
      // Nas outras linhas o texto cabe numa linha na largura natural (selo = texto + 20).
      for (final (i, w) in [(0, 51.46), (2, 29.44)]) {
        final r = _rendersOf(tester, 'recent.row$i.tag').single;
        expect(r.size.width, moreOrLessEquals(w, epsilon: 0.05), reason: '$i');
        expect(r.debugLines(), hasLength(1), reason: '$i');
      }
    },
  );

  testWidgets(
    'o algoritmo vem dos DADOS: com "Quero ler" na linha da Senhora (e "Novo" no Frankenstein) o texto e o selo da linha da Senhora encolhem em proporção (128,97 / 69,03) e quebram ("José de Alencar ·" / "EPUB"; "Quero" / "ler"); a linha do Frankenstein deixa de quebrar e cresce',
    (tester) async {
      setCanvasView(tester);
      final base = const HomeMockRepository().snapshot(
        HomeMockRepository.referenceNow,
      );
      final data = [
        RecentItem(
          book: base.recent[0].book,
          format: base.recent[0].format,
          status: RecentStatus.isNew,
        ),
        base.recent[1],
        RecentItem(
          book: base.recent[2].book,
          format: base.recent[2].format,
          status: RecentStatus.wantToRead,
        ),
      ];
      await pumpApp(
        tester,
        overrides: [
          homeSnapshotProvider.overrideWithValue(
            HomeSnapshot(
              now: base.now,
              user: base.user,
              continueReading: base.continueReading,
              alsoReading: base.alsoReading,
              readingDay: base.readingDay,
              dailyReview: base.dailyReview,
              forYou: base.forYou,
              club: base.club,
              recent: data,
            ),
          ),
        ],
      );
      expect(_recentData(tester), same(data));
      expect(_textOf(tester, 'recent.row0.tag'), 'Novo');
      expect(_textOf(tester, 'recent.row2.tag'), 'Quero ler');
      Rect rect(String id) => tester.getRect(find.byKey(ValueKey<String>(id)));

      // Linha 2 (Senhora + "Quero ler"): 135,37 + 71,46 = 206,83 > 198 → estouro 8,83 repartido pela base interna.
      expect(rect('recent.row2.textBlock').width, closeTo(128.97, 0.1));
      expect(rect('recent.row2.tag').width, closeTo(69.03, 0.1));
      expect(
        rect('recent.row2.textBlock').width + rect('recent.row2.tag').width,
        moreOrLessEquals(198, epsilon: 1e-9),
      );
      expect(
        [
          for (final l in _rendersOf(
            tester,
            'recent.row2.subtitle',
          ).single.debugLines())
            l.text,
        ],
        ['José de Alencar ·', 'EPUB'],
      );
      expect(
        [
          for (final l in _rendersOf(
            tester,
            'recent.row2.tag',
          ).single.debugLines())
            l.text,
        ],
        ['Quero', 'ler'],
      );
      expect(rect('recent.row2.tag').height, closeTo(38.8, 1e-3));
      // A linha cresceu? Não: a capa (66) continua mandando na altura (a coluna de texto tem 52,2 < 66).
      expect(rect('recent.row2').height, 90);

      // Linha 0 (Frankenstein + "Novo", 49,44): sobra mais espaço para o texto, que cresce para 198 − 49,44.
      expect(rect('recent.row0.tag').width, closeTo(49.44, 0.05));
      expect(rect('recent.row0.textBlock').width, closeTo(198 - 49.44, 0.05));
      expect(
        _rendersOf(tester, 'recent.row0.tag').single.debugLines(),
        hasLength(1),
      );
      // Cada linha continua centralizada na altura da capa e o bloco todo mantém a altura (91 + 91 + 90 + 8).
      expect(rect('recent.list').height, 280);
    },
  );
}

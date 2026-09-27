import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../reference/reference_layout.dart';
import '../support/canvas.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/text_lines.dart';

/// Todos os textos da seção, na ordem da tabela "Linhas de texto" da F07 (sem os trechos inline).
const _textIds = [
  'today.title',
  'today.streakPill',
  'today.dial.value',
  'today.dial.caption',
  'today.goalText.sentence',
  'today.chip.pages',
  'today.chip.highlights',
  'today.week.title',
  'today.week.total',
  'today.week.label0',
  'today.week.label1',
  'today.week.label2',
  'today.week.label3',
  'today.week.label4',
  'today.week.label5',
  'today.week.label6',
  'today.footer.text',
];

/// Linhas da tabela da F07 (relativas à seção): texto, baseline, início e fim.
const _tableLines = <String, List<(String, double, double, double)>>{
  'today.title': [('Seu dia de leitura', 43.32, 19.5, 176.26)],
  'today.streakPill': [('12 dias', 40.05, 277.76, 318)],
  'today.dial.value': [('18', 128.12, 59.57, 91.43)],
  'today.dial.caption': [('de 30 min', 144.35, 50.58, 100.42)],
  'today.goalText.sentence': [
    ('Faltam 12 min para fechar', 100.6, 149.5, 324.58),
    ('a meta de hoje.', 120.1, 149.5, 253.38),
  ],
  'today.chip.pages': [('24 páginas', 152.2, 159.7, 219.81)],
  'today.chip.highlights': [('2 destaques', 152.2, 246.21, 312.66)],
  'today.week.title': [('Esta semana', 223.35, 35, 109.69)],
  'today.week.total': [('4h 00min no total', 223.35, 217.28, 315)],
  'today.week.label0': [('S', 333.05, 48.23, 54.91)],
  'today.week.label1': [('T', 333.05, 89.5, 95.93)],
  'today.week.label2': [('Q', 333.05, 129.52, 138.2)],
  'today.week.label3': [('Q', 333.05, 170.66, 179.34)],
  'today.week.label4': [('S', 333.05, 212.8, 219.48)],
  'today.week.label5': [('S', 333.05, 253.95, 260.62)],
  'today.week.label6': [('Hoje', 333.05, 286.46, 310.4)],
  'today.footer.text': [
    ('Mais 2 dias para o selo de 14 dias', 377.85, 43.5, 237.15),
  ],
};

/// Trechos inline (`<span>` serifado e `<strong>`): id → (Key do parágrafo, trecho, baseline, início, fim),
/// relativos à seção, da tabela da F07 (o JSON do arquivo tem os mesmos valores).
const _inline = <String, (String, String, double, double, double)>{
  'today.title.serif': ('today.title', 'leitura', 43.32, 120.62, 176.26),
  'today.goalText.sentence.strong': (
    'today.goalText.sentence',
    '12 min',
    100.6,
    199.28,
    243.39,
  ),
  'today.footer.text.strong': (
    'today.footer.text',
    '2 dias',
    377.85,
    73.84,
    108.59,
  ),
};

Offset _sectionOrigin(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(const ValueKey('today')));

AppText _textWidget(WidgetTester tester, String id) => tester.widget<AppText>(
  find.descendant(
    of: find.byKey(ValueKey<String>(id)),
    matching: find.byType(AppText),
    matchRoot: true,
  ),
);

RenderAppText _renderOf(WidgetTester tester, String id) =>
    tester.renderObject<RenderAppText>(
      find.descendant(
        of: find.byKey(ValueKey<String>(id)),
        matching: find.byType(AppText),
        matchRoot: true,
      ),
    );

/// Extensão horizontal de um trecho [start, end) do parágrafo de [render], em coordenadas globais — o
/// mesmo parágrafo que o `RenderAppText` diagrama (estilo de parágrafo do span raiz, distribuição "even",
/// largura de layout = restrição justa, ou a intrínseca + 0,001 quando frouxa) e a mesma correção
/// `dx = −left` da linha alinhada à esquerda.
({double left, double right, double baseline}) _rangeExtent(
  RenderAppText render,
  InlineSpan span,
  int start,
  int end,
) {
  final root = span.style ?? const TextStyle();
  final builder = ui.ParagraphBuilder(
    root.getParagraphStyle(
      textDirection: TextDirection.ltr,
      textHeightBehavior: const TextHeightBehavior(
        leadingDistribution: TextLeadingDistribution.even,
      ),
    ),
  );
  span.build(builder);
  final p = builder.build()
    ..layout(const ui.ParagraphConstraints(width: double.infinity));
  final c = render.constraints;
  final width = c.hasTightWidth ? c.maxWidth : p.maxIntrinsicWidth + 0.001;
  p.layout(ui.ParagraphConstraints(width: width));
  final line = p.computeLineMetrics().first;
  final boxes = p.getBoxesForRange(start, end);
  final origin = render.localToGlobal(Offset.zero);
  final dx = -line.left;
  final result = (
    left:
        origin.dx +
        dx +
        boxes.map((b) => b.left).reduce((a, b) => a < b ? a : b),
    right:
        origin.dx +
        dx +
        boxes.map((b) => b.right).reduce((a, b) => a > b ? a : b),
    baseline: origin.dy + line.ascent,
  );
  p.dispose();
  return result;
}

/// F07 — camada 4 (texto) da seção `today`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F07 texto: quebras, baselines e extensões dos 17 textos da seção (referência medida no arquivo)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final id in _textIds) {
        expectTextLines(tester, id);
        reportTextLines(tester, id);
      }
    },
  );

  testWidgets(
    'a tabela "Linhas de texto" da F07 (relativa à seção) é a mesma referência — e o Flutter fica a ≤ 0,05 px dela',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final origin = _sectionOrigin(tester);
      // y soma alturas de texto (float32 do SkParagraph): ±1e-3.
      expect(origin.dx, 20);
      expect(origin.dy, moreOrLessEquals(766.76, epsilon: 1e-3));
      for (final MapEntry(key: id, value: lines) in _tableLines.entries) {
        final ref = kRefLayout[id]!.lines;
        final got = _renderOf(tester, id).debugLines();
        expect(got, hasLength(lines.length), reason: id);
        expect(ref, hasLength(lines.length), reason: id);
        for (final (i, (text, baseline, left, right)) in lines.indexed) {
          // Tabela da fase = JSON do arquivo menos a origem da seção (2 casas decimais).
          expect(ref[i].text, text, reason: '$id L${i + 1}');
          expect(
            ref[i].baseline - origin.dy,
            moreOrLessEquals(baseline, epsilon: 0.011),
            reason: '$id L${i + 1} baseline (tabela)',
          );
          expect(
            ref[i].left - origin.dx,
            moreOrLessEquals(left, epsilon: 0.011),
            reason: '$id L${i + 1} início (tabela)',
          );
          expect(
            ref[i].right - origin.dx,
            moreOrLessEquals(right, epsilon: 0.011),
            reason: '$id L${i + 1} fim (tabela)',
          );
          expect(got[i].text, text, reason: '$id L${i + 1}');
          expect(
            got[i].baseline - origin.dy,
            moreOrLessEquals(baseline, epsilon: 0.05),
            reason: '$id L${i + 1} baseline',
          );
          expect(
            got[i].left - origin.dx,
            moreOrLessEquals(left, epsilon: 0.05),
            reason: '$id L${i + 1} início',
          );
          expect(
            got[i].right - origin.dx,
            moreOrLessEquals(right, epsilon: 0.05),
            reason: '$id L${i + 1} fim',
          );
        }
      }
    },
  );

  testWidgets(
    'trechos inline ("leitura", "12 min", "2 dias"): mesma baseline da linha e extensão do arquivo (±0,05)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final origin = _sectionOrigin(tester);
      for (final MapEntry(key: id, value: (parent, text, baseline, left, right))
          in _inline.entries) {
        final widget = _textWidget(tester, parent);
        final render = _renderOf(tester, parent);
        final plain = widget.span.toPlainText();
        final start = plain.indexOf(text);
        expect(start, greaterThanOrEqualTo(0), reason: id);
        expect(plain.indexOf(text, start + 1), -1, reason: '$id: trecho único');
        final got = _rangeExtent(
          render,
          widget.span,
          start,
          start + text.length,
        );
        // A reconstrução reproduz a linha do AppText (mesma largura, mesmo dx, mesma baseline).
        final line = render.debugLines().first;
        expect(got.baseline, moreOrLessEquals(line.baseline, epsilon: 1e-9));
        debugPrint(
          '[texto] $id "$text": baseline ${(got.baseline - origin.dy).toStringAsFixed(3)} (arquivo $baseline) | '
          'início ${(got.left - origin.dx).toStringAsFixed(3)} (arquivo $left) | '
          'fim ${(got.right - origin.dx).toStringAsFixed(3)} (arquivo $right)',
        );
        expect(
          got.baseline - origin.dy,
          moreOrLessEquals(baseline, epsilon: 0.05),
          reason: '$id baseline',
        );
        expect(
          got.left - origin.dx,
          moreOrLessEquals(left, epsilon: 0.05),
          reason: '$id início',
        );
        expect(
          got.right - origin.dx,
          moreOrLessEquals(right, epsilon: 0.05),
          reason: '$id fim',
        );
        // Mesmo retângulo horizontal do JSON do arquivo (o inline não entra no kRefLayout).
      }
    },
  );

  testWidgets(
    'strings exatas do arquivo, derivadas dos dados, e tokens dos trechos mistos',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final expected = {
        'today.title': 'Seu dia de leitura',
        'today.streakPill': '12 dias',
        'today.dial.value': '18',
        'today.dial.caption': 'de 30 min',
        'today.goalText.sentence': 'Faltam 12 min para fechar a meta de hoje.',
        'today.chip.pages': '24 páginas',
        'today.chip.highlights': '2 destaques',
        'today.week.title': 'Esta semana',
        'today.week.total': '4h 00min no total',
        'today.week.label0': 'S',
        'today.week.label1': 'T',
        'today.week.label2': 'Q',
        'today.week.label3': 'Q',
        'today.week.label4': 'S',
        'today.week.label5': 'S',
        'today.week.label6': 'Hoje',
        'today.footer.text': 'Mais 2 dias para o selo de 14 dias',
      };
      expect(expected.keys.toList(), _textIds);
      for (final MapEntry(key: id, value: text) in expected.entries) {
        final widget = _textWidget(tester, id);
        expect(widget.span.toPlainText(), text, reason: id);
        // Nenhum "\n" e nenhum limite de linhas/reticências no arquivo.
        expect(text.contains('\n'), isFalse, reason: id);
        expect((widget.maxLines, widget.ellipsis), (null, false), reason: id);
        expect(
          _renderOf(tester, id).debugDidExceedMaxLines,
          isFalse,
          reason: id,
        );
      }

      // Parágrafos mistos: um span raiz com o estilo do elemento e o trecho com o estilo do <span>/<strong>.
      void expectMixed(
        String id,
        TextStyle rootStyle,
        List<(String, TextStyle?)> parts,
      ) {
        final span = _textWidget(tester, id).span as TextSpan;
        expect(span.style, same(rootStyle), reason: id);
        final children = span.children!.cast<TextSpan>();
        expect(
          [(span.text, null), for (final c in children) (c.text, c.style)],
          [for (final (i, (t, s)) in parts.indexed) (t, i == 0 ? null : s)],
          reason: id,
        );
        for (final (i, (_, s)) in parts.indexed.skip(1)) {
          if (s != null) expect(children[i - 1].style, same(s), reason: id);
        }
      }

      expectMixed('today.title', AppTextStyles.cardTitleM, [
        ('Seu dia de ', null),
        ('leitura', AppTextStyles.cardSerifM),
      ]);
      expectMixed('today.goalText.sentence', AppTextStyles.goalSentence, [
        ('Faltam ', null),
        ('12 min', AppTextStyles.goalSentenceStrong),
        (' para fechar a meta de hoje.', null),
      ]);
      expectMixed('today.footer.text', AppTextStyles.body13Semi, [
        ('Mais ', null),
        ('2 dias', AppTextStyles.body13Bold),
        (' para o selo de 14 dias', null),
      ]);
    },
  );

  testWidgets(
    '7.4 quebra "Faltam 12 min para fechar" / "a meta de hoje." em 181: com o "a" a 1ª linha estouraria por 5,55',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final widget = _textWidget(tester, 'today.goalText.sentence');
      final render = _renderOf(tester, 'today.goalText.sentence');
      expect(render.size.width, 181);
      expect(render.debugLines().map((l) => l.text), [
        'Faltam 12 min para fechar',
        'a meta de hoje.',
      ]);
      // Largura de "Faltam 12 min para fechar a" no mesmo parágrafo misto, numa linha sem limite.
      final plain = widget.span.toPlainText();
      final end = plain.indexOf('a meta') + 1;
      final unconstrained = _naturalPrefixWidth(widget.span, end);
      debugPrint(
        '[texto] "Faltam 12 min para fechar a" mede ${unconstrained.toStringAsFixed(3)} → estoura 181 por '
        '${(unconstrained - 181).toStringAsFixed(3)} (arquivo: 5,55)',
      );
      expect(unconstrained - 181, moreOrLessEquals(5.55, epsilon: 0.05));
    },
  );
}

/// Largura, numa linha sem limite, do prefixo [0, end) do parágrafo misto [span].
double _naturalPrefixWidth(InlineSpan span, int end) {
  final root = span.style ?? const TextStyle();
  final builder = ui.ParagraphBuilder(
    root.getParagraphStyle(
      textDirection: TextDirection.ltr,
      textHeightBehavior: const TextHeightBehavior(
        leadingDistribution: TextLeadingDistribution.even,
      ),
    ),
  );
  span.build(builder);
  final p = builder.build()
    ..layout(const ui.ParagraphConstraints(width: double.infinity));
  final boxes = p.getBoxesForRange(0, end);
  final line = p.computeLineMetrics().first;
  final width =
      boxes.map((b) => b.right).reduce((a, b) => a > b ? a : b) - line.left;
  p.dispose();
  return width;
}

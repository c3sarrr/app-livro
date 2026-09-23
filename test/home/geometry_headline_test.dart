import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/geometry.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

const _headline = ValueKey<String>('headline');

Finder get _lines =>
    find.descendant(of: find.byKey(_headline), matching: find.byType(AppText));

/// Início da linha no parágrafo "cru" do SkParagraph (sem a correção do AppText): o motor desloca a
/// linha alinhada à esquerda em metade do letter-spacing do 1º caractere.
double _rawLineLeft(TextStyle style, String text, double width) {
  final builder =
      ui.ParagraphBuilder(
          style.getParagraphStyle(
            textHeightBehavior: const TextHeightBehavior(
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        )
        ..pushStyle(style.getTextStyle())
        ..addText(text);
  final paragraph = builder.build()
    ..layout(ui.ParagraphConstraints(width: width));
  final left = paragraph.computeLineMetrics().single.left;
  paragraph.dispose();
  return left;
}

/// F04 — camada 1 (geometria) e construção da seção `headline`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F04 geometria: headline (20, 134, 350, 90,16) dentro da tolerância (canvas 390×2390)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final ids = idsOfSection('headline').toList();
      // `headline.serif` é inline (o <span> da linha 2): sem retângulo próprio na referência.
      expect(ids, ['headline']);
      expectGeometry(tester, ids);
      reportGeometry(tester, ids);
    },
  );

  testWidgets(
    '4.1 construção: Semantics(container, header, h1, label, excludeSemantics) > Column(Key headline, stretch) > 2 AppText',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final semantics = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.byKey(_headline),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.child, isA<Column>());
      expect(semantics.child!.key, _headline);
      expect(semantics.container, isTrue);
      expect(semantics.explicitChildNodes, isFalse);
      expect(semantics.excludeSemantics, isTrue);
      expect(semantics.properties.header, isTrue);
      expect(semantics.properties.headingLevel, 1);
      expect(semantics.properties.label, 'Continue sua história.');

      final column = tester.widget<Column>(find.byKey(_headline));
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
      expect(column.spacing, 0);
      expect(column.children, hasLength(2));
      final texts = column.children.cast<AppText>();
      expect((texts[0].span as TextSpan).text, 'Continue');
      expect(texts[0].span.style, same(AppTextStyles.displayXL));
      expect((texts[1].span as TextSpan).text, 'sua história.');
      expect(texts[1].span.style, same(AppTextStyles.displaySerifXL));
      // Uma linha por AppText, sem limite de linhas nem reticências.
      for (final text in texts) {
        expect(text.maxLines, isNull);
        expect(text.ellipsis, isFalse);
        expect(text.textAlign, TextAlign.start);
      }
    },
  );

  testWidgets(
    '4.1 linhas de 41,16 e 49 (0,98 × 42 / 50, "even"), empilhadas sem vão, largura tight 350 a partir de x = 20',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      expect(_lines, findsNWidgets(2));
      final l1 = tester.getRect(_lines.at(0)),
          l2 = tester.getRect(_lines.at(1));
      final section = tester.getRect(find.byKey(_headline));
      expect(l1.height, moreOrLessEquals(41.16, epsilon: 1e-3));
      expect(l2.height, moreOrLessEquals(49, epsilon: 1e-3));
      expect(l1.top, section.top);
      expect(l2.top, l1.bottom);
      expect(l2.bottom, section.bottom);
      expect(section.height, moreOrLessEquals(90.16, epsilon: 1e-3));
      for (final r in [l1, l2]) {
        expect((r.left, r.width), (20.0, 350.0));
      }
      debugPrint(
        '[headline] seção $section | linha 1 ${l1.top} + ${l1.height} | linha 2 ${l2.top} + ${l2.height}',
      );
    },
  );

  testWidgets(
    '4.1 correção de meio letter-spacing em contexto: as duas linhas começam em 20,00 ±0,05 (sem a correção: 19,30 e 19,70)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final starts = [
        for (var i = 0; i < 2; i++)
          tester
              .renderObject<RenderAppText>(_lines.at(i))
              .debugLines()
              .single
              .left,
      ];
      final raw = [
        20 + _rawLineLeft(AppTextStyles.displayXL, 'Continue', 350),
        20 + _rawLineLeft(AppTextStyles.displaySerifXL, 'sua história.', 350),
      ];
      debugPrint(
        '[meio letter-spacing] início AppText ${starts.map((v) => v.toStringAsFixed(3))} | '
        'cru (sem correção) ${raw.map((v) => v.toStringAsFixed(3))}',
      );
      for (final start in starts) {
        expect(start, moreOrLessEquals(20, epsilon: 0.05));
      }
      expect(raw[0], moreOrLessEquals(19.30, epsilon: 1e-3));
      expect(raw[1], moreOrLessEquals(19.70, epsilon: 1e-3));
    },
  );
}

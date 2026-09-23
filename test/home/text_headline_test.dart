import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/text_lines.dart';

const _headline = ValueKey<String>('headline');

Finder get _lines =>
    find.descendant(of: find.byKey(_headline), matching: find.byType(AppText));

/// F04 — camada 4 (texto) da seção `headline`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F04 texto: "Continue" / "sua história." — baselines 168,44 e 216,66, extensões 20→190,69 e 20→239,65',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      // Junta as linhas dos dois AppText sob a Key (ordem vertical) e confere como um parágrafo só.
      expectTextLines(tester, 'headline');
      reportTextLines(tester, 'headline');
      final lines = [
        for (var i = 0; i < 2; i++)
          ...tester.renderObject<RenderAppText>(_lines.at(i)).debugLines(),
      ];
      expect(lines.map((l) => l.text), ['Continue', 'sua história.']);
      expect(lines[0].baseline, moreOrLessEquals(168.44, epsilon: 0.5));
      expect(lines[1].baseline, moreOrLessEquals(216.66, epsilon: 0.5));
      // A largura inclui o letter-spacing após o último caractere, como no navegador.
      expect(
        lines[0].right - lines[0].left,
        moreOrLessEquals(170.69, epsilon: 1.0),
      );
      expect(
        lines[1].right - lines[1].left,
        moreOrLessEquals(219.65, epsilon: 1.0),
      );
      debugPrint(
        '[headline] larguras ${(lines[0].right - lines[0].left).toStringAsFixed(3)} (arquivo 170.69) e '
        '${(lines[1].right - lines[1].left).toStringAsFixed(3)} (arquivo 219.65)',
      );
    },
  );

  testWidgets(
    'strings exatas do arquivo: "ó" pré-composto (U+00F3), ponto final no itálico, sem quebra forçada',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      final texts = [
        for (var i = 0; i < 2; i++)
          (tester.widget<AppText>(_lines.at(i)).span as TextSpan).text!,
      ];
      expect(texts, ['Continue', 'sua história.']);
      final serif = texts[1];
      expect(serif.codeUnits, contains(0x00F3));
      expect(serif.codeUnits, isNot(contains(0x0301))); // sem acento combinante
      expect(serif.endsWith('.'), isTrue); // o "." pertence ao <span> itálico
      // A quebra é o <br> = dois parágrafos: nenhum "\n" nas strings.
      for (final text in texts) {
        expect(text.contains('\n'), isFalse);
      }
      // Uma linha cada, sem reticências.
      for (var i = 0; i < 2; i++) {
        final render = tester.renderObject<RenderAppText>(_lines.at(i));
        expect(render.debugLines(), hasLength(1), reason: texts[i]);
        expect(render.debugDidExceedMaxLines, isFalse, reason: texts[i]);
      }
    },
  );
}

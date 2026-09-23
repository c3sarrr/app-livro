import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/geometry_report.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/text_lines.dart';

/// F03 — camada 4 (texto) da seção `header`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'F03 texto: quebras, baselines (29,94 / 18,45 / 37,90 + 62) e extensão horizontal',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      for (final id in ['header.avatar', 'header.greeting', 'header.name']) {
        expectTextLines(tester, id);
        reportTextLines(tester, id);
      }
    },
  );

  testWidgets(
    'strings exatas do arquivo, derivadas dos dados (inicial, saudação às 20:00, nome)',
    (tester) async {
      setCanvasView(tester);
      await pumpApp(tester);
      String textOf(String id) =>
          (tester
                      .widget<AppText>(
                        find.descendant(
                          of: find.byKey(ValueKey<String>(id)),
                          matching: find.byType(AppText),
                          matchRoot: true,
                        ),
                      )
                      .span
                  as TextSpan)
              .text!;
      expect(textOf('header.avatar'), 'M');
      expect(textOf('header.greeting'), 'Boa noite,');
      expect(textOf('header.name'), 'Marina');
      // Linha única cada, sem reticências.
      for (final id in ['header.greeting', 'header.name']) {
        final render = tester.renderObject<RenderAppText>(
          find.byKey(ValueKey<String>(id)),
        );
        expect(render.debugLines(), hasLength(1), reason: id);
        expect(render.debugDidExceedMaxLines, isFalse, reason: id);
      }
    },
  );
}

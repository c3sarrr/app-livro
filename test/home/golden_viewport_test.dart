import 'package:flutter_test/flutter_test.dart';

import '../reference/inicio2/referencias_inicio2.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/fase_inicio.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';

/// Golden do viewport: desde a T03 (D-241) a prancha 60 — a Início num aparelho 390×844 (safe 47/34 → 1170×2532
/// @3x) rolada de 930, com o degradê e a barra presos por cima do conteúdo. É comparado, via
/// `tools/compare_images.py`, com `docs/design/medicao/inicio2/png/060_inicio_grifos_de_hoje_390x844@3x.png` (até a
/// T03, a primeira dobra da v1 contra uma composição derivada, sem prancha própria). A geometria e o texto da mesma
/// tela estão em `test/home/inicio01/l60_test.dart`.
void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'golden viewport: a prancha 60 (390×844, safe 47/34, rolada 930)',
    (tester) async {
      await abrirInicio01(tester, prancha: kRef60, safeTop: 47, safeBottom: 34);
      homeScrollPosition(tester).jumpTo(930);
      await tester.pumpAndSettle();
      final image = await captureAt(tester, find.byKey(goldenRootKey));
      expect((image.width, image.height), (1170, 2532));
      await expectLater(
        image,
        matchesGoldenFile('../golden/goldens/inicio_viewport@3x.png'),
      );
    },
  );
}

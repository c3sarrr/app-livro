import 'package:flutter_test/flutter_test.dart';

import '../reference/inicio2_larguras/referencias_inicio2_larguras.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/fase_inicio.dart';
import '../support/load_fonts.dart';

/// Goldens @2x das larguras 360 e 430 (F13 · 13.3; desde a T03 a prancha 01 medida nessas larguras, canvas de 2650),
/// comparados via `tools/compare_images.py` com
/// `docs/design/medicao/inicio2_larguras/png/001_inicio_w360_360x2650@2x.png` / `…_w430_430x2650@2x.png`. A
/// geometria e o texto das duas larguras estão em `test/home/inicio01/pagina_test.dart`.
void main() {
  setUpAll(loadAppFonts);

  for (final (tela, width, pngWidth) in [
    ('01w360', 360, 720),
    ('01w430', 430, 860),
  ]) {
    testWidgets('golden largura $width @2x (prancha 01)', (tester) async {
      final prancha = kRefInicio2Larguras[tela]!;
      expect(prancha.canvas.width, width);
      await abrirInicio01(tester, prancha: prancha, dpr: 2);
      final image = await captureAt(
        tester,
        find.byKey(goldenRootKey),
        pixelRatio: 2,
      );
      expect((image.width, image.height), (pngWidth, 5300));
      await expectLater(
        image,
        matchesGoldenFile('../golden/goldens/inicio_w$width@2x.png'),
      );
    });
  }
}

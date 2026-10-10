import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/fase_inicio.dart';
import '../support/load_fonts.dart';

/// Golden do canvas inteiro da prancha 01 (390×2650 @3x = 1170×7950; T03, D-240), gerado com `--update-goldens` e
/// comparado com a prancha via `tools/compare_images.py` contra
/// `docs/design/medicao/inicio2/png/001_inicio_390x2650@3x.png` (prompt mestre §7). Captura a 3× com `captureAt`: o
/// `matchesGoldenFile(Finder)` capturaria a 1× (ver F01).
void main() {
  setUpAll(loadAppFonts);

  testWidgets('golden canvas (prancha 01)', (tester) async {
    await abrirInicio01(tester);
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 7950));
    await expectLater(
      image,
      matchesGoldenFile('../golden/goldens/inicio_canvas@3x.png'),
    );
  });
}

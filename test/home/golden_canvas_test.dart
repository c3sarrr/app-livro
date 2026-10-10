import 'package:app_leitura/app/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';

/// Golden do canvas inteiro (390×2390 @3x = 1170×7170), gerado a cada fase com `--update-goldens` e
/// comparado com a referência do HTML via `tools/compare_images.py` (prompt mestre §7).
/// Captura a 3× com `captureAt`: o `matchesGoldenFile(Finder)` capturaria a 1× (ver F01).
void main() {
  setUpAll(loadAppFonts);

  testWidgets('golden canvas', (tester) async {
    setCanvasView(tester);
    await precacheAppIcons(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overridesDoMundo,
        child: const RepaintBoundary(key: goldenRootKey, child: App.forTests()),
      ),
    );
    await tester.pumpAndSettle();
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 7170));
    await expectLater(
      image,
      matchesGoldenFile('../golden/goldens/inicio_canvas@3x.png'),
    );
  });
}

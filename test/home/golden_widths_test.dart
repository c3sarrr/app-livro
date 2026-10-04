import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/overrides_do_mundo.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';

/// Goldens @2x das larguras 360 e 430 (F13 · 13.3), comparados via `tools/compare_images.py` com
/// `referencia/png/inicio_w360x2390@2x.png` / `inicio_w430x2390@2x.png` (modo `--layout` com o JSON da largura).
void main() {
  setUpAll(loadAppFonts);

  for (final (width, pngWidth) in [(360, 720), (430, 860)]) {
    testWidgets('golden largura $width @2x', (tester) async {
      setCanvasView(tester, logical: Size(width.toDouble(), 2390), dpr: 2);
      await precacheSvgs(tester, AppIcons.all);
      await tester.pumpWidget(
        ProviderScope(
          overrides: overridesDoMundo,
          child: const RepaintBoundary(
            key: goldenRootKey,
            child: App.forTests(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final image = await captureAt(
        tester,
        find.byKey(goldenRootKey),
        pixelRatio: 2,
      );
      expect((image.width, image.height), (pngWidth, 4780));
      await expectLater(
        image,
        matchesGoldenFile('../golden/goldens/inicio_w$width@2x.png'),
      );
    });
  }
}

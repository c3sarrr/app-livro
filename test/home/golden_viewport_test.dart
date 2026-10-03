import 'package:app_leitura/app/app.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';

/// Golden do viewport (F11): a primeira dobra num aparelho 390×844 (safe 47/34 → 1170×2532 @3x) com a navegação
/// fixa por cima do conteúdo. É comparado, via `tools/compare_images.py`, com
/// `referencia/png/inicio_viewport_390x844_DERIVADA@3x.png` (composição derivada: não existe como tela separada
/// no arquivo). Mesma captura a 3× do golden do canvas.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('golden viewport 390×844 (safe 47/34)', (tester) async {
    setCanvasView(
      tester,
      logical: const Size(390, 844),
      safeTop: 47,
      safeBottom: 34,
    );
    await precacheSvgs(tester, AppIcons.all);
    await tester.pumpWidget(
      const ProviderScope(
        child: RepaintBoundary(key: goldenRootKey, child: App.forTests()),
      ),
    );
    await tester.pumpAndSettle();
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 2532));
    await expectLater(
      image,
      matchesGoldenFile('../golden/goldens/inicio_viewport@3x.png'),
    );
  });
}

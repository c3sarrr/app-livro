import 'package:app_leitura/core/design_system/gallery/design_system_gallery.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/precache_svgs.dart';

const _key = Key('galeria');

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    '1.8 DesignSystemGallery: golden de revisão @3x (paleta, 46 estilos, ícones, pintores, primitivos)',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(390, 8000) * 3;
      addTearDown(tester.view.reset);
      await precacheAppIcons(tester);
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: _key,
              child: SizedBox(
                width: 390,
                child: ColoredBox(
                  color: AppColors.paper,
                  child: DesignSystemGalleryContent(),
                ),
              ),
            ),
          ),
        ),
      );
      final size = tester.getSize(find.byKey(_key));
      debugPrint(
        '[galeria] tamanho lógico $size → PNG @3x ${(size.width * 3).ceil()}×${(size.height * 3).ceil()}',
      );
      // Todos os 18 ícones aparecem (sparkleSolid em 14 e 16).
      final assets = tester
          .widgetList<SvgPicture>(find.byType(SvgPicture))
          .map((p) => (p.bytesLoader as SvgAssetLoader).assetName)
          .toSet();
      expect(assets, containsAll(AppIcons.all));
      expect(find.byType(AppSvg), findsAtLeastNWidgets(19));
      await expectLater(
        await captureAt(tester, find.byKey(_key)),
        matchesGoldenFile('../golden/goldens/ds_galeria@3x.png'),
      );
    },
  );

  testWidgets(
    'DesignSystemGallery rola num aparelho 390 × 844 sem erros de layout',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      tester.view.physicalSize = const Size(390, 844) * 3;
      addTearDown(tester.view.reset);
      await precacheAppIcons(tester);
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: DesignSystemGallery(),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -3000),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}

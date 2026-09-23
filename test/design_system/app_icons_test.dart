import 'dart:io';

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/capture.dart';
import '../support/precache_svgs.dart';

/// Espessura (px lógicos) da tinta na coluna [x]: soma da cobertura (canal vermelho sobre branco).
double _inkThickness(
  Uint8List rgba,
  int width,
  int height,
  int x,
  double pixelRatio,
) {
  var sum = 0.0;
  for (var y = 0; y < height; y++) {
    final i = (y * width + x) * 4;
    final alpha = rgba[i + 3] / 255;
    final red = rgba[i] * alpha + 255 * (1 - alpha);
    sum += ((255 - red) / (255 - 0x1A)).clamp(0.0, 1.0);
  }
  return sum / pixelRatio;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1.5 AppIcons', () {
    test('18 caminhos únicos = todos os SVGs de assets/icons', () {
      expect(AppIcons.all, hasLength(18));
      expect(AppIcons.all.toSet(), hasLength(18));
      final files = Directory('assets/icons')
          .listSync()
          .whereType<File>()
          .map((f) => 'assets/icons/${f.uri.pathSegments.last}')
          .where((p) => p.endsWith('.svg'))
          .toSet();
      expect(AppIcons.all.toSet(), files);
    });

    test('cada ícone está declarado no pubspec e é byte a byte igual ao do pacote de handoff', () async {
      for (final path in AppIcons.all) {
        final bundled = (await rootBundle.load(path)).buffer.asUint8List();
        final handoff = File('design_handoff/$path').readAsBytesSync();
        expect(bundled, handoff, reason: path);
      }
    });
  });

  group('1.5 AppSvg', () {
    testWidgets('tamanho de uso, sem colorFilter, fora da árvore semântica', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await precacheAppIcons(tester);
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: AppSvg(AppIcons.bell, size: 22),
          ),
        ),
      );
      expect(tester.getSize(find.byType(AppSvg)), const Size(22, 22));
      final picture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(
        (picture.width, picture.height, picture.colorFilter),
        (22.0, 22.0, null),
      );
      expect(
        find.ancestor(
          of: find.byType(SvgPicture),
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      expect(tester.getSemantics(find.byType(AppSvg)), matchesSemantics());
      handle.dispose();
    });

    testWidgets('com precacheAppIcons o ícone já sai pintado no 1º quadro', (
      tester,
    ) async {
      await precacheAppIcons(tester);
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: Key('k'),
              child: ColoredBox(
                color: AppColors.paper,
                child: AppSvg(AppIcons.bell, size: 22),
              ),
            ),
          ),
        ),
      );
      final image = await captureAt(tester, find.byKey(const Key('k')));
      final rgba = await rgbaOf(tester, image);
      var ink = 0;
      for (var i = 0; i < rgba.length; i += 4) {
        if (rgba[i] < 0x60) ink++;
      }
      debugPrint(
        '[ícone] sino 22 @3x: $ink pixels de tinta (${image.width}×${image.height})',
      );
      expect(image.width, 66);
      expect(ink, greaterThan(150));
    });

    testWidgets(
      'traço escala como no navegador: seta 18 px (traço 2 no viewBox 24) → 1,5 px',
      (tester) async {
        await precacheAppIcons(tester);
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: Key('k'),
                child: ColoredBox(
                  color: Color(0xFFFFFFFF),
                  child: AppSvg(AppIcons.arrowRight, size: 18),
                ),
              ),
            ),
          ),
        );
        final image = await captureAt(
          tester,
          find.byKey(const Key('k')),
          pixelRatio: 10,
        );
        final rgba = await rgbaOf(tester, image);
        // "M5 12h14": na coluna x = 6 (viewBox 8) só a haste horizontal é atravessada.
        final thickness = _inkThickness(
          rgba,
          image.width,
          image.height,
          60,
          10,
        );
        debugPrint(
          '[ícone] seta 18: espessura da haste ${thickness.toStringAsFixed(3)} px (esperado 2 × 18/24 = 1,5)',
        );
        expect(thickness, moreOrLessEquals(1.5, epsilon: 0.05));
      },
    );
  });
}

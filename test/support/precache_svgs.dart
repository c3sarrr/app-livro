import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// O flutter_svg carrega de forma assíncrona; sem pré-cache o golden sai sem ícones.
Future<void> precacheSvgs(WidgetTester tester, Iterable<String> assets) async {
  await tester.runAsync(() async {
    for (final asset in assets) {
      final loader = SvgAssetLoader(asset);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }
  });
}

/// Pré-cache de todos os ícones do design system (`AppIcons.all`, F01 1.5).
Future<void> precacheAppIcons(WidgetTester tester) =>
    precacheSvgs(tester, AppIcons.all);

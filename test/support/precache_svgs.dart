import 'dart:ui' show Color;

import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// O flutter_svg carrega de forma assíncrona; sem pré-cache o golden sai sem ícones. Com [colors], a chave da troca
/// de cor do `AppSvg` (G16: as ilustrações com a `brand` e a tinta).
Future<void> precacheSvgs(
  WidgetTester tester,
  Iterable<String> assets, {
  Map<Color, Color>? colors,
}) async {
  await tester.runAsync(() async {
    for (final asset in assets) {
      final loader = appSvgLoader(asset, colors: colors);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }
  });
}

/// Pré-cache de todos os ícones do design system (`AppIcons.all`, F01 1.5; T03: e os da Início nova).
Future<void> precacheAppIcons(WidgetTester tester) =>
    precacheSvgs(tester, [...AppIcons.all, ...AppIconsInicio.all]);

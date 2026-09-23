import 'package:app_leitura/core/design_system/tokens/app_radii.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/tokens/app_spacing.dart';
import 'package:app_leitura/core/design_system/tokens/app_strokes.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Subfase 1.2 — traços, sombras, raios e espaçamentos exatamente como no arquivo (sem arredondar).
void main() {
  test('AppStrokes: 1,5 / 1,2 / 1,0', () {
    expect(AppStrokes.regular, 1.5);
    expect(AppStrokes.thin, 1.2);
    expect(AppStrokes.divider, 1.0);
  });

  test('AppShadows: deslocamentos das sombras duras', () {
    expect(AppShadows.hard4, const Offset(4, 4));
    expect(AppShadows.hard3, const Offset(3, 3));
    expect(AppShadows.hard2, const Offset(2, 2));
    expect(AppShadows.drop4, const Offset(0, 4));
  });

  test('AppRadii: raios do arquivo (ordem CSS TL, TR, BR, BL nas capas)', () {
    expect(AppRadii.pill, 999);
    expect(AppRadii.card, 28);
    expect(AppRadii.cardM, 22);
    expect(AppRadii.list, 24);
    expect(AppRadii.navItem, 20);
    expect(
      AppRadii.coverL,
      const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
        bottomLeft: Radius.circular(4),
      ),
    );
    expect(
      AppRadii.coverS,
      const BorderRadius.only(
        topLeft: Radius.circular(3),
        topRight: Radius.circular(7),
        bottomRight: Radius.circular(7),
        bottomLeft: Radius.circular(3),
      ),
    );
  });

  test('AppSpacing: gutter, insets, margens das seções e navegação', () {
    expect(AppSpacing.gutter, 20);
    expect(AppSpacing.topInsetMin, 62);
    expect(AppSpacing.bottomPadding, 140);
    expect(AppSpacing.sectionGaps, [24, 24, 32, 36, 40, 40, 40]);
    expect(AppSpacing.navSide, 16);
    expect(AppSpacing.navBottomMin, 30);
    expect(AppSpacing.navHeight, 70);
  });
}

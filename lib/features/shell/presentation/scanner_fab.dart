import 'package:flutter/widgets.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';

/// FAB "Scanner" (F11 11.4): círculo 60×60 `#FED170`, borda 1,5, sombra dura (0, 4), ícone de código de barras 28
/// (traço 1,9 já no SVG).
///
/// No HTML é `position: absolute; top: -30px` a partir do item da barra: sobe 20,5 px acima da borda superior
/// dela e pinta por cima. Por isso o `MainShell` o posiciona como IRMÃO da barra, depois dela: o toque funciona
/// em toda a área do círculo, inclusive na parte que sai da barra.
///
/// Semântica: `ExcludeSemantics`. O nome acessível é do item "Scanner" da barra (`aria-label`); o FAB chama o
/// mesmo `onTap`, então o leitor de tela encontra um único nó, sem leitura duplicada.
class ScannerFab extends StatelessWidget {
  const ScannerFab({super.key, required this.onTap});

  final VoidCallback? onTap;

  /// Diâmetro (`width`/`height`: 60).
  static const double size = 60;

  /// Ícone do código de barras.
  static const double iconSize = 28;

  /// `top: -30px` em relação ao item da barra.
  static const double itemTop = -30;

  /// `bottom` do FAB no `MainShell`, dado o `bottom` da barra: o topo do item fica a borda (1,5) + padding (8) abaixo
  /// do topo da barra, e o topo do FAB a 30 px acima dele → `navBottom + 30,5` (topo = 20,5 px acima da barra).
  static double bottom(double navBottom) =>
      navBottom +
      AppSpacing.navHeight -
      (AppStrokes.regular + 8 + itemTop) -
      size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Pressable(
      onTap: onTap,
      child: NeoBox(
        width: size,
        height: size,
        color: AppColors.sun,
        border: const BorderSide(
          width: AppStrokes.regular,
          color: AppColors.ink,
        ),
        radius: BorderRadius.circular(AppRadii.pill),
        shadow: AppShadows.drop4,
        child: const Center(
          child: AppSvg(
            AppIcons.navScanner,
            size: iconSize,
            key: ValueKey('nav.scanner.icon'),
          ),
        ),
      ),
    ),
  );
}

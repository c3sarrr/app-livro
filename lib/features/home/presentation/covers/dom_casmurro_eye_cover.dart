import 'package:flutter/widgets.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_illustrations_inicio.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_shadows.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da capa "Dom Casmurro" do herói da prancha 01 (L01a2): 104×156, violeta, borda 1,5, raio 4/10/10/4, sombra
/// dura 3/3 e `overflow: hidden`. Dentro da borda (101×153): o desenho `il_capa_dom_casmurro.svg` (céu, olho e mar;
/// viewBox 96×144 com `xMidYMid slice` → escala 1,0625 e 0,5 recortado de cada lado) e, por cima, a lombada de 7
/// `rgba(0,0,0,.22)`. O SVG traz três `<text>` que o flutter_svg desenharia com a fonte do sistema: o desenho entra sem
/// eles e os textos são `AppText` nas mesmas baselines do viewBox × 1,0625. A rotação −3° fica na seção, em volta
/// desta arte.
class DomCasmurroEyeCover extends StatelessWidget {
  const DomCasmurroEyeCover({super.key});

  /// Escala do `slice`: max(101 ÷ 96, 153 ÷ 144).
  static const double scale = 153 / 144;

  /// Deslocamento horizontal do `slice` (o desenho de 102 centrado em 101).
  static const double dx = (101 - 96 * scale) / 2;

  /// Um texto do SVG com a baseline em ([x], [y]) do viewBox.
  static Widget _texto(String text, double x, double y, TextStyle style) =>
      Positioned(
        left: x * scale + dx,
        top: 0,
        child: Baseline(
          baseline: y * scale,
          baselineType: TextBaseline.alphabetic,
          child: AppText(text, style: style),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      width: 104,
      height: 156,
      color: AppColors.violet,
      border: const BorderSide(width: 1.5, color: AppColors.ink),
      radius: AppRadii.coverL,
      shadow: AppShadows.hard3,
      clip: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const AppSvg(
            AppIllustrationsInicio.coverDomCasmurro,
            key: ValueKey('hero.cover.art'),
            size: 101,
            height: 153,
            fit: BoxFit.cover,
          ),
          _texto('Dom', 12, 24, AppTextStyles.coverEyeTitle),
          _texto('Casmurro', 12, 41, AppTextStyles.coverEyeTitle),
          _texto('MACHADO DE ASSIS', 12.5, 51, AppTextStyles.coverEyeAuthor),
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 7,
            child: NeoBox(
              key: ValueKey('hero.cover.spine'),
              color: AppColors.spine22,
            ),
          ),
        ],
      ),
    );
  }
}

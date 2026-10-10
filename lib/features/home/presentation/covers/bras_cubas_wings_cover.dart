import 'package:flutter/widgets.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_illustrations_inicio.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da capa "Memórias Póstumas de Brás Cubas" com asas, a da mini-barra do cronômetro da prancha 01b (L01b.2,
/// R10 — só a fixture a desenha; com dados reais, a capa do livro na mesma moldura): 32×48, azul `#058CD7`, borda 1,2
/// `#F7F0E3`, raio 2/5/5/2, sem sombra e `overflow: hidden`. Dentro da borda (29,6×45,6): o desenho
/// `il_capa_bras_cubas_asas.svg` (estrelas, asas, cartola e nuvens; viewBox 96×144 com `xMidYMid slice` → escala
/// 45,6 ÷ 144 e 0,4 recortado de cada lado). O SVG traz três `<text>` que o flutter_svg desenharia com a fonte do
/// sistema: o desenho entra sem eles e os textos são `AppText` nas mesmas baselines do viewBox × a escala (como a capa
/// do herói, T03). O giro −5° fica na mini-barra, em volta desta arte.
class BrasCubasWingsCover extends StatelessWidget {
  const BrasCubasWingsCover({super.key});

  /// Escala do `slice`: max(29,6 ÷ 96, 45,6 ÷ 144).
  static const double scale = 45.6 / 144;

  /// Deslocamento horizontal do `slice` (o desenho de 30,4 centrado em 29,6).
  static const double dx = (29.6 - 96 * scale) / 2;

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
      width: 32,
      height: 48,
      color: AppColors.azure,
      border: const BorderSide(width: 1.2, color: AppColors.paper),
      radius: AppRadii.coverXs,
      clip: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const AppSvg(
            AppIllustrationsInicio.coverBrasCubasWings,
            key: ValueKey('miniBar.cover.art'),
            size: 29.6,
            height: 45.6,
            fit: BoxFit.cover,
          ),
          _texto(
            'MEMÓRIAS PÓSTUMAS DE',
            12,
            20,
            AppTextStyles.coverWingsKicker,
          ),
          _texto('Brás Cubas', 11, 38, AppTextStyles.coverWingsTitle),
          _texto('MACHADO DE ASSIS', 12.5, 104, AppTextStyles.coverWingsAuthor),
        ],
      ),
    );
  }
}

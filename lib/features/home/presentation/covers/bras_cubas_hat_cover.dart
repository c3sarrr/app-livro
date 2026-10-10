import 'package:flutter/widgets.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_shadows.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da capa "Memórias Póstumas de Brás Cubas" de "Também lendo" da prancha 01 (L01a3, card 1): 54×81, azul
/// `#058CD7`, borda 1,5, raio 3/7/7/3, sombra dura 2/2 e `overflow: hidden` (recorte na padding box 51×78). Em CSS,
/// não SVG: os filhos são absolutos, medidos dentro da borda e pintados na ordem do arquivo — lombada de 5
/// `rgba(0,0,0,.18)`, a cartola (copa 18×16 com raio 2/2/0/0 e aba elíptica 28×5, ambas tinta) e "Brás / Cubas". A
/// rotação −4° fica na seção, em volta desta arte (a Key do slot fica fora do giro).
class BrasCubasHatCover extends StatelessWidget {
  const BrasCubasHatCover({super.key});

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      width: 54,
      height: 81,
      color: AppColors.azure,
      border: const BorderSide(width: 1.5, color: AppColors.ink),
      radius: AppRadii.coverS,
      shadow: AppShadows.hard2,
      clip: true,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: NeoBox(
              key: ValueKey('alsoReading.card1.cover.spine'),
              color: AppColors.spine18,
            ),
          ),
          // A copa: 18×16, `border-radius: 2px 2px 0 0`.
          const Positioned(
            left: 18,
            top: 14,
            child: NeoBox(
              key: ValueKey('alsoReading.card1.cover.hat'),
              width: 18,
              height: 16,
              color: AppColors.ink,
              radius: BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
          ),
          // A aba: 28×5 com `border-radius: 50%` → a elipse inteira (raios 14 × 2,5).
          const Positioned(
            left: 13,
            top: 29,
            child: NeoBox(
              key: ValueKey('alsoReading.card1.cover.brim'),
              width: 28,
              height: 5,
              color: AppColors.ink,
              radius: BorderRadius.all(Radius.elliptical(14, 2.5)),
            ),
          ),
          Positioned(
            left: 9,
            right: 3,
            bottom: 8,
            // O `<br>` do arquivo.
            child: AppText(
              'Brás\nCubas',
              key: const ValueKey('alsoReading.card1.cover.title'),
              style: AppTextStyles.coverTitle11Sun,
            ),
          ),
        ],
      ),
    );
  }
}

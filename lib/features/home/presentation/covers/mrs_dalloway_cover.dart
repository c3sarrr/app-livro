import 'package:flutter/widgets.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_shadows.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da capa "Mrs. Dalloway" de "Também lendo" (F06, card 1): 54×81, verde, borda 1,5, raio 3/7/7/3,
/// sombra dura 2/2 e `overflow: hidden` (recorte na padding box 51×78, raio interno 1,5/5,5/5,5/1,5).
/// Os filhos são absolutos, medidos dentro da borda e pintados na ordem do arquivo: lombada, arco e
/// título. A rotação −4° fica na seção, em volta desta arte (a Key do slot fica fora do giro).
class MrsDallowayCover extends StatelessWidget {
  const MrsDallowayCover({super.key});

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      width: 54,
      height: 81,
      color: AppColors.leaf,
      border: const BorderSide(width: 1.5, color: AppColors.ink),
      radius: AppRadii.coverS,
      shadow: AppShadows.hard2,
      clip: true,
      child: Stack(
        children: [
          // Lombada: 5 px na altura toda, rgba(0,0,0,.15).
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: NeoBox(
              key: ValueKey('alsoReading.card1.cover.spine'),
              color: AppColors.spine15,
            ),
          ),
          // Arco: left 12 / right 7 / top 12 → 32×20 com raio 20 20 0 0. Os raios de cima somam 40 em 32 de
          // largura: o CSS (e o Skia, ao pintar) reduz todos os raios pelo mesmo fator 0,8 → 16.
          const Positioned(
            left: 12,
            right: 7,
            top: 12,
            height: 20,
            child: NeoBox(
              key: ValueKey('alsoReading.card1.cover.arch'),
              color: AppColors.ink,
              radius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 5,
            bottom: 8,
            // O `<br>` do arquivo.
            child: AppText(
              'Mrs.\nDalloway',
              key: const ValueKey('alsoReading.card1.cover.title'),
              style: AppTextStyles.coverTitle11,
            ),
          ),
        ],
      ),
    );
  }
}

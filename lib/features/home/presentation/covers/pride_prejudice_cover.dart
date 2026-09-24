import 'package:flutter/widgets.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_shadows.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da capa "Orgulho e Preconceito" de "Também lendo" (F06, card 2): 54×81, rosa, borda 1,5, raio
/// 3/7/7/3, sombra dura 2/2 e `overflow: hidden` (recorte na padding box 51×78, raio interno 1,5/5,5/5,5/1,5).
/// Os filhos são absolutos, medidos dentro da borda e pintados na ordem do arquivo: lombada, círculo e
/// título. A rotação +3° fica na seção, em volta desta arte (a Key do slot fica fora do giro).
class PridePrejudiceCover extends StatelessWidget {
  const PridePrejudiceCover({super.key});

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      width: 54,
      height: 81,
      color: AppColors.blush,
      border: const BorderSide(width: 1.5, color: AppColors.ink),
      radius: AppRadii.coverS,
      shadow: AppShadows.hard2,
      clip: true,
      child: Stack(
        children: [
          // Lombada: 5 px na altura toda, rgba(0,0,0,.12).
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: NeoBox(
              key: ValueKey('alsoReading.card2.cover.spine'),
              color: AppColors.spine12,
            ),
          ),
          // Círculo 20×20 border-box (`border-radius: 50%` → 10), borda 1,5 tinta, sem preenchimento.
          const Positioned(
            left: 17,
            top: 13,
            child: NeoBox(
              key: ValueKey('alsoReading.card2.cover.circle'),
              width: 20,
              height: 20,
              border: BorderSide(width: 1.5, color: AppColors.ink),
              radius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          Positioned(
            left: 9,
            right: 2,
            bottom: 8,
            // O `<br>` do arquivo.
            child: AppText(
              'Orgulho e\nPreconceito',
              key: const ValueKey('alsoReading.card2.cover.title'),
              style: AppTextStyles.coverTitle9,
            ),
          ),
        ],
      ),
    );
  }
}

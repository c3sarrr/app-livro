import 'package:flutter/widgets.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_shadows.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da capa "Dom Casmurro" do hero (F05): 104×156, violeta, borda 1,5, raio 4/10/10/4, sombra dura
/// 3/3 e `overflow: hidden` (recorte na padding box 101×153, raio interno 2,5/8,5/8,5/2,5).
/// Os filhos são absolutos, medidos dentro da borda e pintados na ordem do arquivo: lombada, sol, anel e
/// bloco de texto. A rotação −3° fica no hero, em volta desta arte (a Key do slot fica fora do giro).
class DomCasmurroCover extends StatelessWidget {
  const DomCasmurroCover({super.key});

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
        children: [
          // Lombada: 7 px na altura toda, rgba(0,0,0,.22).
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
          // Sol 70×70 em right −20 / top −20: sai da capa e é recortado pelo canto.
          const Positioned(
            right: -20,
            top: -20,
            child: NeoBox(
              key: ValueKey('hero.cover.sun'),
              width: 70,
              height: 70,
              color: AppColors.sun,
              radius: BorderRadius.all(Radius.circular(35)),
            ),
          ),
          // Anel content-box: 18 + 2 × 1,5 = 21, sem preenchimento.
          const Positioned(
            right: 18,
            top: 38,
            child: NeoBox(
              key: ValueKey('hero.cover.ring'),
              width: 21,
              height: 21,
              border: BorderSide(width: 1.5, color: AppColors.sun),
              radius: BorderRadius.all(Radius.circular(10.5)),
            ),
          ),
          Positioned(
            left: 15,
            right: 8,
            bottom: 12,
            child: Column(
              key: const ValueKey('hero.cover.textBlock'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                // O `<br>` do arquivo.
                AppText(
                  'Dom\nCasmurro',
                  key: const ValueKey('hero.cover.title'),
                  style: AppTextStyles.coverTitle22,
                ),
                // Quebra FORÇADA (exceção documentada na F05): no arquivo "MACHADO DE ASSIS" mede 78,33 px
                // (com o letter-spacing final) em 78,00 disponíveis e quebra por 0,33 px — fio de navalha
                // numa arte estática. O rótulo semântico continua sem a quebra, como no texto do arquivo.
                AppText(
                  'MACHADO DE\nASSIS',
                  key: const ValueKey('hero.cover.author'),
                  style: AppTextStyles.coverAuthorPaper,
                  semanticsLabel: 'MACHADO DE ASSIS',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

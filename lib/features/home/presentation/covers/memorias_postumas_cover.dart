import 'package:flutter/widgets.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da capa "Memórias Póstumas de Brás Cubas" de "Para você" (F08, item 1): 116×174, laranja, borda 1,5,
/// raio 4/10/10/4, `overflow: hidden` (recorte na padding box 113×171, raio interno 2,5/8,5/8,5/2,5), sem
/// sombra e sem rotação. Os filhos são absolutos, medidos dentro da borda e pintados na ordem do arquivo:
/// lombada, elipse, título e autor.
class MemoriasPostumasCover extends StatelessWidget {
  const MemoriasPostumasCover({super.key});

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      key: const ValueKey('forYou.item1.cover'),
      width: 116,
      height: 174,
      color: AppColors.flame,
      border: const BorderSide(width: 1.5, color: AppColors.ink),
      radius: AppRadii.coverL,
      clip: true,
      // O único recorte é o do NeoBox (padding box, raio interno, suavizado). Sem `Clip.none`, a Stack
      // recortaria de novo — num retângulo SEM suavização — sempre que um filho transbordasse.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lombada: 7 px na altura toda, rgba(0,0,0,.15).
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 7,
            child: NeoBox(
              key: ValueKey('forYou.item1.cover.spine'),
              color: AppColors.spine15,
            ),
          ),
          // Elipse: left 20 / right −30 / bottom −58, altura 116 → 123×116 (border-radius 50% = semieixos
          // 61,5 × 58, não um círculo). Sai pela direita e por baixo e é recortada pela capa.
          const Positioned(
            left: 20,
            right: -30,
            bottom: -58,
            height: 116,
            child: DecoratedBox(
              key: ValueKey('forYou.item1.cover.blob'),
              decoration: ShapeDecoration(
                shape: OvalBorder(),
                color: AppColors.ink,
              ),
            ),
          ),
          // left 16 / right 10 → 87 de largura: quebra em "Memórias" / "Póstumas de" / "Brás Cubas".
          Positioned(
            left: 16,
            right: 10,
            top: 16,
            child: AppText(
              'Memórias Póstumas de Brás Cubas',
              key: const ValueKey('forYou.item1.cover.title'),
              style: AppTextStyles.coverTitle19,
            ),
          ),
          // Só left/bottom: largura do texto (78,33). A cor é a do fundo — o texto só aparece sobre a elipse
          // (o "M" inicial fica sobre o laranja, invisível, como no arquivo).
          Positioned(
            left: 16,
            bottom: 12,
            child: AppText(
              'MACHADO DE ASSIS',
              key: const ValueKey('forYou.item1.cover.author'),
              style: AppTextStyles.coverAuthorFlame,
            ),
          ),
        ],
      ),
    );
  }
}

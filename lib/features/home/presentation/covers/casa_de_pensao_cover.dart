import 'package:flutter/widgets.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da capa "Casa de Pensão" do Para você da prancha 01 (L01a6, item 3): 116×174, verde, borda 1,5, raio
/// 4/10/10/4, `overflow: hidden` (recorte na padding box 113×171), sem sombra e sem rotação. Os filhos são absolutos,
/// medidos dentro da borda e pintados na ordem do arquivo: lombada, arco externo, arco interno (a "porta", na cor do
/// fundo) e bloco de texto ("Casa de / Pensão" — o `<br>` da prancha — e "ALUÍSIO AZEVEDO"). O desenho é o da v1
/// (F08, "O Cortiço").
class CasaDePensaoCover extends StatelessWidget {
  const CasaDePensaoCover({super.key});

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      key: const ValueKey('forYou.item3.cover'),
      width: 116,
      height: 174,
      color: AppColors.emerald,
      border: const BorderSide(width: 1.5, color: AppColors.ink),
      radius: AppRadii.coverL,
      clip: true,
      // O único recorte é o do NeoBox (padding box, raio interno, suavizado). Sem `Clip.none`, a Stack
      // recortaria de novo — num retângulo SEM suavização — sempre que um filho transbordasse.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lombada: 7 px na altura toda, rgba(0,0,0,.18).
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 7,
            child: NeoBox(
              key: ValueKey('forYou.item3.cover.spine'),
              color: AppColors.spine18,
            ),
          ),
          // Arco externo 68×80 em left 24 / top 22, raio 34 34 0 0.
          const Positioned(
            left: 24,
            top: 22,
            width: 68,
            height: 80,
            child: NeoBox(
              key: ValueKey('forYou.item3.cover.archOuter'),
              color: AppColors.sun,
              radius: BorderRadius.only(
                topLeft: Radius.circular(34),
                topRight: Radius.circular(34),
              ),
            ),
          ),
          // Arco interno 28×46 em left 44 / top 56, raio 14 14 0 0, na cor do fundo.
          const Positioned(
            left: 44,
            top: 56,
            width: 28,
            height: 46,
            child: NeoBox(
              key: ValueKey('forYou.item3.cover.archInner'),
              color: AppColors.emerald,
              radius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),
          // Bloco inferior: left 16 / right 10 / bottom 12, gap 6.
          Positioned(
            left: 16,
            right: 10,
            bottom: 12,
            child: Column(
              key: const ValueKey('forYou.item3.cover.textBlock'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                AppText(
                  'Casa de\nPensão',
                  key: const ValueKey('forYou.item3.cover.title'),
                  style: AppTextStyles.coverTitle26,
                ),
                AppText(
                  'ALUÍSIO AZEVEDO',
                  key: const ValueKey('forYou.item3.cover.author'),
                  style: AppTextStyles.coverAuthorSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

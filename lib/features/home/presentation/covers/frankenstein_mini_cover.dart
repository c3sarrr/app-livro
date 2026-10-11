import 'package:flutter/widgets.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_strokes.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da mini-capa "Frankenstein" de "Recém-chegados" (F10, linha 1): 44×66, fundo tinta, borda 1,2 tinta,
/// raio 3/7/7/3, `overflow: hidden` (recorte na padding box 41,6×63,6), sem sombra e sem lombada. Os filhos são
/// absolutos, medidos dentro da borda e pintados na ordem do arquivo: lua e barra, ambas `#B6ACE4`.
///
/// [id] é a Key da capa (`recent.row0.cover`); os filhos levam `$id.moon` e `$id.bar`.
class FrankensteinMiniCover extends StatelessWidget {
  const FrankensteinMiniCover({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      key: ValueKey<String>(id),
      width: 44,
      height: 66,
      color: AppColors.ink,
      border: const BorderSide(width: AppStrokes.thin, color: AppColors.ink),
      radius: AppRadii.coverS,
      clip: true,
      // O único recorte é o do NeoBox (padding box, raio interno, suavizado): sem `Clip.none` a Stack recortaria
      // de novo num retângulo sem suavização.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lua 22×22 em left 10 / top 10.
          Positioned(
            left: 10,
            top: 10,
            width: 22,
            height: 22,
            child: NeoBox(
              key: ValueKey<String>('$id.moon'),
              color: AppColors.lavender,
              radius: BorderRadius.circular(11),
            ),
          ),
          // Barra: left 8 / right 6 / bottom 7, altura 3 e raio 3 (o CSS reduz para 1,5) → largura 27,6.
          Positioned(
            left: 8,
            right: 6,
            bottom: 7,
            height: 3,
            child: NeoBox(
              key: ValueKey<String>('$id.bar'),
              color: AppColors.lavender,
              radius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}

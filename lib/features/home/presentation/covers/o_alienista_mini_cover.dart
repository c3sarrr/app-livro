import 'package:flutter/widgets.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_strokes.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da mini-capa "O Alienista" de "Recém-chegados" (F10, linha 2): 44×66, lavanda, borda 1,2 tinta, raio
/// 3/7/7/3, `overflow: hidden` (recorte na padding box 41,6×63,6), sem sombra. Os filhos são absolutos, medidos
/// dentro da borda e pintados na ordem do arquivo: lombada, anel e ponto.
///
/// [id] é a Key da capa (`recent.row1.cover`); os filhos levam `$id.spine`, `$id.ring` e `$id.dot`.
class OAlienistaMiniCover extends StatelessWidget {
  const OAlienistaMiniCover({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      key: ValueKey<String>(id),
      width: 44,
      height: 66,
      color: AppColors.lavender,
      border: const BorderSide(width: AppStrokes.thin, color: AppColors.ink),
      radius: AppRadii.coverS,
      clip: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lombada: 4 px na altura toda, rgba(0,0,0,.12).
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: NeoBox(
              key: ValueKey<String>('$id.spine'),
              color: AppColors.spine12,
            ),
          ),
          // Anel 20×20 (`box-sizing: border-box`, borda 1,5 tinta, sem fundo) em left 12 / top 12.
          Positioned(
            left: 12,
            top: 12,
            width: 20,
            height: 20,
            child: NeoBox(
              key: ValueKey<String>('$id.ring'),
              border: const BorderSide(
                width: AppStrokes.regular,
                color: AppColors.ink,
              ),
              radius: BorderRadius.circular(10),
            ),
          ),
          // Ponto 8×8 tinta em left 18 / top 18.
          Positioned(
            left: 18,
            top: 18,
            width: 8,
            height: 8,
            child: NeoBox(
              key: ValueKey<String>('$id.dot'),
              color: AppColors.ink,
              radius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

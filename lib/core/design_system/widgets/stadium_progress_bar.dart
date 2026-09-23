import 'package:flutter/widgets.dart';

import '../tokens/app_colors.dart';
import 'neo_box.dart';

/// Barra de progresso em pílula com preenchimento à esquerda.
class StadiumProgressBar extends StatelessWidget {
  const StadiumProgressBar({
    super.key,
    this.fillKey,
    required this.progress,
    required this.height,
    required this.background,
    required this.fillColor,
    this.border = const BorderSide(width: 1.5, color: AppColors.ink),
  });
  final Key? fillKey;
  final double progress, height;
  final Color background, fillColor;
  final BorderSide border;
  @override
  Widget build(BuildContext context) => NeoBox(
    height: height,
    color: background,
    border: border,
    radius: BorderRadius.circular(999),
    clip: true,
    child: Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        key: fillKey,
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        heightFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    ),
  );
}

import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_strokes.dart';

/// Preenchimento das barras da semana: `height: H; background: C; border-top: 1.5px solid #1A1714;
/// border-radius: 999px; box-sizing: border-box`. O raio normaliza para `R = min(W, H)/2` e a borda
/// superior vira uma MEIA-LUA: espessura 1,5 no topo, afinando até 0 nas laterais
/// (raio interno vertical = R − 1,5; horizontal = R).
class TopBorderCrescentPainter extends CustomPainter {
  const TopBorderCrescentPainter({
    required this.fill,
    this.border = AppStrokes.regular,
    this.borderColor = AppColors.ink,
  });
  final Color fill;
  final double border;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2;
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(r),
    );
    canvas.drawRRect(outer, Paint()..color = fill);
    final innerTop = Radius.elliptical(r, math.max(0, r - border));
    final inner = RRect.fromLTRBAndCorners(
      0,
      border,
      size.width,
      size.height,
      topLeft: innerTop,
      topRight: innerTop,
      bottomLeft: Radius.circular(r),
      bottomRight: Radius.circular(r),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRRect(outer),
        Path()..addRRect(inner),
      ),
      Paint()..color = borderColor,
    );
  }

  @override
  bool shouldRepaint(TopBorderCrescentPainter old) =>
      old.fill != fill ||
      old.border != border ||
      old.borderColor != borderColor;
}

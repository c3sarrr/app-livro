import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_strokes.dart';

/// O anel cônico arco-íris (o `conic-gradient` do arquivo, começando no topo e no sentido horário, como o CSS) com a
/// borda de 1,5 e o miolo na cor [center] (raio [centerRadius], borda de 1,5). Opcional, o aro [halo] em volta do
/// miolo (o `box-shadow: 0 0 0 Npx` do CSS). A barra de grifar da G13 usa o miolo de 7 (L21b nº 10); o poço de cor
/// do modo anotação, 13,5 com o aro de 2,5 `#FFFAF1` (L22d nº 11–12).
class ConicRingPainter extends CustomPainter {
  const ConicRingPainter({
    required this.border,
    required this.center,
    required this.centerRadius,
    this.halo,
  });

  final Color border;
  final Color center;
  final double centerRadius;
  final ({Color color, double width})? halo;

  static const List<Color> colors = [
    AppColors.flame,
    AppColors.amber,
    AppColors.sun,
    AppColors.leaf,
    AppColors.emerald,
    AppColors.azure,
    AppColors.lavender,
    AppColors.violet,
    AppColors.blush,
    AppColors.flame,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    const half = AppStrokes.regular / 2;
    Paint stroke() => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppStrokes.regular
      ..color = border;
    canvas
      ..drawCircle(
        c,
        r,
        Paint()
          ..shader = const SweepGradient(
            colors: colors,
            transform: GradientRotation(-math.pi / 2),
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      )
      ..drawCircle(c, r - half, stroke());
    final h = halo;
    if (h != null) {
      canvas.drawCircle(c, centerRadius + h.width, Paint()..color = h.color);
    }
    canvas
      ..drawCircle(c, centerRadius, Paint()..color = center)
      ..drawCircle(c, centerRadius - half, stroke());
  }

  @override
  bool shouldRepaint(ConicRingPainter old) =>
      old.border != border ||
      old.center != center ||
      old.centerRadius != centerRadius ||
      old.halo != halo;
}

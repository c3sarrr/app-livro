import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_strokes.dart';

/// `border: 1.5px dashed` de uma pílula (`border-radius: 999px`), como o Chromium: traço = 2 × espessura e vão ideal
/// = espessura (o trilho do tamanho na tela 26 — medido na prancha @3x: 3 e ~1,5). O contorno é fechado: o vão é
/// ajustado para caber um número inteiro de traços.
class DashedStadiumPainter extends CustomPainter {
  const DashedStadiumPainter({
    this.thickness = AppStrokes.regular,
    this.color = AppColors.dashReader,
  });

  final double thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final h = thickness / 2;
    final box = (Offset.zero & size).deflate(h);
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(box, Radius.circular(box.shortestSide / 2)),
      );
    final metric = path.computeMetrics().first;
    final dash = 2 * thickness;
    final n = math.max(1, (metric.length / (dash + thickness)).round());
    final step = metric.length / n;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;
    for (var i = 0; i < n; i++) {
      canvas.drawPath(metric.extractPath(i * step, i * step + dash), paint);
    }
  }

  @override
  bool shouldRepaint(DashedStadiumPainter old) =>
      old.thickness != thickness || old.color != color;
}

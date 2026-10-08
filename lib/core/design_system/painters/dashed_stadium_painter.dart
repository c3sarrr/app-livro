import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_strokes.dart';

/// `border: 1.5px dashed` de uma pílula (`border-radius: 999px`), como o Chromium: traço = 2 × espessura e vão ideal
/// = espessura (o trilho do tamanho na tela 26 — medido na prancha @3x: 3 e ~1,5). O contorno é fechado: o vão é
/// ajustado para caber um número inteiro de traços. Com [radius], o retângulo arredondado (a dica da 23b — G17).
class DashedStadiumPainter extends CustomPainter {
  const DashedStadiumPainter({
    this.thickness = AppStrokes.regular,
    this.color = AppColors.dashReader,
    this.radius,
  });

  final double thickness;
  final Color color;

  /// O raio dos cantos (a borda de fora); `null` = a pílula.
  final double? radius;

  @override
  void paint(Canvas canvas, Size size) => drawDashedRRect(
    canvas,
    Offset.zero & size,
    radius: radius,
    thickness: thickness,
    color: color,
  );

  @override
  bool shouldRepaint(DashedStadiumPainter old) =>
      old.thickness != thickness || old.color != color || old.radius != radius;
}

/// G18: o mesmo tracejado num retângulo [rect] qualquer do canvas (a borda de fora; [radius] `null` = a pílula) — a
/// caixa da nota à mão, a área do abridor e o dedo da tela 24.
void drawDashedRRect(
  Canvas canvas,
  Rect rect, {
  double? radius,
  double thickness = AppStrokes.regular,
  Color color = AppColors.dashReader,
}) {
  final h = thickness / 2;
  final box = rect.deflate(h);
  final path = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        box,
        Radius.circular(radius == null ? box.shortestSide / 2 : radius - h),
      ),
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

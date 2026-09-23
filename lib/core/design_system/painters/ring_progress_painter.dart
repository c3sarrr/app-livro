import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../tokens/app_colors.dart';

/// Anel 46×46 de "Também lendo": trilho `ringTrack` + arco de progresso em tinta com ponta redonda,
/// começando no topo, sentido horário (SVG do arquivo: `stroke-dasharray` + `rotate(-90)`).
class RingProgressPainter extends CustomPainter {
  const RingProgressPainter({required this.progress}); // 0..1
  final double progress;
  static const double radius = 18, stroke = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.ringTrack,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.ink,
    );
  }

  @override
  bool shouldRepaint(RingProgressPainter old) => old.progress != progress;
}

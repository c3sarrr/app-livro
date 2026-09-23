import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../tokens/app_colors.dart';

/// Dial 112×112 de "Seu dia de leitura" (SVG do arquivo: face, marcações, arco de progresso e pino).
class GoalDialPainter extends CustomPainter {
  const GoalDialPainter({required this.progress}); // lidos / meta (18/30 = 0,6)
  final double progress;
  static const Offset _c = Offset(56, 56);

  @override
  void paint(Canvas canvas, Size size) {
    // 1) face r=54: preenchimento surface + traço 1,5 tinta centrado no raio (como SVG)
    canvas.drawCircle(_c, 54, Paint()..color = AppColors.surface);
    canvas.drawCircle(
      _c,
      54,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.ink,
    );
    // 2) marcações: r=44, traço 2, dash 1,5 / vão 7,71, início às 3h, sentido horário, cap reto, alpha .35
    const r = 44.0, dash = 1.5, period = 1.5 + 7.71;
    final circumference = 2 * math.pi * r;
    final rect = Rect.fromCircle(center: _c, radius: r);
    final tick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt
      ..color = AppColors.dialTick;
    for (var i = 0; i * period < circumference; i++) {
      final s = i * period, e = math.min(s + dash, circumference);
      canvas.drawArc(rect, s / r, (e - s) / r, false, tick);
    }
    // 3) progresso: r=44, traço 10, cap redondo, início no topo, horário
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = AppColors.ink,
    );
    // 4) pino no fim do arco: r=6, flame + traço 1,5 tinta → no arquivo (30,1; 91,6)
    final a = -math.pi / 2 + sweep;
    final knob = _c + Offset(math.cos(a), math.sin(a)) * r;
    canvas.drawCircle(knob, 6, Paint()..color = AppColors.flame);
    canvas.drawCircle(
      knob,
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = AppColors.ink,
    );
  }

  @override
  bool shouldRepaint(GoalDialPainter old) => old.progress != progress;
}

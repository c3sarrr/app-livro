// G17.1 — a roda de cores da tela 23 (L23.6, R13): o `conic-gradient(#FF0000, #FFFF00, #00FF00, #00FFFF, #0000FF,
// #FF00FF, #FF0000)` do arquivo (do topo, no sentido horário, como o CSS) com o `radial-gradient(circle closest-side,
// #FFFFFF, transparente)` por cima, no círculo de dentro da borda, e a borda de 1,5. A roda é sempre desenhada com
// brilho 100 %: o brilho é outro controle. O cursor é um widget por cima (a posição sai de `wheelOffsetOf`).
import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../color/hsv.dart';
import '../tokens/app_strokes.dart';

/// O raio útil da roda de [size]: o círculo de dentro da borda (60,5 na roda de 124 do arquivo).
double wheelRadius(double size) => size / 2 - AppStrokes.regular;

/// O ponto da roda de [size] com o tom e a intensidade de [c] (a origem é o canto da roda).
Offset wheelOffsetOf(Hsv c, double size) {
  final a = c.h * math.pi / 180;
  final r = c.s.clamp(0.0, 1.0) * wheelRadius(size);
  return Offset(size / 2 + math.sin(a) * r, size / 2 - math.cos(a) * r);
}

/// O tom (graus, do topo no sentido horário) e a intensidade (0 no centro, 1 na borda útil, preso a 1 fora dela) do
/// ponto [p] da roda de [size].
(double, double) wheelHsvAt(Offset p, double size) {
  final dx = p.dx - size / 2;
  final dy = p.dy - size / 2;
  final d = math.sqrt(dx * dx + dy * dy);
  if (d == 0) return (0, 0);
  final h = math.atan2(dx, -dy) * 180 / math.pi;
  return (h < 0 ? h + 360 : h, math.min(1.0, d / wheelRadius(size)));
}

class ColorWheelPainter extends CustomPainter {
  const ColorWheelPainter({required this.border});

  /// A cor da borda de 1,5 (a tinta; no Noite, a das letras da ilha).
  final Color border;

  static const List<Color> hues = [
    Color(0xFFFF0000),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFFF),
    Color(0xFF0000FF),
    Color(0xFFFF00FF),
    Color(0xFFFF0000),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final inner = r - AppStrokes.regular;
    final circle = Rect.fromCircle(center: c, radius: inner);
    canvas
      ..drawCircle(
        c,
        r,
        Paint()
          ..shader = const SweepGradient(
            colors: hues,
            transform: GradientRotation(-math.pi / 2),
          ).createShader(circle),
      )
      ..drawCircle(
        c,
        inner,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
          ).createShader(circle),
      )
      ..drawCircle(
        c,
        r - AppStrokes.regular / 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppStrokes.regular
          ..color = border,
      );
  }

  @override
  bool shouldRepaint(ColorWheelPainter old) => old.border != border;
}

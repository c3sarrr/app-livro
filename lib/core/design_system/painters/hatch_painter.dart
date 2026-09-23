import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../tokens/app_colors.dart';

/// `repeating-linear-gradient(135deg, A 0 3px, B 3px 7px)` — listras "/" de 3 px a cada 7 px.
class HatchPainter extends CustomPainter {
  const HatchPainter({required this.stripe, this.base = AppColors.surface});
  final Color stripe;
  final Color base;
  static const double _period = 7, _stripe = 3, _k = 0.7071067811865476; // 1/√2

  @override
  void paint(Canvas canvas, Size size) {
    // Origem = canto superior esquerdo da PADDING BOX (dentro da borda). t = (x + y)/√2; listra se (t mod 7) < 3.
    final shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(_period * _k, _period * _k),
      [stripe, stripe, base, base],
      const [0, _stripe / _period, _stripe / _period, 1],
      TileMode.repeated,
    );
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(HatchPainter old) =>
      old.stripe != stripe || old.base != base;
}

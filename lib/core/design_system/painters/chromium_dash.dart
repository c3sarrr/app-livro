import 'package:flutter/rendering.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_strokes.dart';

/// Traço = 2 × espessura e vão ideal = espessura (Chromium, espessura física ≥ 3 px — telas ≥ 2x).
/// O vão é ajustado para o padrão começar E terminar com traço (StrokeData::SelectBestDashGap, caminho aberto).
List<double> chromiumDashStarts({
  required double length,
  required double thickness,
}) {
  final dash = 2 * thickness, gap = thickness;
  // Chromium: se length <= 2 × traço, desenha linha contínua (não ocorre nesta tela; os casos são 263,6 e 288).
  assert(length > 2 * dash, 'comprimento curto: desenhe uma linha contínua');
  final minDashes = ((length + gap) / (dash + gap)).floorToDouble();
  final maxDashes = minDashes + 1;
  final minGap = minDashes > 1
      ? (length - minDashes * dash) / (minDashes - 1)
      : double.infinity;
  final maxGap = (length - maxDashes * dash) / (maxDashes - 1);
  final useMin = maxGap <= 0 || (minGap - gap).abs() < (maxGap - gap).abs();
  final n = (useMin ? minDashes : maxDashes).toInt();
  final g = useMin ? minGap : maxGap;
  return [for (var i = 0; i < n; i++) i * (dash + g)];
}

/// `border-*: 1.5px dashed` de um único lado, com o padrão de traços do Chromium.
class ChromiumDashPainter extends CustomPainter {
  const ChromiumDashPainter({
    required this.axis,
    this.thickness = AppStrokes.regular,
    this.color = AppColors.ink,
  });
  final Axis axis;
  final double thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final length = axis == Axis.horizontal ? size.width : size.height;
    final paint = Paint()..color = color;
    final dash = 2 * thickness;
    for (final s in chromiumDashStarts(length: length, thickness: thickness)) {
      canvas.drawRect(
        axis == Axis.horizontal
            ? Rect.fromLTWH(s, 0, dash, thickness)
            : Rect.fromLTWH(0, s, thickness, dash),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ChromiumDashPainter old) =>
      old.axis != axis || old.thickness != thickness || old.color != color;
}

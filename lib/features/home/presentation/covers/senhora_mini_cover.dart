import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_strokes.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da mini-capa "Senhora" de "Recém-chegados" (F10, linha 3): 44×66, âmbar, borda 1,2 tinta, raio 3/7/7/3,
/// `overflow: hidden` (recorte na padding box 41,6×63,6), sem sombra. Os filhos são absolutos, medidos dentro da
/// borda e pintados na ordem do arquivo: lombada e arco vazado.
///
/// [id] é a Key da capa (`recent.row2.cover`); os filhos levam `$id.spine` e `$id.arch`.
class SenhoraMiniCover extends StatelessWidget {
  const SenhoraMiniCover({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      key: ValueKey<String>(id),
      width: 44,
      height: 66,
      color: AppColors.amber,
      border: const BorderSide(width: AppStrokes.thin, color: AppColors.ink),
      radius: AppRadii.coverS,
      clip: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lombada: 4 px na altura toda, rgba(0,0,0,.12).
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: NeoBox(
              key: ValueKey<String>('$id.spine'),
              color: AppColors.spine12,
            ),
          ),
          // Arco vazado: left 10 / right 8 / top 12, altura 26 → 23,6×26, raio 13 13 0 0, borda 1,5 tinta em cima
          // e nas laterais, SEM a de baixo. O `Positioned` dá restrição justa: o `CustomPaint` mede 23,6×26.
          Positioned(
            left: 10,
            right: 8,
            top: 12,
            height: 26,
            child: CustomPaint(
              key: ValueKey<String>('$id.arch'),
              painter: const ArchBorderPainter(
                topRadius: 13,
                border: AppStrokes.regular,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Borda de um arco aberto embaixo: `border-radius: R R 0 0; border: B solid C; border-bottom: none;
/// box-sizing: border-box` num retângulo W×H, sem fundo. O Flutter não pinta `borderRadius` com bordas de lados
/// diferentes, então a borda é a faixa em "U" entre o contorno externo e o interno, num caminho só (sem arestas
/// coincidentes). Raios como no CSS: quando os dois de cima somam mais que a largura (2 × 13 = 26 > 23,6), todos
/// são reduzidos pelo mesmo fator (→ 11,8); o interno é o externo − B.
class ArchBorderPainter extends CustomPainter {
  const ArchBorderPainter({
    required this.topRadius,
    required this.border,
    required this.color,
  });

  final double topRadius;
  final double border;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final scale = math.min(1.0, w / (2 * topRadius));
    final r = topRadius * scale; // externo
    final ri = r - border; // interno (raio − borda)
    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      ..lineTo(w, h)
      ..lineTo(w - border, h)
      ..lineTo(w - border, r)
      ..arcToPoint(
        Offset(w - r, border),
        radius: Radius.circular(ri),
        clockwise: false,
      )
      ..lineTo(r, border)
      ..arcToPoint(
        Offset(border, r),
        radius: Radius.circular(ri),
        clockwise: false,
      )
      ..lineTo(border, h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(ArchBorderPainter old) =>
      old.topRadius != topRadius || old.border != border || old.color != color;
}

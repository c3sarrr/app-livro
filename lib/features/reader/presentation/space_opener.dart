// G18.3 — o abridor do Espaço (tela 24, L24.1–L24.2): o dedo começou entre duas linhas e arrasta para baixo; a área
// tracejada roxa com a hachura a 135°, a costura no topo com as bolinhas, o rastro pontilhado com as setas, o dedo na
// borda que se move e o chip "↕ N linhas" (R2). Só mostra: o toque é da sessão (o canvas por baixo). Noite: R14.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/dashed_stadium_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../annotations/space/hand_note_layout.dart';

/// As cores do abridor no papel (Creme e os claros) e no Noite (R14).
@immutable
final class OpenerColors {
  const OpenerColors({
    required this.line,
    required this.hatch,
    required this.hatchGap,
    required this.finger,
    required this.fingerDash,
    required this.chip,
    required this.chipText,
  });

  /// A costura, as bolinhas, o rastro e o tracejado da área.
  final Color line;
  final Color hatch;
  final Color hatchGap;
  final Color finger;
  final Color fingerDash;
  final Color chip;
  final Color chipText;

  /// A prancha 24.
  static const OpenerColors paper = OpenerColors(
    line: AppColors.violet,
    hatch: Color(0x52B6ACE4), // rgba(182,172,228,.32)
    hatchGap: Color(0xE6FFFDF8), // rgba(255,253,248,.9)
    finger: Color(0x8CB6ACE4), // rgba(182,172,228,.55)
    fingerDash: AppColors.ink,
    chip: AppColors.ink,
    chipText: AppColors.paper,
  );

  /// R14: a hachura lavanda sobre o papel do Noite; a costura e o rastro na `brand`; o chip claro.
  static const OpenerColors night = OpenerColors(
    line: AppColors.lavender,
    hatch: Color(0x52B6ACE4),
    hatchGap: Color(0xE61F1B17),
    finger: Color(0x8CB6ACE4),
    fingerDash: AppColors.inkNight,
    chip: AppColors.inkNight,
    chipText: AppColors.ink,
  );
}

/// "1 linha", "3 linhas".
String linesLabel(int n) => n == 1 ? '1 linha' : '$n linhas';

/// O abridor com [lines] linhas na área [area] (coordenadas deste widget), com o dedo no x [fingerX].
class SpaceOpener extends StatelessWidget {
  const SpaceOpener({
    super.key,
    required this.area,
    required this.lines,
    required this.fingerX,
    this.colors = OpenerColors.paper,
  });

  final Rect area;
  final int lines;
  final double fingerX;
  final OpenerColors colors;

  @override
  Widget build(BuildContext context) {
    final parts = openerLayout(area, fingerX);
    final label = linesLabel(lines);
    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // `role=status`: o leitor de tela ouve o tamanho mudando; o resto é desenho (o chip repete o rótulo)
          Positioned.fromRect(
            rect: area,
            child: Semantics(
              key: const ValueKey('ann.page.spaceOpener'),
              container: true,
              liveRegion: true,
              label: 'Abrindo espaço: $label',
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: ExcludeSemantics(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      key: const ValueKey('ann.page.spaceOpener.paint'),
                      painter: OpenerPainter(parts: parts, colors: colors),
                    ),
                  ),
                  for (final (id, r) in [
                    ('area', parts.area),
                    ('seam', parts.seam),
                    ('seamDotLeft', parts.dotLeft),
                    ('seamDotRight', parts.dotRight),
                    ('trail', parts.trail),
                    ('finger', parts.finger),
                  ])
                    Positioned.fromRect(
                      rect: r,
                      child: SizedBox(
                        key: ValueKey('ann.page.spaceOpener.$id'),
                      ),
                    ),
                  Positioned(
                    left: parts.chip.left,
                    top: parts.chip.top,
                    height: parts.chip.height,
                    child: _SizeChip(label: label, colors: colors),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// O chip "↕ N linhas": 28 de altura, raio 9, 10 de cada lado, o ícone de 14 e 6 até o texto.
class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.label, required this.colors});

  final String label;
  final OpenerColors colors;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('ann.page.spaceOpener.sizeChip'),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: colors.chip,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSvg(
          AppIconsLeitor.arrowsVertical,
          key: const ValueKey('ann.page.spaceOpener.sizeChip.icon'),
          size: 14,
          // o arquivo vem no papel (`#F7F0E3`); no Noite, a tinta
          colors: colors.chipText == AppColors.paper
              ? null
              : {AppColors.paper: colors.chipText},
        ),
        const SizedBox(width: 6),
        AppText(
          label,
          key: const ValueKey('ann.page.spaceOpener.sizeChip.text'),
          style: AppTextStyles.annOpenerChip.copyWith(color: colors.chipText),
          maxLines: 1,
        ),
      ],
    ),
  );
}

/// A área com a hachura e o tracejado, a costura, as bolinhas, o rastro e o dedo (sem camada — regra 12.4).
class OpenerPainter extends CustomPainter {
  const OpenerPainter({required this.parts, required this.colors});

  final OpenerParts parts;
  final OpenerColors colors;

  /// A hachura do arquivo: `repeating-linear-gradient(135deg, A 0 4px, B 4px 9px)` — a linha do gradiente passa
  /// pelo centro da caixa e começa no canto de cima à esquerda.
  static Shader hatchShader(Rect r, Color a, Color b) {
    const dir = Offset(math.sqrt1_2, math.sqrt1_2);
    final len = (r.width + r.height) * math.sqrt1_2;
    final from = r.center - dir * (len / 2);
    return ui.Gradient.linear(
      from,
      from + dir * 9,
      [a, a, b, b],
      const [0, 4 / 9, 4 / 9, 1],
      TileMode.repeated,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final area = parts.area;
    final rr = RRect.fromRectAndRadius(area, const Radius.circular(14));
    // o gradiente se mede pela caixa por dentro da borda (o `background-origin: padding-box` do CSS)
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = hatchShader(
          area.deflate(1.5),
          colors.hatch,
          colors.hatchGap,
        ),
    );
    drawDashedRRect(
      canvas,
      area,
      radius: 14,
      thickness: 1.5,
      color: colors.line,
    );
    final line = Paint()..color = colors.line;
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(parts.seam, const Radius.circular(2)),
        line,
      )
      ..drawOval(parts.dotLeft, line)
      ..drawOval(parts.dotRight, line);
    _trail(canvas, parts.trail);
    canvas.drawOval(parts.finger, Paint()..color = colors.finger);
    drawDashedRRect(
      canvas,
      parts.finger,
      radius: parts.finger.width / 2,
      thickness: 1.5,
      color: colors.fingerDash,
    );
  }

  /// O rastro (`rastro_arrasto_espaco.svg`, 24 de largura): o pontilhado de 4 até a base − 24 (traços de 1 a cada
  /// 8, pontas redondas), as duas setas e a bolinha de 4 no começo; o que passa da altura dele não aparece.
  void _trail(Canvas canvas, Rect r) {
    if (r.height <= 0) return;
    canvas
      ..save()
      ..clipRect(Rect.fromLTRB(r.left - 4, r.top - 6, r.right + 4, r.bottom));
    final p = Paint()
      ..color = colors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final x = r.left + 12;
    final end = r.top + math.max(4, r.height - 24);
    for (var y = r.top + 4; y <= end + 1e-6; y += 8) {
      canvas.drawLine(Offset(x, y), Offset(x, math.min(y + 1, end)), p);
    }
    for (final top in const [26.0, 44.0]) {
      if (top + 7 > r.height) continue;
      canvas.drawPath(
        Path()
          ..moveTo(r.left + 5, r.top + top)
          ..lineTo(r.left + 12, r.top + top + 7)
          ..lineTo(r.left + 19, r.top + top),
        p,
      );
    }
    canvas
      ..drawCircle(Offset(x, r.top + 4), 4, Paint()..color = colors.line)
      ..restore();
  }

  @override
  bool shouldRepaint(OpenerPainter old) =>
      old.parts != parts || old.colors != colors;
}

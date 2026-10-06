// G12.3 — barra de posição da ilha de baixo (`r20.bottomIsland.scrubber`, L20b): trilho 16 com a hachura 135° do
// tema, preenchimento `brand` até a posição terminando numa onda, botão 28 e o balão "pág. N" com bico. Arrastar
// move o botão, o preenchimento e o balão (a página sob o dedo) sem navegar; soltar — ou tocar no trilho — salta
// para essa página quando ela é outra (D-22, D-119). Para o leitor de tela é um `slider` "Posição no livro" com o
// valor "página X de Y" e passos de 1 % do livro, pelo menos 1 página (D-124); botão e balão ficam de fora.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/hatch_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import 'reader_chrome_scope.dart';

/// Onda do fim do preenchimento: o caminho do arquivo (`M0 0H5Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15H0Z`, viewBox
/// 10×15) esticado na altura, com o traço de 1,5 sem escala (`vector-effect: non-scaling-stroke`).
class FillWavePainter extends CustomPainter {
  const FillWavePainter({required this.fill, required this.stroke});

  final Color fill, stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 10;
    final sy = size.height / 15;
    Path wave({required bool closed}) {
      final path = Path()..moveTo(closed ? 0 : 5 * sx, 0);
      if (closed) path.lineTo(5 * sx, 0);
      path
        ..quadraticBezierTo(9.5 * sx, 2.5 * sy, 5 * sx, 5 * sy)
        ..quadraticBezierTo(0.5 * sx, 7.5 * sy, 5 * sx, 10 * sy)
        ..quadraticBezierTo(9.5 * sx, 12.5 * sy, 5 * sx, 15 * sy);
      if (closed) {
        path
          ..lineTo(0, 15 * sy)
          ..close();
      }
      return path;
    }

    canvas
      ..drawPath(wave(closed: true), Paint()..color = fill)
      ..drawPath(
        wave(closed: false),
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppStrokes.regular,
      );
  }

  @override
  bool shouldRepaint(FillWavePainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.stroke != stroke;
}

/// Passo do leitor de tela: 1 % do livro, pelo menos 1 página (D-124).
int scrubberStep(int total) => math.max(1, (total / 100).round());

class Scrubber extends StatefulWidget {
  const Scrubber({
    super.key,
    required this.page,
    required this.total,
    required this.progression,
    required this.onJump,
  });

  /// A página de referência mostrada e o total.
  final int page, total;

  /// Fração lida (0–1) — onde o preenchimento termina e o botão fica.
  final double progression;

  /// A página de referência escolhida ao soltar ou tocar (só quando é outra).
  final ValueChanged<int> onJump;

  @override
  State<Scrubber> createState() => _ScrubberState();
}

class _ScrubberState extends State<Scrubber> {
  /// Fração sob o dedo durante o arrasto.
  double? _drag;

  double _fractionAt(double x) {
    final w = context.size?.width ?? 1;
    return w <= 0 ? 0 : (x / w).clamp(0.0, 1.0);
  }

  int _pageAt(double f) =>
      widget.total <= 1 ? 1 : 1 + (f * (widget.total - 1)).round();

  void _release(double f) {
    final n = _pageAt(f);
    setState(() => _drag = null);
    if (n != widget.page) widget.onJump(n);
  }

  @override
  Widget build(BuildContext context) {
    final s = ReaderChromeScope.of(context);
    final p = s.palette;
    final brand = s.tint(s.brand);
    final drag = _drag;
    final f = (drag ?? widget.progression).clamp(0.0, 1.0);
    final shown = drag == null ? widget.page : _pageAt(drag);
    final total = widget.total;
    final step = scrubberStep(total);
    final up = math.min(total, widget.page + step);
    final down = math.max(1, widget.page - step);
    return Semantics(
      container: true,
      slider: true,
      label: 'Posição no livro',
      value: 'página ${widget.page} de $total',
      increasedValue: up == widget.page ? null : 'página $up de $total',
      decreasedValue: down == widget.page ? null : 'página $down de $total',
      onIncrease: up == widget.page ? null : () => widget.onJump(up),
      onDecrease: down == widget.page ? null : () => widget.onJump(down),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onHorizontalDragStart: (d) =>
            setState(() => _drag = _fractionAt(d.localPosition.dx)),
        onHorizontalDragUpdate: (d) =>
            setState(() => _drag = _fractionAt(d.localPosition.dx)),
        onHorizontalDragEnd: (_) => _release(_drag ?? widget.progression),
        onHorizontalDragCancel: () => setState(() => _drag = null),
        onTapUp: (d) => _release(_fractionAt(d.localPosition.dx)),
        child: SizedBox(
          key: const ValueKey('r20.bottomIsland.scrubber'),
          height: 26,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final inner = math.max(0.0, w - 2 * AppStrokes.regular);
              final x = f * w;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 5,
                    height: 16,
                    child: NeoBox(
                      key: const ValueKey('r20.bottomIsland.scrubber.track'),
                      border: BorderSide(
                        width: AppStrokes.regular,
                        color: p.border,
                      ),
                      radius: BorderRadius.circular(999),
                      clip: true,
                      child: CustomPaint(
                        painter: HatchPainter(
                          stripe: p.hatch,
                          base: p.hatchBase,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            key: const ValueKey(
                              'r20.bottomIsland.scrubber.fill',
                            ),
                            width: f * inner,
                            height: double.infinity,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: ColoredBox(color: brand),
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  right: -5,
                                  width: 10,
                                  child: CustomPaint(
                                    key: const ValueKey(
                                      'r20.bottomIsland.scrubber.fill.wave',
                                    ),
                                    painter: FillWavePainter(
                                      fill: brand,
                                      stroke: p.border,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: x - 14,
                    top: -1,
                    width: 28,
                    height: 28,
                    child: ExcludeSemantics(
                      child: NeoBox(
                        key: const ValueKey('r20.bottomIsland.scrubber.knob'),
                        color: p.island,
                        border: BorderSide(width: 2, color: p.border),
                        radius: BorderRadius.circular(14),
                        shadow: AppShadows.hard2,
                        shadowColor: p.shadow,
                      ),
                    ),
                  ),
                  Positioned(
                    left: x,
                    bottom: 30,
                    child: ExcludeSemantics(
                      child: FractionalTranslation(
                        translation: const Offset(-0.5, 0),
                        child: _Bubble(label: 'pág. $shown'),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Balão "pág. N" (raio 10) com o bico 10×10 girado 45° centrado 5 abaixo da base.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final p = ReaderChromeScope.of(context).palette;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        NeoBox(
          key: const ValueKey('r20.bottomIsland.scrubber.bubble'),
          height: 28,
          color: p.bubble,
          radius: BorderRadius.circular(10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            widthFactor: 1,
            child: AppText(
              label,
              style: AppTextStyles.readerBubble.copyWith(color: p.bubbleText),
              maxLines: 1,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -5,
          child: Center(
            child: SizedBox.square(
              key: const ValueKey('r20.bottomIsland.scrubber.bubble.tail'),
              dimension: 10,
              child: Transform.rotate(
                angle: math.pi / 4,
                child: ColoredBox(color: p.bubble),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

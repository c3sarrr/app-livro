// G13.3 — a camada da seleção (tela 21): as alças (`#552CB7`, medidas da caixa de 1 em do arquivo), a âncora da
// barra, o nó "Trecho selecionado" (D-57), a lupa do app (D-135: sem camada, a página pintada de novo 1,25×) e a
// barra no lugar da D-136 (em cima, embaixo ou presa). A barra some enquanto uma alça é arrastada; parada 300 ms, a
// alça passa a andar por letra e a lupa aparece (D-45). O dedo pega a bolinha, mas quem anda é o ponto da alça na
// linha (a diferença entre os dois fica a mesma durante o arrasto).
import 'dart:async';

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../layout/display_page.dart';
import 'reader_chrome_palette.dart';
import 'reader_page_view.dart' show ReaderPagesPainter;
import 'selection_controller.dart';

/// Altura da barra de ações (L21b): 116,5.
const double highlightToolbarHeight = 116.5;

/// No arquivo, o topo da barra fica 162 acima do fim da 1ª linha selecionada (L21a).
const double toolbarAboveGap = 162;

/// Embaixo, a barra fica a 7,4 da bolinha final (a folga do arquivo).
const double toolbarBelowGap = 7.4;

/// Quanto o dedo fica parado na alça até a lupa aparecer (D-45).
const Duration selectionCharDelay = Duration(milliseconds: 300);

/// Lupa (D-135, extrapolada): 132 × 48, raio 14, centro 60 acima da linha, 1,25×.
const Size magnifierSize = Size(132, 48);
const double magnifierRadius = 14;
const double magnifierZoom = 1.25;
const double magnifierLift = 60;

/// Área de toque de cada alça, em volta da bolinha.
const double handleTouch = 44;

enum ToolbarPlace { above, below, pinned }

/// Onde a barra fica (D-136): em cima (como o arquivo); senão embaixo; senão presa em [minTop].
({double top, ToolbarPlace place}) toolbarPlacement({
  required double firstLineBottom,
  required double endKnobBottom,
  required double minTop,
  required double maxBottom,
}) {
  final above = firstLineBottom - toolbarAboveGap;
  if (above >= minTop) return (top: above, place: ToolbarPlace.above);
  final below = endKnobBottom + toolbarBelowGap;
  if (below + highlightToolbarHeight <= maxBottom) {
    return (top: below, place: ToolbarPlace.below);
  }
  return (top: minTop, place: ToolbarPlace.pinned);
}

/// As medidas de uma alça no ponto [x] de uma linha com [baseline] e [em] (a caixa de 1 em com
/// `vertical-align: −0,2em`): a haste e a bolinha (em cima na inicial, embaixo na final).
({Rect stem, Rect knob}) handleGeometry(
  SelectionHandle h,
  double x,
  double baseline,
  double em,
) {
  final top = baseline - 0.8 * em;
  final bottom = baseline + 0.2 * em;
  return (
    stem: Rect.fromLTWH(x - 1, top - 2, 2, em + 8),
    knob: h == SelectionHandle.start
        ? Rect.fromLTWH(x - 7, top - 13, 12, 12)
        : Rect.fromLTWH(x - 6, bottom + 5, 12, 12),
  );
}

class SelectionLayer extends StatefulWidget {
  const SelectionLayer({
    super.key,
    required this.page,
    required this.controller,
    required this.palette,
    required this.paper,
    required this.sideMargin,
    required this.contentWidth,
    required this.safeTop,
    required this.safeBottom,
    required this.pages,
    required this.toolbar,
    required this.startTimer,
  });

  final DisplayPage page;
  final SelectionController controller;
  final ReaderChromePalette palette;

  /// O papel (o fundo da lupa).
  final Color paper;
  final double sideMargin;
  final double contentWidth;
  final double safeTop;
  final double safeBottom;

  /// O pintor da página (a lupa o usa ampliado).
  final ReaderPagesPainter Function() pages;
  final Widget toolbar;
  final Timer Function(Duration, void Function()) startTimer;

  @override
  State<SelectionLayer> createState() => _SelectionLayerState();
}

class _SelectionLayerState extends State<SelectionLayer> {
  Timer? _still;

  /// Do dedo ao ponto da alça na linha (fica a mesma durante o arrasto).
  Offset _grab = Offset.zero;

  @override
  void dispose() {
    _still?.cancel();
    super.dispose();
  }

  void _armStill() {
    _still?.cancel();
    _still = widget.startTimer(
      selectionCharDelay,
      widget.controller.enterCharMode,
    );
  }

  /// O ponto da alça [h] na linha dela: a borda do trecho, no meio da linha.
  static Offset _point(SelectionHandle h, TextLineBox line) => Offset(
    h == SelectionHandle.start ? line.rect.left : line.rect.right,
    line.rect.center.dy,
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final s = widget.controller.selection;
      if (s == null) return const SizedBox.shrink();
      final r = s.range;
      final boxes = widget.page.boxesOf(r.unit, r.from, r.to);
      if (boxes.isEmpty) return const SizedBox.shrink();
      final first = boxes.first;
      final last = boxes.last;
      final start = handleGeometry(
        SelectionHandle.start,
        first.rect.left,
        first.baseline,
        first.em,
      );
      final end = handleGeometry(
        SelectionHandle.end,
        last.rect.right,
        last.baseline,
        last.em,
      );
      final size = MediaQuery.sizeOf(context);
      final at = toolbarPlacement(
        firstLineBottom: first.rect.bottom,
        endKnobBottom: end.knob.bottom,
        minTop: widget.safeTop + 8,
        maxBottom: size.height - widget.safeBottom - 8,
      );
      final union = boxes
          .map((b) => b.rect)
          .reduce((a, b) => a.expandToInclude(b));
      final handles = [
        (SelectionHandle.start, start, first, 'r21.page.text.handleStart'),
        (SelectionHandle.end, end, last, 'r21.page.text.handleEnd'),
      ];
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fromRect(
            rect: union,
            child: Semantics(
              key: const ValueKey('r21.page.text.selection'),
              container: true,
              label: 'Trecho selecionado',
              value: widget.page.textOf(r.unit, r.from, r.to),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            key: const ValueKey('r21.page.text.toolbarAnchor'),
            left: first.rect.left,
            top: first.textTop,
            width: 0,
            height: first.textBottom - first.textTop,
            child: const SizedBox.shrink(),
          ),
          for (final (h, g, line, k) in handles) ...[
            // a caixa de 1 em do arquivo (o elemento medido na L21a)
            Positioned(
              key: ValueKey(k),
              left: h == SelectionHandle.start
                  ? line.rect.left
                  : line.rect.right,
              top: line.baseline - 0.8 * line.em,
              width: 0,
              height: line.em,
              child: const SizedBox.shrink(),
            ),
            Positioned.fromRect(
              key: ValueKey('$k.stem'),
              rect: g.stem,
              child: const ExcludeSemantics(
                child: ColoredBox(color: AppColors.violet),
              ),
            ),
            Positioned.fromRect(
              key: ValueKey('$k.knob'),
              rect: g.knob,
              child: const ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.violet,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
          if (s.dragging == null)
            Positioned(
              key: const ValueKey('leitor.selecao.barra'),
              left: widget.sideMargin - 6,
              top: at.top,
              width: widget.contentWidth + 12,
              child: widget.toolbar,
            ),
          if (s.byChar && s.finger != null) _magnifier(s, boxes, size),
          // com chave: a barra e a lupa entram e saem no meio do arrasto, e a área da alça não pode ser trocada
          // por outra (o gesto em curso seria cancelado)
          for (final (h, g, line, _) in handles)
            Positioned.fromRect(
              key: ValueKey('leitor.selecao.area.${h.name}'),
              rect: Rect.fromCenter(
                center: g.knob.center,
                width: handleTouch,
                height: handleTouch,
              ),
              child: GestureDetector(
                key: ValueKey('leitor.selecao.alca.${h.name}'),
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                dragStartBehavior: DragStartBehavior.down,
                onPanStart: (d) {
                  _grab = _point(h, line) - d.globalPosition;
                  widget.controller.beginDrag(h, d.globalPosition + _grab);
                  _armStill();
                },
                onPanUpdate: (d) {
                  widget.controller.dragTo(
                    widget.page,
                    d.globalPosition + _grab,
                  );
                  if (!(widget.controller.selection?.byChar ?? true)) {
                    _armStill();
                  }
                },
                onPanEnd: (_) => _end(),
                onPanCancel: _end,
              ),
            ),
        ],
      );
    },
  );

  void _end() {
    _still?.cancel();
    widget.controller.endDrag();
  }

  Widget _magnifier(ReaderSelection s, List<TextLineBox> boxes, Size screen) {
    final line = s.dragging == SelectionHandle.start ? boxes.first : boxes.last;
    // segue o dedo na horizontal e a linha da alça na vertical (como o Android)
    final focus = Offset(s.finger!.dx, (line.textTop + line.textBottom) / 2);
    final half = magnifierSize / 2;
    final center = Offset(
      focus.dx.clamp(half.width + 8, screen.width - half.width - 8),
      (focus.dy - magnifierLift).clamp(
        half.height + 8,
        screen.height - half.height - 8,
      ),
    );
    return Positioned.fromRect(
      key: const ValueKey('leitor.lupa'),
      rect: Rect.fromCenter(
        center: center,
        width: magnifierSize.width,
        height: magnifierSize.height,
      ).inflate(3),
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: MagnifierPainter(
            pages: widget.pages(),
            focus: focus,
            paper: widget.paper,
            border: widget.palette.border,
            shadow: widget.palette.shadow,
            screen: screen,
          ),
        ),
      ),
    );
  }
}

/// A lupa (D-135): sombra dura 3/3, o papel e a página ampliada 1,25× em volta de [focus], recortados na caixa
/// arredondada (raio 14), e a borda 1,5. Sem camada.
class MagnifierPainter extends CustomPainter {
  const MagnifierPainter({
    required this.pages,
    required this.focus,
    required this.paper,
    required this.border,
    required this.shadow,
    required this.screen,
  });

  final ReaderPagesPainter pages;
  final Offset focus;
  final Color paper;
  final Color border;
  final Color shadow;
  final Size screen;

  @override
  void paint(Canvas canvas, Size size) {
    // a caixa fica 3 px para dentro (a área do widget tem a sombra em volta)
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, magnifierSize.width, magnifierSize.height),
      const Radius.circular(magnifierRadius),
    );
    canvas
      ..drawRRect(box.shift(AppShadows.hard3), Paint()..color = shadow)
      ..save()
      ..clipRRect(box)
      ..drawRRect(box, Paint()..color = paper)
      ..translate(box.center.dx, box.center.dy)
      ..scale(magnifierZoom)
      ..translate(-focus.dx, -focus.dy);
    pages.paint(canvas, screen);
    canvas
      ..restore()
      ..drawRRect(
        box.deflate(AppStrokes.regular / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppStrokes.regular
          ..color = border,
      );
  }

  @override
  bool shouldRepaint(MagnifierPainter old) =>
      old.focus != focus ||
      old.paper != paper ||
      old.border != border ||
      old.shadow != shadow ||
      old.screen != screen ||
      !identical(old.pages, pages);
}

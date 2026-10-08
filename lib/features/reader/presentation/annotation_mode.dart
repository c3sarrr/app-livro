// G16.6 — a camada do modo anotação (tela 22), por cima da tela inteira do leitor, com os lugares da D-167 (3):
// - o canvas (a página 30 px abaixo, recortada da pílula para baixo) e a borda de mesa no pé;
// - a prateleira (312×70, centrada, com a base 68 acima da base da ilha) **atrás** da ilha; a ilha com a base em
//   `max(30, área segura de baixo − 4)`, 14 de cada lado; a pílula e o Concluir com o topo em
//   `max(50, área segura de cima + 3)`;
// - a pílula da falha ao salvar (D-21) e o aviso "Chega numa próxima fase" (D-163) acima da prateleira.
// Entrada: o texto desce 30 px em 220 ms `easeOutCubic` e a moldura aparece em 150 ms; saída ao contrário (o texto
// sobe e a moldura some), e então [onExited]. Enquanto anima, os toques não chegam à página.
// A prateleira e a ilha decidem pouco: a ferramenta das próximas fases, o 2º toque na ativa e o poço de cor chamam
// [onSoon] (D-163); o resto vai direto à sessão.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../application/annotation_session.dart';
import '../domain/reader_settings.dart';
import '../layout/display_page.dart';
import 'annotation_canvas.dart';
import 'annotation_island.dart';
import 'annotation_top_bar.dart';
import 'page_marks.dart';
import 'reader_chrome_palette.dart';
import 'reader_chrome_scope.dart';
import 'reader_overlays.dart';
import 'reader_page_view.dart' show readerTurnCurve, readerTurnDuration;
import 'reader_palette.dart';
import 'tool_shelf.dart';

/// D-167 (3): o topo da pílula e do Concluir.
double annotationTopOf(EdgeInsets safe) => math.max(50, safe.top + 3);

/// D-167 (3): a base da ilha.
double annotationBottomOf(EdgeInsets safe) => math.max(30, safe.bottom - 4);

/// A altura da ilha e da pílula (L22b/L22d); o vão entre a pílula e a página (L22a: 116 = 50 + 52 + 14).
const double annotationIslandHeight = 90;
const double annotationTopBarHeight = 52;
const double annotationPageGap = 14;

/// A base da prateleira fica 68 acima da base da ilha (L22c: 746 = 814 − 68).
const double toolShelfAboveIsland = 68;

/// O subtítulo da pílula na Caneta (L22b nº 6).
const String annotationHint = '2 dedos movem a página';

/// A pílula da falha ao salvar (D-21).
const String annotationSaveFailed = 'Não deu para salvar as anotações agora.';

class AnnotationMode extends StatefulWidget {
  const AnnotationMode({
    super.key,
    required this.open,
    required this.session,
    required this.page,
    required this.paper,
    required this.brand,
    required this.sideMargin,
    required this.semanticsLabel,
    required this.onDone,
    required this.onSoon,
    this.highlights = const [],
    this.inkHighlights = const [],
    this.toast,
    this.onExited,
  });

  /// `false` = saindo (anima e chama [onExited]).
  final bool open;
  final AnnotationSession session;
  final DisplayPage page;
  final ReaderPaper paper;
  final Color brand;

  /// A margem do lado da página (a caixa `ann.page` vai de uma à outra).
  final double sideMargin;

  /// "‹Título›, página X de Y — modo anotação".
  final String semanticsLabel;

  /// Concluir (e o Voltar — D-42): a tela grava e sai.
  final VoidCallback onDone;

  /// Marca-texto, Espaço, o poço de cor e o 2º toque na ativa (D-163).
  final VoidCallback onSoon;

  final List<PaintedHighlight> highlights, inkHighlights;

  /// O aviso na tela ("Chega numa próxima fase"), ou `null`.
  final String? toast;
  final VoidCallback? onExited;

  @override
  State<AnnotationMode> createState() => _AnnotationModeState();
}

class _AnnotationModeState extends State<AnnotationMode>
    with TickerProviderStateMixin {
  late final AnimationController _text = AnimationController(
    vsync: this,
    duration: readerTurnDuration,
  );
  late final Animation<double> _enter = CurvedAnimation(
    parent: _text,
    curve: readerTurnCurve,
    reverseCurve: readerTurnCurve.flipped,
  );
  late final AnimationController _frame = AnimationController(
    vsync: this,
    duration: readerFade,
  );

  @override
  void initState() {
    super.initState();
    _text.addStatusListener(_status);
    if (widget.open) _show();
  }

  @override
  void didUpdateWidget(AnnotationMode old) {
    super.didUpdateWidget(old);
    if (old.open == widget.open) return;
    if (widget.open) {
      _show();
    } else {
      _text.reverse();
      _frame.reverse();
    }
  }

  void _show() {
    _text.forward();
    _frame.forward();
  }

  void _status(AnimationStatus s) {
    if (s == AnimationStatus.dismissed && !widget.open) widget.onExited?.call();
  }

  @override
  void dispose() {
    _text.dispose();
    _frame.dispose();
    super.dispose();
  }

  void _tool(AnnotationTool t) {
    final s = widget.session;
    // o 2º toque na ativa abriria o painel dela (telas 23/23b — G17); as ferramentas das próximas fases ficam
    if (t == s.tool || !s.setTool(t)) widget.onSoon();
  }

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.viewPaddingOf(context);
    final size = MediaQuery.sizeOf(context);
    final top = annotationTopOf(safe);
    final bottom = annotationBottomOf(safe);
    final shelfBottom = bottom + toolShelfAboveIsland;
    final paper = ReaderPalette.of(widget.paper);
    final chrome = ReaderChromePalette.of(widget.paper);
    final pageBox = Rect.fromLTRB(
      widget.sideMargin,
      top + annotationTopBarHeight + annotationPageGap,
      size.width - widget.sideMargin,
      size.height,
    );
    final s = widget.session;
    return AnimatedBuilder(
      animation: Listenable.merge([_text, _frame, s]),
      builder: (context, _) {
        final a = _frame.value;
        final settled = widget.open && _text.isCompleted;
        final ink = Color(s.color);
        final message = s.failed ? annotationSaveFailed : widget.toast;
        return IgnorePointer(
          key: const ValueKey('ann.mode'),
          ignoring: !settled,
          child: ExcludeSemantics(
            excluding: !widget.open,
            child: ReaderChromeScope(
              palette: chrome.faded(a),
              brand: widget.brand,
              a: a,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnnotationCanvas(
                      session: s,
                      page: widget.page,
                      pageBox: pageBox,
                      paper: paper.paper,
                      lightText: paper.lightText,
                      highlights: widget.highlights,
                      inkHighlights: widget.inkHighlights,
                      semanticsLabel: widget.semanticsLabel,
                      enter: _enter,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DeskEdge(
                      paper: paper.paper.withValues(alpha: paper.paper.a * a),
                    ),
                  ),
                  Positioned(
                    left: (size.width - 312) / 2,
                    bottom: shelfBottom,
                    child: ToolShelf(active: s.tool, ink: ink, onTool: _tool),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: bottom,
                    height: annotationIslandHeight,
                    child: AnnotationIsland(
                      tool: s.tool,
                      ink: ink,
                      strokeSize: s.strokeSize,
                      canUndo: s.canUndo,
                      canRedo: s.canRedo,
                      onColorWell: widget.onSoon,
                      onStrokeSize: s.setStrokeSize,
                      onUndo: s.undo,
                      onRedo: s.redo,
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    top: top,
                    child: AnnotationTopBar(
                      subtitle: annotationHint,
                      onDone: widget.onDone,
                    ),
                  ),
                  if (message != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: shelfBottom + 70 + toolShelfLift + 12,
                      child: Center(child: ReaderToastPill(text: message)),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

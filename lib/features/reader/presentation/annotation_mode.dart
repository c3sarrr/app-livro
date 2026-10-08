// G16.6 — a camada do modo anotação (tela 22), por cima da tela inteira do leitor, com os lugares da D-167 (3):
// - o canvas (a página 30 px abaixo, recortada da pílula para baixo) e a borda de mesa no pé;
// - a prateleira (312×70, centrada, com a base 68 acima da base da ilha) **atrás** da ilha; a ilha com a base em
//   `max(30, área segura de baixo − 4)`, 14 de cada lado; a pílula e o Concluir com o topo em
//   `max(50, área segura de cima + 3)`;
// - a pílula da falha ao salvar (D-21) e o aviso "Chega numa próxima fase" (D-163) acima da prateleira.
// Entrada: o texto desce 30 px em 220 ms `easeOutCubic` e a moldura aparece em 150 ms; saída ao contrário (o texto
// sobe e a moldura some), e então [onExited]. Enquanto anima, os toques não chegam à página.
// A prateleira e a ilha decidem pouco: o Espaço chama [onSoon] (D-163); o 2º toque na ativa e o poço abrem e fecham
// o painel dela (telas 23 e 23b — R1, R2); o resto vai direto à sessão.
// G17: com um painel aberto, o véu e o painel ficam entre a página (e o topo) e a prateleira, que continua viva com a
// ilha por cima (R4); o véu e o painel aparecem e somem em 150 ms (R5).
// G18: a página pintada é a da sessão (refeita com os espaços — R3); com a fonte dela, o Espaço fica ativo e a pílula
// diz "Arraste entre as linhas" (R4); no arrasto, o abridor (tela 24) sobre a página, 30 px abaixo como o texto.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../annotations/domain/annotation.dart' show HighlightStyle;
import '../annotations/ink/ink_stroke.dart' show argbOfHex;
import '../application/annotation_session.dart';
import '../domain/reader_settings.dart';
import '../layout/display_page.dart';
import 'annotation_canvas.dart';
import 'annotation_island.dart';
import 'annotation_top_bar.dart';
import 'ink_latency_meter.dart';
import 'page_marks.dart';
import 'reader_chrome_palette.dart';
import 'reader_chrome_scope.dart';
import 'reader_overlays.dart';
import 'reader_page_view.dart' show readerTurnCurve, readerTurnDuration;
import 'reader_palette.dart';
import 'marker_panel.dart';
import 'pen_panel.dart';
import 'space_opener.dart';
import 'tool_panel_frame.dart';
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

/// O subtítulo da pílula no Espaço (L24 nº 4 — R4).
const String annotationSpaceHint = 'Arraste entre as linhas';

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
    this.meter,
    this.onEditLabels,
  });

  /// `false` = saindo (anima e chama [onExited]).
  final bool open;
  final AnnotationSession session;

  /// A página aberta, do leitor limpo; com os espaços, o modo mostra a da sessão (`session.page`).
  final DisplayPage page;
  final ReaderPaper paper;
  final Color brand;

  /// A margem do lado da página (a caixa `ann.page` vai de uma à outra).
  final double sideMargin;

  /// "‹Título›, página X de Y — modo anotação".
  final String semanticsLabel;

  /// Concluir (e o Voltar — D-42): a tela grava e sai.
  final VoidCallback onDone;

  /// O Espaço (D-163).
  final VoidCallback onSoon;

  /// "Editar rótulos" no painel do marca-texto (D-177): a tela abre a folha.
  final VoidCallback? onEditLabels;

  final List<PaintedHighlight> highlights, inkHighlights;

  /// O aviso na tela ("Chega numa próxima fase"), ou `null`.
  final String? toast;
  final VoidCallback? onExited;

  /// O medidor de latência do traço; sem ele, o modo cria um só com `--dart-define=BOOKNEST_MEDIR_TINTA=true`.
  final InkLatencyMeter? meter;

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

  /// O véu e o painel (R5); [_shown] fica até o painel sumir.
  late final AnimationController _panel = AnimationController(
    vsync: this,
    duration: readerFade,
  );
  OpenPanel? _shown;

  /// O medidor criado aqui (com o define), que o modo liga e desliga.
  final InkLatencyMeter? _ownMeter = inkLatencyMeterOn
      ? InkLatencyMeter()
      : null;

  @override
  void initState() {
    super.initState();
    _text.addStatusListener(_status);
    widget.session.panel.addListener(_panelChanged);
    _panel.addStatusListener(_panelStatus);
    _ownMeter?.start();
    if (widget.open) _show();
  }

  @override
  void didUpdateWidget(AnnotationMode old) {
    super.didUpdateWidget(old);
    if (!identical(old.session, widget.session)) {
      old.session.panel.removeListener(_panelChanged);
      widget.session.panel.addListener(_panelChanged);
    }
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
    widget.session.panel.removeListener(_panelChanged);
    _ownMeter?.dispose();
    _text.dispose();
    _frame.dispose();
    _panel.dispose();
    super.dispose();
  }

  // ---- painéis (R1–R5) --------------------------------------------------------------------------------------

  void _panelChanged() {
    final p = widget.session.panel.value;
    final instant = MediaQuery.disableAnimationsOf(context);
    if (p != null) {
      setState(() => _shown = p);
      if (instant) {
        _panel.value = 1;
      } else {
        _panel.forward();
      }
    } else if (instant) {
      _panel.value = 0;
      setState(() => _shown = null);
    } else {
      _panel.reverse();
    }
  }

  void _panelStatus(AnimationStatus st) {
    if (st == AnimationStatus.dismissed && widget.session.panel.value == null) {
      setState(() => _shown = null);
    }
  }

  /// Uma ferramenta da prateleira: na ativa, abre ou fecha o painel dela (R1; Borracha e Laço não têm); outra
  /// ferramenta fecha o painel e troca (R4); o Espaço avisa (D-163).
  void _tool(AnnotationTool t) {
    final s = widget.session;
    if (t == s.tool) {
      if (t != AnnotationTool.pen &&
          t != AnnotationTool.line &&
          t != AnnotationTool.marker) {
        return;
      }
      if (s.panel.value?.from == t) {
        s.closePanel();
      } else {
        s.openPanel(t);
      }
      return;
    }
    if (!s.setTool(t)) widget.onSoon();
  }

  /// O poço abre o painel da ferramenta de tinta em uso; com um painel aberto, fecha (R2).
  void _well() {
    final s = widget.session;
    if (s.panel.value != null) {
      s.closePanel();
    } else {
      s.openPanel(s.tool);
    }
  }

  /// O véu e o painel aberto (telas 23 e 23b), com a base 22 acima do topo da prateleira e a seta na ferramenta de
  /// onde ele saiu.
  Widget _panelOf(
    OpenPanel shown,
    double shelfBottom,
    Color paper,
    double top,
  ) {
    final s = widget.session;
    final bottom = shelfBottom + toolShelfHeight + panelAboveShelf;
    if (shown.kind == PanelKind.pen) {
      return PenPanelLayer(
        session: s,
        from: shown.from,
        bottom: bottom,
        paper: paper,
        top: top,
      );
    }
    // a prévia da 23b com a página aberta (D-171)
    final range = widget.page.shown;
    final text = range == null ? null : s.anchors.textOf(range.unit);
    return MarkerPanelLayer(
      session: s,
      bottom: bottom,
      top: top,
      paper: paper,
      preview: range == null || text == null
          ? null
          : (text: text, start: range.from, end: range.to),
      onEditLabels: widget.onEditLabels,
    );
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
    // o canvas fica fora do que é refeito a cada mudança da sessão e a cada quadro da entrada: ele ouve o que precisa
    final canvas = RepaintBoundary(
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
        meter: widget.meter ?? _ownMeter,
      ),
    );
    return AnimatedBuilder(
      animation: Listenable.merge([_text, _frame, _panel, s, s.opening]),
      child: canvas,
      builder: (context, canvas) {
        final a = _frame.value;
        final settled = widget.open && _text.isCompleted;
        final ink = Color(s.color);
        final pen = Color(argbOfHex(s.presets.penColor));
        final marker = Color(argbOfHex(s.presets.highlighterColor));
        final shown = _shown;
        final pa = a * _panel.value;
        final message = s.failed ? annotationSaveFailed : widget.toast;
        final opening = s.opening.value;
        final openerArea = s.openerArea;
        return IgnorePointer(
          key: const ValueKey('ann.mode'),
          // entrando, saindo ou gravando (o que viesse agora não entraria na gravação)
          ignoring: !settled || s.saving,
          child: ExcludeSemantics(
            excluding: !widget.open,
            child: ReaderChromeScope(
              palette: chrome.faded(a),
              brand: widget.brand,
              a: a,
              child: Stack(
                children: [
                  Positioned.fill(child: canvas!),
                  // o abridor (tela 24): sobre a página, onde o texto está (30 px abaixo, com o deslocamento)
                  if (opening != null && openerArea != null)
                    Positioned.fill(
                      child: SpaceOpener(
                        area: openerArea.shift(
                          Offset(0, s.textShift * _enter.value + s.panOffset),
                        ),
                        lines: opening.lines,
                        fingerX: opening.finger.x,
                        colors: widget.paper == ReaderPaper.noite
                            ? OpenerColors.nightOf(widget.brand)
                            : OpenerColors.paper,
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
                    left: 14,
                    right: 14,
                    top: top,
                    child: AnnotationTopBar(
                      subtitle: s.tool == AnnotationTool.space
                          ? annotationSpaceHint
                          : annotationHint,
                      onDone: widget.onDone,
                    ),
                  ),
                  if (shown != null)
                    Positioned.fill(
                      child: ReaderChromeScope(
                        palette: chrome.faded(pa),
                        brand: widget.brand,
                        a: pa,
                        child: _panelOf(
                          shown,
                          shelfBottom,
                          paper.paper,
                          safe.top,
                        ),
                      ),
                    ),
                  Positioned(
                    left: (size.width - 312) / 2,
                    bottom: shelfBottom,
                    child: ToolShelf(
                      active: s.tool,
                      ink: pen,
                      marker: marker,
                      onTool: _tool,
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: bottom,
                    height: annotationIslandHeight,
                    child: AnnotationIsland(
                      tool: s.tool,
                      inkTool: s.inkTool,
                      ink: ink,
                      strokeSize: s.strokeSize,
                      height: s.tool == AnnotationTool.marker
                          ? s.presets.highlighterHeight
                          : null,
                      heightEnabled:
                          s.presets.highlighterStyle == HighlightStyle.fill,
                      onHeight: s.setHighlighterHeight,
                      canUndo: s.canUndo,
                      canRedo: s.canRedo,
                      onColorWell: _well,
                      onStrokeSize: s.setStrokeSize,
                      onUndo: s.undo,
                      onRedo: s.redo,
                    ),
                  ),
                  if (message != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom:
                          shelfBottom + toolShelfHeight + toolShelfLift + 12,
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

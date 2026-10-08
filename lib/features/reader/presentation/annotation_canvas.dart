// G16.6 — o canvas do modo anotação (L22a):
// - um `Listener` cru leva os eventos de ponteiro (tipo, posição, pressão, tempo) à sessão; o árbitro decide o que é
//   desenho e o que move a página;
// - a pintura: o papel na tela toda e, recortada na caixa `ann.page`, a página do leitor limpo 30 px abaixo (mais o
//   deslocamento dos 2 dedos), com os fundos dos grifos de seleção, o texto, o sublinhado, a mancha dos grifos à mão
//   que a Borracha ainda não apagou (D-161) e a tinta da sessão (uma `Picture` pela revisão);
// - o traço ao vivo numa `RepaintBoundary` própria que só ouve a sessão ao vivo (o contorno inteiro a cada amostra —
//   ADR-006): a Caneta, a prévia da Reta, o contorno do Laço e a seleção (o retângulo com 6 de folga e raio 8 —
//   D-21), no estilo do ícone do Laço (lavanda a 35 %, traço `#1A1714` de 1,7 tracejado 4/3);
// - o indicador de toque (D-167 6): só com o dedo; o anel de 38 lavanda a 42 % com a borda tracejada e, na Caneta e
//   na Reta, o ponto de 12 na cor da tinta;
// - ao soltar os 2 dedos fora do limite, a página volta em 220 ms `easeOutCubic` (D-165);
// - a borda de mesa (`DeskEdge`): o degradê do papel no pé da tela, sem receber toque.
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/dashed_stadium_painter.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../annotations/ink/gesture_arbiter.dart';
import '../annotations/ink/ink_geometry.dart' show InkOffset;
import '../annotations/ink/ink_stroke.dart' show InkStroke;
import '../annotations/ink/ink_tools.dart' show panLimit;
import '../application/annotation_session.dart';
import '../layout/display_page.dart';
import 'ink_latency_meter.dart';
import 'ink_painter.dart';
import 'page_marks.dart';
import 'reader_page_view.dart'
    show paintTextPage, readerTurnCurve, readerTurnDuration;

/// O estilo do Laço (o ícone da prateleira): lavanda a 35 %, traço de 1,7, tracejado 4/3.
const Color lassoFill = Color(0x59B6ACE4);
const double lassoStroke = 1.7;
const double lassoDash = 4;
const double lassoGap = 3;

/// O retângulo da seleção (D-21): raio 8.
const double lassoFrameRadius = 8;

/// O indicador de toque (D-167 6): anel de 38 lavanda a 42 % e ponto de 12.
const double touchRingSize = 38;
const double touchDotSize = 12;
const Color touchRingFill = Color(0x6BB6ACE4);

/// A borda de mesa (L22a nº 15): 250 px no pé da tela, o papel opaco nos 135 de baixo.
const double deskEdgeHeight = 250;
const double deskEdgeSolid = 135;

/// O tipo do ponteiro para o árbitro: o mouse vale como dedo (o app no computador); a ponta de borracha da caneta
/// fica para depois (fora da G16).
InkPointerKind inkPointerKind(PointerDeviceKind k) => switch (k) {
  PointerDeviceKind.touch || PointerDeviceKind.mouse => InkPointerKind.touch,
  PointerDeviceKind.stylus => InkPointerKind.stylus,
  _ => InkPointerKind.ignored,
};

/// A pressão de 0 a 1 (a caneta do aparelho informa a faixa dela).
double inkPressure(PointerEvent e) => e.pressureMax > e.pressureMin
    ? ((e.pressure - e.pressureMin) / (e.pressureMax - e.pressureMin))
          .clamp(0, 1)
          .toDouble()
    : e.pressure.clamp(0, 1).toDouble();

class AnnotationCanvas extends StatefulWidget {
  const AnnotationCanvas({
    super.key,
    required this.session,
    required this.page,
    required this.pageBox,
    required this.paper,
    required this.semanticsLabel,
    this.lightText,
    this.highlights = const [],
    this.inkHighlights = const [],
    this.enter = kAlwaysCompleteAnimation,
    this.meter,
  });

  final AnnotationSession session;

  /// O medidor de latência do S4 (só com `--dart-define=BOOKNEST_MEDIR_TINTA=true`): recebe o tempo de cada evento.
  final InkLatencyMeter? meter;

  /// A entrada (0 → 1) e a saída (1 → 0) do modo: o texto desce e sobe os 30 px junto (220 ms — a camada anima).
  final Animation<double> enter;

  /// A página aberta, do leitor limpo (o layout fica travado no modo).
  final DisplayPage page;

  /// A caixa `ann.page` na tela: só as linhas que caem nela aparecem.
  final Rect pageBox;
  final Color paper;

  /// As letras claras do Noite (a técnica da D-133 nos fundos e na mancha).
  final Color? lightText;

  /// Os grifos de fundo/sublinhado da página e os grifos feitos à mão (a mancha), antes da sessão.
  final List<PaintedHighlight> highlights, inkHighlights;

  /// "‹Título›, página X de Y — modo anotação".
  final String semanticsLabel;

  @override
  State<AnnotationCanvas> createState() => _AnnotationCanvasState();
}

class _AnnotationCanvasState extends State<AnnotationCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _back = AnimationController(
    vsync: this,
    duration: readerTurnDuration,
  );

  /// O deslocamento pintado (o da sessão; ao soltar fora do limite, anima até ele).
  final ValueNotifier<double> _pan = ValueNotifier(0);
  double _backFrom = 0;
  double _backTo = 0;

  /// A tinta da sessão: a passada de cima e, no Noite, a de trás e a dos fundos (o Marca-texto pela D-133 — achado
  /// 17).
  final InkPictureCache _pictures = InkPictureCache(capacity: 3);

  /// Os traços do Laço sendo arrastados, gravados uma vez no começo do arrasto (depois, só transladados).
  final InkPictureCache _dragged = InkPictureCache(capacity: 1);
  bool _wasPanning = false;

  @override
  void initState() {
    super.initState();
    _pan.value = widget.session.panOffset;
    widget.session.addListener(_sessionChanged);
    _back.addListener(() {
      _pan.value =
          _backFrom +
          (_backTo - _backFrom) * readerTurnCurve.transform(_back.value);
    });
  }

  @override
  void didUpdateWidget(AnnotationCanvas old) {
    super.didUpdateWidget(old);
    if (!identical(old.session, widget.session)) {
      old.session.removeListener(_sessionChanged);
      widget.session.addListener(_sessionChanged);
      _pan.value = widget.session.panOffset;
    }
  }

  void _sessionChanged() {
    final s = widget.session;
    final target = s.panOffset;
    if (s.panning) {
      _back.stop();
      _pan.value = target;
    } else if (_wasPanning && target != _pan.value) {
      // soltou fora do limite: volta do batente (D-165)
      _backFrom = _pan.value;
      _backTo = target;
      _back.forward(from: 0);
    } else if (!_back.isAnimating) {
      _pan.value = target;
    }
    _wasPanning = s.panning;
  }

  @override
  void dispose() {
    widget.session.removeListener(_sessionChanged);
    _back.dispose();
    _pan.dispose();
    _pictures.dispose();
    _dragged.dispose();
    super.dispose();
  }

  /// Com o medidor (S4), o evento só conta se mudou o que a tela mostra: o traço ao vivo, a tinta ou a página (a
  /// palma, o dedo além do 2º e a caneta parada não pintam nada).
  void _measured(PointerEvent e, VoidCallback handle) {
    final m = widget.meter;
    if (m == null) return handle();
    final s = widget.session;
    final live = s.live.value;
    final revision = s.revision;
    final pan = s.panOffset;
    handle();
    if (!identical(live, s.live.value) ||
        revision != s.revision ||
        pan != s.panOffset) {
      m.event(e.timeStamp);
    }
  }

  InkPointer _pointer(PointerEvent e) => (
    id: e.pointer,
    kind: inkPointerKind(e.kind),
    x: e.localPosition.dx,
    y: e.localPosition.dy,
    pressure: inkPressure(e),
    tMs: e.timeStamp.inMilliseconds,
  );

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final size = MediaQuery.sizeOf(context);
    // a página sobe até a base da última linha passar do topo da borda de mesa (D-165)
    final lines = s.geometry.lines;
    s.panLimit = lines.isEmpty
        ? 0
        : panLimit(
            lastLineBottom: lines.last.bottom + s.textShift,
            deskTop: size.height - deskEdgeHeight,
          );
    return Semantics(
      container: true,
      label: widget.semanticsLabel,
      value: widget.page.spokenText,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) {
          // um toque durante a volta do batente: a página vai ao lugar final já (onde a sessão põe o traço)
          if (_back.isAnimating) {
            _back.stop();
            _pan.value = s.panOffset;
          }
          _measured(e, () => s.pointerDown(_pointer(e)));
        },
        onPointerMove: (e) => _measured(e, () => s.pointerMove(_pointer(e))),
        onPointerUp: (e) => s.pointerUp(_pointer(e)),
        onPointerCancel: (e) => s.pointerCancel(_pointer(e)),
        child: Stack(
          children: [
            // a página, o traço ao vivo e o indicador em camadas próprias: o dedo andando não repinta o texto
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  key: const ValueKey('ann.canvas.page'),
                  painter: AnnotationPagePainter(
                    session: s,
                    page: widget.page,
                    pageBox: widget.pageBox,
                    paper: widget.paper,
                    lightText: widget.lightText,
                    highlights: widget.highlights,
                    inkHighlights: widget.inkHighlights,
                    pan: _pan,
                    enter: widget.enter,
                    pictures: _pictures,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  key: const ValueKey('ann.canvas.live'),
                  painter: AnnotationLivePainter(
                    session: s,
                    pageBox: widget.pageBox,
                    pan: _pan,
                    enter: widget.enter,
                    dragged: _dragged,
                    lightText: widget.lightText,
                  ),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: widget.pageBox,
              child: const SizedBox(key: ValueKey('ann.page')),
            ),
            Positioned.fill(
              child: RepaintBoundary(
                child: ValueListenableBuilder<InkOffset?>(
                  valueListenable: s.touch,
                  builder: (context, at, _) => at == null
                      ? const SizedBox.shrink()
                      : TouchIndicator(
                          at: Offset(at.x, at.y),
                          ink: Color(s.color),
                          dot:
                              s.tool != AnnotationTool.eraser &&
                              s.tool != AnnotationTool.lasso,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O papel e a página (recortada em [pageBox], 30 px + o deslocamento abaixo do leitor limpo), com os grifos que a
/// sessão não escondeu e a tinta dela.
class AnnotationPagePainter extends CustomPainter {
  AnnotationPagePainter({
    required this.session,
    required this.page,
    required this.pageBox,
    required this.paper,
    required this.pan,
    required this.pictures,
    this.enter = kAlwaysCompleteAnimation,
    this.lightText,
    this.highlights = const [],
    this.inkHighlights = const [],
  }) : super(
         // a folha repinta quando a tinta muda (a revisão), não a cada aviso da sessão (a ferramenta, os ajustes, o
         // arrasto na roda); no Noite, também com o Marca-texto ao vivo, que vai nela (R26) — só com ele
         repaint: Listenable.merge([
           session.revisions,
           pan,
           enter,
           if (lightText != null) session.liveMarker,
         ]),
       );

  final AnnotationSession session;
  final DisplayPage page;
  final Rect pageBox;
  final Color paper;
  final Color? lightText;
  final List<PaintedHighlight> highlights, inkHighlights;
  final ValueListenable<double> pan;

  /// A entrada e a saída do modo (0–1): quanto dos 30 px o texto já desceu.
  final ValueListenable<double> enter;
  final InkPictureCache pictures;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = paper);
    final hidden = session.hiddenHighlights;
    final light = lightText;
    // no Noite, o Marca-texto ao vivo é pintado aqui, por trás das letras e por cima, com os fundos (D-133 — R26)
    final live = light == null ? null : session.liveMarker.value;
    ui.Picture? picture(InkPass pass) => pictures.pictureOf(
      session,
      session.revision,
      () => session.visibleStrokes,
      lightText: light,
      pass: pass,
    );
    canvas
      ..save()
      ..clipRect(pageBox)
      ..translate(0, session.textShift * enter.value + pan.value);
    // com a mesa (G17), os grifos vêm da sessão: o marca-texto e a D-32 aparecem antes do Concluir
    paintTextPage(
      canvas,
      page,
      highlights: [
        for (final h in session.paintedHighlights ?? highlights)
          if (!hidden.contains(h.id)) h,
      ],
      inkHighlights: [
        for (final h in session.paintedInkHighlights ?? inkHighlights)
          if (!hidden.contains(h.id)) h,
      ],
      lightText: light,
      paintInkBehind: light == null
          ? null
          : _noite(picture(InkPass.behind), live, (c, s) {
              paintInkBehind(c, s, lightText: light);
            }),
      paintInkFill: light == null
          ? null
          : _noite(picture(InkPass.fill), live, (c, s) {
              paintInkFill(c, s, lightText: light);
            }),
      paintInkLayer: (c) {
        final p = picture(InkPass.top);
        if (p != null) c.drawPicture(p);
      },
    );
    canvas.restore();
  }

  /// A passada do Noite: a `Picture` da tinta salva e o Marca-texto ao vivo [live]; `null` sem nenhum dos dois.
  static void Function(Canvas)? _noite(
    ui.Picture? picture,
    InkStroke? live,
    void Function(Canvas, List<InkStroke>) paintLive,
  ) {
    if (picture == null && live == null) return null;
    return (c) {
      if (picture != null) c.drawPicture(picture);
      if (live != null) paintLive(c, [live]);
    };
  }

  @override
  bool shouldRepaint(AnnotationPagePainter old) =>
      !identical(old.session, session) ||
      !identical(old.page, page) ||
      old.pageBox != pageBox ||
      old.paper != paper ||
      old.lightText != lightText ||
      !identical(old.highlights, highlights) ||
      !identical(old.inkHighlights, inkHighlights) ||
      !identical(old.pan, pan) ||
      !identical(old.enter, enter) ||
      !identical(old.pictures, pictures);
}

/// O que acontece agora: o traço ao vivo, a prévia da Reta, o contorno do Laço e a seleção (com o arrasto).
class AnnotationLivePainter extends CustomPainter {
  AnnotationLivePainter({
    required this.session,
    required this.pageBox,
    required this.pan,
    this.enter = kAlwaysCompleteAnimation,
    this.dragged,
    this.lightText,
  }) : super(
         repaint: Listenable.merge([
           session.live,
           session.selection,
           pan,
           enter,
         ]),
       );

  final AnnotationSession session;
  final Rect pageBox;
  final ValueListenable<double> pan;
  final ValueListenable<double> enter;

  /// Os traços do arrasto do Laço gravados numa `Picture` (pela seleção e pela revisão da tinta); sem ela, o
  /// contorno é refeito a cada quadro.
  final InkPictureCache? dragged;

  /// As letras do Noite (R26): a tinta pela D-174; o Marca-texto ao vivo fica com a folha (D-133).
  final Color? lightText;

  @override
  void paint(Canvas canvas, Size size) {
    final live = session.live.value;
    final sel = session.selection.value;
    if (live == null && sel == null) return;
    canvas
      ..save()
      ..clipRect(pageBox)
      ..translate(0, session.textShift * enter.value + pan.value);
    final light = lightText;
    switch (live) {
      case LiveStroke(:final stroke) || LiveLine(:final stroke):
        paintInk(canvas, [stroke], lightText: light);
      case LiveMarker(:final stroke):
        if (light == null) paintInk(canvas, [stroke]);
      case LiveLasso(:final polygon):
        if (polygon.length > 1) {
          paintLassoShape(
            canvas,
            Path()
              ..addPolygon([for (final p in polygon) Offset(p.x, p.y)], true),
          );
        }
      case null:
        break;
    }
    if (sel != null) {
      if (sel.dragging) {
        final cache = dragged;
        final picture = cache?.pictureOf(
          sel.strokes,
          session.revision,
          () => session.selectedStrokes,
          lightText: light,
        );
        if (picture != null) {
          canvas
            ..save()
            ..translate(sel.dx, sel.dy)
            ..drawPicture(picture)
            ..restore();
        } else {
          paintInk(canvas, [
            for (final s in session.selectedStrokes)
              s.translated(sel.dx, sel.dy),
          ], lightText: light);
        }
      }
      final f = sel.frame;
      paintLassoShape(
        canvas,
        Path()..addRRect(
          RRect.fromLTRBR(
            f.left,
            f.top,
            f.right,
            f.bottom,
            const Radius.circular(lassoFrameRadius),
          ),
        ),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(AnnotationLivePainter old) =>
      !identical(old.session, session) ||
      old.pageBox != pageBox ||
      !identical(old.pan, pan) ||
      !identical(old.enter, enter) ||
      !identical(old.dragged, dragged) ||
      old.lightText != lightText;
}

/// O contorno do Laço e a seleção: lavanda a 35 % e o traço `#1A1714` de 1,7 tracejado 4/3.
void paintLassoShape(Canvas canvas, Path shape) {
  canvas
    ..drawPath(shape, Paint()..color = lassoFill)
    ..drawPath(
      dashedPath(shape, lassoDash, lassoGap),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lassoStroke
        ..color = AppColors.ink,
    );
}

/// [source] em traços de [on] com vãos de [off], ao longo de cada contorno.
Path dashedPath(Path source, double on, double off) {
  final out = Path();
  for (final m in source.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      final end = (d + on).clamp(0, m.length).toDouble();
      out.addPath(m.extractPath(d, end), Offset.zero);
      d = end + off;
    }
  }
  return out;
}

/// O indicador de toque (D-167 6), centrado no dedo: o anel e, se [dot], o ponto na cor da tinta.
class TouchIndicator extends StatelessWidget {
  const TouchIndicator({
    super.key,
    required this.at,
    required this.ink,
    required this.dot,
  });

  final Offset at;
  final Color ink;
  final bool dot;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        left: at.dx - touchRingSize / 2,
        top: at.dy - touchRingSize / 2,
        child: const IgnorePointer(
          child: CustomPaint(
            key: ValueKey('ann.page.text.wavy.touchRing'),
            painter: DashedStadiumPainter(color: AppColors.ink),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: touchRingFill,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(dimension: touchRingSize),
            ),
          ),
        ),
      ),
      if (dot)
        Positioned(
          left: at.dx - touchDotSize / 2,
          top: at.dy - touchDotSize / 2,
          child: IgnorePointer(
            child: DecoratedBox(
              key: const ValueKey('ann.page.text.wavy.touchDot'),
              decoration: BoxDecoration(
                color: ink,
                shape: BoxShape.circle,
                border: Border.all(
                  width: AppStrokes.regular,
                  color: AppColors.ink,
                ),
              ),
              child: const SizedBox.square(dimension: touchDotSize),
            ),
          ),
        ),
    ],
  );
}

/// A borda de mesa (L22a nº 15): o papel no pé da tela, opaco nos 135 de baixo e sumindo até os 250; não recebe
/// toque (os toques vão à página).
class DeskEdge extends StatelessWidget {
  const DeskEdge({super.key, required this.paper});

  final Color paper;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: DecoratedBox(
        key: const ValueKey('ann.deskEdge'),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [paper, paper, paper.withValues(alpha: 0)],
            stops: const [0, deskEdgeSolid / deskEdgeHeight, 1],
          ),
        ),
        child: const SizedBox(height: deskEdgeHeight, width: double.infinity),
      ),
    ),
  );
}

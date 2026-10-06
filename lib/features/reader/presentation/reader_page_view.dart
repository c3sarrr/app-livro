// G11.3 — a página do leitor e os gestos de virar (D-22, D-107, D-113):
// - toque pelo terço da largura: esquerdo volta, direito avança, centro chama [onCenter]; o toque num link
//   (no desenho das letras) vale antes dos terços;
// - arrasto horizontal: a página segue o dedo e a vizinha vem junto (carrossel, como o "Deslizar" do Apple
//   Books); ao soltar, completa se passou de 1/4 da largura ou se foi rápido (≥ 300 px/s no sentido), senão
//   volta — 220 ms `easeOutCubic` nos dois casos; no começo e no fim do livro a página anda 1/3 do dedo e volta
//   (batente). Se a vizinha ainda não está montada, desliza o papel e ela aparece quando chega;
// - pressão longa: a seleção da G13 (D-45), avisada à tela; a vizinha que não abre não é batente: soltar vira e a
//   sessão mostra o aviso (D-21). Seguir um link segura os gestos até ele terminar.
// - G13 (D-132, D-136): com uma seleção na tela, o toque é dela ([onTapSelecting]); sem seleção, o link vale
//   primeiro, depois o grifo ([onTapHighlight]), depois os terços.
// - G12 (D-117): com os controles abertos, qualquer toque só fecha os controles ([onCenter]); o arrasto vira como
//   sempre e avisa [onDragStarted] (a tela fecha os controles). A ocorrência da busca (D-120) é pintada por trás
//   das letras na cor [foundColor].
// A página atual é lida do documento na hora de pintar (ele avisa quando ela muda por dentro).
import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/widgets.dart';

import '../application/reader_document.dart';
import '../application/reader_errors.dart';
import 'page_marks.dart';

/// D-22 / D-107.
const Duration readerTurnDuration = Duration(milliseconds: 220);
const Curve readerTurnCurve = Curves.easeOutCubic;

/// Fração da largura que completa a virada ao soltar (D-107).
const double readerTurnThreshold = 1 / 4;

/// Velocidade (px/s, no sentido do arrasto) que completa a virada mesmo curta (D-107).
const double readerTurnFling = 300;

/// No começo e no fim do livro a página anda esta fração do dedo (batente — D-107).
const double readerEdgeFactor = 1 / 3;

/// Quanto o toque nos terços espera a vizinha antes de deslizar (normalmente ela já está montada).
const Duration readerPeekWait = Duration(milliseconds: 50);

class ReaderPageView extends StatefulWidget {
  const ReaderPageView({
    super.key,
    required this.document,
    required this.onTurn,
    required this.onCenter,
    required this.onLink,
    required this.onInteraction,
    this.controlsOpen = false,
    this.onDragStarted,
    this.foundColor,
    this.foundLightText,
    this.highlights,
    this.selection,
    this.selectionColor,
    this.selecting = false,
    this.onTapSelecting,
    this.onTapHighlight,
    this.onLongPressStart,
    this.onLongPressMove,
    this.onLongPressEnd,
  });

  final ReaderDocument document;

  /// Há uma seleção na tela (G13): o toque vai para [onTapSelecting] (fechar ou não — D-136).
  final bool selecting;
  final ValueChanged<Offset>? onTapSelecting;

  /// Toque fora de link: `true` = era um grifo e a tela abriu a barra dele (D-132); senão valem os terços.
  final bool Function(Offset p)? onTapHighlight;

  /// Pressão longa (a seleção — D-45), arrastar sem soltar e soltar.
  final ValueChanged<Offset>? onLongPressStart;
  final ValueChanged<Offset>? onLongPressMove;
  final VoidCallback? onLongPressEnd;

  /// Os controles estão abertos: o toque só os fecha (D-117).
  final bool controlsOpen;

  /// Um arrasto começou (a tela fecha os controles — D-117).
  final VoidCallback? onDragStarted;

  /// Cor da marca da busca (a `brand` — D-120); `null` = não pinta.
  final Color? foundColor;

  /// A cor das letras quando são mais claras que o papel (o Noite): a palavra marcada fica escura (D-127), e o
  /// mesmo nos grifos e na seleção (D-133).
  final Color? foundLightText;

  /// Os grifos do livro, pintados por trás das letras (G13).
  final HighlightSource? highlights;

  /// A seleção (G13), pintada na cor [selectionColor] (a `brand`).
  final ValueListenable<ReaderRange?>? selection;
  final Color? selectionColor;

  /// Vira de verdade (a sessão conta a virada); `false` = começo/fim do livro, ou não deu (a sessão mostra o
  /// aviso).
  final Future<bool> Function(PageDirection d) onTurn;
  final VoidCallback onCenter;

  /// Segue um link; a página não aceita outro gesto até ele terminar.
  final Future<void> Function(LinkHit link) onLink;

  /// Qualquer toque ou arrasto (tempo automático e tela acesa).
  final VoidCallback onInteraction;

  @override
  State<ReaderPageView> createState() => _ReaderPageViewState();
}

class _ReaderPageViewState extends State<ReaderPageView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: readerTurnDuration,
  );

  /// Deslocamento da página atual (negativo = indo para a próxima).
  double _dx = 0;

  /// Para onde a página está indo e a vizinha desse lado (`null` = ainda não chegou).
  PageDirection? _dir;
  DisplayPage? _neighbor;

  /// A vizinha desse lado não existe (começo/fim do livro).
  bool _edge = false;

  /// Arrasto bruto (sem o batente).
  double _drag = 0;
  bool _dragging = false;

  /// Uma virada (ou volta) animando ou esperando o documento: gestos novos esperam.
  bool _busy = false;
  int _peekGen = 0;

  double get _width => context.size?.width ?? 0;

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // ---- vizinha ---------------------------------------------------------------------------------------

  /// Pede a vizinha de [d]; quando chega (ainda do mesmo lado), aparece ou vira batente.
  Future<DisplayPage?> _peek(PageDirection d) {
    final gen = ++_peekGen;
    _dir = d;
    _neighbor = null;
    _edge = false;
    final f = widget.document.peek(d);
    unawaited(
      f.then(
        (page) {
          if (!mounted || gen != _peekGen) return;
          setState(() {
            _neighbor = page;
            _edge = page == null;
            if (_dragging) _dx = _offsetFor(_drag);
          });
        },
        // vizinha que não abre não é batente: soltar vira, e a sessão mostra o aviso
        onError: (Object _) {},
      ),
    );
    return f;
  }

  double _offsetFor(double drag) => _edge ? drag * readerEdgeFactor : drag;

  // ---- toque -----------------------------------------------------------------------------------------

  void _tapUp(TapUpDetails d) {
    if (_busy) return;
    widget.onInteraction();
    if (widget.controlsOpen) {
      // com os controles abertos o toque só os fecha: nem vira, nem segue link (D-117)
      widget.onCenter();
      return;
    }
    if (widget.selecting) {
      // com uma seleção na tela o toque é dela: fecha ou não (D-136), nunca vira nem segue link
      widget.onTapSelecting?.call(d.localPosition);
      return;
    }
    // sem seleção: o link primeiro (G11), depois o grifo (a barra dele — D-132), depois os terços
    final hit = widget.document.current.linkAt(d.localPosition);
    if (hit != null) {
      unawaited(_follow(hit));
      return;
    }
    if (widget.onTapHighlight?.call(d.localPosition) ?? false) return;
    final x = d.localPosition.dx / _width;
    if (x < 1 / 3) {
      unawaited(_tapTurn(PageDirection.backward));
    } else if (x > 2 / 3) {
      unawaited(_tapTurn(PageDirection.forward));
    } else {
      widget.onCenter();
    }
  }

  Future<void> _follow(LinkHit hit) async {
    _busy = true;
    try {
      await widget.onLink(hit);
    } on Object catch (e, st) {
      reportReaderError(e, st);
    } finally {
      _busy = false;
    }
  }

  Future<void> _tapTurn(PageDirection d) async {
    _busy = true;
    final f = _peek(d);
    DisplayPage? page;
    var arrived = false;
    var failed = false;
    await Future.any<void>([
      f.then(
        (p) {
          page = p;
          arrived = true;
        },
        onError: (Object _) {
          arrived = true;
          failed = true;
        },
      ),
      Future<void>.delayed(readerPeekWait),
    ]);
    if (!mounted) return;
    if (arrived && page == null && !failed) {
      // começo/fim do livro: o toque nas laterais não faz nada (D-107)
      _reset();
      return;
    }
    await _complete(d);
  }

  // ---- arrasto ---------------------------------------------------------------------------------------

  void _dragStart(DragStartDetails _) {
    if (_busy) return;
    widget.onInteraction();
    widget.onDragStarted?.call();
    _dragging = true;
    _drag = 0;
    _dir = null;
    _neighbor = null;
    _edge = false;
  }

  void _dragUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    _drag += d.delta.dx;
    if (_drag == 0) return;
    final dir = _drag < 0 ? PageDirection.forward : PageDirection.backward;
    if (dir != _dir) unawaited(_peek(dir));
    setState(() => _dx = _offsetFor(_drag));
  }

  void _dragEnd(DragEndDetails d) {
    if (!_dragging) return;
    _dragging = false;
    final dir = _dir;
    final v = d.velocity.pixelsPerSecond.dx;
    final fast = v.abs() >= readerTurnFling && v.sign == _dx.sign && _dx != 0;
    final far = _dx.abs() >= _width * readerTurnThreshold;
    widget.onInteraction();
    if (dir != null && !_edge && (far || fast)) {
      _busy = true;
      unawaited(_complete(dir));
    } else {
      _busy = true;
      unawaited(_animateTo(0).then((_) => _reset()));
    }
  }

  // ---- animação --------------------------------------------------------------------------------------

  Future<void> _animateTo(double target) async {
    final from = _dx;
    if (from == target) return;
    void tick() {
      if (!mounted) return;
      setState(() {
        _dx = from + (target - from) * readerTurnCurve.transform(_anim.value);
      });
    }

    _anim
      ..removeListener(tick)
      ..addListener(tick);
    try {
      await _anim.forward(from: 0).orCancel;
    } on TickerCanceled {
      // a tela saiu no meio
    } finally {
      _anim.removeListener(tick);
    }
  }

  /// Desliza até a vizinha ocupar a tela, vira de verdade e volta o deslocamento a 0 (a página nova é a atual).
  /// Aconteça o que acontecer na virada, a página volta a aceitar gestos.
  Future<void> _complete(PageDirection d) async {
    try {
      final w = _width;
      await _animateTo(d == PageDirection.forward ? -w : w);
      if (!mounted) return;
      bool ok;
      try {
        ok = await widget.onTurn(d);
      } on Object catch (e, st) {
        reportReaderError(e, st);
        ok = false;
      }
      if (!mounted) return;
      if (!ok) {
        // não virou (fim do livro descoberto tarde, ou falhou — a sessão mostra o aviso): volta
        setState(() => _edge = true);
        await _animateTo(0);
      }
    } finally {
      _reset();
    }
  }

  void _reset() {
    if (!mounted) return;
    _peekGen++;
    setState(() {
      _dx = 0;
      _dir = null;
      _neighbor = null;
      _edge = false;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    // o leitor de tela usa as ações do nó da página (r19.page), não um toque sem rótulo no meio da tela
    excludeFromSemantics: true,
    // pressão longa: a seleção da tela 21 (D-45); segurar e soltar nunca vale como toque (D-113)
    onLongPressStart: (d) {
      if (_busy || widget.onLongPressStart == null) return;
      widget.onInteraction();
      widget.onLongPressStart!(d.localPosition);
    },
    onLongPressMoveUpdate: (d) => widget.onLongPressMove?.call(d.localPosition),
    onLongPressEnd: (_) => widget.onLongPressEnd?.call(),
    // o deslocamento conta do ponto onde o dedo encostou (a página acompanha o dedo desde o começo)
    dragStartBehavior: DragStartBehavior.down,
    onTapUp: _tapUp,
    onHorizontalDragStart: _dragStart,
    onHorizontalDragUpdate: _dragUpdate,
    onHorizontalDragEnd: _dragEnd,
    child: CustomPaint(
      key: const ValueKey('leitor.paginas'),
      size: Size.infinite,
      painter: ReaderPagesPainter(
        document: widget.document,
        dx: _dx,
        dir: _dir,
        neighbor: _neighbor,
        foundColor: widget.foundColor,
        foundLightText: widget.foundLightText,
        highlights: widget.highlights,
        selection: widget.selection,
        selectionColor: widget.selectionColor,
      ),
    ),
  );
}

/// A página atual deslocada por [dx] e a vizinha encostada nela, do lado de [dir]. Repinta quando o documento
/// avisa que a página atual mudou por dentro ([ReaderDocument.changes]) ou quando um dos campos muda. A marca da
/// busca ([ReaderDocument.found]) vai por trás das letras da página atual, na cor [foundColor]; com letras
/// claras ([foundLightText], o Noite) a palavra marcada fica escura (D-127). G13: os grifos ([highlights]) e a
/// seleção ([selection]) também, com recorte por prioridade (`page_marks.dart`); o sublinhado vai por cima. A
/// vizinha que chega no arrasto vem com os grifos dela.
class ReaderPagesPainter extends CustomPainter {
  ReaderPagesPainter({
    required this.document,
    required this.dx,
    required this.dir,
    required this.neighbor,
    this.foundColor,
    this.foundLightText,
    this.highlights,
    this.selection,
    this.selectionColor,
  }) : super(
         repaint: Listenable.merge(<Listenable?>[
           document.changes,
           highlights,
           selection,
         ]),
       );

  final ReaderDocument document;
  final double dx;
  final PageDirection? dir;
  final DisplayPage? neighbor;
  final Color? foundColor;
  final Color? foundLightText;
  final HighlightSource? highlights;
  final ValueListenable<ReaderRange?>? selection;
  final Color? selectionColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..translate(dx, 0);
    final page = document.current;
    if (page.opaque) {
      // a imagem do PDF cobriria a marca: ela vai por cima, multiplicada (G12)
      page.paint(canvas);
      final f = document.found;
      final color = foundColor;
      if (f != null && color != null) {
        final paint = Paint()
          ..color = color
          ..blendMode = BlendMode.multiply;
        for (final r in page.rectsOf(f.unit, f.from, f.to)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              r.inflate(foundInflate),
              const Radius.circular(foundRadius),
            ),
            paint,
          );
        }
      }
    } else {
      _paintText(
        canvas,
        page,
        found: document.found,
        selection: selection?.value,
      );
    }
    canvas.restore();
    final n = neighbor;
    if (n == null || dir == null || dx == 0) return;
    final offset = dir == PageDirection.forward
        ? dx + size.width
        : dx - size.width;
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..translate(offset, 0);
    // a vizinha chega com os grifos dela; a seleção e a marca da busca são só da atual
    if (n.opaque) {
      n.paint(canvas);
    } else {
      _paintText(canvas, n);
    }
    canvas.restore();
  }

  /// Uma página de texto: os fundos (grifos, marca da busca, seleção) por trás das letras — no Noite, pela técnica
  /// da D-127 — e os sublinhados por cima.
  void _paintText(
    Canvas canvas,
    DisplayPage page, {
    FoundRange? found,
    ReaderRange? selection,
  }) {
    final light = foundLightText;
    final shown = page.shown;
    final hs = shown == null
        ? const <PaintedHighlight>[]
        : highlights?.highlightsIn(shown) ?? const <PaintedHighlight>[];
    final bands = backgroundBands(
      page,
      highlights: hs,
      found: found,
      foundColor: foundColor,
      selection: selection,
      selectionColor: selectionColor,
      night: light != null,
    );
    if (light == null) {
      // letras escuras: os fundos vão por trás delas
      for (final b in bands) {
        paintBand(canvas, b, b.color);
      }
      page.paint(canvas);
    } else {
      // letras claras (o Noite — D-127/D-133): a palavra fica escura no fundo sem refazer a página e sem
      // camada. Com D = o maior de letra e cor em cada canal, por trás vai D − cor e, por cima, D em diferença:
      // o fundo volta a ser a cor exata e a letra vira D − letra (quase preta), passando pelas bordas sem degrau.
      for (final b in bands) {
        paintBand(canvas, b, channelMinus(channelMax(light, b.color), b.color));
      }
      page.paint(canvas);
      for (final b in bands) {
        paintBand(canvas, b, channelMax(light, b.color), BlendMode.difference);
      }
    }
    paintUnderlines(canvas, page, hs);
  }

  @override
  bool shouldRepaint(ReaderPagesPainter old) =>
      old.dx != dx ||
      old.dir != dir ||
      old.foundColor != foundColor ||
      old.foundLightText != foundLightText ||
      !identical(old.highlights, highlights) ||
      !identical(old.selection, selection) ||
      old.selectionColor != selectionColor ||
      !identical(old.neighbor, neighbor) ||
      !identical(old.document, document);
}

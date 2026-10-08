// G16.3 — a sessão do modo anotação (tela 22, §3): uma por entrada no modo, sobre o retrato da página aberta.
// - Entrada: os eventos crus do `Listener` (coordenadas da tela) passam pelo árbitro de dedos e caneta; os pontos do
//   desenho vão para as coordenadas do leitor limpo (sem os 30 px do modo e sem o deslocamento da página).
// - Caneta: traço suavizado com a ponta, a cor e a espessura do `pen_presets`; com o dedo, a pressão é simulada pela
//   velocidade na captura e gravada no ponto (a caneta do aparelho grava a dela); um toque sem arrastar = 1 ponto.
//   O traço entra no desenho que ele toca, com a folga de meia linha (D-162); o desenho que passaria de 256 KiB
//   fecha e o traço começa outro.
// - Reta: do toque até o dedo, grudada em 15° (menos de 4°); com menos de 4 px não cria nada; grava 2 pontos.
// - Borracha: cada passada (do toque ao soltar) é um passo do desfazer; o que ela toca some já na passada. Só tinta
//   (D-168): os traços e os grifos feitos à mão; o grifo de seleção nem é candidato.
// - Laço: o contorno ao vivo; ao soltar, seleciona os traços com ≥ 50 % dos pontos dentro; arrastar dentro do
//   retângulo (6 px de folga) move ao vivo e grava ao soltar; tocar fora solta; a Borracha com a seleção apaga os
//   selecionados (um passo) e fica ativa (D-46).
// - 2 dedos: a página sobe e desce, com o batente (D-165); ao soltar, volta para dentro dos limites (a tela anima).
// - Marca-texto e Espaço são das fases seguintes (D-163): `setTool` recusa e a ferramenta atual continua.
// - O Concluir grava as mudanças da sessão numa transação: os desenhos novos e mudados com a âncora refeita sobre o
//   desenho inteiro (D-162), os pontos em em, o grupo dos cartões (Anexo 02 §4.3), os apagados e os grifos à mão
//   apagados. O rascunho vai ao `kv` a cada 5 s com mudanças e no segundo plano (D-166). A falha ao salvar deixa o
//   modo aberto com a pílula (D-21) e o rascunho guardado.
// - Cada toque avisa a sessão de leitura (D-95).
import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/data/ids/uuid_v7.dart';
import '../annotations/domain/pen_presets.dart';
import '../annotations/ink/bnk1_codec.dart';
import '../annotations/ink/card_groups.dart';
import '../annotations/ink/drawing_anchor.dart';
import '../annotations/ink/drawing_clusters.dart';
import '../annotations/ink/freehand.dart';
import '../annotations/ink/gesture_arbiter.dart';
import '../annotations/ink/ink_changes.dart';
import '../annotations/ink/ink_commands.dart';
import '../annotations/ink/ink_geometry.dart';
import '../annotations/ink/ink_stroke.dart';
import '../annotations/ink/ink_tools.dart';
import '../annotations/ink/ink_units.dart';
import '../annotations/ink_repository.dart';
import '../domain/anchoring.dart' show quoteAt;
import '../domain/locator.dart';
import '../layout/display_page.dart' show ReaderRange;
import 'annotation_anchors.dart';
import 'reader_errors.dart';

/// O texto desce 30 px no modo anotação (24 da página + 6 do respiro em cima — L22a).
const double annotationTextShift = 30;

/// O rascunho vai ao `kv` a cada tanto, quando há mudanças (D-166).
const Duration inkDraftEvery = Duration(seconds: 5);

/// A folga do retângulo da seleção do Laço (D-21).
const double lassoPadding = 6;

/// As ferramentas da prateleira (L22c), na ordem dela.
enum AnnotationTool {
  pen,
  marker,
  eraser,
  lasso,
  line,
  space;

  /// O Marca-texto (G17) e o Espaço (G18) ficam para as fases seguintes (D-163).
  bool get inThisPhase => this != marker && this != space;
}

/// Um desenho salvo na página aberta: o que ele tinha no banco, o trecho dele no texto e os traços já na página
/// (coordenadas do leitor limpo).
typedef PageDrawing = ({
  SavedDrawingRef saved,
  ReaderRange range,
  List<InkStroke> strokes,
});

/// Um grifo da página: o id, se veio da tinta (só esses a Borracha apaga — D-168) e a área pintada em cada linha
/// (coordenadas do leitor limpo).
typedef PageHighlight = ({String id, bool ink, List<InkRect> areas});

/// O que está sendo desenhado agora (coordenadas do leitor limpo).
@immutable
sealed class LiveInk {
  const LiveInk();
}

/// O traço da Caneta, ao vivo.
final class LiveStroke extends LiveInk {
  const LiveStroke(this.stroke);

  final InkStroke stroke;
}

/// A prévia da Reta (2 pontos, já grudada).
final class LiveLine extends LiveInk {
  const LiveLine(this.stroke);

  final InkStroke stroke;
}

/// O contorno do Laço.
final class LiveLasso extends LiveInk {
  const LiveLasso(this.polygon);

  final List<InkOffset> polygon;
}

/// A seleção do Laço: os traços, a caixa deles e o arrasto em curso ([dx], [dy]).
@immutable
final class LassoSelection {
  const LassoSelection({
    required this.strokes,
    required this.bounds,
    this.dx = 0,
    this.dy = 0,
  });

  final Set<int> strokes;

  /// A caixa dos traços selecionados, antes do arrasto.
  final InkRect bounds;
  final double dx;
  final double dy;

  /// O retângulo mostrado (e onde arrastar move): a caixa com a folga, já com o arrasto.
  InkRect get frame {
    final f = bounds.inflate(lassoPadding);
    return InkRect(f.left + dx, f.top + dy, f.right + dx, f.bottom + dy);
  }

  bool get dragging => dx != 0 || dy != 0;

  LassoSelection movedBy(double dx, double dy) =>
      LassoSelection(strokes: strokes, bounds: bounds, dx: dx, dy: dy);

  @override
  bool operator ==(Object other) =>
      other is LassoSelection &&
      setEquals(other.strokes, strokes) &&
      other.bounds == bounds &&
      other.dx == dx &&
      other.dy == dy;

  @override
  int get hashCode =>
      Object.hash(Object.hashAllUnordered(strokes), bounds, dx, dy);
}

enum _Mode { pen, line, erase, lasso, move }

void _nothing() {}

Future<void> _noSave(PenPresets _) async {}

final class AnnotationSession extends ChangeNotifier {
  AnnotationSession({
    required this.geometry,
    required this.anchors,
    required List<PageDrawing> drawings,
    required List<PageHighlight> highlights,
    required PenPresets presets,
    required this.repository,
    required this.owner,
    required this.userBookId,
    this.startTimer = Timer.new,
    DateTime Function()? now,
    UuidV7Generator? ids,
    this.onError = reportReaderError,
    this.onInteraction = _nothing,
    this.savePresets = _noSave,
    this.textShift = annotationTextShift,
  }) : _pen = presets,
       _now = now ?? DateTime.now,
       _ids = ids ?? UuidV7Generator(),
       _highlights = List.unmodifiable(highlights) {
    final initial = <SessionDrawing>[];
    for (final d in drawings) {
      final id = d.saved.layerId;
      _saved[id] = d;
      _initialStrokes[id] = d.strokes;
      initial.add(
        SessionDrawing(
          id: id,
          order: _nextOrder++,
          strokes: List.unmodifiable([
            for (final s in d.strokes) SessionStroke(_nextStroke++, s),
          ]),
          saved: d.saved,
        ),
      );
    }
    _copy = InkWorkingCopy(initial);
    _history = InkHistory(_copy);
    _armDraft();
  }

  /// As linhas e as palavras da página (coordenadas do leitor limpo).
  final InkPageGeometry geometry;
  final AnnotationAnchors anchors;
  final InkRepository repository;
  final String owner;
  final String userBookId;
  final ReaderErrorReporter onError;

  /// Quanto o texto desceu no modo.
  final double textShift;

  final Timer Function(Duration duration, void Function() callback) startTimer;
  final DateTime Function() _now;
  final UuidV7Generator _ids;

  /// Cada toque é interação da leitura (D-95).
  final void Function() onInteraction;

  /// Grava o `pen_presets` (a espessura vale para todos os livros).
  final Future<void> Function(PenPresets presets) savePresets;
  final List<PageHighlight> _highlights;

  final InkGestureArbiter _arbiter = InkGestureArbiter();
  late final InkWorkingCopy _copy;
  late final InkHistory _history;

  /// Os desenhos salvos da página (pelo id da camada) e os traços com que eles chegaram.
  final Map<String, PageDrawing> _saved = {};
  final Map<String, List<InkStroke>> _initialStrokes = {};

  /// A hora de criação e a anotação de cada desenho novo (ficam no desfazer e no refazer).
  final Map<String, DateTime> _createdAt = {};
  final Map<String, String> _annotationOf = {};

  int _nextOrder = 0;
  int _nextStroke = 0;

  PenPresets _pen;
  AnnotationTool _tool = AnnotationTool.pen;

  /// O traço ao vivo, a prévia da Reta ou o contorno do Laço.
  final ValueNotifier<LiveInk?> live = ValueNotifier(null);

  /// Onde está o dedo que desenha (coordenadas da tela), para o indicador de toque; com a caneta, `null`.
  final ValueNotifier<InkOffset?> touch = ValueNotifier(null);

  /// A seleção do Laço.
  final ValueNotifier<LassoSelection?> selection = ValueNotifier(null);

  _Mode? _mode;
  int _t0 = 0;
  double _size = 0;
  final List<InkPoint> _points = [];
  InkOffset? _lineStart;
  InkOffset? _lineEnd;
  int _lineMs = 0;
  InkOffset? _erasePrev;
  final Set<int> _pendingStrokes = {};
  final Set<String> _pendingHighlights = {};
  final List<InkOffset> _polygon = [];
  InkOffset? _moveFrom;

  double _panRaw = 0;
  double _panOffset = 0;
  bool _panning = false;

  /// Quanto a página pode subir (a tela calcula: a última linha passando da borda de mesa — D-165).
  double panLimit = 0;

  bool _failed = false;
  int _revision = 0;
  bool _unsaved = false;
  Timer? _timer;
  bool _disposed = false;

  AnnotationTool get tool => _tool;
  PenPresets get presets => _pen;
  StrokeSize get strokeSize => _pen.strokeSize;

  /// A cor da Caneta (ARGB).
  int get color => argbOfHex(_pen.penColor);

  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  /// O deslocamento vertical da página (negativo = subiu).
  double get panOffset => _panOffset;

  /// Os dedos estão movendo a página agora (sem animação); ao soltar, a tela anima a volta do batente.
  bool get panning => _panning;

  /// A gravação do Concluir falhou: a pílula "Não deu para salvar as anotações agora." (D-21).
  bool get failed => _failed;

  /// Sobe a cada mudança da tinta mostrada (o cache da pintura).
  int get revision => _revision;

  /// Os desenhos da cópia de trabalho, em ordem de criação.
  List<SessionDrawing> get drawings => _copy.drawings.toList();

  /// Os traços que a página pinta: sem o que a Borracha está apagando e sem a seleção que está sendo arrastada.
  List<InkStroke> get visibleStrokes {
    final moving = selection.value?.dragging ?? false
        ? selection.value!.strokes
        : const <int>{};
    return [
      for (final d in _copy.drawings)
        for (final s in d.strokes)
          if (!_pendingStrokes.contains(s.id) && !moving.contains(s.id))
            s.stroke,
    ];
  }

  /// Os traços selecionados pelo Laço, onde estão (sem o arrasto em curso).
  List<InkStroke> get selectedStrokes {
    final sel = selection.value;
    if (sel == null) return const [];
    return [
      for (final d in _copy.drawings)
        for (final s in d.strokes)
          if (sel.strokes.contains(s.id)) s.stroke,
    ];
  }

  /// Os grifos que não aparecem: os apagados na sessão e os que a Borracha está apagando.
  Set<String> get hiddenHighlights => {
    ..._copy.erasedHighlights,
    ..._pendingHighlights,
  };

  // ---- entrada --------------------------------------------------------------------------------------------

  void pointerDown(InkPointer p) {
    onInteraction();
    _handle(_arbiter.down(p));
  }

  void pointerMove(InkPointer p) => _handle(_arbiter.move(p));

  void pointerUp(InkPointer p) => _handle(_arbiter.up(p));

  void pointerCancel(InkPointer p) => _handle(_arbiter.cancel(p));

  void _handle(List<InkGesture> gestures) {
    for (final g in gestures) {
      switch (g) {
        case DrawStart(:final p):
          _drawStart(p);
        case DrawMove(:final p):
          _drawMove(p);
        case DrawEnd():
          _drawEnd();
        case DrawDiscard():
          _drawDiscard();
        case PanStart():
          _panning = true;
          _panRaw = _panOffset;
          notifyListeners();
        case PanMove(:final dy):
          _panRaw += dy;
          _panOffset = rubberBand(_panRaw, panLimit);
          notifyListeners();
        case PanEnd():
          _panRaw = _panRaw.clamp(-panLimit, 0).toDouble();
          _panOffset = _panRaw;
          _panning = false;
          notifyListeners();
      }
    }
  }

  /// [p] nas coordenadas do leitor limpo.
  InkOffset _page(InkPointer p) => (x: p.x, y: p.y - textShift - _panOffset);

  void _showTouch(InkPointer p) =>
      touch.value = p.kind == InkPointerKind.touch ? (x: p.x, y: p.y) : null;

  void _drawStart(InkPointer p) {
    final at = _page(p);
    _showTouch(p);
    _t0 = p.tMs;
    switch (_tool) {
      case AnnotationTool.pen:
        _mode = _Mode.pen;
        _size = strokeDp(_pen.penWidthMm, strokeSize);
        _points
          ..clear()
          ..add(
            InkPoint(
              at.x,
              at.y,
              p.kind == InkPointerKind.stylus
                  ? p.pressure.clamp(0, 1).toDouble()
                  : firstPressure,
              0,
            ),
          );
        live.value = LiveStroke(_liveStroke());
      case AnnotationTool.line:
        _mode = _Mode.line;
        _lineStart = at;
        _lineEnd = null;
        _lineMs = 0;
        live.value = LiveLine(_lineStroke(at, at, 0));
      case AnnotationTool.eraser:
        _mode = _Mode.erase;
        _erasePrev = at;
        _eraseAlong(at, at);
      case AnnotationTool.lasso:
        final sel = selection.value;
        if (sel != null && _inside(at, sel.frame)) {
          _mode = _Mode.move;
          _moveFrom = at;
          return;
        }
        if (sel != null) _release();
        _mode = _Mode.lasso;
        _polygon
          ..clear()
          ..add(at);
        live.value = LiveLasso(UnmodifiableListView(_polygon));
      case AnnotationTool.marker:
      case AnnotationTool.space:
        _mode = null;
    }
  }

  void _drawMove(InkPointer p) {
    final at = _page(p);
    _showTouch(p);
    switch (_mode) {
      case _Mode.pen:
        final last = _points.last;
        if (last.x == at.x && last.y == at.y) return;
        final dx = at.x - last.x;
        final dy = at.y - last.y;
        final distance = math.sqrt(dx * dx + dy * dy);
        _points.add(
          InkPoint(
            at.x,
            at.y,
            p.kind == InkPointerKind.stylus
                ? p.pressure.clamp(0, 1).toDouble()
                : simulatedPressure(last.pressure, distance, _size),
            p.tMs - _t0,
          ),
        );
        live.value = LiveStroke(_liveStroke());
      case _Mode.line:
        final start = _lineStart!;
        _lineEnd = snapLineEnd(start, at);
        _lineMs = p.tMs - _t0;
        live.value = LiveLine(_lineStroke(start, _lineEnd!, _lineMs));
      case _Mode.erase:
        _eraseAlong(_erasePrev!, at);
        _erasePrev = at;
      case _Mode.lasso:
        _polygon.add(at);
        live.value = LiveLasso(UnmodifiableListView(_polygon));
      case _Mode.move:
        final sel = selection.value!;
        final from = _moveFrom!;
        final wasDragging = sel.dragging;
        selection.value = sel.movedBy(at.x - from.x, at.y - from.y);
        if (wasDragging != selection.value!.dragging) _repaint();
      case null:
        break;
    }
  }

  void _drawEnd() {
    touch.value = null;
    final mode = _mode;
    _mode = null;
    switch (mode) {
      case _Mode.pen:
        live.value = null;
        _addStroke(
          InkStroke(
            tool: InkTool.pen.code,
            tip: tipCode(_pen.penTip),
            argb: color,
            widthCentiMm: widthCentiMm(_pen.penWidthMm, strokeSize),
            points: List.unmodifiable(_points),
          ),
        );
        _points.clear();
      case _Mode.line:
        live.value = null;
        final start = _lineStart!;
        final end = _lineEnd;
        if (end != null && !lineTooShort(start, end)) {
          _addStroke(_lineStroke(start, end, _lineMs));
        }
      case _Mode.erase:
        if (_pendingStrokes.isEmpty && _pendingHighlights.isEmpty) return;
        final strokes = {..._pendingStrokes};
        final highlights = {..._pendingHighlights};
        _pendingStrokes.clear();
        _pendingHighlights.clear();
        _push(Erase(strokeIds: strokes, highlightIds: highlights));
      case _Mode.lasso:
        live.value = null;
        _select(List.of(_polygon));
        _polygon.clear();
      case _Mode.move:
        final sel = selection.value!;
        if (!sel.dragging) return;
        selection.value = LassoSelection(
          strokes: sel.strokes,
          bounds: InkRect(
            sel.bounds.left + sel.dx,
            sel.bounds.top + sel.dy,
            sel.bounds.right + sel.dx,
            sel.bounds.bottom + sel.dy,
          ),
        );
        _push(
          MoveStrokes(
            strokeIds: sel.strokes,
            dx: sel.dx,
            dy: sel.dy,
            newDrawingId: _newDrawing(),
            order: _nextOrder++,
          ),
        );
      case null:
        break;
    }
  }

  void _drawDiscard() {
    touch.value = null;
    final mode = _mode;
    _mode = null;
    switch (mode) {
      case _Mode.pen:
        _points.clear();
        live.value = null;
      case _Mode.line:
      case _Mode.lasso:
        _polygon.clear();
        live.value = null;
      case _Mode.erase:
        if (_pendingStrokes.isEmpty && _pendingHighlights.isEmpty) return;
        _pendingStrokes.clear();
        _pendingHighlights.clear();
        _repaint();
      case _Mode.move:
        final sel = selection.value!;
        if (!sel.dragging) return;
        selection.value = sel.movedBy(0, 0);
        _repaint();
      case null:
        break;
    }
  }

  InkStroke _liveStroke() => InkStroke(
    tool: InkTool.pen.code,
    tip: tipCode(_pen.penTip),
    argb: color,
    widthCentiMm: widthCentiMm(_pen.penWidthMm, strokeSize),
    points: UnmodifiableListView(_points),
  );

  InkStroke _lineStroke(InkOffset a, InkOffset b, int ms) => InkStroke(
    tool: InkTool.line.code,
    tip: tipCode(_pen.penTip),
    argb: color,
    widthCentiMm: widthCentiMm(_pen.penWidthMm, strokeSize),
    points: List.unmodifiable([
      InkPoint(a.x, a.y, 0.5, 0),
      InkPoint(b.x, b.y, 0.5, ms),
    ]),
  );

  static bool _inside(InkOffset p, InkRect r) =>
      p.x >= r.left && p.x <= r.right && p.y >= r.top && p.y <= r.bottom;

  /// Um desenho novo: o id da camada, a anotação e a hora de criação.
  String _newDrawing() {
    final id = _ids.next();
    _annotationOf[id] = _ids.next();
    _createdAt[id] = _now().toUtc();
    return id;
  }

  /// O traço [s] entra no desenho que ele toca (D-162) ou começa outro; o desenho que passaria de 256 KiB fecha.
  void _addStroke(InkStroke s) {
    final drawings = _copy.drawings.toList();
    final touched = touchedDrawing(strokeBox(s), [
      for (final d in drawings)
        (
          order: d.order,
          box: drawingBox([for (final x in d.strokes) x.stroke]),
        ),
    ], lineHeight: geometry.lineHeight);
    final into = touched == null
        ? null
        : drawings.firstWhere((d) => d.order == touched);
    if (into != null && _fits([for (final x in into.strokes) x.stroke, s])) {
      _push(
        AddStroke(
          SessionStroke(_nextStroke++, s),
          into: into.id,
          newDrawingId: into.id,
          order: into.order,
        ),
      );
      return;
    }
    _push(
      AddStroke(
        SessionStroke(_nextStroke++, s),
        into: null,
        newDrawingId: _newDrawing(),
        order: _nextOrder++,
      ),
    );
  }

  /// Os traços [strokes] cabem numa camada, em em na moldura deles.
  bool _fits(List<InkStroke> strokes) {
    final place = placeDrawing(drawingBox(strokes), geometry);
    if (place == null) return true;
    return fitsBnk1([
      for (final s in strokes) toFrame(s, place.frame),
    ], Bnk1Unit.em);
  }

  /// A Borracha andou de [a] a [b]: o que ela toca some já (e é apagado ao soltar).
  void _eraseAlong(InkOffset a, InkOffset b) {
    var changed = false;
    for (final d in _copy.drawings) {
      for (final s in d.strokes) {
        if (_pendingStrokes.contains(s.id)) continue;
        if (eraserTouchesStroke(a, b, s.stroke)) {
          _pendingStrokes.add(s.id);
          changed = true;
        }
      }
    }
    final erased = _copy.erasedHighlights;
    for (final h in _highlights) {
      // só tinta (D-168)
      if (!h.ink ||
          erased.contains(h.id) ||
          _pendingHighlights.contains(h.id)) {
        continue;
      }
      if (h.areas.any((r) => eraserTouchesRect(a, b, r))) {
        _pendingHighlights.add(h.id);
        changed = true;
      }
    }
    if (changed) _repaint();
  }

  /// O Laço de contorno [polygon] seleciona os traços com ≥ 50 % dos pontos dentro.
  void _select(List<InkOffset> polygon) {
    if (polygon.length < 3) return;
    final picked = <int>{};
    final strokes = <InkStroke>[];
    for (final d in _copy.drawings) {
      for (final s in d.strokes) {
        if (lassoSelects(s.stroke, polygon)) {
          picked.add(s.id);
          strokes.add(s.stroke);
        }
      }
    }
    if (picked.isEmpty) return;
    selection.value = LassoSelection(
      strokes: picked,
      bounds: drawingBox(strokes),
    );
  }

  void _release() {
    if (selection.value == null) return;
    selection.value = null;
    _repaint();
  }

  // ---- ferramentas e espessura ------------------------------------------------------------------------------

  /// Troca a ferramenta. O Marca-texto e o Espaço (D-163) devolvem `false` e a atual continua. A Borracha com a
  /// seleção do Laço apaga os selecionados (um passo) e fica ativa.
  bool setTool(AnnotationTool t) {
    if (!t.inThisPhase) return false;
    final sel = selection.value;
    if (sel != null && t != AnnotationTool.lasso) {
      selection.value = null;
      if (t == AnnotationTool.eraser) {
        _push(Erase(strokeIds: sel.strokes, highlightIds: const {}));
      } else {
        _repaint();
      }
    }
    if (t != _tool) {
      _tool = t;
      notifyListeners();
    }
    return true;
  }

  /// Fina, Média ou Grossa: vale para o próximo traço e grava no `pen_presets` na hora (todos os livros).
  void setStrokeSize(StrokeSize s) {
    if (s == _pen.strokeSize) return;
    _pen = _pen.copyWith(strokeSize: s);
    notifyListeners();
    unawaited(
      savePresets(_pen).catchError((Object e, StackTrace st) {
        onError(e, st);
      }),
    );
  }

  // ---- desfazer -----------------------------------------------------------------------------------------------

  void undo() {
    if (_history.undo()) _changed();
  }

  void redo() {
    if (_history.redo()) _changed();
  }

  void _push(InkCommand c) {
    _history.push(c);
    _changed();
  }

  void _changed() {
    _unsaved = true;
    final sel = selection.value;
    if (sel != null) {
      // a seleção segue os traços (o desfazer de um movimento os devolve)
      final strokes = [
        for (final d in _copy.drawings)
          for (final s in d.strokes)
            if (sel.strokes.contains(s.id)) s.stroke,
      ];
      selection.value = strokes.isEmpty
          ? null
          : LassoSelection(strokes: sel.strokes, bounds: drawingBox(strokes));
    }
    _repaint();
  }

  void _repaint() {
    _revision++;
    notifyListeners();
  }

  // ---- o que o Concluir grava -----------------------------------------------------------------------------------

  /// A linha da página que contém o caractere [offset] do item [unit].
  int? _lineOf(int unit, int offset) {
    for (var i = 0; i < geometry.lines.length; i++) {
      final l = geometry.lines[i];
      if (l.unit == unit && offset >= l.from && offset < l.to) return i;
    }
    return null;
  }

  /// As mudanças da sessão: os desenhos novos e mudados (âncora refeita sobre o desenho inteiro — D-162), os salvos
  /// que ficaram sem traços e os grifos à mão apagados.
  InkChanges changes() {
    final present = {for (final d in _copy.drawings) d.id: d};
    final cards = <CardCandidate>[
      for (final d in present.values)
        if (d.saved case final saved?)
          if (_lineOf(_saved[d.id]!.range.unit, _saved[d.id]!.range.from)
              case final line?)
            (
              id: d.id,
              group: saved.groupId,
              line: line,
              createdAt: saved.createdAt,
            ),
    ];
    final rows = <DrawingRow>[];
    for (final d in present.values) {
      final strokes = [for (final s in d.strokes) s.stroke];
      final saved = d.saved;
      if (saved != null && listEquals(strokes, _initialStrokes[d.id])) {
        continue;
      }
      final place = placeDrawing(drawingBox(strokes), geometry);
      if (place == null) continue;
      final unit = geometry.lines[place.line].unit;
      final text = anchors.textOf(unit);
      if (text == null) continue;
      final where = anchors.placeOf(unit, place.from);
      final range = EpubAnchor(
        sha: anchors.sha,
        spine: unit,
        start: place.from,
        end: place.to,
        quote: quoteAt(text, place.from, place.to),
        refPage: where.refPage,
      );
      final annotationId = saved?.annotationId ?? _annotationOf[d.id]!;
      final createdAt = saved?.createdAt ?? _createdAt[d.id]!;
      final group =
          saved?.groupId ??
          cardGroup(id: annotationId, line: place.line, others: cards);
      if (saved == null) {
        cards.add((
          id: d.id,
          group: group,
          line: place.line,
          createdAt: createdAt,
        ));
      }
      rows.add(
        DrawingRow(
          layerId: d.id,
          annotationId: annotationId,
          createdAt: createdAt,
          anchor: inkLayerAnchor(range, place.frame.w),
          range: range,
          refPage: where.refPage,
          chapterIndex: where.chapterIndex,
          groupId: group,
          color: colorHex(strokes.first.argb),
          strokesB64: encodeStrokesB64([
            for (final s in strokes) toFrame(s, place.frame),
          ], Bnk1Unit.em),
          strokeCount: strokes.length,
        ),
      );
    }
    return InkChanges(
      layers: rows,
      deletedLayers: {
        for (final id in _saved.keys)
          if (!present.containsKey(id)) id,
      },
      erasedHighlights: _copy.erasedHighlights,
    );
  }

  /// Concluir: grava numa transação e apaga o rascunho (`true`); sem mudanças, só apaga um rascunho velho. A falha
  /// deixa o modo aberto com a pílula e o rascunho guardado (`false`).
  Future<bool> conclude() async {
    final c = changes();
    if (c.isEmpty) {
      try {
        await repository.clearDraft(owner, userBookId);
      } on Object catch (e, st) {
        onError(e, st);
      }
      _unsaved = false;
      _setFailed(false);
      return true;
    }
    try {
      await repository.commit(owner, userBookId, c);
      await repository.clearDraft(owner, userBookId);
      _unsaved = false;
      _setFailed(false);
      return true;
    } on Object catch (e, st) {
      onError(e, st);
      _setFailed(true);
      try {
        await repository.saveDraft(owner, userBookId, c);
      } on Object catch (e2, st2) {
        onError(e2, st2);
      }
      return false;
    }
  }

  void _setFailed(bool v) {
    if (_failed == v) return;
    _failed = v;
    if (!_disposed) notifyListeners();
  }

  // ---- rascunho -------------------------------------------------------------------------------------------------

  void _armDraft() => _timer = startTimer(inkDraftEvery, _tick);

  void _tick() {
    if (_disposed) return;
    _armDraft();
    if (_unsaved) unawaited(_saveDraft());
  }

  /// O app foi para o segundo plano: o rascunho vai já.
  Future<void> toBackground() async {
    if (_unsaved) await _saveDraft();
  }

  Future<void> _saveDraft() async {
    _unsaved = false;
    try {
      await repository.saveDraft(owner, userBookId, changes());
    } on Object catch (e, st) {
      _unsaved = true;
      onError(e, st);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    live.dispose();
    touch.dispose();
    selection.dispose();
    super.dispose();
  }
}

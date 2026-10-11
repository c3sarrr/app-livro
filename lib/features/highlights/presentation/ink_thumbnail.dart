// G19.6 — a tinta nos cartões da tela 25 (R10), pintada a partir dos traços salvos:
// - o desenho (`drawing`): os traços da camada `over_text` (em em, a partir do começo do trecho, na base) postos de
//   volta sobre o trecho do cartão pela moldura da D-162 (`placedFrame` com o `w` da criação; o trecho que quebra
//   não estica); a espessura não escala;
// - a nota à mão (`handwriting`): os traços na unidade da caixa (x = fração da largura, y = linhas de 42) na caixa da
//   prancha 24b em 390 (334 de largura), reduzidos à altura da miniatura (96) e alinhados à esquerda e ao meio (o
//   `xMinYMid meet` da miniatura do arquivo);
// - cada miniatura é decodificada e vira uma imagem (`toImageSync`) na escala do aparelho uma vez só, guardada por
//   camada, versão, moldura e escala (não pelo lugar: rolar não redesenha); até 64, a mais antiga sai primeiro.
import 'dart:collection';
import 'dart:ui' as ui;

import '../../reader/annotations/domain/ink_layer.dart';
import '../../reader/annotations/ink/bnk1_codec.dart';
import '../../reader/annotations/ink/drawing_anchor.dart';
import '../../reader/annotations/ink/ink_stroke.dart';
import '../../reader/annotations/space/note_ink.dart';
import '../../reader/annotations/space/space_metrics.dart';
import '../../reader/presentation/ink_painter.dart';

/// A largura da caixa da nota à mão em que a miniatura é desenhada (a da prancha 24b em 390).
const double thumbNoteBoxWidth = 334;

/// A altura da tinta da miniatura da nota à mão (`hl.list.card7.body.handNote.ink`).
const double thumbNoteInkHeight = 96;

/// Os traços do desenho [layer] postos sobre os pedaços [pieces] do trecho no cartão; `null` = sem traços ou sem
/// lugar.
List<InkStroke>? drawingInCard(InkLayer layer, List<InkPiece> pieces) {
  final anchor = inkAnchorOf(layer.anchor);
  if (anchor == null || layer.strokesB64.isEmpty) return null;
  final frame = placedFrame(pieces, anchor.w);
  if (frame == null) return null;
  final List<InkStroke> strokes;
  try {
    strokes = decodeStrokesB64(layer.strokesB64, Bnk1Unit.em);
  } on Object {
    return null;
  }
  return [for (final s in strokes) fromFrame(s, frame)];
}

/// Os traços da nota à mão [layer] na miniatura: a caixa de [thumbNoteBoxWidth] × a altura das linhas dela, na
/// escala que cabe em [thumbNoteInkHeight].
List<InkStroke>? handNoteInThumb(InkLayer layer) {
  if (layer.strokesB64.isEmpty) return null;
  final lines = layer.spaceLines ?? 1;
  final h = noteBoxHeight(lines);
  final scale = thumbNoteInkHeight / h;
  final box = ui.Rect.fromLTWH(0, 0, thumbNoteBoxWidth, h);
  final List<InkStroke> strokes;
  try {
    strokes = decodeStrokesB64(layer.strokesB64, Bnk1Unit.box);
  } on Object {
    return null;
  }
  return [
    for (final s in strokes)
      () {
        final p = fromNote(s, box);
        return p.copyWith(
          points: [
            for (final q in p.points)
              InkPoint(q.x * scale, q.y * scale, q.pressure, q.tMs),
          ],
        );
      }(),
  ];
}

/// A chave de uma miniatura: a camada, a versão, a moldura (o `k` e o em do desenho; a nota à mão, zeros) e a escala
/// do aparelho — não o lugar na tela (rolar não redesenha).
typedef _ThumbKey = (String layer, String version, int k, int em, double dpr);

/// Uma miniatura pronta: a imagem e onde ela fica, a partir da origem da moldura.
typedef _Thumb = ({ui.Image image, ui.Rect bounds, double dpr});

/// O cache das miniaturas em imagem (R10): os traços decodificados e a imagem de cada um, por camada e versão.
final class InkThumbnailCache {
  InkThumbnailCache({this.capacity = 64});

  final int capacity;
  final LinkedHashMap<_ThumbKey, _Thumb?> _images = LinkedHashMap();

  /// Quantas miniaturas o cache guarda agora.
  int get length => _images.length;

  /// Quantas vezes uma miniatura foi decodificada e desenhada (teste).
  int renders = 0;

  /// O desenho [layer] sobre os pedaços [pieces] do trecho (nas coordenadas da citação), em [at] do [canvas].
  void paintDrawing(
    ui.Canvas canvas,
    ui.Offset at,
    InkLayer layer,
    List<InkPiece> pieces, {
    required double dpr,
  }) {
    final anchor = inkAnchorOf(layer.anchor);
    if (anchor == null || layer.strokesB64.isEmpty) return;
    final frame = placedFrame(pieces, anchor.w);
    if (frame == null) return;
    final key = (
      layer.id,
      layer.meta.version.toString(),
      (frame.k * 100000).round(),
      (frame.em * 100).round(),
      dpr,
    );
    final t = _thumb(key, dpr, () {
      final strokes = _decode(layer, Bnk1Unit.em);
      return [
        for (final s in strokes)
          fromFrame(s, (x: 0, baseline: 0, em: frame.em, k: frame.k)),
      ];
    });
    if (t != null) _draw(canvas, at + ui.Offset(frame.x, frame.baseline), t);
  }

  /// A nota à mão [layer] na miniatura, com o canto da tinta em [at] do [canvas].
  void paintHandNote(
    ui.Canvas canvas,
    ui.Offset at,
    InkLayer layer, {
    required double dpr,
  }) {
    if (layer.strokesB64.isEmpty) return;
    final key = (layer.id, layer.meta.version.toString(), 0, 0, dpr);
    final t = _thumb(key, dpr, () => handNoteInThumb(layer) ?? const []);
    if (t != null) _draw(canvas, at, t);
  }

  List<InkStroke> _decode(InkLayer layer, Bnk1Unit unit) {
    try {
      return decodeStrokesB64(layer.strokesB64, unit);
    } on Object {
      return const [];
    }
  }

  /// A miniatura de [key]; a 1ª vez, os traços de [strokes] desenhados numa imagem (`null` = sem tinta).
  _Thumb? _thumb(
    _ThumbKey key,
    double dpr,
    List<InkStroke> Function() strokes,
  ) {
    if (_images.containsKey(key)) {
      final hit = _images.remove(key);
      _images[key] = hit;
      return hit;
    }
    renders++;
    final s = strokes();
    final bounds = inkBounds(s);
    _Thumb? t;
    if (!bounds.isEmpty) {
      final recorder = ui.PictureRecorder();
      final c = ui.Canvas(recorder)
        ..scale(dpr)
        ..translate(-bounds.left, -bounds.top);
      paintInk(c, s);
      final picture = recorder.endRecording();
      t = (
        image: picture.toImageSync(
          (bounds.width * dpr).ceil(),
          (bounds.height * dpr).ceil(),
        ),
        bounds: bounds,
        dpr: dpr,
      );
      picture.dispose();
    }
    while (_images.length >= capacity) {
      final oldest = _images.keys.first;
      _images.remove(oldest)?.image.dispose();
    }
    _images[key] = t;
    return t;
  }

  void _draw(ui.Canvas canvas, ui.Offset at, _Thumb t) {
    final i = t.image;
    canvas.drawImageRect(
      i,
      ui.Rect.fromLTWH(0, 0, i.width.toDouble(), i.height.toDouble()),
      ui.Rect.fromLTWH(
        at.dx + t.bounds.left,
        at.dy + t.bounds.top,
        i.width / t.dpr,
        i.height / t.dpr,
      ),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
  }

  void clear() {
    for (final t in _images.values) {
      t?.image.dispose();
    }
    _images.clear();
  }
}

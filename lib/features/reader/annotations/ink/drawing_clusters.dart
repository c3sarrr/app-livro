// G16.2 — um desenho = traços que se tocam (D-162). A caixa de um traço são os pontos crescidos em meia espessura
// (D-159); a de um desenho, a união das caixas dos traços. O traço novo entra no desenho da sessão cuja caixa,
// crescida em meia altura de linha, ele toca; tocando dois, entra no mais recente e os dois NÃO se fundem; não
// tocando nenhum, começa um desenho novo. Dart puro.
import 'dart:math' as math;

import 'ink_geometry.dart';
import 'ink_stroke.dart';
import 'ink_units.dart';

/// A caixa do traço [s]: os pontos crescidos em meia espessura.
InkRect strokeBox(InkStroke s) {
  if (s.points.isEmpty) {
    throw ArgumentError.value(s, 's', 'traço sem pontos');
  }
  var left = double.infinity;
  var top = double.infinity;
  var right = double.negativeInfinity;
  var bottom = double.negativeInfinity;
  for (final p in s.points) {
    left = math.min(left, p.x);
    top = math.min(top, p.y);
    right = math.max(right, p.x);
    bottom = math.max(bottom, p.y);
  }
  final r = dpOfCentiMm(s.widthCentiMm) / 2;
  return InkRect(left - r, top - r, right + r, bottom + r);
}

/// A caixa do desenho de traços [strokes] (pelo menos um).
InkRect drawingBox(List<InkStroke> strokes) =>
    strokes.map(strokeBox).reduce((a, b) => a.union(b));

/// O desenho ([order]) em que entra o traço de caixa [box]: o mais recente entre os que ele toca, com as caixas deles
/// crescidas em meia [lineHeight]; `null` = um desenho novo.
int? touchedDrawing(
  InkRect box,
  List<({int order, InkRect box})> drawings, {
  required double lineHeight,
}) {
  int? best;
  for (final d in drawings) {
    if (!d.box.inflate(lineHeight / 2).overlaps(box)) continue;
    if (best == null || d.order > best) best = d.order;
  }
  return best;
}

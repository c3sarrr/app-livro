// G18 — a tinta da nota à mão (R6; Anexo 03 §9.5): guardada na unidade da caixa do espaço — x = fração da largura
// da caixa (0–1), y = linhas da nota (42 px) a partir do topo dela —, o BNK1 `box` (1/10000). A caixa cresce e
// encolhe pela alça sem mexer na tinta (o y não depende da altura) e acompanha a largura do texto.
import 'dart:math' as math;
import 'dart:ui';

import '../ink/ink_stroke.dart';
import '../ink/ink_units.dart';
import 'space_metrics.dart';

/// O traço [s] da página (px) na unidade da nota da caixa [box].
InkStroke toNote(InkStroke s, Rect box) => s.copyWith(
  points: [
    for (final p in s.points)
      InkPoint(
        (p.x - box.left) / box.width,
        (p.y - box.top) / noteLinePx,
        p.pressure,
        p.tMs,
      ),
  ],
);

/// O traço [s] (unidade da nota) de volta à página, na caixa [box].
InkStroke fromNote(InkStroke s, Rect box) => s.copyWith(
  points: [
    for (final p in s.points)
      InkPoint(
        box.left + p.x * box.width,
        box.top + p.y * noteLinePx,
        p.pressure,
        p.tMs,
      ),
  ],
);

/// Onde a tinta [strokes] (unidade da nota) acaba embaixo: px a partir do topo da caixa, com a metade da largura.
double inkBottomPx(List<InkStroke> strokes) {
  var bottom = 0.0;
  for (final s in strokes) {
    final half = dpOfCentiMm(s.widthCentiMm) / 2;
    for (final p in s.points) {
      bottom = math.max(bottom, p.y * noteLinePx + half);
    }
  }
  return bottom;
}

/// D-186: as linhas da menor caixa que contém a tinta [strokes].
int minLinesFor(List<InkStroke> strokes) => linesForInk(inkBottomPx(strokes));

/// R6: o traço é da nota quando começa dentro da caixa [box].
bool startsInside(InkStroke s, Rect box) =>
    s.points.isNotEmpty &&
    box.contains(Offset(s.points.first.x, s.points.first.y));

// G18 — a tinta da nota à mão (R6; Anexo 03 §9.5): guardada na unidade da caixa do espaço — x = fração da largura
// da caixa (0–1), y = linhas da nota (42 px) a partir do topo dela —, o BNK1 `box` (1/10000). A caixa cresce e
// encolhe pela alça sem mexer na tinta (o y não depende da altura) e acompanha a largura do texto. O traço que sai da
// caixa é recortado na borda (`clipToFrame`): o que não aparece não fica guardado.
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

/// R6: o traço [s] (px da página) recortado na caixa [frame] da nota: os pedaços de dentro, cada um com o ponto onde
/// ele cruza a borda (a pressão e o tempo no meio do caminho). A tinta inteira fica por dentro: a borda menos a
/// metade da largura do traço. Tudo dentro: o próprio traço; nada dentro: nenhum.
List<InkStroke> clipToFrame(InkStroke s, Rect frame) {
  final pts = s.points;
  if (pts.isEmpty) return const [];
  final half = dpOfCentiMm(s.widthCentiMm) / 2;
  final r = frame.width > 2 * half && frame.height > 2 * half
      ? frame.deflate(half)
      : frame;
  bool inside(InkPoint p) =>
      p.x >= r.left && p.x <= r.right && p.y >= r.top && p.y <= r.bottom;
  if (pts.every(inside)) return [s];
  final runs = <List<InkPoint>>[];
  List<InkPoint>? run = inside(pts.first) ? [pts.first] : null;
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1];
    final b = pts[i];
    final cut = _segmentIn(a, b, r);
    if (cut == null) {
      if (run != null) runs.add(run);
      run = null;
      continue;
    }
    final (t0, t1) = cut;
    if (run != null && t0 > 0) {
      runs.add(run);
      run = null;
    }
    run ??= [if (t0 > 0) _lerp(a, b, t0) else a];
    if (t1 < 1) {
      run.add(_lerp(a, b, t1));
      runs.add(run);
      run = null;
    } else {
      run.add(b);
    }
  }
  if (run != null) runs.add(run);
  return [for (final p in runs) s.copyWith(points: List.unmodifiable(p))];
}

/// O trecho do segmento [a]→[b] dentro de [r] (Liang–Barsky): os parâmetros de entrada e saída, ou `null`.
(double, double)? _segmentIn(InkPoint a, InkPoint b, Rect r) {
  var t0 = 0.0;
  var t1 = 1.0;
  bool edge(double p, double q) {
    if (p == 0) return q >= 0;
    final t = q / p;
    if (p < 0) {
      if (t > t1) return false;
      if (t > t0) t0 = t;
    } else {
      if (t < t0) return false;
      if (t < t1) t1 = t;
    }
    return true;
  }

  final dx = b.x - a.x;
  final dy = b.y - a.y;
  final ok =
      edge(-dx, a.x - r.left) &&
      edge(dx, r.right - a.x) &&
      edge(-dy, a.y - r.top) &&
      edge(dy, r.bottom - a.y);
  return ok ? (t0, t1) : null;
}

InkPoint _lerp(InkPoint a, InkPoint b, double t) => InkPoint(
  a.x + (b.x - a.x) * t,
  a.y + (b.y - a.y) * t,
  a.pressure + (b.pressure - a.pressure) * t,
  (a.tMs + (b.tMs - a.tMs) * t).round(),
);

/// R6: o traço é da nota quando começa dentro da caixa [box].
bool startsInside(InkStroke s, Rect box) =>
    s.points.isNotEmpty &&
    box.contains(Offset(s.points.first.x, s.points.first.y));

// G17.4 — o Marca-texto "gruda nas palavras" (Anexo 03 §9.4, R21): a linha central do traço é recortada na faixa de
// cada linha da página (o topo e a base da linha inteira, sem buraco entre elas); uma palavra com letra ou número é
// coberta quando ≥ 50 % da largura dela fica sob os pedaços do traço nessa faixa (a pontuação não conta nem quebra);
// cobertas seguidas no texto formam um trecho, do começo da 1ª ao fim da última. Sem palavra coberta, nenhum trecho:
// o traço vira tinta translúcida (R22). Dart puro.
import 'dart:math' as math;

import 'ink_geometry.dart';

/// Um trecho grifado pelo marca-texto: [from]…[to) do item [unit].
typedef MarkedRun = ({int unit, int from, int to});

/// Quanto da largura de uma palavra o traço precisa cobrir (Anexo 03 §9.4).
const double markerCover = 0.5;

final RegExp _letter = RegExp(r'[\p{L}\p{N}]', unicode: true);

/// Os trechos que o traço [points] (a linha central, nas coordenadas do leitor limpo) grifa em [page]. [textOf] dá o
/// texto do item (para saber o que é palavra); sem texto, nada.
List<MarkedRun> markedRuns(
  List<InkOffset> points,
  InkPageGeometry page, {
  required String? Function(int unit) textOf,
  double cover = markerCover,
}) {
  final runs = <MarkedRun>[];
  int? unit;
  var from = 0;
  var to = 0;
  void close() {
    final u = unit;
    if (u != null) runs.add((unit: u, from: from, to: to));
    unit = null;
  }

  for (final line in page.lines) {
    final text = textOf(line.unit);
    if (text == null) continue;
    final spans = _spansIn(points, line.top, line.bottom);
    for (final w in line.words) {
      if (w.to > text.length ||
          !_letter.hasMatch(text.substring(w.from, w.to))) {
        continue;
      }
      final width = w.right - w.left;
      final covered =
          spans.isNotEmpty &&
          width > 0 &&
          _overlap(spans, w.left, w.right) >= cover * width;
      if (!covered) {
        close();
      } else if (unit == line.unit) {
        to = w.to;
      } else {
        close();
        unit = line.unit;
        from = w.from;
        to = w.to;
      }
    }
  }
  close();
  return runs;
}

/// Os intervalos em x que a polilinha [points] percorre dentro da faixa [top]…[bottom], unidos.
List<(double, double)> _spansIn(
  List<InkOffset> points,
  double top,
  double bottom,
) {
  final raw = <(double, double)>[];
  if (points.length == 1) {
    final p = points.single;
    if (p.y >= top && p.y <= bottom) raw.add((p.x, p.x));
  }
  for (var k = 0; k + 1 < points.length; k++) {
    final a = points[k];
    final b = points[k + 1];
    final lo = math.min(a.y, b.y);
    final hi = math.max(a.y, b.y);
    if (hi < top || lo > bottom) continue;
    if (a.y == b.y) {
      raw.add((math.min(a.x, b.x), math.max(a.x, b.x)));
      continue;
    }
    // o pedaço do segmento entre as duas bordas da faixa
    double xAt(double y) => a.x + (b.x - a.x) * (y - a.y) / (b.y - a.y);
    final y0 = math.max(lo, top);
    final y1 = math.min(hi, bottom);
    final x0 = xAt(y0);
    final x1 = xAt(y1);
    raw.add((math.min(x0, x1), math.max(x0, x1)));
  }
  raw.sort((p, q) => p.$1.compareTo(q.$1));
  final merged = <(double, double)>[];
  for (final r in raw) {
    if (merged.isNotEmpty && r.$1 <= merged.last.$2) {
      merged[merged.length - 1] = (
        merged.last.$1,
        math.max(merged.last.$2, r.$2),
      );
    } else {
      merged.add(r);
    }
  }
  return merged;
}

/// Quanto de [left]…[right] fica sob os intervalos [spans].
double _overlap(List<(double, double)> spans, double left, double right) {
  var sum = 0.0;
  for (final (a, b) in spans) {
    final l = math.max(a, left);
    final r = math.min(b, right);
    if (r > l) sum += r - l;
  }
  return sum;
}

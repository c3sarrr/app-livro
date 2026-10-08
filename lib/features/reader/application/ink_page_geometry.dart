// G16.2 — a geometria da tinta tirada da página mostrada: as caixas do trecho mostrado agrupadas pela linha de base
// dão as linhas; as palavras saem do `wordAround` andando pelo texto (espaço = `null`, vai para o próximo), cada uma
// com as caixas dela na linha dela, cortada ao que está nesta página. A palavra quebrada entre linhas (o hífen
// discreto) entra em cada linha só com o pedaço dela. Sem trecho mostrado (o PDF — D-134), sem linhas.
import 'dart:math' as math;

import '../annotations/ink/ink_geometry.dart';
import '../layout/display_page.dart';

/// As linhas e as palavras de [page], nas coordenadas da tela.
InkPageGeometry inkGeometryOf(DisplayPage page) {
  final shown = page.shown;
  if (shown == null) return InkPageGeometry.empty;
  final lines = <_Line>[];
  _Line? lineAt(double baseline) {
    for (final l in lines) {
      if ((l.baseline - baseline).abs() < 0.5) return l;
    }
    return null;
  }

  for (final b in page.boxesOf(shown.unit, shown.from, shown.to)) {
    final l = lineAt(b.baseline);
    if (l == null) {
      lines.add(_Line(b));
    } else {
      l.add(b);
    }
  }
  var o = shown.from;
  while (o < shown.to) {
    final w = page.wordAround((unit: shown.unit, offset: o));
    if (w == null || w.to <= o) {
      o++;
      continue;
    }
    final from = math.max(w.from, shown.from);
    final to = math.min(w.to, shown.to);
    final boxes = page.boxesOf(shown.unit, from, to);
    if (boxes.every((b) => (b.baseline - boxes.first.baseline).abs() < 0.5)) {
      for (final b in boxes) {
        lineAt(b.baseline)?.addWord(from, to, b.rect.left, b.rect.right);
      }
    } else {
      _splitAcrossLines(page, shown.unit, from, to, lineAt);
    }
    o = w.to;
  }
  lines.sort((a, b) => a.baseline.compareTo(b.baseline));
  return InkPageGeometry([
    for (final l in lines)
      if (l.words.isNotEmpty) l.build(shown.unit),
  ]);
}

/// A palavra [from]…[to) que a quebra de linha partiu: letra a letra, cada pedaço contínuo vai à linha dele.
void _splitAcrossLines(
  DisplayPage page,
  int unit,
  int from,
  int to,
  _Line? Function(double baseline) lineAt,
) {
  _Line? line;
  var start = from;
  var left = 0.0;
  var right = 0.0;
  void flush(int end) {
    if (line != null && end > start) line.addWord(start, end, left, right);
  }

  for (var k = from; k < to; k++) {
    final bs = page.boxesOf(unit, k, k + 1);
    if (bs.isEmpty) continue;
    final b = bs.first;
    final l = lineAt(b.baseline);
    if (!identical(l, line)) {
      flush(k);
      line = l;
      start = k;
      left = b.rect.left;
      right = b.rect.right;
      continue;
    }
    left = math.min(left, b.rect.left);
    right = math.max(right, b.rect.right);
  }
  flush(to);
}

/// Uma linha em montagem.
final class _Line {
  _Line(TextLineBox b)
    : baseline = b.baseline,
      em = b.em,
      top = b.rect.top,
      bottom = b.rect.bottom,
      textTop = b.textTop,
      textBottom = b.textBottom,
      left = b.rect.left,
      right = b.rect.right;

  final double baseline;
  final double em;
  double top;
  double bottom;
  double textTop;
  double textBottom;
  double left;
  double right;
  final List<InkWord> words = [];

  void add(TextLineBox b) {
    top = math.min(top, b.rect.top);
    bottom = math.max(bottom, b.rect.bottom);
    textTop = math.min(textTop, b.textTop);
    textBottom = math.max(textBottom, b.textBottom);
    left = math.min(left, b.rect.left);
    right = math.max(right, b.rect.right);
  }

  /// A palavra [from]…[to) com as bordas [l]…[r]; a mesma palavra em mais de uma caixa (estilos diferentes) junta.
  void addWord(int from, int to, double l, double r) {
    if (words.isNotEmpty && words.last.from == from && words.last.to == to) {
      final last = words.removeLast();
      words.add((
        from: from,
        to: to,
        left: math.min(last.left, l),
        right: math.max(last.right, r),
      ));
      return;
    }
    words.add((from: from, to: to, left: l, right: r));
  }

  InkLine build(int unit) => InkLine(
    unit: unit,
    from: words.first.from,
    to: words.last.to,
    top: top,
    bottom: bottom,
    baseline: baseline,
    em: em,
    left: left,
    right: right,
    words: List.unmodifiable(words),
    textTop: textTop,
    textBottom: textBottom,
  );
}

// G16.2 — a geometria da tinta tirada da página mostrada: as caixas do trecho mostrado agrupadas pela linha de base
// dão as linhas; as palavras saem do `wordAround` andando pelo texto (espaço = `null`, vai para o próximo), cada uma
// com as caixas dela na linha dela. Sem trecho mostrado (o PDF — D-134), sem linhas.
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
    for (final b in page.boxesOf(shown.unit, w.from, w.to)) {
      lineAt(b.baseline)?.addWord(w.from, w.to, b.rect.left, b.rect.right);
    }
    o = w.to;
  }
  lines.sort((a, b) => a.baseline.compareTo(b.baseline));
  return InkPageGeometry([
    for (final l in lines)
      if (l.words.isNotEmpty) l.build(shown.unit),
  ]);
}

/// Uma linha em montagem.
final class _Line {
  _Line(TextLineBox b)
    : baseline = b.baseline,
      em = b.em,
      top = b.rect.top,
      bottom = b.rect.bottom,
      left = b.rect.left,
      right = b.rect.right;

  final double baseline;
  final double em;
  double top;
  double bottom;
  double left;
  double right;
  final List<InkWord> words = [];

  void add(TextLineBox b) {
    top = math.min(top, b.rect.top);
    bottom = math.max(bottom, b.rect.bottom);
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
  );
}

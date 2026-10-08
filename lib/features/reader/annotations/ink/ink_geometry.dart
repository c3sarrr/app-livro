// G16.2 — as linhas e as palavras da página, para a âncora da tinta (D-162). Dart puro, sem widget: o adaptador
// `inkGeometryOf` (application/ink_page_geometry.dart) tira tudo da `DisplayPage`. Coordenadas da tela do leitor
// limpo (o modo anotação desloca a página; a sessão tira o deslocamento antes de chegar aqui).
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable, listEquals;

/// Um ponto da tela.
typedef InkOffset = ({double x, double y});

/// Uma palavra da linha (o `getWordBoundary`: a pontuação e a imagem também são "palavras"): o trecho [from]…[to)
/// do texto e as bordas das letras.
typedef InkWord = ({int from, int to, double left, double right});

/// Um retângulo da tela. Tocar a borda conta como tocar ([overlaps]).
@immutable
final class InkRect {
  const InkRect(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;
  InkOffset get center => (x: (left + right) / 2, y: (top + bottom) / 2);

  InkRect inflate(double d) =>
      InkRect(left - d, top - d, right + d, bottom + d);

  InkRect union(InkRect o) => InkRect(
    math.min(left, o.left),
    math.min(top, o.top),
    math.max(right, o.right),
    math.max(bottom, o.bottom),
  );

  /// Os dois se tocam (a borda conta).
  bool overlaps(InkRect o) =>
      left <= o.right && o.left <= right && top <= o.bottom && o.top <= bottom;

  @override
  bool operator ==(Object other) =>
      other is InkRect &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() => 'InkRect($left, $top, $right, $bottom)';
}

/// Uma linha de texto da página: o trecho [from]…[to) de [unit] (da 1ª à última palavra), a altura da linha
/// inteira ([top]…[bottom]), a linha de base, o tamanho da letra, as bordas das letras e as palavras.
@immutable
final class InkLine {
  const InkLine({
    required this.unit,
    required this.from,
    required this.to,
    required this.top,
    required this.bottom,
    required this.baseline,
    required this.em,
    required this.left,
    required this.right,
    required this.words,
  });

  final int unit;
  final int from;
  final int to;
  final double top;
  final double bottom;
  final double baseline;
  final double em;
  final double left;
  final double right;
  final List<InkWord> words;

  /// O ponto de referência da linha (§2): 0,25 em acima da linha de base, o meio da letra pequena.
  double get refY => baseline - 0.25 * em;

  @override
  bool operator ==(Object other) =>
      other is InkLine &&
      other.unit == unit &&
      other.from == from &&
      other.to == to &&
      other.top == top &&
      other.bottom == bottom &&
      other.baseline == baseline &&
      other.em == em &&
      other.left == left &&
      other.right == right &&
      listEquals(other.words, words);

  @override
  int get hashCode => Object.hash(
    unit,
    from,
    to,
    top,
    bottom,
    baseline,
    em,
    left,
    right,
    Object.hashAll(words),
  );
}

/// As linhas da página, de cima para baixo.
@immutable
final class InkPageGeometry {
  const InkPageGeometry(this.lines);

  static const InkPageGeometry empty = InkPageGeometry([]);

  final List<InkLine> lines;

  /// A altura de uma linha (a da 1ª): a folga do agrupamento (D-162) é a metade dela. Sem linhas, 0.
  double get lineHeight =>
      lines.isEmpty ? 0 : lines.first.bottom - lines.first.top;
}

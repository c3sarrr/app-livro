// G16.2 — a âncora do desenho (D-162, refina a D-29). Dart puro.
//
// - Linha: a que tem o ponto de referência (0,25 em acima da base, o meio da letra pequena) mais perto do centro do
//   desenho inteiro.
// - Trecho: as palavras dessa linha com ≥ 50 % da largura dentro da extensão horizontal do desenho; sem nenhuma (um
//   traço na margem, depois do fim da linha), a palavra mais perto.
// - Moldura: a origem no começo do trecho, na linha de base; a unidade é o em; `w` = a largura do trecho em em, na
//   criação. Os pontos vão em em a partir da origem.
// - Volta à página (outra fonte, tamanho, entrelinha ou margem): trecho numa linha só → `k = (largura ÷ em) ÷ w` e
//   `X = início + ex·em·k`, `Y = base + ey·em`; trecho que passou a quebrar → `k = 1` no começo do 1º pedaço (o limite
//   do Anexo 03 §9.5); âncora que não volta → `null`: o desenho não aparece e não é apagado (D-44). A espessura não
//   escala (o `non-scaling-stroke` do arquivo).
// - A camada `over_text` grava a âncora de intervalo de 7 chaves mais `"ink": {"w": …}` (8 chaves); a anotação
//   `drawing` grava a de 7. O `EpubAnchor` continua aceitando só as 7.
import 'dart:math' as math;

import '../../domain/locator.dart';
import 'ink_geometry.dart';
import 'ink_stroke.dart';

/// A moldura do desenho, na criação: [x] e [baseline] = a origem (o começo do trecho, na linha de base); [em] = a
/// unidade; [w] = a largura do trecho em em.
typedef InkFrame = ({double x, double baseline, double em, double w});

/// Onde o desenho se prende: a linha (índice na página), o trecho [from]…[to) do texto e a moldura.
typedef DrawingPlace = ({int line, int from, int to, InkFrame frame});

/// A moldura de volta à página: a origem, o em e o quanto o trecho esticou na horizontal ([k]).
typedef PlacedFrame = ({double x, double baseline, double em, double k});

/// Um pedaço do trecho numa linha da página (as caixas do `boxesOf`).
typedef InkPiece = ({double left, double right, double baseline, double em});

/// Onde o desenho de caixa [bounds] se prende na página [g]; `null` sem linhas.
DrawingPlace? placeDrawing(InkRect bounds, InkPageGeometry g) {
  final cy = bounds.center.y;
  int? best;
  for (var i = 0; i < g.lines.length; i++) {
    if (g.lines[i].words.isEmpty) continue;
    if (best == null ||
        (g.lines[i].refY - cy).abs() < (g.lines[best].refY - cy).abs()) {
      best = i;
    }
  }
  if (best == null) return null;
  final line = g.lines[best];
  final inside = [
    for (final w in line.words)
      if (_mostlyInside(w, bounds)) w,
  ];
  final first = inside.isNotEmpty ? inside.first : _nearest(line.words, bounds);
  final last = inside.isNotEmpty ? inside.last : first;
  return (
    line: best,
    from: first.from,
    to: last.to,
    frame: (
      x: first.left,
      baseline: line.baseline,
      em: line.em,
      w: (last.right - first.left) / line.em,
    ),
  );
}

/// ≥ 50 % da largura da palavra [w] dentro da extensão horizontal de [b].
bool _mostlyInside(InkWord w, InkRect b) {
  final width = w.right - w.left;
  if (width <= 0) return w.left >= b.left && w.left <= b.right;
  final inside = math.min(w.right, b.right) - math.max(w.left, b.left);
  return inside >= width / 2;
}

/// A palavra mais perto de [b] na horizontal (a primeira, no empate).
InkWord _nearest(List<InkWord> words, InkRect b) {
  double distance(InkWord w) =>
      math.max(0, math.max(w.left - b.right, b.left - w.right));
  var best = words.first;
  for (final w in words.skip(1)) {
    if (distance(w) < distance(best)) best = w;
  }
  return best;
}

/// O traço [s] (coordenadas da página) em em, na moldura [f].
InkStroke toFrame(InkStroke s, InkFrame f) => s.copyWith(
  points: [
    for (final p in s.points)
      InkPoint(
        (p.x - f.x) / f.em,
        (p.y - f.baseline) / f.em,
        p.pressure,
        p.tMs,
      ),
  ],
);

/// O traço [s] (em em) de volta à página, pela moldura [p].
InkStroke fromFrame(InkStroke s, PlacedFrame p) => s.copyWith(
  points: [
    for (final q in s.points)
      InkPoint(
        p.x + q.x * p.em * p.k,
        p.baseline + q.y * p.em,
        q.pressure,
        q.tMs,
      ),
  ],
);

/// A moldura do trecho de pedaços [pieces] (as caixas dele na página), para a largura [w] da criação (`null` = a
/// camada sem a chave `ink`: não estica). Sem pedaços (a âncora não volta), `null`.
PlacedFrame? placedFrame(List<InkPiece> pieces, double? w) {
  final lines = <InkPiece>[];
  for (final p in pieces) {
    final i = lines.indexWhere((l) => (l.baseline - p.baseline).abs() < 0.5);
    if (i < 0) {
      lines.add(p);
      continue;
    }
    final l = lines[i];
    lines[i] = (
      left: math.min(l.left, p.left),
      right: math.max(l.right, p.right),
      baseline: l.baseline,
      em: l.em,
    );
  }
  if (lines.isEmpty) return null;
  final first = lines.first;
  final k = lines.length == 1 && w != null && w > 0 && first.em > 0
      ? (first.right - first.left) / first.em / w
      : 1.0;
  return (x: first.left, baseline: first.baseline, em: first.em, k: k);
}

/// A âncora da camada `over_text` (8 chaves): a de intervalo [range] e a largura do trecho em em, com 4 casas.
TextAnchor inkLayerAnchor(EpubAnchor range, double w) => RawAnchor({
  ...range.toJson(),
  'ink': {'w': (w * 10000).round() / 10000},
});

/// O intervalo e a largura (em em) da âncora de uma camada; a de 7 chaves dá `w` nulo; outro formato, `null`.
({EpubAnchor range, double? w})? inkAnchorOf(TextAnchor a) {
  switch (a) {
    case EpubAnchor():
      return (range: a, w: null);
    case RawAnchor(:final json):
      final ink = json['ink'];
      if (ink is! Map || ink['w'] is! num) return null;
      final range = TextAnchor.fromJson({
        for (final e in json.entries)
          if (e.key != 'ink') e.key: e.value,
      });
      if (range is! EpubAnchor) return null;
      return (range: range, w: (ink['w'] as num).toDouble());
  }
}

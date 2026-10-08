// G16.2 — a âncora do desenho (D-162, refina a D-29): a linha cujo ponto de referência (0,25 em acima da base) fica
// mais perto do centro, o trecho com as palavras ≥ 50 % dentro, a moldura em em e a volta à página (mesma página,
// outra fonte, trecho que quebrou, âncora que não volta), e a âncora de 8 chaves da camada.
import 'dart:math' as math;

import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Uma página sintética de 3 linhas (bases 100; 135,25; 170,5 — em 20,5), com as caixas das palavras.
const _lines = [
  [
    ('Olhos', 28.0, 83.0),
    ('de', 89.0, 109.0),
    ('ressaca', 115.0, 190.0),
    ('fim', 196.0, 225.0),
  ],
  [
    ('a', 28.0, 39.0),
    ('vaga', 45.0, 92.0),
    ('que', 98.0, 133.0),
    ('se', 139.0, 158.0),
  ],
  [('da', 28.0, 50.0), ('praia', 56.0, 105.0)],
];
const _baselines = [100.0, 135.25, 170.5];
const _em = 20.5;

late String _text;

InkPageGeometry _geometry() {
  final text = StringBuffer();
  final lines = <InkLine>[];
  for (var i = 0; i < _lines.length; i++) {
    final words = <InkWord>[];
    for (final (word, left, right) in _lines[i]) {
      if (text.isNotEmpty) text.write(' ');
      words.add((
        from: text.length,
        to: text.length + word.length,
        left: left,
        right: right,
      ));
      text.write(word);
    }
    final top = _baselines[i] - 26;
    lines.add(
      InkLine(
        unit: 4,
        from: words.first.from,
        to: words.last.to,
        top: top,
        bottom: top + 35.26,
        baseline: _baselines[i],
        em: _em,
        left: words.first.left,
        right: words.last.right,
        words: words,
      ),
    );
  }
  _text = text.toString();
  return InkPageGeometry(lines);
}

InkRect _box({
  double left = 30,
  double right = 80,
  double top = 90,
  double bottom = 100,
}) => InkRect(left, top, right, bottom);

String _textOf(DrawingPlace p) => _text.substring(p.from, p.to);

InkStroke _stroke(List<(double, double)> points) => InkStroke(
  tool: InkTool.pen.code,
  tip: 0,
  argb: 0xFFFF552E,
  widthCentiMm: 120,
  points: [
    for (var i = 0; i < points.length; i++)
      InkPoint(points[i].$1, points[i].$2, 0.5, i * 8),
  ],
);

double _maxDistance(InkStroke a, InkStroke b) {
  var d = 0.0;
  for (var i = 0; i < a.points.length; i++) {
    d = math.max(d, (a.points[i].x - b.points[i].x).abs());
    d = math.max(d, (a.points[i].y - b.points[i].y).abs());
  }
  return d;
}

final _range = EpubAnchor(
  sha: 'a' * 64,
  spine: 4,
  start: 0,
  end: 8,
  quote: const TextQuote(exact: 'Olhos de'),
  refPage: 159,
);

void main() {
  late InkPageGeometry g;
  setUp(() => g = _geometry());

  test('a linha da âncora: o ponto 0,25 em acima da base mais perto do centro', () {
    // centro 3 px abaixo da linha 1: fica na 1 (como o sublinhado duplo na 13)
    expect(placeDrawing(_box(top: 98, bottom: 108), g)!.line, 0);
    // centro logo acima da linha de base da 2: fica na 2
    expect(placeDrawing(_box(top: 126, bottom: 134), g)!.line, 1);
    // longe de tudo, embaixo: a última
    expect(placeDrawing(_box(top: 400, bottom: 420), g)!.line, 2);
    expect(placeDrawing(_box(), InkPageGeometry.empty), isNull);
  });

  test('o trecho: palavras com ≥ 50 % da largura dentro da extensão do desenho', () {
    // "Olhos" inteira e "de" (89–109) com 60 %
    expect(_textOf(placeDrawing(_box(left: 0, right: 101), g)!), 'Olhos de');
    // "de" com 50 % exatos entra; com 49 %, não
    expect(_textOf(placeDrawing(_box(left: 0, right: 99), g)!), 'Olhos de');
    expect(_textOf(placeDrawing(_box(left: 0, right: 98.8), g)!), 'Olhos');
    // o meio da linha: só as palavras de dentro ("de" com 70 %, "fim" com 14 %)
    expect(_textOf(placeDrawing(_box(left: 95, right: 200), g)!), 'de ressaca');
    // depois do fim da linha: a palavra mais perto
    expect(_textOf(placeDrawing(_box(left: 300, right: 330), g)!), 'fim');
    // um risco curto no meio de uma palavra comprida: a palavra
    expect(_textOf(placeDrawing(_box(left: 140, right: 150), g)!), 'ressaca');
    // no vão entre duas palavras: a mais perto (1,5 px de "de", 2,5 de "Olhos")
    expect(_textOf(placeDrawing(_box(left: 85.5, right: 87.5), g)!), 'de');
    expect(_textOf(placeDrawing(_box(left: 84, right: 86), g)!), 'Olhos');
  });

  test('a moldura: origem no começo do trecho, na linha de base; w em em', () {
    final p = placeDrawing(_box(left: 0, right: 101), g)!;
    expect(p.frame.x, 28);
    expect(p.frame.baseline, 100);
    expect(p.frame.em, _em);
    expect(p.frame.w, closeTo((109 - 28) / _em, 1e-12));
    final s = toFrame(_stroke([(28, 100), (48.5, 79.5)]), p.frame);
    expect([for (final q in s.points) (q.x, q.y)], [(0.0, 0.0), (1.0, -1.0)]);
    // a pressão, o tempo e o resto do traço ficam
    expect(s.points.last.pressure, 0.5);
    expect(s.points.last.tMs, 8);
    expect(s.argb, 0xFFFF552E);
  });

  test('a moldura e a volta: mesma página dá os mesmos pontos', () {
    final stroke = _stroke([(20, 92), (60, 88.3), (110.7, 104.2)]);
    final p = placeDrawing(
      _box(left: 20, right: 110.7, top: 88.3, bottom: 104.2),
      g,
    )!;
    final em = toFrame(stroke, p.frame);
    final back = fromFrame(em, (
      x: p.frame.x,
      baseline: p.frame.baseline,
      em: p.frame.em,
      k: 1,
    ));
    expect(_maxDistance(back, stroke), lessThan(1e-9));
    // e o mesmo pela moldura da página de novo (um pedaço só, a mesma largura)
    final again = placedFrame([
      (left: 28, right: 109, baseline: 100, em: _em),
    ], p.frame.w)!;
    expect(again.k, closeTo(1, 1e-12));
    expect(_maxDistance(fromFrame(em, again), stroke), lessThan(1e-9));
  });

  test('outra fonte: estica na horizontal; na vertical fica em em a partir da base', () {
    final p = placeDrawing(_box(left: 0, right: 101), g)!;
    final em = toFrame(_stroke([(28, 100), (109, 100), (60, 90)]), p.frame);
    // "Olhos de" agora vai de 30 a 120, na base 200, com a letra de 22
    final placed = placedFrame([
      (left: 30, right: 120, baseline: 200, em: 22),
    ], p.frame.w)!;
    expect(placed.k, closeTo((90 / 22) / p.frame.w, 1e-12));
    final s = fromFrame(em, placed);
    expect(s.points[0].x, closeTo(30, 1e-9));
    expect(s.points[1].x, closeTo(120, 1e-9), reason: 'o fim do trecho');
    expect(s.points[0].y, closeTo(200, 1e-9));
    expect(s.points[2].y, closeTo(200 - 10 / _em * 22, 1e-9));
  });

  test('pedaços da mesma linha (estilos diferentes) se juntam antes', () {
    final placed = placedFrame([
      (left: 28, right: 60, baseline: 100, em: _em),
      (left: 60, right: 109, baseline: 100.2, em: _em),
    ], (109 - 28) / _em)!;
    expect((placed.x, placed.baseline, placed.em), (28.0, 100.0, _em));
    expect(placed.k, closeTo(1, 1e-12));
  });

  test('o trecho que passou a quebrar: k = 1 no começo do 1º pedaço', () {
    final placed = placedFrame([
      (left: 250, right: 330, baseline: 100, em: _em),
      (left: 28, right: 60, baseline: 135.26, em: _em),
    ], 5.3)!;
    expect(placed, (x: 250.0, baseline: 100.0, em: _em, k: 1.0));
  });

  test('camada sem a chave "ink" (w nulo): k = 1', () {
    final placed = placedFrame([
      (left: 28, right: 109, baseline: 100, em: _em),
    ], null)!;
    expect(placed.k, 1);
  });

  test('a âncora que não volta: null (não pinta, não apaga)', () {
    expect(placedFrame(const [], 3.2), isNull);
  });

  test('âncora de 8 chaves: grava e lê; o EpubAnchor recusa as 8', () {
    final a = inkLayerAnchor(_range, 8.21234);
    expect(a.toJson()['ink'], {'w': 8.2123});
    expect(a.toJson().length, 8);
    expect(TextAnchor.fromJson(a.toJson()), isA<RawAnchor>());
    expect(inkAnchorOf(TextAnchor.fromJson(a.toJson())), (
      range: _range,
      w: 8.2123,
    ));
    // a de 7 chaves (a da anotação `drawing`) dá w nulo
    expect(inkAnchorOf(_range), (range: _range, w: null));
    // o servidor pode devolver o número inteiro
    expect(
      inkAnchorOf(
        RawAnchor({
          ..._range.toJson(),
          'ink': {'w': 8},
        }),
      )!.w,
      8.0,
    );
    // outra coisa: null
    expect(inkAnchorOf(RawAnchor(const {'page': 1, 'quads': []})), isNull);
    expect(inkAnchorOf(RawAnchor({..._range.toJson(), 'ink': 'w'})), isNull);
  });
}

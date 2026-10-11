// G17.4 (Anexo 03 §9.4, R21) — o Marca-texto gruda nas palavras: a linha central do traço recortada na faixa de cada
// linha; palavra coberta = ≥ 50 % da largura dela sob o traço; a pontuação não conta nem quebra; cobertas seguidas no
// texto formam um trecho; sem palavra coberta, nada (o traço vira tinta — R22).
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/annotations/ink/marker_snap.dart';
import 'package:flutter_test/flutter_test.dart';

/// 3 linhas de texto, 8 px por letra a partir de x = 28; as linhas de 35 a partir de y = 100.
const _linhas = [
  'Retórica dos namorados, dá-me',
  'Olhos de ressaca? Vá, de ressaca.',
  'É o que me dá ideia daquela',
];
late String _texto;

InkPageGeometry _pagina() {
  final buf = StringBuffer();
  final lines = <InkLine>[];
  final token = RegExp(r'[\p{L}\p{N}]+|[^\p{L}\p{N}\s]', unicode: true);
  for (var i = 0; i < _linhas.length; i++) {
    if (buf.isNotEmpty) buf.write(' ');
    final start = buf.length;
    buf.write(_linhas[i]);
    final words = [
      for (final m in token.allMatches(_linhas[i]))
        (
          from: start + m.start,
          to: start + m.end,
          left: 28.0 + 8 * m.start,
          right: 28.0 + 8 * m.end,
        ),
    ];
    final top = 100.0 + 35 * i;
    lines.add(
      InkLine(
        unit: 4,
        from: words.first.from,
        to: words.last.to,
        top: top,
        bottom: top + 35,
        baseline: top + 26,
        em: 20.5,
        left: 28,
        right: words.last.right,
        words: words,
      ),
    );
  }
  _texto = buf.toString();
  return InkPageGeometry(lines);
}

/// O x do caractere [i] da linha [l] (o meio da letra).
double _x(int l, int i) => 28.0 + 8 * i + 4;
double _y(int l) => 100.0 + 35 * l + 17;

String _de(MarkedRun r) => _texto.substring(r.from, r.to);

void main() {
  final pagina = _pagina();
  List<MarkedRun> grifa(List<InkOffset> pts) =>
      markedRuns(pts, pagina, textOf: (u) => u == 4 ? _texto : null);

  test('reta sobre "de ressaca": um trecho, do começo da 1ª palavra ao fim da última', () {
    final l = _linhas[1];
    final a = l.indexOf('de ressaca');
    final runs = grifa([
      (x: _x(1, a), y: _y(1)),
      (x: _x(1, a + 'de ressaca'.length - 1), y: _y(1)),
    ]);
    expect(runs.map(_de), ['de ressaca']);
    expect(runs.single.unit, 4);
  });

  test(
    'menos da metade fica de fora; a pontuação no meio não conta nem quebra',
    () {
      final l = _linhas[1];
      // de "ressaca" (inteira) até 1 letra de "Vá" (metade de 2 letras = conta) e só a 1ª letra de "Olhos"
      final a = l.indexOf('ressaca?');
      final b = l.indexOf('Vá');
      // até o fim do "V": 8 de 16 px de "Vá" = 50 %, conta
      final runs = grifa([
        (x: _x(1, a) - 4, y: _y(1)),
        (x: 28.0 + 8 * (b + 1), y: _y(1)),
      ]);
      expect(runs.map(_de), ['ressaca? Vá']);
      // até o meio do "V": 25 %, fica de fora
      final menos = grifa([
        (x: _x(1, a) - 4, y: _y(1)),
        (x: _x(1, b), y: _y(1)),
      ]);
      expect(menos.map(_de), ['ressaca']);
      // "Olhos": o traço cobre 2 das 5 letras (16 de 40 px) → fora
      final o = grifa([(x: 28, y: _y(1)), (x: 28 + 16, y: _y(1))]);
      expect(o, isEmpty);
    },
  );

  test('torto, descendo para a linha de baixo: em cada linha, as palavras ≥ 50 % sob o pedaço dela', () {
    final l1 = _linhas[1];
    // de "de ressaca." no fim da linha 1, descendo na diagonal até o fim de "que" na linha 2
    final runs = grifa([
      (x: _x(1, l1.lastIndexOf('de ressaca')), y: _y(1)),
      (x: 28.0 + 8 * l1.length, y: _y(1) + 13),
      (x: _x(2, 6), y: _y(2) + 3),
    ]);
    // na linha 1, "de ressaca" (o "." não conta); na 2, o traço volta da direita: "que" fica com 4 de 24 px,
    // "É" e "o" de fora — e quebram o trecho; de "me" a "daquela", coberto
    expect(runs.map(_de), ['de ressaca', 'me dá ideia daquela']);
  });

  test('cobertas com uma palavra sem cobrir no meio = 2 trechos', () {
    final l = _linhas[1];
    final runs = grifa([
      (x: _x(1, l.indexOf('Olhos')), y: _y(1)),
      (x: _x(1, l.indexOf('Olhos') + 4), y: _y(1)),
      (
        x: _x(1, l.indexOf('Olhos') + 4),
        y: _y(1) - 30,
      ), // sai da linha por cima de "de"
      (x: _x(1, l.indexOf('ressaca')), y: _y(1) - 30),
      (x: _x(1, l.indexOf('ressaca')), y: _y(1)),
      (x: _x(1, l.indexOf('ressaca') + 6), y: _y(1)),
    ]);
    expect(runs.map(_de), ['Olhos', 'ressaca']);
  });

  test(
    'o fim de uma linha e o começo da seguinte, cobertos, formam um trecho só',
    () {
      final l0 = _linhas[0];
      // o fim da linha 0, por fora da página (acima dela e na margem da esquerda) até o começo da linha 1
      final runs = grifa([
        (x: _x(0, l0.indexOf('dá-me')), y: _y(0)),
        (x: _x(0, l0.length - 1), y: _y(0)),
        (x: _x(0, l0.length - 1), y: 90),
        (x: 10, y: 90),
        (x: 10, y: _y(1)),
        (x: _x(1, 'Olhos'.length - 1), y: _y(1)),
      ]);
      expect(runs.map(_de), ['dá-me Olhos']);
    },
  );

  test('um toque (1 ponto) não cobre palavra; na margem, nada; sem o texto do item, nada', () {
    expect(grifa([(x: _x(1, 2), y: _y(1))]), isEmpty);
    expect(grifa([(x: 2, y: _y(1)), (x: 20, y: _y(1))]), isEmpty);
    expect(grifa([(x: 300, y: 50), (x: 340, y: 60)]), isEmpty);
    expect(
      markedRuns(
        [(x: _x(1, 0), y: _y(1)), (x: _x(1, 20), y: _y(1))],
        pagina,
        textOf: (_) => null,
      ),
      isEmpty,
    );
  });

  test('a faixa das letras da linha (R20): sem medida, a linha inteira', () {
    const linha = InkLine(
      unit: 1,
      from: 0,
      to: 1,
      top: 10,
      bottom: 40,
      baseline: 30,
      em: 20,
      left: 0,
      right: 8,
      words: [(from: 0, to: 1, left: 0, right: 8)],
    );
    expect((linha.textTop, linha.textBottom), (10.0, 40.0));
    const medida = InkLine(
      unit: 1,
      from: 0,
      to: 1,
      top: 10,
      bottom: 40,
      baseline: 30,
      em: 20,
      left: 0,
      right: 8,
      words: [(from: 0, to: 1, left: 0, right: 8)],
      textTop: 13,
      textBottom: 36,
    );
    expect((medida.textTop, medida.textBottom), (13.0, 36.0));
    expect(medida == linha, isFalse);
  });
}

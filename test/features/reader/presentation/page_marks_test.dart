// G17 — o que a página pinta dos grifos: o fundo na altura de cada um (D-172: Baixa 50–92 %, Média 12–92 %, Alta
// 0–100 % da letra), o sublinhado (4 px a 3 px da base) e o ondulado (R25) por cima do texto, na cor viva; no Noite,
// as manchas dos grifos à mão recortam os fundos da mesma linha (achado 17).
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/annotations/domain/annotation.dart'
    show FillHeight, HighlightStyle;
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/presentation/page_marks.dart';
import 'package:app_leitura/features/reader/presentation/wavy_underline.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Uma linha: o caractere i ocupa 2 px a partir de x = 30; área do texto de 122,41 a 152,85, base 149,6.
final class _Pagina implements DisplayPage {
  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) => [
    (
      rect: Rect.fromLTRB(30.0 + 2 * from, 120, 30.0 + 2 * to, 140),
      baseline: 149.6,
      textTop: 122.41,
      textBottom: 152.85,
      em: 20.5,
    ),
  ];

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _Tela implements ui.Canvas {
  final retangulos = <(Rect, Color)>[];
  final caminhos = <(Path, Paint)>[];

  @override
  void drawRect(Rect rect, Paint paint) => retangulos.add((rect, paint.color));

  @override
  void drawPath(Path path, Paint paint) => caminhos.add((path, paint));

  @override
  Float64List getTransform() => Float64List(16);

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

PaintedHighlight _g(
  HighlightStyle style, {
  FillHeight height = FillHeight.medium,
  Color color = const Color(0xFFFED170),
}) => PaintedHighlight(
  id: 'g',
  range: (unit: 2, from: 10, to: 30),
  color: color,
  style: style,
  height: height,
);

void main() {
  const area = 152.85 - 122.41;

  test('D-172: o fundo corta a faixa de cada altura', () {
    for (final (h, a, z) in [
      (FillHeight.low, .50, .92),
      (FillHeight.medium, .12, .92),
      (FillHeight.high, .0, 1.0),
    ]) {
      final b = backgroundBands(
        _Pagina(),
        highlights: [_g(HighlightStyle.fill, height: h)],
      ).single;
      expect(b.clipTop, moreOrLessEquals(122.41 + a * area, epsilon: 1e-9));
      expect(b.clipBottom, moreOrLessEquals(122.41 + z * area, epsilon: 1e-9));
      expect((b.left, b.right, b.radius), (50.0, 90.0, 3.0));
    }
    // o sublinhado e o ondulado não têm fundo
    expect(
      backgroundBands(
        _Pagina(),
        highlights: [_g(HighlightStyle.underline), _g(HighlightStyle.wavy)],
      ),
      isEmpty,
    );
  });

  test('o sublinhado (4 px a 3 px da base) e o ondulado (R25) por cima, na cor viva; o fundo, nada', () {
    final tela = _Tela();
    paintUnderlines(tela, _Pagina(), [
      _g(HighlightStyle.fill),
      _g(HighlightStyle.underline, color: const Color(0xD9FFC1C6)),
      _g(HighlightStyle.wavy, color: const Color(0xD9B6ACE4)),
    ]);
    final (r, c) = tela.retangulos.single;
    expect(r, const Rect.fromLTRB(50, 152.6, 90, 156.6));
    expect(c.toARGB32(), 0xFFFFC1C6);
    final (path, paint) = tela.caminhos.single;
    expect(paint.style, PaintingStyle.stroke);
    expect(paint.strokeWidth, wavyThickness);
    expect(paint.strokeCap, StrokeCap.butt);
    expect(paint.color.toARGB32(), 0xFFB6ACE4);
    final b = path.getBounds();
    expect((b.left, b.right), (50.0, 90.0));
    expect(b.top, closeTo(149.6 + 4.5 - 2.2, 0.01));
    expect(b.bottom, closeTo(149.6 + 4.5 + 2.2, 0.01));
  });
}

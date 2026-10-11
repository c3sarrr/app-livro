// G16.2 — um desenho = traços que se tocam (D-162): a caixa do traço cresce meia espessura, a do desenho meia altura
// de linha; tocando dois, entra no mais recente e eles não se fundem. Os casos são os da pág. 159, com as caixas
// medidas da prancha 22 menos os 30 px do modo (coordenadas do leitor limpo).
import 'package:app_leitura/features/reader/annotations/ink/drawing_clusters.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:flutter_test/flutter_test.dart';

const _lineHeight = 35.26;

// ann.page.text.circled.ellipse / .flourish / doubleUnderline.line1 / .line2 / wavy.wave, sem os 30 px
const _ellipse = InkRect(19, 335.23, 205.54, 377.67);
const _flourish = InkRect(95.27, 327.23, 129.27, 339.23);
const _bar1 = InkRect(83.67, 548.57, 271.14, 550.97);
const _bar2 = InkRect(83.67, 553.57, 271.14, 555.97);
const _wave = InkRect(27, 476.45, 135.99, 486.45);

InkStroke _stroke(List<(double, double)> points, {int width = 120}) =>
    InkStroke(
      tool: InkTool.pen.code,
      tip: 0,
      argb: 0xFFFF552E,
      widthCentiMm: width,
      points: [for (final (x, y) in points) InkPoint(x, y, 0.5, 0)],
    );

void main() {
  test('a caixa do traço: os pontos crescidos em meia espessura (D-159)', () {
    final box = strokeBox(_stroke([(10, 20), (30, 5)]));
    expect(box.left, closeTo(8.9, 1e-12));
    expect(box.top, closeTo(3.9, 1e-12));
    expect(box.right, closeTo(31.1, 1e-12));
    expect(box.bottom, closeTo(21.1, 1e-12));
    // um ponto só (um toque): o círculo dele
    final r = dpOfCentiMm(240) / 2;
    expect(r, closeTo(2.2, 1e-12));
    expect(
      strokeBox(_stroke([(50, 50)], width: 240)),
      InkRect(50 - r, 50 - r, 50 + r, 50 + r),
    );
    expect(() => strokeBox(_stroke(const [])), throwsArgumentError);
  });

  test('a caixa do desenho: a união das caixas dos traços', () {
    final a = _stroke([(10, 20), (30, 5)]);
    final b = _stroke([(100, 200)]);
    expect(drawingBox([a, b]), strokeBox(a).union(strokeBox(b)));
    expect(drawingBox([a]), strokeBox(a));
  });

  test('pág. 159: a elipse e o risco ficam juntos', () {
    expect(
      touchedDrawing(_flourish, [
        (order: 0, box: _ellipse),
      ], lineHeight: _lineHeight),
      0,
    );
  });

  test('pág. 159: as 2 barras do sublinhado duplo ficam juntas', () {
    expect(
      touchedDrawing(_bar2, [(order: 3, box: _bar1)], lineHeight: _lineHeight),
      3,
    );
  });

  test('pág. 159: a onda fica separada da elipse e das barras', () {
    expect(
      touchedDrawing(_wave, [
        (order: 0, box: _ellipse),
        (order: 1, box: _bar1.union(_bar2)),
      ], lineHeight: _lineHeight),
      isNull,
    );
    expect(
      touchedDrawing(_bar1, [(order: 0, box: _wave)], lineHeight: _lineHeight),
      isNull,
    );
  });

  test('a folga é de meia altura de linha, no desenho', () {
    const drawing = InkRect(0, 0, 100, 10);
    final half = _lineHeight / 2;
    expect(
      touchedDrawing(InkRect(0, 10 + half, 10, 30 + half), [
        (order: 0, box: drawing),
      ], lineHeight: _lineHeight),
      0,
      reason: 'na borda da folga',
    );
    expect(
      touchedDrawing(InkRect(0, 10.01 + half, 10, 30 + half), [
        (order: 0, box: drawing),
      ], lineHeight: _lineHeight),
      isNull,
    );
  });

  test(
    'tocando dois desenhos: entra no mais recente (e eles não se fundem)',
    () {
      const left = InkRect(0, 0, 50, 10);
      const right = InkRect(60, 0, 110, 10);
      const between = InkRect(45, 2, 65, 8);
      expect(
        touchedDrawing(between, [
          (order: 2, box: right),
          (order: 5, box: left),
        ], lineHeight: _lineHeight),
        5,
      );
      expect(
        touchedDrawing(between, [
          (order: 7, box: right),
          (order: 5, box: left),
        ], lineHeight: _lineHeight),
        7,
      );
      expect(
        touchedDrawing(between, const [], lineHeight: _lineHeight),
        isNull,
        reason: 'desenho novo',
      );
    },
  );
}

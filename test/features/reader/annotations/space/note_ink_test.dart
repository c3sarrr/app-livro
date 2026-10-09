// G18.2 — a tinta da nota à mão na unidade da caixa (R6, Anexo 03 §9.5): x = fração da largura da caixa, y = linhas
// da nota (42 px) a partir do topo; ida e volta no BNK1 `box`; a parte de baixo da tinta e as linhas que ela ocupa
// (D-186); o traço é da nota quando começa dentro da caixa.
import 'dart:ui';

import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:app_leitura/features/reader/annotations/space/note_ink.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const caixa = Rect.fromLTWH(28, 434.08, 334, 150);
  InkStroke traco(List<(double, double)> pts, {int largura = 120}) => InkStroke(
    tool: InkTool.pen.code,
    tip: 0,
    argb: 0xFFFF552E,
    widthCentiMm: largura,
    points: [for (final (x, y) in pts) InkPoint(x, y, 0.5, 0)],
  );

  test(
    'na unidade da nota: x ÷ largura, y ÷ 42 a partir do topo; e de volta',
    () {
      final s = traco([(28, 434.08), (195, 476.08), (362, 584.08)]);
      final n = toNote(s, caixa);
      const esperado = [(0.0, 0.0), (0.5, 1.0), (1.0, 150 / 42)];
      for (var i = 0; i < esperado.length; i++) {
        expect(n.points[i].x, closeTo(esperado[i].$1, 1e-12));
        expect(n.points[i].y, closeTo(esperado[i].$2, 1e-12));
      }
      final volta = fromNote(n, caixa);
      for (var i = 0; i < s.points.length; i++) {
        expect(volta.points[i].x, closeTo(s.points[i].x, 1e-9));
        expect(volta.points[i].y, closeTo(s.points[i].y, 1e-9));
      }
      expect(
        (volta.argb, volta.widthCentiMm, volta.tool),
        (s.argb, s.widthCentiMm, s.tool),
      );
    },
  );

  test('ida e volta no BNK1 box: o erro fica no meio passo da quantização', () {
    final s = traco([(41.3, 470.2), (200.77, 520.9), (350.1, 560.05)]);
    final b64 = encodeStrokesB64([toNote(s, caixa)], Bnk1Unit.box);
    final volta = fromNote(decodeStrokesB64(b64, Bnk1Unit.box).single, caixa);
    for (var i = 0; i < s.points.length; i++) {
      expect(
        volta.points[i].x,
        closeTo(s.points[i].x, 0.5 * 334 / 10000 + 1e-9),
      );
      expect(
        volta.points[i].y,
        closeTo(s.points[i].y, 0.5 * 42 / 10000 + 1e-9),
      );
    }
  });

  test('a parte de baixo da tinta (px do topo da caixa): o maior y e a metade da largura', () {
    final a = toNote(traco([(40, 450), (60, 530)]), caixa);
    final b = toNote(traco([(80, 470)], largura: 240), caixa);
    final meia = dpOfCentiMm(120) / 2;
    expect(inkBottomPx([a, b]), closeTo(530 - 434.08 + meia, 1e-9));
    expect(inkBottomPx(const []), 0);
    expect(minLinesFor([a, b]), 2); // 96,98 → passa da 1ª pauta (64)
    expect(minLinesFor(const []), 1);
  });

  test('o traço que sai da caixa é recortado na borda (R6): os pedaços de dentro, com o ponto da borda', () {
    const quadro = Rect.fromLTWH(29.5, 435.58, 331, 147);
    InkStroke fino(List<(double, double, double, int)> pts) => InkStroke(
      tool: InkTool.pen.code,
      tip: 0,
      argb: 0xFFFF552E,
      widthCentiMm: 0,
      points: [for (final (x, y, p, t) in pts) InkPoint(x, y, p, t)],
    );
    // desce e sai pelo pé; volta por baixo, entra, e sai pela direita
    final r = clipToFrame(
      fino([
        (100, 500, 0.2, 0),
        (100, 620, 0.6, 10),
        (200, 560, 0.4, 20),
        (400, 560, 0.8, 30),
      ]),
      quadro,
    );
    expect(r, hasLength(2));
    final pe = quadro.bottom;
    final u = (pe - 500) / 120;
    expect(r[0].points, hasLength(2));
    expect(r[0].points[0], const InkPoint(100, 500, 0.2, 0));
    expect(r[0].points[1].x, closeTo(100, 1e-9));
    expect(r[0].points[1].y, closeTo(pe, 1e-9));
    expect(r[0].points[1].pressure, closeTo(0.2 + 0.4 * u, 1e-9));
    expect(r[0].points[1].tMs, (10 * u).round());
    final v = (620 - pe) / 60;
    expect(r[1].points, hasLength(3));
    expect(r[1].points[0].x, closeTo(100 + 100 * v, 1e-9));
    expect(r[1].points[0].y, closeTo(pe, 1e-9));
    expect(r[1].points[1], const InkPoint(200, 560, 0.4, 20));
    expect(r[1].points[2].x, closeTo(quadro.right, 1e-9));
    expect(r[1].points[2].y, closeTo(560, 1e-9));
    // tudo dentro: o mesmo traço; tudo fora: nada; o ponto solto conta pelo lugar dele
    final dentro = fino([(40, 450, 0.5, 0), (60, 530, 0.5, 8)]);
    expect(clipToFrame(dentro, quadro), [dentro]);
    expect(
      clipToFrame(fino([(10, 10, 0.5, 0), (20, 20, 0.5, 8)]), quadro),
      isEmpty,
    );
    expect(clipToFrame(fino([(40, 450, 0.5, 0)]), quadro), hasLength(1));
    expect(clipToFrame(fino([(10, 450, 0.5, 0)]), quadro), isEmpty);
    // com largura: a tinta inteira fica por dentro (a borda menos a metade dela)
    final grosso = traco([(100, 500), (100, 620)]);
    final meia = dpOfCentiMm(120) / 2;
    expect(
      clipToFrame(grosso, quadro).single.points.last.y,
      closeTo(pe - meia, 1e-9),
    );
  });

  test('o traço é da nota quando o 1º ponto cai na caixa (R6)', () {
    expect(startsInside(traco([(30, 440), (30, 300)]), caixa), isTrue);
    expect(startsInside(traco([(30, 300), (30, 440)]), caixa), isFalse);
    expect(startsInside(traco(const []), caixa), isFalse);
  });
}

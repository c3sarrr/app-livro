// G16.1 — o traço da tinta: pontos, ferramenta e ponta com os códigos fixos do BNK1 (Anexo 03 §9.6).
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const a = InkStroke(
    tool: 1,
    tip: 0,
    argb: 0xFFFF552E,
    widthCentiMm: 120,
    points: [InkPoint(1, 2, 0.5, 0), InkPoint(3, 4, 0.6, 8)],
  );

  test('igualdade por valor, inclusive dos pontos', () {
    const b = InkStroke(
      tool: 1,
      tip: 0,
      argb: 0xFFFF552E,
      widthCentiMm: 120,
      points: [InkPoint(1, 2, 0.5, 0), InkPoint(3, 4, 0.6, 8)],
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a == a.copyWith(points: const [InkPoint(1, 2, 0.5, 0)]), isFalse);
    expect(a == a.copyWith(argb: 0xFF552CB7), isFalse);
    expect(a == a.copyWith(widthCentiMm: 72), isFalse);
    expect(const InkPoint(1, 2, 0.5, 0), const InkPoint(1, 2, 0.5, 0));
    expect(
      const InkPoint(1, 2, 0.5, 0) == const InkPoint(1, 2, 0.5, 1),
      isFalse,
    );
  });

  test('transladar move só x e y', () {
    final t = a.translated(10, -2);
    expect(t.points, const [InkPoint(11, 0, 0.5, 0), InkPoint(13, 2, 0.6, 8)]);
    expect((t.tool, t.tip, t.argb, t.widthCentiMm), (1, 0, 0xFFFF552E, 120));
  });

  test('códigos fixos da ferramenta; o 3 é o marca-texto (G17)', () {
    expect(InkTool.pen.code, 1);
    expect(InkTool.line.code, 2);
    expect(InkTool.marker.code, 3);
    expect(InkTool.fromCode(1), InkTool.pen);
    expect(InkTool.fromCode(2), InkTool.line);
    // G17: o 3 é o Marca-texto (a tinta translúcida — R22)
    expect(InkTool.fromCode(3), InkTool.marker);
    expect(InkTool.fromCode(4), isNull);
    expect(InkTool.fromCode(0), isNull);
  });

  test('ponta: as do PenTip; desconhecida = esferográfica', () {
    expect(tipCode(PenTip.ballpoint), 0);
    expect(tipCode(PenTip.fountain), 1);
    expect(tipCode(PenTip.brush), 2);
    expect(tipOfCode(1), PenTip.fountain);
    expect(tipOfCode(2), PenTip.brush);
    expect(tipOfCode(9), PenTip.ballpoint);
  });

  test('cor: ARGB ↔ #RRGGBB', () {
    expect(colorHex(0xFFFF552E), '#FF552E');
    expect(colorHex(0x80058CD7), '#058CD7');
    expect(argbOfHex('#552CB7'), 0xFF552CB7);
  });
}

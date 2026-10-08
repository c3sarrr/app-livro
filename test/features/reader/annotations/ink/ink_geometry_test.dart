// G16.2 — linhas e palavras da página para a âncora da tinta, sem widget: o ponto de referência da linha (0,25 em
// acima da base — §2), a altura de linha e o retângulo (tocar a borda conta como tocar).
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

InkLine _line({double top = 80, double baseline = 100, double em = 20}) =>
    InkLine(
      unit: 3,
      from: 10,
      to: 20,
      top: top,
      bottom: top + 35,
      baseline: baseline,
      em: em,
      left: 28,
      right: 300,
      words: const [(from: 10, to: 15, left: 28, right: 80)],
    );

void main() {
  test('o ponto de referência da linha: 0,25 em acima da linha de base', () {
    expect(_line().refY, 95);
    expect(_line(baseline: 135.25, em: 20.5).refY, closeTo(130.125, 1e-12));
  });

  test('altura de linha: a da 1ª linha; sem linhas, 0', () {
    expect(InkPageGeometry([_line(), _line(top: 115)]).lineHeight, 35);
    expect(const InkPageGeometry([]).lineHeight, 0);
    expect(InkPageGeometry.empty.lines, isEmpty);
  });

  test('retângulo: centro, crescer, unir', () {
    const r = InkRect(10, 20, 30, 60);
    expect((r.width, r.height), (20, 40));
    expect(r.center, (x: 20, y: 40));
    expect(r.inflate(5), const InkRect(5, 15, 35, 65));
    expect(r.union(const InkRect(0, 30, 15, 90)), const InkRect(0, 20, 30, 90));
  });

  test('retângulo: tocar a borda conta como tocar', () {
    const r = InkRect(0, 0, 10, 10);
    expect(r.overlaps(const InkRect(10, 0, 20, 10)), isTrue);
    expect(r.overlaps(const InkRect(0, 10, 10, 20)), isTrue);
    expect(r.overlaps(const InkRect(10, 10, 20, 20)), isTrue);
    expect(r.overlaps(const InkRect(10.01, 0, 20, 10)), isFalse);
    expect(r.overlaps(const InkRect(0, -10, 10, -0.01)), isFalse);
    expect(r.overlaps(const InkRect(2, 2, 3, 3)), isTrue, reason: 'dentro');
  });
}

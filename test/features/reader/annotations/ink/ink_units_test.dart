// G16.1 (D-159) — espessura na escala da prancha 22: 1 mm = 11/6 dp.
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('1,2 mm Média desenha com 2,2 px (o traço ao vivo da 22)', () {
    expect(dpPerMm, 11 / 6);
    expect(strokeDp(1.2, StrokeSize.medium), closeTo(2.2, 1e-12));
    expect(strokeDp(1.2, StrokeSize.thin), closeTo(1.32, 1e-12));
    expect(strokeDp(1.2, StrokeSize.thick), closeTo(3.96, 1e-12));
  });

  test('o slider de 0,3–4,0 mm vira 0,55–7,33 px', () {
    expect(strokeDp(0.3, StrokeSize.medium), closeTo(0.55, 1e-12));
    expect(strokeDp(4.0, StrokeSize.medium), closeTo(22 / 3, 1e-12));
  });

  test('a largura gravada é a efetiva, em centésimos de mm', () {
    expect(widthCentiMm(1.2, StrokeSize.medium), 120);
    expect(widthCentiMm(1.2, StrokeSize.thin), 72);
    expect(widthCentiMm(1.2, StrokeSize.thick), 216);
    expect(widthCentiMm(4.0, StrokeSize.thick), 720);
    expect(widthCentiMm(0.3, StrokeSize.thin), 18);
    expect(dpOfCentiMm(120), closeTo(2.2, 1e-12));
    expect(dpOfCentiMm(216), closeTo(3.96, 1e-12));
  });

  test('as larguras do arquivo viram centésimos pela D-159 (§7)', () {
    // a elipse (2,3 px), o risco (1,8 px) e as barras do sublinhado duplo (2,4 px)
    expect(centiMmOfDp(2.3), 125);
    expect(centiMmOfDp(1.8), 98);
    expect(centiMmOfDp(2.4), 131);
    expect(centiMmOfDp(2.2), 120);
  });
}

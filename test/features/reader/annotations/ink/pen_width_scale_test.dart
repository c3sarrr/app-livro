// G17.3 (D-50, R11) — o slider de espessura da tela 23: 0,3–4,0 mm com `v = 0,3 + 3,7 · t^1,24`, que põe 1,2 mm em
// 32 % como a prancha; o valor anda de 0,1 em 0,1 (o `numeric(3,1)` do `pen_presets`).
import 'package:app_leitura/features/reader/annotations/ink/pen_width_scale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('1,2 mm fica em 32 % (o preenchimento de 89,92 em 281 da prancha)', () {
    expect(sliderOfWidth(1.2), closeTo(0.32, 0.001));
    expect(281 * sliderOfWidth(1.2), closeTo(89.92, 0.3));
  });

  test('as pontas: 0,3 e 4,0 mm', () {
    expect(widthOfSlider(0), 0.3);
    expect(widthOfSlider(1), 4.0);
    expect(widthOfSlider(-0.5), 0.3);
    expect(widthOfSlider(1.5), 4.0);
    expect(sliderOfWidth(0.3), 0);
    expect(sliderOfWidth(4.0), 1);
  });

  test('ida e volta em passos de 0,1; o valor sai arredondado a 1 casa', () {
    for (var d = 3; d <= 40; d++) {
      final mm = d / 10;
      expect(widthOfSlider(sliderOfWidth(mm)), mm, reason: '$mm');
    }
    expect(widthOfSlider(0.32), 1.2);
    expect(widthOfSlider(0.5), 1.9);
  });

  test(
    'o texto do valor: "1,2 mm" e "2,0 mm" (sempre 1 casa, com vírgula)',
    () {
      expect(widthLabel(1.2), '1,2 mm');
      expect(widthLabel(2), '2,0 mm');
      expect(widthLabel(0.3), '0,3 mm');
      expect(widthSpoken(1.2), '1,2 milímetro');
      expect(widthSpoken(1.9), '1,9 milímetro');
      expect(widthSpoken(2), '2,0 milímetros');
    },
  );
}

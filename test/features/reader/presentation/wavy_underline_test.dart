// G17 (R25) — o ondulado, medido na amostra da 23b (`mk.markerPanel.styles.wavy.sample.word`, Chromium 141 a 10×:
// `text-decoration: underline 2.5px wavy`, `text-underline-offset: 2px`): a linha do meio da onda fica 4,5 px abaixo
// da base, com período de 10,3 px e amplitude de 2,2 px, e começa na borda esquerda da caixa, no meio, descendo; o
// traço tem 2,5 px.
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/presentation/wavy_underline.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('as medidas', () {
    expect(
      (wavyThickness, wavyPeriod, wavyAmplitude, wavyBelowBaseline),
      (2.5, 10.3, 2.2, 4.5),
    );
  });

  test('a linha do meio: começa no meio descendo; pico, vale e volta a cada período', () {
    double y(double x) => wavyY(x, left: 10, baseline: 100);
    expect(y(10), closeTo(104.5, 1e-9));
    expect(y(10.5), greaterThan(104.5), reason: 'descendo');
    expect(y(10 + 10.3 / 4), closeTo(106.7, 1e-9));
    expect(y(10 + 10.3 / 2), closeTo(104.5, 1e-9));
    expect(y(10 + 3 * 10.3 / 4), closeTo(102.3, 1e-9));
    expect(y(10 + 10.3), closeTo(104.5, 1e-9));
  });

  test('bate com o Chromium: os picos (para baixo) e os vales medidos a partir da borda', () {
    double y(double x) => wavyY(x, left: 0, baseline: 0);
    for (final x in [2.5, 12.8, 23.1, 33.4, 43.7, 54.0]) {
      expect(y(x), greaterThan(4.5 + 2.2 - 0.05), reason: 'pico em $x');
    }
    for (final x in [7.5, 17.8, 28.1, 38.4, 48.7]) {
      expect(y(x), lessThan(4.5 - 2.2 + 0.05), reason: 'vale em $x');
    }
  });

  test('o caminho vai da borda esquerda à direita, entre o vale e o pico', () {
    final b = wavyUnderlinePath(10, 65.04, 100).getBounds();
    expect(b.left, closeTo(10, 1e-6));
    expect(b.right, closeTo(65.04, 1e-6));
    expect(b.top, closeTo(102.3, 0.01));
    expect(b.bottom, closeTo(106.7, 0.01));
    expect(wavyUnderlinePath(10, 10, 100).getBounds().isEmpty, isTrue);
  });

  test(
    'nos pixels: o traço de 2,5 px no pico, na cor; acima do pico, o papel',
    () async {
      const papel = Color(0xFFF8F1E4);
      const cor = Color(0xFFFED170);
      final gravador = ui.PictureRecorder();
      final canvas = Canvas(gravador)
        ..drawRect(const Rect.fromLTWH(0, 0, 80, 40), Paint()..color = papel);
      paintWavyUnderline(canvas, 10, 70, 20, cor);
      final img = await gravador.endRecording().toImage(80, 40);
      final bytes = (await img.toByteData())!;
      img.dispose();
      Color px(int x, int y) {
        final i = (y * 80 + x) * 4;
        return Color.fromARGB(
          bytes.getUint8(i + 3),
          bytes.getUint8(i),
          bytes.getUint8(i + 1),
          bytes.getUint8(i + 2),
        );
      }

      // o pico do 1º período: x = 10 + 2,575; a linha do meio em 26,7, o traço de 25,45 a 27,95
      expect(px(12, 26), cor);
      expect(px(12, 23), papel);
      // o vale: x = 10 + 7,725; o traço de 21,05 a 23,55
      expect(px(17, 22), cor);
      expect(px(17, 26), papel);
      // fora da caixa, nada
      expect(px(8, 24), papel);
      expect(px(72, 24), papel);
    },
  );
}

// G17.1 — a cor da roda da tela 23 (R13): HSV com o tom a partir do topo no sentido horário, o hex de 6 dígitos (R14)
// e o contraste da WCAG 2.1 que decide a tinta quase preta no Noite (D-174).
import 'package:app_leitura/core/design_system/color/hsv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coral #FF552E: tom 11,2°, intensidade 0,82, brilho 1 (o cursor da prancha 23)', () {
    final c = Hsv.fromHex('#FF552E');
    expect(c.h, closeTo(11.196, 1e-3));
    expect(c.s, closeTo(209 / 255, 1e-9));
    expect(c.v, 1);
    expect(c.toHex(), '#FF552E');
    expect(c.toArgb(), 0xFFFF552E);
  });

  test('ida e volta: hex → HSV → hex volta igual', () {
    for (final hex in const [
      '#000000',
      '#FFFFFF',
      '#1A1714',
      '#552CB7',
      '#058CD7',
      '#00995E',
      '#F2A815',
      '#FED170',
      '#FFC1C6',
      '#ABCF82',
      '#B6ACE4',
      '#7F7F80',
      '#010203',
      '#FEFDFC',
    ]) {
      expect(Hsv.fromHex(hex).toHex(), hex, reason: hex);
    }
    // todos os cinzas e uma varredura grossa do cubo
    for (var r = 0; r < 256; r += 17) {
      for (var g = 0; g < 256; g += 51) {
        for (var b = 0; b < 256; b += 85) {
          final argb = 0xFF000000 | r << 16 | g << 8 | b;
          expect(Hsv.fromArgb(argb).toArgb(), argb);
        }
      }
    }
  });

  test('as 6 cores da roda a cada 60°, do topo no sentido horário', () {
    expect(const Hsv(0, 1, 1).toHex(), '#FF0000');
    expect(const Hsv(60, 1, 1).toHex(), '#FFFF00');
    expect(const Hsv(120, 1, 1).toHex(), '#00FF00');
    expect(const Hsv(180, 1, 1).toHex(), '#00FFFF');
    expect(const Hsv(240, 1, 1).toHex(), '#0000FF');
    expect(const Hsv(300, 1, 1).toHex(), '#FF00FF');
    expect(const Hsv(360, 1, 1).toHex(), '#FF0000');
    // o centro da roda é branco; o brilho 0 é preto
    expect(const Hsv(200, 0, 1).toHex(), '#FFFFFF');
    expect(const Hsv(200, 1, 0).toHex(), '#000000');
  });

  test('com brilho 0 a cor é preta, mas o tom e a intensidade ficam (R13)', () {
    final c = const Hsv(11, 0.8, 1).withV(0);
    expect(c.toHex(), '#000000');
    expect((c.h, c.s, c.v), (11.0, 0.8, 0.0));
    expect(c.withV(1).withS(0.5).withH(90), const Hsv(90, 0.5, 1));
  });

  test(
    'normalizeHex: só 6 dígitos hexadecimais, com ou sem "#", em maiúsculas',
    () {
      expect(normalizeHex('ff552e'), '#FF552E');
      expect(normalizeHex('#ff552e'), '#FF552E');
      expect(normalizeHex('#FF55'), isNull);
      expect(normalizeHex('#FF552E0'), isNull);
      expect(normalizeHex('#GG0000'), isNull);
      expect(normalizeHex(''), isNull);
    },
  );

  test('contraste da WCAG 2.1 e o limite da D-174 contra o papel do Noite', () {
    expect(contrastRatio(0xFFFFFFFF, 0xFF000000), closeTo(21, 1e-9));
    expect(contrastRatio(0xFF000000, 0xFFFFFFFF), closeTo(21, 1e-9));
    expect(contrastRatio(0xFF777777, 0xFF777777), 1);
    expect(relativeLuminance(0xFFFFFFFF), closeTo(1, 1e-12));
    expect(relativeLuminance(0xFF000000), 0);
    // a Tinta preta some no Noite; roxo, azul, coral e o resto não
    const noite = 0xFF1F1B17;
    expect(contrastRatio(0xFF1A1714, noite), lessThan(1.5));
    for (final c in const [0xFF552CB7, 0xFF058CD7, 0xFFFF552E, 0xFF00995E]) {
      expect(contrastRatio(c, noite), greaterThan(1.5), reason: '$c');
    }
  });
}

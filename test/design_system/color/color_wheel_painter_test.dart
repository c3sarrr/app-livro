// G17.1 — a roda de cores da tela 23 (L23.6, R13): o `conic-gradient` de matiz (do topo, no sentido horário) com o
// `radial-gradient(circle closest-side)` branco por cima, num círculo de 121 (a caixa de 124 menos a borda de 1,5) e a
// borda de tinta. O cursor da prancha (coral) fica onde `wheelOffsetOf` diz, e `wheelHsvAt` volta ao tom e à
// intensidade.
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/color/hsv.dart';
import 'package:app_leitura/core/design_system/painters/color_wheel_painter.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<(Uint8List, int)> _pixels(CustomPainter p, double size) async {
  final recorder = ui.PictureRecorder();
  p.paint(Canvas(recorder), Size(size, size));
  final n = size.ceil();
  final image = recorder.endRecording().toImageSync(n, n);
  final data = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  image.dispose();
  return (data!.buffer.asUint8List(), n);
}

(int, int, int, int) _at(Uint8List rgba, int width, int x, int y) {
  final i = (y * width + x) * 4;
  return (rgba[i], rgba[i + 1], rgba[i + 2], rgba[i + 3]);
}

void main() {
  const size = 124.0;
  const useful = 60.5;

  test('o centro é branco; na borda útil, as 6 cores do conic do arquivo a cada 60° (do topo, horário)', () async {
    final (px, w) = await _pixels(
      const ColorWheelPainter(border: AppColors.ink),
      size,
    );
    final (r0, g0, b0, a0) = _at(px, w, 62, 62);
    // o pixel do meio fica a 0,7 px do centro: o branco a 99 %
    for (final ch in [r0, g0, b0]) {
      expect(ch, greaterThanOrEqualTo(250));
    }
    expect(a0, 255);
    const pure = [
      (255, 0, 0),
      (255, 255, 0),
      (0, 255, 0),
      (0, 255, 255),
      (0, 0, 255),
      (255, 0, 255),
    ];
    const radius = 56.0;
    // o branco do radial a 56 de 60,5: 1 − 56/60,5
    const white = 1 - radius / useful;
    for (var k = 0; k < 6; k++) {
      final a = k * math.pi / 3;
      final x = (62 + math.sin(a) * radius).floor();
      final y = (62 - math.cos(a) * radius).floor();
      final (r, g, b, alpha) = _at(px, w, x, y);
      int mix(int c) => (c + (255 - c) * white).round();
      final (pr, pg, pb) = pure[k];
      expect(alpha, 255, reason: 'k=$k');
      expect((r - mix(pr)).abs(), lessThanOrEqualTo(14), reason: 'r k=$k ($r)');
      expect((g - mix(pg)).abs(), lessThanOrEqualTo(14), reason: 'g k=$k ($g)');
      expect((b - mix(pb)).abs(), lessThanOrEqualTo(14), reason: 'b k=$k ($b)');
    }
  });

  test(
    'fora do círculo é transparente; a borda de 1,5 é da cor pedida',
    () async {
      final (px, w) = await _pixels(
        const ColorWheelPainter(border: AppColors.ink),
        size,
      );
      expect(_at(px, w, 2, 2).$4, 0);
      // na borda, de cima: o pixel 0 da linha do meio é tinta
      final (r, g, b, a) = _at(px, w, 62, 0);
      expect((r, g, b), (0x1A, 0x17, 0x14));
      expect(a, greaterThan(200));
    },
  );

  test('o cursor do coral fica onde a prancha mede (o centro em 103; 523,8 com a roda em 31,5; 510,5)', () {
    final o = wheelOffsetOf(Hsv.fromHex('#FF552E'), size);
    expect(31.5 + o.dx, closeTo(103, 0.5));
    expect(510.5 + o.dy, closeTo(523.8, 0.5));
  });

  test(
    'wheelHsvAt e wheelOffsetOf são inversos; fora da roda, preso à borda',
    () {
      for (final (h, s) in const [
        (0.0, 1.0),
        (90.0, 0.5),
        (200.0, 0.25),
        (359.0, 0.9),
        (11.2, 0.82),
      ]) {
        final o = wheelOffsetOf(Hsv(h, s, 1), size);
        final (hh, ss) = wheelHsvAt(o, size);
        expect(hh, closeTo(h, 1e-6));
        expect(ss, closeTo(s, 1e-9));
      }
      // à direita, bem longe: tom 90°, intensidade 1
      final (h, s) = wheelHsvAt(const Offset(400, 62), size);
      expect(h, closeTo(90, 1e-9));
      expect(s, 1);
      // no centro: intensidade 0
      expect(wheelHsvAt(const Offset(62, 62), size).$2, 0);
    },
  );

  test('só repinta com outra borda', () {
    const a = ColorWheelPainter(border: AppColors.ink);
    expect(
      a.shouldRepaint(const ColorWheelPainter(border: AppColors.ink)),
      isFalse,
    );
    expect(
      a.shouldRepaint(const ColorWheelPainter(border: AppColors.inkNight)),
      isTrue,
    );
  });
}

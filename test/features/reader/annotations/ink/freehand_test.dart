// G16.1 — o porte da suavização confere com o perfect-freehand 1.2.3 (npm) nos 30 casos da G02 (S4), as pontas fazem
// sentido e a estabilização 0,2 não achata as ondas curtas (§1).
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/freehand.dart';
import 'package:flutter_test/flutter_test.dart';

FreehandOptions _options(Map<String, dynamic> o) {
  final start = (o['start'] as Map?) ?? const {};
  final end = (o['end'] as Map?) ?? const {};
  double taper(Object? v) => switch (v) {
    true => double.infinity,
    final num n => n.toDouble(),
    _ => 0,
  };
  return FreehandOptions(
    size: (o['size'] as num?)?.toDouble() ?? 16,
    thinning: (o['thinning'] as num?)?.toDouble() ?? 0.5,
    smoothing: (o['smoothing'] as num?)?.toDouble() ?? 0.5,
    streamline: (o['streamline'] as num?)?.toDouble() ?? 0.5,
    simulatePressure: (o['simulatePressure'] as bool?) ?? true,
    taperStart: taper(start['taper']),
    taperEnd: taper(end['taper']),
    capStart: (start['cap'] as bool?) ?? true,
    capEnd: (end['cap'] as bool?) ?? true,
    last: (o['last'] as bool?) ?? false,
  );
}

/// Quanto da amplitude sobra nos pontos estabilizados de uma onda de 12 px de período e 4,5 px de pico a pico,
/// amostrada a cada 2 px. A amplitude sai do ajuste de uma senoide no trecho já estável: o pico a pico das amostras
/// dependeria de onde elas caem na crista (a 2 px, ±30° do pico na entrada e quase no pico depois do atraso do filtro).
double _waveAmplitudeKept(double streamline) {
  const period = 12.0;
  const peak = 2.25;
  final input = [
    for (var x = 0.0; x <= 144; x += 2)
      (x, peak * math.sin(2 * math.pi * x / period), 0.5),
  ];
  final pts = strokePoints(
    input,
    FreehandOptions(size: 2.2, streamline: streamline, simulatePressure: false),
  );
  // 30 pontos seguidos = 5 períodos inteiros: o seno e o cosseno ficam ortogonais e a soma dá a amplitude.
  final steady = pts.where((p) => p.point.$1 >= 72).take(30).toList();
  expect(steady, hasLength(30));
  var sinSum = 0.0;
  var cosSum = 0.0;
  for (final p in steady) {
    final theta = 2 * math.pi * p.point.$1 / period;
    sinSum += p.point.$2 * math.sin(theta);
    cosSum += p.point.$2 * math.cos(theta);
  }
  return 2 *
      math.sqrt(sinSum * sinSum + cosSum * cosSum) /
      steady.length /
      peak;
}

void main() {
  final ref = jsonDecode(
    File('test/fixtures/tinta/pf_referencia.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final inputs = (ref['entradas'] as Map<String, dynamic>).map(
    (k, v) => MapEntry(k, [
      for (final p in v as List)
        (
          ((p as List)[0] as num).toDouble(),
          (p[1] as num).toDouble(),
          p.length > 2 ? (p[2] as num).toDouble() : null,
        ),
    ]),
  );
  final options = (ref['opcoes'] as Map<String, dynamic>).map(
    (k, v) => MapEntry(k, _options(v as Map<String, dynamic>)),
  );

  test(
    'porte = perfect-freehand ${ref['versao']} em ${(ref['casos'] as List).length} casos',
    () {
      var maxError = 0.0;
      for (final c in (ref['casos'] as List).cast<Map<String, dynamic>>()) {
        final expected = (c['saida'] as List).cast<List>();
        final got = freehandOutline(
          inputs[c['entrada']]!,
          options[c['opcoes']]!,
        );
        expect(
          got.length,
          expected.length,
          reason: '${c['entrada']}/${c['opcoes']}',
        );
        for (var i = 0; i < got.length; i++) {
          maxError = math.max(
            maxError,
            (got[i].$1 - (expected[i][0] as num)).abs(),
          );
          maxError = math.max(
            maxError,
            (got[i].$2 - (expected[i][1] as num)).abs(),
          );
        }
      }
      expect(maxError, lessThan(1e-9));
    },
  );

  test('pontas: mais pressão = traço mais largo, menos na esferográfica', () {
    double width(PenTip tip, double pressure) {
      final o = tipOptions(tip, size: 2.2, last: true);
      final c = freehandOutline([
        for (var i = 0; i < 60; i++) (i * 3.0, 0.0, pressure),
      ], o);
      return 2 * c.map((v) => v.$2.abs()).reduce(math.max);
    }

    final ballpoint =
        width(PenTip.ballpoint, 0.9) / width(PenTip.ballpoint, 0.2);
    final fountain = width(PenTip.fountain, 0.9) / width(PenTip.fountain, 0.2);
    final brush = width(PenTip.brush, 0.9) / width(PenTip.brush, 0.2);
    expect(ballpoint, lessThan(fountain));
    expect(fountain, lessThan(brush));
    // esferográfica com pressão média: a largura do painel (D-159)
    expect(width(PenTip.ballpoint, 0.5), closeTo(2.2, 0.01));
  });

  test('pontas: os parâmetros do Anexo 03 §9.3 com a estabilização 0,2', () {
    final b = tipOptions(PenTip.ballpoint, size: 2.2);
    final f = tipOptions(PenTip.fountain, size: 2.2);
    final r = tipOptions(PenTip.brush, size: 2.2, last: true);
    expect((b.thinning, b.taperEnd, b.streamline), (0.1, 0.0, 0.2));
    expect((f.thinning, f.taperEnd, f.streamline), (0.6, double.infinity, 0.2));
    expect((r.thinning, r.smoothing, r.streamline), (0.85, 0.5, 0.2));
    // a pressão vem do ponto (a real ou a simulada na captura): o desenho salvo nunca simula de novo
    expect([
      b.simulatePressure,
      f.simulatePressure,
      r.simulatePressure,
    ], everyElement(isFalse));
    expect((b.size, b.last, r.last), (2.2, false, true));
  });

  test('pressão simulada na captura: a fórmula do perfect-freehand', () {
    expect(firstPressure, 0.25);
    expect(simulatedPressure(0.25, 0, 2.2), closeTo(0.25, 1e-12));
    expect(simulatedPressure(0.5, 1.1, 2.2), closeTo(0.5, 1e-12));
    expect(simulatedPressure(0.25, 1.1, 2.2), closeTo(0.284375, 1e-12));
    expect(simulatedPressure(0.8, 4.4, 2.2), closeTo(0.58, 1e-12));
  });

  test('estabilização 0,2: a onda curta fica; com 0,5 ela achata', () {
    // a média móvel do streamline: t / |1 − (1 − t)·e^(−iω)|, com t = 0,15 + (1 − s)·0,85 e ω = 60° por amostra
    expect(_waveAmplitudeKept(0.2), closeTo(0.8956, 1e-3));
    expect(_waveAmplitudeKept(0.2), greaterThan(0.85));
    expect(_waveAmplitudeKept(0.5), closeTo(0.6615, 1e-3));
    expect(_waveAmplitudeKept(0.5), lessThan(0.7));
  });

  test('entrada vazia e tamanho zero: sem contorno', () {
    expect(freehandOutline(const [], const FreehandOptions()), isEmpty);
    expect(
      freehandOutline(const [(0, 0, 0.5)], const FreehandOptions(size: 0)),
      isEmpty,
    );
  });
}

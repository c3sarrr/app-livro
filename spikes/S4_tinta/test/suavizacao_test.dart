// G02 · S4 — o porte da suavização confere com o perfect-freehand 1.2.3 (npm) e as pontas fazem sentido.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:spike_s4_tinta/suavizacao.dart';

OpcoesTraco _opcoes(Map<String, dynamic> o) {
  final ini = (o['start'] as Map?) ?? const {};
  final fim = (o['end'] as Map?) ?? const {};
  double taper(Object? v) => switch (v) {
    true => double.infinity,
    final num n => n.toDouble(),
    _ => 0,
  };
  return OpcoesTraco(
    tamanho: (o['size'] as num?)?.toDouble() ?? 16,
    afinamento: (o['thinning'] as num?)?.toDouble() ?? 0.5,
    suavizacao: (o['smoothing'] as num?)?.toDouble() ?? 0.5,
    estabilizacao: (o['streamline'] as num?)?.toDouble() ?? 0.5,
    simularPressao: (o['simulatePressure'] as bool?) ?? true,
    taperInicio: taper(ini['taper']),
    taperFim: taper(fim['taper']),
    capInicio: (ini['cap'] as bool?) ?? true,
    capFim: (fim['cap'] as bool?) ?? true,
    completo: (o['last'] as bool?) ?? false,
  );
}

void main() {
  final ref = jsonDecode(
    File('dados/pf_referencia.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final entradas = (ref['entradas'] as Map<String, dynamic>).map(
    (k, v) => MapEntry(k, [
      for (final p in v as List)
        (
          ((p as List)[0] as num).toDouble(),
          (p[1] as num).toDouble(),
          p.length > 2 ? (p[2] as num).toDouble() : null,
        ),
    ]),
  );
  final opcoes = (ref['opcoes'] as Map<String, dynamic>).map(
    (k, v) => MapEntry(k, _opcoes(v as Map<String, dynamic>)),
  );

  test(
    'porte = perfect-freehand ${ref['versao']} em ${(ref['casos'] as List).length} casos',
    () {
      var maxErro = 0.0;
      var pontos = 0;
      for (final c in (ref['casos'] as List).cast<Map<String, dynamic>>()) {
        final esperado = (c['saida'] as List).cast<List>();
        final obtido = contorno(entradas[c['entrada']]!, opcoes[c['opcoes']]!);
        expect(
          obtido.length,
          esperado.length,
          reason: '${c['entrada']}/${c['opcoes']}',
        );
        for (var i = 0; i < obtido.length; i++) {
          final e = (
            (esperado[i][0] as num).toDouble(),
            (esperado[i][1] as num).toDouble(),
          );
          maxErro = math.max(maxErro, (obtido[i].$1 - e.$1).abs());
          maxErro = math.max(maxErro, (obtido[i].$2 - e.$2).abs());
        }
        pontos += obtido.length;
      }
      print(
        'S4 suavização: $pontos pontos de contorno, erro máx ${maxErro.toStringAsExponential(2)}',
      );
      expect(maxErro, lessThan(1e-9));
    },
  );

  test('pontas: mais pressão = traço mais largo, menos na esferográfica', () {
    double larguraMedia(Ponta p, double pressao) {
      final e = [for (var i = 0; i < 60; i++) (i * 3.0, 0.0, pressao)];
      final c = contorno(
        e,
        p.opcoes.copyWith(
          tamanho: 1.2 * dpPorMm,
          simularPressao: false,
          completo: true,
        ),
      );
      final ys = c.map((v) => v.$2.abs());
      return 2 * ys.reduce(math.max);
    }

    final esfero =
        larguraMedia(Ponta.esferografica, 0.9) /
        larguraMedia(Ponta.esferografica, 0.2);
    final tinteiro =
        larguraMedia(Ponta.tinteiro, 0.9) / larguraMedia(Ponta.tinteiro, 0.2);
    final pincel =
        larguraMedia(Ponta.pincel, 0.9) / larguraMedia(Ponta.pincel, 0.2);
    print(
      'S4 razão largura pressão 0,9/0,2: esferográfica $esfero · tinteiro $tinteiro · pincel $pincel',
    );
    expect(esfero, lessThan(tinteiro));
    expect(tinteiro, lessThan(pincel));
    expect(dpPorMm, closeTo(6.2992, 1e-4));
  });
}

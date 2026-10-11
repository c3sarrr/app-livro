// G02 · S4 — custo do codec BNK1 e da suavização, em Dart AOT (como o app em release).
// Uso: dart compile exe bin/bench.dart -o build/bench.exe && build/bench.exe > dados/bench_host.json
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:spike_s4_tinta/bnk1.dart';
import 'package:spike_s4_tinta/simulador.dart';
import 'package:spike_s4_tinta/suavizacao.dart';

double _us(Stopwatch s, int n) => s.elapsedMicroseconds / n;

List<double> _pct(List<double> v) {
  final s = [...v]..sort();
  double p(double q) => s[((s.length - 1) * q).round()];
  return [p(0.5), p(0.95), s.last];
}

void main() {
  final saida = <String, Object>{
    'dart': Platform.version,
    'so': Platform.operatingSystemVersion,
    'cpus': Platform.numberOfProcessors,
  };

  // Codec: camada de 50 traços realistas a 120 Hz.
  final r = math.Random(7);
  final tracos = [
    for (var i = 0; i < 50; i++)
      tracoEmEm(tracoSintetico(r, FormaTraco.values[i % 3], 120)),
  ];
  final pontos = tracos.fold(0, (s, t) => s + t.pontos.length);
  late List<int> bytes;
  for (var i = 0; i < 50; i++) {
    bytes = codificarBnk1(tracos, UnidadeCamada.em); // aquecimento
    decodificarBnk1(codificarBnk1(tracos, UnidadeCamada.em), UnidadeCamada.em);
  }
  const rep = 200;
  final se = Stopwatch()..start();
  for (var i = 0; i < rep; i++) {
    bytes = codificarBnk1(tracos, UnidadeCamada.em);
  }
  se.stop();
  final dados = codificarBnk1(tracos, UnidadeCamada.em);
  final sd = Stopwatch()..start();
  for (var i = 0; i < rep; i++) {
    decodificarBnk1(dados, UnidadeCamada.em);
  }
  sd.stop();
  saida['codec'] = {
    'tracos': tracos.length,
    'pontos': pontos,
    'bytes': bytes.length,
    'codificar_us_por_100_pontos': _us(se, rep) * 100 / pontos,
    'decodificar_us_por_100_pontos': _us(sd, rep) * 100 / pontos,
  };

  // Suavização: contorno inteiro de um traço com N pontos (o que se recalcula a cada amostra).
  final porN = <String, Object>{};
  for (final n in [50, 200, 500, 1000, 2000]) {
    final rr = math.Random(n);
    var x = 0.0;
    var y = 0.0;
    var ang = 0.0;
    final e = [
      for (var i = 0; i < n; i++)
        (
          x += math.cos(ang += (rr.nextDouble() - 0.5) * 0.8) * 2.5,
          y += math.sin(ang) * 2.5,
          0.3 + 0.4 * rr.nextDouble(),
        ),
    ];
    for (final ponta in Ponta.values) {
      final o = ponta.opcoes.copyWith(
        tamanho: 1.2 * dpPorMm,
        simularPressao: false,
      );
      for (var i = 0; i < 20; i++) {
        contorno(e, o);
      }
      final reps = math.max(20, 20000 ~/ n);
      final s = Stopwatch()..start();
      for (var i = 0; i < reps; i++) {
        contorno(e, o);
      }
      s.stop();
      porN['$n/${ponta.name}'] = {
        'us_contorno': _us(s, reps),
        'us_por_ponto': _us(s, reps) / n,
      };
    }
  }
  saida['suavizacao_contorno_inteiro'] = porN;

  // Traço ao vivo: 2 s a 120 Hz (240 amostras) — recalcula o contorno inteiro a cada amostra.
  final vivo = <String, Object>{};
  for (final hz in [60, 120, 240]) {
    final amostras = tracoSintetico(
      math.Random(3),
      FormaTraco.manuscrito,
      hz.toDouble(),
    );
    while (amostras.length < 2 * hz) {
      final u = amostras.last;
      amostras.add(
        AmostraDp(
          u.x + 0.5,
          u.y + math.sin(amostras.length / 9) * 0.8,
          u.pressao,
          u.tMs + 1000 ~/ hz,
        ),
      );
    }
    final custos = <double>[];
    final o = Ponta.tinteiro.opcoes.copyWith(
      tamanho: 1.2 * dpPorMm,
      simularPressao: false,
    );
    for (var k = 0; k < 3; k++) {
      custos.clear();
      for (var i = 1; i <= amostras.length; i++) {
        final s = Stopwatch()..start();
        contorno([for (final a in amostras.take(i)) (a.x, a.y, a.pressao)], o);
        custos.add(s.elapsedMicroseconds.toDouble());
      }
    }
    final p = _pct(custos);
    vivo['$hz Hz'] = {
      'amostras': amostras.length,
      'us_p50': p[0],
      'us_p95': p[1],
      'us_max': p[2],
      'orcamento_quadro_us': 1e6 / hz,
    };
  }
  saida['traco_ao_vivo'] = vivo;
  stdout.writeln(const JsonEncoder.withIndent(' ').convert(saida));
}

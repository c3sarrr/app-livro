// G02 · S4 — custo de montar o Path do contorno e gravar o desenho (lado da UI, no host).
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:spike_s4_tinta/latencia_app.dart';
import 'package:spike_s4_tinta/suavizacao.dart';

void main() {
  test('Path + PictureRecorder do contorno (traço de 240 pontos)', () {
    final r = math.Random(9);
    var x = 0.0;
    var y = 0.0;
    var a = 0.0;
    final e = [
      for (var i = 0; i < 240; i++)
        (
          x += math.cos(a += (r.nextDouble() - 0.5) * 0.8) * 2.5,
          y += math.sin(a) * 2.5,
          null,
        ),
    ];
    final o = Ponta.esferografica.opcoes.copyWith(tamanho: 1.2 * dpPorMm);
    final c = contorno(e, o);
    for (var i = 0; i < 200; i++) {
      caminho(c);
    }
    const reps = 2000;
    final s = Stopwatch()..start();
    for (var i = 0; i < reps; i++) {
      final rec = ui.PictureRecorder();
      ui.Canvas(rec).drawPath(caminho(c), ui.Paint());
      rec.endRecording().dispose();
    }
    s.stop();
    final us = s.elapsedMicroseconds / reps;
    print(
      'S4 Path+gravação: ${c.length} vértices em ${us.toStringAsFixed(1)} µs (host, JIT)',
    );
    Directory('dados').createSync(recursive: true);
    File('dados/resultado_caminho.json').writeAsStringSync(
      jsonEncode({'vertices': c.length, 'us_por_quadro_host_jit': us}),
    );
    expect(us, lessThan(1000));
  });
}

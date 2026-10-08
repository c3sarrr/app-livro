// G16.7 — a latência do traço (Anexo 03 §9.3, o medidor do S4): do `timeStamp` do evento de ponteiro ao fim da
// rasterização do 1º quadro que começou depois dele; o medidor ligado ao modo anotação junta os eventos e os quadros
// e escreve o resumo acumulado ("G16LAT {...}") a cada lote de quadros que cobre eventos novos.
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show FrameTiming;

import 'package:app_leitura/features/reader/annotations/ink/ink_latency.dart';
import 'package:app_leitura/features/reader/presentation/ink_latency_meter.dart';
import 'package:flutter/scheduler.dart' show TimingsCallback;
import 'package:flutter_test/flutter_test.dart';

FrameTiming _quadro(int vsync, int fimDoRaster) => FrameTiming(
  vsyncStart: vsync,
  buildStart: vsync,
  buildFinish: vsync,
  rasterStart: vsync,
  rasterFinish: fimDoRaster,
  rasterFinishWallTime: fimDoRaster,
);

void main() {
  test(
    '120 Hz sintético: evento → raster do 1º quadro seguinte (o vetor do S4)',
    () {
      const periodo = 8333; // µs
      final r = math.Random(5);
      final quadros = [
        for (var k = 0; k < 600; k++)
          (vsyncUs: k * periodo, rasterEndUs: k * periodo + 5000),
      ];
      final eventos = [for (var k = 0; k < 2000; k++) r.nextInt(599 * periodo)];
      final res = inkLatency(eventos, quadros);
      // a espera até o vsync (0…8,3 ms) + 5 ms de build e raster → entre 5 e 13,3 ms
      expect(res.samples, 2000);
      expect(res.maxMs, lessThanOrEqualTo(13.34));
      expect(res.p50Ms, closeTo(9.2, 0.6));
      expect(res.meets(16.7), isTrue);
      expect(res.meets(8.3), isFalse);
    },
  );

  test('o evento no vsync entra nesse quadro; os depois do último quadro ficam de fora', () {
    final res = inkLatency(
      [10, 15, 20, 999999],
      const [(vsyncUs: 15, rasterEndUs: 30)],
    );
    expect(res.samples, 2);
    expect(res.withoutFrame, 2);
    // o p50 do S4: o índice arredondado de (n − 1) · 0,5
    expect((res.p50Ms, res.maxMs), (0.02, 0.02));
  });

  test(
    'p50, p95 e máximo pelo índice arredondado do S4: latências de 1 a 20 ms',
    () {
      final res = inkLatency(
        [for (var i = 0; i < 20; i++) i * 100000],
        [
          for (var i = 0; i < 20; i++)
            (vsyncUs: i * 100000, rasterEndUs: i * 100000 + (i + 1) * 1000),
        ],
      );
      expect(
        (res.samples, res.p50Ms, res.p95Ms, res.maxMs),
        (20, 11.0, 19.0, 20.0),
      );
    },
  );

  test('sem eventos com quadro: tudo zero', () {
    final res = inkLatency(const [5], const []);
    expect(
      (res.samples, res.p50Ms, res.p95Ms, res.maxMs, res.withoutFrame),
      (0, 0.0, 0.0, 0.0, 1),
    );
  });

  test('o medidor: escreve o resumo acumulado quando os quadros cobrem eventos novos; sai ao descartar', () {
    TimingsCallback? ouvinte;
    var removido = false;
    final linhas = <String>[];
    final m = InkLatencyMeter(
      addTimings: (c) => ouvinte = c,
      removeTimings: (c) => removido = identical(c, ouvinte),
      log: linhas.add,
      refreshRate: () => 60,
    )..start();
    m
      ..event(const Duration(microseconds: 1000))
      ..event(const Duration(microseconds: 9000));
    ouvinte!([_quadro(5000, 12000)]);
    ouvinte!([_quadro(13333, 20000)]);
    // o 2º lote não tem evento novo: nada a escrever
    ouvinte!([_quadro(30000, 31000)]);
    expect(linhas, hasLength(2));
    expect(linhas.first, startsWith('G16LAT '));
    final ultimo = jsonDecode(
      linhas.last.substring('G16LAT '.length),
    ) as Map<String, Object?>;
    expect(ultimo, {
      'tela_hz': 60,
      'amostras': 2,
      'p50_ms': 11.0,
      'p95_ms': 11.0,
      'max_ms': 11.0,
      'sem_quadro': 0,
      'meta_ms': 16.7,
    });
    m.dispose();
    expect(removido, isTrue);
  });

  test('a 120 Hz a meta é 8,3 ms; o medidor guarda no máximo [keep] eventos e quadros', () {
    TimingsCallback? ouvinte;
    final linhas = <String>[];
    final m = InkLatencyMeter(
      addTimings: (c) => ouvinte = c,
      removeTimings: (_) {},
      log: linhas.add,
      refreshRate: () => 120,
      keep: 2,
    )..start();
    for (final t in const [100, 200, 300]) {
      m.event(Duration(microseconds: t));
    }
    ouvinte!([_quadro(50, 60), _quadro(150, 160), _quadro(250, 260)]);
    final r = jsonDecode(
      linhas.single.substring('G16LAT '.length),
    ) as Map<String, Object?>;
    expect(r['meta_ms'], 8.3);
    // ficaram os eventos 200 e 300 e os quadros 150 e 250: o 300 fica sem quadro
    expect((r['amostras'], r['sem_quadro']), (1, 1));
    m.dispose();
  });

  test(
    'quadros cortados levam junto os eventos de antes do 1º quadro que ficou',
    () {
      TimingsCallback? ouvinte;
      final linhas = <String>[];
      final m = InkLatencyMeter(
        addTimings: (c) => ouvinte = c,
        removeTimings: (_) {},
        log: linhas.add,
        refreshRate: () => 60,
        keep: 2,
      )..start();
      m
        ..event(const Duration(microseconds: 100))
        ..event(const Duration(microseconds: 400));
      ouvinte!([_quadro(50, 60), _quadro(150, 160), _quadro(450, 460)]);
      final r = jsonDecode(
        linhas.single.substring('G16LAT '.length),
      ) as Map<String, Object?>;
      // o 100 era do quadro 150 ou de um anterior que saiu: fica de fora
      expect((r['amostras'], r['sem_quadro'], r['max_ms']), (1, 0, 0.06));
      expect(m.eventsUs, [400]);
      m.dispose();
    },
  );

  test('o medidor só liga com --dart-define=BOOKNEST_MEDIR_TINTA=true', () {
    expect(inkLatencyMeterOn, isFalse);
  });
}

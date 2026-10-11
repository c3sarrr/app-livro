// G16.7 — a latência do traço (Anexo 03 §9.3; o cálculo do S4): o tempo entre o `timeStamp` do evento de ponteiro e o
// fim da rasterização (`FramePhase.rasterFinish`) do 1º quadro que começou nele ou depois dele. Dart puro: os
// eventos e os quadros vêm do medidor do modo anotação (`ink_latency_meter.dart`) ou dos testes.

/// Um quadro: o início do vsync e o fim da rasterização, em µs, no relógio dos eventos.
typedef FrameTimes = ({int vsyncUs, int rasterEndUs});

/// O resumo: quantos eventos tiveram quadro, p50, p95 e o máximo (ms), e os que ficaram sem quadro (o fim da
/// medição).
final class InkLatency {
  const InkLatency({
    required this.samples,
    required this.p50Ms,
    required this.p95Ms,
    required this.maxMs,
    required this.withoutFrame,
  });

  final int samples;
  final double p50Ms;
  final double p95Ms;
  final double maxMs;
  final int withoutFrame;

  /// O p95 cabe no orçamento (16,7 ms a 60 Hz; 8,3 ms a 120 Hz — Anexo 03 §12).
  bool meets(double budgetMs) => p95Ms <= budgetMs;

  Map<String, Object> toJson() => {
    'amostras': samples,
    'p50_ms': p50Ms,
    'p95_ms': p95Ms,
    'max_ms': maxMs,
    'sem_quadro': withoutFrame,
  };
}

/// A latência de cada evento de [eventsUs] até o fim do raster do 1º quadro de [frames] com vsync ≥ o evento (a
/// aproximação conservadora do S4).
InkLatency inkLatency(List<int> eventsUs, List<FrameTimes> frames) {
  final fs = [...frames]..sort((a, b) => a.vsyncUs.compareTo(b.vsyncUs));
  final lat = <double>[];
  var without = 0;
  var j = 0;
  for (final e in [...eventsUs]..sort()) {
    while (j < fs.length && fs[j].vsyncUs < e) {
      j++;
    }
    if (j == fs.length) {
      without++;
      continue;
    }
    lat.add((fs[j].rasterEndUs - e) / 1000);
  }
  if (lat.isEmpty) {
    return InkLatency(
      samples: 0,
      p50Ms: 0,
      p95Ms: 0,
      maxMs: 0,
      withoutFrame: without,
    );
  }
  lat.sort();
  double p(double q) => lat[((lat.length - 1) * q).round()];
  return InkLatency(
    samples: lat.length,
    p50Ms: p(0.5),
    p95Ms: p(0.95),
    maxMs: lat.last,
    withoutFrame: without,
  );
}

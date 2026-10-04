// G02 · S4 — cálculo da latência do traço (Anexo 03 §9.3): tempo entre o `timeStamp` do evento de
// ponteiro e o fim da rasterização (`FramePhase.rasterFinish`) do 1º quadro que começou depois dele.
// Dart puro — os dados vêm do app de medição (`lib/latencia_app.dart`) ou de testes.
class QuadroMedido {
  const QuadroMedido(this.vsyncUs, this.rasterFimUs);
  final int vsyncUs;
  final int rasterFimUs;
}

class ResumoLatencia {
  const ResumoLatencia(
    this.amostras,
    this.p50Ms,
    this.p95Ms,
    this.maxMs,
    this.semQuadro,
  );
  final int amostras;
  final double p50Ms;
  final double p95Ms;
  final double maxMs;

  /// Eventos sem quadro posterior (o fim da medição) — ficam de fora.
  final int semQuadro;

  bool passa(double orcamentoMs) => p95Ms <= orcamentoMs;

  Map<String, Object> toJson() => {
    'amostras': amostras,
    'p50_ms': p50Ms,
    'p95_ms': p95Ms,
    'max_ms': maxMs,
    'sem_quadro': semQuadro,
  };
}

/// [eventosUs] e [quadros] no mesmo relógio monotônico (Android: CLOCK_MONOTONIC; iOS: uptime).
/// Aproximação conservadora: o evento entra no 1º quadro com vsync ≥ instante do evento.
ResumoLatencia calcularLatencia(
  List<int> eventosUs,
  List<QuadroMedido> quadros,
) {
  final qs = [...quadros]..sort((a, b) => a.vsyncUs.compareTo(b.vsyncUs));
  final lat = <double>[];
  var semQuadro = 0;
  var j = 0;
  for (final e in [...eventosUs]..sort()) {
    while (j < qs.length && qs[j].vsyncUs < e) {
      j++;
    }
    if (j == qs.length) {
      semQuadro++;
      continue;
    }
    lat.add((qs[j].rasterFimUs - e) / 1000);
  }
  if (lat.isEmpty) return ResumoLatencia(0, 0, 0, 0, semQuadro);
  lat.sort();
  double p(double q) => lat[((lat.length - 1) * q).round()];
  return ResumoLatencia(lat.length, p(0.5), p(0.95), lat.last, semQuadro);
}

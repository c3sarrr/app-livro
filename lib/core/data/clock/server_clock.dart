// Relógio do aparelho corrigido pela hora do servidor (ADR-003, pendência da G06): a RPC recusa
// versão (HLC) mais de 5 min à frente do relógio dela (`invalid_hlc`). A defasagem é medida em cada
// consulta do Pro (`my_entitlement` devolve a hora do servidor) e fica no `kv` para valer também
// offline. Pequenas diferenças (rede, segundos) são ignoradas.

/// Uma medida: a hora do servidor recebida entre [sentAtMs] e [receivedAtMs] (relógio do aparelho).
/// Devolve `servidor − aparelho` em ms, ou null se a ida e volta demorou demais para valer.
int? measureClockOffset({
  required int sentAtMs,
  required int receivedAtMs,
  required int serverTimeMs,
  int maxRoundTripMs = 10000,
}) {
  final ida = receivedAtMs - sentAtMs;
  if (ida < 0 || ida > maxRoundTripMs) return null;
  return serverTimeMs - (sentAtMs + ida ~/ 2);
}

final class ServerClock {
  ServerClock({this.offsetMs = 0, int Function()? deviceNowMs})
    : _device = deviceNowMs ?? _systemMs;

  /// Chave no `kv`.
  static const String offsetKey = 'relogio.defasagem_ms';

  /// Abaixo disto a defasagem é tratada como zero (latência da rede, arredondamentos).
  static const int ignoreBelowMs = 60 * 1000;

  /// O aparelho está tão adiantado que a RPC recusaria as versões (avisar a pessoa).
  static const int aheadWarningMs = 5 * 60 * 1000;

  static int _systemMs() => DateTime.now().millisecondsSinceEpoch;

  final int Function() _device;

  /// `servidor − aparelho` medido por último (ms).
  int offsetMs;

  /// Quanto o aparelho está ADIANTADO em relação ao servidor (0 se atrasado ou certo).
  int get deviceAheadMs => offsetMs < 0 ? -offsetMs : 0;

  /// Relógio para os HLC: o do aparelho, corrigido quando a diferença passa de [ignoreBelowMs].
  int nowMs() {
    final d = _device();
    return offsetMs.abs() < ignoreBelowMs ? d : d + offsetMs;
  }

  int deviceNowMs() => _device();
}

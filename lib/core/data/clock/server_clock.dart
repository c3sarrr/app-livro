// Relógio do aparelho corrigido pela hora do servidor (ADR-003, pendência da G06): a RPC recusa
// versão (HLC) mais de 5 min à frente do relógio dela (`invalid_hlc`). A hora do servidor chega em
// cada consulta do Pro (`my_entitlement`).
//
// Revisão da G06: com uma medida NESTA sessão, a hora vem de uma âncora MONOTÔNICA (hora do servidor na
// medida + tempo decorrido) — não depende do relógio de parede, que pode ser acertado depois. Sem
// medida (app aberto offline), só vale a correção para TRÁS guardada (aparelho adiantado): se o relógio
// já foi acertado, a versão fica no passado (aceita), nunca no futuro (recusada).

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
  ServerClock({
    this.offsetMs = 0,
    int Function()? deviceNowMs,
    int Function()? monotonicMs,
  }) : _device = deviceNowMs ?? _systemMs,
       _mono = monotonicMs ?? _monoMs;

  /// Chave no `kv`.
  static const String offsetKey = 'relogio.defasagem_ms';

  /// Abaixo disto a defasagem guardada é tratada como zero (latência da rede, arredondamentos).
  static const int ignoreBelowMs = 60 * 1000;

  /// O aparelho está tão adiantado que a RPC recusaria as versões (avisar a pessoa).
  static const int aheadWarningMs = 5 * 60 * 1000;

  static int _systemMs() => DateTime.now().millisecondsSinceEpoch;
  static final Stopwatch _stopwatch = Stopwatch()..start();
  static int _monoMs() => _stopwatch.elapsedMilliseconds;

  final int Function() _device;
  final int Function() _mono;

  /// `servidor − aparelho` medido por último (ms) — guardado no aparelho.
  int offsetMs;

  int? _anchorServerMs;
  int? _anchorMono;

  /// Quanto o aparelho está ADIANTADO em relação ao servidor (0 se atrasado ou certo).
  int get deviceAheadMs => offsetMs < 0 ? -offsetMs : 0;

  /// Houve uma medida nesta sessão (a hora corrigida não depende do relógio de parede).
  bool get measured => _anchorServerMs != null;

  /// Registra uma medida feita agora: [offset] = `servidor − aparelho`. Diferença pequena
  /// ([ignoreBelowMs]: latência da rede, arredondamentos) não corrige a hora — senão dois aparelhos
  /// certos ficariam desencontrados pelo ruído de cada medida —, mas a âncora vale do mesmo jeito.
  void record(int offset) {
    offsetMs = offset;
    _anchorServerMs = _device() + (offset.abs() < ignoreBelowMs ? 0 : offset);
    _anchorMono = _mono();
  }

  /// Relógio para os HLC.
  int nowMs() {
    final s = _anchorServerMs;
    if (s != null) return s + (_mono() - _anchorMono!);
    final d = _device();
    return offsetMs <= -ignoreBelowMs ? d + offsetMs : d;
  }

  int deviceNowMs() => _device();
}

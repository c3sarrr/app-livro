// Relógio lógico híbrido (Anexo 02 §3.4) — versão de cada linha pessoal (`version_hlc`) para o
// last-writer-wins da sincronização Pro.
//
// Texto ordenável byte a byte (é assim que a RPC compara, `COLLATE "C"`):
//   "<ms Unix com 16 dígitos>-<contador com 4 dígitos>-<id do aparelho>"
// Regras: `send()` = max(agora, último ms), contador +1 se o ms repetiu (e, no limite 9999, o ms
// avança 1); `receive(remoto)` = avança para o maior. Regra do ADR-003: toda escrita faz `receive` da
// versão que leu antes do `send` (`sendAfterReading`) — senão um aparelho com o relógio atrasado perde
// edições sem conflito nenhum.
import 'package:flutter/foundation.dart' show immutable;

@immutable
final class Hlc implements Comparable<Hlc> {
  Hlc(this.ms, this.counter, this.deviceId) {
    if (ms < 0 || ms > maxMs) {
      throw ArgumentError.value(ms, 'ms', 'fora de 0…$maxMs');
    }
    if (counter < 0 || counter > maxCounter) {
      throw ArgumentError.value(counter, 'counter', 'fora de 0…$maxCounter');
    }
    if (!deviceIdPattern.hasMatch(deviceId)) {
      throw ArgumentError.value(
        deviceId,
        'deviceId',
        'só [A-Za-z0-9_-], 1 a 64',
      );
    }
  }

  factory Hlc.parse(String text) {
    final m = _textPattern.firstMatch(text);
    if (m == null) throw FormatException('HLC inválido', text);
    return Hlc(int.parse(m[1]!), int.parse(m[2]!), m[3]!);
  }

  static Hlc? tryParse(String text) {
    final m = _textPattern.firstMatch(text);
    return m == null ? null : Hlc(int.parse(m[1]!), int.parse(m[2]!), m[3]!);
  }

  static const int maxMs = 9999999999999999;
  static const int maxCounter = 9999;

  /// Mesmo conjunto aceito pela RPC `sync_apply_changes`.
  static final RegExp deviceIdPattern = RegExp(r'^[A-Za-z0-9_-]{1,64}$');
  static final RegExp _textPattern = RegExp(
    r'^([0-9]{16})-([0-9]{4})-([A-Za-z0-9_-]{1,64})$',
  );

  final int ms;
  final int counter;
  final String deviceId;

  @override
  int compareTo(Hlc other) {
    final porMs = ms.compareTo(other.ms);
    if (porMs != 0) return porMs;
    final porContador = counter.compareTo(other.counter);
    if (porContador != 0) return porContador;
    return deviceId.compareTo(other.deviceId);
  }

  bool operator <(Hlc other) => compareTo(other) < 0;
  bool operator >(Hlc other) => compareTo(other) > 0;
  bool operator <=(Hlc other) => compareTo(other) <= 0;
  bool operator >=(Hlc other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.ms == ms &&
      other.counter == counter &&
      other.deviceId == deviceId;

  @override
  int get hashCode => Object.hash(ms, counter, deviceId);

  @override
  String toString() =>
      '${ms.toString().padLeft(16, '0')}-${counter.toString().padLeft(4, '0')}-$deviceId';
}

/// Relógio do aparelho. Guardar `last` no `kv` (via `onAdvance`) e repassar na abertura do app.
final class HlcClock {
  HlcClock({
    required this.deviceId,
    int Function()? nowMs,
    Hlc? last,
    this.onAdvance,
    this.maxDriftMs,
  }) : _nowMs = nowMs ?? _systemMs,
       _last = last,
       _ms = last?.ms ?? 0,
       _counter = last?.counter ?? 0 {
    if (!Hlc.deviceIdPattern.hasMatch(deviceId)) {
      throw ArgumentError.value(
        deviceId,
        'deviceId',
        'só [A-Za-z0-9_-], 1 a 64',
      );
    }
  }

  static int _systemMs() => DateTime.now().millisecondsSinceEpoch;

  final String deviceId;
  final void Function(Hlc)? onAdvance;

  /// Versão lida mais que isto à frente do relógio NÃO puxa o relógio do aparelho (G06): ela veio de
  /// um período com o relógio errado e levaria todas as escritas seguintes para o futuro (a RPC
  /// recusa tudo). A versão nova daquela LINHA continua maior que a dela. Null = sem limite.
  final int? maxDriftMs;
  final int Function() _nowMs;
  Hlc? _last;
  int _ms;
  int _counter;

  /// Último HLC emitido ou recebido (o que deve ser persistido).
  Hlc? get last => _last;

  /// Nova versão para uma escrita local.
  Hlc send() {
    final now = _nowMs();
    if (now > _ms) {
      _ms = now;
      _counter = 0;
    } else if (_counter < Hlc.maxCounter) {
      _counter++;
    } else {
      _ms++;
      _counter = 0;
    }
    return _advance(Hlc(_ms, _counter, deviceId));
  }

  /// Avança para uma versão vinda de outro aparelho (ou lida do banco), se for maior.
  void receive(Hlc remote) {
    if (remote.ms > _ms || (remote.ms == _ms && remote.counter > _counter)) {
      _ms = remote.ms;
      _counter = remote.counter;
      _advance(remote);
    }
  }

  /// Regra do ADR-003: `receive` de cada versão lida (nulas ignoradas) e depois `send`.
  Hlc sendAfterReading(Iterable<String?> versions) {
    final now = _nowMs();
    final drift = maxDriftMs;
    Hlc? far;
    for (final v in versions) {
      if (v == null) continue;
      final h = Hlc.parse(v);
      if (drift != null && h.ms > now + drift) {
        if (far == null || h.compareTo(far) > 0) far = h;
      } else {
        receive(h);
      }
    }
    final s = send();
    if (far == null || s.compareTo(far) > 0) return s;
    // acima da versão da linha, sem mexer no relógio do aparelho
    return far.counter < Hlc.maxCounter
        ? Hlc(far.ms, far.counter + 1, deviceId)
        : Hlc(far.ms + 1, 0, deviceId);
  }

  Hlc _advance(Hlc h) {
    _last = h;
    onAdvance?.call(h);
    return h;
  }
}

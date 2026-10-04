// IDs gerados no aparelho (Anexo 02 §1.6 e §3.4): UUIDv7, ordenáveis pelo tempo e sem colisão entre
// aparelhos — permitem criar offline e sincronizar depois.
// Layout: RFC 9562 §5.7. Ordem dentro do mesmo milissegundo: §6.2, método 1 (contador de 12 bits no
// `rand_a`, começando num valor aleatório da metade de baixo; se estourar, o instante avança 1 ms).
import 'dart:math';

/// Gera UUIDv7 em ordem estritamente crescente neste aparelho, mesmo se o relógio voltar.
final class UuidV7Generator {
  UuidV7Generator({int Function()? clockMs, Random? random})
    : _clockMs = clockMs ?? _systemMs,
      _random = random ?? Random.secure();

  static int _systemMs() => DateTime.now().millisecondsSinceEpoch;

  static const int _maxCounter = 0xFFF;
  static const int _counterSeedRange = 0x800;
  static const int _maxMs = 0xFFFFFFFFFFFF;

  final int Function() _clockMs;
  final Random _random;
  int _lastMs = -1;
  int _counter = 0;

  String next() {
    final now = _clockMs();
    if (now > _lastMs) {
      _lastMs = now;
      _counter = _random.nextInt(_counterSeedRange);
    } else if (_counter < _maxCounter) {
      _counter++;
    } else {
      _lastMs++;
      _counter = _random.nextInt(_counterSeedRange);
    }
    if (_lastMs < 0 || _lastMs > _maxMs) {
      throw StateError('instante fora do intervalo do UUIDv7: $_lastMs');
    }
    final ts = _lastMs.toRadixString(16).padLeft(12, '0');
    final variantAndRandB = 0x8000 | _random.nextInt(0x4000);
    final randB = [
      for (var i = 0; i < 3; i++)
        _random.nextInt(0x10000).toRadixString(16).padLeft(4, '0'),
    ].join();
    return '${ts.substring(0, 8)}-${ts.substring(8)}-'
        '${(0x7000 | _counter).toRadixString(16)}-'
        '${variantAndRandB.toRadixString(16)}-$randB';
  }
}

/// Leitura e validação de UUIDv7 em texto (minúsculo, com hífens — o formato do Postgres).
abstract final class UuidV7 {
  static final RegExp pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );

  static bool isValid(String id) => pattern.hasMatch(id);

  /// Instante (ms desde a época Unix) gravado nos 48 bits iniciais.
  static int timestampMs(String id) {
    if (!isValid(id)) throw FormatException('UUIDv7 inválido', id);
    return int.parse(id.substring(0, 8) + id.substring(9, 13), radix: 16);
  }
}

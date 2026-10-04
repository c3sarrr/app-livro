// Validações das entidades = os mesmos CHECKs do SQL (`personal.*`, handoff_v2/sql §4): uma
// entidade inválida nunca chega ao banco local nem à fila de sincronização.

/// Enum com o código gravado no banco (o texto dos CHECKs do SQL).
abstract interface class DbCode {
  String get code;
}

abstract final class Check {
  static final RegExp _hexColor = RegExp(r'^#[0-9A-F]{6}$');
  static final RegExp _sha256 = RegExp(r'^[0-9a-f]{64}$');
  static final RegExp _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  static DateTime utc(DateTime value, String name) {
    if (!value.isUtc) throw ArgumentError.value(value, name, 'precisa ser UTC');
    return value;
  }

  static DateTime? utcOrNull(DateTime? value, String name) =>
      value == null ? null : utc(value, name);

  static int range(int value, int min, int max, String name) {
    if (value < min || value > max) {
      throw ArgumentError.value(value, name, 'fora de $min…$max');
    }
    return value;
  }

  static int? rangeOrNull(int? value, int min, int max, String name) =>
      value == null ? null : range(value, min, max, name);

  /// Comprimento em caracteres (code points), como o `char_length` do Postgres.
  static String text(
    String value, {
    int min = 0,
    required int max,
    required String name,
  }) {
    final n = value.runes.length;
    if (n < min || n > max) {
      throw ArgumentError.value(value, name, 'comprimento fora de $min…$max');
    }
    return value;
  }

  static String? textOrNull(
    String? value, {
    int min = 0,
    required int max,
    required String name,
  }) => value == null ? null : text(value, min: min, max: max, name: name);

  static String hexColor(String value, String name) {
    if (!_hexColor.hasMatch(value)) {
      throw ArgumentError.value(value, name, 'cor precisa ser #RRGGBB');
    }
    return value;
  }

  static String? hexColorOrNull(String? value, String name) =>
      value == null ? null : hexColor(value, name);

  static String? sha256OrNull(String? value, String name) {
    if (value != null && !_sha256.hasMatch(value)) {
      throw ArgumentError.value(value, name, 'sha256 em hexadecimal minúsculo');
    }
    return value;
  }

  static String uuid(String value, String name) {
    if (!_uuid.hasMatch(value)) {
      throw ArgumentError.value(value, name, 'UUID em minúsculas');
    }
    return value;
  }

  static String? uuidOrNull(String? value, String name) =>
      value == null ? null : uuid(value, name);

  /// Valor do enum pelo código do banco; código desconhecido = dado corrompido.
  static T byCode<T extends DbCode>(List<T> values, String code) {
    for (final v in values) {
      if (v.code == code) return v;
    }
    throw FormatException('código desconhecido para $T', code);
  }
}

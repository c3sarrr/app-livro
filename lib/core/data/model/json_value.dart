// Igualdade e hash profundos para valores JSON decodificados (jsonb guardado como TEXT): o
// Postgres devolve o JSON reformatado, então a comparação é sempre do valor, nunca do texto.

bool jsonEquals(Object? a, Object? b) {
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || !jsonEquals(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!jsonEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

int jsonHash(Object? v) {
  if (v is Map) {
    // independente da ordem das chaves
    var h = 0;
    for (final e in v.entries) {
      h ^= Object.hash(e.key, jsonHash(e.value));
    }
    return h;
  }
  if (v is List) return Object.hashAll(v.map(jsonHash));
  if (v is num) return v.toDouble().hashCode; // 1 == 1.0 no Dart
  return v.hashCode;
}

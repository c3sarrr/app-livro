import 'package:flutter/foundation.dart' show immutable;

/// Valor explícito para campos anuláveis no `copyWith` das entidades:
/// `Nullable(x)` grava `x` (inclusive `null`, para limpar); omitir o parâmetro mantém o valor atual.
@immutable
final class Nullable<T> {
  const Nullable(this.value);

  final T? value;
}

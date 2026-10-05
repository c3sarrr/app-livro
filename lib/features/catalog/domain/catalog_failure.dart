// Falhas do catálogo (erros tipados — §4.5).
import 'package:flutter/foundation.dart' show immutable;

@immutable
sealed class CatalogFailure implements Exception {
  const CatalogFailure(this.code);

  /// Código curto, sem conteúdo (telemetria e testes).
  final String code;

  @override
  String toString() => 'CatalogFailure($code)';
}

/// Sem rede, tempo esgotado ou 5xx: tentar de novo depois.
final class CatalogOffline extends CatalogFailure {
  const CatalogOffline([super.code = 'rede']);
}

/// Limite de consultas (por IP no Worker, ou a cota diária da `isbn-lookup`).
final class CatalogQuotaExceeded extends CatalogFailure {
  const CatalogQuotaExceeded() : super('cota');
}

/// A consulta externa e a comunidade exigem conta.
final class CatalogNeedsAccount extends CatalogFailure {
  const CatalogNeedsAccount() : super('sem_conta');
}

/// Contribuir com a comunidade exige a faixa etária registrada (D-72/D-74).
final class CatalogNeedsAge extends CatalogFailure {
  const CatalogNeedsAge() : super('faixa');
}

/// Arquivo baixado com hash diferente do manifesto, banco ilegível etc.
final class CatalogCorrupted extends CatalogFailure {
  const CatalogCorrupted(super.code);
}

final class CatalogUnexpected extends CatalogFailure {
  const CatalogUnexpected(super.code);
}

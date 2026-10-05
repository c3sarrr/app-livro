// Estados da tela do scanner (D-76; textos em docs/design/estados_sem_design.md, seção G07).
import 'package:flutter/foundation.dart' show immutable;

import '../../catalog/domain/catalog_book.dart';
import '../../catalog/domain/catalog_failure.dart';
import '../../catalog/domain/community.dart';
import '../../library/domain/user_book.dart';

@immutable
sealed class ScanState {
  const ScanState();
}

/// Câmera ligada, esperando um código. [notABook]: o último código lido não é de livro.
final class ScanAiming extends ScanState {
  const ScanAiming({this.notABook = false});
  final bool notABook;
}

final class ScanLooking extends ScanState {
  const ScanLooking(this.isbn13);
  final String isbn13;
}

/// Achou o livro em alguma camada do catálogo.
final class ScanFound extends ScanState {
  const ScanFound(this.book, this.layer);
  final CatalogBook book;
  final CatalogLayer layer;
}

/// O ISBN já está numa linha ativa da estante (D-77) — nada vai para a rede.
final class ScanOnShelf extends ScanState {
  const ScanOnShelf(this.book);
  final UserBook book;
}

/// Ninguém achou: a pessoa pode digitar os dados (e, com um toque, enviar à comunidade) ou
/// confirmar uma sugestão pendente.
final class ScanNotFound extends ScanState {
  const ScanNotFound(this.isbn13, {this.suggestions = const []});
  final String isbn13;
  final List<CommunitySuggestion> suggestions;
}

/// Sem rede, limite do dia etc. — "Tentar de novo".
final class ScanFailed extends ScanState {
  const ScanFailed(this.isbn13, this.failure);
  final String isbn13;
  final CatalogFailure failure;
}

/// Entrou na estante. [contribution]: o que a comunidade respondeu (se a pessoa enviou);
/// [contributionFailure]: o envio não deu certo (o livro continua na estante).
final class ScanAdded extends ScanState {
  const ScanAdded(this.book, {this.contribution, this.contributionFailure});
  final UserBook book;
  final CommunityContribution? contribution;
  final CatalogFailure? contributionFailure;
}

/// Mensagem curta de cada falha do catálogo (D-21).
String catalogFailureMessage(CatalogFailure f) => switch (f) {
  CatalogOffline() => 'Sem conexão. Tente de novo quando a internet voltar.',
  CatalogQuotaExceeded() => 'Limite de consultas de hoje atingido. Tente amanhã ou digite os dados do livro.',
  CatalogNeedsAccount() => 'Entre na sua conta para usar esta opção.',
  CatalogNeedsAge() =>
    'Confirme sua idade no Perfil para contribuir com o catálogo.',
  CatalogCorrupted() ||
  CatalogUnexpected() => 'Algo deu errado. Tente de novo.',
};

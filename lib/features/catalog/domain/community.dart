// Camada da comunidade (D-74): livros aprovados e sugestões pendentes de um ISBN, e o resultado de
// "adicionar este livro" / confirmar uma sugestão.
import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'catalog_book.dart';

/// Sugestão pendente de outra pessoa (ou da própria) — sem dizer quem enviou.
@immutable
final class CommunitySuggestion {
  const CommunitySuggestion({
    required this.id,
    required this.title,
    required this.authors,
    this.publisher,
    required this.confirmations,
    required this.mine,
    required this.confirmedByMe,
  });

  factory CommunitySuggestion.fromJson(Map<String, Object?> j) =>
      CommunitySuggestion(
        id: j['id']! as String,
        title: j['title']! as String,
        authors: j['authors']! as String,
        publisher: j['publisher'] as String?,
        confirmations: (j['confirmations'] as num?)?.toInt() ?? 0,
        mine: j['mine'] == true,
        confirmedByMe: j['confirmed_by_me'] == true,
      );

  final String id;
  final String title;

  /// Como a pessoa digitou ("Ana; Bia").
  final String authors;
  final String? publisher;
  final int confirmations;

  /// Enviada por esta conta (não pode confirmar a própria).
  final bool mine;
  final bool confirmedByMe;

  /// Pode tocar em "Confirmar".
  bool get canConfirm => !mine && !confirmedByMe;

  @override
  bool operator ==(Object other) =>
      other is CommunitySuggestion &&
      other.id == id &&
      other.title == title &&
      other.authors == authors &&
      other.publisher == publisher &&
      other.confirmations == confirmations &&
      other.mine == mine &&
      other.confirmedByMe == confirmedByMe;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    authors,
    publisher,
    confirmations,
    mine,
    confirmedByMe,
  );
}

/// Resposta da comunidade para um ISBN.
@immutable
final class CommunityLookup {
  const CommunityLookup({this.book, this.pending = const []});

  /// Edição no catálogo compartilhado do servidor (aprovada pela comunidade ou referenciada).
  final CatalogBook? book;
  final List<CommunitySuggestion> pending;

  @override
  bool operator ==(Object other) =>
      other is CommunityLookup &&
      other.book == book &&
      listEquals(other.pending, pending);

  @override
  int get hashCode => Object.hash(book, Object.hashAll(pending));
}

/// Resultado de enviar ou confirmar.
@immutable
sealed class CommunityContribution {
  const CommunityContribution();
}

/// Ficou pendente (esperando 2 confirmações de outras pessoas).
final class ContributionPending extends CommunityContribution {
  const ContributionPending(this.submissionId);
  final String submissionId;
}

/// Contou como confirmação de uma sugestão (ainda pendente).
final class ContributionConfirmed extends CommunityContribution {
  const ContributionConfirmed(this.submissionId);
  final String submissionId;
}

/// Com esta confirmação o livro entrou no catálogo compartilhado.
final class ContributionApproved extends CommunityContribution {
  const ContributionApproved(this.book);
  final CatalogBook book;
}

/// O ISBN já estava no catálogo.
final class ContributionAlreadyInCatalog extends CommunityContribution {
  const ContributionAlreadyInCatalog(this.book);
  final CatalogBook? book;
}

// Fontes de duas seções da Início que não vêm só do banco local: "Para você" (catálogo do aparelho —
// D-81) e o ticket do Clube (social — D-80, ligado ao Supabase na G21).
import 'package:flutter/foundation.dart' show immutable, listEquals, setEquals;

import '../domain/models.dart';

/// O que a estante diz para "Para você": autores em ordem de preferência e o que já está nela.
@immutable
final class ForYouRequest {
  const ForYouRequest({
    required this.authors,
    required this.shelfIsbns,
    required this.shelfTitles,
  });

  /// Autores da estante: mais livros primeiro; empate → o adicionado mais recentemente.
  final List<String> authors;

  /// ISBN-13 dos livros da estante (não são sugeridos de novo).
  final Set<String> shelfIsbns;

  /// Títulos da estante, como gravados (a fonte normaliza para comparar).
  final Set<String> shelfTitles;

  @override
  bool operator ==(Object other) =>
      other is ForYouRequest &&
      listEquals(other.authors, authors) &&
      setEquals(other.shelfIsbns, shelfIsbns) &&
      setEquals(other.shelfTitles, shelfTitles);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(authors),
    Object.hashAllUnordered(shelfIsbns),
    Object.hashAllUnordered(shelfTitles),
  );
}

/// Sugestões a partir dos autores da estante; `null` = a seção some (D-81).
abstract interface class ForYouSource {
  Future<ForYou?> suggest(ForYouRequest request);
}

/// O clube do ticket da Início para o dono ativo; `null` = o ticket some (D-80).
abstract interface class ClubTicketSource {
  Future<BookClub?> current(String owner);
}

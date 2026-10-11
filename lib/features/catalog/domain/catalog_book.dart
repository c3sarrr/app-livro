// Um livro do catálogo (não é um livro da estante): o que se sabe de uma edição pelo ISBN.
import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'community.dart';

/// De qual camada a resposta veio (Anexo 02 §7) — ordem de consulta.
enum CatalogLayer {
  /// Já visto neste aparelho (`catalog_cache`).
  device,

  /// `catalog.db` baixado.
  localCatalog,

  /// Worker + shards dos dumps abertos.
  edge,

  /// Catálogo da comunidade (aprovado).
  community,

  /// APIs externas pela Edge Function `isbn-lookup` (com cota).
  external,
}

/// Fontes cujos dados podem ir para o catálogo compartilhado (LICENCAS.md do pipeline).
const Set<String> shareableSources = {'openlibrary', 'dnb', 'community'};

@immutable
final class CatalogBook {
  const CatalogBook({
    required this.isbn13,
    required this.title,
    this.subtitle,
    this.authors = const [],
    this.publisher,
    this.year,
    this.pages,
    this.language,
    this.coverRef,
    required this.source,
    this.license,
  });

  /// JSON da API do Worker / colunas do `catalog.db` / payload do `catalog_cache`.
  factory CatalogBook.fromJson(Map<String, Object?> j) => CatalogBook(
    isbn13: j['isbn13']! as String,
    title: j['title']! as String,
    subtitle: j['subtitle'] as String?,
    authors: [
      for (final a in (j['authors'] as List<Object?>?) ?? const [])
        if (a is String && a.isNotEmpty) a,
    ],
    publisher: j['publisher'] as String?,
    year: (j['year'] as num?)?.toInt(),
    pages: (j['pages'] as num?)?.toInt(),
    language: j['language'] as String?,
    coverRef: (j['cover_ref'] ?? j['cover_url']) as String?,
    source: j['source']! as String,
    license: (j['source_license'] ?? j['license']) as String?,
  );

  final String isbn13;
  final String title;
  final String? subtitle;
  final List<String> authors;
  final String? publisher;
  final int? year;
  final int? pages;

  /// ISO 639-2/B (por, eng, ger…).
  final String? language;

  /// Id da capa na fonte (`ol:123`) ou URL da API externa (só para mostrar).
  final String? coverRef;
  final String source;
  final String? license;

  /// O dado pode ir para o catálogo compartilhado (CBL, Google, ISBNdb… não — D-73).
  bool get shareable => shareableSources.contains(source);

  /// "Machado de Assis" / "Ana · Bia" — o `author_display` da estante.
  String get authorDisplay => authors.isEmpty ? '' : authors.join(' · ');

  Map<String, Object?> toJson() => {
    'isbn13': isbn13,
    'title': title,
    'subtitle': subtitle,
    'authors': authors,
    'publisher': publisher,
    'year': year,
    'pages': pages,
    'language': language,
    'cover_ref': coverRef,
    'source': source,
    'source_license': license,
  };

  @override
  bool operator ==(Object other) =>
      other is CatalogBook &&
      other.isbn13 == isbn13 &&
      other.title == title &&
      other.subtitle == subtitle &&
      listEquals(other.authors, authors) &&
      other.publisher == publisher &&
      other.year == year &&
      other.pages == pages &&
      other.language == language &&
      other.coverRef == coverRef &&
      other.source == source &&
      other.license == license;

  @override
  int get hashCode => Object.hash(
    isbn13,
    title,
    subtitle,
    Object.hashAll(authors),
    publisher,
    year,
    pages,
    language,
    coverRef,
    source,
    license,
  );

  @override
  String toString() => 'CatalogBook($isbn13, $title, $source)';
}

/// Resultado da resolução de um ISBN.
@immutable
sealed class IsbnResolution {
  const IsbnResolution(this.isbn13);
  final String isbn13;
}

final class IsbnFound extends IsbnResolution {
  IsbnFound(this.book, this.layer) : super(book.isbn13);
  final CatalogBook book;
  final CatalogLayer layer;
}

/// Nenhuma camada achou. [externalTried] = a consulta externa (com cota) foi feita.
/// [suggestions]: sugestões pendentes da comunidade para o ISBN (a pessoa pode confirmar uma).
final class IsbnNotFound extends IsbnResolution {
  const IsbnNotFound(
    super.isbn13, {
    required this.externalTried,
    this.suggestions = const [],
  });
  final bool externalTried;
  final List<CommunitySuggestion> suggestions;
}

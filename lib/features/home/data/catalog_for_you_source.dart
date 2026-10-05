// "Para você" calculado no aparelho (G08, D-81): o autor da estante → o `catalog.db` baixado (G07). Uma edição
// por título, nada que já esteja na estante; até 3 autores tentados; sem catálogo ou sem sugestão → `null`
// (a seção some). Nada sai do aparelho.
import '../../catalog/data/local_catalog.dart';
import '../../catalog/domain/catalog_book.dart';
import '../domain/models.dart';
import 'home_sources.dart';

/// Língua do aparelho (ISO 639-1) → código do catálogo (ISO 639-2/B); fora da lista → sem preferência.
String? catalogLanguageOf(String languageCode) => const {
  'pt': 'por',
  'en': 'eng',
  'es': 'spa',
  'de': 'ger',
  'fr': 'fre',
  'it': 'ita',
}[languageCode.toLowerCase()];

/// Minúsculas, sem acento e sem pontuação, espaços colapsados — para comparar títulos e nomes.
String foldText(String s) {
  final out = StringBuffer();
  for (final r in s.toLowerCase().runes) {
    final c = String.fromCharCode(r);
    out.write(_fold[c] ?? c);
  }
  return out
      .toString()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim();
}

const Map<String, String> _fold = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a', //
  'ç': 'c', 'č': 'c', 'ć': 'c',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ę': 'e', 'ě': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i',
  'ñ': 'n', 'ń': 'n', 'ň': 'n',
  'ò': 'o',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ö': 'o',
  'ø': 'o',
  'ō': 'o',
  'ő': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u', 'ů': 'u', 'ű': 'u',
  'ý': 'y', 'ÿ': 'y',
  'ß': 'ss', 'æ': 'ae', 'œ': 'oe',
  'š': 's', 'ś': 's', 'ž': 'z', 'ź': 'z', 'ż': 'z', 'ł': 'l', 'ř': 'r',
};

final class CatalogForYouSource implements ForYouSource {
  CatalogForYouSource(
    this._catalog, {
    required this.language,
    this.maxItems = 10,
    this.maxAuthors = 3,
  });

  /// O catálogo do aparelho; `null` = ainda não baixou.
  final Future<LocalCatalog?> Function() _catalog;

  /// Língua preferida (ISO 639-2/B); `null` = sem preferência.
  final String? language;
  final int maxItems;
  final int maxAuthors;

  ({String? version, ForYouRequest request})? _key;
  ForYou? _value;

  @override
  Future<ForYou?> suggest(ForYouRequest request) async {
    final catalog = await _catalog();
    if (catalog == null || request.authors.isEmpty) return null;
    final key = (version: await catalog.version(), request: request);
    if (key == _key) return _value;

    final titles = {for (final t in request.shelfTitles) foldText(t)};
    ForYou? result;
    for (final author in request.authors.take(maxAuthors)) {
      final items = _pick(
        await catalog.byAuthor(author, language: language),
        author,
        request.shelfIsbns,
        titles,
      );
      if (items.isNotEmpty) {
        result = ForYou(reasonAuthor: author, items: List.unmodifiable(items));
        break;
      }
    }
    _key = key;
    return _value = result;
  }

  List<Book> _pick(
    List<CatalogBook> editions,
    String author,
    Set<String> shelfIsbns,
    Set<String> shelfTitles,
  ) {
    final name = foldText(author);
    final best = <String, CatalogBook>{};
    for (final e in editions) {
      if (shelfIsbns.contains(e.isbn13)) continue;
      if (!e.authors.any((a) => foldText(a) == name)) continue;
      final t = foldText(e.title);
      if (t.isEmpty || shelfTitles.contains(t)) continue;
      final cur = best[t];
      if (cur == null || _compare(e, cur) < 0) best[t] = e;
    }
    final chosen = best.values.toList()..sort(_compare);
    return [
      for (final e in chosen.take(maxItems))
        Book(
          id: e.isbn13,
          title: e.title,
          author: e.authorDisplay,
          cover: PhotoCover(ref: e.coverRef, isbn13: e.isbn13),
        ),
    ];
  }

  /// Língua do aparelho, depois com capa, depois a mais nova; empate → ISBN (determinístico).
  int _compare(CatalogBook a, CatalogBook b) {
    int rank(bool x) => x ? 0 : 1;
    final l = language;
    var c = l == null
        ? 0
        : rank(a.language == l).compareTo(rank(b.language == l));
    if (c != 0) return c;
    c = rank(a.coverRef != null).compareTo(rank(b.coverRef != null));
    if (c != 0) return c;
    c = (b.year ?? -1).compareTo(a.year ?? -1);
    return c != 0 ? c : a.isbn13.compareTo(b.isbn13);
  }
}

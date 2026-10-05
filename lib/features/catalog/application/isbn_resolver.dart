// Resolução do ISBN em camadas (Anexo 02 §7, ADR-008, D-73):
//   aparelho (já visto) → catalog.db → borda (Worker) → comunidade → APIs externas (com cota).
// Pára na primeira que achar e guarda no aparelho. O "não achou" fica guardado 7 dias (não gasta a
// cota de novo). Grátis: o pedido de rede leva só o ISBN (§4.3.7).
import '../data/catalog_cache_dao.dart';
import '../data/edge_catalog_api.dart';
import '../data/external_isbn_api.dart';
import '../data/local_catalog.dart';
import '../domain/catalog_book.dart';
import '../domain/catalog_failure.dart';
import '../domain/community.dart';

/// Catálogo da comunidade no servidor (G07.4): a edição aprovada e as sugestões pendentes.
abstract interface class CommunityCatalogLookup {
  Future<CommunityLookup> lookup(String isbn13);
}

final class IsbnResolver {
  IsbnResolver({
    required this.cache,
    required this.localCatalog,
    this.edge,
    this.community,
    this.external,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final CatalogCacheDao cache;

  /// O `catalog.db` aberto agora (null = ainda não baixado).
  final Future<LocalCatalog?> Function() localCatalog;
  final EdgeCatalogApi? edge;

  /// Null = sem conta (a comunidade e a consulta externa exigem login).
  final CommunityCatalogLookup? community;
  final ExternalIsbnApi? external;
  final DateTime Function() _now;

  /// Quanto tempo um "não achou" vale antes de consultar de novo.
  static const Duration missValidity = Duration(days: 7);

  Future<IsbnResolution> resolve(
    String isbn13, {
    bool allowExternal = true,
  }) async {
    final now = _now().toUtc();
    final cached = await cache.byIsbn(isbn13);
    if (cached is CachedBook) {
      return IsbnFound(cached.book, CatalogLayer.device);
    }
    final recentMiss =
        cached is CachedMiss && now.difference(cached.fetchedAt) < missValidity
        ? cached
        : null;

    final local = await localCatalog();
    final fromLocal = local == null ? null : await local.byIsbn(isbn13);
    if (fromLocal != null) {
      return _found(fromLocal, CatalogLayer.localCatalog, now);
    }

    CatalogFailure? failure;
    Future<T?> attempt<T>(Future<T?> Function() f) async {
      try {
        return await f();
      } on CatalogNeedsAccount {
        return null;
      } on CatalogFailure catch (e) {
        failure ??= e;
        return null;
      }
    }

    // a borda e a comunidade são grátis para o servidor: sempre consultadas (o catálogo cresce)
    final e = edge;
    if (e != null) {
      final b = await attempt(() => e.byIsbn(isbn13));
      if (b != null) return _found(b, CatalogLayer.edge, now);
    }
    final c = community;
    var suggestions = const <CommunitySuggestion>[];
    if (c != null) {
      final r = await attempt(() => c.lookup(isbn13));
      final b = r?.book;
      if (b != null) return _found(b, CatalogLayer.community, now);
      suggestions = r?.pending ?? const [];
    }
    final x = external;
    var externalTried = recentMiss?.externalTried ?? false;
    var missAt = recentMiss?.fetchedAt ?? now;
    if (x != null && allowExternal && !(recentMiss?.externalTried ?? false)) {
      final b = await attempt(() => x.byIsbn(isbn13));
      if (b != null) return _found(b, CatalogLayer.external, now);
      if (failure == null) {
        externalTried = true;
        missAt = now; // a contagem dos 7 dias recomeça só quando a externa é consultada de novo
      }
    }
    final f = failure;
    if (f != null) throw f; // sem rede/cota: a pessoa tenta de novo; nada fica guardado como "não achou"
    await cache.putMiss(isbn13, missAt, externalTried: externalTried);
    return IsbnNotFound(
      isbn13,
      externalTried: externalTried,
      suggestions: suggestions,
    );
  }

  Future<IsbnFound> _found(
    CatalogBook b,
    CatalogLayer layer,
    DateTime now,
  ) async {
    await cache.putBook(b, now);
    return IsbnFound(b, layer);
  }
}

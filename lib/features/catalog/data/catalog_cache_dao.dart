// Camada do aparelho (Anexo 02 §7.2): "tudo que a própria pessoa já escaneou" — `catalog_cache`, com a
// fonte e a licença de cada resposta (o que vem da CBL/Google/ISBNdb não vai para o catálogo
// compartilhado). Também guarda o "não achou" por um tempo, para não gastar a cota de novo.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import '../domain/catalog_book.dart';

/// Resposta guardada: o livro, ou "não achou" com a data.
sealed class CachedIsbn {
  const CachedIsbn(this.fetchedAt);
  final DateTime fetchedAt;
}

final class CachedBook extends CachedIsbn {
  const CachedBook(this.book, super.fetchedAt);
  final CatalogBook book;
}

final class CachedMiss extends CachedIsbn {
  const CachedMiss(super.fetchedAt, {required this.externalTried});
  final bool externalTried;
}

final class CatalogCacheDao {
  CatalogCacheDao(this._db);

  final AppDatabase _db;

  static String keyOf(String isbn13) => 'isbn:$isbn13';

  Future<CachedIsbn?> byIsbn(String isbn13) async {
    final r = await (_db.select(
      _db.catalogCache,
    )..where((t) => t.key.equals(keyOf(isbn13)))).getSingleOrNull();
    if (r == null) return null;
    final j = jsonDecode(r.payload) as Map<String, Object?>;
    if (j['encontrado'] == false) {
      return CachedMiss(r.fetchedAt, externalTried: j['externa'] == true);
    }
    return CachedBook(CatalogBook.fromJson(j), r.fetchedAt);
  }

  Future<void> putBook(CatalogBook b, DateTime at) => _db
      .into(_db.catalogCache)
      .insertOnConflictUpdate(
        CatalogCacheCompanion.insert(
          key: keyOf(b.isbn13),
          kind: 'isbn',
          source: b.source,
          license: Value(b.license),
          payload: jsonEncode(b.toJson()),
          fetchedAt: at.toUtc(),
        ),
      );

  Future<void> putMiss(
    String isbn13,
    DateTime at, {
    required bool externalTried,
  }) => _db
      .into(_db.catalogCache)
      .insertOnConflictUpdate(
        CatalogCacheCompanion.insert(
          key: keyOf(isbn13),
          kind: 'isbn',
          source: 'nenhuma',
          payload: jsonEncode({'encontrado': false, 'externa': externalTried}),
          fetchedAt: at.toUtc(),
        ),
      );
}

// T04 — o livro da sessão do cronômetro: o que a mini-barra (título, capa) e a folha (total, última página) mostram,
// lido da estante do dono; e as páginas do catálogo para o "De quantas páginas é o livro?" (D-260), só das camadas do
// APARELHO — o cache do scanner (`catalog_cache`) e o `catalog.db` —, nunca a rede (o Grátis não manda nada).
import 'package:flutter/foundation.dart' show immutable;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/library_daos.dart';
import '../../../core/data/database/daos/reader_daos.dart';
import '../../catalog/data/catalog_cache_dao.dart';
import '../../catalog/data/local_catalog.dart';
import '../../home/domain/models.dart';

/// O livro da sessão aberta.
@immutable
final class PaperBook {
  const PaperBook({
    required this.book,
    this.pagesTotal,
    this.lastPage,
    this.isbn13,
  });

  /// O modelo da Início (título, autor, capa) — a mini-barra usa a mesma capa e o mesmo título curto.
  final Book book;

  /// `user_books.ref_pages_total` (D-260: sem ele, a folha pede o total).
  final int? pagesTotal;

  /// A página da posição atual ("Última registrada: pág. N").
  final int? lastPage;
  final String? isbn13;

  @override
  bool operator ==(Object other) =>
      other is PaperBook &&
      other.book == book &&
      other.pagesTotal == pagesTotal &&
      other.lastPage == lastPage &&
      other.isbn13 == isbn13;

  @override
  int get hashCode => Object.hash(book, pagesTotal, lastPage, isbn13);
}

abstract interface class PaperBookSource {
  /// O livro [userBookId] do [owner]; `null` = apagado, de outro dono ou inexistente.
  Future<PaperBook?> book(String owner, String userBookId);

  /// As páginas do livro no catálogo do aparelho, ou `null`.
  Future<int?> catalogPages(String isbn13);
}

final class LocalPaperBookSource implements PaperBookSource {
  LocalPaperBookSource(this._db, {required this.catalog});

  final AppDatabase _db;

  /// O `catalog.db` aberto agora (null = ainda não baixado).
  final Future<LocalCatalog?> Function() catalog;

  @override
  Future<PaperBook?> book(String owner, String userBookId) async {
    final b = await UserBooksDao(_db).byId(userBookId);
    if (b == null || b.meta.isDeleted || b.meta.userId != owner) return null;
    final p = await ReadingPositionsDao(_db).forBook(userBookId);
    return PaperBook(
      // como o `LocalHomeRepository` monta o livro da estante
      book: Book(
        id: b.id,
        title: b.title,
        author: b.authorDisplay,
        cover: PhotoCover(
          ref: b.coverRef,
          isbn13: b.isbn13,
          fileSha: b.contentSha256,
        ),
      ),
      pagesTotal: b.refPagesTotal,
      lastPage: p == null || p.meta.isDeleted ? null : p.refPage,
      isbn13: b.isbn13,
    );
  }

  @override
  Future<int?> catalogPages(String isbn13) async {
    int? valid(int? pages) => pages != null && pages > 0 ? pages : null;
    final cached = await CatalogCacheDao(_db).byIsbn(isbn13);
    if (cached is CachedBook) {
      final pages = valid(cached.book.pages);
      if (pages != null) return pages;
    }
    try {
      final local = await catalog();
      return valid((await local?.byIsbn(isbn13))?.pages);
    } on Object {
      return null; // catálogo trocando de versão ou ilegível: a folha fica sem sugestão
    }
  }
}

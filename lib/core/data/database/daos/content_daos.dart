// G09.2 — tabelas só do aparelho do conteúdo dos livros (Anexo 02 §3.3): o índice (`book_content_index`) e o
// arquivo (`local_files`). Nunca sincronizam; somem com o livro ("apagar deste aparelho", troca de conta).
import 'package:drift/drift.dart';

import '../../../../features/reader/content/book_index.dart';
import '../app_database.dart';

final class BookContentIndexDao {
  BookContentIndexDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(
    String userBookId,
    BookIndex index, {
    required DateTime builtAt,
  }) => _db
      .into(_db.bookContentIndex)
      .insertOnConflictUpdate(
        BookContentIndexCompanion(
          userBookId: Value(userBookId),
          contentSha256: Value(index.contentSha256),
          refPageVersion: Value(index.refPageVersion),
          spineJson: Value(index.spineJson),
          charCountsJson: Value(index.charCountsJson),
          tocJson: Value(index.tocJson),
          refPagesJson: Value(index.refPagesJson),
          builtAt: Value(builtAt.toUtc()),
        ),
      );

  Future<BookContentIndexRow?> _row(String userBookId) => (_db.select(
    _db.bookContentIndex,
  )..where((t) => t.userBookId.equals(userBookId))).getSingleOrNull();

  Future<BookIndex?> byBook(String userBookId) async {
    final r = await _row(userBookId);
    return r == null
        ? null
        : BookIndex.fromColumns(
            contentSha256: r.contentSha256,
            refPageVersion: r.refPageVersion,
            spineJson: r.spineJson,
            tocJson: r.tocJson,
            refPagesJson: r.refPagesJson,
          );
  }

  Future<DateTime?> builtAt(String userBookId) async =>
      (await _row(userBookId))?.builtAt;

  Future<void> delete(String userBookId) => (_db.delete(
    _db.bookContentIndex,
  )..where((t) => t.userBookId.equals(userBookId))).go();
}

final class LocalFilesDao {
  LocalFilesDao(this._db);

  final AppDatabase _db;

  /// Arquivo novo do livro (envio à nuvem do Pro começa como `none` — manual até a tela do livro).
  Future<void> upsert({
    required String userBookId,
    required String path,
    required int bytes,
    required String sha256,
    required DateTime now,
    String uploadState = 'none',
  }) => _db
      .into(_db.localFiles)
      .insertOnConflictUpdate(
        LocalFilesCompanion(
          userBookId: Value(userBookId),
          path: Value(path),
          bytes: Value(bytes),
          sha256: Value(sha256),
          uploadState: Value(uploadState),
          updatedAt: Value(now.toUtc()),
        ),
      );

  Future<LocalFileRow?> byBook(String userBookId) => (_db.select(
    _db.localFiles,
  )..where((t) => t.userBookId.equals(userBookId))).getSingleOrNull();

  Future<void> delete(String userBookId) => (_db.delete(
    _db.localFiles,
  )..where((t) => t.userBookId.equals(userBookId))).go();
}

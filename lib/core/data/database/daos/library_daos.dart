// DAOs da estante e das metas. Escrita = upsert da linha inteira (a versão vem de
// `LocalVersioning.next`, que aplica a regra receive-antes-de-send do ADR-003); `_extras` nunca é
// tocado por escrita local. Leitura devolve entidades de domínio (validadas de novo).
import 'package:drift/drift.dart';

import '../../../../features/library/domain/reading_goals.dart';
import '../../../../features/library/domain/user_book.dart';
import '../app_database.dart';
import 'rows.dart';

final class UserBooksDao {
  UserBooksDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(UserBook b) => _db
      .into(_db.userBooks)
      .insertOnConflictUpdate(
        UserBooksCompanion(
          id: Value(b.id),
          userId: Value(b.meta.userId),
          editionId: Value(b.editionId),
          title: Value(b.title),
          authorDisplay: Value(b.authorDisplay),
          format: Value(b.format),
          status: Value(b.status),
          contentSha256: Value(b.contentSha256),
          fileBytes: Value(b.fileBytes),
          storageObjectPath: Value(b.storageObjectPath),
          refPagesTotal: Value(b.refPagesTotal),
          refPageVersion: Value(b.refPageVersion),
          chaptersTotal: Value(b.chaptersTotal),
          coverRef: Value(b.coverRef),
          rating: Value(b.rating),
          addedAt: Value(b.addedAt),
          startedAt: Value(b.startedAt),
          finishedAt: Value(b.finishedAt),
          lastOpenedAt: Value(b.lastOpenedAt),
          createdAt: Value(b.meta.createdAt),
          updatedAt: Value(b.meta.updatedAt),
          deletedAt: Value(b.meta.deletedAt),
          versionHlc: Value(b.meta.version),
        ),
      );

  Future<UserBook?> byId(String id) async {
    final r = await (_db.select(
      _db.userBooks,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return r == null ? null : _toEntity(r);
  }

  /// Estante do usuário (sem os apagados), na ordem em que os livros chegaram.
  Future<List<UserBook>> shelf(String userId) => _shelfQuery(userId).get();

  Stream<List<UserBook>> watchShelf(String userId) =>
      _shelfQuery(userId).watch();

  Selectable<UserBook> _shelfQuery(String userId) =>
      (_db.select(_db.userBooks)
            ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull())
            ..orderBy([
              (t) => OrderingTerm(expression: t.addedAt),
              (t) => OrderingTerm(expression: t.id),
            ]))
          .map(_toEntity);

  static UserBook _toEntity(UserBookRow r) => UserBook(
    id: r.id,
    meta: metaFromRow(
      userId: r.userId,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
      versionHlc: r.versionHlc,
    ),
    editionId: r.editionId,
    title: r.title,
    authorDisplay: r.authorDisplay,
    format: r.format,
    status: r.status,
    contentSha256: r.contentSha256,
    fileBytes: r.fileBytes,
    storageObjectPath: r.storageObjectPath,
    refPagesTotal: r.refPagesTotal,
    refPageVersion: r.refPageVersion,
    chaptersTotal: r.chaptersTotal,
    coverRef: r.coverRef,
    rating: r.rating,
    addedAt: r.addedAt,
    startedAt: r.startedAt,
    finishedAt: r.finishedAt,
    lastOpenedAt: r.lastOpenedAt,
  );
}

final class ReadingGoalsDao {
  ReadingGoalsDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(ReadingGoals g) => _db
      .into(_db.readingGoalsRows)
      .insertOnConflictUpdate(
        ReadingGoalsRowsCompanion(
          id: Value(g.id),
          userId: Value(g.meta.userId),
          dailyMinutes: Value(g.dailyMinutes),
          badgeTargetDays: Value(g.badgeTargetDays),
          createdAt: Value(g.meta.createdAt),
          updatedAt: Value(g.meta.updatedAt),
          deletedAt: Value(g.meta.deletedAt),
          versionHlc: Value(g.meta.version),
        ),
      );

  Future<ReadingGoals?> forUser(String userId) async {
    final r = await (_db.select(
      _db.readingGoalsRows,
    )..where((t) => t.id.equals(userId))).getSingleOrNull();
    if (r == null) return null;
    return ReadingGoals(
      id: r.id,
      meta: metaFromRow(
        userId: r.userId,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
        versionHlc: r.versionHlc,
      ),
      dailyMinutes: r.dailyMinutes,
      badgeTargetDays: r.badgeTargetDays,
    );
  }
}

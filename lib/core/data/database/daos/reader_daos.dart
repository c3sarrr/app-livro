// DAOs do leitor: posição, sessões de leitura, marcadores e ajustes.
import 'package:drift/drift.dart';

import '../../../../features/reader/domain/bookmark.dart';
import '../../../../features/reader/domain/reader_settings.dart';
import '../../../../features/reader/domain/reading_position.dart';
import '../../../../features/reader/domain/reading_session.dart';
import '../app_database.dart';
import '../codecs.dart';
import 'rows.dart';

final class ReadingPositionsDao {
  ReadingPositionsDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(ReadingPosition p) => _db
      .into(_db.readingPositions)
      .insertOnConflictUpdate(
        ReadingPositionsCompanion(
          id: Value(p.id),
          userId: Value(p.meta.userId),
          locator: Value(p.locator),
          refPage: Value(p.refPage),
          chapterIndex: Value(p.chapterIndex),
          progression: Value(p.progression),
          deviceId: Value(p.deviceId),
          createdAt: Value(p.meta.createdAt),
          updatedAt: Value(p.meta.updatedAt),
          deletedAt: Value(p.meta.deletedAt),
          versionHlc: Value(p.meta.version),
        ),
      );

  /// Posição do livro (id da posição = id do livro).
  Future<ReadingPosition?> forBook(String userBookId) async {
    final r = await (_db.select(
      _db.readingPositions,
    )..where((t) => t.id.equals(userBookId))).getSingleOrNull();
    if (r == null) return null;
    return ReadingPosition(
      id: r.id,
      meta: metaFromRow(
        userId: r.userId,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
        versionHlc: r.versionHlc,
      ),
      locator: r.locator,
      refPage: r.refPage,
      chapterIndex: r.chapterIndex,
      progression: r.progression,
      deviceId: r.deviceId,
    );
  }
}

final class ReadingSessionsDao {
  ReadingSessionsDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(ReadingSession s) => _db
      .into(_db.readingSessions)
      .insertOnConflictUpdate(
        ReadingSessionsCompanion(
          id: Value(s.id),
          userId: Value(s.meta.userId),
          userBookId: Value(s.userBookId),
          startedAt: Value(s.startedAt),
          endedAt: Value(s.endedAt),
          activeSeconds: Value(s.activeSeconds),
          refPageFrom: Value(s.refPageFrom),
          refPageTo: Value(s.refPageTo),
          pagesViewed: Value(s.pagesViewed),
          source: Value(s.source),
          deviceId: Value(s.deviceId),
          createdAt: Value(s.meta.createdAt),
          updatedAt: Value(s.meta.updatedAt),
          deletedAt: Value(s.meta.deletedAt),
          versionHlc: Value(s.meta.version),
        ),
      );

  /// Sessões não apagadas do usuário que começaram em [from, to), em ordem de início.
  Future<List<ReadingSession>> startedBetween(
    String userId,
    DateTime from,
    DateTime to,
  ) =>
      (_db.select(_db.readingSessions)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.deletedAt.isNull() &
                  t.startedAt.isBiggerOrEqualValue(_text(from)) &
                  t.startedAt.isSmallerThanValue(_text(to)),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.startedAt)]))
          .map(_toEntity)
          .get();

  Future<List<ReadingSession>> forBook(String userBookId) =>
      (_db.select(_db.readingSessions)
            ..where(
              (t) => t.userBookId.equals(userBookId) & t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm(expression: t.startedAt)]))
          .map(_toEntity)
          .get();

  static String _text(DateTime d) => formatInstant(d);

  static ReadingSession _toEntity(ReadingSessionRow r) => ReadingSession(
    id: r.id,
    meta: metaFromRow(
      userId: r.userId,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
      versionHlc: r.versionHlc,
    ),
    userBookId: r.userBookId,
    startedAt: r.startedAt,
    endedAt: r.endedAt,
    activeSeconds: r.activeSeconds,
    refPageFrom: r.refPageFrom,
    refPageTo: r.refPageTo,
    pagesViewed: r.pagesViewed,
    source: r.source,
    deviceId: r.deviceId,
  );
}

final class BookmarksDao {
  BookmarksDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(Bookmark b) => _db
      .into(_db.bookmarks)
      .insertOnConflictUpdate(
        BookmarksCompanion(
          id: Value(b.id),
          userId: Value(b.meta.userId),
          userBookId: Value(b.userBookId),
          locator: Value(b.locator),
          refPage: Value(b.refPage),
          chapterIndex: Value(b.chapterIndex),
          excerpt: Value(b.excerpt),
          createdAt: Value(b.meta.createdAt),
          updatedAt: Value(b.meta.updatedAt),
          deletedAt: Value(b.meta.deletedAt),
          versionHlc: Value(b.meta.version),
        ),
      );

  /// Páginas marcadas do livro, na ordem do livro (aba Marcadas da tela 27b).
  Future<List<Bookmark>> forBook(String userBookId) =>
      _forBook(userBookId).get();

  Stream<List<Bookmark>> watchForBook(String userBookId) =>
      _forBook(userBookId).watch();

  /// A linha pelo id, também a apagada (G15 — a fita da aba Marcadas devolve a mesma linha, D-152).
  Future<Bookmark?> byId(String id) => (_db.select(
    _db.bookmarks,
  )..where((t) => t.id.equals(id))).map(_fromRow).getSingleOrNull();

  Selectable<Bookmark> _forBook(String userBookId) =>
      (_db.select(_db.bookmarks)
            ..where(
              (t) => t.userBookId.equals(userBookId) & t.deletedAt.isNull(),
            )
            ..orderBy([
              (t) => OrderingTerm(expression: t.refPage),
              (t) => OrderingTerm(expression: t.createdAt),
            ]))
          .map(_fromRow);

  static Bookmark _fromRow(BookmarkRow r) => Bookmark(
    id: r.id,
    meta: metaFromRow(
      userId: r.userId,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
      versionHlc: r.versionHlc,
    ),
    userBookId: r.userBookId,
    locator: r.locator,
    refPage: r.refPage,
    chapterIndex: r.chapterIndex,
    excerpt: r.excerpt,
  );
}

final class ReaderSettingsDao {
  ReaderSettingsDao(this._db);

  final AppDatabase _db;

  Future<void> upsert(ReaderSettings s) => _db
      .into(_db.readerSettingsRows)
      .insertOnConflictUpdate(
        ReaderSettingsRowsCompanion(
          id: Value(s.id),
          userId: Value(s.meta.userId),
          fontStep: Value(s.fontStep),
          fontFamily: Value(s.fontFamily),
          paper: Value(s.paper),
          lineSpacing: Value(s.lineSpacing),
          margins: Value(s.margins),
          createdAt: Value(s.meta.createdAt),
          updatedAt: Value(s.meta.updatedAt),
          deletedAt: Value(s.meta.deletedAt),
          versionHlc: Value(s.meta.version),
        ),
      );

  Future<ReaderSettings?> forUser(String userId) async {
    final r = await (_db.select(
      _db.readerSettingsRows,
    )..where((t) => t.id.equals(userId))).getSingleOrNull();
    if (r == null) return null;
    return ReaderSettings(
      id: r.id,
      meta: metaFromRow(
        userId: r.userId,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
        versionHlc: r.versionHlc,
      ),
      fontStep: r.fontStep,
      fontFamily: r.fontFamily,
      paper: r.paper,
      lineSpacing: r.lineSpacing,
      margins: r.margins,
    );
  }
}

// G09.2 — tabelas só do aparelho do conteúdo dos livros (Anexo 02 §3.3): o índice (`book_content_index`) e o
// arquivo (`local_files`). G10.2: o cache das páginas (`page_layout_cache`). Nunca sincronizam; somem com o
// livro ("apagar deste aparelho", troca de conta).
import 'dart:convert';

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

/// Onde cada página começa (posição no texto canônico), por item do spine, para um arquivo ([sha]).
final class PageBreaks {
  const PageBreaks({
    required this.sha,
    required this.chapters,
    this.spaces = const {},
  });

  final String sha;

  /// Item do spine → início de cada página.
  final Map<int, List<int>> chapters;

  /// G18: item do spine → a assinatura dos espaços abertos com que ele foi paginado (sem entrada = sem espaços).
  final Map<int, String> spaces;

  List<int> encode() => utf8.encode(
    jsonEncode({
      'sha': sha,
      'c': {for (final e in chapters.entries) '${e.key}': e.value},
      if (spaces.isNotEmpty)
        's': {for (final e in spaces.entries) '${e.key}': e.value},
    }),
  );

  /// `null` quando o conteúdo não é deste formato (cache de outra versão ou corrompido).
  static PageBreaks? decode(List<int> bytes) {
    try {
      final j = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
      final c = j['c']! as Map<String, Object?>;
      final s = (j['s'] as Map<String, Object?>?) ?? const {};
      return PageBreaks(
        sha: j['sha']! as String,
        chapters: {
          for (final e in c.entries)
            int.parse(e.key): [for (final x in e.value! as List) x as int],
        },
        spaces: {
          for (final e in s.entries) int.parse(e.key): e.value! as String,
        },
      );
    } on Object {
      return null;
    }
  }
}

/// Cache das páginas (Anexo 03 §7.2): chave = livro, ajustes que mudam o layout, viewport e versão das fontes.
final class PageLayoutCacheDao {
  PageLayoutCacheDao(this._db);

  final AppDatabase _db;

  /// R11 (G20): até 4 combinações por livro (ajustes + tela + versão das fontes); a de uso mais antigo sai.
  static const int perBook = 4;

  Future<PageBreaks?> get({
    required String userBookId,
    required String settingsHash,
    required String viewport,
    required int fontsVersion,
    DateTime? now,
  }) async {
    final r =
        await (_db.select(_db.pageLayoutCache)..where(
              (t) =>
                  t.userBookId.equals(userBookId) &
                  t.settingsHash.equals(settingsHash) &
                  t.viewport.equals(viewport) &
                  t.fontsVersion.equals(fontsVersion),
            ))
            .getSingleOrNull();
    if (r == null) return null;
    // ler marca o uso (a coluna `created_at` guarda o último uso — R11)
    if (now != null) {
      await (_db.update(_db.pageLayoutCache)..where(
            (t) =>
                t.userBookId.equals(userBookId) &
                t.settingsHash.equals(settingsHash) &
                t.viewport.equals(viewport) &
                t.fontsVersion.equals(fontsVersion),
          ))
          .write(PageLayoutCacheCompanion(createdAt: Value(now.toUtc())));
    }
    return PageBreaks.decode(r.breaks);
  }

  Future<void> put({
    required String userBookId,
    required String settingsHash,
    required String viewport,
    required int fontsVersion,
    required PageBreaks breaks,
    required DateTime now,
  }) async {
    await _db
        .into(_db.pageLayoutCache)
        .insertOnConflictUpdate(
          PageLayoutCacheCompanion(
            userBookId: Value(userBookId),
            settingsHash: Value(settingsHash),
            viewport: Value(viewport),
            fontsVersion: Value(fontsVersion),
            breaks: Value(Uint8List.fromList(breaks.encode())),
            createdAt: Value(now.toUtc()),
          ),
        );
    await _trim(userBookId, settingsHash, viewport, fontsVersion);
  }

  /// Fica com as [perBook] combinações de uso mais recente do livro: a recém-gravada e as outras mais novas (no mesmo
  /// instante, a gravada por último).
  Future<void> _trim(
    String userBookId,
    String settingsHash,
    String viewport,
    int fontsVersion,
  ) => _db.customStatement(
    'DELETE FROM page_layout_cache WHERE user_book_id = ?1 '
    'AND NOT (settings_hash = ?2 AND viewport = ?3 AND fonts_version = ?4) '
    'AND rowid NOT IN (SELECT rowid FROM page_layout_cache WHERE user_book_id = ?1 '
    'AND NOT (settings_hash = ?2 AND viewport = ?3 AND fonts_version = ?4) '
    'ORDER BY created_at DESC, rowid DESC LIMIT ${perBook - 1})',
    [userBookId, settingsHash, viewport, fontsVersion],
  );

  /// Tudo do livro (o arquivo mudou).
  Future<void> deleteBook(String userBookId) => (_db.delete(
    _db.pageLayoutCache,
  )..where((t) => t.userBookId.equals(userBookId))).go();
}

// G09.4 — importar um EPUB/PDF para a estante (Anexo 03 §3, D-87…D-93), em dois tempos:
//   1º (o livro aparece logo): cópia em pedaços com SHA-256 → tipo pelo conteúdo → mesmo arquivo já na estante?
//      → metadados, DRM e capa (isolate) → ISBN no catálogo do aparelho e no Worker (D-91) → `user_books`
//      ("Quero ler") + `local_files` + capa do arquivo (D-90). O PDF já sai indexado (páginas do PDF).
//   2º (segundo plano): índice completo do EPUB (isolate) → `book_content_index` + páginas/capítulos no livro.
// Um arquivo de cada vez. Qualquer falha apaga a cópia e não deixa linha pela metade.
// Privacidade (§4.3.7): nada do arquivo sai do aparelho; a única rede é a consulta do ISBN.
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Variable;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/content_daos.dart';
import '../../../core/data/database/daos/library_daos.dart';
import '../../../core/data/database/failures.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/ids/uuid_v7.dart';
import '../../../core/data/model/nullable.dart';
import '../../../core/data/model/record_meta.dart';
import '../../catalog/application/isbn_resolver.dart';
import '../../catalog/domain/catalog_book.dart';
import '../../reader/content/book_index.dart';
import '../../reader/content/content_failure.dart';
import '../../reader/content/epub_inspection.dart';
import '../../reader/content/ref_pages.dart';
import '../../scanner/application/scanned_shelf.dart'
    show shelfText, unknownAuthor;
import '../data/book_files.dart';
import '../data/pdf_inspector.dart';
import '../domain/import_outcome.dart';
import '../domain/user_book.dart';

/// Roda [task] fora da linha principal (padrão: `Isolate.run`).
typedef BackgroundRunner = Future<T> Function<T>(T Function() task);

Future<T> runInIsolate<T>(T Function() task) => Isolate.run(task);

/// O que o catálogo sabe de um ISBN (D-91: só aparelho e Worker).
final class IsbnMatch {
  const IsbnMatch({this.title, this.authors = const [], this.coverRef});

  final String? title;
  final List<String> authors;
  final String? coverRef;
}

abstract interface class IsbnLookup {
  Future<IsbnMatch?> find(String isbn13);
}

/// Separador de autores no `author_display` (a Início separa por ele — G08).
const String authorSeparator = ' · ';

final class BookImporter {
  BookImporter({
    required this._db,
    required this._versioning,
    required this._owner,
    required this._booksDir,
    required this._fileCoversDir,
    required this._pdf,
    this._catalog,
    BackgroundRunner? run,
    UuidV7Generator? ids,
    DateTime Function()? now,
    void Function(Object error, StackTrace stack)? onError,
  }) : _run = run ?? runInIsolate,
       _ids = ids ?? UuidV7Generator(),
       _now = now ?? DateTime.now,
       _onError = onError ?? ((_, _) {});

  final AppDatabase _db;
  final LocalVersioning _versioning;
  final Future<String> Function() _owner;
  final Future<Directory> Function() _booksDir;
  final Future<Directory> Function() _fileCoversDir;
  final PdfInspector _pdf;
  final IsbnLookup? _catalog;
  final BackgroundRunner _run;
  final UuidV7Generator _ids;
  final DateTime Function() _now;
  final void Function(Object, StackTrace) _onError;

  /// Tempo máximo da consulta ao catálogo (a importação não espera a rede além disso).
  static const Duration catalogTimeout = Duration(seconds: 4);

  Future<void> _queue = Future<void>.value();

  /// Importa o arquivo [file] ([fileName] = o nome como veio, quando a cópia recebida tem outro).
  Future<ImportOutcome> importFile(File file, {String? fileName}) =>
      importStream(
        file.openRead(),
        fileName: fileName ?? file.uri.pathSegments.last,
      );

  /// Importa os bytes de [data] (seletor, "Abrir com"); [fileName] dá o título quando o arquivo não tem.
  Future<ImportOutcome> importStream(
    Stream<List<int>> data, {
    required String fileName,
  }) {
    final r = _queue.then((_) => _import(data, fileName));
    _queue = r.then((_) {}, onError: (_) {});
    return r;
  }

  Future<ImportOutcome> _import(Stream<List<int>> data, String fileName) async {
    final File tmp;
    final CopiedFile copied;
    try {
      final dir = await _booksDir();
      await dir.create(recursive: true);
      tmp = File(
        '${dir.path}${Platform.pathSeparator}.importando-${_ids.next()}.part',
      );
      copied = await copyWithSha256(data, tmp);
    } on Object catch (e, st) {
      if (isNoSpace(e)) {
        return const ImportFailed(ImportError.noSpace);
      }
      _onError(e, st);
      return const ImportFailed(ImportError.unexpected);
    }
    File? placed;
    try {
      final kind = sniffBookFile(copied.head);
      if (kind == BookFileKind.unknown) {
        return const ImportFailed(ImportError.unsupported);
      }
      final owner = await _owner();
      final dup = await _activeBySha(owner, copied.sha256);
      if (dup != null) {
        return AlreadyOnShelf(userBookId: dup.$1, title: dup.$2);
      }

      final _Found found;
      final PdfInfo? pdfInfo;
      if (kind == BookFileKind.epub) {
        final i = await _inspectIn(_run, tmp.path);
        found = _Found(i.title, i.authors, i.isbn13, i.cover, i.fixedLayout);
        pdfInfo = null;
      } else {
        pdfInfo = await _pdf.inspect(tmp.path);
        found = _Found(
          pdfInfo.title ?? '',
          [?pdfInfo.author],
          null,
          pdfInfo.coverPng,
          false,
        );
      }
      final match = found.isbn13 == null ? null : await _lookup(found.isbn13!);

      var title = shelfText(found.title, 500);
      if (title.isEmpty) title = shelfText(match?.title ?? '', 500);
      if (title.isEmpty) title = _titleFromFileName(fileName);
      var authors = found.authors.where((a) => a.trim().isNotEmpty).toList();
      if (authors.isEmpty) authors = match?.authors ?? const [];
      final authorText = shelfText(authors.join(authorSeparator), 500);

      final id = _ids.next();
      final ext = kind == BookFileKind.epub ? 'epub' : 'pdf';
      placed = File('${tmp.parent.path}${Platform.pathSeparator}$id.$ext');
      await tmp.rename(placed.path);

      final result = await _versioning.write('user_books', id, (v) async {
        final again = await _activeBySha(owner, copied.sha256);
        if (again != null) {
          return AlreadyOnShelf(userBookId: again.$1, title: again.$2);
        }
        final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
        final pdfIndex = pdfInfo == null
            ? null
            : _pdfIndex(copied.sha256, pdfInfo);
        await UserBooksDao(_db).upsert(
          UserBook(
            id: id,
            meta: RecordMeta(
              userId: owner,
              createdAt: at,
              updatedAt: at,
              version: v,
            ),
            title: title,
            authorDisplay: authorText.isEmpty ? unknownAuthor : authorText,
            format: kind == BookFileKind.epub
                ? BookFileFormat.epub
                : BookFileFormat.pdf,
            status: ShelfStatus.wantToRead,
            contentSha256: copied.sha256,
            fileBytes: copied.bytes,
            refPagesTotal: pdfIndex?.refPagesTotal,
            refPageVersion: pdfIndex == null ? null : refPageVersion,
            coverRef: match?.coverRef,
            addedAt: at,
            isbn13: found.isbn13,
          ),
        );
        await LocalFilesDao(_db).upsert(
          userBookId: id,
          path: placed!.path,
          bytes: copied.bytes,
          sha256: copied.sha256,
          now: _now(),
        );
        if (pdfIndex != null) {
          await BookContentIndexDao(_db).upsert(id, pdfIndex, builtAt: _now());
        }
        return Imported(
          userBookId: id,
          title: title,
          fixedLayout: found.fixedLayout,
        );
      });
      if (result is! Imported) {
        await _deleteQuietly(placed);
        return result;
      }
      await _saveCover(copied.sha256, found.cover);
      return result;
    } on DuplicateActiveRow catch (e) {
      await _deleteQuietly(placed);
      return AlreadyOnShelf(userBookId: e.existingId, title: '');
    } on ContentProtected {
      await _deleteQuietly(placed);
      return const ImportFailed(ImportError.protected);
    } on ContentUnsupported {
      await _deleteQuietly(placed);
      return const ImportFailed(ImportError.unsupported);
    } on ContentDamaged {
      await _deleteQuietly(placed);
      return const ImportFailed(ImportError.damaged);
    } on Object catch (e, st) {
      await _deleteQuietly(placed);
      if (isNoSpace(e)) {
        return const ImportFailed(ImportError.noSpace);
      }
      _onError(e, st);
      return const ImportFailed(ImportError.unexpected);
    } finally {
      await _deleteQuietly(tmp);
    }
  }

  /// Segundo tempo: índice completo do EPUB [userBookId] (refeito se faltar ou se o arquivo mudou).
  /// `true` = indexou agora.
  Future<bool> indexBook(String userBookId) async {
    final lf = await LocalFilesDao(_db).byBook(userBookId);
    final book = await UserBooksDao(_db).byId(userBookId);
    if (lf == null ||
        book == null ||
        book.meta.isDeleted ||
        book.format != BookFileFormat.epub) {
      return false;
    }
    final current = await BookContentIndexDao(_db).byBook(userBookId);
    if (current != null &&
        current.contentSha256 == lf.sha256 &&
        current.refPageVersion == refPageVersion) {
      return false;
    }
    final sha = lf.sha256;
    final BookIndex index;
    try {
      index = await _indexIn(_run, lf.path, sha);
    } on ContentFailure catch (e, st) {
      _onError(e, st);
      return false;
    } on FileSystemException catch (e, st) {
      _onError(e, st);
      return false;
    }
    return _versioning.write('user_books', userBookId, (v) async {
      final cur = await UserBooksDao(_db).byId(userBookId);
      final file = await LocalFilesDao(_db).byBook(userBookId);
      if (cur == null || cur.meta.isDeleted || file?.sha256 != sha) {
        return false;
      }
      final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
      await BookContentIndexDao(_db).upsert(userBookId, index, builtAt: _now());
      await UserBooksDao(_db).upsert(
        cur.copyWith(
          meta: RecordMeta(
            userId: cur.meta.userId,
            createdAt: cur.meta.createdAt,
            updatedAt: at,
            version: v,
          ),
          refPagesTotal: Nullable(index.refPagesTotal),
          refPageVersion: Nullable(index.refPageVersion),
          chaptersTotal: Nullable(index.chaptersTotal),
        ),
      );
      return true;
    });
  }

  /// Livros com arquivo no aparelho e sem índice (o app fechou no meio, ou veio da nuvem): indexa um por um.
  Future<int> indexPending() async {
    final owner = await _owner();
    final rows = await _db
        .customSelect(
          'SELECT f.user_book_id AS id FROM local_files f '
          'JOIN user_books b ON b.id = f.user_book_id '
          'LEFT JOIN book_content_index i ON i.user_book_id = f.user_book_id '
          "WHERE b.user_id = ? AND b.deleted_at IS NULL AND b.format = 'epub' "
          'AND (i.user_book_id IS NULL OR i.content_sha256 <> f.sha256 OR i.ref_page_version <> ?)',
          variables: [
            Variable.withString(owner),
            Variable.withInt(refPageVersion),
          ],
        )
        .get();
    var n = 0;
    for (final r in rows) {
      if (await indexBook(r.read<String>('id'))) n++;
    }
    return n;
  }

  Future<(String, String)?> _activeBySha(String owner, String sha) async {
    final r = await _db
        .customSelect(
          'SELECT id, title FROM user_books WHERE user_id = ? AND content_sha256 = ? '
          'AND deleted_at IS NULL LIMIT 1',
          variables: [Variable.withString(owner), Variable.withString(sha)],
        )
        .getSingleOrNull();
    return r == null ? null : (r.read<String>('id'), r.read<String>('title'));
  }

  Future<IsbnMatch?> _lookup(String isbn13) async {
    final c = _catalog;
    if (c == null) {
      return null;
    }
    try {
      return await c.find(isbn13).timeout(catalogTimeout);
    } on Object {
      return null; // sem rede, catálogo trocando: fica o que está no arquivo
    }
  }

  /// Capa do arquivo (D-90) em `capas_arquivo/<sha256>.img` — some com o livro, nunca pela limpeza do cache.
  Future<void> _saveCover(String sha, Uint8List? bytes) async {
    if (bytes == null || bytes.isEmpty) {
      return;
    }
    try {
      final dir = await _fileCoversDir();
      await dir.create(recursive: true);
      final f = File('${dir.path}${Platform.pathSeparator}$sha.img');
      final part = File('${f.path}.part');
      await part.writeAsBytes(bytes, flush: true);
      await part.rename(f.path);
    } on Object catch (e, st) {
      _onError(e, st); // sem capa do arquivo: fica a da fonte ou a gerada
    }
  }

  static BookIndex _pdfIndex(String sha, PdfInfo info) => BookIndex(
    contentSha256: sha,
    layout: 'pdf',
    spine: const [],
    toc: [
      for (final o in info.outline)
        TocPoint(
          title: o.title,
          spine: o.page == null ? null : 0,
          offset: o.page == null ? null : o.page! - 1,
          depth: o.depth,
          leaf: !o.hasChildren,
        ),
    ],
    refPages: RefPageMap.pdf(info.pages),
    refPageVersion: refPageVersion,
  );

  static String _titleFromFileName(String name) {
    var t = name;
    final dot = t.lastIndexOf('.');
    if (dot > 0) t = t.substring(0, dot);
    t = shelfText(t.replaceAll(RegExp(r'[_]+'), ' '), 500);
    return t.isEmpty ? 'Sem título' : t;
  }

  static Future<void> _deleteQuietly(File? f) async {
    if (f == null) {
      return;
    }
    try {
      if (await f.exists()) {
        await f.delete();
      }
    } on FileSystemException {
      // em uso: fica para a próxima limpeza
    }
  }
}

// O fecho mandado ao isolate só pode levar o caminho: criado aqui, fora do escopo do importador (que tem o
// banco), para o contexto dele não arrastar nada que não atravessa isolates.
Future<EpubInspection> _inspectIn(BackgroundRunner run, String path) =>
    run(() => inspectEpub(path));

Future<BookIndex> _indexIn(BackgroundRunner run, String path, String sha) =>
    run(() => indexEpubFile(path, sha));

final class _Found {
  const _Found(
    this.title,
    this.authors,
    this.isbn13,
    this.cover,
    this.fixedLayout,
  );

  final String title;
  final List<String> authors;
  final String? isbn13;
  final Uint8List? cover;
  final bool fixedLayout;
}

/// D-91: o ISBN do arquivo consulta só o `catalog.db` do aparelho e o Worker — o resolvedor vem montado sem a
/// comunidade e sem a consulta externa (que gasta cota).
final class ResolverIsbnLookup implements IsbnLookup {
  ResolverIsbnLookup(this._resolver);

  final IsbnResolver _resolver;

  @override
  Future<IsbnMatch?> find(String isbn13) async {
    final r = await _resolver.resolve(isbn13, allowExternal: false);
    return r is IsbnFound
        ? IsbnMatch(
            title: r.book.title,
            authors: r.book.authors,
            coverRef: r.book.coverRef,
          )
        : null;
  }
}

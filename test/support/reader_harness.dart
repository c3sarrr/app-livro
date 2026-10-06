// G11 — um livro na estante de um banco em memória, pronto para o leitor: a linha do `user_books`, o arquivo no
// disco (`local_files`), o índice (`book_content_index`) e, se pedido, a posição guardada. Serve aos testes do
// documento, da sessão e da tela.
import 'dart:io';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_errors.dart';
import 'package:app_leitura/features/reader/application/reading_position_keeper.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/layout/layout_scheduler.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:drift/native.dart';

import 'epub_builder.dart';
import 'personal_builders.dart';

/// O Dom Casmurro do Projeto Gutenberg (domínio público) — o livro real dos testes do leitor.
const String domCasmurroEpub = 'test/fixtures/livros/pg55752.epub';

final class LivroNaEstante {
  LivroNaEstante._({
    required this.dir,
    required this.db,
    required this.versioning,
    required this.book,
    required this.path,
    required this.index,
    required this.epub,
  });

  /// Grava o EPUB [bytes] como o livro [n] da estante de [usuarioTeste] (com índice, se [indexar]).
  static Future<LivroNaEstante> epubDe(
    List<int> bytes, {
    int n = 7,
    String title = 'Dom Casmurro',
    bool indexar = true,
    String dono = usuarioTeste,
  }) async {
    final dir = Directory.systemTemp.createTempSync('booknest_g11_livro_');
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    final versioning = LocalVersioning(db, HlcClock(deviceId: 'aparelhoA'));
    final path = writeTemp(dir, '${idTeste(n)}.epub', bytes);
    final sha = shaDoLivroTeste(n);
    final index = indexEpubFile(path, sha);
    final book = livroTeste(
      n,
      title: title,
      dono: dono,
    ).copyWith(refPagesTotal: Nullable(index.refPagesTotal));
    await UserBooksDao(db).upsert(book);
    await LocalFilesDao(db).upsert(
      userBookId: book.id,
      path: path,
      bytes: bytes.length,
      sha256: sha,
      now: t0Teste,
    );
    if (indexar) {
      await BookContentIndexDao(db).upsert(book.id, index, builtAt: t0Teste);
    }
    return LivroNaEstante._(
      dir: dir,
      db: db,
      versioning: versioning,
      book: book,
      path: path,
      index: index,
      epub: EpubBook.open(path),
    );
  }

  /// O Dom Casmurro real.
  static Future<LivroNaEstante> domCasmurro({bool indexar = true}) =>
      epubDe(File(domCasmurroEpub).readAsBytesSync(), indexar: indexar);

  final Directory dir;
  final AppDatabase db;
  final LocalVersioning versioning;
  final UserBook book;
  final String path;
  final BookIndex index;
  final EpubBook epub;

  String get userBookId => book.id;

  ReadingPositionKeeper keeper({
    Duration delay = positionSaveDelay,
    ReaderErrorReporter? onError,
  }) => ReadingPositionKeeper(
    db: db,
    versioning: versioning,
    owner: () async => book.meta.userId,
    userBookId: book.id,
    index: index,
    deviceId: 'aparelhoA',
    delay: delay,
    onError: onError ?? reportReaderError,
  );

  /// Guarda a posição no caractere [offset] do item [spine] (como se o livro tivesse sido lido até ali).
  Future<void> guardarPosicao(int spine, int offset) async {
    final k = keeper(delay: Duration.zero)
      ..pageShown(spine, offset, chapterOf(epub, spine).item.text);
    await k.flush();
    k.dispose();
  }

  EpubDocumentDeps deps({
    ReaderTypography t = const ReaderTypography(),
    LayoutScheduler? scheduler,
    ReadingPositionKeeper? keeper,
  }) => EpubDocumentDeps(
    book: book,
    index: index,
    path: path,
    typography: t,
    scheduler: scheduler ?? LayoutScheduler(),
    keeper: keeper ?? this.keeper(),
    loader: (s) async => chapterOf(epub, s),
  );

  Future<void> close() async {
    epub.close();
    await db.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}

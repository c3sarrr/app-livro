// G11 — um livro na estante de um banco em memória, pronto para o leitor: a linha do `user_books`, o arquivo no
// disco (`local_files`), o índice (`book_content_index`) e, se pedido, a posição guardada. Serve aos testes do
// documento, da sessão e da tela.
import 'dart:async';
import 'dart:io';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/ink_repository.dart';
import 'package:app_leitura/features/reader/application/book_search.dart';
import 'package:app_leitura/features/reader/application/epub_images.dart';
import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_club_source.dart';
import 'package:app_leitura/features/reader/application/reader_errors.dart';
import 'package:app_leitura/features/reader/application/reader_session_controller.dart';
import 'package:app_leitura/features/reader/application/reading_speed_source.dart';
import 'package:app_leitura/features/reader/application/reading_position_keeper.dart';
import 'package:app_leitura/features/reader/application/screen_awake.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/content_failure.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/layout/layout_scheduler.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:app_leitura/features/reader/layout/space_cut.dart';
import 'package:drift/native.dart';
import 'package:flutter/scheduler.dart' show Priority;

import '../fixtures/mundo_2026_09_20.dart' show Slugs;
import '../fixtures/telas/indice_t19.dart';
import 'epub_builder.dart';
import 'mundo_epub.dart';
import 'personal_builders.dart';

/// O Dom Casmurro do Projeto Gutenberg (domínio público) — o livro real dos testes do leitor.
const String domCasmurroEpub = 'test/fixtures/livros/pg55752.epub';

final class LivroNaEstante {
  LivroNaEstante._({
    this.leitor = usuarioTeste,
    required this.dir,
    required this.db,
    required this.versioning,
    required this.book,
    required this.path,
    required this.index,
    required this.epub,
  });

  /// Grava o EPUB [bytes] como o livro [n] da estante de [usuarioTeste] (com índice, se [indexar]). [livro] troca
  /// a linha do livro (o Dom Casmurro do mundo — tela 20) e [leitor], a conta que abre o leitor.
  static Future<LivroNaEstante> epubDe(
    List<int> bytes, {
    int n = 7,
    String title = 'Dom Casmurro',
    bool indexar = true,
    String dono = usuarioTeste,
    UserBook? livro,
    String leitor = usuarioTeste,
  }) async {
    final dir = Directory.systemTemp.createTempSync('booknest_g11_livro_');
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    final versioning = LocalVersioning(db, HlcClock(deviceId: 'aparelhoA'));
    final path = writeTemp(dir, '${idTeste(n)}.epub', bytes);
    final sha = shaDoLivroTeste(n);
    final index = indexEpubFile(path, sha);
    final book = (livro ?? livroTeste(n, title: title, dono: dono)).copyWith(
      refPagesTotal: Nullable(index.refPagesTotal),
      contentSha256: Nullable(sha),
    );
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
      leitor: leitor,
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

  /// A conta que abre o leitor (a dona da estante).
  final String leitor;
  final Directory dir;
  final AppDatabase db;
  final LocalVersioning versioning;
  final UserBook book;
  final String path;
  BookIndex index;
  final EpubBook epub;

  /// Troca o índice guardado (ex.: o mapa injetado da tela 19 — D-34).
  Future<void> usarIndice(BookIndex novo) async {
    index = novo;
    await BookContentIndexDao(db).upsert(book.id, novo, builtAt: t0Teste);
  }

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

  /// A busca do EPUB sem isolate (os capítulos lidos na hora, como o `loader`).
  Stream<UnitHits> buscaNaHora(String path, List<int> spines, String query) =>
      Stream.fromIterable(
        searchTexts(spines, (s) => chapterOf(epub, s).item.text, query),
      );

  EpubDocumentDeps deps({
    ReaderTypography t = const ReaderTypography(),
    LayoutScheduler? scheduler,
    ReadingPositionKeeper? keeper,
    EpubSearchRunner? busca,
    SpaceCutsOf? espacos,
  }) => EpubDocumentDeps(
    book: book,
    index: index,
    path: path,
    typography: t,
    scheduler: scheduler ?? LayoutScheduler(),
    keeper: keeper ?? this.keeper(),
    loader: (s) async => chapterOf(epub, s),
    images: (href) async => readImageOf(epub, href),
    search: busca ?? buscaNaHora,
    spaces: espacos,
  );

  /// O que a sessão de leitura usa, sobre este livro: capítulos lidos na hora (sem isolate), o tempo sem o
  /// tique de 1 s, a indexação da G09 trocada por gravar o índice já calculado (ou [indexar]).
  ReaderDeps readerDeps({
    required ScreenAwake awake,
    ReaderErrorReporter? onError,
    Future<bool> Function(String id)? indexar,
    Duration Function()? elapsed,
    DateTime Function()? now,
    Timer Function(Duration, void Function())? startTimer,
    Set<int> quebrados = const {},
    Future<void> Function()? pdfInitialize,
    Future<double> Function(AppDatabase db, String userId)? speedOf,
    ReaderClubSource club = const NoReaderClub(),
    Duration Function(DateTime utc)? utcOffsetAt,
    InkRepository? ink,
    Future<String> Function()? owner,
  }) => ReaderDeps(
    db: db,
    versioning: versioning,
    owner: owner ?? () async => leitor,
    booksDir: () async => dir,
    indexBook:
        indexar ??
        (id) async {
          await BookContentIndexDao(db).upsert(id, index, builtAt: t0Teste);
          return true;
        },
    // Nos testes de tela o tempo é falso (`testWidgets`): uma fatia de layout com prioridade ociosa, pedida
    // enquanto uma animação roda (a entrada da rota, a virada), é adiada pelo `SchedulerBinding` com
    // `Timer.run` de novo a cada volta — no aparelho isso só espera a animação acabar; no tempo falso o
    // `pump` nunca termina. Aqui as fatias têm a prioridade de animação (a ordem entre capítulos é a mesma).
    scheduler: LayoutScheduler(priority: Priority.animation),
    screenAwake: awake,
    deviceId: 'aparelhoA',
    now: now,
    elapsed: elapsed,
    autoTick: false,
    // [quebrados]: capítulos que não abrem (arquivo danificado no meio do livro)
    chapterLoader: (path) =>
        (s) async => quebrados.contains(s)
        ? throw const ContentDamaged('capitulo_quebrado')
        : chapterOf(epub, s),
    imageLoader: (path) =>
        (href) async => readImageOf(epub, href),
    searchRunner: buscaNaHora,
    speedOf: speedOf ?? readingSpeedOf,
    startTimer: startTimer ?? Timer.new,
    pdfInitialize: pdfInitialize,
    club: club,
    utcOffsetAt: utcOffsetAt ?? readerUtcOffset,
    onError: onError ?? reportReaderError,
    inkRepository: ink,
  );

  Future<void> close() async {
    epub.close();
    await db.close();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}

/// A tela 19 do mundo de referência (D-34): o Dom Casmurro do mundo, com o índice injetado da tela 19, aberto no
/// começo do cap. XXXII — a pág. 159 de 256, 62 %.
Future<LivroNaEstante> livroDaTela19() async {
  final livro = await LivroNaEstante.epubDe(
    mundoEpub(Slugs.domCasmurro, completo: true),
  );
  await livro.usarIndice(indiceDaTela19(livro.index));
  await livro.guardarPosicao(itemDaPagina159, 0);
  return livro;
}

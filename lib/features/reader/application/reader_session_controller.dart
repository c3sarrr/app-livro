// G11.2 — a sessão de leitura de uma tela aberta (desenho G11 §2): abre o livro da estante pelo id (o arquivo, o
// índice — indexa ao abrir se faltar —, os ajustes e a posição), diz por que não abriu (D-21, D-92, D-113), e
// liga a página mostrada ao tempo automático (D-95), à posição salva (G10) e à tela acesa (D-111). Guarda uma
// volta depois de seguir um link (D-108): some em 6 s ou em 2 viradas.
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/painting.dart' show EdgeInsets, Size;
import 'package:flutter/widgets.dart' show AppLifecycleState;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/content_daos.dart';
import '../../../core/data/database/daos/library_daos.dart';
import '../../../core/data/database/daos/reader_daos.dart';
import '../../../core/data/database/versioning.dart';
import '../../library/domain/user_book.dart';
import '../content/content_failure.dart';
import '../content/ref_pages.dart' show refPageVersion;
import '../domain/reader_settings.dart';
import '../layout/layout_scheduler.dart';
import '../layout/reader_typography.dart';
import '../presentation/reader_insets.dart';
import '../presentation/reader_palette.dart';
import 'book_pager.dart';
import 'epub_images.dart' show EpubImageLoader;
import 'epub_reader_document.dart';
import 'pdf_position_keeper.dart';
import 'pdf_reader_document.dart';
import 'reader_document.dart';
import 'reader_errors.dart';
import 'reading_position_keeper.dart';
import 'reading_session_tracker.dart';
import 'screen_awake.dart';

/// Por que o livro não abriu (textos na tela — G11 §3).
enum ReaderFailure { notOnShelf, fileMissing, damaged, fixedLayout, unexpected }

sealed class ReaderState {
  const ReaderState();
}

/// Abrindo; [preparing] = indexando o livro antes ("Preparando o livro…").
final class ReaderOpening extends ReaderState {
  const ReaderOpening({this.preparing = false});

  final bool preparing;
}

final class ReaderReady extends ReaderState {
  const ReaderReady(this.document, {this.back});

  final ReaderDocument document;

  /// A volta do último link seguido (D-108), enquanto vale.
  final BackLink? back;
}

final class ReaderFailed extends ReaderState {
  const ReaderFailed(this.failure);

  final ReaderFailure failure;
}

/// De onde se saiu ao seguir um link e a pág. de lá ("Voltar à pág. N").
typedef BackLink = ({ReaderMark mark, int refPage});

/// A tela onde o livro vai aparecer: tamanho, áreas seguras e densidade (chave do cache de páginas).
typedef ReaderViewport = ({
  Size size,
  EdgeInsets padding,
  double devicePixelRatio,
});

/// Quanto a volta de um link vale (D-108).
const Duration backLinkLife = Duration(seconds: 6);
const int backLinkTurns = 2;

/// O que a sessão usa do app (o provider monta; os testes trocam).
final class ReaderDeps {
  const ReaderDeps({
    required this.db,
    required this.versioning,
    required this.owner,
    required this.booksDir,
    required this.indexBook,
    required this.scheduler,
    required this.screenAwake,
    this.deviceId,
    this.now,
    this.elapsed,
    this.autoTick = true,
    this.chapterLoader,
    this.imageLoader,
    this.startTimer = Timer.new,
    this.pdfInitialize,
    this.onError = reportReaderError,
  });

  final AppDatabase db;
  final LocalVersioning versioning;

  /// A conta ativa (dona da estante).
  final Future<String> Function() owner;

  /// A pasta dos livros de agora (no iOS ela muda de lugar numa atualização).
  final Future<Directory> Function() booksDir;

  /// Indexa o livro (`BookImporter.indexBook`): `true` = gravou um índice novo.
  final Future<bool> Function(String userBookId) indexBook;
  final LayoutScheduler scheduler;
  final ScreenAwake screenAwake;
  final String? deviceId;
  final DateTime Function()? now;
  final Duration Function()? elapsed;

  /// O tempo confere a pausa por parado sozinho a cada segundo (os testes chamam `tick`).
  final bool autoTick;

  /// Como ler os capítulos do arquivo (padrão: num isolate).
  final ChapterLoader Function(String path)? chapterLoader;

  /// Como ler as imagens do livro (padrão: num isolate — D-114).
  final EpubImageLoader Function(String path)? imageLoader;

  /// Relógio dos prazos da tela (a volta do link — 6 s). Os testes andam com ele à mão.
  final Timer Function(Duration duration, void Function() callback) startTimer;

  /// Prepara o PDFium (padrão: o do `pdfrx` para Flutter).
  final Future<void> Function()? pdfInitialize;
  final ReaderErrorReporter onError;
}

class ReaderSessionController extends ChangeNotifier {
  ReaderSessionController({required this.userBookId, required this.deps});

  final String userBookId;
  final ReaderDeps deps;

  ReaderState _state = const ReaderOpening();
  ReaderState get state => _state;

  /// Cores do papel escolhido (ajustes da pessoa; Creme até os ajustes serem lidos).
  ReaderPalette get palette => _palette;
  ReaderPalette _palette = ReaderPalette.of(ReaderPaper.creme);

  /// Áreas da tela (D-112) para a última abertura.
  ReaderInsets get insets => _insets;
  ReaderInsets _insets = ReaderInsets.of(EdgeInsets.zero);

  /// Medidas da página (margens, caixa do texto) da última abertura.
  ReaderTypography? get typography => _typography;
  ReaderTypography? _typography;

  ReaderViewport? _viewport;
  ReaderDocument? _doc;
  ReadingSessionTracker? _tracker;
  KeepAwake? _awake;
  ReaderMark? _lastMark;
  BackLink? _back;
  Timer? _backTimer;
  int _backTurns = 0;
  bool _closed = false;
  bool _disposed = false;
  int _opening = 0;

  /// Abre o livro para [v]. Pode ser chamado de novo ("Tentar de novo").
  Future<void> open(ReaderViewport v) async {
    _viewport = v;
    _insets = ReaderInsets.of(v.padding);
    final gen = ++_opening;
    _set(const ReaderOpening());
    await _detach(); // "Tentar de novo" depois de uma falha no meio da leitura: o livro de antes sai
    try {
      final result = await _open(v, gen);
      if (gen != _opening || _closed || _disposed) {
        if (result is ReaderDocument) result.dispose();
        return;
      }
      switch (result) {
        case final ReaderFailure f:
          _set(ReaderFailed(f));
        case final ReaderDocument d:
          _attach(d);
          _set(ReaderReady(d));
      }
    } on ContentFailure {
      if (gen == _opening) _set(const ReaderFailed(ReaderFailure.damaged));
    } on PagerClosed {
      // a tela saiu no meio da abertura
    } on Object catch (e, st) {
      deps.onError(e, st);
      if (gen == _opening) _set(const ReaderFailed(ReaderFailure.unexpected));
    }
  }

  /// "Tentar de novo" depois de uma falha inesperada.
  Future<void> retry() async {
    final v = _viewport;
    if (v != null) await open(v);
  }

  /// `ReaderFailure` ou `ReaderDocument`.
  Future<Object> _open(ReaderViewport v, int gen) async {
    final owner = await deps.owner();
    final book = await UserBooksDao(deps.db).byId(userBookId);
    if (book == null || book.meta.isDeleted || book.meta.userId != owner) {
      return ReaderFailure.notOnShelf;
    }
    if (book.format == BookFileFormat.physical) {
      return ReaderFailure.fileMissing;
    }
    final file = await LocalFilesDao(deps.db).byBook(userBookId);
    final path = file == null ? null : await _existing(file.path);
    if (file == null || path == null) return ReaderFailure.fileMissing;
    final settings = await ReaderSettingsDao(deps.db).forUser(owner);
    _palette = ReaderPalette.of(settings?.paper ?? ReaderPaper.creme);
    final t = _typography = _typographyFor(settings, v);
    if (book.format == BookFileFormat.pdf) {
      return _openPdf(book, path, file.sha256, v);
    }
    return _openEpub(book, path, file.sha256, t, v, gen);
  }

  /// O PDF básico (D-109): página inteira, sem o motor de texto.
  Future<Object> _openPdf(
    UserBook book,
    String path,
    String sha,
    ReaderViewport v,
  ) async {
    final keeper = PdfPositionKeeper(
      db: deps.db,
      versioning: deps.versioning,
      owner: deps.owner,
      userBookId: userBookId,
      sha: sha,
      deviceId: deps.deviceId,
      onError: deps.onError,
    );
    try {
      return await PdfReaderDocument.open(
        book: book,
        path: path,
        keeper: keeper,
        viewport: v.size,
        top: v.padding.top,
        footerBottom: _insets.footerBottom,
        devicePixelRatio: v.devicePixelRatio,
        initialize: deps.pdfInitialize,
      );
    } on Object {
      keeper.dispose();
      rethrow;
    }
  }

  Future<Object> _openEpub(
    UserBook book,
    String path,
    String sha,
    ReaderTypography t,
    ReaderViewport v,
    int gen,
  ) async {
    final dao = BookContentIndexDao(deps.db);
    var index = await dao.byBook(userBookId);
    if (index == null ||
        index.contentSha256 != sha ||
        index.refPageVersion != refPageVersion) {
      if (gen == _opening) _set(const ReaderOpening(preparing: true));
      await deps.indexBook(userBookId);
      index = await dao.byBook(userBookId);
      if (index == null || index.contentSha256 != sha) {
        return ReaderFailure.damaged;
      }
    }
    if (index.layout == 'fixed') return ReaderFailure.fixedLayout;
    final keeper = ReadingPositionKeeper(
      db: deps.db,
      versioning: deps.versioning,
      owner: deps.owner,
      userBookId: userBookId,
      index: index,
      deviceId: deps.deviceId,
      onError: deps.onError,
    );
    try {
      return await EpubReaderDocument.open(
        EpubDocumentDeps(
          book: book,
          index: index,
          path: path,
          typography: t,
          scheduler: deps.scheduler,
          keeper: keeper,
          cache: PagerCacheKey(
            userBookId: userBookId,
            devicePixelRatio: v.devicePixelRatio,
            dao: PageLayoutCacheDao(deps.db),
          ),
          loader: deps.chapterLoader?.call(path),
          images: deps.imageLoader?.call(path),
          devicePixelRatio: v.devicePixelRatio,
        ),
      );
    } on Object {
      keeper.dispose();
      rethrow;
    }
  }

  ReaderTypography _typographyFor(ReaderSettings? s, ReaderViewport v) {
    final w = v.size.width;
    final h = v.size.height;
    if (s != null) {
      return ReaderTypography.fromSettings(
        s,
        viewportWidth: w,
        viewportHeight: h,
        topInset: _insets.top,
        bottomInset: _insets.bottom,
        ink: _palette.text,
      );
    }
    return ReaderTypography(
      viewportWidth: w,
      viewportHeight: h,
      topInset: _insets.top,
      bottomInset: _insets.bottom,
      ink: _palette.text,
    );
  }

  /// O caminho guardado, ou o mesmo nome na pasta dos livros de agora (como a importação — G09).
  Future<String?> _existing(String stored) async {
    if (File(stored).existsSync()) return stored;
    final name = stored.split(RegExp(r'[/\\]')).last;
    final moved =
        '${(await deps.booksDir()).path}${Platform.pathSeparator}$name';
    return File(moved).existsSync() ? moved : null;
  }

  void _attach(ReaderDocument d) {
    _doc = d;
    _tracker = ReadingSessionTracker(
      db: deps.db,
      versioning: deps.versioning,
      owner: deps.owner,
      userBookId: userBookId,
      deviceId: deps.deviceId,
      now: deps.now,
      elapsed: deps.elapsed,
      autoTick: deps.autoTick,
      onError: deps.onError,
    );
    _awake = KeepAwake(deps.screenAwake, onError: deps.onError);
    d.changes.addListener(_pageChanged);
    _pageChanged();
  }

  /// A página mostrada mudou: o tempo recebe as páginas de referência dela (se mudou de lugar) e a tela, os
  /// números novos.
  void _pageChanged() {
    final d = _doc;
    if (d == null || _disposed) return;
    final m = d.mark;
    if (m != _lastMark) {
      _lastMark = m;
      final r = d.shownRange;
      unawaited(_tracker?.pageShown(r.fromRef, r.toRef));
    }
    notifyListeners();
  }

  /// A página está (ou deixou de estar) na tela.
  void setVisible(bool visible) {
    unawaited(_tracker?.setVisible(visible));
    if (visible) {
      _awake?.touch();
    } else {
      _awake?.stop();
    }
  }

  /// Toque, arrasto: conta como leitura (D-95) e segura a tela acesa (D-111).
  void interaction() {
    unawaited(_tracker?.interaction());
    _awake?.touch();
  }

  /// Ciclo de vida do app: em segundo plano (escondido, pausado) pausa o tempo, grava a posição e solta a
  /// tela. "Inativo" (a central de controle por cima, uma ligação chegando) ainda é a leitura na tela.
  Future<void> lifecycle(AppLifecycleState s) async {
    final foreground =
        s == AppLifecycleState.resumed || s == AppLifecycleState.inactive;
    await _tracker?.setForeground(foreground);
    if (foreground) {
      _awake?.touch();
    } else {
      _awake?.stop();
      await _doc?.flush();
    }
  }

  /// Vira; `false` = começo/fim do livro, ou não deu (a falha vira o aviso da D-21).
  Future<bool> turn(PageDirection d) {
    final doc = _doc;
    if (doc == null || _closed || _state is ReaderFailed) {
      return Future.value(false);
    }
    interaction();
    return _serial(() async {
      if (_closed || !identical(_doc, doc)) return false;
      try {
        final ok = await doc.turn(d);
        if (ok && _back != null && ++_backTurns >= backLinkTurns) _clearBack();
        return ok;
      } on Object catch (e, st) {
        return _navFailed(e, st);
      }
    });
  }

  /// Segue um link interno e guarda a volta (D-108). [timed] = a volta some em 6 s; com o leitor de tela ela
  /// fica até as 2 viradas (D-116). Enquanto a volta vale, a posição gravada é a de onde se saiu (D-115).
  Future<bool> follow(LinkHit link, {bool timed = true}) {
    final doc = _doc;
    if (doc == null || _closed || _state is ReaderFailed) {
      return Future.value(false);
    }
    interaction();
    return _serial(() async {
      if (_closed || !identical(_doc, doc)) return false;
      final from = doc.mark;
      final refPage = doc.numbers.refPage;
      try {
        final ok = await doc.follow(link);
        if (!ok || _disposed || _closed) return ok;
        _back = (mark: from, refPage: refPage);
        _backTurns = 0;
        _backTimer?.cancel();
        _backTimer = timed ? deps.startTimer(backLinkLife, _clearBack) : null;
        await doc.pin(from);
        _set(ReaderReady(doc, back: _back));
        return true;
      } on Object catch (e, st) {
        return _navFailed(e, st);
      }
    });
  }

  /// "Voltar à pág. N": de volta ao caractere de onde se saiu.
  Future<void> back() {
    final doc = _doc;
    final b = _back;
    if (doc == null || b == null || _closed || _state is ReaderFailed) {
      return Future.value();
    }
    interaction();
    return _serial(() async {
      if (_closed || !identical(_back, b)) return;
      _clearBack();
      try {
        await doc.goTo(b.mark);
      } on Object catch (e, st) {
        _navFailed(e, st);
      }
    });
  }

  void _clearBack() {
    _backTimer?.cancel();
    _backTimer = null;
    if (_back == null) return;
    _back = null;
    final doc = _doc;
    if (doc == null || _disposed) return;
    unawaited(
      doc
          .pin(null)
          .catchError((Object e, StackTrace st) => deps.onError(e, st)),
    );
    if (!_closed) _set(ReaderReady(doc));
  }

  /// Virar, seguir link e voltar em fila: um termina antes do outro começar (a volta de um link fica gravada
  /// antes da virada seguinte contar).
  Future<void> _nav = Future<void>.value();

  Future<T> _serial<T>(Future<T> Function() f) {
    final run = _nav.then((_) => f());
    _nav = run.then<void>((_) {}, onError: (Object _) {});
    return run;
  }

  /// Virar, seguir ou voltar falhou: arquivo danificado → o aviso da D-21; o resto é relatado e vira "Não deu
  /// para abrir o livro agora" com "Tentar de novo" (reabre onde a pessoa estava).
  bool _navFailed(Object e, StackTrace st) {
    if (e is PagerClosed || _closed || _disposed) return false;
    if (e is ContentFailure) {
      _set(const ReaderFailed(ReaderFailure.damaged));
    } else {
      deps.onError(e, st);
      _set(const ReaderFailed(ReaderFailure.unexpected));
    }
    return false;
  }

  /// Solta o livro aberto (antes de reabrir): grava a posição e o tempo dele.
  Future<void> _detach() async {
    final doc = _doc;
    if (doc == null) return;
    final tracker = _tracker;
    doc.changes.removeListener(_pageChanged);
    _doc = null;
    _tracker = null;
    _lastMark = null;
    _backTimer?.cancel();
    _backTimer = null;
    _back = null;
    _awake?.stop();
    try {
      await doc.flush();
      await tracker?.close();
    } on Object catch (e, st) {
      deps.onError(e, st);
    }
    tracker?.dispose();
    doc.dispose();
  }

  /// Sai do livro: grava a posição e fecha o tempo (a tela chama ao fechar ou voltar). Chamar de novo devolve
  /// o mesmo fechamento.
  Future<void> close() => _closing ??= _close();
  Future<void>? _closing;

  Future<void> _close() async {
    _closed = true;
    _backTimer?.cancel();
    _awake?.stop();
    try {
      await _doc?.flush();
      await _tracker?.close();
    } on Object catch (e, st) {
      deps.onError(e, st);
    }
  }

  void _set(ReaderState s) {
    if (_disposed) return;
    _state = s;
    notifyListeners();
  }

  /// Fecha (se ninguém fechou) e solta o livro quando o fechamento terminar — a posição e o tempo não se
  /// perdem quando a tela sai sem esperar.
  @override
  void dispose() {
    _disposed = true;
    _opening++;
    final doc = _doc;
    final tracker = _tracker;
    doc?.changes.removeListener(_pageChanged);
    unawaited(
      close().whenComplete(() {
        tracker?.dispose();
        doc?.dispose();
      }),
    );
    super.dispose();
  }
}

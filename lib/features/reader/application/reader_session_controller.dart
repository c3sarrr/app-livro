// G11.2 — a sessão de leitura de uma tela aberta (desenho G11 §2): abre o livro da estante pelo id (o arquivo, o
// índice — indexa ao abrir se faltar —, os ajustes e a posição), diz por que não abriu (D-21, D-92, D-113), e
// liga a página mostrada ao tempo automático (D-95), à posição salva (G10) e à tela acesa (D-111). Guarda uma
// volta depois de seguir um link (D-108): some em 6 s ou em 2 viradas. G12: a mesma volta depois de um salto pela
// barra ou pela busca (D-119), o marcador da página (fita), o Tema da conta (D-121), os minutos de hoje e o tempo
// restante (D-97), e o livro físico (D-123). G14.2 — os ajustes de leitura da folha (tela 26): grava com versão,
// repagina no caractere que a pessoa lia e guarda o último papel claro; o Tema passa pelo mesmo caminho (D-121,
// D-144).
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/painting.dart' show Color, EdgeInsets, Size;
import 'package:flutter/widgets.dart' show AppLifecycleState;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/content_daos.dart';
import '../../../core/data/database/daos/kv_dao.dart';
import '../../../core/data/database/daos/library_daos.dart';
import '../../../core/data/database/daos/reader_daos.dart';
import '../../../core/data/database/versioning.dart';
import '../../../core/data/ids/uuid_v7.dart';
import '../../../core/data/model/record_meta.dart';
import '../../library/domain/user_book.dart';
import '../annotations/ink_repository.dart' show InkRepository;
import '../content/content_failure.dart';
import '../content/ref_pages.dart' show refPageVersion;
import '../domain/bookmark.dart';
import '../domain/reader_settings.dart';
import '../domain/reading_speed.dart' show defaultCharsPerMinute, timeLeftFor;
import '../layout/layout_scheduler.dart';
import '../layout/reader_typography.dart';
import '../presentation/reader_insets.dart';
import '../presentation/reader_palette.dart';
import 'book_pager.dart';
import 'book_search.dart' show EpubSearchRunner;
import 'epub_images.dart' show EpubImageLoader;
import 'epub_reader_document.dart';
import 'pdf_position_keeper.dart';
import 'pdf_reader_document.dart';
import 'reader_club_source.dart';
import 'reader_document.dart';
import 'reader_errors.dart';
import 'reading_position_keeper.dart';
import 'reading_session_tracker.dart';
import 'reading_session_tracker.dart' as sessions show minutesToday;
import 'reading_speed_source.dart';
import 'screen_awake.dart';

/// Por que o livro não abriu (textos na tela — G11 §3; [physical] — D-123).
enum ReaderFailure {
  notOnShelf,
  fileMissing,
  damaged,
  fixedLayout,
  physical,
  unexpected,
}

/// O último papel claro (Creme, Branco ou Sépia), para o Tema voltar a ele saindo do Noite (D-121). Fica no
/// aparelho (`kv`).
const String lastLightPaperKey = 'pref.leitor.papelClaro';

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
    this.searchRunner,
    this.speedOf = readingSpeedOf,
    this.startTimer = Timer.new,
    this.pdfInitialize,
    this.club = const NoReaderClub(),
    this.utcOffsetAt = readerUtcOffset,
    this.onError = reportReaderError,
    this.inkRepository,
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

  /// Como buscar no EPUB (padrão: num isolate — D-120); os testes buscam na hora.
  final EpubSearchRunner? searchRunner;

  /// A velocidade pessoal da conta (D-97). As fases L20/L26b trocam pela que dá o "≈ 2 h 10 min" que a prancha
  /// escreve à mão (desvio registrado na G12).
  final Future<double> Function(AppDatabase db, String userId) speedOf;

  /// Relógio dos prazos da tela (a volta do link — 6 s). Os testes andam com ele à mão.
  final Timer Function(Duration duration, void Function() callback) startTimer;

  /// Prepara o PDFium (padrão: o do `pdfrx` para Flutter).
  final Future<void> Function()? pdfInitialize;

  /// O clube que lê o livro, para a faixa do sumário (D-149): nenhum até a G21.
  final ReaderClubSource club;

  /// O fuso nas datas da folha do sumário ("marcada hoje", "QUI 24/9").
  final Duration Function(DateTime utc) utcOffsetAt;
  final ReaderErrorReporter onError;

  /// Onde a tinta grava (G16); `null` = no banco ([db], com [versioning]). Os testes trocam (a falha ao salvar).
  final InkRepository? inkRepository;
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

  /// O papel escolhido (Tema — D-121).
  ReaderPaper get paper => _look.paper;

  /// Os ajustes da conta (a folha da tela 26; os padrões da tela 26 enquanto a conta não tem linha).
  ReaderLook get look => _look;
  ReaderLook _look = const ReaderLook();

  /// Repaginações pedidas: só a mais nova relata falha (as anteriores terminam com ela).
  int _retypes = 0;

  /// A mais nova ainda está em curso: trocar só o papel no meio dela vai junto com ela (sem segurar a fila).
  bool _retyping = false;

  /// Velocidade pessoal da conta (D-97), lida ao abrir.
  double _speed = defaultCharsPerMinute;

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

  /// A volta tem o prazo de 6 s (sem o leitor de tela — D-116).
  bool _backTimed = true;

  /// Os controles ou a busca por cima da página: a pílula está escondida (D-125).
  bool _backHeld = false;
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
      return ReaderFailure.physical;
    }
    final file = await LocalFilesDao(deps.db).byBook(userBookId);
    final path = file == null ? null : await _existing(file.path);
    if (file == null || path == null) return ReaderFailure.fileMissing;
    final settings = await ReaderSettingsDao(deps.db).forUser(owner);
    _look = settings?.look ?? const ReaderLook();
    _palette = ReaderPalette.of(_look.paper);
    // a tela já pinta o "abrindo" no papel da conta (no Noite, sem passar pelo Creme)
    if (!_disposed) notifyListeners();
    final t = _typography = _typographyFor(_look, v, _palette.text);
    try {
      _speed = await deps.speedOf(deps.db, owner);
    } on Object catch (e, st) {
      // o tempo restante é acessório: fica a velocidade padrão (D-97)
      deps.onError(e, st);
      _speed = defaultCharsPerMinute;
    }
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
    // índice de antes da G15 (sem os numerais do texto): refeito uma vez (D-154)
    if (index == null ||
        index.contentSha256 != sha ||
        index.refPageVersion != refPageVersion ||
        !index.tocUpToDate) {
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
          search: deps.searchRunner,
          devicePixelRatio: v.devicePixelRatio,
        ),
      );
    } on Object {
      keeper.dispose();
      rethrow;
    }
  }

  ReaderTypography _typographyFor(ReaderLook l, ReaderViewport v, Color ink) =>
      ReaderTypography.fromLook(
        l,
        viewportWidth: v.size.width,
        viewportHeight: v.size.height,
        topInset: _insets.top,
        bottomInset: _insets.bottom,
        ink: ink,
      );

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
        if (ok &&
            _back != null &&
            !_backHeld &&
            ++_backTurns >= backLinkTurns) {
          _clearBack();
        }
        return ok;
      } on Object catch (e, st) {
        return _navFailed(e, st);
      }
    });
  }

  /// Segue um link interno e guarda a volta (D-108). [timed] = a volta some em 6 s; com o leitor de tela ela
  /// fica até as 2 viradas (D-116). Enquanto a volta vale, a posição gravada é a de onde se saiu (D-115); outro
  /// salto (link, barra, busca) mantém a volta para antes do 1º e recomeça o prazo (D-126).
  Future<bool> follow(LinkHit link, {bool timed = true}) =>
      _jump((doc) => doc.follow(link), timed: timed);

  /// Os controles ou a busca abriram ([held]) ou fecharam por cima da página (D-125): a pílula da volta fica
  /// escondida e o prazo dela (os 6 s e as 2 viradas) só conta com ela à vista — ao fechar, começa do zero.
  void holdBack(bool held) {
    if (_backHeld == held) return;
    _backHeld = held;
    if (_back == null) return;
    _startBackDeadline();
  }

  /// Zera as viradas e (re)começa os 6 s da volta, se ela está à vista e tem prazo.
  void _startBackDeadline() {
    _backTimer?.cancel();
    _backTimer = null;
    _backTurns = 0;
    if (_backTimed && !_backHeld) {
      _backTimer = deps.startTimer(backLinkLife, _clearBack);
    }
  }

  /// Salta para [to] (barra de posição, resultado da busca) e guarda a volta como o link (D-119). [found] = a
  /// ocorrência da busca a marcar na página (D-120). Para a mesma página de referência não guarda volta.
  Future<bool> jumpTo(ReaderMark to, {FoundRange? found, bool timed = true}) =>
      _jump(
        (doc) async {
          await doc.goTo(to);
          return true;
        },
        timed: timed,
        found: found,
      );

  /// A barra de posição (D-22, D-119): salta para a página de referência [refPage] e guarda a volta.
  Future<bool> jumpToPage(int refPage, {bool timed = true}) =>
      _jump((doc) async {
        final before = doc.numbers.refPage;
        await doc.goToRefPage(refPage);
        // página da tela maior que a de referência (tablet, letra pequena): nenhuma começa na pág. pedida e o
        // salto pode ficar onde estava — para a frente, anda uma página da tela (o "aumentar" do leitor de tela)
        if (refPage > before && doc.numbers.refPage <= before) {
          await doc.turn(PageDirection.forward);
        }
        return true;
      }, timed: timed);

  Future<bool> _jump(
    Future<bool> Function(ReaderDocument doc) go, {
    required bool timed,
    FoundRange? found,
  }) {
    final doc = _doc;
    if (doc == null || _closed || _state is ReaderFailed) {
      return Future.value(false);
    }
    interaction();
    return _serial(() async {
      if (_closed || !identical(_doc, doc)) return false;
      // saltos seguidos (D-126): enquanto a volta vale, ela continua para antes do 1º salto
      final kept = _back;
      final origin = kept ?? (mark: doc.mark, refPage: doc.numbers.refPage);
      final before = doc.numbers.refPage;
      try {
        final ok = await go(doc);
        if (!ok || _disposed || _closed) return ok;
        if (found != null) doc.showFound(found);
        final now = doc.numbers.refPage;
        if (now == before) return true;
        if (now == origin.refPage) {
          // de volta à página de onde se saiu: não há para onde voltar (D-119)
          _clearBack();
          return true;
        }
        _back = origin;
        _backTimed = timed;
        _startBackDeadline();
        if (kept == null) await doc.pin(origin.mark);
        _set(ReaderReady(doc, back: origin));
        return true;
      } on Object catch (e, st) {
        return _navFailed(e, st);
      }
    });
  }

  /// A fita da ilha de cima: marca a página de referência mostrada ou tira o marcador dela (tombstone).
  Future<void> toggleBookmark() {
    final doc = _doc;
    if (doc == null || _closed || _state is ReaderFailed) return Future.value();
    interaction();
    return _serial(() async {
      if (_closed || !identical(_doc, doc)) return;
      try {
        final draft = doc.bookmarkHere();
        final owner = await deps.owner();
        final dao = BookmarksDao(deps.db);
        final here = [
          for (final b in await dao.forBook(userBookId))
            if (b.refPage == draft.refPage) b,
        ];
        if (here.isNotEmpty) {
          for (final b in here) {
            await deps.versioning.write('bookmarks', b.id, (v) async {
              final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
              await dao.upsert(b.copyWith(meta: b.meta.deleted(at, v)));
            });
          }
          return;
        }
        final id = UuidV7Generator().next();
        await deps.versioning.write('bookmarks', id, (v) async {
          final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
          await dao.upsert(
            Bookmark(
              id: id,
              meta: RecordMeta(
                userId: owner,
                createdAt: at,
                updatedAt: at,
                version: v,
              ),
              userBookId: userBookId,
              locator: draft.locator,
              refPage: draft.refPage,
              chapterIndex: draft.chapterIndex,
              excerpt: draft.excerpt.isEmpty ? null : draft.excerpt,
            ),
          );
        });
      } on Object catch (e, st) {
        deps.onError(e, st);
      }
    });
  }

  /// A fita da aba Marcadas (tela 27b, D-152): tira ([on] falso) ou devolve a marca [b] — a mesma linha, com o mesmo
  /// excerto e a mesma data —, na fila e com versão. Vale a linha do banco, lida na hora de gravar (pode ter vindo de
  /// outro aparelho): tirar a que já está tirada, ou devolver a que já está viva, não grava nada. Falha: relatada.
  /// Termina com `true` quando a marca ficou como pedida; `false` quando a gravação falhou ou a sessão fechou (a folha
  /// volta a mostrar o que o banco diz).
  Future<bool> setBookmark(Bookmark b, {required bool on}) {
    if (_closed) return Future.value(false);
    interaction();
    return _serial(() async {
      try {
        final dao = BookmarksDao(deps.db);
        await deps.versioning.write('bookmarks', b.id, (v) async {
          final cur = await dao.byId(b.id) ?? b;
          if (cur.meta.isDeleted != on) return;
          final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
          await dao.upsert(
            cur.copyWith(
              meta: on ? cur.meta.restored(at, v) : cur.meta.deleted(at, v),
            ),
          );
        });
        return true;
      } on Object catch (e, st) {
        deps.onError(e, st);
        return false;
      }
    });
  }

  /// A folha de ajustes (tela 26, D-144): aplica [change] sobre os ajustes mais novos da conta (os da linha do
  /// banco, que podem ter vindo de outro aparelho — D-148), na fila (toques rápidos somam), e grava a linha com
  /// versão; a tela passa a mostrar a linha inteira. Se o papel mudou, guarda o último claro (D-121). Tamanho, fonte,
  /// entrelinha e margens repaginam na página do caractere que a pessoa lia; a repaginação mais nova passa na
  /// frente, sem segurar a fila. Só o papel troca a cor do texto sem repaginar (no meio de uma repaginação, vai
  /// junto com ela). Falha ao gravar: relatada, e tudo fica como estava; falha ao guardar o último claro: relatada,
  /// e o ajuste vale. Se a sessão reabriu enquanto gravava, o ajuste vai para o livro de agora. Termina quando a
  /// página nova chega.
  Future<void> applySettings(ReaderLookChange change) async {
    final doc = _doc;
    if (doc == null || _closed || _state is ReaderFailed) return;
    interaction();
    final pending = await _serial(() => _applyLook(doc, change));
    await pending?.relayout;
  }

  /// O botão Tema (D-37, D-121): de um papel claro para o Noite e do Noite de volta ao último claro (Creme se não
  /// houver) — o mesmo caminho da folha: grava no ajuste da conta e o texto troca de cor sem repaginar.
  Future<void> toggleTheme() async {
    final doc = _doc;
    if (doc == null || _closed || _state is ReaderFailed) return;
    interaction();
    await _serial(() async {
      final ReaderPaper next;
      try {
        next = _look.paper == ReaderPaper.noite
            ? await _lastLight()
            : ReaderPaper.noite;
      } on Object catch (e, st) {
        deps.onError(e, st);
        return null;
      }
      return _applyLook(doc, (l) => l.copyWith(paper: next));
    });
  }

  Future<ReaderPaper> _lastLight() async {
    final light = await KvDao(deps.db).get(lastLightPaperKey);
    return ReaderPaper.values.firstWhere(
      (p) => p.code == light && p != ReaderPaper.noite,
      orElse: () => ReaderPaper.creme,
    );
  }

  /// Aplica (na fila): grava, troca a cor ou pede a repaginação e avisa a tela. `relayout` = a repaginação em
  /// curso (quem pediu espera por ela; a fila não).
  Future<({Future<void> relayout})?> _applyLook(
    ReaderDocument doc,
    ReaderLookChange change,
  ) async {
    if (_closed || !identical(_doc, doc)) return null;
    final ReaderLook? next;
    try {
      next = await _save(change);
    } on Object catch (e, st) {
      // ajuste é conforto: uma falha do banco não derruba a leitura (tudo fica como estava)
      deps.onError(e, st);
      return null;
    }
    if (next == null) return null; // a mesma escolha: nada a gravar
    // enquanto gravava, a sessão pode ter reaberto ("Tentar de novo"): o ajuste gravado vai para o livro de agora
    final now = _doc;
    if (_closed || _disposed || now == null || _state is ReaderFailed) {
      return null;
    }
    final was = _look;
    if (next == was) return null; // a reabertura já leu o ajuste gravado
    final palette = ReaderPalette.of(next.paper);
    Future<void>? relayout;
    if (next.sameLayout(was) && !_retyping) {
      // só o papel: o texto troca de cor antes (as mesmas quebras); o papel e as ilhas animam em seguida
      try {
        await now.recolor(palette.text);
      } on Object catch (e, st) {
        _navFailed(e, st);
        return null;
      }
      if (_closed || _disposed || !identical(_doc, now)) return null;
      _typography = _typography?.withInk(palette.text);
    } else {
      relayout = _retype(
        now,
        _typography = _typographyFor(next, _viewport!, palette.text),
      );
    }
    _look = next;
    _palette = palette;
    notifyListeners();
    return relayout == null ? null : (relayout: relayout);
  }

  /// Repagina [doc] com [t] fora da fila: a mais nova passa na frente e só ela relata falha.
  Future<void> _retype(ReaderDocument doc, ReaderTypography t) {
    final gen = ++_retypes;
    _retyping = true;
    return doc
        .retypeset(t)
        .then<void>(
          (_) {},
          onError: (Object e, StackTrace st) {
            if (gen == _retypes) _navFailed(e, st);
          },
        )
        .whenComplete(() {
          if (gen == _retypes) _retyping = false;
        });
  }

  /// Grava [change] sobre a linha da conta (D-148: os ajustes mais novos, mesmo os vindos de outro aparelho; sem
  /// linha, os da sessão — os padrões da tela 26), com versão HLC. Devolve os ajustes gravados, ou `null` se a
  /// mudança não muda nada. O último claro (D-121) vai só depois do ajuste gravado: o papel claro escolhido, ou o
  /// claro que se deixou pelo Noite (a falha dele é relatada e não desfaz o ajuste).
  Future<ReaderLook?> _save(ReaderLookChange change) async {
    final owner = await deps.owner();
    final dao = ReaderSettingsDao(deps.db);
    final from = (await dao.forUser(owner))?.look ?? _look;
    if (change(from) == from) return null;
    late ReaderLook next;
    await deps.versioning.write('reader_settings', owner, (v) async {
      final at = DateTime.fromMillisecondsSinceEpoch(v.ms, isUtc: true);
      // de novo dentro da transação: o que chegou entre a leitura e a gravação também fica
      final old = await dao.forUser(owner);
      next = change(old?.look ?? from);
      await dao.upsert(
        old == null
            ? ReaderSettings(
                id: owner,
                meta: RecordMeta(
                  userId: owner,
                  createdAt: at,
                  updatedAt: at,
                  version: v,
                ),
              ).withLook(next)
            : old.withLook(next, meta: old.meta.edited(at, v)),
      );
    });
    await _saveLastLight(from, next);
    return next;
  }

  /// O último claro (D-121): o papel claro escolhido, ou o claro que se deixou pelo Noite.
  Future<void> _saveLastLight(ReaderLook from, ReaderLook next) async {
    if (next.paper == from.paper) return;
    final light = next.paper != ReaderPaper.noite ? next.paper : from.paper;
    if (light == ReaderPaper.noite) return;
    try {
      await KvDao(deps.db).set(lastLightPaperKey, light.code);
    } on Object catch (e, st) {
      // o ajuste já está gravado: só o Tema perde o último claro (volta ao Creme)
      deps.onError(e, st);
    }
  }

  /// "N min hoje" do chip (Anexo 03 §8): as sessões de hoje mais a aberta.
  Future<int> minutesToday() async => sessions.minutesToday(
    deps.db,
    userId: await deps.owner(),
    now: (deps.now ?? DateTime.now)(),
    open: _tracker,
  );

  /// Tempo para terminar (D-97): o que falta ÷ a velocidade; `null` na última página do livro (D-124).
  Duration? timeLeft() {
    final doc = _doc;
    if (doc == null || doc.atEnd) return null;
    final n = doc.numbers;
    return timeLeftFor(((1 - n.progression) * doc.totalChars).round(), _speed);
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

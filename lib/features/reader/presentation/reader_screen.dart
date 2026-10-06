// G11.3 — tela 19, o leitor limpo (`/leitor/:bookId`, L19): a página do livro sobre o papel, o rodapé
// "pág. X de Y · %" e nada mais. Por trás, a sessão de leitura (abrir, falhas, tempo, posição, tela acesa,
// links). A barra de status some com a página na tela (D-105) e volta no "abrindo", nos erros e ao sair; o
// Voltar do Android fecha gravando a posição; segundo plano pausa o tempo e grava (ciclo de vida). Leitor de
// tela: "Título, página X de Y", o texto da página e as ações Próxima/Anterior (Anexo 03 §11).
// G12.3 — telas 20/26b: o toque no centro abre os controles (D-117) por cima da página — véu, ilha de cima, chip
// de tempo e ilha de baixo —; o toque fora das ilhas e o arrasto fecham; o Voltar fecha primeiro os controles
// (D-42). Com os controles abertos a barra de status volta; no Noite, com ícones claros (D-124). O Tema troca o
// papel e as ilhas em 220 ms (D-121); a barra de posição salta (D-119); os botões das próximas fases mostram
// "Chega numa próxima fase" por 2 s (D-118). G12.4 — a lupa abre a busca no livro (D-120): o Voltar fecha
// primeiro o painel, depois os controles.
import 'dart:async';

import 'package:flutter/semantics.dart'
    show CustomSemanticsAction, SemanticsService;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/preferences/brand_preference.dart';
import '../../shell/presentation/main_shell.dart';
import '../application/pdf_reader_document.dart';
import '../application/reader_chrome.dart';
import '../application/reader_document.dart';
import '../application/reader_errors.dart';
import '../application/reader_providers.dart';
import '../application/reader_session_controller.dart';
import '../domain/reader_settings.dart';
import 'book_search_panel.dart';
import 'bottom_island.dart';
import 'reader_chrome_palette.dart';
import 'reader_controls.dart';
import 'reader_footer.dart';
import 'reader_overlays.dart';
import 'reader_page_view.dart';
import 'reader_palette.dart';
import 'reader_states.dart';
import 'time_chip.dart';
import 'top_island.dart';

/// No Noite a barra de status tem ícones claros (D-124); nos claros, o padrão do app (D-13).
/// A região vale para a tela toda: no Android, a barra de navegação (transparente, sem véu) também ganha ícones
/// claros, senão os botões somem no papel escuro.
const SystemUiOverlayStyle readerNightOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Color(0x00000000),
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Color(0x00000000),
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: false,
);

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.bookId});

  /// `user_books.id` do livro na estante.
  final String bookId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  ReaderSessionController? _c;
  AppLifecycleListener? _life;
  ReaderSystemUi? _ui;
  ReaderViewport? _viewport;
  bool _started = false;
  bool _depsFailed = false;
  bool _showOpening = false;
  Timer? _openingTimer;
  bool _immersive = false;

  /// Os controles da tela 20 estão abertos (D-117).
  bool _controls = false;

  /// O que as ilhas mostram, do documento aberto agora.
  ReaderChrome? _chrome;
  ReaderDocument? _chromeDoc;

  /// "Chega numa próxima fase" na tela (D-118).
  String? _toast;
  Timer? _toastTimer;

  /// O Tema anima (D-121) só depois que a primeira página apareceu: abrir já no Noite não passa pelo Creme.
  bool _themeAnimates = false;

  /// O painel da busca está aberto (D-120) e a busca do documento aberto (a última fica guardada).
  bool _search = false;
  BookSearchSession? _searchSession;
  bool _leaving = false;
  ReaderState? _lastState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _ui = ref.read(readerSystemUiProvider);
    _armOpening();
    // só o que a página usa (MediaQuery.of inteira refaria a tela a cada quadro do teclado da busca)
    final v = _viewport = (
      size: MediaQuery.sizeOf(context),
      padding: MediaQuery.viewPaddingOf(context),
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    unawaited(_start(v));
  }

  /// "Abrindo o livro…" só depois de 300 ms (D-113) — de novo a cada abertura ("Tentar de novo").
  void _armOpening() {
    _openingTimer?.cancel();
    _showOpening = false;
    _openingTimer = Timer(readerOpeningDelay, () {
      if (mounted) setState(() => _showOpening = true);
    });
  }

  Future<void> _start(ReaderViewport v) async {
    final ReaderDeps deps;
    try {
      deps = await ref.read(readerDepsProvider.future);
    } on Object catch (e, st) {
      reportReaderError(e, st);
      if (mounted) setState(() => _depsFailed = true);
      return;
    }
    if (!mounted) return;
    final c = ReaderSessionController(userBookId: widget.bookId, deps: deps)
      ..addListener(_changed);
    _life = AppLifecycleListener(
      onStateChange: (s) => unawaited(c.lifecycle(s)),
    );
    setState(() => _c = c);
    await c.open(v);
  }

  /// As dependências do leitor não vieram (banco, pasta): "Tentar de novo" pede de novo.
  void _retryDeps() {
    final v = _viewport;
    if (v == null) return;
    ref.invalidate(readerDepsProvider);
    setState(() => _depsFailed = false);
    _armOpening();
    unawaited(_start(v));
  }

  void _changed() {
    if (!mounted) return;
    final state = _c?.state;
    final before = _lastState;
    _lastState = state;
    final ready = state is ReaderReady;
    if (state is ReaderReady) {
      _ensureChrome(state.document);
      _chrome?.pageChanged();
    } else if (_controls || _search) {
      // o livro deixou de estar na tela (erro, reabertura): os controles e a busca fecham
      _controls = false;
      _search = false;
      _chrome?.ticking = false;
      _clearToast();
    }
    if (ready && !_themeAnimates) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _themeAnimates = true,
      );
    }
    if (ready && before is! ReaderReady) {
      // a página apareceu: conta como leitura e liga a tela acesa (depois, só toques e o ciclo de vida)
      _openingTimer?.cancel();
      _c!.setVisible(true);
    }
    if (state is ReaderOpening && before != null && before is! ReaderOpening) {
      _armOpening();
    }
    if (state is ReaderReady &&
        state.back != null &&
        (before is! ReaderReady || before.back == null)) {
      _announceBack(state.back!.refPage);
    }
    _systemUi(immersive: ready && !_controls && !_search);
    _holdBack();
    setState(() {});
  }

  /// Um `ReaderChrome` (e uma busca) por documento aberto ("Tentar de novo" abre outro).
  void _ensureChrome(ReaderDocument doc) {
    final c = _c;
    if (c == null || identical(_chromeDoc, doc)) return;
    _chrome?.dispose();
    _searchSession?.dispose();
    _searchSession = BookSearchSession(
      doc,
      startTimer: c.deps.startTimer,
      onError: c.deps.onError,
    );
    _chromeDoc = doc;
    _chrome = ReaderChrome(
      db: c.deps.db,
      userBookId: widget.bookId,
      refPage: () => doc.numbers.refPage,
      minutes: c.minutesToday,
      timeLeft: c.timeLeft,
      startTimer: c.deps.startTimer,
      onError: c.deps.onError,
    )..ticking = _controls;
  }

  /// Com o leitor de tela, a pílula que apareceu é anunciada (D-116).
  void _announceBack(int refPage) {
    if (!MediaQuery.accessibleNavigationOf(context)) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        'Voltar à pág. $refPage, no rodapé',
        TextDirection.ltr,
      ),
    );
  }

  /// Esconde a barra de status com a página na tela; devolve o padrão do app (D-13) só se escondeu.
  void _systemUi({required bool immersive}) {
    if (_immersive == immersive) return;
    _immersive = immersive;
    final ui = _ui;
    if (ui == null) return;
    unawaited(immersive ? ui.immersive() : ui.edgeToEdge());
  }

  // ---- fechar ----------------------------------------------------------------------------------------

  /// Abre ou fecha os controles (D-117): a barra de status volta com eles (D-105); o chip conta os minutos
  /// enquanto estão abertos (D-124).
  void _setControls(bool open) {
    if (_controls == open || _leaving) return;
    setState(() => _controls = open);
    _chrome?.ticking = open;
    if (!open) _clearToast();
    _systemUi(immersive: _c?.state is ReaderReady && !open && !_search);
    _holdBack();
  }

  /// A pílula da volta fica escondida com os controles ou a busca por cima: o prazo dela só conta à vista
  /// (D-125).
  void _holdBack() => _c?.holdBack(_controls || _search);

  void _tool(ReaderTool t) {
    final c = _c;
    if (c == null) return;
    switch (t) {
      case ReaderTool.theme:
        unawaited(c.toggleTheme());
      case ReaderTool.font:
      case ReaderTool.notes:
      case ReaderTool.annotate:
      case ReaderTool.toc:
        // Fonte → G14, Grifos → G19, Anotar → G16, Sumário → G15 (D-118)
        _showToast(readerSoonText);
    }
  }

  void _showToast(String text) {
    final c = _c;
    if (c == null) return;
    _toastTimer?.cancel();
    setState(() => _toast = text);
    _toastTimer = c.deps.startTimer(readerToastLife, () {
      if (mounted) setState(() => _toast = null);
    });
    if (MediaQuery.accessibleNavigationOf(context)) {
      unawaited(
        SemanticsService.sendAnnouncement(
          View.of(context),
          text,
          TextDirection.ltr,
        ),
      );
    }
  }

  void _clearToast() {
    _toastTimer?.cancel();
    _toastTimer = null;
    _toast = null;
  }

  /// A lupa da ilha de cima: o painel da busca por cima de tudo (D-120).
  void _openSearch() {
    if (_searchSession == null || _leaving) return;
    _clearToast();
    setState(() => _search = true);
    _systemUi(immersive: false);
    _holdBack();
  }

  /// ← do painel ou o Voltar: volta aos controles, que continuam abertos.
  void _closeSearch() {
    if (!_search) return;
    setState(() => _search = false);
    _systemUi(immersive: _c?.state is ReaderReady && !_controls);
    _holdBack();
  }

  /// Tocar num resultado: fecha o painel e os controles, salta para a ocorrência, marca a palavra e guarda a
  /// volta (D-119, D-120).
  void _pick(SearchHit hit) {
    final c = _c;
    if (c == null) return;
    setState(() => _search = false);
    _setControls(false);
    _systemUi(immersive: c.state is ReaderReady && !_controls);
    _holdBack();
    unawaited(
      c.jumpTo(
        hit.at,
        found: hit.found,
        timed: !MediaQuery.accessibleNavigationOf(context),
      ),
    );
  }

  /// Fecha o livro: grava, devolve a barra de status já na saída (não no fim da animação) e volta.
  void _leave() {
    if (_leaving) return;
    _leaving = true;
    _systemUi(immersive: false);
    unawaited(_c?.close());
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.inicio);
    }
  }

  @override
  void dispose() {
    _openingTimer?.cancel();
    _toastTimer?.cancel();
    _chrome?.dispose();
    _searchSession?.dispose();
    _life?.dispose();
    _systemUi(immersive: false);
    final c = _c;
    if (c != null) {
      c
        ..removeListener(_changed)
        ..setVisible(false)
        // fecha (grava a posição e o tempo) e solta o livro quando terminar
        ..dispose();
    }
    super.dispose();
  }

  // ---- montagem --------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final paper = c?.paper ?? ReaderPaper.creme;
    final target = c?.palette ?? ReaderPalette.of(ReaderPaper.creme);
    final chrome = c == null ? null : ReaderChromePalette.of(paper);
    final state = c?.state;
    // o Voltar do sistema fecha primeiro os controles (D-42); sem eles, pelo mesmo caminho do "Fechar o livro";
    // sem o gesto de voltar da borda (no iOS ele roubaria o arrasto para a página anterior)
    return AnnotatedRegion<SystemUiOverlayStyle>(
      key: const ValueKey('leitor.barraDeStatus'),
      value: paper == ReaderPaper.noite
          ? readerNightOverlayStyle
          : MainShell.overlayStyle,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_search) {
            _closeSearch();
          } else if (_controls) {
            _setControls(false);
          } else {
            _leave();
          }
        },
        // papel e ilhas trocam em 220 ms no Tema (D-121)
        child: TweenAnimationBuilder<ReaderPalette>(
          tween: ReaderPaletteTween(end: target),
          duration: _themeAnimates ? readerThemeDuration : Duration.zero,
          builder: (context, palette, _) => ColoredBox(
            color: palette.paper,
            child: switch (state) {
              ReaderReady() => _ready(c!, state, palette),
              ReaderFailed(:final failure) => ReaderFailureView(
                failure: failure,
                onBack: _leave,
                onRetry: c!.retry,
                palette: chrome,
              ),
              _ when _depsFailed => ReaderFailureView(
                failure: ReaderFailure.unexpected,
                onBack: _leave,
                onRetry: _retryDeps,
                palette: chrome,
              ),
              ReaderOpening(:final preparing) => ReaderOpeningView(
                visible: _showOpening,
                preparing: preparing,
                palette: chrome,
              ),
              null => ReaderOpeningView(visible: _showOpening),
            },
          ),
        ),
      ),
    );
  }

  Widget _ready(
    ReaderSessionController c,
    ReaderReady state,
    ReaderPalette palette,
  ) {
    final doc = state.document;
    final n = doc.numbers;
    final insets = c.insets;
    final t = c.typography!;
    final back = state.back;
    final brand = ref.watch(brandProvider);
    final chrome = _chrome;
    final search = _searchSession;
    // com o leitor de tela a volta fica até as 2 viradas (D-116)
    final timed = !MediaQuery.accessibleNavigationOf(context);
    return TweenAnimationBuilder<ReaderChromePalette>(
      tween: ReaderChromePaletteTween(end: ReaderChromePalette.of(c.paper)),
      duration: _themeAnimates ? readerThemeDuration : Duration.zero,
      builder: (context, islands, _) => Stack(
        children: [
          Positioned.fill(
            child: ReaderPageView(
              document: doc,
              onTurn: c.turn,
              onCenter: () => _setControls(!_controls),
              onLink: (hit) => c.follow(hit, timed: timed),
              onInteraction: c.interaction,
              controlsOpen: _controls,
              onDragStarted: () => _setControls(false),
              foundColor: brand,
              foundLightText: c.palette.lightText,
            ),
          ),
          // a caixa da página (r19.page): o nó do leitor de tela (sem filho que pegue toque: os toques passam
          // para a página embaixo)
          Positioned(
            left: t.sideMargin,
            top: insets.top,
            width: t.contentWidth,
            height: t.contentHeight,
            child: Semantics(
              key: const ValueKey('r19.page'),
              container: true,
              label: '${doc.title}, página ${n.refPage} de ${n.refTotal}',
              value: doc.current.spokenText,
              customSemanticsActions: {
                const CustomSemanticsAction(label: 'Próxima página'): () =>
                    unawaited(c.turn(PageDirection.forward)),
                const CustomSemanticsAction(label: 'Página anterior'): () =>
                    unawaited(c.turn(PageDirection.backward)),
                // o centro não é tocável pelo leitor de tela (D-116, D-117)
                CustomSemanticsAction(
                  label: _controls
                      ? 'Esconder os controles'
                      : 'Mostrar os controles',
                ): () =>
                    _setControls(!_controls),
                const CustomSemanticsAction(label: 'Fechar o livro'): _leave,
              },
              child: const SizedBox.expand(),
            ),
          ),
          ReaderFooter(
            numbers: n,
            palette: palette,
            bottom: insets.footerBottom,
          ),
          if (back != null)
            ReaderFooterGap(
              numbers: n,
              bottom: insets.footerBottom,
              // com os controles abertos a pílula fica sob a ilha de baixo: fora do leitor de tela também
              child: ExcludeSemantics(
                excluding: _controls,
                child: BackToPagePill(
                  refPage: back.refPage,
                  onTap: () => unawaited(c.back()),
                  palette: islands,
                ),
              ),
            ),
          if (chrome != null)
            Positioned.fill(
              child: ListenableBuilder(
                listenable: chrome,
                builder: (context, _) {
                  final toast = _toast;
                  return ReaderControls(
                    open: _controls,
                    palette: islands,
                    brand: brand,
                    top: TopIsland(
                      title: doc.title,
                      author: doc.author,
                      marked: chrome.marked,
                      onClose: _leave,
                      onSearch: _openSearch,
                      onBookmark: () => unawaited(c.toggleBookmark()),
                    ),
                    chip: TimeChip(label: chrome.chipLabel),
                    bottom: BottomIsland(
                      numbers: n,
                      timeLeftLabel: chrome.timeLeftLabel,
                      notes: chrome.notes,
                      isPdf: doc is PdfReaderDocument,
                      onJump: (page) =>
                          unawaited(c.jumpToPage(page, timed: timed)),
                      onTool: _tool,
                    ),
                    toast: toast == null ? null : ReaderToastPill(text: toast),
                  );
                },
              ),
            ),
          if (_search && search != null)
            Positioned.fill(
              // o painel cobre a tela: o leitor de tela não chega ao que está embaixo
              child: BlockSemantics(
                child: BookSearchPanel(
                  session: search,
                  paper: palette,
                  palette: islands,
                  brand: brand,
                  onClose: _closeSearch,
                  onPick: _pick,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

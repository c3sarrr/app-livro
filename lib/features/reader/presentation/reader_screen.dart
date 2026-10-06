// G11.3 — tela 19, o leitor limpo (`/leitor/:bookId`, L19): a página do livro sobre o papel, o rodapé
// "pág. X de Y · %" e nada mais. Por trás, a sessão de leitura (abrir, falhas, tempo, posição, tela acesa,
// links). A barra de status some com a página na tela (D-105) e volta no "abrindo", nos erros e ao sair; o
// Voltar do Android e o "Fechar o livro" provisório (D-106) fecham gravando a posição; segundo plano pausa o
// tempo e grava (ciclo de vida). Leitor de tela: "Título, página X de Y", o texto da página e as ações
// Próxima/Anterior (Anexo 03 §11).
import 'dart:async';

import 'package:flutter/semantics.dart'
    show CustomSemanticsAction, SemanticsService;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../application/reader_document.dart';
import '../application/reader_errors.dart';
import '../application/reader_providers.dart';
import '../application/reader_session_controller.dart';
import '../domain/reader_settings.dart';
import 'reader_footer.dart';
import 'reader_overlays.dart';
import 'reader_page_view.dart';
import 'reader_palette.dart';
import 'reader_states.dart';

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
  bool _closeVisible = false;
  Timer? _closeTimer;
  bool _immersive = false;
  bool _leaving = false;
  ReaderState? _lastState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _ui = ref.read(readerSystemUiProvider);
    _armOpening();
    final mq = MediaQuery.of(context);
    final v = _viewport = (
      size: mq.size,
      padding: mq.viewPadding,
      devicePixelRatio: mq.devicePixelRatio,
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
    _systemUi(immersive: ready);
    setState(() {});
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

  void _toggleClose() {
    _closeTimer?.cancel();
    setState(() => _closeVisible = !_closeVisible);
    if (_closeVisible) {
      _closeTimer = Timer(readerCloseLife, () {
        if (mounted) setState(() => _closeVisible = false);
      });
    }
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
    _closeTimer?.cancel();
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
    final palette = c?.palette ?? ReaderPalette.of(ReaderPaper.creme);
    final state = c?.state;
    // o Voltar do sistema fecha pelo mesmo caminho do "Fechar o livro"; sem o gesto de voltar da borda (no iOS
    // ele roubaria o arrasto para a página anterior)
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: ColoredBox(
        color: palette.paper,
        child: switch (state) {
          ReaderReady() => _ready(c!, state, palette),
          ReaderFailed(:final failure) => ReaderFailureView(
            failure: failure,
            onBack: _leave,
            onRetry: c!.retry,
          ),
          _ when _depsFailed => ReaderFailureView(
            failure: ReaderFailure.unexpected,
            onBack: _leave,
            onRetry: _retryDeps,
          ),
          ReaderOpening(:final preparing) => ReaderOpeningView(
            visible: _showOpening,
            preparing: preparing,
          ),
          null => ReaderOpeningView(visible: _showOpening),
        },
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
    return Stack(
      children: [
        Positioned.fill(
          child: ReaderPageView(
            document: doc,
            onTurn: c.turn,
            onCenter: _toggleClose,
            // com o leitor de tela a volta fica até as 2 viradas (D-116)
            onLink: (hit) => c.follow(
              hit,
              timed: !MediaQuery.accessibleNavigationOf(context),
            ),
            onInteraction: c.interaction,
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
              // o "Fechar" provisório só aparece com toque no centro (D-116)
              const CustomSemanticsAction(label: 'Fechar o livro'): _leave,
            },
            child: const SizedBox.expand(),
          ),
        ),
        ReaderFooter(numbers: n, palette: palette, bottom: insets.footerBottom),
        if (back != null)
          ReaderFooterGap(
            numbers: n,
            bottom: insets.footerBottom,
            child: BackToPagePill(
              refPage: back.refPage,
              onTap: () => unawaited(c.back()),
            ),
          ),
        ReaderCloseButton(visible: _closeVisible, onTap: _leave),
      ],
    );
  }
}

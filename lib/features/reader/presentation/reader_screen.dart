// G11.3 — tela 19, o leitor limpo (`/leitor/:bookId`, L19): a página do livro sobre o papel, o rodapé
// "pág. X de Y · %" e nada mais. Por trás, a sessão de leitura (abrir, falhas, tempo, posição, tela acesa,
// links). A barra de status some com a página na tela (D-105) e volta no "abrindo", nos erros e ao sair; o
// Voltar do Android e o "Fechar o livro" provisório (D-106) fecham gravando a posição; segundo plano pausa o
// tempo e grava (ciclo de vida). Leitor de tela: "Título, página X de Y", o texto da página e as ações
// Próxima/Anterior (Anexo 03 §11).
import 'dart:async';

import 'package:flutter/semantics.dart' show CustomSemanticsAction;
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
  bool _started = false;
  bool _depsFailed = false;
  bool _showOpening = false;
  Timer? _openingTimer;
  bool _closeVisible = false;
  Timer? _closeTimer;
  bool _immersive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _ui = ref.read(readerSystemUiProvider);
    _openingTimer = Timer(readerOpeningDelay, () {
      if (mounted) setState(() => _showOpening = true);
    });
    final mq = MediaQuery.of(context);
    unawaited(
      _start((
        size: mq.size,
        padding: mq.viewPadding,
        devicePixelRatio: mq.devicePixelRatio,
      )),
    );
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

  void _changed() {
    if (!mounted) return;
    final ready = _c?.state is ReaderReady;
    if (ready) {
      _openingTimer?.cancel();
      _c!.setVisible(true);
    }
    _systemUi(immersive: ready);
    setState(() {});
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

  void _leave() {
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
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) unawaited(_c?.close());
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
            onLink: (hit) => unawaited(c.follow(hit)),
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
            },
            child: const SizedBox.expand(),
          ),
        ),
        ReaderFooter(numbers: n, palette: palette, bottom: insets.footerBottom),
        if (back != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: insets.footerBottom - 9,
            child: Center(
              child: BackToPagePill(
                refPage: back.refPage,
                onTap: () => unawaited(c.back()),
              ),
            ),
          ),
        ReaderCloseButton(visible: _closeVisible, onTap: _leave),
      ],
    );
  }
}

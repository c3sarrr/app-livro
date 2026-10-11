// T04 — a folha da sessão do cronômetro (D-256, D-260, D-262). Nenhuma prancha a desenha (D-23): é uma folha mínima
// com os primitivos da D-21 (`account_widgets.dart`) na moldura das folhas da G21 (o véu, o cartão a 14 das bordas,
// raio 28, borda 1,5 e sombra dura) — listada em docs/design/estados_sem_design.md para o design desenhar depois.
// Abre por cima de tudo (navigator raiz) pelo toque na mini-barra ou pelo play de outro livro com a sessão aberta:
// mostra o livro e o tempo (que anda), pausa e retoma, pede a página (e o total, se o livro não tem), encerra
// (o writer grava — R7), descarta (com confirmação) e fecha. Aberta pelo play de outro livro (D-262), encerrar ou
// descartar começa a sessão dele; fechar não começa nada. Se encerrar, descartar, pausar ou retomar falha (o banco do
// aparelho fora do ar), o aviso de erro da folha diz "Não deu para … Tente de novo." e os botões voltam (D-266).
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, LengthLimitingTextInputFormatter;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/presentation/account_widgets.dart';
import '../../highlights/presentation/highlight_more_sheet.dart'
    show HighlightsSheetFrame, hlSheetMargin;
import '../../home/application/formatters.dart';
import '../../home/application/home_providers.dart' show clockProvider;
import '../../home/domain/models.dart';
import '../../reader/domain/reader_settings.dart' show ReaderPaper;
import '../../reader/presentation/reader_chrome_palette.dart';
import '../application/paper_end_form.dart';
import '../application/paper_timer_controller.dart';
import '../application/paper_timer_format.dart';
import '../application/second_ticker.dart';
import '../data/paper_book_source.dart';
import '../data/paper_timer_store.dart' show reportPaperTimerError;
import '../domain/open_paper_session.dart';
import '../domain/paper_timer_failure.dart';
import 'second_ticking.dart';

/// O nome da rota da folha (para os observadores e os testes).
const String sessionSheetRouteName = 'sessao-papel';

/// Abre a folha da sessão aberta por cima de tudo. [pending] = o livro cujo play foi tocado com outra sessão aberta
/// (D-262): encerrar ou descartar começa a dele.
Future<void> showSessionSheet(BuildContext context, {Book? pending}) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        settings: const RouteSettings(name: sessionSheetRouteName),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => SessionSheet(pending: pending),
      ),
    );

class SessionSheet extends ConsumerStatefulWidget {
  const SessionSheet({super.key, this.pending});

  /// O livro que começa quando esta sessão for encerrada ou descartada (D-262).
  final Book? pending;

  @override
  ConsumerState<SessionSheet> createState() => _SessionSheetState();
}

class _SessionSheetState extends ConsumerState<SessionSheet> {
  /// O papel claro do leitor: o cartão `#FFFAF1` com a borda tinta e o véu do papel a 62 %.
  static final ReaderChromePalette _palette = ReaderChromePalette.of(
    ReaderPaper.creme,
  );

  final TextEditingController _page = TextEditingController();
  final TextEditingController _total = TextEditingController();
  String? _notice;
  bool _confirming = false;
  bool _busy = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    // D-260: o total do catálogo do aparelho já no campo (só quando o livro não tem e a pessoa ainda não digitou)
    final book = ref.read(paperTimerProvider).value?.book;
    final isbn = book?.isbn13;
    if (book != null && book.pagesTotal == null && isbn != null) {
      unawaited(_prefillTotal(isbn));
    }
  }

  Future<void> _prefillTotal(String isbn13) async {
    try {
      final source = await ref.read(paperBookSourceProvider.future);
      final pages = await source.catalogPages(isbn13);
      if (!mounted || pages == null || _total.text.isNotEmpty) return;
      setState(() => _total.text = '$pages');
    } on Object catch (e, st) {
      reportPaperTimerError(e, st);
    }
  }

  @override
  void dispose() {
    _page.dispose();
    _total.dispose();
    super.dispose();
  }

  /// Fecha a folha — só ela: se outra rota já está por cima, tira só a folha; se ela já saiu (o Voltar durante a
  /// gravação), nada.
  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    if (route.isCurrent) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).removeRoute(route);
    }
  }

  /// Pausar / Retomar na folha: a falha vira o aviso dela (D-266).
  Future<void> _toggle(bool running) async {
    setState(() => _notice = null);
    try {
      await ref.read(paperTimerProvider.notifier).toggle();
    } on Object catch (e, st) {
      reportPaperTimerError(e, st);
      if (mounted) {
        setState(
          () => _notice = running
              ? PaperTimerFormat.pauseFailed
              : PaperTimerFormat.resumeFailed,
        );
      }
    }
  }

  void _end(PaperBook book) {
    final form = PaperEndForm.read(
      page: _page.text,
      total: _total.text,
      bookTotal: book.pagesTotal,
    );
    switch (form) {
      case PaperEndRejected(:final notice):
        setState(() => _notice = notice);
      case PaperEndAccepted(:final page, :final pagesTotal):
        unawaited(
          _run(
            (c) => c.end(page: page, pagesTotal: pagesTotal),
            failure: PaperTimerFormat.endFailed,
          ),
        );
    }
  }

  /// Encerra ou descarta e fecha; aberta pelo play de outro livro, começa a sessão dele (D-262). O livro que saiu da
  /// estante já leva a sessão junto (o controlador a limpa); outra falha vai ao relatório e a folha continua, com o
  /// aviso [failure] e os botões de volta (D-266).
  Future<void> _run(
    Future<void> Function(PaperTimerController timer) action, {
    required String failure,
  }) async {
    final timer = ref.read(paperTimerProvider.notifier);
    final pending = widget.pending;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      await action(timer);
    } on PaperBookGone {
      // a sessão saiu com o livro
    } on Object catch (e, st) {
      reportPaperTimerError(e, st);
      if (mounted) {
        setState(() {
          _busy = false;
          _confirming = false;
          _notice = failure;
        });
      }
      return;
    }
    if (pending != null) {
      try {
        await timer.start(pending.id);
      } on PaperBookGone {
        // o outro livro também saiu da estante: nada começa
      } on Object catch (e, st) {
        reportPaperTimerError(e, st);
      }
    }
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(paperTimerProvider.select((t) => t.value));
    final session = timer?.session;
    final book = timer?.book;
    if (session == null || book == null) {
      // a sessão acabou por outro caminho (outra tela, o livro saiu): a folha sai junto
      if (!_busy) WidgetsBinding.instance.addPostFrameCallback((_) => _close());
      return const SizedBox.shrink();
    }
    final mq = MediaQuery.of(context);
    final bottom =
        math.max(mq.viewPadding.bottom, mq.viewInsets.bottom) + hlSheetMargin;
    // o cartão cabe entre a área segura de cima e o teclado (padding 16 + borda 1,5 dos dois lados); passou, rola
    final maxHeight =
        mq.size.height - mq.viewPadding.top - hlSheetMargin - bottom - 35;
    return HighlightsSheetFrame(
      id: 'session.sheet',
      label: PaperTimerFormat.sheetLabel,
      palette: _palette,
      onDismiss: _busy ? () {} : _close,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: math.max(0, maxHeight)),
        child: SingleChildScrollView(
          child: _confirming ? _confirmation(session) : _main(session, book),
        ),
      ),
    );
  }

  /// [child] com o tempo da sessão, refeito a cada tique (a parede manda).
  Widget _ticking(OpenPaperSession s, Widget Function(int seconds) child) =>
      SecondTicking(
        running: s.isRunning,
        ticker: ref.watch(secondTickerProvider),
        builder: (_) => child(s.elapsedAt(ref.read(clockProvider)())),
      );

  Widget _main(OpenPaperSession session, PaperBook book) {
    final pending = widget.pending;
    final lastPage = book.lastPage;
    final notice = _notice;
    final digits = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(5),
    ];
    return AccountColumn(
      children: [
        if (pending != null)
          AccountText(
            PaperTimerFormat.pendingStart(
              HomeFormatters.bookTitleShort(pending),
            ),
            key: const ValueKey('session.sheet.pending'),
          ),
        AccountHeading(
          HomeFormatters.bookTitleShort(book.book),
          key: const ValueKey('session.sheet.title'),
        ),
        _ticking(
          session,
          (seconds) => AccountText(
            PaperTimerFormat.sheetStatus(
              running: session.isRunning,
              seconds: seconds,
            ),
            key: const ValueKey('session.sheet.status'),
            muted: true,
          ),
        ),
        AccountButton(
          session.isRunning
              ? PaperTimerFormat.pauseButton
              : PaperTimerFormat.resumeButton,
          key: const ValueKey('session.sheet.toggle'),
          onTap: _busy ? null : () => unawaited(_toggle(session.isRunning)),
        ),
        if (lastPage != null)
          AccountText(
            PaperTimerFormat.lastPage(lastPage),
            key: const ValueKey('session.sheet.last'),
            muted: true,
          ),
        AccountField(
          key: const ValueKey('session.sheet.page'),
          controller: _page,
          label: PaperTimerFormat.pageQuestion,
          keyboardType: TextInputType.number,
          inputFormatters: digits,
        ),
        if (book.pagesTotal == null)
          AccountField(
            key: const ValueKey('session.sheet.total'),
            controller: _total,
            label: PaperTimerFormat.totalQuestion,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
          ),
        if (notice != null)
          AccountNotice(
            notice,
            key: const ValueKey('session.sheet.notice'),
            error: true,
          ),
        AccountButton(
          PaperTimerFormat.endButton,
          key: const ValueKey('session.sheet.end'),
          tone: AccountButtonTone.primary,
          onTap: _busy ? null : () => _end(book),
        ),
        AccountButton(
          PaperTimerFormat.discardButton,
          key: const ValueKey('session.sheet.discard'),
          tone: AccountButtonTone.danger,
          onTap: _busy ? null : () => setState(() => _confirming = true),
        ),
        AccountButton(
          PaperTimerFormat.closeButton,
          key: const ValueKey('session.sheet.close'),
          onTap: _busy ? null : _close,
        ),
      ],
    );
  }

  Widget _confirmation(OpenPaperSession session) => AccountColumn(
    children: [
      _ticking(
        session,
        (seconds) => AccountText(
          PaperTimerFormat.discardQuestion(seconds),
          key: const ValueKey('session.sheet.confirm'),
        ),
      ),
      AccountButton(
        PaperTimerFormat.discardConfirm,
        key: const ValueKey('session.sheet.confirmDiscard'),
        tone: AccountButtonTone.danger,
        onTap: _busy
            ? null
            : () => unawaited(
                _run(
                  (c) => c.discard(),
                  failure: PaperTimerFormat.discardFailed,
                ),
              ),
      ),
      AccountButton(
        PaperTimerFormat.backButton,
        key: const ValueKey('session.sheet.back'),
        onTap: _busy ? null : () => setState(() => _confirming = false),
      ),
    ],
  );
}

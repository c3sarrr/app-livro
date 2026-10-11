// G19.3–G19.8 — a tela 25, "Grifos e notas" (rota `/livro/:bookId/destaques`): uma página só que rola (R14), com o
// topo e a busca (L25a), os filtros (L25b), a lista na ordem do livro com os separadores e os cartões (L25c, em
// sliver, construída sob demanda), o fim e os vazios (L25d, D-198), e por cima as folhas "Mais opções" (D-192) e
// Exportar (D-194) e as pílulas dos avisos (D-118) e do Desfazer (D-193). As pílulas e as folhas usam as cores das
// ilhas do Creme (D-118/D-132).
//
// Saídas (R13, D-195): Voltar = `pop`; tocar num cartão = pelo leitor, `pop` com o 1º item; pela Início, troca a tela
// pelo leitor com `?ir=`; "Continuar lendo" = pelo leitor, `pop`; pela Início, o leitor (ou a página do livro físico —
// D-123).
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter/semantics.dart' show SemanticsService;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/preferences/brand_preference.dart';
import '../../reader/domain/reader_settings.dart';
import '../../reader/presentation/reader_chrome_palette.dart';
import '../../reader/presentation/reader_chrome_scope.dart';
import '../../reader/presentation/reader_overlays.dart';
import '../application/highlights_controller.dart';
import '../application/highlights_exit.dart';
import '../application/highlights_providers.dart';
import '../application/highlights_share.dart';
import '../domain/card_dates.dart';
import '../domain/card_filters.dart';
import '../domain/highlight_card.dart';
import '../domain/list_entries.dart';
import 'highlight_card.dart';
import 'highlight_export_sheet.dart';
import 'highlight_filters.dart';
import 'highlight_more_sheet.dart';
import 'highlight_share_sheets.dart';
import 'highlights_end.dart';
import 'highlights_top.dart';
import 'ink_thumbnail.dart';
import 'page_separator.dart';

/// O aviso de "Cartão apagado · Desfazer" (D-193).
const String cardRemovedText = 'Cartão apagado';

/// O aviso do erro ao exportar (D-194).
const String exportFailedText = 'Não deu para exportar';

/// A folha aberta por cima da tela.
sealed class _Sheet {
  const _Sheet();
}

final class _More extends _Sheet {
  const _More(this.card);
  final HighlightCard card;
}

final class _Note extends _Sheet {
  const _Note(this.card);
  final HighlightCard card;
}

final class _Export extends _Sheet {
  const _Export();
}

/// G21.5: "Antes de publicar" (os termos — D-222).
final class _Terms extends _Sheet {
  const _Terms(this.card, this.step);
  final HighlightCard card;
  final ShareNeedsTerms step;
}

/// G21.5: "Compartilhar em…" (mais de um clube lê o livro).
final class _ShareTo extends _Sheet {
  const _ShareTo(this.card, this.clubs);
  final HighlightCard card;
  final List<ShareClub> clubs;
}

class HighlightsScreen extends ConsumerStatefulWidget {
  const HighlightsScreen({
    super.key,
    required this.bookId,
    this.fromReader = false,
  });

  /// O id do livro na estante (`user_books.id`).
  final String bookId;

  /// Aberta pelo botão Grifos do leitor (`?de=leitor`): as saídas voltam a ele (R13).
  final bool fromReader;

  @override
  ConsumerState<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends ConsumerState<HighlightsScreen> {
  HighlightsController? _c;
  final ScrollController _scroll = ScrollController();
  final InkThumbnailCache _cache = InkThumbnailCache();
  final GlobalKey _filtersKey = GlobalKey(debugLabel: 'hl.filters');
  late final double _content = quoteContentHeight();
  bool _started = false;

  /// O último `results` anunciado (§9) e o cartão de cima antes do filtro (a rolagem volta se ele sumiu).
  int _lastResults = 0;
  String? _topGroup;
  bool _exporting = false;
  bool _sharing = false;
  _Sheet? _sheet;
  String? _toast;
  Timer? _toastTimer;
  Timer? _undoTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    unawaited(_start());
  }

  Future<void> _start() async {
    final HighlightsDeps deps;
    try {
      deps = await ref.read(highlightsDepsProvider.future);
    } on Object catch (e, st) {
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st));
      return;
    }
    if (!mounted) return;
    final c = HighlightsController(deps: deps, userBookId: widget.bookId)
      ..addListener(_changed);
    setState(() => _c = c);
    await c.load();
  }

  @override
  void dispose() {
    _c
      ?..removeListener(_changed)
      ..dispose();
    _toastTimer?.cancel();
    _undoTimer?.cancel();
    _scroll.dispose();
    _cache.clear();
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    final s = _c!.state;
    if (s.results != _lastResults) {
      // a lista mudou por um filtro ou pela busca: anuncia o resultado (região viva educada — §9)
      _lastResults = s.results;
      final n = s.visibleCards;
      _announce(n == 1 ? '1 cartão' : '$n cartões');
      final top = _topGroup;
      _topGroup = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _keepListTop(top));
    }
    setState(() {});
  }

  /// Com o leitor de tela, o que mudou é lido (região viva educada).
  void _announce(String text) {
    if (!MediaQuery.accessibleNavigationOf(context)) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        text,
        TextDirection.ltr,
      ),
    );
  }

  /// O `group_id` do cartão de cima na tela (o 1º cuja base passa do topo), ou `null`.
  String? _topCardGroup() {
    String? group;
    var best = double.infinity;
    void visit(Element e) {
      final w = e.widget;
      if (w is HighlightCardView) {
        final box = e.renderObject;
        if (box is RenderBox && box.attached && box.hasSize) {
          final top = box.localToGlobal(Offset.zero).dy;
          if (top + box.size.height > 0 && top < best) {
            best = top;
            group = w.card.groupId;
          }
        }
        return;
      }
      e.visitChildElements(visit);
    }

    context.visitChildElements(visit);
    return group;
  }

  /// Depois de um filtro, com a lista rolada para baixo: se o cartão [wasTop] (o de cima antes) sumiu, a rolagem volta
  /// ao começo da lista (§4).
  void _keepListTop(String? wasTop) {
    final c = _c;
    if (wasTop == null || c == null) return;
    if (c.state.entries.any((e) => e is CardItem && e.card.groupId == wasTop)) {
      return;
    }
    final ctx = _filtersKey.currentContext;
    if (!mounted || ctx == null || !_scroll.hasClients) return;
    final box = ctx.findRenderObject()! as RenderBox;
    final top =
        RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset +
        box.size.height;
    if (_scroll.offset > top) _scroll.jumpTo(top);
  }

  void _showToast(String text) {
    _toastTimer?.cancel();
    setState(() => _toast = text);
    _toastTimer = Timer(readerToastLife, () {
      if (mounted) setState(() => _toast = null);
    });
    _announce(text);
  }

  /// A próxima ação tira o "Desfazer" (D-139).
  void _dismissUndo() {
    _undoTimer?.cancel();
    _undoTimer = null;
    _c?.dismissUndo();
  }

  // --- filtros -----------------------------------------------------------------------------------------------

  void _act(void Function(HighlightsController c) f) {
    final c = _c;
    if (c == null) return;
    _dismissUndo();
    _topGroup = _topCardGroup();
    f(c);
  }

  // --- saídas (R13, D-195) -------------------------------------------------------------------------------------

  void _back() => unawaited(Navigator.of(context).maybePop());

  /// R5: fecha e publica a saída no canal do app — o leitor de baixo escuta, mesmo restaurado (D-207).
  void _exitToReader(HighlightsExit exit) {
    final bus = ref.read(highlightsExitBusProvider);
    Navigator.of(context).pop();
    bus.post(widget.bookId, exit);
  }

  void _open(HighlightCard card) {
    final c = _c;
    if (c == null) return;
    final first = card.items.first;
    if (widget.fromReader) {
      _exitToReader(
        HighlightsOpenAt(
          first.id,
          page: card.page,
          orphan: c.state.orphans.contains(card.groupId),
        ),
      );
      return;
    }
    context.pushReplacement(AppRoutes.leitor(widget.bookId, goTo: first.id));
  }

  void _continue() {
    final c = _c;
    if (c == null) return;
    if (widget.fromReader) {
      _exitToReader(const HighlightsContinue());
      return;
    }
    context.pushReplacement(
      c.state.physical
          ? AppRoutes.livro(widget.bookId)
          : AppRoutes.leitor(widget.bookId),
    );
  }

  // --- folhas -------------------------------------------------------------------------------------------------

  void _openSheet(_Sheet s) {
    _dismissUndo();
    // o teclado da busca fecha: a folha fica à vista
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _sheet = s);
  }

  void _closeSheet() => setState(() => _sheet = null);

  Future<void> _delete(HighlightCard card) async {
    final c = _c;
    if (c == null) return;
    _closeSheet();
    await c.deleteCard(card);
    if (!mounted || c.state.undo == null) return;
    _undoTimer?.cancel();
    if (!MediaQuery.accessibleNavigationOf(context)) {
      _undoTimer = Timer(readerUndoLife, () {
        if (mounted) _c?.dismissUndo();
      });
    }
    _announce(cardRemovedText);
  }

  Future<void> _recolor(HighlightCard card, String hex) async {
    final c = _c;
    if (c == null) return;
    _closeSheet();
    await c.recolor(card, hex);
  }

  /// A folha da nota fecha quando a nota foi gravada (no erro, o texto fica — D-131).
  Future<void> _saveNote(HighlightCard card, String text) async {
    final c = _c;
    if (c == null) return;
    if (await c.saveNote(card, text) && mounted) _closeSheet();
  }

  /// G21.5 (§5): um passo por vez (o 2º toque, enquanto o 1º publica, não faz nada).
  Future<void> _share(
    HighlightCard card,
    Future<ShareStep> Function(HighlightsController c) step,
  ) async {
    final c = _c;
    if (c == null || _sharing) return;
    _sharing = true;
    _closeSheet();
    try {
      final next = await step(c);
      if (!mounted) return;
      switch (next) {
        case ShareNotice(:final text):
          _showToast(text);
        case final ShareNeedsTerms t:
          setState(() => _sheet = _Terms(card, t));
        case ShareChoose(:final clubs):
          setState(() => _sheet = _ShareTo(card, clubs));
      }
    } finally {
      _sharing = false;
    }
  }

  /// Um arquivo por vez (o 2º toque no Exportar, enquanto o 1º entrega, não faz nada).
  Future<void> _export(ExportFormat f) async {
    final c = _c;
    if (c == null || _exporting) return;
    _exporting = true;
    try {
      final ok = await c.export(f);
      if (!mounted) return;
      if (ok) {
        _closeSheet();
      } else {
        _showToast(exportFailedText);
      }
    } finally {
      _exporting = false;
    }
  }

  // --- lista --------------------------------------------------------------------------------------------------

  /// O texto do cartão para o leitor de tela: o rótulo da R4, a data, a citação e a nota.
  String _cardLabel(HighlightCard card, String date, String quote) {
    final note = card.notes.firstOrNull?.noteText;
    return [
      '${cardSemanticsLabel(card)}, $date',
      quote,
      if (note != null) 'Nota: $note',
    ].join('\n');
  }

  Widget _entry(BuildContext context, ListEntry e) {
    final c = _c!;
    final s = c.state;
    switch (e) {
      case PageMark(:final page, :final n, :final here):
        return PageSeparator(id: 'hl.list.sep$n', page: page, here: here);
      case OrphanMark():
        return const PageSeparator.orphan(id: 'hl.list.sepOrphan');
      case CardItem(:final card, :final n, :final orphan):
        final date = cardDate(
          card.createdAt,
          now: c.deps.now(),
          offsetAt: c.deps.utcOffsetAt,
        );
        final spans = s.texts[card.groupId] ?? const [];
        final post = card.clubPostId;
        final club = post == null ? null : s.clubs[post];
        return HighlightCardView(
          key: ValueKey('card:${card.groupId}'),
          id: 'hl.list.card$n',
          card: card,
          spans: spans,
          date: orphan ? 'pág. ${card.page} · $date' : date,
          semanticsLabel: _cardLabel(
            card,
            date,
            spans.map((p) => p.text).join(),
          ),
          handLabel: 'Nota à mão, $date',
          layers: s.layers,
          cache: _cache,
          content: _content,
          club: club,
          onOpen: () => _open(card),
          onMore: () => _openSheet(_More(card)),
          onClub: club == null
              ? null
              : () => unawaited(
                  context.push<void>(AppRoutes.discussao(club.clubId)),
                ),
        );
    }
  }

  List<Widget> _slivers(BuildContext context, double top) {
    final c = _c;
    final s = c?.state;
    final ready = s != null && !s.loading;
    final empty = s?.empty ?? false;
    final filters = s?.filters ?? const HighlightFilters();
    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16, top, 16, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HighlightsTopBar(
                onBack: _back,
                onExport: () => _openSheet(const _Export()),
              ),
              const SizedBox(height: 20),
              HighlightsHeading(title: s?.title ?? ''),
              if (!empty) ...[
                const SizedBox(height: 16),
                HighlightsSearch(
                  query: filters.query,
                  onQuery: (q) => _act((c) => c.setQuery(q)),
                ),
              ],
            ],
          ),
        ),
      ),
      if (ready && !empty) ...[
        SliverPadding(
          padding: const EdgeInsets.only(top: 12),
          sliver: SliverToBoxAdapter(
            child: HighlightTypes(
              counts: s.counts,
              active: filters.type,
              brand: ref.watch(brandProvider),
              onType: (t) => _act((c) => c.setType(t)),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          sliver: SliverToBoxAdapter(
            child: KeyedSubtree(
              key: _filtersKey,
              child: HighlightColorFilters(
                colors: s.colors,
                marked: filters.colors,
                clubOnly: filters.clubOnly,
                onColor: (hex) => _act((c) => c.toggleColor(hex)),
                onClubOnly: (on) => _act((c) => c.setClubOnly(on)),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverSemantics(
            container: true,
            explicitChildNodes: true,
            label: 'Grifos e notas na ordem do livro',
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _entry(context, s.entries[i]),
                childCount: s.entries.length,
              ),
            ),
          ),
        ),
      ],
      if (ready)
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            32 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (empty)
                  HighlightsEndCard(
                    text: emptyBookText,
                    cta: continueText(s.herePage),
                    onCta: _continue,
                  )
                else ...[
                  if (s.entries.isEmpty)
                    HighlightsEndCard(
                      id: 'hl.empty',
                      text: noResultsText,
                      clear: true,
                      onCta: () => _act((c) => c.clearFilters()),
                    ),
                  HighlightsEndCard(
                    text: endText,
                    cta: continueText(s.herePage),
                    onCta: _continue,
                  ),
                ],
              ],
            ),
          ),
        ),
    ];
  }

  Widget? _sheetView(BuildContext context, ReaderChromePalette p) {
    final c = _c;
    final sheet = _sheet;
    if (c == null || sheet == null) return null;
    final brand = ref.watch(brandProvider);
    return switch (sheet) {
      _More(:final card) => HighlightMoreSheet(
        card: card,
        excerpt: (c.state.texts[card.groupId] ?? const [])
            .map((s) => s.text)
            .join(),
        palette: p,
        onNote: () => setState(() => _sheet = _Note(card)),
        onColor: (hex) => unawaited(_recolor(card, hex)),
        canShare: c.canShare(card),
        sharedLabel: c.sharedLabel(card),
        onShare: () => unawaited(_share(card, (c) => c.startShare(card))),
        onDelete: () => unawaited(_delete(card)),
        onClose: _closeSheet,
      ),
      _Note(:final card) => HighlightNoteSheet(
        card: card,
        palette: p,
        brand: brand,
        onCancel: _closeSheet,
        onSave: (text) => unawaited(_saveNote(card, text)),
      ),
      _Terms(:final card, :final step) => HighlightTermsSheet(
        palette: p,
        brand: brand,
        onAccept: () =>
            unawaited(_share(card, (c) => c.acceptTerms(card, step))),
        onLater: _closeSheet,
      ),
      _ShareTo(:final card, :final clubs) => HighlightShareToSheet(
        clubs: clubs,
        palette: p,
        onPick: (club) => unawaited(_share(card, (c) => c.shareTo(card, club))),
        onClose: _closeSheet,
      ),
      _Export() => HighlightExportSheet(
        title: c.state.title,
        exportable: c.exportable,
        palette: p,
        brand: brand,
        onPdf: () => _showToast(readerSoonText),
        onCancel: _closeSheet,
        onExport: (f) => unawaited(_export(f)),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandProvider);
    final p = ReaderChromePalette.of(ReaderPaper.creme);
    final padding = MediaQuery.viewPaddingOf(context);
    final top = math.max(54.0, padding.top + 7);
    final undo = _c?.state.undo;
    final sheet = _sheetView(context, p);
    return PopScope(
      canPop: _sheet == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _sheet != null) _closeSheet();
      },
      child: ReaderChromeScope(
        palette: p,
        brand: brand,
        a: 1,
        child: ColoredBox(
          color: AppColors.paper,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomScrollView(
                  key: const ValueKey('hl.scroll'),
                  controller: _scroll,
                  slivers: _slivers(context, top),
                ),
              ),
              if (sheet != null)
                Positioned.fill(child: BlockSemantics(child: sheet)),
              if (undo != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: padding.bottom + 24,
                  child: Center(
                    child: ReaderUndoPill(
                      text: cardRemovedText,
                      onUndo: () {
                        _undoTimer?.cancel();
                        unawaited(_c?.undo());
                      },
                    ),
                  ),
                ),
              if (_toast case final t?)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: padding.bottom + 24,
                  child: Center(child: ReaderToastPill(text: t)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

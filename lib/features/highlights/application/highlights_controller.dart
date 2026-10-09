// G19.2 — o estado da tela 25: o livro, a posição (o "você parou aqui"), os itens do repositório (relidos a cada
// escrita), os filtros e a busca (com espera — R7), os cartões e as entradas da lista, as contagens (R1), a fileira de
// cores (D-196), os textos dos cartões e os sem lugar (R3, D-199), os chips do clube (R8), o Desfazer pendente
// (D-193) e a exportação (D-194, R12).
import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/daos/content_daos.dart';
import '../../../core/data/database/daos/library_daos.dart';
import '../../../core/data/database/daos/reader_daos.dart';
import '../../library/domain/user_book.dart';
import '../../reader/annotations/domain/annotation.dart';
import '../../reader/annotations/domain/annotation_stats.dart';
import '../../reader/annotations/domain/ink_layer.dart';
import '../../reader/application/toc_view.dart' show chapterLabels;
import '../domain/card_filters.dart';
import '../domain/card_text.dart';
import '../domain/highlight_card.dart';
import '../domain/highlights_export.dart';
import '../domain/list_entries.dart';
import 'card_text_source.dart';
import 'highlights_club_source.dart';
import 'highlights_file_sink.dart';
import 'highlights_repository.dart';

enum ExportFormat { markdown, csv }

/// O que a tela 25 precisa de fora (os testes trocam pela fixture — D-34).
final class HighlightsDeps {
  const HighlightsDeps({
    required this.db,
    required this.repository,
    required this.textSourceFor,
    required this.club,
    required this.now,
    required this.utcOffsetAt,
    required this.files,
    required this.onError,
    this.searchDelay = const Duration(milliseconds: 200),
  });

  final AppDatabase db;
  final HighlightsRepository repository;

  /// A fonte do texto dos cartões do livro (o arquivo dele, ou a citação).
  final Future<CardTextSource> Function(UserBook book) textSourceFor;
  final HighlightsClubSource club;
  final DateTime Function() now;
  final Duration Function(DateTime utc) utcOffsetAt;
  final HighlightsFileSink files;
  final void Function(Object error, StackTrace stack) onError;

  /// R7: a busca espera a pessoa parar de digitar.
  final Duration searchDelay;
}

final class HighlightsState {
  const HighlightsState({
    this.loading = true,
    this.title = '',
    this.author,
    this.physical = false,
    this.herePage,
    this.items = const [],
    this.layers = const {},
    this.cards = const [],
    this.entries = const [],
    this.counts = const AnnotationKindCounts(
      highlights: 0,
      notes: 0,
      handwriting: 0,
      drawings: 0,
    ),
    this.colors = markerChoices,
    this.filters = const HighlightFilters(),
    this.texts = const {},
    this.orphans = const {},
    this.clubs = const {},
    this.undo,
  });

  final bool loading;
  final String title;
  final String? author;

  /// Livro físico: "Continuar lendo" vai à página do livro (D-123).
  final bool physical;
  final int? herePage;

  /// Todos os itens vivos do livro, na ordem do livro.
  final List<Annotation> items;
  final Map<String, InkLayer> layers;

  /// Todos os cartões (sem filtro).
  final List<HighlightCard> cards;

  /// O que a lista mostra: separadores e cartões filtrados.
  final List<ListEntry> entries;
  final AnnotationKindCounts counts;
  final List<ColorChoice> colors;
  final HighlightFilters filters;

  /// Os trechos de cada cartão, por `group_id`.
  final Map<String, List<CardSpan>> texts;
  final Set<String> orphans;

  /// O chip do clube de cada `shared_club_post_id`.
  final Map<String, ClubChip> clubs;
  final RemovedCard? undo;

  bool get empty => !loading && items.isEmpty;
  int get visibleCards => entries.whereType<CardItem>().length;

  HighlightsState copyWith({
    bool? loading,
    String? title,
    String? author,
    bool? physical,
    int? herePage,
    List<Annotation>? items,
    Map<String, InkLayer>? layers,
    List<HighlightCard>? cards,
    List<ListEntry>? entries,
    AnnotationKindCounts? counts,
    List<ColorChoice>? colors,
    HighlightFilters? filters,
    Map<String, List<CardSpan>>? texts,
    Set<String>? orphans,
    Map<String, ClubChip>? clubs,
    RemovedCard? Function()? undo,
  }) => HighlightsState(
    loading: loading ?? this.loading,
    title: title ?? this.title,
    author: author ?? this.author,
    physical: physical ?? this.physical,
    herePage: herePage ?? this.herePage,
    items: items ?? this.items,
    layers: layers ?? this.layers,
    cards: cards ?? this.cards,
    entries: entries ?? this.entries,
    counts: counts ?? this.counts,
    colors: colors ?? this.colors,
    filters: filters ?? this.filters,
    texts: texts ?? this.texts,
    orphans: orphans ?? this.orphans,
    clubs: clubs ?? this.clubs,
    undo: undo == null ? this.undo : undo(),
  );
}

final class HighlightsController extends ChangeNotifier {
  HighlightsController({required this.deps, required this.userBookId});

  final HighlightsDeps deps;
  final String userBookId;

  HighlightsState _state = const HighlightsState();
  HighlightsState get state => _state;

  StreamSubscription<BookItems>? _sub;
  CardTextSource _texts = const AnchorOnlyCardTextSource();
  List<String?> _labels = const [];
  Set<String>? _hits;
  Timer? _searchTimer;
  int _searchGen = 0;
  int _itemsGen = 0;
  bool _disposed = false;

  void _set(HighlightsState s) {
    if (_disposed) return;
    _state = s;
    notifyListeners();
  }

  Future<void> load() async {
    try {
      final book = await UserBooksDao(deps.db).byId(userBookId);
      final position = await ReadingPositionsDao(deps.db).forBook(userBookId);
      _labels = chapterLabels(
        await BookContentIndexDao(deps.db).byBook(userBookId),
      );
      if (book != null) _texts = await deps.textSourceFor(book);
      if (_disposed) return;
      _state = _state.copyWith(
        title: book?.title ?? '',
        author: book?.authorDisplay,
        physical: book?.format == BookFileFormat.physical,
        herePage: position?.refPage,
      );
      _sub = deps.repository
          .watch(userBookId)
          .listen((b) => unawaited(_onItems(b)), onError: deps.onError);
    } on Object catch (e, st) {
      deps.onError(e, st);
      _set(_state.copyWith(loading: false));
    }
  }

  Future<void> _onItems(BookItems b) async {
    final gen = ++_itemsGen;
    try {
      final cards = buildCards(b.items);
      final texts = await _texts.textsFor(cards);
      final clubs = <String, ClubChip>{};
      for (final id in {for (final c in cards) ?c.clubPostId}) {
        final chip = await deps.club.clubOf(id);
        if (chip != null) clubs[id] = chip;
      }
      final q = _state.filters.query;
      final hits = q.trim().isEmpty
          ? null
          : await deps.repository.search(userBookId, q);
      if (gen != _itemsGen || _disposed) return;
      _hits = hits;
      _state = _state.copyWith(
        loading: false,
        items: b.items,
        layers: b.layers,
        cards: cards,
        counts: kindCounts(b.items),
        colors: colorRow(b.items),
        texts: texts.byGroup,
        orphans: texts.orphans,
        clubs: clubs,
      );
      _rebuild();
    } on Object catch (e, st) {
      deps.onError(e, st);
    }
  }

  void _rebuild() {
    final visible = filterCards(_state.cards, _state.filters, hits: _hits);
    _set(
      _state.copyWith(
        entries: listEntries(
          visible,
          herePage: _state.herePage,
          orphanGroups: _state.orphans,
        ),
      ),
    );
  }

  void _filters(HighlightFilters f) {
    _state = _state.copyWith(filters: f);
    _rebuild();
  }

  void setType(TypeFilter t) => _filters(_state.filters.copyWith(type: t));

  void toggleColor(String hex) {
    final c = {..._state.filters.colors};
    if (!c.remove(hex)) c.add(hex);
    _filters(_state.filters.copyWith(colors: c));
  }

  void setClubOnly(bool on) => _filters(_state.filters.copyWith(clubOnly: on));

  /// R7: guarda o texto na hora; a busca espera [HighlightsDeps.searchDelay] (a última tecla vence).
  void setQuery(String q) {
    _searchTimer?.cancel();
    final gen = ++_searchGen;
    _state = _state.copyWith(filters: _state.filters.copyWith(query: q));
    if (q.trim().isEmpty) {
      _hits = null;
      _rebuild();
      return;
    }
    notifyListeners();
    _searchTimer = Timer(deps.searchDelay, () => unawaited(_search(q, gen)));
  }

  Future<void> _search(String q, int gen) async {
    try {
      final hits = await deps.repository.search(userBookId, q);
      if (gen != _searchGen || _disposed) return;
      _hits = hits;
      _rebuild();
    } on Object catch (e, st) {
      deps.onError(e, st);
    }
  }

  /// "Limpar filtros" (D-198): Tudo, sem cor, sem clube, sem busca.
  void clearFilters() {
    _searchTimer?.cancel();
    _searchGen++;
    _hits = null;
    _filters(const HighlightFilters());
  }

  /// D-193: apaga o cartão inteiro e guarda o que levou para o Desfazer.
  Future<void> deleteCard(HighlightCard c) async {
    try {
      final r = await deps.repository.deleteGroup(userBookId, c.groupId);
      if (r != null) _set(_state.copyWith(undo: () => r));
    } on Object catch (e, st) {
      deps.onError(e, st);
    }
  }

  Future<void> undo() async {
    final r = _state.undo;
    if (r == null) return;
    _set(_state.copyWith(undo: () => null));
    try {
      await deps.repository.restore(r);
    } on Object catch (e, st) {
      deps.onError(e, st);
    }
  }

  void dismissUndo() => _set(_state.copyWith(undo: () => null));

  /// R11: troca a cor de todos os grifos do cartão; `false` se nenhum mudou.
  Future<bool> recolor(HighlightCard c, String hex) async {
    var any = false;
    try {
      for (final a in c.items) {
        if (a.kind != AnnotationKind.highlight || a.color == hex) continue;
        any = await deps.repository.recolor(a.id, hex) || any;
      }
    } on Object catch (e, st) {
      deps.onError(e, st);
    }
    return any;
  }

  Future<void> saveNote(HighlightCard c, String text) async {
    final h = c.highlight;
    if (h == null) return;
    try {
      await deps.repository.saveNote(userBookId, h.id, text);
    } on Object catch (e, st) {
      deps.onError(e, st);
    }
  }

  /// Quantos itens a exportação leva (grifos e notas de texto).
  int get exportable => exportableCount(_state.items);

  /// O conteúdo do arquivo em [f] com o livro todo (D-194); `null` = nada para exportar (R12).
  String? exportText(ExportFormat f) {
    if (exportable == 0) return null;
    return switch (f) {
      ExportFormat.markdown => markdownOf(
        (title: _state.title, author: _state.author),
        _state.items,
        now: deps.now(),
        offsetAt: deps.utcOffsetAt,
      ),
      ExportFormat.csv => csvOf(
        _state.items,
        chapterLabels: _labels,
        offsetAt: deps.utcOffsetAt,
      ),
    };
  }

  /// Gera e entrega o arquivo; `false` = nada para exportar ou falhou (relatado).
  Future<bool> export(ExportFormat f) async {
    final text = exportText(f);
    if (text == null) return false;
    try {
      await deps.files.share(
        fileName: exportFileName(
          _state.title,
          f == ExportFormat.markdown ? 'md' : 'csv',
        ),
        content: text,
        mimeType: f == ExportFormat.markdown ? 'text/markdown' : 'text/csv',
      );
      return true;
    } on Object catch (e, st) {
      deps.onError(e, st);
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _searchTimer?.cancel();
    unawaited(_sub?.cancel());
    super.dispose();
  }
}

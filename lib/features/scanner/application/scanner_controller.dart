// Scanner (Anexo 02 §7, D-76/D-77): código lido → ISBN → estante? → camadas do catálogo → cartão de
// resultado. O envio à comunidade só acontece pelos botões de envio/confirmação (toque explícito — D-74).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/database/local_database.dart';
import '../../../core/sync/sync_providers.dart' show localVersioningProvider;
import '../../account/application/account_controller.dart';
import '../../account/application/account_providers.dart'
    show localLibraryProvider;
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/data/community_catalog_api.dart';
import '../../catalog/domain/catalog_book.dart';
import '../../catalog/domain/catalog_failure.dart';
import '../../catalog/domain/community.dart';
import '../../catalog/domain/isbn.dart';
import '../data/cover_reader.dart';
import '../domain/scan_state.dart';
import 'scanned_shelf.dart';

final scannedShelfProvider = FutureProvider<ScannedShelf>((ref) async {
  final lib = await ref.watch(localLibraryProvider.future);
  return ScannedShelf(
    db: await ref.watch(localDatabaseProvider.future),
    versioning: await ref.watch(localVersioningProvider.future),
    owner: lib.activeOwnerId,
  );
});

final coverReaderProvider = Provider<CoverReader>(
  (ref) => const MlKitCoverReader(),
);

/// Pode enviar à comunidade: conta com sessão e servidor configurado (D-74).
final canContributeProvider = Provider<bool>(
  (ref) =>
      ref.watch(accountControllerProvider) is MemberView &&
      ref.watch(communityCatalogApiProvider) != null,
);

/// Autores digitados ("Ana; Bia") como a estante mostra ("Ana · Bia").
String authorsForShelf(String typed) => typed
    .split(RegExp(r'\s*[;·]\s*'))
    .map((a) => a.trim())
    .where((a) => a.isNotEmpty)
    .join(' · ');

final scannerControllerProvider =
    NotifierProvider.autoDispose<ScannerController, ScanState>(
      ScannerController.new,
    );

final class ScannerController extends Notifier<ScanState> {
  /// Cada busca nova invalida a anterior (resposta atrasada não troca a tela).
  int _turn = 0;
  String? _lastRaw;

  @override
  ScanState build() => const ScanAiming();

  /// Código lido pela câmera. Ignorado enquanto um resultado está na tela.
  Future<void> onBarcode(String raw) async {
    if (state is! ScanAiming) return;
    final isbn = isbnFromBarcode(raw);
    if (isbn == null) {
      if (raw != _lastRaw) state = const ScanAiming(notABook: true);
      _lastRaw = raw;
      return;
    }
    _lastRaw = raw;
    await lookUp(isbn);
  }

  /// "Digitar ISBN" (10 ou 13 dígitos, com ou sem hífens). false = não é um ISBN válido.
  Future<bool> typed(String text) async {
    final isbn = normalizeIsbn(text);
    if (isbn == null) return false;
    await lookUp(isbn);
    return true;
  }

  Future<void> lookUp(String isbn13) async {
    final turn = ++_turn;
    state = ScanLooking(isbn13);
    try {
      final shelf = await ref.read(scannedShelfProvider.future);
      final there = await shelf.onShelf(isbn13);
      if (!_current(turn)) return;
      if (there != null) {
        state = ScanOnShelf(there);
        return;
      }
      final resolver = await ref.read(isbnResolverProvider.future);
      final r = await resolver.resolve(isbn13);
      if (!_current(turn)) return;
      state = switch (r) {
        IsbnFound(:final book, :final layer) => ScanFound(book, layer),
        IsbnNotFound(:final suggestions) => ScanNotFound(
          isbn13,
          suggestions: suggestions,
        ),
      };
    } on CatalogFailure catch (f) {
      if (_current(turn)) state = ScanFailed(isbn13, f);
    } on Object {
      // nunca fica preso em "Procurando…" (achado 4 da revisão)
      if (_current(turn)) {
        state = ScanFailed(isbn13, const CatalogUnexpected('erro'));
      }
    }
  }

  bool _current(int turn) => ref.mounted && turn == _turn;

  /// "Tentar de novo".
  Future<void> retry() async {
    final s = state;
    if (s is ScanFailed) await lookUp(s.isbn13);
  }

  /// "Digitar os dados" depois de uma falha (sem rede, limite do dia).
  void enterManually() {
    final s = state;
    if (s is ScanFailed) {
      _turn++;
      state = ScanNotFound(s.isbn13);
    }
  }

  /// "Escanear outro".
  void scanAgain() {
    _turn++;
    _lastRaw = null;
    state = const ScanAiming();
  }

  /// "Adicionar à estante" do livro achado.
  Future<void> addFound() async {
    final s = state;
    if (s is! ScanFound) return;
    final b = s.book;
    await _add(
      isbn13: b.isbn13,
      title: b.title,
      authors: b.authorDisplay,
      coverRef: b.coverRef,
    );
  }

  /// Livro que ninguém achou, com os dados digitados (ou lidos da capa). [share] = o toque em
  /// "Adicionar e enviar ao catálogo". false = título vazio (nada muda).
  Future<bool> addTyped({
    required String title,
    required String authors,
    String? publisher,
    required bool share,
  }) async {
    final s = state;
    if (s is! ScanNotFound || shelfText(title, 500).isEmpty) return false;
    final added = await _add(
      isbn13: s.isbn13,
      title: title,
      authors: authorsForShelf(authors),
    );
    if (added == null || !share) return true;
    await _contribute(
      added,
      (api) => api.submit(
        isbn13: s.isbn13,
        title: shelfText(title, 500),
        authors: shelfText(authors, 500),
        publisher: publisher == null || publisher.trim().isEmpty
            ? null
            : shelfText(publisher, 200),
      ),
    );
    return true;
  }

  /// "Confirmar e adicionar" uma sugestão de outra pessoa (toque explícito).
  Future<void> confirmSuggestion(CommunitySuggestion sugestao) async {
    final s = state;
    if (s is! ScanNotFound || !sugestao.canConfirm) return;
    final added = await _add(
      isbn13: s.isbn13,
      title: sugestao.title,
      authors: authorsForShelf(sugestao.authors),
    );
    if (added == null) return;
    await _contribute(added, (api) => api.confirm(sugestao.id));
  }

  /// Põe na estante; null = já estava (a tela mostra "já está na estante").
  Future<ShelfAdded?> _add({
    required String isbn13,
    required String title,
    required String authors,
    String? coverRef,
  }) async {
    final turn = ++_turn;
    final ShelfAdd r;
    try {
      final shelf = await ref.read(scannedShelfProvider.future);
      r = await shelf.add(
        isbn13: isbn13,
        title: title,
        authorDisplay: authors,
        coverRef: coverRef,
      );
    } on Object {
      if (_current(turn)) {
        state = ScanFailed(isbn13, const CatalogUnexpected('estante'));
      }
      return null;
    }
    if (!_current(turn)) return null;
    switch (r) {
      case ShelfAdded():
        state = ScanAdded(r.book);
        return r;
      case ShelfAlreadyThere(:final book):
        state = ScanOnShelf(book);
        return null;
    }
  }

  /// O livro já está na estante; o envio à comunidade vem depois e pode falhar sem desfazer nada.
  Future<void> _contribute(
    ShelfAdded added,
    Future<CommunityContribution> Function(CommunityCatalogApi api) send,
  ) async {
    final turn = _turn;
    try {
      final api = ref.read(communityCatalogApiProvider);
      if (api == null) throw const CatalogNeedsAccount();
      final c = await send(api);
      if (_current(turn)) state = ScanAdded(added.book, contribution: c);
    } on CatalogFailure catch (f) {
      if (_current(turn)) {
        state = ScanAdded(added.book, contributionFailure: f);
      }
    }
  }
}

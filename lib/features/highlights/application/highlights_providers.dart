// G19.2 — as dependências da tela 25 no app: o banco local, o versionamento (a fila do Pro), a conta ativa, o texto
// dos cartões pelo arquivo do livro neste aparelho, os clubes (G21: o chip do cache, ao vivo, e o compartilhar), o
// relógio, o fuso do aparelho e a folha de compartilhar. Os testes trocam o provedor inteiro (D-34).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/database/local_database.dart';
import '../../../core/sync/sync_providers.dart' show localVersioningProvider;
import '../../account/application/account_providers.dart'
    show localLibraryProvider;
import '../../clubs/application/club_sources.dart'
    show ClubsHighlightsClubSource;
import '../../clubs/application/clubs_providers.dart';
import '../../home/application/home_providers.dart' show clockProvider;
import '../../library/application/library_import.dart' show booksDirProvider;
import '../../reader/application/book_file.dart';
import '../../reader/application/reader_club_source.dart' show readerUtcOffset;
import '../../reader/application/reader_errors.dart';
import 'card_text_source.dart';
import 'highlights_controller.dart';
import 'highlights_exit.dart';
import 'highlights_file_sink.dart';
import 'highlights_repository.dart';

/// R5 (G20): o canal das saídas da 25 para o leitor (um por app).
final highlightsExitBusProvider = Provider<HighlightsExitBus>((ref) {
  final bus = HighlightsExitBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final highlightsDepsProvider = FutureProvider<HighlightsDeps>((ref) async {
  final db = await ref.watch(localDatabaseProvider.future);
  final library = await ref.watch(localLibraryProvider.future);
  final versioning = await ref.watch(localVersioningProvider.future);
  final booksDir = ref.watch(booksDirProvider);
  return HighlightsDeps(
    db: db,
    repository: HighlightsRepository(
      db: db,
      versioning: versioning,
      owner: library.activeOwnerId,
    ),
    textSourceFor: (book) async => EpubCardTextSource(
      path: await bookFilePath(db, booksDir, book.id),
      sha: book.contentSha256 ?? '',
    ),
    club: ClubsHighlightsClubSource(
      owner: () async => ref.read(socialOwnerProvider),
      cache: ref.watch(clubsCacheProvider),
    ),
    clubUpdates: ref.watch(clubChipUpdatesProvider),
    share: ref.watch(highlightsShareProvider),
    now: ref.watch(clockProvider),
    utcOffsetAt: readerUtcOffset,
    files: const ShareHighlightsFileSink(),
    onError: reportReaderError,
  );
});

// G11 — o leitor ligado ao app (Riverpod): o banco, a conta ativa, a pasta dos livros, a indexação da G09, a
// fila de layout, a tela acesa (D-111) e a barra de status (D-105). Os testes trocam o que precisam.
import 'package:flutter/services.dart' show SystemChrome, SystemUiMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/database/daos/kv_dao.dart';
import '../../../core/data/database/local_database.dart';
import '../../../core/data/database/local_sql.dart' show deviceIdKey;
import '../../../core/sync/sync_providers.dart' show localVersioningProvider;
import '../../account/application/account_providers.dart'
    show localLibraryProvider;
import '../../clubs/application/club_sources.dart' show ClubsReaderClubSource;
import '../../clubs/application/clubs_providers.dart';
import '../../home/application/home_providers.dart' show clockProvider;
import '../../library/application/library_import.dart'
    show bookImporterProvider, booksDirProvider;
import '../layout/layout_scheduler.dart';
import 'reader_session_controller.dart';
import 'screen_awake.dart';

/// A fila das fatias de layout (uma para o app: o livro aberto e a prévia dos ajustes dividem — G14).
final layoutSchedulerProvider = Provider<LayoutScheduler>(
  (ref) => LayoutScheduler(),
);

final screenAwakeProvider = Provider<ScreenAwake>(
  (ref) => const WakelockScreenAwake(),
);

/// Barra de status do sistema no leitor (D-105).
abstract interface class ReaderSystemUi {
  /// Esconde a barra (leitor limpo); puxar do topo mostra por alguns segundos.
  Future<void> immersive();

  /// Volta ao padrão do app (D-13).
  Future<void> edgeToEdge();
}

final class PlatformReaderSystemUi implements ReaderSystemUi {
  const PlatformReaderSystemUi();

  @override
  Future<void> immersive() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  @override
  Future<void> edgeToEdge() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

final readerSystemUiProvider = Provider<ReaderSystemUi>(
  (ref) => const PlatformReaderSystemUi(),
);

final readerDepsProvider = FutureProvider<ReaderDeps>((ref) async {
  final db = await ref.watch(localDatabaseProvider.future);
  final library = await ref.watch(localLibraryProvider.future);
  final versioning = await ref.watch(localVersioningProvider.future);
  return ReaderDeps(
    db: db,
    versioning: versioning,
    owner: library.activeOwnerId,
    booksDir: ref.watch(booksDirProvider),
    indexBook: (id) async =>
        (await ref.read(bookImporterProvider.future)).indexBook(id),
    scheduler: ref.watch(layoutSchedulerProvider),
    screenAwake: ref.watch(screenAwakeProvider),
    deviceId: await KvDao(db).get(deviceIdKey),
    now: ref.watch(clockProvider),
    // G21.5: a faixa do sumário (27) do clube que lê o livro, do cache
    club: ClubsReaderClubSource(ref.watch(clubsCacheProvider)),
    // G21.6 (R9): a posição do livro de um clube vai para o clube ao sair
    onLeave: (id) async {
      final owner = ref.read(socialOwnerProvider);
      if (owner == null) return;
      await ref.read(progressPublisherProvider)?.publish(owner, id);
    },
  );
});

// Ligações da sincronização do Pro (Riverpod). Sem servidor ou sem PowerSync configurado
// (AppEnv.hasSync = false) a sincronização não existe ([NoSync]) e nada sai do aparelho.
import 'dart:io' show File, FileSystemException;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/server_providers.dart';
import '../data/clock/server_clock.dart';
import '../data/database/local_database.dart';
import 'booknest_connector.dart';
import 'sync_backend.dart';
import 'sync_engine.dart';
import 'sync_store.dart';

final syncTelemetryProvider = Provider<SyncTelemetry>(
  (ref) => const NoSyncTelemetry(),
);

/// Relógio dos HLC corrigido pela hora do servidor (a defasagem guardada vale também offline).
final serverClockProvider = FutureProvider<ServerClock>((ref) async {
  final db = await ref.watch(localDatabaseProvider.future);
  return ServerClock(offsetMs: await SyncStore(db).clockOffset());
});

final syncBackendProvider = Provider<SyncBackend?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseSyncBackend(client);
});

/// O motor (null = sem sincronização nesta versão).
final syncEngineProvider = FutureProvider<SyncEngine?>((ref) async {
  final env = ref.watch(appEnvProvider);
  final backend = ref.watch(syncBackendProvider);
  if (!env.hasSync || backend == null) return null;
  final ps = await ref.watch(powerSyncDatabaseProvider.future);
  final db = await ref.watch(localDatabaseProvider.future);
  final engine = SyncEngine(
    connection: PowerSyncConnection(ps),
    store: SyncStore(db, removeFile: _removeFile),
    backend: backend,
    endpoint: env.powersyncUrl,
    clock: await ref.watch(serverClockProvider.future),
    telemetry: ref.watch(syncTelemetryProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

/// O que a conta usa (sair, entrar, Pro confirmado).
final syncPortProvider = FutureProvider<SyncPort>((ref) async {
  final SyncEngine? engine = await ref.watch(syncEngineProvider.future);
  return engine ?? const NoSync();
});

/// Estado para o indicador (D-21). Sem sincronização: Grátis parado.
final syncStateProvider = StreamProvider<SyncState>((ref) async* {
  final engine = await ref.watch(syncEngineProvider.future);
  if (engine == null) {
    yield const SyncState();
    return;
  }
  yield engine.state;
  yield* engine.states;
});

Future<void> _removeFile(String path) async {
  try {
    await File(path).delete();
  } on FileSystemException {
    // já não existia
  }
}

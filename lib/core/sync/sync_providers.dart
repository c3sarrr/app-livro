// Ligações da sincronização do Pro (Riverpod). Sem servidor ou sem PowerSync configurado
// (AppEnv.hasSync = false) a sincronização não existe ([NoSync]) e nada sai do aparelho.
import 'dart:io' show Directory, File, FileSystemException, Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../config/server_providers.dart';
import '../data/clock/server_clock.dart';
import '../data/database/daos/kv_dao.dart';
import '../data/database/local_database.dart';
import '../data/database/local_sql.dart';
import '../data/database/versioning.dart';
import '../data/ids/uuid_v7.dart';
import 'booknest_connector.dart';
import 'ebook_cloud.dart';
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

/// Versões das escritas locais (ADR-003) com o relógio corrigido pela hora do servidor. O id deste
/// aparelho nos HLC é gerado na 1ª vez e fica no `kv`.
final localVersioningProvider = FutureProvider<LocalVersioning>((ref) async {
  final db = await ref.watch(localDatabaseProvider.future);
  final clock = await ref.watch(serverClockProvider.future);
  final kv = KvDao(db);
  var device = await kv.get(deviceIdKey);
  if (device == null) {
    device = UuidV7Generator().next();
    await kv.set(deviceIdKey, device);
  }
  return LocalVersioning.open(db, deviceId: device, nowMs: clock.nowMs);
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
    store: SyncStore(
      db,
      removeFile: _removeFile,
      versioning: await ref.watch(localVersioningProvider.future),
    ),
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

/// E-books na nuvem (Pro). Null sem servidor nesta versão.
final ebookCloudProvider = FutureProvider<EbookCloud?>((ref) async {
  final env = ref.watch(appEnvProvider);
  final client = ref.watch(supabaseClientProvider);
  if (!env.hasServer || client == null) return null;
  final nuvem = EbookCloud(
    db: await ref.watch(localDatabaseProvider.future),
    api: SupabaseEbookCloudApi(client, projectUrl: Uri.parse(env.supabaseUrl)),
    uploader: ResumableUploader(
      endpoint: Uri.parse(
        '${env.supabaseUrl}/storage/v1/upload/resumable/sign',
      ),
      apiKey: env.supabasePublishableKey,
    ),
    versioning: await ref.watch(localVersioningProvider.future),
    bookFilePath: _bookFilePath,
  );
  await nuvem.recover();
  return nuvem;
});

/// Pasta dos arquivos dos livros (suporte do app, fora dos documentos do usuário). A importação (G09)
/// usa a mesma.
Future<String> _bookFilePath(String userBookId, String format) async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory('${base.path}${Platform.pathSeparator}livros');
  await dir.create(recursive: true);
  return '${dir.path}${Platform.pathSeparator}$userBookId.$format';
}

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

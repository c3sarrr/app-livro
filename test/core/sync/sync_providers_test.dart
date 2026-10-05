// G06 — sem servidor ou sem PowerSync configurado, a sincronização não existe: nada sai do aparelho.
import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/core/config/server_providers.dart';
import 'package:app_leitura/core/data/clock/server_clock.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:app_leitura/core/sync/sync_engine.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'sem configuração: NoSync e o estado Grátis parado (sem abrir o banco)',
    () async {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(await c.read(syncPortProvider.future), isA<NoSync>());
      expect(await c.read(syncEngineProvider.future), isNull);
      // StreamProvider sem ouvinte fica pausado (Riverpod 3)
      final sub = c.listen(syncStateProvider, (_, _) {});
      addTearDown(sub.close);
      expect(await c.read(syncStateProvider.future), const SyncState());
    },
  );

  test(
    'URL do PowerSync sem o servidor (login): continua sem sincronização',
    () async {
      final c = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(powersyncUrl: 'http://127.0.0.1:54330'),
          ),
        ],
      );
      addTearDown(c.dispose);
      expect(await c.read(syncPortProvider.future), isA<NoSync>());
      expect(c.read(syncBackendProvider), isNull);
    },
  );

  test('NoSync não faz nada', () async {
    const s = NoSync();
    await s.resume('x');
    await s.onAccountConfirmed('x', pro: true);
    await s.beforeOwnerChange();
    expect(await s.pendingUploads(), 0);
  });

  test('versões locais: o id do aparelho é criado uma vez e o relógio é o corrigido pelo servidor', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    const servidor = 1789945200000;
    final relogio = ServerClock(
      deviceNowMs: () => servidor + 10 * 60 * 1000,
      offsetMs: -10 * 60 * 1000,
    );
    ProviderContainer novo() => ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWith((ref) async => db),
        serverClockProvider.overrideWith((ref) async => relogio),
      ],
    );
    final c1 = novo();
    final v = await c1.read(localVersioningProvider.future);
    final id = await KvDao(db).get(deviceIdKey);
    expect(id, isNotNull);
    expect(v.clock.deviceId, id);
    expect(v.clock.send().ms, servidor);
    c1.dispose();
    final c2 = novo();
    addTearDown(c2.dispose);
    expect((await c2.read(localVersioningProvider.future)).clock.deviceId, id);
  });

  test('e-books na nuvem: sem servidor, nada', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(await c.read(ebookCloudProvider.future), isNull);
  });
}

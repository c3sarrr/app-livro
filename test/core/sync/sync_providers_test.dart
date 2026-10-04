// G06 — sem servidor ou sem PowerSync configurado, a sincronização não existe: nada sai do aparelho.
import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/core/config/server_providers.dart';
import 'package:app_leitura/core/sync/sync_engine.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

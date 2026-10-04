// Configuração pública do app: o que liga cada parte (servidor, Google, sincronização do Pro).
import 'package:app_leitura/core/config/app_env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'sem nada configurado: só convidado (sem servidor, sem Google, sem sync)',
    () {
      const e = AppEnv();
      expect((e.hasServer, e.hasGoogle, e.hasSync), (false, false, false));
    },
  );

  test('marcador "<…>" do arquivo de exemplo conta como não preenchido', () {
    const e = AppEnv(
      supabaseUrl: 'http://127.0.0.1:54321',
      supabasePublishableKey: '<chave pública sb_publishable_…>',
      powersyncUrl: '<URL da instância PowerSync — G06>',
    );
    expect((e.hasServer, e.hasSync), (false, false));
  });

  test('sync do Pro precisa do servidor (login) e da URL do PowerSync', () {
    const servidor = AppEnv(
      supabaseUrl: 'http://127.0.0.1:54321',
      supabasePublishableKey: 'sb_publishable_x',
    );
    expect((servidor.hasServer, servidor.hasSync), (true, false));
    const tudo = AppEnv(
      supabaseUrl: 'http://127.0.0.1:54321',
      supabasePublishableKey: 'sb_publishable_x',
      powersyncUrl: 'http://127.0.0.1:54330',
    );
    expect(tudo.hasSync, isTrue);
    const soPowerSync = AppEnv(powersyncUrl: 'http://127.0.0.1:54330');
    expect(soPowerSync.hasSync, isFalse);
  });
}

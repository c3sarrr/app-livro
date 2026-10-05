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

  test('G07: catálogo na borda não depende de conta; o endereço sempre termina em "/"', () {
    expect(const AppEnv().hasCatalog, isFalse);
    expect(
      const AppEnv(catalogUrl: '<endereço do Worker>').hasCatalog,
      isFalse,
    );
    const so = AppEnv(catalogUrl: 'http://127.0.0.1:8787');
    expect((so.hasCatalog, so.hasServer), (true, false));
    expect(
      so.catalogBase.resolve('v1/isbn/1').toString(),
      'http://127.0.0.1:8787/v1/isbn/1',
    );
    expect(
      const AppEnv(catalogUrl: 'https://cat.exemplo/base/').catalogBase
          .resolve('v1/x')
          .toString(),
      'https://cat.exemplo/base/v1/x',
    );
  });
}

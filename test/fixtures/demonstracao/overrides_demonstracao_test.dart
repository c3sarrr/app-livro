// R00.7 (D-267, R6) — o modo demonstração não toca no que é do app normal: o banco do demo (PowerSync de verdade, num
// arquivo) abre e se semeia só em `booknest_demo.db` e nas pastas `*_demo`, ao lado de um `booknest.db` e das pastas
// do app normal que ficam byte a byte como estavam; reabrir não semeia de novo; o recomeço apaga só o que é do demo;
// nenhum serviço (servidor, sincronização, catálogo, loja) é ligado, e os dois `main` do demo recusam os
// `--dart-define` deles; o relógio parte do "agora" de referência e anda.
import 'dart:io';

import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/core/preferences/brand_preference.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/catalog/application/catalog_providers.dart';
import 'package:app_leitura/features/catalog/application/catalog_updater.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/library/application/library_import.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_normal_ao_lado.dart';
import '../mundo_2026_09_20.dart';
import 'catalogo_demonstracao.dart';
import 'overrides_demonstracao.dart';
import 'relogio_demonstracao.dart';
import 'semear_mundo.dart';

/// Um cronômetro que só anda quando o teste manda.
final class _Cronometro implements Stopwatch {
  @override
  Duration elapsed = Duration.zero;

  @override
  int get elapsedMicroseconds => elapsed.inMicroseconds;
  @override
  int get elapsedMilliseconds => elapsed.inMilliseconds;
  @override
  int get elapsedTicks => elapsed.inMicroseconds;
  @override
  int get frequency => 1000000;
  @override
  bool get isRunning => true;
  @override
  void reset() => elapsed = Duration.zero;
  @override
  void start() {}
  @override
  void stop() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final m = mundoReferencia;
  late Directory suporte;

  setUp(() => suporte = suporteComAppNormal());
  tearDown(() => apagarPasta(suporte));

  Future<ProviderContainer> abrir() async {
    final c = ProviderContainer(
      overrides: overridesDemonstracao(suporte: () async => suporte),
    );
    // o banco abre e se semeia; os do PowerSync fecham com o container
    await c.read(localDatabaseProvider.future);
    return c;
  }

  Future<void> fechar(ProviderContainer c) async {
    final db = await c.read(localDatabaseProvider.future);
    final ps = await c.read(powerSyncDatabaseProvider.future);
    await db.close();
    await ps.close();
    c.dispose();
  }

  test('abre e semeia só o booknest_demo.db e as pastas *_demo; o app normal fica como estava', () async {
    final c = await abrir();
    final db = await c.read(localDatabaseProvider.future);
    expect(await semeado(db), isTrue);
    expect(
      await (await c.read(localLibraryProvider.future)).activeOwnerId(),
      m.usuarioId,
    );

    final livros = await c.read(booksDirProvider)();
    final capasDoArquivo = await c.read(fileCoversDirProvider)();
    final catalogo = await c.read(catalogDirProvider.future);
    expect(
      [livros.path, capasDoArquivo.path, catalogo.path],
      [
        caminhoEm(suporte, livrosDemonstracao),
        caminhoEm(suporte, capasDoArquivoDemonstracao),
        caminhoEm(suporte, catalogoDemonstracao),
      ],
    );
    expect(arquivoDoDomCasmurro(livros).existsSync(), isTrue);
    expect(c.read(brandStoreProvider), isA<MemoryBrandStore>());
    await fechar(c);

    final nomes = nomesNaRaiz(suporte);
    final doDemo = nomes.where(ehDaDemonstracao).toSet();
    expect(doDemo, containsAll([bancoDemonstracao, livrosDemonstracao]));
    expect(
      nomes.difference(doDemo),
      nomesDoAppNormal,
      reason: 'nada além do demo apareceu na pasta de suporte',
    );
    conferirAppNormal(suporte);
  });

  test('reabrir não semeia de novo: o que se fez no demo continua', () async {
    var c = await abrir();
    var db = await c.read(localDatabaseProvider.future);
    await db.customStatement(
      "INSERT INTO kv (key, value) VALUES ('r00.teste', 'feito no demo')",
    );
    arquivoDoDomCasmurro(await c.read(booksDirProvider)()).deleteSync();
    await fechar(c);

    c = await abrir();
    db = await c.read(localDatabaseProvider.future);
    expect(await semeado(db), isTrue);
    final feito = await db
        .customSelect("SELECT value FROM kv WHERE key = 'r00.teste'")
        .getSingleOrNull();
    expect(feito?.read<String>('value'), 'feito no demo');
    expect(
      arquivoDoDomCasmurro(await c.read(booksDirProvider)()).existsSync(),
      isFalse,
      reason: 'semeado: o arquivo não é escrito de novo',
    );
    await fechar(c);
    conferirAppNormal(suporte);
  });

  test('semeado por outra versão da semeadura: o demo recomeça do zero (só o demo)', () async {
    var c = await abrir();
    var db = await c.read(localDatabaseProvider.future);
    await db.customStatement(
      "INSERT INTO kv (key, value) VALUES ('r00.teste', 'feito no demo')",
    );
    await db.customStatement(
      "UPDATE kv SET value = 'r00-v0' WHERE key = '$chaveSemeado'",
    );
    expect(await semeado(db), isFalse);
    await fechar(c);

    c = await abrir();
    db = await c.read(localDatabaseProvider.future);
    expect(await semeado(db), isTrue);
    expect(
      await db
          .customSelect("SELECT value FROM kv WHERE key = 'r00.teste'")
          .getSingleOrNull(),
      isNull,
      reason: 'o banco antigo do demo saiu inteiro',
    );
    expect(
      arquivoDoDomCasmurro(await c.read(booksDirProvider)()).existsSync(),
      isTrue,
    );
    await fechar(c);
    conferirAppNormal(suporte);
  });

  test(
    'o recomeço (BOOKNEST_DEMO_RECOMECAR) apaga só o banco e as pastas do demo',
    () async {
      final c = await abrir();
      await c.read(catalogDirProvider.future);
      await c.read(fileCoversDirProvider)();
      await fechar(c);
      expect(nomesNaRaiz(suporte).where(ehDaDemonstracao), isNotEmpty);

      await apagarDemonstracao(suporte: () async => suporte);
      expect(nomesNaRaiz(suporte).where(ehDaDemonstracao), isEmpty);
      expect(nomesNaRaiz(suporte), nomesDoAppNormal);
      conferirAppNormal(suporte);

      // e o demo volta ao mundo de referência
      final d = await abrir();
      expect(await semeado(await d.read(localDatabaseProvider.future)), isTrue);
      await fechar(d);
    },
  );

  test(
    'o recomeço numa pasta de suporte que ainda não existe não faz nada',
    () async {
      final nenhuma = Directory(caminhoEm(suporte, 'nao_existe'));
      await apagarDemonstracao(suporte: () async => nenhuma);
      expect(nenhuma.existsSync(), isFalse);
    },
  );

  test('ehDaDemonstracao: só o banco do demo (e os arquivos do SQLite ao lado) e as pastas *_demo', () {
    for (final nome in [
      'booknest_demo.db',
      'booknest_demo.db-wal',
      'booknest_demo.db-shm',
      'livros_demo',
      'capas_demo',
      'capas_arquivo_demo',
      'catalogo_demo',
    ]) {
      expect(ehDaDemonstracao(nome), isTrue, reason: nome);
    }
    for (final nome in [
      'booknest.db',
      'booknest.db-wal',
      'livros',
      'capas',
      'capas_arquivo',
      'catalogo',
      'livros_demo_x',
      'demo',
    ]) {
      expect(ehDaDemonstracao(nome), isFalse, reason: nome);
    }
  });

  test('nenhum serviço: sem servidor, sem Supabase, sem loja e o catálogo só do demo, sem rede; a Marina no '
      'cabeçalho', () async {
    // o demo troca a configuração e o cliente do Supabase (trocar de novo no mesmo container é proibido)
    for (final outro in [
      appEnvProvider.overrideWithValue(const AppEnv()),
      supabaseClientProvider.overrideWithValue(null),
    ]) {
      expect(
        () => ProviderContainer(
          overrides: [
            ...overridesDemonstracao(suporte: () async => suporte),
            outro,
          ],
        ),
        throwsA(isA<AssertionError>()),
      );
    }
    final c = ProviderContainer(
      overrides: overridesDemonstracao(suporte: () async => suporte),
    );
    addTearDown(c.dispose);
    final env = c.read(appEnvProvider);
    expect((env.hasServer, env.hasSync, env.hasCatalog), (false, false, false));
    expect(servicosNosDefines(env), isEmpty);
    expect(c.read(supabaseClientProvider), isNull);
    // o catálogo do aparelho é o do demo, na pasta do demo, e não baixa: a rede é sempre "nenhuma"
    final catalogo = (await c.read(catalogUpdaterProvider.future))!;
    expect(catalogo.dir.path, caminhoEm(suporte, catalogoDemonstracao));
    expect(
      await catalogo.update(force: true),
      isA<CatalogUpdateSkipped>().having((u) => u.reason, 'reason', 'sem_rede'),
    );
    expect(await (await catalogo.catalog())!.version(), versaoDoCatalogoDoDemo);
    expect(c.read(homeAccountUserProvider), usuarioDoMundo);
    expect(
      (usuarioDoMundo.firstName, usuarioDoMundo.unreadNotifications),
      (m.perfil.nome, m.perfil.notificacoesNaoLidas),
    );
  });

  test('os dois main do demo recusam os --dart-define dos serviços', () {
    expect(() => recusarServicos(const AppEnv()), returnsNormally);
    expect(
      () => recusarServicos(const AppEnv(catalogUrl: 'http://catalogo/')),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('catálogo (CATALOG_URL)'),
        ),
      ),
    );
    expect(servicosNosDefines(const AppEnv(supabaseUrl: 'https://x')), [
      'servidor (SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY)',
    ]);
    expect(
      servicosNosDefines(const AppEnv(supabasePublishableKey: 'k')),
      hasLength(1),
    );
    expect(servicosNosDefines(const AppEnv(powersyncUrl: 'http://p')), [
      'sincronização (POWERSYNC_URL)',
    ]);
    expect(servicosNosDefines(const AppEnv(revenuecatKeyAndroid: 'goog_x')), [
      'loja (REVENUECAT_PUBLIC_KEY_*)',
    ]);
    expect(servicosNosDefines(const AppEnv(revenuecatKeyIos: 'appl_x')), [
      'loja (REVENUECAT_PUBLIC_KEY_*)',
    ]);
    expect(servicosNosDefines(const AppEnv(termsUrl: 'https://t')), isEmpty);
    for (final main in [
      'test/fixtures/main_demonstracao.dart',
      'test/fixtures/main_mundo_referencia.dart',
    ]) {
      final fonte = File(main).readAsStringSync();
      expect(
        fonte,
        contains('recusarServicos(AppEnv.fromDefines());'),
        reason: main,
      );
      expect(fonte, contains('if (kReleaseMode)'), reason: main);
      expect(
        fonte.indexOf('recusarServicos('),
        lessThan(fonte.indexOf('runBookNest(')),
        reason: '$main recusa antes de subir o app',
      );
    }
  });

  test('o relógio parte de dom 20/09/2026 20:00 e anda com o cronômetro', () {
    final cronometro = _Cronometro();
    final agora = relogioDemonstracao(m.agora, cronometro: cronometro);
    expect(agora(), m.agora);
    expect(m.agora.add(m.fuso), DateTime.utc(2026, 9, 20, 20));
    cronometro.elapsed = const Duration(minutes: 3, seconds: 7);
    expect(agora(), m.agora.add(const Duration(minutes: 3, seconds: 7)));
    cronometro.elapsed = const Duration(hours: 5);
    expect(agora(), DateTime.utc(2026, 9, 21, 4));

    // sem cronômetro, um de verdade (que já anda)
    final real = relogioDemonstracao(m.agora);
    final a = real();
    expect(a.isBefore(m.agora), isFalse);
    expect(a.difference(m.agora), lessThan(const Duration(seconds: 5)));
  });
}

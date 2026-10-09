// G05.6 — privacidade do plano Grátis (§4.3.7, ADR-002): com conta, o Grátis só fala com o servidor
// para login/sessão e perfil. Os livros, grifos, notas, sessões e a data de nascimento NUNCA saem do
// aparelho. O teste passa pela pilha real (controller → gateway/API → cliente do Supabase) e grava
// cada pedido HTTP; qualquer endpoint fora da lista ou qualquer dado pessoal no pedido reprova.
import 'dart:io';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:app_leitura/features/account/application/account_controller.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/account/data/native_sign_in.dart';
import 'package:app_leitura/features/account/data/store_age_signals.dart';
import 'package:app_leitura/features/billing/application/billing_controller.dart';
import 'package:app_leitura/features/billing/application/billing_providers.dart';
import 'package:app_leitura/features/clubs/application/clubs_providers.dart';
import 'package:app_leitura/features/clubs/application/publishers.dart';
import 'package:app_leitura/features/clubs/application/stats_provider.dart';
import 'package:app_leitura/features/clubs/data/clubs_cache.dart';
import 'package:app_leitura/features/highlights/application/highlights_controller.dart';
import 'package:app_leitura/features/highlights/application/highlights_providers.dart';
import 'package:app_leitura/features/home/application/home_providers.dart'
    show clockProvider;
import 'package:app_leitura/features/library/application/library_import.dart'
    show booksDirProvider;
import 'package:app_leitura/features/social/application/social_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show OtpType, SupabaseClient;

import '../../support/personal_builders.dart';
import '../billing/support/billing_fakes.dart'
    show ContaFalsa, LojaFalsa, MemoriaFalsa, membro, proDaLoja;
import 'support/account_fakes.dart';
import 'support/fake_backend.dart';

final class _SemGoogle implements GoogleTokenSource {
  @override
  Future<GoogleTokens> obtain() => throw UnimplementedError();
}

final class _SemApple implements AppleTokenSource {
  @override
  bool get isNative => true;
  @override
  Future<String> identityToken({required String hashedNonce}) =>
      throw UnimplementedError();
}

/// O que o Grátis pode chamar (login/sessão e perfil — §4.3.7).
const Set<String> permitidos = {
  'POST /auth/v1/otp',
  'POST /auth/v1/verify',
  'POST /auth/v1/logout',
  'POST /rest/v1/rpc/my_account',
  'POST /rest/v1/rpc/set_my_age_band',
  'PATCH /rest/v1/profiles',
  'POST /functions/v1/export-data',
  'POST /functions/v1/delete-account',
};

/// G21.6 (docs/progresso/G21.md §6): o social do Grátis — só o que ele publica, e as leituras sem dado pessoal.
const Set<String> permitidosG21 = {
  // leituras que não levam dado pessoal: os meus clubes (o ticket), os resumos do chip da 25 (os ids dos posts),
  // os termos e a contagem do sininho (sem as linhas)
  'POST /rest/v1/rpc/my_clubs',
  'POST /rest/v1/rpc/club_post_summaries',
  'POST /rest/v1/rpc/my_terms',
  'HEAD /rest/v1/notifications',
  // só depois do toque em Compartilhar: o trecho, a cor, a página e o capítulo do clube (a nota fica — D-217)
  'POST /rest/v1/rpc/share_highlight',
  // só do livro de um clube, ao sair do leitor (R9): a fração e o capítulo do clube
  'POST /rest/v1/rpc/publish_progress',
  // os 4 números agregados do perfil, uma vez por dia (R10)
  'POST /rest/v1/rpc/publish_my_stats',
  // o aceite das regras da comunidade (D-222)
  'POST /rest/v1/rpc/accept_terms',
};

/// G22 (docs/progresso/G22.md §2, D-229): o Pro. Só depois de uma ação de compra (comprar, restaurar) ou do "conferir
/// agora" da tela técnica; o pedido não leva nada além da sessão: o servidor busca o estado da própria conta no
/// RevenueCat. O Grátis que não compra não fala com o RevenueCat (o SDK nem é configurado).
const Set<String> permitidosG22 = {
  'POST /functions/v1/revenuecat-sync',
  'POST /rest/v1/rpc/my_entitlement',
};

void main() {
  test('Grátis com conta: entrar, idade, @, exportar e sair só tocam login/perfil — nenhum dado pessoal sai', () async {
    final backend = FakeBackend();
    final SupabaseClient client = backend.client();
    final h = AccountHarness(
      servidor: false,
      loja: const StoreAgeUnavailable(),
    );
    final c = ProviderContainer(
      overrides: [
        ...h.deviceOverrides,
        h.relogio,
        // o gateway e a API são os reais, montados sobre o cliente do Supabase
        supabaseClientProvider.overrideWithValue(client),
        googleTokenSourceProvider.overrideWithValue(_SemGoogle()),
        appleTokenSourceProvider.overrideWithValue(_SemApple()),
      ],
    );
    addTearDown(() async {
      c.dispose();
      await client.dispose();
      await h.close();
    });
    c.listen(accountControllerProvider, (_, _) {}, fireImmediately: true);
    final ctl = c.read(accountControllerProvider.notifier);
    await ctl.settled();

    // Dados pessoais do convidado no aparelho.
    final g = await h.library.guestOwnerId();
    const titulo = 'Memórias Póstumas de Brás Cubas';
    const trecho = 'Ao verme que primeiro roeu as frias carnes';
    const nota = 'Dedicatória mais irônica da literatura brasileira';
    final livro = livroTeste(1, dono: g, title: titulo);
    await UserBooksDao(h.db).upsert(livro);
    final grifo = grifoTeste(10, livro: livro.id, dono: g, exato: trecho);
    await AnnotationsDao(h.db).upsert(grifo);
    await AnnotationsDao(h.db)
        .upsert(notaTeste(11, livro: livro.id, pai: grifo, texto: nota));
    await ReadingSessionsDao(h.db)
        .upsert(sessaoTeste(12, livro: livro.id, inicio: t0Teste, dono: g));

    // Fluxo completo do Grátis com conta.
    await ctl.checkAge(birthDate: DateTime(1987, 3, 14));
    await ctl.sendEmailCode(emailTeste);
    await ctl.verifyEmailCode(emailTeste, '123456');
    await ctl.settled();
    await ctl.chooseHandle('bras.cubas');
    await ctl.exportMyData();
    await ctl.signOut(eraseLocal: false);

    // O arquivo exportado tem os dados (vai para a pessoa, pelo menu de compartilhar)…
    final (_, exportado) = h.sink.entregas.single;
    expect(exportado, contains(titulo));
    expect(exportado, contains(nota));

    // …mas nada disso foi para a rede.
    expect(backend.pedidos, isNotEmpty);
    final fora = backend.caminhos
        .where((p) => !permitidos.contains(p))
        .toList();
    expect(
      fora,
      isEmpty,
      reason: 'endpoints fora do permitido ao Grátis: $fora',
    );
    final proibidos = [
      titulo,
      trecho,
      nota,
      livro.id,
      livro.contentSha256!,
      grifo.id,
      '1987', // a data de nascimento fica no aparelho (só a faixa sobe)
      '03-14',
      '14/03',
    ];
    for (final p in backend.pedidos) {
      final tudo = '${p.url} ${p.body}';
      for (final x in proibidos) {
        expect(
          tudo.contains(x),
          isFalse,
          reason: '"$x" saiu do aparelho em $p',
        );
      }
    }
    // Os endpoints de sincronização e de livros na nuvem (Pro) nunca aparecem.
    for (final p in backend.caminhos) {
      expect(p, isNot(contains('sync_apply_changes')));
      expect(p, isNot(contains('ebook-upload-url')));
      expect(p, isNot(contains('/storage/v1/')));
    }
    debugPrintPedidos(backend);
  });

  _semClube();
  _pro();
}

/// G21.6: um Grátis com conta e sem clube.
void _semClube() => test('G21: Grátis com conta e sem clube — ler, grifar e abrir a 25 não chamam nada; o ciclo do app só lê e publica os números', () async {
  final backend = FakeBackend(
    respostas: {
      'POST /rest/v1/rpc/my_clubs': (200, <Object?>[]),
      'HEAD /rest/v1/notifications': (200, null),
      'POST /rest/v1/rpc/publish_my_stats': (200, true),
    },
    cabecalhos: {
      'HEAD /rest/v1/notifications': {'content-range': '*/0'},
    },
  );
  final client = backend.client();
  addTearDown(client.dispose);
  await client.auth.verifyOTP(
    email: emailTeste,
    token: '123456',
    type: OtpType.email,
  );
  final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
  addTearDown(db.close);
  final raiz = Directory.systemTemp.createTempSync('booknest_g21_priv_');
  addTearDown(() => raiz.deleteSync(recursive: true));

  const titulo = 'Memórias Póstumas de Brás Cubas';
  const trecho = 'Ao verme que primeiro roeu as frias carnes';
  final livro = livroTeste(1, dono: contaTeste, title: titulo);
  await UserBooksDao(db).upsert(livro);
  await ReadingPositionsDao(db)
      .upsert(posicaoTeste(livro.id, dono: contaTeste));

  final cache = ClubsCache(() async => db);
  final c = ProviderContainer(
    overrides: [
      supabaseClientProvider.overrideWithValue(client),
      socialOwnerProvider.overrideWithValue(contaTeste),
      localDatabaseProvider.overrideWith((ref) async => db),
      localLibraryProvider.overrideWith((ref) async => LocalLibrary(db)),
      localVersioningProvider.overrideWith(
        (ref) async => LocalVersioning(db, HlcClock(deviceId: 'aparelhoX')),
      ),
      booksDirProvider.overrideWithValue(() async => raiz),
      clockProvider.overrideWithValue(() => DateTime.utc(2026, 10, 9, 12)),
      clubsCacheProvider.overrideWithValue(cache),
      statsPublisherProvider.overrideWith(
        (ref) => StatsPublisher(
          profiles: ref.watch(profileRepositoryProvider)!,
          cache: cache,
          database: () async => db,
          streak: () async => 4,
          now: () => DateTime.utc(2026, 10, 9, 12),
        ),
      ),
    ],
  );
  addTearDown(c.dispose);
  backend.pedidos.clear();

  // o ciclo do app (abrir, voltar): os clubes, o sininho e os números do perfil
  await c.read(clubsSyncProvider)!.refresh(contaTeste);
  await c.read(statsPublisherProvider)!.publishIfDue(contaTeste);
  expect(backend.caminhos, [
    'POST /rest/v1/rpc/my_clubs',
    'HEAD /rest/v1/notifications',
    'POST /rest/v1/rpc/publish_my_stats',
  ]);
  expect(backend.caminhos.every(permitidosG21.contains), isTrue);
  expect((backend.pedidos.last.json! as Map).keys.toSet(), {
    'p_books_read_total',
    'p_books_read_year',
    'p_reading_now',
    'p_streak_days',
  }, reason: 'só os 4 números agregados');

  backend.pedidos.clear();
  // ler: sair do leitor (o livro não é de clube — R9)
  expect(
    await c.read(progressPublisherProvider)!.publish(contaTeste, livro.id),
    0,
  );
  // grifar: o grifo fica no aparelho
  await AnnotationsDao(db)
      .upsert(grifoTeste(10, livro: livro.id, dono: contaTeste, exato: trecho));
  // abrir a 25 (o chip ao vivo e o compartilhar ligados)
  final deps = await c.read(highlightsDepsProvider.future);
  expect(deps.clubUpdates, isNotNull);
  expect(deps.share, isNotNull);
  final h = HighlightsController(deps: deps, userBookId: livro.id);
  await h.load();
  for (var i = 0; i < 100 && h.state.loading; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(h.state.cards, hasLength(1));
  h.dispose();
  await pumpEventQueue();
  expect(backend.pedidos, isEmpty, reason: 'nada novo: ${backend.caminhos}');
});

void debugPrintPedidos(FakeBackend b) =>
    debugPrint('[privacidade] pedidos do Grátis: ${b.caminhos.join(', ')}');

/// G22.5: um Grátis com conta que não compra, e depois restaura.
void _pro() => test('G22: Grátis com conta e sem compra — entrar e voltar ao app não chamam o RevenueCat nem o servidor do Pro; restaurar chama só o permitido, sem corpo', () async {
  final backend = FakeBackend(
    respostas: {
      'POST /functions/v1/revenuecat-sync': (
        200,
        {'pro': true, 'active_until': '2026-11-12T15:00:00+00:00'},
      ),
    },
  );
  final client = backend.client();
  addTearDown(client.dispose);
  await client.auth.verifyOTP(
    email: emailTeste,
    token: '123456',
    type: OtpType.email,
  );
  final loja = LojaFalsa();
  final conta = ContaFalsa(membro(contaTeste));
  final c = ProviderContainer(
    overrides: [
      supabaseClientProvider.overrideWithValue(client),
      accountControllerProvider.overrideWith(() => conta),
      billingGatewayProvider.overrideWithValue(loja),
      billingStoreMemoryProvider.overrideWithValue(MemoriaFalsa()),
      billingSleepProvider.overrideWithValue((_) async {}),
    ],
  );
  addTearDown(c.dispose);
  c.listen(billingControllerProvider, (_, _) {});
  backend.pedidos.clear();

  // entrar (o resumo Grátis) e voltar ao app
  await pumpEventQueue();
  c.read(billingControllerProvider.notifier).resumed();
  await pumpEventQueue();
  expect(
    loja.chamadas,
    isEmpty,
    reason: 'o Grátis sem compra não fala com o RevenueCat',
  );
  expect(backend.pedidos, isEmpty);

  // restaurar (uma ação da pessoa): a loja, e o servidor só com a sessão
  loja.cliente = proDaLoja;
  conta.proNoServidor = true;
  await c.read(billingControllerProvider.notifier).restore();
  await pumpEventQueue();
  expect(loja.chamadas.first, 'configure:$contaTeste');
  expect(backend.caminhos, ['POST /functions/v1/revenuecat-sync']);
  expect(backend.caminhos.every(permitidosG22.contains), isTrue);
  expect(backend.pedidos.single.body, anyOf(isEmpty, '{}'));
});

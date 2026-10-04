// G05 — ponta a ponta contra o Supabase LOCAL (WSL): idade → código por e-mail (lido no Mailpit) →
// conta → @ → exportação → exclusão, pela pilha real do app (controller → gateway/API → supabase).
// Também confere, na rede de verdade, a privacidade do Grátis (G05.6).
//
// Roda só quando pedido:
//   $env:BOOKNEST_SUPABASE_URL = 'http://127.0.0.1:54321'
//   $env:BOOKNEST_SUPABASE_PUBLISHABLE_KEY = '<a chave pública LOCAL de `supabase status`>'
//   flutter test --tags integracao test/integracao
// (as variáveis vêm do ambiente — nunca do repositório; o código do e-mail não é impresso)
@Tags(['integracao'])
library;

import 'dart:convert';

import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/features/account/application/account_controller.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/secure_session_storage.dart';
import 'package:app_leitura/features/account/domain/age.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthClientOptions, SupabaseClient;

import '../features/account/support/account_fakes.dart';
import '../features/account/support/fake_backend.dart' as fb;
import '../support/personal_builders.dart';
import 'support/local.dart';

final String? _url = supabaseUrlLocal;
final String? _key = supabaseChaveLocal;

/// Grava os pedidos que saem do app (para o teste de privacidade) e repassa à rede de verdade.
final class _Gravador extends http.BaseClient {
  _Gravador(this._inner);
  final http.Client _inner;
  final List<fb.Pedido> pedidos = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // ler `body` não finaliza o pedido: ele segue igual para a rede
    final body = request is http.Request ? request.body : '<stream>';
    pedidos.add(fb.Pedido(request.method, request.url, body, request.headers));
    return _inner.send(request);
  }
}

void main() {
  final pronto = _url != null && _key != null;

  test(
    'Grátis com conta, de ponta a ponta no Supabase local: só login/perfil vão para a rede',
    () async {
      final gravador = _Gravador(http.Client());
      final client = SupabaseClient(
        _url!,
        _key!,
        httpClient: gravador,
        authOptions: AuthClientOptions(
          autoRefreshToken: false,
          pkceAsyncStorage: SecurePkceStorage(fb.MemorySecureStore()),
        ),
      );
      final h = AccountHarness(servidor: false);
      final c = ProviderContainer(
        overrides: [
          ...h.deviceOverrides,
          h.relogio,
          supabaseClientProvider.overrideWithValue(client),
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

      // Dado pessoal do convidado (não pode ir para a rede).
      final g = await h.library.guestOwnerId();
      const titulo = 'Quincas Borba — exemplar de teste G05';
      const trecho = 'Ao vencedor, as batatas';
      final livro = livroTeste(1, dono: g, title: titulo);
      await UserBooksDao(h.db).upsert(livro);
      await AnnotationsDao(h.db)
          .upsert(grifoTeste(10, livro: livro.id, dono: g, exato: trecho));

      final marca = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
      final email = 'g05-$marca@exemplo.test';
      expect(
        await ctl.checkAge(birthDate: DateTime(1990, 5, 1)),
        isA<AgeAllowed>(),
      );
      final antes = DateTime.now().toUtc().subtract(const Duration(seconds: 5));
      await ctl.sendEmailCode(email);
      final codigo = await codigoNoMailpit(email, depoisDe: antes);
      await ctl.verifyEmailCode(email, codigo);
      await ctl.settled();

      var s = c.read(accountControllerProvider);
      expect(s, isA<MemberView>());
      s as MemberView;
      expect(s.problem, isNull, reason: '${s.problem}');
      expect(s.summary!.handleProvisional, isTrue);
      expect(s.summary!.ageBand, AgeBand.adult);
      expect(s.needsOnboarding, isTrue);

      final arroba = 'g05_$marca';
      await ctl.chooseHandle(arroba);
      s = c.read(accountControllerProvider) as MemberView;
      expect(s.summary!.handle, arroba);
      expect(s.needsOnboarding, isFalse);

      await ctl.exportMyData();
      final json =
          jsonDecode(h.sink.entregas.single.$2) as Map<String, Object?>;
      final conta = json['account']! as Map;
      expect(conta['format_version'], 2);
      expect((conta['age']! as Map)['band'], '18_plus');
      expect(
        jsonEncode(json),
        contains(titulo),
      ); // o aparelho vai no arquivo, para a pessoa

      await ctl.deleteAccount(eraseLocal: true);
      expect(c.read(accountControllerProvider), isA<GuestView>());

      // Privacidade (G05.6) na rede de verdade.
      final caminhos = gravador.pedidos
          .map((p) => '${p.method} ${p.url.path}')
          .toSet();
      const permitidos = {
        'POST /auth/v1/otp',
        'POST /auth/v1/verify',
        'POST /auth/v1/logout',
        'POST /rest/v1/rpc/my_account',
        'POST /rest/v1/rpc/set_my_age_band',
        'PATCH /rest/v1/profiles',
        'POST /functions/v1/export-data',
        'POST /functions/v1/delete-account',
      };
      expect(caminhos.difference(permitidos), isEmpty);
      for (final p in gravador.pedidos) {
        final tudo = '${p.url} ${p.body}';
        for (final x in [
          titulo,
          trecho,
          livro.id,
          livro.contentSha256!,
          '1990',
        ]) {
          expect(
            tudo.contains(x),
            isFalse,
            reason: '"$x" saiu do aparelho em ${p.method} ${p.url.path}',
          );
        }
      }
    },
    skip: pronto
        ? false
        : 'defina BOOKNEST_SUPABASE_URL e BOOKNEST_SUPABASE_PUBLISHABLE_KEY',
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

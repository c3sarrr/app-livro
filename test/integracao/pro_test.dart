// G22.6 — o "conferir agora" de verdade (D-229): a Edge Function `revenuecat-sync` do Supabase LOCAL, com a chave
// secreta do RevenueCat no `supabase/functions/.env` (fora do git), contra a API do RevenueCat (o projeto com a
// Test Store — D-228).
//
// Roda só quando pedido (as variáveis vêm do ambiente — nunca do repositório; o código do e-mail não é impresso):
//   $env:BOOKNEST_SUPABASE_URL = 'http://127.0.0.1:54321'
//   $env:BOOKNEST_SUPABASE_PUBLISHABLE_KEY = '<a chave pública LOCAL de `supabase status`>'
//   flutter test --tags integracao test/integracao/pro_test.dart
// Com `BOOKNEST_PRO_EMAIL` (a conta que comprou na Test Store pelo emulador), confere também o Pro dela.
@Tags(['integracao'])
library;

import 'dart:io';

import 'package:app_leitura/features/account/data/secure_session_storage.dart';
import 'package:app_leitura/features/billing/data/pro_server_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthClientOptions, OtpType, SupabaseClient;

import '../features/account/support/fake_backend.dart' show MemorySecureStore;
import 'support/local.dart';

/// Uma conta entra pelo código do e-mail (o Mailpit local).
Future<SupabaseClient> entrar(String email) async {
  final client = SupabaseClient(
    supabaseUrlLocal!,
    supabaseChaveLocal!,
    authOptions: AuthClientOptions(
      autoRefreshToken: false,
      pkceAsyncStorage: SecurePkceStorage(MemorySecureStore()),
    ),
  );
  final antes = DateTime.now().toUtc().subtract(const Duration(seconds: 5));
  await client.auth.signInWithOtp(email: email);
  await client.auth.verifyOTP(
    email: email,
    token: await codigoNoMailpit(email, depoisDe: antes),
    type: OtpType.email,
  );
  return client;
}

void main() {
  final pronto = supabaseUrlLocal != null && supabaseChaveLocal != null;
  final emailPro = Platform.environment['BOOKNEST_PRO_EMAIL'];

  test(
    'uma conta que nunca comprou: o servidor confere no RevenueCat e diz Grátis, sem gravar assinatura',
    () async {
      final email =
          'g22.gratis.${DateTime.now().millisecondsSinceEpoch}@booknest.teste';
      final client = await entrar(email);
      addTearDown(client.dispose);
      final id = client.auth.currentUser!.id;

      final r = await SupabaseProServerApi(client).syncNow();
      expect(r, (pro: false, activeUntil: null));
      expect(
        await sqlLocal(
          "select count(*) from billing.subscriptions where user_id = '$id';",
        ),
        '0',
      );
      // o my_entitlement concorda
      expect(
        await SupabaseProServerApi(client).current(),
        (pro: false, activeUntil: null),
      );
    },
    skip: pronto ? false : 'sem o Supabase local',
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'a conta que comprou na Test Store: o servidor confirma o Pro, marcado como sandbox',
    () async {
      final client = await entrar(emailPro!);
      addTearDown(client.dispose);
      final id = client.auth.currentUser!.id;

      final r = await SupabaseProServerApi(client).syncNow();
      expect(r.pro, isTrue);
      expect(r.activeUntil, isNotNull);
      expect(
        await sqlLocal(
          "select string_agg(distinct environment || ':' || store, ',') "
          "from billing.subscriptions where user_id = '$id';",
        ),
        'sandbox:test_store',
      );
      expect(
        await sqlLocal("select public.entitlement_of('$id') ->> 'pro';"),
        'true',
      );
    },
    skip: !pronto
        ? 'sem o Supabase local'
        : emailPro == null
        ? 'sem BOOKNEST_PRO_EMAIL (a conta que comprou no emulador)'
        : false,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

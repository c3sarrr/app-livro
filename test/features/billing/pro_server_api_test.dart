// G22.2 — o servidor do Pro no app (docs/progresso/G22.md §2, D-229): o "conferir agora" (`revenuecat-sync`) e o
// `my_entitlement`, com a sessão conferida e as falhas do social (G21).
import 'package:app_leitura/features/billing/data/pro_server_api.dart';
import 'package:app_leitura/features/social/domain/social_failure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../social/support/social_backend.dart';

void main() {
  const sync = 'POST /functions/v1/revenuecat-sync';
  const direito = 'POST /rest/v1/rpc/my_entitlement';

  test('conferir agora: só o POST da função, com o JWT da conta; devolve o Pro do servidor', () async {
    final (b, c) = await servidorSocial(
      respostas: {
        sync: (200, {'pro': true, 'active_until': '2026-11-12T15:00:00+00:00'}),
      },
    );
    final r = await SupabaseProServerApi(c).syncNow();
    expect(r, (pro: true, activeUntil: DateTime.utc(2026, 11, 12, 15)));
    expect(b.caminhos, [sync]);
    expect(b.pedidos.single.jwt, c.auth.currentSession!.accessToken);
  });

  test('sem Pro no servidor: falso e sem data', () async {
    final (_, c) = await servidorSocial(
      respostas: {
        sync: (200, {'pro': false, 'active_until': null}),
      },
    );
    expect(await SupabaseProServerApi(c).syncNow(), (
      pro: false,
      activeUntil: null,
    ));
  });

  test('as respostas de erro da função viram as falhas do social', () async {
    Future<Object?> falha(int status) async {
      final (_, c) = await servidorSocial(
        respostas: {
          sync: (status, {'erro': 'x'}),
        },
      );
      try {
        await SupabaseProServerApi(c).syncNow();
      } on SocialFailure catch (e) {
        return e;
      }
      return null;
    }

    expect(await falha(401), isA<SocialNeedsAccount>());
    // o limite do dia e o RevenueCat fora do ar: tentar de novo mais tarde (R2)
    expect(await falha(429), isA<SocialOffline>());
    expect(await falha(502), isA<SocialOffline>());
    expect(
      await falha(500),
      isA<SocialUnexpected>().having((f) => f.code, 'code', 'fn_500'),
    );
  });

  test('sem rede: sem conexão', () async {
    final (b, c) = await servidorSocial();
    b.offline = true;
    await expectLater(
      SupabaseProServerApi(c).syncNow(),
      throwsA(isA<SocialOffline>()),
    );
  });

  test('sem sessão: nada sai', () async {
    final (b, c) = await servidorSocial(entrar: false);
    await expectLater(
      SupabaseProServerApi(c).syncNow(),
      throwsA(isA<SocialNeedsAccount>()),
    );
    await expectLater(
      SupabaseProServerApi(c).current(),
      throwsA(isA<SocialNeedsAccount>()),
    );
    expect(b.pedidos, isEmpty);
  });

  test('o que o servidor sabe agora: my_entitlement', () async {
    final (b, c) = await servidorSocial(
      respostas: {
        direito: (200, {'pro': true, 'active_until': '2026-11-12T15:00:00Z'}),
      },
    );
    expect(await SupabaseProServerApi(c).current(), (
      pro: true,
      activeUntil: DateTime.utc(2026, 11, 12, 15),
    ));
    expect(b.caminhos, [direito]);
  });
}

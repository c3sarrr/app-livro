// G06.1 — o servidor da sincronização sobre o cliente REAL do Supabase (servidor de mentira): estado do
// Pro com a hora do servidor, RPC em lote e a classificação dos erros da chamada inteira.
import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:app_leitura/core/sync/sync_backend.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OtpType;

import '../../features/account/support/fake_backend.dart';

void main() {
  late FakeBackend fb;
  late SupabaseSyncBackend b;

  setUp(() {
    fb = FakeBackend();
    b = SupabaseSyncBackend(fb.client());
  });

  Future<void> logar() async {
    final client = fb.client();
    b = SupabaseSyncBackend(client);
    await client.auth.verifyOTP(
      email: emailTeste,
      token: '123456',
      type: OtpType.email,
    );
  }

  test('sem sessão: sem token e sem usuário', () async {
    expect(await b.accessToken(), isNull);
    expect(b.userId, isNull);
  });

  test('com sessão: o JWT da sessão e quando vence', () async {
    await logar();
    final t = (await b.accessToken())!;
    final corpo = t.token.split('.')[1];
    final claims = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(corpo))),
    ) as Map;
    expect(claims['sub'], contaTeste);
    expect(t.expiresAt!.isAfter(DateTime.now().toUtc()), isTrue);
    expect(b.userId, contaTeste);
  });

  test('estado do Pro: pro, fim previsto e a hora do servidor', () async {
    await logar();
    fb.respostas['POST /rest/v1/rpc/my_entitlement'] = (
      200,
      {
        'pro': true,
        'active_until': '2026-11-04T12:00:00+00:00',
        'server_time_ms': 1791115200000,
      },
    );
    final e = await b.entitlement();
    expect(e.pro, isTrue);
    expect(e.activeUntil, DateTime.utc(2026, 11, 4, 12));
    expect(e.serverTimeMs, 1791115200000);
  });

  test(
    'RPC: manda o lote em p_changes e lê aplicadas, ignoradas e recusas',
    () async {
      await logar();
      fb.respostas['POST /rest/v1/rpc/sync_apply_changes'] = (
        200,
        {
          'applied': 1,
          'skipped': 1,
          'rejected': [
            {
              'table': 'annotations',
              'id': 'a1',
              'error': 'invalid_hlc',
              'code': '22023',
              'retryable': false,
            },
          ],
        },
      );
      final ops = [
        {
          'op': 'PUT',
          'table': 'annotations',
          'id': 'a1',
          'hlc': 'h',
          'data': {'x': 1},
        },
      ];
      final r = await b.applyChanges(ops);
      expect((r.applied, r.skipped), (1, 1));
      expect(r.rejected.single.invalidHlc, isTrue);
      expect(r.rejected.single.code, '22023');
      expect(fb.pedidos.last.json, {'p_changes': ops});
      expect(fb.pedidos.last.jwt, isNotNull);
    },
  );

  group('erro da chamada inteira (nada aplicado)', () {
    Future<SyncCallFailure> falha(Resposta r) async {
      await logar();
      fb.respostas['POST /rest/v1/rpc/sync_apply_changes'] = r;
      try {
        await b.applyChanges(const []);
      } on SyncCallFailure catch (f) {
        return f;
      }
      fail('não lançou');
    }

    test('pro_required → ProRequired', () async {
      expect(
        await falha(erroPostgrest(400, 'P0001', 'pro_required')),
        isA<ProRequired>(),
      );
    });

    test('conflito/trava transitória e 5xx → repetir', () async {
      expect(
        await falha(erroPostgrest(500, '40001', 'could not serialize')),
        isA<SyncTransient>().having((f) => f.kind, 'kind', 'pg_40001'),
      );
      expect(
        await falha(erroPostgrest(500, '55P03', 'lock not available')),
        isA<SyncTransient>(),
      );
      expect(
        await falha((503, 'Service Unavailable')),
        isA<SyncTransient>().having((f) => f.kind, 'kind', 'pg_503'),
      );
      expect(
        await falha(erroPostgrest(429, '429', 'too many')),
        isA<SyncTransient>(),
      );
    });

    test(
      'token vencido → sem sessão; outro erro do Postgres → inesperado',
      () async {
        expect(
          await falha(erroPostgrest(401, 'PGRST301', 'JWT expired')),
          isA<SyncUnauthorized>(),
        );
        expect(
          await falha(erroPostgrest(400, '22023', 'invalid_batch')),
          isA<SyncUnexpected>().having((f) => f.kind, 'kind', 'pg_22023'),
        );
      },
    );

    test('sem rede → repetir', () async {
      await logar();
      fb.offline = true;
      await expectLater(
        b.applyChanges(const []),
        throwsA(isA<SyncTransient>().having((f) => f.kind, 'kind', 'rede')),
      );
    });
  });

  test('syncFailureOf: socket e timeout são rede', () {
    expect(syncFailureOf(const SocketException('x')), isA<SyncTransient>());
    expect(syncFailureOf(TimeoutException('x')), isA<SyncTransient>());
    expect(syncFailureOf(StateError('x')), isA<SyncUnexpected>());
  });
}

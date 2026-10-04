// D-67: login por e-mail com código (OTP), Google e Apple (idToken) sobre o cliente REAL do Supabase,
// com o servidor de mentira — confere o que vai na rede e a tradução dos erros.
import 'dart:async';
import 'dart:io' show SocketException;

import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/features/account/data/auth_gateway.dart';
import 'package:app_leitura/features/account/data/native_sign_in.dart';
import 'package:app_leitura/features/account/data/secure_session_storage.dart';
import 'package:app_leitura/features/account/domain/account_failure.dart';
import 'package:app_leitura/features/account/domain/auth_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthApiException, AuthRetryableFetchException, SupabaseClient;

import 'support/fake_backend.dart';

final class _Google implements GoogleTokenSource {
  _Google([this.falha]);
  final AccountFailure? falha;
  int chamadas = 0;

  @override
  Future<GoogleTokens> obtain() async {
    chamadas++;
    if (falha != null) throw falha!;
    return const GoogleTokens(
      idToken: 'google-id-token',
      accessToken: 'google-access',
    );
  }
}

final class _Apple implements AppleTokenSource {
  @override
  bool get isNative => true;
  String? nonceCifrado;

  @override
  Future<String> identityToken({required String hashedNonce}) async {
    nonceCifrado = hashedNonce;
    return 'apple-id-token';
  }
}

void main() {
  late FakeBackend backend;
  late MemorySecureStore store;
  late SupabaseClient client;
  late _Google google;
  late _Apple apple;
  late SupabaseAuthGateway gw;

  void montar({Map<String, Resposta>? respostas}) {
    backend = FakeBackend(respostas: respostas);
    store = MemorySecureStore();
    client = backend.client(store: store);
    google = _Google();
    apple = _Apple();
    gw = SupabaseAuthGateway(
      client,
      google: google,
      apple: apple,
      redirect: AppEnv.defaultAuthRedirect,
    );
  }

  setUp(montar);
  tearDown(() => client.dispose());

  group('normalizeEmail', () {
    test('minúsculas e sem espaços nas pontas; formato inválido → null', () {
      expect(normalizeEmail('  Leitora@Exemplo.COM '), 'leitora@exemplo.com');
      for (final e in [
        '',
        'leitora',
        'leitora@',
        '@exemplo.com',
        'a b@c.com',
        'a@b',
      ]) {
        expect(normalizeEmail(e), isNull, reason: e);
      }
      expect(normalizeEmail('${'a' * 250}@b.co'), isNull, reason: '> 254');
    });
  });

  group('e-mail com código (OTP)', () {
    test('envia o código: POST /auth/v1/otp com o e-mail normalizado e create_user; PKCE no armazenamento seguro', () async {
      await gw.sendEmailCode(' Leitora@Exemplo.com ');
      expect(backend.caminhos, ['POST /auth/v1/otp']);
      final body = backend.pedidos.single.json! as Map;
      expect(body['email'], emailTeste);
      expect(body['create_user'], isTrue);
      expect(body['code_challenge'], isA<String>());
      expect(
        store.values.keys.where((k) => k.startsWith(SecurePkceStorage.prefix)),
        isNotEmpty,
      );
      expect(gw.current, const SignedOut());
    });

    test('e-mail inválido → InvalidEmail sem tocar a rede', () async {
      await expectLater(
        gw.sendEmailCode('leitora@'),
        throwsA(isA<InvalidEmail>()),
      );
      await expectLater(
        gw.verifyEmailCode('leitora', '123456'),
        throwsA(isA<InvalidEmail>()),
      );
      expect(backend.pedidos, isEmpty);
    });

    test('confere o código: POST /auth/v1/verify (type email) → sessão; watch emite SignedIn', () async {
      final eventos = <AuthStatus>[];
      final sub = gw.watch().listen(eventos.add);
      await gw.verifyEmailCode('LEITORA@exemplo.com', ' 123 456 ');
      expect(backend.caminhos, ['POST /auth/v1/verify']);
      final body = backend.pedidos.single.json! as Map;
      expect(body['email'], emailTeste);
      expect(body['token'], '123456');
      expect(body['type'], 'email');
      expect(gw.current, const SignedIn(userId: contaTeste, email: emailTeste));
      await pumpEventQueue();
      expect(
        eventos.last,
        const SignedIn(userId: contaTeste, email: emailTeste),
      );
      await sub.cancel();
    });

    test(
      'código fora do formato (6 dígitos) → InvalidCode sem tocar a rede',
      () async {
        for (final c in ['12345', '1234567', '12a456', '']) {
          await expectLater(
            gw.verifyEmailCode(emailTeste, c),
            throwsA(isA<InvalidCode>()),
            reason: c,
          );
        }
        expect(backend.pedidos, isEmpty);
      },
    );

    test(
      'erros do servidor viram falhas da conta (sem texto cru do servidor)',
      () async {
        Future<void> espera(
          Resposta r,
          Matcher m, {
          bool verificar = true,
        }) async {
          await client.dispose();
          montar(
            respostas: {'POST /auth/v1/otp': r, 'POST /auth/v1/verify': r},
          );
          final f = verificar
              ? gw.verifyEmailCode(emailTeste, '123456')
              : gw.sendEmailCode(emailTeste);
          await expectLater(f, throwsA(m));
        }

        await espera(
          erroAuth(403, 'otp_expired', 'Token has expired'),
          isA<InvalidCode>(),
        );
        await espera(
          erroAuth(429, 'over_email_send_rate_limit', 'rate limit'),
          isA<TooManyAttempts>(),
          verificar: false,
        );
        await espera(
          erroAuth(400, 'email_address_invalid', 'invalid'),
          isA<InvalidEmail>(),
          verificar: false,
        );
        await espera((
          500,
          {'msg': 'boom'},
        ), isA<ServerFailure>().having((f) => f.code, 'code', 'auth_500'));
        await espera(
          erroAuth(400, 'outro_codigo', 'x'),
          isA<ServerFailure>().having(
            (f) => f.code,
            'code',
            'auth_outro_codigo',
          ),
        );
      },
    );

    test('sem rede → OfflineFailure', () async {
      backend.offline = true;
      await expectLater(
        gw.sendEmailCode(emailTeste),
        throwsA(isA<OfflineFailure>()),
      );
    });
  });

  group('Google e Apple (idToken)', () {
    test(
      'Google: POST /auth/v1/token?grant_type=id_token com provider google',
      () async {
        await gw.signInWithGoogle();
        expect(google.chamadas, 1);
        final p = backend.pedidos.single;
        expect(p.toString(), 'POST /auth/v1/token?grant_type=id_token');
        final body = p.json! as Map;
        expect(body['provider'], 'google');
        expect(body['id_token'], 'google-id-token');
        expect(body['access_token'], 'google-access');
        expect(gw.current, isA<SignedIn>());
      },
    );

    test('Google sem credencial nesta versão → ProviderNotConfigured, sem rede e sem abrir o plugin', () async {
      final semGoogle = SupabaseAuthGateway(
        client,
        google: GoogleSignInTokenSource(const AppEnv()),
        apple: apple,
        redirect: AppEnv.defaultAuthRedirect,
      );
      await expectLater(
        semGoogle.signInWithGoogle(),
        throwsA(
          isA<ProviderNotConfigured>().having(
            (f) => f.method,
            'method',
            SignInMethod.google,
          ),
        ),
      );
      expect(backend.pedidos, isEmpty);
    });

    test(
      'pessoa fechou o seletor do Google → SignInCancelled, sem rede',
      () async {
        final cancelado = SupabaseAuthGateway(
          client,
          google: _Google(const SignInCancelled()),
          apple: apple,
          redirect: AppEnv.defaultAuthRedirect,
        );
        await expectLater(
          cancelado.signInWithGoogle(),
          throwsA(isA<SignInCancelled>()),
        );
        expect(backend.pedidos, isEmpty);
      },
    );

    test(
      'Apple nativo (iOS): nonce cifrado para a Apple, cru para o Supabase',
      () async {
        await gw.signInWithApple();
        final body = backend.pedidos.single.json! as Map;
        expect(body['provider'], 'apple');
        expect(body['id_token'], 'apple-id-token');
        final cru = body['nonce']! as String;
        expect(cru, isNotEmpty);
        expect(apple.nonceCifrado, sha256Hex(cru));
        expect(apple.nonceCifrado, isNot(cru));
      },
    );
  });

  group('sair', () {
    test('POST /auth/v1/logout e a sessão some deste aparelho', () async {
      await gw.verifyEmailCode(emailTeste, '123456');
      await gw.signOut();
      expect(backend.caminhos.last, 'POST /auth/v1/logout');
      expect(gw.current, const SignedOut());
    });

    test('sem rede: a sessão local sai mesmo assim (o servidor vence o token sozinho)', () async {
      await gw.verifyEmailCode(emailTeste, '123456');
      backend.offline = true;
      await expectLater(gw.signOut(), throwsA(isA<OfflineFailure>()));
      expect(gw.current, const SignedOut());
    });
  });

  group('accountFailureOf', () {
    test('rede e tempo esgotado → OfflineFailure; desconhecido → ServerFailure com o tipo', () {
      expect(
        accountFailureOf(const SocketException('x')),
        isA<OfflineFailure>(),
      );
      expect(accountFailureOf(TimeoutException('x')), isA<OfflineFailure>());
      expect(accountFailureOf(ClientException('x')), isA<OfflineFailure>());
      expect(
        accountFailureOf(AuthRetryableFetchException()),
        isA<OfflineFailure>(),
      );
      expect(
        accountFailureOf(const AuthApiException('x', statusCode: '429')),
        isA<TooManyAttempts>(),
      );
      expect(
        accountFailureOf(const AuthApiException('x', statusCode: '422')),
        isA<InvalidEmail>(),
      );
      expect(
        accountFailureOf(
          const AuthApiException('x', code: 'invalid_credentials'),
        ),
        isA<InvalidCode>(),
      );
      expect(accountFailureOf(const InvalidCode()), isA<InvalidCode>());
      expect(
        accountFailureOf(StateError('x')),
        isA<ServerFailure>().having((f) => f.code, 'code', 'StateError'),
      );
    });
  });
}

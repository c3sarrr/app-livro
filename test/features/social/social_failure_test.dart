// G21.3 — as falhas do social (docs/progresso/G21.md §3): cada código que o servidor levanta vira a falha que a tela
// precisa, e o `socialCall` cobre a sessão, a rede, o tempo e o formato.
import 'dart:async';

import 'package:app_leitura/features/social/data/social_call.dart';
import 'package:app_leitura/features/social/domain/social_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthApiException, AuthRetryableFetchException, PostgrestException;

import 'support/social_backend.dart';

void main() {
  group('socialFailureOf: o código do banco vira a falha', () {
    final casos = <(String?, String, Type)>[
      ('P0001', 'terms_required', SocialTermsRequired),
      ('22023', 'stale_terms', SocialTermsRequired),
      ('P0001', 'free_club_limit', SocialFreeClubLimit),
      ('P0001', 'invalid_invite', SocialInvalidInvite),
      ('22023', 'invalid_invite', SocialInvalidInvite),
      ('P0001', 'blocked', SocialBlocked),
      ('P0001', 'age_required', SocialNeedsAge),
      ('P0001', 'content_blocked', SocialContentBlocked),
      ('42501', 'not_member', SocialNotAllowed),
      ('42501', 'not_allowed', SocialNotAllowed),
      ('P0001', 'content_moderated', SocialNotAllowed),
      ('42501', 'permission denied for table club_posts', SocialNotAllowed),
      (
        '42501',
        'new row violates row-level security policy for table "follows"',
        SocialNotAllowed,
      ),
      ('P0001', 'post_not_found', SocialNotFound),
      ('P0001', 'target_not_found', SocialNotFound),
      ('P0001', 'club_not_public', SocialNotFound),
      ('P0002', 'not_found', SocialNotFound),
      (
        'PGRST116',
        'JSON object requested, multiple (or no) rows returned',
        SocialNotFound,
      ),
      ('28000', 'unauthenticated', SocialNeedsAccount),
      ('PGRST301', 'JWT expired', SocialNeedsAccount),
      ('PGRST303', 'JWT expired', SocialNeedsAccount),
    ];
    for (final (code, message, tipo) in casos) {
      test('$code $message → $tipo', () {
        expect(socialFailureOf(code, message).runtimeType, tipo);
      });
    }

    test('o resto: o código curto do servidor, ou o do Postgres', () {
      expect(
        socialFailureOf('22023', 'invalid_weeks'),
        isA<SocialUnexpected>().having((f) => f.code, 'code', 'invalid_weeks'),
      );
      expect(
        socialFailureOf(
          '23505',
          'duplicate key value violates unique constraint "follows_pkey"',
        ).code,
        'pg_23505',
      );
      expect(socialFailureOf(null, 'Algo deu errado').code, 'pg_desconhecido');
    });

    test('cada falha tem um código curto e diferente', () {
      const todas = <SocialFailure>[
        SocialOffline(),
        SocialNeedsAccount(),
        SocialNeedsAge(),
        SocialTermsRequired(),
        SocialFreeClubLimit(),
        SocialInvalidInvite(),
        SocialBlocked(),
        SocialNotAllowed(),
        SocialNotFound(),
        SocialContentBlocked(),
      ];
      expect(todas.map((f) => f.code).toSet(), hasLength(todas.length));
      expect(const SocialOffline().toString(), 'SocialFailure(rede)');
    });
  });

  group('socialCall', () {
    test('sem conta: SocialNeedsAccount e nada vai para a rede', () async {
      final (b, c) = await servidorSocial(entrar: false);
      addTearDown(c.dispose);
      var rodou = false;
      await expectLater(
        socialCall(c, () async => rodou = true),
        throwsA(isA<SocialNeedsAccount>()),
      );
      expect(rodou, isFalse);
      expect(() => socialUserId(c), throwsA(isA<SocialNeedsAccount>()));
      expect(b.pedidos, isEmpty);
    });

    test('com conta: o id da sessão; o resultado volta como veio', () async {
      final (_, c) = await servidorSocial();
      addTearDown(c.dispose);
      expect(socialUserId(c), contaTeste);
      expect(await socialCall(c, () async => 42), 42);
    });

    test('sem rede: SocialOffline', () async {
      final (b, c) = await servidorSocial();
      addTearDown(c.dispose);
      b.offline = true;
      await expectLater(
        socialCall(c, () => c.rpc<Object?>('my_terms')),
        throwsA(isA<SocialOffline>()),
      );
    });

    test('o tempo acaba: SocialOffline', () async {
      final (_, c) = await servidorSocial();
      addTearDown(c.dispose);
      await expectLater(
        socialCall(
          c,
          () => Completer<void>().future,
          timeout: const Duration(milliseconds: 10),
        ),
        throwsA(isA<SocialOffline>()),
      );
    });

    test('erro do PostgREST: a falha do código', () async {
      final (_, c) = await servidorSocial(
        respostas: {
          'POST /rest/v1/rpc/accept_terms': erroPostgrest(
            400,
            '22023',
            'stale_terms',
          ),
        },
      );
      addTearDown(c.dispose);
      await expectLater(
        socialCall(
          c,
          () => c.rpc<Object?>('accept_terms', params: {'p_version': 'velha'}),
        ),
        throwsA(isA<SocialTermsRequired>()),
      );
      await expectLater(
        socialCall(
          c,
          () =>
              throw const PostgrestException(message: 'blocked', code: 'P0001'),
        ),
        throwsA(isA<SocialBlocked>()),
      );
    });

    test('a renovação do login sem rede: SocialOffline; o login recusado: SocialNeedsAccount', () async {
      final (_, c) = await servidorSocial();
      addTearDown(c.dispose);
      await expectLater(
        socialCall(c, () => throw AuthRetryableFetchException()),
        throwsA(isA<SocialOffline>()),
      );
      await expectLater(
        socialCall(
          c,
          () => throw const AuthApiException(
            'Invalid Refresh Token',
            statusCode: '400',
          ),
        ),
        throwsA(isA<SocialNeedsAccount>()),
      );
    });

    test(
      'um formato que o app não entende: SocialUnexpected("resposta")',
      () async {
        final (_, c) = await servidorSocial();
        addTearDown(c.dispose);
        await expectLater(
          socialCall(c, () async => int.parse('não é número')),
          throwsA(
            isA<SocialUnexpected>().having((f) => f.code, 'code', 'resposta'),
          ),
        );
        await expectLater(
          socialCall(c, () => throw const SocialBlocked()),
          throwsA(isA<SocialBlocked>()),
        );
      },
    );
  });
}

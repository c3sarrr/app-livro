// G21.3 — o perfil pelo plano (prompt mestre §6 G21: "Grátis preview vs Pro full profile"): o Grátis pede só a
// prévia, que não traz o texto das resenhas; o Pro lê o perfil e os posts pelas tabelas. E o meu perfil: mudar e
// publicar os 4 números.
import 'dart:convert';

import 'package:app_leitura/features/social/data/profile_repository.dart';
import 'package:app_leitura/features/social/domain/social_failure.dart';
import 'package:app_leitura/features/social/domain/social_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/social_backend.dart';

const _capitu = '0199a7c4-2f00-7a10-8b20-0000000000c1';

/// `profile_preview` como o servidor devolve (G04): o tamanho das resenhas, sem o texto.
final Map<String, Object?> _previa = {
  'id': _capitu,
  'handle': 'capitu',
  'display_name': 'Capitu',
  'avatar_path': null,
  'visibility': 'public',
  'stats': {
    'books_read_total': 42,
    'books_read_year': 9,
    'reading_now': 2,
    'streak_days': 15,
    'followers_count': 120,
    'following_count': 80,
    'posts_count': 7,
    'updated_at': '2026-10-08T12:00:00Z',
  },
  'recent_posts': [
    {
      'id': 'p1',
      'kind': 'review',
      'chars': 812,
      'created_at': '2026-10-07T21:00:00Z',
    },
    {
      'id': 'p2',
      'kind': 'quote',
      'chars': 64,
      'created_at': '2026-10-01T09:30:00-03:00',
    },
  ],
};

const String _resenha =
    'Olhos de ressaca: a narração de Bentinho não merece confiança.';

void main() {
  test(
    'Grátis: só a prévia — os números e o tamanho das resenhas, nenhum texto',
    () async {
      final (b, c) = await servidorSocial(
        respostas: {'POST /rest/v1/rpc/profile_preview': (200, _previa)},
      );
      addTearDown(c.dispose);
      final p = await SupabaseProfileRepository(c)
          .byHandle(' Capitu ', pro: false);

      expect(b.caminhos, ['POST /rest/v1/rpc/profile_preview']);
      expect(b.pedidos.single.json, {'p_handle': 'capitu'});
      expect(p, isA<ProfilePreview>());
      final v = p! as ProfilePreview;
      expect(
        (v.id, v.handle, v.displayName, v.isPrivate),
        (_capitu, 'capitu', 'Capitu', false),
      );
      expect(
        v.numbers,
        const ProfileNumbers(
          booksReadTotal: 42,
          booksReadYear: 9,
          readingNow: 2,
          streakDays: 15,
        ),
      );
      expect(v.recentPosts.map((r) => (r.kind, r.chars)), [
        ('review', 812),
        ('quote', 64),
      ]);
      expect(v.recentPosts.last.createdAt, DateTime.utc(2026, 10, 1, 12, 30));
      // o que chegou ao aparelho não tem texto de resenha
      expect(jsonEncode(_previa), isNot(contains('body')));
    },
  );

  test('Grátis: perfil que não existe (ou bloqueio) → null', () async {
    final (_, c) = await servidorSocial(
      respostas: {'POST /rest/v1/rpc/profile_preview': (200, null)},
    );
    addTearDown(c.dispose);
    expect(
      await SupabaseProfileRepository(c).byHandle('ninguem', pro: false),
      isNull,
    );
  });

  test(
    'Pro: o perfil com os números e os posts com o texto, pelas tabelas',
    () async {
      final (b, c) = await servidorSocial(
        respostas: {
          'GET /rest/v1/profiles': (
            200,
            [
              {
                'id': _capitu,
                'handle': 'capitu',
                'display_name': 'Capitu',
                'avatar_path': 'avatars/capitu.webp',
                'bio': 'Leio de olhos de ressaca.',
                'visibility': 'private',
                'profile_stats': {
                  'books_read_total': 42,
                  'books_read_year': 9,
                  'reading_now': 2,
                  'streak_days': 15,
                },
              },
            ],
          ),
          'GET /rest/v1/posts': (
            200,
            [
              {
                'id': 'p1',
                'kind': 'review',
                'quote_text': null,
                'body': _resenha,
                'rating': 4,
                'created_at': '2026-10-07T21:00:00Z',
              },
              {
                'id': 'p2',
                'kind': 'quote',
                'quote_text': 'Capitu, apesar daqueles olhos…',
                'body': null,
                'rating': null,
                'created_at': '2026-10-01T12:30:00Z',
              },
            ],
          ),
        },
      );
      addTearDown(c.dispose);
      final p = await SupabaseProfileRepository(c)
          .byHandle('capitu', pro: true);

      expect(b.caminhos, ['GET /rest/v1/profiles', 'GET /rest/v1/posts']);
      final perfil = b.pedidos.first;
      expect(filtro(perfil, 'handle'), 'eq.capitu');
      expect(filtro(perfil, 'select'), contains('bio'));
      expect(filtro(perfil, 'select'), contains('profile_stats('));
      final posts = b.pedidos.last;
      expect(filtro(posts, 'author_id'), 'eq.$_capitu');
      expect(filtro(posts, 'deleted_at'), 'is.null');
      expect(filtro(posts, 'order'), 'created_at.desc.nullslast');
      expect(filtro(posts, 'limit'), '${SupabaseProfileRepository.postsShown}');

      final v = p! as ProfileFull;
      expect(
        (v.isPrivate, v.bio, v.avatarPath),
        (true, 'Leio de olhos de ressaca.', 'avatars/capitu.webp'),
      );
      expect(v.numbers.streakDays, 15);
      expect(v.posts.first.body, _resenha);
      expect(
        (v.posts.first.rating, v.posts.last.quote),
        (4, 'Capitu, apesar daqueles olhos…'),
      );
    },
  );

  test('Pro: perfil que não existe → null sem pedir os posts; perfil fechado sem pedido: sem posts', () async {
    final (b, c) = await servidorSocial(
      respostas: {'GET /rest/v1/profiles': (200, <Object?>[])},
    );
    addTearDown(c.dispose);
    expect(
      await SupabaseProfileRepository(c).byHandle('ninguem', pro: true),
      isNull,
    );
    expect(b.caminhos, ['GET /rest/v1/profiles']);

    final (_, c2) = await servidorSocial(
      respostas: {
        'GET /rest/v1/profiles': (
          200,
          [
            {
              'id': _capitu,
              'handle': 'capitu',
              'display_name': 'Capitu',
              'visibility': 'private',
              'profile_stats': null,
            },
          ],
        ),
        'GET /rest/v1/posts': (200, <Object?>[]),
      },
    );
    addTearDown(c2.dispose);
    final v = await SupabaseProfileRepository(
      c2,
    ).byHandle('capitu', pro: true) as ProfileFull?;
    expect(
      (v!.isPrivate, v.posts.length, v.numbers.booksReadTotal),
      (true, 0, 0),
    );
  });

  test(
    'o meu perfil: só os campos dados vão no PATCH; nada a mudar, nada vai',
    () async {
      final (b, c) = await servidorSocial();
      addTearDown(c.dispose);
      final r = SupabaseProfileRepository(c);
      await r.updateMine(displayName: '  Marina ', isPrivate: true);
      expect(b.caminhos, ['PATCH /rest/v1/profiles']);
      expect(filtro(b.pedidos.single, 'id'), 'eq.$contaTeste');
      expect(b.pedidos.single.json, {
        'display_name': 'Marina',
        'visibility': 'private',
      });

      b.pedidos.clear();
      await r.updateMine(bio: 'Clássicos brasileiros.', isPrivate: false);
      expect(b.pedidos.single.json, {
        'bio': 'Clássicos brasileiros.',
        'visibility': 'public',
      });

      b.pedidos.clear();
      await r.updateMine();
      expect(b.pedidos, isEmpty);
    },
  );

  test('os 4 números (R10): só os agregados vão', () async {
    final (b, c) = await servidorSocial(
      respostas: {'POST /rest/v1/rpc/publish_my_stats': (200, true)},
    );
    addTearDown(c.dispose);
    expect(
      await SupabaseProfileRepository(c).publishStats(
        const ProfileNumbers(
          booksReadTotal: 12,
          booksReadYear: 3,
          readingNow: 1,
          streakDays: 6,
        ),
      ),
      isTrue,
      reason: 'o servidor gravou',
    );
    expect(b.caminhos, ['POST /rest/v1/rpc/publish_my_stats']);
    expect(b.pedidos.single.json, {
      'p_books_read_total': 12,
      'p_books_read_year': 3,
      'p_reading_now': 1,
      'p_streak_days': 6,
    });
  });

  test('sem conta, nada vai; sem rede, SocialOffline', () async {
    final (b, c) = await servidorSocial(entrar: false);
    addTearDown(c.dispose);
    final r = SupabaseProfileRepository(c);
    await expectLater(
      r.byHandle('capitu', pro: false),
      throwsA(isA<SocialNeedsAccount>()),
    );
    await expectLater(
      r.byHandle('capitu', pro: true),
      throwsA(isA<SocialNeedsAccount>()),
    );
    await expectLater(
      r.updateMine(bio: 'x'),
      throwsA(isA<SocialNeedsAccount>()),
    );
    await expectLater(
      r.publishStats(
        const ProfileNumbers(
          booksReadTotal: 0,
          booksReadYear: 0,
          readingNow: 0,
          streakDays: 0,
        ),
      ),
      throwsA(isA<SocialNeedsAccount>()),
    );
    expect(b.pedidos, isEmpty);

    final (b2, c2) = await servidorSocial();
    addTearDown(c2.dispose);
    b2.offline = true;
    await expectLater(
      SupabaseProfileRepository(c2).byHandle('capitu', pro: true),
      throwsA(isA<SocialOffline>()),
    );
    expect(
      b2.pedidos,
      hasLength(1),
      reason: 'sem as novas tentativas do PostgREST: uma ida e a pílula',
    );
  });
}

// G21.3 — seguir, bloquear, posts, comentários, curtidas, denúncias, termos e o sininho (docs/progresso/G21.md §3)
// sobre o cliente REAL do Supabase com o servidor de mentira: o que vai na rede, de quem, e o que volta.
import 'package:app_leitura/features/social/data/community_repository.dart';
import 'package:app_leitura/features/social/data/follow_repository.dart';
import 'package:app_leitura/features/social/data/post_repository.dart';
import 'package:app_leitura/features/social/domain/social_failure.dart';
import 'package:app_leitura/features/social/domain/social_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/social_backend.dart';

const _bento = '0199a7c4-2f00-7a10-8b20-0000000000b1';
const _escobar = '0199a7c4-2f00-7a10-8b20-0000000000e5';
final _agora = DateTime.utc(2026, 10, 9, 15, 30);

Map<String, Object?> _pessoa(String id, String handle, String nome) => {
  'id': id,
  'handle': handle,
  'display_name': nome,
  'avatar_path': null,
};

void main() {
  group('seguir', () {
    test('perfil fechado: o servidor devolve o pedido (o app não escolhe o status)', () async {
      final (b, c) = await servidorSocial(
        respostas: {
          'POST /rest/v1/follows': (201, {'status': 'pending'}),
        },
      );
      addTearDown(c.dispose);
      expect(
        await SupabaseFollowRepository(c).follow(_bento),
        FollowState.pending,
      );
      expect(b.pedidos.single.json, {
        'follower_id': contaTeste,
        'followee_id': _bento,
      });
      expect(filtro(b.pedidos.single, 'select'), 'status');
    });

    test('perfil aberto: seguidora na hora; bloqueio: SocialBlocked', () async {
      final (_, c) = await servidorSocial(
        respostas: {
          'POST /rest/v1/follows': (201, {'status': 'accepted'}),
        },
      );
      addTearDown(c.dispose);
      expect(
        await SupabaseFollowRepository(c).follow(_bento),
        FollowState.accepted,
      );

      final (_, c2) = await servidorSocial(
        respostas: {
          'POST /rest/v1/follows': erroPostgrest(400, 'P0001', 'blocked'),
        },
      );
      addTearDown(c2.dispose);
      await expectLater(
        SupabaseFollowRepository(c2).follow(_bento),
        throwsA(isA<SocialBlocked>()),
      );
    });

    test('deixar de seguir, aceitar e recusar: só as linhas de quem está na sessão', () async {
      final (b, c) = await servidorSocial(
        respostas: {
          'DELETE /rest/v1/follows': (204, null),
          'PATCH /rest/v1/follows': (204, null),
        },
      );
      addTearDown(c.dispose);
      final r = SupabaseFollowRepository(c);
      await r.unfollow(_bento);
      await r.accept(_escobar);
      await r.decline(_bento);
      expect(b.caminhos, [
        'DELETE /rest/v1/follows',
        'PATCH /rest/v1/follows',
        'DELETE /rest/v1/follows',
      ]);
      final [deixar, aceitar, recusar] = b.pedidos;
      expect(
        (filtro(deixar, 'follower_id'), filtro(deixar, 'followee_id')),
        ('eq.$contaTeste', 'eq.$_bento'),
      );
      expect(
        (filtro(aceitar, 'follower_id'), filtro(aceitar, 'followee_id')),
        ('eq.$_escobar', 'eq.$contaTeste'),
      );
      expect(aceitar.json, {'status': 'accepted'});
      expect(
        (filtro(recusar, 'follower_id'), filtro(recusar, 'followee_id')),
        ('eq.$_bento', 'eq.$contaTeste'),
      );
    });

    test('os pedidos, os seguidores e quem segue: o lado certo da relação; quem bloqueou some', () async {
      final (b, c) = await servidorSocial(
        respostas: {
          'GET /rest/v1/follows': (
            200,
            [
              {'follower': _pessoa(_bento, 'bentinho', 'Bento')},
              {'follower': null}, // bloqueio: a RLS de profiles esconde
            ],
          ),
        },
      );
      addTearDown(c.dispose);
      final r = SupabaseFollowRepository(c);
      final pedidos = await r.requests();
      expect(pedidos.map((p) => (p.id, p.handle, p.displayName)), [
        (_bento, 'bentinho', 'Bento'),
      ]);
      final p = b.pedidos.single;
      expect(
        filtro(p, 'select'),
        'follower:profiles!follows_follower_id_fkey(id,handle,display_name,avatar_path)',
      );
      expect(
        (filtro(p, 'followee_id'), filtro(p, 'status')),
        ('eq.$contaTeste', 'eq.pending'),
      );
      expect(
        (filtro(p, 'order'), filtro(p, 'limit')),
        ('created_at.desc.nullslast', '$peopleShown'),
      );

      b.pedidos.clear();
      await r.followers(_escobar);
      expect(
        (
          filtro(b.pedidos.single, 'followee_id'),
          filtro(b.pedidos.single, 'status'),
        ),
        ('eq.$_escobar', 'eq.accepted'),
      );

      b.respostas['GET /rest/v1/follows'] = (
        200,
        [
          {'followee': _pessoa(_escobar, 'escobar', 'Escobar')},
        ],
      );
      b.pedidos.clear();
      final seguindo = await r.following(_bento);
      expect(seguindo.single.handle, 'escobar');
      expect(
        filtro(b.pedidos.single, 'select'),
        startsWith('followee:profiles!follows_followee_id_fkey('),
      );
      expect(filtro(b.pedidos.single, 'follower_id'), 'eq.$_bento');
    });
  });

  test('bloquear, desbloquear e a lista de quem eu bloqueei', () async {
    final (b, c) = await servidorSocial(
      respostas: {
        'POST /rest/v1/user_blocks': (201, null),
        'DELETE /rest/v1/user_blocks': (204, null),
        'GET /rest/v1/user_blocks': (
          200,
          [
            {'blocked_id': _escobar},
          ],
        ),
      },
    );
    addTearDown(c.dispose);
    final r = SupabaseBlockRepository(c);
    await r.block(_escobar);
    expect(b.pedidos.single.json, {
      'blocker_id': contaTeste,
      'blocked_id': _escobar,
    });
    b.pedidos.clear();
    await r.unblock(_escobar);
    expect(
      (
        filtro(b.pedidos.single, 'blocker_id'),
        filtro(b.pedidos.single, 'blocked_id'),
      ),
      ('eq.$contaTeste', 'eq.$_escobar'),
    );
    b.pedidos.clear();
    expect(await r.blocked(), {_escobar});
    expect(filtro(b.pedidos.single, 'blocker_id'), 'eq.$contaTeste');
  });

  group('posts, comentários e curtidas', () {
    test('publicar uma resenha: autora = a sessão; o id volta', () async {
      final (b, c) = await servidorSocial(
        respostas: {
          'POST /rest/v1/posts': (201, {'id': 'post-1'}),
        },
      );
      addTearDown(c.dispose);
      final id = await SupabasePostRepository(c).create((
        kind: PostKind.review,
        editionId: 'ed-1',
        workId: null,
        rating: 5,
        quote: null,
        body: 'Releitura obrigatória.',
      ));
      expect(id, 'post-1');
      expect(b.pedidos.single.json, {
        'author_id': contaTeste,
        'kind': 'review',
        'edition_id': 'ed-1',
        'work_id': null,
        'rating': 5,
        'quote_text': null,
        'body': 'Releitura obrigatória.',
      });
    });

    test('apagar é marcar a data, só no que é meu', () async {
      final (b, c) = await servidorSocial(
        respostas: {
          'PATCH /rest/v1/posts': (204, null),
          'PATCH /rest/v1/post_comments': (204, null),
        },
      );
      addTearDown(c.dispose);
      final r = SupabasePostRepository(c, now: () => _agora);
      await r.delete('post-1');
      await r.deleteComment('com-1');
      for (final (p, id) in [
        (b.pedidos[0], 'post-1'),
        (b.pedidos[1], 'com-1'),
      ]) {
        expect(p.json, {'deleted_at': '2026-10-09T15:30:00.000Z'});
        expect(
          (filtro(p, 'id'), filtro(p, 'author_id')),
          ('eq.$id', 'eq.$contaTeste'),
        );
      }
    });

    test('comentar, ler os comentários (os mais antigos primeiro), curtir e descurtir', () async {
      final (b, c) = await servidorSocial(
        respostas: {
          'POST /rest/v1/post_comments': (201, {'id': 'com-9'}),
          'GET /rest/v1/post_comments': (
            200,
            [
              {
                'id': 'com-1',
                'author_id': _bento,
                'body': 'Concordo.',
                'created_at': '2026-10-08T10:00:00Z',
              },
            ],
          ),
          'POST /rest/v1/post_likes': (201, null),
          'DELETE /rest/v1/post_likes': (204, null),
        },
      );
      addTearDown(c.dispose);
      final r = SupabasePostRepository(c);
      expect(await r.comment('post-1', 'Que final!'), 'com-9');
      expect(b.pedidos.last.json, {
        'post_id': 'post-1',
        'author_id': contaTeste,
        'body': 'Que final!',
      });

      final lista = await r.comments('post-1', limit: 10);
      expect(lista.single, (
        id: 'com-1',
        authorId: _bento,
        body: 'Concordo.',
        createdAt: DateTime.utc(2026, 10, 8, 10),
      ));
      final get = b.pedidos.last;
      expect(
        (filtro(get, 'post_id'), filtro(get, 'deleted_at')),
        ('eq.post-1', 'is.null'),
      );
      expect(
        (filtro(get, 'order'), filtro(get, 'limit')),
        ('created_at.asc.nullslast', '10'),
      );

      await r.like('post-1');
      expect(b.pedidos.last.json, {'post_id': 'post-1', 'user_id': contaTeste});
      await r.unlike('post-1');
      expect(
        (filtro(b.pedidos.last, 'post_id'), filtro(b.pedidos.last, 'user_id')),
        ('eq.post-1', 'eq.$contaTeste'),
      );
    });

    test(
      'termos não aceitos: SocialTermsRequired (a folha "Antes de publicar")',
      () async {
        final (_, c) = await servidorSocial(
          respostas: {
            'POST /rest/v1/posts': erroPostgrest(
              400,
              'P0001',
              'terms_required',
            ),
          },
        );
        addTearDown(c.dispose);
        await expectLater(
          SupabasePostRepository(c).create((
            kind: PostKind.quote,
            editionId: null,
            workId: 'w',
            rating: null,
            quote: 'Trecho',
            body: null,
          )),
          throwsA(isA<SocialTermsRequired>()),
        );
      },
    );
  });

  test(
    'denunciar cada tipo: quem denuncia é a sessão; os detalhes só se escritos',
    () async {
      final (b, c) = await servidorSocial(
        respostas: {'POST /rest/v1/content_reports': (201, null)},
      );
      addTearDown(c.dispose);
      final r = SupabaseReportRepository(c);
      for (final t in ReportTarget.values) {
        await r.report(t, 'alvo-${t.code}', ReportReason.spoiler);
      }
      await r.report(
        ReportTarget.clubPostReply,
        'resp-1',
        ReportReason.harassment,
        details: 'Ofensa na resposta.',
      );
      expect(b.pedidos.map((p) => (p.json! as Map)['target_type']), [
        'profile',
        'post',
        'post_comment',
        'club',
        'club_post',
        'club_post_reply',
        'club_post_reply',
      ]);
      expect(b.pedidos.first.json, {
        'reporter_id': contaTeste,
        'target_type': 'profile',
        'target_id': 'alvo-profile',
        'reason': 'spoiler',
      });
      expect((b.pedidos.last.json! as Map)['details'], 'Ofensa na resposta.');
      expect(
        filtro(b.pedidos.first, 'select'),
        isNull,
        reason: 'quem denuncia não lê a tabela das denúncias',
      );
      expect(ReportReason.values.map((r) => r.code), [
        'spam',
        'harassment',
        'hate',
        'sexual',
        'spoiler',
        'other',
      ]);
    },
  );

  test('termos: a versão e se aceitei; aceitar leva a versão lida', () async {
    final (b, c) = await servidorSocial(
      respostas: {
        'POST /rest/v1/rpc/my_terms': (
          200,
          {'version': '2026-10-provisorio', 'accepted': false},
        ),
        'POST /rest/v1/rpc/accept_terms': (204, null),
      },
    );
    addTearDown(c.dispose);
    final r = SupabaseTermsRepository(c);
    final t = await r.mine();
    expect((t.version, t.accepted), ('2026-10-provisorio', false));
    await r.accept(t.version);
    expect(b.caminhos, [
      'POST /rest/v1/rpc/my_terms',
      'POST /rest/v1/rpc/accept_terms',
    ]);
    expect(b.pedidos.last.json, {'p_version': '2026-10-provisorio'});
  });

  test(
    'o sininho: uma ida HEAD com a contagem, sem as linhas; marcar lidas',
    () async {
      final (b, c) = await servidorSocial(
        respostas: {
          'HEAD /rest/v1/notifications': (200, null),
          'PATCH /rest/v1/notifications': (204, null),
        },
        cabecalhos: {
          'HEAD /rest/v1/notifications': {'content-range': '*/3'},
        },
      );
      addTearDown(c.dispose);
      final r = SupabaseNotificationsRepository(c, now: () => _agora);
      expect(await r.unreadCount(), 3);
      final h = b.pedidos.single;
      expect(h.method, 'HEAD');
      expect(
        (filtro(h, 'user_id'), filtro(h, 'read_at')),
        ('eq.$contaTeste', 'is.null'),
      );
      expect(h.headers['prefer'], contains('count=exact'));

      b.pedidos.clear();
      await r.markAllRead();
      expect(b.pedidos.single.json, {'read_at': '2026-10-09T15:30:00.000Z'});
      expect(
        (
          filtro(b.pedidos.single, 'user_id'),
          filtro(b.pedidos.single, 'read_at'),
        ),
        ('eq.$contaTeste', 'is.null'),
      );
    },
  );

  test('sem conta, nenhum repositório vai à rede', () async {
    final (b, c) = await servidorSocial(entrar: false);
    addTearDown(c.dispose);
    final follow = SupabaseFollowRepository(c);
    final block = SupabaseBlockRepository(c);
    final posts = SupabasePostRepository(c);
    // cada chamada só começa na sua vez (uma falha sem ninguém esperando seria um erro solto)
    final chamadas = <Future<Object?> Function()>[
      () => follow.follow(_bento),
      () => follow.unfollow(_bento),
      () => follow.requests(),
      () => follow.accept(_bento),
      () => follow.decline(_bento),
      () => follow.followers(_bento),
      () => follow.following(_bento),
      () => block.block(_bento),
      () => block.unblock(_bento),
      () => block.blocked(),
      () => posts.create((
        kind: PostKind.list,
        editionId: null,
        workId: null,
        rating: null,
        quote: null,
        body: 'Lista',
      )),
      () => posts.delete('p'),
      () => posts.comment('p', 'x'),
      () => posts.deleteComment('c'),
      () => posts.comments('p'),
      () => posts.like('p'),
      () => posts.unlike('p'),
      () =>
          SupabaseReportRepository(c)
              .report(ReportTarget.post, 'p', ReportReason.spam),
      () => SupabaseTermsRepository(c).mine(),
      () => SupabaseTermsRepository(c).accept('v'),
      () => SupabaseNotificationsRepository(c).unreadCount(),
      () => SupabaseNotificationsRepository(c).markAllRead(),
    ];
    for (final f in chamadas) {
      await expectLater(f(), throwsA(isA<SocialNeedsAccount>()));
    }
    expect(b.pedidos, isEmpty);
  });
}

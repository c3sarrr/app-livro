// G21.3 — os clubes pelo Supabase (docs/progresso/G21.md §1 e §3) sobre o cliente REAL com o servidor de mentira:
// o corpo de cada RPC, os resumos do mundo das pranchas (o JSON capturado do banco local) e as falhas.
import 'dart:convert';

import 'package:app_leitura/features/clubs/data/clubs_repository.dart';
import 'package:app_leitura/features/clubs/domain/club_models.dart';
import 'package:app_leitura/features/social/domain/social_failure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../social/support/social_backend.dart';
import 'club_models_test.dart' show fixture;

const _clube = '00000000-0000-7000-8000-00000c200001';
const _encontro = '00000000-0000-7000-8000-00000c400002';

String _rpc(String fn) => 'POST /rest/v1/rpc/$fn';

Future<(FakeBackend, SupabaseClubsRepository)> _repo([
  Map<String, Resposta>? respostas,
]) async {
  final (b, c) = await servidorSocial(respostas: respostas);
  addTearDown(c.dispose);
  return (b, SupabaseClubsRepository(c));
}

void main() {
  group('os resumos: uma ida por tela, com os números do mundo', () {
    test('my_clubs: os cartões e o JSON como veio (para o cache)', () async {
      final (b, r) = await _repo({
        _rpc('my_clubs'): (200, fixture('my_clubs')),
      });
      final m = await r.myClubs();
      expect(b.caminhos, [_rpc('my_clubs')]);
      expect(m.cards.single.name, 'Leitoras de Capitu');
      expect(jsonDecode(m.json), fixture('my_clubs'));
    });

    test('club_overview, meeting_overview e club_members_overview', () async {
      final (b, r) = await _repo({
        _rpc('club_overview'): (200, fixture('club_overview')),
        _rpc('meeting_overview'): (200, fixture('meeting_overview')),
        _rpc('club_members_overview'): (200, fixture('club_members_overview')),
      });
      expect((await r.overview(_clube)).club.membersCount, 11);
      expect((await r.meeting(_encontro)).mine, Rsvp.going);
      expect((await r.members(_clube)).members, hasLength(11));
      expect(b.pedidos.map((p) => p.json), [
        {'p_club': _clube},
        {'p_meeting': _encontro},
        {'p_club': _clube},
      ]);
    });

    test('week_thread: por curtidas, a página seguinte pelo cursor; as recentes; as respostas de uma', () async {
      final (b, r) = await _repo({
        _rpc('week_thread'): (200, fixture('week_thread')),
      });
      final t = await r.weekThread(_clube, 2, limit: 3);
      expect(b.pedidos.last.json, {
        'p_club': _clube,
        'p_week': 2,
        'p_order': 'likes',
        'p_parent': null,
        'p_cursor': null,
        'p_limit': 3,
      });
      await r.weekThread(_clube, 2, cursor: t.nextCursor, limit: 3);
      expect((b.pedidos.last.json! as Map)['p_cursor'], t.nextCursor);
      await r.weekThread(_clube, 2, recent: true, parentId: 'resp-1');
      expect(b.pedidos.last.json, containsPair('p_order', 'recent'));
      expect(b.pedidos.last.json, containsPair('p_parent', 'resp-1'));
      expect(b.pedidos.last.json, containsPair('p_limit', 30));
    });

    test(
      'club_post_summaries: sem ids não vai; ids repetidos vão uma vez',
      () async {
        final (b, r) = await _repo({
          _rpc('club_post_summaries'): (200, fixture('club_post_summaries')),
        });
        expect(await r.postSummaries(const []), isEmpty);
        expect(b.pedidos, isEmpty);
        final s = await r.postSummaries(['b', 'a', 'b']);
        expect(b.pedidos.single.json, {
          'p_ids': ['a', 'b'],
        });
        expect(s.map((x) => x.replies), [4, 3]);
      },
    );
  });

  group('a escrita', () {
    test(
      'criar o clube (prancha 33): a leitura em semanas e o encontro',
      () async {
        final (b, r) = await _repo({_rpc('create_club'): (200, _clube)});
        final id = await r.createClub((
          name: 'Leitoras de Capitu',
          nameHighlight: 'Capitu',
          category: 'Clássicos brasileiros',
          color: '#B6ACE4',
          privacy: 'invite',
          spoilerProtection: true,
          progressColors: 'club',
          meeting: (
            weekday: 4,
            time: '20:00',
            minutes: 90,
            mode: 'online',
            timezone: 'America/Sao_Paulo',
          ),
          reading: (
            editionId: 'ed-dom',
            workId: null,
            startsOn: DateTime(2026, 9, 10),
            weeks: [
              (from: 1, to: 25, toLabel: null),
              (from: 26, to: 50, toLabel: 'L'),
            ],
          ),
        ));
        expect(id, _clube);
        expect(b.pedidos.single.json, {
          'p': {
            'name': 'Leitoras de Capitu',
            'name_highlight': 'Capitu',
            'category': 'Clássicos brasileiros',
            'color': '#B6ACE4',
            'privacy': 'invite',
            'spoiler_protection': true,
            'progress_colors': 'club',
            'meeting': {
              'weekday': 4,
              'time': '20:00',
              'minutes': 90,
              'mode': 'online',
              'timezone': 'America/Sao_Paulo',
            },
            'reading': {
              'edition_id': 'ed-dom',
              'work_id': null,
              'starts_on': '2026-09-10',
              'weeks': [
                {'from': 1, 'to': 25, 'to_label': null},
                {'from': 26, 'to': 50, 'to_label': 'L'},
              ],
            },
          },
        });
      },
    );

    test('sem encontro, a chave não vai; o 2º clube do Grátis: SocialFreeClubLimit', () async {
      final (b, r) = await _repo({
        _rpc('create_club'): erroPostgrest(400, 'P0001', 'free_club_limit'),
      });
      await expectLater(
        r.createClub((
          name: 'Poesia',
          nameHighlight: null,
          category: null,
          color: '#ABCF82',
          privacy: 'public',
          spoilerProtection: false,
          progressColors: 'members',
          meeting: null,
          reading: (
            editionId: null,
            workId: 'w',
            startsOn: DateTime(2026, 10, 1),
            weeks: [(from: 1, to: 10, toLabel: null)],
          ),
        )),
        throwsA(isA<SocialFreeClubLimit>()),
      );
      expect((b.pedidos.single.json! as Map)['p'], isNot(contains('meeting')));
    });

    test(
      'convites: criar, desativar, entrar pelo código, entrar no público, sair',
      () async {
        final (b, r) = await _repo({
          _rpc('create_invite'): (200, 'Kx7Pq2Lm'),
          _rpc('revoke_invite'): (204, null),
          _rpc('join_club'): (200, _clube),
          _rpc('join_public_club'): (204, null),
          'DELETE /rest/v1/club_members': (204, null),
        });
        expect(await r.createInvite(_clube), 'Kx7Pq2Lm');
        await r.revokeInvite('Kx7Pq2Lm');
        expect(await r.joinByCode('Kx7Pq2Lm'), _clube);
        await r.joinPublic(_clube);
        await r.leave(_clube);
        expect(b.pedidos.take(4).map((p) => p.json), [
          {'p_club': _clube, 'p_days': 7, 'p_max_uses': 12},
          {'p_code': 'Kx7Pq2Lm'},
          {'p_code': 'Kx7Pq2Lm'},
          {'p_club': _clube},
        ]);
        final sair = b.pedidos.last;
        expect(
          (filtro(sair, 'club_id'), filtro(sair, 'user_id')),
          ('eq.$_clube', 'eq.$contaTeste'),
        );
      },
    );

    test('convite vencido: SocialInvalidInvite; clube que não é público: SocialNotFound', () async {
      final (_, r) = await _repo({
        _rpc('join_club'): erroPostgrest(400, 'P0001', 'invalid_invite'),
        _rpc('join_public_club'): erroPostgrest(
          400,
          'P0001',
          'club_not_public',
        ),
      });
      await expectLater(
        r.joinByCode('velho123'),
        throwsA(isA<SocialInvalidInvite>()),
      );
      await expectLater(r.joinPublic(_clube), throwsA(isA<SocialNotFound>()));
    });

    test('o progresso (R9): a fração e o capítulo do clube — a página não vai; marcar como lido', () async {
      final (b, r) = await _repo({
        _rpc('publish_progress'): (204, null),
        _rpc('mark_club_read'): (204, null),
      });
      await r.publishProgress(_clube, ratio: 0.62, chapter: 32);
      await r.markRead(_clube);
      expect(b.pedidos.first.json, {
        'p_club': _clube,
        'p_ratio': 0.62,
        'p_chapter': 32,
      });
      expect(b.pedidos.last.json, {'p_club': _clube});
    });

    test(
      'a presença (70): a resposta, o recado e quem vê; volta a contagem',
      () async {
        final (b, r) = await _repo({
          _rpc('set_rsvp'): (200, {'vou': 9, 'talvez': 2, 'nao_vou': 0}),
        });
        final n = await r.setRsvp(
          _encontro,
          Rsvp.going,
          note: 'Levo o livro.',
          visibility: NoteVisibility.club,
        );
        expect(n, const RsvpCounts(going: 9, maybe: 2, notGoing: 0));
        expect(b.pedidos.single.json, {
          'p_meeting': _encontro,
          'p_answer': 'vou',
          'p_note': 'Levo o livro.',
          'p_visibility': 'club',
        });
        await r.setRsvp(_encontro, Rsvp.maybe);
        expect(b.pedidos.last.json, {
          'p_meeting': _encontro,
          'p_answer': 'talvez',
          'p_note': null,
          'p_visibility': null,
        });
      },
    );

    test('as perguntas da semana (72 e 73)', () async {
      final (b, r) = await _repo({
        _rpc('suggest_question'): (200, 'q-1'),
        _rpc('order_questions'): (204, null),
        _rpc('set_question_status'): (204, null),
      });
      expect(await r.suggestQuestion(_clube, 2, 'Capitu traiu?'), 'q-1');
      await r.orderQuestions(_clube, 2, ['q-2', 'q-1']);
      await r.setQuestionStatus(
        'q-1',
        QuestionStatus.postponed,
        note: 'Fica para a semana 3.',
      );
      expect(b.pedidos.map((p) => p.json), [
        {'p_club': _clube, 'p_week': 2, 'p_body': 'Capitu traiu?'},
        {
          'p_club': _clube,
          'p_week': 2,
          'p_ids': ['q-2', 'q-1'],
        },
        {
          'p_question': 'q-1',
          'p_status': 'postponed',
          'p_note': 'Fica para a semana 3.',
        },
      ]);
    });

    test('compartilhar o grifo (D-217): o trecho, a cor, a página, o capítulo e a fração — a nota não', () async {
      final (b, r) = await _repo({_rpc('share_highlight'): (200, 'post-9')});
      final id = await r.shareHighlight(_clube, (
        text: 'Olhos de cigana oblíqua e dissimulada.',
        color: '#FED170',
        page: 121,
        chapter: 25,
        ratio: 0.47,
      ));
      expect(id, 'post-9');
      expect(b.pedidos.single.json, {
        'p_club': _clube,
        'p_quote': 'Olhos de cigana oblíqua e dissimulada.',
        'p_color': '#FED170',
        'p_page': 121,
        'p_chapter': 25,
        'p_ratio': 0.47,
      });
    });

    test('curtir, descurtir e responder (31): a posição de quem escreve e a citação vão juntas', () async {
      final (b, r) = await _repo({
        'POST /rest/v1/club_likes': (201, null),
        'DELETE /rest/v1/club_likes': (204, null),
        'POST /rest/v1/club_post_replies': (201, {'id': 'resp-7'}),
      });
      await r.like(LikeTarget.reply, 'resp-1');
      expect(b.pedidos.last.json, {
        'target_type': 'reply',
        'target_id': 'resp-1',
        'user_id': contaTeste,
      });
      await r.unlike(LikeTarget.post, 'q-1');
      expect(
        (
          filtro(b.pedidos.last, 'target_type'),
          filtro(b.pedidos.last, 'target_id'),
          filtro(b.pedidos.last, 'user_id'),
        ),
        ('eq.post', 'eq.q-1', 'eq.$contaTeste'),
      );
      final id = await r.reply('q-1', (
        body: 'Ele já decidiu antes de contar.',
        parentId: null,
        ratio: 0.62,
        page: 160,
        quote: (
          text: 'A vida é cheia de obrigações…',
          color: '#FFC1C6',
          page: 121,
        ),
      ));
      expect(id, 'resp-7');
      expect(b.pedidos.last.json, {
        'post_id': 'q-1',
        'author_id': contaTeste,
        'parent_reply_id': null,
        'body': 'Ele já decidiu antes de contar.',
        'spoiler_ratio': 0.62,
        'spoiler_page': 160,
        'quote_text': 'A vida é cheia de obrigações…',
        'quote_color': '#FFC1C6',
        'quote_page': 121,
      });
      expect(filtro(b.pedidos.last, 'select'), 'id');
    });
  });

  group('as falhas', () {
    test('quem não é do clube: SocialNotAllowed; bloqueio: SocialBlocked; termos: SocialTermsRequired', () async {
      final (_, r) = await _repo({
        _rpc('club_overview'): erroPostgrest(403, '42501', 'not_member'),
        'POST /rest/v1/club_post_replies': erroPostgrest(
          400,
          'P0001',
          'blocked',
        ),
        _rpc('share_highlight'): erroPostgrest(400, 'P0001', 'terms_required'),
      });
      await expectLater(r.overview(_clube), throwsA(isA<SocialNotAllowed>()));
      await expectLater(
        r.reply('q-1', (
          body: 'oi',
          parentId: null,
          ratio: null,
          page: null,
          quote: null,
        )),
        throwsA(isA<SocialBlocked>()),
      );
      await expectLater(
        r.shareHighlight(_clube, (
          text: 't',
          color: '#FED170',
          page: null,
          chapter: 1,
          ratio: 0.1,
        )),
        throwsA(isA<SocialTermsRequired>()),
      );
    });

    test('um resumo num formato que o app não entende: SocialUnexpected("resposta")', () async {
      final (_, r) = await _repo({
        _rpc('club_overview'): (200, <Object?>['não é um mapa']),
      });
      await expectLater(
        r.overview(_clube),
        throwsA(
          isA<SocialUnexpected>().having((f) => f.code, 'code', 'resposta'),
        ),
      );
    });

    test('sem rede: SocialOffline; sem conta: nada vai', () async {
      final (b, r) = await _repo();
      b.offline = true;
      await expectLater(r.myClubs(), throwsA(isA<SocialOffline>()));
      await expectLater(r.leave(_clube), throwsA(isA<SocialOffline>()));

      final (b2, c2) = await servidorSocial(entrar: false);
      addTearDown(c2.dispose);
      final semConta = SupabaseClubsRepository(c2);
      await expectLater(semConta.myClubs(), throwsA(isA<SocialNeedsAccount>()));
      await expectLater(
        semConta.leave(_clube),
        throwsA(isA<SocialNeedsAccount>()),
      );
      await expectLater(
        semConta.like(LikeTarget.post, 'q'),
        throwsA(isA<SocialNeedsAccount>()),
      );
      await expectLater(
        semConta.reply('q', (
          body: 'x',
          parentId: null,
          ratio: null,
          page: null,
          quote: null,
        )),
        throwsA(isA<SocialNeedsAccount>()),
      );
      expect(b2.pedidos, isEmpty);
    });
  });
}

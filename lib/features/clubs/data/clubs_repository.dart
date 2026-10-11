// G21.3 — os clubes pelo Supabase (docs/progresso/G21.md §1 e §3): os 6 resumos (uma ida por tela) e a escrita.
// Tudo precisa de conta e de rede; os erros viram `SocialFailure`. O que o Grátis manda está na lista do
// privacy_free_test (só depois de um toque, ou o progresso do livro de um clube — §6).
import 'dart:convert';
import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../../social/data/social_call.dart';
import '../domain/club_models.dart';

/// Os meus clubes: os modelos e o JSON como veio (o cache guarda o JSON — D-80).
typedef MyClubs = ({List<ClubCard> cards, String json});

/// Um clube novo (prancha 33): as semanas vêm prontas (até 12, contíguas desde o cap. 1).
typedef NewClub = ({
  String name,
  String? nameHighlight,
  String? category,
  String color,
  String privacy,
  bool spoilerProtection,
  String progressColors,
  ({int weekday, String time, int minutes, String mode, String timezone})?
  meeting,
  ({
    String? editionId,
    String? workId,
    DateTime startsOn,
    List<({int from, int to, String? toLabel})> weeks,
  })
  reading,
});

/// O grifo que vai para o clube (D-217): o trecho, a cor, a página e o capítulo do clube; a fração é o spoiler
/// (D-218). A nota fica no aparelho.
typedef SharedQuote = ({
  String text,
  String color,
  int? page,
  int chapter,
  double ratio,
});

/// Curtir um post ou uma resposta.
enum LikeTarget {
  post('post'),
  reply('reply');

  const LikeTarget(this.code);
  final String code;
}

/// Uma resposta nova (31): a posição de quem escreve vai junto (o spoiler, D-218).
typedef NewReply = ({
  String body,
  String? parentId,
  double? ratio,
  int? page,
  ({String text, String? color, int? page})? quote,
});

abstract interface class ClubsRepository {
  Future<MyClubs> myClubs();
  Future<ClubOverview> overview(String clubId);
  Future<WeekThread> weekThread(
    String clubId,
    int week, {
    bool recent = false,
    String? parentId,
    Json? cursor,
    int limit = 30,
  });
  Future<MeetingOverview> meeting(String meetingId);
  Future<ClubMembers> members(String clubId);

  /// O chip da 25 (até 200 por ida): os posts que eu não vejo (saí do clube, apagado) não voltam.
  Future<List<PostSummary>> postSummaries(Iterable<String> postIds);

  Future<String> createClub(NewClub club);
  Future<String> createInvite(String clubId, {int days = 7, int maxUses = 12});
  Future<void> revokeInvite(String code);
  Future<String> joinByCode(String code);
  Future<void> joinPublic(String clubId);
  Future<void> leave(String clubId);

  /// R9 (D-216): a fração e o capítulo do clube. `false`: o servidor ignorou (a 2ª no mesmo minuto) — não marque como
  /// publicada.
  Future<bool> publishProgress(
    String clubId, {
    required double ratio,
    required int? chapter,
  });
  Future<void> markRead(String clubId);
  Future<RsvpCounts> setRsvp(
    String meetingId,
    Rsvp answer, {
    String? note,
    NoteVisibility? visibility,
  });
  Future<String> suggestQuestion(String clubId, int week, String body);
  Future<void> orderQuestions(
    String clubId,
    int week,
    List<String> questionIds,
  );
  Future<void> setQuestionStatus(
    String questionId,
    QuestionStatus status, {
    String? note,
  });

  /// Devolve o id do post, que vai para `annotations.shared_club_post_id`.
  Future<String> shareHighlight(String clubId, SharedQuote quote);
  Future<void> like(LikeTarget target, String id);
  Future<void> unlike(LikeTarget target, String id);
  Future<String> reply(String postId, NewReply reply);
}

final class SupabaseClubsRepository implements ClubsRepository {
  SupabaseClubsRepository(this._client);

  final SupabaseClient _client;

  /// A RPC [fn] dentro do [socialCall]: a sessão, o tempo e os erros; [read] monta o resultado (um formato que o app
  /// não entende também vira falha do social).
  Future<T> _call<T>(String fn, Json? params, T Function(Object? r) read) =>
      socialCall(
        _client,
        () async => read(await _client.rpc<Object?>(fn, params: params)),
      );

  static Json _asMap(Object? r) => (r! as Map).cast<String, Object?>();

  @override
  Future<MyClubs> myClubs() => _call(
    'my_clubs',
    null,
    (r) => (cards: clubCardsFromJson(r), json: jsonEncode(r)),
  );

  @override
  Future<ClubOverview> overview(String clubId) => _call('club_overview', {
    'p_club': clubId,
  }, (r) => ClubOverview.fromJson(_asMap(r)));

  @override
  Future<WeekThread> weekThread(
    String clubId,
    int week, {
    bool recent = false,
    String? parentId,
    Json? cursor,
    int limit = 30,
  }) => _call('week_thread', {
    'p_club': clubId,
    'p_week': week,
    'p_order': recent ? 'recent' : 'likes',
    'p_parent': parentId,
    'p_cursor': cursor,
    'p_limit': limit,
  }, (r) => WeekThread.fromJson(_asMap(r)));

  @override
  Future<MeetingOverview> meeting(String meetingId) => _call(
    'meeting_overview',
    {'p_meeting': meetingId},
    (r) => MeetingOverview.fromJson(_asMap(r)),
  );

  @override
  Future<ClubMembers> members(String clubId) => _call('club_members_overview', {
    'p_club': clubId,
  }, (r) => ClubMembers.fromJson(_asMap(r)));

  @override
  Future<List<PostSummary>> postSummaries(Iterable<String> postIds) async {
    final ids = postIds.toSet().toList()..sort();
    final out = <PostSummary>[];
    // o servidor aceita até [summariesPerCall] por ida
    for (var i = 0; i < ids.length; i += summariesPerCall) {
      out.addAll(
        await _call(
          'club_post_summaries',
          {'p_ids': ids.sublist(i, math.min(i + summariesPerCall, ids.length))},
          (r) => [
            for (final s in (r as List<Object?>?) ?? const <Object?>[])
              PostSummary.fromJson(_asMap(s)),
          ],
        ),
      );
    }
    return out;
  }

  /// Quantos ids o `club_post_summaries` aceita numa ida.
  static const int summariesPerCall = 200;

  @override
  Future<String> createClub(NewClub c) {
    final m = c.meeting;
    final r = c.reading;
    return _call('create_club', {
      'p': {
        'name': c.name,
        'name_highlight': c.nameHighlight,
        'category': c.category,
        'color': c.color,
        'privacy': c.privacy,
        'spoiler_protection': c.spoilerProtection,
        'progress_colors': c.progressColors,
        if (m != null)
          'meeting': {
            'weekday': m.weekday,
            'time': m.time,
            'minutes': m.minutes,
            'mode': m.mode,
            'timezone': m.timezone,
          },
        'reading': {
          'edition_id': r.editionId,
          'work_id': r.workId,
          'starts_on': _date(r.startsOn),
          'weeks': [
            for (final w in r.weeks)
              {'from': w.from, 'to': w.to, 'to_label': w.toLabel},
          ],
        },
      },
    }, (id) => id! as String);
  }

  @override
  Future<String> createInvite(
    String clubId, {
    int days = 7,
    int maxUses = 12,
  }) => _call('create_invite', {
    'p_club': clubId,
    'p_days': days,
    'p_max_uses': maxUses,
  }, (c) => c! as String);

  @override
  Future<void> revokeInvite(String code) =>
      _call('revoke_invite', {'p_code': code}, (_) {});

  @override
  Future<String> joinByCode(String code) =>
      _call('join_club', {'p_code': code}, (id) => id! as String);

  @override
  Future<void> joinPublic(String clubId) =>
      _call('join_public_club', {'p_club': clubId}, (_) {});

  @override
  Future<void> leave(String clubId) => socialCall(
    _client,
    () => _client
        .from('club_members')
        .delete()
        .eq('club_id', clubId)
        .eq('user_id', socialUserId(_client)),
  );

  @override
  Future<bool> publishProgress(
    String clubId, {
    required double ratio,
    required int? chapter,
  }) => _call('publish_progress', {
    'p_club': clubId,
    'p_ratio': ratio,
    'p_chapter': chapter,
  }, (r) => r == true);

  @override
  Future<void> markRead(String clubId) =>
      _call('mark_club_read', {'p_club': clubId}, (_) {});

  @override
  Future<RsvpCounts> setRsvp(
    String meetingId,
    Rsvp answer, {
    String? note,
    NoteVisibility? visibility,
  }) => _call('set_rsvp', {
    'p_meeting': meetingId,
    'p_answer': answer.code,
    'p_note': note,
    'p_visibility': visibility?.code,
  }, (r) => RsvpCounts.fromJson(_asMap(r)));

  @override
  Future<String> suggestQuestion(String clubId, int week, String body) => _call(
    'suggest_question',
    {'p_club': clubId, 'p_week': week, 'p_body': body},
    (id) => id! as String,
  );

  @override
  Future<void> orderQuestions(
    String clubId,
    int week,
    List<String> questionIds,
  ) => _call('order_questions', {
    'p_club': clubId,
    'p_week': week,
    'p_ids': questionIds,
  }, (_) {});

  @override
  Future<void> setQuestionStatus(
    String questionId,
    QuestionStatus status, {
    String? note,
  }) => _call('set_question_status', {
    'p_question': questionId,
    'p_status': status.code,
    'p_note': note,
  }, (_) {});

  @override
  Future<String> shareHighlight(String clubId, SharedQuote q) =>
      _call('share_highlight', {
        'p_club': clubId,
        'p_quote': q.text,
        'p_color': q.color,
        'p_page': q.page,
        'p_chapter': q.chapter,
        'p_ratio': q.ratio,
      }, (id) => id! as String);

  @override
  Future<void> like(LikeTarget target, String id) => socialCall(
    _client,
    () => _client.from('club_likes').insert({
      'target_type': target.code,
      'target_id': id,
      'user_id': socialUserId(_client),
    }),
  );

  @override
  Future<void> unlike(LikeTarget target, String id) => socialCall(
    _client,
    () => _client
        .from('club_likes')
        .delete()
        .eq('target_type', target.code)
        .eq('target_id', id)
        .eq('user_id', socialUserId(_client)),
  );

  @override
  Future<String> reply(String postId, NewReply r) =>
      socialCall(_client, () async {
        final q = r.quote;
        final row = await _client
            .from('club_post_replies')
            .insert({
              'post_id': postId,
              'author_id': socialUserId(_client),
              'parent_reply_id': r.parentId,
              'body': r.body,
              'spoiler_ratio': r.ratio,
              'spoiler_page': r.page,
              'quote_text': q?.text,
              'quote_color': q?.color,
              'quote_page': q?.page,
            })
            .select('id')
            .single();
        return row['id']! as String;
      });

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

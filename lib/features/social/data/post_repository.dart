// G21.3 — os posts do perfil, os comentários e as curtidas (docs/progresso/G21.md §3). Comentar e curtir as
// resenhas: todos, nas que podem ver (o Grátis, nas próprias — monetização v3, pela RLS). Apagar = marcar a data.
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../domain/social_models.dart';
import 'social_call.dart';

abstract interface class PostRepository {
  /// Publica e devolve o id.
  Future<String> create(NewPost post);
  Future<void> delete(String postId);
  Future<String> comment(String postId, String body);
  Future<void> deleteComment(String commentId);

  /// Os comentários de uma resenha, os mais antigos primeiro (até [limit]).
  Future<List<PostComment>> comments(String postId, {int limit = 50});
  Future<void> like(String postId);
  Future<void> unlike(String postId);
}

final class SupabasePostRepository implements PostRepository {
  SupabasePostRepository(this._client, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final SupabaseClient _client;
  final DateTime Function() _now;

  String get _nowIso => _now().toUtc().toIso8601String();

  @override
  Future<String> create(NewPost p) => socialCall(_client, () async {
    final row = await _client
        .from('posts')
        .insert({
          'author_id': socialUserId(_client),
          'kind': p.kind.code,
          'edition_id': p.editionId,
          'work_id': p.workId,
          'rating': p.rating,
          'quote_text': p.quote,
          'body': p.body,
        })
        .select('id')
        .single();
    return row['id']! as String;
  });

  @override
  Future<void> delete(String postId) => socialCall(
    _client,
    () => _client
        .from('posts')
        .update({'deleted_at': _nowIso})
        .eq('id', postId)
        .eq('author_id', socialUserId(_client)),
  );

  @override
  Future<String> comment(String postId, String body) =>
      socialCall(_client, () async {
        final row = await _client
            .from('post_comments')
            .insert({
              'post_id': postId,
              'author_id': socialUserId(_client),
              'body': body,
            })
            .select('id')
            .single();
        return row['id']! as String;
      });

  @override
  Future<void> deleteComment(String commentId) => socialCall(
    _client,
    () => _client
        .from('post_comments')
        .update({'deleted_at': _nowIso})
        .eq('id', commentId)
        .eq('author_id', socialUserId(_client)),
  );

  @override
  Future<List<PostComment>> comments(String postId, {int limit = 50}) =>
      socialCall(_client, () async {
        final rows = await _client
            .from('post_comments')
            .select('id,author_id,body,created_at')
            .eq('post_id', postId)
            .isFilter('deleted_at', null)
            .order('created_at', ascending: true)
            .limit(limit)
            .retry(enabled: false);
        return [for (final r in rows) postCommentFromJson(r)];
      });

  @override
  Future<void> like(String postId) => socialCall(
    _client,
    () => _client.from('post_likes').insert({
      'post_id': postId,
      'user_id': socialUserId(_client),
    }),
  );

  @override
  Future<void> unlike(String postId) => socialCall(
    _client,
    () => _client
        .from('post_likes')
        .delete()
        .eq('post_id', postId)
        .eq('user_id', socialUserId(_client)),
  );
}

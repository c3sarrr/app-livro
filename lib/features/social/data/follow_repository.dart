// G21.3 — seguir e bloquear (docs/progresso/G21.md §3). Perfil fechado vira pedido pelo gatilho do servidor (o app
// não escolhe o status); o bloqueio esconde nos dois sentidos (D-223), e quem está bloqueado some das listas.
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../domain/social_models.dart';
import 'social_call.dart';

abstract interface class FollowRepository {
  Future<FollowState> follow(String userId);
  Future<void> unfollow(String userId);

  /// Os pedidos para seguir o meu perfil fechado.
  Future<List<PersonRef>> requests();
  Future<void> accept(String followerId);
  Future<void> decline(String followerId);

  /// Quem segue [userId] (a RLS mostra a lista de quem eu posso ver).
  Future<List<PersonRef>> followers(String userId);

  /// Quem [userId] segue.
  Future<List<PersonRef>> following(String userId);
}

abstract interface class BlockRepository {
  Future<void> block(String userId);
  Future<void> unblock(String userId);

  /// Quem eu bloqueei.
  Future<Set<String>> blocked();
}

const String _person = 'id,handle,display_name,avatar_path';

/// Até quantas pessoas uma lista traz (a tela pagina depois, com a Trilha T).
const int peopleShown = 100;

final class SupabaseFollowRepository implements FollowRepository {
  SupabaseFollowRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<FollowState> follow(String userId) => socialCall(_client, () async {
    final row = await _client
        .from('follows')
        .insert({'follower_id': socialUserId(_client), 'followee_id': userId})
        .select('status')
        .single();
    return FollowState.of(row['status']);
  });

  @override
  Future<void> unfollow(String userId) => socialCall(
    _client,
    () => _client
        .from('follows')
        .delete()
        .eq('follower_id', socialUserId(_client))
        .eq('followee_id', userId),
  );

  @override
  Future<List<PersonRef>> requests() => _people(
    'follower:profiles!follows_follower_id_fkey',
    'pending',
    () => {'followee_id': socialUserId(_client)},
  );

  @override
  Future<void> accept(String followerId) => socialCall(
    _client,
    () => _client
        .from('follows')
        .update({'status': 'accepted'})
        .eq('follower_id', followerId)
        .eq('followee_id', socialUserId(_client)),
  );

  @override
  Future<void> decline(String followerId) => socialCall(
    _client,
    () => _client
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('followee_id', socialUserId(_client)),
  );

  @override
  Future<List<PersonRef>> followers(String userId) => _people(
    'follower:profiles!follows_follower_id_fkey',
    'accepted',
    () => {'followee_id': userId},
  );

  @override
  Future<List<PersonRef>> following(String userId) => _people(
    'followee:profiles!follows_followee_id_fkey',
    'accepted',
    () => {'follower_id': userId},
  );

  /// As pessoas de um lado da relação ([embed] = `alias:profiles!fk`), as mais novas primeiro; [where] roda dentro
  /// do [socialCall] (a sessão é conferida antes).
  Future<List<PersonRef>> _people(
    String embed,
    String status,
    Map<String, String> Function() where,
  ) => socialCall(_client, () async {
    var q = _client
        .from('follows')
        .select('$embed($_person)')
        .eq('status', status);
    for (final w in where().entries) {
      q = q.eq(w.key, w.value);
    }
    final rows = await q
        .order('created_at', ascending: false)
        .limit(peopleShown)
        .retry(enabled: false);
    final alias = embed.substring(0, embed.indexOf(':'));
    return [
      for (final r in rows)
        // perfil bloqueado: o embutido vem nulo (a RLS de `profiles`)
        if (r[alias] case final Map<String, Object?> p) personRefFromJson(p),
    ];
  });
}

final class SupabaseBlockRepository implements BlockRepository {
  SupabaseBlockRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> block(String userId) => socialCall(
    _client,
    () => _client.from('user_blocks').insert({
      'blocker_id': socialUserId(_client),
      'blocked_id': userId,
    }),
  );

  @override
  Future<void> unblock(String userId) => socialCall(
    _client,
    () => _client
        .from('user_blocks')
        .delete()
        .eq('blocker_id', socialUserId(_client))
        .eq('blocked_id', userId),
  );

  @override
  Future<Set<String>> blocked() => socialCall(_client, () async {
    final rows = await _client
        .from('user_blocks')
        .select('blocked_id')
        .eq('blocker_id', socialUserId(_client))
        .retry(enabled: false);
    return {for (final r in rows) r['blocked_id']! as String};
  });
}

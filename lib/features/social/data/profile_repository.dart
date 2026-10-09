// G21.3 — o perfil (docs/progresso/G21.md §3): o de outra pessoa pelo plano — o Pro lê o perfil e os posts pelas
// tabelas (a RLS confere `can_view_profile_content`); o Grátis, a prévia `profile_preview`, que não traz texto (o
// "desfocado" não pode ser revertido no aparelho). O meu: mudar nome, bio e se é fechado; publicar os 4 números.
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../domain/social_models.dart';
import 'social_call.dart';

abstract interface class ProfileRepository {
  /// O perfil pelo @. `null`: não existe, ou há bloqueio entre as duas pessoas.
  Future<ProfileView?> byHandle(String handle, {required bool pro});

  /// Muda o meu perfil (só os campos dados; o @ muda pela conta — G05).
  Future<void> updateMine({String? displayName, String? bio, bool? isPrivate});

  /// R10 (D-216): os 4 números agregados; o servidor ignora a 2ª vez no mesmo minuto.
  Future<void> publishStats(ProfileNumbers numbers);
}

final class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  /// Quantos posts o perfil completo traz (a tela pagina depois, com a Trilha T).
  static const int postsShown = 20;

  @override
  Future<ProfileView?> byHandle(String handle, {required bool pro}) =>
      socialCall(_client, () async {
        final h = handle.trim().toLowerCase();
        if (!pro) {
          final r = await _client.rpc<Object?>(
            'profile_preview',
            params: {'p_handle': h},
          );
          return r == null
              ? null
              : ProfilePreview.fromJson((r as Map).cast<String, Object?>());
        }
        final rows = await _client
            .from('profiles')
            .select(
              'id,handle,display_name,avatar_path,bio,visibility,'
              'profile_stats(books_read_total,books_read_year,reading_now,streak_days)',
            )
            .eq('handle', h)
            .limit(1)
            .retry(enabled: false);
        if (rows.isEmpty) return null;
        final profile = rows.first;
        final posts = await _client
            .from('posts')
            .select('id,kind,quote_text,body,rating,created_at')
            .eq('author_id', profile['id']! as String)
            .isFilter('deleted_at', null)
            .order('created_at', ascending: false)
            .limit(postsShown)
            .retry(enabled: false);
        return ProfileFull.fromJson(profile, posts);
      });

  @override
  Future<void> updateMine({String? displayName, String? bio, bool? isPrivate}) {
    final changes = <String, Object?>{
      'display_name': ?displayName?.trim(),
      'bio': ?bio,
      if (isPrivate != null) 'visibility': isPrivate ? 'private' : 'public',
    };
    if (changes.isEmpty) return Future.value();
    return socialCall(
      _client,
      () => _client
          .from('profiles')
          .update(changes)
          .eq('id', socialUserId(_client)),
    );
  }

  @override
  Future<void> publishStats(ProfileNumbers n) => socialCall(
    _client,
    () => _client.rpc<Object?>(
      'publish_my_stats',
      params: {
        'p_books_read_total': n.booksReadTotal,
        'p_books_read_year': n.booksReadYear,
        'p_reading_now': n.readingNow,
        'p_streak_days': n.streakDays,
      },
    ),
  );
}

// G21.3 — o social do prompt mestre (§6, G21): perfil, números, prévia do Grátis × perfil completo do Pro, termos.
// Só dados; as telas do perfil vêm pela Trilha T.
import 'package:flutter/foundation.dart' show immutable;

typedef SocialJson = Map<String, Object?>;

SocialJson _map(Object? o) => (o! as Map).cast<String, Object?>();
int _int(Object? o) => (o as num?)?.toInt() ?? 0;

/// Um recurso embutido pelo PostgREST: o objeto (um para um) ou a lista com ele.
SocialJson? _one(Object? o) => switch (o) {
  final Map<Object?, Object?> m => m.cast<String, Object?>(),
  [final Object? first, ...] => _one(first),
  _ => null,
};

/// Uma pessoa numa lista (seguidores, pedidos): o básico do perfil, que é público para quem tem conta.
typedef PersonRef = ({
  String id,
  String handle,
  String displayName,
  String? avatarPath,
});

PersonRef personRefFromJson(SocialJson j) => (
  id: j['id']! as String,
  handle: j['handle']! as String,
  displayName: j['display_name']! as String,
  avatarPath: j['avatar_path'] as String?,
);

/// Os 4 números públicos do perfil (o Grátis publica só estes agregados — Anexo 02 §1; D-216).
@immutable
final class ProfileNumbers {
  const ProfileNumbers({
    required this.booksReadTotal,
    required this.booksReadYear,
    required this.readingNow,
    required this.streakDays,
  });

  factory ProfileNumbers.fromJson(SocialJson j) => ProfileNumbers(
    booksReadTotal: _int(j['books_read_total']),
    booksReadYear: _int(j['books_read_year']),
    readingNow: _int(j['reading_now']),
    streakDays: _int(j['streak_days']),
  );

  final int booksReadTotal;
  final int booksReadYear;
  final int readingNow;
  final int streakDays;

  @override
  bool operator ==(Object other) =>
      other is ProfileNumbers &&
      other.booksReadTotal == booksReadTotal &&
      other.booksReadYear == booksReadYear &&
      other.readingNow == readingNow &&
      other.streakDays == streakDays;

  @override
  int get hashCode =>
      Object.hash(booksReadTotal, booksReadYear, readingNow, streakDays);
}

/// O perfil de outra pessoa: a prévia (Grátis) ou o completo (Pro). O que o Grátis recebe não tem texto.
@immutable
sealed class ProfileView {
  const ProfileView({
    required this.id,
    required this.handle,
    required this.displayName,
    required this.isPrivate,
    required this.numbers,
    this.avatarPath,
  });

  final String id;
  final String handle;
  final String displayName;
  final String? avatarPath;
  final bool isPrivate;
  final ProfileNumbers numbers;
}

/// Uma resenha na prévia: só o tipo, o tamanho e a data ("desfocada" sem poder ser revertida no aparelho).
typedef PostPreview = ({String id, String kind, int chars, DateTime createdAt});

/// A prévia do Grátis (`profile_preview`): nome, foto, números e o tamanho das 3 últimas resenhas.
final class ProfilePreview extends ProfileView {
  const ProfilePreview({
    required super.id,
    required super.handle,
    required super.displayName,
    required super.isPrivate,
    required super.numbers,
    required this.recentPosts,
    super.avatarPath,
  });

  factory ProfilePreview.fromJson(SocialJson j) => ProfilePreview(
    id: j['id']! as String,
    handle: j['handle']! as String,
    displayName: j['display_name']! as String,
    avatarPath: j['avatar_path'] as String?,
    isPrivate: j['visibility'] == 'private',
    numbers: ProfileNumbers.fromJson(_map(j['stats'])),
    recentPosts: [
      for (final p
          in (j['recent_posts'] as List<Object?>?) ?? const <Object?>[])
        (
          id: _map(p)['id']! as String,
          kind: _map(p)['kind']! as String,
          chars: _int(_map(p)['chars']),
          createdAt: DateTime.parse(_map(p)['created_at']! as String).toUtc(),
        ),
    ],
  );

  final List<PostPreview> recentPosts;
}

/// Uma resenha, citação ou lista do perfil (o Pro lê o texto).
typedef ProfilePost = ({
  String id,
  String kind,
  String? quote,
  String? body,
  int? rating,
  DateTime createdAt,
});

/// O perfil completo do Pro (perfil aberto, ou fechado com o pedido aceito; fechado sem pedido: sem posts).
final class ProfileFull extends ProfileView {
  const ProfileFull({
    required super.id,
    required super.handle,
    required super.displayName,
    required super.isPrivate,
    required super.numbers,
    required this.posts,
    super.avatarPath,
    this.bio,
  });

  /// [profile] = a linha de `profiles` com `profile_stats` embutido; [posts] = as linhas de `posts`.
  factory ProfileFull.fromJson(SocialJson profile, List<Object?> posts) {
    final stats = _one(profile['profile_stats']);
    return ProfileFull(
      id: profile['id']! as String,
      handle: profile['handle']! as String,
      displayName: profile['display_name']! as String,
      avatarPath: profile['avatar_path'] as String?,
      bio: profile['bio'] as String?,
      isPrivate: profile['visibility'] == 'private',
      numbers: stats == null
          ? const ProfileNumbers(
              booksReadTotal: 0,
              booksReadYear: 0,
              readingNow: 0,
              streakDays: 0,
            )
          : ProfileNumbers.fromJson(stats),
      posts: [
        for (final o in posts)
          if (_one(o) case final p?)
            (
              id: p['id']! as String,
              kind: p['kind']! as String,
              quote: p['quote_text'] as String?,
              body: p['body'] as String?,
              rating: (p['rating'] as num?)?.toInt(),
              createdAt: DateTime.parse(p['created_at']! as String).toUtc(),
            ),
      ],
    );
  }

  final String? bio;
  final List<ProfilePost> posts;
}

/// Os termos da comunidade (D-222).
@immutable
final class TermsStatus {
  const TermsStatus({required this.version, required this.accepted});

  factory TermsStatus.fromJson(SocialJson j) => TermsStatus(
    version: j['version']! as String,
    accepted: j['accepted'] == true,
  );

  final String version;
  final bool accepted;
}

/// O que se denuncia (`content_reports.target_type`).
enum ReportTarget {
  profile('profile'),
  post('post'),
  postComment('post_comment'),
  club('club'),
  clubPost('club_post'),
  clubPostReply('club_post_reply');

  const ReportTarget(this.code);
  final String code;
}

/// O motivo da denúncia.
enum ReportReason {
  spam('spam'),
  harassment('harassment'),
  hate('hate'),
  sexual('sexual'),
  spoiler('spoiler'),
  other('other');

  const ReportReason(this.code);
  final String code;
}

/// Seguir: perfil aberto vira seguidora na hora; fechado, um pedido (o servidor decide — o app não escolhe).
enum FollowState {
  pending('pending'),
  accepted('accepted');

  const FollowState(this.code);
  final String code;

  static FollowState of(Object? code) => code == 'pending' ? pending : accepted;
}

/// Os tipos de post do perfil.
enum PostKind {
  review('review'),
  quote('quote'),
  list('list');

  const PostKind(this.code);
  final String code;
}

/// Um post novo do perfil (resenha com nota, citação ou lista).
typedef NewPost = ({
  PostKind kind,
  String? editionId,
  String? workId,
  int? rating,
  String? quote,
  String? body,
});

/// Um comentário numa resenha.
typedef PostComment = ({
  String id,
  String authorId,
  String body,
  DateTime createdAt,
});

PostComment postCommentFromJson(SocialJson j) => (
  id: j['id']! as String,
  authorId: j['author_id']! as String,
  body: j['body']! as String,
  createdAt: DateTime.parse(j['created_at']! as String).toUtc(),
);

// G21.4 — o cache do social no aparelho (docs/progresso/G21.md §4; D-68, D-80): por dono, em `social_cache`. O
// ticket, a faixa, o chip e o sininho leem daqui, sem rede, com o último dado. Conteúdo que não se entende vira
// "nada" (nunca derruba a tela). Trocar de conta não mostra o da outra: a chave leva o dono; sair apaga tudo
// (`LocalLibrary.clearSocialCache`).
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/codecs.dart' show parseInstant;
import '../../home/data/cached_club_ticket_source.dart';
import '../domain/club_models.dart';
import '../domain/club_rules.dart';

final class ClubsCache {
  ClubsCache(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Future<AppDatabase> Function() _database;
  final DateTime Function() _now;

  /// A última resposta de `my_clubs`.
  static String clubsKey(String owner) => 'clubes:$owner';

  /// O ticket da Início (o contrato do [CachedClubTicketSource]).
  static String ticketKey(String owner) => CachedClubTicketSource.keyFor(owner);

  /// Os resumos do chip da 25, por post.
  static String postsKey(String owner) => 'clube.posts:$owner';

  /// A contagem do sininho.
  static String notificationsKey(String owner) => 'notificacoes:$owner';

  /// Quando os números do perfil foram publicados (R10).
  static String statsKey(String owner) => 'perfil.numeros:$owner';

  /// A última posição publicada em cada clube (R9).
  static String progressKey(String owner) => 'clube.progresso:$owner';

  // ---------------------------------------------------------------------------------------------- os clubes

  Future<List<ClubCard>> clubs(String owner) async =>
      _clubsOf(await _read(clubsKey(owner)));

  Stream<List<ClubCard>> watchClubs(String owner) =>
      _watch(clubsKey(owner)).map(_clubsOf);

  /// Guarda a resposta de `my_clubs` ([json], como veio) e refaz o ticket (R3).
  Future<void> saveClubs(String owner, String json) async {
    await _write(clubsKey(owner), json);
    await refreshTicket(owner);
  }

  /// R3 (D-215, D-226): o ticket da Início — o clube com encontro marcado que lê o livro em leitura; sem nenhum
  /// com encontro, a chave sai (o ticket some). Roda ao guardar os clubes e ao sair do leitor (o herói pode ter
  /// mudado).
  Future<void> refreshTicket(String owner) async {
    final db = await _database();
    // numa transação: guardar os clubes e sair do leitor ao mesmo tempo não deixam o ticket velho por cima
    await db.transaction(() async {
      final club = ticketClub(await clubs(owner), await readingBook(owner));
      if (club == null) {
        await _remove(ticketKey(owner));
      } else {
        await _write(ticketKey(owner), jsonEncode(ticketJson(club)));
      }
    });
  }

  /// O herói da Início — o livro em leitura com a atividade mais recente (a mesma ordem da Início): a edição e o
  /// ISBN-13. Fica no aparelho (D-213).
  Future<ShelfBookId?> readingBook(String owner) async {
    final db = await _database();
    final rows = await db
        .customSelect(
          'SELECT b.id, b.edition_id, b.isbn13, b.last_opened_at, b.started_at, b.added_at, '
          'p.updated_at AS position_at '
          'FROM user_books b LEFT JOIN reading_positions p '
          'ON p.id = b.id AND p.user_id = b.user_id AND p.deleted_at IS NULL '
          "WHERE b.user_id = ?1 AND b.deleted_at IS NULL AND b.status = 'reading'",
          variables: [Variable.withString(owner)],
        )
        .get();
    if (rows.isEmpty) return null;
    DateTime? at(QueryRow r, String c) {
      final s = r.readNullable<String>(c);
      if (s == null) return null;
      try {
        return parseInstant(s);
      } on FormatException {
        return null;
      }
    }

    DateTime activity(QueryRow r) =>
        at(r, 'last_opened_at') ??
        at(r, 'position_at') ??
        at(r, 'started_at') ??
        at(r, 'added_at') ??
        DateTime.utc(1970);
    final sorted = rows.toList()
      ..sort((a, b) {
        final c = activity(b).compareTo(activity(a));
        return c != 0
            ? c
            : b.read<String>('id').compareTo(a.read<String>('id'));
      });
    final hero = sorted.first;
    return (
      editionId: hero.readNullable<String>('edition_id'),
      isbn13: hero.readNullable<String>('isbn13'),
    );
  }

  /// O livro [userBookId] da conta [owner]: a edição e o ISBN-13 (`null`: não está na estante).
  Future<ShelfBookId?> book(String owner, String userBookId) async {
    final db = await _database();
    final row =
        await (db.select(db.userBooks)..where(
              (t) =>
                  t.id.equals(userBookId) &
                  t.userId.equals(owner) &
                  t.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return row == null ? null : (editionId: row.editionId, isbn13: row.isbn13);
  }

  // ------------------------------------------------------------------------------------- o chip da 25

  Future<Map<String, PostSummary>> posts(String owner) async =>
      _postsOf(await _read(postsKey(owner)));

  Stream<Map<String, PostSummary>> watchPosts(String owner) =>
      _watch(postsKey(owner)).map(_postsOf);

  /// Guarda os resumos que voltaram ([got]) dos posts pedidos ([asked]): um pedido que não voltou (saí do clube,
  /// o post foi apagado) sai do cache e o chip some.
  Future<void> savePosts(
    String owner,
    Iterable<String> asked,
    Iterable<PostSummary> got,
  ) => _update(postsKey(owner), _postsOf, (m) {
    for (final id in asked) {
      m.remove(id);
    }
    for (final s in got) {
      m[s.id] = s;
    }
    return m;
  }, _encodePosts);

  /// O post que acabei de compartilhar (o chip aparece sem esperar a rede).
  Future<void> addPost(String owner, PostSummary s) =>
      savePosts(owner, const [], [s]);

  // ----------------------------------------------------------------------------------------- o sininho

  Future<int> notifications(String owner) async =>
      _intOf(await _read(notificationsKey(owner)));

  Stream<int> watchNotifications(String owner) =>
      _watch(notificationsKey(owner)).map(_intOf);

  Future<void> saveNotifications(String owner, int unread) =>
      _write(notificationsKey(owner), jsonEncode(unread < 0 ? 0 : unread));

  // ------------------------------------------------------------------------------- o que já foi publicado

  Future<DateTime?> statsPublishedAt(String owner) async {
    final s = await _read(statsKey(owner));
    try {
      return s == null ? null : parseInstant(jsonDecode(s)! as String);
    } on Object {
      return null;
    }
  }

  Future<void> saveStatsPublishedAt(String owner, DateTime at) =>
      _write(statsKey(owner), jsonEncode(at.toUtc().toIso8601String()));

  Future<PublishedProgress?> publishedProgress(
    String owner,
    String clubId,
  ) async => _progressOf(await _read(progressKey(owner)))[clubId];

  Future<void> savePublishedProgress(
    String owner,
    String clubId,
    PublishedProgress p,
  ) => _update(
    progressKey(owner),
    _progressOf,
    (m) => m..[clubId] = p,
    (m) => jsonEncode({
      for (final e in m.entries)
        e.key: {'ratio': e.value.ratio, 'chapter': e.value.chapter},
    }),
  );

  // ---------------------------------------------------------------------------------------------- base

  Future<String?> _read(String key) async {
    final db = await _database();
    final row = await (db.select(
      db.socialCache,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.payload;
  }

  Stream<String?> _watch(String key) async* {
    final db = await _database();
    yield* (db.select(db.socialCache)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((r) => r?.payload)
        // a tabela muda por outras chaves também: só o que mudou nesta chave sai
        .distinct();
  }

  Future<void> _write(String key, String payload) async {
    final db = await _database();
    await db
        .into(db.socialCache)
        .insertOnConflictUpdate(
          SocialCacheCompanion.insert(
            key: key,
            payload: payload,
            updatedAt: _now().toUtc(),
          ),
        );
  }

  Future<void> _remove(String key) async {
    final db = await _database();
    await (db.delete(db.socialCache)..where((t) => t.key.equals(key))).go();
  }

  /// Ler, mudar e gravar numa transação (duas mudanças ao mesmo tempo não se perdem).
  Future<void> _update<T>(
    String key,
    T Function(String?) decode,
    T Function(T) change,
    String Function(T) encode,
  ) async {
    final db = await _database();
    await db.transaction(() async {
      await _write(key, encode(change(decode(await _read(key)))));
    });
  }

  static List<ClubCard> _clubsOf(String? json) {
    if (json == null) return const [];
    try {
      return clubCardsFromJson(jsonDecode(json));
    } on Object {
      return const [];
    }
  }

  static Map<String, PostSummary> _postsOf(String? json) {
    if (json == null) return {};
    try {
      final m = (jsonDecode(json)! as Map).cast<String, Object?>();
      return {
        for (final e in m.entries)
          e.key: PostSummary.fromJson(
            (e.value! as Map).cast<String, Object?>(),
          ),
      };
    } on Object {
      return {};
    }
  }

  static String _encodePosts(Map<String, PostSummary> m) =>
      jsonEncode({for (final e in m.entries) e.key: e.value.toJson()});

  static int _intOf(String? json) {
    if (json == null) return 0;
    try {
      final n = (jsonDecode(json)! as num).toInt();
      return n < 0 ? 0 : n;
    } on Object {
      return 0;
    }
  }

  static Map<String, PublishedProgress> _progressOf(String? json) {
    if (json == null) return {};
    try {
      final m = (jsonDecode(json)! as Map).cast<String, Object?>();
      return {
        for (final e in m.entries)
          e.key: (
            ratio: ((e.value! as Map)['ratio']! as num).toDouble(),
            chapter: ((e.value! as Map)['chapter'] as num?)?.toInt(),
          ),
      };
    } on Object {
      return {};
    }
  }
}

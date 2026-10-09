// G21.4 — a atualização do social (D-225): os meus clubes e o sininho vão para o cache da conta; sem rede, o cache
// fica como estava; os resumos do chip numa ida.
import 'dart:convert';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/features/clubs/application/clubs_sync.dart';
import 'package:app_leitura/features/clubs/data/clubs_cache.dart';
import 'package:app_leitura/features/clubs/data/clubs_repository.dart';
import 'package:app_leitura/features/clubs/domain/club_models.dart';
import 'package:app_leitura/features/social/data/community_repository.dart';
import 'package:app_leitura/features/social/domain/social_failure.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'club_models_test.dart' show fixture;

const _dona = 'dona';

final class _Clubes implements ClubsRepository {
  SocialFailure? falha;
  Object? clubes = fixture('my_clubs');
  final pedidosDeResumo = <List<String>>[];
  List<PostSummary> resumos = const [];

  @override
  Future<MyClubs> myClubs() async {
    if (falha case final f?) throw f;
    return (cards: clubCardsFromJson(clubes), json: jsonEncode(clubes));
  }

  @override
  Future<List<PostSummary>> postSummaries(Iterable<String> postIds) async {
    if (falha case final f?) throw f;
    pedidosDeResumo.add(postIds.toList()..sort());
    return resumos;
  }

  @override
  Object? noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

final class _Sininho implements NotificationsRepository {
  SocialFailure? falha;
  int naoLidas = 2;

  @override
  Future<int> unreadCount() async {
    if (falha case final f?) throw f;
    return naoLidas;
  }

  @override
  Future<void> markAllRead() async {}
}

void main() {
  late AppDatabase db;
  late ClubsCache cache;
  late _Clubes clubes;
  late _Sininho sininho;
  late ClubsSync sync;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    cache = ClubsCache(() async => db);
    clubes = _Clubes();
    sininho = _Sininho();
    sync = ClubsSync(clubs: clubes, notifications: sininho, cache: cache);
  });
  tearDown(() => db.close());

  test('abrir o app: os clubes, o ticket e a contagem do sininho vão para o cache da conta', () async {
    expect(await sync.refresh(_dona), isNull);
    expect((await cache.clubs(_dona)).single.membersCount, 11);
    expect(await cache.notifications(_dona), 2);
    final ticket =
        await (db.select(db.socialCache)
              ..where((t) => t.key.equals(ClubsCache.ticketKey(_dona))))
            .getSingleOrNull();
    expect(ticket, isNotNull);
  });

  test('sem rede: o cache fica como estava, e a falha volta para quem pediu na hora', () async {
    await sync.refresh(_dona);
    clubes.falha = const SocialOffline();
    sininho.falha = const SocialOffline();
    expect(await sync.refresh(_dona), isA<SocialOffline>());
    expect((await cache.clubs(_dona)).single.name, 'Leitoras de Capitu');
    expect(await cache.notifications(_dona), 2);
  });

  test('o sininho falha sozinho: os clubes atualizam do mesmo jeito', () async {
    sininho.falha = const SocialUnexpected('pg_500');
    clubes.clubes = <Object?>[];
    expect(await sync.refresh(_dona), isNull);
    expect(await cache.clubs(_dona), isEmpty);
    expect(await cache.notifications(_dona), 0);
  });

  test('os resumos do chip: uma ida com os ids sem repetição; nada a pedir, nada vai', () async {
    clubes.resumos = const [
      PostSummary(
        id: 'p1',
        clubId: 'c1',
        clubName: 'Leitoras de Capitu',
        replies: 3,
      ),
    ];
    expect(await sync.refreshPosts(_dona, const []), isNull);
    expect(clubes.pedidosDeResumo, isEmpty);
    expect(await sync.refreshPosts(_dona, ['p2', 'p1', 'p2']), isNull);
    expect(clubes.pedidosDeResumo, [
      ['p1', 'p2'],
    ]);
    expect((await cache.posts(_dona)).keys, ['p1']);

    clubes.falha = const SocialOffline();
    expect(await sync.refreshPosts(_dona, ['p1']), isA<SocialOffline>());
    expect((await cache.posts(_dona)).keys, [
      'p1',
    ], reason: 'sem rede, o chip fica');
  });
}

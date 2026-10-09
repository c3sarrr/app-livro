// G21.4 — o cache do social por dono (docs/progresso/G21.md §4; D-68, D-80): o ticket que a Início lê (R3 com o
// herói da estante), o chip da 25, o sininho e o que já foi publicado; trocar de conta não mostra o da outra; lixo
// no cache vira "nada".
import 'dart:convert';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/clubs/data/clubs_cache.dart';
import 'package:app_leitura/features/clubs/domain/club_models.dart';
import 'package:app_leitura/features/home/data/cached_club_ticket_source.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/personal_builders.dart';
import 'club_models_test.dart' show fixture;

const _dona = usuarioTeste;
const _outra = '0199a7c4-2f00-7a10-8b20-0000000000ff';
const _domEdicao = '00000000-0000-7000-8000-00000c0a0003';

/// Edições de teste (a estante guarda o id do catálogo: um UUID).
final _edOutro = idTeste(701);
final _edVelho = idTeste(801);
final _edNovo = idTeste(802);
final _edQuero = idTeste(803);
final _edDaOutra = idTeste(804);

/// O clube do mundo com outro id, nome, edição e encontro (para a R3 entre dois).
Map<String, Object?> _outroClube({
  required String id,
  required String name,
  String? edition,
  List<String> isbns = const [],
  String? meeting,
}) {
  final c = ((fixture('my_clubs')! as List).single as Map)
      .cast<String, Object?>();
  final reading = (c['reading']! as Map).cast<String, Object?>();
  return {
    ...c,
    'id': id,
    'name': name,
    'name_highlight': null,
    'reading': {
      ...reading,
      'edition_id': edition,
      'isbns': isbns,
      'isbn13': null,
    },
    'next_meeting': meeting == null
        ? null
        : {
            ...(c['next_meeting']! as Map).cast<String, Object?>(),
            'starts_at': meeting,
          },
  };
}

void main() {
  late AppDatabase db;
  late ClubsCache cache;
  final agora = DateTime.utc(2026, 10, 9, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    cache = ClubsCache(() async => db, now: () => agora);
  });
  tearDown(() => db.close());

  Future<String?> chave(String k) async => (await (db.select(
    db.socialCache,
  )..where((t) => t.key.equals(k))).getSingleOrNull())?.payload;

  Future<void> livro(
    int n, {
    String dono = _dona,
    String? edicao,
    String? isbn,
    DateTime? aberto,
    bool lendo = true,
  }) => UserBooksDao(db).upsert(
    livroTeste(n, dono: dono).copyWith(
      editionId: Nullable(edicao),
      isbn13: Nullable(isbn),
      lastOpenedAt: Nullable(aberto),
      status: lendo ? null : ShelfStatus.wantToRead,
    ),
  );

  group('os clubes e o ticket (R3)', () {
    test('o JSON do my_clubs vira os cartões, e o ticket que a Início lê de volta com os números do mundo', () async {
      await livro(1, edicao: _domEdicao, aberto: agora);
      await cache.saveClubs(_dona, jsonEncode(fixture('my_clubs')));
      expect((await cache.clubs(_dona)).single.name, 'Leitoras de Capitu');

      final t = await CachedClubTicketSource(
        () async => db,
        utcOffsetAt: (_) => Duration.zero,
      ).current(_dona);
      expect(
        (t!.namePrefix, t.nameHighlight, t.untilChapter, t.participantsCount),
        ('Leitoras de', 'Capitu', 50, 11),
      );
      expect(
        (t.groupProgress, t.userProgress, t.unreadMessages),
        (0.5373, 0.62, 3),
      );
    });

    test(
      'o herói lê o livro do clube de encontro mais longe: o ticket é dele',
      () async {
        await livro(
          1,
          edicao: _edOutro,
          aberto: agora.subtract(const Duration(days: 2)),
        );
        await livro(
          2,
          isbn: '9788535902778',
          aberto: agora,
        ); // o herói: o Dom Casmurro por ISBN
        await cache.saveClubs(
          _dona,
          jsonEncode([
            _outroClube(
              id: 'perto',
              name: 'Clube Perto',
              edition: _edOutro,
              meeting: '2026-10-10T23:00:00Z',
            ),
            _outroClube(
              id: 'longe',
              name: 'Clube Longe',
              isbns: const ['9788535902778'],
              meeting: '2026-10-20T23:00:00Z',
            ),
          ]),
        );
        expect(
          (jsonDecode((await chave(ClubsCache.ticketKey(_dona)))!)!
              as Map)['id'],
          'longe',
        );
        expect(await cache.readingBook(_dona), (
          editionId: null,
          isbn13: '9788535902778',
        ));
      },
    );

    test('sem encontro marcado em nenhum, a chave do ticket sai (D-226); sem clube também', () async {
      await cache.saveClubs(_dona, jsonEncode(fixture('my_clubs')));
      expect(await chave(ClubsCache.ticketKey(_dona)), isNotNull);
      await cache.saveClubs(
        _dona,
        jsonEncode([_outroClube(id: 'sem', name: 'Sem data')]),
      );
      expect(await chave(ClubsCache.ticketKey(_dona)), isNull);
      await cache.saveClubs(_dona, '[]');
      expect(await chave(ClubsCache.ticketKey(_dona)), isNull);
      expect(await cache.clubs(_dona), isEmpty);
    });

    test('trocar de conta não mostra o clube da outra (D-68)', () async {
      await cache.saveClubs(_dona, jsonEncode(fixture('my_clubs')));
      expect(await cache.clubs(_outra), isEmpty);
      expect(
        await CachedClubTicketSource(() async => db).current(_outra),
        isNull,
      );
    });

    test('o herói: o livro em leitura com a atividade mais recente, só da conta, sem os apagados', () async {
      expect(await cache.readingBook(_dona), isNull);
      await livro(1, edicao: _edVelho, aberto: DateTime.utc(2026, 9, 1));
      await livro(2, edicao: _edNovo, aberto: DateTime.utc(2026, 10, 1));
      await livro(
        3,
        edicao: _edQuero,
        aberto: DateTime.utc(2026, 10, 8),
        lendo: false,
      );
      await livro(
        4,
        edicao: _edDaOutra,
        aberto: DateTime.utc(2026, 10, 9),
        dono: _outra,
      );
      expect((await cache.readingBook(_dona))!.editionId, _edNovo);
      expect((await cache.book(_dona, idTeste(1)))!.editionId, _edVelho);
      expect(
        await cache.book(_dona, idTeste(4)),
        isNull,
        reason: 'o livro é de outra conta',
      );
    });

    test('lixo no cache não derruba: nenhum clube', () async {
      await db
          .into(db.socialCache)
          .insert(
            SocialCacheCompanion.insert(
              key: ClubsCache.clubsKey(_dona),
              payload: '{"x": 1}',
              updatedAt: agora,
            ),
          );
      expect(await cache.clubs(_dona), isEmpty);
      await cache.refreshTicket(_dona);
      expect(await chave(ClubsCache.ticketKey(_dona)), isNull);
    });

    test('a lista acompanha as mudanças', () async {
      final vistos = <int>[];
      final sub = cache.watchClubs(_dona).listen((c) => vistos.add(c.length));
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await cache.saveClubs(_dona, jsonEncode(fixture('my_clubs')));
      await pumpEventQueue();
      expect(vistos, [0, 1]);
    });
  });

  group('o chip da 25', () {
    const a = PostSummary(
      id: 'p1',
      clubId: 'c1',
      clubName: 'Leitoras de Capitu',
      replies: 3,
    );
    const b = PostSummary(
      id: 'p2',
      clubId: 'c1',
      clubName: 'Leitoras de Capitu',
      replies: 1,
    );

    test('guardar o que voltou; o que foi pedido e não voltou sai; compartilhar acrescenta', () async {
      await cache.savePosts(_dona, ['p1', 'p2'], [a, b]);
      expect((await cache.posts(_dona)).values, [a, b]);
      await cache.savePosts(
        _dona,
        ['p1', 'p2'],
        [
          const PostSummary(
            id: 'p1',
            clubId: 'c1',
            clubName: 'Leitoras de Capitu',
            replies: 4,
          ),
        ],
      );
      expect((await cache.posts(_dona)).map((k, v) => MapEntry(k, v.replies)), {
        'p1': 4,
      });
      await cache.addPost(_dona, b);
      expect((await cache.posts(_dona)).keys, ['p1', 'p2']);
      expect(await cache.posts(_outra), isEmpty);
    });

    test('a 25 acompanha', () async {
      final vistos = <Set<String>>[];
      final sub = cache
          .watchPosts(_dona)
          .listen((m) => vistos.add(m.keys.toSet()));
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await cache.addPost(_dona, a);
      await pumpEventQueue();
      expect(vistos, [
        <String>{},
        {'p1'},
      ]);
    });
  });

  test('o sininho: a contagem por conta; lixo ou negativo vira 0', () async {
    expect(await cache.notifications(_dona), 0);
    await cache.saveNotifications(_dona, 3);
    expect(
      (await cache.notifications(_dona), await cache.notifications(_outra)),
      (3, 0),
    );
    await cache.saveNotifications(_dona, -2);
    expect(await cache.notifications(_dona), 0);
    final vistos = <int>[];
    final sub = cache.watchNotifications(_dona).listen(vistos.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    await cache.saveNotifications(_dona, 5);
    await pumpEventQueue();
    expect(vistos, [0, 5]);
  });

  test('o que já foi publicado: a hora dos números (R10) e a posição em cada clube (R9)', () async {
    expect(await cache.statsPublishedAt(_dona), isNull);
    await cache.saveStatsPublishedAt(_dona, DateTime.utc(2026, 10, 8, 9));
    expect(await cache.statsPublishedAt(_dona), DateTime.utc(2026, 10, 8, 9));

    expect(await cache.publishedProgress(_dona, 'c1'), isNull);
    await cache.savePublishedProgress(_dona, 'c1', (ratio: 0.62, chapter: 32));
    await cache.savePublishedProgress(_dona, 'c2', (ratio: 0.1, chapter: null));
    expect(await cache.publishedProgress(_dona, 'c1'), (
      ratio: 0.62,
      chapter: 32,
    ));
    expect(await cache.publishedProgress(_dona, 'c2'), (
      ratio: 0.1,
      chapter: null,
    ));
    expect(await cache.publishedProgress(_outra, 'c1'), isNull);

    await db
        .into(db.socialCache)
        .insertOnConflictUpdate(
          SocialCacheCompanion.insert(
            key: ClubsCache.statsKey(_dona),
            payload: '42',
            updatedAt: agora,
          ),
        );
    expect(await cache.statsPublishedAt(_dona), isNull);
  });
}

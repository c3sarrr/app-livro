// G08.2 — o ticket do Clube lê o cache do social no aparelho (D-80): vazio até a G21 gravar; conteúdo
// inválido não derruba a Início.
import 'dart:convert';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/features/home/data/cached_club_ticket_source.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const _dono = '6f1c2a3b-4d5e-4f60-8a7b-9c0d1e2f3a4b';

Map<String, Object?> _payload() => {
  'id': 'c1',
  'name_prefix': 'Leitoras de',
  'name_highlight': 'Capitu',
  'book': {
    'id': 'b1',
    'title': 'Dom Casmurro',
    'author': 'Machado de Assis',
    'cover_ref': 'ol:8231432',
    'isbn13': '9788535902778',
  },
  'until_chapter': 50,
  'participants': [
    {'initial': 'A', 'color': '#B6ACE4'},
    {'initial': 'J', 'color': '#ABCF82'},
  ],
  'participants_count': 11,
  'group_progress': 0.54,
  'user_progress': 0.62,
  'user_initial': 'M',
  'unread_messages': 3,
  'next_meeting': '2026-09-24T23:00:00.000000Z',
};

void main() {
  late AppDatabase db;
  late CachedClubTicketSource fonte;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    fonte = CachedClubTicketSource(
      () async => db,
      utcOffsetAt: (_) => const Duration(hours: -3),
    );
  });
  tearDown(() => db.close());

  Future<void> gravar(String dono, Object payload) => db
      .into(db.socialCache)
      .insertOnConflictUpdate(
        SocialCacheCompanion.insert(
          key: CachedClubTicketSource.keyFor(dono),
          payload: payload is String ? payload : jsonEncode(payload),
          updatedAt: DateTime.utc(2026, 10, 5),
        ),
      );

  test('sem cache: sem clube (até a G21)', () async {
    expect(await fonte.current(_dono), isNull);
  });

  test('o cache do dono vira o ticket (encontro na hora local)', () async {
    await gravar(_dono, _payload());
    await gravar('outro', {..._payload(), 'id': 'c2'});
    final c = (await fonte.current(_dono))!;
    expect(c.id, 'c1');
    expect([c.namePrefix, c.nameHighlight], ['Leitoras de', 'Capitu']);
    expect(
      [c.book.id, c.book.title, c.book.author],
      ['b1', 'Dom Casmurro', 'Machado de Assis'],
    );
    expect(
      c.book.cover,
      const PhotoCover(ref: 'ol:8231432', isbn13: '9788535902778'),
    );
    expect(c.untilChapter, 50);
    expect(c.shownParticipants.map((p) => (p.initial, p.color.toARGB32())), [
      ('A', 0xFFB6ACE4),
      ('J', 0xFFABCF82),
    ]);
    expect(
      [c.participantsCount, c.groupProgress, c.userProgress],
      [11, 0.54, 0.62],
    );
    expect([c.userInitial, c.unreadMessages], ['M', 3]);
    expect(c.nextMeeting, DateTime(2026, 9, 24, 20));
  });

  test('conteúdo inválido não derruba a Início: sem clube', () async {
    for (final ruim in <Object>[
      {..._payload()}..remove('id'),
      {..._payload(), 'group_progress': 'muito'},
      {..._payload(), 'next_meeting': 'ontem'},
      {..._payload(), 'participants': 'A,J'},
      [1, 2, 3],
      '"texto"',
    ]) {
      await gravar(_dono, ruim);
      expect(await fonte.current(_dono), isNull, reason: '$ruim');
    }
  });

  test('a chave é por dono (D-68)', () {
    expect(CachedClubTicketSource.keyFor('x'), 'inicio.clube:x');
  });
}

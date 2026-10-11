// G21.4 — as regras do clube no aparelho (docs/progresso/G21.md §4): R1 livro ↔ clube, R2 o capítulo do clube pela
// numeração do livro (com o Dom Casmurro real), R3 o clube do ticket, R7 a semana aberta, R8 o spoiler, R9 e R10 o
// que publicar, e o JSON do ticket que o CachedClubTicketSource (G08) lê de volta.
import 'dart:convert';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/features/clubs/domain/club_models.dart';
import 'package:app_leitura/features/clubs/domain/club_rules.dart';
import 'package:app_leitura/features/home/data/cached_club_ticket_source.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/application/toc_view.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/reader_harness.dart';
import 'club_models_test.dart' show fixture;

ClubCard clube({
  String id = 'c1',
  String name = 'Clube',
  String? highlight,
  String? edition,
  List<String> isbns = const [],
  DateTime? meeting,
  DateTime? activity,
  int to = 50,
}) => ClubCard(
  id: id,
  name: name,
  nameHighlight: highlight,
  color: '#B6ACE4',
  role: 'member',
  privacy: 'invite',
  spoilerProtection: true,
  membersCount: 4,
  participants: const [ClubFace(initial: 'A', color: '#B6ACE4')],
  unread: 0,
  me: const ClubFace(initial: 'M', color: '#FED170'),
  reading: ClubReading(
    id: 'r-$id',
    editionId: edition,
    isbns: isbns,
    weeks: 6,
    title: 'Livro',
    author: 'Autora',
    currentWeek: ClubWeekRange(no: 2, from: 26, to: to),
  ),
  nextMeeting: meeting == null
      ? null
      : MeetingSummary(
          id: 'm-$id',
          startsAt: meeting,
          timezone: 'America/Sao_Paulo',
          counts: const RsvpCounts(going: 1, maybe: 0, notGoing: 0),
        ),
  lastActivityAt: activity,
);

void main() {
  final dom = clubCardsFromJson(fixture('my_clubs')).single;

  group('R1 livro ↔ clube (D-213)', () {
    test('a mesma edição, a mesma obra (um ISBN das edições dela) ou o mesmo ISBN-13', () {
      final r = dom.reading!;
      expect(
        bookMatchesReading((editionId: r.editionId, isbn13: null), r),
        isTrue,
      );
      expect(
        bookMatchesReading((editionId: 'outra', isbn13: '9788508140912'), r),
        isTrue,
        reason: 'outra edição da obra',
      );
      expect(
        bookMatchesReading((editionId: null, isbn13: '9788535902778'), r),
        isTrue,
      );
      expect(
        bookMatchesReading((editionId: 'outra', isbn13: '9780000000000'), r),
        isFalse,
      );
      expect(
        bookMatchesReading((editionId: null, isbn13: null), r),
        isFalse,
        reason: 'livro sem edição nem ISBN não casa',
      );
    });
  });

  group('R2 o capítulo do clube pela numeração do livro (D-214)', () {
    test(
      'com o Dom Casmurro real: o cap. 50 do clube é o L; o XXXII é o 32',
      () {
        final index = indexEpubFile(domCasmurroEpub, 'a' * 64);
        final numerals = chapterNumerals(index);
        expect(clubChapterLabel(numerals, 50), 'L');
        expect(clubChapterLabel(numerals, 148), 'CXLVIII');
        final xxxii = numerals.indexOf('XXXII');
        expect(
          clubChapterOf(
            numerals,
            chapterIndex: xxxii,
            chaptersTotal: index.chaptersTotal,
          ),
          32,
        );
      },
    );

    test('sem numeração: a folha, com o rótulo do clube ou o número', () {
      const semNumero = <String?>[null, null, null];
      expect(clubChapterLabel(semNumero, 2, clubLabel: 'Parte 2'), 'Parte 2');
      expect(clubChapterLabel(semNumero, 2), '2');
      expect(clubChapterOf(semNumero, chapterIndex: 1, chaptersTotal: 3), 2);
      expect(
        clubChapterOf(const ['I', 'II'], chapterIndex: null, chaptersTotal: 2),
        isNull,
      );
    });
  });

  group('R3 o clube do ticket (D-215, D-226)', () {
    final t0 = DateTime.utc(2026, 9, 20, 12);
    final perto = clube(
      id: 'perto',
      name: 'Perto',
      meeting: t0.add(const Duration(days: 1)),
    );
    final longe = clube(
      id: 'longe',
      name: 'Longe',
      edition: 'e-dom',
      meeting: t0.add(const Duration(days: 9)),
    );
    final semEncontro = clube(id: 'sem', name: 'Sem', edition: 'e-dom');

    test('o que lê o livro em leitura, mesmo com o encontro mais longe', () {
      expect(
        ticketClub(
          [perto, longe, semEncontro],
          (editionId: 'e-dom', isbn13: null),
        )!.id,
        'longe',
      );
    });
    test('nenhum lê o livro: o do encontro mais próximo', () {
      expect(
        ticketClub([longe, perto], (editionId: 'outro', isbn13: null))!.id,
        'perto',
      );
      expect(ticketClub([longe, perto], null)!.id, 'perto');
    });
    test('empate no encontro: a atividade mais recente', () {
      final a = clube(id: 'a', name: 'A', meeting: t0, activity: t0);
      final b = clube(
        id: 'b',
        name: 'B',
        meeting: t0,
        activity: t0.add(const Duration(hours: 1)),
      );
      expect(ticketClub([a, b], null)!.id, 'b');
    });
    test('sem encontro marcado em nenhum: o ticket some', () {
      expect(
        ticketClub([semEncontro], (editionId: 'e-dom', isbn13: null)),
        isNull,
      );
      expect(ticketClub(const [], null), isNull);
    });
  });

  test('R7 a semana aberta: as que eu já alcancei e a atual; a que está entre mim e a atual, fechada', () {
    const w1 = ClubWeekRange(no: 1, from: 1, to: 25);
    const w2 = ClubWeekRange(no: 2, from: 26, to: 50);
    const w3 = ClubWeekRange(no: 3, from: 51, to: 75);
    expect(weekOpenFor(w3, currentWeek: 2, myChapter: 32), isFalse);
    expect(weekOpenFor(w3, currentWeek: 2, myChapter: 51), isTrue);
    expect(weekOpenFor(w3, currentWeek: 3), isTrue);
    // atrasada: no cap. 10 (semana 1) com a semana 3 em curso — a 2 é spoiler
    expect(weekOpenFor(w1, currentWeek: 3, myChapter: 10), isTrue);
    expect(weekOpenFor(w2, currentWeek: 3, myChapter: 10), isFalse);
    expect(
      weekOpenFor(w2, currentWeek: 3),
      isFalse,
      reason: 'sem progresso, só a atual',
    );
  });

  test('R8 o spoiler: à frente de mim e com a proteção ligada', () {
    const rafa = Spoiler(ratio: 0.78, page: 201);
    expect(isAhead(rafa, 0.62, protection: true), isTrue);
    expect(isAhead(rafa, 0.80, protection: true), isFalse);
    expect(isAhead(rafa, 0.62, protection: false), isFalse);
    expect(isAhead(null, 0.1, protection: true), isFalse);
  });

  test(
    'R9 publica só o que mudou; R10 os números uma vez por dia; o % do grupo',
    () {
      expect(shouldPublishProgress(null, (ratio: 0.62, chapter: 32)), isTrue);
      expect(
        shouldPublishProgress(
          (ratio: 0.62, chapter: 32),
          (ratio: 0.62, chapter: 32),
        ),
        isFalse,
      );
      expect(
        shouldPublishProgress(
          (ratio: 0.62, chapter: 32),
          (ratio: 0.63, chapter: 32),
        ),
        isTrue,
      );
      expect(
        shouldPublishProgress(
          (ratio: 0.62, chapter: 32),
          (ratio: 0.62, chapter: 33),
        ),
        isTrue,
      );
      final t = DateTime.utc(2026, 10, 9, 9);
      expect(statsDue(null, t), isTrue);
      expect(statsDue(t.subtract(const Duration(hours: 23)), t), isFalse);
      expect(statsDue(t.subtract(const Duration(hours: 24)), t), isTrue);
      expect((percentText(0.5373), percentText(0.62)), ('54%', '62%'));
    },
  );

  test('o nome do ticket em duas partes; sem destaque, a última palavra', () {
    expect(ticketName(dom), (prefix: 'Leitoras de', highlight: 'Capitu'));
    expect(ticketName(clube(name: 'Poesia de domingo')), (
      prefix: 'Poesia de',
      highlight: 'domingo',
    ));
    expect(ticketName(clube(name: 'Sci-fi')), (
      prefix: '',
      highlight: 'Sci-fi',
    ));
  });

  test('o JSON do ticket é lido de volta pelo CachedClubTicketSource com os números do mundo', () async {
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    addTearDown(db.close);
    await db
        .into(db.socialCache)
        .insert(
          SocialCacheCompanion.insert(
            key: CachedClubTicketSource.keyFor('dona'),
            payload: jsonEncode(ticketJson(dom)),
            updatedAt: DateTime.utc(2026, 10, 9),
          ),
        );
    final t = await CachedClubTicketSource(
      () async => db,
      utcOffsetAt: (_) => Duration.zero,
    ).current('dona');
    expect(t, isNotNull);
    expect(
      (t!.namePrefix, t.nameHighlight, t.untilChapter, t.participantsCount),
      ('Leitoras de', 'Capitu', 50, 11),
    );
    expect(
      (t.groupProgress, t.userProgress, t.userInitial, t.unreadMessages),
      (0.5373, 0.62, 'M', 3),
    );
    expect(t.shownParticipants.map((p) => p.initial).join(), 'AJL');
    expect(t.book.title, 'Dom Casmurro');
    expect(t.nextMeeting, isNotNull);
  });
}

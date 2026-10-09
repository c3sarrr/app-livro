// G21.3 — os resumos do clube como o servidor devolve: o JSON real do mundo das pranchas (capturado do banco local
// por tools/supabase/capturar_mundo_clube.sql, como a Marina) vira os modelos com os números das pranchas.
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/features/clubs/domain/club_models.dart';
import 'package:flutter_test/flutter_test.dart';

Object? fixture(String nome) =>
    jsonDecode(File('test/fixtures/clube/$nome.json').readAsStringSync());

Json fixtureMap(String nome) => (fixture(nome)! as Map).cast<String, Object?>();

void main() {
  test(
    'my_clubs: as Leitoras de Capitu como o ticket, a faixa e a folha precisam',
    () {
      final clubs = clubCardsFromJson(fixture('my_clubs'));
      expect(clubs, hasLength(1));
      final c = clubs.single;
      expect(
        (c.name, c.nameHighlight, c.category),
        ('Leitoras de Capitu', 'Capitu', 'Clássicos brasileiros'),
      );
      expect((c.membersCount, c.unread, c.role), (11, 3, 'member'));
      expect(c.participants.map((p) => '${p.initial}${p.color}'), [
        'A#B6ACE4',
        'J#ABCF82',
        'L#FFC1C6',
      ]);
      expect((c.me!.initial, c.me!.color), ('M', '#FED170'));
      expect((c.myProgress, c.groupProgress), (0.62, 0.5373));
      final r = c.reading!;
      expect(
        (r.title, r.author, r.pages, r.weeks),
        ('Dom Casmurro', 'Machado de Assis', 256, 6),
      );
      expect(r.isbns, ['9788508140912', '9788535902778']);
      expect(
        (r.currentWeek!.no, r.currentWeek!.from, r.currentWeek!.to),
        (2, 26, 50),
      );
      final m = c.nextMeeting!;
      expect((m.weekNo, m.weeks, m.mode, m.mine), (2, 6, 'online', Rsvp.going));
      expect(m.counts, const RsvpCounts(going: 8, maybe: 3, notGoing: 0));
      expect(m.endsAt!.difference(m.startsAt), const Duration(minutes: 90));
      expect(c.lastActivityAt, isNotNull);
    },
  );

  test(
    'club_overview (04): as semanas, onde cada uma está e o grifo da Ana',
    () {
      final o = ClubOverview.fromJson(fixtureMap('club_overview'));
      expect(
        (o.club.membersCount, o.club.progressColors, o.unread),
        (11, 'club', 3),
      );
      expect(o.weeks.map((w) => (w.range.no, w.comments, w.fresh)).take(2), [
        (1, 48, 0),
        (2, 15, 3),
      ]);
      final q = o.weeks[1].question!;
      expect(
        (q.body, q.replies, q.fresh, q.author.name, q.author.host),
        ('Bentinho é um narrador confiável?', 12, 3, 'Ana', true),
      );
      expect(o.weeks[2].question, isNull);
      expect(o.members.map((m) => m.initial).join(), 'RJALMBCDFGH');
      expect(o.members.firstWhere((m) => m.me).ratio, 0.62);
      final s = o.shared.first;
      expect(
        (
          s.author.name,
          s.samePassage,
          s.likes,
          s.replies,
          s.chapter,
          s.refPage,
        ),
        ('Ana', 7, 9, 4, 25, 121),
      );
      expect(s.spoiler!.page, 121);
    },
  );

  test('week_thread (31): a página de 3 e o cursor da próxima', () {
    final t = WeekThread.fromJson(fixtureMap('week_thread'));
    expect(t.week!.no, 2);
    expect((t.question!.replies, t.question!.fresh), (12, 3));
    expect(t.replies.map((r) => (r.author.initial, r.likes)), [
      ('J', 9),
      ('A', 6),
      ('L', 4),
    ]);
    expect(t.replies.first.replies, 2);
    expect(t.replies[1].quote!.page, 121);
    expect(t.nextCursor, containsPair('likes', 4));
  });

  test('meeting_overview (70): quem vai, na ordem de quem está mais à frente, e as perguntas da Ana', () {
    final m = MeetingOverview.fromJson(fixtureMap('meeting_overview'));
    expect(
      (m.clubName, m.bookTitle, m.host.name, m.mine),
      ('Leitoras de Capitu', 'Dom Casmurro', 'Ana', Rsvp.going),
    );
    expect(
      m.people[Rsvp.going]!.map((p) => p.person.initial).join(),
      'RJAMBCFG',
    );
    expect(m.people[Rsvp.maybe]!.map((p) => p.person.initial).join(), 'LDH');
    expect(m.people[Rsvp.notGoing], isEmpty);
    expect(m.people[Rsvp.going]!.first.ratio, 0.78);
    expect(m.questions.map((q) => q.position), [1, 2, 3, 4]);
    expect(m.meeting.agenda!.to, 50);
    expect(m.myNote, isNull);
  });

  test('club_members_overview (32) e club_post_summaries (o chip da 25)', () {
    final g = ClubMembers.fromJson(fixtureMap('club_members_overview'));
    expect(g.members.map((m) => m.person.initial).join(), 'RJALMBCDFGH');
    expect((g.members[3].rsvp, g.members.first.ratio), (Rsvp.maybe, 0.78));
    final chips = [
      for (final s in (fixture('club_post_summaries')! as List<Object?>))
        PostSummary.fromJson((s! as Map).cast<String, Object?>()),
    ];
    expect(chips.map((c) => (c.clubName, c.replies)), [
      ('Leitoras de Capitu', 4),
      ('Leitoras de Capitu', 3),
    ]);
    expect(PostSummary.fromJson(chips.first.toJson()), chips.first);
  });

  test(
    'conta excluída vira só "deleted"; spoiler e citação ausentes viram null',
    () {
      final p = Person.fromJson(const {'deleted': true});
      expect((p.deleted, p.name, p.host, p.me), (true, null, false, false));
      expect(Spoiler.fromJson(null), isNull);
      expect(QuoteRef.fromJson(null), isNull);
      expect(Rsvp.of(null), isNull);
    },
  );
}

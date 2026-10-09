// G21.3 — os resumos do clube como o servidor devolve (docs/progresso/G21.md §1). O formato real está em
// test/fixtures/clube/*.json (capturado do banco local com o mundo das pranchas). Só leitura: o ticket, a faixa e o
// chip usam o [ClubCard] e o [PostSummary]; as telas do clube (Trilha T) montam a partir do resto.
import 'package:flutter/foundation.dart' show immutable;

typedef Json = Map<String, Object?>;

Json _map(Object? o) => (o! as Map).cast<String, Object?>();
Json? _mapOrNull(Object? o) => o == null ? null : _map(o);
List<Json> _list(Object? o) => [
  for (final e in (o as List<Object?>?) ?? const <Object?>[]) _map(e),
];
double? _ratio(Object? o) => (o as num?)?.toDouble();
int _int(Object? o) => (o! as num).toInt();
int? _intOrNull(Object? o) => (o as num?)?.toInt();
DateTime _instant(Object? o) => DateTime.parse(o! as String).toUtc();
DateTime? _instantOrNull(Object? o) => o == null ? null : _instant(o);

/// A presença no encontro.
enum Rsvp {
  going('vou'),
  maybe('talvez'),
  notGoing('nao_vou');

  const Rsvp(this.code);
  final String code;

  static Rsvp? of(Object? code) =>
      code == null ? null : values.firstWhere((r) => r.code == code);
}

/// Quem vê o recado: "Só a Ana" ou "O clube todo".
enum NoteVisibility {
  host('host'),
  club('club');

  const NoteVisibility(this.code);
  final String code;

  static NoteVisibility of(Object? code) =>
      values.firstWhere((v) => v.code == code);
}

/// O estado de uma pergunta (prancha 73).
enum QuestionStatus {
  open('open'),
  discussed('discussed'),
  postponed('postponed');

  const QuestionStatus(this.code);
  final String code;

  static QuestionStatus of(Object? code) =>
      values.firstWhere((s) => s.code == code);
}

/// Um avatar: a inicial e a cor.
@immutable
final class ClubFace {
  const ClubFace({required this.initial, required this.color});

  factory ClubFace.fromJson(Json j) =>
      ClubFace(initial: j['initial']! as String, color: j['color']! as String);

  final String initial;
  final String color;

  @override
  bool operator ==(Object other) =>
      other is ClubFace && other.initial == initial && other.color == color;

  @override
  int get hashCode => Object.hash(initial, color);
}

/// Uma semana da leitura: o intervalo no cap. do clube (D-214) e os rótulos do clube (livro sem numeração).
@immutable
final class ClubWeekRange {
  const ClubWeekRange({
    required this.no,
    required this.from,
    required this.to,
    this.fromLabel,
    this.toLabel,
  });

  factory ClubWeekRange.fromJson(Json j) => ClubWeekRange(
    no: _int(j['no']),
    from: _int(j['from']),
    to: _int(j['to']),
    fromLabel: j['from_label'] as String?,
    toLabel: j['to_label'] as String?,
  );

  final int no;
  final int from;
  final int to;
  final String? fromLabel;
  final String? toLabel;
}

/// "8 vão · 3 talvez".
@immutable
final class RsvpCounts {
  const RsvpCounts({
    required this.going,
    required this.maybe,
    required this.notGoing,
  });

  factory RsvpCounts.fromJson(Json j) => RsvpCounts(
    going: _int(j['vou']),
    maybe: _int(j['talvez']),
    notGoing: _int(j['nao_vou']),
  );

  final int going;
  final int maybe;
  final int notGoing;

  @override
  bool operator ==(Object other) =>
      other is RsvpCounts &&
      other.going == going &&
      other.maybe == maybe &&
      other.notGoing == notGoing;

  @override
  int get hashCode => Object.hash(going, maybe, notGoing);
}

/// Um encontro: quando, o modo, a pauta (a semana), as contagens e a minha presença.
@immutable
final class MeetingSummary {
  const MeetingSummary({
    required this.id,
    required this.startsAt,
    required this.timezone,
    required this.counts,
    this.endsAt,
    this.mode,
    this.location,
    this.weekNo,
    this.weeks,
    this.agenda,
    this.mine,
  });

  factory MeetingSummary.fromJson(Json j) => MeetingSummary(
    id: j['id']! as String,
    startsAt: _instant(j['starts_at']),
    endsAt: _instantOrNull(j['ends_at']),
    mode: j['mode'] as String?,
    timezone: j['timezone']! as String,
    location: j['location'] as String?,
    weekNo: _intOrNull(j['week_no']),
    weeks: _intOrNull(j['weeks']),
    agenda: switch (_mapOrNull(j['agenda'])) {
      final a? => ClubWeekRange.fromJson(a),
      null => null,
    },
    counts: RsvpCounts.fromJson(_map(j['counts'])),
    mine: Rsvp.of(j['mine']),
  );

  final String id;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? mode;
  final String timezone;
  final String? location;
  final int? weekNo;
  final int? weeks;
  final ClubWeekRange? agenda;
  final RsvpCounts counts;
  final Rsvp? mine;
}

/// O livro da leitura atual (D-213: a obra, a edição e os ISBN-13 das edições da obra) e a semana atual (R4).
@immutable
final class ClubReading {
  const ClubReading({
    required this.id,
    required this.isbns,
    required this.weeks,
    this.workId,
    this.editionId,
    this.title,
    this.author,
    this.coverRef,
    this.isbn13,
    this.pages,
    this.currentWeek,
  });

  factory ClubReading.fromJson(Json j) => ClubReading(
    id: j['id']! as String,
    workId: j['work_id'] as String?,
    editionId: j['edition_id'] as String?,
    isbns: [
      for (final i in (j['isbns'] as List<Object?>?) ?? const <Object?>[])
        i! as String,
    ],
    title: j['title'] as String?,
    author: j['author'] as String?,
    coverRef: j['cover_ref'] as String?,
    isbn13: j['isbn13'] as String?,
    pages: _intOrNull(j['pages']),
    weeks: _int(j['weeks']),
    currentWeek: switch (_mapOrNull(j['current_week'])) {
      final w? => ClubWeekRange.fromJson(w),
      null => null,
    },
  );

  final String id;
  final String? workId;
  final String? editionId;
  final List<String> isbns;
  final String? title;
  final String? author;
  final String? coverRef;
  final String? isbn13;
  final int? pages;
  final int weeks;
  final ClubWeekRange? currentWeek;
}

/// Um clube meu (`my_clubs`): o ticket da Início, a faixa do sumário e a folha "Compartilhar em…".
@immutable
final class ClubCard {
  const ClubCard({
    required this.id,
    required this.name,
    required this.color,
    required this.role,
    required this.privacy,
    required this.spoilerProtection,
    required this.membersCount,
    required this.participants,
    required this.unread,
    this.nameHighlight,
    this.category,
    this.me,
    this.reading,
    this.nextMeeting,
    this.myProgress,
    this.groupProgress,
    this.lastActivityAt,
  });

  factory ClubCard.fromJson(Json j) => ClubCard(
    id: j['id']! as String,
    name: j['name']! as String,
    nameHighlight: j['name_highlight'] as String?,
    category: j['category'] as String?,
    color: j['color']! as String,
    role: j['role']! as String,
    privacy: j['privacy']! as String,
    spoilerProtection: j['spoiler_protection']! as bool,
    membersCount: _int(j['members_count']),
    participants: [
      for (final p in _list(j['participants'])) ClubFace.fromJson(p),
    ],
    me: switch (_mapOrNull(j['me'])) {
      final m? => ClubFace.fromJson(m),
      null => null,
    },
    reading: switch (_mapOrNull(j['reading'])) {
      final r? => ClubReading.fromJson(r),
      null => null,
    },
    nextMeeting: switch (_mapOrNull(j['next_meeting'])) {
      final m? => MeetingSummary.fromJson(m),
      null => null,
    },
    myProgress: _ratio(j['my_progress']),
    groupProgress: _ratio(j['group_progress']),
    unread: _int(j['unread']),
    lastActivityAt: _instantOrNull(j['last_activity_at']),
  );

  final String id;
  final String name;
  final String? nameHighlight;
  final String? category;
  final String color;

  /// `owner` (a anfitriã), `moderator` ou `member`.
  final String role;
  final String privacy;
  final bool spoilerProtection;
  final int membersCount;

  /// As 3 primeiras sem mim: a anfitriã e depois a ordem de chegada.
  final List<ClubFace> participants;
  final ClubFace? me;
  final ClubReading? reading;
  final MeetingSummary? nextMeeting;
  final double? myProgress;
  final double? groupProgress;
  final int unread;
  final DateTime? lastActivityAt;
}

/// A lista de `my_clubs`.
List<ClubCard> clubCardsFromJson(Object? json) => [
  for (final c in _list(json)) ClubCard.fromJson(c),
];

/// Uma leitora nos resumos. Conta excluída: só [deleted].
@immutable
final class Person {
  const Person({
    required this.host,
    required this.me,
    this.id,
    this.name,
    this.initial,
    this.color,
    this.deleted = false,
  });

  factory Person.fromJson(Json j) => j['deleted'] == true
      ? const Person(host: false, me: false, deleted: true)
      : Person(
          id: j['id'] as String?,
          name: j['name'] as String?,
          initial: j['initial'] as String?,
          color: j['color'] as String?,
          host: j['host'] == true,
          me: j['me'] == true,
        );

  final String? id;
  final String? name;
  final String? initial;
  final String? color;

  /// A anfitriã ("anfitriã" nas pranchas).
  final bool host;
  final bool me;
  final bool deleted;
}

/// A posição de quem escreveu (D-218): borrado para quem está antes.
@immutable
final class Spoiler {
  const Spoiler({required this.ratio, this.page});

  static Spoiler? fromJson(Object? o) => switch (_mapOrNull(o)) {
    final j? => Spoiler(
      ratio: _ratio(j['ratio'])!,
      page: _intOrNull(j['page']),
    ),
    null => null,
  };

  final double ratio;

  /// "Fala da pág. 201".
  final int? page;
}

/// O trecho citado numa resposta.
@immutable
final class QuoteRef {
  const QuoteRef({required this.text, this.color, this.page});

  static QuoteRef? fromJson(Object? o) => switch (_mapOrNull(o)) {
    final j? => QuoteRef(
      text: j['text']! as String,
      color: j['color'] as String?,
      page: _intOrNull(j['page']),
    ),
    null => null,
  };

  final String text;
  final String? color;
  final int? page;
}

/// Uma pergunta (a da semana, as sugeridas, as do encontro).
@immutable
final class QuestionSummary {
  const QuestionSummary({
    required this.id,
    required this.body,
    required this.status,
    required this.author,
    required this.likes,
    required this.replies,
    required this.fresh,
    this.position,
    this.hostNote,
    this.weekNo,
  });

  factory QuestionSummary.fromJson(Json j) => QuestionSummary(
    id: j['id']! as String,
    body: j['body']! as String,
    position: _intOrNull(j['position']),
    status: QuestionStatus.of(j['status']),
    hostNote: j['host_note'] as String?,
    weekNo: _intOrNull(j['week_no']),
    author: Person.fromJson(_map(j['author'])),
    likes: _int(j['likes']),
    replies: _int(j['replies']),
    fresh: _int(j['new']),
  );

  final String id;
  final String body;
  final int? position;
  final QuestionStatus status;
  final String? hostNote;
  final int? weekNo;
  final Person author;
  final int likes;

  /// As respostas que eu vejo (R12).
  final int replies;

  /// As novas desde o meu lido ("12 respostas · 3 novas").
  final int fresh;
}

/// Uma semana na 04: o intervalo, os comentários, os novos e a pergunta da semana.
@immutable
final class WeekCard {
  const WeekCard({
    required this.range,
    required this.comments,
    required this.fresh,
    this.question,
  });

  factory WeekCard.fromJson(Json j) => WeekCard(
    range: ClubWeekRange.fromJson(j),
    comments: _int(j['comments']),
    fresh: _int(j['new']),
    question: switch (_mapOrNull(j['question'])) {
      final q? => QuestionSummary.fromJson(q),
      null => null,
    },
  );

  final ClubWeekRange range;
  final int comments;
  final int fresh;
  final QuestionSummary? question;
}

/// Um grifo compartilhado no feed da 04 ("Ana grifou em Dom Casmurro · 7 leitoras grifaram ♥9 💬4").
@immutable
final class SharedHighlight {
  const SharedHighlight({
    required this.id,
    required this.author,
    required this.quoteText,
    required this.chapter,
    required this.createdAt,
    required this.samePassage,
    required this.likes,
    required this.liked,
    required this.replies,
    this.quoteColor,
    this.refPage,
    this.weekNo,
    this.spoiler,
  });

  factory SharedHighlight.fromJson(Json j) => SharedHighlight(
    id: j['id']! as String,
    author: Person.fromJson(_map(j['author'])),
    quoteText: j['quote_text']! as String,
    quoteColor: j['quote_color'] as String?,
    refPage: _intOrNull(j['ref_page']),
    chapter: _int(j['chapter']),
    weekNo: _intOrNull(j['week_no']),
    createdAt: _instant(j['created_at']),
    samePassage: _int(j['same_passage']),
    likes: _int(j['likes']),
    liked: j['liked'] == true,
    replies: _int(j['replies']),
    spoiler: Spoiler.fromJson(j['spoiler']),
  );

  final String id;
  final Person author;
  final String quoteText;
  final String? quoteColor;
  final int? refPage;
  final int chapter;
  final int? weekNo;
  final DateTime createdAt;

  /// R11: quantas do clube compartilharam o mesmo trecho.
  final int samePassage;
  final int likes;
  final bool liked;
  final int replies;
  final Spoiler? spoiler;
}

/// Onde cada uma está (só a fração).
@immutable
final class MemberProgress {
  const MemberProgress({
    required this.userId,
    required this.initial,
    required this.me,
    this.color,
    this.ratio,
  });

  factory MemberProgress.fromJson(Json j) => MemberProgress(
    userId: j['user_id']! as String,
    initial: j['initial']! as String,
    color: j['color'] as String?,
    ratio: _ratio(j['ratio']),
    me: j['me'] == true,
  );

  final String userId;
  final String initial;
  final String? color;
  final double? ratio;
  final bool me;
}

/// O topo da 04.
@immutable
final class ClubHeader {
  const ClubHeader({
    required this.id,
    required this.name,
    required this.color,
    required this.privacy,
    required this.progressColors,
    required this.spoilerProtection,
    required this.role,
    required this.membersCount,
    this.nameHighlight,
    this.category,
  });

  factory ClubHeader.fromJson(Json j) => ClubHeader(
    id: j['id']! as String,
    name: j['name']! as String,
    nameHighlight: j['name_highlight'] as String?,
    category: j['category'] as String?,
    color: j['color']! as String,
    privacy: j['privacy']! as String,
    progressColors: j['progress_colors']! as String,
    spoilerProtection: j['spoiler_protection']! as bool,
    role: j['role']! as String,
    membersCount: _int(j['members_count']),
  );

  final String id;
  final String name;
  final String? nameHighlight;
  final String? category;
  final String color;
  final String privacy;

  /// `club` ("Uma cor para todas") ou `member` ("Cada uma escolhe").
  final String progressColors;
  final bool spoilerProtection;
  final String role;
  final int membersCount;
}

/// A 04 (`club_overview`).
@immutable
final class ClubOverview {
  const ClubOverview({
    required this.club,
    required this.weeks,
    required this.members,
    required this.unread,
    required this.shared,
    this.reading,
    this.nextMeeting,
    this.myProgress,
    this.groupProgress,
  });

  factory ClubOverview.fromJson(Json j) {
    final r = _mapOrNull(j['reading']);
    return ClubOverview(
      club: ClubHeader.fromJson(_map(j['club'])),
      reading: r == null ? null : ClubReading.fromJson(r),
      weeks: [for (final w in _list(r?['weeks_list'])) WeekCard.fromJson(w)],
      nextMeeting: switch (_mapOrNull(j['next_meeting'])) {
        final m? => MeetingSummary.fromJson(m),
        null => null,
      },
      members: [
        for (final m in _list(j['members'])) MemberProgress.fromJson(m),
      ],
      myProgress: _ratio(j['my_progress']),
      groupProgress: _ratio(j['group_progress']),
      unread: _int(j['unread']),
      shared: [for (final s in _list(j['shared'])) SharedHighlight.fromJson(s)],
    );
  }

  final ClubHeader club;
  final ClubReading? reading;
  final List<WeekCard> weeks;
  final MeetingSummary? nextMeeting;
  final List<MemberProgress> members;
  final double? myProgress;
  final double? groupProgress;
  final int unread;
  final List<SharedHighlight> shared;
}

/// Uma resposta da discussão (31).
@immutable
final class ThreadReply {
  const ThreadReply({
    required this.id,
    required this.author,
    required this.createdAt,
    required this.body,
    required this.likes,
    required this.liked,
    required this.replies,
    this.parentId,
    this.quote,
    this.spoiler,
  });

  factory ThreadReply.fromJson(Json j) => ThreadReply(
    id: j['id']! as String,
    parentId: j['parent_id'] as String?,
    author: Person.fromJson(_map(j['author'])),
    createdAt: _instant(j['created_at']),
    body: j['body']! as String,
    likes: _int(j['likes']),
    liked: j['liked'] == true,
    replies: _int(j['replies']),
    quote: QuoteRef.fromJson(j['quote']),
    spoiler: Spoiler.fromJson(j['spoiler']),
  );

  final String id;
  final String? parentId;
  final Person author;
  final DateTime createdAt;
  final String body;
  final int likes;
  final bool liked;

  /// As filhas que eu vejo ("2 respostas").
  final int replies;
  final QuoteRef? quote;
  final Spoiler? spoiler;
}

/// A 31 (`week_thread`): a pergunta da semana e uma página de respostas; [nextCursor] = a próxima página.
@immutable
final class WeekThread {
  const WeekThread({
    required this.replies,
    this.week,
    this.question,
    this.nextCursor,
  });

  factory WeekThread.fromJson(Json j) => WeekThread(
    week: switch (_mapOrNull(j['week'])) {
      final w? => ClubWeekRange.fromJson(w),
      null => null,
    },
    question: switch (_mapOrNull(j['question'])) {
      final q? => QuestionSummary.fromJson(q),
      null => null,
    },
    replies: [for (final r in _list(j['replies'])) ThreadReply.fromJson(r)],
    nextCursor: _mapOrNull(j['next_cursor']),
  );

  final ClubWeekRange? week;
  final QuestionSummary? question;
  final List<ThreadReply> replies;
  final Json? nextCursor;
}

/// Quem vai, com a fração dela (a ordem: da mais à frente).
typedef MeetingPerson = ({Person person, double? ratio});

/// Um recado que eu posso ler.
typedef MeetingNote = ({Person author, String body, NoteVisibility visibility});

/// As 70, 72 e 73 (`meeting_overview`).
@immutable
final class MeetingOverview {
  const MeetingOverview({
    required this.meeting,
    required this.clubId,
    required this.clubName,
    required this.host,
    required this.people,
    required this.questions,
    required this.notes,
    this.bookTitle,
    this.mine,
    this.myNote,
  });

  factory MeetingOverview.fromJson(Json j) {
    final m = _map(j['meeting']);
    final mine = _map(j['mine']);
    final note = _mapOrNull(mine['note']);
    final people = _mapOrNull(j['people']) ?? const <String, Object?>{};
    return MeetingOverview(
      meeting: MeetingSummary.fromJson(m),
      clubId: m['club_id']! as String,
      clubName: m['club_name']! as String,
      bookTitle: m['book_title'] as String?,
      host: Person.fromJson(_map(j['host'])),
      mine: Rsvp.of(mine['answer']),
      myNote: note == null
          ? null
          : (
              body: note['body']! as String,
              visibility: NoteVisibility.of(note['visibility']),
            ),
      people: {
        for (final r in Rsvp.values)
          r: [
            for (final p in _list(people[r.code]))
              (person: Person.fromJson(p), ratio: _ratio(p['ratio'])),
          ],
      },
      questions: [
        for (final q in _list(j['questions'])) QuestionSummary.fromJson(q),
      ],
      notes: [
        for (final n in _list(j['notes']))
          (
            author: Person.fromJson(_map(n['author'])),
            body: n['body']! as String,
            visibility: NoteVisibility.of(n['visibility']),
          ),
      ],
    );
  }

  final MeetingSummary meeting;
  final String clubId;
  final String clubName;
  final String? bookTitle;
  final Person host;
  final Rsvp? mine;
  final ({String body, NoteVisibility visibility})? myNote;
  final Map<Rsvp, List<MeetingPerson>> people;
  final List<QuestionSummary> questions;
  final List<MeetingNote> notes;
}

/// Uma linha da 32.
@immutable
final class MemberRow {
  const MemberRow({
    required this.person,
    required this.role,
    this.ratio,
    this.rsvp,
  });

  factory MemberRow.fromJson(Json j) => MemberRow(
    person: Person.fromJson(j),
    role: j['role']! as String,
    ratio: _ratio(j['ratio']),
    rsvp: Rsvp.of(j['rsvp']),
  );

  final Person person;
  final String role;
  final double? ratio;
  final Rsvp? rsvp;
}

/// A 32 (`club_members_overview`).
@immutable
final class ClubMembers {
  const ClubMembers({required this.members, this.nextMeeting});

  factory ClubMembers.fromJson(Json j) => ClubMembers(
    nextMeeting: switch (_mapOrNull(j['next_meeting'])) {
      final m? => MeetingSummary.fromJson(m),
      null => null,
    },
    members: [for (final m in _list(j['members'])) MemberRow.fromJson(m)],
  );

  final MeetingSummary? nextMeeting;
  final List<MemberRow> members;
}

/// O chip da 25: "Leitoras de Capitu · 3 respostas".
@immutable
final class PostSummary {
  const PostSummary({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.replies,
  });

  factory PostSummary.fromJson(Json j) => PostSummary(
    id: j['id']! as String,
    clubId: j['club_id']! as String,
    clubName: j['club_name']! as String,
    replies: _int(j['replies']),
  );

  Json toJson() => {
    'id': id,
    'club_id': clubId,
    'club_name': clubName,
    'replies': replies,
  };

  final String id;
  final String clubId;
  final String clubName;
  final int replies;

  @override
  bool operator ==(Object other) =>
      other is PostSummary &&
      other.id == id &&
      other.clubId == clubId &&
      other.clubName == clubName &&
      other.replies == replies;

  @override
  int get hashCode => Object.hash(id, clubId, clubName, replies);
}

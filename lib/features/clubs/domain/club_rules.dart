// G21.4 — as regras do clube no aparelho (docs/progresso/G21.md §4, R1–R3 e R7–R10; R4–R6, R11 e R12 vêm prontas
// do servidor). Dart puro.
import '../../home/domain/home_chapter.dart';
import 'club_models.dart';

/// Um livro da estante: a edição do catálogo e o ISBN-13 (o que o aparelho sabe; a estante não sai dele — D-213).
typedef ShelfBookId = ({String? editionId, String? isbn13});

/// R1 (D-213): o livro é o da leitura do clube? A mesma edição; senão, a mesma obra (o ISBN-13 é de uma das
/// edições da obra, que o servidor manda em [ClubReading.isbns]); senão, o mesmo ISBN-13.
bool bookMatchesReading(ShelfBookId book, ClubReading reading) {
  final edition = book.editionId;
  if (edition != null && edition == reading.editionId) return true;
  final isbn = book.isbn13;
  if (isbn == null) return false;
  return reading.isbns.contains(isbn) || isbn == reading.isbn13;
}

/// R2 (D-214): o rótulo do cap. [n] do clube no livro — o numeral do N-º capítulo numerado ([numerals] = o numeral
/// de cada folha do sumário, `chapterNumerals`); livro sem numeração: o rótulo do clube ([clubLabel]) ou o número.
String clubChapterLabel(List<String?> numerals, int n, {String? clubLabel}) {
  final numbered = [for (final x in numerals) ?x];
  if (numbered.isEmpty) return clubLabel ?? '$n';
  return n >= 1 && n <= numbered.length ? numbered[n - 1] : '$n';
}

/// R2 ao contrário: o cap. do clube da folha [chapterIndex] — a contagem do "Cap. N de M" da Início (D-206): o
/// N-º numerado (fora de um numerado, o último antes); sem numeração, a folha + 1. `null` = antes do 1º.
int? clubChapterOf(
  List<String?> numerals, {
  required int? chapterIndex,
  required int? chaptersTotal,
}) => homeChapter(
  numerals,
  chapterIndex: chapterIndex,
  chaptersTotal: chaptersTotal,
)?.chapter;

/// Os clubes cuja leitura atual é o livro [book] (R1), do encontro mais próximo para o mais distante (sem
/// encontro por último; empate: a atividade mais recente).
List<ClubCard> clubsReading(List<ClubCard> clubs, ShelfBookId book) =>
    nearestFirst([
      for (final c in clubs)
        if (c.reading case final r? when bookMatchesReading(book, r)) c,
    ]);

/// Do encontro mais próximo para o mais distante; sem encontro, por último; empate: a atividade mais recente.
List<ClubCard> nearestFirst(Iterable<ClubCard> clubs) {
  final out = clubs.toList();
  int byMeeting(ClubCard a, ClubCard b) {
    final x = a.nextMeeting?.startsAt;
    final y = b.nextMeeting?.startsAt;
    if (x != null && y != null && x != y) return x.compareTo(y);
    if (x == null && y != null) return 1;
    if (x != null && y == null) return -1;
    final p = a.lastActivityAt;
    final q = b.lastActivityAt;
    if (p != null && q != null && p != q) return q.compareTo(p);
    if (p == null && q != null) return 1;
    if (p != null && q == null) return -1;
    return a.name.compareTo(b.name);
  }

  out.sort(byMeeting);
  return out;
}

/// R3 (D-215, D-226): o clube do ticket da Início — entre os clubes com encontro marcado e leitura, o que lê o
/// livro em leitura ([reading], o herói da Início); senão, o do encontro mais próximo (a atividade mais recente
/// desempata). Nenhum com encontro: `null` (o ticket some).
ClubCard? ticketClub(List<ClubCard> clubs, ShelfBookId? reading) {
  final scheduled = [
    for (final c in clubs)
      if (c.nextMeeting != null && c.reading?.currentWeek != null) c,
  ];
  if (scheduled.isEmpty) return null;
  if (reading != null) {
    final same = clubsReading(scheduled, reading);
    if (same.isNotEmpty) return same.first;
  }
  return nearestFirst(scheduled).first;
}

/// R7: a semana está aberta para mim? As que eu já alcancei pelo meu cap. do clube, mais a atual; as outras (à
/// frente de mim, mesmo antes da atual) dizem "Abre quando você chegar lá".
bool weekOpenFor(
  ClubWeekRange week, {
  required int currentWeek,
  int? myChapter,
}) => week.no == currentWeek || (myChapter != null && week.from <= myChapter);

/// R8 (D-218): o post ou a resposta está à frente de mim (fica borrado)? Pela minha posição no aparelho ([myRatio],
/// mais nova que a publicada). Com a proteção do clube desligada, nada fica à frente.
bool isAhead(Spoiler? s, double myRatio, {required bool protection}) =>
    protection && s != null && s.ratio > myRatio;

/// A posição publicada num clube (R9).
typedef PublishedProgress = ({double ratio, int? chapter});

/// R9: publica de novo só se a posição mudou desde a última publicação.
bool shouldPublishProgress(PublishedProgress? last, PublishedProgress now) =>
    last == null ||
    (last.ratio - now.ratio).abs() >= 0.0001 ||
    last.chapter != now.chapter;

/// R10: os números do perfil, uma vez por dia (D-216).
bool statsDue(DateTime? lastPublished, DateTime now) =>
    lastPublished == null ||
    now.difference(lastPublished) >= const Duration(hours: 24);

/// "54%" (R5: a fração do servidor, arredondada para o % inteiro).
String percentText(double ratio) => '${(ratio * 100).round()}%';

/// O nome do ticket em duas partes ("Leitoras de" + o destaque "Capitu"). Sem destaque marcado, a última palavra.
({String prefix, String highlight}) ticketName(ClubCard c) {
  final name = c.name.trim();
  final h = c.nameHighlight?.trim();
  if (h != null && h.isNotEmpty && name.contains(h)) {
    final i = name.lastIndexOf(h);
    return (
      prefix: '${name.substring(0, i)}${name.substring(i + h.length)}'.trim(),
      highlight: h,
    );
  }
  final i = name.lastIndexOf(' ');
  return i < 0
      ? (prefix: '', highlight: name)
      : (prefix: name.substring(0, i).trim(), highlight: name.substring(i + 1));
}

/// O resumo do ticket que o `CachedClubTicketSource` (G08) lê de `inicio.clube:<dono>`: o "até o cap." é o fim da
/// semana atual (R4), no número do clube.
Json ticketJson(ClubCard c) {
  final r = c.reading!;
  final name = ticketName(c);
  return {
    'id': c.id,
    'name_prefix': name.prefix,
    'name_highlight': name.highlight,
    'book': {
      'id': r.editionId ?? r.workId ?? r.id,
      'title': r.title ?? '',
      'author': r.author ?? '',
      'cover_ref': r.coverRef,
      'isbn13': r.isbn13,
    },
    'until_chapter': r.currentWeek!.to,
    'participants': [
      for (final p in c.participants) {'initial': p.initial, 'color': p.color},
    ],
    'participants_count': c.membersCount,
    'group_progress': c.groupProgress ?? 0,
    'user_progress': c.myProgress ?? 0,
    'user_initial': c.me?.initial ?? '',
    'unread_messages': c.unread,
    'next_meeting': c.nextMeeting!.startsAt.toUtc().toIso8601String(),
  };
}

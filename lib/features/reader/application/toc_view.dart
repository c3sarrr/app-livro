// G15.2 — tudo o que a folha do sumário mostra (telas 27 e 27b), a partir dos dados; puro, sem banco nem tela:
// - linhas do sumário: as partes (entradas com subentradas) viram um título em maiúsculas sem página, marcas nem
//   "lido" (D-153); cada capítulo (folha — D-93) tem o numeral do livro (D-150), o título, a página de início (D-19),
//   as marcas (Anexo 02 §4.2; "1 marca" — D-51c), "lido" (a posição passou do fim dele) e, no atual, o anel (quanto
//   dele já foi lido, até o começo do próximo); entrada sem lugar no texto não tem página nem é tocável;
// - a faixa do clube (D-149): "NOME · QUI 24/9" e "Até o cap. L · faltam 18" ("falta 1"; na meta ou depois, só a
//   meta);
// - os cartões das Marcadas (D-152): na ordem do livro, "cap. I · Do título", "você está aqui", "marcada hoje" /
//   "marcada em 2 set" (com o ano quando não é o deste ano), no fuso; os tirados nesta abertura ficam com a fita vazia.
// No EPUB a posição é o caractere global; no PDF, a página.
import 'dart:math' as math;

import '../annotations/domain/annotation.dart';
import '../annotations/domain/annotation_stats.dart';
import '../content/book_index.dart';
import '../content/toc_labels.dart';
import '../domain/bookmark.dart';
import '../domain/locator.dart';
import '../domain/reader_numbers.dart' show globalPositionOf;
import 'reader_club_source.dart';
import 'reader_document.dart' show ReaderMark;

enum TocRowKind { part, chapter }

/// Uma linha da aba Capítulos.
final class TocRow {
  const TocRow({
    required this.kind,
    required this.entry,
    required this.title,
    this.chapter,
    this.numeral,
    this.page,
    this.marks = const ChapterMarks(count: 0, symbols: []),
    this.read = false,
    this.current = false,
    this.progress = 0,
    this.target,
  });

  final TocRowKind kind;

  /// A entrada no sumário.
  final int entry;

  /// O capítulo (folha, contado de 0); `null` na parte.
  final int? chapter;
  final String? numeral;

  /// O título (na parte, em maiúsculas).
  final String title;

  /// A página de início; `null` na parte e na entrada sem lugar.
  final int? page;
  final ChapterMarks marks;
  final bool read;
  final bool current;

  /// Quanto do capítulo atual já foi lido (0…1).
  final double progress;

  /// Onde o toque leva; `null` = não tocável.
  final ReaderMark? target;

  /// "1 marca", "5 marcas".
  String get marksLabel =>
      marks.count == 1 ? '1 marca' : '${marks.count} marcas';
}

/// A faixa do clube.
typedef TocClubStrip = ({String kicker, String goal});

/// Um cartão da aba Marcadas.
final class TocBookmarkCard {
  const TocBookmarkCard({
    required this.bookmark,
    required this.marked,
    required this.page,
    required this.chapter,
    required this.here,
    required this.excerpt,
    required this.date,
    required this.target,
  });

  final Bookmark bookmark;

  /// A fita: marcada (viva) ou só o contorno (tirada nesta abertura).
  final bool marked;
  final int page;

  /// "cap. I · Do título" (sem numeral, só o título; capítulo fora do sumário, `null`).
  final String? chapter;

  /// A página da marca é a de agora ("você está aqui").
  final bool here;
  final String? excerpt;

  /// "marcada hoje", "marcada em 2 set".
  final String date;
  final ReaderMark? target;
}

final class TocView {
  const TocView({
    required this.subtitle,
    required this.chapters,
    required this.bookmarks,
    required this.rows,
    required this.currentRow,
    required this.refPage,
    required this.club,
    required this.cards,
  });

  /// "Dom Casmurro · 148 capítulos" (sem sumário, só o título).
  final String subtitle;

  /// O número da aba Capítulos; `null` sem sumário.
  final int? chapters;

  /// O número da aba Marcadas (as vivas).
  final int bookmarks;
  final List<TocRow> rows;

  /// A linha do capítulo atual; `null` antes do 1º capítulo ou sem sumário.
  final int? currentRow;
  final int refPage;
  final TocClubStrip? club;
  final List<TocBookmarkCard> cards;
}

const List<String> _months = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];
const List<String> _weekdays = [
  'SEG',
  'TER',
  'QUA',
  'QUI',
  'SEX',
  'SÁB',
  'DOM',
];

TocView buildTocView({
  required String bookTitle,
  required BookIndex? index,
  required ReaderMark at,
  required int refPage,
  required List<Annotation> annotations,
  required List<Bookmark> bookmarks,
  List<Bookmark> removed = const [],
  ReaderClubGoal? club,
  required DateTime now,
  required Duration Function(DateTime utc) utcOffsetAt,
}) {
  final toc = index?.toc ?? const <TocPoint>[];
  final rows = index == null || toc.isEmpty
      ? const <TocRow>[]
      : _rows(index, at, annotations);
  final currentRow = rows.indexWhere((r) => r.current);
  final chapters = index?.chaptersTotal;
  final leaves = [
    for (final r in rows)
      if (r.kind == TocRowKind.chapter) r,
  ];
  final current = currentRow < 0 ? null : rows[currentRow].chapter;
  return TocView(
    subtitle: chapters == null
        ? bookTitle
        : '$bookTitle · ${chapters == 1 ? '1 capítulo' : '$chapters capítulos'}',
    chapters: chapters,
    bookmarks: bookmarks.length,
    rows: rows,
    currentRow: currentRow < 0 ? null : currentRow,
    refPage: refPage,
    club: club == null ? null : _club(club, leaves, current, utcOffsetAt),
    cards: _cards(bookmarks, removed, leaves, refPage, now, utcOffsetAt),
  );
}

List<TocRow> _rows(BookIndex index, ReaderMark at, List<Annotation> notes) {
  final pdf = index.layout == 'pdf';
  final toc = index.toc;
  final labels = tocLabels([
    for (final t in toc)
      (title: t.title, textNumeral: t.textNumeral, leaf: t.leaf),
  ]);
  // começo de cada entrada: caractere global (EPUB) ou página (PDF); `null` = sem lugar no texto linear
  int? startOf(TocPoint t) {
    final s = t.spine;
    if (s == null) return null;
    if (pdf) {
      final p = t.offset ?? 0;
      return p >= 0 && p < index.refPagesTotal ? p : null;
    }
    return index.globalOffset(s, t.offset ?? 0);
  }

  final starts = [for (final t in toc) startOf(t)];
  final end = pdf ? index.refPagesTotal : index.totalChars;
  final position = pdf
      ? at.offset
      : globalPositionOf(index, at.spine, at.offset);
  // as folhas (capítulos), o atual (o último que começa na posição ou antes) e o fim de cada uma (o começo da
  // próxima folha com lugar; no último, o fim do livro)
  final leaves = [
    for (var i = 0; i < toc.length; i++)
      if (toc[i].leaf) i,
  ];
  int? current;
  for (var c = 0; c < leaves.length; c++) {
    final s = starts[leaves[c]];
    if (s != null && s <= position) current = c;
  }
  final ends = List<int>.filled(leaves.length, end);
  int? following;
  for (var c = leaves.length - 1; c >= 0; c--) {
    ends[c] = following ?? end;
    final s = starts[leaves[c]];
    if (s != null) following = s;
  }
  final byChapter = <int, List<Annotation>>{};
  for (final a in notes) {
    if (!a.meta.isDeleted) (byChapter[a.chapterIndex] ??= []).add(a);
  }
  ReaderMark? targetOf(int i) => starts[i] == null
      ? null
      : pdf
      ? (spine: 0, offset: starts[i]!)
      : (spine: toc[i].spine!, offset: toc[i].offset ?? 0);

  final out = <TocRow>[];
  var leaf = -1;
  for (var i = 0; i < toc.length; i++) {
    if (!toc[i].leaf) {
      out.add(
        TocRow(
          kind: TocRowKind.part,
          entry: i,
          title: tocTitle(toc[i].title).toUpperCase(),
          target: targetOf(i),
        ),
      );
      continue;
    }
    final c = ++leaf;
    final s = starts[i];
    final isCurrent = c == current;
    final e = ends[c];
    out.add(
      TocRow(
        kind: TocRowKind.chapter,
        entry: i,
        chapter: c,
        numeral: labels[i].numeral,
        title: labels[i].title,
        page: s == null
            ? null
            : pdf
            ? s + 1
            : math.max(1, index.refPages.pageOf(s)),
        marks: AnnotationStats.chapterMarks(
          byChapter[c] ?? const [],
          chapterIndex: c,
        ),
        read: s != null && !isCurrent && position >= e && e >= s,
        current: isCurrent,
        progress: !isCurrent || e <= s!
            ? (isCurrent ? 1 : 0)
            : ((position - s) / (e - s)).clamp(0.0, 1.0),
        target: targetOf(i),
      ),
    );
  }
  return out;
}

TocClubStrip _club(
  ReaderClubGoal g,
  List<TocRow> leaves,
  int? current,
  Duration Function(DateTime) offsetAt,
) {
  final name = g.name.toUpperCase();
  final meet = g.nextMeeting;
  final String kicker;
  if (meet == null) {
    kicker = name;
  } else {
    final local = meet.toUtc().add(offsetAt(meet.toUtc()));
    kicker =
        '$name · ${_weekdays[local.weekday - 1]} ${local.day}/${local.month}';
  }
  final i = g.goalChapter - 1;
  final numeral = i >= 0 && i < leaves.length ? leaves[i].numeral : null;
  final goal = 'Até o cap. ${numeral ?? g.goalChapter}';
  final left = g.goalChapter - ((current ?? -1) + 1);
  return (
    kicker: kicker,
    goal: left <= 0
        ? goal
        : '$goal · ${left == 1 ? 'falta 1' : 'faltam $left'}',
  );
}

List<TocBookmarkCard> _cards(
  List<Bookmark> live,
  List<Bookmark> removed,
  List<TocRow> leaves,
  int refPage,
  DateTime now,
  Duration Function(DateTime) offsetAt,
) {
  final alive = {for (final b in live) b.id};
  final all = [
    ...live,
    for (final b in removed)
      if (!alive.contains(b.id)) b,
  ];
  final seen = <String>{};
  final unique =
      [
        for (final b in all)
          if (seen.add(b.id)) b,
      ]..sort((a, b) {
        final p = a.refPage.compareTo(b.refPage);
        return p != 0 ? p : a.meta.createdAt.compareTo(b.meta.createdAt);
      });
  final today = _local(now, offsetAt);
  return [
    for (final b in unique)
      TocBookmarkCard(
        bookmark: b,
        marked: alive.contains(b.id),
        page: b.refPage,
        chapter: b.chapterIndex < leaves.length
            ? _chapterLabel(leaves[b.chapterIndex])
            : null,
        here: b.refPage == refPage,
        excerpt: b.excerpt,
        date: _markedOn(_local(b.meta.createdAt, offsetAt), today),
        target: switch (b.locator) {
          EpubLocator(:final spine, :final offset) => (
            spine: spine,
            offset: offset,
          ),
          PdfLocator(:final page) => (spine: 0, offset: page),
          RawLocator() => null,
        },
      ),
  ];
}

String _chapterLabel(TocRow r) =>
    r.numeral == null ? r.title : 'cap. ${r.numeral} · ${r.title}';

DateTime _local(DateTime t, Duration Function(DateTime) offsetAt) {
  final u = t.toUtc();
  return u.add(offsetAt(u));
}

String _markedOn(DateTime day, DateTime today) {
  if (day.year == today.year &&
      day.month == today.month &&
      day.day == today.day) {
    return 'marcada hoje';
  }
  final y = day.year == today.year ? '' : ' ${day.year}';
  return 'marcada em ${day.day} ${_months[day.month - 1]}$y';
}

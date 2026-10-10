// G15.2 — tudo o que a folha do sumário mostra (telas 27 e 27b), a partir dos dados; puro, sem banco nem tela:
// - linhas do sumário: as partes (entradas com subentradas) viram um título pequeno sem página, marcas nem "lido"
//   (D-153; a folha põe em maiúsculas); cada capítulo (folha — D-93) tem o numeral do livro (D-150, D-155, D-156), o
//   título, a página de início (D-19), as marcas (Anexo 02 §4.2; "1 marca" — D-51c), "lido" (a posição passou do fim
//   dele) e, no atual, o anel (quanto dele já foi lido, até o começo do próximo); entrada sem lugar no texto não tem
//   página nem é tocável. O atual é o capítulo que começa mais perto antes da posição, e o fim de cada um é o próximo
//   começo na ordem do livro (uma entrada fora de ordem — "Créditos" apontando para o começo — não vira o atual);
// - a faixa do clube (D-149): "NOME · QUI 24/9" e "Até o cap. L · faltam 18" ("falta 1"; na meta ou depois, só a
//   meta), e o que o leitor de tela lê;
// - os cartões das Marcadas (D-152): na ordem do livro, o capítulo do lugar da marca ("cap. I · Do título"; antes do
//   1º capítulo, nenhum; no PDF, pela página), "você está aqui", "marcada hoje" / "marcada em 2 set" (com o ano quando
//   não é o deste ano), no fuso; os tirados nesta abertura ficam com a fita vazia; a fita pedida vale na hora; o
//   leitor de tela lê o cartão inteiro (D-158).
// No EPUB a posição é o caractere global; no PDF, a página. O índice que não se leu não vira "sem sumário".
import 'dart:math' as math;

import '../../clubs/domain/club_rules.dart'
    show clubChapterLabel, clubChapterOf;
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

  /// O título (a parte, como no livro: a folha mostra em maiúsculas).
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

/// A faixa do clube: as duas linhas e o que o leitor de tela lê ("Leitoras de Capitu, quinta 24/9, Até o cap. L,
/// faltam 18").
typedef TocClubStrip = ({String kicker, String goal, String spoken});

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

  /// O cartão para o leitor de tela (D-158): "Página 159, cap. XXXII, Olhos de ressaca, você está aqui, ‹excerto›,
  /// marcada hoje".
  String get spoken => [
    'Página $page',
    ?chapter?.replaceAll(' · ', ', '),
    if (here) 'você está aqui',
    ?excerpt,
    date,
  ].join(', ');
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
    this.tocFailed = false,
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

  /// O índice não se leu: a aba Capítulos fica só com a moldura (não diz que o livro não tem sumário).
  final bool tocFailed;
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
const List<String> _weekdaysSpoken = [
  'segunda',
  'terça',
  'quarta',
  'quinta',
  'sexta',
  'sábado',
  'domingo',
];

TocView buildTocView({
  required String bookTitle,
  required BookIndex? index,
  bool indexFailed = false,
  required ReaderMark at,
  ReaderMark? atEnd,
  required int refPage,
  required List<Annotation> annotations,
  required List<Bookmark> bookmarks,
  List<Bookmark> removed = const [],
  Map<String, bool> wanted = const {},
  ReaderClubGoal? club,
  required DateTime now,
  required Duration Function(DateTime utc) utcOffsetAt,
}) {
  final toc = index?.toc ?? const <TocPoint>[];
  final places = index == null || toc.isEmpty ? null : _Places(index);
  final rows = places == null
      ? const <TocRow>[]
      : _rows(places, at, annotations, end: atEnd);
  final currentRow = rows.indexWhere((r) => r.current);
  final chapters = index?.chaptersTotal;
  final leaves = [
    for (final r in rows)
      if (r.kind == TocRowKind.chapter) r,
  ];
  final current = currentRow < 0 ? null : rows[currentRow].chapter;
  final cards = _cards(
    bookmarks,
    removed,
    wanted,
    leaves,
    places,
    refPage,
    now,
    utcOffsetAt,
  );
  return TocView(
    subtitle: chapters == null
        ? bookTitle
        : '$bookTitle · ${chapters == 1 ? '1 capítulo' : '$chapters capítulos'}',
    chapters: chapters,
    bookmarks: cards.where((c) => c.marked).length,
    rows: rows,
    currentRow: currentRow < 0 ? null : currentRow,
    refPage: refPage,
    club: club == null ? null : _club(club, leaves, current, utcOffsetAt),
    cards: cards,
    tocFailed: indexFailed && index == null,
  );
}

/// Onde cada capítulo começa e termina, e o capítulo de uma posição: caractere global (EPUB) ou página (PDF).
final class _Places {
  _Places(this.index)
    : pdf = index.layout == 'pdf',
      end = index.layout == 'pdf' ? index.refPagesTotal : index.totalChars {
    final toc = index.toc;
    starts = [for (final t in toc) _startOf(t)];
    leaves = [
      for (var i = 0; i < toc.length; i++)
        if (toc[i].leaf) i,
    ];
    // o fim de cada capítulo: o próximo começo na ordem do livro (no último, o fim do livro)
    final sorted = <int>{for (final i in leaves) ?starts[i]}.toList()..sort();
    ends = [
      for (final i in leaves)
        switch (starts[i]) {
          final s? => _after(sorted, s) ?? end,
          null => end,
        },
    ];
  }

  final BookIndex index;
  final bool pdf;
  final int end;
  late final List<int?> starts;
  late final List<int> leaves;
  late final List<int> ends;

  int? _startOf(TocPoint t) {
    final s = t.spine;
    if (s == null) return null;
    if (pdf) {
      final p = t.offset ?? 0;
      return p >= 0 && p < index.refPagesTotal ? p : null;
    }
    return index.globalOffset(s, t.offset ?? 0);
  }

  /// O menor começo depois de [s] (busca binária na lista ordenada).
  static int? _after(List<int> sorted, int s) {
    var lo = 0;
    var hi = sorted.length;
    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (sorted[mid] <= s) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    return lo < sorted.length ? sorted[lo] : null;
  }

  /// A posição da marca [at] da leitura: o caractere global (EPUB) ou a página (PDF).
  int positionOf(ReaderMark at) =>
      pdf ? at.offset : globalPositionOf(index, at.spine, at.offset);

  /// O capítulo (folha) da [position]: o que começa mais perto antes dela (no empate, o último no sumário); `null`
  /// antes do primeiro.
  int? leafAt(int position) {
    int? best;
    int? bestStart;
    for (var c = 0; c < leaves.length; c++) {
      final s = starts[leaves[c]];
      if (s == null || s > position) continue;
      if (bestStart == null || s >= bestStart) {
        best = c;
        bestStart = s;
      }
    }
    return best;
  }
}

/// [at] = o começo da página mostrada; [end] = o último caractere dela. O capítulo atual é o último que começa na
/// página (D-210): a folha de [end] (sem [end], a de [at]).
List<TocRow> _rows(
  _Places places,
  ReaderMark at,
  List<Annotation> notes, {
  ReaderMark? end,
}) {
  final index = places.index;
  final pdf = places.pdf;
  final toc = index.toc;
  final labels = tocLabels([
    for (final t in toc)
      (title: t.title, textNumeral: t.textNumeral, leaf: t.leaf),
  ]);
  final starts = places.starts;
  final position = places.positionOf(at);
  final current = places.leafAt(
    end == null ? position : places.positionOf(end),
  );
  final ends = places.ends;
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
          title: tocTitle(toc[i].title),
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
  final String said;
  if (meet == null) {
    kicker = name;
    said = g.name;
  } else {
    final local = meet.toUtc().add(offsetAt(meet.toUtc()));
    final day = '${local.day}/${local.month}';
    kicker = '$name · ${_weekdays[local.weekday - 1]} $day';
    said = '${g.name}, ${_weekdaysSpoken[local.weekday - 1]} $day';
  }
  // R2 (D-214): o cap. N do clube é o N-º capítulo numerado do livro, com o numeral dele; o "faltam" conta do
  // mesmo jeito (antes do 1º numerado, falta a meta inteira)
  final numerals = <String?>[];
  for (final r in leaves) {
    final c = r.chapter;
    if (c == null) continue;
    while (numerals.length <= c) {
      numerals.add(null);
    }
    numerals[c] = r.numeral;
  }
  final meta =
      'Até o cap. ${clubChapterLabel(numerals, g.goalChapter, clubLabel: g.goalLabel)}';
  final mine =
      clubChapterOf(
        numerals,
        chapterIndex: current,
        chaptersTotal: numerals.length,
      ) ??
      0;
  final left = g.goalChapter - mine;
  final goal = left <= 0
      ? meta
      : '$meta · ${left == 1 ? 'falta 1' : 'faltam $left'}';
  return (
    kicker: kicker,
    goal: goal,
    spoken: '$said, ${goal.replaceAll(' · ', ', ')}',
  );
}

List<TocBookmarkCard> _cards(
  List<Bookmark> live,
  List<Bookmark> removed,
  Map<String, bool> wanted,
  List<TocRow> leaves,
  _Places? places,
  int refPage,
  DateTime now,
  Duration Function(DateTime) offsetAt,
) {
  // o capítulo do lugar da marca (no PDF, pela página; a marca guarda o capítulo 0); sem lugar legível, o guardado
  String? chapterOf(Bookmark b) {
    final at = switch (b.locator) {
      EpubLocator(:final spine, :final offset) when places?.pdf == false => (
        spine: spine,
        offset: offset,
      ),
      PdfLocator(:final page) when places?.pdf ?? false => (
        spine: 0,
        offset: page,
      ),
      _ => null,
    };
    final c = at == null
        ? b.chapterIndex
        : places!.leafAt(places.positionOf(at));
    return c != null && c < leaves.length ? _chapterLabel(leaves[c]) : null;
  }

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
        marked: wanted[b.id] ?? alive.contains(b.id),
        page: b.refPage,
        chapter: chapterOf(b),
        here: b.refPage == refPage,
        excerpt: b.excerpt,
        date: _markedOn(_local(b.meta.createdAt, offsetAt), today),
        target: switch (b.locator) {
          EpubLocator(:final spine, :final offset) => (
            spine: spine,
            offset: offset,
          ),
          PdfLocator(:final page) => (spine: 0, offset: page),
          // o livro de papel não abre no leitor (T04): o marcador não tem para onde saltar
          PaperLocator() || RawLocator() => null,
        },
      ),
  ];
}

/// G19: o rótulo de cada capítulo pelo índice dele ("cap. XXXII · Olhos de ressaca"), para o CSV da tela 25; sem
/// índice ou sumário, nenhum.
List<String?> chapterLabels(BookIndex? index) {
  if (index == null || index.toc.isEmpty) return const [];
  final out = <String?>[];
  for (final r in _rows(_Places(index), (spine: 0, offset: 0), const [])) {
    final c = r.chapter;
    if (r.kind != TocRowKind.chapter || c == null) continue;
    while (out.length <= c) {
      out.add(null);
    }
    out[c] = _chapterLabel(r);
  }
  return out;
}

/// G20 (D-206): o numeral de cada capítulo (folha) pelo índice dele, como o leitor mostra (D-150/D-155/D-156); sem
/// numeral, `null`; sem índice ou sumário, nenhum. O "Cap. N de M" da Início conta por eles.
List<String?> chapterNumerals(BookIndex? index) {
  if (index == null || index.toc.isEmpty) return const [];
  final out = <String?>[];
  for (final r in _rows(_Places(index), (spine: 0, offset: 0), const [])) {
    final c = r.chapter;
    if (r.kind != TocRowKind.chapter || c == null) continue;
    while (out.length <= c) {
      out.add(null);
    }
    out[c] = r.numeral;
  }
  return out;
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

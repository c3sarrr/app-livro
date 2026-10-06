// Fonte real da Início (G08 — D-78, D-81…D-85, D-10; tempo restante da G10 — D-97): tudo lido do banco do
// aparelho, só as linhas do dono ativo (D-68) e sem linhas apagadas, com os dias no fuso do aparelho. Nada sai
// do aparelho; "Para você" e o Clube vêm das fontes injetadas.
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show FlutterError, FlutterErrorDetails;

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/codecs.dart';
import '../../reader/content/ref_pages.dart' show refPageChars;
import '../../reader/domain/reading_speed.dart';
import '../../scanner/application/scanned_shelf.dart' show unknownAuthor;
import '../domain/models.dart';
import 'home_repository.dart';
import 'home_sources.dart';

/// Deslocamento do fuso num instante (o do aparelho por padrão; os testes fixam).
typedef UtcOffsetAt = Duration Function(DateTime utc);

Duration deviceUtcOffset(DateTime utc) => utc.toLocal().timeZoneOffset;

final class LocalHomeRepository implements HomeRepository {
  LocalHomeRepository({
    required this._database,
    required this._owner,
    this._utcOffsetAt = deviceUtcOffset,
    this._forYou,
    this._club,
    this.debounce = const Duration(milliseconds: 300),
    this._wakeups,
    void Function(Object error, StackTrace stack)? onSourceError,
  }) : _onSourceError = onSourceError ?? _report;

  final Future<AppDatabase> Function() _database;
  final Future<String> Function() _owner;
  final UtcOffsetAt _utcOffsetAt;
  final ForYouSource? _forYou;
  final ClubTicketSource? _club;

  /// Gravações em rajada (a sincronização, o leitor virando página) viram um recálculo só.
  final Duration debounce;

  /// O app voltou do segundo plano (o relógio do timer não anda com o aparelho dormindo): recalcula.
  final Stream<void> Function()? _wakeups;

  /// Falha de "Para você" ou do Clube: a seção some e a Início continua (D-81, D-80).
  final void Function(Object error, StackTrace stack) _onSourceError;

  static void _report(Object e, StackTrace st) => FlutterError.reportError(
    FlutterErrorDetails(exception: e, stack: st, library: 'inicio'),
  );

  /// Sem conta (ou antes de a conta responder): convidado, sem notificações (D-84; G21).
  static const UserSummary guest = UserSummary(unreadNotifications: 0);

  /// Meta e selo quando o dono ainda não gravou os dele (padrões do SQL).
  static const int defaultGoalMinutes = 30;
  static const int defaultBadgeTargetDays = 7;

  /// D-10: barra = minutos × 4/3 px, limitada à altura interna do trilho (borda 1,2 → 77,6; hoje, borda
  /// 1,5 → 77,0).
  static const double barPxPerMinute = 4 / 3;
  static const double barMaxPx = 77.6;
  static const double barMaxTodayPx = 77.0;

  /// Um dia entra na sequência com pelo menos 1 minuto lido (D-85).
  static const int streakMinSeconds = 60;

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) {
    late final StreamController<HomeSnapshot> out;
    StreamSubscription<void>? tables;
    StreamSubscription<void>? wakeups;
    Timer? next;
    Timer? burst;
    var closed = false;
    var running = false;
    var again = false;

    Future<void> refresh() async {
      if (closed) return;
      if (running) {
        again = true;
        return;
      }
      running = true;
      try {
        do {
          again = false;
          final now = clock();
          try {
            final s = await read(now);
            if (closed) return;
            out.add(s);
          } on Object catch (e, st) {
            if (!closed) out.addError(e, st);
          }
          next?.cancel();
          if (!closed) {
            next = Timer(untilNextRefresh(now, _utcOffsetAt), refresh);
          }
        } while (again && !closed);
      } finally {
        running = false;
      }
    }

    void soon() {
      burst?.cancel();
      burst = Timer(debounce, refresh);
    }

    out = StreamController<HomeSnapshot>(
      onListen: () async {
        try {
          final db = await _database();
          if (closed) return;
          tables = db
              .tableUpdates(
                TableUpdateQuery.onAllTables([
                  db.userBooks,
                  db.readingPositions,
                  db.readingSessions,
                  db.bookContentIndex,
                  db.annotations,
                  db.readingGoalsRows,
                  db.kv,
                  db.socialCache,
                ]),
              )
              .listen((_) => soon());
          wakeups = _wakeups?.call().listen((_) => unawaited(refresh()));
          await refresh();
        } on Object catch (e, st) {
          if (!closed) out.addError(e, st);
        }
      },
      onCancel: () async {
        closed = true;
        next?.cancel();
        burst?.cancel();
        await tables?.cancel();
        await wakeups?.cancel();
      },
    );
    return out.stream;
  }

  /// Até a próxima mudança do que a tela mostra pelo relógio (+1 s): meia-noite (dia, semana, sequência) e 5h,
  /// 12h e 18h (saudação), no fuso do aparelho.
  static Duration untilNextRefresh(DateTime now, UtcOffsetAt utcOffsetAt) {
    final utc = now.toUtc();
    final local = utc.add(utcOffsetAt(utc));
    final day = DateTime.utc(local.year, local.month, local.day);
    final next = [
      for (final h in const [5, 12, 18, 24]) day.add(Duration(hours: h)),
    ].firstWhere((t) => t.isAfter(local));
    return next.difference(local) + const Duration(seconds: 1);
  }

  /// Um instantâneo coerente (uma transação) para o "agora" [now].
  Future<HomeSnapshot> read(DateTime now) async {
    final db = await _database();
    final owner = await _owner();
    final utc = now.toUtc();
    final offset = _utcOffsetAt(utc);
    final local = utc.add(offset);
    final today = DateTime.utc(local.year, local.month, local.day);
    final data = await db.transaction(
      () => _Reader(db, owner, _utcOffsetAt).read(utc, today),
    );

    final reading = data.books.where((b) => b.status == 'reading').toList()
      ..sort(_byLastOpened);
    final hero = reading.isEmpty ? null : reading.first;
    // Recém-chegados: nunca abertos e ainda "quero ler" — um livro em leitura já está em Continue lendo /
    // Também lendo e não se repete aqui (G08.6; antes, um exemplar físico "lendo" aparecia nos dois).
    final recent =
        data.books
            .where((b) => b.lastOpenedAt == null && b.status == 'want_to_read')
            .toList()
          ..sort((a, b) {
            final c = b.addedAt.compareTo(a.addedAt);
            return c != 0 ? c : b.id.compareTo(a.id);
          });

    final forYouSource = _forYou;
    final forYou = forYouSource == null || data.books.isEmpty
        ? null
        : await _guarded(
            () => forYouSource.suggest(_forYouRequest(data.books)),
          );
    final clubSource = _club;
    final club = clubSource == null
        ? null
        : await _guarded(() => clubSource.current(owner));

    return HomeSnapshot(
      now: DateTime(
        local.year,
        local.month,
        local.day,
        local.hour,
        local.minute,
      ),
      // O cabeçalho vem da conta, por cima (home_providers — D-84).
      user: guest,
      continueReading: hero == null
          ? null
          : ContinueReading(
              book: hero.book,
              chapter: hero.chapterIndex == null || hero.chaptersTotal == null
                  ? null
                  : hero.chapterIndex! + 1,
              totalChapters: hero.chapterIndex == null
                  ? null
                  : hero.chaptersTotal,
              progress: hero.progress,
              timeLeft: _timeLeft(hero, data),
              highlightsCount: data.heroAnnotations,
            ),
      alsoReading: List.unmodifiable([
        for (final b in reading.skip(1))
          AlsoReadingItem(book: b.book, progress: b.progress),
      ]),
      readingDay: _readingDay(data, today),
      forYou: forYou,
      club: club,
      recent: List.unmodifiable([
        for (final b in recent.take(3))
          RecentItem(
            book: b.book,
            format: switch (b.format) {
              'pdf' => BookFormat.pdf,
              'physical' => BookFormat.physical,
              _ => BookFormat.epub,
            },
            // D-88: "Novo" para quem chegou hoje ou nos 6 dias anteriores (a janela da D-82); depois "Quero ler"
            status: today.difference(_localDay(b.addedAt)).inDays < newDays
                ? RecentStatus.isNew
                : RecentStatus.wantToRead,
          ),
      ]),
      shelfIsEmpty: data.books.isEmpty,
    );
  }

  /// D-88: dias em que um livro recém-chegado é "Novo" (hoje e os 6 anteriores).
  static const int newDays = 7;

  /// Dia local (meia-noite UTC do dia no fuso do aparelho naquele instante).
  DateTime _localDay(DateTime utc) {
    final l = utc.toUtc().add(_utcOffsetAt(utc.toUtc()));
    return DateTime.utc(l.year, l.month, l.day);
  }

  Future<T?> _guarded<T>(Future<T?> Function() f) async {
    try {
      return await f();
    } on Object catch (e, st) {
      _onSourceError(e, st);
      return null;
    }
  }

  /// Aberto mais recentemente primeiro (sem abertura: a posição, o início, a chegada).
  static int _byLastOpened(_ShelfBook a, _ShelfBook b) {
    final c = b.lastActivity.compareTo(a.lastActivity);
    return c != 0 ? c : b.id.compareTo(a.id);
  }

  /// Caracteres que faltam ÷ velocidade pessoal, arredondado (D-97); livro sem índice e sem páginas de
  /// referência → `null`.
  static Duration? _timeLeft(_ShelfBook b, _Data data) {
    final total = data.totalChars(b);
    if (total == null) return null;
    final remaining = (total * (1 - b.progress)).round();
    return timeLeftFor(remaining, data.charsPerMinute);
  }

  ReadingDay _readingDay(_Data data, DateTime today) {
    String key(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    int seconds(DateTime d) => data.days[key(d)]?.seconds ?? 0;

    final week = <WeekDayStat>[
      for (var i = 6; i >= 0; i--)
        () {
          final d = today.subtract(Duration(days: i));
          final minutes = seconds(d) ~/ 60;
          final isToday = i == 0;
          return WeekDayStat(
            date: DateTime(d.year, d.month, d.day),
            minutes: minutes,
            barHeightPx: math.min(
              minutes * barPxPerMinute,
              isToday ? barMaxTodayPx : barMaxPx,
            ),
            isToday: isToday,
          );
        }(),
    ];

    var day = seconds(today) >= streakMinSeconds
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (seconds(day) >= streakMinSeconds) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    return ReadingDay(
      goalMinutes: data.goalMinutes ?? defaultGoalMinutes,
      readMinutes: seconds(today) ~/ 60,
      streakDays: streak,
      pagesToday: data.days[key(today)]?.pages ?? 0,
      highlightsToday: data.highlightsToday,
      week: List.unmodifiable(week),
      badgeTargetDays: data.badgeTargetDays ?? defaultBadgeTargetDays,
    );
  }

  /// Autores da estante (os de "A · B" contam separados; "Autoria desconhecida" não conta).
  static ForYouRequest _forYouRequest(List<_ShelfBook> books) {
    final count = <String, int>{};
    final last = <String, DateTime>{};
    for (final b in books) {
      for (final a in b.authorDisplay.split(' · ')) {
        final name = a.trim();
        if (name.isEmpty || name == unknownAuthor) continue;
        count[name] = (count[name] ?? 0) + 1;
        final l = last[name];
        if (l == null || b.addedAt.isAfter(l)) last[name] = b.addedAt;
      }
    }
    final authors = count.keys.toList()
      ..sort((a, b) {
        final c = count[b]!.compareTo(count[a]!);
        if (c != 0) return c;
        final d = last[b]!.compareTo(last[a]!);
        return d != 0 ? d : a.compareTo(b);
      });
    return ForYouRequest(
      authors: List.unmodifiable(authors),
      shelfIsbns: {
        for (final b in books)
          if (b.isbn13 != null) b.isbn13!,
      },
      shelfTitles: {for (final b in books) b.title},
    );
  }
}

/// Um livro da estante com a posição (quando há).
final class _ShelfBook {
  _ShelfBook(QueryRow r)
    : id = r.read<String>('id'),
      title = r.read<String>('title'),
      authorDisplay = r.read<String>('author_display'),
      format = r.read<String>('format'),
      status = r.read<String>('status'),
      chaptersTotal = r.readNullable<int>('chapters_total'),
      refPagesTotal = r.readNullable<int>('ref_pages_total'),
      coverRef = r.readNullable<String>('cover_ref'),
      isbn13 = r.readNullable<String>('isbn13'),
      contentSha256 = r.readNullable<String>('content_sha256'),
      addedAt = parseInstant(r.read<String>('added_at')),
      lastOpenedAt = _instant(r.readNullable<String>('last_opened_at')),
      startedAt = _instant(r.readNullable<String>('started_at')),
      chapterIndex = r.readNullable<int>('chapter_index'),
      progress = (r.readNullable<double>('progression') ?? 0).clamp(0.0, 1.0),
      positionAt = _instant(r.readNullable<String>('position_at'));

  static DateTime? _instant(String? s) => s == null ? null : parseInstant(s);

  final String id;
  final String title;
  final String authorDisplay;
  final String format;
  final String status;
  final int? chaptersTotal;
  final int? refPagesTotal;
  final String? coverRef;
  final String? isbn13;
  final String? contentSha256;
  final DateTime addedAt;
  final DateTime? lastOpenedAt;
  final DateTime? startedAt;
  final int? chapterIndex;
  final double progress;
  final DateTime? positionAt;

  DateTime get lastActivity =>
      lastOpenedAt ?? positionAt ?? startedAt ?? addedAt;

  Book get book => Book(
    id: id,
    title: title,
    author: authorDisplay,
    cover: PhotoCover(ref: coverRef, isbn13: isbn13, fileSha: contentSha256),
  );
}

/// Segundos e páginas de um dia local.
typedef _Day = ({int seconds, int pages});

final class _Data {
  _Data({
    required this.books,
    required this.days,
    required this.heroAnnotations,
    required this.highlightsToday,
    required this.indexedChars,
    required this.charsPerMinute,
    required this.goalMinutes,
    required this.badgeTargetDays,
  });

  final List<_ShelfBook> books;

  /// 'AAAA-MM-DD' local → soma do dia.
  final Map<String, _Day> days;
  final int heroAnnotations;
  final int highlightsToday;

  /// Caracteres dos itens lineares de cada livro com índice (id → total).
  final Map<String, int> indexedChars;

  /// Velocidade pessoal (D-97).
  final double charsPerMinute;
  final int? goalMinutes;
  final int? badgeTargetDays;

  /// Caracteres do livro: os do índice; sem índice, as páginas de referência × 1.500; sem os dois, `null`.
  int? totalChars(_ShelfBook b) =>
      indexedChars[b.id] ??
      (b.refPagesTotal == null ? null : b.refPagesTotal! * refPageChars);
}

/// As consultas de um instantâneo (todas dentro da mesma transação).
final class _Reader {
  _Reader(this._db, this._owner, this._utcOffsetAt);

  final AppDatabase _db;
  final String _owner;

  /// Fuso de cada instante: o dia local de uma sessão é o do fuso de quando ela começou (horário de verão).
  final UtcOffsetAt _utcOffsetAt;

  /// 'AAAA-MM-DD' do dia local de um instante.
  String _localDay(DateTime utc) => _dayKey(utc.add(_utcOffsetAt(utc)));

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Instante gravado (o servidor pode mandar outros formatos — `parseInstant`); ilegível = ignorado.
  static DateTime? _instant(String? s) {
    if (s == null) return null;
    try {
      return parseInstant(s);
    } on FormatException {
      return null;
    }
  }

  /// Caracteres dos itens lineares do `spine_json`; ilegível ou sem texto → `null` (o livro fica sem índice
  /// aqui).
  static int? _linearChars(String spineJson) {
    try {
      final items =
          (jsonDecode(spineJson) as Map<String, Object?>)['items']! as List;
      var total = 0;
      for (final i in items) {
        final m = i as Map<String, Object?>;
        if (m['linear']! as bool) total += m['chars']! as int;
      }
      // PDF (o índice dele não tem itens) e livro só de imagens: sem caracteres para medir — o livro conta
      // pelas páginas de referência
      return total > 0 ? total : null;
    } on Object {
      return null;
    }
  }

  Future<List<QueryRow>> _all(String sql, List<Object> args) => _db
      .customSelect(sql, variables: [for (final a in args) _variable(a)])
      .get();

  static Variable<Object> _variable(Object a) => switch (a) {
    final int i => Variable.withInt(i),
    final String s => Variable.withString(s),
    _ => throw ArgumentError.value(a),
  };

  Future<_Data> read(DateTime nowUtc, DateTime today) async {
    final books = [
      for (final r in await _all(
        'SELECT b.id, b.title, b.author_display, b.format, b.status, b.chapters_total, '
        'b.ref_pages_total, b.cover_ref, b.isbn13, b.content_sha256, b.added_at, b.last_opened_at, '
        'b.started_at, '
        'p.chapter_index, CAST(p.progression AS REAL) AS progression, p.updated_at AS position_at '
        'FROM user_books b LEFT JOIN reading_positions p '
        'ON p.id = b.id AND p.user_id = b.user_id AND p.deleted_at IS NULL '
        'WHERE b.user_id = ?1 AND b.deleted_at IS NULL',
        [_owner],
      ))
        _ShelfBook(r),
    ];

    // Caracteres de cada livro com índice (a régua do tempo restante e da velocidade — D-97).
    final indexed = <String, int>{};
    for (final r in await _all(
      'SELECT i.user_book_id, i.spine_json FROM book_content_index i '
      'JOIN user_books b ON b.id = i.user_book_id '
      'WHERE b.user_id = ?1 AND b.deleted_at IS NULL',
      [_owner],
    )) {
      final chars = _linearChars(r.read<String>('spine_json'));
      if (chars != null) indexed[r.read<String>('user_book_id')] = chars;
    }
    final byId = {for (final b in books) b.id: b};
    double perRefPage(String userBookId) {
      final b = byId[userBookId];
      return charsPerRefPage(
        totalChars: indexed[userBookId],
        refPagesTotal: b?.refPagesTotal,
      );
    }

    // Sessões somadas por dia local aqui, não no SQL: o `date()` do SQLite não lê todos os formatos que o
    // servidor manda e usaria um fuso só para todas (revisão da G08).
    final days = <String, _Day>{};
    final samples = <(DateTime, SpeedSample)>[];
    for (final r in await _all(
      'SELECT started_at, active_seconds, pages_viewed, user_book_id FROM reading_sessions '
      'WHERE user_id = ?1 AND deleted_at IS NULL',
      [_owner],
    )) {
      final start = _instant(r.read<String>('started_at'));
      if (start == null) continue;
      final seconds = r.read<int>('active_seconds');
      final pages = r.readNullable<int>('pages_viewed') ?? 0;
      final day = _localDay(start);
      final d = days[day];
      days[day] = (
        seconds: (d?.seconds ?? 0) + seconds,
        pages: (d?.pages ?? 0) + pages,
      );
      samples.add((
        start,
        (
          activeSeconds: seconds,
          pagesViewed: pages,
          charsPerRefPage: perRefPage(r.read<String>('user_book_id')),
        ),
      ));
    }
    // em ordem de início (o texto gravado pode vir em formatos diferentes: ordena pelo instante)
    samples.sort((a, b) => a.$1.compareTo(b.$1));

    final reading = books.where((b) => b.status == 'reading').toList()
      ..sort(LocalHomeRepository._byLastOpened);
    final heroAnnotations = reading.isEmpty
        ? 0
        : (await _all(
            'SELECT count(*) AS n FROM annotations '
            'WHERE user_id = ?1 AND user_book_id = ?2 AND deleted_at IS NULL',
            [_owner, reading.first.id],
          )).single.read<int>('n');

    // Grifos de hoje: só os criados de anteontem (UTC) para cá vêm do banco — o prefixo da data é o mesmo em
    // todos os formatos aceitos; o dia local de cada um é decidido aqui.
    final todayKey = _dayKey(today);
    var highlightsToday = 0;
    for (final r in await _all(
      'SELECT created_at FROM annotations WHERE user_id = ?1 AND deleted_at IS NULL '
      "AND kind = 'highlight' AND substr(created_at, 1, 10) >= ?2",
      [_owner, _dayKey(nowUtc.subtract(const Duration(days: 2)))],
    )) {
      final created = _instant(r.read<String>('created_at'));
      if (created != null && _localDay(created) == todayKey) highlightsToday++;
    }

    final goals = await _all(
      'SELECT daily_minutes, badge_target_days FROM reading_goals '
      'WHERE id = ?1 AND deleted_at IS NULL',
      [_owner],
    );

    return _Data(
      books: books,
      days: days,
      heroAnnotations: heroAnnotations,
      highlightsToday: highlightsToday,
      indexedChars: indexed,
      charsPerMinute: personalSpeed([for (final s in samples) s.$2]),
      goalMinutes: goals.isEmpty
          ? null
          : goals.single.read<int>('daily_minutes'),
      badgeTargetDays: goals.isEmpty
          ? null
          : goals.single.read<int>('badge_target_days'),
    );
  }
}

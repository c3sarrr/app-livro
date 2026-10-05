// Fonte real da Início (G08 — D-78, D-81…D-85, D-10): tudo lido do banco do aparelho, só as linhas do dono
// ativo (D-68) e sem linhas apagadas, com os dias no fuso do aparelho. Nada sai do aparelho; "Para você" e o
// Clube vêm das fontes injetadas.
import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../../core/data/database/app_database.dart';
import '../../../core/data/database/codecs.dart';
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
    this._users,
  });

  final Future<AppDatabase> Function() _database;
  final Future<String> Function() _owner;
  final UtcOffsetAt _utcOffsetAt;
  final ForYouSource? _forYou;
  final ClubTicketSource? _club;

  /// Usuário da conta: o fluxo começa com o atual (D-84).
  final Stream<UserSummary> Function()? _users;

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

  /// Janela das sessões que dão a velocidade pessoal do tempo restante (D-85).
  static const Duration speedWindow = Duration(days: 30);

  /// Um dia entra na sequência com pelo menos 1 minuto lido (D-85).
  static const int streakMinSeconds = 60;

  @override
  Stream<HomeSnapshot> watch(DateTime Function() clock) {
    late final StreamController<HomeSnapshot> out;
    StreamSubscription<void>? tables;
    StreamSubscription<UserSummary>? users;
    Timer? midnight;
    var user = guest;
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
          final s = await read(now, user: user);
          if (closed) return;
          out.add(s);
          midnight?.cancel();
          midnight = Timer(_untilNextLocalDay(now), refresh);
        } while (again && !closed);
      } on Object catch (e, st) {
        if (!closed) out.addError(e, st);
      } finally {
        running = false;
      }
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
                  db.annotations,
                  db.readingGoalsRows,
                  db.kv,
                  db.socialCache,
                ]),
              )
              .listen((_) => unawaited(refresh()));
          users = _users?.call().listen((u) {
            user = u;
            unawaited(refresh());
          });
          await refresh();
        } on Object catch (e, st) {
          if (!closed) out.addError(e, st);
        }
      },
      onCancel: () async {
        closed = true;
        midnight?.cancel();
        await tables?.cancel();
        await users?.cancel();
      },
    );
    return out.stream;
  }

  /// Tempo até a próxima meia-noite local (+1 s): a semana e a sequência andam sozinhas.
  Duration _untilNextLocalDay(DateTime now) {
    final utc = now.toUtc();
    final offset = _utcOffsetAt(utc);
    final local = utc.add(offset);
    final next = DateTime.utc(
      local.year,
      local.month,
      local.day + 1,
    ).subtract(offset);
    return next.difference(utc) + const Duration(seconds: 1);
  }

  /// Um instantâneo coerente (uma transação) para o "agora" [now].
  Future<HomeSnapshot> read(DateTime now, {UserSummary user = guest}) async {
    final db = await _database();
    final owner = await _owner();
    final utc = now.toUtc();
    final offset = _utcOffsetAt(utc);
    final local = utc.add(offset);
    final today = DateTime.utc(local.year, local.month, local.day);
    final modifier = '${offset.inMinutes} minutes';

    final data = await db.transaction(
      () => _Reader(db, owner, modifier).read(utc, today),
    );

    final reading = data.books.where((b) => b.status == 'reading').toList()
      ..sort(_byLastOpened);
    final hero = reading.isEmpty ? null : reading.first;
    final recent =
        data.books
            .where(
              (b) =>
                  b.lastOpenedAt == null &&
                  (b.status == 'want_to_read' || b.status == 'reading'),
            )
            .toList()
          ..sort((a, b) {
            final c = b.addedAt.compareTo(a.addedAt);
            return c != 0 ? c : b.id.compareTo(a.id);
          });

    final forYouSource = _forYou;
    final forYou = forYouSource == null || data.books.isEmpty
        ? null
        : await forYouSource.suggest(_forYouRequest(data.books));
    final club = await _club?.current(owner);

    return HomeSnapshot(
      now: DateTime(
        local.year,
        local.month,
        local.day,
        local.hour,
        local.minute,
      ),
      user: user,
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
              timeLeft: _timeLeft(hero, data.secondsPerPage),
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
            status: b.status == 'want_to_read'
                ? RecentStatus.wantToRead
                : RecentStatus.isNew,
          ),
      ]),
      shelfIsEmpty: data.books.isEmpty,
    );
  }

  /// Aberto mais recentemente primeiro (sem abertura: a posição, o início, a chegada).
  static int _byLastOpened(_ShelfBook a, _ShelfBook b) {
    final c = b.lastActivity.compareTo(a.lastActivity);
    return c != 0 ? c : b.id.compareTo(a.id);
  }

  /// Páginas de referência que faltam × segundos por página (D-85); sem dado → `null`.
  static Duration? _timeLeft(_ShelfBook b, double? secondsPerPage) {
    final pages = b.refPagesTotal;
    if (pages == null || secondsPerPage == null) return null;
    final remaining = pages * (1 - b.progress);
    return Duration(seconds: (remaining * secondsPerPage).round());
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
    cover: PhotoCover(ref: coverRef, isbn13: isbn13),
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
    required this.secondsPerPage,
    required this.goalMinutes,
    required this.badgeTargetDays,
  });

  final List<_ShelfBook> books;

  /// 'AAAA-MM-DD' local → soma do dia.
  final Map<String, _Day> days;
  final int heroAnnotations;
  final int highlightsToday;
  final double? secondsPerPage;
  final int? goalMinutes;
  final int? badgeTargetDays;
}

/// As consultas de um instantâneo (todas dentro da mesma transação).
final class _Reader {
  _Reader(this._db, this._owner, this._modifier);

  final AppDatabase _db;
  final String _owner;

  /// Modificador do SQLite para o dia local ("-180 minutes").
  final String _modifier;

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
        'b.ref_pages_total, b.cover_ref, b.isbn13, b.added_at, b.last_opened_at, b.started_at, '
        'p.chapter_index, CAST(p.progression AS REAL) AS progression, p.updated_at AS position_at '
        'FROM user_books b LEFT JOIN reading_positions p '
        'ON p.id = b.id AND p.user_id = b.user_id AND p.deleted_at IS NULL '
        'WHERE b.user_id = ?1 AND b.deleted_at IS NULL',
        [_owner],
      ))
        _ShelfBook(r),
    ];

    final days = <String, _Day>{
      for (final r in await _all(
        'SELECT date(started_at, ?2) AS d, sum(active_seconds) AS s, '
        'sum(coalesce(pages_viewed, 0)) AS p FROM reading_sessions '
        'WHERE user_id = ?1 AND deleted_at IS NULL GROUP BY d',
        [_owner, _modifier],
      ))
        r.read<String>('d'): (
          seconds: r.read<int>('s'),
          pages: r.read<int>('p'),
        ),
    };

    final reading = books.where((b) => b.status == 'reading').toList()
      ..sort(LocalHomeRepository._byLastOpened);
    final heroAnnotations = reading.isEmpty
        ? 0
        : (await _all(
            'SELECT count(*) AS n FROM annotations '
            'WHERE user_id = ?1 AND user_book_id = ?2 AND deleted_at IS NULL',
            [_owner, reading.first.id],
          )).single.read<int>('n');

    final todayKey =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    final highlightsToday = (await _all(
      "SELECT count(*) AS n FROM annotations WHERE user_id = ?1 AND deleted_at IS NULL "
      "AND kind = 'highlight' AND date(created_at, ?2) = ?3",
      [_owner, _modifier, todayKey],
    )).single.read<int>('n');

    final speed = (await _all(
      'SELECT sum(active_seconds) AS s, sum(pages_viewed) AS p FROM reading_sessions '
      'WHERE user_id = ?1 AND deleted_at IS NULL AND pages_viewed > 0 '
      'AND julianday(started_at) >= julianday(?2)',
      [_owner, formatInstant(nowUtc.subtract(LocalHomeRepository.speedWindow))],
    )).single;
    final speedSeconds = speed.readNullable<int>('s');
    final speedPages = speed.readNullable<int>('p');

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
      secondsPerPage:
          speedSeconds == null || speedPages == null || speedPages == 0
          ? null
          : speedSeconds / speedPages,
      goalMinutes: goals.isEmpty
          ? null
          : goals.single.read<int>('daily_minutes'),
      badgeTargetDays: goals.isEmpty
          ? null
          : goals.single.read<int>('badge_target_days'),
    );
  }
}

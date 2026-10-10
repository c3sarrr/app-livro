// Cópia profunda de um instantâneo da Início com instâncias novas (fora de `const`): o mesmo conteúdo em objetos
// diferentes, como o banco entrega a cada leitura. Usada pelos testes da igualdade dos modelos e das reconstruções.
// ignore_for_file: prefer_const_constructors
import 'package:app_leitura/features/home/domain/models.dart';

/// Cópia profunda com instâncias novas (fora de `const`), opcionalmente trocando partes.
HomeSnapshot copiaProfunda(
  HomeSnapshot s, {
  DateTime? now,
  ReadingDay? readingDay,
  List<AlsoReadingItem>? alsoReading,
  bool semRevisao = false,
  DailyReview? dailyReview,
  ForYou? forYou,
  BookClub? club,
  List<RecentItem>? recent,
}) {
  Book b(Book x) => Book(
    id: x.id,
    title: x.title,
    shortTitle: x.shortTitle,
    author: x.author,
    cover: x.cover,
  );
  final c = s.continueReading;
  final d = s.readingDay;
  final f = s.forYou;
  final k = s.club;
  final r = s.dailyReview;
  return HomeSnapshot(
    now: now ?? s.now,
    user: UserSummary(
      firstName: s.user.firstName,
      initial: s.user.initial,
      unreadNotifications: s.user.unreadNotifications,
    ),
    continueReading: c == null
        ? null
        : ContinueReading(
            book: b(c.book),
            progress: c.progress,
            timeLeft: c.timeLeft,
            highlightsCount: c.highlightsCount,
            format: c.format,
            refPage: c.refPage,
            refPagesTotal: c.refPagesTotal,
          ),
    alsoReading:
        alsoReading ??
        [
          for (final i in s.alsoReading)
            AlsoReadingItem(
              book: b(i.book),
              progress: i.progress,
              format: i.format,
              paperPage: i.paperPage,
              readTime: i.readTime,
            ),
        ],
    readingDay:
        readingDay ??
        ReadingDay(
          goalMinutes: d.goalMinutes,
          readMinutes: d.readMinutes,
          streakDays: d.streakDays,
          highlightsToday: d.highlightsToday,
          sessionsToday: d.sessionsToday,
          week: [
            for (final w in d.week)
              WeekDayStat(
                date: w.date,
                minutes: w.minutes,
                barHeightPx: w.barHeightPx,
                isToday: w.isToday,
              ),
          ],
          badgeTargetDays: d.badgeTargetDays,
        ),
    dailyReview: semRevisao || dailyReview != null || r == null
        ? dailyReview
        : DailyReview(
            highlights: r.highlights,
            minutes: r.minutes,
            bookTitles: [...r.bookTitles],
          ),
    forYou: forYou != null || f == null
        ? forYou
        : ForYou(
            reasonAuthor: f.reasonAuthor,
            items: [for (final i in f.items) b(i)],
          ),
    club: club != null || k == null
        ? club
        : BookClub(
            id: k.id,
            namePrefix: k.namePrefix,
            nameHighlight: k.nameHighlight,
            book: b(k.book),
            untilChapter: k.untilChapter,
            shownParticipants: [
              for (final p in k.shownParticipants)
                ClubParticipant(initial: p.initial, color: p.color),
            ],
            participantsCount: k.participantsCount,
            groupProgress: k.groupProgress,
            userProgress: k.userProgress,
            userInitial: k.userInitial,
            unreadMessages: k.unreadMessages,
            nextMeeting: k.nextMeeting,
          ),
    recent:
        recent ??
        [
          for (final i in s.recent)
            RecentItem(book: b(i.book), format: i.format, status: i.status),
        ],
    shelfIsEmpty: s.shelfIsEmpty,
  );
}

extension ClubeDaCopia on BookClub {
  /// O mesmo clube com outra contagem de mensagens novas.
  BookClub comMensagens(int unread) => BookClub(
    id: id,
    namePrefix: namePrefix,
    nameHighlight: nameHighlight,
    book: book,
    untilChapter: untilChapter,
    shownParticipants: shownParticipants,
    participantsCount: participantsCount,
    groupProgress: groupProgress,
    userProgress: userProgress,
    userInitial: userInitial,
    unreadMessages: unread,
    nextMeeting: nextMeeting,
  );
}

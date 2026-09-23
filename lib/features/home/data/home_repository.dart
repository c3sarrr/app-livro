import '../../../core/design_system/tokens/app_colors.dart';
import '../domain/models.dart';

/// Fonte dos dados da tela Início.
abstract interface class HomeRepository {
  HomeSnapshot snapshot(DateTime now);
}

/// Repositório mock síncrono com os dados EXATOS do arquivo (F02 2.2, D-09).
/// Sem estados de loading/erro/vazio: não existem no arquivo.
class HomeMockRepository implements HomeRepository {
  const HomeMockRepository();

  /// "Agora" de referência (D-09): domingo, 20/09/2026, 20:00 — coerente com "Boa noite,",
  /// semana S T Q Q S S + Hoje e encontro na quinta 24/09.
  static final DateTime referenceNow = DateTime(2026, 9, 20, 20);

  static const Book domCasmurro = Book(
    id: 'dom-casmurro',
    title: 'Dom Casmurro',
    author: 'Machado de Assis',
    cover: CoverArt.domCasmurro,
  );
  static const Book mrsDalloway = Book(
    id: 'mrs-dalloway',
    title: 'Mrs. Dalloway',
    author: 'Virginia Woolf',
    cover: CoverArt.mrsDalloway,
  );
  static const Book pridePrejudice = Book(
    id: 'orgulho-e-preconceito',
    title: 'Orgulho e Preconceito',
    author: 'Jane Austen',
    cover: CoverArt.pridePrejudice,
  );
  static const Book memoriasPostumas = Book(
    id: 'memorias-postumas-de-bras-cubas',
    title: 'Memórias Póstumas de Brás Cubas',
    shortTitle: 'Memórias Póstumas',
    author: 'Machado de Assis',
    cover: CoverArt.memoriasPostumas,
  );
  static const Book quincasBorba = Book(
    id: 'quincas-borba',
    title: 'Quincas Borba',
    author: 'Machado de Assis',
    cover: CoverArt.quincasBorba,
  );
  static const Book oCortico = Book(
    id: 'o-cortico',
    title: 'O Cortiço',
    author: 'Aluísio Azevedo',
    cover: CoverArt.oCortico,
  );
  static const Book frankenstein = Book(
    id: 'frankenstein',
    title: 'Frankenstein',
    author: 'Mary Shelley',
    cover: CoverArt.frankenstein,
  );
  static const Book oAlienista = Book(
    id: 'o-alienista',
    title: 'O Alienista',
    author: 'Machado de Assis',
    cover: CoverArt.oAlienista,
  );
  static const Book senhora = Book(
    id: 'senhora',
    title: 'Senhora',
    author: 'José de Alencar',
    cover: CoverArt.senhora,
  );

  /// Segunda 14/09 → domingo 20/09 (hoje). Alturas das barras = px do arquivo (D-10).
  static const List<({int day, int minutes, double barHeightPx})> _week = [
    (day: 14, minutes: 32, barHeightPx: 43),
    (day: 15, minutes: 45, barHeightPx: 60),
    (day: 16, minutes: 30, barHeightPx: 40),
    (day: 17, minutes: 22, barHeightPx: 30),
    (day: 18, minutes: 38, barHeightPx: 51),
    (day: 19, minutes: 55, barHeightPx: 73),
    (day: 20, minutes: 18, barHeightPx: 24),
  ];

  @override
  HomeSnapshot snapshot(DateTime now) => HomeSnapshot(
    now: now,
    user: const UserSummary(
      firstName: 'Marina',
      initial: 'M',
      unreadNotifications: 2,
    ),
    continueReading: const ContinueReading(
      book: domCasmurro,
      chapter: 92,
      totalChapters: 148,
      progress: 0.62,
      timeLeft: Duration(hours: 2, minutes: 10),
      highlightsCount: 14,
    ),
    alsoReading: const [
      AlsoReadingItem(book: mrsDalloway, progress: 0.34),
      AlsoReadingItem(book: pridePrejudice, progress: 0.81),
    ],
    readingDay: ReadingDay(
      goalMinutes: 30,
      readMinutes: 18,
      streakDays: 12,
      pagesToday: 24,
      highlightsToday: 2,
      week: List.unmodifiable([
        for (final d in _week)
          WeekDayStat(
            date: DateTime(2026, 9, d.day),
            minutes: d.minutes,
            barHeightPx: d.barHeightPx,
            isToday: d.day == 20,
          ),
      ]),
      badgeTargetDays: 14,
    ),
    forYou: const ForYou(
      reasonAuthor: 'Machado de Assis',
      items: [memoriasPostumas, quincasBorba, oCortico],
    ),
    club: BookClub(
      id: 'leitoras-de-capitu',
      namePrefix: 'Leitoras de',
      nameHighlight: 'Capitu',
      book: domCasmurro,
      untilChapter: 100,
      shownParticipants: const [
        ClubParticipant(initial: 'A', color: AppColors.lavender),
        ClubParticipant(initial: 'J', color: AppColors.leaf),
        ClubParticipant(initial: 'L', color: AppColors.blush),
      ],
      participantsCount: 11,
      groupProgress: 0.54,
      userProgress: 0.62,
      userInitial: 'M',
      unreadMessages: 3,
      nextMeeting: DateTime(2026, 9, 24, 20),
    ),
    recent: const [
      RecentItem(
        book: frankenstein,
        format: BookFormat.epub,
        status: RecentStatus.wantToRead,
      ),
      RecentItem(
        book: oAlienista,
        format: BookFormat.pdf,
        status: RecentStatus.wantToRead,
      ),
      RecentItem(
        book: senhora,
        format: BookFormat.epub,
        status: RecentStatus.isNew,
      ),
    ],
  );
}

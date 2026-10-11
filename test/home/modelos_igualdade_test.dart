// T03 · pendência 5 — os modelos da Início se comparam pelo conteúdo (`==` e `hashCode`), e um instantâneo novo
// reaproveita as instâncias do anterior nas partes iguais (`HomeSnapshot.reusing`): as seções observam recortes do
// instantâneo e só reconstroem quando o recorte muda (a prova na tela está em `reconstrucoes_test.dart`).
//
// As instâncias aqui são criadas fora de contexto `const` de propósito: duas chamadas iguais dão objetos diferentes
// (com `const` o Dart canonizaria e o teste compararia o objeto com ele mesmo).
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:ui' show Color;

import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/telas/inicio01.dart';
import '../support/copia_inicio.dart';

/// [base] é chamado duas vezes (objetos distintos e iguais); cada variante muda um único campo e tem de ser diferente.
void _igualdade<T extends Object>(
  String nome,
  T Function() base,
  Map<String, T> variantes,
) {
  test(
    '$nome: igual pelo conteúdo, diferente em cada campo (${variantes.keys.join(', ')})',
    () {
      final a = base();
      final b = base();
      expect(identical(a, b), isFalse);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      for (final MapEntry(key: campo, value: v) in variantes.entries) {
        expect(v == a, isFalse, reason: campo);
        expect(a == v, isFalse, reason: campo);
      }
    },
  );
}

Book _livro({
  String id = 'dom',
  String title = 'Dom Casmurro',
  String? shortTitle = 'Casmurro',
  String author = 'Machado de Assis',
  BookCover cover = const DesignedCover(CoverArt.domCasmurro),
}) => Book(
  id: id,
  title: title,
  shortTitle: shortTitle,
  author: author,
  cover: cover,
);

WeekDayStat _dia({
  DateTime? date,
  int minutes = 32,
  double barHeightPx = 40,
  bool isToday = false,
}) => WeekDayStat(
  date: date ?? DateTime(2026, 9, 14),
  minutes: minutes,
  barHeightPx: barHeightPx,
  isToday: isToday,
);

ClubParticipant _part({
  String initial = 'L',
  Color color = const Color(0xFFFFC1C6),
}) => ClubParticipant(initial: initial, color: color);

void main() {
  _igualdade('Book', _livro, {
    'id': _livro(id: 'outro'),
    'title': _livro(title: 'Outro'),
    'shortTitle': _livro(shortTitle: null),
    'author': _livro(author: 'Outra'),
    'cover': _livro(cover: const PhotoCover()),
  });

  UserSummary user({
    String? firstName = 'Marina',
    String? initial = 'M',
    int unread = 2,
  }) => UserSummary(
    firstName: firstName,
    initial: initial,
    unreadNotifications: unread,
  );
  _igualdade('UserSummary', user, {
    'firstName': user(firstName: null),
    'initial': user(initial: null),
    'unreadNotifications': user(unread: 0),
  });

  ContinueReading leitura({
    Book? book,
    double progress = 0.62,
    Duration? timeLeft = const Duration(minutes: 130),
    int highlightsCount = 12,
    BookFormat format = BookFormat.epub,
    int? refPage = 159,
    int? refPagesTotal = 256,
  }) => ContinueReading(
    book: book ?? _livro(),
    progress: progress,
    timeLeft: timeLeft,
    highlightsCount: highlightsCount,
    format: format,
    refPage: refPage,
    refPagesTotal: refPagesTotal,
  );
  _igualdade('ContinueReading', leitura, {
    'book': leitura(book: _livro(id: 'outro')),
    'progress': leitura(progress: 0.63),
    'timeLeft': leitura(timeLeft: null),
    'highlightsCount': leitura(highlightsCount: 13),
    'format': leitura(format: BookFormat.pdf),
    'refPage': leitura(refPage: 160),
    'refPagesTotal': leitura(refPagesTotal: null),
  });

  AlsoReadingItem item({
    Book? book,
    double progress = 0.81,
    BookFormat format = BookFormat.physical,
    int? paperPage = 344,
    Duration? readTime = const Duration(minutes: 220),
  }) => AlsoReadingItem(
    book: book ?? _livro(),
    progress: progress,
    format: format,
    paperPage: paperPage,
    readTime: readTime,
  );
  _igualdade('AlsoReadingItem', item, {
    'book': item(book: _livro(title: 'Outro')),
    'progress': item(progress: 0.8),
    'format': item(format: BookFormat.epub),
    'paperPage': item(paperPage: null),
    'readTime': item(readTime: const Duration(minutes: 221)),
  });

  _igualdade('WeekDayStat', _dia, {
    'date': _dia(date: DateTime(2026, 9, 15)),
    'minutes': _dia(minutes: 33),
    'barHeightPx': _dia(barHeightPx: 41),
    'isToday': _dia(isToday: true),
  });

  ReadingDay dia({
    int goal = 30,
    int read = 18,
    int streak = 12,
    int highlights = 2,
    int sessions = 2,
    List<WeekDayStat>? week,
    int badge = 14,
  }) => ReadingDay(
    goalMinutes: goal,
    readMinutes: read,
    streakDays: streak,
    highlightsToday: highlights,
    sessionsToday: sessions,
    week: week ?? [_dia(), _dia(minutes: 45, isToday: true)],
    badgeTargetDays: badge,
  );
  _igualdade('ReadingDay', dia, {
    'goalMinutes': dia(goal: 31),
    'readMinutes': dia(read: 19),
    'streakDays': dia(streak: 13),
    'highlightsToday': dia(highlights: 3),
    'sessionsToday': dia(sessions: 3),
    'week (um dia)': dia(week: [_dia(), _dia(minutes: 46, isToday: true)]),
    'week (tamanho)': dia(week: [_dia()]),
    'badgeTargetDays': dia(badge: 21),
  });

  ForYou paraVoce({String reason = 'Machado de Assis', List<Book>? items}) =>
      ForYou(
        reasonAuthor: reason,
        items: items ?? [_livro(), _livro(id: 'b')],
      );
  _igualdade('ForYou', paraVoce, {
    'reasonAuthor': paraVoce(reason: 'Jane Austen'),
    'items (ordem)': paraVoce(
      items: [
        _livro(id: 'b'),
        _livro(),
      ],
    ),
    'items (tamanho)': paraVoce(items: [_livro()]),
  });

  _igualdade('ClubParticipant', _part, {
    'initial': _part(initial: 'J'),
    'color': _part(color: const Color(0xFFABCF82)),
  });

  BookClub clube({
    String id = 'capitu',
    String prefix = 'Leitoras de',
    String highlight = 'Capitu',
    Book? book,
    int until = 100,
    List<ClubParticipant>? shown,
    int count = 11,
    double group = 0.54,
    double userP = 0.62,
    String userInitial = 'M',
    int unread = 3,
    DateTime? meeting,
  }) => BookClub(
    id: id,
    namePrefix: prefix,
    nameHighlight: highlight,
    book: book ?? _livro(),
    untilChapter: until,
    shownParticipants: shown ?? [_part(), _part(initial: 'J')],
    participantsCount: count,
    groupProgress: group,
    userProgress: userP,
    userInitial: userInitial,
    unreadMessages: unread,
    nextMeeting: meeting ?? DateTime(2026, 9, 24, 20),
  );
  _igualdade('BookClub', clube, {
    'id': clube(id: 'outro'),
    'namePrefix': clube(prefix: 'Leitores de'),
    'nameHighlight': clube(highlight: 'Bentinho'),
    'book': clube(book: _livro(author: 'Outra')),
    'untilChapter': clube(until: 101),
    'shownParticipants': clube(
      shown: [
        _part(),
        _part(initial: 'K'),
      ],
    ),
    'participantsCount': clube(count: 12),
    'groupProgress': clube(group: 0.55),
    'userProgress': clube(userP: 0.63),
    'userInitial': clube(userInitial: 'N'),
    'unreadMessages': clube(unread: 4),
    'nextMeeting': clube(meeting: DateTime(2026, 9, 24, 21)),
  });

  RecentItem recente({
    Book? book,
    BookFormat format = BookFormat.epub,
    RecentStatus status = RecentStatus.isNew,
  }) => RecentItem(book: book ?? _livro(), format: format, status: status);
  _igualdade('RecentItem', recente, {
    'book': recente(book: _livro(shortTitle: 'Outro')),
    'format': recente(format: BookFormat.physical),
    'status': recente(status: RecentStatus.read),
  });

  DailyReview revisao({
    int highlights = 5,
    int minutes = 2,
    List<String>? titles,
  }) => DailyReview(
    highlights: highlights,
    minutes: minutes,
    bookTitles: titles ?? ['Dom Casmurro', 'Iracema'],
  );
  _igualdade('DailyReview', revisao, {
    'highlights': revisao(highlights: 6),
    'minutes': revisao(minutes: 3),
    'bookTitles': revisao(titles: ['Dom Casmurro', 'Senhora']),
  });

  group('HomeSnapshot.reusing', () {
    final agora = TelaInicio01.agora;

    test('tudo igual (instâncias novas): cada parte volta a ser a instância do anterior; o relógio é o novo', () {
      final antes = TelaInicio01.snapshot(agora);
      final novo = copiaProfunda(
        antes,
        now: agora.add(const Duration(minutes: 1)),
      );
      expect(identical(novo.readingDay, antes.readingDay), isFalse);
      expect(identical(novo.alsoReading, antes.alsoReading), isFalse);
      final r = novo.reusing(antes);
      expect(r.now, novo.now);
      expect(r.user, same(antes.user));
      expect(r.continueReading, same(antes.continueReading));
      expect(r.alsoReading, same(antes.alsoReading));
      expect(r.readingDay, same(antes.readingDay));
      expect(r.dailyReview, same(antes.dailyReview));
      expect(r.forYou, same(antes.forYou));
      expect(r.club, same(antes.club));
      expect(r.recent, same(antes.recent));
      expect(r.shelfIsEmpty, novo.shelfIsEmpty);
    });

    test('uma parte mudou: só ela é a nova; as listas comparam item a item; null fica null', () {
      final antes = TelaInicio01.snapshot(agora);
      final d = antes.readingDay;
      final hoje = ReadingDay(
        goalMinutes: d.goalMinutes,
        readMinutes: d.readMinutes + 1,
        streakDays: d.streakDays,
        highlightsToday: d.highlightsToday,
        sessionsToday: d.sessionsToday,
        week: d.week,
        badgeTargetDays: d.badgeTargetDays,
      );
      final [a, b, ...resto] = antes.alsoReading;
      final lendo = [b, a, ...resto];
      final novo = copiaProfunda(
        antes,
        readingDay: hoje,
        alsoReading: lendo,
        semRevisao: true,
      ).reusing(antes);
      expect(novo.readingDay, same(hoje));
      expect(novo.alsoReading, same(lendo));
      expect(novo.dailyReview, isNull);
      expect(novo.continueReading, same(antes.continueReading));
      expect(novo.recent, same(antes.recent));
      // e de volta: o anterior sem revisão não impede a nova de entrar
      final volta = antes.reusing(novo);
      expect(volta.dailyReview, same(antes.dailyReview));
    });
  });
}

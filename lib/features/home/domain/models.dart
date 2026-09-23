import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;

// Dados crus da tela Início (F02 2.1). Nenhum texto já formatado: os únicos textos são nomes e
// títulos; rótulos, contagens, datas e durações são montados em `application/formatters.dart`.

/// Arte de capa de cada livro do arquivo (cada uma é uma ilustração própria nas fases das seções).
enum CoverArt {
  domCasmurro,
  mrsDalloway,
  pridePrejudice,
  memoriasPostumas,
  quincasBorba,
  oCortico,
  frankenstein,
  oAlienista,
  senhora,
}

/// Formato do arquivo do livro (rótulo "EPUB"/"PDF" só no formatador).
enum BookFormat { epub, pdf }

/// Situação de um livro recém-chegado (rótulo "Quero ler"/"Novo" só no formatador).
enum RecentStatus { wantToRead, isNew }

@immutable
class Book {
  const Book({
    required this.id,
    required this.title,
    this.shortTitle,
    required this.author,
    required this.cover,
  });

  final String id;
  final String title;

  /// Título curto usado onde o arquivo abrevia (ex.: "Memórias Póstumas").
  final String? shortTitle;
  final String author;
  final CoverArt cover;
}

@immutable
class UserSummary {
  const UserSummary({
    required this.firstName,
    required this.initial,
    required this.unreadNotifications,
  });

  final String firstName;
  final String initial;
  final int unreadNotifications;
}

@immutable
class ContinueReading {
  const ContinueReading({
    required this.book,
    required this.chapter,
    required this.totalChapters,
    required this.progress,
    required this.timeLeft,
    required this.highlightsCount,
  });

  final Book book;
  final int chapter;
  final int totalChapters;

  /// Fração lida (0–1).
  final double progress;

  /// Tempo estimado para terminar o livro.
  final Duration timeLeft;
  final int highlightsCount;
}

@immutable
class AlsoReadingItem {
  const AlsoReadingItem({required this.book, required this.progress});

  final Book book;

  /// Fração lida (0–1).
  final double progress;
}

@immutable
class WeekDayStat {
  const WeekDayStat({
    required this.date,
    required this.minutes,
    required this.barHeightPx,
    required this.isToday,
  });

  final DateTime date;
  final int minutes;

  /// Altura da barra no gráfico da semana, em px (D-10).
  final double barHeightPx;
  final bool isToday;
}

@immutable
class ReadingDay {
  const ReadingDay({
    required this.goalMinutes,
    required this.readMinutes,
    required this.streakDays,
    required this.pagesToday,
    required this.highlightsToday,
    required this.week,
    required this.badgeTargetDays,
  });

  final int goalMinutes;
  final int readMinutes;
  final int streakDays;
  final int pagesToday;
  final int highlightsToday;

  /// Segunda → hoje (7 dias).
  final List<WeekDayStat> week;

  /// Sequência de dias que dá o selo.
  final int badgeTargetDays;
}

@immutable
class ForYou {
  const ForYou({required this.reasonAuthor, required this.items});

  /// Autor do motivo da recomendação ("Porque você lê …").
  final String reasonAuthor;
  final List<Book> items;
}

@immutable
class ClubParticipant {
  const ClubParticipant({required this.initial, required this.color});

  final String initial;
  final Color color;
}

@immutable
class BookClub {
  const BookClub({
    required this.id,
    required this.namePrefix,
    required this.nameHighlight,
    required this.book,
    required this.untilChapter,
    required this.shownParticipants,
    required this.participantsCount,
    required this.groupProgress,
    required this.userProgress,
    required this.userInitial,
    required this.unreadMessages,
    required this.nextMeeting,
  });

  final String id;

  /// Nome do clube em duas partes com estilos diferentes ("Leitoras de" + "Capitu").
  final String namePrefix;
  final String nameHighlight;
  final Book book;

  /// Capítulo-limite da leitura do grupo.
  final int untilChapter;
  final List<ClubParticipant> shownParticipants;

  /// Total de participantes (inclui os exibidos).
  final int participantsCount;

  /// Frações lidas (0–1).
  final double groupProgress;
  final double userProgress;
  final String userInitial;
  final int unreadMessages;
  final DateTime nextMeeting;
}

@immutable
class RecentItem {
  const RecentItem({
    required this.book,
    required this.format,
    required this.status,
  });

  final Book book;
  final BookFormat format;
  final RecentStatus status;
}

@immutable
class HomeSnapshot {
  const HomeSnapshot({
    required this.now,
    required this.user,
    required this.continueReading,
    required this.alsoReading,
    required this.readingDay,
    required this.forYou,
    required this.club,
    required this.recent,
  });

  /// "Agora" usado na formatação (saudação etc.).
  final DateTime now;
  final UserSummary user;
  final ContinueReading continueReading;
  final List<AlsoReadingItem> alsoReading;
  final ReadingDay readingDay;
  final ForYou forYou;
  final BookClub club;
  final List<RecentItem> recent;
}

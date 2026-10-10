import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;

// Dados crus da tela Início (F02 2.1). Nenhum texto já formatado: os únicos textos são nomes e
// títulos; rótulos, contagens, datas e durações são montados em `application/formatters.dart`.

/// Arte de capa de cada livro do arquivo (cada uma é uma ilustração própria nas fases das seções).
/// Só a fixture do mundo de referência usa (D-34); livro real tem foto (D-79).
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

  /// Prancha 01 (T03): o Brás Cubas de cartola do Também lendo e as 3 recomendações do Para você.
  brasCubas,
  esauEJaco,
  memorialDeAires,
  casaDePensao,
}

/// Formato do livro (rótulos "EPUB"/"PDF"/"Papel" e o selo "E-BOOK"/"PDF"/"PAPEL" só no formatador).
/// `physical` = livro de papel (exemplar escaneado — D-85).
enum BookFormat { epub, pdf, physical }

/// Situação de um livro recém-chegado (rótulo "Quero ler"/"Novo"/"Lido" só no formatador — D-88, D-255).
enum RecentStatus { wantToRead, isNew, read }

/// Capa de um livro: a arte desenhada do arquivo ([DesignedCover], só a fixture) ou a foto real
/// ([PhotoCover], D-79). Sem foto disponível, a seção desenha a capa gerada a partir do título e do autor.
@immutable
sealed class BookCover {
  const BookCover();
}

/// Arte desenhada do arquivo.
final class DesignedCover extends BookCover {
  const DesignedCover(this.art);

  final CoverArt art;

  @override
  bool operator ==(Object other) => other is DesignedCover && other.art == art;

  @override
  int get hashCode => art.hashCode;
}

/// Foto real (D-79): a capa que veio dentro do arquivo do livro ([fileSha], o sha256 do arquivo — D-90, sem
/// rede), [ref] da fonte (`ol:<id>` ou URL https da API externa) e/ou [isbn13] (recuo pelo ISBN no Open
/// Library). Todos podem faltar: a capa gerada é o que aparece.
final class PhotoCover extends BookCover {
  const PhotoCover({this.ref, this.isbn13, this.fileSha});

  final String? ref;
  final String? isbn13;
  final String? fileSha;

  @override
  bool operator ==(Object other) =>
      other is PhotoCover &&
      other.ref == ref &&
      other.isbn13 == isbn13 &&
      other.fileSha == fileSha;

  @override
  int get hashCode => Object.hash(ref, isbn13, fileSha);
}

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
  final BookCover cover;
}

@immutable
class UserSummary {
  const UserSummary({
    this.firstName,
    this.initial,
    required this.unreadNotifications,
  });

  /// Primeiro nome do perfil; `null` = convidado (D-84).
  final String? firstName;

  /// Inicial do avatar; `null` = convidado (ícone de pessoa).
  final String? initial;
  final int unreadNotifications;
}

@immutable
class ContinueReading {
  const ContinueReading({
    required this.book,
    this.chapter,
    this.totalChapters,
    required this.progress,
    this.timeLeft,
    required this.highlightsCount,
    this.format = BookFormat.epub,
    this.refPage,
    this.refPagesTotal,
  });

  final Book book;

  /// Formato do exemplar: o físico não abre o leitor — "Continuar lendo" leva à página do livro (D-123).
  final BookFormat format;

  /// Capítulo atual e total; `null` quando o livro não tem capítulos (a pílula some).
  final int? chapter;
  final int? totalChapters;

  /// Fração lida (0–1).
  final double progress;

  /// Tempo estimado para terminar o livro; `null` sem sessões para estimar (o rótulo some — D-85).
  final Duration? timeLeft;
  final int highlightsCount;

  /// Página de referência atual e total (G10) — a pílula "pág. 159 de 256"; sem um dos dois, a pílula some
  /// (D-254).
  final int? refPage;
  final int? refPagesTotal;
}

@immutable
class AlsoReadingItem {
  const AlsoReadingItem({
    required this.book,
    required this.progress,
    required this.format,
    this.paperPage,
    this.readTime,
  });

  final Book book;

  /// Fração lida (0–1).
  final double progress;
  final BookFormat format;

  /// Livro de papel: a página registrada (o cartão mostra o anel e "Papel · pág. N" — D-253); `null` = sem
  /// página (o "play" e o tempo já lido).
  final int? paperPage;

  /// Livro de papel: o tempo já lido, a soma das sessões do livro (D-252); `null` = nenhuma sessão.
  final Duration? readTime;
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
    required this.sessionsToday,
    required this.week,
    required this.badgeTargetDays,
  });

  final int goalMinutes;
  final int readMinutes;
  final int streakDays;
  final int pagesToday;
  final int highlightsToday;

  /// Sessões de leitura que começaram hoje (dia local) — "2 sessões".
  final int sessionsToday;

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

/// A revisão dos grifos do dia ("Seus grifos de hoje"). Só a fixture tem até a T05 (D-247).
@immutable
class DailyReview {
  const DailyReview({
    required this.highlights,
    required this.minutes,
    required this.bookTitles,
  });

  /// Grifos do baralho do dia e o tempo estimado ("5 GRIFOS · 2 MIN").
  final int highlights;
  final int minutes;

  /// Livros de onde os grifos vêm, na ordem do subtítulo (ao menos um).
  final List<String> bookTitles;
}

@immutable
class HomeSnapshot {
  const HomeSnapshot({
    required this.now,
    required this.user,
    required this.continueReading,
    required this.alsoReading,
    required this.readingDay,
    required this.dailyReview,
    required this.forYou,
    required this.club,
    required this.recent,
    this.shelfIsEmpty = false,
  });

  /// "Agora" usado na formatação (saudação etc.).
  final DateTime now;
  final UserSummary user;

  /// `null` = nenhum livro em leitura: o herói vira convite (D-78).
  final ContinueReading? continueReading;

  /// Todos os outros livros em leitura; a seção mostra até 2 e conta todos (D-85). Vazia → some.
  final List<AlsoReadingItem> alsoReading;

  /// Existe sempre (zerado sem leitura — D-78).
  final ReadingDay readingDay;

  /// `null` → o cartão "Seus grifos de hoje" some (com dados reais até a T05 — D-247).
  final DailyReview? dailyReview;

  /// `null` → a seção some (D-81).
  final ForYou? forYou;

  /// `null` → o ticket some (D-80).
  final BookClub? club;

  /// Vazia → a seção some.
  final List<RecentItem> recent;

  /// Nenhum livro na estante do dono ativo: escolhe a frase do convite (D-78/D-85).
  final bool shelfIsEmpty;

  /// O mesmo instantâneo com outro cabeçalho (a conta — D-84); as seções continuam as mesmas instâncias.
  HomeSnapshot withUser(UserSummary user) => HomeSnapshot(
    now: now,
    user: user,
    continueReading: continueReading,
    alsoReading: alsoReading,
    readingDay: readingDay,
    dailyReview: dailyReview,
    forYou: forYou,
    club: club,
    recent: recent,
    shelfIsEmpty: shelfIsEmpty,
  );
}

import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable, listEquals;

// Dados crus da tela Início (F02 2.1). Nenhum texto já formatado: os únicos textos são nomes e
// títulos; rótulos, contagens, datas e durações são montados em `application/formatters.dart`.
// Os modelos se comparam pelo conteúdo (listas item a item): as seções observam recortes do instantâneo e só
// reconstroem quando o recorte muda (pendência 5 da T03; ver [HomeSnapshot.reusing]).

/// Arte de capa de cada livro que a prancha 01 desenha (cada uma é uma ilustração própria nas fases das seções).
/// Só a fixture do mundo de referência usa (D-34); livro real tem foto (D-79). As artes que só a v1 desenhava (Mrs.
/// Dalloway e o trio Memórias Póstumas · Quincas Borba · O Cortiço) saíram no fim da T03.
enum CoverArt {
  domCasmurro,
  pridePrejudice,
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

  @override
  bool operator ==(Object other) =>
      other is Book &&
      other.id == id &&
      other.title == title &&
      other.shortTitle == shortTitle &&
      other.author == author &&
      other.cover == cover;

  @override
  int get hashCode => Object.hash(id, title, shortTitle, author, cover);
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

  @override
  bool operator ==(Object other) =>
      other is UserSummary &&
      other.firstName == firstName &&
      other.initial == initial &&
      other.unreadNotifications == unreadNotifications;

  @override
  int get hashCode => Object.hash(firstName, initial, unreadNotifications);
}

@immutable
class ContinueReading {
  const ContinueReading({
    required this.book,
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

  /// Fração lida (0–1).
  final double progress;

  /// Tempo estimado para terminar o livro; `null` sem sessões para estimar (o rótulo some — D-85).
  final Duration? timeLeft;
  final int highlightsCount;

  /// Página de referência atual e total (G10) — a pílula "pág. 159 de 256"; sem um dos dois, a pílula some
  /// (D-254).
  final int? refPage;
  final int? refPagesTotal;

  @override
  bool operator ==(Object other) =>
      other is ContinueReading &&
      other.book == book &&
      other.format == format &&
      other.progress == progress &&
      other.timeLeft == timeLeft &&
      other.highlightsCount == highlightsCount &&
      other.refPage == refPage &&
      other.refPagesTotal == refPagesTotal;

  @override
  int get hashCode => Object.hash(
    book,
    format,
    progress,
    timeLeft,
    highlightsCount,
    refPage,
    refPagesTotal,
  );
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

  @override
  bool operator ==(Object other) =>
      other is AlsoReadingItem &&
      other.book == book &&
      other.progress == progress &&
      other.format == format &&
      other.paperPage == paperPage &&
      other.readTime == readTime;

  @override
  int get hashCode => Object.hash(book, progress, format, paperPage, readTime);
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

  @override
  bool operator ==(Object other) =>
      other is WeekDayStat &&
      other.date == date &&
      other.minutes == minutes &&
      other.barHeightPx == barHeightPx &&
      other.isToday == isToday;

  @override
  int get hashCode => Object.hash(date, minutes, barHeightPx, isToday);
}

@immutable
class ReadingDay {
  const ReadingDay({
    required this.goalMinutes,
    required this.readMinutes,
    required this.streakDays,
    required this.highlightsToday,
    required this.sessionsToday,
    required this.week,
    required this.badgeTargetDays,
  });

  final int goalMinutes;
  final int readMinutes;
  final int streakDays;
  final int highlightsToday;

  /// Sessões de leitura que começaram hoje (dia local) — "2 sessões".
  final int sessionsToday;

  /// Segunda → hoje (7 dias).
  final List<WeekDayStat> week;

  /// Sequência de dias que dá o selo.
  final int badgeTargetDays;

  @override
  bool operator ==(Object other) =>
      other is ReadingDay &&
      other.goalMinutes == goalMinutes &&
      other.readMinutes == readMinutes &&
      other.streakDays == streakDays &&
      other.highlightsToday == highlightsToday &&
      other.sessionsToday == sessionsToday &&
      other.badgeTargetDays == badgeTargetDays &&
      listEquals(other.week, week);

  @override
  int get hashCode => Object.hash(
    goalMinutes,
    readMinutes,
    streakDays,
    highlightsToday,
    sessionsToday,
    badgeTargetDays,
    Object.hashAll(week),
  );
}

@immutable
class ForYou {
  const ForYou({required this.reasonAuthor, required this.items});

  /// Autor do motivo da recomendação ("Porque você lê …").
  final String reasonAuthor;
  final List<Book> items;

  @override
  bool operator ==(Object other) =>
      other is ForYou &&
      other.reasonAuthor == reasonAuthor &&
      listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(reasonAuthor, Object.hashAll(items));
}

@immutable
class ClubParticipant {
  const ClubParticipant({required this.initial, required this.color});

  final String initial;
  final Color color;

  @override
  bool operator ==(Object other) =>
      other is ClubParticipant &&
      other.initial == initial &&
      other.color == color;

  @override
  int get hashCode => Object.hash(initial, color);
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

  @override
  bool operator ==(Object other) =>
      other is BookClub &&
      other.id == id &&
      other.namePrefix == namePrefix &&
      other.nameHighlight == nameHighlight &&
      other.book == book &&
      other.untilChapter == untilChapter &&
      other.participantsCount == participantsCount &&
      other.groupProgress == groupProgress &&
      other.userProgress == userProgress &&
      other.userInitial == userInitial &&
      other.unreadMessages == unreadMessages &&
      other.nextMeeting == nextMeeting &&
      listEquals(other.shownParticipants, shownParticipants);

  @override
  int get hashCode => Object.hash(
    id,
    namePrefix,
    nameHighlight,
    book,
    untilChapter,
    participantsCount,
    groupProgress,
    userProgress,
    userInitial,
    unreadMessages,
    nextMeeting,
    Object.hashAll(shownParticipants),
  );
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

  @override
  bool operator ==(Object other) =>
      other is RecentItem &&
      other.book == book &&
      other.format == format &&
      other.status == status;

  @override
  int get hashCode => Object.hash(book, format, status);
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

  /// Livros de onde os grifos vêm, na ordem do subtítulo.
  final List<String> bookTitles;

  /// Nada a revisar: sem grifos ou sem livros de onde eles venham. Uma revisão vazia é "sem revisão" — o cartão
  /// some como no `null` (pendência 4 da T03): nunca "REVISÃO · 0 GRIFOS" nem o subtítulo sem livro.
  bool get isEmpty => highlights == 0 || bookTitles.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is DailyReview &&
      other.highlights == highlights &&
      other.minutes == minutes &&
      listEquals(other.bookTitles, bookTitles);

  @override
  int get hashCode =>
      Object.hash(highlights, minutes, Object.hashAll(bookTitles));
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

  /// A revisão que a Início mostra: `null` sem baralho (D-247) ou com o baralho vazio ([DailyReview.isEmpty]).
  DailyReview? get visibleReview =>
      dailyReview == null || dailyReview!.isEmpty ? null : dailyReview;

  /// `null` → a seção some (D-81).
  final ForYou? forYou;

  /// `null` → o ticket some (D-80).
  final BookClub? club;

  /// Vazia → a seção some.
  final List<RecentItem> recent;

  /// Nenhum livro na estante do dono ativo: escolhe a frase do convite (D-78/D-85).
  final bool shelfIsEmpty;

  /// Este instantâneo com as partes iguais às de [previous] trocadas pelas instâncias dele (as listas comparadas
  /// item a item). O banco entrega objetos novos a cada leitura; com isto, a seção cujo recorte não mudou recebe o
  /// mesmo objeto e não reconstrói (nem compara de novo nas leituras seguintes). O relógio é sempre o novo.
  HomeSnapshot reusing(HomeSnapshot previous) {
    T keep<T>(T current, T before) => current == before ? before : current;
    List<T> keepList<T>(List<T> current, List<T> before) =>
        listEquals(current, before) ? before : current;
    return HomeSnapshot(
      now: now,
      user: keep(user, previous.user),
      continueReading: keep(continueReading, previous.continueReading),
      alsoReading: keepList(alsoReading, previous.alsoReading),
      readingDay: keep(readingDay, previous.readingDay),
      dailyReview: keep(dailyReview, previous.dailyReview),
      forYou: keep(forYou, previous.forYou),
      club: keep(club, previous.club),
      recent: keepList(recent, previous.recent),
      shelfIsEmpty: shelfIsEmpty,
    );
  }

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

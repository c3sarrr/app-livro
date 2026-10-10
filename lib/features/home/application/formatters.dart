import '../domain/models.dart';

/// Frase com um trecho em negrito no meio (`<strong>` do arquivo): `before` + **`strong`** + `after`.
typedef EmphasisText = ({String before, String strong, String after});

/// Dados → textos EXATOS do arquivo (F02 2.3). Sem `intl` (que produz "qui." e "set."): as
/// abreviações e os nomes de dia/mês do arquivo estão abaixo. Índices: `DateTime.weekday` 1 = segunda
/// … 7 = domingo; `DateTime.month` 1 = janeiro.
abstract final class HomeFormatters {
  static const List<String> _weekdayShort = [
    'SEG',
    'TER',
    'QUA',
    'QUI',
    'SEX',
    'SÁB',
    'DOM',
  ];
  static const List<String> _weekdayInitial = [
    'S',
    'T',
    'Q',
    'Q',
    'S',
    'S',
    'D',
  ];
  static const List<String> _weekdayName = [
    'segunda',
    'terça',
    'quarta',
    'quinta',
    'sexta',
    'sábado',
    'domingo',
  ];
  static const List<String> _monthShort = [
    'JAN',
    'FEV',
    'MAR',
    'ABR',
    'MAI',
    'JUN',
    'JUL',
    'AGO',
    'SET',
    'OUT',
    'NOV',
    'DEZ',
  ];
  static const List<String> _monthName = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  /// 5–11 h "Bom dia,"; 12–17 h "Boa tarde,"; 18–4 h "Boa noite,". Sem nome embaixo (convidado — D-84),
  /// sem a vírgula: "Boa noite".
  static String greeting(DateTime now, {bool named = true}) {
    final g = switch (now.hour) {
      >= 5 && <= 11 => 'Bom dia',
      >= 12 && <= 17 => 'Boa tarde',
      _ => 'Boa noite',
    };
    return named ? '$g,' : g;
  }

  /// "Cap. 92 de 148".
  static String chapterLabel(int chapter, int totalChapters) =>
      'Cap. $chapter de $totalChapters';

  /// Página de referência no herói (D-254): "pág. 159 de 256".
  static String pageLabel(int page, int totalPages) =>
      'pág. $page de $totalPages';

  /// Selo do formato no herói (D-254): "E-BOOK" · "PDF" · "PAPEL".
  static String formatBadge(BookFormat format) => switch (format) {
    BookFormat.epub => 'E-BOOK',
    BookFormat.pdf => 'PDF',
    BookFormat.physical => 'PAPEL',
  };

  /// Pílula do livro de papel no Também lendo (D-252, D-253): com página, "Papel · pág. 344"; sem página, o
  /// tempo já lido ("Papel · 3h 40min"); sem nenhuma sessão, só "Papel".
  static String paperMeta({int? page, Duration? readTime}) {
    final label = formatLabel(BookFormat.physical);
    if (page != null) return '$label · pág. $page';
    if (readTime != null) return '$label · ${durationLabel(readTime)}';
    return label;
  }

  /// Título onde a prancha abrevia ("Brás Cubas"); sem título curto, o título.
  static String bookTitleShort(Book book) => book.shortTitle ?? book.title;

  /// 0,62 → "62%".
  static String percent(double progress) => '${(progress * 100).round()}%';

  /// Padrão do arquivo `Xh MMmin` (minutos com 2 dígitos): 130 min → "2h 10min"; 240 → "4h 00min".
  /// `approx` acrescenta o "~" da estimativa ("~2h 10min").
  static String durationLabel(Duration duration, {bool approx = false}) {
    final minutes = duration.inMinutes;
    final hours = minutes ~/ 60;
    final rest = (minutes % 60).toString().padLeft(2, '0');
    return '${approx ? '~' : ''}${hours}h ${rest}min';
  }

  /// Soma da semana: "4h 00min no total".
  static String weekTotalLabel(Iterable<WeekDayStat> week) {
    final total = week.fold<int>(0, (sum, d) => sum + d.minutes);
    return '${durationLabel(Duration(minutes: total))} no total';
  }

  /// "Faltam " + **"12 min"** + " para fechar a meta de hoje."; meta batida → "Meta de hoje cumprida."
  /// (D-83 — estado que o arquivo não desenha).
  static EmphasisText remainingGoal(int goalMinutes, int readMinutes) =>
      readMinutes >= goalMinutes
      ? (before: 'Meta de hoje cumprida.', strong: '', after: '')
      : (
          before: 'Faltam ',
          strong: '${goalMinutes - readMinutes} min',
          after: ' para fechar a meta de hoje.',
        );

  /// "24 páginas", "2 destaques", "12 dias" (singular só para 1).
  static String countLabel(int count, String singular, String plural) =>
      '$count ${count == 1 ? singular : plural}';

  /// Sessões de hoje: "2 sessões" · "1 sessão".
  static String sessionsLabel(int sessions) =>
      countLabel(sessions, 'sessão', 'sessões');

  /// Cabeçalho do cartão da revisão: "REVISÃO · 5 GRIFOS · 2 MIN".
  static String reviewKicker(int highlights, int minutes) =>
      'REVISÃO · ${countLabel(highlights, 'GRIFO', 'GRIFOS')} · $minutes MIN';

  /// De onde vêm os grifos da revisão: "De Dom Casmurro, Quincas Borba e Iracema.".
  static String reviewSubtitle(List<String> bookTitles) {
    assert(bookTitles.isNotEmpty, 'a revisão tem ao menos um livro');
    final last = bookTitles.last;
    final rest = bookTitles.sublist(0, bookTitles.length - 1);
    return rest.isEmpty ? 'De $last.' : 'De ${rest.join(', ')} e $last.';
  }

  /// "Mais " + **"2 dias"** + " para o selo de 14 dias"; selo alcançado → "Selo de " + **"14 dias"** +
  /// " conquistado" (D-83 — estado que o arquivo não desenha).
  static EmphasisText badgeHint(int streakDays, int badgeTargetDays) {
    final target = countLabel(badgeTargetDays, 'dia', 'dias');
    if (streakDays >= badgeTargetDays) {
      return (before: 'Selo de ', strong: target, after: ' conquistado');
    }
    return (
      before: 'Mais ',
      strong: countLabel(badgeTargetDays - streakDays, 'dia', 'dias'),
      after: ' para o selo de $target',
    );
  }

  /// Rótulos do gráfico da semana: inicial do dia ("S T Q Q S S") e "Hoje" no dia atual.
  static List<String> weekInitials(Iterable<WeekDayStat> week) => [
    for (final d in week)
      d.isToday ? 'Hoje' : _weekdayInitial[d.date.weekday - 1],
  ];

  /// "Minutos lidos por dia: segunda 32, terça 45, …, sábado 55, hoje 18 de 30".
  static String weekAria(Iterable<WeekDayStat> week, int goalMinutes) {
    final days = [
      for (final d in week)
        d.isToday
            ? 'hoje ${d.minutes} de $goalMinutes'
            : '${_weekdayName[d.date.weekday - 1]} ${d.minutes}',
    ];
    return 'Minutos lidos por dia: ${days.join(', ')}';
  }

  /// Motivo da recomendação: "Porque você lê Machado de Assis".
  static String forYouReason(String author) => 'Porque você lê $author';

  /// Participantes além dos avatares exibidos: 11 − 3 → "+8".
  static String participantsExtra(int participantsCount, int shown) =>
      '+${participantsCount - shown}';

  /// "11 participantes".
  static String participantsAria(int participantsCount) =>
      countLabel(participantsCount, 'participante', 'participantes');

  /// "Dom Casmurro · até o cap. 100" (ponto médio U+00B7 com espaços).
  static String clubSubtitle(Book book, int untilChapter) =>
      '${book.title} · até o cap. $untilChapter';

  /// Nome acessível do `<h3>` do clube: as duas partes com um espaço no lugar do `<br>` → "Leitoras de Capitu".
  static String clubName(BookClub club) =>
      '${club.namePrefix} ${club.nameHighlight}';

  /// Legenda do progresso do grupo: 0,54 → "Grupo em 54%".
  static String groupProgressLabel(double progress) =>
      'Grupo em ${percent(progress)}';

  /// Legenda do progresso da pessoa: 0,62 → "Você em 62%".
  static String userProgressLabel(double progress) =>
      'Você em ${percent(progress)}';

  /// "EPUB" · "PDF" · "Papel" (livro de papel — D-255; a v1 dizia "Físico").
  static String formatLabel(BookFormat format) => switch (format) {
    BookFormat.epub => 'EPUB',
    BookFormat.pdf => 'PDF',
    BookFormat.physical => 'Papel',
  };

  /// "Mary Shelley · EPUB".
  static String recentSubtitle(RecentItem item) =>
      '${item.book.author} · ${formatLabel(item.format)}';

  /// "Quero ler" · "Novo" · "Lido" (D-255).
  static String recentStatusLabel(RecentStatus status) => switch (status) {
    RecentStatus.wantToRead => 'Quero ler',
    RecentStatus.isNew => 'Novo',
    RecentStatus.read => 'Lido',
  };

  /// 24/09/2026 → "QUI".
  static String weekdayShort(DateTime date) => _weekdayShort[date.weekday - 1];

  /// 24/09/2026 → "SET".
  static String monthShort(DateTime date) => _monthShort[date.month - 1];

  /// 24/09/2026 → "24".
  static String day(DateTime date) => '${date.day}';

  /// 20:00 → "20h" (com minutos: "20h30").
  static String hourLabel(DateTime time) => time.minute == 0
      ? '${time.hour}h'
      : '${time.hour}h${time.minute.toString().padLeft(2, '0')}';

  /// "Próximo encontro: quinta, 24 de setembro, às 20h".
  static String meetingAria(DateTime meeting) =>
      'Próximo encontro: ${_weekdayName[meeting.weekday - 1]}, '
      '${meeting.day} de ${_monthName[meeting.month - 1]}, às ${hourLabel(meeting)}';

  /// "Notificações, 2 novas"; sem novidades, só "Notificações".
  static String notificationsAria(int unread) => unread == 0
      ? 'Notificações'
      : 'Notificações, ${countLabel(unread, 'nova', 'novas')}';

  /// "Destaques e notas deste livro (14)".
  static String highlightsAria(int highlightsCount) =>
      'Destaques e notas deste livro ($highlightsCount)';

  /// A lupa do cabeçalho (sem ação até a busca ter prancha — D-243 b).
  static const String searchAria = 'Buscar livros';

  /// "Ler agora" do Seu dia (sem ação até a T04 — D-247).
  static const String readNowAria = 'Iniciar leitura (cronômetro)';

  /// O "play" do livro de papel (sem ação até a T04 — D-247): "Iniciar leitura de Brás Cubas".
  static String startReadingAria(Book book) =>
      'Iniciar leitura de ${bookTitleShort(book)}';

  /// "Mais opções para Frankenstein".
  static String moreOptionsAria(Book book) => 'Mais opções para ${book.title}';

  /// "3 mensagens novas".
  static String messagesAria(int unread) =>
      countLabel(unread, 'mensagem nova', 'mensagens novas');
}

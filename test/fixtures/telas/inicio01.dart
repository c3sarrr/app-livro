// T03 — instantâneo da Início nova (prancha 01; a 60 é a mesma tela rolada — D-241): os valores EXATOS da prancha,
// montados a partir do mundo de referência. O que o mundo guarda vem dele (perfil, Dom Casmurro na pág. 159 de 256,
// as 12 anotações, minutos, sequência, metas, semana, clube até o cap. 50, Orgulho na pág. 344, Para você); só ficam
// escritos aqui os valores que a prancha 01 desenhou e o mundo do leitor não tem — cada um com o motivo — e as alturas
// das barras (px do arquivo — D-10). A lista das diferenças para o mundo gravado no banco está em
// `test/home/t01_divergencias_test.dart`.
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation_stats.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';

import '../mundo_2026_09_20.dart';

abstract final class TelaInicio01 {
  /// "Agora" de referência (D-09): domingo 20/09/2026 20:00, na hora local da Início.
  static final DateTime agora = _local(mundoReferencia.agora);

  // ---- o que a prancha 01 desenhou e o mundo do leitor não tem ---------------------------------------------
  /// "2 destaques" (no mundo: 1 grifo hoje e 4 itens de tinta — a divergência "grifos hoje" da D-60 continua).
  static const int grifosHojeNaPrancha = 2;

  /// "2 sessões" (no mundo: uma sessão hoje, de 18 min).
  static const int sessoesHojeNaPrancha = 2;

  /// "Papel · 3h 40min": o Brás Cubas de papel, já lido nessas sessões (D-252) e sem página registrada (D-253).
  static const Duration brasCubasJaLido = Duration(hours: 3, minutes: 40);

  /// "Seus grifos de hoje" (D-247: o baralho do dia nasce na T05; até lá, só a fixture).
  static const DailyReview revisao = DailyReview(
    highlights: 5,
    minutes: 2,
    bookTitles: ['Dom Casmurro', 'Quincas Borba', 'Iracema'],
  );

  // ---- livros como a Início os mostra (capa = arte da seção) -------------------------------------------------
  static const Book domCasmurro = Book(
    id: Slugs.domCasmurro,
    title: 'Dom Casmurro',
    author: 'Machado de Assis',
    cover: DesignedCover(CoverArt.domCasmurro),
  );

  /// O livro de papel do Também lendo (no mundo do leitor ele não está na estante).
  static const Book brasCubas = Book(
    id: 'memorias-postumas-de-bras-cubas',
    title: 'Memórias Póstumas de Brás Cubas',
    shortTitle: 'Brás Cubas',
    author: 'Machado de Assis',
    cover: DesignedCover(CoverArt.brasCubas),
  );
  static const Book orgulho = Book(
    id: Slugs.orgulho,
    title: 'Orgulho e Preconceito',
    author: 'Jane Austen',
    cover: DesignedCover(CoverArt.pridePrejudice),
  );

  /// O 3º livro em leitura além do herói (o contador diz 3; a grade mostra 2).
  static const Book mrsDalloway = Book(
    id: Slugs.mrsDalloway,
    title: 'Mrs. Dalloway',
    author: 'Virginia Woolf',
    cover: DesignedCover(CoverArt.mrsDalloway),
  );
  static const Book frankenstein = Book(
    id: Slugs.frankenstein,
    title: 'Frankenstein',
    author: 'Mary Shelley',
    cover: DesignedCover(CoverArt.frankenstein),
  );
  static const Book oAlienista = Book(
    id: Slugs.alienista,
    title: 'O Alienista',
    author: 'Machado de Assis',
    cover: DesignedCover(CoverArt.oAlienista),
  );
  static const Book senhora = Book(
    id: Slugs.senhora,
    title: 'Senhora',
    author: 'José de Alencar',
    cover: DesignedCover(CoverArt.senhora),
  );

  /// Capa de cada recomendação do Para você (o mundo guarda o título e o autor).
  static const Map<String, CoverArt> capasDoParaVoce = {
    'esau-e-jaco': CoverArt.esauEJaco,
    'memorial-de-aires': CoverArt.memorialDeAires,
    'casa-de-pensao': CoverArt.casaDePensao,
  };

  /// Alturas das barras do gráfico da semana, em px do arquivo (D-10), de segunda 14 a hoje 20.
  static const Map<int, double> alturaDasBarras = {
    14: 43,
    15: 60,
    16: 40,
    17: 30,
    18: 51,
    19: 73,
    20: 24,
  };

  // ---- partes do instantâneo (montadas uma vez: as mesmas instâncias a cada `snapshot`) ----------------------
  static final UserSummary usuario = (() {
    final p = mundoReferencia.perfil;
    return UserSummary(
      firstName: p.nome,
      initial: p.inicial,
      unreadNotifications: p.notificacoesNaoLidas,
    );
  })();

  static final ContinueReading continuarLendo = (() {
    final m = mundoReferencia;
    final livro = m.livro(Slugs.domCasmurro);
    final posicao = m.posicao(Slugs.domCasmurro);
    return ContinueReading(
      book: domCasmurro,
      // o herói da 01 não mostra o capítulo; os campos saem na troca da T03
      progress: _progresso(Slugs.domCasmurro),
      timeLeft: m.tempoRestante[Slugs.domCasmurro]!,
      highlightsCount: AnnotationStats.countByKind(
        m.anotacoes,
        userBookId: livro.id,
      ).all,
      format: _formato(livro.format),
      refPage: posicao.refPage,
      refPagesTotal: livro.refPagesTotal,
    );
  })();

  static final List<AlsoReadingItem> tambemLendo = List.unmodifiable([
    const AlsoReadingItem(
      book: brasCubas,
      progress: 0,
      format: BookFormat.physical,
      readTime: brasCubasJaLido,
    ),
    // a 01 desenha o Orgulho em papel; no mundo do leitor é o EPUB (tem grifos ancorados no texto)
    AlsoReadingItem(
      book: orgulho,
      progress: _progresso(Slugs.orgulho),
      format: BookFormat.physical,
      paperPage: mundoReferencia.posicao(Slugs.orgulho).refPage,
    ),
    AlsoReadingItem(
      book: mrsDalloway,
      progress: _progresso(Slugs.mrsDalloway),
      format: _formato(mundoReferencia.livro(Slugs.mrsDalloway).format),
    ),
  ]);

  static final ForYou paraVoce = ForYou(
    reasonAuthor: mundoReferencia.paraVoceAutor,
    items: List.unmodifiable([
      for (final l in mundoReferencia.paraVoce)
        Book(
          id: l.slug,
          title: l.titulo,
          shortTitle: l.tituloCurto,
          author: l.autor,
          cover: DesignedCover(capasDoParaVoce[l.slug]!),
        ),
    ]),
  );

  /// Recém-chegados: a 01 desenha "Quero ler" no Frankenstein (a D-88 diria "Novo"), "Lido" no O Alienista (no
  /// mundo, "quero ler") e a Senhora em papel (no mundo, EPUB).
  static final List<RecentItem> recentes = List.unmodifiable([
    RecentItem(
      book: frankenstein,
      format: _formato(mundoReferencia.livro(Slugs.frankenstein).format),
      status: RecentStatus.wantToRead,
    ),
    RecentItem(
      book: oAlienista,
      format: _formato(mundoReferencia.livro(Slugs.alienista).format),
      status: RecentStatus.read,
    ),
    const RecentItem(
      book: senhora,
      format: BookFormat.physical,
      status: RecentStatus.isNew,
    ),
  ]);

  static ReadingDay diaDeLeitura() {
    final m = mundoReferencia;
    final hoje = m.agoraLocal;
    int minutos(int dia) => ReadingTime.minutesOn(
      m.sessoes,
      localDay: DateTime.utc(2026, 9, dia),
      utcOffset: m.fuso,
    );
    var sequencia = 0;
    for (var d = hoje.day; d >= 1 && minutos(d) > 0; d--) {
      sequencia++;
    }
    final paginasHoje = [
      for (final s in m.sessoes)
        if (s.startedAt.add(m.fuso).day == hoje.day) s.pagesViewed ?? 0,
    ].fold(0, (a, b) => a + b);
    return ReadingDay(
      goalMinutes: m.metas.dailyMinutes,
      readMinutes: minutos(hoje.day),
      streakDays: sequencia,
      pagesToday: paginasHoje,
      highlightsToday: grifosHojeNaPrancha,
      sessionsToday: sessoesHojeNaPrancha,
      week: List.unmodifiable([
        for (final MapEntry(key: dia, value: altura) in alturaDasBarras.entries)
          WeekDayStat(
            date: DateTime(2026, 9, dia),
            minutes: minutos(dia),
            barHeightPx: altura,
            isToday: dia == hoje.day,
          ),
      ]),
      badgeTargetDays: m.metas.badgeTargetDays,
    );
  }

  static BookClub clube() {
    final c = mundoReferencia.clube;
    return BookClub(
      id: c.id,
      namePrefix: c.nomePrefixo,
      nameHighlight: c.nomeDestaque,
      book: domCasmurro,
      untilChapter: c.metaCapitulo,
      shownParticipants: List.unmodifiable([
        for (final p in c.exibidos)
          ClubParticipant(initial: p.inicial, color: p.cor),
      ]),
      participantsCount: c.participantes,
      groupProgress: c.progressoDoGrupo,
      userProgress: _progresso(c.livroSlug),
      userInitial: c.inicialDaUsuaria,
      unreadMessages: c.mensagensNaoLidas,
      nextMeeting: _local(c.proximoEncontro),
    );
  }

  static HomeSnapshot snapshot(DateTime now) => HomeSnapshot(
    now: now,
    user: usuario,
    continueReading: continuarLendo,
    alsoReading: tambemLendo,
    readingDay: diaDeLeitura(),
    dailyReview: revisao,
    forYou: paraVoce,
    club: clube(),
    recent: recentes,
  );

  /// Progresso como a Início mostra (2 casas: 0,62113 → 0,62).
  static double _progresso(String slug) => double.parse(
    mundoReferencia.posicao(slug).progression.toStringAsFixed(2),
  );

  static BookFormat _formato(BookFileFormat f) => switch (f) {
    BookFileFormat.epub => BookFormat.epub,
    BookFileFormat.pdf => BookFormat.pdf,
    BookFileFormat.physical => BookFormat.physical,
  };

  /// Instante UTC → data/hora local (sem fuso) de São Paulo, como a Início usa.
  static DateTime _local(DateTime utc) {
    final t = utc.add(mundoReferencia.fuso);
    return DateTime(t.year, t.month, t.day, t.hour, t.minute);
  }
}

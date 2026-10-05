// G03 — instantâneo da Início (prancha 00, v1): os valores EXATOS do arquivo (F02), montados a partir
// do mundo de referência. O que o mundo guarda vem dele (perfil, livros, progresso, sessões, metas,
// clube…); só ficam escritos aqui os números em que a Início diverge do Leitor (Q25) e as alturas das
// barras (px do arquivo — D-10).
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';

import '../mundo_2026_09_20.dart';

abstract final class TelaInicio {
  /// "Agora" de referência (D-09): domingo 20/09/2026 20:00, na hora local da Início.
  static final DateTime agora = _local(mundoReferencia.agora);

  // ---- divergências Início × Leitor (Q25) — valores da Início, mantidos ------------------------
  /// "Cap. 92 de 148" (o Leitor está no cap. XXXII).
  static const int capituloNaInicio = 92;

  /// Ticket do clube "Dom Casmurro · até o cap. 100" (o sumário diz "Até o cap. L").
  static const int metaDoClubeNaInicio = 100;

  /// "Destaques e notas deste livro (14)" (o Leitor conta 12).
  static const int destaquesNaInicio = 14;

  /// Grifos de hoje no "Seu dia de leitura" (no mundo do Leitor: 1 grifo + 4 itens de tinta).
  static const int grifosHojeNaInicio = 2;

  // ---- livros como a Início os mostra (capa = arte da seção) ---------------------------------
  static const Book domCasmurro = Book(
    id: Slugs.domCasmurro,
    title: 'Dom Casmurro',
    author: 'Machado de Assis',
    cover: DesignedCover(CoverArt.domCasmurro),
  );
  static const Book mrsDalloway = Book(
    id: Slugs.mrsDalloway,
    title: 'Mrs. Dalloway',
    author: 'Virginia Woolf',
    cover: DesignedCover(CoverArt.mrsDalloway),
  );
  static const Book pridePrejudice = Book(
    id: Slugs.orgulho,
    title: 'Orgulho e Preconceito',
    author: 'Jane Austen',
    cover: DesignedCover(CoverArt.pridePrejudice),
  );
  static const Book memoriasPostumas = Book(
    id: 'memorias-postumas-de-bras-cubas',
    title: 'Memórias Póstumas de Brás Cubas',
    shortTitle: 'Memórias Póstumas',
    author: 'Machado de Assis',
    cover: DesignedCover(CoverArt.memoriasPostumas),
  );
  static const Book quincasBorba = Book(
    id: 'quincas-borba',
    title: 'Quincas Borba',
    author: 'Machado de Assis',
    cover: DesignedCover(CoverArt.quincasBorba),
  );
  static const Book oCortico = Book(
    id: 'o-cortico',
    title: 'O Cortiço',
    author: 'Aluísio Azevedo',
    cover: DesignedCover(CoverArt.oCortico),
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

  // ---- partes do instantâneo (montadas uma vez: as mesmas instâncias a cada `snapshot`) --------
  static final UserSummary usuario = (() {
    final p = mundoReferencia.perfil;
    return UserSummary(
      firstName: p.nome,
      initial: p.inicial,
      unreadNotifications: p.notificacoesNaoLidas,
    );
  })();

  static final ContinueReading continuarLendo = ContinueReading(
    book: domCasmurro,
    chapter: capituloNaInicio,
    totalChapters: mundoReferencia.domCasmurro.chaptersTotal!,
    progress: _progresso(Slugs.domCasmurro),
    timeLeft: mundoReferencia.tempoRestante[Slugs.domCasmurro]!,
    highlightsCount: destaquesNaInicio,
  );

  static final List<AlsoReadingItem> tambemLendo = List.unmodifiable([
    AlsoReadingItem(book: mrsDalloway, progress: _progresso(Slugs.mrsDalloway)),
    AlsoReadingItem(book: pridePrejudice, progress: _progresso(Slugs.orgulho)),
  ]);

  static final ForYou paraVoce = ForYou(
    reasonAuthor: mundoReferencia.paraVoceAutor,
    items: List.unmodifiable([memoriasPostumas, quincasBorba, oCortico]),
  );

  /// Recém-chegados: formato da estante; "Quero ler" = want_to_read; "Novo" (Senhora) é o rótulo da
  /// Início — a regra que o deriva dos dados é da G08.
  static final List<RecentItem> recentes = List.unmodifiable([
    RecentItem(
      book: frankenstein,
      format: _formato(Slugs.frankenstein),
      status: RecentStatus.wantToRead,
    ),
    RecentItem(
      book: oAlienista,
      format: _formato(Slugs.alienista),
      status: RecentStatus.wantToRead,
    ),
    RecentItem(
      book: senhora,
      format: _formato(Slugs.senhora),
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
      highlightsToday: grifosHojeNaInicio,
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
      id: 'leitoras-de-capitu',
      namePrefix: c.nomePrefixo,
      nameHighlight: c.nomeDestaque,
      book: domCasmurro,
      untilChapter: metaDoClubeNaInicio,
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
    forYou: paraVoce,
    club: clube(),
    recent: recentes,
  );

  /// Progresso como a Início mostra (2 casas: 0,62113 → 0,62).
  static double _progresso(String slug) => double.parse(
    mundoReferencia.posicao(slug).progression.toStringAsFixed(2),
  );

  static BookFormat _formato(String slug) =>
      switch (mundoReferencia.livro(slug).format) {
        BookFileFormat.epub => BookFormat.epub,
        BookFileFormat.pdf => BookFormat.pdf,
        BookFileFormat.physical => throw StateError('livro físico na Início'),
      };

  /// Instante UTC → data/hora local (sem fuso) de São Paulo, como a Início usa.
  static DateTime _local(DateTime utc) {
    final t = utc.add(mundoReferencia.fuso);
    return DateTime(t.year, t.month, t.day, t.hour, t.minute);
  }
}

// G08.2 — a fonte real da Início (banco local em memória): o que cada seção mostra a partir das linhas do
// dono ativo, no fuso do aparelho (D-78, D-81, D-82, D-85, D-10). O mundo de referência gravado no banco
// reproduz o lado do Leitor e só diverge da prancha da Início onde o arquivo desenhou à mão.
import 'dart:async';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/home/data/home_sources.dart';
import 'package:app_leitura/features/home/data/local_home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/library/domain/reading_goals.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/domain/reading_position.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/telas/inicio.dart';
import '../fixtures/telas/t20.dart';
import '../support/personal_builders.dart';

/// São Paulo (sem horário de verão).
const Duration _sp = Duration(hours: -3);

/// Segunda 05/10/2026, 20:00 em São Paulo.
final DateTime _agora = DateTime.utc(2026, 10, 5, 23);

/// Instante UTC de uma hora local de São Paulo.
DateTime _local(int mes, int dia, int hora, [int min = 0]) =>
    DateTime.utc(2026, mes, dia, hora, min).subtract(_sp);

UserBook _livro(
  int n, {
  String titulo = 'Livro',
  String autor = 'Autora',
  BookFileFormat formato = BookFileFormat.epub,
  ShelfStatus status = ShelfStatus.wantToRead,
  DateTime? adicionado,
  DateTime? aberto,
  int? capitulos,
  int? paginas,
  String? capa,
  String? isbn,
  String dono = usuarioTeste,
  bool apagado = false,
}) => UserBook(
  id: idTeste(n),
  meta: metaTeste(userId: dono, apagado: apagado),
  title: titulo,
  authorDisplay: autor,
  format: formato,
  status: status,
  contentSha256: formato == BookFileFormat.physical ? null : shaDoLivroTeste(n),
  chaptersTotal: capitulos,
  refPagesTotal: paginas,
  refPageVersion: paginas == null ? null : 1,
  coverRef: capa,
  isbn13: isbn,
  addedAt: adicionado ?? _local(9, n.clamp(1, 28), 12),
  lastOpenedAt: aberto,
);

ReadingPosition _posicao(
  UserBook livro, {
  required double progresso,
  int capitulo = 0,
  DateTime? em,
}) => ReadingPosition(
  id: livro.id,
  meta: metaTeste(em: em ?? t0Teste, userId: livro.meta.userId),
  locator: localizadorTeste(),
  refPage: 1,
  chapterIndex: capitulo,
  progression: progresso,
);

var _sessoes = 0;
ReadingSession _sessao(
  UserBook livro,
  DateTime inicio, {
  required int segundos,
  int? paginas,
  String dono = usuarioTeste,
  bool apagada = false,
}) => ReadingSession(
  id: idTeste(5000 + _sessoes++),
  meta: metaTeste(em: inicio, userId: dono, apagado: apagada),
  userBookId: livro.id,
  startedAt: inicio,
  endedAt: inicio.add(Duration(seconds: segundos)),
  activeSeconds: segundos,
  pagesViewed: paginas,
  source: SessionSource.auto,
);

/// Espera curta das gravações em rajada nos testes (a do app é 300 ms).
const Duration _rajada = Duration(milliseconds: 20);

/// Deixa passar a espera da rajada e o recálculo.
Future<void> _assentar() async {
  await Future<void>.delayed(const Duration(milliseconds: 120));
  await pumpEventQueue();
}

final class _ParaVoceQuebrado implements ForYouSource {
  @override
  Future<ForYou?> suggest(ForYouRequest request) async =>
      throw StateError('catálogo trocado no meio da consulta');
}

final class _ClubeQuebrado implements ClubTicketSource {
  @override
  Future<BookClub?> current(String owner) async =>
      throw const FormatException('cache estragado');
}

/// Fonte de "Para você" que só registra o pedido.
final class _ParaVoceFalso implements ForYouSource {
  ForYouRequest? pedido;
  ForYou? resposta;

  @override
  Future<ForYou?> suggest(ForYouRequest request) async {
    pedido = request;
    return resposta;
  }
}

final class _ClubeFalso implements ClubTicketSource {
  BookClub? clube;

  @override
  Future<BookClub?> current(String owner) async => clube;
}

void main() {
  late AppDatabase db;
  late _ParaVoceFalso paraVoce;
  late _ClubeFalso clube;
  late LocalHomeRepository repo;
  late List<Object> erros;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    paraVoce = _ParaVoceFalso();
    clube = _ClubeFalso();
    erros = [];
    repo = LocalHomeRepository(
      database: () async => db,
      owner: () async => usuarioTeste,
      utcOffsetAt: (_) => _sp,
      forYou: paraVoce,
      club: clube,
      debounce: _rajada,
      onSourceError: (e, _) => erros.add(e),
    );
  });
  tearDown(() => db.close());

  Future<void> gravar(Iterable<UserBook> livros) async {
    for (final b in livros) {
      await UserBooksDao(db).upsert(b);
    }
  }

  Future<void> sessoes(Iterable<ReadingSession> s) async {
    for (final x in s) {
      await ReadingSessionsDao(db).upsert(x);
    }
  }

  group('sem dados (D-78)', () {
    test('banco vazio: convidado, estante vazia, sem leitura, dia zerado com a meta padrão e 7 dias', () async {
      final s = await repo.read(_agora);
      expect(s.now, DateTime(2026, 10, 5, 20));
      expect(s.user.firstName, isNull);
      expect(s.user.initial, isNull);
      expect(s.user.unreadNotifications, 0);
      expect(s.shelfIsEmpty, isTrue);
      expect(s.continueReading, isNull);
      expect(s.alsoReading, isEmpty);
      expect(s.forYou, isNull);
      expect(s.club, isNull);
      expect(s.recent, isEmpty);
      final d = s.readingDay;
      expect(
        [d.goalMinutes, d.readMinutes, d.streakDays, d.pagesToday],
        [30, 0, 0, 0],
      );
      expect([d.highlightsToday, d.badgeTargetDays], [0, 7]);
      expect(d.week.map((w) => w.date), [
        for (var dia = 29; dia <= 30; dia++) DateTime(2026, 9, dia),
        for (var dia = 1; dia <= 5; dia++) DateTime(2026, 10, dia),
      ]);
      expect(
        d.week.map((w) => (w.minutes, w.barHeightPx)),
        everyElement((0, 0.0)),
      );
      expect(d.week.map((w) => w.isToday), [...List.filled(6, false), true]);
    });

    test('só livros escaneados: recém-chegados (físico, quero ler), sem leitura; estante não vazia', () async {
      await gravar([
        for (var n = 1; n <= 4; n++)
          _livro(
            n,
            titulo: 'Livro $n',
            formato: BookFileFormat.physical,
            adicionado: _local(10, n, 9),
            capa: n == 2 ? 'ol:42' : null,
            isbn: '978853590277$n',
          ),
      ]);
      final s = await repo.read(_agora);
      expect(s.shelfIsEmpty, isFalse);
      expect(s.continueReading, isNull);
      expect(s.recent.map((r) => (r.book.title, r.format, r.status)), [
        ('Livro 4', BookFormat.physical, RecentStatus.isNew),
        ('Livro 3', BookFormat.physical, RecentStatus.isNew),
        ('Livro 2', BookFormat.physical, RecentStatus.isNew),
      ], reason: 'mais novos primeiro, até 3; chegaram nesta semana (D-88)');
      expect(
        s.recent[2].book.cover,
        const PhotoCover(ref: 'ol:42', isbn13: '9788535902772'),
      );
      expect(s.recent[0].book.id, idTeste(4));
    });
  });

  group('leitura (D-85)', () {
    test('herói = aberto mais recentemente; capítulo, progresso e anotações; os outros em "também lendo"', () async {
      final a = _livro(
        1,
        titulo: 'A',
        status: ShelfStatus.reading,
        aberto: _local(10, 3, 21),
        capitulos: 10,
        paginas: 200,
      );
      final b = _livro(
        2,
        titulo: 'B',
        status: ShelfStatus.reading,
        aberto: _local(10, 5, 8),
        capitulos: 20,
      );
      final c = _livro(
        3,
        titulo: 'C',
        status: ShelfStatus.reading,
        aberto: _local(9, 1, 8),
      );
      final d = _livro(
        4,
        titulo: 'D',
        status: ShelfStatus.reading,
        aberto: _local(9, 2, 8),
      );
      await gravar([a, b, c, d]);
      await ReadingPositionsDao(db)
          .upsert(_posicao(b, progresso: 0.25, capitulo: 4));
      await ReadingPositionsDao(db).upsert(_posicao(a, progresso: 0.5));
      final g1 = grifoTeste(10, livro: b.id);
      await AnnotationsDao(db).upsert(g1);
      await AnnotationsDao(db)
          .upsert(notaTeste(11, livro: b.id, pai: g1, texto: 'nota'));
      await AnnotationsDao(db).upsert(grifoTeste(12, livro: b.id, inicio: 40));
      await AnnotationsDao(db)
          .upsert(grifoTeste(13, livro: b.id, inicio: 80, apagado: true));
      await AnnotationsDao(db).upsert(grifoTeste(14, livro: a.id));

      final s = await repo.read(_agora);
      final h = s.continueReading!;
      expect(h.book.title, 'B');
      expect(h.book.id, b.id);
      expect([h.chapter, h.totalChapters], [5, 20]);
      expect(h.progress, 0.25);
      expect(h.highlightsCount, 3, reason: 'anotações não apagadas do livro');
      expect(s.alsoReading.map((x) => (x.book.title, x.progress)), [
        ('A', 0.5),
        ('D', 0.0),
        ('C', 0.0),
      ]);
    });

    test(
      'sem capítulos (PDF) e sem sessões: capítulo e tempo restante nulos',
      () async {
        await gravar([
          _livro(
            1,
            formato: BookFileFormat.pdf,
            status: ShelfStatus.reading,
            aberto: _local(10, 5, 8),
            paginas: 100,
          ),
        ]);
        final h = (await repo.read(_agora)).continueReading!;
        expect(h.chapter, isNull);
        expect(h.totalChapters, isNull);
        expect(h.timeLeft, isNull);
      },
    );

    test('tempo restante ≈ páginas que faltam × segundos por página das sessões dos últimos 30 dias', () async {
      final a = _livro(
        1,
        status: ShelfStatus.reading,
        aberto: _local(10, 5, 8),
        paginas: 200,
      );
      await gravar([a]);
      await ReadingPositionsDao(db).upsert(_posicao(a, progresso: 0.5));
      await sessoes([
        _sessao(a, _local(10, 4, 10), segundos: 1200, paginas: 20),
        _sessao(a, _local(10, 5, 10), segundos: 600, paginas: 10),
        // fora da janela de 30 dias: não entra na velocidade
        _sessao(a, _local(8, 20, 10), segundos: 9000, paginas: 1),
      ]);
      // 1800 s / 30 páginas = 60 s/página × 100 páginas = 100 min
      expect(
        (await repo.read(_agora)).continueReading!.timeLeft,
        const Duration(minutes: 100),
      );
    });

    test('só o dono ativo e só linhas não apagadas', () async {
      const outro = 'a1b2c3d4-0000-4000-8000-000000000001';
      await gravar([
        _livro(
          1,
          status: ShelfStatus.reading,
          aberto: _local(10, 5, 8),
          dono: outro,
        ),
        _livro(
          2,
          status: ShelfStatus.reading,
          aberto: _local(10, 5, 9),
          apagado: true,
        ),
        _livro(3, titulo: 'Meu', adicionado: _local(10, 1, 9)),
      ]);
      await sessoes([
        _sessao(
          _livro(1, dono: outro),
          _local(10, 5, 10),
          segundos: 3600,
          dono: outro,
        ),
        _sessao(_livro(3), _local(10, 5, 11), segundos: 3600, apagada: true),
      ]);
      final s = await repo.read(_agora);
      expect(s.continueReading, isNull);
      expect(s.recent.map((r) => r.book.title), ['Meu']);
      expect(s.readingDay.readMinutes, 0);
    });
  });

  group('dia de leitura', () {
    test('minutos pelo início da sessão no fuso do aparelho; soma de segundos ÷ 60 para baixo', () async {
      final a = _livro(1, status: ShelfStatus.reading);
      await gravar([a]);
      await sessoes([
        _sessao(a, _local(10, 5, 9), segundos: 90),
        _sessao(a, _local(10, 5, 19, 59), segundos: 89),
        // 23:50 de ontem (02:50 UTC de hoje): conta em ontem
        _sessao(a, _local(10, 4, 23, 50), segundos: 1200),
        // 00:10 de hoje (03:10 UTC): conta hoje
        _sessao(a, _local(10, 5, 0, 10), segundos: 60),
      ]);
      final d = (await repo.read(_agora)).readingDay;
      expect(d.readMinutes, (90 + 89 + 60) ~/ 60);
      expect(d.week.last.minutes, 3);
      expect(d.week[5].minutes, 20);
    });

    test('sequência: dias seguidos com ≥ 1 min; hoje ainda sem leitura não quebra; buraco quebra', () async {
      final a = _livro(1, status: ShelfStatus.reading);
      await gravar([a]);
      await sessoes([
        for (final dia in [30]) _sessao(a, _local(9, dia, 21), segundos: 600),
        for (final dia in [2, 3, 4])
          _sessao(a, _local(10, dia, 21), segundos: 600),
        // 59 s não chegam a 1 minuto: o dia 1 não conta (e quebra a sequência)
        _sessao(a, _local(10, 1, 21), segundos: 59),
      ]);
      expect((await repo.read(_agora)).readingDay.streakDays, 3);
      await sessoes([_sessao(a, _local(10, 5, 7), segundos: 60)]);
      expect((await repo.read(_agora)).readingDay.streakDays, 4);
      // amanhã sem leitura ainda: a sequência de ontem continua até o dia acabar
      expect(
        (await repo.read(_agora.add(const Duration(hours: 5))))
            .readingDay
            .streakDays,
        4,
      );
      // depois de amanhã: buraco ontem → zera
      expect(
        (await repo.read(_agora.add(const Duration(days: 2))))
            .readingDay
            .streakDays,
        0,
      );
    });

    test('semana = últimos 7 dias, hoje no fim; barras D-10 (min × 4/3, teto 77,6 e 77,0 hoje)', () async {
      final a = _livro(1, status: ShelfStatus.reading);
      await gravar([a]);
      await sessoes([
        _sessao(a, _local(9, 29, 20), segundos: 30 * 60),
        _sessao(a, _local(10, 1, 20), segundos: 58 * 60),
        _sessao(a, _local(10, 2, 20), segundos: 59 * 60),
        _sessao(a, _local(10, 3, 20), segundos: 120 * 60),
        _sessao(a, _local(10, 5, 19), segundos: 58 * 60),
      ]);
      final w = (await repo.read(_agora)).readingDay.week;
      expect(w.map((x) => x.minutes), [30, 0, 58, 59, 120, 0, 58]);
      expect(w.map((x) => x.barHeightPx), [
        40.0,
        0.0,
        58 * 4 / 3,
        77.6,
        77.6,
        0.0,
        77.0,
      ]);
    });

    test('páginas e grifos de hoje; meta e selo do dono', () async {
      final a = _livro(1, status: ShelfStatus.reading);
      await gravar([a]);
      await sessoes([
        _sessao(a, _local(10, 5, 9), segundos: 600, paginas: 7),
        _sessao(a, _local(10, 5, 10), segundos: 600, paginas: 5),
        _sessao(a, _local(10, 4, 10), segundos: 600, paginas: 50),
      ]);
      Annotation grifoEm(int n, DateTime em) {
        final g = grifoTeste(n, livro: a.id, inicio: n * 10);
        return g.copyWith(meta: metaTeste(em: em));
      }

      await AnnotationsDao(db).upsert(grifoEm(20, _local(10, 5, 9)));
      await AnnotationsDao(db).upsert(grifoEm(21, _local(10, 5, 0, 5)));
      await AnnotationsDao(db).upsert(grifoEm(22, _local(10, 4, 23, 55)));
      await ReadingGoalsDao(db).upsert(
        ReadingGoals(
          id: usuarioTeste,
          meta: metaTeste(),
          dailyMinutes: 45,
          badgeTargetDays: 21,
        ),
      );
      final d = (await repo.read(_agora)).readingDay;
      expect(d.pagesToday, 12);
      expect(d.highlightsToday, 2);
      expect([d.goalMinutes, d.badgeTargetDays], [45, 21]);
    });
  });

  group('recém-chegados (D-85)', () {
    test('só nunca abertos, fora lidos, abandonados e os que já estão em leitura (cada livro aparece uma vez — G08.6)', () async {
      await gravar([
        _livro(1, titulo: 'Quero', adicionado: _local(10, 1, 9)),
        _livro(
          2,
          titulo: 'Lendo nunca aberto',
          status: ShelfStatus.reading,
          adicionado: _local(10, 2, 9),
        ),
        _livro(
          3,
          titulo: 'Aberto',
          status: ShelfStatus.reading,
          adicionado: _local(10, 3, 9),
          aberto: _local(10, 3, 10),
        ),
        _livro(
          4,
          titulo: 'Lido',
          status: ShelfStatus.finished,
          adicionado: _local(10, 4, 9),
        ),
        _livro(
          5,
          titulo: 'Abandonado',
          status: ShelfStatus.abandoned,
          adicionado: _local(10, 4, 10),
        ),
        _livro(
          6,
          titulo: 'PDF',
          formato: BookFileFormat.pdf,
          adicionado: _local(9, 30, 9),
        ),
      ]);
      final s = await repo.read(_agora);
      expect(s.recent.map((x) => (x.book.title, x.status, x.format)), [
        ('Quero', RecentStatus.isNew, BookFormat.epub),
        ('PDF', RecentStatus.isNew, BookFormat.pdf),
      ]);
      // o "lendo" nunca aberto (ex.: exemplar físico) fica só na leitura
      expect(s.continueReading!.book.title, 'Aberto');
      expect(s.alsoReading.map((a) => a.book.title), ['Lendo nunca aberto']);
    });
  });

  group('pílula "Novo" (D-88)', () {
    test('hoje e os 6 dias anteriores (dia local): "Novo"; do 7º dia para trás: "Quero ler"', () async {
      await gravar([
        _livro(1, titulo: 'Hoje', adicionado: _local(10, 5, 1)),
        // 00:30 de 29/09 em São Paulo (03:30 UTC): 6 dias antes de hoje (5/10)
        _livro(2, titulo: 'Seis dias', adicionado: _local(9, 29, 0, 30)),
        // 23:30 de 28/09 em São Paulo — já é 29/09 em UTC, mas o dia local é 28: 7 dias
        _livro(3, titulo: 'Sete dias', adicionado: _local(9, 28, 23, 30)),
      ]);
      final r = (await repo.read(_agora)).recent;
      expect(r.map((x) => (x.book.title, x.status)), [
        ('Hoje', RecentStatus.isNew),
        ('Seis dias', RecentStatus.isNew),
        ('Sete dias', RecentStatus.wantToRead),
      ]);
    });

    test('capa: o sha do arquivo vai para a foto (a capa que veio no EPUB/PDF — D-90)', () async {
      final sha = 'c' * 64;
      await gravar([
        _livro(1, titulo: 'Com arquivo', adicionado: _local(10, 5, 1)).copyWith(
          contentSha256: Nullable(sha),
          coverRef: const Nullable('ol:7'),
        ),
      ]);
      final r = (await repo.read(_agora)).recent.single;
      expect(r.book.cover, PhotoCover(ref: 'ol:7', fileSha: sha));
    });
  });

  group('Para você e Clube (D-81, D-80)', () {
    test('o pedido leva os autores da estante (mais livros primeiro; empate: o mais recente), ISBNs e títulos', () async {
      await gravar([
        _livro(
          1,
          titulo: 'Um',
          autor: 'Clarice Lispector',
          adicionado: _local(9, 1, 9),
          isbn: '9788532508126',
        ),
        _livro(
          2,
          titulo: 'Dois',
          autor: 'Machado de Assis',
          adicionado: _local(9, 2, 9),
        ),
        _livro(
          3,
          titulo: 'Três',
          autor: 'Machado de Assis · José de Alencar',
          adicionado: _local(9, 3, 9),
        ),
        _livro(
          4,
          titulo: 'Quatro',
          autor: 'Autoria desconhecida',
          adicionado: _local(9, 4, 9),
        ),
        _livro(
          5,
          titulo: 'Cinco',
          autor: 'Clarice Lispector',
          adicionado: _local(9, 5, 9),
        ),
        _livro(
          6,
          titulo: 'Seis',
          autor: 'Graciliano Ramos',
          adicionado: _local(9, 6, 9),
        ),
      ]);
      paraVoce.resposta = const ForYou(
        reasonAuthor: 'Clarice Lispector',
        items: [
          Book(
            id: '9788532508010',
            title: 'Perto do coração selvagem',
            author: 'Clarice Lispector',
            cover: PhotoCover(ref: 'ol:1', isbn13: '9788532508010'),
          ),
        ],
      );
      final s = await repo.read(_agora);
      final p = paraVoce.pedido!;
      expect(p.authors, [
        'Clarice Lispector',
        'Machado de Assis',
        'Graciliano Ramos',
        'José de Alencar',
      ]);
      expect(p.shelfIsbns, {'9788532508126'});
      expect(
        p.shelfTitles,
        containsAll(['Um', 'Dois', 'Três', 'Quatro', 'Cinco', 'Seis']),
      );
      expect(s.forYou, same(paraVoce.resposta));
    });

    test('estante vazia: nem pergunta (Para você some)', () async {
      await repo.read(_agora);
      expect(paraVoce.pedido, isNull);
    });

    test('o clube vem da fonte (vazia até a G21)', () async {
      expect((await repo.read(_agora)).club, isNull);
      final c = BookClub(
        id: 'c1',
        namePrefix: 'Leitoras de',
        nameHighlight: 'Capitu',
        book: const Book(id: 'b', title: 'T', author: 'A', cover: PhotoCover()),
        untilChapter: 10,
        shownParticipants: const [],
        participantsCount: 1,
        groupProgress: 0.1,
        userProgress: 0.2,
        userInitial: 'M',
        unreadMessages: 0,
        nextMeeting: DateTime(2026, 10, 8, 20),
      );
      clube.clube = c;
      expect((await repo.read(_agora)).club, same(c));
    });
  });

  group('robustez (revisão da G08)', () {
    test('falha em Para você ou no Clube: a seção some, a Início continua e o erro é reportado', () async {
      await gravar([_livro(1, titulo: 'Um', autor: 'Clarice Lispector')]);
      final r = LocalHomeRepository(
        database: () async => db,
        owner: () async => usuarioTeste,
        utcOffsetAt: (_) => _sp,
        forYou: _ParaVoceQuebrado(),
        club: _ClubeQuebrado(),
        onSourceError: (e, _) => erros.add(e),
      );
      final s = await r.read(_agora);
      expect(s.forYou, isNull);
      expect(s.club, isNull);
      expect(s.recent.single.book.title, 'Um');
      expect(erros, [isA<StateError>(), isA<FormatException>()]);
    });

    test('sessão com a data em outro formato (+0000): conta no dia certo e não derruba', () async {
      final a = _livro(1, status: ShelfStatus.reading);
      await gravar([a]);
      await db.customStatement(
        'INSERT INTO reading_sessions (id, user_id, user_book_id, started_at, ended_at, '
        'active_seconds, source, created_at, updated_at, version_hlc) '
        'VALUES (?, ?, ?, ?, ?, 600, ?, ?, ?, ?)',
        [
          idTeste(9001),
          usuarioTeste,
          a.id,
          '2026-10-05T12:00:00+0000',
          '2026-10-05T12:10:00+0000',
          'auto',
          '2026-10-05T12:10:00+0000',
          '2026-10-05T12:10:00+0000',
          '0001791000000000-0000-aparelhoA',
        ],
      );
      final d = (await repo.read(_agora)).readingDay;
      expect(d.readMinutes, 10);
      expect(d.streakDays, 1);
    });
  });

  group('tempo (revisão da G08)', () {
    test('dia local pelo fuso de cada sessão (troca de horário)', () async {
      // −2 h antes de 04/10 12:00 UTC, −3 h depois (como o fim de um horário de verão)
      final troca = DateTime.utc(2026, 10, 4, 12);
      final r = LocalHomeRepository(
        database: () async => db,
        owner: () async => usuarioTeste,
        utcOffsetAt: (t) => t.isBefore(troca)
            ? const Duration(hours: -2)
            : const Duration(hours: -3),
      );
      final a = _livro(1, status: ShelfStatus.reading);
      await gravar([a]);
      // 02:30 UTC de 04/10 = 00:30 do dia 04 no fuso de então (com o fuso de hoje seria 23:30 do dia 03)
      await sessoes([
        _sessao(a, DateTime.utc(2026, 10, 4, 2, 30), segundos: 1200),
      ]);
      final w = (await r.read(_agora)).readingDay.week;
      expect(w[5].date, DateTime(2026, 10, 4));
      expect(w[5].minutes, 20);
      expect(w[4].minutes, 0);
    });

    test(
      'próximo recálculo: meia-noite, 5h, 12h e 18h locais (dia e saudação)',
      () {
        Duration d(int dia, int h, int m) =>
            LocalHomeRepository.untilNextRefresh(
              _local(10, dia, h, m),
              (_) => _sp,
            );
        const s1 = Duration(seconds: 1);
        expect(d(5, 20, 0), const Duration(hours: 4) + s1);
        expect(d(5, 3, 0), const Duration(hours: 2) + s1);
        expect(d(5, 11, 30), const Duration(minutes: 30) + s1);
        expect(d(5, 12, 0), const Duration(hours: 6) + s1);
        expect(d(5, 17, 59), const Duration(minutes: 1) + s1);
        expect(d(5, 0, 0), const Duration(hours: 5) + s1);
      },
    );

    test(
      'o app volta do segundo plano: recalcula o "agora" (saudação e dia)',
      () async {
        final acordar = StreamController<void>.broadcast();
        addTearDown(acordar.close);
        var agora = _agora;
        final r = LocalHomeRepository(
          database: () async => db,
          owner: () async => usuarioTeste,
          utcOffsetAt: (_) => _sp,
          debounce: _rajada,
          wakeups: () => acordar.stream,
        );
        final emitidos = <HomeSnapshot>[];
        final sub = r.watch(() => agora).listen(emitidos.add);
        addTearDown(sub.cancel);
        await _assentar();
        expect(emitidos.single.now, DateTime(2026, 10, 5, 20));
        agora = _agora.add(const Duration(hours: 13));
        acordar.add(null);
        await _assentar();
        expect(emitidos.last.now, DateTime(2026, 10, 6, 9));
        expect(emitidos.last.readingDay.week.last.date, DateTime(2026, 10, 6));
      },
    );

    test('gravações em rajada viram um recálculo só', () async {
      final emitidos = <HomeSnapshot>[];
      final sub = repo.watch(() => _agora).listen(emitidos.add);
      addTearDown(sub.cancel);
      await _assentar();
      expect(emitidos, hasLength(1));
      for (var n = 1; n <= 5; n++) {
        await gravar([_livro(n, titulo: 'L$n')]);
      }
      await _assentar();
      expect(emitidos, hasLength(2));
      expect(emitidos.last.recent, hasLength(3));
    });
  });

  group('fluxo', () {
    test('emite de novo quando o banco muda (e não emite à toa)', () async {
      final emitidos = <HomeSnapshot>[];
      final sub = repo.watch(() => _agora).listen(emitidos.add);
      addTearDown(sub.cancel);
      await _assentar();
      expect(emitidos, hasLength(1));
      expect(emitidos.last.shelfIsEmpty, isTrue);
      await gravar([_livro(1, titulo: 'Novo')]);
      await _assentar();
      expect(emitidos, hasLength(2));
      expect(emitidos.last.recent.single.book.title, 'Novo');
      await _assentar();
      expect(emitidos, hasLength(2));
    });

    test(
      'um livro que deixa de ser "quero ler" sai dos recém-chegados',
      () async {
        final b = _livro(1, titulo: 'X');
        await gravar([b]);
        final emitidos = <HomeSnapshot>[];
        final sub = repo.watch(() => _agora).listen(emitidos.add);
        addTearDown(sub.cancel);
        await _assentar();
        await gravar([
          b.copyWith(
            status: ShelfStatus.finished,
            meta: metaTeste(em: t0Teste.add(const Duration(minutes: 1))),
            finishedAt: Nullable(_local(10, 5, 9)),
          ),
        ]);
        await _assentar();
        expect(emitidos.last.recent, isEmpty);
      },
    );
  });

  group('mundo de referência no banco (D-34, D-60)', () {
    test('reproduz o lado do Leitor; as diferenças para a prancha da Início são só as conhecidas', () async {
      final m = mundoReferencia;
      await m.gravarEm(db);
      final r = LocalHomeRepository(
        database: () async => db,
        owner: () async => m.usuarioId,
        utcOffsetAt: (_) => m.fuso,
      );
      final s = await r.read(m.agora);
      final prancha = TelaInicio.snapshot(TelaInicio.agora);

      final h = s.continueReading!;
      expect(h.book.title, 'Dom Casmurro');
      expect(h.book.author, 'Machado de Assis');
      expect(h.chapter, t20.capituloAtual); // cap. XXXII
      expect(h.totalChapters, 148);
      expect(h.highlightsCount, t20.contagens.all); // 12
      expect((h.progress * 100).round(), 62);
      expect(s.readingDay.readMinutes, t20.minutosHoje); // 18
      expect(s.readingDay.pagesToday, 24);
      expect(s.readingDay.streakDays, 12);
      expect(s.readingDay.goalMinutes, 30);
      expect(s.readingDay.badgeTargetDays, 14);
      expect(
        s.readingDay.week.map((d) => d.minutes),
        prancha.readingDay.week.map((d) => d.minutes),
      );
      expect(
        s.readingDay.week.map((d) => (d.date, d.isToday)),
        prancha.readingDay.week.map((d) => (d.date, d.isToday)),
      );
      expect(s.alsoReading.map((a) => (a.book.title, a.progress)), [
        ('Mrs. Dalloway', 0.34),
        ('Orgulho e Preconceito', 0.81),
      ]);
      expect(s.recent.map((x) => (x.book.title, x.book.author, x.format)), [
        for (final x in prancha.recent) (x.book.title, x.book.author, x.format),
      ]);
      expect(s.now, prancha.now);

      // O que a prancha da Início desenhou diferente do mundo (Q25/D-60, D-10, D-34) — e nada mais.
      final diferencas = <String, Object>{
        if (h.chapter != prancha.continueReading!.chapter)
          'capítulo': (h.chapter, prancha.continueReading!.chapter),
        if (h.highlightsCount != prancha.continueReading!.highlightsCount)
          'destaques': (
            h.highlightsCount,
            prancha.continueReading!.highlightsCount,
          ),
        if (s.readingDay.highlightsToday != prancha.readingDay.highlightsToday)
          'grifos hoje': (
            s.readingDay.highlightsToday,
            prancha.readingDay.highlightsToday,
          ),
        if (h.progress != prancha.continueReading!.progress)
          'progresso (a prancha arredonda a 2 casas)': (
            h.progress,
            prancha.continueReading!.progress,
          ),
        if (h.timeLeft != prancha.continueReading!.timeLeft)
          'tempo restante (o arquivo escreve; a regra pessoal é da G10)': (
            h.timeLeft,
            prancha.continueReading!.timeLeft,
          ),
        if (!_iguais(
          s.readingDay.week.map((d) => d.barHeightPx),
          prancha.readingDay.week.map((d) => d.barHeightPx),
        ))
          'alturas das barras (D-10: arquivo × regra)': true,
        if (!_mesmos(
          s.recent.map((x) => x.status),
          prancha.recent.map((x) => x.status),
        ))
          'pílulas: "Novo" nos 7 primeiros dias (D-88); a prancha tem "Quero ler" em Frankenstein e O Alienista':
              [for (final x in s.recent) x.status],
        if (s.forYou != null) 'para você sem catálogo no teste': s.forYou!,
        if (s.club != null) 'clube antes da G21': s.club!,
        if (s.user.firstName != null)
          'usuário (vem da conta)': s.user.firstName!,
      };
      expect(diferencas.keys, [
        'capítulo',
        'destaques',
        'grifos hoje',
        'progresso (a prancha arredonda a 2 casas)',
        'tempo restante (o arquivo escreve; a regra pessoal é da G10)',
        'alturas das barras (D-10: arquivo × regra)',
        'pílulas: "Novo" nos 7 primeiros dias (D-88); a prancha tem "Quero ler" em Frankenstein e O Alienista',
      ]);
      expect(
        diferencas['pílulas: "Novo" nos 7 primeiros dias (D-88); a prancha tem "Quero ler" em Frankenstein e O Alienista'],
        [RecentStatus.isNew, RecentStatus.isNew, RecentStatus.isNew],
      );
      expect(prancha.recent.map((x) => x.status), [
        RecentStatus.wantToRead,
        RecentStatus.wantToRead,
        RecentStatus.isNew,
      ]);
      expect(diferencas['capítulo'], (32, 92));
      expect(diferencas['destaques'], (12, 14));
      expect(diferencas['grifos hoje'], (1, 2));
    });
  });
}

bool _iguais(Iterable<double> a, Iterable<double> b) {
  final x = a.toList();
  final y = b.toList();
  if (x.length != y.length) return false;
  for (var i = 0; i < x.length; i++) {
    if ((x[i] - y[i]).abs() > 1e-9) return false;
  }
  return true;
}

bool _mesmos<T>(Iterable<T> a, Iterable<T> b) {
  final x = a.toList();
  final y = b.toList();
  if (x.length != y.length) return false;
  for (var i = 0; i < x.length; i++) {
    if (x[i] != y[i]) return false;
  }
  return true;
}

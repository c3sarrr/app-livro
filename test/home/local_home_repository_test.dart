// G08.2 — a fonte real da Início (banco local em memória): o que cada seção mostra a partir das linhas do
// dono ativo, no fuso do aparelho (D-78, D-81, D-82, D-85, D-10). O mundo de referência gravado no banco
// reproduz o lado do Leitor e só diverge da prancha da Início onde o arquivo desenhou à mão.
import 'dart:async';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/home/data/home_sources.dart';
import 'package:app_leitura/features/home/data/local_home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:app_leitura/features/library/domain/reading_goals.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reading_position.dart';
import 'package:app_leitura/features/reader/domain/reading_session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/telas/inicio.dart';
import '../fixtures/telas/t20.dart';
import '../support/personal_builders.dart';
import '../support/reader_harness.dart' show domCasmurroEpub;

/// São Paulo (sem horário de verão).
const Duration _sp = Duration(hours: -3);

/// Outra conta no mesmo aparelho (as linhas dela não contam).
const String _outroDono = 'a1b2c3d4-0000-4000-8000-000000000001';

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
  int pagina = 1,
  DateTime? em,
}) => ReadingPosition(
  id: livro.id,
  meta: metaTeste(em: em ?? t0Teste, userId: livro.meta.userId),
  // livro de papel: a T04 define o localizador; aqui, um objeto qualquer (o banco só exige JSON de objeto)
  locator: livro.format == BookFileFormat.physical
      ? RawLocator({'type': 'paper', 'page': pagina})
      : localizadorTeste(pagina: pagina),
  refPage: pagina,
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
  SessionSource origem = SessionSource.auto,
}) => ReadingSession(
  id: idTeste(5000 + _sessoes++),
  meta: metaTeste(em: inicio, userId: dono, apagado: apagada),
  userBookId: livro.id,
  startedAt: inicio,
  endedAt: inicio.add(Duration(seconds: segundos)),
  activeSeconds: segundos,
  pagesViewed: paginas,
  source: origem,
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
      expect(
        s.dailyReview,
        isNull,
        reason: 'D-247: a revisão só na fixture até a T05',
      );
      final d = s.readingDay;
      expect(
        [d.goalMinutes, d.readMinutes, d.streakDays, d.pagesToday],
        [30, 0, 0, 0],
      );
      expect(d.sessionsToday, 0);
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

    test('G20 (D-206): com o índice do livro, "Cap. 32 de 148" pela numeração do livro (não as 153 entradas)', () async {
      final livro = _livro(
        1,
        status: ShelfStatus.reading,
        aberto: _local(10, 5, 8),
        capitulos: 153,
      );
      await gravar([livro]);
      await BookContentIndexDao(db).upsert(
        livro.id,
        indexEpubFile(domCasmurroEpub, shaDoLivroTeste(1)),
        builtAt: t0Teste,
      );
      await ReadingPositionsDao(db)
          .upsert(_posicao(livro, progresso: 0.2, capitulo: 33));
      final h = (await repo.read(_agora)).continueReading!;
      expect((h.chapter, h.totalChapters), (32, 148));
      // na abertura (antes do cap. I) a pílula some
      await ReadingPositionsDao(db).upsert(
        _posicao(
          livro,
          progresso: 0.01,
          capitulo: 1,
          em: t0Teste.add(const Duration(minutes: 1)),
        ),
      );
      final h2 = (await repo.read(_agora)).continueReading!;
      expect((h2.chapter, h2.totalChapters), (null, null));
    });

    test('G20 (D-206): os numerais ficam guardados enquanto o índice é o mesmo; o índice refeito conta de novo', () async {
      final livro = _livro(
        1,
        status: ShelfStatus.reading,
        aberto: _local(10, 5, 8),
        capitulos: 153,
      );
      await gravar([livro]);
      await BookContentIndexDao(db).upsert(
        livro.id,
        indexEpubFile(domCasmurroEpub, shaDoLivroTeste(1)),
        builtAt: t0Teste,
      );
      await ReadingPositionsDao(db)
          .upsert(_posicao(livro, progresso: 0.2, capitulo: 33));
      expect((await repo.read(_agora)).continueReading!.chapter, 32);
      // o sumário mexido por fora, sem o índice ser refeito: a Início não relê o índice a cada recálculo
      await db.customStatement(
        "UPDATE book_content_index SET toc_json = '[]' WHERE user_book_id = ?",
        [livro.id],
      );
      final guardado = (await repo.read(_agora)).continueReading!;
      expect((guardado.chapter, guardado.totalChapters), (32, 148));
      // o índice refeito (outro built_at): conta pelo índice novo — sem sumário, pelas 153 entradas do livro
      await db.customStatement(
        "UPDATE book_content_index SET built_at = '2026-10-02T00:00:00.000Z' WHERE user_book_id = ?",
        [livro.id],
      );
      final novo = (await repo.read(_agora)).continueReading!;
      expect((novo.chapter, novo.totalChapters), (34, 153));
    });

    test('sem capítulos (PDF): capítulo nulo; sem sessões, o tempo restante usa 1.000 car./min (D-97)', () async {
      await gravar([
        _livro(
          1,
          formato: BookFileFormat.pdf,
          status: ShelfStatus.reading,
          aberto: _local(10, 5, 8),
          paginas: 100,
        ),
      ]);
      // o índice do PDF como a importação grava (sem itens: o PDF não tem texto canônico)
      await BookContentIndexDao(db).upsert(
        idTeste(1),
        BookIndex(
          contentSha256: shaDoLivroTeste(1),
          layout: 'pdf',
          spine: const [],
          toc: const [],
          refPages: RefPageMap.pdf(100),
          refPageVersion: refPageVersion,
        ),
        builtAt: t0Teste,
      );
      final h = (await repo.read(_agora)).continueReading!;
      expect(h.chapter, isNull);
      expect(h.totalChapters, isNull);
      // sem texto no índice: 100 páginas × 1.500 caracteres ÷ 1.000 por minuto = 150 min
      expect(h.timeLeft, const Duration(minutes: 150));
    });

    test(
      'sem índice e sem páginas de referência: tempo restante some',
      () async {
        await gravar([
          _livro(1, status: ShelfStatus.reading, aberto: _local(10, 5, 8)),
        ]);
        expect((await repo.read(_agora)).continueReading!.timeLeft, isNull);
      },
    );

    test('tempo restante = caracteres que faltam ÷ velocidade pessoal das sessões de 3 min ou mais (D-97)', () async {
      final a = _livro(
        1,
        status: ShelfStatus.reading,
        aberto: _local(10, 5, 8),
        paginas: 200,
      );
      final b = _livro(
        2,
        status: ShelfStatus.reading,
        aberto: _local(10, 1, 8),
        paginas: 50,
      );
      await gravar([a, b]);
      // índice do livro a: 300.000 caracteres nos itens lineares (as notas fora da leitura, 150.000, não
      // contam — nem no total nem nos caracteres por página)
      await BookContentIndexDao(db).upsert(
        a.id,
        BookIndex(
          contentSha256: shaDoLivroTeste(1),
          layout: 'reflowable',
          spine: const [
            SpineInfo(path: 'a.xhtml', linear: true, chars: 100000),
            SpineInfo(path: 'n.xhtml', linear: false, chars: 150000),
            SpineInfo(path: 'b.xhtml', linear: true, chars: 200000),
          ],
          toc: const [],
          refPages: RefPageMap.synthetic(const [0]),
          refPageVersion: refPageVersion,
        ),
        builtAt: t0Teste,
      );
      await ReadingPositionsDao(db).upsert(_posicao(a, progresso: 0.5));
      await sessoes([
        // fora de ordem de propósito: vale a ordem de início
        _sessao(a, _local(10, 3, 10), segundos: 300, paginas: 3), // 900/min
        _sessao(
          a,
          _local(10, 1, 10),
          segundos: 600,
          paginas: 10,
        ), // 1.500/min — começa a média
        _sessao(
          a,
          _local(10, 2, 10),
          segundos: 179,
          paginas: 9,
        ), // curta: não entra
        _sessao(
          b,
          _local(10, 4, 10),
          segundos: 600,
          paginas: 4,
        ), // livro b (1.500 por página): 600/min
        _sessao(
          a,
          _local(10, 4, 12),
          segundos: 900,
        ), // sem página lida: não entra
      ]);
      // 1.500 → 0,2 × 900 + 0,8 × 1.500 = 1.380 → 0,2 × 600 + 0,8 × 1.380 = 1.224 car./min
      // 150.000 caracteres ÷ 1.224 = 122,5 min → 120 min (a 10 min acima de 1 h)
      expect(
        (await repo.read(_agora)).continueReading!.timeLeft,
        const Duration(minutes: 120),
      );
    });

    test(
      'índice ilegível: o livro conta pelas páginas de referência',
      () async {
        final a = _livro(
          1,
          status: ShelfStatus.reading,
          aberto: _local(10, 5, 8),
          paginas: 40,
          capitulos: 12,
        );
        await gravar([a]);
        await ReadingPositionsDao(db)
            .upsert(_posicao(a, progresso: 0, capitulo: 4));
        await db.customStatement(
          "INSERT INTO book_content_index (user_book_id, content_sha256, ref_page_version, spine_json, "
          "char_counts_json, toc_json, ref_pages_json, built_at) VALUES (?, 'x', 1, '{\"items\": 3}', '[]', "
          "'[]', '{}', '2026-10-01T00:00:00.000Z')",
          [a.id],
        );
        // 40 × 1.500 ÷ 1.000 = 60 min
        final h = (await repo.read(_agora)).continueReading!;
        expect(h.timeLeft, const Duration(minutes: 60));
        // o "Cap. N de M" volta ao de antes da G20: a folha do sumário e o total do livro
        expect((h.chapter, h.totalChapters), (5, 12));
      },
    );

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

  group('recém-chegados (D-85, D-255)', () {
    test('só nunca abertos, "quero ler" ou "lido"; fora abandonados e os que já estão em leitura (cada livro aparece uma vez — G08.6)', () async {
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
        ('Lido', RecentStatus.read, BookFormat.epub),
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

    test('um livro marcado como lido vira "Lido" (D-255); abandonado, sai dos recém-chegados', () async {
      final b = _livro(1, titulo: 'X');
      await gravar([b]);
      final emitidos = <HomeSnapshot>[];
      final sub = repo.watch(() => _agora).listen(emitidos.add);
      addTearDown(sub.cancel);
      await _assentar();
      expect(emitidos.last.recent.single.status, RecentStatus.wantToRead);
      await gravar([
        b.copyWith(
          status: ShelfStatus.finished,
          meta: metaTeste(em: t0Teste.add(const Duration(minutes: 1))),
          finishedAt: Nullable(_local(10, 5, 9)),
        ),
      ]);
      await _assentar();
      expect(emitidos.last.recent.single.status, RecentStatus.read);
      await gravar([
        b.copyWith(
          status: ShelfStatus.abandoned,
          meta: metaTeste(em: t0Teste.add(const Duration(minutes: 2))),
        ),
      ]);
      await _assentar();
      expect(emitidos.last.recent, isEmpty);
    });
  });

  group('T03 — a Início 01 (D-252…D-255)', () {
    test('herói: "pág. X de Y" = página da posição e total do livro; sem um dos dois, nulo (D-254)', () async {
      final comTudo = _livro(
        1,
        titulo: 'Com tudo',
        status: ShelfStatus.reading,
        aberto: _local(10, 5, 9),
        paginas: 256,
      );
      await gravar([comTudo]);
      await ReadingPositionsDao(db)
          .upsert(_posicao(comTudo, progresso: 0.62113, pagina: 159));
      var h = (await repo.read(_agora)).continueReading!;
      expect(
        (h.refPage, h.refPagesTotal, h.format),
        (159, 256, BookFormat.epub),
      );

      // sem total de páginas de referência (livro sem índice ainda): a página fica, o total não
      await gravar([comTudo.copyWith(refPagesTotal: const Nullable(null))]);
      h = (await repo.read(_agora)).continueReading!;
      expect((h.refPage, h.refPagesTotal), (159, null));

      // sem posição (nunca aberto no app, mas "lendo"): nem a página
      final semPosicao = _livro(
        2,
        titulo: 'Papel sem posição',
        formato: BookFileFormat.physical,
        status: ShelfStatus.reading,
        aberto: _local(10, 5, 10),
        paginas: 300,
      );
      await gravar([semPosicao]);
      h = (await repo.read(_agora)).continueReading!;
      expect(h.book.title, 'Papel sem posição');
      expect(
        (h.refPage, h.refPagesTotal, h.format),
        (null, 300, BookFormat.physical),
      );
    });

    test('Também lendo: formato; papel com página → página e progresso; papel sem página → tempo já lido; '
        'e-book sem nada disso (D-252, D-253)', () async {
      final heroi = _livro(
        1,
        titulo: 'Herói',
        status: ShelfStatus.reading,
        aberto: _local(10, 5, 19),
      );
      final papelSemPagina = _livro(
        2,
        titulo: 'Papel sem página',
        formato: BookFileFormat.physical,
        status: ShelfStatus.reading,
        aberto: _local(10, 5, 8),
      );
      final papelComPagina = _livro(
        3,
        titulo: 'Papel com página',
        formato: BookFileFormat.physical,
        status: ShelfStatus.reading,
        aberto: _local(10, 4, 8),
        paginas: 425,
      );
      final ebook = _livro(
        4,
        titulo: 'E-book',
        status: ShelfStatus.reading,
        aberto: _local(10, 3, 8),
      );
      final papelSemSessao = _livro(
        5,
        titulo: 'Papel sem sessão',
        formato: BookFileFormat.physical,
        status: ShelfStatus.reading,
        aberto: _local(10, 2, 8),
      );
      await gravar([
        heroi,
        papelSemPagina,
        papelComPagina,
        ebook,
        papelSemSessao,
      ]);
      await ReadingPositionsDao(db)
          .upsert(_posicao(papelComPagina, progresso: 0.81, pagina: 344));
      await ReadingPositionsDao(db)
          .upsert(_posicao(ebook, progresso: 0.34, pagina: 68));
      await sessoes([
        // 3h 40min 59s em sessões de dias diferentes e de qualquer origem (D-252)
        _sessao(papelSemPagina, _local(9, 20, 21), segundos: 2 * 3600),
        _sessao(
          papelSemPagina,
          _local(10, 5, 7),
          segundos: 100 * 60 + 59,
          origem: SessionSource.timer,
        ),
        // não contam: apagada e de outro dono
        _sessao(papelSemPagina, _local(10, 1, 7), segundos: 999, apagada: true),
        _sessao(
          papelSemPagina,
          _local(10, 1, 8),
          segundos: 999,
          dono: _outroDono,
        ),
        // as do e-book e as do papel com página não aparecem no cartão
        _sessao(ebook, _local(10, 3, 8), segundos: 600),
        _sessao(papelComPagina, _local(10, 4, 8), segundos: 600),
      ]);
      final a = (await repo.read(_agora)).alsoReading;
      expect(
        a.map(
          (x) => (x.book.title, x.format, x.paperPage, x.readTime, x.progress),
        ),
        [
          (
            'Papel sem página',
            BookFormat.physical,
            null,
            const Duration(hours: 3, minutes: 40, seconds: 59),
            0.0,
          ),
          ('Papel com página', BookFormat.physical, 344, null, 0.81),
          ('E-book', BookFormat.epub, null, null, 0.34),
          ('Papel sem sessão', BookFormat.physical, null, null, 0.0),
        ],
      );
    });

    test('"N sessões": as que começaram hoje no fuso do aparelho, sem as apagadas nem as de outro dono', () async {
      final b = _livro(
        1,
        status: ShelfStatus.reading,
        aberto: _local(10, 5, 9),
      );
      await gravar([b]);
      await sessoes([
        _sessao(b, _local(10, 5, 0, 30), segundos: 60), // 03:30 UTC: hoje
        _sessao(
          b,
          _local(10, 5, 19),
          segundos: 15,
          origem: SessionSource.timer,
        ),
        // 23:50 de ontem até 00:20 de hoje: conta no dia em que começou
        _sessao(b, _local(10, 4, 23, 50), segundos: 1800),
        _sessao(b, _local(10, 5, 12), segundos: 600, apagada: true),
        _sessao(b, _local(10, 5, 13), segundos: 600, dono: _outroDono),
      ]);
      expect((await repo.read(_agora)).readingDay.sessionsToday, 2);
    });

    test('recém-chegados: "Lido" vale mais que "Novo"; o lido já aberto não entra (D-255)', () async {
      await gravar([
        _livro(
          1,
          titulo: 'Lido de hoje',
          status: ShelfStatus.finished,
          adicionado: _local(10, 5, 9),
        ),
        _livro(
          2,
          titulo: 'Lido antigo',
          formato: BookFileFormat.physical,
          status: ShelfStatus.finished,
          adicionado: _local(9, 1, 9),
        ),
        _livro(
          3,
          titulo: 'Lido no app',
          status: ShelfStatus.finished,
          adicionado: _local(10, 5, 10),
          aberto: _local(10, 5, 11),
        ),
      ]);
      expect(
        (await repo.read(_agora)).recent
            .map((x) => (x.book.title, x.status, x.format)),
        [
          ('Lido de hoje', RecentStatus.read, BookFormat.epub),
          ('Lido antigo', RecentStatus.read, BookFormat.physical),
        ],
      );
    });
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
          'tempo restante (o arquivo escreve; a regra é a velocidade pessoal — D-97)':
              (h.timeLeft, prancha.continueReading!.timeLeft),
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
        'tempo restante (o arquivo escreve; a regra é a velocidade pessoal — D-97)',
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
      // 256 × 1.500 × (1 − 0,62113) ≈ 145 mil caracteres ÷ ≈ 2.000 car./min das sessões do mundo ≈ 70 min
      expect(
        diferencas['tempo restante (o arquivo escreve; a regra é a velocidade pessoal — D-97)'],
        (const Duration(minutes: 70), const Duration(hours: 2, minutes: 10)),
      );
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

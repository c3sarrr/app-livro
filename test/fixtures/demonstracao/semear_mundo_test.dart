// R00.7 (D-267, R6) — a semeadura do modo demonstração: o mundo de referência, o EPUB do Dom Casmurro com o índice
// das telas do leitor, a camada da prancha 01, o clube no cache e o dono, gravados num banco; semear de novo não
// muda nada; e a Início lida desse banco pela fonte real (`LocalHomeRepository` + o ticket do clube do cache)
// comparada com a prancha 01: o que bate depois da camada e, uma a uma, as diferenças que as regras do app mantêm.
import 'dart:io';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/model/nullable.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/catalog/data/catalog_cache_dao.dart';
import 'package:app_leitura/features/catalog/data/local_catalog.dart';
import 'package:app_leitura/features/clubs/data/clubs_cache.dart';
import 'package:app_leitura/features/home/data/cached_club_ticket_source.dart';
import 'package:app_leitura/features/home/data/catalog_for_you_source.dart';
import 'package:app_leitura/features/home/data/local_home_repository.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mundo_2026_09_20.dart';
import '../telas/inicio01.dart';
import 'camada_inicio01.dart';
import 'catalogo_demonstracao.dart';
import 'semear_mundo.dart';

typedef _Cartao = (
  String,
  BookFormat,
  int? paperPage,
  Duration? readTime,
  double progress,
);

List<_Cartao> _cartoes(List<AlsoReadingItem> a) => [
  for (final x in a)
    (x.book.title, x.format, x.paperPage, x.readTime, x.progress),
];

/// As tabelas pessoais (sem os apagados).
const _tabelas = [
  'user_books',
  'reading_positions',
  'reading_sessions',
  'bookmarks',
  'ink_layers',
  'annotations',
  'highlight_labels',
];

Future<Map<String, int>> _contagens(AppDatabase db) async => {
  for (final t in _tabelas)
    t:
        (await db
                .customSelect(
                  'SELECT count(*) n FROM $t WHERE deleted_at IS NULL',
                )
                .getSingle())
            .read<int>('n'),
};

void main() {
  final m = mundoReferencia;
  late AppDatabase db;
  late Directory livros;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    livros = Directory.systemTemp.createTempSync('booknest_r00_semear_');
  });
  tearDown(() async {
    await db.close();
    livros.deleteSync(recursive: true);
  });

  test('grava o mundo, o EPUB e o índice do Dom Casmurro, a camada da 01, o clube e o dono', () async {
    expect(await semeado(db), isFalse);
    await semearMundo(db, livros: livros);

    // o mundo inteiro, mais o Brás Cubas e as 6 sessões dele e a 2ª sessão de hoje (a camada)
    expect(await _contagens(db), {
      'user_books': m.livros.length + 1,
      'reading_positions': m.posicoes.length,
      'reading_sessions': m.sessoes.length + minutosBrasCubas.length + 1,
      'bookmarks': m.marcadores.length,
      'ink_layers': m.camadas.length,
      'annotations': m.anotacoes.length,
      'highlight_labels': m.rotulos.length,
    });
    expect(m.anotacoesDo(Slugs.domCasmurro), hasLength(12));

    final dc = m.domCasmurro;
    final arquivo = arquivoDoDomCasmurro(livros);
    expect(arquivo.existsSync(), isTrue);
    expect(arquivo.parent.path, livros.path);
    final f = (await LocalFilesDao(db).byBook(dc.id))!;
    expect(
      (f.path, f.sha256, f.bytes),
      (arquivo.path, dc.contentSha256, arquivo.lengthSync()),
    );
    final indice = (await BookContentIndexDao(db).byBook(dc.id))!;
    expect(indice.refPagesTotal, 256, reason: 'as contagens da tela 19');

    final bras = (await UserBooksDao(db).byId(idBrasCubas))!;
    expect(
      (bras.title, bras.isbn13, bras.status.name, bras.format.name),
      ('Memórias Póstumas de Brás Cubas', isbnBrasCubas, 'reading', 'physical'),
    );
    final cache = await CatalogCacheDao(db).byIsbn(isbnBrasCubas);
    expect(
      cache is CachedBook ? cache.book.pages : null,
      paginasBrasCubas,
      reason: 'o total da folha da sessão (D-260)',
    );

    // as 2 sessões de hoje: a de 18 min do mundo em 10 + 8 (135 → 147 → 159, as 24 páginas de hoje)
    final hoje = await db
        .customSelect(
          'SELECT active_seconds, ref_page_from, ref_page_to, pages_viewed FROM reading_sessions '
          'WHERE user_book_id = ?1 AND started_at >= ?2 AND deleted_at IS NULL ORDER BY started_at',
          variables: [
            Variable.withString(dc.id),
            Variable.withString(
              m.agora.subtract(const Duration(hours: 12)).toIso8601String(),
            ),
          ],
        )
        .get();
    expect(
      [
        for (final r in hoje)
          (
            r.read<int>('active_seconds'),
            r.read<int>('ref_page_from'),
            r.read<int>('ref_page_to'),
            r.read<int>('pages_viewed'),
          ),
      ],
      [
        (minutosDeHoje.$1 * 60, 135, 147, 12),
        (minutosDeHoje.$2 * 60, 147, 159, 12),
      ],
    );

    expect(await KvDao(db).get(OwnerKeys.guest), m.usuarioId);
    expect(await LocalLibrary(db).activeOwnerId(), m.usuarioId);
    final clubes = ClubsCache(() async => db);
    expect((await clubes.clubs(m.usuarioId)).single.id, m.clube.id);
    expect(
      await clubes.notifications(m.usuarioId),
      m.perfil.notificacoesNaoLidas,
    );
    expect(await semeado(db), isTrue);
    expect(await KvDao(db).get(chaveSemeado), versaoDaSemeadura);
  });

  test('semearSeFaltar semeia uma vez: semear de novo não regrava o banco nem o arquivo', () async {
    await semearSeFaltar(db, livros: livros);
    final antes = await _contagens(db);

    // o que a pessoa mudou no demo continua (a marca diz que o banco já tem o mundo)
    final dc = m.domCasmurro;
    final depois = m.agora.add(const Duration(hours: 1));
    await UserBooksDao(db).upsert(
      dc.copyWith(
        meta: dc.meta.edited(
          depois,
          Hlc(depois.millisecondsSinceEpoch, 0, m.aparelhoId),
        ),
        lastOpenedAt: Nullable(depois),
      ),
    );
    arquivoDoDomCasmurro(livros).deleteSync();
    await semearSeFaltar(db, livros: livros);
    expect(await _contagens(db), antes);
    expect((await UserBooksDao(db).byId(dc.id))!.lastOpenedAt, depois);
    expect(arquivoDoDomCasmurro(livros).existsSync(), isFalse);
  });

  test('a Início do banco semeado × a prancha 01: o que bate e as diferenças, uma a uma', () async {
    await semearMundo(db, livros: livros);
    final pasta = Directory('${livros.path}${Platform.pathSeparator}catalogo');
    await semearCatalogoSeFaltar(pasta);
    final catalogo = await SqliteLocalCatalog.open(
      arquivoDoCatalogo(pasta).path,
    );
    addTearDown(catalogo.close);
    final s = await LocalHomeRepository(
      database: () async => db,
      owner: () async => LocalLibrary(db).activeOwnerId(),
      utcOffsetAt: (_) => m.fuso,
      forYou: CatalogForYouSource(() async => catalogo, language: 'por'),
      club: CachedClubTicketSource(() async => db, utcOffsetAt: (_) => m.fuso),
    ).read(m.agora);
    final p = TelaInicio01.snapshot(TelaInicio01.agora);

    // ---- o que bate ----
    final h = s.continueReading!;
    final ph = p.continueReading!;
    expect(
      (h.book.title, h.book.author, h.format, h.refPage, h.refPagesTotal),
      (ph.book.title, ph.book.author, ph.format, ph.refPage, ph.refPagesTotal),
    );
    expect((h.refPage, h.refPagesTotal), (159, 256), reason: 'pág. 159 de 256');
    expect(h.highlightsCount, ph.highlightsCount);
    expect((h.progress * 100).round(), (ph.progress * 100).round());
    final d = s.readingDay;
    final pd = p.readingDay;
    expect(
      (d.readMinutes, d.goalMinutes, d.streakDays, d.sessionsToday),
      (pd.readMinutes, pd.goalMinutes, pd.streakDays, pd.sessionsToday),
    );
    expect(
      (d.readMinutes, d.goalMinutes, d.streakDays, d.sessionsToday),
      (18, 30, 12, 2),
      reason: '18 de 30 min, 12 dias, 2 sessões',
    );
    expect(d.badgeTargetDays, pd.badgeTargetDays);
    expect(
      d.week.map((w) => (w.date, w.minutes, w.isToday)),
      pd.week.map((w) => (w.date, w.minutes, w.isToday)),
    );
    expect(_cartoes(s.alsoReading), _cartoes(p.alsoReading));
    expect(_cartoes(s.alsoReading).first, (
      'Memórias Póstumas de Brás Cubas',
      BookFormat.physical,
      null,
      const Duration(hours: 3, minutes: 40),
      0.0,
    ), reason: 'Papel · 3h 40min');
    expect(
      s.recent.map((r) => (r.book.title, r.book.author, r.format)),
      p.recent.map((r) => (r.book.title, r.book.author, r.format)),
    );
    final c = s.club!;
    final pc = p.club!;
    expect(
      (
        c.id,
        c.namePrefix,
        c.nameHighlight,
        c.book.title,
        c.book.author,
        c.untilChapter,
        c.participantsCount,
        c.groupProgress,
        c.userProgress,
        c.userInitial,
        c.unreadMessages,
        c.nextMeeting,
      ),
      (
        pc.id,
        pc.namePrefix,
        pc.nameHighlight,
        pc.book.title,
        pc.book.author,
        pc.untilChapter,
        pc.participantsCount,
        pc.groupProgress,
        pc.userProgress,
        pc.userInitial,
        pc.unreadMessages,
        pc.nextMeeting,
      ),
      reason: 'o ticket do clube, refeito pela R3 a partir do cache',
    );
    expect(c.shownParticipants, pc.shownParticipants);
    expect(s.now, p.now);
    expect(
      s.forYou?.reasonAuthor,
      p.forYou!.reasonAuthor,
      reason: '"Porque você lê Machado de Assis" — do catálogo do demo',
    );

    // ---- as diferenças que ficam (as regras do app; a lista do R00.md) ----
    final diferencas = <String, Object?>{
      if (d.highlightsToday != pd.highlightsToday)
        'grifos hoje (D-60: o mundo tem 1 grifo hoje)': (
          d.highlightsToday,
          pd.highlightsToday,
        ),
      if (h.progress != ph.progress)
        'progresso (a prancha arredonda a 2 casas)': (h.progress, ph.progress),
      if (h.timeLeft != ph.timeLeft)
        'tempo restante (a regra é a velocidade pessoal — D-97)': (
          h.timeLeft,
          ph.timeLeft,
        ),
      if (d.week.map((w) => w.barHeightPx).join() !=
          pd.week.map((w) => w.barHeightPx).join())
        'alturas das barras (D-10: arquivo × regra)': true,
      if (s.recent.map((r) => r.status).join() !=
          p.recent.map((r) => r.status).join())
        'recém-chegados: o Frankenstein é "Novo" (D-88), não "Quero ler"': (
          [for (final r in s.recent) r.status],
          [for (final r in p.recent) r.status],
        ),
      if (c.book.cover != pc.book.cover || c.book.id != pc.book.id)
        'capa do clube (a foto do catálogo × a desenhada — D-79)': true,
      if (s.dailyReview != p.dailyReview)
        'revisão do dia (D-247: só a fixture até a T05)': (
          s.dailyReview,
          p.dailyReview,
        ),
      if (s.forYou?.items.map((b) => b.title).join() !=
          p.forYou!.items.map((b) => b.title).join())
        'Para você (D-81: um autor só, a edição mais nova primeiro)': (
          [for (final b in s.forYou?.items ?? const <Book>[]) b.title],
          [for (final b in p.forYou!.items) b.title],
        ),
      if (s.user.firstName != p.user.firstName)
        'usuário (a conta — no demo, homeAccountUserProvider)': (
          s.user.firstName,
          p.user.firstName,
        ),
    };
    expect(diferencas.keys, [
      'grifos hoje (D-60: o mundo tem 1 grifo hoje)',
      'progresso (a prancha arredonda a 2 casas)',
      'tempo restante (a regra é a velocidade pessoal — D-97)',
      'alturas das barras (D-10: arquivo × regra)',
      'recém-chegados: o Frankenstein é "Novo" (D-88), não "Quero ler"',
      'capa do clube (a foto do catálogo × a desenhada — D-79)',
      'revisão do dia (D-247: só a fixture até a T05)',
      'Para você (D-81: um autor só, a edição mais nova primeiro)',
      'usuário (a conta — no demo, homeAccountUserProvider)',
    ]);
    expect(diferencas['grifos hoje (D-60: o mundo tem 1 grifo hoje)'], (1, 2));
    final (situacoes, situacoesDaPrancha) =
        diferencas['recém-chegados: o Frankenstein é "Novo" (D-88), não "Quero ler"']!
            as (List<RecentStatus>, List<RecentStatus>);
    expect(situacoes, [
      RecentStatus.isNew,
      RecentStatus.read,
      RecentStatus.isNew,
    ]);
    expect(situacoesDaPrancha, [
      RecentStatus.wantToRead,
      RecentStatus.read,
      RecentStatus.isNew,
    ]);
    // o catálogo do demo (Penguin-Companhia): Memorial de Aires (2022), depois as duas de 2012 pelo ISBN; a Casa de
    // Pensão da prancha é de outro autor
    final (sugestoes, sugestoesDaPrancha) =
        diferencas['Para você (D-81: um autor só, a edição mais nova primeiro)']!
            as (List<String>, List<String>);
    expect(sugestoes, ['Memorial de Aires', 'Quincas Borba', 'Esaú e Jacó']);
    expect(sugestoesDaPrancha, [
      'Esaú e Jacó',
      'Memorial de Aires',
      'Casa de Pensão',
    ]);
    // a média móvel da D-97 (α = 0,2) pesa as duas sessões de hoje mais que a de 18 min do mundo (70 min no T03)
    expect(
      diferencas['tempo restante (a regra é a velocidade pessoal — D-97)'],
      (
        const Duration(hours: 1, minutes: 20),
        const Duration(hours: 2, minutes: 10),
      ),
    );
  });
}

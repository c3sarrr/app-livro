// T04.12 (D-244) — o cronômetro do livro de papel no app inteiro, com o banco real em memória (o padrão da G20:
// `abrirAppComLivro`, a Início pela fonte real, o relógio da G20 e o fuso UTC) e os provedores reais do cronômetro sobre
// o mesmo banco (a sessão aberta no KV, o writer, a estante e o catálogo do aparelho). A estante: o Dom Casmurro
// (e-book) no herói, com 2 sessões hoje (20 + 10 min), e o Brás Cubas de papel — sem página e sem total; o cache do
// catálogo sabe as 368 — no Também lendo. O fluxo:
// - o play começa a sessão → pausar na mini-barra → retomar no cartão → o "Continuar" do herói abre o leitor e pausa o
//   papel (D-263) → retomar → encerrar na pág. 120 (o total já vem do catálogo — D-260) → a Início relê do banco:
//   3 sessões, os minutos somados (20 + 10 + 8:42 → 38), o Brás Cubas no herói com "pág. 120 de 368" e "PAPEL"
//   (D-261) e fora do Também lendo;
// - o "Ler agora" com o papel no herói começa a sessão dele (D-258); o app fecha com ela rodando e volta 1 h depois em
//   "1:08:42" — a sessão aberta vem do banco do aparelho, não da memória.
// O plano pedia o "Ler agora" com o e-book no herói abrindo o leitor; com um livro de papel em leitura a D-258 escolhe o
// papel (o "Ler agora" nunca abre o leitor com sessão aberta), então o leitor abre pelo "Continuar" do herói — a pausa
// é da rota do leitor, por qualquer caminho (D-263).
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_inicio.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/catalog/data/catalog_cache_dao.dart';
import 'package:app_leitura/features/catalog/domain/catalog_book.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reading_session/application/paper_timer_controller.dart';
import 'package:app_leitura/features/reading_session/application/second_ticker.dart';
import 'package:app_leitura/features/reading_session/data/paper_timer_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/paper_timer_fakes.dart' show ManualTicker;
import '../support/app_com_livro.dart';
import '../support/load_fonts.dart';
import '../support/personal_builders.dart';
import '../support/pump_reader.dart';
import '../support/reader_harness.dart';

const String _isbn = '9788535910667';
const String _titulo = 'Memórias Póstumas de Brás Cubas';

Finder _k(String k) => find.byKey(ValueKey<String>(k));

/// O Brás Cubas de papel na estante do leitor (sem página, sem total, chegou há 10 dias), as 368 páginas no cache do
/// catálogo do aparelho (o scanner guardou) e as 2 sessões de hoje no Dom Casmurro: 20 min às 8h e 10 min às 10h.
Future<UserBook> _estante(LivroNaEstante livro) async {
  final papel = UserBook(
    id: idTeste(41),
    meta: metaTeste(userId: livro.leitor),
    title: _titulo,
    authorDisplay: 'Machado de Assis',
    format: BookFileFormat.physical,
    status: ShelfStatus.reading,
    addedAt: agoraG20.subtract(const Duration(days: 10)),
    isbn13: _isbn,
  );
  await UserBooksDao(livro.db).upsert(papel);
  await CatalogCacheDao(livro.db).putBook(
    const CatalogBook(
      isbn13: _isbn,
      title: _titulo,
      pages: 368,
      source: 'openlibrary',
    ),
    agoraG20.subtract(const Duration(days: 10)),
  );
  for (final (n, hora, segundos) in [(51, 8, 1200), (52, 10, 600)]) {
    await ReadingSessionsDao(livro.db).upsert(
      sessaoTeste(
        n,
        livro: livro.book.id,
        inicio: DateTime.utc(2026, 10, 9, hora),
        segundos: segundos,
        dono: livro.leitor,
      ),
    );
  }
  await LocalLibrary(livro.db).setActiveOwner(livro.leitor);
  return papel;
}

/// O cronômetro real sobre o banco do [livro] (cada abertura do app, uma biblioteca e um tique novos); o fuso é o
/// da Início (UTC).
List<Override> _cronometroDoBanco(LivroNaEstante livro, ManualTicker tique) => [
  localDatabaseProvider.overrideWith((ref) async => livro.db),
  localLibraryProvider.overrideWith((ref) async => LocalLibrary(livro.db)),
  localVersioningProvider.overrideWith((ref) async => livro.versioning),
  secondTickerProvider.overrideWithValue(tique),
  paperTimerUtcOffsetProvider.overrideWithValue((_) => Duration.zero),
];

/// Deixa o banco (em memória, com futuros de verdade) gravar e a Início reler.
Future<void> _banco(WidgetTester tester, [int voltas = 8]) async {
  for (var i = 0; i < voltas; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Rola a Início até [k] ficar no meio da tela (fora da mini-barra e da barra de abas) e toca.
Future<void> _tocar(WidgetTester tester, String k) async {
  await Scrollable.ensureVisible(tester.element(_k(k)), alignment: 0.4);
  await tester.pumpAndSettle();
  await tester.tap(_k(k));
  await tester.pump();
  await _banco(tester);
  await tester.pumpAndSettle();
}

/// O relógio anda [d] e o tique bate uma vez.
Future<void> _andar(
  WidgetTester tester,
  RelogioG20 relogio,
  ManualTicker tique,
  Duration d,
) async {
  relogio.andar(d);
  tique.tick();
  await tester.pump(Duration.zero);
  await tester.pump();
}

String _tempo(WidgetTester tester) => textosEm(tester, 'miniBar.time');

String _icone(WidgetTester tester, String k) =>
    tester.widget<AppSvg>(_k(k)).asset;

/// O Voltar do sistema até a Início.
Future<void> _voltarAteInicio(WidgetTester tester) async {
  for (var i = 0; i < 6 && _k('hero.title').evaluate().isEmpty; i++) {
    await tester.binding.handlePopRoute();
    for (var q = 0; q < 30; q++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await _banco(tester, 4);
  }
  await esperarInicio(tester);
  await _banco(tester);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  late UserBook papel;
  setUp(() async {
    livro = await domCasmurroEmLeitura();
    papel = await _estante(livro);
  });
  tearDown(() async => livro.close());

  testWidgets('começar no play → pausar → retomar → o leitor pausa → encerrar na pág. 120 de 368: a Início relê do '
      'banco (3 sessões, 38 min, o Brás Cubas no herói); o "Ler agora" começa a sessão do papel, o app fecha com ela '
      'rodando e volta 1 h depois em "1:08:42"', (tester) async {
    final relogio = RelogioG20();
    final t0 = relogio.agora;
    var tique = ManualTicker();
    await abrirAppComLivro(
      tester,
      livro,
      relogio: relogio,
      cronometro: _cronometroDoBanco(livro, tique),
    );
    await _banco(tester);
    await tester.pumpAndSettle();

    // antes: o Dom Casmurro no herói, 2 sessões e 30 min hoje, o Brás Cubas com o play e nenhuma mini-barra
    expect(textosEm(tester, 'hero.title'), 'Dom Casmurro');
    expect(textosEm(tester, 'today.chip.sessions'), '2 sessões');
    expect(textosEm(tester, 'today.dial.value'), '30');
    expect(textosEm(tester, 'alsoReading.card1.title'), _titulo);
    expect(_k('alsoReading.card2'), findsNothing);
    expect(_icone(tester, 'alsoReading.card1.play.icon'), AppIconsInicio.play);
    expect(_k('miniBar'), findsNothing);

    // o play começa a sessão (a sessão aberta vai ao KV do banco)
    await _tocar(tester, 'alsoReading.card1.play');
    expect(_k('miniBar'), findsOneWidget);
    expect(textosEm(tester, 'miniBar.title'), _titulo);
    expect(textosEm(tester, 'miniBar.kicker'), 'LENDO · PAPEL');
    expect(_tempo(tester), '00:00');
    expect(_icone(tester, 'alsoReading.card1.play.icon'), AppIconsInicio.pause);
    final aberta = await tester.runAsync(
      () => KvPaperTimerStore(livro.db).load(livro.leitor),
    );
    expect(aberta!.userBookId, papel.id);
    expect(aberta.isRunning, isTrue);

    // 5 min → pausa na mini-barra → 2 min parados → retoma no cartão → 3 min
    await _andar(tester, relogio, tique, const Duration(minutes: 5));
    expect(_tempo(tester), '05:00');
    await tester.tap(_k('miniBar.pause'));
    await tester.pump();
    await _banco(tester);
    await tester.pumpAndSettle();
    expect(textosEm(tester, 'miniBar.kicker'), 'EM PAUSA · PAPEL');
    await _andar(tester, relogio, tique, const Duration(minutes: 2));
    expect(_tempo(tester), '05:00', reason: 'a pausa não conta');
    await _tocar(tester, 'alsoReading.card1.play');
    expect(textosEm(tester, 'miniBar.kicker'), 'LENDO · PAPEL');
    await _andar(tester, relogio, tique, const Duration(minutes: 3));
    expect(_tempo(tester), '08:00');

    // D-263: o "Continuar" do herói (o e-book) abre o leitor e pausa o papel; de volta, a mini-barra em pausa
    await _tocar(tester, 'hero.cta');
    await esperarLeitor(tester);
    await _banco(tester, 4);
    expect(_k('miniBar'), findsNothing, reason: 'o leitor cobre o shell');
    final pausada = await tester.runAsync(
      () => KvPaperTimerStore(livro.db).load(livro.leitor),
    );
    expect(pausada!.isRunning, isFalse, reason: 'o leitor pausou o papel');
    await _voltarAteInicio(tester);
    expect(textosEm(tester, 'miniBar.kicker'), 'EM PAUSA · PAPEL');
    expect(_tempo(tester), '08:00');

    // retoma na mini-barra, 42 s, e encerra na pág. 120 (o total vem do catálogo do aparelho)
    await tester.tap(_k('miniBar.pause'));
    await tester.pump();
    await _banco(tester);
    await tester.pumpAndSettle();
    await _andar(tester, relogio, tique, const Duration(seconds: 42));
    expect(_tempo(tester), '08:42');
    final fim = relogio.agora;
    await tester.tap(_k('miniBar.title'));
    await tester.pump();
    await _banco(tester);
    await tester.pumpAndSettle();
    expect(_k('session.sheet'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: _k('session.sheet.total'),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      '368',
    );
    await tester.enterText(
      find.descendant(
        of: _k('session.sheet.page'),
        matching: find.byType(EditableText),
      ),
      '120',
    );
    await tester.pump();
    await tester.tap(_k('session.sheet.end'));
    await tester.pump();
    await _banco(tester, 12);
    await tester.pumpAndSettle();

    // a Início relê do banco
    expect(_k('session.sheet'), findsNothing);
    expect(_k('miniBar'), findsNothing);
    expect(textosEm(tester, 'hero.title'), _titulo, reason: 'D-261');
    expect(textosEm(tester, 'hero.pagePill'), 'pág. 120 de 368');
    expect(textosEm(tester, 'hero.formatPill'), 'PAPEL');
    expect(textosEm(tester, 'today.chip.sessions'), '3 sessões');
    expect(
      textosEm(tester, 'today.dial.value'),
      '38',
      reason: '20 min + 10 min + 8 min 42 s',
    );
    expect(textosEm(tester, 'alsoReading.card1.title'), 'Dom Casmurro');
    expect(_k('alsoReading.card2'), findsNothing, reason: 'fora do Também');
    // e no banco: a sessão timer, a posição de papel e o livro (R7)
    final (sessoes, posicao, livroDepois) = (await tester.runAsync(
      () async => (
        [
          for (final s in await livro.db.select(livro.db.readingSessions).get())
            if (s.userBookId == papel.id) s,
        ],
        await ReadingPositionsDao(livro.db).forBook(papel.id),
        await UserBooksDao(livro.db).byId(papel.id),
      ),
    ))!;
    expect(sessoes, hasLength(1));
    expect(sessoes.single.activeSeconds, 8 * 60 + 42);
    expect(sessoes.single.source.code, 'timer');
    expect(sessoes.single.startedAt, t0);
    expect(sessoes.single.endedAt, fim);
    expect(posicao!.locator, PaperLocator(120));
    expect(livroDepois!.refPagesTotal, 368);
    expect(livroDepois.lastOpenedAt, fim);
    expect(
      await tester.runAsync(
        () => KvPaperTimerStore(livro.db).load(livro.leitor),
      ),
      isNull,
    );

    // D-258: o "Ler agora" com o papel no herói começa a sessão dele; 8 min 42 s
    await _tocar(tester, 'today.readNow');
    expect(textosEm(tester, 'miniBar.title'), _titulo);
    await _andar(
      tester,
      relogio,
      tique,
      const Duration(minutes: 8, seconds: 42),
    );
    expect(_tempo(tester), '08:42');

    // o app fecha com a sessão rodando; 1 h depois, outro ProviderScope sobre o mesmo banco
    await tester.pumpWidget(const SizedBox.shrink());
    await _banco(tester, 4);
    relogio.andar(const Duration(hours: 1));
    tique = ManualTicker();
    await abrirAppComLivro(
      tester,
      livro,
      relogio: relogio,
      cronometro: _cronometroDoBanco(livro, tique),
    );
    await _banco(tester);
    await tester.pumpAndSettle();
    expect(_k('miniBar'), findsOneWidget);
    expect(_tempo(tester), '1:08:42');
    expect(textosEm(tester, 'miniBar.kicker'), 'LENDO · PAPEL');
    expect(tique.hasListener, isTrue, reason: 'o tique voltou a bater');
    await _andar(tester, relogio, tique, const Duration(seconds: 1));
    expect(_tempo(tester), '1:08:43');
    // a sessão aberta ainda não conta no dia (só ao encerrar)
    expect(textosEm(tester, 'today.chip.sessions'), '3 sessões');
    expect(textosEm(tester, 'today.dial.value'), '38');

    // fecha o app: o `watch` do dono no banco (o drift) fecha a consulta num timer de 0 s
    await tester.pumpWidget(const SizedBox.shrink());
    await _banco(tester, 2);
  });
}

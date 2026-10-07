// G15.4 — o sumário pela rota real, com o Dom Casmurro do Gutenberg num banco em memória: "Sumário" abre a folha na aba
// Capítulos (sai o aviso da D-118), com os numerais do livro (D-150) e sem a faixa do clube no app (D-149); ×, Voltar,
// véu e alça fecham e devolvem os controles; tocar num capítulo salta, fecha tudo e mostra "← Voltar à pág. N"
// (D-151); o atual só fecha; na aba Marcadas a fita tira e devolve a mesma marca (na hora, mesmo com dois toques
// seguidos), o cartão fica até fechar e a fita da ilha de cima acompanha (D-152); o cartão abre a página; PDF com e
// sem estrutura (D-154); Noite.
import 'dart:io';

import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_numbers.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_overlays.dart'
    show readerSoonText;
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' show pdfrxInitialize;

import '../../../support/app_text_finder.dart';
import '../../../support/canvas.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

Future<void> _quadros(WidgetTester tester, [int n = 40]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Espera o banco (leituras da folha, gravações da fita) e a tela.
Future<void> _banco(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

String _texto(WidgetTester tester, String id) => tester
    .widget<AppText>(
      find
          .descendant(
            of: _key(id),
            matching: find.byType(AppText),
            matchRoot: true,
          )
          .first,
    )
    .span
    .toPlainText();

Future<void> _abrirControles(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  expect(_key('r20.topIsland'), findsOneWidget);
}

/// Abre os controles e toca em "Sumário"; espera os 150 ms e a leitura do banco.
Future<void> _abrirSumario(WidgetTester tester) async {
  await _abrirControles(tester);
  await tester.tap(_key('r20.bottomIsland.tools.toc'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _banco(tester);
  expect(_key('toc.sheet'), findsOneWidget);
}

Future<void> _fechou(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  expect(_key('toc.sheet'), findsNothing);
  expect(_key('bm.sheet'), findsNothing);
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async {
    livro = await LivroNaEstante.domCasmurro();
    await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
  });
  tearDown(() async => livro.close());

  /// O capítulo (folha) da posição guardada.
  int capituloAtual() => chapterIndexAt(
    livro.index,
    livro.index.globalOffset(2, livro.index.spine[2].chars ~/ 2)!,
  );

  testWidgets(
    '"Sumário" abre a folha em Capítulos: os 153 do Gutenberg com os numerais, o atual no cartão; sem faixa no app; × devolve os controles',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final t = await abrirLeitor(tester, livro);
      await _abrirSumario(tester);
      expect(findAppText(readerSoonText), findsNothing);
      expect(_key('r20.topIsland'), findsNothing, reason: 'os controles somem');
      expect(t.ui.log.last, 'padrão', reason: 'a barra de status fica');
      expect(
        _texto(tester, 'toc.sheet.subtitle'),
        'Dom Casmurro · 153 capítulos',
      );
      final c = capituloAtual();
      final atual = 'toc.sheet.chapters.ch${c + 1}';
      expect(
        tester.widget<NeoBox>(_key('$atual.link')).shadow,
        const Offset(2, 2),
      );
      // o capítulo c do Gutenberg é a folha c: as duas primeiras são o rosto e a academia (sem numeral)
      expect(_texto(tester, '$atual.numeral'), isNotEmpty);
      expect(
        _key('toc.sheet.club'),
        findsNothing,
        reason: 'D-149: sem clube até a G21',
      );
      expect(_key('toc.sheet.chapters.ch$c.read'), findsOneWidget);
      await tester.tap(_key('toc.sheet.close'));
      await _fechou(tester);
      expect(
        _key('r20.topIsland'),
        findsOneWidget,
        reason: 'volta aos controles',
      );
    },
  );

  testWidgets('Voltar, o véu e a alça fecham e devolvem os controles', (
    tester,
  ) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _abrirSumario(tester);
    await tester.binding.handlePopRoute();
    await _fechou(tester);
    expect(_key('r20.topIsland'), findsOneWidget);
    await tester.tap(_key('r20.bottomIsland.tools.toc'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await _banco(tester);
    await tester.tapAt(const Offset(195, 60));
    await _fechou(tester);
    expect(_key('r20.topIsland'), findsOneWidget);
    await tester.tap(_key('r20.bottomIsland.tools.toc'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await _banco(tester);
    await tester.drag(_key('toc.sheet.grabber'), const Offset(0, 80));
    await _fechou(tester);
    expect(_key('r20.topIsland'), findsOneWidget);
  });

  testWidgets(
    'tocar num capítulo adiante salta para ele, fecha tudo e mostra "Voltar à pág. N"; o atual só fecha (D-151)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final antes = _doc(tester).numbers.refPage;
      await _abrirSumario(tester);
      final c = capituloAtual();
      // o atual: fecha tudo e fica na página
      await tester.tap(_key('toc.sheet.chapters.ch${c + 1}'));
      await _fechou(tester);
      expect(_key('r20.topIsland'), findsNothing);
      expect(_doc(tester).numbers.refPage, antes);
      expect(findAppText('Voltar à pág. $antes'), findsNothing);
      // um adiante: salta para o começo dele
      await _abrirSumario(tester);
      // no Gutenberg todas as entradas são folhas: a folha c + 5 é a entrada c + 5 (páginas adiante — um capítulo
      // que começa na mesma página não guarda volta, D-119)
      await tester.ensureVisible(_key('toc.sheet.chapters.ch${c + 6}'));
      await tester.pump();
      await tester.tap(_key('toc.sheet.chapters.ch${c + 6}'));
      await _fechou(tester);
      await _banco(tester);
      expect(
        _key('r20.topIsland'),
        findsNothing,
        reason: 'a leitura volta limpa',
      );
      final p = livro.index.toc[c + 5];
      final destino = numbersAt(livro.index, p.spine!, p.offset!).refPage;
      expect(destino, greaterThan(antes));
      expect(_doc(tester).numbers.refPage, destino);
      // a volta chega depois de gravar a posição de onde se saiu (D-115)
      for (
        var i = 0;
        i < 20 && findAppText('Voltar à pág. $antes').evaluate().isEmpty;
        i++
      ) {
        await _banco(tester);
      }
      expect(findAppText('Voltar à pág. $antes'), findsOneWidget);
    },
  );

  testWidgets(
    'Marcadas (D-152): a fita tira, o cartão fica com a fita vazia e o contador cai; tocar devolve a mesma marca; reaberta, a tirada some; a fita de cima acompanha',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _abrirControles(tester);
      await tester.tap(_key('r20.topIsland.bookmark'));
      await _banco(tester);
      final dao = BookmarksDao(livro.db);
      final m = (await tester.runAsync(() => dao.forBook(livro.userBookId)))!
          .single;
      await tester.tap(_key('r20.bottomIsland.tools.toc'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await _banco(tester);
      await tester.tap(_key('toc.sheet.tabs.bookmarks'));
      await tester.pump();
      expect(
        _texto(tester, 'bm.sheet.bookmarks.item1.head.page'),
        'pág. ${m.refPage}',
      );
      expect(_key('bm.sheet.bookmarks.item1.head.here'), findsOneWidget);
      await tester.tap(_key('bm.sheet.bookmarks.item1.ribbon'));
      await _banco(tester);
      expect(
        (await tester.runAsync(() => dao.byId(m.id)))!.meta.isDeleted,
        isTrue,
      );
      expect(
        _key('bm.sheet.bookmarks.item1'),
        findsOneWidget,
        reason: 'o cartão fica',
      );
      expect(_texto(tester, 'bm.sheet.tabs.bookmarks.count'), '0');
      await tester.tap(_key('bm.sheet.bookmarks.item1.ribbon'));
      await _banco(tester);
      final volta = (await tester.runAsync(
        () => dao.forBook(livro.userBookId),
      ))!.single;
      expect(
        (volta.id, volta.meta.createdAt, volta.excerpt),
        (m.id, m.meta.createdAt, m.excerpt),
      );
      expect(_texto(tester, 'bm.sheet.tabs.bookmarks.count'), '1');
      // dois toques seguidos, sem esperar o banco: tira e devolve (o 2º toque vale o que a fita mostra)
      await tester.tap(_key('bm.sheet.bookmarks.item1.ribbon'));
      await tester.pump();
      expect(_texto(tester, 'bm.sheet.tabs.bookmarks.count'), '0');
      await tester.tap(_key('bm.sheet.bookmarks.item1.ribbon'));
      await tester.pump();
      expect(_texto(tester, 'bm.sheet.tabs.bookmarks.count'), '1');
      await _banco(tester);
      expect(
        (await tester.runAsync(() => dao.byId(m.id)))!.meta.isDeleted,
        isFalse,
      );
      expect(_texto(tester, 'bm.sheet.tabs.bookmarks.count'), '1');
      expect(
        tester
            .widget<AppSvg>(_key('bm.sheet.bookmarks.item1.ribbon.icon'))
            .asset,
        AppIconsLeitor.ribbonCoral,
      );
      // tira, fecha e reabre: o cartão some
      await tester.tap(_key('bm.sheet.bookmarks.item1.ribbon'));
      await _banco(tester);
      await tester.tap(_key('bm.sheet.close'));
      await _fechou(tester);
      expect(_key('r20.topIsland'), findsOneWidget);
      expect(
        tester.widget<AppSvg>(_key('r20.topIsland.bookmark.icon')).asset,
        AppIconsLeitor.ribbonEmpty,
        reason: 'a fita de cima acompanha',
      );
      await tester.tap(_key('r20.bottomIsland.tools.toc'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await _banco(tester);
      await tester.tap(_key('toc.sheet.tabs.bookmarks'));
      await tester.pump();
      expect(_key('bm.sheet.bookmarks.item1'), findsNothing);
      expect(_key('bm.sheet.hint'), findsOneWidget);
    },
  );

  testWidgets(
    'o cartão das Marcadas abre a página, fecha tudo e mostra a volta (D-151)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final antes = _doc(tester).numbers.refPage;
      // uma marca 10 páginas para trás
      await _abrirControles(tester);
      await tester.tap(_key('r20.topIsland.bookmark'));
      await _banco(tester);
      final dao = BookmarksDao(livro.db);
      final m = (await tester.runAsync(() => dao.forBook(livro.userBookId)))!
          .single;
      // a marca vai para o começo do item 1 (bem antes da página de agora)
      final ali = numbersAt(livro.index, 1, 0);
      await tester.runAsync(
        () => dao.upsert(
          m.copyWith(
            refPage: ali.refPage,
            locator: EpubLocator(
              sha: (m.locator as EpubLocator).sha,
              spine: 1,
              offset: 0,
              refPage: ali.refPage,
              progression: ali.progression,
            ),
          ),
        ),
      );
      await tester.tap(_key('r20.bottomIsland.tools.toc'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await _banco(tester);
      await tester.tap(_key('toc.sheet.tabs.bookmarks'));
      await tester.pump();
      await tester.tap(_key('bm.sheet.bookmarks.item1.link'));
      await _fechou(tester);
      await _banco(tester);
      expect(_key('r20.topIsland'), findsNothing);
      expect(_doc(tester).numbers.refPage, isNot(antes));
      for (
        var i = 0;
        i < 20 && findAppText('Voltar à pág. $antes').evaluate().isEmpty;
        i++
      ) {
        await _banco(tester);
      }
      expect(findAppText('Voltar à pág. $antes'), findsOneWidget);
    },
  );

  testWidgets('Noite: a folha nas cores das ilhas', (tester) async {
    await tester.runAsync(
      () async => ReaderSettingsDao(livro.db).upsert(
        ReaderSettings(
          id: usuarioTeste,
          meta: metaTeste(),
        ).copyWith(paper: ReaderPaper.noite),
      ),
    );
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _abrirSumario(tester);
    final folha = tester.widget<NeoBox>(_key('toc.sheet'));
    expect(folha.color, AppColors.islandNight);
  });

  testWidgets(
    'PDF (D-154): a estrutura do PDF; sem ela, "Este livro não tem sumário."',
    (tester) async {
      final tmp = Directory.systemTemp.createTempSync('booknest_g15_pdf_');
      addTearDown(
        () => tester.runAsync(() async {
          for (var i = 0; i < 20 && tmp.existsSync(); i++) {
            try {
              tmp.deleteSync(recursive: true);
            } on FileSystemException {
              await Future<void>.delayed(const Duration(milliseconds: 100));
            }
          }
        }),
      );
      BookIndex pdf(List<TocPoint> toc) => BookIndex(
        contentSha256: shaTeste,
        layout: 'pdf',
        spine: const [],
        toc: toc,
        refPages: RefPageMap.pdf(2),
      );
      await tester.runAsync(() async {
        final copia = File('test/fixtures/livros/amostra.pdf')
            .copySync('${tmp.path}${Platform.pathSeparator}amostra.pdf');
        await UserBooksDao(livro.db).upsert(
          livro.book.copyWith(format: BookFileFormat.pdf, title: 'Amostra'),
        );
        await LocalFilesDao(livro.db).upsert(
          userBookId: livro.userBookId,
          path: copia.path,
          bytes: copia.lengthSync(),
          sha256: shaTeste,
          now: t0Teste,
        );
        await BookContentIndexDao(livro.db).upsert(
          livro.userBookId,
          pdf(const [
            TocPoint(
              title: '1. Começo',
              spine: 0,
              offset: 0,
              depth: 0,
              leaf: true,
            ),
            TocPoint(
              title: '2. Fim',
              spine: 0,
              offset: 1,
              depth: 0,
              leaf: true,
            ),
          ]),
          builtAt: t0Teste,
        );
      });
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(
        tester,
        livro,
        esperar: false,
        deps: (t) async => livro.readerDeps(
          awake: t.awake,
          pdfInitialize: () => pdfrxInitialize(tmpPath: tmp.path),
        ),
      );
      for (var i = 0; i < 200 && _key('r19.footer').evaluate().isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      await _abrirSumario(tester);
      expect(_texto(tester, 'toc.sheet.chapters.ch1.page'), '1');
      expect(_texto(tester, 'toc.sheet.chapters.ch2.numeral'), '2');
      expect(_key('toc.sheet.chapters.ch1.link'), findsOneWidget);
      await tester.tap(_key('toc.sheet.close'));
      await _fechou(tester);
      await tester.runAsync(
        () =>
            BookContentIndexDao(livro.db)
                .upsert(livro.userBookId, pdf(const []), builtAt: t0Teste),
      );
      await tester.tap(_key('r20.bottomIsland.tools.toc'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await _banco(tester);
      expect(_texto(tester, 'toc.sheet.empty'), 'Este livro não tem sumário.');
    },
  );
}

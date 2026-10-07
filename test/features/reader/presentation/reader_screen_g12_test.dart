// G12.3 — os controles das telas 20/26b pela rota real, com o Dom Casmurro de verdade num banco em memória:
// - abrir com o toque no centro e fechar com o toque fora das ilhas, o arrasto e o Voltar (D-117, D-42), em
//   150 ms pela cor do véu (D-124); com os controles abertos os terços não viram;
// - a barra de status volta com os controles e, no Noite, tem ícones claros (D-105, D-124);
// - as ilhas com as áreas do aparelho (D-124);
// - o Tema: papel e ilhas em 220 ms, gravado na conta, o texto na cor nova e a mesma página (D-121);
// - a fita grava e apaga o marcador; a barra de posição salta e a pílula de voltar aparece ao fechar (D-119);
// - os botões das próximas fases mostram "Chega numa próxima fase" por 2 s (D-118);
// - o PDF: Fonte cinza e sem ação, Tema só em volta (D-122).
import 'dart:io';

import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/features/library/domain/user_book.dart';
import 'package:app_leitura/features/reader/application/pdf_reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/presentation/reader_overlays.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/semantics.dart'
    show CustomSemanticsAction, SemanticsNode;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
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

/// O fundo da tela (o papel).
Color _papel(WidgetTester tester) => tester
    .widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(ReaderScreen),
            matching: find.byType(ColoredBox),
          )
          .first,
    )
    .color;

ReaderPagesPainter _pintor(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((c) => c.painter)
    .whereType<ReaderPagesPainter>()
    .single;

SystemUiOverlayStyle _barra(WidgetTester tester) => tester
    .widget<AnnotatedRegion<SystemUiOverlayStyle>>(_key('leitor.barraDeStatus'))
    .value;

/// Abre os controles (toque no centro) e espera os 150 ms e o banco.
Future<void> _abrirControles(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  expect(_key('r20.topIsland'), findsOneWidget);
}

Future<void> _fecharControles(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  expect(_key('r20.topIsland'), findsNothing);
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async {
    livro = await LivroNaEstante.domCasmurro();
    await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
  });
  tearDown(() async => livro.close());

  testWidgets(
    'o centro abre véu, ilhas e chip em 150 ms (sem o "Fechar" provisório); tocar fora fecha; barra de status',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final t = await abrirLeitor(tester, livro);
      expect(_key('r20.topIsland'), findsNothing);
      expect(_key('r20.fade'), findsNothing, reason: 'fechados, nada montado');
      await tester.tapAt(const Offset(195, 420));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      final veu = ReaderPalette.of(ReaderPaper.creme).paper;
      expect(
        tester.widget<ColoredBox>(_key('r20.fade')).color.a,
        allOf(greaterThan(0.62 * 0.3), lessThan(0.62 * 0.7)),
        reason: 'na metade dos 150 ms',
      );
      await tester.pump(const Duration(milliseconds: 75));
      await _quadros(tester, 4);
      final cor = tester.widget<ColoredBox>(_key('r20.fade')).color;
      expect(cor.toARGB32() & 0xFFFFFF, veu.toARGB32() & 0xFFFFFF);
      expect(cor.a, closeTo(0.62, 0.01));
      for (final id in const [
        'r20.topIsland',
        'r20.timeChip',
        'r20.bottomIsland',
      ]) {
        expect(_key(id), findsOneWidget, reason: id);
      }
      expect(_key('leitor.fechar'), findsNothing, reason: 'D-106 saiu (D-117)');
      expect(tester.getRect(_key('r20.topIsland')).top, 54);
      expect(tester.getRect(_key('r20.timeChip')).top, 130);
      expect(tester.getRect(_key('r20.bottomIsland')).bottom, 844 - 30);
      expect(t.ui.log, ['imersivo', 'padrão'], reason: 'a barra volta (D-105)');
      // não somem sozinhos
      await tester.pump(const Duration(seconds: 30));
      expect(_key('r20.topIsland'), findsOneWidget);
      await _fecharControles(tester);
      expect(t.ui.log, ['imersivo', 'padrão', 'imersivo']);
      expect(t.erros, isEmpty);
    },
  );

  testWidgets(
    'com os controles abertos os terços não viram (fecham); o arrasto vira e fecha',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final antes = _doc(tester).mark;
      await _abrirControles(tester);
      await tester.tapAt(const Offset(360, 420));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await _quadros(tester, 20);
      expect(_key('r20.topIsland'), findsNothing);
      expect(_doc(tester).mark, antes);
      await _abrirControles(tester);
      await tester.dragFrom(const Offset(300, 420), const Offset(-150, 0));
      await _quadros(tester, 20);
      expect(_key('r20.topIsland'), findsNothing);
      expect(_doc(tester).mark.offset, greaterThan(antes.offset));
    },
  );

  testWidgets('o Voltar fecha só os controles; de novo, fecha o livro', (
    tester,
  ) async {
    setCanvasView(tester, logical: const Size(390, 844));
    final t = await abrirLeitor(tester, livro);
    await _abrirControles(tester);
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(_key('r20.topIsland'), findsNothing);
    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(t.ui.log.last, 'imersivo');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsNothing);
  });

  testWidgets('"Fechar o livro" da ilha de cima grava a página e sai', (
    tester,
  ) async {
    setCanvasView(tester, logical: const Size(390, 844));
    final t = await abrirLeitor(tester, livro);
    await tester.tapAt(const Offset(360, 420));
    await _quadros(tester, 20);
    final nova = _doc(tester).mark;
    await _abrirControles(tester);
    await tester.tap(_key('r20.topIsland.close'));
    await tester.pump();
    expect(t.ui.log.last, 'padrão');
    final p = await tester.runAsync(
      () => ReadingPositionsDao(livro.db).forBook(livro.userBookId),
    );
    final l = p!.locator as EpubLocator;
    expect((l.spine, l.offset), (nova.spine, nova.offset));
    await tester.pumpAndSettle();
    expect(find.byType(ReaderScreen), findsNothing);
  });

  testWidgets(
    'ilhas com o aparelho (D-124): iPhone e Android dão 54/130/30; área de cima 59 → 66/142',
    (tester) async {
      for (final (cima, baixo, topo, chip, base) in const [
        (47.0, 34.0, 54.0, 130.0, 30.0),
        (24.0, 0.0, 54.0, 130.0, 30.0),
        (59.0, 48.0, 66.0, 142.0, 44.0),
      ]) {
        await tester.pumpWidget(const SizedBox());
        setCanvasView(
          tester,
          logical: const Size(390, 844),
          safeTop: cima,
          safeBottom: baixo,
        );
        await abrirLeitor(tester, livro);
        await _abrirControles(tester);
        expect(
          tester.getRect(_key('r20.topIsland')).top,
          topo,
          reason: '$cima',
        );
        expect(tester.getRect(_key('r20.timeChip')).top, chip, reason: '$cima');
        expect(
          844 - tester.getRect(_key('r20.bottomIsland')).bottom,
          base,
          reason: '$baixo',
        );
      }
    },
  );

  testWidgets(
    'Tema: Creme → Noite em 220 ms, grava na conta, texto na cor nova, mesma página; barra com ícones claros',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final t = await abrirLeitor(tester, livro);
      final mark = _doc(tester).mark;
      final numeros = _doc(tester).numbers;
      final creme = ReaderPalette.of(ReaderPaper.creme);
      final noite = ReaderPalette.of(ReaderPaper.noite);
      expect(_papel(tester), creme.paper);
      expect(_barra(tester), MainShell.overlayStyle);
      expect(_pintor(tester).foundLightText, isNull, reason: 'letras escuras');
      await _abrirControles(tester);
      await tester.tap(_key('r20.bottomIsland.tools.theme'));
      for (
        var i = 0;
        i < 60 && _barra(tester) != readerNightOverlayStyle;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(_barra(tester), readerNightOverlayStyle);
      // ícones claros em cima e, no Android, na barra de navegação (transparente, sem véu)
      expect(_barra(tester).statusBarIconBrightness, Brightness.light);
      expect(
        _barra(tester).systemNavigationBarIconBrightness,
        Brightness.light,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 110));
      final meio = _papel(tester);
      final f = (meio.r - creme.paper.r) / (noite.paper.r - creme.paper.r);
      expect(
        f,
        allOf(greaterThan(0.3), lessThan(0.7)),
        reason: 'metade de 220 ms',
      );
      await tester.pump(const Duration(milliseconds: 150));
      await _quadros(tester, 20);
      expect(_papel(tester), noite.paper);
      expect(_doc(tester).mark, mark);
      expect(_doc(tester).numbers, numeros);
      expect((_doc(tester).current as PageSnapshot).typography.ink, noite.text);
      expect(
        tester.widget<AppSvg>(_key('r20.bottomIsland.tools.theme.icon')).asset,
        AppIconsLeitor.moon,
      );
      final ajuste = await tester.runAsync(
        () => ReaderSettingsDao(livro.db).forUser(usuarioTeste),
      );
      expect(ajuste!.paper, ReaderPaper.noite);
      // de volta ao Creme
      await tester.tap(_key('r20.bottomIsland.tools.theme'));
      await _quadros(tester, 30);
      expect(_papel(tester), creme.paper);
      expect(_barra(tester), MainShell.overlayStyle);
      expect((_doc(tester).current as PageSnapshot).typography.ink, creme.text);
      expect(t.erros, isEmpty);
    },
  );

  testWidgets(
    'Grifos e Anotar: "Chega numa próxima fase" por 2 s, 12 acima da ilha; anunciado (a Fonte abre a folha — G14; o Sumário, a do sumário — G15)',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(accessibleNavigation: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _abrirControles(tester);
      tester.takeAnnouncements();
      for (final t in const ['notes', 'annotate']) {
        await tester.tap(_key('r20.bottomIsland.tools.$t'));
        await tester.pump();
        expect(findAppText(readerSoonText), findsOneWidget, reason: t);
        expect(tester.takeAnnouncements().map((a) => a.message), [
          readerSoonText,
        ], reason: t);
        final aviso = tester.getRect(_key('leitor.aviso'));
        final ilha = tester.getRect(_key('r20.bottomIsland'));
        expect(aviso.bottom, closeTo(ilha.top - 12, 0.01));
        expect(aviso.center.dx, closeTo(195, 0.01));
        await tester.pump(const Duration(milliseconds: 1900));
        expect(findAppText(readerSoonText), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 100));
        expect(findAppText(readerSoonText), findsNothing, reason: '2 s');
        expect(
          _key('r20.topIsland'),
          findsOneWidget,
          reason: 'os controles ficam',
        );
      }
    },
  );

  testWidgets(
    'fita: tocar marca a página e tocar de novo tira (banco e estado)',
    (tester) async {
      final h = tester.ensureSemantics();
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _abrirControles(tester);
      SemanticsNode fita() =>
          tester.getSemantics(_key('r20.topIsland.bookmark'));
      expect(fita(), isSemantics(hasToggledState: true, isToggled: false));
      await tester.tap(_key('r20.topIsland.bookmark'));
      await _quadros(tester, 10);
      expect(fita(), isSemantics(hasToggledState: true, isToggled: true));
      final marcas = await tester.runAsync(
        () => BookmarksDao(livro.db).forBook(livro.userBookId),
      );
      expect(marcas!.single.refPage, _doc(tester).numbers.refPage);
      expect(
        tester.widget<AppSvg>(_key('r20.topIsland.bookmark.icon')).asset,
        AppIconsLeitor.ribbonMarked,
      );
      await tester.tap(_key('r20.topIsland.bookmark'));
      await _quadros(tester, 10);
      expect(fita(), isSemantics(hasToggledState: true, isToggled: false));
      expect(
        await tester.runAsync(
          () => BookmarksDao(livro.db).forBook(livro.userBookId),
        ),
        isEmpty,
      );
      h.dispose();
    },
  );

  testWidgets(
    'barra: tocar no trilho salta (os controles ficam); a pílula de voltar aparece ao fechar e volta',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final origem = _doc(tester).mark;
      final pag = _doc(tester).numbers.refPage;
      final total = _doc(tester).numbers.refTotal;
      await _abrirControles(tester);
      final trilho = tester.getRect(_key('r20.bottomIsland.scrubber.track'));
      await tester.tapAt(
        Offset(trilho.left + trilho.width * 0.25, trilho.center.dy),
      );
      await _quadros(tester, 20);
      final n = 1 + (0.25 * (total - 1)).round();
      expect(_doc(tester).numbers.refPage, n);
      expect(_key('r20.topIsland'), findsOneWidget);
      expect(
        findAppText('Voltar à pág. $pag'),
        findsOneWidget,
        reason: 'sob a ilha',
      );
      await _fecharControles(tester);
      await tester.tap(findAppText('Voltar à pág. $pag'));
      await _quadros(tester, 20);
      expect(_doc(tester).mark, origem);
    },
  );

  testWidgets(
    'barra com os controles abertos (D-125): a pílula espera escondida; os 6 s só contam depois de fechar',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final pag = _doc(tester).numbers.refPage;
      await _abrirControles(tester);
      final trilho = tester.getRect(_key('r20.bottomIsland.scrubber.track'));
      await tester.tapAt(
        Offset(trilho.left + trilho.width * 0.25, trilho.center.dy),
      );
      await _quadros(tester, 20);
      await tester.pump(const Duration(seconds: 20));
      expect(_key('r20.topIsland'), findsOneWidget);
      expect(findAppText('Voltar à pág. $pag'), findsOneWidget);
      await _fecharControles(tester);
      await tester.pump(const Duration(milliseconds: 5700));
      expect(
        findAppText('Voltar à pág. $pag'),
        findsOneWidget,
        reason: 'o prazo começou ao fechar',
      );
      await tester.pump(const Duration(milliseconds: 300));
      await _quadros(tester, 20);
      expect(findAppText('Voltar à pág. $pag'), findsNothing, reason: '6 s');
    },
  );

  testWidgets(
    'abrir já no Noite: o papel não passa pelo Creme (o Tema só anima depois da 1ª página)',
    (tester) async {
      await tester.runAsync(
        () => ReaderSettingsDao(livro.db).upsert(
          ReaderSettings(
            id: usuarioTeste,
            meta: metaTeste(),
            paper: ReaderPaper.noite,
          ),
        ),
      );
      setCanvasView(tester, logical: const Size(390, 844));
      final creme = ReaderPalette.of(ReaderPaper.creme).paper;
      final noite = ReaderPalette.of(ReaderPaper.noite).paper;
      // o papel de cada quadro desde o 1º (a abertura assenta as animações antes de devolver)
      final vistos = <Color>{};
      var olhando = true;
      addTearDown(() => olhando = false);
      tester.binding.addPersistentFrameCallback((_) {
        if (!olhando) return;
        final papel = find.descendant(
          of: find.byType(ReaderScreen),
          matching: find.byType(ColoredBox),
        );
        if (papel.evaluate().isNotEmpty) {
          vistos.add(tester.widget<ColoredBox>(papel.first).color);
        }
      });
      await abrirLeitor(tester, livro, esperar: false);
      for (var i = 0; i < 400 && _key('r19.footer').evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
      olhando = false;
      expect(_papel(tester), noite);
      expect(vistos, contains(noite));
      // a palavra achada pela busca fica escura na marca (D-127): o pintor recebe a cor clara das letras
      expect(
        _pintor(tester).foundLightText,
        ReaderPalette.of(ReaderPaper.noite).text,
      );
      expect(
        vistos.where((c) => c != creme && c != noite),
        isEmpty,
        reason: 'nenhuma cor do meio do caminho (sem a animação de 220 ms)',
      );
    },
  );

  testWidgets(
    'leitor de tela com os controles abertos: "Esconder os controles"; a pílula coberta sai da árvore',
    (tester) async {
      final h = tester.ensureSemantics();
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final pag = _doc(tester).numbers.refPage;
      await _abrirControles(tester);
      final trilho = tester.getRect(_key('r20.bottomIsland.scrubber.track'));
      await tester.tapAt(
        Offset(trilho.left + trilho.width * 0.25, trilho.center.dy),
      );
      await _quadros(tester, 20);
      expect(findAppText('Voltar à pág. $pag'), findsOneWidget);
      expect(find.bySemanticsLabel('Voltar à pág. $pag'), findsNothing);
      tester.semantics.customAction(
        find.semantics.byLabel(RegExp(r'^Dom Casmurro, página')),
        const CustomSemanticsAction(label: 'Esconder os controles'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(_key('r20.topIsland'), findsNothing);
      expect(find.bySemanticsLabel('Voltar à pág. $pag'), findsOneWidget);
      h.dispose();
    },
  );

  testWidgets('leitor de tela: "Mostrar os controles" abre os controles', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    tester.semantics.customAction(
      find.semantics.byLabel(RegExp(r'^Dom Casmurro, página')),
      const CustomSemanticsAction(label: 'Mostrar os controles'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(_key('r20.topIsland'), findsOneWidget);
    h.dispose();
  });

  testWidgets(
    'PDF (D-122): Fonte cinza e sem ação; Tema escurece o papel e as ilhas, a página é a mesma',
    (tester) async {
      final h = tester.ensureSemantics();
      final tmp = Directory.systemTemp.createTempSync('booknest_g12_pdf_');
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
      Future<void> esperar(bool Function() pronto) async {
        for (var i = 0; i < 200 && !pronto(); i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 20)),
          );
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(pronto(), isTrue);
      }

      await esperar(() => _key('r19.footer').evaluate().isNotEmpty);
      await tester.pumpAndSettle();
      expect(_doc(tester), isA<PdfReaderDocument>());
      final imagem = (_doc(tester).current as PdfDisplayPage).image;
      await _abrirControles(tester);
      expect(
        tester.getSemantics(_key('r20.bottomIsland.tools.font')),
        isSemantics(
          label: 'Fonte',
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      await tester.tap(_key('r20.bottomIsland.tools.font'));
      await tester.pump();
      expect(findAppText(readerSoonText), findsNothing);
      expect(
        _key('rs.sheet'),
        findsNothing,
        reason: 'a folha não abre no PDF (D-122)',
      );
      await tester.tap(_key('r20.bottomIsland.tools.theme'));
      await esperar(
        () => _papel(tester) == ReaderPalette.of(ReaderPaper.noite).paper,
      );
      expect((_doc(tester).current as PdfDisplayPage).image, same(imagem));
      expect(
        tester.widget<AppSvg>(_key('r20.topIsland.search.icon')).asset,
        AppIconsLeitor.searchNight,
      );
      h.dispose();
    },
  );
}

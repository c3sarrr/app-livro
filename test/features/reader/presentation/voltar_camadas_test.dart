// G20.3 (R3) — o Voltar do sistema por camadas: cada Voltar fecha só a camada de cima. Uma linha da matriz por
// teste, cada camada aberta pelo auxiliar da fase dela (o mundo de referência no banco do leitor):
// - Rótulos (23b) → o painel do marca-texto; painel da caneta ou do marca-texto (23/23b) → o modo anotação;
// - modo anotação (22), também com a nota à mão aberta (24b) → Concluir (grava — D-42) e a leitura limpa;
// - folha da nota → a barra do grifo; Outra cor → a barra do grifo;
// - busca → os controles; ajustes (26) → os controles (D-142); sumário (27) → os controles;
// - controles (20) → a leitura limpa (D-117); seleção (21) → a leitura limpa;
// - leitura limpa → sai do leitor e grava (D-113);
// - 25: Mais opções, Exportar e a folha da nota → a lista; aberta pelo leitor → o leitor na mesma página (D-195);
//   aberta pela Início → a Início.
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/features/highlights/presentation/highlights_screen.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/app_com_livro.dart' show textosEm;
import '../../../support/canvas.dart';
import '../../../support/dados_t20.dart';
import '../../../support/dados_t21.dart';
import '../../../support/dados_t22.dart';
import '../../../support/dados_t23.dart';
import '../../../support/dados_t24.dart' show abrirTela24b, livroDaTela24b;
import '../../../support/dados_t25.dart';
import '../../../support/fase_l20.dart';
import '../../../support/fase_l25.dart';
import '../../../support/fase_l26.dart';
import '../../../support/fase_l27.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _k(String k) => find.byKey(ValueKey<String>(k));

Future<void> _quadros(WidgetTester tester, [int n = 20]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// O banco em memória (futuros de verdade) e a tela.
Future<void> _banco(WidgetTester tester, [int voltas = 6]) async {
  for (var i = 0; i < voltas; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Aperta o Voltar do sistema e anda os quadros da animação (a saída de uma rota leva até 800 ms).
Future<void> _voltar(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await _quadros(tester, 60);
}

String _rodape(WidgetTester tester) => textosEm(tester, 'r19.footer.pageLabel');

void main() {
  setUpAll(loadAppFonts);

  group('o modo anotação', () {
    testWidgets('Rótulos (23b) → o painel do marca-texto', (tester) async {
      final livro = await livroDaTela23();
      addTearDown(livro.close);
      await abrirTela23b(tester, livro);
      await tester.tap(_k('ann.markerPanel.colorsHeader.editLabels'));
      await _quadros(tester, 12);
      expect(_k('ann.labels'), findsOneWidget);
      await _voltar(tester);
      expect(_k('ann.labels'), findsNothing);
      expect(_k('ann.markerPanel'), findsOneWidget);
      expect(_k('ann.mode'), findsOneWidget);
    });

    testWidgets('o painel da caneta (23) → o modo anotação', (tester) async {
      final livro = await livroDaTela23();
      addTearDown(livro.close);
      await abrirTela23(tester, livro);
      await _voltar(tester);
      expect(_k('ann.penPanel'), findsNothing);
      expect(_k('ann.mode'), findsOneWidget);
    });

    testWidgets('o painel do marca-texto (23b) → o modo anotação', (
      tester,
    ) async {
      final livro = await livroDaTela23();
      addTearDown(livro.close);
      await abrirTela23b(tester, livro);
      await _voltar(tester);
      expect(_k('ann.markerPanel'), findsNothing);
      expect(_k('ann.mode'), findsOneWidget);
    });

    testWidgets('a nota à mão aberta (24b) → Concluir: a leitura limpa', (
      tester,
    ) async {
      final livro = await livroDaTela24b();
      addTearDown(livro.close);
      await abrirTela24b(tester, livro);
      expect(_k('ann.mode'), findsOneWidget);
      await _voltar(tester);
      await _banco(tester);
      expect(_k('ann.mode'), findsNothing);
      expect(find.byType(ReaderScreen), findsOneWidget);
    });

    testWidgets(
      'o modo (22) → Concluir: a tinta gravada e a leitura limpa (D-42)',
      (tester) async {
        final livro = await livroDaTela22();
        addTearDown(livro.close);
        await abrirTela22(tester, livro);
        await dedoDaTela22!.up();
        dedoDaTela22 = null;
        await _quadros(tester, 6);
        final antes = (await tester.runAsync(
          () => InkLayersDao(livro.db).forBook(livro.userBookId),
        ))!;
        await _voltar(tester);
        await _banco(tester);
        expect(_k('ann.mode'), findsNothing);
        expect(_k('r20.topIsland'), findsNothing, reason: 'a leitura limpa');
        expect(
          find.byType(ReaderScreen),
          findsOneWidget,
          reason: 'um Voltar só sai do modo',
        );
        final depois = (await tester.runAsync(
          () => InkLayersDao(livro.db).forBook(livro.userBookId),
        ))!;
        expect(
          {for (final l in depois) (l.id, l.strokesB64)},
          isNot({for (final l in antes) (l.id, l.strokesB64)}),
          reason: 'os traços desta vez foram gravados',
        );
      },
    );
  });

  group('a seleção', () {
    testWidgets('a seleção (21) → a leitura limpa', (tester) async {
      final livro = await livroDaTela21();
      addTearDown(livro.close);
      await abrirTela21(tester, livro);
      expect(_k('r21.toolbar'), findsOneWidget);
      await _voltar(tester);
      expect(_k('r21.toolbar'), findsNothing);
      expect(_k('r20.topIsland'), findsNothing);
      expect(find.byType(ReaderScreen), findsOneWidget);
    });

    testWidgets('a folha da nota → a barra do grifo', (tester) async {
      final livro = await livroDaTela21();
      addTearDown(livro.close);
      await abrirTela21(tester, livro);
      await tester.tap(_k('r21.toolbar.actions.note'));
      await _quadros(tester, 20);
      await _banco(tester, 3);
      expect(_k('leitor.nota'), findsOneWidget);
      await _voltar(tester);
      expect(_k('leitor.nota'), findsNothing);
      expect(find.byType(ReaderScreen), findsOneWidget);
    });

    testWidgets('Outra cor → a barra do grifo', (tester) async {
      final livro = await livroDaTela21();
      addTearDown(livro.close);
      await abrirTela21(tester, livro);
      await tester.tap(_k('r21.toolbar.colors.other'));
      await _quadros(tester, 20);
      expect(_k('leitor.outraCor'), findsOneWidget);
      await _voltar(tester);
      expect(_k('leitor.outraCor'), findsNothing);
      expect(_k('r21.toolbar'), findsOneWidget);
    });
  });

  group('os controles e as folhas', () {
    testWidgets('a busca → os controles', (tester) async {
      final livro = await livroDaTela20();
      addTearDown(livro.close);
      await abrirTela20(tester, livro);
      await tester.tap(_k('r20.topIsland.search'));
      await _quadros(tester, 20);
      expect(_k('leitor.busca'), findsOneWidget);
      await _voltar(tester);
      expect(_k('leitor.busca'), findsNothing);
      expect(_k('r20.topIsland'), findsOneWidget);
    });

    testWidgets('os ajustes (26) → os controles (D-142)', (tester) async {
      final livro = await livroDaTela26();
      addTearDown(livro.close);
      await abrirTela26(tester, livro);
      expect(_k('rs.sheet'), findsOneWidget);
      await _voltar(tester);
      expect(_k('rs.sheet'), findsNothing);
      expect(_k('r20.topIsland'), findsOneWidget);
    });

    testWidgets('o sumário (27) → os controles', (tester) async {
      final livro = await livroDaTela27();
      addTearDown(livro.close);
      await abrirTela27(tester, livro);
      expect(_k('toc.sheet'), findsOneWidget);
      await _voltar(tester);
      expect(_k('toc.sheet'), findsNothing);
      expect(_k('r20.topIsland'), findsOneWidget);
    });

    testWidgets('os controles (20) → a leitura limpa (D-117)', (tester) async {
      final livro = await livroDaTela20();
      addTearDown(livro.close);
      await abrirTela20(tester, livro);
      expect(_k('r20.topIsland'), findsOneWidget);
      await _voltar(tester);
      expect(_k('r20.topIsland'), findsNothing);
      expect(_k('r19.footer'), findsOneWidget);
    });
  });

  group('sair', () {
    testWidgets('a leitura limpa → sai do leitor e grava a página (D-113)', (
      tester,
    ) async {
      final livro = await LivroNaEstante.domCasmurro();
      addTearDown(livro.close);
      await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await tester.tapAt(const Offset(360, 420));
      await _quadros(tester, 30);
      final pagina = _rodape(tester);
      await _voltar(tester);
      await _banco(tester);
      expect(find.byType(ReaderScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
      final pos = (await tester.runAsync(
        () => ReadingPositionsDao(livro.db).forBook(livro.userBookId),
      ))!;
      expect('pág. ${pos.refPage} de ${livro.index.refPagesTotal}', pagina);
      expect((pos.locator as EpubLocator).spine, 2);
    });

    testWidgets(
      'a 25 pelo leitor: Mais opções → a lista; a lista → o leitor na mesma página (D-195)',
      (tester) async {
        final livro = await livroDaTela25();
        addTearDown(livro.close);
        setCanvasView(tester, logical: const Size(390, 844));
        await abrirLeitor(tester, livro, destaques: depsDaTela25(livro));
        final pagina = _rodape(tester);
        await tester.tapAt(const Offset(195, 420));
        await _quadros(tester, 12);
        await tester.tap(_k('r20.bottomIsland.tools.notes'));
        await esperarTela25(tester, assentar: false);
        await tester.tap(_k('hl.list.card1.head.more'));
        await _quadros(tester, 20);
        expect(_k('hl.more'), findsOneWidget);
        await _voltar(tester);
        expect(_k('hl.more'), findsNothing);
        expect(
          find.byType(HighlightsScreen),
          findsOneWidget,
          reason: 'um Voltar só fecha a folha',
        );
        await _voltar(tester);
        await _banco(tester, 3);
        expect(find.byType(HighlightsScreen), findsNothing);
        expect(find.byType(ReaderScreen), findsOneWidget);
        expect(_rodape(tester), pagina);
      },
    );

    testWidgets('a 25: Exportar → a lista; a folha da nota → a lista', (
      tester,
    ) async {
      final livro = await livroDaTela25();
      addTearDown(livro.close);
      await abrirTela25(tester, livro, tela: const Size(390, 844));
      await tester.tap(_k('hl.topBar.export'));
      await tester.pumpAndSettle();
      expect(_k('hl.export.title'), findsOneWidget);
      await _voltar(tester);
      expect(_k('hl.export.title'), findsNothing);
      expect(find.byType(HighlightsScreen), findsOneWidget);
      await tester.ensureVisible(_k('hl.list.card2.head.more'));
      await tester.pumpAndSettle();
      await tester.tap(_k('hl.list.card2.head.more'));
      await tester.pump();
      await tester.tap(_k('hl.more.note'));
      await tester.pump();
      expect(_k('leitor.nota.campo'), findsOneWidget);
      await _voltar(tester);
      expect(_k('leitor.nota.campo'), findsNothing);
      expect(
        find.byType(HighlightsScreen),
        findsOneWidget,
        reason: 'um Voltar só fecha a folha',
      );
    });

    testWidgets('a 25 pela Início → a Início', (tester) async {
      final livro = await livroDaTela25();
      addTearDown(livro.close);
      await abrirTela25(tester, livro, tela: const Size(390, 844));
      await _voltar(tester);
      await _quadros(tester, 20);
      expect(find.byType(HighlightsScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}

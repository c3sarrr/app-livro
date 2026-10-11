// G20.4 (D-207, R4, R5, D-166) — a restauração de estado: o sistema fecha o app em segundo plano e o reabre com o
// que guardou (`restartAndRestore`):
// - a Início na mesma aba e na mesma rolagem;
// - o leitor do mesmo livro na mesma página, com a leitura limpa (a posição grava ao ir para o segundo plano);
// - o `?ir=` salta uma vez: restaurado, o leitor abre na posição, não de novo no trecho (R4);
// - a 25 restaurada sobre o leitor: tocar num cartão ainda leva ao trecho (R5);
// - restaurado no meio do modo anotação: a leitura limpa e a tinta gravada (D-166).
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/features/highlights/application/highlights_exit.dart';
import 'package:app_leitura/features/highlights/application/highlights_providers.dart';
import 'package:app_leitura/features/highlights/presentation/highlights_screen.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../support/app_com_livro.dart' show textosEm;
import '../support/canvas.dart';
import '../support/dados_t22.dart';
import '../support/dados_t25.dart';
import '../support/fase_l25.dart';
import '../support/load_fonts.dart';
import '../support/pump_app.dart';
import '../support/pump_reader.dart';
import '../support/reader_harness.dart';

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

String _rodape(WidgetTester tester) => textosEm(tester, 'r19.footer.pageLabel');

String _rota(WidgetTester tester) => routerOf(tester).state.uri.toString();

/// O app vai para o segundo plano (a posição e a tinta gravam) e o sistema o fecha; volta restaurado.
Future<void> _fecharEReabrir(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  await _banco(tester);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.restartAndRestore();
  await _banco(tester);
}

void main() {
  setUpAll(loadAppFonts);

  group('a Início (D-207)', () {
    testWidgets('volta na mesma rolagem', (tester) async {
      await pumpApp(tester);
      await tester.drag(homeScrollView(), const Offset(0, -600));
      await tester.pumpAndSettle();
      double rolagem() => tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: homeScrollView(),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position
          .pixels;
      final antes = rolagem();
      expect(antes, greaterThan(0));
      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      expect(rolagem(), antes);
    });

    testWidgets('volta na mesma aba (Perfil)', (tester) async {
      await pumpApp(tester);
      await tester.tap(_k('nav.profile'));
      await tester.pumpAndSettle();
      expect(_rota(tester), '/perfil');
      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      expect(_rota(tester), '/perfil');
    });
  });

  group('o leitor', () {
    late LivroNaEstante livro;
    setUp(() async {
      livro = await LivroNaEstante.domCasmurro();
      await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
    });
    tearDown(() async => livro.close());

    testWidgets('volta na mesma página, com a leitura limpa (D-207)', (
      tester,
    ) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      for (var i = 0; i < 2; i++) {
        await tester.tapAt(const Offset(360, 420));
        await _quadros(tester, 30);
      }
      final pagina = _rodape(tester);
      await tester.tapAt(const Offset(195, 420));
      await _quadros(tester, 12);
      expect(_k('r20.topIsland'), findsOneWidget);
      await _fecharEReabrir(tester);
      await esperarLeitor(tester);
      expect(_rota(tester), '/leitor/${livro.userBookId}');
      expect(_rodape(tester), pagina);
      expect(
        _k('r20.topIsland'),
        findsNothing,
        reason: 'os controles não voltam',
      );
    });
  });

  group('o leitor com as anotações do mundo', () {
    late LivroNaEstante livro;
    setUp(() async => livro = await livroDaTela25());
    tearDown(() async => livro.close());

    testWidgets(
      'R4: o ?ir= salta uma vez — restaurado, abre na posição e não de novo no trecho',
      (tester) async {
        final p41 = mundoReferencia.anotacoes.firstWhere(
          (a) => a.refPage == 41,
        );
        setCanvasView(tester, logical: const Size(390, 844));
        await abrirLeitor(tester, livro, ir: p41.id);
        await _quadros(tester, 60);
        final noTrecho = _rodape(tester);
        for (var i = 0; i < 3; i++) {
          await tester.tapAt(const Offset(360, 420));
          await _quadros(tester, 30);
        }
        final depois = _rodape(tester);
        expect(depois, isNot(noTrecho));
        expect(
          _k('leitor.voltarDoLink'),
          findsNothing,
          reason: 'a volta some em 2 viradas (D-108)',
        );
        await _fecharEReabrir(tester);
        await esperarLeitor(tester);
        await _quadros(tester, 60);
        expect(
          _rodape(tester),
          depois,
          reason: 'abre na posição gravada, sem saltar de novo',
        );
      },
    );

    testWidgets(
      'R5: a saída da 25 que chega antes de o livro abrir espera por ele',
      (tester) async {
        final p41 = mundoReferencia.anotacoes.firstWhere(
          (a) => a.refPage == 41,
        );
        setCanvasView(tester, logical: const Size(390, 844));
        await abrirLeitor(tester, livro, esperar: false);
        await tester.pump();
        await tester.pump();
        expect(find.byType(ReaderScreen), findsOneWidget);
        expect(_k('r19.footer'), findsNothing, reason: 'o livro ainda abre');
        ProviderScope.containerOf(tester.element(find.byType(ReaderScreen)))
            .read(highlightsExitBusProvider)
            .post(livro.userBookId, HighlightsOpenAt(p41.id, page: 41));
        await esperarLeitor(tester);
        await _quadros(tester, 60);
        await _banco(tester);
        await _quadros(tester, 30);
        expect(
          _k('leitor.voltarDoLink'),
          findsOneWidget,
          reason: 'saltou para o trecho quando o livro abriu',
        );
      },
    );

    testWidgets(
      'R5: a 25 restaurada sobre o leitor — o cartão ainda leva ao trecho',
      (tester) async {
        setCanvasView(tester, logical: const Size(390, 844));
        final t = await abrirLeitor(
          tester,
          livro,
          destaques: depsDaTela25(livro),
        );
        await tester.tapAt(const Offset(195, 420));
        await _quadros(tester, 12);
        await tester.tap(_k('r20.bottomIsland.tools.notes'));
        await esperarTela25(tester, assentar: false);
        await _fecharEReabrir(tester);
        await esperarTela25(tester, assentar: false);
        expect(find.byType(HighlightsScreen), findsOneWidget);
        // o leitor restaurado embaixo da 25 não está na tela: não acende a tela (nem conta o tempo)
        await _banco(tester);
        expect(t.awake.log.last, 'off');
        await tester.dragUntilVisible(
          hl('hl.list.card3.body.quote'),
          hl('hl.scroll'),
          const Offset(0, -200),
        );
        await _quadros(tester, 20);
        await tester.tap(hl('hl.list.card3.body.quote'));
        await _quadros(tester, 60);
        await _banco(tester);
        await _quadros(tester, 30);
        expect(find.byType(HighlightsScreen), findsNothing);
        expect(find.byType(ReaderScreen), findsOneWidget);
        expect(
          _k('leitor.voltarDoLink'),
          findsOneWidget,
          reason: 'saltou para o trecho, com a volta',
        );
      },
    );
  });

  testWidgets(
    'D-166: restaurado no meio do modo anotação — a leitura limpa e a tinta gravada',
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
      await _fecharEReabrir(tester);
      await esperarLeitor(tester);
      await _banco(tester);
      expect(
        _k('ann.mode'),
        findsNothing,
        reason: 'restaurado, o leitor abre limpo',
      );
      final depois = (await tester.runAsync(
        () => InkLayersDao(livro.db).forBook(livro.userBookId),
      ))!;
      expect(
        {for (final l in depois) (l.id, l.strokesB64)},
        isNot({for (final l in antes) (l.id, l.strokesB64)}),
        reason: 'os traços desta vez foram gravados ao ir para o segundo plano (D-166)',
      );
    },
  );
}

// G14.4 — a folha de ajustes pela rota real, com o Dom Casmurro num banco em memória: "Aa Fonte" abre a folha (os
// controles somem e a barra de status fica — D-105); ×, Voltar, toque na página de cima e puxar pela alça fecham e
// devolvem os controles (D-141, D-142); a página de cima não vira com a folha aberta; o prazo da pílula de voltar
// fica parado (D-125); mudar o tamanho repagina na tela mantendo o caractere e fica gravado (reabrir mantém); o papel
// anima em 220 ms (D-121) e o Noite pela folha usa as ilhas do Noite (D-143), com o Tema voltando ao último claro.
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_overlays.dart'
    show readerSoonText;
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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

/// Abre os controles e toca em "Aa Fonte"; espera os 150 ms.
Future<void> _abrirFolha(WidgetTester tester) async {
  await _abrirControles(tester);
  await tester.tap(_key('r20.bottomIsland.tools.font'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  expect(_key('rs.sheet'), findsOneWidget);
}

/// Espera a sessão gravar e a página nova chegar.
Future<void> _aplicar(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Fecha a folha pelo × e espera os 150 ms.
Future<void> _fecharFolha(WidgetTester tester) async {
  await tester.tap(_key('rs.sheet.close'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
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
    '"Aa Fonte" abre a folha: os controles somem e a barra de status fica; × fecha e os controles voltam',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      final t = await abrirLeitor(tester, livro);
      await _abrirFolha(tester);
      expect(_key('r20.topIsland'), findsNothing, reason: 'os controles somem');
      expect(
        findAppText(readerSoonText),
        findsNothing,
        reason: 'não é mais "Chega numa próxima fase"',
      );
      expect(t.ui.log.last, 'padrão', reason: 'a barra de status fica (D-105)');
      await _fecharFolha(tester);
      expect(_key('rs.sheet'), findsNothing);
      expect(
        _key('r20.topIsland'),
        findsOneWidget,
        reason: 'volta aos controles (D-142)',
      );
      expect(t.ui.log.last, 'padrão');
      await _fecharControles(tester);
      expect(t.ui.log.last, 'imersivo');
      expect(t.erros, isEmpty);
    },
  );

  testWidgets(
    'o Voltar fecha a folha, depois os controles, depois o livro (D-42)',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _abrirFolha(tester);
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(_key('rs.sheet'), findsNothing);
      expect(_key('r20.topIsland'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(_key('r20.topIsland'), findsNothing);
      expect(find.byType(ReaderScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ReaderScreen), findsNothing);
    },
  );

  testWidgets(
    'tocar na página de cima fecha; arrastar nela não vira a página',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final antes = _doc(tester).mark;
      await _abrirFolha(tester);
      await tester.dragFrom(const Offset(300, 200), const Offset(-200, 0));
      await _quadros(tester, 20);
      expect(_doc(tester).mark, antes, reason: 'a página não virou');
      expect(_key('rs.sheet'), findsOneWidget, reason: 'o arrasto não fecha');
      await tester.tapAt(const Offset(195, 200));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await _quadros(tester, 6);
      expect(_key('rs.sheet'), findsNothing);
      expect(_key('r20.topIsland'), findsOneWidget);
    },
  );

  testWidgets('puxar a folha pela alça fecha e volta aos controles', (
    tester,
  ) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    await _abrirFolha(tester);
    await tester.dragFrom(
      tester.getCenter(_key('rs.sheet.grabber')),
      const Offset(0, 120),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    await _quadros(tester, 6);
    expect(_key('rs.sheet'), findsNothing);
    expect(_key('r20.topIsland'), findsOneWidget);
  });

  testWidgets(
    'A+ repagina na tela mantendo o caractere; fica gravado e reabrir mantém',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      final lendo = _doc(tester).mark;
      await _abrirFolha(tester);
      await tester.tap(_key('rs.sheet.size.larger'));
      await _aplicar(tester);
      final p = _doc(tester).current as PageSnapshot;
      expect(p.typography.fontSize, 22);
      expect(lendo.offset, inInclusiveRange(p.shown!.from, p.shown!.to - 1));
      expect(
        tester.getSize(_key('rs.sheet.size.step5')),
        const Size(14, 14),
        reason: 'o ativo agora é o 5º',
      );
      final linha = await tester.runAsync(
        () => ReaderSettingsDao(livro.db).forUser(usuarioTeste),
      );
      expect(linha!.fontStep, 5);
      // reabrir mantém
      await tester.binding.handlePopRoute(); // fecha a folha
      await tester.pump(const Duration(milliseconds: 150));
      await tester.binding.handlePopRoute(); // fecha os controles
      await tester.pump(const Duration(milliseconds: 150));
      await tester.binding.handlePopRoute(); // sai do livro
      await tester.pumpAndSettle();
      await abrirLeitor(tester, livro);
      expect((_doc(tester).current as PageSnapshot).typography.fontSize, 22);
    },
  );

  testWidgets(
    'papel na folha: o papel anima em 220 ms, a página na cor nova e a folha mostra o escolhido',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _abrirFolha(tester);
      await tester.tap(_key('rs.sheet.papers.sepia'));
      await _aplicar(tester);
      await tester.pump(const Duration(milliseconds: 220));
      expect(_papel(tester), ReaderPalette.of(ReaderPaper.sepia).paper);
      expect(
        (_doc(tester).current as PageSnapshot).typography.ink,
        ReaderPalette.of(ReaderPaper.sepia).text,
      );
      expect(_key('rs.sheet.papers.sepia.check'), findsOneWidget);
    },
  );

  testWidgets(
    'Noite pela folha: a folha e a pílula viram as ilhas do Noite; o Tema volta ao último claro',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _abrirFolha(tester);
      await tester.tap(_key('rs.sheet.papers.white'));
      await _aplicar(tester);
      await tester.tap(_key('rs.sheet.papers.night'));
      await _aplicar(tester);
      await tester.pump(const Duration(milliseconds: 220));
      final n = ReaderChromePalette.of(ReaderPaper.noite);
      expect(tester.widget<NeoBox>(_key('rs.sheet')).color, n.island);
      expect(tester.widget<NeoBox>(_key('rs.livePill')).color, n.island);
      await _fecharFolha(tester);
      await tester.tap(_key('r20.bottomIsland.tools.theme'));
      await _aplicar(tester);
      await tester.pump(const Duration(milliseconds: 220));
      expect(
        _papel(tester),
        ReaderPalette.of(ReaderPaper.branco).paper,
        reason: 'o último claro (D-121)',
      );
    },
  );

  testWidgets('a pílula de voltar fica parada com a folha aberta (D-125)', (
    tester,
  ) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
    final pag = _doc(tester).numbers.refPage;
    await _abrirControles(tester);
    final trilho = tester.getRect(_key('r20.bottomIsland.scrubber.track'));
    await tester.tapAt(
      Offset(trilho.left + trilho.width * 0.25, trilho.center.dy),
    );
    await _quadros(tester, 20);
    await tester.tap(_key('r20.bottomIsland.tools.font'));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(seconds: 20));
    await _fecharFolha(tester);
    await _fecharControles(tester);
    await tester.pump(const Duration(milliseconds: 5700));
    expect(
      findAppText('Voltar à pág. $pag'),
      findsOneWidget,
      reason: 'o prazo começou ao fechar os controles',
    );
  });

  testWidgets(
    'leitor de tela: com a folha aberta, a página e os controles saem da árvore',
    (tester) async {
      final h = tester.ensureSemantics();
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro);
      await _abrirFolha(tester);
      expect(
        tester.getSemantics(_key('rs.sheet')),
        isSemantics(label: 'Ajustes de leitura', scopesRoute: true),
      );
      expect(find.semantics.byLabel('Prévia da página'), findsOneWidget);
      expect(
        find.semantics.byLabel('Fechar o livro'),
        findsNothing,
        reason: 'a ilha de cima ficou embaixo',
      );
      expect(
        find.semantics.byLabel(RegExp(r'^Dom Casmurro, página')),
        findsNothing,
        reason: 'a página ficou atrás da folha',
      );
      h.dispose();
    },
  );
}

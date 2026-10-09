// G19.9 — capturas da tela 25 para conferência (mandadas na conversa), 390×844 @3x, pela rota real no mundo de
// referência (D-34):
// - o topo da tela e a lista rolada até os desenhos;
// - um filtro (Rosa) e a busca ("ressaca");
// - a folha "Mais opções" (D-192), a folha Exportar (D-194) e o Desfazer (D-193);
// - os vazios (D-198): o livro sem anotações e os filtros sem resultado;
// - os grifos sem lugar no fim (D-199).
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela chegou ao estado pedido.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fixtures/mundo_2026_09_20.dart';
import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t25.dart';
import '../support/fase_l25.dart';
import '../support/load_fonts.dart';
import '../support/reader_harness.dart';

const Size _tela = Size(390, 844);

Future<void> _gravar(WidgetTester tester, String nome) async {
  final image = await captureAt(tester, find.byKey(goldenRootKey));
  expect((image.width, image.height), (1170, 2532));
  final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
  if (pasta == null) return;
  final png = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.png),
  );
  Directory(pasta).createSync(recursive: true);
  File('$pasta${Platform.pathSeparator}$nome')
      .writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela25());
  tearDown(() async => livro.close());

  testWidgets('o topo e os desenhos', (tester) async {
    await abrirTela25(tester, livro, golden: true, tela: _tela);
    await _gravar(tester, 'g19_01_topo.png');
    await tester.dragUntilVisible(
      hl('hl.list.card8'),
      hl('hl.scroll'),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await _gravar(tester, 'g19_02_desenhos.png');
  });

  testWidgets('filtro Rosa e a busca "ressaca"', (tester) async {
    await abrirTela25(tester, livro, golden: true, tela: _tela);
    await tester.tap(hl('hl.filters.colors.pink'));
    await tester.pump();
    expect(cartoes25(tester), hasLength(1));
    await _gravar(tester, 'g19_03_filtro_rosa.png');
    await tester.tap(hl('hl.filters.colors.pink'));
    await tester.pump();
    await tester.enterText(hl('hl.search.field'), 'ressaca');
    await tester.pump(const Duration(milliseconds: 250));
    await banco25(tester);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(cartoes25(tester), hasLength(1));
    await _gravar(tester, 'g19_04_busca.png');
  });

  testWidgets('Mais opções, Exportar e o Desfazer', (tester) async {
    await abrirTela25(tester, livro, golden: true, tela: _tela);
    await tester.tap(hl('hl.list.card2.head.more'));
    await tester.pump();
    expect(hl('hl.more'), findsOneWidget);
    await _gravar(tester, 'g19_05_mais_opcoes.png');
    await tester.tap(hl('hl.more.close'));
    await tester.pump();
    await tester.tap(hl('hl.topBar.export'));
    await tester.pump();
    expect(hl('hl.export'), findsOneWidget);
    await _gravar(tester, 'g19_06_exportar.png');
    await tester.tap(hl('hl.export.cancel'));
    await tester.pump();
    await tester.tap(hl('hl.list.card1.head.more'));
    await tester.pump();
    await tester.tap(hl('hl.more.delete'));
    await tester.pump();
    await banco25(tester);
    expect(hl('leitor.desfazer'), findsOneWidget);
    await _gravar(tester, 'g19_07_desfazer.png');
  });

  testWidgets('os vazios (D-198)', (tester) async {
    await abrirTela25(tester, livro, golden: true, tela: _tela);
    await tester.tap(hl('hl.types.notes'));
    await tester.pump();
    await tester.tap(hl('hl.filters.colors.green'));
    await tester.pump();
    expect(hl('hl.empty'), findsOneWidget);
    await _gravar(tester, 'g19_08_sem_resultado.png');
  });

  testWidgets('o livro sem anotações (D-198)', (tester) async {
    final vazio = await livroDaTela25(comAnotacoes: false);
    addTearDown(vazio.close);
    await abrirTela25(tester, vazio, golden: true, tela: _tela);
    expect(hl('hl.search'), findsNothing);
    await _gravar(tester, 'g19_09_livro_vazio.png');
  });

  testWidgets('os sem lugar no fim (D-199)', (tester) async {
    final p121 = mundoReferencia.anotacoes
        .firstWhere((a) => a.refPage == 121)
        .groupId;
    await abrirTela25(
      tester,
      livro,
      golden: true,
      tela: _tela,
      deps: depsDaTela25(livro, texto: TrechosDaTela25(semLugar: {p121})),
    );
    await tester.dragUntilVisible(
      hl('hl.list.sepOrphan'),
      hl('hl.scroll'),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await _gravar(tester, 'g19_10_sem_lugar.png');
  });
}

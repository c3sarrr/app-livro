// G16.7 — capturas do modo anotação, para conferência (mandadas na conversa), 390×844 @3x, pela rota real no mundo da
// tela 22 (D-34, D-160):
// - a tela 22 em Creme e no Noite (o fluxo da prancha: as 2 barras com a Reta, a onda até 66 % e o dedo parado);
// - a tinta no leitor limpo (o grifo à mão e a elipse com o risco) e depois de A+ e da Lora (a moldura da D-162);
// - o Laço com a seleção, parado e sendo arrastado (D-46);
// - a Borracha passando sobre o grifo à mão (D-168), com o anel sem o ponto.
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela chegou ao estado pedido.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t20.dart' show depsDaTela20;
import '../support/dados_t22.dart';
import '../support/load_fonts.dart';
import '../support/pump_reader.dart';
import '../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

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

Future<void> _quadros(WidgetTester tester, [int n = 20]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// O leitor limpo na pág. 159 do mundo da 22, na raiz da captura.
Future<void> _abrir(WidgetTester tester, LivroNaEstante livro) async {
  setCanvasView(tester, logical: const Size(390, 844));
  await precacheTela22(tester);
  await abrirLeitor(
    tester,
    livro,
    golden: true,
    deps: (t) => depsDaTela20(t, livro),
  );
  await esperarBancoL22(tester);
}

AnnotationSession _sessao(WidgetTester tester) =>
    tester.widget<AnnotationMode>(find.byType(AnnotationMode)).session;

/// Um traço da caneta da ferramenta ativa pelos [pontos], sem soltar no fim se [soltar] = `false`.
Future<TestGesture> _passar(
  WidgetTester tester,
  List<Offset> pontos, {
  bool soltar = true,
}) async {
  final g = await tester.startGesture(pontos.first);
  for (var i = 1; i < pontos.length; i++) {
    await g.moveTo(pontos[i], timeStamp: Duration(milliseconds: 16 * i));
    await tester.pump();
  }
  if (soltar) await g.up();
  await tester.pump();
  return g;
}

/// Abre a folha de ajustes pelos controles, toca em [chave] e fecha a folha e os controles.
Future<void> _ajustar(WidgetTester tester, String chave) async {
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  await tester.tap(_key('r20.bottomIsland.tools.font'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  await tester.tap(_key(chave));
  await esperarBancoL22(tester);
  await esperarBancoL22(tester);
  await tester.binding.handlePopRoute();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.binding.handlePopRoute();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester);
}

void main() {
  setUpAll(loadAppFonts);

  for (final papel in const [ReaderPaper.creme, ReaderPaper.noite]) {
    testWidgets('a tela 22 (${papel.name})', (tester) async {
      final livro = await livroDaTela22(papel: papel);
      addTearDown(livro.close);
      await abrirTela22(tester, livro, golden: true);
      expect(_key('ann.island'), findsOneWidget);
      await _gravar(tester, 'g16_tela22_${papel.name}_390x844@3x.png');
    });
  }

  testWidgets('a tinta no leitor limpo; depois de A+ e da Lora (D-162)', (
    tester,
  ) async {
    final livro = await livroDaTela22();
    addTearDown(livro.close);
    await _abrir(tester, livro);
    final pagina = tester.widget<ReaderPageView>(find.byType(ReaderPageView));
    expect(pagina.ink!.drawingsOn(pagina.document.current), hasLength(1));
    await _gravar(tester, 'g16_tinta_leitor_limpo_390x844@3x.png');
    await _ajustar(tester, 'rs.sheet.size.larger');
    await _gravar(tester, 'g16_tinta_a_mais_390x844@3x.png');
    await _ajustar(tester, 'rs.sheet.fonts.lora');
    final depois = tester.widget<ReaderPageView>(find.byType(ReaderPageView));
    expect(depois.ink!.drawingsOn(depois.document.current), hasLength(1));
    await _gravar(tester, 'g16_tinta_a_mais_lora_390x844@3x.png');
  });

  testWidgets('o Laço com a seleção, parado e sendo arrastado (D-46)', (
    tester,
  ) async {
    final livro = await livroDaTela22();
    addTearDown(livro.close);
    await _abrir(tester, livro);
    await entrarNoModoAnotacao(tester);
    await tester.tap(_key('ann.toolShelf.lasso'));
    await tester.pump();
    // em volta da elipse e do risco ("Olhos de ressaca?")
    await _passar(tester, const [
      Offset(12, 350),
      Offset(120, 346),
      Offset(214, 352),
      Offset(216, 420),
      Offset(110, 424),
      Offset(10, 418),
      Offset(12, 352),
    ]);
    expect(_sessao(tester).selection.value, isNotNull);
    await _quadros(tester, 4);
    await _gravar(tester, 'g16_laco_selecao_390x844@3x.png');
    final g = await _passar(tester, const [
      Offset(110, 386),
      Offset(110, 400),
      Offset(112, 420),
      Offset(114, 436),
    ], soltar: false);
    expect(_sessao(tester).selection.value!.dragging, isTrue);
    await _quadros(tester, 4);
    await _gravar(tester, 'g16_laco_arrastando_390x844@3x.png');
    await g.up();
    await tester.pump();
  });

  testWidgets(
    'a Borracha sobre o grifo à mão (D-168), com o anel sem o ponto',
    (tester) async {
      final livro = await livroDaTela22();
      addTearDown(livro.close);
      await _abrir(tester, livro);
      await entrarNoModoAnotacao(tester);
      await tester.tap(_key('ann.toolShelf.eraser'));
      await tester.pump();
      final g = await _passar(tester, const [
        Offset(60, 228),
        Offset(80, 238),
        Offset(100, 246),
        Offset(120, 252),
      ], soltar: false);
      expect(_sessao(tester).hiddenHighlights, hasLength(1));
      expect(_key('ann.page.text.wavy.touchDot'), findsNothing);
      await _quadros(tester, 4);
      await _gravar(tester, 'g16_borracha_390x844@3x.png');
      await g.up();
      await tester.pump();
    },
  );
}

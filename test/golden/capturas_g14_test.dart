// G14.5 — capturas da folha de ajustes e da página nos ajustes da tela 26, para conferência (mandadas na conversa),
// 390×844 @3x pela rota real no mundo de referência, com o ajuste da conta trocado antes de abrir:
// - a tela 26 em Creme e no Noite (a folha nas cores das ilhas do Noite — D-143);
// - a página nas fontes Lora, Figtree e Atkinson (D-18);
// - os tamanhos 1 e 7, a entrelinha Justa e a Solta, as margens Estreita e Larga (D-20).
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela chegou ao estado pedido.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t20.dart';
import '../support/fase_l26.dart';
import '../support/load_fonts.dart';
import '../support/pump_reader.dart';

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

PageSnapshot _pagina(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document.current
        as PageSnapshot;

void main() {
  setUpAll(loadAppFonts);

  for (final papel in const [ReaderPaper.creme, ReaderPaper.noite]) {
    testWidgets('tela 26 em ${papel.code}', (tester) async {
      final livro = (await tester.runAsync(
        () => livroDaTela26(look: ReaderLook(paper: papel)),
      ))!;
      addTearDown(() => tester.runAsync(livro.close));
      await abrirTela26(tester, livro, golden: true);
      expect(find.byKey(const ValueKey('rs.sheet')), findsOneWidget);
      await _gravar(tester, 'g14_tela26_${papel.code}_390x844@3x.png');
    });
  }

  for (final (nome, look) in const [
    ('fonte_lora', ReaderLook(fontFamily: ReaderFontFamily.lora)),
    ('fonte_figtree', ReaderLook(fontFamily: ReaderFontFamily.figtree)),
    ('fonte_atkinson', ReaderLook(fontFamily: ReaderFontFamily.atkinson)),
    ('tamanho_1', ReaderLook(fontStep: 1)),
    ('tamanho_7', ReaderLook(fontStep: 7)),
    ('entrelinha_justo', ReaderLook(lineSpacing: ReaderLineSpacing.justo)),
    ('entrelinha_solto', ReaderLook(lineSpacing: ReaderLineSpacing.solto)),
    ('margens_estreita', ReaderLook(margins: ReaderMargins.estreita)),
    ('margens_larga', ReaderLook(margins: ReaderMargins.larga)),
  ]) {
    testWidgets('página em $nome', (tester) async {
      final livro = (await tester.runAsync(() => livroDaTela26(look: look)))!;
      addTearDown(() => tester.runAsync(livro.close));
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(
        tester,
        livro,
        golden: true,
        deps: (t) => depsDaTela20(t, livro),
      );
      final t = _pagina(tester).typography;
      expect(
        (t.font, t.fontSize, t.lineSpacing, t.sideMargin),
        (
          look.fontFamily,
          readerFontSizes[look.fontStep - 1],
          lineSpacingOf(look.lineSpacing),
          sideMarginOf(look.margins),
        ),
      );
      await _gravar(tester, 'g14_${nome}_390x844@3x.png');
    });
  }
}

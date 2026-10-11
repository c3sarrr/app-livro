// G18.6 — capturas do Espaço e da nota à mão, para conferência (mandadas na conversa), 390×844 @3x, pela rota real no
// mundo das telas 24 e 24b (D-34, D-160, R15):
// - as telas 24 e 24b em Creme e no Noite (R14);
// - a faixa recolhida no modo e no leitor limpo (D-184);
// - a página do leitor limpo com a nota (R11, D-183);
// - a nota que não cabe no resto da página, inteira na seguinte (R12);
// - a pílula "Nota apagada · Desfazer" (D-185).
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela chegou ao estado pedido.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/space/space_metrics.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t20.dart' show depsDaTela20;
import '../support/dados_t22.dart';
import '../support/dados_t24.dart';
import '../support/load_fonts.dart';
import '../support/pump_reader.dart';

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

Future<void> _quadros(WidgetTester tester, [int n = 30]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// O Concluir e o leitor limpo de volta, repaginado.
Future<void> _concluir(WidgetTester tester) async {
  await tester.tap(_key('ann.done'));
  for (var i = 0; i < 2; i++) {
    await esperarBancoL22(tester);
    await _quadros(tester);
  }
  expect(find.byType(AnnotationMode), findsNothing);
}

DisplayPage _pagina(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document.current;

void main() {
  setUpAll(loadAppFonts);

  for (final papel in const [ReaderPaper.creme, ReaderPaper.noite]) {
    testWidgets('a tela 24 (${papel.name})', (tester) async {
      final livro = await livroDaTela24(papel: papel);
      addTearDown(livro.close);
      final (_, dedo) = await abrirTela24(tester, livro, golden: true);
      await _gravar(tester, 'g18_tela24_${papel.name}_390x844@3x.png');
      await dedo.up();
      await tester.pump();
    });

    testWidgets('a tela 24b (${papel.name})', (tester) async {
      final livro = await livroDaTela24b(papel: papel);
      addTearDown(livro.close);
      await abrirTela24b(tester, livro, golden: true);
      await _gravar(tester, 'g18_tela24b_${papel.name}_390x844@3x.png');
    });
  }

  testWidgets('a faixa recolhida no modo e no leitor limpo (D-184)', (
    tester,
  ) async {
    final livro = await livroDaTela24b();
    addTearDown(livro.close);
    await abrirTela24b(tester, livro, golden: true);
    await tester.tap(_key('ann.page.handNote.actions.collapse'));
    await tester.pump();
    await _quadros(tester, 12);
    final s = sessaoNaTela(tester);
    expect(s.notes.single.collapsed, isTrue);
    final linha = s.geometry.lineHeight;
    await _gravar(tester, 'g18_faixa_no_modo_390x844@3x.png');
    await _concluir(tester);
    final faixa = spacesOf(_pagina(tester)).single;
    expect(faixa.rect.height, closeTo(stripFlowHeight(linha), 0.01));
    await _gravar(tester, 'g18_faixa_no_leitor_390x844@3x.png');
  });

  testWidgets('a página do leitor limpo com a nota (R11, D-183)', (
    tester,
  ) async {
    final livro = await livroDaTela24b();
    addTearDown(livro.close);
    setCanvasView(tester, logical: const Size(390, 844));
    await precacheTela24(tester);
    await abrirLeitor(
      tester,
      livro,
      golden: true,
      deps: (t) => depsDaTela20(t, livro),
    );
    await esperarBancoL22(tester);
    await _quadros(tester);
    expect(spacesOf(_pagina(tester)), hasLength(1));
    await _gravar(tester, 'g18_leitor_com_a_nota_390x844@3x.png');
  });

  testWidgets('a pílula "Nota apagada · Desfazer" (D-185)', (tester) async {
    final livro = await livroDaTela24b();
    addTearDown(livro.close);
    await abrirTela24b(tester, livro, golden: true);
    await tester.tap(_key('ann.page.handNote.actions.delete'));
    await tester.pump();
    await _quadros(tester, 12);
    expect(_key('leitor.desfazer'), findsOneWidget);
    await _gravar(tester, 'g18_pilula_nota_apagada_390x844@3x.png');
  });

  testWidgets(
    'a nota que não cabe no resto da página vai inteira para a seguinte (R12)',
    (tester) async {
      final livro = await livroDaTela24();
      addTearDown(livro.close);
      final (_, dedo) = await abrirTela24(tester, livro, golden: true);
      await dedo.up();
      await tester.pump();
      final s = sessaoNaTela(tester);
      // a nota da 24 sai (a mesma fresta) e outra, perto do pé, com tinta
      s
        ..undo()
        ..setTool(AnnotationTool.space);
      final limpo = _pagina(tester) as PageSnapshot;
      final fundo = limpo.typography.topInset + limpo.typography.contentHeight;
      final l = s.geometry.lines.lastWhere(
        (x) =>
            x.bottom + s.textShift + 2 < 660 &&
            x.bottom + noteFlowHeight(3) > fundo,
      );
      final fresta = l.bottom + s.textShift;
      await tracarL22(tester, [
        Offset(dedoDaTela24, fresta + 2),
        Offset(dedoDaTela24, fresta + 20),
        Offset(dedoDaTela24, fresta + 14 + 3 * s.geometry.lineHeight - 2),
      ]);
      final nota = s.notes.single;
      final caixa = s.noteBox(nota.id)!;
      InkPointer p(double x, double y, int t) => (
        id: 9,
        kind: InkPointerKind.touch,
        x: x,
        y: y + s.textShift,
        pressure: 1,
        tMs: t,
      );
      s
        ..pointerDown(p(80, caixa.top + 40, 0))
        ..pointerMove(p(140, caixa.top + 48, 8))
        ..pointerMove(p(200, caixa.top + 38, 16))
        ..pointerUp(p(260, caixa.top + 44, 24));
      await tester.pump();
      await _concluir(tester);
      await tester.tapAt(const Offset(360, 420));
      await _quadros(tester);
      final seguinte = _pagina(tester) as PageSnapshot;
      expect(seguinte.page.slices.first, isA<SpaceSlice>());
      await _gravar(tester, 'g18_nota_na_pagina_seguinte_390x844@3x.png');
    },
  );
}

// G13.5 — capturas da seleção e dos grifos para conferência (mandadas na conversa), 390×844 @3x pela rota real no
// mundo da tela 21:
// - a tela 21 em Creme e no Noite (D-133: o grifo e a seleção na cor viva com as letras escuras);
// - a lupa (a alça parada 300 ms — D-45, D-135);
// - a barra embaixo da seleção (uma palavra perto do topo — D-136);
// - a folha da nota com texto (o teclado simulado — D-131);
// - a barra de um grifo existente, com o anel na cor dele (D-132);
// - o aviso "Grifo apagado · Desfazer" (D-132).
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela chegou ao estado pedido.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t21.dart';
import '../support/load_fonts.dart';

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

/// Deixa o banco gravar e a tela reler.
Future<void> _banco(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await _quadros(tester, 3);
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final papel in const [ReaderPaper.creme, ReaderPaper.noite]) {
    testWidgets('tela 21 em ${papel.code}', (tester) async {
      final livro = (await tester.runAsync(() => livroDaTela21(papel: papel)))!;
      addTearDown(() => tester.runAsync(livro.close));
      await abrirTela21(tester, livro, golden: true);
      expect(_key('r21.toolbar'), findsOneWidget);
      await _gravar(tester, 'g13_tela21_${papel.code}_390x844@3x.png');
    });
  }

  testWidgets('a lupa: a alça final parada 300 ms', (tester) async {
    final livro = (await tester.runAsync(livroDaTela21))!;
    addTearDown(() => tester.runAsync(livro.close));
    await abrirTela21(tester, livro, golden: true);
    final bolinha = tester.getCenter(_key('r21.page.text.handleEnd.knob'));
    final g = await tester.startGesture(bolinha);
    await g.moveBy(const Offset(0, 40));
    await tester.pump();
    await g.moveBy(const Offset(-30, -40));
    await tester.pump(const Duration(milliseconds: 320));
    await _quadros(tester, 3);
    expect(_key('leitor.lupa'), findsOneWidget);
    await _gravar(tester, 'g13_lupa_390x844@3x.png');
    await g.up();
    await _quadros(tester, 3);
  });

  testWidgets('a barra embaixo: uma palavra na 1ª linha da página', (
    tester,
  ) async {
    final livro = (await tester.runAsync(livroDaTela21))!;
    addTearDown(() => tester.runAsync(livro.close));
    await abrirTela21(tester, livro, golden: true);
    await tester.binding.handlePopRoute();
    await _quadros(tester);
    final p = paginaNaTela(tester);
    final s = p.shown!;
    final texto = p.textOf(s.unit, s.from, s.to);
    final i = texto.indexOf('namorados');
    final caixa = p.boxesOf(s.unit, s.from + i, s.from + i + 9).first.rect;
    await tester.longPressAt(caixa.center);
    await _quadros(tester);
    expect(
      tester.getRect(_key('r21.toolbar')).top,
      greaterThan(caixa.bottom),
      reason: 'embaixo',
    );
    await _gravar(tester, 'g13_barra_embaixo_390x844@3x.png');
  });

  testWidgets('a folha da nota com texto (teclado simulado)', (tester) async {
    final livro = (await tester.runAsync(livroDaTela21))!;
    addTearDown(() => tester.runAsync(livro.close));
    await abrirTela21(tester, livro, golden: true);
    await tester.tap(_key('r21.toolbar.actions.note'));
    await _quadros(tester, 3);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300 * 3);
    await tester.enterText(
      _key('leitor.nota.campo'),
      'O mar puxando para dentro: é Capitu inteira nesta imagem.',
    );
    await _quadros(tester, 5);
    expect(_key('leitor.nota'), findsOneWidget);
    await _gravar(tester, 'g13_nota_390x844@3x.png');
  });

  testWidgets('a barra de um grifo existente, com o anel na cor dele', (
    tester,
  ) async {
    final livro = (await tester.runAsync(livroDaTela21))!;
    addTearDown(() => tester.runAsync(livro.close));
    await abrirTela21(tester, livro, golden: true);
    await tester.binding.handlePopRoute();
    await _quadros(tester);
    final p = paginaNaTela(tester);
    final s = p.shown!;
    final i = p.textOf(s.unit, s.from, s.to).indexOf('olhos de Capitu');
    final caixa = p.boxesOf(s.unit, s.from + i, s.from + i + 5).first.rect;
    await tester.tapAt(caixa.center);
    await _quadros(tester);
    expect(_key('r21.toolbar.colors.yellow.marked'), findsOneWidget);
    await _gravar(tester, 'g13_grifo_existente_390x844@3x.png');
  });

  testWidgets('o aviso "Grifo apagado · Desfazer"', (tester) async {
    final livro = (await tester.runAsync(livroDaTela21))!;
    addTearDown(() => tester.runAsync(livro.close));
    await abrirTela21(tester, livro, golden: true);
    await tester.binding.handlePopRoute();
    await _quadros(tester);
    final p = paginaNaTela(tester);
    final s = p.shown!;
    final i = p.textOf(s.unit, s.from, s.to).indexOf('olhos de Capitu');
    final caixa = p.boxesOf(s.unit, s.from + i, s.from + i + 5).first.rect;
    await tester.tapAt(caixa.center);
    await _quadros(tester);
    await tester.tap(_key('r21.toolbar.colors.yellow'));
    await tester.pump();
    await _banco(tester);
    expect(_key('leitor.desfazer'), findsOneWidget);
    await _gravar(tester, 'g13_desfazer_390x844@3x.png');
    await tester.pump(const Duration(seconds: 4));
  });
}

// G20.8 — capturas da integração do leitor para conferência (mandadas na conversa), 390×844 @3x:
// - a Início com o Dom Casmurro real em leitura ("Cap. 32 de 148"), o leitor aberto pelo Continuar no mesmo ponto e
//   a Início depois de ler (o % e os minutos andam juntos — R1, R2);
// - o Voltar por camadas (R3): Rótulos → o painel do marca-texto → o modo anotação → a leitura limpa;
// - a restauração (D-207): o leitor com os controles antes de o sistema fechar o app, e o mesmo leitor restaurado na
//   mesma página, com a leitura limpa;
// - os alvos de toque que cresceram (R7), com a área marcada só na captura: o desenho em azul, a área de toque em
//   laranja (20, 22, 23 e 25).
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela chegou ao estado pedido.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/widgets/tap_target.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_com_livro.dart';
import '../support/canvas.dart';
import '../support/dados_t20.dart';
import '../support/dados_t22.dart';
import '../support/dados_t23.dart';
import '../support/dados_t25.dart';
import '../support/fase_l20.dart';
import '../support/fase_l25.dart';
import '../support/load_fonts.dart';
import '../support/pump_reader.dart';
import '../support/reader_harness.dart';

const Size _tela = Size(390, 844);

Finder _k(String k) => find.byKey(ValueKey<String>(k));

Future<void> _quadros(WidgetTester tester, [int n = 20]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _banco(WidgetTester tester, [int voltas = 8]) async {
  for (var i = 0; i < voltas; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _voltar(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await _quadros(tester, 60);
}

/// A tela inteira (a camada da view, em pixels físicos — 1170×2532).
Future<ui.Image> _imagem(WidgetTester tester) async {
  final view = tester.binding.renderViews.first;
  final layer = view.debugLayer! as OffsetLayer;
  final image = await tester.runAsync(() => layer.toImage(view.paintBounds));
  expect((image!.width, image.height), (1170, 2532));
  return image;
}

Future<void> _salvar(WidgetTester tester, ui.Image image, String nome) async {
  final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
  if (pasta == null) return;
  final png = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.png),
  );
  Directory(pasta).createSync(recursive: true);
  File('$pasta${Platform.pathSeparator}$nome')
      .writeAsBytesSync(png!.buffer.asUint8List());
}

Future<void> _gravar(WidgetTester tester, String nome) async =>
    _salvar(tester, await _imagem(tester), nome);

/// Os alvos que cresceram e se veem na tela (o toque no meio do desenho chega a eles).
List<RenderTapTarget> _alvosQueCresceram(WidgetTester tester) {
  final out = <RenderTapTarget>[];
  void visitar(RenderObject o) {
    if (o is RenderTapTarget &&
        o.attached &&
        o.hasSize &&
        (o.size.width < o.minSize || o.size.height < o.minSize)) {
      final centro = o.localToGlobal(o.size.center(Offset.zero));
      if (tester
          .hitTestOnBinding(centro)
          .path
          .any((e) => identical(e.target, o))) {
        out.add(o);
      }
    }
    o.visitChildren(visitar);
  }

  for (final v in tester.binding.renderViews) {
    visitar(v);
  }
  return out;
}

/// A tela com os alvos marcados: o desenho em azul, a área de toque em laranja.
Future<void> _gravarAlvos(WidgetTester tester, String nome) async {
  final base = await _imagem(tester);
  final alvos = _alvosQueCresceram(tester);
  expect(alvos, isNotEmpty);
  final dpr = tester.view.devicePixelRatio;
  final r = ui.PictureRecorder();
  final c = Canvas(r)
    ..drawImage(base, Offset.zero, Paint())
    ..scale(dpr);
  for (final a in alvos) {
    final m = a.getTransformTo(null);
    final area = MatrixUtils.transformRect(m, a.hitArea);
    final desenho = MatrixUtils.transformRect(m, Offset.zero & a.size);
    c
      ..drawRect(area, Paint()..color = const Color(0x40FF8A00))
      ..drawRect(
        area,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFFFF8A00),
      )
      ..drawRect(
        desenho,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0xFF1E6BFF),
      );
  }
  final quadro = r.endRecording();
  final image = await tester.runAsync(
    () => quadro.toImage(base.width, base.height),
  );
  quadro.dispose();
  await _salvar(tester, image!, nome);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('a Início e o leitor no mesmo ponto, antes e depois de ler', (
    tester,
  ) async {
    final livro = await domCasmurroEmLeitura();
    addTearDown(livro.close);
    final relogio = RelogioG20();
    await abrirAppComLivro(tester, livro, relogio: relogio, tela: _tela);
    expect(textosEm(tester, 'hero.chapterPill'), 'Cap. 32 de 148');
    final antes = textosEm(tester, 'hero.percent');
    await _gravar(tester, 'g20_01_inicio_antes.png');
    await tester.tap(_k('hero.cta'));
    await tester.pump();
    await esperarLeitor(tester);
    await _banco(tester, 4);
    expect(textosEm(tester, 'r19.footer.percent'), antes);
    await _gravar(tester, 'g20_02_leitor_mesmo_ponto.png');
    // ~40 s por página da tela (meia página de referência): o ritmo de quem lê o Dom Casmurro
    for (var i = 0; i < 6; i++) {
      relogio.andar(const Duration(seconds: 40));
      await tester.tapAt(const Offset(360, 420));
      await _quadros(tester, 30);
    }
    await _banco(tester);
    for (var i = 0; i < 6 && _k('hero.title').evaluate().isEmpty; i++) {
      await _voltar(tester);
      await _banco(tester, 4);
    }
    await esperarInicio(tester);
    await _banco(tester);
    await tester.pumpAndSettle();
    expect(textosEm(tester, 'hero.percent'), isNot(antes));
    await _gravar(tester, 'g20_03_inicio_depois.png');
  });

  testWidgets(
    'o Voltar por camadas: Rótulos, o painel, o modo, a leitura limpa',
    (tester) async {
      final livro = await livroDaTela23();
      addTearDown(livro.close);
      await abrirTela23b(tester, livro);
      await tester.tap(_k('ann.markerPanel.colorsHeader.editLabels'));
      await _quadros(tester, 20);
      expect(_k('ann.labels'), findsOneWidget);
      await _gravar(tester, 'g20_04_voltar_1_rotulos.png');
      await _voltar(tester);
      expect(_k('ann.labels'), findsNothing);
      expect(_k('ann.markerPanel'), findsOneWidget);
      await _gravar(tester, 'g20_05_voltar_2_painel.png');
      await _voltar(tester);
      expect(_k('ann.markerPanel'), findsNothing);
      expect(_k('ann.mode'), findsOneWidget);
      await _gravar(tester, 'g20_06_voltar_3_modo.png');
      await _voltar(tester);
      await _banco(tester);
      expect(_k('ann.mode'), findsNothing);
      expect(_k('r20.topIsland'), findsNothing);
      await _gravar(tester, 'g20_07_voltar_4_leitura_limpa.png');
    },
  );

  testWidgets('a restauração: antes de o sistema fechar o app e depois', (
    tester,
  ) async {
    final livro = await LivroNaEstante.domCasmurro();
    addTearDown(livro.close);
    await livro.guardarPosicao(2, livro.index.spine[2].chars ~/ 2);
    setCanvasView(tester, logical: _tela);
    await abrirLeitor(tester, livro);
    for (var i = 0; i < 2; i++) {
      await tester.tapAt(const Offset(360, 420));
      await _quadros(tester, 30);
    }
    final pagina = textosEm(tester, 'r19.footer.pageLabel');
    await tester.tapAt(const Offset(195, 420));
    await _quadros(tester, 24);
    expect(_k('r20.topIsland'), findsOneWidget);
    await _gravar(tester, 'g20_08_restauracao_antes.png');
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await _banco(tester, 6);
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.restartAndRestore();
    await _banco(tester, 6);
    await esperarLeitor(tester);
    await _quadros(tester, 30);
    expect(textosEm(tester, 'r19.footer.pageLabel'), pagina);
    expect(_k('r20.topIsland'), findsNothing);
    await _gravar(tester, 'g20_09_restauracao_depois.png');
  });

  group('os alvos que cresceram (R7)', () {
    testWidgets('20 — os controles', (tester) async {
      final livro = await livroDaTela20();
      addTearDown(livro.close);
      await abrirTela20(tester, livro);
      await _quadros(tester, 4);
      await _gravarAlvos(tester, 'g20_10_alvos_20.png');
    });

    testWidgets('22 — o modo anotação', (tester) async {
      final livro = await livroDaTela22();
      addTearDown(livro.close);
      await abrirTela22(tester, livro);
      await dedoDaTela22!.up();
      dedoDaTela22 = null;
      await _quadros(tester, 6);
      await _gravarAlvos(tester, 'g20_11_alvos_22.png');
    });

    testWidgets('23 — o painel da caneta', (tester) async {
      final livro = await livroDaTela23();
      addTearDown(livro.close);
      await abrirTela23(tester, livro);
      await _quadros(tester, 4);
      await _gravarAlvos(tester, 'g20_12_alvos_23.png');
    });

    testWidgets('25 — o topo e os filtros', (tester) async {
      final livro = await livroDaTela25();
      addTearDown(livro.close);
      await abrirTela25(tester, livro, tela: _tela);
      await _gravarAlvos(tester, 'g20_13_alvos_25.png');
    });
  });
}

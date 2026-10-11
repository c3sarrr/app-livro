// G17.7 — capturas dos painéis da caneta e do marca-texto, para conferência (mandadas na conversa), 390×844 @3x, pela
// rota real no mundo das telas 23 e 23b (D-34, D-160):
// - as telas 23 e 23b em Creme e no Noite (R26);
// - o marca-texto ao vivo (o dedo ainda na tela) e depois de soltar, grudado nas palavras (R20, R21);
// - a D-32 com o marca-texto: outra cor no meio de um grifo da página o corta (D-173);
// - a folha "Rótulos" sobre o painel (D-177) e a folha "Outra cor" da tela 21 (D-178);
// - a tinta preta no Noite, na cor das letras (D-174).
// Só grava com BOOKNEST_CAPTURAS=<pasta>; sem a pasta, confere que cada tela chegou ao estado pedido.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t21.dart';
import '../support/dados_t23.dart';
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

/// Espera o banco e a tela.
Future<void> _banco(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
}

AnnotationSession _sessao(WidgetTester tester) =>
    tester.widget<AnnotationMode>(find.byType(AnnotationMode)).session;

DisplayPage _pagina(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document.current;

/// Fecha o painel aberto pelo ×.
Future<void> _fechar(WidgetTester tester, String painel) async {
  await tester.tap(_key('$painel.close'));
  await tester.pump();
  await _quadros(tester, 12);
}

/// Um traço pelos [pontos] (na tela), sem soltar no fim se [soltar] = `false`.
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

void main() {
  setUpAll(loadAppFonts);

  for (final papel in const [ReaderPaper.creme, ReaderPaper.noite]) {
    testWidgets('a tela 23 (${papel.name})', (tester) async {
      final livro = await livroDaTela23(papel: papel);
      addTearDown(livro.close);
      await abrirTela23(tester, livro, golden: true);
      await _gravar(tester, 'g17_tela23_${papel.name}_390x844@3x.png');
    });

    testWidgets('a tela 23b (${papel.name})', (tester) async {
      final livro = await livroDaTela23(papel: papel);
      addTearDown(livro.close);
      await abrirTela23b(tester, livro, golden: true);
      await _gravar(tester, 'g17_tela23b_${papel.name}_390x844@3x.png');
    });
  }

  testWidgets(
    'o marca-texto ao vivo e depois de soltar, grudado nas palavras (R20, R21)',
    (tester) async {
      final livro = await livroDaTela23();
      addTearDown(livro.close);
      await abrirTela23b(tester, livro, golden: true);
      await _fechar(tester, 'ann.markerPanel');
      final s = _sessao(tester);
      final antes = s.desk.items.length;
      // a 9ª linha da página, um pouco torto, de "lado a lado" até perto do fim
      final l = s.geometry.lines[8];
      final y = (l.textTop + l.textBottom) / 2 + annotationTextShift;
      final x0 = l.left + 4;
      final x1 = l.left + (l.right - l.left) * 0.7;
      final g = await _passar(tester, [
        for (var i = 0; i <= 12; i++)
          Offset(x0 + (x1 - x0) * i / 12, y - 3 + 6 * (i % 3) / 2),
      ], soltar: false);
      expect(s.live.value, isA<LiveMarker>());
      await _quadros(tester, 4);
      await _gravar(tester, 'g17_marcatexto_ao_vivo_390x844@3x.png');
      await g.up();
      await tester.pump();
      await _quadros(tester, 4);
      expect(s.desk.items.length, antes + 1);
      await _gravar(tester, 'g17_marcatexto_solto_390x844@3x.png');
    },
  );

  testWidgets(
    'a D-32 com o marca-texto: outra cor no meio de um grifo da página o corta (D-173)',
    (tester) async {
      final livro = await livroDaTela23();
      addTearDown(livro.close);
      await abrirTela23b(tester, livro, golden: true);
      final s = _sessao(tester);
      // o grifo da página com mais letras
      final alvo = ([
        ...s.desk.items,
      ]..sort((a, b) => (b.end - b.start).compareTo(a.end - a.start))).first;
      final rosa = alvo.color.toUpperCase() != '#FFC1C6';
      await tester.tap(
        _key('ann.markerPanel.colors.${rosa ? 'pink' : 'yellow'}'),
      );
      await tester.pump();
      await _fechar(tester, 'ann.markerPanel');
      final pagina = _pagina(tester);
      final texto = s.anchors.textOf(alvo.unit)!;
      final palavras = RegExp(
        r'[\p{L}]{2,}',
        unicode: true,
      ).allMatches(texto.substring(alvo.start, alvo.end)).toList();
      expect(palavras.length, greaterThanOrEqualTo(3));
      final meio = palavras[palavras.length ~/ 2];
      final caixa = pagina
          .boxesOf(alvo.unit, alvo.start + meio.start, alvo.start + meio.end)
          .first;
      final y = (caixa.textTop + caixa.textBottom) / 2 + annotationTextShift;
      final antes = s.desk.items.length;
      await _passar(tester, [
        Offset(caixa.rect.left + 1, y),
        Offset(caixa.rect.center.dx, y + 1),
        Offset(caixa.rect.right - 1, y),
      ]);
      await _quadros(tester, 4);
      // o novo no meio e o antigo em 2 pedaços
      expect(s.desk.items.length, antes + 2);
      await _gravar(tester, 'g17_d32_marcatexto_corta_390x844@3x.png');
    },
  );

  testWidgets('a folha "Rótulos" sobre o painel (D-177)', (tester) async {
    final livro = await livroDaTela23();
    addTearDown(livro.close);
    await abrirTela23b(tester, livro, golden: true);
    await tester.tap(_key('ann.markerPanel.colorsHeader.editLabels'));
    await tester.pump();
    await _quadros(tester, 12);
    expect(_key('ann.labels'), findsOneWidget);
    await _gravar(tester, 'g17_folha_rotulos_390x844@3x.png');
  });

  testWidgets('a folha "Outra cor" da tela 21 (D-178)', (tester) async {
    final livro = await livroDaTela21();
    addTearDown(livro.close);
    await abrirTela21(tester, livro, golden: true);
    await tester.tap(_key('r21.toolbar.colors.other'));
    await tester.pump();
    await _banco(tester);
    await _quadros(tester, 12);
    expect(_key('leitor.outraCor'), findsOneWidget);
    await _gravar(tester, 'g17_folha_outra_cor_390x844@3x.png');
  });

  testWidgets('a tinta preta no Noite, na cor das letras (D-174)', (
    tester,
  ) async {
    final livro = await livroDaTela23(papel: ReaderPaper.noite);
    addTearDown(livro.close);
    await abrirTela23(tester, livro, golden: true);
    await tester.tap(_key('ann.penPanel.favorites.black'));
    await _banco(tester);
    await _fechar(tester, 'ann.penPanel');
    await _passar(tester, [
      for (var i = 0; i <= 10; i++)
        Offset(60 + 24.0 * i, 470 + 14 * (i.isEven ? 0 : 1).toDouble()),
    ]);
    await _quadros(tester, 4);
    expect(
      _sessao(tester).visibleStrokes.where((t) => t.argb == 0xFF1A1714),
      hasLength(1),
    );
    await _gravar(tester, 'g17_tinta_preta_noite_390x844@3x.png');
  });
}

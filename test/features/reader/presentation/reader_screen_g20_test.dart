// G20.6 (R8) — o leitor de tela no modo anotação e na página:
// - trocar de ferramenta ou de cor é anunciado ("Marca-texto, verde"; a Borracha só com o nome); o anúncio da entrada
//   continua o da G16;
// - na leitura limpa, cada desenho da página é um nó de imagem "Desenho, 20 de setembro" (como a nota à mão da G18).
import 'package:app_leitura/features/highlights/presentation/highlights_screen.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart'
    show StrokeSize;
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart'
    show InkRect;
import 'package:app_leitura/features/reader/application/annotation_session.dart'
    show AnnotationTool, LassoSelection;
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/canvas.dart';
import '../../../support/dados_t20.dart';
import '../../../support/dados_t22.dart';
import '../../../support/dados_t23.dart';
import '../../../support/dados_t24.dart' show sessaoNaTela;
import '../../../support/dados_t25.dart';
import '../../../support/fase_l20.dart';
import '../../../support/fase_l25.dart' show esperarTela25;
import '../../../support/load_fonts.dart';
import '../../../support/pump_reader.dart';

Finder _k(String k) => find.byKey(ValueKey<String>(k));

Future<void> _quadros(WidgetTester tester, [int n = 20]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'trocar de ferramenta ou de cor no modo é anunciado; a Borracha só com o nome',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(accessibleNavigation: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final livro = await livroDaTela23();
      addTearDown(livro.close);
      await abrirTela22(tester, livro);
      await dedoDaTela22!.up();
      dedoDaTela22 = null;
      await _quadros(tester, 6);
      tester.takeAnnouncements();
      Future<List<String>> depois(Future<void> Function() acao) async {
        await acao();
        await _quadros(tester, 6);
        return [for (final a in tester.takeAnnouncements()) a.message];
      }

      expect(await depois(() => tester.tap(_k('ann.toolShelf.marker'))), [
        matches(RegExp(r'^Marca-texto, \S')),
      ]);
      expect(
        await depois(
          () async => sessaoNaTela(tester).setHighlighterColor('#ABCF82'),
        ),
        ['Marca-texto, verde'],
      );
      expect(await depois(() => tester.tap(_k('ann.toolShelf.eraser'))), [
        'Borracha',
      ]);
      expect(await depois(() => tester.tap(_k('ann.toolShelf.pen'))), [
        matches(RegExp(r'^Caneta, \S')),
      ]);
      expect(
        await depois(() async => sessaoNaTela(tester).setPenColor('#058CD7')),
        ['Caneta, azul'],
      );
      expect(
        await depois(
          () async => sessaoNaTela(tester).setStrokeSize(StrokeSize.thin),
        ),
        isEmpty,
        reason: 'sem troca de ferramenta nem de cor, nada a anunciar',
      );
    },
  );

  testWidgets(
    'do Laço com uma seleção para o Marca-texto: um anúncio só, o do Marca-texto',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(accessibleNavigation: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final livro = await livroDaTela23();
      addTearDown(livro.close);
      await abrirTela22(tester, livro);
      await dedoDaTela22!.up();
      dedoDaTela22 = null;
      await _quadros(tester, 6);
      final s = sessaoNaTela(tester);
      s.setTool(AnnotationTool.lasso);
      await _quadros(tester, 6);
      s.selection.value = const LassoSelection(
        strokes: {},
        bounds: InkRect(40, 300, 120, 340),
      );
      await _quadros(tester, 6);
      tester.takeAnnouncements();
      s.setTool(AnnotationTool.marker);
      await _quadros(tester, 6);
      expect(
        [for (final a in tester.takeAnnouncements()) a.message],
        [matches(RegExp(r'^Marca-texto, \S'))],
        reason:
            'a cor muda antes da ferramenta dentro da troca: nada de "Laço"',
      );
    },
  );

  testWidgets('dois toques rápidos em Grifos abrem a 25 uma vez', (
    tester,
  ) async {
    final livro = await livroDaTela25();
    addTearDown(livro.close);
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro, destaques: depsDaTela25(livro));
    await tester.tapAt(const Offset(195, 420));
    await _quadros(tester, 12);
    await tester.tap(_k('r20.bottomIsland.tools.notes'));
    await tester.tap(_k('r20.bottomIsland.tools.notes'), warnIfMissed: false);
    await esperarTela25(tester, assentar: false);
    await _quadros(tester, 60);
    expect(find.byType(HighlightsScreen, skipOffstage: false), findsOneWidget);
  });

  testWidgets(
    'a barra de posição (26) recebe o toque e o nó com 48 de altura (R7)',
    (tester) async {
      final h = tester.ensureSemantics();
      final livro = await livroDaTela20();
      addTearDown(livro.close);
      await abrirTela20(tester, livro);
      final trilho = tester.getRect(_k('r20.bottomIsland.scrubber'));
      expect(trilho.height, 26, reason: 'o desenho não muda');
      final no = tester.getSemantics(_k('r20.bottomIsland.scrubber'));
      expect(no.getSemanticsData().label, 'Posição no livro');
      expect(no.rect.height, 48);
      int pagina() => tester
          .widget<ReaderPageView>(find.byType(ReaderPageView))
          .document
          .numbers
          .refPage;
      final antes = pagina();
      // um toque a 10 abaixo do trilho, no meio: salta para o meio do livro, como um toque no trilho
      await tester.tapAt(
        Offset(trilho.left + trilho.width * 0.5, trilho.bottom + 10),
      );
      await _quadros(tester, 20);
      final abaixo = pagina();
      expect(abaixo, isNot(antes), reason: 'o toque abaixo do trilho saltou');
      expect(abaixo, inInclusiveRange(110, 140), reason: 'o meio do livro');
      h.dispose();
    },
  );

  testWidgets(
    'na leitura limpa, cada desenho da página é um nó "Desenho, 20 de setembro"',
    (tester) async {
      final h = tester.ensureSemantics();
      final livro = await livroDaTela23();
      addTearDown(livro.close);
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro, deps: (t) => depsDaTela20(t, livro));
      await esperarBancoL22(tester);
      await _quadros(tester, 10);
      final hoje = find.bySemanticsLabel('Desenho, 20 de setembro');
      // a elipse, o ondulado e o duplo do mundo, os três na pág. 159
      expect(hoje, findsNWidgets(3));
      expect(
        find.bySemanticsLabel(RegExp(r'^Desenho, ')).evaluate().length,
        3,
        reason: 'todos os desenhos da página são de hoje no mundo',
      );
      // cada nó no lugar do seu desenho: três retângulos diferentes, dentro do texto da página, de cima para baixo
      final caixas = [
        for (final e in hoje.evaluate())
          tester.getSemantics(find.byElementPredicate((x) => x == e)).rect,
      ];
      final globais = [
        for (final e in hoje.evaluate())
          MatrixUtils.transformRect(
            e.renderObject!.getTransformTo(null),
            Offset.zero & (e.renderObject! as RenderBox).size,
          ),
      ]..sort((a, b) => a.top.compareTo(b.top));
      expect(caixas.toSet(), hasLength(3));
      for (final r in globais) {
        expect(r.left, greaterThanOrEqualTo(0));
        expect(r.right, lessThanOrEqualTo(390));
        expect(r.top, greaterThan(60));
        expect(r.bottom, lessThan(800));
      }
      expect(globais.first.top, lessThan(globais.last.top));
      expect(
        tester.getSemantics(hoje.first),
        matchesSemantics(label: 'Desenho, 20 de setembro', isImage: true),
      );
      h.dispose();
    },
  );
}

// G20.6 (R8) — o leitor de tela no modo anotação e na página:
// - trocar de ferramenta ou de cor é anunciado ("Marca-texto, verde"; a Borracha só com o nome); o anúncio da entrada
//   continua o da G16;
// - na leitura limpa, cada desenho da página é um nó de imagem "Desenho, 20 de setembro" (como a nota à mão da G18).
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart'
    show StrokeSize;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/canvas.dart';
import '../../../support/dados_t20.dart';
import '../../../support/dados_t22.dart';
import '../../../support/dados_t23.dart';
import '../../../support/dados_t24.dart' show sessaoNaTela;
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
      expect(hoje, findsWidgets);
      expect(
        find.bySemanticsLabel(RegExp(r'^Desenho, ')).evaluate().length,
        hoje.evaluate().length,
        reason: 'todos os desenhos da página são de hoje no mundo',
      );
      expect(
        tester.getSemantics(hoje.first),
        matchesSemantics(label: 'Desenho, 20 de setembro', isImage: true),
      );
      h.dispose();
    },
  );
}

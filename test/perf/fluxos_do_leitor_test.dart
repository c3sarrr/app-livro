// G20 (R9) — a fumaça dos fluxos dos orçamentos (sem medir tempo): cada um roda uma vez no `flutter_test` sem quebrar,
// para o teste de aparelho (`integration_test/leitor_orcamentos_test.dart`) não chegar quebrado à G26.
import 'package:app_leitura/features/library/domain/import_outcome.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/load_fonts.dart';
import 'fluxos_do_leitor.dart';

void main() {
  setUpAll(loadAppFonts);

  test('o EPUB gerado de ~2 MB e a importação até poder ler', () async {
    final bytes = epubDe2MB();
    expect(bytes.length, inInclusiveRange(1500000, 3000000));
    final r = await importarEpub(bytes);
    expect(r.resultado, isA<Imported>());
  });

  test('paginar um capítulo inteiro, passo a passo', () async {
    final livro = await livroGerado();
    addTearDown(livro.close);
    final spine = livro.index.spine.indexWhere((s) => s.linear) + 3;
    final r = paginarCapitulo(livro, spine);
    expect(r.paginas, greaterThan(20));
    expect(r.maiorPassoMicros, greaterThan(0));
  });

  testWidgets(
    'abrir já indexado, virar 5 páginas e traçar 3 vezes no modo anotação',
    (tester) async {
      final livro = await livroGerado();
      addTearDown(livro.close);
      setCanvasView(tester, logical: const Size(390, 844));
      final t = await abrirLivroIndexado(tester, livro);
      final antes = find.byKey(const ValueKey('r19.footer.pageLabel'));
      expect(antes, findsOneWidget);
      await virarPaginas(tester, 5);
      await tester.tapAt(const Offset(195, 420));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.tap(
        find.byKey(const ValueKey('r20.bottomIsland.tools.annotate')),
      );
      for (var i = 0; i < 4; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(find.byKey(const ValueKey('ann.mode')), findsOneWidget);
      await tracar(tester, 3);
      expect(t.erros, isEmpty);
      await tester.binding.handlePopRoute();
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    },
  );
}

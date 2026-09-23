// Modelo: na F02 crie test/home/golden_canvas_test.dart com este conteúdo (descomentado).
// Cada fase gera/atualiza o PNG do canvas inteiro (--update-goldens) e compara o retângulo
// da seção com a referência via tools/compare_images.py (ordem dos comandos: prompt mestre §7).
//
// testWidgets('golden canvas', (tester) async {
//   setCanvasView(tester);
//   await precacheSvgs(tester, AppIcons.all);
//   await tester.pumpWidget(const ProviderScope(child: RepaintBoundary(key: goldenRootKey, child: App.forTests())));
//   await tester.pumpAndSettle();
//   await expectLater(find.byKey(goldenRootKey), matchesGoldenFile('../golden/goldens/inicio_canvas@3x.png'));
// });

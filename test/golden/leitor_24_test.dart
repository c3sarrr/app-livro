// G18.6 — goldens das telas 24 e 24b (Creme: abrindo espaço e a nota à mão) (L24, L24b, "Visual"): a tela inteira @3x
// (390×844 → 1170×2532, sem áreas seguras, como a prancha) pela rota real, no mundo das telas (D-34, D-160, R15):
// "Anotar", o Espaço e o dedo parado 3 linhas abaixo da fresta de "Vá, de ressaca." (24); "Anotar" com a nota salva
// (24b). Comparados com `handoff_v2/referencia/png/24_abrindo_espaco_390x844@3x.png` e `24b_nota_mao_390x844@3x.png`
// no recorte das fases (y 108–844) por `tools/compare_images.py`: blur_mismatch_% ≤ 0,5. Com BOOKNEST_CAPTURAS=<pasta>
// grava também as capturas lá.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t24.dart';
import '../support/load_fonts.dart';

Future<void> _gravar(WidgetTester tester, ui.Image image, String nome) async {
  final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
  if (pasta == null) return;
  final png = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.png),
  );
  Directory(pasta).createSync(recursive: true);
  File('$pasta${Platform.pathSeparator}$nome')
      .writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'golden da tela 24 (Creme, abrindo espaço de 3 linhas) (390×844 @3x)',
    (tester) async {
      final livro = await livroDaTela24();
      addTearDown(livro.close);
      await abrirTela24(tester, livro, golden: true);
      final image = await captureAt(tester, find.byKey(goldenRootKey));
      expect((image.width, image.height), (1170, 2532));
      await _gravar(tester, image, 'g18_tela24_390x844@3x.png');
      await expectLater(image, matchesGoldenFile('goldens/leitor_24@3x.png'));
    },
  );

  testWidgets('golden da tela 24b (Creme, a nota à mão) (390×844 @3x)', (
    tester,
  ) async {
    final livro = await livroDaTela24b();
    addTearDown(livro.close);
    await abrirTela24b(tester, livro, golden: true);
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 2532));
    await _gravar(tester, image, 'g18_tela24b_390x844@3x.png');
    await expectLater(image, matchesGoldenFile('goldens/leitor_24b@3x.png'));
  });
}

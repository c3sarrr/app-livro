// G13.5 — golden da tela 21 (Creme, seleção e barra de ações) (L21a/L21b, "Visual"): a tela inteira @3x (390×844 →
// 1170×2532, sem áreas seguras, como a prancha) pela rota real, no mundo da tela 21, com a seleção feita pelos
// gestos. É comparado com `handoff_v2/referencia/png/21_selecao_texto_corrigida_390x844@3x.png` (D-55) nos recortes
// y 84–844 (página) e y 345,12–477,62 (barra) por `tools/compare_images.py`: blur_mismatch_% ≤ 0,5. Com
// BOOKNEST_CAPTURAS=<pasta> grava também a captura lá.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t21.dart';
import '../support/load_fonts.dart';
import '../support/reader_harness.dart';

void main() {
  setUpAll(loadAppFonts);
  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela21());
  tearDown(() async => livro.close());

  testWidgets('golden da tela 21 (Creme, seleção) (390×844 @3x)', (
    tester,
  ) async {
    await abrirTela21(tester, livro, golden: true);
    expect(find.byKey(const ValueKey('r21.toolbar')), findsOneWidget);
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 2532));
    final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
    if (pasta != null) {
      final png = await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.png),
      );
      Directory(pasta).createSync(recursive: true);
      File('$pasta${Platform.pathSeparator}g13_tela21_390x844@3x.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
    }
    await expectLater(image, matchesGoldenFile('goldens/leitor_21@3x.png'));
  });
}

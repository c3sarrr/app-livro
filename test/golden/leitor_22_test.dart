// G16.7 — golden da tela 22 (Creme, modo anotação com a Caneta) (L22a–d, "Visual"): a tela inteira @3x (390×844 →
// 1170×2532, sem áreas seguras, como a prancha) pela rota real, no mundo da tela 22 (D-34 e D-160): "Anotar", as 2
// barras do sublinhado duplo com a Reta e a onda com a Caneta até 66 %, com o dedo parado no centro do anel. É
// comparado com `handoff_v2/referencia/png/22_modo_anotacao_390x844@3x.png` nos recortes das fases (a y 108–844,
// b 42–110, c 656–754, d 716–822) por `tools/compare_images.py`: blur_mismatch_% ≤ 0,5. Com BOOKNEST_CAPTURAS=<pasta>
// grava também a captura lá.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t22.dart';
import '../support/load_fonts.dart';
import '../support/reader_harness.dart';

void main() {
  setUpAll(loadAppFonts);
  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela22());
  tearDown(() async => livro.close());

  testWidgets('golden da tela 22 (Creme, modo anotação) (390×844 @3x)', (
    tester,
  ) async {
    await abrirTela22(tester, livro, golden: true);
    expect(find.byKey(const ValueKey('ann.island')), findsOneWidget);
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 2532));
    final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
    if (pasta != null) {
      final png = await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.png),
      );
      Directory(pasta).createSync(recursive: true);
      File('$pasta${Platform.pathSeparator}g16_tela22_390x844@3x.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
    }
    await expectLater(image, matchesGoldenFile('goldens/leitor_22@3x.png'));
  });
}

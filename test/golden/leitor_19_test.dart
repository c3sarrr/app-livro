// G11.5 — golden da tela 19 (L19, "Visual"): a tela inteira @3x (390×844 → 1170×2532, sem áreas seguras, como a
// prancha) pela rota real, no mundo de referência (pág. 159 de 256, 62 %). É comparado com
// `handoff_v2/referencia/png/19_leitor_limpo_390x844@3x.png` no recorte y 84–844 (a faixa da fase) por
// `tools/compare_images.py`: blur_mismatch_% ≤ 0,5. Com BOOKNEST_CAPTURAS=<pasta> grava também a captura lá.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/load_fonts.dart';
import '../support/pump_reader.dart';
import '../support/reader_harness.dart';

void main() {
  setUpAll(loadAppFonts);
  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela19());
  tearDown(() async => livro.close());

  testWidgets('golden da tela 19 (390×844 @3x)', (tester) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro, golden: true);
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 2532));
    final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
    if (pasta != null) {
      final png = await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.png),
      );
      Directory(pasta).createSync(recursive: true);
      File('$pasta${Platform.pathSeparator}g11_tela19_390x844@3x.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
    }
    await expectLater(image, matchesGoldenFile('goldens/leitor_19@3x.png'));
  });
}

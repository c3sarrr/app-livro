// G19.9 — golden da tela 25 (Grifos e notas) (L25a–L25d, "Visual"): a tela inteira @3x (390×2170 → 1170×6510, sem
// áreas seguras, como a prancha) pela rota real, no mundo de referência. É comparado com
// `handoff_v2/referencia/png/25_grifos_notas_390x2170@3x.png` nos recortes das fases (y 46–257,96; 253,96–367,96;
// 377,96–2099,98; 2109,98–2170) por `tools/compare_images.py`: blur_mismatch_% ≤ 0,5. Com BOOKNEST_CAPTURAS=<pasta>
// grava também a captura lá. A máscara da faixa dos tipos é conferida nos pixels (a borda direita mais clara).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t25.dart';
import '../support/fase_l25.dart';
import '../support/load_fonts.dart';
import '../support/reader_harness.dart';

void main() {
  setUpAll(loadAppFonts);
  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela25());
  tearDown(() async => livro.close());

  testWidgets('golden da tela 25 (Grifos e notas) (390×2170 @3x)', (
    tester,
  ) async {
    await abrirTela25(tester, livro, golden: true);
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 6510));
    final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
    if (pasta != null) {
      final png = await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.png),
      );
      Directory(pasta).createSync(recursive: true);
      File('$pasta${Platform.pathSeparator}g19_tela25_390x2170@3x.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
    }
    // a máscara (preto 85 % → transparente): no chip "À mão", a borda da direita (x 369,5) sai mais clara que a da
    // esquerda (x 288,5), as duas na borda de tinta do chip
    final px = await rgbaOf(tester, image);
    int luz(double x, double y) {
      final i = ((y * 3).round() * 1170 + (x * 3).round()) * 4;
      return px[i] + px[i + 1] + px[i + 2];
    }

    expect(luz(369.5, 282), greaterThan(luz(288.2, 282) + 60));
    await expectLater(image, matchesGoldenFile('goldens/leitor_25@3x.png'));
  });
}

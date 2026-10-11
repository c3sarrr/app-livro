// G12.5 — golden da tela 20 (Creme, controles) (L20, "Visual"): a tela inteira @3x (390×844 → 1170×2532, sem áreas
// seguras, como a prancha) pela rota real, no mundo de referência com os controles abertos. É comparado com
// `handoff_v2/referencia/png/20_leitor_controles_390x844@3x.png` no recorte y 46–844 por `tools/compare_images.py`:
// blur_mismatch_% ≤ 0,5. Com BOOKNEST_CAPTURAS=<pasta> grava também a captura lá.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t20.dart';
import '../support/fase_l20.dart' show abrirTela20;
import '../support/load_fonts.dart';
import '../support/reader_harness.dart';

void main() {
  setUpAll(loadAppFonts);
  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela20(papel: ReaderPaper.creme));
  tearDown(() async => livro.close());

  testWidgets('golden da tela 20 (Creme, controles) (390×844 @3x)', (
    tester,
  ) async {
    await abrirTela20(tester, livro, golden: true);
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 2532));
    final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
    if (pasta != null) {
      final png = await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.png),
      );
      Directory(pasta).createSync(recursive: true);
      File('$pasta${Platform.pathSeparator}g12_tela20_390x844@3x.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
    }
    await expectLater(image, matchesGoldenFile('goldens/leitor_20@3x.png'));
  });
}

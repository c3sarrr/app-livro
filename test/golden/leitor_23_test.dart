// G17.7 — goldens das telas 23 e 23b (Creme, os painéis da caneta e do marca-texto) (L23, L23b, "Visual"): a tela
// inteira @3x (390×844 → 1170×2532, sem áreas seguras, como a prancha) pela rota real, no mundo das telas 23 e 23b
// (D-34 e D-160): "Anotar" e o 2º toque na Caneta (23) ou o Marca-texto e o 2º toque nele (23b). Comparados com
// `handoff_v2/referencia/png/23_ajustes_caneta_390x844@3x.png` e `23b_ajustes_marcatexto_390x844@3x.png` nos recortes
// das fases (23: y 117–673,63; 23b: y 100,86–673,63) por `tools/compare_images.py`: blur_mismatch_% ≤ 0,5. Com
// BOOKNEST_CAPTURAS=<pasta> grava também as capturas lá.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/capture.dart';
import '../support/dados_t23.dart';
import '../support/load_fonts.dart';
import '../support/reader_harness.dart';

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
  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela23());
  tearDown(() async => livro.close());

  testWidgets('golden da tela 23 (Creme, o painel da caneta) (390×844 @3x)', (
    tester,
  ) async {
    await abrirTela23(tester, livro, golden: true);
    final image = await captureAt(tester, find.byKey(goldenRootKey));
    expect((image.width, image.height), (1170, 2532));
    await _gravar(tester, image, 'g17_tela23_390x844@3x.png');
    await expectLater(image, matchesGoldenFile('goldens/leitor_23@3x.png'));
  });

  testWidgets(
    'golden da tela 23b (Creme, o painel do marca-texto) (390×844 @3x)',
    (tester) async {
      await abrirTela23b(tester, livro, golden: true);
      final image = await captureAt(tester, find.byKey(goldenRootKey));
      expect((image.width, image.height), (1170, 2532));
      await _gravar(tester, image, 'g17_tela23b_390x844@3x.png');
      await expectLater(image, matchesGoldenFile('goldens/leitor_23b@3x.png'));
    },
  );
}

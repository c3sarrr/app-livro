// G01.8 — os SVGs exportados do arquivo novo (telas 19–27b) abrem no flutter_svg e batem com o catálogo.
// Os arquivos ainda não estão no pubspec (registro na G11): o teste lê do disco.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final catalogo = jsonDecode(
    File('handoff_v2/referencia/svg_catalogo.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final arquivos = catalogo['arquivos'] as Map<String, dynamic>;

  test('o catálogo lista exatamente os arquivos das pastas do leitor', () {
    final noDisco = <String>{
      for (final d in [
        'assets/icons/leitor',
        'assets/illustrations/leitor',
        'handoff_v2/referencia/svg_tinta',
        'handoff_v2/referencia/svg_graficos',
      ])
        for (final f in Directory(d).listSync().whereType<File>())
          f.path.replaceAll(r'\', '/'),
    };
    expect(noDisco, arquivos.keys.toSet());
  });

  test('todo uso do catálogo aponta para um arquivo existente', () {
    final usos = catalogo['usos'] as Map<String, dynamic>;
    for (final MapEntry(key: id, value: porPrancha) in usos.entries) {
      for (final u in (porPrancha as Map<String, dynamic>).values) {
        final arq = (u as Map<String, dynamic>)['arquivo'] as String;
        expect(arquivos.containsKey(arq), isTrue, reason: '$id → $arq');
      }
    }
  });

  for (final caminho in arquivos.keys) {
    test('flutter_svg abre $caminho', () async {
      final svg = File(caminho).readAsStringSync();
      final info = await vg.loadPicture(SvgStringLoader(svg), null);
      expect(info.size.width, greaterThan(0));
      expect(info.size.height, greaterThan(0));
      info.picture.dispose();
    });
  }
}

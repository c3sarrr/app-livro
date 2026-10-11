// G18 — os ícones das telas 24 e 24b no catálogo do leitor: as setas do chip do abridor (14, no papel), o lápis da
// etiqueta "Nota à mão" (13), o recolher (18) e o apagar (18) da caixa. Os arquivos são os da G01 (o mesmo desenho
// do arquivo, byte a byte fora o fim de linha) e abrem no flutter_svg.
import 'dart:io';

import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// O SVG da G01 de cada ícone (o `svg_catalogo.json` do handoff).
const _g01 = <String, String>{
  AppIconsLeitor.arrowsVertical:
      '<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" '
      'stroke="#F7F0E3" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="M12 3v18M7 7l5-4 5 4M7 17l5 4 5-4"></path></svg>',
  AppIconsLeitor.pencilBold:
      '<svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" viewBox="0 0 24 24" fill="none" '
      'stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16z"></path></svg>',
  AppIconsLeitor.chevronUp:
      '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" '
      'stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="m6 15 6-6 6 6"></path></svg>',
  AppIconsLeitor.trash:
      '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" '
      'stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="M4 7h16M9 7V4.5h6V7M6.5 7l1 13h9l1-13"></path></svg>',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('os 4 ícones no catálogo do leitor, nos arquivos da G01', () {
    expect(
      AppIconsLeitor.arrowsVertical,
      'assets/icons/leitor/ic_arrows_vertical.svg',
    );
    expect(AppIconsLeitor.pencilBold, 'assets/icons/leitor/ic_pencil_bold.svg');
    expect(AppIconsLeitor.chevronUp, 'assets/icons/leitor/ic_chevron_up.svg');
    expect(AppIconsLeitor.trash, 'assets/icons/leitor/ic_trash.svg');
    expect(AppIconsLeitor.all, containsAll(_g01.keys));
    for (final MapEntry(key: a, value: svg) in _g01.entries) {
      final f = File(a);
      expect(f.existsSync(), isTrue, reason: a);
      expect(f.readAsStringSync().replaceAll('\r', '').trim(), svg, reason: a);
    }
  });

  test('abrem no flutter_svg (a caixa de 24 do desenho; o tamanho de uso vem do `width` do arquivo)', () async {
    for (final a in _g01.keys) {
      final info = await vg.loadPicture(
        SvgStringLoader(File(a).readAsStringSync()),
        null,
      );
      expect(info.size, const Size(24, 24), reason: a);
      info.picture.dispose();
    }
  });
}

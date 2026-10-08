// G17 — os recursos das telas 23 e 23b: o "+" das favoritas (14, traço 3) e o × dos painéis (18, traço 2,4) no
// catálogo de ícones; as amostras das 3 pontas (80×26, na cor da caneta pela troca de cor do SVG) e a ilustração da
// dica "Gruda nas palavras" (34×22, sem cor do usuário, pré-carregada) existem e abrem.
import 'dart:io';

import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_illustrations_leitor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('o "+" e o × dos painéis no catálogo de ícones', () {
    expect(AppIconsLeitor.plus, 'assets/icons/leitor/ic_plus.svg');
    expect(
      AppIconsLeitor.all,
      containsAll([AppIconsLeitor.plus, AppIconsLeitor.close]),
    );
  });

  test(
    'as amostras das pontas e a dica existem, abrem e têm o tamanho do arquivo',
    () async {
      final tamanhos = {
        AppIllustrationsLeitor.tipBallpoint: const Size(80, 26),
        AppIllustrationsLeitor.tipFountain: const Size(80, 26),
        AppIllustrationsLeitor.tipBrush: const Size(80, 26),
        AppIllustrationsLeitor.markerTip: const Size(34, 22),
      };
      expect(AppIllustrationsLeitor.panels, tamanhos.keys.toList());
      for (final MapEntry(key: a, value: tamanho) in tamanhos.entries) {
        final f = File(a);
        expect(f.existsSync(), isTrue, reason: a);
        final info = await vg.loadPicture(
          SvgStringLoader(f.readAsStringSync()),
          null,
        );
        expect(info.size, tamanho, reason: a);
        info.picture.dispose();
      }
      // as amostras levam a cor da caneta (o coral do arquivo trocado); a dica vai pronta para o cache
      for (final a in [
        AppIllustrationsLeitor.tipBallpoint,
        AppIllustrationsLeitor.tipFountain,
        AppIllustrationsLeitor.tipBrush,
      ]) {
        expect(File(a).readAsStringSync(), contains('#FF552E'), reason: a);
        expect(AppIllustrationsLeitor.plain, isNot(contains(a)));
      }
      expect(
        AppIllustrationsLeitor.plain,
        contains(AppIllustrationsLeitor.markerTip),
      );
    },
  );
}

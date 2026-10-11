// G12.1 — os ícones dos controles do leitor existem e abrem no flutter_svg; a fita desmarcada (D-124) é a forma
// da marcada só no contorno; as variantes do Noite têm o traço claro #EDE3D1.
import 'dart:io';

import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('todos os ícones da lista existem e abrem', () async {
    expect(AppIconsLeitor.all.toSet(), hasLength(AppIconsLeitor.all.length));
    for (final a in AppIconsLeitor.all) {
      final f = File(a);
      expect(f.existsSync(), isTrue, reason: a);
      final info = await vg.loadPicture(
        SvgStringLoader(f.readAsStringSync()),
        null,
      );
      expect(info.size.width, greaterThan(0), reason: a);
      info.picture.dispose();
    }
  });

  test(
    'fita desmarcada: a forma da marcada, só o contorno; Noite com traço claro',
    () {
      final marcada = File(AppIconsLeitor.ribbonMarked).readAsStringSync();
      final vazia = File(AppIconsLeitor.ribbonEmpty).readAsStringSync();
      final vaziaNoite = File(AppIconsLeitor.ribbonEmptyNight)
          .readAsStringSync();
      const forma = 'd="M4 2h14v20l-7-5-7 5z"';
      expect(marcada, contains(forma));
      expect(vazia, contains(forma));
      expect(vazia, contains('fill="#FFFAF1"'));
      expect(vazia, contains('stroke="#1A1714"'));
      expect(vaziaNoite, contains('fill="#2A2520"'));
      expect(vaziaNoite, contains('stroke="#EDE3D1"'));
      for (final n in [
        AppIconsLeitor.arrowLeftNight,
        AppIconsLeitor.searchNight,
        AppIconsLeitor.highlighterNight,
        AppIconsLeitor.annotateNight,
        AppIconsLeitor.tocNight,
        AppIconsLeitor.moon,
      ]) {
        expect(File(n).readAsStringSync(), contains('#EDE3D1'), reason: n);
      }
    },
  );
}

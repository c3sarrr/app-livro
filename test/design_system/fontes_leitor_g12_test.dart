// G12.1 — letras dos controles do leitor contra as medidas da prancha 20: o título da ilha na Bricolage 17/800
// (instância da G01.7), o "≈ 2 h 10 min" com o glifo "≈" da Inter Bold (D-54) e o "Aa" na Literata estática
// 19/500 (D-104).
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

double largura(String s, TextStyle st) {
  final p = TextPainter(
    text: TextSpan(text: s, style: st),
    textDirection: TextDirection.ltr,
  )..layout();
  final w = p.width;
  p.dispose();
  return w;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  test('título da ilha: Bricolage 17/800, "Dom Casmurro" = 122,31 ±1 (r20.topIsland.title)', () {
    expect(AppFonts.bricolageOpsz, contains(17));
    final st = AppTextStyles.readerIslandTitle;
    expect(
      (st.fontFamily, st.fontSize, st.fontWeight, st.height, st.letterSpacing),
      ('Bricolage17', 17.0, FontWeight.w800, 1.1, -0.3),
    );
    expect(largura('Dom Casmurro', st), closeTo(122.31, 1.0));
  });

  test('"≈ 2 h 10 min" = 72,08 ±1 com o "≈" da Inter Bold (r20.bottomIsland.progressRow.timeLeft)', () {
    final st = AppTextStyles.readerProgress;
    expect(st.fontFamilyFallback, contains('BookNestApprox'));
    expect(st.fontFeatures, contains(const FontFeature.tabularFigures()));
    expect(largura('≈ 2 h 10 min', st), closeTo(72.08, 1.0));
    expect(
      largura('62%', AppTextStyles.readerProgressStrong),
      closeTo(26.21, 1.0),
    );
  });

  test('chip, rótulo, contador e balão nas medidas da prancha', () {
    expect(
      largura('18 min hoje · contando sozinho', AppTextStyles.readerChip),
      closeTo(221.95 - 1.5 * 2 - 9 - 12 - 15 - 6, 1.0),
    );
    expect(
      largura('pág. 159', AppTextStyles.readerBubble),
      closeTo(68.09 - 20, 1.0),
    );
    expect(
      largura('12', AppTextStyles.readerBadge),
      closeTo(24.15 - 3 - 10, 1.0),
    );
    expect(
      largura('Machado de Assis', AppTextStyles.readerIslandAuthor),
      closeTo(101.9, 1.0),
    );
  });

  test('"Aa" na Literata estática 19/500 (D-104), não na variável', () {
    final st = AppTextStyles.readerToolAa;
    expect(
      (st.fontFamily, st.fontWeight, st.fontSize),
      ('Literata19', FontWeight.w500, 19.0),
    );
    expect(AppTextStyles.readerSearchExcerpt.fontFamily, 'Literata17');
  });
}

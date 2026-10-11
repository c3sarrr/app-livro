// G15 — as letras da folha do sumário (telas 27 e 27b) contra as medidas das pranchas (L27/L27b, "Linhas de texto"):
// a Bricolage 26 do título, a Figtree 11–15 (abas, faixa, numerais, páginas, marcas, cartões), a Literata estática 16,
// 17/500 e 15,5 (D-104: títulos dos capítulos e excertos) — as novas 16 e 15,5 registradas no pubspec.
import 'dart:convert';

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

double largura(InlineSpan s) {
  final p = TextPainter(text: s, textDirection: TextDirection.ltr)..layout();
  final w = p.width;
  p.dispose();
  return w;
}

double de(String t, TextStyle s) => largura(TextSpan(text: t, style: s));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  test(
    'Literata estática 16 e 15,5 (400) no pubspec e no mapa; 17/500 já existia',
    () async {
      final manifest = (json.decode(
        await rootBundle.loadString('FontManifest.json'),
      ) as List).cast<Map<String, dynamic>>();
      final familias = {for (final m in manifest) m['family'] as String};
      for (final f in [
        'Literata16',
        'Literata16Ext',
        'Literata16Vi',
        'Literata15_5',
        'Literata15_5Ext',
        'Literata15_5Vi',
      ]) {
        expect(familias, contains(f));
      }
      // T13.10 somou a 600 (telas das etapas 7–11; o conjunto exato fica no t13_recursos_projeto_test)
      expect(AppFonts.literataStatic[16], contains(400));
      expect(AppFonts.literataStatic[15.5], {400});
      expect(AppTextStyles.readerTocChapter.fontFamily, 'Literata16');
      expect(AppTextStyles.readerTocChapterCurrent.fontFamily, 'Literata17');
      expect(AppTextStyles.readerBmExcerpt.fontFamily, 'Literata15_5');
      expect(AppTextStyles.readerTocTitle.fontFamily, 'Bricolage26');
    },
  );

  test('tela 27: título, subtítulo, abas, faixa', () {
    expect(de('Sumário', AppTextStyles.readerTocTitle), closeTo(103.08, 1.0));
    expect(
      de('Dom Casmurro · 148 capítulos', AppTextStyles.readerTocSubtitle),
      closeTo(177.12, 1.0),
    );
    expect(
      largura(
        TextSpan(
          children: [
            TextSpan(text: 'Capítulos ', style: AppTextStyles.readerTocTabOn),
            TextSpan(text: '148', style: AppTextStyles.readerTocTabCount),
          ],
        ),
      ),
      closeTo(88.97, 1.0),
    );
    expect(de('Marcadas', AppTextStyles.readerTocTab), closeTo(62.19, 1.0));
    expect(de('Marcadas', AppTextStyles.readerTocTabOn), closeTo(63.11, 1.0));
    expect(de('3', AppTextStyles.readerTocTabCount), closeTo(7.79, 0.5));
    expect(
      de('LEITORAS DE CAPITU · QUI 24/9', AppTextStyles.readerTocClubKicker),
      closeTo(191.17, 1.0),
    );
    expect(
      de('Até o cap. L · faltam 18', AppTextStyles.readerTocClubGoal),
      closeTo(157.43, 1.0),
    );
  });

  test('tela 27: linhas e o capítulo atual (o fio de navalha de "As curiosidades de")', () {
    expect(de('XXV', AppTextStyles.readerTocNumeral), closeTo(27.35, 0.5));
    expect(de('XXXVII', AppTextStyles.readerTocNumeral), closeTo(44.48, 0.5));
    expect(
      de('No Passeio Público', AppTextStyles.readerTocChapter),
      closeTo(140.66, 0.5),
    );
    expect(
      de('As curiosidades de', AppTextStyles.readerTocChapter),
      closeTo(139.19, 0.05),
    );
    expect(
      de('Olhos de ressaca', AppTextStyles.readerTocChapterCurrent),
      closeTo(134.52, 0.5),
    );
    expect(de('121', AppTextStyles.readerTocPage), closeTo(24.65, 0.5));
    expect(de('157', AppTextStyles.readerTocPageCurrent), closeTo(24.8, 0.5));
    expect(de('1', AppTextStyles.readerTocMarks), closeTo(4.9, 0.5));
    expect(
      de('você está na pág. 159', AppTextStyles.readerTocHere),
      closeTo(113.69, 1.0),
    );
    expect(AppTextStyles.readerTocPage.fontFeatures, [
      const FontFeature.tabularFigures(),
    ]);
  });

  test('tela 27b: cartões e dica', () {
    expect(de('pág. 3', AppTextStyles.readerBmPage), closeTo(36.09, 1.0));
    expect(
      de('cap. I · Do título', AppTextStyles.readerBmChapter),
      closeTo(86.05, 1.0),
    );
    expect(
      de('Uma noite destas, vindo da cidade', AppTextStyles.readerBmExcerpt),
      closeTo(248.36, 0.5),
    );
    expect(
      de('marcada em 2 set', AppTextStyles.readerBmDate),
      closeTo(93.52, 1.0),
    );
    expect(
      de('você está aqui', AppTextStyles.readerBmHere),
      closeTo(73.47, 1.0),
    );
    expect(
      de(
        'Toque na fita no alto do leitor para marcar ou',
        AppTextStyles.readerBmHint,
      ),
      closeTo(264.4, 1.0),
    );
  });

  test('cores e ícones novos', () {
    expect(AppColors.clubKicker, const Color(0xFF5B3A3E));
    expect(AppColors.tocRule, const Color(0xFFE3D8C4));
    expect(
      AppIconsLeitor.all,
      containsAll(<String>[
        AppIconsLeitor.flag,
        AppIconsLeitor.chevronRight,
        AppIconsLeitor.ribbonCoral,
        AppIconsLeitor.ribbonTiny,
        AppIconsLeitor.ribbonHint,
        AppIconsLeitor.checkRead,
        AppIconsLeitor.pencilCoral,
      ]),
    );
  });
}

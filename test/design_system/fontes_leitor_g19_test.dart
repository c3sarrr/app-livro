// G19 — as letras da tela 25 contra as medidas da prancha (L25a–L25d, "Linhas de texto"): a Bricolage 34 e a
// Instrument Serif 42 do título, a Figtree 10,5–15,5 (topo, filtros, separadores, cartões, nota, fim), a Literata
// estática 16,5 (D-104: a citação dos cartões — registrada agora no pubspec) e a serif 22 do fim; os ícones novos.
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

  test('Literata estática 16,5 (400) no pubspec e no mapa', () async {
    final manifest = (json.decode(
      await rootBundle.loadString('FontManifest.json'),
    ) as List).cast<Map<String, dynamic>>();
    final familias = {for (final m in manifest) m['family'] as String};
    for (final f in ['Literata16_5', 'Literata16_5Ext', 'Literata16_5Vi']) {
      expect(familias, contains(f));
    }
    expect(AppFonts.literataStatic[16.5], {400});
    expect(AppTextStyles.hlQuote.fontFamily, 'Literata16_5');
    expect(AppTextStyles.hlTitle.fontFamily, 'Bricolage34');
  });

  test('topo, título e subtítulo (L25a)', () {
    expect(de('Exportar', AppTextStyles.hlExport), closeTo(57.06, 1.0));
    expect(
      largura(
        TextSpan(
          children: [
            TextSpan(text: 'Grifos ', style: AppTextStyles.hlTitle),
            TextSpan(text: 'e notas', style: AppTextStyles.hlTitleSerif),
          ],
        ),
      ),
      closeTo(203.46, 1.0),
    );
    expect(
      largura(
        TextSpan(
          children: [
            TextSpan(
              text: 'Dom Casmurro',
              style: AppTextStyles.hlSubtitleStrong,
            ),
            TextSpan(
              text: ' · na ordem do livro',
              style: AppTextStyles.hlSubtitle,
            ),
          ],
        ),
      ),
      closeTo(218.75, 1.0),
    );
  });

  test('filtros e separadores (L25b, L25c)', () {
    expect(de('Tudo', AppTextStyles.hlChip), closeTo(31.32, 1.0));
    expect(
      de('pág. 159 · você parou aqui', AppTextStyles.hlSepHere),
      closeTo(149.71, 1.0),
    );
  });

  test('cartão: citação em Literata 16,5, nota, fim (L25c, L25d)', () {
    expect(
      de('…encontrei no trem da Central um rapaz', AppTextStyles.hlQuoteMuted),
      closeTo(315.99, 1.0),
    );
    expect(
      de('É o livro todo nessa frase.', AppTextStyles.hlNoteText),
      closeTo(169.54, 1.0),
    );
    expect(de('Daqui para frente,', AppTextStyles.hlEnd), closeTo(145.9, 1.0));
    expect(
      de('as margens ainda estão em branco.', AppTextStyles.hlEnd),
      closeTo(277.62, 1.0),
    );
    expect(
      de('Continuar lendo · pág. 159', AppTextStyles.hlEndCta),
      closeTo(186.64, 1.0),
    );
    expect(AppTextStyles.hlQuoteMuted.color, AppColors.inkSoft);
    expect(AppTextStyles.hlSearchPlaceholder.color, const Color(0xFF757575));
  });

  test('os ícones novos carregam', () async {
    for (final a in [
      AppIconsLeitor.starDeco,
      AppIconsLeitor.searchGray,
      AppIconsLeitor.people,
      AppIconsLeitor.moreDots,
      AppIconsLeitor.peopleChip,
      AppIconsLeitor.pencilHeavy,
    ]) {
      expect(await rootBundle.loadString(a), contains('<svg'));
      expect(AppIconsLeitor.all, contains(a));
    }
  });
}

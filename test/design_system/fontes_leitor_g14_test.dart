// G14.3 — as letras da folha de ajustes contra as medidas da prancha 26 (L26, "Linhas de texto"): a Bricolage 23
// e a Instrument Serif 28 do título, a Literata estática dos "A" (15 e 25/500), do "Aa" dos cartões (26 e 18 — D-104),
// o "Aa" na própria fonte (Lora, Figtree, Atkinson — as do livro) e a Figtree dos rótulos, nomes e opções.
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/painting.dart';
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
    'famílias novas: Bricolage 23 e Literata estática 15/500, 18, 25/500, 26',
    () {
      expect(AppFonts.bricolageOpsz, contains(23));
      expect(AppTextStyles.readerSheetTitle.fontFamily, 'Bricolage23');
      expect(
        [
          AppTextStyles.readerSheetSmallA.fontFamily,
          AppTextStyles.readerSheetLargeA.fontFamily,
          AppTextStyles.readerSheetPaperSample.fontFamily,
          AppTextStyles.readerSheetSampleLiterata.fontFamily,
        ],
        ['Literata15', 'Literata25', 'Literata18', 'Literata26'],
      );
      expect(AppTextStyles.readerSheetSampleLora.fontFamily, 'LoraBook');
      expect(
        AppTextStyles.readerSheetSampleAtkinson.fontFamily,
        'AtkinsonBook',
      );
      expect(AppTextStyles.readerSheetSampleFigtree.fontFamily, 'Figtree');
    },
  );

  test('título "Ajustes de leitura" = 181,16 ±1 (Bricolage 23/800 + Instrument Serif itálico 28)', () {
    final t = TextSpan(
      children: [
        TextSpan(text: 'Ajustes ', style: AppTextStyles.readerSheetTitle),
        TextSpan(
          text: 'de leitura',
          style: AppTextStyles.readerSheetTitleSerif,
        ),
      ],
    );
    expect(largura(t), closeTo(181.16, 1.0));
    expect(
      de('Ajustes', AppTextStyles.readerSheetTitle),
      closeTo(110.88 - 29.5, 1.0),
    );
  });

  test('tamanho e amostras', () {
    expect(de('A', AppTextStyles.readerSheetSmallA), closeTo(11.08, 1.0));
    expect(de('A', AppTextStyles.readerSheetLargeA), closeTo(18.24, 1.0));
    expect(
      de('Aa', AppTextStyles.readerSheetSampleLiterata),
      closeTo(32.71, 1.0),
    );
    expect(de('Aa', AppTextStyles.readerSheetSampleLora), closeTo(30.39, 1.0));
    expect(
      de('Aa', AppTextStyles.readerSheetSampleFigtree),
      closeTo(30.69, 1.0),
    );
    expect(
      de('Aa', AppTextStyles.readerSheetSampleAtkinson),
      closeTo(29.95, 1.0),
    );
    expect(de('Aa', AppTextStyles.readerSheetPaperSample), closeTo(22.81, 1.0));
  });

  test('rótulos, nomes, legendas, opções e a pílula', () {
    expect(de('FONTE', AppTextStyles.readerSheetLabel), closeTo(42.41, 1.0));
    expect(
      de('ENTRELINHA', AppTextStyles.readerSheetLabel),
      closeTo(81.26, 1.0),
    );
    expect(
      de('Literata', AppTextStyles.readerSheetFontName),
      closeTo(43.95, 1.0),
    );
    expect(
      de('Atkinson', AppTextStyles.readerSheetFontName),
      closeTo(50.29, 1.0),
    );
    expect(
      de('sem serifa', AppTextStyles.readerSheetCaption),
      closeTo(48.84, 1.0),
    );
    expect(
      de('Creme', AppTextStyles.readerSheetPaperNameOn),
      closeTo(37.51, 1.0),
    );
    expect(
      de('Branco', AppTextStyles.readerSheetPaperName),
      closeTo(38.63, 1.0),
    );
    expect(de('Justo', AppTextStyles.readerSheetOption), closeTo(33.28, 1.0));
    expect(de('Médio', AppTextStyles.readerSheetOptionOn), closeTo(37.46, 1.0));
    expect(
      de('prévia ao vivo', AppTextStyles.readerSheetPill),
      closeTo(74.78, 1.0),
    );
  });

  test('alturas de linha: as "normais" das fontes (título 36,4; rótulo 13,2; nome 14,4)', () {
    expect(
      (
        AppTextStyles.readerSheetTitle.height,
        AppTextStyles.readerSheetTitleSerif.height,
      ),
      (1.2, 1.3),
    );
    expect(AppTextStyles.readerSheetLabel.height, 1.2);
    expect(AppTextStyles.readerSheetSampleLora.height, 1.1);
    expect(AppTextStyles.readerSheetPaperSample.height, 1.0);
    expect(
      AppTextStyles.readerSheetSmallA.height,
      isNull,
      reason: 'line-height normal da Literata (1,485)',
    );
  });
}

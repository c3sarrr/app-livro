import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/features/home/application/css_flex.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/painting.dart' show TextStyle;
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

/// F10 — 10.4: `resolveTextAndTag` (CSS Flexbox §9.7) e as medidas intrínsecas que o alimentam.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  group('resolveTextAndTag — tabela da F10 (±0,05)', () {
    test(
      'Frankenstein: cabe → o texto cresce (126,54) e o selo mantém 71,46',
      () {
        final w = resolveTextAndTag(
          available: 198,
          textMaxContent: 116.78,
          tagTextMaxContent: 51.46,
          tagTextMinContent: 34.45,
        );
        expect(w.text, closeTo(126.54, 0.05));
        expect(w.tag, closeTo(71.46, 0.05));
        expect(w.text + w.tag, closeTo(198, 1e-9));
      },
    );

    test('O Alienista: estoura ≈ 12,13 → texto 129,83 e selo 68,17', () {
      final w = resolveTextAndTag(
        available: 198,
        textMaxContent: 138.68,
        tagTextMaxContent: 51.46,
        tagTextMinContent: 34.45,
      );
      expect(w.text, closeTo(129.83, 0.05));
      expect(w.tag, closeTo(68.17, 0.05));
      expect(w.text + w.tag, closeTo(198, 1e-9));
    });

    test(
      'Senhora: cabe → o texto cresce (148,56) e o selo "Novo" mantém 49,44',
      () {
        final w = resolveTextAndTag(
          available: 198,
          textMaxContent: 135.37,
          tagTextMaxContent: 29.44,
          tagTextMinContent: 29.44,
        );
        expect(w.text, closeTo(148.56, 0.05));
        expect(w.tag, closeTo(49.44, 0.05));
        expect(w.text + w.tag, closeTo(198, 1e-9));
      },
    );
  });

  group('resolveTextAndTag — regras do algoritmo', () {
    test('o estouro é repartido pela base INTERNA (sem o padding), não pela externa', () {
      const text = 138.676, tagText = 51.456;
      final w = resolveTextAndTag(
        available: 198,
        textMaxContent: text,
        tagTextMaxContent: tagText,
        tagTextMinContent: 34.45,
      );
      final overflow = text + tagText + 20 - 198;
      expect(overflow, closeTo(12.13, 0.005)); // "≈ 12,13" do arquivo
      // Fator = flex-shrink × base interna: 138,676 e 51,456.
      expect(w.text, closeTo(text - overflow * text / (text + tagText), 1e-9));
      expect(
        w.tag,
        closeTo(tagText + 20 - overflow * tagText / (text + tagText), 1e-9),
      );
      // Com a base externa (71,456) o resultado seria outro (≈ 130,67 / 67,33): o Flutter (Flexible) erraria.
      final outerText = text - overflow * text / (text + tagText + 20);
      expect((w.text - outerText).abs(), greaterThan(0.5));
    });

    test('o selo nunca encolhe abaixo do min-content (maior palavra + padding): congela e o texto fica com o resto', () {
      final w = resolveTextAndTag(
        available: 100,
        textMaxContent: 200,
        tagTextMaxContent: 10,
        tagTextMinContent: 10,
      );
      // Sem o piso, o selo iria a 30 − 130 × 10/210 ≈ 23,8 (< 30 = 10 + 20).
      expect(w.tag, 30);
      expect(w.text, 70);
      expect(w.text + w.tag, 100);
    });

    test('padding horizontal configurável (padrão 20 = 10 + 10)', () {
      final w = resolveTextAndTag(
        available: 100,
        textMaxContent: 40,
        tagTextMaxContent: 20,
        tagTextMinContent: 20,
        tagHorizontalPadding: 0,
      );
      // Cabe com folga: o texto fica com 100 − 20.
      expect((w.text, w.tag), (80.0, 20.0));
    });

    test('linha estreita demais: o selo congela no min-content e o texto vai a 0 (min-width: 0), nunca negativo', () {
      final w = resolveTextAndTag(
        available: 20,
        textMaxContent: 138.68,
        tagTextMaxContent: 51.46,
        tagTextMinContent: 34.45,
      );
      expect(w.tag, closeTo(34.45 + 20, 1e-9));
      expect(w.text, 0);
    });

    test('exatamente no limite (soma = disponível) não encolhe nada', () {
      final w = resolveTextAndTag(
        available: 198,
        textMaxContent: 126.54,
        tagTextMaxContent: 51.46,
        tagTextMinContent: 34.45,
      );
      expect(w.text, closeTo(126.54, 1e-9));
      expect(w.tag, closeTo(71.46, 1e-9));
    });
  });

  group('medidas intrínsecas (fontes do arquivo, sem arredondar)', () {
    test('max-content: as larguras da tabela de linhas de texto da F10', () {
      final expected = <(String, TextStyle, double)>[
        ('Frankenstein', AppTextStyles.title15, 88.51),
        ('Mary Shelley · EPUB', AppTextStyles.body13Muted, 116.78),
        ('Quero ler', AppTextStyles.tagLavender, 51.46),
        ('O Alienista', AppTextStyles.title15, 75.34),
        ('Machado de Assis · PDF', AppTextStyles.body13Muted, 138.68),
        ('Senhora', AppTextStyles.title15, 56.88),
        ('José de Alencar · EPUB', AppTextStyles.body13Muted, 135.37),
        ('Novo', AppTextStyles.tagSand, 29.44),
      ];
      for (final (text, style, width) in expected) {
        expect(measure(text, style), closeTo(width, 0.05), reason: text);
      }
    });

    test('min-content = a maior palavra: "Quero ler" → "Quero" (34,45); "Novo" → ela mesma (29,44)', () {
      expect(
        longestWord('Quero ler', AppTextStyles.tagLavender),
        closeTo(34.45, 0.05),
      );
      expect(longestWord('Novo', AppTextStyles.tagSand), closeTo(29.44, 0.05));
      expect(
        longestWord('Quero ler', AppTextStyles.tagLavender),
        measure('Quero', AppTextStyles.tagLavender),
      );
      expect(longestWord('', AppTextStyles.tagSand), 0);
    });

    test('as medidas alimentam o algoritmo: as 3 linhas do arquivo (texto + selo = 198)', () {
      ({double text, double tag}) row(
        String title,
        String subtitle,
        String tag,
        TextStyle tagStyle,
      ) => resolveTextAndTag(
        available: 198,
        textMaxContent: [
          measure(title, AppTextStyles.title15),
          measure(subtitle, AppTextStyles.body13Muted),
        ].reduce((a, b) => a > b ? a : b),
        tagTextMaxContent: measure(tag, tagStyle),
        tagTextMinContent: longestWord(tag, tagStyle),
      );
      final r0 = row(
        'Frankenstein',
        'Mary Shelley · EPUB',
        'Quero ler',
        AppTextStyles.tagLavender,
      );
      final r1 = row(
        'O Alienista',
        'Machado de Assis · PDF',
        'Quero ler',
        AppTextStyles.tagLavender,
      );
      final r2 = row(
        'Senhora',
        'José de Alencar · EPUB',
        'Novo',
        AppTextStyles.tagSand,
      );
      for (final (r, text, tag) in [
        (r0, 126.54, 71.46),
        (r1, 129.83, 68.17),
        (r2, 148.56, 49.44),
      ]) {
        expect(r.text, closeTo(text, 0.05));
        expect(r.tag, closeTo(tag, 0.05));
        expect(r.text + r.tag, closeTo(198, 1e-9));
      }
      // O estouro da linha 2 vem das larguras SEM arredondar: ≈ 12,13 no arquivo (138,676 + 71,456 − 198). As
      // fontes estáticas têm desvio ≤ 0,05 px por texto medido (§6.1 do prompt mestre), então a soma de dois
      // textos pode ficar até ≈ 0,1 px do arquivo.
      final subtitle = measure(
        'Machado de Assis · PDF',
        AppTextStyles.body13Muted,
      );
      final tagText = measure('Quero ler', AppTextStyles.tagLavender);
      final overflow = subtitle + tagText + 20 - 198;
      debugPrint(
        '[flex] subtítulo ${subtitle.toStringAsFixed(6)} + selo ${(tagText + 20).toStringAsFixed(6)} − 198 = ${overflow.toStringAsFixed(6)} (arquivo ≈ 12,13)',
      );
      expect(overflow, closeTo(12.13, 0.1));
    });
  });
}

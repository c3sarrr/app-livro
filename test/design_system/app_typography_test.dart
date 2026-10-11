import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/load_fonts.dart';

/// Linha do catálogo da Subfase 1.3.2 (tabela da F01): família, tamanho, peso RENDERIZADO,
/// itálico, height, letterSpacing e cor.
typedef _Token = ({
  String name,
  TextStyle style,
  String family,
  double size,
  FontWeight weight,
  bool italic,
  double height,
  double letterSpacing,
  Color color,
});

// dart format off
final List<_Token> _kCatalog = [
  (name: 'displayXL', style: AppTextStyles.displayXL, family: 'Bricolage42', size: 42, weight: FontWeight.w800, italic: false, height: 0.98, letterSpacing: -1.4, color: AppColors.ink),
  (name: 'stubDay', style: AppTextStyles.stubDay, family: 'Bricolage42', size: 42, weight: FontWeight.w800, italic: false, height: 0.95, letterSpacing: -1.5, color: AppColors.ink),
  (name: 'dialValue', style: AppTextStyles.dialValue, family: 'Bricolage34', size: 34, weight: FontWeight.w800, italic: false, height: 1, letterSpacing: -1, color: AppColors.ink),
  (name: 'heroPercent', style: AppTextStyles.heroPercent, family: 'Bricolage26', size: 26, weight: FontWeight.w800, italic: false, height: 1.2, letterSpacing: -0.6, color: AppColors.ink),
  (name: 'heroTitle', style: AppTextStyles.heroTitle, family: 'Bricolage24', size: 24, weight: FontWeight.w800, italic: false, height: 1.05, letterSpacing: -0.6, color: AppColors.ink),
  (name: 'sectionTitleL', style: AppTextStyles.sectionTitleL, family: 'Bricolage24', size: 24, weight: FontWeight.w800, italic: false, height: 1.2, letterSpacing: -0.6, color: AppColors.ink),
  (name: 'clubTitle', style: AppTextStyles.clubTitle, family: 'Bricolage22', size: 22, weight: FontWeight.w800, italic: false, height: 1, letterSpacing: -0.5, color: AppColors.ink),
  (name: 'cardTitleM', style: AppTextStyles.cardTitleM, family: 'Bricolage20', size: 20, weight: FontWeight.w800, italic: false, height: 1.2, letterSpacing: -0.4, color: AppColors.ink),
  (name: 'sectionTitleS', style: AppTextStyles.sectionTitleS, family: 'Bricolage18', size: 18, weight: FontWeight.w800, italic: false, height: 1.2, letterSpacing: -0.3, color: AppColors.ink),
  (name: 'avatarInitial', style: AppTextStyles.avatarInitial, family: 'Bricolage18', size: 18, weight: FontWeight.w800, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.ink),
  (name: 'markerInitial', style: AppTextStyles.markerInitial, family: 'Bricolage12', size: 11, weight: FontWeight.w800, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.ink),
  (name: 'displaySerifXL', style: AppTextStyles.displaySerifXL, family: 'InstrumentSerif', size: 50, weight: FontWeight.w400, italic: true, height: 0.98, letterSpacing: -0.6, color: AppColors.ink),
  (name: 'clubSerif', style: AppTextStyles.clubSerif, family: 'InstrumentSerif', size: 36, weight: FontWeight.w400, italic: true, height: 0.95, letterSpacing: -0.4, color: AppColors.ink),
  (name: 'cardSerifM', style: AppTextStyles.cardSerifM, family: 'InstrumentSerif', size: 23, weight: FontWeight.w400, italic: true, height: 1.3, letterSpacing: -0.2, color: AppColors.ink),
  (name: 'coverTitle26', style: AppTextStyles.coverTitle26, family: 'InstrumentSerif', size: 26, weight: FontWeight.w400, italic: false, height: 0.9, letterSpacing: 0, color: AppColors.surface),
  (name: 'coverTitle22', style: AppTextStyles.coverTitle22, family: 'InstrumentSerif', size: 22, weight: FontWeight.w400, italic: false, height: 0.92, letterSpacing: 0, color: AppColors.sun),
  (name: 'coverTitle19', style: AppTextStyles.coverTitle19, family: 'InstrumentSerif', size: 19, weight: FontWeight.w400, italic: false, height: 0.95, letterSpacing: 0, color: AppColors.ink),
  (name: 'coverTitle11', style: AppTextStyles.coverTitle11, family: 'InstrumentSerif', size: 11, weight: FontWeight.w400, italic: false, height: 0.95, letterSpacing: 0, color: AppColors.ink),
  (name: 'coverTitle9', style: AppTextStyles.coverTitle9, family: 'InstrumentSerif', size: 9, weight: FontWeight.w400, italic: false, height: 0.95, letterSpacing: 0, color: AppColors.ink),
  (name: 'coverAuthorPaper', style: AppTextStyles.coverAuthorPaper, family: 'Figtree', size: 6.5, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0.91, color: AppColors.paper),
  (name: 'coverAuthorFlame', style: AppTextStyles.coverAuthorFlame, family: 'Figtree', size: 6.5, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0.91, color: AppColors.flame),
  (name: 'coverAuthorSurface', style: AppTextStyles.coverAuthorSurface, family: 'Figtree', size: 6.5, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0.91, color: AppColors.surface),
  (name: 'stubLabel', style: AppTextStyles.stubLabel, family: 'Figtree', size: 10, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 1, color: AppColors.stubLabel),
  (name: 'avatarCount', style: AppTextStyles.avatarCount, family: 'Figtree', size: 10, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.ink),
  (name: 'navLabel', style: AppTextStyles.navLabel, family: 'Figtree', size: 11, weight: FontWeight.w600, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.inkMuted),
  (name: 'dialCaption', style: AppTextStyles.dialCaption, family: 'Figtree', size: 11, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.inkWarm),
  (name: 'weekDay', style: AppTextStyles.weekDay, family: 'Figtree', size: 11, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.inkMuted),
  (name: 'micro11Bold', style: AppTextStyles.micro11Bold, family: 'Figtree', size: 11, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.ink),
  (name: 'caption12Plum', style: AppTextStyles.caption12Plum, family: 'Figtree', size: 12, weight: FontWeight.w600, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.inkPlum),
  (name: 'caption12Muted', style: AppTextStyles.caption12Muted, family: 'Figtree', size: 12, weight: FontWeight.w600, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.inkMuted),
  (name: 'label12Bold', style: AppTextStyles.label12Bold, family: 'Figtree', size: 12, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.ink),
  (name: 'tagLavender', style: AppTextStyles.tagLavender, family: 'Figtree', size: 12, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.tagLavenderFg),
  (name: 'tagSand', style: AppTextStyles.tagSand, family: 'Figtree', size: 12, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.inkWarm),
  (name: 'count12OnInk', style: AppTextStyles.count12OnInk, family: 'Figtree', size: 12, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.paper),
  (name: 'stubMeta', style: AppTextStyles.stubMeta, family: 'Figtree', size: 12, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0.96, color: AppColors.ink),
  (name: 'body13Muted', style: AppTextStyles.body13Muted, family: 'Figtree', size: 13, weight: FontWeight.w500, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.inkMuted),
  (name: 'body13Semi', style: AppTextStyles.body13Semi, family: 'Figtree', size: 13, weight: FontWeight.w600, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.ink),
  (name: 'body13Bold', style: AppTextStyles.body13Bold, family: 'Figtree', size: 13, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.ink),
  (name: 'body14Plum', style: AppTextStyles.body14Plum, family: 'Figtree', size: 14, weight: FontWeight.w500, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.inkPlum),
  (name: 'label14Bold', style: AppTextStyles.label14Bold, family: 'Figtree', size: 14, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.ink),
  (name: 'cta14OnInk', style: AppTextStyles.cta14OnInk, family: 'Figtree', size: 14, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.paper),
  (name: 'goalSentence', style: AppTextStyles.goalSentence, family: 'Figtree', size: 15, weight: FontWeight.w600, italic: false, height: 1.3, letterSpacing: 0, color: AppColors.ink),
  (name: 'goalSentenceStrong', style: AppTextStyles.goalSentenceStrong, family: 'Figtree', size: 15, weight: FontWeight.w700, italic: false, height: 1.3, letterSpacing: 0, color: AppColors.ink),
  (name: 'title15', style: AppTextStyles.title15, family: 'Figtree', size: 15, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.ink),
  (name: 'name16', style: AppTextStyles.name16, family: 'Figtree', size: 16, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: -0.1, color: AppColors.ink),
  (name: 'cta16OnInk', style: AppTextStyles.cta16OnInk, family: 'Figtree', size: 16, weight: FontWeight.w700, italic: false, height: 1.2, letterSpacing: 0, color: AppColors.paper),
];
// dart format on

// (token, texto, largura esperada, altura de 1 linha) — medidos no HTML original.
final kTypographyProof = <(TextStyle, String, double, double)>[
  (AppTextStyles.displayXL, 'Continue', 170.69, 41.16),
  (AppTextStyles.stubDay, '24', 48.24, 39.9),
  (AppTextStyles.dialValue, '18', 31.86, 34.0),
  (AppTextStyles.heroPercent, '62%', 56.46, 31.2),
  (AppTextStyles.heroTitle, 'Dom Casmurro', 169.03, 25.2),
  (AppTextStyles.sectionTitleL, 'Para você', 109.35, 28.8),
  (AppTextStyles.clubTitle, 'Leitoras de', 112.98, 22.0),
  (AppTextStyles.sectionTitleS, 'Também lendo', 126.54, 21.6),
  (AppTextStyles.avatarInitial, 'M', 17.06, 21.6),
  (AppTextStyles.markerInitial, 'M', 10.54, 13.2),
  (AppTextStyles.displaySerifXL, 'sua história.', 219.65, 49.0),
  (AppTextStyles.clubSerif, 'Capitu', 86.41, 34.2),
  (AppTextStyles.coverTitle26, 'O Cortiço', 81.77, 23.4),
  (AppTextStyles.coverTitle22, 'Casmurro', 74.56, 20.24),
  (AppTextStyles.coverTitle19, 'Póstumas de', 80.98, 18.05),
  (AppTextStyles.coverTitle11, 'Dalloway', 34.52, 10.45),
  (AppTextStyles.coverTitle9, 'Preconceito', 35.46, 8.55),
  (AppTextStyles.coverAuthorPaper, 'MACHADO DE', 52.96, 7.8),
  (AppTextStyles.coverAuthorFlame, 'MACHADO DE ASSIS', 78.33, 7.8),
  (AppTextStyles.coverAuthorSurface, 'MACHADO DE ASSIS', 78.33, 7.8),
  (AppTextStyles.stubLabel, 'ENCONTRO', 64.63, 12.0),
  (AppTextStyles.avatarCount, '+8', 12.44, 12.0),
  (AppTextStyles.navLabel, 'Biblioteca', 49.8, 13.2),
  (AppTextStyles.dialCaption, 'de 30 min', 49.84, 13.2),
  (AppTextStyles.weekDay, 'S', 6.68, 13.2),
  (AppTextStyles.micro11Bold, 'Scanner', 41.3, 13.2),
  (AppTextStyles.caption12Plum, '~2h 10min', 56.96, 14.4),
  (AppTextStyles.caption12Muted, '4h 00min no total', 97.72, 14.4),
  (AppTextStyles.label12Bold, 'Cap. 92 de 148', 81.55, 14.4),
  (AppTextStyles.tagLavender, 'Quero ler', 51.46, 14.4),
  (AppTextStyles.tagSand, 'Novo', 29.44, 14.4),
  (AppTextStyles.count12OnInk, '2', 6.95, 14.4),
  (AppTextStyles.stubMeta, 'QUI', 24.26, 14.4),
  (AppTextStyles.body13Muted, 'Boa noite,', 58.43, 15.6),
  (AppTextStyles.body13Semi, 'Porque você lê Machado de Assis', 196.28, 15.6),
  (AppTextStyles.body13Bold, '12 dias', 40.24, 15.6),
  (AppTextStyles.body14Plum, 'Machado de Assis', 113.41, 16.8),
  (AppTextStyles.label14Bold, 'Ver tudo', 55.99, 16.8),
  (AppTextStyles.cta14OnInk, 'Abrir discussão', 98.63, 16.8),
  (AppTextStyles.title15, 'Mrs. Dalloway', 95.79, 18.0),
  (AppTextStyles.name16, 'Marina', 49.51, 19.2),
  (AppTextStyles.cta16OnInk, 'Continuar lendo', 117.89, 19.2),
];

const _kWidthTolerance = 0.10;
const _kHeightTolerance = 0.01;

/// Os 4 tokens que só aparecem em textos mistos são provados na F07 (linhas completas).
const _kMixedOnly = {
  'cardTitleM',
  'cardSerifM',
  'goalSentence',
  'goalSentenceStrong',
};

String _nameOf(TextStyle style) =>
    _kCatalog.firstWhere((t) => identical(t.style, style)).name;

/// Layout de um `ui.Paragraph` com o estilo do token, largura infinita (Subfase 1.3.3).
ui.Paragraph _layoutProof(TextStyle style, String text) {
  final builder =
      ui.ParagraphBuilder(
          style.getParagraphStyle(
            textHeightBehavior: const TextHeightBehavior(
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        )
        ..pushStyle(style.getTextStyle())
        ..addText(text);
  return builder.build()
    ..layout(const ui.ParagraphConstraints(width: double.infinity));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  group('1.3.2 catálogo AppTextStyles', () {
    test('46 tokens, cada um com família, tamanho, peso, itálico, height, letterSpacing e cor da tabela', () {
      expect(_kCatalog, hasLength(46));
      expect(
        _kCatalog.map((t) => t.name).toSet(),
        hasLength(46),
        reason: 'nomes repetidos',
      );
      for (final t in _kCatalog) {
        final s = t.style;
        expect(s.fontFamily, t.family, reason: '${t.name}.fontFamily');
        expect(s.fontSize, t.size, reason: '${t.name}.fontSize');
        expect(s.fontWeight, t.weight, reason: '${t.name}.fontWeight');
        expect(
          s.fontStyle ?? FontStyle.normal,
          t.italic ? FontStyle.italic : FontStyle.normal,
          reason: '${t.name}.fontStyle',
        );
        expect(s.height, t.height, reason: '${t.name}.height');
        expect(
          s.letterSpacing,
          t.letterSpacing,
          reason: '${t.name}.letterSpacing',
        );
        expect(s.color, t.color, reason: '${t.name}.color');
        expect(
          s.leadingDistribution,
          TextLeadingDistribution.even,
          reason: '${t.name}.leadingDistribution',
        );
        final fallback = switch (t.family) {
          'Figtree' => ['FigtreeExt'],
          'InstrumentSerif' => ['InstrumentSerifExt'],
          final b => ['${b}Ext', '${b}Vi'],
        };
        expect(
          s.fontFamilyFallback,
          fallback,
          reason: '${t.name}.fontFamilyFallback',
        );
      }
    });

    test(
      'nenhum token Figtree usa peso fora de 400–700 (CSS 800 = 700, D-14)',
      () {
        for (final t in _kCatalog.where((t) => t.family == 'Figtree')) {
          expect(
            t.style.fontWeight!.value,
            inInclusiveRange(400, 700),
            reason: t.name,
          );
        }
      },
    );
  });

  group('1.3.1 asserts de AppFonts', () {
    test('Bricolage: tamanho sem instância opsz dispara assert; 11 px usa a instância 12', () {
      expect(
        () => AppFonts.bricolage(16, height: 1),
        throwsA(isA<AssertionError>()),
      );
      // T13.10: a 30 passou a existir (telas das etapas 7–11); a 29 continua sem instância
      expect(
        () => AppFonts.bricolage(29, height: 1),
        throwsA(isA<AssertionError>()),
      );
      expect(AppFonts.bricolage(11, height: 1.2).fontFamily, 'Bricolage12');
      for (final opsz in AppFonts.bricolageOpsz) {
        expect(
          AppFonts.bricolage(opsz.toDouble(), height: 1).fontFamily,
          'Bricolage$opsz',
        );
      }
    });

    test('Figtree: pesos fora de 400–700 disparam assert (não existe 800)', () {
      expect(
        () => AppFonts.figtree(12, FontWeight.w800),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => AppFonts.figtree(12, FontWeight.w300),
        throwsA(isA<AssertionError>()),
      );
      for (final w in [
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700,
      ]) {
        expect(AppFonts.figtree(12, w).fontWeight, w);
      }
    });
  });

  group('1.3.3 prova tipográfica (42 amostras)', () {
    test('cobre todos os tokens exceto os 4 de texto misto', () {
      expect(kTypographyProof, hasLength(42));
      final proved = kTypographyProof.map((p) => _nameOf(p.$1)).toSet();
      final expected = _kCatalog
          .map((t) => t.name)
          .where((n) => !_kMixedOnly.contains(n))
          .toSet();
      expect(proved, expected);
    });

    for (final (style, text, width, height) in kTypographyProof) {
      final name = _nameOf(style);
      test(
        '$name: "$text" → largura $width (±$_kWidthTolerance), altura $height (±$_kHeightTolerance)',
        () {
          final p = _layoutProof(style, text);
          final lines = p.computeLineMetrics();
          final gotWidth = p.maxIntrinsicWidth;
          // Altura exata da linha = ascent + descent (decisão A da F00, 23/09/2026): o SkParagraph
          // arredonda `paragraph.height` para pixel inteiro (Run.h `InternalLineMetrics::height()`).
          final gotHeight = lines.fold<double>(
            0,
            (s, l) => s + l.ascent + l.descent,
          );
          debugPrint(
            '[prova] ${name.padRight(18)} "$text": largura ${gotWidth.toStringAsFixed(3)} '
            '(esperado ${width.toStringAsFixed(2)}, Δ ${(gotWidth - width).toStringAsFixed(3)}) | '
            'altura ${gotHeight.toStringAsFixed(3)} (esperado ${height.toStringAsFixed(2)}, '
            'Δ ${(gotHeight - height).toStringAsFixed(3)}) | paragraph.height ${p.height.toStringAsFixed(0)} '
            '(round(esperado) = ${height.roundToDouble().toStringAsFixed(0)})',
          );
          expect(lines, hasLength(1), reason: '1 linha');
          expect(gotWidth, closeTo(width, _kWidthTolerance), reason: 'largura');
          expect(
            gotHeight,
            closeTo(height, _kHeightTolerance),
            reason: 'altura exata da linha',
          );
          expect(
            p.height,
            height.roundToDouble(),
            reason: 'paragraph.height = altura arredondada pelo SkParagraph',
          );
        },
      );
    }
  });
}

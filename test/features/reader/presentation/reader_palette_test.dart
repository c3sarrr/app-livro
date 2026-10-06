// G11.1 — tokens do leitor: os 4 papéis (papel, texto do livro, rodapé — Anexo 01 §0, Anexo 03 §7.1, D-110), a
// Figtree 800 real das telas 19–27b (D-16, L00), o estilo do rodapé "pág. X de Y · %" (L19 §4) e as áreas do
// leitor com as áreas seguras do aparelho (D-112).
import 'dart:math' as math;

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_insets.dart';
import 'package:app_leitura/features/reader/presentation/reader_palette.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String hex(Color c) => c.toARGB32().toRadixString(16).toUpperCase();

  test(
    'os 4 papéis: papel, texto e rodapé (Anexo 01, Anexo 03 §7.1, D-110)',
    () {
      final got = {
        for (final p in ReaderPaper.values)
          p: [
            ReaderPalette.of(p).paper,
            ReaderPalette.of(p).text,
            ReaderPalette.of(p).footer,
          ].map(hex).toList(),
      };
      expect(got, {
        ReaderPaper.creme: ['FFF8F1E4', 'FF2A2520', 'FFA89D8B'],
        ReaderPaper.branco: ['FFFFFDF8', 'FF1A1714', 'FFA9A6A2'],
        ReaderPaper.sepia: ['FFEEDDBF', 'FF4A3622', 'FFA08E74'],
        ReaderPaper.noite: ['FF1F1B17', 'FFE3D9C6', 'FF8A8073'],
      });
    },
  );

  test('a palavra achada pela busca fica escura na marca (D-127): letras claras só no Noite', () {
    for (final p in ReaderPaper.values) {
      final c = ReaderPalette.of(p);
      final noite = p == ReaderPaper.noite;
      expect(c.lightText, noite ? c.text : null, reason: p.name);
      expect(c.foundInk, noite ? c.paper : c.text, reason: p.name);
    }
  });

  test(
    'rodapé dos papéis claros com o mesmo contraste do Creme (2,4:1 — D-110)',
    () {
      double lum(Color c) {
        double ch(double v) => v <= 0.04045
            ? v / 12.92
            : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
        return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
      }

      double contrast(Color a, Color b) {
        final (x, y) = (lum(a), lum(b));
        return ((x > y ? x : y) + 0.05) / ((x > y ? y : x) + 0.05);
      }

      final creme = ReaderPalette.of(ReaderPaper.creme);
      final alvo = contrast(creme.footer, creme.paper);
      expect(alvo, closeTo(2.38, 0.01));
      for (final p in [ReaderPaper.branco, ReaderPaper.sepia]) {
        final pal = ReaderPalette.of(p);
        expect(
          contrast(pal.footer, pal.paper),
          closeTo(alvo, 0.02),
          reason: '$p',
        );
      }
    },
  );

  test('Figtree 800 real nas telas 19–27b (D-16, L00); a Início continua até 700 (D-14)', () {
    final s = AppFonts.figtreeReader(12.5, FontWeight.w800);
    expect((s.fontFamily, s.fontWeight), ('Figtree', FontWeight.w800));
    // G12 (D-54): o "≈" do tempo restante vem da Inter Bold (BookNestApprox), depois da FigtreeExt
    expect(s.fontFamilyFallback, ['FigtreeExt', 'BookNestApprox']);
    expect(
      () => AppFonts.figtree(12.5, FontWeight.w800),
      throwsA(isA<AssertionError>()),
    );
    expect(
      () => AppFonts.figtreeReader(12.5, FontWeight.w900),
      throwsA(isA<AssertionError>()),
    );
  });

  test('rodapé: Figtree 11,5/600, altura normal, números tabulares, cor do Creme (L19 §4)', () {
    final s = AppTextStyles.readerFooter;
    expect(
      (s.fontFamily, s.fontSize, s.fontWeight, s.height),
      ('Figtree', 11.5, FontWeight.w600, 1.2),
    );
    expect(s.fontFeatures, contains(const FontFeature.tabularFigures()));
    expect(s.color, AppColors.readerFooter);
  });

  test('áreas (D-112): canvas e iPhone dão 92/82/40; aparelho com área maior empurra', () {
    final zero = ReaderInsets.of(EdgeInsets.zero);
    expect((zero.top, zero.bottom, zero.footerBottom), (92.0, 82.0, 40.0));
    final iphone = ReaderInsets.of(const EdgeInsets.only(top: 47, bottom: 34));
    expect(
      (iphone.top, iphone.bottom, iphone.footerBottom),
      (92.0, 82.0, 40.0),
    );
    final alto = ReaderInsets.of(const EdgeInsets.only(top: 59, bottom: 48));
    expect((alto.top, alto.bottom, alto.footerBottom), (104.0, 96.0, 54.0));
  });
}

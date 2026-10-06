// G13.3 — o que a barra de ações da 21 e a folha da nota pedem do design system: a cor dos rótulos pequenos do
// leitor (#6F665B — L21b nº 3; no Noite, o cinza das ilhas), as letras da barra e da folha, a Literata variável do
// livro num tamanho de interface (o "a" do Sublinhar) e os ícones da barra no catálogo do leitor.
import 'dart:io';

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rótulo pequeno do leitor: #6F665B nos papéis claros, o cinza das ilhas no Noite', () {
    expect(AppColors.labelReader, const Color(0xFF6F665B));
    for (final p in [
      ReaderPaper.creme,
      ReaderPaper.branco,
      ReaderPaper.sepia,
    ]) {
      expect(ReaderChromePalette.of(p).label, AppColors.labelReader);
    }
    final noite = ReaderChromePalette.of(ReaderPaper.noite);
    expect(noite.label, AppColors.mutedNight);
    final creme = ReaderChromePalette.of(ReaderPaper.creme);
    expect(creme.faded(0.5).label.a, closeTo(0.5, 1e-6));
    expect(
      ReaderChromePalette.lerp(creme, noite, 0.5).label,
      Color.lerp(creme.label, noite.label, 0.5),
    );
    // só o rótulo diferente já é outra paleta (igualdade e hash)
    final outra = ReaderChromePalette(
      night: creme.night,
      veil: creme.veil,
      island: creme.island,
      border: creme.border,
      shadow: creme.shadow,
      well: creme.well,
      title: creme.title,
      muted: creme.muted,
      label: AppColors.ink,
      hatch: creme.hatch,
      hatchBase: creme.hatchBase,
      bubble: creme.bubble,
      bubbleText: creme.bubbleText,
      dash: creme.dash,
      disabled: creme.disabled,
    );
    expect(outra == creme, isFalse);
    expect(outra.hashCode == creme.hashCode, isFalse);
  });

  test('letras da barra (L21b) e da folha da nota (D-131)', () {
    final r = AppTextStyles.readerToolbarLabel;
    expect(
      (
        r.fontFamily,
        r.fontSize,
        r.fontWeight,
        r.letterSpacing,
        r.height,
        r.color,
      ),
      ('Figtree', 11.0, FontWeight.w800, 1.2, 1.0, AppColors.labelReader),
    );
    final a = AppTextStyles.readerToolbarAction;
    expect(
      (a.fontFamily, a.fontSize, a.fontWeight, a.height, a.color),
      ('Figtree', 11.5, FontWeight.w800, 1.2, AppColors.ink),
    );
    final f = AppTextStyles.readerNoteField;
    expect(
      (f.fontFamily, f.fontSize, f.fontWeight, f.height),
      ('Figtree', 15.0, FontWeight.w500, 1.35),
    );
    final b = AppTextStyles.readerNoteButton;
    expect(
      (b.fontFamily, b.fontSize, b.fontWeight),
      ('Figtree', 14.0, FontWeight.w800),
    );
  });

  test('Literata do livro num tamanho de interface: a variável com opsz e wght explícitos', () {
    final s = AppFonts.literataBook(13, size: 10.83, color: AppColors.inkNight);
    expect(s.fontFamily, readerFontFamily);
    expect(s.fontFamilyFallback, readerFontFallback);
    expect(
      (s.fontSize, s.fontWeight, s.height, s.color),
      (10.83, FontWeight.w400, 1.0, AppColors.inkNight),
    );
    expect(s.fontVariations, const [
      FontVariation('opsz', 13),
      FontVariation('wght', 400),
    ]);
    expect(AppFonts.literataBook(17).fontSize, 17);
    expect(AppFonts.literataBook(17).color, AppColors.ink);
  });

  test('ícones da barra de ações no catálogo do leitor, do arquivo (sem versão do Noite: são tingidos)', () {
    for (final (a, nome) in [
      (AppIconsLeitor.note, 'ic_note.svg'),
      (AppIconsLeitor.copy, 'ic_copy.svg'),
      (AppIconsLeitor.share, 'ic_share.svg'),
      (AppIconsLeitor.plusTiny, 'ic_plus_tiny.svg'),
    ]) {
      expect(a, 'assets/icons/leitor/$nome');
      expect(File(a).existsSync(), isTrue, reason: a);
      expect(AppIconsLeitor.all, contains(a));
    }
  });
}

// G11.1 — as cores de cada papel do leitor: papel, texto do livro e rodapé "pág. X de Y · %" (Anexo 01 §0,
// Anexo 03 §7.1, D-110). O texto do livro entra na `ReaderTypography.ink`; o papel e o rodapé são da tela.
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../domain/reader_settings.dart';

@immutable
final class ReaderPalette {
  const ReaderPalette({
    required this.paper,
    required this.text,
    required this.footer,
  });

  final Color paper;
  final Color text;
  final Color footer;

  static ReaderPalette of(ReaderPaper p) => switch (p) {
    ReaderPaper.creme => const ReaderPalette(
      paper: AppColors.paperCream,
      text: AppColors.bookText,
      footer: AppColors.readerFooter,
    ),
    ReaderPaper.branco => const ReaderPalette(
      paper: AppColors.paperWhite,
      text: AppColors.ink,
      footer: AppColors.readerFooterWhite,
    ),
    ReaderPaper.sepia => const ReaderPalette(
      paper: AppColors.paperSepia,
      text: AppColors.bookTextSepia,
      footer: AppColors.readerFooterSepia,
    ),
    ReaderPaper.noite => const ReaderPalette(
      paper: AppColors.paperNight,
      text: AppColors.bookTextNight,
      footer: AppColors.readerFooterNight,
    ),
  };
}

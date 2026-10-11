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

  /// As letras, quando são mais claras que o papel (o Noite): a marca da busca as escurece (D-127).
  Color? get lightText =>
      text.computeLuminance() > paper.computeLuminance() ? text : null;

  /// A palavra achada sobre a marca da busca, escura em todo papel: as letras ou, no Noite, o papel (D-127).
  Color get foundInk => lightText == null ? text : paper;

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

  /// O caminho de uma paleta à outra (Tema em 220 ms — D-121).
  static ReaderPalette lerp(ReaderPalette a, ReaderPalette b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    return ReaderPalette(
      paper: Color.lerp(a.paper, b.paper, t)!,
      text: Color.lerp(a.text, b.text, t)!,
      footer: Color.lerp(a.footer, b.footer, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReaderPalette &&
      other.paper == paper &&
      other.text == text &&
      other.footer == footer;

  @override
  int get hashCode => Object.hash(paper, text, footer);
}

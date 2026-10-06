// G11.3 — rodapé da tela 19 (L19 §4): "pág. 159 de 256" à esquerda e "62%" à direita, `left/right 28`,
// `bottom 40` (D-112 com o aparelho), Figtree 11,5/600 com números tabulares, na cor do rodapé do papel
// (D-110). Os números saem dos cálculos (D-19/D-89), nunca escritos aqui. O leitor de tela lê a página
// (rótulo "Título, página X de Y"): o rodapé repetiria, fica fora.
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../application/reader_document.dart';
import 'reader_palette.dart';

/// Margens do rodapé (fixas no arquivo — não acompanham as margens do texto).
const double readerFooterSide = 28;

class ReaderFooter extends StatelessWidget {
  const ReaderFooter({
    super.key,
    required this.numbers,
    required this.palette,
    required this.bottom,
  });

  final ReaderNumbersView numbers;
  final ReaderPalette palette;

  /// Distância à base da tela (ReaderInsets.footerBottom).
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.readerFooter.copyWith(color: palette.footer);
    return Positioned(
      left: readerFooterSide,
      right: readerFooterSide,
      bottom: bottom,
      child: ExcludeSemantics(
        child: Row(
          key: const ValueKey('r19.footer'),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              numbers.pageLabel,
              key: const ValueKey('r19.footer.pageLabel'),
              style: style,
              maxLines: 1,
            ),
            AppText(
              numbers.percentLabel,
              key: const ValueKey('r19.footer.percent'),
              style: style,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

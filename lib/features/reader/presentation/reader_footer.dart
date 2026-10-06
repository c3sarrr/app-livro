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

/// O vão do rodapé entre "pág. X de Y" e "%" (D-108): [child] (a pílula "Voltar à pág. N") fica centralizada nele
/// e na altura da linha do rodapé; se o vão for estreito (tela pequena, números longos), ela encolhe para caber —
/// nunca cobre os números.
class ReaderFooterGap extends StatelessWidget {
  const ReaderFooterGap({
    super.key,
    required this.numbers,
    required this.bottom,
    required this.child,
  });

  final ReaderNumbersView numbers;

  /// Distância à base da tela (ReaderInsets.footerBottom).
  final double bottom;
  final Widget child;

  /// Folga entre a pílula e cada número.
  static const double gap = 8;

  /// Altura da faixa onde a pílula é centralizada (maior que ela; só a pílula pega toque).
  static const double band = 64;

  @override
  Widget build(BuildContext context) {
    // como o AppText do rodapé: sem escala de texto do sistema, linha = tamanho × altura (Figtree 11,5 × 1,2)
    final style = AppTextStyles.readerFooter;
    double largura(String s) {
      final p = TextPainter(
        text: TextSpan(text: s, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final w = p.width;
      p.dispose();
      return w;
    }

    final line = style.fontSize! * style.height!;
    final left = readerFooterSide + largura(numbers.pageLabel) + gap;
    final right = readerFooterSide + largura(numbers.percentLabel) + gap;
    return Positioned(
      left: left,
      right: right,
      bottom: bottom + line / 2 - band / 2,
      height: band,
      child: Center(
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      ),
    );
  }
}

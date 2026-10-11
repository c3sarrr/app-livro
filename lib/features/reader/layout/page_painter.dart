// G10.2 — pintura de uma página (ADR-005): texto linha a linha na posição exata, troca de cena como um fio
// centralizado na linha dela (D-102) e imagem escalada dentro da faixa. O fundo (papel) e o rodapé são da tela (G11).
import 'dart:ui' as ui;

import 'laid_block.dart';
import 'paginator.dart';
import 'reader_typography.dart';

/// Imagem já decodificada do livro (a tela cuida do cache; sem imagem, a faixa fica vazia).
typedef ReaderImageOf = ui.Image? Function(String path);

/// Pinta [page] com a caixa de conteúdo no lugar de [t] (margem lateral e topo). [blockOf] devolve o bloco
/// pelo índice dele no capítulo.
void paintReaderPage(
  ui.Canvas c,
  ReaderPage page,
  LaidBlock Function(int block) blockOf,
  ReaderTypography t, {
  ReaderImageOf? imageOf,
}) {
  final left = t.sideMargin;
  for (final s in page.slices) {
    final b = blockOf(s.block);
    final top = t.topInset + s.y;
    switch ((s, b)) {
      case (TextSlice(:final firstLine, :final lastLine), final LaidText text):
        paintTextLines(c, text, firstLine, lastLine, left: left, top: top);
      case (ObjectSlice(), final LaidSceneBreak scene):
        if (!scene.rule) break; // linha decorativa: só o espaço (D-103)
        c.drawRect(
          ui.Rect.fromCenter(
            center: ui.Offset(
              left + t.contentWidth / 2,
              top + scene.lineHeight / 2,
            ),
            width: scene.ruleWidth,
            height: scene.ruleThickness,
          ),
          ui.Paint()..color = t.ink,
        );
      case (ObjectSlice(), final LaidImage image):
        final img = imageOf?.call(image.path);
        if (img == null || image.drawWidth <= 0) break;
        c.drawImageRect(
          img,
          ui.Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          ui.Rect.fromLTWH(
            left + image.left,
            top + image.drawTop,
            image.drawWidth,
            image.drawHeight,
          ),
          ui.Paint()..filterQuality = ui.FilterQuality.medium,
        );
      default:
        break;
    }
  }
}

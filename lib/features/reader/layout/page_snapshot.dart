// G11.2 — página do EPUB pronta para a tela: pinta pelo motor da G10 (linha a linha — D-94), dá o texto da
// página e acha o link sob o dedo no desenho das letras (`getBoxesForRange`), não só na palavra mais próxima.
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../content/content_blocks.dart';
import 'display_page.dart';
import 'laid_block.dart';
import 'page_painter.dart';
import 'paginator.dart';
import 'reader_typography.dart';

final class PageSnapshot implements DisplayPage {
  PageSnapshot({
    required this.spine,
    required this.page,
    required this._blockOf,
    required this.typography,
    required this.item,
    this._alive,
    this.imageOf,
  });

  /// Item do spine e a página dentro dele.
  final int spine;
  final ReaderPage page;

  /// Os ajustes com que a página foi montada.
  final ReaderTypography typography;

  /// O item aberto (texto canônico e blocos com os links).
  final ParsedItem item;
  final ReaderImageOf? imageOf;
  final LaidBlock Function(int block) _blockOf;
  final bool Function()? _alive;

  @override
  bool get alive => _alive?.call() ?? true;

  /// O bloco [index] do capítulo montado (os da página são os das fatias de [page]) — medidas e seleção.
  LaidBlock block(int index) => _blockOf(index);

  @override
  void paint(ui.Canvas canvas) {
    if (!alive) return;
    paintReaderPage(canvas, page, _blockOf, typography, imageOf: imageOf);
  }

  @override
  String get spokenText {
    final from = page.start.clamp(0, item.text.length);
    final to = page.end.clamp(from, item.text.length);
    return item.text.substring(from, to).replaceAll(objectChar, '').trim();
  }

  @override
  LinkHit? linkAt(ui.Offset p) {
    if (!alive) return null;
    for (final s in page.slices) {
      if (s is! TextSlice) continue;
      final b = _blockOf(s.block);
      if (b is! LaidText || b.source is! TextBlock) continue;
      for (final (a, z, target) in _links(b)) {
        for (final box in _boxes(b, s, a, z)) {
          if (box.contains(p)) {
            return (
              target: target,
              spine: spine,
              offset: math.max(a, _lineStartAt(b, s, p.dy) ?? a),
            );
          }
        }
      }
    }
    return null;
  }

  @override
  List<ui.Rect> rectsOf(int unit, int from, int to) {
    if (!alive || unit != spine || from >= to) return const [];
    return [
      for (final s in page.slices)
        if (s is TextSlice)
          if (_blockOf(s.block) case final LaidText b)
            ..._boxes(b, s, from, to),
    ];
  }

  /// As caixas das letras de [from]…[to] (texto canônico) nas linhas da fatia [s] do bloco [b], na tela. A
  /// altura de cada caixa é a da linha (o toque num link vale na linha inteira dele).
  Iterable<ui.Rect> _boxes(LaidText b, TextSlice s, int from, int to) sync* {
    final t = typography;
    final base = t.topInset + s.y - b.lines[s.firstLine].top;
    final x0 = t.sideMargin + b.left;
    for (var i = s.firstLine; i <= s.lastLine; i++) {
      final line = b.lines[i];
      final a = from < line.start ? line.start : from;
      final z = to > line.end ? line.end : to;
      if (a >= z) continue;
      final (pa, pi) = b.toParagraph(a);
      final (pz, pj) = b.toParagraph(z);
      // cada linha está num pedaço só; o fim pode cair no começo do pedaço seguinte
      final end = pz == pa
          ? pj
          : b.pieces[pa].paragraph
                .getLineBoundary(ui.TextPosition(offset: pi))
                .end;
      final top = base + line.top;
      for (final box in b.pieces[pa].paragraph.getBoxesForRange(pi, end)) {
        yield ui.Rect.fromLTRB(
          x0 + box.left,
          top,
          x0 + box.right,
          top + line.height,
        );
      }
    }
  }

  /// O começo (texto canônico) da linha da fatia [s] que está na altura [dy] da tela.
  int? _lineStartAt(LaidText b, TextSlice s, double dy) {
    final base = typography.topInset + s.y - b.lines[s.firstLine].top;
    for (var i = s.firstLine; i <= s.lastLine; i++) {
      final line = b.lines[i];
      final top = base + line.top;
      if (dy >= top && dy < top + line.height) return line.start;
    }
    return null;
  }

  /// Trechos com link do bloco, em posições do texto canônico: (início, fim, destino).
  static Iterable<(int, int, String)> _links(LaidText b) sync* {
    var at = b.start;
    for (final r in (b.source as TextBlock).runs) {
      final end = at + r.text.length;
      if (r.link case final l?) yield (at, end, l);
      at = end;
    }
  }
}

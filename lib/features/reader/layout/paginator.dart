// G10.1/G10.2 — paginação de um capítulo (Anexo 03 §7.2, D-96, D-98, D-100): as linhas entram na página até a
// próxima não caber (tolerância 0,02 px); parágrafo partido = o mesmo `Paragraph` pintado em duas páginas;
// título inteiro e nunca sozinho no pé; imagem e quebra de cena inteiras; `page-break-before` abre página.
// Cada capítulo (item do spine) é paginado à parte — e por isso começa numa página nova (D-100).
import 'laid_block.dart';
import 'reader_typography.dart';

/// Um bloco (ou parte dele) numa página, com o topo em [y] na caixa de conteúdo.
sealed class PageSlice {
  const PageSlice(this.block, this.y);

  /// Índice do bloco no capítulo.
  final int block;
  final double y;
}

/// Linhas [firstLine]…[lastLine] de um bloco de texto.
final class TextSlice extends PageSlice {
  const TextSlice(super.block, this.firstLine, this.lastLine, super.y);

  final int firstLine;
  final int lastLine;
}

/// Imagem ou quebra de cena (inteira).
final class ObjectSlice extends PageSlice {
  const ObjectSlice(super.block, super.y);
}

/// Uma página: as fatias e o trecho do texto canônico do item que ela cobre ([start] = 1º caractere visível).
final class ReaderPage {
  const ReaderPage(this.slices, {required this.start, required this.end});

  final List<PageSlice> slices;
  final int start;
  final int end;
}

/// Paginação incremental: [add] recebe os blocos em ordem (como as fatias de tempo os entregam) e [finish]
/// fecha a última página. As páginas fechadas ficam em [pages]. Com [firstBlock], o 1º bloco recebido é esse
/// índice do capítulo ([addFrom] começa nele por uma linha do meio — página guardada no cache).
final class ChapterPaginator {
  ChapterPaginator(this.contentHeight, {this.firstBlock = 0});

  final double contentHeight;
  final int firstBlock;
  final List<ReaderPage> pages = [];
  final List<LaidBlock> _blocks = [];
  List<PageSlice> _current = [];
  double _y = 0;

  /// Bloco anterior que é título esperando a 1ª linha do seguinte (D-98).
  int? _pendingHeading;

  double get _limit => contentHeight + ReaderTypography.fitTolerance;

  LaidBlock _block(int i) => _blocks[i - firstBlock];

  /// O 1º bloco a partir da linha [firstLine] (as anteriores ficaram em páginas que não são montadas aqui).
  void addFrom(LaidBlock b, int firstLine) {
    assert(_blocks.isEmpty);
    _blocks.add(b);
    _place(firstBlock, from: firstLine);
    if (b is LaidText && b.keepTogether && b.lines.isNotEmpty) {
      _pendingHeading = firstBlock;
    }
  }

  void add(LaidBlock b) {
    final i = firstBlock + _blocks.length;
    _blocks.add(b);
    if (b.pageBreakBefore && _current.isNotEmpty) _close();
    final waiting = _pendingHeading;
    if (waiting != null) {
      _pendingHeading = null;
      // o título só fica nesta página se a 1ª linha do seguinte (ou ele inteiro, se for outro título ou um
      // objeto) também couber
      final need = switch (b) {
        LaidText(keepTogether: true) => b.height,
        LaidText(:final lines) when lines.isNotEmpty => lines.first.height,
        _ => b.height,
      };
      if (_y + need > _limit) {
        // tira do pé desta página o título (e os títulos logo antes dele: título + subtítulo) e começa a
        // próxima com eles — a não ser que a página só tenha títulos
        final removed = <PageSlice>[];
        while (_current.isNotEmpty) {
          final last = _current.last;
          final blk = _block(last.block);
          if (last is! TextSlice || blk is! LaidText || !blk.keepTogether) {
            break;
          }
          removed.insert(0, _current.removeLast());
        }
        if (_current.isEmpty) {
          _current.addAll(removed);
        } else {
          _close();
          for (final r in removed) {
            _place(r.block);
          }
        }
      }
    }
    _place(i);
    if (b is LaidText && b.keepTogether && b.lines.isNotEmpty) {
      _pendingHeading = i;
    }
  }

  /// Fecha a última página. Devolve todas.
  List<ReaderPage> finish() {
    _pendingHeading = null;
    _close();
    return pages;
  }

  void _place(int i, {int from = 0}) {
    final b = _block(i);
    switch (b) {
      case LaidText(:final lines) when lines.isEmpty:
        return;
      case LaidText(keepTogether: true):
        if (_y > 0 && _y + b.height > _limit) _close();
        _current.add(TextSlice(i, 0, b.lines.length - 1, _y));
        _y += b.height;
      case LaidText():
        var l = from;
        while (l < b.lines.length) {
          final first = l;
          final top = b.lines[l].top;
          while (l < b.lines.length &&
              _y + (b.lines[l].bottom - top) <= _limit) {
            l++;
          }
          if (l == first) {
            if (_current.isEmpty) {
              l++; // nem uma linha cabe numa página vazia: vai assim mesmo
            } else {
              _close();
              continue;
            }
          }
          _current.add(TextSlice(i, first, l - 1, _y));
          _y += b.lines[l - 1].bottom - top;
          if (l < b.lines.length) _close();
        }
        if (b.extraBottom > 0) _y += b.extraBottom;
      case LaidImage() || LaidSceneBreak():
        if (_y > 0 && _y + b.height > _limit) _close();
        _current.add(ObjectSlice(i, _y));
        _y += b.height;
    }
  }

  void _close() {
    if (_current.isEmpty) {
      _y = 0;
      return;
    }
    final first = _current.first;
    final last = _current.last;
    pages.add(
      ReaderPage(
        List.unmodifiable(_current),
        start: _startOf(first),
        end: _endOf(last),
      ),
    );
    _current = [];
    _y = 0;
  }

  int _startOf(PageSlice s) => switch (s) {
    TextSlice(:final block, :final firstLine) =>
      (_block(block) as LaidText).lines[firstLine].start,
    ObjectSlice(:final block) => _block(block).start,
  };

  int _endOf(PageSlice s) => switch (s) {
    TextSlice(:final block, :final lastLine) =>
      (_block(block) as LaidText).lines[lastLine].end,
    ObjectSlice(:final block) => _block(block).start + 1,
  };
}

/// Pagina um capítulo inteiro de uma vez.
List<ReaderPage> paginateChapter(List<LaidBlock> blocks, double contentHeight) {
  final p = ChapterPaginator(contentHeight);
  for (final b in blocks) {
    p.add(b);
  }
  return p.finish();
}

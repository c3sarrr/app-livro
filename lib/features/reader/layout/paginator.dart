// G10.1/G10.2 — paginação de um capítulo (Anexo 03 §7.2, D-96, D-98, D-100): as linhas entram na página até a
// próxima não caber (tolerância 0,02 px); parágrafo partido = o mesmo `Paragraph` pintado em duas páginas;
// título inteiro e nunca sozinho no pé; imagem e quebra de cena inteiras; `page-break-before` abre página.
// Cada capítulo (item do spine) é paginado à parte — e por isso começa numa página nova (D-100). G18 (R12): o
// espaço aberto é uma fatia inteira entre as linhas do parágrafo; se não cabe no resto da página, vai para a seguinte.
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

/// G18 — um espaço aberto (o buraco [gap] do bloco de texto [block]), inteiro: a nota à mão, a faixa dela ou o
/// abridor. Quem pinta é a tinta (a página só reserva o lugar).
final class SpaceSlice extends PageSlice {
  const SpaceSlice(super.block, this.gap, super.y);

  /// Índice em `LaidText.gaps`.
  final int gap;
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

  /// O 1º bloco a partir da linha [firstLine] (as anteriores ficaram em páginas que não são montadas aqui); com
  /// [gap], a página começa pelo espaço aberto desse índice (o que ficou para o topo dela — G18).
  void addFrom(LaidBlock b, int firstLine, {int? gap}) {
    assert(_blocks.isEmpty);
    _blocks.add(b);
    _place(firstBlock, from: firstLine, gapFirst: gap);
    if (_keeps(b)) _pendingHeading = firstBlock;
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
        LaidText(keepTogether: true) when _keeps(b) => b.height,
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
          if (last is! TextSlice || !_keeps(blk)) {
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
    if (_keeps(b)) _pendingHeading = i;
  }

  /// Título que espera a 1ª linha do bloco seguinte: o que cabe numa página (o maior que ela é partido como
  /// texto comum).
  bool _keeps(LaidBlock b) =>
      b is LaidText &&
      b.keepTogether &&
      b.lines.isNotEmpty &&
      b.gaps.isEmpty &&
      b.height <= _limit;

  /// Fecha a última página. Devolve todas.
  List<ReaderPage> finish() {
    _pendingHeading = null;
    _close();
    return pages;
  }

  void _place(int i, {int from = 0, int? gapFirst}) {
    final b = _block(i);
    switch (b) {
      case LaidText(:final lines, :final gaps)
          when lines.isEmpty && gaps.isEmpty:
        return;
      // título maior que a página inteira (livro mal marcado): vai como texto comum, partido; com um espaço aberto,
      // também (G18)
      case LaidText(keepTogether: true)
          when b.height <= _limit && b.gaps.isEmpty:
        if (_y > 0 && _y + b.height > _limit) _close();
        _current.add(TextSlice(i, 0, b.lines.length - 1, _y));
        _y += b.height;
      case LaidText():
        _placeText(i, b, from: from, gapFirst: gapFirst);
      case LaidImage() || LaidSceneBreak():
        if (_y > 0 && _y + b.height > _limit) _close();
        _current.add(ObjectSlice(i, _y));
        _y += b.height;
    }
  }

  /// As linhas de [b] a partir de [from], com os espaços abertos entre elas (G18): os que ficaram em páginas
  /// anteriores (antes de [from]) não voltam; [gapFirst] = o espaço que abre esta página.
  void _placeText(int i, LaidText b, {required int from, int? gapFirst}) {
    final gaps = b.gaps;
    var g = gapFirst ?? gaps.indexWhere((x) => x.afterLine >= from);
    if (g < 0) g = gaps.length;
    var l = from;
    while (true) {
      while (g < gaps.length && gaps[g].afterLine < l) {
        _placeGap(i, g, gaps[g].height);
        g++;
      }
      if (l >= b.lines.length) break;
      final stop = g < gaps.length ? gaps[g].afterLine + 1 : b.lines.length;
      l = _fillLines(i, b, l, stop);
    }
    if (b.extraBottom > 0) _y += b.extraBottom;
  }

  /// As linhas [from, stop) de [b], fechando as páginas que encherem. Devolve [stop].
  int _fillLines(int i, LaidText b, int from, int stop) {
    var l = from;
    while (l < stop) {
      final first = l;
      final top = b.lines[l].top;
      while (l < stop && _y + (b.lines[l].bottom - top) <= _limit) {
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
      if (l < stop) _close();
    }
    return l;
  }

  /// R12: o espaço inteiro aqui; se não cabe no resto da página, no topo da seguinte.
  void _placeGap(int i, int g, double h) {
    if (_y > 0 && _y + h > _limit) _close();
    _current.add(SpaceSlice(i, g, _y));
    _y += h;
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
    SpaceSlice(:final block, :final gap) =>
      (_block(block) as LaidText).gaps[gap].at,
  };

  int _endOf(PageSlice s) => switch (s) {
    TextSlice(:final block, :final lastLine) =>
      (_block(block) as LaidText).lines[lastLine].end,
    ObjectSlice(:final block) => _block(block).start + 1,
    SpaceSlice(:final block, :final gap) =>
      (_block(block) as LaidText).gaps[gap].at,
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

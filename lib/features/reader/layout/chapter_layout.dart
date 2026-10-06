// G10.2 — layout e paginação de um capítulo em passos pequenos (Anexo 03 §7.2 e §12): cada passo monta um
// bloco ou um pedaço de parágrafo longo e entrega ao paginador; [ChapterLayoutJob.runFor] trabalha até o
// orçamento de tempo da fatia (4 ms) e devolve o controle. [layoutPageFrom] monta só a página que começa num
// caractere conhecido (o início que o cache de páginas guardou) para mostrar a posição antes do resto.
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../content/chapter_content.dart';
import '../content/content_blocks.dart';
import 'laid_block.dart';
import 'paginator.dart';
import 'reader_typography.dart';

/// Orçamento de cada fatia de trabalho por quadro (Anexo 03 §7.2).
const Duration layoutSliceBudget = Duration(milliseconds: 4);

/// Um capítulo pronto: os blocos com layout e as páginas.
final class ChapterLayout {
  ChapterLayout({
    required this.spineIndex,
    required this.item,
    required this.blocks,
    required this.pages,
  });

  final int spineIndex;
  final ParsedItem item;
  final List<LaidBlock> blocks;
  final List<ReaderPage> pages;

  /// Página que contém o caractere [offset] do item (antes do 1º → a 1ª; depois do último → a última).
  int pageAt(int offset) {
    if (pages.isEmpty) return 0;
    var lo = 0;
    var hi = pages.length - 1;
    while (lo < hi) {
      final m = (lo + hi + 1) >> 1;
      if (pages[m].start <= offset) {
        lo = m;
      } else {
        hi = m - 1;
      }
    }
    return lo;
  }

  /// Início de cada página (o que o cache guarda).
  List<int> get pageStarts => [for (final p in pages) p.start];

  void dispose() {
    for (final b in blocks) {
      b.dispose();
    }
  }
}

/// Layout + paginação de um capítulo, em passos.
final class ChapterLayoutJob {
  ChapterLayoutJob(this.content, ReaderTypography t)
    : _layouter = BlockLayouter(t, imageSize: _sizes(content)),
      _paginator = ChapterPaginator(t.contentHeight);

  final ChapterContent content;
  final BlockLayouter _layouter;
  final ChapterPaginator _paginator;
  final List<LaidBlock> _blocks = [];
  BlockLayoutTask? _task;
  int _next = 0;
  ChapterLayout? _result;
  bool _disposed = false;

  /// Maior tempo gasto num passo (µs) — para medir as fatias.
  int maxStepMicros = 0;

  /// Quanto o próximo passo deve levar (µs): o maior dos últimos, esquecendo devagar (1/8 por passo) — um
  /// pedaço de parágrafo longo depois de vários parágrafos curtos não estoura a fatia.
  int _expectedStep = 0;

  bool get done => _result != null;

  /// Páginas já fechadas (as primeiras ficam prontas antes do fim).
  List<ReaderPage> get pagesSoFar => _paginator.pages;

  /// Blocos já montados, pelo índice no capítulo (para pintar as páginas já fechadas).
  List<LaidBlock> get blocksSoFar => _blocks;

  ChapterLayout get result => _result!;

  /// Um passo. `true` = terminou.
  bool step() {
    if (_result != null) return true;
    if (_disposed) throw StateError('job descartado');
    final blocks = content.item.blocks;
    if (_next >= blocks.length && _task == null) {
      _result = ChapterLayout(
        spineIndex: content.spineIndex,
        item: content.item,
        blocks: List.unmodifiable(_blocks),
        pages: List.unmodifiable(_paginator.finish()),
      );
      return true;
    }
    final sw = Stopwatch()..start();
    var task = _task;
    if (task == null) {
      final i = _next++;
      task = _layouter.begin(
        blocks[i],
        start: content.item.blockStarts[i],
        previous: i == 0 ? null : blocks[i - 1],
        next: i + 1 < blocks.length ? blocks[i + 1] : null,
      );
      _task = task;
    }
    if (task.step()) {
      _task = null;
      _blocks.add(task.result);
      _paginator.add(task.result);
    }
    final us = sw.elapsedMicroseconds;
    if (us > maxStepMicros) maxStepMicros = us;
    _expectedStep = math.max(us, _expectedStep - (_expectedStep >> 3));
    return false;
  }

  /// Trabalha até terminar ou até o próximo passo (pelo que os últimos levaram) não caber em [budget]: a
  /// fatia passa do orçamento só se um passo sozinho passar dele. `true` = terminou.
  bool runFor(Duration budget) {
    final sw = Stopwatch()..start();
    final limit = budget.inMicroseconds;
    while (true) {
      if (step()) return true;
      if (sw.elapsedMicroseconds + _expectedStep > limit) return false;
    }
  }

  /// Tudo de uma vez (testes e medidas).
  ChapterLayout runAll() {
    while (!step()) {}
    return result;
  }

  /// Descarta o que foi montado (o capítulo saiu da vizinhança antes de terminar).
  void dispose() {
    _disposed = true;
    if (_result != null) {
      _result!.dispose();
    } else {
      for (final b in _blocks) {
        b.dispose();
      }
      if (_task case final t?) {
        if (t.step()) t.result.dispose();
      }
    }
  }
}

ImageSizeOf _sizes(ChapterContent c) => (img) {
  final s = c.imageSizes[img.path];
  return s == null
      ? (img.width != null &&
                img.height != null &&
                img.width! > 0 &&
                img.height! > 0
            ? ui.Size(img.width!.toDouble(), img.height!.toDouble())
            : null)
      : ui.Size(s.$1.toDouble(), s.$2.toDouble());
};

/// Uma página que começa no caractere [start] do item (um início de página guardado no cache): monta só os
/// blocos dela. `null` quando [start] não cai no começo de uma linha (o cache não vale para este layout).
({ReaderPage page, List<LaidBlock> blocks, int firstBlock})? layoutPageFrom(
  ChapterContent content,
  ReaderTypography t,
  int start,
) {
  final item = content.item;
  if (item.blocks.isEmpty) return null;
  final layouter = BlockLayouter(t, imageSize: _sizes(content));
  // bloco que contém o início
  var k = 0;
  for (var i = 0; i < item.blocks.length; i++) {
    if (item.blockStarts[i] <= start) k = i;
  }
  final paginator = ChapterPaginator(t.contentHeight, firstBlock: k);
  final laid = <LaidBlock>[];
  var firstLine = 0;
  for (var i = k; i < item.blocks.length; i++) {
    final b = layouter.layout(
      item.blocks[i],
      start: item.blockStarts[i],
      previous: i == 0 ? null : item.blocks[i - 1],
      next: i + 1 < item.blocks.length ? item.blocks[i + 1] : null,
    );
    laid.add(b);
    if (i == k) {
      if (b is LaidText) {
        firstLine = b.lines.indexWhere((l) => l.start == start);
        if (firstLine < 0) {
          for (final x in laid) {
            x.dispose();
          }
          return null;
        }
      } else if (b.start != start) {
        b.dispose();
        return null;
      }
      paginator.addFrom(b, firstLine);
    } else {
      paginator.add(b);
    }
    if (paginator.pages.isNotEmpty) break;
  }
  final pages = paginator.pages.isNotEmpty
      ? paginator.pages
      : paginator.finish();
  return (page: pages.first, blocks: laid, firstBlock: k);
}

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
import 'text_geometry.dart';

final class PageSnapshot implements DisplayPage, PageWithSpaces {
  @override
  bool get opaque => false;

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
          if (box.rect.contains(p)) {
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
  List<PageSpace> get spaces {
    if (!alive) return const [];
    final t = typography;
    return [
      for (final s in page.slices)
        if (s is SpaceSlice)
          if (_blockOf(s.block) case final LaidText b)
            (
              id: b.gaps[s.gap].id,
              rect: ui.Rect.fromLTWH(
                t.sideMargin,
                t.topInset + s.y,
                t.contentWidth,
                b.gaps[s.gap].height,
              ),
            ),
    ];
  }

  @override
  ReaderRange? get shown =>
      alive ? (unit: spine, from: page.start, to: page.end) : null;

  @override
  List<ui.Rect> rectsOf(int unit, int from, int to) => [
    for (final b in boxesOf(unit, from, to)) b.rect,
  ];

  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) {
    if (!alive || unit != spine || from >= to) return const [];
    return [
      for (final s in page.slices)
        if (s is TextSlice)
          if (_blockOf(s.block) case final LaidText b)
            ..._boxes(b, s, from, to),
    ];
  }

  @override
  String textOf(int unit, int from, int to) {
    final r = shown;
    if (r == null || unit != spine) return '';
    final a = math.max(from, r.from);
    final z = math.min(to, math.min(r.to, item.text.length));
    return a < z ? item.text.substring(a, z) : '';
  }

  @override
  ReaderSpot? spotAt(ui.Offset p) {
    final r = shown;
    if (r == null) return null;
    final lines = _shownLines().toList();
    if (lines.isEmpty) return null;
    if (p.dy < lines.first.top) return (unit: spine, offset: r.from);
    final last = lines.last;
    if (p.dy >= last.top + last.line.height) {
      return (unit: spine, offset: math.min(r.to, _visibleEnd(last.line)));
    }
    final l = lines.firstWhere(
      (l) => p.dy < l.top + l.line.height,
      orElse: () => last,
    );
    final piece = l.block.pieces[l.line.piece];
    // o meio da linha dentro do pedaço (o `pieceBaseline` é a baseline dos glifos — T01; difere da do LineMetrics
    // em menos de 1 px, e o meio continua dentro da faixa da linha)
    final y = l.line.pieceBaseline - l.line.ascent + l.line.height / 2;
    final pos = piece.paragraph.getPositionForOffset(ui.Offset(p.dx - l.x0, y));
    final at = l.block
        .toCanonical(l.line.piece, pos.offset)
        .clamp(l.line.start, _visibleEnd(l.line));
    return (unit: spine, offset: at.clamp(r.from, r.to));
  }

  @override
  ReaderRange? wordAround(ReaderSpot s) {
    final r = shown;
    if (r == null || s.unit != spine) return null;
    for (final l in _shownLines()) {
      final line = l.line;
      if (s.offset < line.start || s.offset >= line.end) continue;
      // a posição no pedaço que desenha a linha (os pedaços se sobrepõem)
      final piece = l.block.pieces[line.piece];
      final inPiece =
          s.offset -
          l.block.start -
          piece.textOffset +
          (piece.placeholder ? 1 : 0);
      final w = piece.paragraph.getWordBoundary(
        ui.TextPosition(offset: inPiece),
      );
      final from = l.block.toCanonical(line.piece, w.start);
      final to = l.block.toCanonical(line.piece, w.end);
      if (to <= from || item.text.substring(from, to).trim().isEmpty) {
        return null;
      }
      return (
        unit: spine,
        from: math.max(from, r.from),
        to: math.min(to, r.to),
      );
    }
    return null;
  }

  static final RegExp _letter = RegExp(r'[\p{L}\p{N}]', unicode: true);

  @override
  ReaderRange? wordAt(ui.Offset p) {
    final s = spotAt(p);
    if (s == null) return null;
    // o dedo na metade direita da última letra cai depois dela: vale também a palavra da letra anterior
    for (final o in [s.offset, s.offset - 1]) {
      final w = wordAround((unit: spine, offset: o));
      if (w == null) continue;
      if (!_letter.hasMatch(item.text.substring(w.from, w.to))) continue;
      if (boxesOf(
        spine,
        w.from,
        w.to,
      ).any((b) => b.rect.inflate(4).contains(p))) {
        return w;
      }
    }
    return null;
  }

  /// As linhas de texto da página, de cima para baixo, com o topo e a margem esquerda na tela.
  Iterable<({LaidText block, LaidLine line, double top, double x0})>
  _shownLines() sync* {
    final t = typography;
    for (final s in page.slices) {
      if (s is! TextSlice) continue;
      final b = _blockOf(s.block);
      if (b is! LaidText) continue;
      final base = t.topInset + s.y - b.lines[s.firstLine].top;
      for (var i = s.firstLine; i <= s.lastLine; i++) {
        yield (
          block: b,
          line: b.lines[i],
          top: base + b.lines[i].top,
          x0: t.sideMargin + b.left,
        );
      }
    }
  }

  /// O fim da linha sem o espaço (ou a quebra) que fica pendurado nela.
  int _visibleEnd(LaidLine line) {
    var e = line.end;
    while (e > line.start) {
      final c = item.text.codeUnitAt(e - 1);
      if (c != 0x20 && c != 0x0A) break;
      e--;
    }
    return e;
  }

  /// As caixas das letras de [from]…[to) nas linhas da fatia [s] do bloco [b], na tela: a altura da linha
  /// inteira (o toque num link vale na linha inteira), a linha de base e a área do texto do CSS.
  Iterable<TextLineBox> _boxes(
    LaidText b,
    TextSlice s,
    int from,
    int to,
  ) sync* {
    final t = typography;
    final base = t.topInset + s.y - b.lines[s.firstLine].top;
    final x0 = t.sideMargin + b.left;
    for (var i = s.firstLine; i <= s.lastLine; i++) {
      final line = b.lines[i];
      final a = from < line.start ? line.start : from;
      final lineEnd = _visibleEnd(line);
      final z = to > lineEnd ? lineEnd : to;
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
      final em = line.height / t.lineSpacing;
      final area = readerTextArea(em, t.font);
      final textTop = top + (line.height - area) / 2;
      for (final box in b.pieces[pa].paragraph.getBoxesForRange(pi, end)) {
        yield (
          rect: ui.Rect.fromLTRB(
            x0 + box.left,
            top,
            x0 + box.right,
            top + line.height,
          ),
          baseline: top + line.ascent,
          textTop: textTop,
          textBottom: textTop + area,
          em: em,
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

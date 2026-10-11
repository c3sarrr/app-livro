// G10.1 — blocos com layout (Anexo 03 §7.2, ADR-005, D-94, D-96, D-98, D-99): cada bloco do conteúdo vira
// um `ui.Paragraph` com layout uma vez. O SkParagraph arredonda a altura de cada linha para px inteiro, então o
// modelo vertical é próprio — topo exato de cada linha = soma de `ascent + descent` — e a pintura é linha a
// linha (recorte na faixa exata da linha + o `Paragraph` deslocado). Parágrafos longos têm layout em pedaços
// costurados na última linha (as linhas saem idênticas; cada pedaço cabe numa fatia de tempo). G18 (D-181): um
// espaço aberto parte o parágrafo na âncora — o 1º segmento acaba nela, o seguinte começa depois do branco, sem
// recuo — e o buraco ([LaidGap]) fica entre as linhas, para o paginador pôr a fatia do espaço.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show immutable;

import '../content/content_blocks.dart';
import 'reader_typography.dart';
import 'space_cut.dart';

/// Parágrafo acima disto (caracteres) tem layout em pedaços (ADR-005; ajustar no aparelho na G26).
const int layoutPieceChars = 1200;

/// Troca de cena (D-102, no lugar do "* * *" da D-99): um fio curto e grosso, centralizado na linha dele, na
/// cor do texto — largura em em (acompanha a letra) e espessura fixa, no estilo das bordas do BookNest.
const double sceneRuleEms = 2;
const double sceneRuleThickness = 3;

/// Marcador de item de lista, pendurado na margem (D-96).
const String listBullet = '•';

/// T01 — onde o SkParagraph põe as letras da linha [m] dentro do `Paragraph`: no topo da linha (a soma das alturas
/// arredondadas das anteriores, `baseline + descent − height`, com o `height` arredondado) mais o `ascent`
/// arredondado ao pixel lógico (`TextLine::buildTextBlob` pinta em `floor(baseline + 0,5)`, como a `AppText`
/// anota). A `m.baseline` fica `round(altura) − altura` acima disso (0,26 px no padrão): desenhar a linha por ela
/// punha as letras 0,5–0,83 px abaixo da baseline exata.
double glyphBaselineOf(ui.LineMetrics m) =>
    m.baseline + m.descent - m.height + (m.ascent + 0.5).floorToDouble();

/// Uma linha com a posição exata no bloco e o pedaço de texto que ela cobre no texto canônico do item.
final class LaidLine {
  const LaidLine({
    required this.top,
    required this.height,
    required this.ascent,
    required this.start,
    required this.end,
    required this.piece,
    required this.pieceBaseline,
  });

  /// Topo exato, relativo ao topo do bloco.
  final double top;

  /// `ascent + descent` da linha (sem arredondar).
  final double height;
  final double ascent;

  /// Primeiro caractere da linha e o fim (exclusivo, com o espaço do fim) no texto canônico do item.
  final int start;
  final int end;

  /// Pedaço (`Paragraph`) que desenha esta linha e a baseline dela dentro dele: onde o SkParagraph põe as letras
  /// ([glyphBaselineOf]).
  final int piece;
  final double pieceBaseline;

  double get baseline => top + ascent;
  double get bottom => top + height;
}

/// G18 — um espaço aberto dentro de um bloco de texto: depois da linha [afterLine], [height] px (com as margens);
/// [id] = a nota (ou o abridor); [at] = a âncora no texto canônico do item.
@immutable
final class LaidGap {
  const LaidGap({
    required this.afterLine,
    required this.height,
    required this.id,
    required this.at,
  });

  final int afterLine;
  final double height;
  final String id;
  final int at;

  @override
  bool operator ==(Object other) =>
      other is LaidGap &&
      other.afterLine == afterLine &&
      other.height == height &&
      other.id == id &&
      other.at == at;

  @override
  int get hashCode => Object.hash(afterLine, height, id, at);

  @override
  String toString() => 'LaidGap($afterLine, $height, $id, $at)';
}

/// Um `Paragraph` de um bloco de texto: começa em [textOffset] do texto do bloco; o 1º pedaço de um
/// parágrafo com recuo leva o U+FFFC do `PlaceholderSpan`.
final class LaidPiece {
  LaidPiece(this.paragraph, this.textOffset, {required this.placeholder});

  final ui.Paragraph paragraph;
  final int textOffset;
  final bool placeholder;
}

/// Bloco pronto para paginar e pintar.
sealed class LaidBlock {
  LaidBlock({required this.start, required this.length, required this.source});

  /// Início do bloco no texto canônico do item e o tamanho dele lá.
  final int start;
  final int length;

  final ContentBlock source;

  /// Altura total (já na grade de linhas quando não é texto corrido — D-96).
  double get height;

  /// Abre página antes (`page-break-before` do livro).
  bool get pageBreakBefore => source.style.pageBreakBefore;

  void dispose() {}
}

/// Parágrafo, título, item de lista ou linha pré-formatada.
final class LaidText extends LaidBlock {
  LaidText({
    required super.start,
    required super.length,
    required super.source,
    required this.pieces,
    required this.lines,
    required this.left,
    required this.width,
    required this.extraBottom,
    this.bullet,
    this.bulletCenter = 0,
    this.gaps = const [],
  });

  final List<LaidPiece> pieces;
  final List<LaidLine> lines;

  /// Os espaços abertos no bloco, em ordem (G18). Os `top` das linhas não os contam: o paginador põe a fatia de
  /// cada um entre as linhas.
  final List<LaidGap> gaps;

  /// Recuo da caixa do bloco (citação, lista) e a largura dela.
  final double left;
  final double width;

  /// Espaço depois das linhas (título: o espaço + o arredondamento para a grade).
  final double extraBottom;

  /// Marcador de lista, pintado na margem à esquerda da 1ª linha, centralizado em [bulletCenter] (x na caixa
  /// de conteúdo: o meio do recuo do último nível).
  final ui.Paragraph? bullet;
  final double bulletCenter;

  bool get isHeading => source is HeadingBlock;

  /// Título não se parte entre páginas e não fica sozinho no pé (D-98).
  bool get keepTogether => isHeading;

  @override
  double get height =>
      (lines.isEmpty ? 0 : lines.last.bottom) +
      extraBottom +
      gaps.fold(0.0, (s, g) => s + g.height);

  /// Posição no `Paragraph` do pedaço [piece] → posição no texto canônico do item (desconta o U+FFFC do
  /// recuo). Antes do 1º caractere → o início do bloco.
  int toCanonical(int piece, int inParagraph) {
    final p = pieces[piece];
    final i = inParagraph - (p.placeholder ? 1 : 0);
    return start + p.textOffset + math.max(0, i);
  }

  /// Posição no texto canônico do item → (pedaço, posição no `Paragraph` dele).
  (int, int) toParagraph(int canonical) {
    final inBlock = (canonical - start).clamp(0, length);
    var piece = 0;
    for (var i = 1; i < pieces.length; i++) {
      if (pieces[i].textOffset <= inBlock) piece = i;
    }
    final p = pieces[piece];
    return (piece, inBlock - p.textOffset + (p.placeholder ? 1 : 0));
  }

  /// Linha que contém o caractere canônico [canonical] (o último caractere do bloco fica na última linha).
  int lineAt(int canonical) {
    var lo = 0;
    var hi = lines.length - 1;
    while (lo < hi) {
      final m = (lo + hi + 1) >> 1;
      if (lines[m].start <= canonical) {
        lo = m;
      } else {
        hi = m - 1;
      }
    }
    return lo;
  }

  @override
  void dispose() {
    for (final p in pieces) {
      p.paragraph.dispose();
    }
    bullet?.dispose();
  }
}

/// Imagem escalada para caber, centralizada, numa faixa com um número inteiro de linhas.
final class LaidImage extends LaidBlock {
  LaidImage({
    required super.start,
    required super.source,
    required this.drawWidth,
    required this.drawHeight,
    required this.slotHeight,
    required this.left,
  }) : super(length: 1);

  final double drawWidth;
  final double drawHeight;
  final double slotHeight;

  /// x da imagem na caixa de conteúdo.
  final double left;

  String get path => (source as ImageBlock).path;

  /// y da imagem dentro da faixa (centralizada).
  double get drawTop => (slotHeight - drawHeight) / 2;

  @override
  double get height => slotHeight;
}

/// Troca de cena: uma linha da grade; com o fio ([rule]) entre parágrafos, só o espaço quando a linha do livro é
/// decorativa — colada num título ou no começo/fim do capítulo (D-103). No texto canônico, 1 caractere (D-93).
final class LaidSceneBreak extends LaidBlock {
  LaidSceneBreak({
    required super.start,
    required super.source,
    required this.rule,
    required this.ruleWidth,
    required this.lineHeight,
  }) : super(length: 1);

  final bool rule;
  final double ruleWidth;
  final double lineHeight;

  double get ruleThickness => sceneRuleThickness;

  @override
  double get height => lineHeight;
}

/// Tamanho natural de uma imagem (px), quando conhecido.
typedef ImageSizeOf = ui.Size? Function(ImageBlock image);

/// Monta os blocos de um item na ordem, com as regras de recuo do estilo BookNest (D-96).
final class BlockLayouter {
  BlockLayouter(
    this.t, {
    ImageSizeOf? imageSize,
    this.pieceChars = layoutPieceChars,
  }) : _imageSize = imageSize ?? _attrSize;

  final ReaderTypography t;

  /// Tamanho dos pedaços de parágrafo longo (os testes mudam para comparar com o layout inteiro).
  final int pieceChars;
  final ImageSizeOf _imageSize;

  static ui.Size? _attrSize(ImageBlock i) =>
      i.width != null && i.height != null && i.width! > 0 && i.height! > 0
      ? ui.Size(i.width!.toDouble(), i.height!.toDouble())
      : null;

  /// Todos os blocos do item ([starts] = início de cada um no texto canônico; [cuts] = os espaços abertos — G18).
  List<LaidBlock> layoutAll(
    List<ContentBlock> blocks,
    List<int> starts, {
    List<SpaceCut> cuts = const [],
  }) => [
    for (var i = 0; i < blocks.length; i++)
      layout(
        blocks[i],
        start: starts[i],
        previous: i == 0 ? null : blocks[i - 1],
        next: i + 1 < blocks.length ? blocks[i + 1] : null,
        cuts: cuts,
      ),
  ];

  /// Um bloco. [previous]/[next] = vizinhos no item (decidem o recuo e o espaço depois do título); [cuts] = os
  /// espaços abertos do item (os do bloco partem o parágrafo — G18).
  LaidBlock layout(
    ContentBlock b, {
    required int start,
    ContentBlock? previous,
    ContentBlock? next,
    List<SpaceCut> cuts = const [],
  }) {
    final task = begin(
      b,
      start: start,
      previous: previous,
      next: next,
      cuts: cuts,
    );
    while (!task.step()) {}
    return task.result;
  }

  /// O mesmo, em passos pequenos (um pedaço de parágrafo por passo) para as fatias de tempo.
  BlockLayoutTask begin(
    ContentBlock b, {
    required int start,
    ContentBlock? previous,
    ContentBlock? next,
    List<SpaceCut> cuts = const [],
  }) => switch (b) {
    TextBlock() => _TextTask(
      this,
      b,
      start,
      previous,
      next,
      cutsIn(cuts, start: start, length: b.text.length),
    ),
    ImageBlock() => _DoneTask(_image(b, start)),
    SceneBreakBlock() => _DoneTask(_scene(b, start, previous, next)),
  };

  /// Recuo do parágrafo (D-96): só parágrafo comum alinhado à esquerda; nunca logo depois de título, imagem
  /// ou quebra de cena. Item que começa direto num parágrafo (capítulo partido em vários arquivos) mantém.
  bool indents(TextBlock b, ContentBlock? previous) =>
      b is ParagraphBlock &&
      _align(b.style.align) == ui.TextAlign.left &&
      previous is! HeadingBlock &&
      previous is! ImageBlock &&
      previous is! SceneBreakBlock;

  /// Do livro, só centralizado e à direita (D-96).
  static ui.TextAlign _align(BlockAlign? a) => switch (a) {
    BlockAlign.center => ui.TextAlign.center,
    BlockAlign.right || BlockAlign.end => ui.TextAlign.right,
    _ => ui.TextAlign.left,
  };

  double _insetOf(BlockStyle s) => (s.quoteDepth + s.listDepth) * t.indent;

  /// Arredonda [h] para cima até um número inteiro de linhas do texto corrido (a grade — D-96).
  double toGrid(double h) {
    if (h <= 0) return 0;
    final n = (h / t.lineHeight - 1e-6).ceil();
    return math.max(1, n) * t.lineHeight;
  }

  LaidImage _image(ImageBlock b, int start) {
    final inset = _insetOf(b.style);
    final availW = t.contentWidth - inset;
    final pageLines = (t.contentHeight / t.lineHeight + 1e-6).floor();
    final availH = math.max(1, pageLines) * t.lineHeight;
    final natural = _imageSize(b);
    if (natural == null || natural.width <= 0 || natural.height <= 0) {
      // tamanho desconhecido: a imagem não ocupa espaço (o caractere dela continua no texto)
      return LaidImage(
        start: start,
        source: b,
        drawWidth: 0,
        drawHeight: 0,
        slotHeight: 0,
        left: inset,
      );
    }
    final scale = math.min(
      1.0,
      math.min(availW / natural.width, availH / natural.height),
    );
    final w = natural.width * scale;
    final h = natural.height * scale;
    return LaidImage(
      start: start,
      source: b,
      drawWidth: w,
      drawHeight: h,
      slotHeight: math.min(toGrid(h), availH),
      left: inset + (availW - w) / 2,
    );
  }

  LaidSceneBreak _scene(
    SceneBreakBlock b,
    int start,
    ContentBlock? previous,
    ContentBlock? next,
  ) => LaidSceneBreak(
    start: start,
    source: b,
    // linha do livro colada num título ou no começo/fim do capítulo é decorativa, não troca de cena (D-103)
    rule:
        previous != null &&
        next != null &&
        previous is! HeadingBlock &&
        next is! HeadingBlock,
    ruleWidth: sceneRuleEms * t.fontSize,
    lineHeight: t.lineHeight,
  );

  ui.Paragraph _bullet(double size) {
    final pb =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: ui.TextAlign.left,
              textDirection: ui.TextDirection.ltr,
            ),
          )
          ..pushStyle(t.runStyle(RunStyle.plain, size: size))
          ..addText(listBullet);
    return pb.build()..layout(const ui.ParagraphConstraints(width: 64));
  }
}

/// Layout de um bloco em passos.
sealed class BlockLayoutTask {
  /// Faz mais um pedaço; `true` = terminou.
  bool step();

  /// Caracteres que o próximo [step] monta (o tamanho do trabalho dele; 0 = quase nada).
  int get nextChars;

  /// Descarta o que já foi montado, sem montar mais nada (o job foi descartado no meio do bloco).
  void dispose();

  LaidBlock get result;
}

final class _DoneTask extends BlockLayoutTask {
  _DoneTask(this.result);

  @override
  final LaidBlock result;

  @override
  int get nextChars => 0;

  @override
  bool step() => true;

  @override
  void dispose() => result.dispose();
}

final class _TextTask extends BlockLayoutTask {
  _TextTask(
    this.l,
    this.block,
    this.start,
    this.previous,
    this.next,
    this._cuts,
  ) : text = block.text,
      heading = block is HeadingBlock {
    final t = l.t;
    size = heading
        ? t.fontSize * headingScale((block as HeadingBlock).level)
        : t.fontSize;
    weight = heading ? readerHeadingWeight : readerTextWeight;
    indent = l.indents(block, previous);
    inset = l._insetOf(block.style);
    width = t.contentWidth - inset;
    align = BlockLayouter._align(block.style.align);
    // títulos e quebras manuais longas não são partidos: só parágrafo comum muito longo
    _pieceChars = heading ? 1 << 30 : l.pieceChars;
  }

  final BlockLayouter l;
  final TextBlock block;
  final int start;
  final ContentBlock? previous;
  final ContentBlock? next;
  final String text;
  final bool heading;
  late final double size;
  late final double weight;
  late final bool indent;
  late final double inset;
  late final double width;
  late final ui.TextAlign align;
  late int _pieceChars;

  final List<LaidPiece> _pieces = [];
  final List<LaidLine> _lines = [];

  /// Os espaços do bloco (posição dentro dele) e o próximo a pôr (G18).
  final List<BlockCut> _cuts;
  int _cut = 0;
  final List<LaidGap> _gaps = [];
  int _pos = 0;
  double _y = 0;
  LaidText? _result;

  @override
  LaidText get result => _result!;

  @override
  int get nextChars =>
      _result != null ? 0 : math.min(_pieceChars, text.length - _pos);

  @override
  void dispose() {
    final r = _result;
    if (r != null) {
      r.dispose();
      return;
    }
    for (final p in _pieces) {
      p.paragraph.dispose();
    }
    _pieces.clear();
  }

  static bool _isHighSurrogate(int c) => c >= 0xD800 && c <= 0xDBFF;

  /// O fim do segmento em montagem: o próximo espaço aberto ou o fim do texto (G18).
  int get _segEnd => _cut < _cuts.length ? _cuts[_cut].at : text.length;

  /// O 1º caractere depois do branco que começa em [at] (onde o segmento seguinte começa).
  int _after(int at) {
    var i = at;
    while (i < text.length) {
      final c = text.codeUnitAt(i);
      if (c != 0x20 && c != 0x0A && c != 0x09 && c != 0x2028) break;
      i++;
    }
    return i;
  }

  @override
  bool step() {
    if (_result != null) return true;
    // dois espaços na mesma âncora (ou no branco depois dela — dados de outro aparelho): um embaixo do outro
    while (_cut < _cuts.length && _cuts[_cut].at < _pos) {
      final c = _cuts[_cut++];
      _gaps.add(
        LaidGap(
          afterLine: _lines.length - 1,
          height: c.height,
          id: c.id,
          at: start + c.at,
        ),
      );
    }
    final segEnd = _segEnd;
    var end = _pos + _pieceChars;
    // o pedaço termina num espaço (até 1/4 de pedaço adiante); sem espaço por perto (palavra enorme, texto
    // sem espaços como o chinês), corta onde estiver — sem partir um par substituto
    if (end >= segEnd) {
      end = segEnd;
    } else {
      final limit = math.min(segEnd, end + (_pieceChars >> 2));
      var e = end;
      while (e < limit && text.codeUnitAt(e) != 0x20) {
        e++;
      }
      if (e < limit || e == segEnd) {
        end = e;
      } else if (_isHighSurrogate(text.codeUnitAt(end - 1))) {
        end--;
      }
    }
    final last = end >= segEnd;
    final first = _pos == 0;
    final placeholder = first && indent;
    final p = _build(_pos, end, placeholder: placeholder);
    final metrics = p.computeLineMetrics();
    // descarta a última linha do pedaço (o seguinte recomeça nela): com a quebra gulosa, só ela depende do
    // que vem depois do corte — o pedaço de uma palavra cortada sempre fica nela, coubesse onde coubesse
    final keep = last ? metrics.length : metrics.length - 1;
    if (!last && keep < 1) {
      // uma "palavra" maior que o pedaço: o resto vai inteiro neste
      p.dispose();
      _pieceChars = 1 << 30;
      return false;
    }
    final pieceIndex = _pieces.length;
    _pieces.add(LaidPiece(p, _pos, placeholder: placeholder));
    final starts = <int>[
      for (var i = 0; i < metrics.length; i++)
        _lineStart(p, i, end - _pos + (placeholder ? 1 : 0)),
    ];
    int canonical(int inParagraph) =>
        start + _pos + math.max(0, inParagraph - (placeholder ? 1 : 0));
    for (var i = 0; i < keep; i++) {
      final m = metrics[i];
      final h = m.ascent + m.descent;
      final s = canonical(starts[i]);
      // a última linha do segmento vai até o começo do seguinte (com o branco, como toda linha)
      final e = i + 1 < metrics.length
          ? canonical(starts[i + 1])
          : start + (segEnd == text.length ? text.length : _after(segEnd));
      _lines.add(
        LaidLine(
          top: _y,
          height: h,
          ascent: m.ascent,
          start: i == 0 && first ? start : s,
          end: e,
          piece: pieceIndex,
          pieceBaseline: glyphBaselineOf(m),
        ),
      );
      _y += h;
    }
    if (!last) {
      // o próximo pedaço recomeça no início da 1ª linha descartada aqui
      _pos += starts[keep] - (placeholder ? 1 : 0);
      return false;
    }
    if (_cut < _cuts.length) {
      final c = _cuts[_cut++];
      _gaps.add(
        LaidGap(
          afterLine: _lines.length - 1,
          height: c.height,
          id: c.id,
          at: start + c.at,
        ),
      );
      final next = _after(c.at);
      if (next < text.length) {
        // o segmento seguinte: sem recuo (`_pos > 0`)
        _pos = next;
        return false;
      }
      // no fim do parágrafo: os outros espaços dali (dados de outro aparelho), um embaixo do outro
      while (_cut < _cuts.length) {
        final d = _cuts[_cut++];
        _gaps.add(
          LaidGap(
            afterLine: _lines.length - 1,
            height: d.height,
            id: d.id,
            at: start + d.at,
          ),
        );
      }
    }
    _finish();
    return true;
  }

  void _finish() {
    final t = l.t;
    double extra = 0;
    if (heading) {
      // uma linha de espaço depois (se o seguinte não for outro título) e o todo na grade (D-96/D-98)
      final after = next is HeadingBlock ? 0.0 : t.lineHeight;
      extra = l.toGrid(_y + after) - _y;
    }
    _result = LaidText(
      start: start,
      length: text.length,
      source: block,
      pieces: List.unmodifiable(_pieces),
      lines: List.unmodifiable(_lines),
      left: inset,
      width: width,
      extraBottom: extra,
      bullet: block is ListItemBlock ? l._bullet(size) : null,
      bulletCenter: inset - t.indent / 2,
      gaps: List.unmodifiable(_gaps),
    );
  }

  ui.Paragraph _build(int from, int to, {required bool placeholder}) {
    final t = l.t;
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: align, textDirection: ui.TextDirection.ltr),
    );
    if (placeholder) {
      pb
        ..pushStyle(t.runStyle(RunStyle.plain, size: size, weight: weight))
        ..addPlaceholder(
          t.indent,
          0,
          ui.PlaceholderAlignment.baseline,
          baseline: ui.TextBaseline.alphabetic,
        )
        ..pop();
    }
    var at = 0;
    for (final r in block.runs) {
      final rs = at;
      final re = at + r.text.length;
      at = re;
      final a = math.max(rs, from);
      final b = math.min(re, to);
      if (a >= b) continue;
      pb
        ..pushStyle(
          t.runStyle(r.style, size: size, weight: weight, link: r.link != null),
        )
        ..addText(r.text.substring(a - rs, b - rs))
        ..pop();
    }
    return pb.build()..layout(ui.ParagraphConstraints(width: width));
  }

  /// Primeira posição (no `Paragraph`) da linha [line]: busca binária em `getLineNumberAt`.
  static int _lineStart(ui.Paragraph p, int line, int length) {
    if (line == 0) return 0;
    var lo = 0;
    var hi = length;
    while (lo < hi) {
      final m = (lo + hi) >> 1;
      if ((p.getLineNumberAt(m) ?? 1 << 30) < line) {
        lo = m + 1;
      } else {
        hi = m;
      }
    }
    return lo;
  }
}

/// Pinta as linhas [first]…[last] de [b] com o topo da linha [first] em [top] (coordenadas do canvas) e a
/// caixa de conteúdo começando em [left]. Cada linha é recortada na própria faixa exata (ADR-005).
void paintTextLines(
  ui.Canvas c,
  LaidText b,
  int first,
  int last, {
  required double left,
  required double top,
}) {
  final base = top - b.lines[first].top;
  final x = left + b.left;
  for (var i = first; i <= last; i++) {
    final line = b.lines[i];
    final p = b.pieces[line.piece].paragraph;
    final lineTop = base + line.top;
    final dy = base + line.baseline - line.pieceBaseline;
    c
      ..save()
      ..clipRect(
        ui.Rect.fromLTRB(
          x - 64,
          lineTop,
          x + b.width + 64,
          lineTop + line.height,
        ),
      )
      ..drawParagraph(p, ui.Offset(x, dy))
      ..restore();
    if (i == 0 && b.bullet != null) {
      // o "•" pela mesma baseline dos glifos das letras (T01, R1)
      final bp = b.bullet!;
      final bl = bp.computeLineMetrics().first;
      c.drawParagraph(
        bp,
        ui.Offset(
          left + b.bulletCenter - bp.maxIntrinsicWidth / 2,
          base + line.baseline - glyphBaselineOf(bl),
        ),
      );
    }
  }
}

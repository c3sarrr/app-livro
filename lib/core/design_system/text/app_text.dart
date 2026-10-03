import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Quebra de linha do parágrafo (CSS `text-wrap`).
/// - [wrap]: quebrador guloso (padrão do CSS e do SkParagraph).
/// - [pretty]: `text-wrap: pretty` do Chromium — evita a "viúva" (última linha com UMA palavra só)
///   reequilibrando as últimas 4 linhas pelo critério de mínimos quadrados da folga (Knuth-Plass),
///   mantendo o número de linhas. Só age quando o guloso deixa a viúva; caso contrário é igual a [wrap].
///   Reproduz o arquivo em 360 px ("Faltam 12 min / para fechar a meta / de hoje.").
enum AppTextWrap { wrap, pretty }

typedef AppTextLine = ({
  String text,
  double left,
  double right,
  double baseline,
});

/// Texto do design system: largura/altura/baseline EXATAS (sem arredondar), `maxLines` + "…",
/// alinhamento, semântica e correção do deslocamento de meio letter-spacing do SkParagraph.
/// Regras de tamanho = CSS:
/// - largura "tight" imposta → usa-a;
/// - senão: min(largura disponível, largura intrínseca máxima) (shrink-to-fit de item flex);
/// - altura = soma exata das linhas (height × fontSize por linha, distribuição "even").
///
/// Duas correções do SkParagraph deste SDK (Skia 8df24be6, `modules/skparagraph/src`), ambas
/// marcadas no código do Skia como mudanças "for flutter":
/// - `InternalLineMetrics::height()` (Run.h) ARREDONDA a altura de cada linha para pixel inteiro, e
///   as linhas seguintes são posicionadas pela soma dessas alturas arredondadas. Por isso
///   `ui.Paragraph.height` e `LineMetrics.baseline` não servem: a altura exata de cada linha é
///   `ascent + descent` (com a distribuição "even" o leading da linha é 0) e a baseline exata dentro
///   da linha é `ascent`;
/// - `TextLine::buildTextBlob` (TextLine.cpp) pinta os glifos em `floor(baseline + 0,5)`, isto é, na
///   baseline arredondada ao pixel lógico inteiro. O deslocamento passado ao `drawParagraph` não é
///   arredondado, então cada linha é pintada com o deslocamento que devolve a baseline exata do CSS.
///   Um parágrafo de várias linhas é pintado linha a linha (um `ui.Paragraph` de linha única por
///   linha, com o mesmo estilo e a mesma largura), porque cada linha tem um erro próprio.
class AppText extends LeafRenderObjectWidget {
  AppText(
    String text, {
    super.key,
    required TextStyle style,
    this.maxLines,
    this.ellipsis = false,
    this.textAlign = TextAlign.start,
    this.semanticsLabel,
    this.textWrap = AppTextWrap.wrap,
  }) : span = TextSpan(text: text, style: style);

  const AppText.rich(
    this.span, {
    super.key,
    this.maxLines,
    this.ellipsis = false,
    this.textAlign = TextAlign.start,
    this.semanticsLabel,
    this.textWrap = AppTextWrap.wrap,
  });

  final InlineSpan span;
  final int? maxLines;
  final bool ellipsis;
  final TextAlign textAlign;
  final String? semanticsLabel;
  final AppTextWrap textWrap;

  @override
  RenderAppText createRenderObject(BuildContext context) => RenderAppText(
    span: span,
    maxLines: maxLines,
    ellipsis: ellipsis,
    textAlign: textAlign,
    textDirection: Directionality.of(context),
    semanticsLabel: semanticsLabel,
    textWrap: textWrap,
  );

  @override
  void updateRenderObject(BuildContext context, RenderAppText renderObject) {
    renderObject
      ..span = span
      ..maxLines = maxLines
      ..ellipsis = ellipsis
      ..textAlign = textAlign
      ..textDirection = Directionality.of(context)
      ..semanticsLabel = semanticsLabel
      ..textWrap = textWrap;
  }
}

/// Uma linha pronta para pintar: o parágrafo (o principal quando `paragraph == null`) e o
/// deslocamento que põe os glifos na posição exata do CSS.
class _PaintedLine {
  const _PaintedLine(this.paragraph, this.offset);
  final ui.Paragraph? paragraph;
  final Offset offset;
}

class RenderAppText extends RenderBox {
  RenderAppText({
    required this._span,
    this._maxLines,
    this._ellipsis = false,
    this._textAlign = TextAlign.start,
    required this._textDirection,
    this._semanticsLabel,
    this._textWrap = AppTextWrap.wrap,
  });

  static const TextHeightBehavior _heightBehavior = TextHeightBehavior(
    leadingDistribution: TextLeadingDistribution.even,
  );

  InlineSpan _span;
  set span(InlineSpan v) {
    if (v == _span) return;
    _span = v;
    _invalidate();
    markNeedsSemanticsUpdate();
  }

  int? _maxLines;
  set maxLines(int? v) {
    if (v == _maxLines) return;
    _maxLines = v;
    _invalidate();
  }

  bool _ellipsis;
  set ellipsis(bool v) {
    if (v == _ellipsis) return;
    _ellipsis = v;
    _invalidate();
  }

  TextAlign _textAlign;
  set textAlign(TextAlign v) {
    if (v == _textAlign) return;
    _textAlign = v;
    _invalidate();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    _invalidate();
  }

  String? _semanticsLabel;
  set semanticsLabel(String? v) {
    if (v == _semanticsLabel) return;
    _semanticsLabel = v;
    markNeedsSemanticsUpdate();
  }

  AppTextWrap _textWrap;
  set textWrap(AppTextWrap v) {
    if (v == _textWrap) return;
    _textWrap = v;
    _invalidate();
  }

  // Cache do `text-wrap: pretty` para UMA largura: o span com as quebras forçadas ("\n" depois do
  // espaço da quebra) e o parágrafo correspondente. Null = o guloso já serve nessa largura.
  double _prettyWidth = double.nan;
  InlineSpan? _prettySpan;
  ui.Paragraph? _prettyParagraph;

  ui.Paragraph? _paragraph;
  double _laidOutWidth = double.nan;
  double _paintWidth = double.nan; // largura de layout escolhida em performLayout (paint/baseline sempre usam esta)

  /// Plano de pintura da largura final (calculado em performLayout).
  List<_PaintedLine> _painted = const <_PaintedLine>[];

  void _invalidate() {
    _paragraph?.dispose();
    _paragraph = null;
    _laidOutWidth = double.nan;
    _clearPretty();
    _disposePainted();
    markNeedsLayout();
  }

  void _clearPretty() {
    _prettyParagraph?.dispose();
    _prettyParagraph = null;
    _prettySpan = null;
    _prettyWidth = double.nan;
  }

  void _disposePainted() {
    for (final line in _painted) {
      line.paragraph?.dispose();
    }
    _painted = const <_PaintedLine>[];
  }

  ui.ParagraphBuilder _newBuilder({
    required int? maxLines,
    required bool ellipsis,
  }) {
    final root = _span.style ?? const TextStyle();
    return ui.ParagraphBuilder(
      root.getParagraphStyle(
        textAlign: _textAlign,
        textDirection: _textDirection,
        maxLines: maxLines,
        ellipsis: ellipsis ? '…' : null,
        textHeightBehavior: _heightBehavior,
      ),
    );
  }

  ui.Paragraph _layoutAt(double width) {
    if (_paragraph == null) {
      final builder = _newBuilder(maxLines: _maxLines, ellipsis: _ellipsis);
      _span.build(builder);
      _paragraph = builder.build();
      _laidOutWidth = double.nan;
    }
    if (_laidOutWidth != width) {
      _paragraph!.layout(ui.ParagraphConstraints(width: width));
      _laidOutWidth = width;
    }
    return _paragraph!;
  }

  /// Parágrafo FINAL na largura dada: o guloso ([_layoutAt]) ou, com [AppTextWrap.pretty], o
  /// reequilibrado (quando o guloso deixa uma viúva).
  ui.Paragraph _finalAt(double width) {
    if (_textWrap == AppTextWrap.wrap || !width.isFinite) {
      return _layoutAt(width);
    }
    if (_prettyWidth != width) {
      _clearPretty();
      _prettyWidth = width;
      final breaks = _prettyBreaks(width);
      if (breaks != null) {
        _prettySpan = _withBreaks(_span, breaks, 0).$1;
        final builder = _newBuilder(maxLines: _maxLines, ellipsis: _ellipsis);
        _prettySpan!.build(builder);
        _prettyParagraph = builder.build()
          ..layout(ui.ParagraphConstraints(width: width));
      }
    }
    return _prettyParagraph ?? _layoutAt(width);
  }

  /// Span efetivamente diagramado na largura dada (com as quebras do `pretty`, se houver).
  InlineSpan _spanAt(double width) {
    _finalAt(width);
    return _prettySpan ?? _span;
  }

  /// Quebras do `text-wrap: pretty` (offsets onde cada linha nova começa, no texto puro), ou null se o
  /// guloso não deixa viúva / não há alternativa melhor.
  Set<int>? _prettyBreaks(double width) {
    final text = _span.toPlainText(includeSemanticsLabels: false);
    if (text.contains('\n')) return null;
    final greedy = _layoutAt(width);
    final n = greedy.computeLineMetrics().length;
    if (n < 2) return null;
    final ranges = _lineRanges(greedy, text, n);
    final lastLine = text
        .substring(ranges[n - 1].start, ranges[n - 1].end)
        .trim();
    // sem viúva: o pretty do Chromium mantém o guloso
    if (lastLine.contains(' ')) return null;
    final first = math.max(0, n - 4); // janela: as últimas 4 linhas
    final start = ranges[first].start;
    final end = text.length;
    final linesInWindow = n - first;

    // Larguras medidas numa linha única infinita (mesma modelagem de glifos do parágrafo).
    final builder = _newBuilder(maxLines: null, ellipsis: false);
    _span.build(builder);
    final measure = builder.build()
      ..layout(const ui.ParagraphConstraints(width: double.infinity));
    double widthOf(int a, int b) {
      var e = b;
      while (e > a && text[e - 1] == ' ') {
        e--;
      }
      if (e <= a) return 0;
      final boxes = measure.getBoxesForRange(a, e);
      if (boxes.isEmpty) return 0;
      return boxes.map((x) => x.right).reduce(math.max) -
          boxes.map((x) => x.left).reduce(math.min);
    }

    final points = <int>[
      start,
      for (var i = start + 1; i < end; i++)
        if (text[i - 1] == ' ' && text[i] != ' ') i,
    ];
    final memo = <(int, int), (double, List<int>)?>{};
    // Melhor divisão de text[points[i]..end) em `left` linhas: (pontuação, inícios das linhas seguintes).
    (double, List<int>)? best(int i, int left) {
      final key = (i, left);
      if (memo.containsKey(key)) return memo[key];
      (double, List<int>)? result;
      final a = points[i];
      if (left == 1) {
        final w = widthOf(a, end);
        final words = text.substring(a, end).trim();
        if (w <= width + 1e-6 && words.contains(' ')) result = (0.0, <int>[]);
      } else {
        for (var j = i + 1; j < points.length; j++) {
          final w = widthOf(a, points[j]);
          if (w > width + 1e-6) break;
          final rest = best(j, left - 1);
          if (rest == null) continue;
          final score = (width - w) * (width - w) + rest.$1;
          if (result == null || score < result.$1) {
            result = (score, <int>[points[j], ...rest.$2]);
          }
        }
      }
      memo[key] = result;
      return result;
    }

    final solution = best(0, linesInWindow);
    measure.dispose();
    if (solution == null) return null;
    final greedyBreaks = {for (var l = first + 1; l < n; l++) ranges[l].start};
    final chosen = solution.$2.toSet();
    if (chosen.length == greedyBreaks.length &&
        chosen.containsAll(greedyBreaks)) {
      return null;
    }
    return {
      for (var l = 1; l <= first; l++)
        ranges[l].start, // linhas antes da janela: iguais ao guloso
      ...chosen,
    };
  }

  /// Copia [span] inserindo "\n" antes dos offsets [breaks] (texto puro). Devolve (span, offset final).
  static (InlineSpan, int) _withBreaks(
    InlineSpan span,
    Set<int> breaks,
    int offset,
  ) {
    if (span is! TextSpan) {
      throw FlutterError(
        'AppText só aceita TextSpan (recebeu ${span.runtimeType}).',
      );
    }
    String? text = span.text;
    if (text != null) {
      final out = StringBuffer();
      for (var i = 0; i < text.length; i++) {
        if (breaks.contains(offset + i) && i + offset > 0) out.write('\n');
        out.write(text[i]);
      }
      offset += text.length;
      text = out.toString();
    }
    final children = <InlineSpan>[];
    for (final child in span.children ?? const <InlineSpan>[]) {
      final (copy, next) = _withBreaks(child, breaks, offset);
      children.add(copy);
      offset = next;
    }
    return (
      TextSpan(
        text: text,
        style: span.style,
        children: span.children == null ? null : children,
        semanticsLabel: span.semanticsLabel,
        locale: span.locale,
        spellOut: span.spellOut,
      ),
      offset,
    );
  }

  /// Altura exata (CSS) do parágrafo diagramado: soma de `ascent + descent` de cada linha
  /// (`ui.Paragraph.height` soma as alturas arredondadas pelo SkParagraph).
  static double _exactHeight(ui.Paragraph p) {
    var height = 0.0;
    for (final line in p.computeLineMetrics()) {
      height += line.ascent + line.descent;
    }
    return height;
  }

  /// Deslocamento vertical que leva os glifos da baseline arredondada pelo SkParagraph
  /// (`floor(baseline + 0,5)`) para a baseline exata (`ascent` da linha).
  static double _baselineFix(double ascent) =>
      ascent - (ascent + 0.5).floorToDouble();

  /// Largura em que o parágrafo deve ser diagramado para as restrições dadas.
  double _layoutWidthFor(BoxConstraints c) {
    final natural = _layoutAt(double.infinity).maxIntrinsicWidth;
    if (c.hasTightWidth) return c.maxWidth;
    // +0,001 evita que o quebrador de linha quebre por arredondamento quando a largura == intrínseca.
    return natural <= c.maxWidth ? natural + 0.001 : c.maxWidth;
  }

  Size _sizeFor(BoxConstraints c) {
    final natural = _layoutAt(double.infinity).maxIntrinsicWidth;
    final width = c.hasTightWidth ? c.maxWidth : math.min(c.maxWidth, natural);
    final p = _finalAt(_layoutWidthFor(c));
    return c.constrain(Size(width, _exactHeight(p)));
  }

  /// Parágrafo diagramado na largura final (reexecuta o layout do ui.Paragraph se uma medição intrínseca/seca
  /// posterior o tiver diagramado em outra largura).
  ui.Paragraph get _final => _finalAt(_paintWidth);

  bool get _isStartAligned =>
      _textAlign == TextAlign.left ||
      (_textAlign == TextAlign.start && _textDirection == TextDirection.ltr) ||
      _textAlign == TextAlign.justify;

  /// Deslocamento que desfaz o "meio letter-spacing" do SkParagraph em linhas alinhadas à esquerda.
  double get _dx {
    if (!_isStartAligned) return 0;
    final lines = _final.computeLineMetrics();
    if (lines.isEmpty) return 0;
    assert(
      lines.every((l) => (l.left - lines.first.left).abs() < 0.01),
      'Linhas com letter-spacing inicial diferente: divida em vários AppText (um por linha).',
    );
    return -lines.first.left;
  }

  /// Intervalo [start, end) de cada linha visível no texto puro (sem as quebras "\n").
  static List<({int start, int end})> _lineRanges(
    ui.Paragraph p,
    String text,
    int lineCount,
  ) {
    final starts = List<int?>.filled(lineCount, null);
    final ends = List<int>.filled(lineCount, 0);
    for (var i = 0; i < text.length; i++) {
      if (text[i] == '\n') continue;
      final line = p.getLineNumberAt(i);
      if (line == null || line >= lineCount) continue;
      starts[line] ??= i;
      ends[line] = i + 1;
    }
    return [
      for (var l = 0; l < lineCount; l++)
        (start: starts[l] ?? ends[l], end: ends[l]),
    ];
  }

  /// Escreve no builder o trecho [start, end) do texto puro de [span], preservando os estilos aninhados
  /// (mesma travessia de `TextSpan.build`). Devolve o deslocamento após [span].
  static int _addRange(
    ui.ParagraphBuilder builder,
    InlineSpan span,
    int start,
    int end,
    int offset,
  ) {
    if (span is! TextSpan) {
      throw FlutterError(
        'AppText só aceita TextSpan (recebeu ${span.runtimeType}).',
      );
    }
    final style = span.style;
    if (style != null) builder.pushStyle(style.getTextStyle());
    final text = span.text;
    if (text != null) {
      final s = math.max(start, offset);
      final e = math.min(end, offset + text.length);
      if (s < e) builder.addText(text.substring(s - offset, e - offset));
      offset += text.length;
    }
    for (final child in span.children ?? const <InlineSpan>[]) {
      offset = _addRange(builder, child, start, end, offset);
    }
    if (style != null) builder.pop();
    return offset;
  }

  /// Plano de pintura na largura final: linha única → o parágrafo principal com a baseline corrigida;
  /// várias linhas → um parágrafo de linha única por linha, cada um na posição exata do CSS.
  void _buildPaintPlan() {
    _disposePainted();
    final p = _finalAt(_paintWidth);
    final span = _spanAt(_paintWidth);
    final lines = p.computeLineMetrics();
    if (lines.isEmpty) return;
    final start = _isStartAligned;
    if (lines.length == 1) {
      final line = lines.single;
      _painted = [
        _PaintedLine(
          null,
          Offset(start ? -line.left : 0, _baselineFix(line.ascent)),
        ),
      ];
      return;
    }
    assert(
      !start || lines.every((l) => (l.left - lines.first.left).abs() < 0.01),
      'Linhas com letter-spacing inicial diferente: divida em vários AppText (um por linha).',
    );
    assert(
      _textAlign != TextAlign.justify,
      'AppText: justify com várias linhas não é suportado.',
    );
    final text = span.toPlainText(includeSemanticsLabels: false);
    final ranges = _lineRanges(p, text, lines.length);
    final ellipsizeLast = _ellipsis && p.didExceedMaxLines;
    final painted = <_PaintedLine>[];
    var top = 0.0;
    for (var i = 0; i < lines.length; i++) {
      final last = ellipsizeLast && i == lines.length - 1;
      final range = ranges[i];
      final end = last ? text.length : range.end;
      if (range.start < end) {
        final builder = _newBuilder(maxLines: last ? 1 : null, ellipsis: last);
        _addRange(builder, span, range.start, end, 0);
        final lineParagraph = builder.build()
          ..layout(ui.ParagraphConstraints(width: _paintWidth));
        final metrics = lineParagraph.computeLineMetrics();
        assert(
          metrics.length == 1 &&
              (metrics.single.left - lines[i].left).abs() < 0.01 &&
              (metrics.single.ascent - lines[i].ascent).abs() < 0.001 &&
              (metrics.single.descent - lines[i].descent).abs() < 0.001,
          'AppText: a linha ${i + 1} diagramada sozinha diverge do parágrafo completo.',
        );
        painted.add(
          _PaintedLine(
            lineParagraph,
            Offset(
              start ? -metrics.single.left : 0,
              top + _baselineFix(metrics.single.ascent),
            ),
          ),
        );
      }
      top += lines[i].ascent + lines[i].descent;
    }
    _painted = painted;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      _layoutAt(double.infinity).minIntrinsicWidth;
  @override
  double computeMaxIntrinsicWidth(double height) =>
      _layoutAt(double.infinity).maxIntrinsicWidth;
  @override
  double computeMinIntrinsicHeight(double width) =>
      _exactHeight(_finalAt(width));
  @override
  double computeMaxIntrinsicHeight(double width) =>
      _exactHeight(_finalAt(width));
  @override
  Size computeDryLayout(BoxConstraints constraints) => _sizeFor(constraints);

  @override
  void performLayout() {
    size = _sizeFor(constraints);
    _paintWidth = _layoutWidthFor(constraints);
    _buildPaintPlan();
  }

  // Necessário para Row/Flex com CrossAxisAlignment.baseline em layout "seco" (Flutter ≥ 3.22).
  // `alphabeticBaseline` do ui.Paragraph é exato (ascent da 1ª linha; não passa pelo arredondamento).
  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final p = _finalAt(_layoutWidthFor(constraints));
    return baseline == TextBaseline.alphabetic
        ? p.alphabeticBaseline
        : p.ideographicBaseline;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    final p = _final;
    return baseline == TextBaseline.alphabetic
        ? p.alphabeticBaseline
        : p.ideographicBaseline;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    for (final line in _painted) {
      context.canvas.drawParagraph(
        line.paragraph ?? _final,
        offset + line.offset,
      );
    }
  }

  // Igual ao RenderParagraph: NÃO é fronteira semântica. Sob um nó sem explicitChildNodes (link, cabeçalho)
  // o rótulo se funde nele; sob uma seção (explicitChildNodes: true) um AppText solto vira um nó de texto
  // próprio — exatamente como o Text do Flutter.
  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..label = _semanticsLabel ?? _span.toPlainText()
      ..textDirection = _textDirection;
  }

  @visibleForTesting
  bool get debugDidExceedMaxLines => _final.didExceedMaxLines;

  /// Linhas visíveis em coordenadas GLOBAIS (já com a correção _dx): texto (sem espaços finais), início, fim, baseline.
  /// A baseline é a EXATA (topo da linha = soma das alturas exatas das linhas anteriores + ascent), que é onde
  /// [paint] coloca os glifos.
  @visibleForTesting
  List<AppTextLine> debugLines() {
    final p = _final;
    final dx = _dx;
    final text = _spanAt(_paintWidth)
        .toPlainText(includeSemanticsLabels: false);
    final metrics = p.computeLineMetrics();
    final buffers = List.generate(metrics.length, (_) => StringBuffer());
    final starts = List<int?>.filled(metrics.length, null);
    for (var i = 0; i < text.length; i++) {
      final line = p.getLineNumberAt(i);
      if (line == null) continue;
      buffers[line].write(text[i]);
      starts[line] ??= i;
    }
    final origin = localToGlobal(Offset.zero);
    final out = <AppTextLine>[];
    var top = 0.0;
    for (var l = 0; l < metrics.length; l++) {
      final visible = buffers[l].toString().replaceAll('\n', '').trimRight();
      final s = starts[l] ?? 0;
      final boxes = p.getBoxesForRange(s, s + visible.length);
      final left = boxes.isEmpty
          ? metrics[l].left
          : boxes.map((b) => b.left).reduce(math.min);
      final right = boxes.isEmpty
          ? metrics[l].left + metrics[l].width
          : boxes.map((b) => b.right).reduce(math.max);
      out.add((
        text: visible,
        left: origin.dx + dx + left,
        right: origin.dx + dx + right,
        baseline: origin.dy + top + metrics[l].ascent,
      ));
      top += metrics[l].ascent + metrics[l].descent;
    }
    return out;
  }

  @override
  void dispose() {
    _paragraph?.dispose();
    _clearPretty();
    _disposePainted();
    super.dispose();
  }
}

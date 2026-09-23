import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

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
  }) : span = TextSpan(text: text, style: style);

  const AppText.rich(
    this.span, {
    super.key,
    this.maxLines,
    this.ellipsis = false,
    this.textAlign = TextAlign.start,
    this.semanticsLabel,
  });

  final InlineSpan span;
  final int? maxLines;
  final bool ellipsis;
  final TextAlign textAlign;
  final String? semanticsLabel;

  @override
  RenderAppText createRenderObject(BuildContext context) => RenderAppText(
    span: span,
    maxLines: maxLines,
    ellipsis: ellipsis,
    textAlign: textAlign,
    textDirection: Directionality.of(context),
    semanticsLabel: semanticsLabel,
  );

  @override
  void updateRenderObject(BuildContext context, RenderAppText renderObject) {
    renderObject
      ..span = span
      ..maxLines = maxLines
      ..ellipsis = ellipsis
      ..textAlign = textAlign
      ..textDirection = Directionality.of(context)
      ..semanticsLabel = semanticsLabel;
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

  ui.Paragraph? _paragraph;
  double _laidOutWidth = double.nan;
  double _paintWidth = double.nan; // largura de layout escolhida em performLayout (paint/baseline sempre usam esta)

  /// Plano de pintura da largura final (calculado em performLayout).
  List<_PaintedLine> _painted = const <_PaintedLine>[];

  void _invalidate() {
    _paragraph?.dispose();
    _paragraph = null;
    _laidOutWidth = double.nan;
    _disposePainted();
    markNeedsLayout();
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
    final p = _layoutAt(_layoutWidthFor(c));
    return c.constrain(Size(width, _exactHeight(p)));
  }

  /// Parágrafo diagramado na largura final (reexecuta o layout do ui.Paragraph se uma medição intrínseca/seca
  /// posterior o tiver diagramado em outra largura).
  ui.Paragraph get _final => _layoutAt(_paintWidth);

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
    final p = _layoutAt(_paintWidth);
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
    final text = _span.toPlainText(includeSemanticsLabels: false);
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
        _addRange(builder, _span, range.start, end, 0);
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
      _exactHeight(_layoutAt(width));
  @override
  double computeMaxIntrinsicHeight(double width) =>
      _exactHeight(_layoutAt(width));
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
    final p = _layoutAt(_layoutWidthFor(constraints));
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
    final text = _span.toPlainText(includeSemanticsLabels: false);
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
    _disposePainted();
    super.dispose();
  }
}

// G17.5 — o painel do marca-texto (tela 23b, L23b.1–L23b.5), por dentro da moldura (`ToolPanelLayer`, seta em 95):
// - o subtítulo (R15): o estilo · a cor e o rótulo entre aspas curvas (ou só a cor) · a altura em minúsculas (só no
//   Fundo);
// - a prévia (R16, D-171): a frase da página em Literata 17, centrada, com o grifo nítido do arquivo na palavra mais
//   longa da 1ª frase — o fundo de 14 a 92 % a 95 % na Média (Baixa e Alta pela D-172), o sublinhado de 4 px a 3 px
//   da base ou o ondulado (R25);
// - ESTILO: 3 cartões de 66 com "ressaca" no estilo e na cor atuais (Literata 16); o ativo com a `brand` e a sombra
//   2/2;
// - CORES E RÓTULOS (R17, D-40): as 4 cores em 2 colunas, linhas de 50, com o rótulo (ou o nome da cor) e "N grifos"
//   de todos os livros mais o saldo da sessão; a marcada com a borda de tinta e o aro duplo; "Editar rótulos" abre a
//   folha (D-177);
// - ALTURA: a pílula de 44 com Baixa/Média/Alta e as amostras de 6, 11 e 16; fora do Fundo, a 0,38 e "indisponível"
//   (R18);
// - a dica tracejada (1,3 `#8A7F63`) com o desenho do arquivo e "Gruda nas palavras." em negrito.
import 'package:flutter/widgets.dart';

import '../../../core/design_system/color/color_names.dart';
import '../../../core/design_system/painters/dashed_stadium_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_illustrations_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../annotations/domain/annotation.dart' show FillHeight, HighlightStyle;
import '../annotations/domain/highlight_band.dart';
import '../annotations/domain/pen_presets.dart';
import '../annotations/ink/ink_stroke.dart' show argbOfHex;
import '../annotations/marker_preview.dart';
import '../application/annotation_session.dart';
import 'reader_chrome_scope.dart';
import 'tool_panel_frame.dart';
import 'wavy_underline.dart';

/// O texto do item e o trecho mostrado na página, para a prévia (D-171); `null` = a frase do arquivo.
typedef MarkerPreviewSource = ({String text, int start, int end});

const Map<HighlightStyle, String> highlightStyleNames = {
  HighlightStyle.fill: 'Fundo',
  HighlightStyle.underline: 'Sublinhado',
  HighlightStyle.wavy: 'Ondulado',
};

const Map<FillHeight, String> fillHeightNames = {
  FillHeight.low: 'Baixa',
  FillHeight.medium: 'Média',
  FillHeight.high: 'Alta',
};

/// As chaves das 4 cores (os ids do arquivo).
const Map<String, String> _colorIds = {
  '#FED170': 'yellow',
  '#FFC1C6': 'pink',
  '#ABCF82': 'green',
  '#B6ACE4': 'lavender',
};

/// A prévia: 14 de cada lado, dentro da borda de 1,5.
const double _previewPadding = 14;

/// O grifo nítido da prévia e das amostras vai a 95 %.
const double _sampleAlpha = 0.95;

/// O rótulo de [hex] em [labels] (sem os espaços das pontas); vazio = sem rótulo.
String _labelOf(Map<String, String> labels, String hex) =>
    (labels[hex.toUpperCase()] ?? '').trim();

/// "Fundo · amarelo “lindo” · média" (R15).
String markerPanelSubtitle(PenPresets p, Map<String, String> labels) {
  final hex = p.highlighterColor.toUpperCase();
  final name = colorNameOf(hex) ?? hex;
  final label = _labelOf(labels, hex);
  return [
    highlightStyleNames[p.highlighterStyle]!,
    if (label.isEmpty) name else '$name “$label”',
    if (p.highlighterStyle == HighlightStyle.fill)
      fillHeightNames[p.highlighterHeight]!.toLowerCase(),
  ].join(' · ');
}

/// "1 grifo", "5 grifos".
String highlightCountLabel(int n) => n == 1 ? '1 grifo' : '$n grifos';

/// O grifo nítido de uma palavra (a prévia e as amostras): o fundo na faixa da altura (a 95 %, raio 3), o sublinhado
/// de 4 px a 3 px da base ou o ondulado, na caixa da palavra (a altura da letra), com a base em [baseline].
class MarkerSamplePainter extends CustomPainter {
  const MarkerSamplePainter({
    required this.color,
    required this.style,
    required this.band,
    required this.baseline,
  });

  final Color color;
  final HighlightStyle style;

  /// O topo e a base do fundo, em frações da altura da letra.
  final (double, double) band;
  final double baseline;

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case HighlightStyle.fill:
        canvas
          ..save()
          ..clipRect(
            Rect.fromLTRB(
              0,
              band.$1 * size.height,
              size.width,
              band.$2 * size.height,
            ),
          )
          ..drawRRect(
            RRect.fromRectAndRadius(
              Offset.zero & size,
              const Radius.circular(3),
            ),
            Paint()..color = color.withValues(alpha: color.a * _sampleAlpha),
          )
          ..restore();
      case HighlightStyle.underline:
        canvas.drawRect(
          Rect.fromLTWH(0, baseline + 3, size.width, 4),
          Paint()..color = color,
        );
      case HighlightStyle.wavy:
        paintWavyUnderline(canvas, 0, size.width, baseline, color);
    }
  }

  @override
  bool shouldRepaint(MarkerSamplePainter old) =>
      old.color != color ||
      old.style != style ||
      old.band != band ||
      old.baseline != baseline;
}

/// Uma linha de texto com o grifo nítido em [from]…[to): o grifo por trás das letras, na caixa da palavra (a altura
/// da letra, centrada na linha). [expand] = a linha ocupa a largura toda (a prévia, centrada); senão, a do texto.
class _MarkedLine extends StatelessWidget {
  const _MarkedLine({
    required this.text,
    required this.from,
    required this.to,
    required this.style,
    required this.color,
    required this.highlight,
    required this.band,
    required this.wordKey,
    this.textKey,
    this.expand = false,
    this.wordColor,
  });

  final String text;
  final int from;
  final int to;
  final TextStyle style;
  final Color color;
  final HighlightStyle highlight;
  final (double, double) band;
  final Key wordKey;
  final Key? textKey;
  final bool expand;

  /// As letras da palavra grifada (no Noite, escuras no fundo — D-133); `null` = as do resto.
  final Color? wordColor;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      // a medida sem o `line-height`: a caixa da letra do CSS (o fundo do `<span>` inline)
      final natural = TextStyle(
        fontFamily: style.fontFamily,
        fontFamilyFallback: style.fontFamilyFallback,
        fontSize: style.fontSize,
        fontWeight: style.fontWeight,
      );
      final tp = TextPainter(
        text: TextSpan(text: text, style: natural),
        textDirection: TextDirection.ltr,
        textAlign: expand ? TextAlign.center : TextAlign.start,
        maxLines: 1,
      );
      if (expand) {
        tp.layout(minWidth: c.maxWidth, maxWidth: c.maxWidth);
      } else {
        tp.layout();
      }
      final m = tp.computeLineMetrics().first;
      final boxes = tp.getBoxesForSelection(
        TextSelection(baseOffset: from, extentOffset: to),
      );
      final width = tp.width;
      tp.dispose();
      final line = style.fontSize! * style.height!;
      final letter = m.ascent + m.descent;
      final top = (line - letter) / 2;
      final left = boxes.isEmpty ? 0.0 : boxes.first.left;
      final right = boxes.isEmpty ? 0.0 : boxes.last.right;
      return SizedBox(
        width: width,
        height: line,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: left,
              top: top,
              width: right - left,
              height: letter,
              child: CustomPaint(
                key: wordKey,
                painter: MarkerSamplePainter(
                  color: color,
                  style: highlight,
                  band: band,
                  baseline: m.ascent,
                ),
              ),
            ),
            Positioned.fill(
              child: AppText.rich(
                TextSpan(
                  style: style,
                  children: [
                    if (from > 0) TextSpan(text: text.substring(0, from)),
                    TextSpan(
                      text: text.substring(from, to),
                      style: wordColor == null
                          ? null
                          : TextStyle(color: wordColor),
                    ),
                    if (to < text.length) TextSpan(text: text.substring(to)),
                  ],
                ),
                key: textKey,
                maxLines: 1,
                textAlign: expand ? TextAlign.center : TextAlign.start,
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// A moldura com o painel do marca-texto, que acompanha a sessão.
class MarkerPanelLayer extends StatelessWidget {
  const MarkerPanelLayer({
    super.key,
    required this.session,
    required this.bottom,
    required this.paper,
    this.preview,
    this.onEditLabels,
    this.top = 0,
  });

  final AnnotationSession session;
  final double bottom;
  final Color paper;
  final MarkerPreviewSource? preview;

  /// "Editar rótulos" (D-177).
  final VoidCallback? onEditLabels;
  final double top;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    builder: (context, _) => ToolPanelLayer(
      id: 'ann.markerPanel',
      label: 'Ajustes do marca-texto',
      title: 'Marca-texto',
      subtitle: markerPanelSubtitle(session.presets, session.labels),
      arrowLeft: panelArrowLeft(AnnotationTool.marker),
      bottom: bottom,
      top: top,
      paper: paper,
      onClose: session.closePanel,
      child: MarkerPanel(
        session: session,
        preview: preview,
        onEditLabels: onEditLabels,
      ),
    ),
  );
}

/// O miolo do painel do marca-texto (abaixo do cabeçalho).
class MarkerPanel extends StatelessWidget {
  const MarkerPanel({
    super.key,
    required this.session,
    this.preview,
    this.onEditLabels,
  });

  final AnnotationSession session;
  final MarkerPreviewSource? preview;
  final VoidCallback? onEditLabels;

  static const String _k = 'ann.markerPanel';

  @override
  Widget build(BuildContext context) {
    final scope = ReaderChromeScope.of(context);
    final p = scope.palette;
    final pen = session.presets;
    final color = scope.tint(Color(argbOfHex(pen.highlighterColor)));
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    final label = AppTextStyles.readerSheetLabel.copyWith(color: p.label);
    final fill = pen.highlighterStyle == HighlightStyle.fill;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        _preview(scope, pen, color, line),
        const SizedBox(height: 14),
        AppText(
          'ESTILO',
          key: const ValueKey('$_k.styleLabel'),
          style: label,
          maxLines: 1,
        ),
        const SizedBox(height: 7),
        _styles(scope, pen, color, line),
        const SizedBox(height: 14),
        _colorsHeader(scope, label),
        const SizedBox(height: 7),
        _colors(scope, pen),
        const SizedBox(height: 14),
        // R18: fora do Fundo, a altura fica apagada e não responde
        ReaderChromeScope(
          palette: fill ? p : p.faded(_disabledAlpha),
          brand: scope.brand,
          a: fill ? scope.a : scope.a * _disabledAlpha,
          child: Builder(builder: (context) => _heights(context, pen, fill)),
        ),
        const SizedBox(height: 12),
        _tip(scope),
      ],
    );
  }

  Widget _preview(
    ReaderChromeScope scope,
    PenPresets pen,
    Color color,
    BorderSide line,
  ) {
    final p = scope.palette;
    final style = AppTextStyles.annMarkerPreview.copyWith(
      color: scope.tint(p.night ? AppColors.bookTextNight : AppColors.bookText),
    );
    return LayoutBuilder(
      builder: (context, c) {
        final inner = c.maxWidth - 2 * AppStrokes.regular - 2 * _previewPadding;
        double measure(String s) {
          final tp = TextPainter(
            text: TextSpan(text: s, style: style),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout();
          final w = tp.width;
          tp.dispose();
          return w;
        }

        final src = preview;
        final m = markerPreviewOf(
          src?.text ?? '',
          start: src?.start ?? 0,
          end: src?.end ?? 0,
          maxWidth: inner,
          width: measure,
        );
        final styleName = highlightStyleNames[pen.highlighterStyle]!
            .toLowerCase();
        final colorName =
            colorNameOf(pen.highlighterColor) ??
            pen.highlighterColor.toUpperCase();
        return Semantics(
          container: true,
          image: true,
          label:
              'Prévia: ${m.firstSentence}, com $styleName $colorName na palavra '
              '${m.text.substring(m.from, m.to)}',
          child: Container(
            key: const ValueKey('$_k.preview'),
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.symmetric(
              horizontal: _previewPadding,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: p.well,
              border: Border.fromBorderSide(line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExcludeSemantics(
              child: _MarkedLine(
                text: m.text,
                from: m.from,
                to: m.to,
                style: style,
                color: color,
                highlight: pen.highlighterStyle,
                band: previewBand(pen.highlighterHeight),
                wordKey: const ValueKey('$_k.preview.highlight'),
                textKey: const ValueKey('$_k.preview.text'),
                expand: true,
                // no Noite, a palavra no fundo fica escura, como na página (D-133)
                wordColor:
                    p.night && pen.highlighterStyle == HighlightStyle.fill
                    ? scope.tint(AppColors.ink)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _styles(
    ReaderChromeScope scope,
    PenPresets pen,
    Color color,
    BorderSide line,
  ) {
    final p = scope.palette;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Estilo do marca-texto',
      child: Row(
        key: const ValueKey('$_k.styles'),
        spacing: 8,
        children: [
          for (final (style, id) in const [
            (HighlightStyle.fill, 'fill'),
            (HighlightStyle.underline, 'underline'),
            (HighlightStyle.wavy, 'wavy'),
          ])
            Expanded(
              child: Pressable(
                key: ValueKey('$_k.styles.$id'),
                semanticsLabel: highlightStyleNames[style],
                checked: style == pen.highlighterStyle,
                onTap: () => session.setHighlighterStyle(style),
                child: Container(
                  height: 66,
                  decoration: BoxDecoration(
                    color: style == pen.highlighterStyle
                        ? scope.tint(scope.brand)
                        : p.well,
                    border: Border.fromBorderSide(line),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: style == pen.highlighterStyle
                        ? [BoxShadow(color: p.shadow, offset: AppShadows.hard2)]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 7,
                    children: [
                      Padding(
                        key: ValueKey('$_k.styles.$id.sample'),
                        padding: const EdgeInsets.only(bottom: 3),
                        child: _MarkedLine(
                          text: 'ressaca',
                          from: 0,
                          to: 7,
                          style: AppTextStyles.annMarkerSample.copyWith(
                            // no Noite: escuras na brand (o ativo) e no fundo (D-133); claras no poço
                            color: scope.tint(
                              !p.night
                                  ? AppColors.bookText
                                  : style == pen.highlighterStyle ||
                                        style == HighlightStyle.fill
                                  ? AppColors.ink
                                  : AppColors.bookTextNight,
                            ),
                          ),
                          color: color,
                          highlight: style,
                          band: previewBand(pen.highlighterHeight),
                          wordKey: ValueKey('$_k.styles.$id.sample.word'),
                        ),
                      ),
                      AppText(
                        highlightStyleNames[style]!,
                        style: AppTextStyles.annPanelOption.copyWith(
                          // o ativo fica sobre a `brand` (letras escuras nos dois temas)
                          color: style == pen.highlighterStyle
                              ? scope.tint(AppColors.ink)
                              : p.title,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _colorsHeader(ReaderChromeScope scope, TextStyle label) {
    final p = scope.palette;
    return Row(
      key: const ValueKey('$_k.colorsHeader'),
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        AppText(
          'CORES E RÓTULOS',
          key: const ValueKey('$_k.colorsHeader.label'),
          style: label,
          maxLines: 1,
        ),
        const Spacer(),
        Pressable(
          key: const ValueKey('$_k.colorsHeader.editLabels'),
          semanticsLabel: 'Editar rótulos',
          onTap: onEditLabels,
          child: AppText(
            'Editar rótulos',
            style: AppTextStyles.annPanelLink.copyWith(
              color: p.title,
              decorationColor: p.title,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _colors(ReaderChromeScope scope, PenPresets pen) {
    final current = pen.highlighterColor.toUpperCase();
    Widget row(String hex) =>
        Expanded(child: _color(scope, hex, hex == current));
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Cor do marca-texto',
      child: Column(
        key: const ValueKey('$_k.colors'),
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            children: [row(markerColors[0]), row(markerColors[1])],
          ),
          Row(
            spacing: 8,
            children: [row(markerColors[2]), row(markerColors[3])],
          ),
        ],
      ),
    );
  }

  Widget _color(ReaderChromeScope scope, String hex, bool selected) {
    final p = scope.palette;
    final id = _colorIds[hex]!;
    final name = markerColorName(hex)!;
    final label = _labelOf(session.labels, hex);
    final count = highlightCountLabel(session.colorCount(hex));
    return Pressable(
      key: ValueKey('$_k.colors.$id'),
      semanticsLabel: label.isEmpty
          ? '$name, $count'
          : '$name, rótulo $label, $count',
      checked: selected,
      onTap: () => session.setHighlighterColor(hex),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: p.island,
          border: Border.all(
            width: AppStrokes.regular,
            color: selected
                ? p.border
                : scope.tint(
                    p.night ? AppColors.dashNight : AppColors.markerRowBorder,
                  ),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ExcludeSemantics(
          child: Row(
            spacing: 9,
            children: [
              SizedBox.square(
                key: ValueKey('$_k.colors.$id.swatch'),
                dimension: 24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scope.tint(Color(argbOfHex(hex))),
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: AppStrokes.regular,
                      color: p.border,
                    ),
                    // a marcada: o aro de 2,5 claro e o de tinta por fora (`box-shadow: 0 0 0 2.5px, 0 0 0 4px`)
                    boxShadow: selected
                        ? [
                            BoxShadow(color: p.border, spreadRadius: 4),
                            BoxShadow(color: p.island, spreadRadius: 2.5),
                          ]
                        : null,
                  ),
                ),
              ),
              // a coluna do CSS: os dois textos na largura do mais largo
              Flexible(
                child: IntrinsicWidth(
                  child: Column(
                    key: ValueKey('$_k.colors.$id.texts'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppText(
                        label.isEmpty ? name : label,
                        key: ValueKey('$_k.colors.$id.label'),
                        style: AppTextStyles.annColorLabel.copyWith(
                          color: p.title,
                        ),
                        maxLines: 1,
                        ellipsis: true,
                      ),
                      AppText(
                        count,
                        key: ValueKey('$_k.colors.$id.count'),
                        style: AppTextStyles.annColorCount.copyWith(
                          color: p.caption,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heights(BuildContext context, PenPresets pen, bool enabled) {
    final scope = ReaderChromeScope.of(context);
    final p = scope.palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    final marker = scope.tint(Color(argbOfHex(pen.highlighterColor)));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          'ALTURA',
          key: const ValueKey('$_k.heightLabel'),
          style: AppTextStyles.readerSheetLabel.copyWith(color: p.label),
          maxLines: 1,
        ),
        const SizedBox(height: 7),
        Semantics(
          container: true,
          explicitChildNodes: true,
          label: 'Altura do fundo',
          child: Container(
            key: const ValueKey('$_k.heights'),
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: p.well,
              border: Border.fromBorderSide(line),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              spacing: 2,
              children: [
                for (final (h, id, sample) in const [
                  (FillHeight.low, 'low', 6.0),
                  (FillHeight.medium, 'medium', 11.0),
                  (FillHeight.high, 'high', 16.0),
                ])
                  Expanded(
                    child: Pressable(
                      key: ValueKey('$_k.heights.$id'),
                      semanticsLabel: fillHeightNames[h],
                      checked: h == pen.highlighterHeight,
                      enabled: enabled,
                      onTap: () => session.setHighlighterHeight(h),
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          color: h == pen.highlighterHeight
                              ? scope.tint(scope.brand)
                              : null,
                          border: h == pen.highlighterHeight
                              ? Border.fromBorderSide(line)
                              : null,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: ExcludeSemantics(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              Container(
                                key: ValueKey('$_k.heights.$id.sample'),
                                width: 16,
                                height: sample,
                                decoration: BoxDecoration(
                                  color: marker,
                                  border: Border.all(
                                    width: 1.2,
                                    color: p.border,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              AppText(
                                fillHeightNames[h]!,
                                style: h == pen.highlighterHeight
                                    ? AppTextStyles.annHeightOptionActive
                                          .copyWith(
                                            color: scope.tint(AppColors.ink),
                                          )
                                    : AppTextStyles.annHeightOption.copyWith(
                                        color: p.muted,
                                      ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tip(ReaderChromeScope scope) {
    final p = scope.palette;
    return CustomPaint(
      key: const ValueKey('$_k.tip'),
      painter: DashedStadiumPainter(
        thickness: 1.3,
        radius: 16,
        color: scope.tint(p.night ? AppColors.dashNight : AppColors.tipDash),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13.3, 11.3, 13.3, 11.3),
        child: Row(
          spacing: 10,
          children: [
            AppSvg(
              AppIllustrationsLeitor.markerTip,
              key: const ValueKey('$_k.tip.icon'),
              size: 34,
              height: 22,
              // o contorno escuro do arquivo, claro no Noite
              colors: p.night ? {AppColors.ink: p.border} : null,
              opacity: scope.a < 1 ? scope.a : null,
            ),
            Expanded(
              child: AppText.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Gruda nas palavras.',
                      style: AppTextStyles.annTipStrong.copyWith(
                        color: p.title,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' Mesmo torto, o traço encaixa na linha e acompanha '
                          'se a fonte mudar.',
                      style: AppTextStyles.annTip.copyWith(
                        color: p.night
                            ? p.muted
                            : scope.tint(AppColors.tipText),
                      ),
                    ),
                  ],
                ),
                key: const ValueKey('$_k.tip.text'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A altura fora do Fundo (como o Desfazer vazio).
const double _disabledAlpha = 0.38;

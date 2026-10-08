// G17.3 — o painel da caneta (tela 23, L23.1–L23.6), por dentro da moldura (`ToolPanelLayer`):
// - a prévia: a faixa pautada de 58 (`#F7F0E3` com o fio `#E6DBC6` a cada 19,5, começando em 7,5) e o caminho do
//   arquivo passado pelo motor da tinta com a ponta, a cor e a espessura do painel × Fina/Média/Grossa, ampliada
//   17/11 — 3,4 px a 1,2 mm na Média, como o arquivo (R9, D-159), com pressão fixa no meio;
// - PONTA: 3 cartões de 70 com as amostras do arquivo na cor da caneta; o ativo com a `brand` e a sombra 2/2 (R10);
// - ESPESSURA: o valor ("1,2 mm"), o trilho hachurado com o preenchimento `brand` até o botão de 28, na escala da
//   D-50, de 0,1 em 0,1; arrastar só muda, soltar grava (R11, R6);
// - COR: as favoritas em fileiras de 7 lugares (47,5 de passo), a marcada com o aro duplo; o "+" tracejado junta a cor
//   atual (apagado se ela já é favorita; some com 12); a pressão longa tira, com a pílula e o Desfazer (R12, D-175);
// - o seletor de cor (R13, R14): com o teclado do hex aberto, o painel sobe até o campo ficar 8 acima dele.
// O subtítulo (R8) e a pílula das favoritas vão na moldura.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/color/color_names.dart';
import '../../../core/design_system/painters/dashed_stadium_painter.dart';
import '../../../core/design_system/painters/hatch_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_illustrations_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../annotations/domain/pen_presets.dart';
import '../annotations/ink/ink_stroke.dart';
import '../annotations/ink/ink_units.dart';
import '../annotations/ink/pen_width_scale.dart';
import '../application/annotation_session.dart';
import 'color_picker.dart';
import 'ink_painter.dart' show inkPath;
import 'reader_chrome_scope.dart';
import 'reader_overlays.dart' show ReaderUndoPill;
import 'tool_panel_frame.dart';

/// A prévia amplia o traço em 17/11 (3,4 px a 1,2 mm na Média — D-159).
const double penPreviewZoom = 17 / 11;

/// O nome de cada ponta.
const Map<PenTip, String> penTipNames = {
  PenTip.ballpoint: 'Esferográfica',
  PenTip.fountain: 'Tinteiro',
  PenTip.brush: 'Pincel',
};

/// "Esferográfica · 1,2 mm · coral" (R8): a ponta, a espessura com 1 casa e o nome da cor (ou o hex).
String penPanelSubtitle(PenPresets p) =>
    '${penTipNames[p.penTip]} · ${widthLabel(p.penWidthMm)} · '
    '${colorNameOf(p.penColor) ?? p.penColor.toUpperCase()}';

/// O caminho da prévia do arquivo (`il_previa_traco_caneta`, caixa de 300×56).
ui.Path _previewPath() {
  final path = ui.Path()
    ..moveTo(14, 38)
    ..cubicTo(30, 14, 44, 14, 50, 28);
  // os `S` do arquivo: o 1º controle é o reflexo do último
  var c = const Offset(44, 14);
  var at = const Offset(50, 28);
  for (final (c2, end) in const [
    (Offset(62, 46), Offset(78, 30)),
    (Offset(96, 10), Offset(108, 22)),
    (Offset(116, 44), Offset(132, 36)),
    (Offset(150, 14), Offset(166, 20)),
    (Offset(172, 40), Offset(190, 38)),
    (Offset(210, 18), Offset(226, 22)),
    (Offset(236, 40), Offset(252, 36)),
    (Offset(268, 22), Offset(290, 26)),
  ]) {
    final c1 = at * 2 - c;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    c = c2;
    at = end;
  }
  return path;
}

/// O traço da prévia (R9): o caminho do arquivo amostrado a cada 0,5 px, deslocado para o meio da faixa de dentro
/// (324 de largura: 12 de cada lado), na ponta e na cor da caneta, com a espessura × Fina/Média/Grossa × 17/11.
InkStroke penPreviewStroke(PenPresets p) {
  final points = <InkPoint>[];
  for (final m in _previewPath().computeMetrics()) {
    final n = (m.length / 0.5).ceil();
    for (var i = 0; i <= n; i++) {
      final t = m.getTangentForOffset(math.min(m.length, i * 0.5))!;
      points.add(InkPoint(t.position.dx + 12, t.position.dy, 0.5, i * 4));
    }
  }
  return InkStroke(
    tool: InkTool.pen.code,
    tip: tipCode(p.penTip),
    argb: argbOfHex(p.penColor),
    widthCentiMm:
        (p.penWidthMm * sizeFactor(p.strokeSize) * penPreviewZoom * 100)
            .round(),
    points: List.unmodifiable(points),
  );
}

/// A faixa pautada e o traço da prévia.
class PenPreviewPainter extends CustomPainter {
  const PenPreviewPainter({
    required this.stroke,
    required this.background,
    required this.rule,
  });

  final InkStroke stroke;
  final Color background;
  final Color rule;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    // o `repeating-linear-gradient(#F7F0E3 0 18px, #E6DBC6 18px 19.5px)` com `background-position: 0 9px`
    final line = Paint()..color = rule;
    for (var y = 7.5; y < size.height; y += 19.5) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1.5), line);
    }
    canvas.drawPath(
      inkPath(stroke),
      Paint()
        ..color = Color(stroke.argb)
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(PenPreviewPainter old) =>
      old.stroke != stroke || old.background != background || old.rule != rule;
}

/// A moldura com o painel da caneta, que acompanha a sessão.
class PenPanelLayer extends StatefulWidget {
  const PenPanelLayer({
    super.key,
    required this.session,
    required this.from,
    required this.bottom,
    required this.paper,
    this.top = 0,
  });

  final AnnotationSession session;

  /// A ferramenta de onde o painel saiu (a seta: a Caneta ou a Reta).
  final AnnotationTool from;

  /// A distância da base do painel à base da tela (22 acima da prateleira).
  final double bottom;
  final Color paper;

  /// O limite de cima (R7).
  final double top;

  @override
  State<PenPanelLayer> createState() => _PenPanelLayerState();
}

/// Quanto o campo hex fica acima da base do painel: o preenchimento de baixo (18), a borda e o meio da roda menos o
/// lado do seletor (o campo é o fim do lado, centrado na roda).
const double _hexAbovePanelBottom =
    18 + AppStrokes.regular + (colorWheelSize - colorPickerSideHeight) / 2;

class _PenPanelLayerState extends State<PenPanelLayer> {
  bool _hex = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return ListenableBuilder(
      listenable: Listenable.merge([s, s.favoriteRemoved]),
      builder: (context, _) {
        final keyboard = MediaQuery.viewInsetsOf(context).bottom;
        // R14: com o teclado do hex, o painel sobe até o campo ficar 8 acima dele
        final bottom = _hex && keyboard > 0
            ? math.max(widget.bottom, keyboard + 8 - _hexAbovePanelBottom)
            : widget.bottom;
        final removed = s.favoriteRemoved.value;
        return ToolPanelLayer(
          id: 'ann.penPanel',
          label: 'Ajustes da caneta',
          title: 'Caneta',
          subtitle: penPanelSubtitle(s.presets),
          arrowLeft: panelArrowLeft(widget.from),
          bottom: bottom,
          top: widget.top,
          bottomPadding: 18,
          paper: widget.paper,
          onClose: s.closePanel,
          banner: removed == null
              ? null
              : ReaderUndoPill(
                  text: 'Cor tirada das favoritas',
                  onUndo: s.undoFavoriteRemoval,
                ),
          child: PenPanel(
            session: s,
            onHexFocus: (f) => setState(() => _hex = f),
          ),
        );
      },
    );
  }
}

/// O miolo do painel da caneta (abaixo do cabeçalho).
class PenPanel extends StatelessWidget {
  const PenPanel({super.key, required this.session, this.onHexFocus});

  final AnnotationSession session;
  final ValueChanged<bool>? onHexFocus;

  static const String _k = 'ann.penPanel';

  @override
  Widget build(BuildContext context) {
    final scope = ReaderChromeScope.of(context);
    final p = scope.palette;
    final pen = session.presets;
    final ink = Color(argbOfHex(pen.penColor));
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    final label = AppTextStyles.readerSheetLabel.copyWith(color: p.label);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        _preview(scope, pen, line),
        const SizedBox(height: 14),
        AppText(
          'PONTA',
          key: const ValueKey('$_k.tipLabel'),
          style: label,
          maxLines: 1,
        ),
        const SizedBox(height: 7),
        _tips(scope, pen, ink, line),
        const SizedBox(height: 15),
        Row(
          key: const ValueKey('$_k.sizeHeader'),
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AppText(
              'ESPESSURA',
              key: const ValueKey('$_k.sizeHeader.label'),
              style: label,
              maxLines: 1,
            ),
            const Spacer(),
            AppText(
              widthLabel(pen.penWidthMm),
              key: const ValueKey('$_k.sizeHeader.value'),
              style: AppTextStyles.annPanelValue.copyWith(color: p.title),
              maxLines: 1,
            ),
          ],
        ),
        const SizedBox(height: 6),
        _size(scope, pen, line),
        const SizedBox(height: 14),
        AppText(
          'COR',
          key: const ValueKey('$_k.colorLabel'),
          style: label,
          maxLines: 1,
        ),
        const SizedBox(height: 8),
        _favorites(scope, pen, line),
        const SizedBox(height: 14),
        ColorPicker(
          color: pen.penColor,
          keyPrefix: '$_k.picker',
          onChanged: (h) => session.setPenColor(h, save: false),
          onChangeEnd: session.setPenColor,
          onHexFocus: onHexFocus,
        ),
      ],
    );
  }

  Widget _preview(ReaderChromeScope scope, PenPresets pen, BorderSide line) {
    final p = scope.palette;
    return Semantics(
      container: true,
      image: true,
      label: 'Prévia do traço',
      child: RepaintBoundary(
        key: const ValueKey('$_k.preview'),
        child: Container(
          height: 58,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.fromBorderSide(line),
          ),
          // a arte de 56 passa 1 px da caixa de dentro (55): o arquivo recorta embaixo
          child: ExcludeSemantics(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 56,
                  child: CustomPaint(
                    key: const ValueKey('$_k.preview.art'),
                    painter: PenPreviewPainter(
                      stroke: penPreviewStroke(pen),
                      background: p.well,
                      rule: scope.tint(
                        p.night ? AppColors.hatchNight : AppColors.rulePen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tips(
    ReaderChromeScope scope,
    PenPresets pen,
    Color ink,
    BorderSide line,
  ) {
    final p = scope.palette;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Tipo de ponta',
      child: Row(
        key: const ValueKey('$_k.tips'),
        spacing: 8,
        children: [
          for (final (tip, name, asset) in const [
            (
              PenTip.ballpoint,
              'ballpoint',
              AppIllustrationsLeitor.tipBallpoint,
            ),
            (PenTip.fountain, 'fountain', AppIllustrationsLeitor.tipFountain),
            (PenTip.brush, 'brush', AppIllustrationsLeitor.tipBrush),
          ])
            Expanded(
              child: Pressable(
                key: ValueKey('$_k.tips.$name'),
                semanticsLabel: penTipNames[tip],
                checked: tip == pen.penTip,
                onTap: () => session.setPenTip(tip),
                child: NeoBox(
                  key: ValueKey('$_k.tips.$name.box'),
                  height: 70,
                  color: tip == pen.penTip ? scope.tint(scope.brand) : p.well,
                  border: line,
                  radius: BorderRadius.circular(16),
                  shadow: tip == pen.penTip ? AppShadows.hard2 : null,
                  shadowColor: p.shadow,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      AppSvg(
                        asset,
                        key: ValueKey('$_k.tips.$name.sample'),
                        size: 80,
                        height: 26,
                        colors: ink == AppColors.flame
                            ? null
                            : {AppColors.flame: ink},
                        opacity: scope.a < 1 ? scope.a : null,
                      ),
                      AppText(
                        penTipNames[tip]!,
                        style: AppTextStyles.annPanelOption.copyWith(
                          // o ativo fica sobre a `brand` (letras escuras nos dois temas)
                          color: tip == pen.penTip
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

  Widget _size(ReaderChromeScope scope, PenPresets pen, BorderSide line) {
    final p = scope.palette;
    Widget dot(String id, double d) => Container(
      key: ValueKey('$_k.size.$id'),
      width: d,
      height: d,
      decoration: BoxDecoration(color: p.title, shape: BoxShape.circle),
    );
    final t = sliderOfWidth(pen.penWidthMm);
    String spoken(double mm) => widthSpoken(mm.clamp(penWidthMin, penWidthMax));
    return SizedBox(
      key: const ValueKey('$_k.size'),
      height: 32,
      child: Row(
        spacing: 12,
        children: [
          dot('minDot', 5),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                // a caixa de dentro do trilho (sem a borda)
                final inner = c.maxWidth - 2 * AppStrokes.regular;
                void at(double x, {bool save = false}) => session.setPenWidth(
                  widthOfSlider((x - AppStrokes.regular) / inner),
                  save: save,
                );
                return Semantics(
                  slider: true,
                  label: 'Espessura',
                  value: widthSpoken(pen.penWidthMm),
                  increasedValue: spoken(pen.penWidthMm + 0.1),
                  decreasedValue: spoken(pen.penWidthMm - 0.1),
                  onIncrease: () => session.setPenWidth(
                    ((pen.penWidthMm + 0.1) * 10).round().clamp(3, 40) / 10,
                  ),
                  onDecrease: () => session.setPenWidth(
                    ((pen.penWidthMm - 0.1) * 10).round().clamp(3, 40) / 10,
                  ),
                  child: GestureDetector(
                    key: const ValueKey('$_k.size.slider'),
                    excludeFromSemantics: true,
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragDown: (d) => at(d.localPosition.dx),
                    // o 1º trecho do arrasto chega no começo (`DragStartBehavior.start`), não num update
                    onHorizontalDragStart: (d) => at(d.localPosition.dx),
                    onHorizontalDragUpdate: (d) => at(d.localPosition.dx),
                    onHorizontalDragEnd: (_) =>
                        session.setPenWidth(session.presets.penWidthMm),
                    onHorizontalDragCancel: () =>
                        session.setPenWidth(session.presets.penWidthMm),
                    child: SizedBox(
                      height: 16,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                border: Border.fromBorderSide(line),
                              ),
                              child: CustomPaint(
                                painter: HatchPainter(
                                  stripe: p.hatch,
                                  base: p.hatchBase,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    key: const ValueKey('$_k.size.slider.fill'),
                                    width: t * inner,
                                    decoration: BoxDecoration(
                                      color: scope.tint(scope.brand),
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                            left: Radius.circular(999),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            key: const ValueKey('$_k.size.slider.knob'),
                            left: AppStrokes.regular + t * inner - 14,
                            top: 8 - 14,
                            width: 28,
                            height: 28,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: p.island,
                                shape: BoxShape.circle,
                                border: Border.all(width: 2, color: p.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: p.shadow,
                                    offset: const Offset(2, 2),
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
              },
            ),
          ),
          dot('maxDot', 14),
        ],
      ),
    );
  }

  Widget _favorites(ReaderChromeScope scope, PenPresets pen, BorderSide line) {
    final p = scope.palette;
    final favs = pen.favoriteColors;
    final current = pen.penColor.toUpperCase();
    final known = favs.any((f) => f.toUpperCase() == current);
    final withAdd = favs.length < maxFavoriteColors;
    final slots = favs.length + (withAdd ? 1 : 0);
    final rows = math.max(1, (slots / favoriteColumns).ceil());
    const step = 34 + favoriteGap;
    Offset place(int i) =>
        Offset(4 + (i % favoriteColumns) * 47.5, (i ~/ favoriteColumns) * step);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Cores favoritas',
      child: SizedBox(
        key: const ValueKey('$_k.favorites'),
        height: rows * 34 + (rows - 1) * favoriteGap,
        child: Stack(
          children: [
            for (var i = 0; i < favs.length; i++)
              Positioned(
                left: place(i).dx,
                top: place(i).dy,
                child: _favorite(
                  scope,
                  favs[i],
                  i,
                  favs[i].toUpperCase() == current,
                ),
              ),
            if (withAdd)
              Positioned(
                left: place(favs.length).dx,
                top: place(favs.length).dy,
                child: Pressable(
                  key: const ValueKey('$_k.favorites.add'),
                  semanticsLabel: 'Salvar a cor atual nas favoritas',
                  enabled: !known,
                  onTap: session.addFavorite,
                  child: CustomPaint(
                    painter: DashedStadiumPainter(
                      color: known
                          ? p.border.withValues(
                              alpha: p.border.a * _disabledAlpha,
                            )
                          : p.border,
                    ),
                    child: SizedBox.square(
                      dimension: 34,
                      child: Center(
                        child: AppSvg(
                          AppIconsLeitor.plus,
                          key: const ValueKey('$_k.favorites.add.icon'),
                          size: 14,
                          color: p.night || known
                              ? p.title.withValues(
                                  alpha:
                                      p.title.a * (known ? _disabledAlpha : 1),
                                )
                              : null,
                          opacity: scope.a < 1 ? scope.a : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _favorite(
    ReaderChromeScope scope,
    String hex,
    int index,
    bool selected,
  ) {
    final p = scope.palette;
    final name = penColorName(hex);
    final id = _favoriteIds[hex.toUpperCase()] ?? '${index + 1}';
    return Pressable(
      key: ValueKey('$_k.favorites.$id'),
      semanticsLabel: name ?? 'Cor ${hex.toUpperCase()}',
      checked: selected,
      onTap: () => session.setPenColor(hex),
      onLongPress: () => session.removeFavorite(hex),
      customActions: {
        const CustomSemanticsAction(label: 'Tirar das favoritas'): () =>
            session.removeFavorite(hex),
      },
      child: SizedBox.square(
        dimension: 34,
        child: DecoratedBox(
          key: ValueKey('$_k.favorites.$id.dot'),
          decoration: BoxDecoration(
            color: scope.tint(Color(argbOfHex(hex.toUpperCase()))),
            shape: BoxShape.circle,
            border: Border.all(width: AppStrokes.regular, color: p.border),
            // a marcada: o aro de 2,5 claro e o de tinta por fora (`box-shadow: 0 0 0 2.5px, 0 0 0 4px`)
            boxShadow: selected
                ? [
                    BoxShadow(color: p.border, spreadRadius: 4),
                    BoxShadow(
                      color: scope.tint(AppColors.surface),
                      spreadRadius: 2.5,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

/// As fileiras de favoritas têm 7 lugares; entre elas, o mesmo vão de 13,5 dos lados (D-175).
const int favoriteColumns = 7;
const double favoriteGap = 13.5;

/// O "+" apagado (como o Desfazer vazio).
const double _disabledAlpha = 0.38;

/// As chaves das 6 favoritas de fábrica (os ids do arquivo).
const Map<String, String> _favoriteIds = {
  '#FF552E': 'coral',
  '#552CB7': 'purple',
  '#058CD7': 'blue',
  '#00995E': 'green',
  '#F2A815': 'gold',
  '#1A1714': 'black',
};

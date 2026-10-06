// G13.3 — a barra de ações da tela 21 (L21b): "GRIFAR" + 4 cores + "outra cor" (anel arco-íris) + Sublinhar, e
// Nota · Copiar · Compartilhar · Buscar. No grifo existente, a cor dele (ou o Sublinhar) ganha um anel (D-132). No
// Noite, as cores das ilhas e os ícones tingidos com a cor da borda. O "a" do Sublinhar é pintado com a Literata do
// livro (o <text> do SVG usaria a fonte do sistema — armadilha da L21b).
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/chromium_dash.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../annotations/domain/annotation.dart' show HighlightStyle;
import 'reader_chrome_palette.dart';

/// As 4 cores da barra (iguais às opções de `brand` — L21b): a key, o hex e o rótulo do arquivo.
const List<({String key, String hex, String label})> highlightPalette = [
  (key: 'yellow', hex: '#FED170', label: 'Grifar em amarelo'),
  (key: 'pink', hex: '#FFC1C6', label: 'Grifar em rosa'),
  (key: 'green', hex: '#ABCF82', label: 'Grifar em verde'),
  (key: 'lavender', hex: '#B6ACE4', label: 'Grifar em lavanda'),
];

/// A dica do leitor de tela na cor marcada (ou no Sublinhar marcado): tocar de novo apaga (D-132).
const String toolbarRemoveHint = 'Apaga o grifo';

/// O grifo existente (D-132): a cor e o estilo dele.
typedef ToolbarMark = ({String color, HighlightStyle style});

/// Círculos da linha de cores (L21b nº 5–13): 34, a 7 um do outro.
const double toolbarSwatch = 34;

/// O anel da cor marcada (D-132, extrapolado): 1,5 de tinta a 1,5 do círculo → 40 de fora a fora.
const double toolbarMarkGap = 1.5;

class HighlightToolbar extends StatelessWidget {
  const HighlightToolbar({
    super.key,
    required this.palette,
    this.marked,
    required this.onColor,
    required this.onOtherColor,
    required this.onUnderline,
    required this.onNote,
    required this.onCopy,
    required this.onShare,
    required this.onSearch,
  });

  final ReaderChromePalette palette;
  final ToolbarMark? marked;
  final ValueChanged<String> onColor;
  final VoidCallback onOtherColor;
  final VoidCallback onUnderline;
  final VoidCallback onNote;
  final VoidCallback onCopy;

  /// Compartilhar, com o retângulo do botão na tela (no iPad a folha do sistema sai dele).
  final ValueChanged<Rect?> onShare;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    final m = marked;
    final round = BorderRadius.circular(999);
    Widget circle(
      String key,
      String label,
      bool on,
      VoidCallback onTap,
      Widget body,
    ) {
      const out = toolbarMarkGap + AppStrokes.regular;
      return Pressable(
        key: ValueKey(key),
        semanticsLabel: label,
        // só com um grifo existente a barra diz qual cor é a dele (D-132)
        selected: m == null ? null : on,
        hint: on ? toolbarRemoveHint : null,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox.square(dimension: toolbarSwatch, child: body),
            if (on)
              Positioned(
                key: ValueKey('$key.marked'),
                left: -out,
                top: -out,
                width: toolbarSwatch + 2 * out,
                height: toolbarSwatch + 2 * out,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(line),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final colors = [
      for (final c in highlightPalette)
        circle(
          'r21.toolbar.colors.${c.key}',
          c.label,
          m != null && m.style == HighlightStyle.fill && m.color == c.hex,
          () => onColor(c.hex),
          NeoBox(color: _hex(c.hex), border: line, radius: round),
        ),
      circle(
        'r21.toolbar.colors.other',
        'Escolher outra cor',
        false,
        onOtherColor,
        CustomPaint(
          painter: RainbowRingPainter(border: p.border, center: p.island),
          child: Center(
            child: SizedBox.square(
              key: const ValueKey('r21.toolbar.colors.other.center'),
              dimension: 14,
              child: Center(
                child: AppSvg(
                  AppIconsLeitor.plusTiny,
                  key: const ValueKey('r21.toolbar.colors.other.icon'),
                  size: 8,
                  color: p.night ? p.border : null,
                ),
              ),
            ),
          ),
        ),
      ),
      circle(
        'r21.toolbar.colors.underline',
        'Sublinhar',
        m != null && m.style == HighlightStyle.underline,
        onUnderline,
        NeoBox(
          color: p.island,
          border: line,
          radius: round,
          child: Center(
            child: SizedBox.square(
              key: const ValueKey('r21.toolbar.colors.underline.icon'),
              dimension: 20,
              child: CustomPaint(
                painter: UnderlineIconPainter(letter: p.title),
              ),
            ),
          ),
        ),
      ),
    ];
    Widget action(
      String key,
      String icon,
      String label,
      ValueChanged<Rect?> onTap,
    ) => Expanded(
      child: Builder(
        builder: (context) => Pressable(
          key: ValueKey('r21.toolbar.actions.$key'),
          semanticsLabel: label,
          onTap: () => onTap(_globalRect(context)),
          child: SizedBox(
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                AppSvg(
                  icon,
                  key: ValueKey('r21.toolbar.actions.$key.icon'),
                  size: 20,
                  color: p.night ? p.border : null,
                ),
                AppText(
                  label,
                  style: AppTextStyles.readerToolbarAction.copyWith(
                    color: p.title,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Ações para o trecho selecionado',
      child: NeoBox(
        key: const ValueKey('r21.toolbar'),
        color: p.island,
        border: line,
        radius: BorderRadius.circular(22),
        shadow: AppShadows.hard3,
        shadowColor: p.shadow,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              key: const ValueKey('r21.toolbar.colors'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ExcludeSemantics(
                        child: AppText(
                          'GRIFAR',
                          key: const ValueKey('r21.toolbar.colors.label'),
                          style: AppTextStyles.readerToolbarLabel.copyWith(
                            color: p.label,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      Row(
                        key: const ValueKey('r21.toolbar.colors.swatches'),
                        mainAxisSize: MainAxisSize.min,
                        spacing: 7,
                        children: colors,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: AppStrokes.regular,
                  child: CustomPaint(
                    painter: ChromiumDashPainter(
                      axis: Axis.horizontal,
                      color: p.dash,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              key: const ValueKey('r21.toolbar.actions'),
              children: [
                action('note', AppIconsLeitor.note, 'Nota', (_) => onNote()),
                action('copy', AppIconsLeitor.copy, 'Copiar', (_) => onCopy()),
                action('share', AppIconsLeitor.share, 'Compartilhar', onShare),
                action(
                  'search',
                  AppIconsLeitor.search,
                  'Buscar',
                  (_) => onSearch(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Color _hex(String hex) =>
    Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

/// Onde o botão está na tela.
Rect? _globalRect(BuildContext context) {
  final box = context.findRenderObject();
  return box is RenderBox && box.hasSize
      ? box.localToGlobal(Offset.zero) & box.size
      : null;
}

/// "Escolher outra cor" (L21b nº 9 e 10): o anel cônico arco-íris (começa no topo e gira no sentido horário, como o
/// CSS), a borda 1,5 e o miolo de 14 com borda 1,5.
class RainbowRingPainter extends CustomPainter {
  const RainbowRingPainter({required this.border, required this.center});

  final Color border;
  final Color center;

  static const List<Color> colors = [
    AppColors.flame,
    AppColors.amber,
    AppColors.sun,
    AppColors.leaf,
    AppColors.emerald,
    AppColors.azure,
    AppColors.lavender,
    AppColors.violet,
    AppColors.blush,
    AppColors.flame,
  ];

  /// O miolo (L21b nº 10): 14.
  static const double centerRadius = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    const half = AppStrokes.regular / 2;
    Paint stroke() => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppStrokes.regular
      ..color = border;
    canvas
      ..drawCircle(
        c,
        r,
        Paint()
          ..shader = const SweepGradient(
            colors: colors,
            transform: GradientRotation(-math.pi / 2),
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      )
      ..drawCircle(c, r - half, stroke())
      ..drawCircle(c, centerRadius, Paint()..color = center)
      ..drawCircle(c, centerRadius - half, stroke());
  }

  @override
  bool shouldRepaint(RainbowRingPainter old) =>
      old.border != border || old.center != center;
}

/// O ícone do Sublinhar (L21b nº 13): o ondulado coral do SVG (`M4 19q2-2 4 0t4 0 4 0 4 0`, traço 2, em 20/24) e o
/// "a" em Literata 13 do SVG (10,83 px na caixa de 20), centrado em x 10, linha de base em 12,08.
class UnderlineIconPainter extends CustomPainter {
  const UnderlineIconPainter({required this.letter});

  final Color letter;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    // o `t` do SVG espelha o controle anterior: os trechos alternam −2/+2
    final wave = Path()
      ..moveTo(4 * k, 19 * k)
      ..relativeQuadraticBezierTo(2 * k, -2 * k, 4 * k, 0)
      ..relativeQuadraticBezierTo(2 * k, 2 * k, 4 * k, 0)
      ..relativeQuadraticBezierTo(2 * k, -2 * k, 4 * k, 0)
      ..relativeQuadraticBezierTo(2 * k, 2 * k, 4 * k, 0);
    canvas.drawPath(
      wave,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * k
        ..strokeCap = StrokeCap.round
        ..color = AppColors.flame,
    );
    final style = AppFonts.literataBook(13, size: 13 * k, color: letter);
    final b =
        ui.ParagraphBuilder(ui.ParagraphStyle(textDirection: TextDirection.ltr))
          ..pushStyle(style.getTextStyle())
          ..addText('a');
    final p = b.build()..layout(const ui.ParagraphConstraints(width: 100));
    final base = p.computeLineMetrics().first.baseline;
    canvas.drawParagraph(
      p,
      Offset(12 * k - p.longestLine / 2, 14.5 * k - base),
    );
    p.dispose();
  }

  @override
  bool shouldRepaint(UnderlineIconPainter old) => old.letter != letter;
}

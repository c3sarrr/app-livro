// G16.6 — a ilha do modo anotação (L22d, "Barra de anotação"): em cima, os rótulos das ferramentas numa grade de 6 ×
// 52 (o ativo numa pílula `brand`; fora do leitor de tela — a prateleira já diz); embaixo do tracejado, o poço de cor
// (o anel cônico com o miolo na cor da tinta e o aro claro), a espessura (Fina/Média/Grossa, a ativa em `brand`) e,
// à direita, Desfazer e Refazer (vazios: a 0,38 e "indisponível"). No Noite (D-167 17), as cores das ilhas do Noite;
// os ícones tingidos com a cor das letras.
// G17: o poço e os pontos na cor da ferramenta de tinta em uso (a do marca-texto com ele — R2); com o Marca-texto, os 3
// pontos são Baixa/Média/Alta (a ALTURA do painel), apagados com Sublinhado ou Ondulado (R18).
import 'package:flutter/widgets.dart';

import '../../../core/design_system/color/color_names.dart';
import '../../../core/design_system/painters/chromium_dash.dart';
import '../../../core/design_system/painters/conic_ring_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../../../core/design_system/widgets/tap_target.dart';
import '../annotations/domain/annotation.dart' show FillHeight;
import '../annotations/domain/pen_presets.dart';
import '../annotations/ink/ink_stroke.dart' show colorHex;
import '../application/annotation_session.dart' show AnnotationTool;
import 'reader_chrome_scope.dart';

/// Desfazer e Refazer vazios (L22d nº 23: `opacity: 0.38`).
const double islandDisabledAlpha = 0.38;

class AnnotationIsland extends StatelessWidget {
  const AnnotationIsland({
    super.key,
    required this.tool,
    required this.ink,
    required this.strokeSize,
    required this.canUndo,
    required this.canRedo,
    required this.onColorWell,
    required this.onStrokeSize,
    required this.onUndo,
    required this.onRedo,
    this.inkTool = AnnotationTool.pen,
    this.height,
    this.heightEnabled = true,
    this.onHeight,
  });

  final AnnotationTool tool;

  /// A ferramenta de tinta em uso (a do poço — R2).
  final AnnotationTool inkTool;

  /// A cor da ferramenta de tinta (o miolo do poço e os pontos da espessura).
  final Color ink;
  final StrokeSize strokeSize;

  /// Com o Marca-texto: a altura do fundo (os 3 pontos viram Baixa/Média/Alta — R18); `null` = a espessura.
  final FillHeight? height;

  /// `false` com Sublinhado ou Ondulado: os pontos ficam a 0,38 e "indisponível" (R18).
  final bool heightEnabled;
  final ValueChanged<FillHeight>? onHeight;
  final bool canUndo, canRedo;
  final VoidCallback onColorWell, onUndo, onRedo;
  final ValueChanged<StrokeSize> onStrokeSize;

  static const List<(AnnotationTool, String, String)> _labels = [
    (AnnotationTool.pen, 'pen', 'Caneta'),
    (AnnotationTool.marker, 'marker', 'Marcador'),
    (AnnotationTool.eraser, 'eraser', 'Borracha'),
    (AnnotationTool.lasso, 'lasso', 'Laço'),
    (AnnotationTool.line, 'line', 'Reta'),
    (AnnotationTool.space, 'space', 'Espaço'),
  ];

  /// R8 (G20): o anúncio da troca de ferramenta ou de cor no modo anotação — "Marca-texto, amarelo", "Caneta, coral";
  /// a Borracha, o Laço e o Espaço só com o nome.
  static String toolAnnouncement(AnnotationTool t, Color c) {
    final name = switch (t) {
      AnnotationTool.pen => 'Caneta',
      AnnotationTool.marker => 'Marca-texto',
      AnnotationTool.line => 'Reta',
      AnnotationTool.eraser => 'Borracha',
      AnnotationTool.lasso => 'Laço',
      AnnotationTool.space => 'Espaço',
    };
    return switch (t) {
      AnnotationTool.eraser ||
      AnnotationTool.lasso ||
      AnnotationTool.space => name,
      _ => '$name, ${colorName(c, pen: t != AnnotationTool.marker)}',
    };
  }

  /// O nome de [c] para o poço (as favoritas da tela 23 e as cores do marca-texto); outra cor = o código
  /// (`#12AB34`). Na caneta ([pen]), só os 6 nomes da tela 23 (R8): o amarelo do marca-texto é o código.
  static String colorName(Color c, {bool pen = false}) {
    final hex = colorHex(c.toARGB32());
    return (pen ? penColorName(hex)?.toLowerCase() : colorNameOf(hex)) ?? hex;
  }

  @override
  Widget build(BuildContext context) {
    final scope = ReaderChromeScope.of(context);
    final p = scope.palette;
    final side = BorderSide(width: AppStrokes.regular, color: p.border);
    return Semantics(
      key: const ValueKey('ann.island'),
      container: true,
      explicitChildNodes: true,
      label: 'Barra de anotação',
      child: NeoBox(
        height: 90,
        color: p.island,
        border: side,
        radius: BorderRadius.circular(26),
        shadow: AppShadows.hard3,
        shadowColor: p.shadow,
        padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ExcludeSemantics(
                child: SizedBox(
                  key: const ValueKey('ann.island.labels'),
                  width: 312,
                  height: 19,
                  child: Row(
                    children: [
                      for (final (t, name, label) in _labels)
                        SizedBox(
                          key: ValueKey('ann.island.labels.$name'),
                          width: 52,
                          height: 19,
                          child: Center(
                            child: t == tool
                                // a pílula do ativo pode passar dos 52 do lugar ("Borracha", "Marcador"):
                                // transborda centrada, como no HTML, sem cortar o texto
                                ? OverflowBox(
                                    maxWidth: double.infinity,
                                    child: NeoBox(
                                      key: ValueKey(
                                        'ann.island.labels.$name.pill',
                                      ),
                                      height: 19,
                                      color: scope.tint(scope.brand),
                                      border: side,
                                      radius: BorderRadius.circular(999),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                      ),
                                      child: Center(
                                        widthFactor: 1,
                                        child: AppText(
                                          label,
                                          style: AppTextStyles.annLabelActive
                                              .copyWith(
                                                color: scope.tint(
                                                  AppColors.ink,
                                                ),
                                              ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  )
                                : AppText(
                                    label,
                                    style: AppTextStyles.annLabel.copyWith(
                                      color: p.label,
                                    ),
                                    maxLines: 1,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 7),
            CustomPaint(
              key: const ValueKey('ann.island.row'),
              // o `border-top: 1.5px dashed #CFC3AE` do arquivo
              painter: ChromiumDashPainter(
                axis: Axis.horizontal,
                color: p.dash,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: AppStrokes.regular + 7),
                child: Row(
                  spacing: 10,
                  children: [
                    _colorWell(scope),
                    _width(context, side),
                    const Expanded(
                      child: SizedBox(
                        key: ValueKey('ann.island.spacer'),
                        height: 0,
                      ),
                    ),
                    _history(
                      context,
                      id: 'ann.island.undo',
                      label: 'Desfazer',
                      icon: AppIconsLeitor.undo,
                      enabled: canUndo,
                      onTap: onUndo,
                    ),
                    _history(
                      context,
                      id: 'ann.island.redo',
                      label: 'Refazer',
                      icon: AppIconsLeitor.redo,
                      enabled: canRedo,
                      onTap: onRedo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorWell(ReaderChromeScope scope) => TapTarget(
    child: Pressable(
      key: const ValueKey('ann.island.colorWell'),
      semanticsLabel: inkTool == AnnotationTool.marker
          ? 'Cor do marca-texto: ${colorName(ink)}. Toque para ajustar o marca-texto'
          : 'Cor da caneta: ${colorName(ink, pen: true)}. Toque para escolher qualquer cor',
      onTap: onColorWell,
      child: CustomPaint(
        painter: ConicRingPainter(
          border: scope.palette.border,
          center: scope.tint(ink),
          centerRadius: 13.5,
          halo: (color: scope.tint(AppColors.surface), width: 2.5),
          alpha: scope.a,
        ),
        child: const SizedBox.square(
          dimension: 42,
          child: Center(
            child: SizedBox.square(
              key: ValueKey('ann.island.colorWell.ink'),
              dimension: 27,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _width(BuildContext context, BorderSide side) {
    final scope = ReaderChromeScope.of(context);
    final p = scope.palette;
    final h = height;
    final enabled = h == null || heightEnabled;
    const sizes = [StrokeSize.thin, StrokeSize.medium, StrokeSize.thick];
    const heights = [FillHeight.low, FillHeight.medium, FillHeight.high];
    return Semantics(
      key: const ValueKey('ann.island.width'),
      container: true,
      explicitChildNodes: true,
      label: h == null ? 'Espessura do traço' : 'Altura do fundo',
      child: NeoBox(
        height: 42,
        color: p.well,
        border: side,
        radius: BorderRadius.circular(999),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 1,
          children: [
            for (final (i, name, label, heightLabel, dot, ring) in const [
              (0, 'thin', 'Fina', 'Baixa', 5.0, 1.0),
              (1, 'medium', 'Média', 'Média', 9.0, 1.2),
              (2, 'thick', 'Grossa', 'Alta', 14.0, 1.4),
            ])
              Builder(
                builder: (context) {
                  final on = h == null
                      ? sizes[i] == strokeSize
                      : heights[i] == h;
                  // apagados (R18): a 0,38, como o Desfazer vazio
                  Color fade(Color c) => enabled
                      ? c
                      : c.withValues(alpha: c.a * islandDisabledAlpha);
                  return TapTarget(
                    child: Pressable(
                      key: ValueKey('ann.island.width.$name'),
                      semanticsLabel: h == null ? label : heightLabel,
                      checked: on,
                      enabled: enabled,
                      onTap: h == null
                          ? () => onStrokeSize(sizes[i])
                          : () => onHeight?.call(heights[i]),
                      child: NeoBox(
                        width: 36,
                        height: 36,
                        color: on ? fade(scope.tint(scope.brand)) : null,
                        border: on
                            ? BorderSide(
                                width: AppStrokes.regular,
                                color: fade(p.border),
                              )
                            : const BorderSide(
                                width: AppStrokes.regular,
                                color: Color(0x00000000),
                              ),
                        radius: BorderRadius.circular(18),
                        child: Center(
                          child: SizedBox.square(
                            key: ValueKey('ann.island.width.$name.dot'),
                            dimension: dot,
                            // o ponto na cor da tinta com o aro fino (`box-shadow: 0 0 0 Npx`)
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: fade(scope.tint(ink)),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: fade(p.border),
                                    spreadRadius: ring,
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _history(
    BuildContext context, {
    required String id,
    required String label,
    required String icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final scope = ReaderChromeScope.of(context);
    final p = scope.palette;
    final alpha = (enabled ? 1.0 : islandDisabledAlpha) * scope.a;
    Color fade(Color c) =>
        enabled ? c : c.withValues(alpha: c.a * islandDisabledAlpha);
    return TapTarget(
      child: Pressable(
        key: ValueKey(id),
        semanticsLabel: label,
        enabled: enabled,
        onTap: onTap,
        child: NeoBox(
          width: 44,
          height: 44,
          color: fade(p.well),
          border: BorderSide(width: AppStrokes.regular, color: fade(p.border)),
          radius: BorderRadius.circular(22),
          child: Center(
            child: AppSvg(
              icon,
              key: ValueKey('$id.icon'),
              size: 20,
              // o arquivo só tem o traço escuro: no Noite, tingido com a cor das letras da ilha
              color: p.night ? fade(p.title) : null,
              opacity: alpha < 1 ? alpha : null,
            ),
          ),
        ),
      ),
    );
  }
}

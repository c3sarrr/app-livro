// G16.6 — a ilha do modo anotação (L22d, "Barra de anotação"): em cima, os rótulos das ferramentas numa grade de 6 ×
// 52 (o ativo numa pílula `brand`; fora do leitor de tela — a prateleira já diz); embaixo do tracejado, o poço de cor
// (o anel cônico com o miolo na cor da tinta e o aro claro), a espessura (Fina/Média/Grossa, a ativa em `brand`) e,
// à direita, Desfazer e Refazer (vazios: a 0,38 e "indisponível"). No Noite (D-167 17), as cores das ilhas do Noite;
// os ícones tingidos com a cor das letras.
import 'package:flutter/widgets.dart';

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
  });

  final AnnotationTool tool;

  /// A cor da caneta (o miolo do poço e os pontos da espessura).
  final Color ink;
  final StrokeSize strokeSize;
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

  /// O nome das cores da tela 23 (as favoritas de fábrica) para o leitor de tela.
  static const Map<String, String> _colorNames = {
    '#FF552E': 'coral',
    '#552CB7': 'roxo',
    '#058CD7': 'azul',
    '#00995E': 'verde',
    '#F2A815': 'dourado',
    '#1A1714': 'tinta preta',
  };

  /// O nome de [c] para o poço; outra cor = o código (`#12AB34`).
  static String colorName(Color c) {
    final hex = colorHex(c.toARGB32());
    return _colorNames[hex] ?? hex;
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
                                ? NeoBox(
                                    key: ValueKey(
                                      'ann.island.labels.$name.pill',
                                    ),
                                    height: 19,
                                    color: scope.brand,
                                    border: side,
                                    radius: BorderRadius.circular(999),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                    ),
                                    child: Center(
                                      widthFactor: 1,
                                      child: AppText(
                                        label,
                                        style: AppTextStyles.annLabelActive,
                                        maxLines: 1,
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
                    _colorWell(p.border),
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

  Widget _colorWell(Color border) => Pressable(
    key: const ValueKey('ann.island.colorWell'),
    semanticsLabel:
        'Cor da caneta: ${colorName(ink)}. Toque para escolher qualquer cor',
    onTap: onColorWell,
    child: CustomPaint(
      painter: ConicRingPainter(
        border: border,
        center: ink,
        centerRadius: 13.5,
        halo: (color: AppColors.surface, width: 2.5),
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
  );

  Widget _width(BuildContext context, BorderSide side) {
    final scope = ReaderChromeScope.of(context);
    final p = scope.palette;
    return Semantics(
      key: const ValueKey('ann.island.width'),
      container: true,
      explicitChildNodes: true,
      label: 'Espessura do traço',
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
            for (final (s, name, label, dot, ring) in const [
              (StrokeSize.thin, 'thin', 'Fina', 5.0, 1.0),
              (StrokeSize.medium, 'medium', 'Média', 9.0, 1.2),
              (StrokeSize.thick, 'thick', 'Grossa', 14.0, 1.4),
            ])
              Pressable(
                key: ValueKey('ann.island.width.$name'),
                semanticsLabel: label,
                checked: s == strokeSize,
                onTap: () => onStrokeSize(s),
                child: NeoBox(
                  width: 36,
                  height: 36,
                  color: s == strokeSize ? scope.brand : null,
                  border: s == strokeSize
                      ? side
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
                          color: ink,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: p.border,
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
    final p = ReaderChromeScope.of(context).palette;
    Color fade(Color c) =>
        enabled ? c : c.withValues(alpha: c.a * islandDisabledAlpha);
    return Pressable(
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
            opacity: enabled ? null : islandDisabledAlpha,
          ),
        ),
      ),
    );
  }
}

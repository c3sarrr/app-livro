// G17.2 — a moldura dos painéis das telas 23 e 23b (L23.1, L23b.1, R1–R5):
// - o véu: o papel da página a 66 % sobre a página e o topo (`rgba(248,241,228,0.66)` no Creme); tocar nele só fecha
//   (R3). A prateleira e a ilha ficam por cima dele, no modo (R4);
// - o painel a 14 das bordas, com a base 22 acima do topo da prateleira (`bottom: 190` na prancha), preenchimento
//   14/16/[bottomPadding] (18 na caneta, 16 no marca-texto), raio 26, fundo `#FFFAF1`, borda 1,5 e sombra dura 4/4;
// - a seta: o quadrado de 16 com as bordas de baixo e da direita, girado 45°, pendurado 9,5 abaixo da caixa de dentro
//   e com o `left` do arquivo ([panelArrowLeft]);
// - o cabeçalho: o título (Bricolage 22/800) e o subtítulo (12,5/600) à esquerda e o fechar de 44 à direita.
// No Noite, as cores da ilha do Noite (R26). Para o leitor de tela, um diálogo com o rótulo do arquivo; o véu e a seta
// ficam fora.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../application/annotation_session.dart' show AnnotationTool;
import 'reader_chrome_scope.dart';

/// A base do painel fica 22 acima do topo da prateleira (`bottom: 190` = 844 − 676 + 22).
const double panelAboveShelf = 22;

/// O véu: o papel da página a 66 %.
const double panelVeilAlpha = 0.66;

/// A seta (o `left` do arquivo, na caixa de dentro do painel): Caneta 42, Marca-texto 95; a Reta, a do marca-texto
/// + 156 (a distância entre as duas ferramentas na prateleira).
double panelArrowLeft(AnnotationTool from) => switch (from) {
  AnnotationTool.marker => 95,
  AnnotationTool.line => 251,
  _ => 42,
};

/// O lado da seta (16 de conteúdo + a borda de 1,5) e quanto ela passa da caixa de dentro (`bottom: −9,5px`).
const double _arrow = 16 + AppStrokes.regular;
const double _arrowBelow = 9.5;

class ToolPanelLayer extends StatelessWidget {
  const ToolPanelLayer({
    super.key,
    required this.id,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.arrowLeft,
    required this.bottom,
    required this.paper,
    required this.onClose,
    required this.child,
    this.bottomPadding = 16,
  });

  /// O começo das chaves (`ann.penPanel`, `ann.markerPanel`).
  final String id;

  /// O rótulo do diálogo ("Ajustes da caneta").
  final String label;
  final String title;
  final String subtitle;
  final double arrowLeft;

  /// A distância da base do painel à base da tela.
  final double bottom;

  /// O papel da página (o véu).
  final Color paper;
  final VoidCallback onClose;
  final Widget child;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final scope = ReaderChromeScope.of(context);
    final p = scope.palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    // a caixa visual da seta girada (o lado × √2), centrada na caixa dela
    const visual = _arrow * math.sqrt2;
    const shift = (visual - _arrow) / 2;
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: onClose,
            child: ColoredBox(
              key: const ValueKey('ann.fade'),
              color: scope.tint(paper.withValues(alpha: panelVeilAlpha)),
            ),
          ),
        ),
        Positioned(
          left: 14,
          right: 14,
          bottom: bottom,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: label,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // o painel segura os toques (não fecham nem chegam à página)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  onTap: () {},
                  child: Container(
                    key: ValueKey(id),
                    padding: EdgeInsets.fromLTRB(16, 14, 16, bottomPadding),
                    decoration: BoxDecoration(
                      color: p.island,
                      border: Border.fromBorderSide(line),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(color: p.shadow, offset: const Offset(4, 4)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [_header(scope, line), child],
                    ),
                  ),
                ),
                Positioned(
                  key: ValueKey('$id.arrow'),
                  left: AppStrokes.regular + arrowLeft - shift,
                  bottom: AppStrokes.regular - _arrowBelow - shift,
                  width: visual,
                  height: visual,
                  child: ExcludeSemantics(
                    child: Center(
                      child: Transform.rotate(
                        angle: math.pi / 4,
                        child: Container(
                          width: _arrow,
                          height: _arrow,
                          decoration: BoxDecoration(
                            color: p.island,
                            border: Border(right: line, bottom: line),
                          ),
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

  Widget _header(ReaderChromeScope scope, BorderSide line) {
    final p = scope.palette;
    return Row(
      key: ValueKey('$id.header'),
      children: [
        IntrinsicWidth(
          child: Column(
            key: ValueKey('$id.header.texts'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                title,
                key: ValueKey('$id.title'),
                style: AppTextStyles.annPanelTitle.copyWith(color: p.title),
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              AppText(
                subtitle,
                key: ValueKey('$id.subtitle'),
                style: AppTextStyles.annPanelSubtitle.copyWith(color: p.muted),
                maxLines: 1,
              ),
            ],
          ),
        ),
        const Spacer(),
        Pressable(
          key: ValueKey('$id.close'),
          semanticsLabel: 'Fechar ajustes',
          onTap: onClose,
          child: NeoBox(
            width: 44,
            height: 44,
            color: p.well,
            border: line,
            radius: BorderRadius.circular(22),
            child: Center(
              child: AppSvg(
                AppIconsLeitor.close,
                key: ValueKey('$id.close.icon'),
                size: 18,
                // o arquivo só tem o traço escuro: no Noite, tingido com a cor das letras da ilha
                color: p.night ? p.title : null,
                opacity: scope.a < 1 ? scope.a : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// G16.6 — a prateleira de ferramentas do modo anotação (L22c): os 6 objetos (50×70, cada um num lugar de 52×70) numa
// fileira de 312×70, atrás da ilha; a ativa sobe 12 px e a caixa de layout fica. Desenho de ativa só na Caneta e no
// Espaço (D-58): a Caneta ativa com o corpo na `brand`; a inativa com o corpo `#FFFAF1`; nas duas, a faixa e a ponta
// na cor da tinta (a troca de cor do SVG — `AppSvg.colors`). As outras só sobem. No Noite, os objetos ficam como no
// Creme (D-167 17). Para o leitor de tela, um grupo de opções "Ferramentas de anotação" com a marcada.
import 'package:flutter/widgets.dart';

import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_illustrations_leitor.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../application/annotation_session.dart' show AnnotationTool;
import 'reader_chrome_scope.dart';

/// Quanto a ferramenta ativa sobe (L22c: `translateY(-12px)`).
const double toolShelfLift = 12;

class ToolShelf extends StatelessWidget {
  const ToolShelf({
    super.key,
    required this.active,
    required this.ink,
    required this.onTool,
  });

  final AnnotationTool active;

  /// A cor da caneta (a faixa e a ponta da Caneta).
  final Color ink;
  final ValueChanged<AnnotationTool> onTool;

  static const List<(AnnotationTool, String, String)> _tools = [
    (AnnotationTool.pen, 'pen', 'Caneta'),
    (AnnotationTool.marker, 'marker', 'Marca-texto'),
    (AnnotationTool.eraser, 'eraser', 'Borracha'),
    (AnnotationTool.lasso, 'lasso', 'Laço — selecionar e mover traços'),
    (AnnotationTool.line, 'line', 'Linha reta'),
    (
      AnnotationTool.space,
      'space',
      'Espaço — arrastar entre as linhas para abrir lugar de escrever',
    ),
  ];

  /// O desenho de [tool] (ativa ou não) e as cores trocadas nele.
  static (String, Map<Color, Color>?) art(
    AnnotationTool tool, {
    required bool on,
    required Color brand,
    required Color ink,
  }) => switch (tool) {
    AnnotationTool.pen when on => (
      AppIllustrationsLeitor.toolPenActive,
      {AppColors.lavender: brand, AppColors.flame: ink},
    ),
    AnnotationTool.pen => (
      AppIllustrationsLeitor.toolPen,
      {AppColors.flame: ink},
    ),
    AnnotationTool.space when on => (
      AppIllustrationsLeitor.toolSpaceActive,
      {AppColors.lavender: brand},
    ),
    AnnotationTool.space => (AppIllustrationsLeitor.toolSpace, null),
    AnnotationTool.marker => (AppIllustrationsLeitor.toolMarker, null),
    AnnotationTool.eraser => (AppIllustrationsLeitor.toolEraser, null),
    AnnotationTool.lasso => (AppIllustrationsLeitor.toolLasso, null),
    AnnotationTool.line => (AppIllustrationsLeitor.toolLine, null),
  };

  @override
  Widget build(BuildContext context) {
    final brand = ReaderChromeScope.of(context).brand;
    return Semantics(
      key: const ValueKey('ann.toolShelf'),
      container: true,
      explicitChildNodes: true,
      label: 'Ferramentas de anotação',
      child: SizedBox(
        width: 312,
        height: 70,
        child: Row(
          children: [
            for (final (tool, name, label) in _tools)
              Builder(
                builder: (context) {
                  final id = 'ann.toolShelf.$name';
                  final on = tool == active;
                  final (asset, colors) = art(
                    tool,
                    on: on,
                    brand: brand,
                    ink: ink,
                  );
                  return SizedBox(
                    key: ValueKey('$id#slot'),
                    width: 52,
                    height: 70,
                    child: Transform.translate(
                      offset: Offset(0, on ? -toolShelfLift : 0),
                      child: Pressable(
                        key: ValueKey(id),
                        semanticsLabel: label,
                        checked: on,
                        onTap: () => onTool(tool),
                        child: SizedBox(
                          width: 52,
                          height: 70,
                          child: Center(
                            child: AppSvg(
                              asset,
                              key: ValueKey('$id.art'),
                              size: 50,
                              height: 70,
                              colors: colors,
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
}

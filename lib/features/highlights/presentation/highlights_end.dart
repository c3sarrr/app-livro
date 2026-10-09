// G19.8 — o fim da lista da tela 25 (L25d) e os vazios (D-198): o cartão tracejado 1,5 de raio 22 (padding 18/16/16)
// com a frase em Instrument Serif itálico 22 (quebra forçada) e o botão preto de 52 "Continuar lendo · pág. N".
// O mesmo cartão serve ao livro sem anotações ("Nenhum grifo ainda.") e, com o botão "Limpar filtros", aos filtros
// sem resultado ("Nada com esses filtros.").
import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/dashed_stadium_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';

/// A margem de cima do cartão do fim (e dos vazios).
const double endGap = 26;

/// Os textos do fim e dos vazios (D-198).
const String endText = 'Daqui para frente,\nas margens ainda estão em branco.';
const String emptyBookText = 'Nenhum grifo ainda.\nAs margens estão em branco.';
const String noResultsText = 'Nada com esses filtros.';
const String clearFiltersText = 'Limpar filtros';

/// "Continuar lendo · pág. N" (sem posição, "Continuar lendo").
String continueText(int? page) =>
    page == null ? 'Continuar lendo' : 'Continuar lendo · pág. $page';

class HighlightsEndCard extends StatelessWidget {
  const HighlightsEndCard({
    super.key,
    this.id = 'hl.end',
    required this.text,
    this.cta,
    this.onCta,
    this.clear = false,
  });

  /// `hl.end` (o fim e o livro sem anotações) ou `hl.empty` (filtros sem resultado).
  final String id;
  final String text;

  /// O texto do botão preto; `null` = sem ele.
  final String? cta;
  final VoidCallback? onCta;

  /// "Limpar filtros" no lugar do botão preto (filtros sem resultado).
  final bool clear;

  @override
  Widget build(BuildContext context) {
    final label = cta;
    return Padding(
      padding: const EdgeInsets.only(top: endGap),
      child: CustomPaint(
        key: ValueKey(id),
        painter: const DashedStadiumPainter(radius: 22, color: AppColors.ink),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16 + AppStrokes.regular,
            18 + AppStrokes.regular,
            16 + AppStrokes.regular,
            16 + AppStrokes.regular,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppText(
                text,
                key: ValueKey('$id.text'),
                style: AppTextStyles.hlEnd,
                textAlign: TextAlign.center,
              ),
              if (clear)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Center(
                    child: Pressable(
                      semanticsLabel: clearFiltersText,
                      onTap: onCta,
                      child: NeoBox(
                        key: ValueKey('$id.clear'),
                        height: 44,
                        color: AppColors.surface,
                        border: const BorderSide(
                          width: AppStrokes.regular,
                          color: AppColors.ink,
                        ),
                        radius: BorderRadius.circular(999),
                        shadow: const Offset(2, 2),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              clearFiltersText,
                              style: AppTextStyles.hlExport,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else if (label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Pressable(
                    semanticsLabel: label,
                    onTap: onCta,
                    child: NeoBox(
                      key: ValueKey('$id.cta'),
                      height: 52,
                      color: AppColors.ink,
                      radius: BorderRadius.circular(999),
                      child: Center(
                        child: AppText(
                          label,
                          key: ValueKey('$id.cta.label'),
                          style: AppTextStyles.hlEndCta,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

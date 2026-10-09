// G19.5 — os separadores da lista da tela 25 (L25c.1): a pílula "pág. N" de 28 (`#FFFAF1`, 12,5/800 com `tnum`) e a
// linha tracejada 1,5 `#CFC3AE` (escondida do leitor de tela), margem de cima 26; o "você parou aqui" (R6): a pílula
// coral de 30 com a sombra 2/2 e a fita `ic_ribbon` 12×15, margem de cima 30; e o "sem lugar no texto" (D-199): a
// pílula como a de página, com o texto em `#8A8073`.
import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/chromium_dash.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';

const BorderSide _line = BorderSide(
  width: AppStrokes.regular,
  color: AppColors.ink,
);

/// A margem de cima do separador comum e do "você parou aqui".
const double sepGap = 26;
const double sepHereGap = 30;

/// O texto do separador cinza dos grifos sem lugar (D-199).
const String orphanSepText = 'sem lugar no texto';

class PageSeparator extends StatelessWidget {
  const PageSeparator({
    super.key,
    required this.id,
    required this.page,
    this.here = false,
  }) : orphan = false;

  /// O separador cinza dos grifos sem lugar (D-199).
  const PageSeparator.orphan({super.key, required this.id})
    : page = 0,
      here = false,
      orphan = true;

  /// `hl.list.sep<n>`.
  final String id;
  final int page;
  final bool here;
  final bool orphan;

  @override
  Widget build(BuildContext context) {
    final Widget label;
    if (here) {
      label = NeoBox(
        key: ValueKey('$id.label'),
        height: 30,
        color: AppColors.flame,
        border: _line,
        radius: BorderRadius.circular(999),
        shadow: const Offset(2, 2),
        padding: const EdgeInsets.fromLTRB(9, 0, 12, 0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            AppSvg(
              AppIconsLeitor.ribbonHint,
              key: ValueKey('$id.label.icon'),
              size: 12,
              height: 15,
            ),
            AppText(
              'pág. $page · você parou aqui',
              style: AppTextStyles.hlSepHere,
              maxLines: 1,
            ),
          ],
        ),
      );
    } else {
      label = NeoBox(
        key: ValueKey('$id.label'),
        height: 28,
        color: AppColors.surface,
        border: _line,
        radius: BorderRadius.circular(999),
        padding: const EdgeInsets.symmetric(horizontal: 11),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              orphan ? orphanSepText : 'pág. $page',
              style: orphan
                  ? AppTextStyles.hlSep.copyWith(color: AppColors.inkSoft)
                  : AppTextStyles.hlSep,
              maxLines: 1,
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(top: here ? sepHereGap : sepGap),
      child: Semantics(
        container: true,
        header: true,
        label: orphan
            ? orphanSepText
            : here
            ? 'página $page, você parou aqui'
            : 'página $page',
        excludeSemantics: true,
        child: SizedBox(
          key: ValueKey(id),
          height: here ? 30 : 28,
          child: Row(
            spacing: 10,
            children: [
              label,
              Expanded(
                child: SizedBox(
                  key: ValueKey('$id.rule'),
                  height: AppStrokes.regular,
                  child: const CustomPaint(
                    painter: ChromiumDashPainter(
                      axis: Axis.horizontal,
                      color: AppColors.dashReader,
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

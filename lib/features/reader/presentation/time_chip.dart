// G12.3 — chip de tempo (`r20.timeChip`, L20c): "N min hoje · contando sozinho" (D-124), 30 de altura, `sun` com
// borda de tinta nos dois temas. É lido pelo leitor de tela.
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/pill.dart';
import 'reader_chrome_scope.dart';

class TimeChip extends StatelessWidget {
  const TimeChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final s = ReaderChromeScope.of(context);
    final ink = s.tint(AppColors.ink);
    return Semantics(
      container: true,
      child: Pill(
        key: const ValueKey('r20.timeChip'),
        padding: const EdgeInsets.fromLTRB(9, 0, 12, 0),
        color: s.tint(AppColors.sun),
        border: BorderSide(width: AppStrokes.regular, color: ink),
        child: SizedBox(
          height: 27, // 30 − 2 × 1,5
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              AppSvg(
                AppIconsLeitor.timer,
                key: const ValueKey('r20.timeChip.icon'),
                size: 15,
                opacity: s.a,
              ),
              AppText(
                label,
                style: AppTextStyles.readerChip.copyWith(color: ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

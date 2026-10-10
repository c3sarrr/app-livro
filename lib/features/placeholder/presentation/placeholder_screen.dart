import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../shell/presentation/shell_insets.dart';

/// Placeholder das abas Biblioteca/Clubes/Perfil (D-07), do Scanner (D-08) e das rotas-destino:
/// fundo `#F7F0E3` + `SafeArea` + título centralizado em Bricolage 24 (`sectionTitleL`). Nada além disso —
/// exceto [below] (D-69: o bloco mínimo da conta na aba Perfil), que fica ABAIXO do título sem tirá-lo do
/// centro e acima da barra de navegação flutuante.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen(this.title, {super.key, this.below});

  final String title;
  final Widget? below;

  /// Folga sobre a barra de navegação flutuante (70 + 30 da barra + 16); com a mini-barra do cronômetro, + 96
  /// (`ShellInsets`, D-259: 116 → 212).
  static const double _navClearance =
      AppSpacing.navHeight + AppSpacing.navBottomMin + 16;

  @override
  Widget build(BuildContext context) {
    final heading = Center(
      child: Semantics(
        container: true,
        header: true,
        child: AppText(title, style: AppTextStyles.sectionTitleL),
      ),
    );
    final extra = below;
    return ColoredBox(
      color: AppColors.paper,
      child: SafeArea(
        child: extra == null
            ? heading
            : LayoutBuilder(
                builder: (context, c) => Stack(
                  children: [
                    heading,
                    Positioned(
                      left: AppSpacing.gutter,
                      right: AppSpacing.gutter,
                      top: c.maxHeight / 2 + 32,
                      bottom:
                          _navClearance + ShellInsets.extraBottomOf(context),
                      child: SingleChildScrollView(child: extra),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

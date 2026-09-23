import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_typography.dart';

/// Placeholder das abas Biblioteca/Clubes/Perfil (D-07), do Scanner (D-08) e das rotas-destino:
/// fundo `#F7F0E3` + `SafeArea` + título centralizado em Bricolage 24 (`sectionTitleL`). Nada além disso.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.paper,
    child: SafeArea(
      child: Center(
        child: Semantics(
          container: true,
          header: true,
          child: AppText(title, style: AppTextStyles.sectionTitleL),
        ),
      ),
    ),
  );
}

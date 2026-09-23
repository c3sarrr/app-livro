import 'dart:ui';

/// Deslocamentos das sombras duras (`box-shadow: X Y 0 #1A1714`).
abstract final class AppShadows {
  static const Offset hard4 = Offset(4, 4); // hero, cartão do dia
  static const Offset hard3 = Offset(3, 3); // capa Dom Casmurro
  static const Offset hard2 = Offset(2, 2); // capas de "Também lendo"
  static const Offset drop4 = Offset(0, 4); // navegação e FAB
  // SEMPRE BoxShadow(color: AppColors.ink, offset: X, blurRadius: 0, spreadRadius: 0)
}

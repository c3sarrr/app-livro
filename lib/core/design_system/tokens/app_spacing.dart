/// Espaçamentos estruturais da tela Início (px CSS = dp lógico).
abstract final class AppSpacing {
  static const double gutter = 20; // padding lateral do main
  static const double topInsetMin = 62; // padding-top do main (ver D-02)
  static const double bottomPadding = 140; // padding-bottom do main
  // margin-top de cada seção, na ordem: headline, hero, também lendo, dia, para você, clube, recém-chegados
  static const List<double> sectionGaps = [24, 24, 32, 36, 40, 40, 40];
  static const double navSide = 16, navBottomMin = 30, navHeight = 70;
}

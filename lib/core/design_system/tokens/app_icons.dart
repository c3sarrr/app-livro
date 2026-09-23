/// Ícones SVG do arquivo (`assets/icons/`, cópias exatas de `design_handoff/assets/icons`).
/// As cores já estão nos SVGs: nunca aplicar `colorFilter`. Tamanho de uso entre parênteses.
abstract final class AppIcons {
  /// (22) Sino.
  static const bell = 'assets/icons/ic_bell.svg';

  /// (30) Brilho grande do hero.
  static const sparkleOutline = 'assets/icons/ic_sparkle_outline.svg';

  /// (14/16) Brilhos sólidos.
  static const sparkleSolid = 'assets/icons/ic_sparkle_solid.svg';

  /// (20) CTA "Continuar lendo" (traço #F7F0E3).
  static const bookOpen = 'assets/icons/ic_book_open.svg';

  /// (22) Botão destaques.
  static const highlighter = 'assets/icons/ic_highlighter.svg';

  /// (17) Sequência.
  static const flame = 'assets/icons/ic_flame.svg';

  /// (18) "Ver tudo", "Biblioteca" (traço 2).
  static const arrowRight = 'assets/icons/ic_arrow_right.svg';

  /// (18) "Abrir discussão" (traço #F7F0E3).
  static const messageCircle = 'assets/icons/ic_message_circle.svg';

  /// (20) "Mais opções".
  static const moreHorizontal = 'assets/icons/ic_more_horizontal.svg';

  /// (22) Aba Início ativa (preenchimento #FFFAF1).
  static const navHomeActive = 'assets/icons/ic_nav_home_active.svg';

  /// (22)
  static const navLibrary = 'assets/icons/ic_nav_library.svg';

  /// (28) Traço 1,9.
  static const navScanner = 'assets/icons/ic_nav_scanner.svg';

  /// (22)
  static const navClubs = 'assets/icons/ic_nav_clubs.svg';

  /// (22)
  static const navProfile = 'assets/icons/ic_nav_profile.svg';

  // D-07 (extrapolados, só quando outra aba estiver ativa)
  static const navHome = 'assets/icons/_extrapolado_ic_nav_home.svg';
  static const navLibraryActive =
      'assets/icons/_extrapolado_ic_nav_library_active.svg';
  static const navClubsActive =
      'assets/icons/_extrapolado_ic_nav_clubs_active.svg';
  static const navProfileActive =
      'assets/icons/_extrapolado_ic_nav_profile_active.svg';

  static const all = [
    bell,
    sparkleOutline,
    sparkleSolid,
    bookOpen,
    highlighter,
    flame,
    arrowRight,
    messageCircle,
    moreHorizontal,
    navHomeActive,
    navLibrary,
    navScanner,
    navClubs,
    navProfile,
    navHome,
    navLibraryActive,
    navClubsActive,
    navProfileActive,
  ];
}

import 'dart:ui';

/// Todas as cores do arquivo (e somente elas). Alphas: `round(a × 255)`.
abstract final class AppColors {
  // Base

  /// Fundo da tela, entalhes do ticket, texto claro sobre tinta.
  static const Color paper = Color(0xFFF7F0E3);

  /// Texto principal, TODAS as bordas, sombras duras.
  static const Color ink = Color(0xFF1A1714);

  /// Cartões/botões claros, trilhas.
  static const Color surface = Color(0xFFFFFAF1);

  /// Texto secundário.
  static const Color inkMuted = Color(0xFF5B544B);

  /// Texto secundário sobre o cartão lavanda (autor, tempo restante).
  static const Color inkPlum = Color(0xFF2F2A40);

  /// Legenda "de 30 min", texto do selo "Novo".
  static const Color inkWarm = Color(0xFF4A4238);

  // Paleta

  /// Brand padrão e weekColor padrão; capa O Alienista; lua do Frankenstein.
  static const Color lavender = Color(0xFFB6ACE4);

  /// Avatar, cartão do dia, FAB, sol da capa, arco O Cortiço, badge 14, marcador "M".
  static const Color sun = Color(0xFFFED170);

  /// Ponto do sino, chama, pino do dial, barra de hoje, capa Memórias, badge 3.
  static const Color flame = Color(0xFFFF552E);

  /// Capa Mrs. Dalloway, avatar J.
  static const Color leaf = Color(0xFFABCF82);

  /// Capa Orgulho, pílula do clube, avatar L, canhoto, progresso do grupo.
  static const Color blush = Color(0xFFFFC1C6);

  /// Capa Dom Casmurro.
  static const Color violet = Color(0xFF552CB7);

  /// Capa Quincas Borba.
  static const Color azure = Color(0xFF058CD7);

  /// Capa O Cortiço.
  static const Color emerald = Color(0xFF00995E);

  /// Mini-capa Senhora.
  static const Color amber = Color(0xFFF2A815);

  /// Trilho dos anéis de progresso.
  static const Color ringTrack = Color(0xFFEAE1CF);

  /// Listra da hachura.
  static const Color hatch = Color(0xFFEFE6D4);

  /// Listra da hachura da barra "Hoje".
  static const Color hatchToday = Color(0xFFFDE2B2);

  /// "ENCONTRO".
  static const Color stubLabel = Color(0xFF4A2F33);

  /// Divisores da lista Recém-chegados.
  static const Color divider = Color(0xFFE9E1D2);

  static const Color tagLavenderBg = Color(0xFFECE7FA);
  static const Color tagLavenderFg = Color(0xFF3B2D86);
  static const Color tagSandBg = Color(0xFFEFE7D7);

  // Translúcidas

  /// rgba(0,0,0,.22) lombada Dom Casmurro.
  static const Color spine22 = Color(0x38000000);

  /// rgba(0,0,0,.18) lombadas Quincas / Cortiço.
  static const Color spine18 = Color(0x2E000000);

  /// rgba(0,0,0,.15) lombadas Mrs. Dalloway / Memórias.
  static const Color spine15 = Color(0x26000000);

  /// rgba(0,0,0,.12) lombadas Orgulho / O Alienista / Senhora.
  static const Color spine12 = Color(0x1F000000);

  /// rgba(26,23,20,.14) círculos decorativos do cartão do dia.
  static const Color decoRing = Color(0x241A1714);

  /// rgba(255,250,241,.7) chips "24 páginas" / "2 destaques".
  static const Color chipGlass = Color(0xB3FFFAF1);

  /// Tinta com opacity .45 (linha tracejada da meta).
  static const Color goalLine = Color(0x731A1714);

  /// Tinta com opacity .35 (marcações do dial).
  static const Color dialTick = Color(0x591A1714);

  /// Início do fade inferior.
  static const Color paperTransparent = Color(0x00F7F0E3);

  // Opções de tema do arquivo (props do componente)
  static const List<Color> brandOptions = [
    Color(0xFFB6ACE4),
    Color(0xFFFFC1C6),
    Color(0xFFABCF82),
    Color(0xFFFED170),
  ];
  static const List<Color> weekColorOptions = [
    Color(0xFFB6ACE4),
    Color(0xFFFFB39E),
    Color(0xFFF2A815),
    Color(0xFFABCF82),
  ];
}

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

  // Leitor (telas 19–27b): papéis e texto do livro (Anexo 01 §0, Anexo 03 §7.1) e rodapé (D-110)

  /// Papel Creme (tela 19) e o texto do livro nele.
  static const Color paperCream = Color(0xFFF8F1E4);
  static const Color bookText = Color(0xFF2A2520);

  /// Papel Branco (o texto do livro nele é [ink]).
  static const Color paperWhite = Color(0xFFFFFDF8);

  /// Papel Sépia (D-51 b) e o texto do livro nele.
  static const Color paperSepia = Color(0xFFEEDDBF);
  static const Color bookTextSepia = Color(0xFF4A3622);

  /// Papel Noite (tela 26b) e o texto do livro nele.
  static const Color paperNight = Color(0xFF1F1B17);
  static const Color bookTextNight = Color(0xFFE3D9C6);

  /// "pág. X de Y · %": Creme (tela 19) e Noite (26b) medidos; Branco e Sépia com o contraste do Creme (D-110).
  static const Color readerFooter = Color(0xFFA89D8B);
  static const Color readerFooterWhite = Color(0xFFA9A6A2);
  static const Color readerFooterSepia = Color(0xFFA08E74);
  static const Color readerFooterNight = Color(0xFF8A8073);

  // Leitor — ilhas dos controles (telas 20 e 26b, G12; medidas no arquivo — L20a/L20b/L26b).
  /// Hachura da barra de posição (`#E9DFCC` sobre `#FFFAF1`).
  static const Color hatchReader = Color(0xFFE9DFCC);

  /// Tracejado acima das ferramentas.
  static const Color dashReader = Color(0xFFCFC3AE);

  /// Noite: fundo das ilhas, tinta clara (borda, título, rótulos), sombra dura, texto apagado.
  static const Color islandNight = Color(0xFF2A2520);
  static const Color inkNight = Color(0xFFEDE3D1);
  static const Color shadowNight = Color(0xFF0B0A08);
  static const Color mutedNight = Color(0xFFB5AA98);

  /// Rótulos pequenos do leitor nos papéis claros ("GRIFAR", "NOTA" — L21b nº 3).
  static const Color labelReader = Color(0xFF6F665B);
  static const Color hatchNight = Color(0xFF3A332B);
  static const Color dashNight = Color(0xFF4A433A);

  /// Legendas dos cartões de fonte fora da escolhida (L26 `rs.sheet.fonts.*.caption`; "inkSoft" da L00).
  static const Color inkSoft = Color(0xFF8A8073);

  /// Legenda do cartão de fonte escolhido, sobre a `brand` (L26).
  static const Color captionOnBrand = Color(0xFF3B3466);

  /// As duas linhas dos cartões de papel (L26 `rs.sheet.papers.*.line*`); as do Noite são o [dashNight].
  static const Color paperLineCream = Color(0xFFD9CCB4);
  static const Color paperLineWhite = Color(0xFFE3DCCD);
  static const Color paperLineSepia = Color(0xFFCDB48C);

  /// Noite: véu da página (a 55 %).
  static const Color veilNight = Color(0xFF14110E);

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

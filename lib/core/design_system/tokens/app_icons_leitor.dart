// G11 — ícones das telas do leitor (19–27b), exportados do arquivo novo na G01.8 (`assets/icons/leitor/`,
// catálogo em `handoff_v2/referencia/svg_catalogo.json`). As cores já estão nos SVGs (as variantes `_noite` são as
// da tela 26b). Cada fase registra os que usa; o tamanho de uso entre parênteses. Os que o arquivo não desenha
// (extrapolados, como os `_extrapolado_` da Início) ficam em `assets/icons/leitor_extra/`, fora do catálogo da G01.
abstract final class AppIconsLeitor {
  static const _d = 'assets/icons/leitor';

  /// (20) "Fechar o livro" (`r20.topIsland.close`); (16) "Voltar à pág. N" (D-108).
  static const arrowLeft = '$_d/ic_arrow_left.svg';
  static const arrowLeftNight = '$_d/ic_arrow_left_noite.svg';

  /// (21) "Buscar no livro" (`r20.topIsland.search`).
  static const search = '$_d/ic_search.svg';
  static const searchNight = '$_d/ic_search_noite.svg';

  /// (22×24) fita "Página marcada" (`r20.topIsland.bookmark`); desmarcada = só o contorno (D-124, extrapolado).
  static const ribbonMarked = '$_d/ic_ribbon_marked.svg';
  static const ribbonMarkedNight = '$_d/ic_ribbon_marked_noite.svg';
  static const ribbonEmpty =
      'assets/icons/leitor_extra/_extrapolado_ic_ribbon_empty.svg';
  static const ribbonEmptyNight =
      'assets/icons/leitor_extra/_extrapolado_ic_ribbon_empty_noite.svg';

  /// (21) Tema: sol nos papéis claros, lua no Noite (D-37).
  static const sun = '$_d/ic_sun.svg';
  static const moon = '$_d/ic_moon.svg';

  /// (21) Grifos, Anotar, Sumário (`r20.bottomIsland.tools.*`).
  static const highlighter = '$_d/ic_highlighter_reader.svg';
  static const highlighterNight = '$_d/ic_highlighter_reader_noite.svg';
  static const annotate = '$_d/ic_annotate.svg';
  static const annotateNight = '$_d/ic_annotate_noite.svg';
  static const toc = '$_d/ic_toc.svg';
  static const tocNight = '$_d/ic_toc_noite.svg';

  /// (15) chip "N min hoje · contando sozinho" (`r20.timeChip.icon`).
  static const timer = '$_d/ic_timer.svg';

  /// (×) limpar a busca (D-120).
  static const close = '$_d/ic_close.svg';

  /// (20) Nota, Copiar e Compartilhar da barra de ações (`r21.toolbar.actions.*`); a Busca usa [search]. Sem versão
  /// do Noite: lá são tingidos com a cor da borda (G13). O `ic_underline` do arquivo tem um `<text>`: o ícone do
  /// Sublinhar é pintado (`UnderlineIconPainter`).
  static const note = '$_d/ic_note.svg';
  static const copy = '$_d/ic_copy.svg';
  static const share = '$_d/ic_share.svg';

  /// (8) "+" do miolo de "Escolher outra cor" (`r21.toolbar.colors.other.icon`).
  static const plusTiny = '$_d/ic_plus_tiny.svg';

  /// (18) fechar a folha de ajustes (`rs.sheet.close.icon`); (12) o ✓ do papel escolhido
  /// (`rs.sheet.papers.*.check.icon`, sobre a `brand`).
  static const closeRound = '$_d/ic_close_round.svg';
  static const checkSmall = '$_d/ic_check_small.svg';

  /// (18) Entrelinha e Margens da folha (`rs.sheet.spacing.*.icon`, `rs.sheet.margins.*.icon`). Sem versão do Noite:
  /// lá são tingidos com a cor do título, menos no escolhido (sobre a `brand`) — G14.
  static const spacingTight = '$_d/ic_spacing_tight.svg';
  static const spacingMedium = '$_d/ic_spacing_medium.svg';
  static const spacingLoose = '$_d/ic_spacing_loose.svg';
  static const marginsNarrow = '$_d/ic_margins_narrow.svg';
  static const marginsMedium = '$_d/ic_margins_medium.svg';
  static const marginsWide = '$_d/ic_margins_wide.svg';

  /// G15 — folha do sumário (telas 27/27b): (18) bandeira e (16) seta da faixa do clube; (11×13 nas abas, 20×22 nos
  /// cartões) a fita coral; (9×11) a fita da pílula "você está na pág. N"; (11×13) a fita da dica; (11) o ✓ do "lido";
  /// (9) a caneta coral da nota à mão nas marcas. Sem versão do Noite: os de traço são tingidos com a cor da borda.
  static const flag = '$_d/ic_flag.svg';
  static const chevronRight = '$_d/ic_chevron_right.svg';
  static const ribbonCoral = '$_d/ic_ribbon_coral.svg';
  static const ribbonTiny = '$_d/ic_ribbon_tiny.svg';
  static const ribbonHint = '$_d/ic_ribbon.svg';
  static const checkRead = '$_d/ic_check_read.svg';
  static const pencilCoral = '$_d/ic_pencil_coral.svg';

  /// G16 — modo anotação (tela 22): (19) o lápis da pílula do modo (`ann.modePill.icon`) e o ✓ do Concluir
  /// (`ann.done.icon`); (20) Desfazer e Refazer da ilha (`ann.island.undo.icon`, `ann.island.redo.icon`). Sem versão
  /// do Noite: lá são tingidos com a cor das letras da ilha.
  static const pencil = '$_d/ic_pencil.svg';
  static const check = '$_d/ic_check.svg';
  static const undo = '$_d/ic_undo.svg';
  static const redo = '$_d/ic_redo.svg';

  static const all = [
    arrowLeft,
    arrowLeftNight,
    search,
    searchNight,
    ribbonMarked,
    ribbonMarkedNight,
    ribbonEmpty,
    ribbonEmptyNight,
    sun,
    moon,
    highlighter,
    highlighterNight,
    annotate,
    annotateNight,
    toc,
    tocNight,
    timer,
    close,
    note,
    copy,
    share,
    plusTiny,
    closeRound,
    checkSmall,
    spacingTight,
    spacingMedium,
    spacingLoose,
    marginsNarrow,
    marginsMedium,
    marginsWide,
    flag,
    chevronRight,
    ribbonCoral,
    ribbonTiny,
    ribbonHint,
    checkRead,
    pencilCoral,
    pencil,
    check,
    undo,
    redo,
  ];
}

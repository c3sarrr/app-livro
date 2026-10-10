// T02 — os ícones novos da Início nova e da revisão (telas 01, 01b, 60–63), exportados do arquivo da Início na T02
// (`assets/icons/inicio2/`, catálogo em `docs/design/medicao/inicio2/svg_catalogo.json`). As cores já estão nos SVGs.
// Os que o arquivo repete da Início v1 (sino, brilhos, livro aberto, marca-texto, chama, seta, balão, ⋯ e a barra) e
// do leitor (`ic_share`, `ic_close_round`) continuam em `AppIcons` e `AppIconsLeitor` (reuso por C14N, R4). O tamanho
// de uso entre parênteses; os ids das pranchas depois.
abstract final class AppIconsInicio {
  static const _d = 'assets/icons/inicio2';

  /// (22) Lupa do cabeçalho (`i01.header.search`).
  static const search = '$_d/ic_search_home.svg';

  /// (12) Livro de papel no meta do Também lendo (`i01.alsoReading.card*.meta`).
  static const bookPaper = '$_d/ic_book_paper.svg';

  /// (18) "play" amarelo do livro de papel (`i01.alsoReading.card1.play`, 01 e 60).
  static const play = '$_d/ic_play.svg';

  /// (16) O mesmo botão em sessão: "pausar" amarelo (`i01b.alsoReading.card1.play`).
  static const pause = '$_d/ic_pause.svg';

  /// (18) "pausar" tinta da mini-barra (`i01b.miniBar.pause`).
  static const pauseInk = '$_d/ic_pause_tinta.svg';

  /// (17) Cronômetro do "Ler agora" (`i01.today.readNow`).
  static const stopwatch = '$_d/ic_stopwatch.svg';

  /// (26) Brilho com contorno do cartão "Seus grifos de hoje" (`i01.review.art.sparkle`).
  static const sparkleYellow = '$_d/ic_sparkle_amarelo.svg';

  /// (15) Brilho cheio do "Revisar" (`i01.review.cta`).
  static const sparkleSolidYellow = '$_d/ic_sparkle_solid_amarelo.svg';

  /// (16) Brilho da pílula "7 dias seguidos revisando" (`rv62.summary.streakPill`).
  static const sparkleBadge = '$_d/ic_sparkle_selo.svg';

  /// (30) Brilho da prévia da imagem (`rv63.sheet.preview.sparkle`).
  static const sparklePreview = '$_d/ic_sparkle_previa.svg';

  /// (9) Brilho creme da marca no rodapé da prévia (`rv63.sheet.preview.footer.brand`).
  static const sparkleSolidCream = '$_d/ic_sparkle_solid_creme.svg';

  /// (20) Fechar a revisão (`rv61.header.close`, `rv62.header.close`).
  static const closeBold = '$_d/ic_close_bold.svg';

  /// (18) "Menos vezes" e "Mais vezes" (`rv61.actions.less/more`).
  static const minus = '$_d/ic_minus.svg';
  static const plusBold = '$_d/ic_plus_bold.svg';

  /// (20) Escrever uma nota (`rv61.actions.note`).
  static const pencilEdit = '$_d/ic_pencil_edit.svg';

  /// (18) Seta amarela do "Próximo" (`rv61.actions.next`).
  static const arrowNext = '$_d/ic_arrow_next.svg';

  /// (10) Visto dos cinco cartões conferidos (`rv62.summary.art.card*.check`).
  static const checkTiny = '$_d/ic_check_tiny.svg';

  /// (18) Calendário da próxima revisão (`rv62.summary.tomorrow`).
  static const calendar = '$_d/ic_calendar.svg';

  /// (19) Livro aberto amarelo do "Voltar a ler · pág. N" (`rv62.footer.cta`).
  static const bookRead = '$_d/ic_book_read.svg';

  /// (22) As ações da folha "Compartilhar grifo": Salvar, Stories, Copiar texto, Mais (`rv63.sheet.actions.*`).
  static const download = '$_d/ic_download.svg';
  static const stories = '$_d/ic_stories.svg';
  static const copyText = '$_d/ic_copy_text.svg';
  static const moreCircles = '$_d/ic_more_circles.svg';

  static const all = [
    search,
    bookPaper,
    play,
    pause,
    pauseInk,
    stopwatch,
    sparkleYellow,
    sparkleSolidYellow,
    sparkleBadge,
    sparklePreview,
    sparkleSolidCream,
    closeBold,
    minus,
    plusBold,
    pencilEdit,
    arrowNext,
    checkTiny,
    calendar,
    bookRead,
    download,
    stories,
    copyText,
    moreCircles,
  ];
}

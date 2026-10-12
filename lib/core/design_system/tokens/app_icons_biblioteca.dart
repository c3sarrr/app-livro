// T13.11 (R7) — os ícones novos da T14 · Biblioteca (telas 02, 17, 17b, 36), em `assets/icons/biblioteca/` (D-284: a
// pasta da área da 1ª etapa que usa o desenho). Gerado por `tools/medicao/gen_classes_svg.py` do catálogo
// `docs/design/medicao/projeto/svg_catalogo.json` — não editar à mão. As cores já estão nos SVGs (cada variante de cor
// é um arquivo); o tamanho de uso entre parênteses, depois a descrição e os ids das pranchas. Os reusados (D-283: o
// mesmo desenho de um asset que já existia) continuam nas classes de antes: `AppIcons.navHome`;
// `AppIcons.navLibraryActive`; `AppIcons.arrowRight`; `AppIcons.bookOpen`; `AppIcons.highlighter`;
// `AppIcons.navClubs`; `AppIcons.navProfile`; `AppIcons.navScanner`; `AppIcons.sparkleSolid`;
// `AppIconsInicio.bookPaper`; `AppIconsInicio.moreCircles`; `AppIconsInicio.sparkleYellow`;
// `AppIconsLeitor.arrowLeft`; `AppIconsLeitor.search`; `AppIconsLeitor.share`.
abstract final class AppIconsBiblioteca {
  static const _d = 'assets/icons/biblioteca';

  /// (14) Livro fechado do formato (meta dos Detalhes) (`d17.meta.format.icon`).
  static const bookClosed = '$_d/ic_book_closed.svg';

  /// (14) Câmera (foto do trecho) (`d17.highlights.quote.caption.icon`).
  static const camera = '$_d/ic_camera.svg';

  /// (20) Câmera com setas (trocar a capa) (`d17.cover.change.icon`, `d17b.cover.change.icon`,
  /// `bu28d.cover.preview.change.icon`).
  static const cameraSwap = '$_d/ic_camera_swap.svg';

  /// (18) Câmera (foto do trecho) (`d17.highlights.photograph.icon`).
  static const cameraTinta = '$_d/ic_camera_tinta.svg';

  /// (12; 13) Check de traço 3 (lido) (`b02.shelf.book5.info.tag.icon`, `b02.shelf.book8.info.tag.icon`,
  /// `b02.shelf.book9.info.tag.icon` e mais 2).
  static const checkBold = '$_d/ic_check_bold.svg';

  /// (16) Chevron para baixo (`b02.sortView.sort.chevron`).
  static const chevronDown = '$_d/ic_chevron_down.svg';

  /// (16,43×20, atributos 20; 18) Chevron para a direita do clube (traço 2,4) (`d17.highlights.club.chevron`,
  /// `bu28b.scanCard.chevron`, `e36a.club.chevron`). Armadilha em `d17.highlights.club.chevron`: o `<svg>` de 20×20
  /// (atributos) não tem flex-shrink: 0 e encolhe na linha que não cabe: fica 16,43×20 no layout, e o desenho (viewBox
  /// 24×24, preserveAspectRatio meet) sai 16,43×16,43, centrado na altura. A prancha mostra o ícone menor — decidir na
  /// T14 se o app repete o encolhimento (o tamanho do catálogo) ou usa o dos atributos.
  static const chevronRightClube = '$_d/ic_chevron_right_clube.svg';

  /// (18; 16) Arquivo com seta para baixo (importar e-book) (`b36.actions.ebook.icon`,
  /// `e36a.firstBook.shortcuts.ebook.icon`).
  static const fileDownload = '$_d/ic_file_download.svg';

  /// (22) Filtros (dois controles deslizantes) (`b02.search.filters.icon`).
  static const filters = '$_d/ic_filters.svg';

  /// (14; 18) Marca-texto de traço 2 (grifos do livro) (`b02.shelf.book7.info.notes.icon`,
  /// `p05.activity.item2.icon.art`, `aj56.visibility.list.highlights.icon.art`).
  static const highlighterBold = '$_d/ic_highlighter_bold.svg';

  /// (14) Lápis sobre a linha (atualizar a página) (`d17.session.page.update.icon`).
  static const pencilLine = '$_d/ic_pencil_line.svg';

  /// (22) "+" do cabeçalho (adicionar livro) (`b02.header.add.icon`).
  static const plusCabecalho = '$_d/ic_plus_cabecalho.svg';

  /// (20) Escanear código de barras (moldura com barras) (`b36.actions.scan.icon`).
  static const scanBarcode = '$_d/ic_scan_barcode.svg';

  /// (18) Ordenar (setas para cima e para baixo) (`b02.sortView.sort.icon`).
  static const sort = '$_d/ic_sort.svg';

  /// (26; 30) Brilho com contorno (`d17.cover.sparkleLarge`, `d17b.cover.sparkleLarge`, `e35.sparkleLarge` e mais 2).
  static const sparkleCreme = '$_d/ic_sparkle_creme.svg';

  /// (21) Cronômetro amarelo (começar a ler) (`d17.session.start.icon`, `sc42.sheet.actions.primary.icon`).
  static const stopwatchAmarelo = '$_d/ic_stopwatch_amarelo.svg';

  /// (14) Leitor digital (formato e-book, traço 2,2) (`d17b.cover.formatTag.icon`).
  static const tablet = '$_d/ic_tablet.svg';

  /// (14) Leitor digital do formato (meta dos Detalhes, traço 2) (`d17b.meta.format.icon`).
  static const tabletMeta = '$_d/ic_tablet_meta.svg';

  /// (18) Ver em grade (`b02.sortView.toggle.grid.icon`).
  static const viewGrid = '$_d/ic_view_grid.svg';

  /// (18) Ver em lista (`b02.sortView.toggle.list.icon`).
  static const viewList = '$_d/ic_view_list.svg';

  static const all = <String>[
    bookClosed,
    camera,
    cameraSwap,
    cameraTinta,
    checkBold,
    chevronDown,
    chevronRightClube,
    fileDownload,
    filters,
    highlighterBold,
    pencilLine,
    plusCabecalho,
    scanBarcode,
    sort,
    sparkleCreme,
    stopwatchAmarelo,
    tablet,
    tabletMeta,
    viewGrid,
    viewList,
  ];
}

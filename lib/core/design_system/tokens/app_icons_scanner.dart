// T13.11 (R7) — os ícones novos da T15 · Scanner e busca (telas 03, 28, 28b, 28c, 28d, 39, 40, 41, 42, 69, 69b), em
// `assets/icons/scanner/` (D-284: a pasta da área da 1ª etapa que usa o desenho). Gerado por
// `tools/medicao/gen_classes_svg.py` do catálogo `docs/design/medicao/projeto/svg_catalogo.json` — não editar à mão.
// As cores já estão nos SVGs (cada variante de cor é um arquivo); o tamanho de uso entre parênteses, depois a
// descrição e os ids das pranchas. Os reusados (D-283: o mesmo desenho de um asset que já existia) continuam nas
// classes de antes: `AppIconsInicio.checkTiny`; `AppIconsInicio.closeBold`; `AppIconsLeitor.arrowLeft`;
// `AppIconsLeitor.checkSmall`; `AppIconsLeitor.close`; `AppIconsLeitor.people`; `AppIconsLeitor.searchGray`.
abstract final class AppIconsScanner {
  static const _d = 'assets/icons/scanner';

  /// (17) Alerta (!) no círculo (`sc69b.sticker.card.alert.icon`).
  static const alert = '$_d/ic_alert.svg';

  /// (13) Alerta (!) pequeno do chip (`sc40.sheet.chip.icon`).
  static const alertSmall = '$_d/ic_alert_small.svg';

  /// (18; 19) Seta papel (abrir o livro) (`bu28b.books.result1.open.icon`, `e36a.firstBook.cta.icon`).
  static const arrowNextPapel = '$_d/ic_arrow_next_papel.svg';

  /// (26) Apagar (teclado do sistema, R8) (`sc69.keypad.delete.icon`, `sc69b.keypad.delete.icon`). Armadilha: a tecla
  /// de apagar do teclado do sistema (R8, informativo): o app não desenha o teclado; fica como referência.
  static const backspace = '$_d/ic_backspace.svg';

  /// (18) Código de barras (modo código) (`sc03.controls.mode.code.icon`, `sc39.controls.mode.code.icon`,
  /// `sc40.controls.mode.code.icon` e mais 4).
  static const barcode = '$_d/ic_barcode.svg';

  /// (14) Livro (tipo do adesivo) (`sc69.sticker.card.kind.icon`, `sc69b.sticker.card.kind.icon`).
  static const bookSimple = '$_d/ic_book_simple.svg';

  /// (19) Câmera (tirar foto da capa) (`bu28d.cover.options.camera.icon`).
  static const cameraCapa = '$_d/ic_camera_capa.svg';

  /// (18; 14; 16) Check de traço 3 em tinta (`bu28b.clubs.club1.member.icon`, `p64.genres.classics.icon`,
  /// `p64.genres.romance.icon` e mais 3).
  static const checkBoldTinta = '$_d/ic_check_bold_tinta.svg';

  /// (13) Check amarelo do chip de status (`sc03.status.chip.badge.icon`, `sc40.status.chip.badge.icon`,
  /// `sc42.status.chip.badge.icon`).
  static const checkReadAmarelo = '$_d/ic_check_read_amarelo.svg';

  /// (20) Chevron para a direita (traço 2) (`sc03.sheet.book.chevron`, `sc42.sheet.book.chevron`).
  static const chevronRightFino = '$_d/ic_chevron_right_fino.svg';

  /// (18) Colar (prancheta) (`sc69.toolbar.paste.icon`).
  static const clipboard = '$_d/ic_clipboard.svg';

  /// (16) Relógio (buscas recentes) (`bu28.recent.item1.icon`, `bu28.recent.item2.icon`, `bu28.recent.item3.icon`).
  static const clock = '$_d/ic_clock.svg';

  /// (14) Limpar a busca (× de traço 2,8) (`bu28b.searchBar.field.clear.icon`, `bu28c.searchBar.field.clear.icon`).
  static const closeSmall = '$_d/ic_close_small.svg';

  /// (18) Borracha (apagar tudo) (`sc69b.toolbar.clearAll.icon`).
  static const eraser = '$_d/ic_eraser.svg';

  /// (20) Lanterna (raio) (`sc03.controls.torch.icon`, `sc39.controls.torch.icon`, `sc40.controls.torch.icon` e mais
  /// 2).
  static const flash = '$_d/ic_flash.svg';

  /// (21) Ajuda (? no círculo) (`sc69.controls.help.icon`, `sc69b.controls.help.icon`).
  static const help = '$_d/ic_help.svg';

  /// (19) Imagem (escolher da galeria) (`bu28d.cover.options.gallery.icon`).
  static const image = '$_d/ic_image.svg';

  /// (18) Teclado (modo digitar) (`sc03.controls.mode.type.icon`, `sc39.controls.mode.type.icon`,
  /// `sc40.controls.mode.type.icon` e mais 5).
  static const keyboard = '$_d/ic_keyboard.svg';

  /// (21) Esconder o teclado (`sc69.toolbar.hide.icon`, `sc69b.toolbar.hide.icon`).
  static const keyboardHide = '$_d/ic_keyboard_hide.svg';

  /// (24; 22; 19) Pessoas no avatar do clube (`bu28b.clubs.club1.avatar.icon`, `bu28b.clubs.club2.avatar.icon`,
  /// `e36a.club.badge.icon` e mais 3).
  static const peopleAvatar = '$_d/ic_people_avatar.svg';

  /// (18) "+" de traço 2,6 (adicionar) (`bu28b.books.result2.add.icon`).
  static const plusAdd = '$_d/ic_plus_add.svg';

  /// (20) "+" de traço 2,6 (adicionar) (`bu28c.actions.manual.icon`, `bu28d.submit.icon`).
  static const plusAddPapel = '$_d/ic_plus_add_papel.svg';

  /// (20) "+" papel do botão principal (`sc03.sheet.actions.primary.icon`, `sc40.sheet.actions.primary.icon`).
  static const plusPapel = '$_d/ic_plus_papel.svg';

  /// (22) Escanear de novo (seta circular) (`sc03.sheet.actions.scanAgain.icon`, `sc40.sheet.actions.scanAgain.icon`,
  /// `sc42.sheet.actions.scanAgain.icon`).
  static const refresh = '$_d/ic_refresh.svg';

  /// (14) Escanear, amarelo, do chip de status (`sc39.status.chip.badge.icon`).
  static const scanBarcodeAmarelo = '$_d/ic_scan_barcode_amarelo.svg';

  /// (21; 20; 22; 19; 17) Escanear da barra de busca (traço 1,9) (`bu28.searchBar.scan.icon`,
  /// `bu28b.scanCard.badge.icon`, `bu28b.searchBar.scan.icon` e mais 4).
  static const scanBarcodeBusca = '$_d/ic_scan_barcode_busca.svg';

  /// (18) Engrenagem do caminho dos Ajustes (`sc41.sheet.path.icon`).
  static const settingsSmall = '$_d/ic_settings_small.svg';

  /// (13) Livros na estante (`sc42.sheet.chip.icon`).
  static const shelf = '$_d/ic_shelf.svg';

  /// (26; 24) Brilho com contorno (`bu28.sparkle`, `e15.heading.sparkle`, `e16.confetti.sparkle4`).
  static const sparkleLavanda = '$_d/ic_sparkle_lavanda.svg';

  static const all = <String>[
    alert,
    alertSmall,
    arrowNextPapel,
    backspace,
    barcode,
    bookSimple,
    cameraCapa,
    checkBoldTinta,
    checkReadAmarelo,
    chevronRightFino,
    clipboard,
    clock,
    closeSmall,
    eraser,
    flash,
    help,
    image,
    keyboard,
    keyboardHide,
    peopleAvatar,
    plusAdd,
    plusAddPapel,
    plusPapel,
    refresh,
    scanBarcodeAmarelo,
    scanBarcodeBusca,
    settingsSmall,
    shelf,
    sparkleLavanda,
  ];
}

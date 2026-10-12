// T13.11 (R7) — os ícones novos da T17 · Perfil, ajustes, conta, privacidade e notificações (telas 05, 06, 30, 30b,
// 30c, 56, 58, 59, 64, 65), em `assets/icons/perfil/` (D-284: a pasta da área da 1ª etapa que usa o desenho). Gerado
// por `tools/medicao/gen_classes_svg.py` do catálogo `docs/design/medicao/projeto/svg_catalogo.json` — não editar à
// mão. As cores já estão nos SVGs (cada variante de cor é um arquivo); o tamanho de uso entre parênteses, depois a
// descrição e os ids das pranchas. Os reusados (D-283: o mesmo desenho de um asset que já existia) continuam nas
// classes de antes: `AppIcons.navHome`; `AppIcons.navProfileActive`; `AppIcons.arrowRight`; `AppIcons.navClubs`;
// `AppIcons.navLibrary`; `AppIcons.navScanner`; `AppIcons.sparkleSolid`; `AppIconsInicio.checkTiny`;
// `AppIconsInicio.closeBold`; `AppIconsInicio.download`; `AppIconsInicio.pencilEdit`;
// `AppIconsInicio.sparkleSolidCream`; `AppIconsLeitor.arrowLeft`; `AppIconsLeitor.check`; `AppIconsLeitor.checkRead`;
// `AppIconsLeitor.plusTiny`; `AppIconsLeitor.search`; `AppIconsLeitor.share`.
abstract final class AppIconsPerfil {
  static const _d = 'assets/icons/perfil';

  /// (18) Seta em tinta (mais do ano) (`p05.year.more.icon`).
  static const arrowForwardTinta = '$_d/ic_arrow_forward_tinta.svg';

  /// (13) Seta para cima e à direita (à frente da meta) (`p05.year.goal.ahead.icon`).
  static const arrowUpRight = '$_d/ic_arrow_up_right.svg';

  /// (18) Gráfico de barras (estatísticas) (`aj56.visibility.list.stats.icon.art`).
  static const barChart = '$_d/ic_bar_chart.svg';

  /// (18) Sino das listas (traço 2) (`aj06.more.list.notifications.icon.art`).
  static const bellLista = '$_d/ic_bell_lista.svg';

  /// (18) Bloqueado (círculo cortado) (`aj56.blockNote.icon`, `aj56.people.list.blocked.icon.art`).
  static const block = '$_d/ic_block.svg';

  /// (26) Livro aberto (26, medalha) (`p05.achievements.grid.badge2.medal.center.icon`).
  static const bookOpenMedalha = '$_d/ic_book_open_medalha.svg';

  /// (15) Câmera (15, trocar o avatar) (`p64.preview.avatar.change.icon`, `p65.preview.avatar.change.icon`).
  static const cameraSmall = '$_d/ic_camera_small.svg';

  /// (14) Câmera (15, trocar o avatar) (`p64.avatarType.toggle.photo.icon`).
  static const cameraSmallGrafite = '$_d/ic_camera_small_grafite.svg';

  /// (26; 20) Balão de conversa (medalha) (`p05.achievements.grid.badge3.medal.center.icon`,
  /// `aj06.help.list.contact.icon`).
  static const chatBubble = '$_d/ic_chat_bubble.svg';

  /// (15) Check de traço 3 creme do rádio (`p65.sheet.options.option1.radio.icon`).
  static const checkBoldCreme = '$_d/ic_check_bold_creme.svg';

  /// (21) Check duplo (marcar como lidas) (`n30.top.markRead.icon`, `n30c.top.markRead.icon`).
  static const checkDouble = '$_d/ic_check_double.svg';

  /// (13) Check creme do rádio (`aj56.profileType.closed.radio.icon`).
  static const checkSmallCreme = '$_d/ic_check_small_creme.svg';

  /// (19) Check verde (salvar) (`p64.bottom.save.icon`).
  static const checkVerde = '$_d/ic_check_verde.svg';

  /// (14) Chevron para baixo (14) (`aj56.visibility.list.highlights.audience.chevron`,
  /// `aj56.visibility.list.lists.audience.chevron`, `aj56.visibility.list.page.audience.chevron` e mais 3).
  static const chevronDownSmall = '$_d/ic_chevron_down_small.svg';

  /// (20) Chevron para a esquerda (voltar) (`aj58.top.back.icon`, `aj59.top.back.icon`, `aj56.top.back.icon`).
  static const chevronLeft = '$_d/ic_chevron_left.svg';

  /// (20; 18) Chevron para a direita das listas (traço 2,2) (`aj06.account.chevron`, `aj06.help.list.center.chevron`,
  /// `aj06.help.list.contact.chevron` e mais 19).
  static const chevronRightLista = '$_d/ic_chevron_right_lista.svg';

  /// (18) Contraste (aparência) (`aj06.more.list.appearance.icon.art`).
  static const contrast = '$_d/ic_contrast.svg';

  /// (20) Documento (termos) (`aj06.help.list.terms.icon`).
  static const document = '$_d/ic_document.svg';

  /// (18) Página (o que estou lendo) (`aj56.visibility.list.page.icon.art`).
  static const documentPage = '$_d/ic_document_page.svg';

  /// (16) Alça de arrastar (6 pontos) (`p64.favorites.grid.slot1.handle.icon`, `p64.favorites.grid.slot2.handle.icon`,
  /// `p64.favorites.grid.slot3.handle.icon` e mais 1).
  static const dragHandle = '$_d/ic_drag_handle.svg';

  /// (15) Chama cheia amarela (sequência) (`p05.hero.avatar.streak.icon`).
  static const flameFilled = '$_d/ic_flame_filled.svg';

  /// (16) Chama cheia coral (`aj06.goals.streak.title.icon`).
  static const flameFilledCoral = '$_d/ic_flame_filled_coral.svg';

  /// (18) Chama de contorno (sequência) (`n30b.topics.streak.icon.art`).
  static const flameOutline = '$_d/ic_flame_outline.svg';

  /// (18) Pasta com seta (biblioteca) (`aj06.more.list.library.icon.art`).
  static const folderDownload = '$_d/ic_folder_download.svg';

  /// (18) Globo (idioma) (`aj06.more.list.language.icon.art`).
  static const globe = '$_d/ic_globe.svg';

  /// (19) Globo (perfil aberto, 19) (`aj56.profileType.open.icon.art`).
  static const globePerfil = '$_d/ic_globe_perfil.svg';

  /// (21; 18) Coração (`n30.today.list.item4.icon.art`, `n30b.topics.social.icon.art`).
  static const heart = '$_d/ic_heart.svg';

  /// (20) Ajuda (? no círculo, 20) (`aj06.help.list.center.icon`).
  static const helpLista = '$_d/ic_help_lista.svg';

  /// (18) Chave (senha) (`aj58.signIn.list.password.icon.art`).
  static const key = '$_d/ic_key.svg';

  /// (18) Estante das listas (`aj56.visibility.list.shelf.icon.art`).
  static const libraryLista = '$_d/ic_library_lista.svg';

  /// (18) Lista com marcadores (`aj56.visibility.list.lists.icon.art`).
  static const list = '$_d/ic_list.svg';

  /// (18; 19) Cadeado (`aj06.more.list.privacy.icon.art`, `aj56.profileType.closed.icon.art`).
  static const lock = '$_d/ic_lock.svg';

  /// (14) Cadeado (14, só eu) (`aj56.visibility.list.highlights.audience.icon`,
  /// `aj56.visibility.list.stats.audience.icon`).
  static const lockSmall = '$_d/ic_lock_small.svg';

  /// (16) "−" do contador (16) (`aj06.goals.daily.stepper.minus.icon`, `aj06.goals.yearly.stepper.minus.icon`).
  static const minusStepper = '$_d/ic_minus_stepper.svg';

  /// (18) Lua creme (não incomodar) (`n30b.quiet.head.icon.art`).
  static const moonCreme = '$_d/ic_moon_creme.svg';

  /// (18) Pausa no círculo (`aj59.alternatives.pause.icon.art`).
  static const pauseCircle = '$_d/ic_pause_circle.svg';

  /// (14) Lápis (14, trocar o favorito) (`p64.favorites.grid.slot1.book.swap.icon`,
  /// `p64.favorites.grid.slot2.book.swap.icon`, `p64.favorites.grid.slot3.book.swap.icon` e mais 1).
  static const pencilSmall = '$_d/ic_pencil_small.svg';

  /// (18) Pessoas das listas (contas ligadas) (`aj58.signIn.list.connected.icon.art`,
  /// `aj56.people.list.requests.icon.art`).
  static const peopleLista = '$_d/ic_people_lista.svg';

  /// (14) Pessoas (14, público) (`aj56.visibility.list.lists.audience.icon`, `aj56.visibility.list.page.audience.icon`,
  /// `aj56.visibility.list.reviews.audience.icon` e mais 1).
  static const peopleSmall = '$_d/ic_people_small.svg';

  /// (21) Pessoa (`n30.week.list.item2.icon.art`).
  static const person = '$_d/ic_person.svg';

  /// (18) Celular (aparelhos) (`aj58.sync.list.devices.icon.art`).
  static const phone = '$_d/ic_phone.svg';

  /// (12) Celular (12, conta) (`aj06.account.badge.icon`).
  static const phoneSmall = '$_d/ic_phone_small.svg';

  /// (16) "+" creme do contador (16) (`aj06.goals.daily.stepper.plus.icon`, `aj06.goals.yearly.stepper.plus.icon`).
  static const plusStepperCreme = '$_d/ic_plus_stepper_creme.svg';

  /// (18) Escanear das listas (18) (`aj06.more.list.scanner.icon.art`).
  static const scanBarcodeLista = '$_d/ic_scan_barcode_lista.svg';

  /// (18) Lupa grafite da folha (`p65.sheet.search.icon`).
  static const searchGrafite = '$_d/ic_search_grafite.svg';

  /// (22; 20; 18) Engrenagem (ajustes) (`p05.top.settings.icon`, `n30.top.settings.icon`, `n30c.empty.cta.icon` e mais
  /// 1).
  static const settings = '$_d/ic_settings.svg';

  /// (18) Trocar (setas cruzadas, amarelo) (`p65.sheet.confirm.icon`).
  static const shuffleAmarelo = '$_d/ic_shuffle_amarelo.svg';

  /// (18) Sair (traço 2,2) (`aj06.footer.signOut.icon`).
  static const signOut = '$_d/ic_sign_out.svg';

  /// (18) Sair (traço 2) (`aj58.signOut.icon`).
  static const signOutFino = '$_d/ic_sign_out_fino.svg';

  /// (24) Brilho rosa com contorno (notificações) (`n30.sparkle`).
  static const sparkleNotificacao = '$_d/ic_sparkle_notificacao.svg';

  /// (24; 20) Brilho rosa com contorno (notificações) (`n30.today.list.item3.icon.art`,
  /// `n30b.topics.achievements.icon.art`).
  static const sparkleNotificacaoCreme = '$_d/ic_sparkle_notificacao_creme.svg';

  /// (12) Brilho cheio cinza (versão) (`aj06.footer.version.icon`).
  static const sparkleSolidCinza = '$_d/ic_sparkle_solid_cinza.svg';

  /// (15) Estrela dourada da nota (`p05.activity.item3.rating.star1`, `p05.activity.item3.rating.star2`,
  /// `p05.activity.item3.rating.star3` e mais 1).
  static const star = '$_d/ic_star.svg';

  /// (22) Estrela coral (plano) (`aj06.plan.icon.art`).
  static const starCoral = '$_d/ic_star_coral.svg';

  /// (15) Estrela dourada da nota (`p05.activity.item3.rating.star5`).
  static const starCreme = '$_d/ic_star_creme.svg';

  /// (12) Meia estrela pequena (`p65.sheet.options.option4.rating.star5`). Armadilha: a meia estrela é uma estrela com
  /// `<mask>` (metade dourada): conferir no app que o flutter_svg recorta igual (a prova é no Chromium).
  static const starHalfSmall = '$_d/ic_star_half_small.svg';

  /// (18) Estrela de contorno (resenhas) (`aj56.visibility.list.reviews.icon.art`).
  static const starOutline = '$_d/ic_star_outline.svg';

  /// (12) Estrela dourada pequena (12) (`p65.sheet.options.option1.rating.star1`,
  /// `p65.sheet.options.option1.rating.star2`, `p65.sheet.options.option1.rating.star3` e mais 16).
  static const starSmall = '$_d/ic_star_small.svg';

  /// (21; 18) Barras (resumo) (`n30.week.list.item1.icon.art`, `n30b.topics.polls.icon.art`).
  static const statsBars = '$_d/ic_stats_bars.svg';

  /// (22; 20) Cronômetro (traço 1,9) (`n30.today.list.item2.icon.art`, `n30b.reading.head.icon.art`,
  /// `n30c.reminder.icon.art`).
  static const stopwatchFino = '$_d/ic_stopwatch_fino.svg';

  /// (17) Lixeira vermelha (excluir a conta) (`aj58.delete.icon`).
  static const trashDelete = '$_d/ic_trash_delete.svg';

  /// (19) Lixeira vermelha (excluir a conta) (`aj59.bottom.delete.icon`).
  static const trashDeleteTinta = '$_d/ic_trash_delete_tinta.svg';

  /// (18) Enviar (importar) (`aj58.data.list.import.icon.art`).
  static const upload = '$_d/ic_upload.svg';

  static const all = <String>[
    arrowForwardTinta,
    arrowUpRight,
    barChart,
    bellLista,
    block,
    bookOpenMedalha,
    cameraSmall,
    cameraSmallGrafite,
    chatBubble,
    checkBoldCreme,
    checkDouble,
    checkSmallCreme,
    checkVerde,
    chevronDownSmall,
    chevronLeft,
    chevronRightLista,
    contrast,
    document,
    documentPage,
    dragHandle,
    flameFilled,
    flameFilledCoral,
    flameOutline,
    folderDownload,
    globe,
    globePerfil,
    heart,
    helpLista,
    key,
    libraryLista,
    list,
    lock,
    lockSmall,
    minusStepper,
    moonCreme,
    pauseCircle,
    pencilSmall,
    peopleLista,
    peopleSmall,
    person,
    phone,
    phoneSmall,
    plusStepperCreme,
    scanBarcodeLista,
    searchGrafite,
    settings,
    shuffleAmarelo,
    signOut,
    signOutFino,
    sparkleNotificacao,
    sparkleNotificacaoCreme,
    sparkleSolidCinza,
    star,
    starCoral,
    starCreme,
    starHalfSmall,
    starOutline,
    starSmall,
    statsBars,
    stopwatchFino,
    trashDelete,
    trashDeleteTinta,
    upload,
  ];
}

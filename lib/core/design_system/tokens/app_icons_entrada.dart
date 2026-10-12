// T13.11 (R7) — os ícones novos da T16 · Entrada e onboarding (telas 07, 08, 09, 09b, 10, 11, 12, 13, 13b, 14, 15, 16,
// 35, 36a), em `assets/icons/entrada/` (D-284: a pasta da área da 1ª etapa que usa o desenho). Gerado por
// `tools/medicao/gen_classes_svg.py` do catálogo `docs/design/medicao/projeto/svg_catalogo.json` — não editar à mão.
// As cores já estão nos SVGs (cada variante de cor é um arquivo); o tamanho de uso entre parênteses, depois a
// descrição e os ids das pranchas. Os reusados (D-283: o mesmo desenho de um asset que já existia) continuam nas
// classes de antes: `AppIcons.bell`; `AppIcons.bookOpen`; `AppIcons.navClubs`; `AppIcons.navHomeActive`;
// `AppIcons.navLibrary`; `AppIcons.navProfile`; `AppIcons.navScanner`; `AppIcons.sparkleOutline`;
// `AppIcons.sparkleSolid`; `AppIconsInicio.checkTiny`; `AppIconsInicio.plusBold`; `AppIconsInicio.search`;
// `AppIconsInicio.sparkleYellow`; `AppIconsInicio.sparkleSolidYellow`; `AppIconsInicio.sparkleSolidCream`;
// `AppIconsLeitor.arrowLeft`; `AppIconsLeitor.checkSmall`; `AppIconsLeitor.plus`; `AppIconsLeitor.search`.
abstract final class AppIconsEntrada {
  static const _d = 'assets/icons/entrada';

  /// (16) Alerta (!) cinza (olhe o spam) (`e10.sheet.help.spam.icon`).
  static const alertCinza = '$_d/ic_alert_cinza.svg';

  /// (20) Seta papel (continuar) (`e08.sheet.form.submit.icon`, `e09.sheet.form.submit.icon`,
  /// `e09b.sheet.form.submit.icon` e mais 5).
  static const arrowForward = '$_d/ic_arrow_forward.svg';

  /// (18) Voltar de traço 2,4 (`e13.top.back.icon`, `e13b.top.back.icon`, `e14.top.back.icon` e mais 1).
  static const arrowLeftBold = '$_d/ic_arrow_left_bold.svg';

  /// (20) Câmera creme (adicionar foto) (`e15.photo.add.icon`).
  static const cameraCreme = '$_d/ic_camera_creme.svg';

  /// (9) Check mínimo das regras da senha (`e08.sheet.form.rules.rule1.check.icon`,
  /// `e08.sheet.form.rules.rule2.check.icon`, `e11.sheet.form.rules.rule1.check.icon` e mais 2).
  static const checkMini = '$_d/ic_check_mini.svg';

  /// (13; 14) Check pequeno creme do rádio (`e12.daily.option3.radio.icon`, `e13.genres.chip1.badge.icon`,
  /// `e13.genres.chip2.badge.icon` e mais 2).
  static const checkTinyCreme = '$_d/ic_check_tiny_creme.svg';

  /// (11) Check do @ válido (traço 3,8) (`e15.username.field.valid.icon`).
  static const checkValid = '$_d/ic_check_valid.svg';

  /// (22; 15) Olho (mostrar a senha) (`e08.sheet.form.password.field.reveal.icon`,
  /// `e09.sheet.form.password.field.reveal.icon`, `e09b.sheet.form.password.field.reveal.icon` e mais 2).
  static const eye = '$_d/ic_eye.svg';

  /// (15) Pessoa (Biografias) (`e13.genres.chip10.badge.icon`).
  static const generoBiografias = '$_d/ic_genero_biografias.svg';

  /// (15) Varinha (Fantasia) (`e13.genres.chip3.badge.icon`).
  static const generoFantasia = '$_d/ic_genero_fantasia.svg';

  /// (15) Foguete (Ficção científica) (`e13.genres.chip4.badge.icon`).
  static const generoFiccaoCientifica = '$_d/ic_genero_ficcao_cientifica.svg';

  /// (15) Ampulheta (História) (`e13.genres.chip11.badge.icon`).
  static const generoHistoria = '$_d/ic_genero_historia.svg';

  /// (15) Carinha sorrindo (Humor) (`e13.genres.chip15.badge.icon`).
  static const generoHumor = '$_d/ic_genero_humor.svg';

  /// (15) Raio (Jovem adulto) (`e13.genres.chip14.badge.icon`).
  static const generoJovemAdulto = '$_d/ic_genero_jovem_adulto.svg';

  /// (15) Lâmpada (Não ficção) (`e13.genres.chip12.badge.icon`).
  static const generoNaoFiccao = '$_d/ic_genero_nao_ficcao.svg';

  /// (15) Pena (Poesia) (`e13.genres.chip9.badge.icon`).
  static const generoPoesia = '$_d/ic_genero_poesia.svg';

  /// (15) Balão de fala (Quadrinhos) (`e13.genres.chip13.badge.icon`).
  static const generoQuadrinhos = '$_d/ic_genero_quadrinhos.svg';

  /// (15) Fantasma (Terror) (`e13.genres.chip7.badge.icon`).
  static const generoTerror = '$_d/ic_genero_terror.svg';

  /// (17) Imagem (17, galeria) (`e15.photo.info.gallery.icon`).
  static const imageSmall = '$_d/ic_image_small.svg';

  /// (20) Envelope papel (e-mail) (`e07.sheet.buttons.email.icon`, `e10.sheet.help.openMail.icon`).
  static const mail = '$_d/ic_mail.svg';

  /// (20; 18) Envelope papel (e-mail) (`e09.sheet.code.icon`, `e09b.sheet.code.icon`, `aj58.signIn.list.email.icon.art`
  /// e mais 1).
  static const mailTinta = '$_d/ic_mail_tinta.svg';

  /// (18) "−" de traço 2,6 do contador (`e12.yearly.stepper.minus.icon`, `cr18b.sheet.page.prev.icon`).
  static const minusBold = '$_d/ic_minus_bold.svg';

  /// (18) Lápis sobre a linha (bio) (`e15.bio.field.icon`).
  static const pencilNote = '$_d/ic_pencil_note.svg';

  /// (18) "+" amarelo do contador da meta (`e12.yearly.stepper.plus.icon`).
  static const plusMeta = '$_d/ic_plus_meta.svg';

  /// (18) Escanear amarelo (traço 2,2) do "tentar" (`e13b.coach.card.actions.try.icon`).
  static const scanBarcodeDica = '$_d/ic_scan_barcode_dica.svg';

  /// (24) Escanear (24, traço 2) (`e13b.search.scan.icon`, `e14.search.scan.icon`).
  static const scanBarcodeGrande = '$_d/ic_scan_barcode_grande.svg';

  /// (19) Compartilhar (19, traço 2) (`e16.sheet.share.icon`).
  static const shareUp = '$_d/ic_share_up.svg';

  /// (15) Escudo cinza (aviso de segurança) (`e11.sheet.notice.icon`).
  static const shield = '$_d/ic_shield.svg';

  /// (24; 22; 16) Brilho com contorno (`e13.heading.sparkle`, `e16.confetti.sparkle3`, `e16.confetti.sparkle6`).
  static const sparkleRosa = '$_d/ic_sparkle_rosa.svg';

  /// (16) Brilho cheio violeta (`e08.card.stamp.icon`).
  static const sparkleSolidVioleta = '$_d/ic_sparkle_solid_violeta.svg';

  /// (20) Brilho com contorno cheio de tinta (`e35.sparkleSmall`).
  static const sparkleTinta = '$_d/ic_sparkle_tinta.svg';

  /// (24; 18) Brilho com contorno (`e13b.heading.sparkle`, `e14.heading.sparkle`, `e16.confetti.sparkle2`).
  static const sparkleVerde = '$_d/ic_sparkle_verde.svg';

  static const all = <String>[
    alertCinza,
    arrowForward,
    arrowLeftBold,
    cameraCreme,
    checkMini,
    checkTinyCreme,
    checkValid,
    eye,
    generoBiografias,
    generoFantasia,
    generoFiccaoCientifica,
    generoHistoria,
    generoHumor,
    generoJovemAdulto,
    generoNaoFiccao,
    generoPoesia,
    generoQuadrinhos,
    generoTerror,
    imageSmall,
    mail,
    mailTinta,
    minusBold,
    pencilNote,
    plusMeta,
    scanBarcodeDica,
    scanBarcodeGrande,
    shareUp,
    shield,
    sparkleRosa,
    sparkleSolidVioleta,
    sparkleTinta,
    sparkleVerde,
  ];
}

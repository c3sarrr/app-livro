// T13.11 (R7) — as ilustrações novas da T16 · Entrada e onboarding (telas 07, 08, 09, 09b, 10, 11, 12, 13, 13b, 14,
// 15, 16, 35, 36a), em `assets/illustrations/entrada/` (D-284: a pasta da área da 1ª etapa que usa o desenho). Gerado
// por `tools/medicao/gen_classes_svg.py` do catálogo `docs/design/medicao/projeto/svg_catalogo.json` — não editar à
// mão. As cores já estão nos SVGs (cada variante de cor é um arquivo); o tamanho de uso entre parênteses, depois a
// descrição e os ids das pranchas. Os reusados (D-283: o mesmo desenho de um asset que já existia) continuam nas
// classes de antes: `AppIllustrationsInicio.coverDomCasmurro`.
abstract final class AppIllustrationsEntrada {
  static const _d = 'assets/illustrations/entrada';

  /// (140×158) Cadeado aberto (nova senha) (`e11.padlock`). Cor dinâmica: #FED170 = prop "lock".
  static const cadeadoAberto = '$_d/cadeado_aberto.svg';

  /// (98) Carimbo "LEITORA Nº … · BOOKNEST" da carteirinha (`e16.stamp`). Armadilha: o texto "LEITORA Nº 0052 ·
  /// BOOKNEST ·" (Figtree 900 10,5 ls 1, violeta) corre num `<textPath>` em volta do círculo (textLength 226,
  /// lengthAdjust spacing): o flutter_svg não faz textPath → no app, o desenho sem o texto e as letras distribuídas no
  /// arco por um pintor com o AppFonts; o número é o da leitora e o "2026" (Bricolage 800 11, no centro) é o ano:
  /// AppText. desenha fora da própria caixa (as três linhas de movimento em x −20 do viewBox 112: saem 18,5 px à
  /// esquerda da caixa 98; o `<svg>` tem overflow: visible): no app, sem recorte (o SvgPicture com clipBehavior:
  /// Clip.none, ou o pintor sem clip) — com o recorte padrão, o que passa some.
  static const carimboCarteirinha = '$_d/carimbo_carteirinha.svg';

  /// (150×30) Código de barras da carteirinha (`e16.card.footer.code.bars`).
  static const codigoBarrasCarteirinha = '$_d/codigo_barras_carteirinha.svg';

  /// (54) Despertador com 15 min (`e12.daily.option2.art`).
  static const despertador15Min = '$_d/despertador_15_min.svg';

  /// (54) Despertador com 30 min (tocando) (`e12.daily.option3.art`). Armadilha: desenha fora da própria caixa (os
  /// risquinhos de toque em x −1,5 e 57,5 do viewBox 56: saem 2,3 px de cada lado da caixa 54, que ainda gira −5°; o
  /// `<svg>` tem overflow: visible): no app, sem recorte (o SvgPicture com clipBehavior: Clip.none, ou o pintor sem
  /// clip) — com o recorte padrão, o que passa some.
  static const despertador30Min = '$_d/despertador_30_min.svg';

  /// (54) Despertador com 5 min (`e12.daily.option1.art`).
  static const despertador5Min = '$_d/despertador_5_min.svg';

  /// (54) Despertador com 60 min (`e12.daily.option4.art`).
  static const despertador60Min = '$_d/despertador_60_min.svg';

  /// (238×200) Envelope com o código (`e10.envelope`). Cor dinâmica: #B6ACE4 = prop "env". Armadilha: tem `<text>`
  /// ("SEU CÓDIGO" Figtree 800 9 ls 1,2 e "482 7••" Bricolage 800 27 ls 2): o flutter_svg desenharia o texto com a
  /// fonte do sistema → no app o AppSvg lê o desenho sem os textos e eles voltam em AppText nas mesmas posições (como
  /// as capas da Início, T03.7) — o código é o enviado de verdade, com os dígitos que faltam em •. desenha fora da
  /// própria caixa (o papel em y −12 do viewBox 190×160: sai 16 px acima da caixa 238×200; o `<svg>` tem overflow:
  /// visible): no app, sem recorte (o SvgPicture com clipBehavior: Clip.none, ou o pintor sem clip) — com o recorte
  /// padrão, o que passa some.
  static const envelopeCodigo = '$_d/envelope_codigo.svg';

  /// (46×60) Livro lavanda com o código (cartão da dica) (`e13b.coach.card.art`).
  static const livroCodigoBarrasDica = '$_d/il_livro_codigo_barras_dica.svg';

  /// (390×844) Ondas verticais da abertura (`e35.waves`). Armadilha: as ondas verticais da abertura: viewBox 390×640
  /// esticado em 390×844 (preserveAspectRatio="none") — no app, BoxFit.fill na altura da tela.
  static const ondasAbertura = '$_d/ondas_abertura.svg';

  /// (390×860) Ondas do topo das telas de entrada (`e07.waves`, `e08.waves`, `e09.waves` e mais 4). Armadilha: faixa de
  /// ondas de largura fixa (390): a 360 sai 30 px do quadro e é cortada na borda (fluidez, T13.9) — decidir na T16 se
  /// acompanha a largura da tela.
  static const ondasEntrada = '$_d/ondas_entrada.svg';

  /// (390×150) Ondas do topo do onboarding (meta) (`e12.waves`, `e13.waves`, `e13b.waves` e mais 2). Armadilha: faixa
  /// de ondas de largura fixa (390), com `<mask>`: a 360 sai 30 px do quadro e é cortada na borda (fluidez, T13.9) —
  /// decidir na T16 se acompanha a largura da tela.
  static const ondasOnboardingMeta = '$_d/ondas_onboarding_meta.svg';

  /// (260) Raios em volta do selo da abertura (`e35.stamp.rays`).
  static const raiosSeloAbertura = '$_d/raios_selo_abertura.svg';

  /// (132) Selo "DE VOLTA À LEITURA · BOOKNEST" (`e09.badge`, `e09b.badge`). Cor dinâmica: #FED170 = prop "badge".
  /// Armadilha: o texto "DE VOLTA À LEITURA · BOOKNEST ·" (Figtree 800 11,5) corre num `<textPath>` em volta do círculo
  /// (textLength 252, lengthAdjust spacing): o flutter_svg não faz textPath → no app, o desenho sem o texto e as letras
  /// distribuídas no arco por um pintor com o AppFonts; a cor do selo é a prop "badge".
  static const seloDeVoltaALeitura = '$_d/selo_de_volta_a_leitura.svg';

  /// (210) Selo "LEIA · GRIFE · CONVERSE" (abertura) (`e35.stamp.badge.art`). Armadilha: o texto "LEIA · GRIFE ·
  /// CONVERSE ·" (Figtree 800 11,5) corre num `<textPath>` em volta do círculo (textLength 252, lengthAdjust spacing):
  /// o flutter_svg não faz textPath → no app, o desenho sem o texto e as letras distribuídas no arco por um pintor com
  /// o AppFonts.
  static const seloLeiaGrifeConverse = '$_d/selo_leia_grife_converse.svg';

  /// (124) O mesmo selo, com a sombra a 3 (login) (`e07.badge`). Armadilha: o texto "LEIA · GRIFE · CONVERSE ·"
  /// (Figtree 800 11,5) corre num `<textPath>` em volta do círculo (textLength 252, lengthAdjust spacing): o
  /// flutter_svg não faz textPath → no app, o desenho sem o texto e as letras distribuídas no arco por um pintor com o
  /// AppFonts.
  static const seloLeiaGrifeConverseLogin =
      '$_d/selo_leia_grife_converse_login.svg';

  /// (350×140) Seta curva da dica (`e13b.coach.arrow`).
  static const setaCurvaDica = '$_d/seta_curva_dica.svg';

  static const all = <String>[
    cadeadoAberto,
    carimboCarteirinha,
    codigoBarrasCarteirinha,
    despertador15Min,
    despertador30Min,
    despertador5Min,
    despertador60Min,
    envelopeCodigo,
    livroCodigoBarrasDica,
    ondasAbertura,
    ondasEntrada,
    ondasOnboardingMeta,
    raiosSeloAbertura,
    seloDeVoltaALeitura,
    seloLeiaGrifeConverse,
    seloLeiaGrifeConverseLogin,
    setaCurvaDica,
  ];

  /// Os desenhos com `<text>`: o `AppSvg` os lê sem os textos (`svgWithoutText`) e os textos voltam em `AppText` (ou
  /// num pintor, os de `<textPath>`) — armadilhas no catálogo.
  static const Set<String> withText = <String>{
    carimboCarteirinha,
    envelopeCodigo,
    seloDeVoltaALeitura,
    seloLeiaGrifeConverse,
    seloLeiaGrifeConverseLogin,
  };
}

// T13.11 (R7) — as ilustrações novas da T15 · Scanner e busca (telas 03, 28, 28b, 28c, 28d, 39, 40, 41, 42, 69, 69b),
// em `assets/illustrations/scanner/` (D-284: a pasta da área da 1ª etapa que usa o desenho). Gerado por
// `tools/medicao/gen_classes_svg.py` do catálogo `docs/design/medicao/projeto/svg_catalogo.json` — não editar à mão.
// As cores já estão nos SVGs (cada variante de cor é um arquivo); o tamanho de uso entre parênteses, depois a
// descrição e os ids das pranchas.
abstract final class AppIllustrationsScanner {
  static const _d = 'assets/illustrations/scanner';

  /// (210×170) Livro com lupa e "?" (nada encontrado) (`bu28c.illustration`). Armadilha: tem `<text>` (o "?" em
  /// Instrument Serif 44): o flutter_svg desenharia o texto com a fonte do sistema → no app o AppSvg lê o desenho sem
  /// os textos e eles voltam em AppText nas mesmas posições (como as capas da Início, T03.7).
  static const buscaNadaEncontrado = '$_d/il_busca_nada_encontrado.svg';

  /// (150×120) Câmera com cadeado (sem permissão) (`sc41.sheet.art.image`).
  static const cameraCadeado = '$_d/il_camera_cadeado.svg';

  /// (121×90) Capa A Hora da Estrela (brilhos) (`bu28.trending.book4.cover.art`). Armadilha: width="100%" (a largura da
  /// caixa da capa): o arquivo sai com a largura medida; no app, a ilustração ocupa a caixa da capa (BoxFit.contain,
  /// centrada).
  static const capaAHoraDaEstrela = '$_d/il_capa_a_hora_da_estrela.svg';

  /// (55×40) Capa Capitu: memórias póstumas (ondas) (`bu28b.books.result2.cover.art`). Armadilha: width="100%" (a
  /// largura da caixa da capa): o arquivo sai com a largura medida; no app, a ilustração ocupa a caixa da capa
  /// (BoxFit.contain, centrada).
  static const capaCapituMemorias = '$_d/il_capa_capitu_memorias.svg';

  /// (55×40) Capa Dom Casmurro do resultado (olho) (`bu28b.books.result1.cover.art`). Armadilha: width="100%" (a
  /// largura da caixa da capa): o arquivo sai com a largura medida; no app, a ilustração ocupa a caixa da capa
  /// (BoxFit.contain, centrada).
  static const capaDomCasmurroOlho = '$_d/il_capa_dom_casmurro_olho.svg';

  /// (121×70) Capa Iracema (sol sobre as ondas) (`bu28.trending.book2.cover.art`). Armadilha: width="100%" (a largura
  /// da caixa da capa) e preserveAspectRatio="none": o arquivo sai com a largura medida; no app, a ilustração ocupa a
  /// caixa da capa (BoxFit.fill: esticada).
  static const capaIracema = '$_d/il_capa_iracema.svg';

  /// (121×96) Capa Policarpo Quaresma (violão) (`bu28.trending.book3.cover.art`). Armadilha: width="100%" (a largura da
  /// caixa da capa): o arquivo sai com a largura medida; no app, a ilustração ocupa a caixa da capa (BoxFit.contain,
  /// centrada).
  static const capaPolicarpoQuaresma = '$_d/il_capa_policarpo_quaresma.svg';

  /// (122×90) Capa Receitas da vó Cida (tigela) (`bu28d.cover.preview.book.art`).
  static const capaReceitasDaVoCida = '$_d/il_capa_receitas_da_vo_cida.svg';

  /// (86×104) Livro lavanda com o código de barras (como mirar) (`sc39.sheet.lead.art`). Armadilha: tem
  /// stroke-dasharray (o `<rect>` de cantos 6, 5/4, 2,4, coral): o flutter_svg traceja com outra fase → no app, o
  /// registro de tracejados (svgDashes, T01 e D-285) lê o arquivo sem esse traço (só o do id="tracejado": os outros
  /// `<rect>` têm traço) e o pinta por cima como o Chromium: o padrão começa em (x + rx, y), no sentido horário, e o
  /// comprimento das curvas é medido na escala da pintura (D-286).
  static const livroCodigoBarras = '$_d/il_livro_codigo_barras.svg';

  /// (84×110) Livro verde com "?" (não encontrado) (`sc40.sheet.lead.art`). Armadilha: tem `<text>` (o "?" em
  /// Instrument Serif 26): o flutter_svg desenharia o texto com a fonte do sistema → no app o AppSvg lê o desenho sem
  /// os textos e eles voltam em AppText nas mesmas posições (como as capas da Início, T03.7). tem stroke-dasharray (o
  /// `<rect>` de cantos 4, 4/3, 1,3, tinta, sobre o fundo creme dele): o flutter_svg traceja com outra fase → no app, o
  /// registro de tracejados (svgDashes, T01 e D-285) lê o arquivo sem esse traço (só o do id="tracejado": os outros
  /// `<rect>` têm traço) e o pinta por cima como o Chromium: o padrão começa em (x + rx, y), no sentido horário, e o
  /// comprimento das curvas é medido na escala da pintura (D-286).
  static const livroInterrogacao = '$_d/il_livro_interrogacao.svg';

  /// (290×170) Cantos da mira do scanner (`sc03.corners`, `sc40.corners`, `sc42.corners`). Cor dinâmica: #FED170 = prop
  /// "reticle".
  static const miraScanner = '$_d/mira_scanner.svg';

  /// (290×170) Cantos da mira do scanner (`sc39.corners`).
  static const miraScannerCreme = '$_d/mira_scanner_creme.svg';

  /// (290×170) Cantos tracejados da mira (sem permissão) (`sc41.corners`). Armadilha: tem stroke-dasharray (os 4 cantos
  /// da mira num `<path>`, 2/9, 5,5, creme, pontas redondas): o flutter_svg traceja com outra fase → no app, o registro
  /// de tracejados (svgDashes, T01 e D-285) lê o arquivo sem esse traço e o pinta por cima como o Chromium: o padrão
  /// começa de novo em cada subcaminho (cada M), e o comprimento das curvas é medido na escala da pintura (D-286).
  static const miraScannerTracejada = '$_d/mira_scanner_tracejada.svg';

  /// (14×60) Marcas de tremor à direita do adesivo (`sc69b.sticker.shakeRight`).
  static const tremorDireita = '$_d/tremor_direita.svg';

  /// (14×60) Marcas de tremor à esquerda do adesivo (`sc69b.sticker.shakeLeft`).
  static const tremorEsquerda = '$_d/tremor_esquerda.svg';

  static const all = <String>[
    buscaNadaEncontrado,
    cameraCadeado,
    capaAHoraDaEstrela,
    capaCapituMemorias,
    capaDomCasmurroOlho,
    capaIracema,
    capaPolicarpoQuaresma,
    capaReceitasDaVoCida,
    livroCodigoBarras,
    livroInterrogacao,
    miraScanner,
    miraScannerCreme,
    miraScannerTracejada,
    tremorDireita,
    tremorEsquerda,
  ];

  /// Os desenhos com `<text>`: o `AppSvg` os lê sem os textos (`svgWithoutText`) e os textos voltam em `AppText` (ou
  /// num pintor, os de `<textPath>`) — armadilhas no catálogo.
  static const Set<String> withText = <String>{
    buscaNadaEncontrado,
    livroInterrogacao,
  };
}

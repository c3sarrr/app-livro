// T13.11 (R7) — as ilustrações novas da T17 · Perfil, ajustes, conta, privacidade e notificações (telas 05, 06, 30,
// 30b, 30c, 56, 58, 59, 64, 65), em `assets/illustrations/perfil/` (D-284: a pasta da área da 1ª etapa que usa o
// desenho). Gerado por `tools/medicao/gen_classes_svg.py` do catálogo `docs/design/medicao/projeto/svg_catalogo.json`
// — não editar à mão. As cores já estão nos SVGs (cada variante de cor é um arquivo); o tamanho de uso entre
// parênteses, depois a descrição e os ids das pranchas.
abstract final class AppIllustrationsPerfil {
  static const _d = 'assets/illustrations/perfil';

  /// (46) Carimbo violeta com brilho da carteirinha (`p05.card.stamp`).
  static const carimboCarteirinhaPerfil = '$_d/carimbo_carteirinha_perfil.svg';

  /// (92×24) Código de barras da carteirinha do perfil (`p05.card.code.bars`).
  static const codigoBarrasCarteirinhaPerfil =
      '$_d/codigo_barras_carteirinha_perfil.svg';

  /// (14×26) Fita coral na capa da grade (14×26) (`p05.reading.grid.book1.cover.bookmark`,
  /// `p05.reading.grid.book2.cover.bookmark`, `p05.reading.grid.book3.cover.bookmark`).
  static const fitaMarcadorCapa = '$_d/fita_marcador_capa.svg';

  /// (230×200) Sino dormindo (zzz) sobre o livro (`n30c.illustration`). Armadilha: tem `<text>` (os três "z" em
  /// Bricolage 800 22, 16 e 12): o flutter_svg desenharia o texto com a fonte do sistema → no app o AppSvg lê o desenho
  /// sem os textos e eles voltam em AppText nas mesmas posições (como as capas da Início, T03.7).
  static const notificacoesVazia = '$_d/il_notificacoes_vazia.svg';

  /// (72) Medalha círculo rosa (`p05.achievements.grid.badge3.medal.art`).
  static const medalhaCirculoRosa = '$_d/medalha_circulo_rosa.svg';

  /// (72) Medalha hexágono verde (`p05.achievements.grid.badge2.medal.art`).
  static const medalhaHexagonoVerde = '$_d/medalha_hexagono_verde.svg';

  /// (72) Medalha losango lavanda (`p05.achievements.grid.badge4.medal.art`).
  static const medalhaLosangoLavanda = '$_d/medalha_losango_lavanda.svg';

  /// (72) Medalha ondulada amarela (`p05.achievements.grid.badge1.medal.art`).
  static const medalhaOnduladaAmarela = '$_d/medalha_ondulada_amarela.svg';

  static const all = <String>[
    carimboCarteirinhaPerfil,
    codigoBarrasCarteirinhaPerfil,
    fitaMarcadorCapa,
    notificacoesVazia,
    medalhaCirculoRosa,
    medalhaHexagonoVerde,
    medalhaLosangoLavanda,
    medalhaOnduladaAmarela,
  ];

  /// Os desenhos com `<text>`: o `AppSvg` os lê sem os textos (`svgWithoutText`) e os textos voltam em `AppText` (ou
  /// num pintor, os de `<textPath>`) — armadilhas no catálogo.
  static const Set<String> withText = <String>{notificacoesVazia};
}

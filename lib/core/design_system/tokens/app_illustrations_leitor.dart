// G16 — as ilustrações do leitor, exportadas do arquivo novo na G01.8 (`assets/illustrations/leitor/`, catálogo em
// `handoff_v2/referencia/svg_catalogo.json`): os objetos da prateleira do modo anotação (50×70, telas 22–24b). As
// cores do usuário entram pela troca de cor do `AppSvg` (`colors`): `#B6ACE4` = a `brand`, `#FF552E` = a tinta. Só a
// Caneta e o Espaço têm desenho de ativa (D-58).
abstract final class AppIllustrationsLeitor {
  static const _d = 'assets/illustrations/leitor';

  /// A Caneta inativa (corpo `#FFFAF1`) e ativa (corpo na `brand`, com a sombra).
  static const toolPen = '$_d/il_ferramenta_caneta.svg';
  static const toolPenActive = '$_d/il_ferramenta_caneta_ativa.svg';

  /// O Marca-texto, a Borracha, o Laço e a Reta (a ativa só sobe).
  static const toolMarker = '$_d/il_ferramenta_marcatexto.svg';
  static const toolEraser = '$_d/il_ferramenta_borracha.svg';
  static const toolLasso = '$_d/il_ferramenta_laco.svg';
  static const toolLine = '$_d/il_ferramenta_reta.svg';

  /// O Espaço inativo e ativo (tela 24, G18).
  static const toolSpace = '$_d/il_ferramenta_espaco.svg';
  static const toolSpaceActive = '$_d/il_ferramenta_espaco_ativa.svg';

  /// G17 — as amostras das pontas da tela 23 (80×26; o coral `#FF552E` vira a cor da caneta) e a dica "Gruda nas
  /// palavras" da 23b (34×22).
  static const tipBallpoint = '$_d/il_ponta_esferografica.svg';
  static const tipFountain = '$_d/il_ponta_tinteiro.svg';
  static const tipBrush = '$_d/il_ponta_pincel.svg';
  static const markerTip = '$_d/il_dica_gruda_nas_palavras.svg';

  /// As dos painéis 23 e 23b.
  static const panels = [tipBallpoint, tipFountain, tipBrush, markerTip];

  /// As que não levam cor do usuário (pré-carregadas no `main()`, como os ícones).
  static const plain = [
    toolMarker,
    toolEraser,
    toolLasso,
    toolLine,
    toolSpace,
    markerTip,
  ];

  static const all = [
    toolPen,
    toolPenActive,
    toolMarker,
    toolEraser,
    toolLasso,
    toolLine,
    toolSpace,
    toolSpaceActive,
  ];
}

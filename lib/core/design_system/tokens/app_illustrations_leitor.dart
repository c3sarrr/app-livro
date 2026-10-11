// G16 — as ilustrações do leitor, exportadas do arquivo novo na G01.8 (`assets/illustrations/leitor/`, catálogo em
// `handoff_v2/referencia/svg_catalogo.json`): os objetos da prateleira do modo anotação (50×70, telas 22–24b). As
// cores do usuário entram pela troca de cor do `AppSvg` (`colors`): `#B6ACE4` = a `brand`, `#FF552E` = a tinta. Só a
// Caneta e o Espaço têm desenho de ativa (D-58).
import 'package:flutter/painting.dart';

import '../painters/svg_dash_painter.dart';
import 'app_colors.dart';

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

/// T01 — os desenhos com um traço tracejado (`stroke-dasharray`): a `AppSvg` lê o SVG sem o traço desse elemento e o
/// pinta por cima, como o Chromium ([SvgDash]).
final Map<String, SvgDash> svgDashes = {
  // `<ellipse cx="25" cy="15" rx="15" ry="10.5" stroke="#1A1714" stroke-width="1.7" stroke-dasharray="4 3">`: o
  // caminho do `<ellipse>` no SVG começa em (cx + rx, cy) e segue no sentido horário
  AppIllustrationsLeitor.toolLasso: SvgDash(
    element: 'ellipse',
    viewBox: const Size(50, 70),
    path: Path()
      ..moveTo(40, 15)
      ..arcToPoint(
        const Offset(25, 25.5),
        radius: const Radius.elliptical(15, 10.5),
      )
      ..arcToPoint(
        const Offset(10, 15),
        radius: const Radius.elliptical(15, 10.5),
      )
      ..arcToPoint(
        const Offset(25, 4.5),
        radius: const Radius.elliptical(15, 10.5),
      )
      ..arcToPoint(
        const Offset(40, 15),
        radius: const Radius.elliptical(15, 10.5),
      )
      ..close(),
    on: 4,
    off: 3,
    width: 1.7,
    color: AppColors.ink,
  ),
  // `<path d="M3 18C9 13 14 19 20 14S29 12 32 9" stroke="#FF552E" stroke-width="1.6" stroke-linecap="round"
  // stroke-dasharray="2.5 2.5">` (o `S` repete o reflexo do controle anterior: 26 9)
  AppIllustrationsLeitor.markerTip: SvgDash(
    element: 'path',
    viewBox: const Size(34, 22),
    path: Path()
      ..moveTo(3, 18)
      ..cubicTo(9, 13, 14, 19, 20, 14)
      ..cubicTo(26, 9, 29, 12, 32, 9),
    on: 2.5,
    off: 2.5,
    width: 1.6,
    color: AppColors.flame,
    cap: StrokeCap.round,
  ),
};

// G16 — as ilustrações do leitor, exportadas do arquivo novo na G01.8 (`assets/illustrations/leitor/`, catálogo em
// `handoff_v2/referencia/svg_catalogo.json`): os objetos da prateleira do modo anotação (50×70, telas 22–24b). As
// cores do usuário entram pela troca de cor do `AppSvg` (`colors`): `#B6ACE4` = a `brand`, `#FF552E` = a tinta. Só a
// Caneta e o Espaço têm desenho de ativa (D-58).
import 'package:flutter/painting.dart';

import '../painters/svg_dash_painter.dart';
import 'app_colors.dart';
import 'app_illustrations_scanner.dart';

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
/// pinta por cima, como o Chromium ([SvgDash]). T13.11 (D-285): também os do scanner (T15) — os livros com o `id` do
/// elemento (outros `<rect>` do desenho têm traço) e a mira; nada que vem depois do tracejado no arquivo o cruza (o
/// teste do registro confere). D-286: o traço é medido na escala da pintura, como o Chromium.
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
  // `<rect id="tracejado" x="11" y="53" width="56" height="38" rx="6" fill="none" stroke="#FF552E" stroke-width="2.4"
  // stroke-dasharray="5 4">`: o caminho do `<rect>` de cantos redondos no Chromium começa em (x + rx, y) e segue no
  // sentido horário
  AppIllustrationsScanner.livroCodigoBarras: SvgDash(
    element: 'rect',
    id: 'tracejado',
    viewBox: const Size(86, 104),
    path: Path()
      ..moveTo(17, 53)
      ..lineTo(61, 53)
      ..arcToPoint(const Offset(67, 59), radius: const Radius.circular(6))
      ..lineTo(67, 85)
      ..arcToPoint(const Offset(61, 91), radius: const Radius.circular(6))
      ..lineTo(17, 91)
      ..arcToPoint(const Offset(11, 85), radius: const Radius.circular(6))
      ..lineTo(11, 59)
      ..arcToPoint(const Offset(17, 53), radius: const Radius.circular(6))
      ..close(),
    on: 5,
    off: 4,
    width: 2.4,
    color: AppColors.flame,
  ),
  // `<rect id="tracejado" x="18" y="16" width="44" height="34" rx="4" fill="#FFFAF1" stroke="#1A1714"
  // stroke-width="1.3" stroke-dasharray="4 3">` (o fundo creme fica no arquivo; o "?" que vem depois está dentro)
  AppIllustrationsScanner.livroInterrogacao: SvgDash(
    element: 'rect',
    id: 'tracejado',
    viewBox: const Size(84, 110),
    path: Path()
      ..moveTo(22, 16)
      ..lineTo(58, 16)
      ..arcToPoint(const Offset(62, 20), radius: const Radius.circular(4))
      ..lineTo(62, 46)
      ..arcToPoint(const Offset(58, 50), radius: const Radius.circular(4))
      ..lineTo(22, 50)
      ..arcToPoint(const Offset(18, 46), radius: const Radius.circular(4))
      ..lineTo(18, 20)
      ..arcToPoint(const Offset(22, 16), radius: const Radius.circular(4))
      ..close(),
    on: 4,
    off: 3,
    width: 1.3,
    color: AppColors.ink,
  ),
  // `<path d="M5 45V27A22 22 0 0 1 27 5H45M245 5…V125" stroke="#FFFAF1" stroke-width="5.5" stroke-dasharray="2 9">`,
  // com o `stroke-linecap="round"` da raiz: os 4 cantos, cada um um subcaminho (o padrão recomeça em cada um)
  AppIllustrationsScanner.miraScannerTracejada: SvgDash(
    element: 'path',
    viewBox: const Size(290, 170),
    path: Path()
      ..moveTo(5, 45)
      ..lineTo(5, 27)
      ..arcToPoint(const Offset(27, 5), radius: const Radius.circular(22))
      ..lineTo(45, 5)
      ..moveTo(245, 5)
      ..lineTo(263, 5)
      ..arcToPoint(const Offset(285, 27), radius: const Radius.circular(22))
      ..lineTo(285, 45)
      ..moveTo(285, 125)
      ..lineTo(285, 143)
      ..arcToPoint(const Offset(263, 165), radius: const Radius.circular(22))
      ..lineTo(245, 165)
      ..moveTo(45, 165)
      ..lineTo(27, 165)
      ..arcToPoint(const Offset(5, 143), radius: const Radius.circular(22))
      ..lineTo(5, 125),
    on: 2,
    off: 9,
    width: 5.5,
    color: AppColors.surface,
    cap: StrokeCap.round,
  ),
};

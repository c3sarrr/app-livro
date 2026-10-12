// T13.11 (R7) — as ilustrações novas da T18 · Cronômetro (telas 18, 18b), em `assets/illustrations/cronometro/`
// (D-284: a pasta da área da 1ª etapa que usa o desenho). Gerado por `tools/medicao/gen_classes_svg.py` do catálogo
// `docs/design/medicao/projeto/svg_catalogo.json` — não editar à mão. As cores já estão nos SVGs (cada variante de cor
// é um arquivo); o tamanho de uso entre parênteses, depois a descrição e os ids das pranchas. Os reusados (D-283: o
// mesmo desenho de um asset que já existia) continuam nas classes de antes:
// `AppIllustrationsInicio.coverBrasCubasWings`.
abstract final class AppIllustrationsCronometro {
  static const _d = 'assets/illustrations/cronometro';

  /// (104) Carimbo "META DO DIA · BATIDA" (`cr18b.sheet.stamp`). Cor dinâmica: #ABCF82 = prop "goal". Armadilha: o
  /// texto "META DO DIA · BATIDA · META DO DIA ·" (Figtree 900 10,5 ls 1) corre num `<textPath>` em volta do círculo
  /// (textLength 232, lengthAdjust spacing): o flutter_svg não faz textPath → no app, o desenho sem o texto e as letras
  /// distribuídas no arco por um pintor com o AppFonts; a cor do selo é a prop "goal".
  static const carimboMetaBatida = '$_d/carimbo_meta_batida.svg';

  static const all = <String>[carimboMetaBatida];

  /// Os desenhos com `<text>`: o `AppSvg` os lê sem os textos (`svgWithoutText`) e os textos voltam em `AppText` (ou
  /// num pintor, os de `<textPath>`) — armadilhas no catálogo.
  static const Set<String> withText = <String>{carimboMetaBatida};
}

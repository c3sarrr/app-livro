// T13.11 (R7) — as ilustrações novas da T14 · Biblioteca (telas 02, 17, 17b, 36), em
// `assets/illustrations/biblioteca/` (D-284: a pasta da área da 1ª etapa que usa o desenho). Gerado por
// `tools/medicao/gen_classes_svg.py` do catálogo `docs/design/medicao/projeto/svg_catalogo.json` — não editar à mão.
// As cores já estão nos SVGs (cada variante de cor é um arquivo); o tamanho de uso entre parênteses, depois a
// descrição e os ids das pranchas. Os reusados (D-283: o mesmo desenho de um asset que já existia) continuam nas
// classes de antes: `AppIllustrationsInicio.coverBrasCubasWings`; `AppIllustrationsInicio.coverDomCasmurro`.
abstract final class AppIllustrationsBiblioteca {
  static const _d = 'assets/illustrations/biblioteca';

  /// (16×30) Fita de marcador coral pendurada na capa da estante (`b02.shelf.book1.ribbon`, `b02.shelf.book2.ribbon`,
  /// `b02.shelf.book3.ribbon`).
  static const fitaMarcador = '$_d/il_fita_marcador.svg';

  static const all = <String>[fitaMarcador];

  /// Os desenhos com `<text>`: o `AppSvg` os lê sem os textos (`svgWithoutText`) e os textos voltam em `AppText` (ou
  /// num pintor, os de `<textPath>`) — armadilhas no catálogo.
  static const Set<String> withText = <String>{};
}

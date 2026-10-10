// T02 — as capas desenhadas da Início nova (`assets/illustrations/inicio2/`, catálogo em
// `docs/design/medicao/inicio2/svg_catalogo.json`): só estas duas são `<svg>` no arquivo; as outras capas e os
// cartões da revisão são `div`s com borda, raio e círculo (widgets — R5, recortes em `docs/design/medicao/inicio2/
// png/elementos/`). Os SVGs são o export literal: têm `<text>` (Instrument Serif e Figtree) e
// `preserveAspectRatio="xMidYMid slice"`, que o flutter_svg não reproduz (fonte do sistema, sem "slice") — a capa no
// app é o desenho sem os textos, em `BoxFit.cover`, com os textos em `AppText` nas posições do viewBox (armadilha da
// L01a2 e da L01b).
abstract final class AppIllustrationsInicio {
  static const _d = 'assets/illustrations/inicio2';

  /// Dom Casmurro, viewBox 96×144, usada em 101×153 no herói (`i01.hero.cover.art`, giro −3°).
  static const coverDomCasmurro = '$_d/il_capa_dom_casmurro.svg';

  /// Memórias Póstumas de Brás Cubas com asas, viewBox 96×144, usada em 29,6×45,6 na mini-barra
  /// (`i01b.miniBar.cover.art`, giro −5°).
  static const coverBrasCubasWings = '$_d/il_capa_bras_cubas_asas.svg';

  static const all = [coverDomCasmurro, coverBrasCubasWings];

  /// As que a Início da prancha 01 desenha (pré-carregadas no `main()`); a das asas é da 01b (T04).
  static const inicio01 = [coverDomCasmurro];

  /// Os desenhos com `<text>`: o `AppSvg` os lê sem os textos (`svgWithoutText`) e a capa põe os textos em `AppText`
  /// por cima (T03).
  static const Set<String> withText = {coverDomCasmurro, coverBrasCubasWings};
}

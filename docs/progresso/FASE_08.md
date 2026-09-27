# FASE 8 — Seção 6: "Para você" (motivo + carrossel de capas)

Checklist da fase (`design_handoff/fases/F08_para_voce.md`), item por item. Um item só é marcado com evidência.
Saídas literais dos comandos: `F08_verificacao.txt` · autorrevisão visual: `F08_comparacao.md`.

- [x] 8.1 Cabeçalho 44 (título 24 ls −0,6; "Ver tudo" 14/700 + seta 18 traço 2, gap 4)
  - **Construção** (`for_you_section.dart`): `Semantics(seção "Para você")` > `Column(stretch, min)` de largura total (o `_fullBleed` da
    F02 põe a Key `forYou` em 20→370) com, nesta ordem:
    - `Padding(h 20)` > `SizedBox(forYou.header, 44)` > `Row(spaceBetween)`;
    - `SizedBox(14)`, `Padding(h 20)` > `Align(centerLeft)` > chip, `SizedBox(14 + 4)`;
    - `SingleChildScrollView(forYou.carousel)`.
  - **Cabeçalho:** `Semantics(h3, headingLevel 3)` > `AppText('Para você')` e `Pressable(link)` > `SizedBox(forYou.seeAll, 44)` >
    `Row(min, gap 4)` com "Ver tudo" + `AppSvg(arrowRight, 18)`.
  - **Geometria** (`geometry_for_you_test.dart`, "8.1"):
    - título 109,392 × 28,8 a y + 7,600 (arquivo 109,35 × 28,8 a 7,6);
    - "Ver tudo" 78,008 × 44 encostado à direita, texto 56,008 × 16,8 centrado (y + 13,6), seta em (332; 13);
    - seção 327,0000 = 44 + 14 + 32,6 + 18 + 218,4.
  - **Estilo** (`style_for_you_test.dart`, "8.1"): `sectionTitleL` = Bricolage24 24/800/1,2 ls −0,6 tinta; `label14Bold` = Figtree
    14/700; seta `ic_arrow_right.svg` 18, traço 2 no viewBox 24 (escala 0,75 no canvas), sem `colorFilter`.
  - **Texto:** "Para você" baseline 1237,480 (arquivo 1237,48), 20,000–129,392 (129,35); "Ver tudo" 1234,460 (1234,46),
    291,992–348,000 (292,01–348,0).
  - **Pixels:** haste da seta em tinta e o papel logo acima.
- [x] 8.2 Chip 7/12/7/10, borda 1,5, brilho 14 + texto 13/600, gap 6 → 241,28×32,6
  - **Construção:** `Pill(forYou.reasonChip, padding LTRB 10/7/12/7, #FFFAF1, borda 1,5 tinta)` > `Row(min, gap 6)` com
    `AppSvg(sparkleSolid, 14)` e `AppText(HomeFormatters.forYouReason(reasonAuthor), body13Semi)`.
  - **Dados:** formatador novo `forYouReason` → "Porque você lê Machado de Assis", com teste unitário e a conferência literal no
    HTML do arquivo (`formatters_test.dart`).
  - **Geometria:** 241,297 × 32,600 (arquivo 241,28 × 32,6); brilho em (11,500; 9,300); texto 196,297, 6 depois do brilho e 13,5
    antes da borda externa direita (12 + 1,5).
  - **Estilo:** fundo `#FFFAF1`, borda 1,5 tinta, raio 999 → 16,3, sem sombra; `body13Semi` = Figtree 13/600 tinta.
  - **Texto:** baseline 1286,410 (arquivo 1286,41), 51,500–247,797 (51,5–247,78).
  - **Pixels (11 no chip, 2 na seta):** fundo dos dois lados do texto, bordas, o canto fora do semicírculo (papel), brilho, papel em volta e sem
    sombra.
- [x] 8.3 Carrossel 0→390, padding 20, gap 14, 18 px abaixo do chip, 3º item cortado em 390; rolagem D-03
  - **Construção:** `SingleChildScrollView(forYou.carousel, horizontal, padding h 20, Clip.hardEdge, physics null)` >
    `Row(start, gap 14)` com 3 × `Pressable(link)` > `SizedBox(forYou.itemN, 116)` > `Column(stretch, min, gap 10)` [capa, bloco
    de texto `Column(gap 2)`].
  - **Geometria:** carrossel 0→390 × 218,4, 18 abaixo do chip; itens em 20 / 150 / 280, largura 116; o 3º vai de 280 a 396 (6 além
    do viewport); conteúdo 416.
  - **Recortes** (`style_for_you_test.dart`, "8.3 recortes" e "8.3 canvas"): o que a seção pinta no canvas é exatamente o recorte do
    carrossel (retângulo 0→390 sem suavização) + os 3 `clipRRect` suavizados das capas; nada mais recorta; sem `saveLayer`; nenhuma
    rotação.
  - **Pixels (5):** a última coluna (389,67–390) ainda é capa verde, borda de cima em tinta e papel abaixo; papel entre as capas.
  - **Rolagem D-03** (`scroll_for_you_test.dart`, 7 execuções):
    - `maxScrollExtent 26`, `pixels 0` em repouso;
    - arrastar −100 → fica em 26 (item 1 em −6, item 3 termina em 370); arrastar +100 → 0 e a geometria volta a 41/41;
    - em Android (clamping + stretch) e iOS (bouncing, com `debugDefaultTargetPlatformOverride`);
    - a rolagem vertical da Início fica em 0;
    - repouso = golden do canvas na faixa da seção; de volta a 0, bytes idênticos ao repouso (0 de 8.388.900 pixels) e ao golden na
      faixa da seção (0 de 1.148.940); em 26 mudam só pixels da faixa do carrossel, com o item 2 igual ao repouso deslocado 78 px @3x.
- [x] 8.4 Memórias: `#FF552E`, lombada .15, elipse 123×116 (OvalBorder), título 19/0,95 em 3 linhas, autor `#FF552E` só visível sobre a elipse
  - **Construção** (`memorias_postumas_cover.dart`): `NeoBox(116×174, #FF552E, borda 1,5, raio 4/10/10/4, clip)` >
    `Stack(Clip.none)` com lombada (left 0 / top 0 / bottom 0 / width 7), elipse (`Positioned(left 20, right −30, bottom −58,
    height 116)` > `DecoratedBox(ShapeDecoration(OvalBorder, tinta))`), título (left 16 / right 10 / top 16) e autor (left 16 /
    bottom 12, sem right).
  - **Geometria:** elipse 123 × 116 em (41,5; 1430,66); título 87 × 54,15 em 3 linhas; autor 78,317 × 7,8 (shrink-to-fit: 63,757 +
    16 × 0,91; arquivo 78,33).
  - **Texto:** "Memórias" / "Póstumas de" / "Brás Cubas", baselines 1349,145 / 1367,195 / 1385,245 (arquivo 1349,14 / 1367,19 /
    1385,24). "Póstumas de Brás" (112,423) e "Memórias Póstumas" (129,580) não caberiam em 87.
  - **Estilo:** `coverTitle19` (Instrument Serif 19/0,95 tinta), `coverAuthorFlame` (Figtree 6,5/700 ls 0,91 `#FF552E`); lombada
    `0x26000000`; `ShapeDecoration(OvalBorder)`, não `BoxShape.circle`; canvas: `drawRRect #FF552E → drawDRRect borda → drawRect
    0x26000000 → drawOval tinta → textos`.
  - **Pixels (16):** fundo, lombada `0xFFD94827` (src-over exato), elipse em dois pontos (um que um círculo não cobriria), borda de baixo
    sob a elipse, cantos 4 e 10, sem sombra; "ACHADO DE ASSIS": 686 pixels `#FF552E` do texto sobre a tinta; a área do "M" (x
    37,33–42,67) tem só `#FF552E` (384 pixels, 0 diferentes).
  - **Correção durante a fase:** a `Stack` usava o `Clip.hardEdge` padrão e, com a elipse transbordando, recortava de novo sem
    suavização (a lombada sumia da coluna física 64). Agora `Clip.none` nas 3 capas: coluna 64 = `0xFF873420` (com lombada), e o
    teste exige um único `clipRRect` por capa.
- [x] 8.5 Quincas: `#058CD7`, lombada .18, barras 6 px (81/56,7/32,4, gap 6), "Quincas⏎Borba" 26/0,9, autor
  - **Construção** (`quincas_borba_cover.dart`): lombada; `Positioned(left 16, right 16, top 18)` > `Column(lines, stretch, min,
    gap 6)` de `FractionallySizedBox(widthFactor 1 / .7 / .4, centerLeft)` > `SizedBox(lineN, 6)` > `DecoratedBox(#F7F0E3, raio 6)`;
    `Positioned(left 16, right 10, bottom 12)` > `Column(textBlock, stretch, min, gap 6)` com "Quincas\nBorba" e o autor.
  - **Geometria:** barras 81 / 56,7 / 32,4 × 6 alinhadas à esquerda em y 1335,66 / 1347,66 / 1359,66; bloco 87 × 60,6 (arquivo
    60,61).
  - **Texto:** "Quincas" / "Borba" baselines 1436,600 / 1460,000 (arquivo 1436,59 / 1459,99); autor 1475,035 (1475,02).
  - **Estilo:** `coverTitle26` (26/0,9 `#FFFAF1`), `coverAuthorSurface`; lombada `0x2E000000`; barras raio 6 (→ 3).
  - **Pixels (19):** fundo, lombada `0xFF0473B0`, centro das 3 barras, vão entre elas, azul depois de 70 % e de 40 %, cantos, bordas,
    sem sombra.
- [x] 8.6 O Cortiço: `#00995E`, lombada .18, arco `#FED170` 68×80 (34/34/0/0) + arco `#00995E` 28×46 (14/14/0/0), título e autor
  - **Construção** (`o_cortico_cover.dart`): lombada; arco externo `Positioned(left 24, top 22, 68×80)` > `NeoBox(#FED170, raio
    34/34/0/0)`; arco interno `Positioned(left 44, top 56, 28×46)` > `NeoBox(#00995E, raio 14/14/0/0)`; bloco inferior "O Cortiço" +
    "ALUÍSIO AZEVEDO".
  - **Geometria:** arcos em (305,5; 1339,66) e (325,5; 1373,66); bloco 87 × 37,2 (arquivo 37,21).
  - **Texto:** "O Cortiço" baseline 1460,000 (1459,99), 297,5–379,270 (379,27); autor 297,5–368,979 (368,99).
  - **Pixels (14):** fundo, lombada `0xFF007D4D`, faixa, topo, canto (raio 34) e base do arco, "porta" com topo e canto (raio 14),
    bordas, sem sombra.
- [x] 8.7 Legendas 14/700/1,2 e 13/500; "Memórias Póstu…" (só o 1º com reticências)
  - **Construção:** título `AppText(shortTitle ?? title, label14Bold)` com `maxLines 1` + reticências só no item 1; autor
    `AppText(author, body13Muted)` sem limite.
  - **Geometria:** títulos 116 × 16,8 e autores 116 × 15,6, 2 abaixo; bloco 34,4.
  - **Texto:** linha pintada "Memórias Póstu…" de 20,000 a 132,876 (112,876; arquivo 112,88); "Memórias Póstum…" mediria 125,082
    (estoura 116 por 9,082). "Quincas Borba" 93,402 e "O Cortiço" 63,022 cabem sem reticências. Autores 105,339 / 105,339 / 93,425.
  - **Dados:** montado com outro `ForYou` (override do provider), o motivo, os títulos e os autores seguem os dados; um título longo
    no item 2 quebra em 3 linhas sem reticências, como o CSS.
- [x] Geometria 41/41 · Texto OK · Estilo OK · Rolagem OK · Visual ≤ 0,5% · Não-regressão OK
  - **Geometria:** 41/41 ids. O maior desvio é `forYou.title.w` = 0,042 px; todos ≤ 0,05.
  - **Texto:** 15 textos e 18 linhas com strings e quebras exatas; baselines com Δ ≤ 0,015; inícios e fins com Δ ≤ 0,042.
  - **Estilo:** 17 testes; cores, alphas, bordas e os 67 pontos de pixel @3x + 3 colunas de lombada exatos; raio normalizado do chip
    e formas dos recortes no canvas com ±1e-3 / 1e-6 (ruído float32); recortes e ordem de pintura conferidos no canvas.
  - **Semântica:** seção "Para você" (container, filhos na ordem do documento); h3 nível 3; link "Ver tudo"; texto do chip; 3 links
    com o texto do item (título completo, sem "…"); toques e `SemanticsAction.tap` chamam o callback certo; o carrossel expõe
    `scrollLeft`/`scrollToOffset` (rolagem D-03).
  - **Rolagem:** ver 8.3.
  - **Visual:** `--rect 0,1199,390,344` → `blur_mismatch_%` **0,0** (raw 2,0278, mean_abs 1,63, max 229) → PASSOU. No modo `--layout`, as 5 seções
    anteriores repetem os números da F07 e forYou dá 0,0.
  - **Resíduo:** só rasterização (`F08_comparacao.md`): deriva vertical +0,1…+0,2 px da própria referência, hinting da Instrument
    Serif a 3× e uma costura de 1/3 px (duas arestas de 50 % na mesma coluna).
  - **Não-regressão:**
    - acima (0, 0, 390, 1207) e abaixo (0, 1535, 390, 855) contra o golden APROVADO da F07: 0,0 / 0,0 / max 0;
    - os 628.476 pixels alterados estão todos na faixa da seção;
    - testes F00–F07 verdes. O carrossel é a 2ª rolagem da Início (dentro da 1ª): `homeScrollPosition` e 8 finders de
      `geometry_shell_test` / `router_test` passaram a apontar para a rolagem mais externa da HomeScreen (`homeScrollView()`), sem
      mudar nenhum assert.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes
  - `Formatted 99 files (0 changed)`, exit 0.
  - `No issues found!`, exit 0.
  - `+353: All tests passed!`, exit 0: os 305 anteriores + 48 da F08 (geometria 11, texto 8, estilo 17, semântica 4, rolagem 7,
    formatador 1).
  - `design_handoff/` 131/131 OK.
  - Suíte completa repetida mais 2 vezes: 3/3 execuções `+353`, nenhuma "did not complete".
- [x] Relatório com lado-a-lado e heatmap inspecionados
  - Autorrevisão do §8: `secoes/F08_para_voce@3x.png` | golden | `redline/F08_para_voce_redline@3x.png` lado a lado
    (`F08_para_voce_secao_golden_redline.png`).
  - Inspecionados: `F08_para_voce_lado_a_lado.png`, `F08_para_voce_heatmap.png` e os 8 recortes ampliados (referência | Flutter 3×
    | Flutter 10× → 3×) do cabeçalho com o chip, do autor sobre a elipse, do título da Memórias, das barras, dos arcos, do corte do
    3º item, dos cantos e das legendas; mais a sonda de escala.
  - Análise em `F08_comparacao.md`; relatório em `RELATORIO_FASE_08.md`.

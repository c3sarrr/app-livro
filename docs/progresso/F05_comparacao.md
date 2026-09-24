# FASE 5 — autorrevisão visual (camada 3 do prompt mestre §7)

Golden: `test/golden/goldens/inicio_canvas@3x.png` (1170 × 7170, `captureAt` 3×), sha256 `85f6b910…dbd1e760` — igual em
regenerações seguidas (render determinístico). Golden aprovado da F04 (o do commit `511a169`) preservado em
`build/visual_diff/F05/golden_aprovado_F04.png` (sha256 `a71b784b…118898d7c`, o mesmo registrado na F04). Referência:
`design_handoff/referencia/png/inicio_canvas_390x2390@3x.png`.

## Gate da fase — seção `hero` (`--rect 16,244,358,284`)

| Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
|---|---:|---:|---:|---:|---|
| F05_hero (16, 244, 358, 284) | 0,0 | 0,6331 | 0,702 | 128 | PASSOU (gate ≤ 0,5) |
| hero no modo `--layout` | 0,0 | 0,6195 | 0,687 | 128 | PASSOU |
| header no modo `--layout` (não-regressão) | 0,0 | 0,4113 | 0,53 | 142 | PASSOU (idêntico à F04) |
| headline no modo `--layout` (não-regressão) | 0,0 | 1,3126 | 1,306 | 221 | PASSOU (idêntico à F04) |

Evidências inspecionadas: `build/visual_diff/F05/F05_hero_lado_a_lado.png` (referência | Flutter | heatmap), `F05_hero_heatmap.png`,
`F05_hero_onion.png` e a ampliação `F05_hero_zoom_bordas_6x.png` (referência | Flutter, 1 px @3x = 6 px). No lado a lado as duas
versões são indistinguíveis: capa girada −3° com a sombra 3/3 girando junto, sol recortado no canto superior direito da capa, anel
vazado, lombada, "Dom / Casmurro" e "MACHADO DE / ASSIS", pílula, brilho pequeno encostando no "rr" do título, barra a 62 %, CTA
centralizado e badge "14" saindo do contorno do botão. O heatmap mostra só halos fracos nas bordas dos textos (mais visíveis no autor
de 6,5 px da capa e no rótulo do CTA) e nas arestas da barra.

## Onde estão as diferenças de pixel (todas de rasterização)

Diferença = máximo entre canais, em níveis de 0–255. "3×" é o golden (render direto). "10× → 3×" é o MESMO hero renderizado pelo
Flutter a 10× (`OffsetLayer.toImage(rect, pixelRatio: 10)`, sonda temporária já removida) e reduzido a 3× por média de área —
o mesmo caminho da referência (supersample 10× → 3×). A sonda a 3× coincide com o golden (5 pixels diferem, max 7, na ponta direita
do CTA). Imagens em `build/visual_diff/F05/sonda_escala/`.

| Região | 3× px > 32 | 3× px > 64 | 3× max | 10× → 3× px > 32 | 10× → 3× px > 64 | 10× → 3× max |
|---|---:|---:|---:|---:|---:|---:|
| hero inteiro | 10.175 | 2.004 | 128 | 4.529 | 26 | 77 |
| capa: título serif | 883 | 192 | 128 | 354 | 12 | 75 |
| capa: autor 6,5 px | 487 | 189 | 121 | 225 | 8 | 73 |
| pílula | 1.041 | 178 | 108 | 571 | 2 | 66 |
| título Bricolage | 1.350 | 286 | 107 | 59 | 0 | 47 |
| rótulo do CTA | 939 | 327 | 123 | 33 | 0 | 44 |
| barra de progresso | 1.091 | 631 | 85 | 417 | 0 | 52 |
| brilho grande | 129 | 31 | 123 | 51 | 0 | 48 |

Sonda inteira contra a referência no retângulo do gate: `blur_mismatch_%` 0,0 · `raw_mismatch_%` **0,0791** · mean_abs 0,497 ·
max **77** (render direto a 3×: 0,6331 · 0,702 · 128).

Leitura, componente a componente (ampliação `F05_hero_zoom_bordas_6x.png`):
- **Textos em Figtree/Bricolage (pílula, título, autor, "62%", tempo, CTA, badge):** mesmas formas e posições; as diferenças são
  pixels de borda de glifo e somem quase todas a 10× (título: 286 → 0 pixels acima de 64; CTA: 327 → 0). Posição de layout exata
  pela camada 4 (baselines Δ ≤ 0,001; inícios/fins Δ ≤ 0,05). Mesma assinatura da F03/F04: arredondamento da baseline ao pixel de
  dispositivo no render direto a 3×.
- **Título da capa (Instrument Serif 22, girado −3°):** a 3× os topos da altura-x de "Casmurro" saem 1 px de dispositivo acima
  (max 128 em (105,67; 378,00)). É o hinting TrueType da Instrument Serif (fpgm/prep/cvt; Bricolage e Figtree não têm), já
  documentado na F04 para o título editorial; a 10× o resíduo cai para 12 pixels acima de 64. A posição das linhas é exata: com a
  arte montada sem o giro no slot de layout, as 4 linhas da capa ficam a ≤ 0,02 px das baselines, inícios e fins do arquivo
  (`text_hero_test.dart`).
- **Autor da capa (Figtree 6,5 / 700, girado):** glifos de 6,5 px com o traço inteiro em poucos pixels de dispositivo; a
  diferença é só suavização (189 → 8 pixels acima de 64 a 10×).
- **Barra de progresso (costura clara de 1 px de dispositivo entre a borda e o preenchimento):** a borda interna da barra e a borda
  do preenchimento coincidem em y 419,16 e 426,16 (1257,48 e 1278,48 em px de dispositivo) e na curva da ponta esquerda (raio 3,5).
  O rasterizador desenha as duas bordas com anti-aliasing por cobertura; onde elas se encontram no meio de um pixel, as coberturas
  complementares não somam tinta cheia (artefato de conflação), e sobra o trilho claro por baixo. Números, canal G (tinta = 23):
  nas retas, referência 23..24 × Flutter 108..109 (a sonda 10× → 3× dá 54, a 1/3,3 da intensidade); na curva, referência até
  **52** × Flutter até 112. A referência também tem a costura na curva, onde o Chromium não consegue alinhar a borda ao grid do
  supersample 10×; nas retas ele alinhou a caixa ao pixel e a costura sumiu. Forma, posição (camada 1: preenchimento 110,36 × 7 a
  1,5/1,5 da barra, Δ 0,000), cor e ordem de pintura são as do arquivo; a 10× → 3× a barra fica com 0 pixels acima de 64.
- **Brilho grande (traço 1,3 no viewBox 24 → 1,625 px):** perto da ponta superior os dois traços convergem; diferença só de
  suavização (31 → 0 pixels acima de 64 a 10×).

Conclusão: nenhuma diferença de forma, posição, cor, espessura, ordem de pintura ou recorte. Tudo o que resta a 3× é rasterização
(hinting da Instrument Serif, suavização de bordas finas e conflação de bordas coincidentes), e o gate passa com folga.

## Cor (camada 2 nos pixels)

`style_hero_test.dart` confere 20 pontos do canvas @3x, 8 deles levados pelo giro −3° da capa (`localToGlobal` do conteúdo girado).
Resultados: fundo brand `0xFFB6ACE4`; borda e sombras duras do cartão em tinta; papel além da sombra; violeta `0xFF552CB7` no meio
da capa; lombada `0xFF42228F` (22 % de preto sobre o violeta: 66,33 / 34,34 / 142,81); sol `0xFFFED170` dentro da capa e fundo brand
3,5 px acima da borda superior (recortado); anel vazado com traço `0xFFFED170`; sombra girada da capa em tinta e brand logo além
dela; miolos dos brilhos `0xFFFFFAF1` e tinta; preenchimento e trilho da barra; fundo do CTA; fundo do botão; badge `0xFFFED170`.

## Tema (brand)

Para cada opção de `AppColors.brandOptions`, `homeThemeProvider.setBrand` → a decoração do cartão recebe a cor e o fundo em (30; 440)
passa a ser exatamente ela. Pixels alterados contra o render padrão: lavanda 0 (é o padrão); rosa `#FFC1C6` 498.726; verde `#ABCF82`
498.744; amarelo `#FED170` 498.744. Nenhum deles fora do retângulo do cartão (a sombra e tudo fora do cartão ficam idênticos).

## Não-regressão

| Comparação | blur_mismatch_% | raw_mismatch_% | max | Resultado |
|---|---:|---:|---:|---|
| topo (0, 0, 390, 244: inset + header + headline) × golden APROVADO da F04 | 0,0 | 0,0 | 0 | PASSOU |
| abaixo do hero (0, 528, 390, 1862: placeholders, fade, navegação) × golden APROVADO da F04 | 0,0 | 0,0 | 0 | PASSOU |

Diferença pixel a pixel contra o golden aprovado da F04: 877.030 pixels alterados, caixa x 20,00..374,00 × y 248,00..527,33, todos
dentro do retângulo do hero mais a sombra dura 4/4 (20; 248,16 → 374; 527,16), nenhum fora. No modo `--layout`, as 7 regiões ainda
não construídas repetem exatamente os números da F04 (falham por definição, §7).

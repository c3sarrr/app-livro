# FASE 6 — autorrevisão visual (camada 3 do prompt mestre §7)

Golden: `test/golden/goldens/inicio_canvas@3x.png` (1170 × 7170, `captureAt` 3×), sha256 `d1e41382…e9b3f503`, igual em
regenerações seguidas (render determinístico). O golden aprovado da F05 foi preservado em
`build/visual_diff/F06/golden_F05_aprovado.png` (sha256 `85f6b910…dbd1e760`, o mesmo registrado na F05). Referência:
`design_handoff/referencia/png/inicio_canvas_390x2390@3x.png`.

## Gate da fase: seção `alsoReading` (`--rect 16,547,358,192`)

| Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
|---|---:|---:|---:|---:|---|
| F06_tambem_lendo (16, 547, 358, 192) | 0,0 | 0,8818 | 0,971 | 189 | PASSOU (gate ≤ 0,5) |
| alsoReading no modo `--layout` | 0,0 | 0,8922 | 0,982 | 189 | PASSOU |
| header no modo `--layout` (não-regressão) | 0,0 | 0,4113 | 0,53 | 142 | PASSOU (idêntico à F05) |
| headline no modo `--layout` (não-regressão) | 0,0 | 1,3126 | 1,306 | 221 | PASSOU (idêntico à F05) |
| hero no modo `--layout` (não-regressão) | 0,0 | 0,6195 | 0,687 | 128 | PASSOU (idêntico à F05) |

Evidências inspecionadas:
- `build/visual_diff/F06/F06_tambem_lendo_lado_a_lado.png` (referência | Flutter | heatmap);
- `F06_tambem_lendo_heatmap.png` e `F06_tambem_lendo_onion.png`;
- a ampliação `F06_tambem_lendo_zoom_6x.png`, em três colunas: referência | Flutter 3× (golden) | Flutter 10× reduzido a 3×.
  Nela, 1 px @3x vira 6 px.

No lado a lado as duas versões não se distinguem. Estes pontos batem com o arquivo:
- Capas saltando 22 px para cima e passando por cima da borda dos cards.
- Giro de −4° em Mrs. Dalloway e de +3° em Orgulho e Preconceito, com a sombra 2/2 girando junto.
- Arco preto com topo arredondado.
- Círculo vazado e lombadas.
- Títulos das capas em duas linhas.
- Anéis começando no topo, com ponta redonda.
- "Orgulho e Precon…" truncado no mesmo ponto.
- Contador "2" no círculo preto.

O heatmap só mostra halos fracos:
- Bordas dos textos. São mais visíveis nos títulos serifados das capas e nos rótulos "34%"/"81%".
- Uma linha fraca na borda de baixo dos cards.

## Onde estão as diferenças de pixel (todas de rasterização)

Diferença = máximo entre canais, em níveis de 0–255. "3×" é o golden (render direto).

"10× → 3×" é a MESMA seção renderizada pelo Flutter a 10× e reduzida a 3× por média de área. É o mesmo caminho da referência (supersample 10× → 3×):
- A sonda usou `OffsetLayer.toImage(rect, pixelRatio: 10)` na raiz do golden. Foi temporária e já foi removida.
- A sonda a 3× coincide com o golden: 10 pixels diferem, max 7.
- Imagens em `build/visual_diff/F06/sonda_escala/`.

| Região | 3× px > 32 | 3× px > 64 | 3× max | 10× → 3× px > 32 | 10× → 3× px > 64 | 10× → 3× max |
|---|---:|---:|---:|---:|---:|---:|
| seção inteira | 7.534 | 2.116 | 189 | 2.788 | 47 | 123 |
| título "Também lendo" (Bricolage 18) | 1.209 | 564 | 133 | 4 | 0 | 37 |
| contador "2" | 152 | 45 | 120 | 44 | 0 | 48 |
| capa 1: título serif 11 | 404 | 75 | 156 | 57 | 6 | 95 |
| capa 2: título serif 9 | 631 | 246 | 189 | 204 | 40 | 123 |
| capa 1 sem o título (arte, sombra, arestas) | 227 | 4 | 92 | 43 | 0 | 41 |
| capa 2 sem o título (arte, sombra, arestas) | 283 | 39 | 99 | 208 | 0 | 46 |
| anel 1 + "34%" | 422 | 192 | 155 | 37 | 1 | 70 |
| anel 2 + "81%" | 450 | 178 | 160 | 41 | 0 | 56 |
| card 1: título (Figtree 15/700) | 781 | 330 | 129 | 1 | 0 | 33 |
| card 2: título "Orgulho e Precon…" | 1.020 | 415 | 130 | 2 | 0 | 33 |
| autores (Figtree 13/500) | 150 | 0 | 56 | 0 | 0 | 24 |
| borda de baixo dos cards | 799 | 0 | 64 | 1.507 | 0 | 38 |

Sonda inteira contra a referência no retângulo do gate:

| Métrica | Sonda 10× → 3× | Render direto a 3× |
|---|---:|---:|
| `blur_mismatch_%` | 0,0 | 0,0 |
| `raw_mismatch_%` | **0,0433** | 0,8818 |
| mean_abs | 0,421 | 0,971 |
| max | **123** | 189 |

### Componente a componente

A leitura abaixo usa `F06_tambem_lendo_zoom_6x.png` e as análises do fim de `F06_verificacao.txt`.

**Títulos das capas (Instrument Serif 9 e 11 px, girados +3° e −4°).** São os maiores resíduos. O max 189 fica em (252,33; 654,67), no "o" de "Preconceito".

Na ampliação as três versões têm os mesmos glifos, nas mesmas posições. A 3× os traços saem mais finos, com cerca de 86 % da tinta da referência; a 10× → 3×, com cerca de 97 %.

Medi os centroides de tinta por glifo (componentes conexos da referência: 19 glifos na capa 2 e 12 na capa 1). O maior deslocamento:

| Capa | 3× direto | 10× → 3× |
|---|---:|---:|
| capa 2 | 0,203 px lógico | 0,137 px lógico |
| capa 1 | 0,100 px lógico | 0,094 px lógico |

A 10× → 3×, quase todos os glifos ficam a ≤ 0,09 px. O resto vem de duas causas:
- **Hinting TrueType da Instrument Serif.** É o mesmo da F04/F05; a 27 e 33 ppem ele pesa mais.
- **Arredondamento da baseline do texto ao pixel de dispositivo no supersample 10× do Chromium.** Tem granularidade de 0,1 px lógico.

A posição de layout das linhas é exata. Com as artes montadas sem o giro nos slots de layout (`text_also_reading_test.dart`), as 4 linhas das capas ficam assim:
- baselines a ≤ 0,005 px do arquivo;
- inícios a 0,000;
- fins a ≤ 0,004.

**Textos em Figtree/Bricolage** ("Também lendo", "2", "34%", "81%", títulos e autores). Mesmas formas e posições. As diferenças são pixels de borda de glifo e quase somem a 10×:

| Texto | Pixels > 64 a 3× | Pixels > 64 a 10× → 3× |
|---|---:|---:|
| título da seção | 564 | 0 |
| títulos dos cards | 330 e 415 | 0 |
| rótulos dos anéis | 177 e 165 | 1 e 0 |

A camada 4 dá a posição exata: baselines com Δ ≤ 0,001 e inícios/fins com Δ ≤ 0,02. É a mesma assinatura da F03–F05: o render direto a 3× arredonda a baseline ao pixel de dispositivo.

**Anéis.** Os arcos batem nas três versões:
- começam no topo e têm ponta redonda;
- 34 % termina em cerca de 122°;
- 81 % termina em cerca de 292°.

A camada 2 confere os pixels em 10 ângulos (arco, trilho e as duas pontas) e no miolo.

O SVG do arquivo usa `stroke-dasharray` 38,5/91,6. O `RingProgressPainter` traça 2π·18·progresso = 38,453/91,609. A diferença de ≤ 0,05 px de arco está coberta pelo teste da F01 e é invisível.

**Arte das capas.** Arco, círculo, lombadas, bordas giradas e sombras duras giradas não têm nenhum pixel > 64 a 10× → 3×.

A 3× sobram 4 e 39 pixels > 64. É suavização das arestas giradas: a borda de 1,5 px do círculo e o contorno da capa. A cor foi conferida nos pixels, através do giro (ver "Cor").

**Borda de baixo dos cards** (linha fraca no heatmap). O CSS põe a borda em 729,26–730,76, e o Flutter pinta exatamente aí. Na linha de dispositivo 2187 (729,000–729,333), canal G:
- **Flutter:** 193, isto é 25 % de tinta, com a borda interna em 729,25;
- **referência:** 250, sem tinta.

Ou seja, no supersample 10× o Chromium alinhou as bordas da caixa à grade de pixels. A borda de cima confirma: na referência começa em 607,22, contra 607,16 do CSS.

Essa diferença é ≤ 0,07 px lógico, com max 64 a 3× e 38 a 10× → 3×. Não muda a geometria, que dá card 169 × 123,6 com Δ 0,000.

**Conclusão.** Nenhuma diferença de forma, posição, cor, espessura, ordem de pintura ou recorte. Tudo o que resta a 3× é rasterização:
- hinting da Instrument Serif em 9/11 px;
- suavização de bordas de glifo e de arestas giradas;
- alinhamento das bordas ao pixel na referência.

O gate passa com folga (blur 0,0).

## Cor (camada 2 nos pixels)

`style_also_reading_test.dart` confere 34 pontos do canvas @3x e as 2 lombadas por composição (36 no total). Treze deles, incluindo as lombadas, são levados pelo giro das capas (`localToGlobal` do conteúdo girado).

**Cards e contador**
- Contador: tinta.
- Fundo dos cards: `#FFFAF1`.
- Bordas: tinta.
- Papel `#F7F0E3` logo à direita e logo abaixo das bordas, porque os cards não têm sombra.

**Capa 1 (Mrs. Dalloway)**
- Verde `#ABCF82` entre o arco e o título.
- Arco em tinta.
- Canto do arco fora do raio 16 em verde, o que prova o topo arredondado.
- Sombra girada à direita e embaixo em tinta, com o card `#FFFAF1` logo além.

**Capa 2 (Orgulho e Preconceito)**
- Rosa `#FFC1C6`.
- Miolo do círculo rosa (vazado) e traço do círculo em tinta.
- Sombra girada em tinta, com o card logo além.

**As capas por cima do card**
- Na faixa da borda superior do card (y 607,16–608,66): verde em (45; 607,91) e rosa em (230; 607,91).
- Acima do card (vazamento): verde em (62,5; 595) e rosa em (243,5; 595).

**Anéis**
- Anel 34 %: arco a 60° e na ponta inicial a −5°; trilho `#EAE1CF` a 140°, 180°, 270° e −15°; miolo claro.
- Anel 81 %: arco a 90°, 180° e 270°; trilho a 320°.

**Lombadas** (composição src-over de preto)
- 15 % de preto sobre o verde: `0xFF92B06F`, com o exato 145,52 / 176,15 / 110,63.
- 12 % sobre o rosa: `0xFFE0AAAE`, com o exato 224,00 / 169,54 / 173,93.

## Não-regressão

| Comparação | blur_mismatch_% | raw_mismatch_% | max | Resultado |
|---|---:|---:|---:|---|
| acima da seção (0, 0, 390, 555: inset, header, headline e hero) × golden APROVADO da F05 | 0,0 | 0,0 | 0 | PASSOU |
| abaixo da seção (0, 731, 390, 1659: placeholders, fade, navegação) × golden APROVADO da F05 | 0,0 | 0,0 | 0 | PASSOU |

Diferença pixel a pixel contra o golden aprovado da F05:
- 401.015 pixels alterados;
- caixa: x 20,00..370,00 × y 555,00..731,00;
- todos dentro do retângulo da seção (20; 555,16 → 370; 730,76), nenhum fora.

As capas vazam para cima dentro do gap de 30 da própria seção. A parte mais alta fica em y ≈ 584,9, abaixo do cabeçalho.

No modo `--layout`, as 6 regiões ainda não construídas repetem exatamente os números da F05. Elas falham por definição (§7).

Sondagem fluida (informativa; a validação formal de 360/430 é da F13): os 29 ids da seção batem com `kRefLayoutW360` e `kRefLayoutW430`, com maior desvio de −0,005 px. A grade `minmax(0, 1fr)` e as reticências acompanham a largura como no CSS.

# FASE 4 — autorrevisão visual (camada 3 do prompt mestre §7)

Golden: `test/golden/goldens/inicio_canvas@3x.png` (1170 × 7170, `captureAt` 3×), sha256 `a71b784b…118898d7c` — igual em
regenerações seguidas (render determinístico). Golden aprovado da F03 preservado em `build/visual_diff/F04/golden_aprovado_F03.png`
(sha256 `e2528321…36578e88`, o mesmo registrado na F03). Referência: `design_handoff/referencia/png/inicio_canvas_390x2390@3x.png`.

## Gate da fase — seção `headline` (`--rect 0,126,390,106`)

| Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
|---|---:|---:|---:|---:|---|
| F04_headline (0, 126, 390, 106) | 0,0 | 1,1724 | 1,166 | 221 | PASSOU (gate ≤ 0,5) |
| headline no modo `--layout` | 0,0 | 1,3126 | 1,306 | 221 | PASSOU |
| header no modo `--layout` (não-regressão) | 0,0 | 0,4113 | 0,53 | 142 | PASSOU (idêntico à F03) |

Evidências inspecionadas: `build/visual_diff/F04/F04_headline_lado_a_lado.png`, `F04_headline_heatmap.png`, `F04_headline_onion.png`
e a ampliação `F04_headline_zoom_linha2_9x.png` (referência / golden / sonda a 10×, a 9× do lógico). No lado a lado os dois títulos
são indistinguíveis; o heatmap mostra um halo fraco nas bordas dos glifos e manchas mais fortes em três lugares da linha 2: os pingos
dos dois "i" e o acento de "ó". Como o `max` 221 vem justamente dali (pixels inteiros de tinta × papel), medi cada glifo.

## Onde estão as diferenças de pixel (todas de rasterização)

Massa de tinta = soma da cobertura (papel → tinta); centroide ponderado; px lógicos; Δ = Flutter − referência. A coluna "3×" é o
golden (render direto a 3×, fonte a 126/150 ppem). As colunas "6×" e "10×" são o MESMO título renderizado pelo Flutter com
`toImage(pixelRatio: 6 | 10)` (sonda temporária, removida; imagens em `build/visual_diff/F04/sonda_escala/`). Na sonda a 3× os
números são idênticos aos do golden.

| Linha | Componente | Δ cx 3× | Δ cy 3× | Δ massa 3× | Δ cy 6× | Δ cy 10× | Δ massa 10× |
|---|---|---:|---:|---:|---:|---:|---:|
| 1 | "Co" | −0,01 | −0,07 | −1,2 % | +0,10 | +0,04 | −0,0 % |
| 1 | "n" | +0,04 | −0,06 | −1,3 % | +0,09 | +0,04 | −0,0 % |
| 1 | "t" | +0,05 | −0,08 | −0,9 % | +0,08 | +0,04 | +0,3 % |
| 1 | pingo do "i" | +0,02 | −0,03 | −1,8 % | +0,14 | +0,04 | −0,0 % |
| 1 | haste do "i" | +0,02 | −0,06 | −0,5 % | +0,08 | +0,03 | +0,5 % |
| 1 | "n" | +0,04 | −0,06 | −1,5 % | +0,09 | +0,04 | −0,2 % |
| 1 | "u" | +0,01 | −0,08 | −1,3 % | +0,09 | +0,03 | −0,1 % |
| 1 | "e" | +0,01 | −0,07 | −1,2 % | +0,11 | +0,04 | +0,1 % |
| 2 | "s" | +0,02 | −0,27 | −3,0 % | −0,02 | −0,06 | +0,1 % |
| 2 | "u" | +0,06 | −0,28 | −2,1 % | −0,04 | −0,05 | +0,1 % |
| 2 | "a" | +0,02 | −0,11 | −2,3 % | −0,05 | −0,04 | −0,0 % |
| 2 | "h" | −0,00 | −0,03 | −1,2 % | −0,00 | −0,03 | +0,1 % |
| 2 | "is" (sem o pingo) | −0,00 | −0,24 | −2,7 % | −0,02 | −0,04 | −0,0 % |
| 2 | pingo do 1º "i" | +0,00 | **−0,50** | −0,9 % | −0,04 | −0,06 | −0,2 % |
| 2 | "t" | +0,01 | −0,26 | −1,7 % | −0,06 | −0,07 | +0,3 % |
| 2 | "o" | −0,00 | −0,19 | −2,6 % | −0,01 | −0,05 | −0,1 % |
| 2 | acento de "ó" | +0,03 | **−0,39** | −3,0 % | −0,03 | −0,05 | −0,1 % |
| 2 | "ri" (sem o pingo) | −0,07 | −0,14 | −0,9 % | −0,01 | −0,04 | +0,0 % |
| 2 | pingo do 2º "i" | +0,02 | **−0,50** | −0,8 % | −0,04 | −0,06 | −0,2 % |
| 2 | "a" | −0,03 | −0,12 | −2,3 % | −0,05 | −0,05 | −0,1 % |
| 2 | "." | +0,04 | −0,19 | −0,5 % | −0,04 | −0,05 | +0,1 % |

Leitura:
- **Horizontal (Δ cx ≤ 0,07 px em qualquer escala):** avanços, letter-spacing e a correção de meio letter-spacing estão certos —
  sem a correção, "Continue" estaria 0,70 px e "sua história." 0,30 px à esquerda.
- **Linha 1 ("Continue", Bricolage — TTF sem hinting):** deslocamento uniforme que só depende da escala: −0,07 a 3×, +0,10 a 6×,
  +0,04 a 10×. É o arredondamento da baseline ao pixel de dispositivo: 168,44 × 3 = 505,32 → 505 (−0,107 px) contra 1684,4 → 1684
  (−0,04 px) no supersample 10× da referência → −0,067 relativo; a 6×: 1010,64 → 1011 (+0,06) → +0,10 relativo. A baseline de layout
  é exata (camada 4: 168,440).
- **Linha 2 ("sua história.", Instrument Serif itálico):** a 3× os traços altos sobem até 0,50 px (pingos), 0,39 (acento) e
  0,19–0,28 (topo da altura-x de "s", "u", "t", "o"), enquanto o "h" (dominado pela haste e pela baseline) fica em −0,03 — o valor
  esperado só pelo arredondamento da baseline (216,66 × 3 = 649,98 → 650 contra 2166,6 → 2167 na referência). A 6× e a 10× o
  MESMO desenho fica a ≤ 0,07 px da referência em todos os componentes, com massa ≤ 0,5 %.
- **Causa:** hinting vertical (grid-fitting) do rasterizador de glifos a 150 ppem. Os TTFs da Instrument Serif trazem programa de
  hinting TrueType completo (`fpgm` 3596 B, `prep` 167 B, `cvt ` 52 B; `gasp` 0xF em todos os tamanhos); Bricolage e Figtree não
  (só um `prep` trivial de 7 B, sem `fpgm`/`cvt`). A referência foi renderizada com supersample 10× (500 ppem), onde o
  grid-fitting move os contornos no máximo ~0,05 px lógicos. Não há API do Flutter para desligar o hinting, e trocar o TTF é proibido
  (§3.2) — não há o que "corrigir" na implementação: forma, posição de layout, cor, espessura e ordem de pintura são iguais.
- **Prova direta:** a sonda a 10× reduzida a 3× por média de área (o mesmo caminho da referência) contra a referência no mesmo
  retângulo: `blur_mismatch_%` 0,0 · `raw_mismatch_%` **0,0263** · mean_abs 0,326 · max **59** (render direto a 3×: 1,1724 · 1,166 ·
  221). Evidências em `build/visual_diff/F04/sonda_escala/`.

## Cor (camada 2 nos pixels)

`style_headline_test.dart` varre os 1170 × 318 pixels da faixa (0, 126, 390, 106) do canvas @3x: todos opacos, todos misturas de
tinta `#1A1714` sobre papel `#F7F0E3` (maior divergência de cobertura entre canais 0,0038; 0 pixels fora da reta papel ↔ tinta),
o pixel mais escuro é exatamente `0xFF1A1714` e há 36.679 pixels de tinta cheia (sem `Opacity`/alpha).

## Não-regressão

| Comparação | blur_mismatch_% | raw_mismatch_% | max | Resultado |
|---|---:|---:|---:|---|
| topo (0, 0, 390, 126: inset + header) × golden APROVADO da F03 | 0,0 | 0,0 | 0 | PASSOU |

Diferença pixel a pixel contra o golden aprovado da F03: 43.235 pixels alterados, caixa x 19,00..235,33 × y 137,00..217,00;
43.205 dentro do retângulo de layout do `headline` (20, 134, 350, 90,16) e 30 fora — todos em x 19..20, y 210..215,67: o sobressalto
à esquerda do "s" itálico, que a referência também tem (30 pixels de tinta em x 18..20 nos dois). No modo `--layout`, as 8 regiões
ainda não construídas repetem exatamente os números da F03 (falham por definição, §7).

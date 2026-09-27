# FASE 9 — autorrevisão visual (camada 3 do prompt mestre §7)

Golden: `test/golden/goldens/inicio_canvas@3x.png` (1170 × 7170, `captureAt` 3×), sha256 `1792bdbf…f2bbd4e3`.
O golden aprovado da F08 foi preservado em `build/visual_diff/F09/golden_F08_aprovado.png` (sha256 `136ca54d…c107a01f`, o mesmo
registrado na F08). Referência: `design_handoff/referencia/png/inicio_canvas_390x2390@3x.png`.

## Gate da fase: seção `club` (`--rect 16,1566,358,284`)

| Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
|---|---:|---:|---:|---:|---|
| F09_clube (16, 1566, 358, 284) | 0,0 | 2,2346 | 2,002 | 229 | PASSOU (gate ≤ 0,5) |
| club no modo `--layout` | 0,0 | 2,2549 | 2,02 | 229 | PASSOU |
| header / headline / hero / alsoReading / today / forYou no modo `--layout` (não-regressão) | 0,0 em todas | 0,4113 / 1,3126 / 0,6195 / 0,8922 / 1,3001 / 2,1986 | — | 142 / 221 / 128 / 189 / 228 / 229 | PASSOU (iguais à F08) |
| acima da seção (0, 0, 390, 1574) × golden aprovado da F08 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
| abaixo da seção (0, 1842, 390, 548) × golden aprovado da F08 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |

Dos pixels que mudaram em relação ao golden da F08 (828.112), **todos** estão na faixa da seção: a caixa dos pixels alterados vai de
x 20,00 a 370,00 e de y 1574,33 a 1841,33 (as linhas físicas 4723 e 5523 são as de cobertura parcial das bordas da seção, em
1574,56 e 1841,16). Os entalhes transbordam 13 px acima e abaixo, mas o recorte da seção não deixa nada passar dessa faixa.

## Evidências inspecionadas

Em `build/visual_diff/F09/`:
- `F09_clube_lado_a_lado.png` (referência | Flutter | heatmap), `F09_clube_heatmap.png` e `F09_clube_onion.png`.
- Recortes ampliados em três faixas — referência | Flutter 3× (golden) | Flutter 10× → 3× (sonda):
  - entalhe de cima e começo da perfuração: `F09_clube_entalhe_cima_perfuracao_zoom6x.png`;
  - entalhe de baixo e canto inferior direito: `F09_clube_entalhe_baixo_canto_zoom5x.png`;
  - canto superior esquerdo (raio 28): `F09_clube_canto_sup_esq_zoom8x.png`;
  - pílula e avatares sobrepostos: `F09_clube_pilula_avatares_zoom4x.png`;
  - título "Leitoras de" / "Capitu": `F09_clube_titulo_zoom4x.png`;
  - trilho (hachura, preenchimento com a borda direita, marcador "M"): `F09_clube_trilho_marcador_zoom5x.png`;
  - legendas e CTA com balão e badge: `F09_clube_legendas_cta_zoom3x.png`;
  - canhoto (ENCONTRO / QUI 24 SET / 20h e a perfuração): `F09_clube_canhoto_zoom3x.png`.
- Autorrevisão do §8 (passo 4): `F09_clube_secao_golden_redline.png` = `secoes/F09_clube@3x.png` | golden (mesmo recorte
  0, 1566, 390, 284) | `redline/F09_clube_redline@3x.png`. A imagem da seção é idêntica ao recorte do canvas de referência (diferença
  máxima 0). As 34 caixas numeradas do redline caem sobre os mesmos elementos do golden; a conferência número a número da tabela
  está no teste "posições da tabela da F09 relativas à seção" (34 linhas, todas a ≤ 0,05 px; maior desvio 0,019).

No lado a lado as duas versões não se distinguem. Nas ampliações, estes pontos batem com o arquivo, nas três faixas:
- **Ticket.** Fundo `#FFFAF1`, borda 1,5 e raio 28 nos quatro cantos; nenhuma sombra. O canhoto rosa ocupa a altura toda e tem os
  cantos da direita arredondados pelo recorte do ticket.
- **Entalhes.** Dois semicírculos `#F7F0E3` com borda 1,5, centrados sobre a perfuração, "mordendo" a borda de cima e a de baixo:
  a borda do ticket é interrompida e a metade de fora é cortada pelo recorte da seção.
- **Perfuração.** Traços de 3 com vãos de ~1,5 na borda esquerda do canhoto, do topo ao pé; o padrão (59 traços, vão 1,4931) coincide
  traço a traço com o da referência (ver a deriva abaixo). Os entalhes pintam por cima dela.
- **Linha superior.** Pílula "Clube do livro" (`#FFC1C6`, borda 1,5) à esquerda; avatares A (lavanda), J (verde), L (rosa) e "+8"
  (claro, fonte menor) à direita, sobrepostos 8 px, cada um por cima do anterior.
- **Título.** "Leitoras de" (Bricolage 22) sobre "Capitu" (Instrument Serif itálico 36) alinhados à esquerda; subtítulo cinza com "·".
- **Progresso.** Trilho com hachura "/" `#EFE6D4`/`#FFFAF1`, preenchimento rosa até 54 % com a borda direita escura e a ponta
  esquerda arredondada pelo trilho; o marcador amarelo "M" em 62 %, saindo 6 px acima e abaixo do trilho, por cima dele.
- **Legendas e CTA.** "Grupo em 54%" cinza × "Você em 62%" em tinta, nas pontas; CTA escuro com o balão de traço claro, "Abrir
  discussão" e o badge laranja "3" com o texto escuro, tudo centralizado.
- **Canhoto.** "ENCONTRO" espaçado em `#4A2F33`; "QUI" / "24" / "SET" empilhados e centrados; pílula "20h" clara com borda.

O heatmap só mostra halos fracos nas bordas dos textos e das caixas, mais fortes no "Capitu" serifado e no "24".

## Onde estão as diferenças de pixel (todas de rasterização)

Diferença = máximo entre canais, em níveis de 0–255. "3×" é o golden (render direto). "10× → 3×" é a mesma seção renderizada pelo
Flutter a 10× e reduzida a 3× por média de área (BOX), como a referência (`supershot.js` + redução BOX). A sonda:
- usou `OffsetLayer.toImage(rect, pixelRatio:)` na raiz do golden, a 3×, 6× e 10×, no recorte (0, 1566, 390, 284)
  (`build/visual_diff/F09/sonda_escala/`);
- ficou fora de `test/` (em `build/`, excluída do analyzer) e já foi removida;
- a 3× difere do golden em 129 pixels, todos de borda suavizada (máx. 24, quase todos ±1): as pontas dos traços da perfuração, o
  arco dos cantos e o topo dos entalhes. O recorte da sonda começa em y = 1566 (4698 px físicos): a cobertura de AA do Skia, calculada
  em float32, muda no último dígito com a magnitude da coordenada. O golden em si é determinístico (a suíte o reproduz a cada
  execução, e os 40 pontos de pixel do teste de estilo são exatos).

| Região | px | 3× > 32 | 3× > 64 | 3× max | 10×→3× > 32 | 10×→3× > 64 | 10×→3× max |
|---|---:|---:|---:|---:|---:|---:|---:|
| seção inteira (recorte 0, 1566, 390, 284) | 996.840 | 22.757 | 12.006 | 229 | 20.454 | 10.943 | 168 |
| borda de cima do ticket (fora dos entalhes) | 8.190 | 630 | 630 | 96 | 1.260 | 1.260 | 115 |
| borda de baixo do ticket | 10.080 | 1.260 | 1.260 | 166 | 1.260 | 1.260 | 129 |
| canto sup. esq. (raio 28) | 8.742 | 198 | 68 | 117 | 290 | 141 | 118 |
| canto inf. dir. (raio 28) | 8.742 | 208 | 131 | 168 | 198 | 120 | 129 |
| entalhe de cima | 4.410 | 210 | 127 | 156 | 219 | 133 | 137 |
| entalhe de baixo | 4.410 | 205 | 109 | 166 | 219 | 136 | 129 |
| perfuração (fora dos entalhes) | 7.887 | 587 | 384 | 112 | 566 | 376 | 116 |
| pílula "Clube do livro" | 24.817 | 1.890 | 889 | 159 | 1.914 | 1.252 | 128 |
| avatares A J L +8 | 19.039 | 1.363 | 672 | 163 | 1.327 | 650 | 129 |
| título "Leitoras de" (Bricolage 22) | 22.981 | 1.746 | 1.198 | 194 | 1.428 | 960 | 168 |
| título "Capitu" (Instrument Serif 36 it.) | 27.295 | 1.934 | 1.308 | 229 | 663 | 172 | 100 |
| subtítulo | 26.112 | 1.025 | 173 | 94 | 1.012 | 47 | 85 |
| trilho sem o marcador | 13.838 | 1.879 | 752 | 148 | 1.856 | 738 | 128 |
| trilho à direita do marcador | 7.955 | 1.063 | 435 | 141 | 1.063 | 428 | 123 |
| marcador "M" | 5.329 | 428 | 191 | 138 | 403 | 206 | 126 |
| legendas | 29.216 | 1.462 | 529 | 155 | 1.089 | 232 | 102 |
| CTA (fundo) | 92.296 | 1.995 | 1.135 | 152 | 2.003 | 1.122 | 124 |
| CTA: balão 18 | 3.025 | 168 | 79 | 136 | 188 | 105 | 121 |
| CTA: rótulo | 15.392 | 810 | 272 | 114 | 755 | 210 | 104 |
| CTA: badge "3" | 3.721 | 176 | 91 | 129 | 210 | 96 | 124 |
| canhoto: ENCONTRO | 7.215 | 432 | 122 | 118 | 350 | 25 | 78 |
| canhoto: QUI | 3.256 | 135 | 15 | 93 | 137 | 43 | 97 |
| canhoto: "24" (Bricolage 42) | 17.666 | 707 | 347 | 172 | 411 | 17 | 76 |
| canhoto: SET | 3.256 | 105 | 9 | 85 | 197 | 94 | 94 |
| canhoto: pílula 20h | 11.340 | 713 | 276 | 158 | 501 | 178 | 82 |

Como na F08, a redução 10× → 3× sozinha **não** zera as diferenças fortes nas bordas retas horizontais (bordas do ticket, pílulas,
trilho, CTA): nas bordas de cima e de baixo do ticket sobram linhas inteiras (630 / 1.260 px = 1 ou 2 linhas de 210 px lógicos). O
motivo é a deriva vertical da própria referência.

### 1. Deriva vertical da referência (screenshot com `zoom: 10`) — +0,07 a +0,20 px

Medida deslocando a sonda 10× em passos de 0,01 px lógico (interpolação linear a 10×) antes de reduzi-la a 3× e procurando o
deslocamento que mais aproxima a referência (+dy = a referência está mais abaixo):

| Região | eixo | px > 64 sem deslocar | melhor deslocamento | px > 64 compensado | max compensado |
|---|---|---:|---:|---:|---:|
| borda de cima do ticket (x 60–250) | y | 1.140 (max 115) | +0,13 | 0 | 17 |
| pílula "Clube do livro" | y | 1.186 (max 128) | +0,13 | 0 | 49 |
| avatares | y | 654 (max 129) | +0,13 | 0 | 42 |
| "Leitoras de" | y | 965 (max 168) | +0,20 | 0 | 33 |
| "Capitu" | y | 173 (max 100) | +0,10 | 0 | 31 |
| subtítulo | y | 48 (max 85) | +0,10 | 0 | 39 |
| trilho (bordas de cima/baixo) | y | 682 (max 128) | +0,15 | 0 | 41 |
| legendas | y | 235 (max 102) | +0,10 | 0 | 42 |
| CTA (bordas de cima/baixo) | y | 1.381 (max 124) | +0,13 | 1 | 65 |
| borda de baixo do ticket (x 60–250) | y | 1.140 (max 129) | +0,17 | 0 | 17 |
| canhoto: ENCONTRO | y | 26 (max 78) | +0,10 | 0 | 21 |
| canhoto: "24" | y | 21 (max 76) | +0,08 | 0 | 28 |
| canhoto: pílula 20h | y | 178 (max 82) | +0,07 | 2 | 65 |
| borda esquerda do ticket | x | 0 (max 0) | 0,00 | 0 | 0 |
| borda direita do ticket | x | 0 (max 0) | 0,00 | 0 | 0 |
| perfuração (traços: bordas verticais e pontas) | x e y | 344 (max 116) | dx 0,00 · dy +0,14 | 0 | 22 |
| borda direita do preenchimento + hachura | x e y | 16 (max 104) | dx −0,02 · dy +0,13 | 0 | 40 |
| hachura à direita do marcador | x e y | 203 (max 119) | dx −0,02 · dy +0,13 | 0 | 17 |
| pílula 20h (pontas redondas) | x e y | 178 (max 82) | dx 0,00 · dy +0,07 | 2 | 65 |

No eixo x a deriva é **zero**: as bordas esquerda e direita do ticket coincidem pixel a pixel (0 pixels diferentes), e nas regiões
com arestas nos dois eixos (perfuração, hachura, pontas da pílula) a busca 2D devolve dx 0,00 ± 0,02. É a mesma deriva registrada na
F07 e na F08, agora nesta seção, ainda mais abaixo na página. O Flutter pinta na geometria do JSON (34/34 ids, maior desvio 0,019 px),
então quem está deslocada é a imagem de referência. Compensando o deslocamento, os pixels > 64 caem a zero em todas as regiões —
restam 1 pixel no CTA e 2 na pílula 20h, com máx. 65, nas pontas arredondadas.

### 2. Instrument Serif ("Capitu") — hinting a 3×

"Capitu" (Instrument Serif itálico 36 = 108 ppem a 3×) tem 1.308 pixels > 64 no golden 3×, mas só 172 na sonda 10× → 3× e 0 depois
de compensar a deriva. É a assinatura de hinting da F04/F06/F08 (os TTFs da Instrument Serif têm programa TrueType; a 3× o
rasterizador ajusta os glifos à grade). As baselines medidas são as do arquivo (Δ ≤ 0,01 no teste de texto): muda só onde o
rasterizador põe os glifos a 3×.

### 3. Bordas de cima e de baixo da seção — suavização de arestas coincidentes

Nas linhas físicas de cobertura parcial das bordas da seção (4723 = y 1574,33–1574,67 e 5523 = y 1841,00–1841,33), três arestas
coincidem: o recorte da seção (raio 28), a borda externa do ticket e o miolo dos entalhes. O Skia aplica o recorte suavizado a cada
desenho, então as coberturas se multiplicam e não se somam como numa única máscara:

| Linha física | coluna | referência | golden 3× | 10× → 3× | cobertura geométrica |
|---|---|---|---|---|---|
| 4723 (topo) | 700 (borda do ticket) | papel (0 % tinta) | 6,3 % tinta (`#E9E2D6`) | 31 % (`#B2ACA2`) | 32 % |
| 4723 (topo) | 831 (abertura do entalhe) | papel | 4,5 % tinta (`#EDE6D9`) | 3,2 % (`#F0E9DD`) | 0 % (o entalhe cobre a borda) |
| 5523 (pé) | 700 (borda do ticket) | tinta (100 %) | 25 % (`#C0BAAF`) | 42 % (`#9B968D`) | 48 % |
| 5523 (pé) | 831 (abertura do entalhe) | papel | 12 % tinta (`#DCD5C9`) | 4 % (`#EEE7DA`) | 0 % |

- Os números batem com um modelo simples: o rasterizador de teste quantiza a cobertura vertical em quartos (4 subamostras por pixel)
  e o recorte multiplica a cobertura de cada desenho. Na borda do ticket: 0,25 × 0,25 = 6,25 % no topo (medido 6,3 %) e 0,5 × 0,5 =
  25 % no pé (medido 25 %), em vez dos 32 % / 48 % geométricos. A sonda 10× → 3× chega perto da cobertura certa (31 % / 42 %).
- Na abertura dos entalhes, o papel do entalhe (com a mesma cobertura parcial do recorte) não esconde por inteiro a borda que está
  embaixo dele: sobra um fio de 1/3 px com 0,75 × 0,0625 = 4,7 % (topo, medido 4,5 %) e 0,5 × 0,25 = 12,5 % (pé, medido 12 %) de
  tinta. Visível só em zoom ≥ 5×.
- A referência não tem nada disso porque a deriva (+0,13 a +0,17) e o encaixe ao pixel do Chromium a 10× levam a borda para linhas
  inteiras: na linha 4723 ela ainda não começou (papel) e na 5523 ela já está inteira (tinta).

Forma, posição, cor, espessura, ordem de pintura (entalhes por cima do ticket) e recortes (os 3 `clipRRect` suavizados que o arquivo
pede) são iguais ao arquivo: é rasterização (composição da suavização de arestas coincidentes), a mesma família da costura da
`StadiumProgressBar` (F05) e da borda da capa Memórias (F08). A construção obrigatória foi mantida.

## Não-regressão

- Acima (0, 0, 390, 1574) e abaixo (0, 1842, 390, 548) da seção: idênticos ao golden aprovado da F08 (0 pixels diferentes).
- No modo `--layout`, as 6 seções anteriores repetem exatamente os números da F08.
- Suíte completa: F00–F08 continuam verdes; nenhum teste de fase aprovada foi alterado.

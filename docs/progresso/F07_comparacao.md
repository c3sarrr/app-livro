# FASE 7 — autorrevisão visual (camada 3 do prompt mestre §7)

Golden: `test/golden/goldens/inicio_canvas@3x.png` (1170 × 7170, `captureAt` 3×), sha256 `60646995…adb55111`.
O render é determinístico:
- o golden do rascunho e o final geram as mesmas evidências, byte a byte;
- no teste de tema, duas capturas com a cor padrão diferem em 0 pixels.

O golden aprovado da F06 foi preservado em `build/visual_diff/F07/golden_F06_aprovado.png` (sha256 `d1e41382…e9b3f503`, o mesmo registrado
na F06). Referência: `design_handoff/referencia/png/inicio_canvas_390x2390@3x.png`.

## Gate da fase: seção `today` (`--rect 16,758,358,418`)

| Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
|---|---:|---:|---:|---:|---|
| F07_seu_dia (16, 758, 358, 418) | 0,0 | 1,2989 | 1,138 | 228 | PASSOU (gate ≤ 0,5) |
| today no modo `--layout` | 0,0 | 1,3001 | 1,139 | 228 | PASSOU |
| header / headline / hero / alsoReading no modo `--layout` (não-regressão) | 0,0 / 0,0 / 0,0 / 0,0 | 0,4113 / 1,3126 / 0,6195 / 0,8922 | — | 142 / 221 / 128 / 189 | PASSOU (iguais à F06) |
| acima do cartão (0, 0, 390, 766) × golden aprovado da F06 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
| abaixo do cartão e da sombra (0, 1172, 390, 1218) × golden aprovado da F06 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |

Dos pixels que mudaram em relação ao golden da F06, 1.283.108 estão dentro do cartão com a sombra (20; 766,76 → 374; 1171,56). Sobra 1 pixel:
- fica na coluna 374,00–374,33, encostado na aresta direita da sombra, na altura y 798,67–799,00;
- ali o arco do canto da sombra encontra a reta (y 798,76);
- leva 3 % de tinta, da suavização do Skia nesse encontro.

## Evidências inspecionadas

Em `build/visual_diff/F07/`:
- `F07_seu_dia_lado_a_lado.png` (referência | Flutter | heatmap), `F07_seu_dia_heatmap.png` e `F07_seu_dia_onion.png`.
- Recortes ampliados em três colunas — referência | Flutter 3× (golden) | Flutter 10× → 3× (sonda):
  - barras: `F07_seu_dia_barras_zoom_4x.png` e `F07_seu_dia_barras_hoje_zoom_4x.png`, com os detalhes `F07_seu_dia_barra0_detalhe.png` e `F07_seu_dia_barra_hoje_detalhe.png`;
  - dial: `F07_seu_dia_dial_zoom_3x.png`;
  - cabeçalho: `F07_seu_dia_cabecalho_empilhado.png`;
  - frase e chips: `F07_seu_dia_meta_chips_empilhado.png`;
  - rodapé: `F07_seu_dia_rodape_empilhado.png`.

No lado a lado as duas versões não se distinguem. Nas ampliações, estes pontos batem com o arquivo, nas três colunas:
- **Hachura.** Listras "/" de 3 a cada 7, começando nos mesmos pontos (a mesma fase). Na barra "Hoje", a cor é `#FDE2B2`.
- **Preenchimentos.** Meia-lua no topo de cada um, afinando até zero nas laterais. A de hoje é mais achatada (raio 12, porque o preenchimento tem 24 de altura).
- **Recorte.** A base laranja de hoje segue a curva interna do trilho (raio 15,071), não o próprio raio 12.
- **Linha da meta.** 64 traços nas mesmas posições, por cima das barras e dos preenchimentos.
- **Dial.** As mesmas 10 marcações visíveis entre o pino e o início do arco, a ponta redonda no topo e o pino por cima do arco.
- **Círculos decorativos.**
  - O pequeno aparece acima e abaixo da pílula e some atrás dela.
  - O grande passa atrás de "fechar".
  - Os dois são recortados pela borda do cartão.
- **Título.** "Seu dia de" e "leitura" na mesma baseline.
- **Negritos.** "12 min" e "2 dias" em 700.
- **Chips.** Fundo translúcido sobre o amarelo e borda de 1,2.
- **Rótulos.** "S T Q Q S S" em `#5B544B` e "Hoje" em tinta.

O heatmap só mostra halos fracos nas bordas dos textos e das caixas.

## Onde estão as diferenças de pixel (todas de rasterização)

Diferença = máximo entre canais, em níveis de 0–255. "3×" é o golden (render direto). "10× → 3×" é a mesma seção renderizada pelo Flutter
a 10× e reduzida a 3× por média de área (BOX), como a referência (`supershot.js` + redução BOX). A sonda:
- usou `OffsetLayer.toImage(rect, pixelRatio:)` na raiz do golden;
- foi temporária e já foi removida;
- a 3× coincide com o golden (502 pixels diferem, max 23).

Imagens em `build/visual_diff/F07/sonda_escala/`.

| Métrica no retângulo do gate | Render direto 3× | Sonda 10× → 3× |
|---|---:|---:|
| `blur_mismatch_%` | 0,0 | 0,0 |
| `raw_mismatch_%` | 1,2989 | **0,4915** |
| mean_abs | 1,138 | 0,77 |
| max | 228 | **121** |

| Região | 3× px > 32 | 3× px > 64 | 3× max | 10× → 3× px > 32 | 10× → 3× px > 64 | 10× → 3× max |
|---|---:|---:|---:|---:|---:|---:|
| seção inteira | 21.404 | 6.854 | 228 | 13.722 | 4.354 | 121 |
| título "Seu dia de " (Bricolage 20) | 997 | 394 | 132 | 1 | 0 | 33 |
| título "leitura" (Instrument Serif 23 itálico) | 725 | 323 | 228 | 12 | 0 | 39 |
| pílula: "12 dias" | 459 | 229 | 153 | 1 | 0 | 34 |
| pílula: chama 17 | 35 | 3 | 90 | 27 | 0 | 57 |
| círculos decorativos (canto) | 900 | 244 | 153 | 599 | 0 | 47 |
| dial sem os textos | 1.143 | 207 | 106 | 412 | 0 | 59 |
| dial: "18" (Bricolage 34) | 513 | 361 | 176 | 258 | 34 | 85 |
| dial: "de 30 min" | 338 | 51 | 97 | 0 | 0 | 16 |
| frase da meta | 2.155 | 856 | 135 | 118 | 0 | 43 |
| chips | 1.635 | 108 | 115 | 841 | 0 | 59 |
| cabeçalho da semana | 1.161 | 412 | 147 | 5 | 0 | 34 |
| barras (trilhos, hachuras, preenchimentos) | 3.702 | 952 | 163 | 1.618 | 7 | 74 |
| linha da meta | 83 | 6 | 81 | 52 | 0 | 49 |
| rótulos S T Q Q S S | 616 | 388 | 137 | 351 | 1 | 66 |
| rótulo "Hoje" | 299 | 218 | 215 | 183 | 75 | 90 |
| rodapé: brilho | 67 | 31 | 117 | 85 | 49 | 121 |
| rodapé: frase | 989 | 148 | 101 | 1.500 | 452 | 100 |
| borda do cartão da semana | 2.617 | 890 | 137 | 3.371 | 1.673 | 114 |
| borda e sombra do cartão | 3.040 | 1.084 | 149 | 3.864 | 1.923 | 119 |

A tabela mostra três efeitos.

**1. Bordas de glifo (Figtree/Bricolage).** Somem a 10× → 3×:

| Texto | Pixels > 64 a 3× | Pixels > 64 a 10× → 3× |
|---|---:|---:|
| "Seu dia de " | 394 | 0 |
| "12 dias" | 229 | 0 |
| frase | 856 | 0 |
| cabeçalho da semana | 412 | 0 |
| "de 30 min" | 51 | 0 |

A posição é exata na camada 4:
- baselines com Δ 0,000;
- inícios e fins com Δ ≤ 0,031;
- os trechos inline "leitura", "12 min" e "2 dias" a ≤ 0,02.

É a mesma assinatura da F03–F06: o render direto a 3× arredonda a baseline ao pixel de dispositivo.

**2. "leitura" (Instrument Serif 23 itálico).** É o max da seção: 228, em (162,00; 798,00). A 10× → 3× os pixels > 64 caem de 323 para 0 e o max
para 39. É o hinting TrueType da Instrument Serif, a mesma assinatura da F04 e da F06.

**3. Deriva vertical da referência, e não do Flutter.** É o que resta a 10× → 3×: rótulos, rodapé, bordas de baixo e o "18". Duas medidas
mostram isso.

**Posição subpixel das bordas retas** (cobertura da linha de pixels @3x, média de colunas longe dos cantos):

| Borda | CSS | Referência (Δ) | Flutter 3× (Δ) | Flutter 10× → 3× (Δ) |
|---|---:|---:|---:|---:|
| cartão, topo (início) | 766,760 | 766,777 (+0,017) | 766,750 (−0,010) | 766,722 (−0,038) |
| pílula, topo (início) | 786,260 | 786,333 (+0,073) | 786,249 (−0,011) | 786,278 (+0,018) |
| chip, topo (início) | 901,360 | 901,418 (+0,058) | 901,333 (−0,027) | 901,375 (+0,015) |
| cartão da semana, topo (início) | 962,260 | 962,333 (+0,073) | 962,249 (−0,011) | 962,278 (+0,018) |
| trilho da barra 3, topo | 1001,360 | 1001,426 (+0,066) | 1001,341 (−0,019) | 1001,385 (+0,025) |
| cartão da semana, base (início) | 1114,560 | 1114,667 (+0,107) | 1114,583 (+0,023) | 1114,542 (−0,018) |
| cartão da semana, base (fim) | 1116,060 | 1116,222 (+0,162) | 1116,084 (+0,024) | 1116,056 (−0,004) |
| cartão, base (início) | 1166,060 | 1166,222 (+0,162) | 1166,082 (+0,022) | 1166,056 (−0,004) |
| cartão, borda esquerda | 20,000 | 20,000 (0) | 20,000 (0) | 20,000 (0) |
| cartão da semana, borda esquerda | 39,500 | 39,500 (0) | 39,500 (0) | 39,500 (0) |

- **Flutter:** pinta as bordas na posição do CSS, a ±0,04 nas duas versões.
- **Referência:** tem as horizontais de +0,02 a +0,16 mais abaixo, e o desvio cresce de cima para baixo. As verticais (x = 20 e 39,5) batem nas três versões.

**Deslocamento vertical que alinha a sonda 10× → 3× à referência** (−0,30 a +0,30, passo 0,01; "+" = referência mais abaixo):

| Região | Melhor Δy | px > 64 antes | px > 64 depois |
|---|---:|---:|---:|
| título, pílula, frase, "de 30 min", cabeçalho da semana | 0,00 | 0 | 0 |
| chips / borda de cima do cartão da semana | +0,02 / +0,04 | 0 | 0 |
| dial: "18" | −0,07 | 34 | 0 |
| rótulos S T Q Q S S / "Hoje" | +0,10 / +0,09 | 1 / 75 | 0 / 0 |
| borda de baixo do cartão da semana | +0,14 | 1.620 | 0 |
| rodapé: brilho / frase | +0,14 / +0,09 | 49 / 452 | 4 / 0 |
| borda de baixo do cartão | +0,19 | 810 | 0 |

Com o alinhamento, o resíduo cai a zero (sobram 4 pixels no brilho). O desenho é o mesmo; o que muda é a posição vertical na referência.

**Onde a deriva começa.** Medi com a mesma sonda 10× → 3× as seções de cima (header, headline, hero e "Também lendo"). Ali o melhor Δy
fica entre −0,04 e +0,06 em todos os trechos, inclusive nos títulos e autores dos cards, que são Figtree. Ou seja, a referência e o
Flutter estão alinhados até o topo desta seção (a borda de cima do cartão sai a +0,017).

Dentro de `today`, a deriva também é zero na parte de cima: cabeçalho, frase, chips e a própria linha "Esta semana". Ela aparece em dois
lugares:
- depois da linha "Esta semana", que é uma linha flex alinhada pela baseline de duas fontes (13/700 e 12/600);
- no bloco centralizado do dial, que sobe o "18" −0,07.

Nos dois casos a altura vem de métricas de fonte.

**Causa provável.** O `supershot.js` do handoff fotografa a tela com `document.body.style.zoom = 10` (DSF 1), e o layout é refeito nessa
escala. O `LEIA-ME` da medição diz que o Chromium arredonda larguras de borda e métricas de fonte, e que com `zoom: 100` "as métricas de
fonte deixam de ser arredondadas" — por isso o JSON de geometria foi medido com `zoom: 100`. Com `zoom: 10`, um arredondamento em
alturas derivadas de métricas de fonte vale 0,1 px lógico, o tamanho da deriva medida. Não reconstruí qual arredondamento exato o
Chromium faz em cada caixa: uma conta simples por linha de texto não bate com a ausência de deriva em "Também lendo". O fato medido é que
a imagem de referência, nessas caixas, está até 0,19 px abaixo do JSON.

O JSON está acima dos PNGs na hierarquia da verdade (§2), e o Flutter o segue: geometria com Δ ≤ 0,021 e baselines com Δ 0,000. A
F05/F06 já tinham visto a referência deslocar bordas horizontais em frações de pixel.

**Bordas de caixa e hachura a 3×.** O render direto a 3× tem halos de suavização nas bordas de 1,2/1,5, nas meias-luas e nas diagonais
da hachura (barras: 952 pixels > 64). A 10× → 3× quase somem (7). Os preenchimentos, as hachuras, as meias-luas, o recorte da base e o
tracejado foram conferidos também na camada 2: 37 pontos de pixel @3x, todos com o valor exato. As 7 composições translúcidas (anel dos
círculos, marcação .35, fundo dos chips, traço .45), calculadas por src-over, bateram sem erro, embora o teste aceite ±1.

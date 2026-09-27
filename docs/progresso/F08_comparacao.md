# FASE 8 — autorrevisão visual (camada 3 do prompt mestre §7)

Golden: `test/golden/goldens/inicio_canvas@3x.png` (1170 × 7170, `captureAt` 3×), sha256 `136ca54d…c107a01f`.
O render é determinístico: a sonda a 3× (`OffsetLayer.toImage` na raiz do golden) coincide com o golden byte a byte
(0 pixels diferentes), e o teste de rolagem volta, depois de ir e voltar, ao repouso idêntico (0 de 8.388.900 pixels) e ao golden
na faixa da seção (0 de 1.148.940 pixels).

O golden aprovado da F07 foi preservado em `build/visual_diff/F08/golden_F07_aprovado.png` (sha256 `60646995…adb55111`, o mesmo
registrado na F07). Referência: `design_handoff/referencia/png/inicio_canvas_390x2390@3x.png`.

## Gate da fase: seção `forYou` (`--rect 0,1199,390,344`)

| Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
|---|---:|---:|---:|---:|---|
| F08_para_voce (0, 1199, 390, 344) | 0,0 | 2,0278 | 1,63 | 229 | PASSOU (gate ≤ 0,5) |
| forYou no modo `--layout` | 0,0 | 2,1986 | 1,77 | 229 | PASSOU |
| header / headline / hero / alsoReading / today no modo `--layout` (não-regressão) | 0,0 em todas | 0,4113 / 1,3126 / 0,6195 / 0,8922 / 1,3001 | — | 142 / 221 / 128 / 189 / 228 | PASSOU (iguais à F07) |
| acima da seção (0, 0, 390, 1207) × golden aprovado da F07 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
| abaixo da seção (0, 1535, 390, 855) × golden aprovado da F07 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |

Dos pixels que mudaram em relação ao golden da F07 (628.476), **todos** estão na faixa da seção (y 1207,56 → 1534,56): a caixa dos
pixels alterados vai de x 20,00 a 390,00 e de y 1218,67 a 1531,67. Nenhum pixel fora dela.

## Evidências inspecionadas

Em `build/visual_diff/F08/`:
- `F08_para_voce_lado_a_lado.png` (referência | Flutter | heatmap), `F08_para_voce_heatmap.png` e `F08_para_voce_onion.png`.
- Recortes ampliados em três faixas — referência | Flutter 3× (golden) | Flutter 10× → 3× (sonda):
  - cabeçalho e chip: `F08_para_voce_cabecalho_chip_zoom3x.png`;
  - capa Memórias, autor sobre a elipse: `F08_para_voce_capa1_autor_elipse_zoom4x.png`;
  - capa Memórias, 1ª linha do título: `F08_capa1_titulo_linha1_zoom5x.png`;
  - capa Quincas, barras: `F08_para_voce_capa2_barras_zoom5x.png`;
  - capa O Cortiço, arcos: `F08_para_voce_capa3_arcos_zoom4x.png`;
  - corte do 3º item em x = 390: `F08_para_voce_corte_item3_zoom6x.png`;
  - cantos das capas 1 e 2 (raios 10 e 4): `F08_para_voce_cantos_capas_zoom8x.png`;
  - legendas: `F08_para_voce_legendas_zoom3x.png`.
- Autorrevisão do §8 (passo 4): `F08_para_voce_secao_golden_redline.png` = `secoes/F08_para_voce@3x.png` | golden (mesmo recorte
  0, 1199, 390, 344) | `redline/F08_para_voce_redline@3x.png`. A imagem da seção é idêntica ao recorte do canvas de referência
  (diferença máxima 0). As 41 caixas numeradas do redline caem sobre os mesmos elementos do golden; a conferência número a número da
  tabela está no teste "posições da tabela da F08 relativas à seção" (41 linhas, todas a ≤ 0,05 px).

No lado a lado as duas versões não se distinguem. Nas ampliações, estes pontos batem com o arquivo, nas três faixas:
- **Cabeçalho.** "Para você" à esquerda e "Ver tudo" + seta encostados à direita, na mesma altura; a seta com traço fino (2 no
  viewBox 24 → 1,5 a 18 px).
- **Chip.** Pílula com borda 1,5 e fundo `#FFFAF1`, brilho sólido e o texto 6 depois dele; mesma largura (termina no mesmo ponto).
- **Memórias.** A elipse larga (123 × 116, não um círculo) sai por baixo e pela direita e é recortada pela capa; o título quebra em
  "Memórias" / "Póstumas de" / "Brás Cubas"; o autor laranja só aparece sobre a elipse — "ACHADO DE ASSIS", com o "M" invisível
  sobre o laranja, exatamente como no arquivo.
- **Quincas.** Três barras `#F7F0E3` de pontas arredondadas, alinhadas à esquerda, com 100 / 70 / 40 % da largura; "Quincas" /
  "Borba" e o autor embaixo.
- **O Cortiço.** Arco amarelo com a "porta" verde (cor do fundo) de topo arredondado; as bases das duas formas na mesma linha.
- **Corte do 3º item.** A capa verde vai até a borda direita do canvas (x = 390) e é cortada ali: a borda direita (394,5 → 396)
  não aparece, e do canto superior direito (raio 10, de 386 a 396) só o começo da curva (386 → 390) fica visível.
- **Cantos.** Raio 4 à esquerda e 10 à direita em todas as capas; nenhuma sombra e nenhuma rotação.
- **Legendas.** "Memórias Póstu…" (só o 1º com reticências), "Quincas Borba" e "O Cortiço" em 700; autores em `#5B544B`.

O heatmap só mostra halos fracos nas bordas dos textos e das caixas, mais fortes nos títulos serifados das capas.

## Onde estão as diferenças de pixel (todas de rasterização)

Diferença = máximo entre canais, em níveis de 0–255. "3×" é o golden (render direto). "10× → 3×" é a mesma seção renderizada pelo
Flutter a 10× e reduzida a 3× por média de área (BOX), como a referência (`supershot.js` + redução BOX). A sonda:
- usou `OffsetLayer.toImage(rect, pixelRatio:)` na raiz do golden, a 3×, 6× e 10× (`build/visual_diff/F08/sonda_escala/`);
- ficou fora de `test/` (em `build/`, excluída do analyzer) e já foi removida;
- a 3× coincide com o golden (0 pixels diferentes).

| Região | px | 3× > 32 | 3× > 64 | 3× max | 10×→3× > 32 | 10×→3× > 64 | 10×→3× max |
|---|---:|---:|---:|---:|---:|---:|---:|
| seção inteira | 1.207.440 | 27.160 | 17.430 | 229 | 21.004 | 11.100 | 177 |
| título "Para você" (Bricolage 24) | 31.248 | 1.709 | 1.193 | 211 | 974 | 248 | 113 |
| "Ver tudo" | 9.918 | 730 | 474 | 200 | 353 | 56 | 107 |
| seta 18 | 3.600 | 128 | 88 | 129 | 130 | 86 | 110 |
| chip: borda e fundo | 74.664 | 5.292 | 3.520 | 170 | 4.593 | 3.203 | 122 |
| chip: texto | 30.447 | 2.274 | 1.401 | 170 | 1.546 | 427 | 106 |
| capa 1: título (Instrument Serif 19) | 44.856 | 3.253 | 1.810 | 229 | 1.599 | 655 | 162 |
| capa 1: autor sobre a elipse | 6.480 | 705 | 455 | 173 | 686 | 429 | 163 |
| capa 2: barras | 22.878 | 1.064 | 979 | 177 | 1.049 | 995 | 119 |
| capa 2: título (Instrument Serif 26) | 38.016 | 1.770 | 963 | 220 | 1.181 | 358 | 126 |
| capa 3: arcos | 50.301 | 427 | 247 | 118 | 492 | 310 | 128 |
| capa 3: título (Instrument Serif 26) | 19.800 | 1.099 | 692 | 194 | 641 | 224 | 107 |
| legendas: títulos (14/700) | 60.102 | 3.972 | 2.736 | 203 | 1.992 | 357 | 107 |
| legendas: autores (13/500) | 56.763 | 1.129 | 15 | 78 | 1.730 | 60 | 72 |

(Tabela completa, com as 20 regiões, em `F08_verificacao.txt`.)

Ao contrário da F07, aqui a redução 10× → 3× sozinha **não** zera as diferenças fortes nas bordas horizontais (chip, barras, bordas
das capas). O motivo é a deriva vertical da própria referência, abaixo.

### 1. Deriva vertical da referência (screenshot com `zoom: 10`) — +0,1 a +0,2 px

Medida deslocando a sonda 10× em passos de 0,1 px lógico antes de reduzi-la a 3× e procurando o deslocamento que mais aproxima
a referência (+dy = a referência está mais abaixo):

| Região | melhor Δy | px > 64 sem deslocar → com | max sem → com |
|---|---:|---:|---:|
| chip: borda de cima / de baixo | +0,1 / +0,2 | 1.080 → 0 / 1.080 → 0 | 115 → 38 / 110 → 38 |
| chip: texto | +0,1 | 427 → 0 | 106 → 45 |
| título "Para você" | +0,1 | 248 → 0 | 113 → 63 |
| capa 2: barras | +0,2 | 995 → 0 | 119 → 59 |
| capa 2: autor | +0,2 | 522 → 0 | 177 → 41 |
| capas 1/2: borda de cima | +0,1 | 1.054 → 0 | 122 → 51 |
| capas: borda de baixo | +0,2 | 790 → 0 | 115 → 46 |
| legendas: títulos / autores | +0,1 / +0,1 | 357 → 0 / 60 → 0 | 107 → 44 / 72 → 28 |
| capa 3: arcos | +0,1 | 310 → 0 | 128 → 45 |
| capa 1: autor sobre a elipse · capa 2/3: títulos · capa 3: autor | +0,2 · +0,1 · +0,2 | 429 · 358/224 · 453 → 0 | ≤ 47 |
| seta · brilho · "Ver tudo" | +0,1 | 86 · 39 · 56 → 0 | ≤ 43 |

No eixo x a deriva é **zero**: nas bordas verticais (chip, capas 1, 2 e 3) o melhor Δx é 0,0 e as bordas esquerdas das capas já
coincidem pixel a pixel (0 pixels > 64, max 0–1). Nas faixas horizontais o Δx não é determinado (a faixa não tem aresta vertical)
e por isso não conta.

É a mesma deriva registrada na F07 (até +0,19 px na metade de baixo do cartão do dia), agora nesta seção, que fica ainda mais abaixo
na página. O Flutter pinta na geometria do JSON (maior desvio de geometria 0,042 px, horizontal, no título), então quem está
deslocada é a imagem de referência. Compensando o deslocamento, os pixels > 64 caem a zero em todas as regiões — exceto no título da
capa Memórias (item 2).

### 2. Instrument Serif (títulos das capas) — hinting a 3×

No título da capa Memórias (Instrument Serif 19), com o deslocamento linha a linha, sobram 37 / 18 / 4 pixels > 64 (max 107 / 106 / 75)
nas três linhas. É a mesma assinatura de hinting da F04/F06. Os centróides dos glifos (px lógicos, cobertura de tinta como peso):

| Linha | referência | golden 3× | sonda 6× → 3× | sonda 10× → 3× |
|---|---|---|---|---|
| "Memórias" | (68,497; 1343,683) | (68,467; **1343,379**) | (68,396; 1343,653) | (68,451; 1343,571) |
| "Póstumas de" | (67,939; 1361,798) | (67,832; 1361,818) | (67,875; 1361,776) | (67,898; 1361,791) |
| "Brás Cubas" | (62,992; 1379,382) | (63,078; 1379,269) | (62,962; 1379,249) | (62,955; 1379,262) |
| "Quincas" | (202,172; 1429,744) | (202,204; 1429,756) | (202,233; 1429,676) | (202,156; 1429,658) |
| "Borba" | (192,922; 1452,038) | (193,043; 1451,983) | (192,987; 1451,872) | (192,953; 1451,935) |
| "O Cortiço" | (339,688; 1452,437) | (339,751; 1452,343) | (339,877; 1452,288) | (339,693; 1452,330) |

- Só o golden 3× puxa a 1ª linha da Memórias 0,30 px para cima; a 6× e a 10× ela volta para a posição da referência (Δ −0,03 e
  −0,11, este último do tamanho da deriva do item 1). O layout é o mesmo nas quatro colunas (as baselines medidas são as do arquivo
  com Δ ≤ 0,015): muda só onde o rasterizador põe os glifos a 3×.
- A "tinta" também muda com a escala, como na F04:
  - nos títulos claros sobre azul e verde, a 3× sai mais cheia (362,5 × 336,2 no "Quincas") e a 10× → 3× bate com a referência
    (336,6 × 336,2 no "Quincas", 280,4 × 281,1 no "Borba", 351,9 × 352,7 no "O Cortiço");
  - no título em tinta sobre laranja (Memórias), a 3× sai mais fina (223,8 × 235,0 na 1ª linha), e a 10× → 3× fecha só metade da
    diferença: fica 5,0 a 6,2 abaixo da referência nas três linhas (228,8 / 219,5 / 186,3 × 235,0 / 224,5 / 191,3).

### 3. Costura de 1/3 px na borda direita da capa Memórias

Na coluna física 403 (x 134,33–134,67), ao longo da elipse, o golden tem `#53261A`; referência e sonda 10× → 3× têm tinta `#1A1714`.
É exatamente o src-over de duas arestas de 50 % no mesmo meio pixel:
- a borda de 1,5 começa em 134,5 → cobre metade da coluna sobre o laranja;
- a elipse, recortada na padding box (que termina em 134,5), cobre a outra metade por cima;
- 0,75 tinta + 0,25 laranja = `#53261A`, o valor medido.

A 10× a aresta 134,5 cai numa fronteira de pixel e a costura some. Forma, posição, cor e recorte estão corretos: é rasterização
(suavização de duas arestas coincidentes), a mesma família da costura da `StadiumProgressBar` da F05/F06.

## Achado corrigido durante a fase: recorte extra na capa Memórias

A revisão adversarial (workflow de revisão, lente de estilo) encontrou, e o teste de canvas (`TestRecordingPaintingContext`)
provou, um segundo recorte na capa 1:
- a `Stack` da capa usava o `clipBehavior` padrão (`Clip.hardEdge`); como a elipse transborda a padding box, a `RenderStack`
  empilhava um `clipRect` **sem suavização** por cima do `clipRRect` suavizado do `NeoBox`;
- o Skia arredonda a aresta desse recorte de 64,5 para 65 px físicos, e a lombada sumia da coluna física 64 (x 21,33–21,67) em
  toda a altura da capa: `0xFF8C3621` (borda/laranja, sem lombada) em vez de `0xFF873420`.

Correção: `Stack(clipBehavior: Clip.none)` nas três capas — o único recorte é o do `NeoBox`, como no cartão do dia da F07. Efeito:
502 pixels, todos na coluna física 64 (linhas 3958–4459), diferença máxima 5. O teste de estilo agora exige exatamente um
`clipRRect` suavizado por capa e o valor `0xFF873420` na coluna 64.

## Rolagem (D-03)

- Repouso: `pixels 0` de `maxScrollExtent 26` (conteúdo 416 − viewport 390). A captura do app em repouso é o golden.
- Em 26: 354.838 pixels mudam, todos na faixa do carrossel (linhas @3x 3948–4595); o item 2 é o repouso deslocado 78 px @3x
  (228.288 pixels idênticos). Diferem só 80 pixels de borda suavizada (máx. 36/255), 22 no item 1 e 58 no item 3 — os dois que
  cruzam a borda do viewport num dos estados: sob o recorte do viewport a suavização das bordas curvas (cantos, arcos) varia, e o
  valor em 26 fica sempre entre as cores que o repouso tem na vizinhança 3 × 3 (nenhuma cor nova, nenhum preenchimento chapado).
- De volta a 0: bytes idênticos ao repouso da mesma execução (0 de 8.388.900 pixels) e ao golden na faixa da seção (0 de 1.148.940
  pixels; a comparação com o golden em disco fica restrita à seção para não depender das outras), em Android (clamping + stretch) e em
  iOS (bouncing).

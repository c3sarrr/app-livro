# F10 — autorrevisão visual (referência × Flutter), seção "Recém-chegados"

Evidências em `build/visual_diff/F10/` (não versionado): `F10_recem_chegados_lado_a_lado.png`, `_heatmap.png`, `_onion.png`,
`F10_recem_chegados_secao_golden_redline.png` (referência `secoes/F10@3x` | golden | redline numerado), `zoom_capas.png`,
`zoom_arco_senhora.png`, `zoom_anel_alienista.png`, `zoom_selo_linha1.png`, `todas/`, `nao_regressao/` e `golden_F09_aprovado.png`.

## Gate (camada 3)

| Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
|---|---:|---:|---:|---:|---|
| F10_recem_chegados `--rect 16,1873,358,351` | 0,0 | 0,891 | 0,973 | 189 | PASSOU |
| recent (`--layout`) | 0,0 | 0,8938 | 0,976 | 189 | PASSOU |
| header / headline / hero / alsoReading / today / forYou / club (`--layout`) | 0,0 | 0,4113 / 1,3126 / 0,6195 / 0,8922 / 1,3001 / 2,1986 / 2,2549 | — | 142 / 221 / 128 / 189 / 228 / 229 / 229 | PASSOU (= F09) |
| bottomFade / nav (`--layout`) | 22,41 / 42,83 | — | — | — | FALHAM por definição (F11, ainda não construídas) |

## O que foi inspecionado

- **Lado a lado e heatmap:** as três linhas coincidem com a referência: título e link, lista sem borda, divisores, capas, textos,
  selos e pontos. A linha 2 reproduz D-12: "Machado de Assis ·" / "PDF" e o selo "Quero" / "ler" (68,17 × 38,8) centralizado.
- **Redline × golden:** os 37 retângulos numerados caem sobre os mesmos elementos do golden (cabeçalho 2–5, lista 6, linhas 7/17/28,
  capas 8/18/29 com seus filhos, blocos de texto, selos 14/25/35, botões 15/26/36 e ícones 16/27/37).
- **Recortes ampliados (referência | Flutter 3×):** arco da Senhora (aberto embaixo, pernas e topo com a mesma espessura e curvatura),
  anel + ponto do Alienista, selo de duas linhas e as três capas. Mesma forma, mesma cor, mesma ordem de pintura.

## Resíduo (todo de rasterização)

Pixels com diferença > 64 na faixa da seção: 6.905 de 1.053.150 (0,66 %); > 128: 1.305; máximo 189. Onde estão:

| Região | pixels > 64 |
|---|---:|
| título + link do cabeçalho | 2.608 |
| capas (linhas 0 / 1 / 2) | 466 / 649 / 511 |
| textos (linhas 0 / 1 / 2) | 735 / 730 / 493 |
| selos (linhas 0 / 1 / 2) | 231 / 316 / 88 |
| botões "mais opções" (cada) | 26 |

- **Glifos com hinting** (Bricolage 24 e Figtree a 3×): o melhor deslocamento vertical entre golden e referência nos textos é de 1
  pixel físico (≈ 0,33 px), igual ao de "Para você" (`forYou.title` e `forYou.seeAll`, aprovadas na F08, com golden idêntico ao da
  F09). As baselines do Flutter batem com o JSON a Δ 0,000.
- **Deriva da própria referência** (screenshot com `zoom: 10`): as pernas do arco da Senhora e as bordas das capas aparecem na
  referência com uma linha parcial a mais na base (+0,1 a +0,2 px), efeito já documentado nas F07–F09; o Flutter termina nítido na
  posição do JSON.
- **Suavização de arestas** nas curvas (anel, ponto, pílulas, cantos das capas).

Nenhuma diferença de forma, posição, cor, espessura, ordem de pintura ou recorte.

## Não-regressão

- Acima da seção `(0, 0, 390, 1873)` e abaixo `(0, 2224, 390, 166)` contra o golden APROVADO da F09: blur 0,0 / raw 0,0 / max 0.
- Os 897.810 pixels alterados em relação ao golden da F09 estão todos em x 20–370, y 1892,7–2215,3 (dentro da seção).
- `forYou.title` idêntico byte a byte ao da F09.
- Testes F00–F09 de geometria, texto, estilo e semântica verdes sem alteração.

## Larguras 360 e 430 (sonda temporária; a validação formal é da F13)

Os 37 ids da seção batem com `reference_layout_w360/w430` (maior desvio 0,0364, `recent.title`): o algoritmo de flex é fluido como o
CSS. A sonda ficou fora de `test/` e foi removida.

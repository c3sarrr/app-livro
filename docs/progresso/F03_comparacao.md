# FASE 3 — autorrevisão visual (camada 3 do prompt mestre §7)

Golden: `test/golden/goldens/inicio_canvas@3x.png` (1170 × 7170, `captureAt` 3×), sha256 `e2528321…36578e88` — igual em
regenerações seguidas (render determinístico). Golden aprovado da F02 preservado em `build/visual_diff/F03/golden_aprovado_F02.png`
(sha256 `64a0f671…eda6de`, o mesmo registrado na F02). Referência: `design_handoff/referencia/png/inicio_canvas_390x2390@3x.png`.

## Gate da fase — seção `header` (`--rect 0,54,390,64`)

| Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
|---|---:|---:|---:|---:|---|
| F03_header (0, 54, 390, 64) | 0,0 | 0,3579 | 0,461 | 142 | PASSOU (gate ≤ 0,5) |
| header no modo `--layout` (margem 6) | 0,0 | 0,4113 | 0,53 | 142 | PASSOU |

Evidências inspecionadas: `build/visual_diff/F03/F03_header_lado_a_lado.png`, `F03_header_heatmap.png`, `F03_header_onion.png` e o
recorte ampliado `F03_header_zoom_4x.png` (referência × Flutter a 12× do lógico). O heatmap não tem nenhuma região acima do limiar;
só um halo fraco nas bordas dos glifos e dos círculos.

## Onde estão as diferenças de pixel (todas de rasterização)

Medição por região (massa de tinta = soma da distância à cor de fundo local; centroide ponderado; px lógicos):

| Região | Δ massa | Δ centroide x | Δ centroide y | caixa dos pixels > 50 % |
|---|---:|---:|---:|---|
| ícone do sino | −0,99 % | 0,010 | 0,013 | idêntica |
| ponto `#FF552E` | −0,22 % | −0,007 | 0,006 | idêntica |
| anel do avatar | −0,06 % | 0,010 | 0,012 | idêntica |
| anel do sino | +0,37 % | −0,016 | 0,035 | idêntica |
| "M" (Bricolage 18/800) | −3,65 % | 0,079 | 0,106 | idêntica |
| "Boa noite," (Figtree 13/500) | −2,69 % | 0,019 | −0,062 | ±1 px de dispositivo |
| "Marina" (Figtree 16/700) | −2,82 % | 0,029 | 0,128 | ±1 px de dispositivo |

- Formas (ícone, ponto, anéis): massa ≤ 1 % e centroide ≤ 0,035 px → geometria, espessura, cor e ordem de pintura idênticas.
- Textos: o antisserrilhado dos glifos do Flutter sai ~3 % mais claro que o do navegador, igual nos pesos 500, 700 e 800 (não é
  diferença de peso: 500 → 700 mudaria a massa em dezenas de %). O deslocamento vertical ≤ 0,13 px é o arredondamento da baseline ao
  pixel de dispositivo a DPR 3 (99,9 × 3 = 299,7 → 300 = +0,1 px em "Marina"; 80,45 × 3 = 241,35 → 241 = −0,12 px em "Boa noite,"),
  com a baseline de layout exata (camada 4: 99,900 / 80,450 / 91,940).
- Ordem de pintura provada também por teste de pixels (`style_header_test.dart`): no ponto por onde o arco do sino passa, sob o anel
  do ponto, o pixel é `#FFFAF1`; no ponto espelhado do arco, fora do anel, é `#1A1714`.

## Não-regressão

| Comparação | blur_mismatch_% | raw_mismatch_% | max | Resultado |
|---|---:|---:|---:|---|
| inset superior (0, 0, 390, 56) × golden APROVADO da F02 | 0,0 | 0,0 | 0 | PASSOU |

Diferença pixel a pixel contra o golden aprovado da F02: 34.832 pixels alterados, todos dentro do retângulo da seção `header`
(x 20..370, y 62..110) — 0 pixels alterados fora dele. No modo `--layout`, as 9 regiões ainda não construídas repetem exatamente os
números da linha de base da F02 (falham por definição, §7).

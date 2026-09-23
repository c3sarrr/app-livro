# FASE 1 — autorrevisão visual dos primitivos contra a referência @3x

A F01 não tem seção da tela (o gate visual por seção começa na F02/F03); estas comparações são a
autorrevisão pedida para os goldens isolados (1.4 c, 1.6) — mesma ferramenta e mesmo gate da §7
(`tools/compare_images.py`, `blur_mismatch_% ≤ 0,5`), aplicados a recortes pequenos.

Ambiente: `python3` = Python 3.11.9 · Pillow 12.3.0 · numpy 2.4.4.
PNGs de evidência (heatmap, lado a lado, onion, `*_zoom2x.png`) em `build/visual_diff/F01/` — artefatos
locais, **não versionados**; esta tabela é a cópia versionada dos `*_relatorio.json`.

## Como as cenas são alinhadas

Os testes `test/design_system/painters_test.dart` geram cenas cuja caixa começa e termina em pixels
físicos **inteiros** da referência @3x, com os elementos nas coordenadas **absolutas** do canvas
(`kRefLayout`) e o fundo do cartão onde o elemento aparece no arquivo. O golden (capturado a 3×) fica,
então, comparável 1:1 com o recorte da referência na mesma caixa (o teste imprime a caixa: `[cena] …`).
As cenas usam somente vocabulário da F01 (pintores, `NeoBox`, `AppText`) e a geometria medida; as
seções de verdade são construídas nas fases F05–F09.

| Golden (`test/golden/goldens/`) | O que contém | Caixa @3x (x0, y0, x1, y1) | Fundo |
|---|---|---|---|
| `ds_apptext_reticencias@3x.png` | `AppText('Orgulho e Preconceito', title15, maxLines 1, "…")` em 138 px | 650, 2039, 1064, 2093 (alsoReading.card2.title) | surface |
| `ds_anel_34@3x.png` | `RingProgressPainter(0,34)` + rótulo "34%" (`micro11Bold`) | 382, 1864, 521, 2003 (alsoReading.card1.ring) | surface |
| `ds_anel_81@3x.png` | `RingProgressPainter(0,81)` + rótulo "81%" | 925, 1864, 1064, 2003 (alsoReading.card2.ring) | surface |
| `ds_dial@3x.png` | `GoalDialPainter(18/30)` + "18" (`dialValue`) e "de 30 min" (`dialCaption`) nas posições medidas | 118, 2502, 455, 2839 (today.dial) | sun |
| `ds_semana@3x.png` | 7 trilhos `NeoBox` (borda 1,2 / 1,5 na barra "Hoje", raio 999, clip) + `HatchPainter` + `TopBorderCrescentPainter` (alturas D-10) + `ChromiumDashPainter` da meta por cima | 153, 3004, 1017, 3245 (today.week.goalLine × today.week.chart) | surface |

## Resultado

| Região | raw_mismatch_% | blur_mismatch_% | mean_abs_diff | max_diff | Resultado |
|---|---:|---:|---:|---:|---|
| reticencias | 6.7141 | 0.0 | 6.744 | 195 | PASSOU |
| ds_anel_34 | 1.8426 | 0.0 | 1.886 | 155 | PASSOU |
| ds_anel_81 | 1.7753 | 0.0 | 2.064 | 160 | PASSOU |
| ds_dial | 1.2917 | 0.0 | 1.402 | 176 | PASSOU |
| ds_semana | 1.3015 | 0.0 | 1.583 | 163 | PASSOU |

Inspeção das imagens (lado a lado ampliado e heatmap): nenhuma diferença de forma, posição, cor,
espessura ou ordem de pintura. O `raw_mismatch_%` vem só da suavização de bordas (a referência foi
renderizada com supersample 10×); no heatmap aparecem apenas contornos tênues, sem viés de direção
(um deslocamento acenderia só um lado das bordas). As listras da hachura estão na mesma fase e na mesma
direção ("/"), as meias-luas afinam até 0 nas laterais, o tracejado da meta coincide traço a traço.

## Comando

```bash
# 1) goldens das cenas (a caixa @3x de cada uma sai no log: "[cena] …")
flutter test --update-goldens test/design_system/painters_test.dart test/design_system/app_text_test.dart
# 2) recorte da referência na mesma caixa + comparação (repetir para cada linha da tabela)
python3 - <<'PY'
from PIL import Image
ref = Image.open('design_handoff/referencia/png/inicio_canvas_390x2390@3x.png').convert('RGB')
ref.crop((382, 1864, 521, 2003)).save('build/visual_diff/F01/ds_anel_34_ref.png')
PY
python3 tools/compare_images.py --flutter test/golden/goldens/ds_anel_34@3x.png \
  --ref build/visual_diff/F01/ds_anel_34_ref.png --scale 3 --out build/visual_diff/F01 --name ds_anel_34
```

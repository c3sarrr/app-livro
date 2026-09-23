# FASE 2 — autorrevisão visual (camada 3 do prompt mestre §7)

Golden: `test/golden/goldens/inicio_canvas@3x.png` (1170 × 7170, `captureAt` 3×). Nesta fase o app só pinta o fundo:
uma única cor em todo o PNG, (247, 240, 227) = `#F7F0E3`. Regenerado 2× com os mesmos bytes (sha256 `64a0f671…eda6de`).
Referência: `design_handoff/referencia/png/inicio_canvas_390x2390@3x.png`.

## Gate da fase — inset superior (2.8, teste 6)

Único retângulo comparado nesta fase (no arquivo é só fundo `#F7F0E3`):

| Região | rect lógico | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
|---|---|---:|---:|---:|---:|---|
| inset superior | 0, 0, 390, 56 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |

Comando: `python3 tools/compare_images.py --flutter test/golden/goldens/inicio_canvas@3x.png --ref design_handoff/referencia/png/inicio_canvas_390x2390@3x.png --scale 3 --rect 0,0,390,56 --out build/visual_diff/F02 --name F02_inset_superior`

Evidências (inspecionadas): `build/visual_diff/F02/F02_inset_superior_lado_a_lado.png` (referência e Flutter idênticos, só papel),
`F02_inset_superior_heatmap.png` (nenhum ponto vermelho), `F02_inset_superior_onion.png`, `F02_inset_superior_relatorio.json`.

## Linha de base `--layout` (não é gate na F02)

Pela §7, no modo `--layout` as seções ainda não construídas falham por definição; na F02 nenhuma seção foi construída
(as fases das seções começam na F03), então nenhuma precisa passar. Registro como linha de base:

| Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
|---|---:|---:|---:|---:|---|
| header | 17,5358 | 10,997 | 13,436 | 221 | FALHOU (não construída) |
| headline | 23,453 | 12,666 | 25,732 | 221 | FALHOU (não construída) |
| hero | 93,5773 | 89,6286 | 88,1 | 222 | FALHOU (não construída) |
| alsoReading | 32,0205 | 21,2697 | 31,067 | 222 | FALHOU (não construída) |
| today | 74,001 | 64,9926 | 53,254 | 222 | FALHOU (não construída) |
| forYou | 58,0276 | 48,8854 | 68,214 | 247 | FALHOU (não construída) |
| club | 51,994 | 42,7901 | 47,662 | 221 | FALHOU (não construída) |
| recent | 15,9536 | 10,8523 | 22,822 | 222 | FALHOU (não construída) |
| bottomFade | 22,4085 | 15,6516 | 22,349 | 222 | FALHOU (não construída) |
| nav | 42,8345 | 29,6272 | 43,447 | 222 | FALHOU (não construída) |

Evidências em `build/visual_diff/F02/todas/` (artefatos locais, não versionados).

## Conferência geométrica da tabela da fase (número por número)

Os 10 blocos do "Ritmo vertical de referência" medidos no canvas (saída do `geometry_shell_test.dart`):

| Bloco | y | altura | termina em | gap até o próximo | Δ (x, y, w, h) |
|---|---|---|---|---|---|
| inset superior | 0 | 62 | 62 | — | — |
| `header` | 62 | 48 | 110 | 24 | 0 |
| `headline` | 134 | 90,16 | 224,16 | 24 | 0 |
| `hero` | 248,16 | 275 | 523,16 | 32 | 0 |
| `alsoReading` | 555,16 | 175,6 | 730,76 | 36 | 0 |
| `today` | 766,76 | 400,8 | 1167,56 | 40 | 0 |
| `forYou` | 1207,56 | 327 | 1534,56 | 40 | 0 |
| `club` | 1574,56 | 266,6 | 1841,16 | 40 | 0 |
| `recent` | 1881,16 | 334 | 2215,16 | — | ≈ 2·10⁻¹³ (ponto flutuante) |
| padding inferior | 2215,16 | 140 | 2355,16 | — | 0 |
| `bottomFade` (fixo) | 2240 | 150 | 2390 | — | 0 |
| `nav` (fixa) | 2290 | 70 | 2360 | — | 0 |

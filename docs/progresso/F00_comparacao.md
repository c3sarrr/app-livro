# FASE 0 — Subfase 0.7: prova da ferramenta de comparação

Ambiente: `python3` = Python 3.11.9 · Pillow 12.3.0 · numpy 2.4.4 (ver `F00_versoes.txt`).
Ferramenta: `tools/compare_images.py` (cópia byte a byte de `design_handoff/ferramentas/compare_images.py`). Gate: `blur_mismatch_% ≤ 0,5` por região.
Os PNGs de evidência (heatmap, lado a lado, onion) ficam em `build/visual_diff/F00/` — artefatos locais, **não versionados** (`build/` está no `.gitignore`); estas tabelas são a cópia versionada dos `*_relatorio.json`.

## Comandos

```bash
# 0.7.2 — identidade
python3 tools/compare_images.py --flutter design_handoff/referencia/png/inicio_canvas_390x2390@3x.png \n  --ref design_handoff/referencia/png/inicio_canvas_390x2390@3x.png --scale 3 \n  --layout design_handoff/referencia/layout/layout_inicio.json --out build/visual_diff/F00 --name identidade

# 0.7.3 — controle negativo: cópia deslocada 3 px físicos (1 px lógico) para baixo;
# a faixa exposta no topo recebe o fundo do papel #F7F0E3
python3 - <<'PY'
from PIL import Image
ref = Image.open('design_handoff/referencia/png/inicio_canvas_390x2390@3x.png')
paper = (247, 240, 227, 255) if ref.mode == 'RGBA' else (247, 240, 227)
out = Image.new(ref.mode, ref.size, paper)
out.paste(ref.crop((0, 0, ref.size[0], ref.size[1] - 3)), (0, 3))
out.save('build/visual_diff/F00/ref_deslocada_1px_logico@3x.png')
PY
python3 tools/compare_images.py --flutter build/visual_diff/F00/ref_deslocada_1px_logico@3x.png \n  --ref design_handoff/referencia/png/inicio_canvas_390x2390@3x.png --scale 3 \n  --layout design_handoff/referencia/layout/layout_inicio.json --out build/visual_diff/F00/controle_negativo --name deslocado_1px

# calibração extra (0,33 px lógico): mesmo procedimento com deslocamento de 1 px físico,
# --out build/visual_diff/F00/calibracao_0.33px --name deslocado_0.33px
```

## Identidade (referência × ela mesma) — esperado: todas PASSAM

| Região | rect lógico (x, y, w, h) | raw_mismatch_% | blur_mismatch_% | mean_abs_diff | max_diff | Resultado |
|---|---|---:|---:|---:|---:|---|
| header | 14, 56, 362, 60 | 0.0 | 0.0 | 0.0 | 0 | PASSOU |
| headline | 14, 128, 362, 102.16 | 0.0 | 0.0 | 0.0 | 0 | PASSOU |
| hero | 14, 242.16, 362, 287 | 0.0 | 0.0 | 0.0 | 0 | PASSOU |
| alsoReading | 14, 549.16, 362, 187.6 | 0.0 | 0.0 | 0.0 | 0 | PASSOU |
| today | 14, 760.76, 362, 412.8 | 0.0 | 0.0 | 0.0 | 0 | PASSOU |
| forYou | 14, 1201.56, 362, 339 | 0.0 | 0.0 | 0.0 | 0 | PASSOU |
| club | 14, 1568.56, 362, 278.6 | 0.0 | 0.0 | 0.0 | 0 | PASSOU |
| recent | 14, 1875.16, 362, 346 | 0.0 | 0.0 | 0.0 | 0 | PASSOU |
| bottomFade | 0, 2234, 390, 156 | 0.0 | 0.0 | 0.0 | 0 | PASSOU |
| nav | 10, 2284, 370, 82 | 0.0 | 0.0 | 0.0 | 0 | PASSOU |

**10/10 passaram · 0/10 falharam.**

## Controle negativo — deslocada 3 px físicos = 1 px lógico para baixo — esperado: todas FALHAM

| Região | rect lógico (x, y, w, h) | raw_mismatch_% | blur_mismatch_% | mean_abs_diff | max_diff | Resultado |
|---|---|---:|---:|---:|---:|---|
| header | 14, 56, 362, 60 | 4.2894 | 3.453 | 6.547 | 229 | FALHOU |
| headline | 14, 128, 362, 102.16 | 4.3323 | 6.1059 | 6.787 | 221 | FALHOU |
| hero | 14, 242.16, 362, 287 | 6.7303 | 10.4239 | 9.933 | 229 | FALHOU |
| alsoReading | 14, 549.16, 362, 187.6 | 6.523 | 7.2878 | 10.642 | 229 | FALHOU |
| today | 14, 760.76, 362, 412.8 | 7.5843 | 8.9574 | 11.448 | 229 | FALHOU |
| forYou | 14, 1201.56, 362, 339 | 6.9581 | 7.5328 | 9.392 | 255 | FALHOU |
| club | 14, 1568.56, 362, 278.6 | 8.035 | 8.9308 | 13.002 | 229 | FALHOU |
| recent | 14, 1875.16, 362, 346 | 3.3942 | 3.0685 | 5.575 | 229 | FALHOU |
| bottomFade | 0, 2234, 390, 156 | 5.2126 | 8.3806 | 8.765 | 229 | FALHOU |
| nav | 10, 2284, 370, 82 | 10.0542 | 15.5636 | 16.953 | 229 | FALHOU |

**0/10 passaram · 10/10 falharam.**

## Calibração extra — deslocada 1 px físico = 0,33 px lógico (não exigida pela F00) — esperado: todas PASSAM (gate não é sensível demais)

| Região | rect lógico (x, y, w, h) | raw_mismatch_% | blur_mismatch_% | mean_abs_diff | max_diff | Resultado |
|---|---|---:|---:|---:|---:|---|
| header | 14, 56, 362, 60 | 1.9884 | 0.0 | 2.212 | 222 | PASSOU |
| headline | 14, 128, 362, 102.16 | 2.0706 | 0.0 | 2.272 | 221 | PASSOU |
| hero | 14, 242.16, 362, 287 | 2.9681 | 0.0 | 3.366 | 229 | PASSOU |
| alsoReading | 14, 549.16, 362, 187.6 | 2.9942 | 0.0 | 3.664 | 229 | PASSOU |
| today | 14, 760.76, 362, 412.8 | 3.4465 | 0.0 | 3.886 | 229 | PASSOU |
| forYou | 14, 1201.56, 362, 339 | 3.3148 | 0.0 | 3.265 | 255 | PASSOU |
| club | 14, 1568.56, 362, 278.6 | 3.7511 | 0.0 | 4.383 | 229 | PASSOU |
| recent | 14, 1875.16, 362, 346 | 1.5459 | 0.0 | 1.901 | 229 | PASSOU |
| bottomFade | 0, 2234, 390, 156 | 2.3375 | 0.0 | 2.956 | 229 | PASSOU |
| nav | 10, 2284, 370, 82 | 4.5019 | 0.0 | 5.718 | 229 | PASSOU |

**10/10 passaram · 0/10 falharam.**

#!/usr/bin/env python3
"""G01.2 — prova que renderizar a prancha ISOLADA (bundle aninhado extraído, rede bloqueada) dá o
mesmo resultado que o arquivo original, e que as prévias do pacote vêm desse mesmo render.

  A1 (gate) isolada@1x × raiz@1x (iframe dentro do bundle raiz)          → idênticas (0 pixel diferente)
  A2 (gate) raiz@2x × prévia handoff_v2/referencia/previa/<slug>@2x.png → idênticas numa linha 0–2
            (as prévias foram fotografadas com o iframe em y fracionário: 1 linha a mais)
  A3 (info) isolada@2x × raiz@2x: dentro do bundle raiz o Chromium headless rasteriza o iframe
            (processo separado) a 1x e amplia — a prévia é mais borrada que o render isolado.
            Medimos o borrão (energia do laplaciano raiz/isolada) e a métrica desfocada
            (σ 1,5 px lógicos, limiar 24) de tools/compare_images.py.
Conclusão esperada: a prancha isolada é a referência correta para medir e fotografar (G01.4/G01.5).
Entradas: tools/medicao/tmp/render/ (conferir_render.js e render_raiz.js, hinting 'nenhum').
Uso: python3 tools/medicao/comparar_previa.py → tabela + tmp/render/comparacao.json; código 1 se falhar.
T02: o conjunto vem de CONJUNTO; prancha sem prévia (o arquivo da Início não traz) fica sem o A2, e o gate é o A1.
"""
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from compare_images import load_rgb, metrics  # noqa: E402

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import caminho, indice  # noqa: E402

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
CFG = indice()
REN = caminho('tmp', 'render')


def arr(im):
    return np.asarray(im).astype(np.int16)


def lap_energy(im):
    g = np.asarray(im.convert('L')).astype(np.float64)
    lap = 4 * g[1:-1, 1:-1] - g[:-2, 1:-1] - g[2:, 1:-1] - g[1:-1, :-2] - g[1:-1, 2:]
    return float((lap ** 2).mean())


res, falhas = {}, 0
print(f'{"prancha":24s} | A1 px≠ (1x) | A2 linha px≠ | A3 blur%  nitidez raiz/isolada')
for p in CFG['pranchas']:
    s = p['slug']
    iso1 = load_rgb(os.path.join(REN, f'{s}_nenhum@1x.png'))
    raiz1 = load_rgb(os.path.join(REN, f'{s}_raiz_nenhum@1x.png'))
    a1 = int((np.abs(arr(iso1) - arr(raiz1)).max(axis=2) > 0).sum()) if iso1.size == raiz1.size else -1
    raiz2 = load_rgb(os.path.join(REN, f'{s}_raiz_nenhum@2x.png'))
    a2 = None
    if p.get('previa'):
        prev = load_rgb(os.path.join(RAIZ, p['previa']))
        for off in range(0, prev.size[1] - raiz2.size[1] + 1):
            d = int((np.abs(arr(prev.crop((0, off, raiz2.size[0], off + raiz2.size[1]))) - arr(raiz2)).max(axis=2) > 0).sum())
            if a2 is None or d < a2[1]:
                a2 = (off, d)
    iso2 = load_rgb(os.path.join(REN, f'{s}_nenhum@2x.png'))
    m3 = metrics(raiz2, iso2, 2, 1.5, 16, 24)[0]
    sharp = lap_energy(raiz2) / lap_energy(iso2)
    ok = a1 == 0 and (a2 is None or a2[1] == 0)
    falhas += 0 if ok else 1
    res[s] = {'A1_pixels_diferentes_1x': a1, 'A2_linha': a2[0] if a2 else None, 'A2_pixels_diferentes': a2[1] if a2 else None,
              'A3': {**m3, 'nitidez_raiz_sobre_isolada': round(sharp, 3)}, 'ok': ok}
    a2txt = f'{a2[0]:>5d} {a2[1]:>6d}' if a2 else f'{"—":>12s}'
    print(f'{s:24s} | {a1:>11d} | {a2txt} | {m3["blur_mismatch_%"]:8.4f}  {sharp:6.3f}  {"OK" if ok else "FALHOU"}')
with open(os.path.join(REN, 'comparacao.json'), 'w', encoding='utf-8') as f:
    json.dump(res, f, indent=1)
print('\nTODAS OK' if not falhas else f'\n{falhas} FALHA(S)')
sys.exit(1 if falhas else 0)

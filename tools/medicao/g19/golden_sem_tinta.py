#!/usr/bin/env python3
"""G19 — o blur_mismatch_% do recorte da L25c (y 377,96–2099,98) com e sem as miniaturas de tinta (R10: a tinta sai
dos traços salvos do mundo, não do <svg> estilizado do arquivo — desvio). Mesmo método do tools/compare_images.py
(desfoque de 1,5 px lógico, limiar 24 no maior canal). Uso: golden_sem_tinta.py <golden@3x.png> <referencia@3x.png>
"""
import sys

import numpy as np
from PIL import Image, ImageFilter

S = 3
RECORTE = (0, 377.96, 390, 2099.98)
# as caixas de tinta da prancha (x0, y0, x1, y1 absolutos), com 6 px lógicos de folga: a elipse (e o risco do mundo
# acima dela), a miniatura da nota à mão, o ondulado e o sublinhado duplo
TINTA = [
    (25.5, 1746.43, 177.26, 1780.93),
    (35.0, 1794.38, 355.0, 1890.38),
    (191.79, 1992.33, 326.87, 2001.33),
    (139.89, 2047.13, 289.67, 2053.13),
]


def main():
    g = Image.open(sys.argv[1]).convert('RGB')
    r = Image.open(sys.argv[2]).convert('RGB')
    x0, y0, x1, y1 = (int(round(v * S)) for v in RECORTE)
    gb = np.asarray(g.crop((x0, y0, x1, y1)).filter(ImageFilter.GaussianBlur(1.5 * S))).astype(np.int16)
    rb = np.asarray(r.crop((x0, y0, x1, y1)).filter(ImageFilter.GaussianBlur(1.5 * S))).astype(np.int16)
    diff = np.abs(gb - rb).max(axis=2) > 24
    total = diff.size
    print(f'L25c com a tinta: {100.0 * diff.sum() / total:.4f} %')
    mask = np.ones_like(diff)
    for (a, b, c, d) in TINTA:
        ya = max(0, int((b - 6) * S) - y0)
        yb = min(diff.shape[0], int((d + 6) * S) - y0)
        xa = max(0, int((a - 6) * S))
        xb = min(diff.shape[1], int((c + 6) * S))
        mask[ya:yb, xa:xb] = False
    print(f'L25c sem as 4 caixas de tinta: {100.0 * (diff & mask).sum() / mask.sum():.4f} %')


main()

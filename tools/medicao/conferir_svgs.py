#!/usr/bin/env python3
"""G01.8 — compara as fotos de conferir_svgs.js (original × SVGs trocados pelos arquivos exportados).
T02: as fotos e o resumo ficam na pasta tmp do conjunto (svgcmp/; com MODO=inline, svgcmp_inline/ — T13.11).
"""
import json
import os
import sys
import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import caminho  # noqa: E402

PASTA = 'svgcmp_inline' if os.environ.get('MODO') == 'inline' else 'svgcmp'
R = json.load(open(caminho('tmp', PASTA, 'svgcmp.json')))
out = {}
for slug, r in R.items():
    a = np.asarray(Image.open(r['a']).convert('RGB')).astype(int)
    b = np.asarray(Image.open(r['b']).convert('RGB')).astype(int)
    d = np.abs(a - b).max(2)
    ys, xs = np.nonzero(d > 24)
    out[slug] = {'trocas': r['trocas'], 'pixels_diferentes': int(len(ys)),
                 'regiao_css': [round(xs.min() / 4, 1), round(ys.min() / 4, 1), round(xs.max() / 4, 1), round(ys.max() / 4, 1)] if len(ys) else None}
    print(f"{slug:24s} trocas {r['trocas']:>3d}  px≠ {len(ys):>6d}  {out[slug]['regiao_css'] or ''}")
json.dump(out, open(caminho('tmp', PASTA, 'svgcmp_resumo.json'), 'w'), indent=1)

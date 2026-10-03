#!/usr/bin/env python3
"""G01.5 — junta as faixas do supershot (zoom 10) e reduz com filtro BOX (média de área, como a v1)
para @1x/@2x/@3x → handoff_v2/referencia/png/<slug>_<W>x<H>@<n>x.png.
Conferências:
  convergência (gate): se existir tmp/supershot_z20/<slug> (supershot.js <slug> 20), o @2x reduzido do
    zoom 20 tem de bater com o do zoom 10 (blur ≤ 0,5 %) → 10× já convergiu;
  render direto @2x (informativo): difere de propósito — no zoom 1 o Chromium arredonda bordas de 1,5 px
    para 1 px NO LAYOUT (o conteúdo das caixas com borda desloca), enquanto o supersample usa a geometria
    exata do CSS, a mesma das medidas (zoom 100) e a que o Flutter desenha (1,5 dp).
PNG sem metadados de data (Pillow, optimize) → bytes reprodutíveis.
Uso: python3 tools/medicao/reduzir.py [todas|19,20…]
"""
import json
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from compare_images import load_rgb, metrics  # noqa: E402

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
CFG = json.load(open(os.path.join(AQUI, 'pranchas.json'), encoding='utf-8'))
OUT = os.path.join(RAIZ, 'handoff_v2', 'referencia', 'png')
Z = 10


def stitch(slug, w, h):
    d = os.path.join(AQUI, 'tmp', 'supershot', slug)
    tiles = sorted(f for f in os.listdir(d) if f.endswith('.png'))
    big = Image.new('RGB', (w * Z, h * Z))
    y = 0
    for t in tiles:
        im = Image.open(os.path.join(d, t)).convert('RGB')
        big.paste(im, (0, y))
        y += im.size[1]
    assert y == h * Z, (slug, y, h * Z)
    return big


def main():
    arg = sys.argv[1] if len(sys.argv) > 1 else 'todas'
    sel = CFG['pranchas'] if arg == 'todas' else [p for p in CFG['pranchas'] if p['tela'] in arg.split(',') or p['slug'] in arg.split(',')]
    os.makedirs(OUT, exist_ok=True)
    falhas = 0
    for p in sel:
        w, h = p['canvas']
        big = stitch(p['slug'], w, h)
        for s in (1, 2, 3):
            im = big.resize((w * s, h * s), Image.BOX)
            im.save(os.path.join(OUT, f"{p['slug']}_{w}x{h}@{s}x.png"), optimize=True)
        ref2 = load_rgb(os.path.join(OUT, f"{p['slug']}_{w}x{h}@2x.png"))
        direto = os.path.join(AQUI, 'tmp', 'render', f"{p['slug']}_nenhum@2x.png")
        info = metrics(load_rgb(direto), ref2, 2, 1.5, 16, 24)[0] if os.path.exists(direto) else None
        conv = ''
        z20 = os.path.join(AQUI, 'tmp', 'supershot_z20', p['slug'])
        if os.path.isdir(z20):
            big20 = Image.new('RGB', (w * 20, h * 20))
            y = 0
            for t in sorted(os.listdir(z20)):
                im = Image.open(os.path.join(z20, t)).convert('RGB')
                big20.paste(im, (0, y))
                y += im.size[1]
            m = metrics(big20.resize((w * 2, h * 2), Image.BOX), ref2, 2, 1.5, 16, 24)[0]
            ok = m['blur_mismatch_%'] <= 0.5
            falhas += 0 if ok else 1
            conv = f"convergência z20×z10: blur {m['blur_mismatch_%']:.4f} % {'OK' if ok else 'FALHOU'} · "
        print(f"{p['slug']:24s} @1x/@2x/@3x  {conv}" + (f"(info) × render direto@2x: blur {info['blur_mismatch_%']:.2f} %" if info else ''))
        # variantes (ex.: 21_selecao_texto_corrigida — proposta do relatório G01, não é a referência literal)
        for var in sorted(os.listdir(os.path.join(AQUI, 'tmp', 'supershot'))):
            if var.startswith(p['slug'] + '_'):
                bigv = stitch(var, w, h)
                for s in (1, 2, 3):
                    bigv.resize((w * s, h * s), Image.BOX).save(os.path.join(OUT, f"{var}_{w}x{h}@{s}x.png"), optimize=True)
                print(f"{var:24s} @1x/@2x/@3x  (variante)")
    sys.exit(1 if falhas else 0)


if __name__ == '__main__':
    main()

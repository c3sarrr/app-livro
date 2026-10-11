#!/usr/bin/env python3
"""G01.5 — junta as faixas do supershot (zoom 10) e reduz com filtro BOX (média de área, como a v1)
para @1x/@2x/@3x → handoff_v2/referencia/png/<slug>_<W>x<H>@<n>x.png.
Conferências:
  convergência (gate): se existir tmp/supershot_z20/<slug> (supershot.js <slug> 20), o @2x reduzido do
    zoom 20 tem de bater com o do zoom 10 (blur ≤ 0,5 %) → 10× já convergiu; T02 (R3): se a prancha tem
    convergenciaFaixa ({y: [y0, y1], zoom: Z}), essa faixa é conferida com o zoom Z × 10 e o resto com o 20 × 10;
  T13 (D-279): a prancha com `zoomBase` no índice (a 30b: no zoom 10 o arredondamento da métrica das fontes com
    line-height normal soma até 0,59 px) é reduzida do zoom zoomBase e conferida com o zoomConvergencia (padrão 20;
    a 30b: 20 e 40); a conferência é reduzida faixa a faixa (as faixas de 2000 px caem em bordas de pixel, então dá
    o mesmo que a imagem inteira e o zoom 40 cabe na memória);
  render direto @2x (informativo): difere de propósito — no zoom 1 o Chromium arredonda bordas de 1,5 px
    para 1 px NO LAYOUT (o conteúdo das caixas com borda desloca), enquanto o supersample usa a geometria
    exata do CSS, a mesma das medidas (zoom 100) e a que o Flutter desenha (1,5 dp).
PNG sem metadados de data (Pillow, optimize) → bytes reprodutíveis.
Uso: python3 tools/medicao/reduzir.py [todas|19,20…]
"""
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from compare_images import load_rgb, metrics  # noqa: E402

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import caminho, indice  # noqa: E402

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
CFG = indice()
OUT = caminho('png')
Z = 10


def stitch(slug, w, h, z=Z):
    d = caminho('tmp', 'supershot' if z == Z else f'supershot_z{z}', slug)
    tiles = sorted(f for f in os.listdir(d) if f.endswith('.png'))
    big = Image.new('RGB', (w * z, h * z))
    y = 0
    for t in tiles:
        im = Image.open(os.path.join(d, t)).convert('RGB')
        big.paste(im, (0, y))
        y += im.size[1]
    assert y == h * z, (slug, y, h * z)
    return big


def reduzir_faixas(d, w, h, z, s):
    """As faixas de um supershot no zoom z já reduzidas à escala s, uma a uma (D-279): a faixa tem de cair numa
    borda de pixel da saída (altura × s / z inteira), e então o BOX dá o mesmo que reduzir a imagem inteira."""
    out = Image.new('RGB', (w * s, h * s))
    y = 0
    for t in sorted(f for f in os.listdir(d) if f.endswith('.png')):
        im = Image.open(os.path.join(d, t)).convert('RGB')
        assert (im.size[1] * s) % z == 0, (d, t, im.size[1], z, s)
        out.paste(im.resize((w * s, im.size[1] * s // z), Image.BOX), (0, y))
        y += im.size[1] * s // z
    assert y == h * s, (d, y, h * s)
    return out


def juntar(d, w, h, z):
    """As faixas de um supershot em outro zoom (convergência), na ordem."""
    big = Image.new('RGB', (w * z, h * z))
    y = 0
    for t in sorted(os.listdir(d)):
        im = Image.open(os.path.join(d, t)).convert('RGB')
        big.paste(im, (0, y))
        y += im.size[1]
    assert y == h * z, (d, y, h * z)
    return big


def main():
    arg = sys.argv[1] if len(sys.argv) > 1 else 'todas'
    sel = CFG['pranchas'] if arg == 'todas' else [p for p in CFG['pranchas'] if p['tela'] in arg.split(',') or p['slug'] in arg.split(',')]
    os.makedirs(OUT, exist_ok=True)
    falhas = 0
    for p in sel:
        w, h = p['canvas']
        zb, zc = p.get('zoomBase', Z), p.get('zoomConvergencia', 20)
        big = stitch(p['slug'], w, h, zb)
        for s in (1, 2, 3):
            im = big.resize((w * s, h * s), Image.BOX)
            im.save(os.path.join(OUT, f"{p['slug']}_{w}x{h}@{s}x.png"), optimize=True)
        ref2 = load_rgb(os.path.join(OUT, f"{p['slug']}_{w}x{h}@2x.png"))
        direto = caminho('tmp', 'render', f"{p['slug']}_nenhum@2x.png")
        info = metrics(load_rgb(direto), ref2, 2, 1.5, 16, 24)[0] if os.path.exists(direto) else None
        conv = ''
        z20 = caminho('tmp', f'supershot_z{zc}', p['slug'])
        if os.path.isdir(z20):
            red20 = reduzir_faixas(z20, w, h, zc, 2)
            # T02 (R3): faixa y (px CSS) em que o zoom 20 tem defeito de raster conhecido (motivo no índice,
            # '_convergencia'): a faixa é conferida com outro zoom, sem o defeito; o z20 confere o resto
            faixa = p.get('convergenciaFaixa')
            if faixa:
                (y0, y1), zf = faixa['y'], faixa['zoom']
                caixa = (0, y0 * 2, w * 2, y1 * 2)
                redf = juntar(caminho('tmp', f'supershot_z{zf}', p['slug']), w, h, zf).resize((w * 2, h * 2), Image.BOX)
                mf = metrics(redf.crop(caixa), ref2.crop(caixa), 2, 1.5, 16, 24)[0]
                okf = mf['blur_mismatch_%'] <= 0.5
                falhas += 0 if okf else 1
                red20.paste(ref2.crop(caixa), caixa[:2])
            m = metrics(red20, ref2, 2, 1.5, 16, 24)[0]
            ok = m['blur_mismatch_%'] <= 0.5
            falhas += 0 if ok else 1
            conv = (f"convergência z{zc}×z{zb}: blur {m['blur_mismatch_%']:.4f} % {'OK' if ok else 'FALHOU'}"
                    + (f" (fora de y {y0}–{y1}) · faixa y {y0}–{y1} z{zf}×z10: blur {mf['blur_mismatch_%']:.4f} % "
                       f"{'OK' if okf else 'FALHOU'}" if faixa else '') + ' · ')
        print(f"{p['slug']:24s} @1x/@2x/@3x  {conv}" + (f"(info) × render direto@2x: blur {info['blur_mismatch_%']:.2f} %" if info else ''))
        # variantes (ex.: 21_selecao_texto_corrigida — proposta do relatório G01, não é a referência literal)
        for var in sorted(os.listdir(caminho('tmp', 'supershot'))):
            if var.startswith(p['slug'] + '_'):
                bigv = stitch(var, w, h)
                for s in (1, 2, 3):
                    bigv.resize((w * s, h * s), Image.BOX).save(os.path.join(OUT, f"{var}_{w}x{h}@{s}x.png"), optimize=True)
                print(f"{var:24s} @1x/@2x/@3x  (variante)")
    sys.exit(1 if falhas else 0)


if __name__ == '__main__':
    main()

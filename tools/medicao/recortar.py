#!/usr/bin/env python3
"""G01.5 — recortes por fase e redlines numerados (@3x), no estilo da v1:
  handoff_v2/referencia/png/secoes/<fase>@3x.png          recorte (largura inteira do canvas; altura = união
                                                          dos retângulos de layout e visuais das seções da
                                                          fase + 8 px de folga, limitada ao canvas)
  handoff_v2/referencia/png/redline/<fase>_redline@3x.png o mesmo recorte com um retângulo por id e o Nº
  handoff_v2/referencia/png/redline/legenda.json          {fase: [[Nº, id, tipo], …]} — Nº das tabelas L
Cores: azul = box · verde = text · laranja = icon · magenta = box+text · roxo = inline.
Os rótulos usam a Figtree do próprio arquivo (instância wght 700) → mesmo resultado em qualquer máquina.
Uso: python3 tools/medicao/recortar.py
"""
import io
import json
import os
import sys

from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import caminho, indice  # noqa: E402

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
LAYOUT, PNG = caminho('layout'), caminho('png')
PR = {p['slug']: p for p in indice()['pranchas']}
FASES = json.load(open(caminho('fasesIndice'), encoding='utf-8'))['fases']
COR = {'box': (30, 120, 255), 'text': (0, 160, 80), 'icon': (240, 120, 0), 'box+text': (230, 0, 140),
       'inline': (130, 60, 220)}
S = 3
MARGEM = 8


def fonte_rotulo(px):
    """Figtree (woff2 embutido no arquivo) → TTF em memória → Pillow com wght 700. A da 20 no leitor (como na G01);
    nos outros conjuntos, a da 1ª prancha que a declara."""
    slugs = ['20_leitor_controles'] if '20_leitor_controles' in PR else list(PR)
    asset = slug = None
    for slug in slugs:
        for f in json.load(open(os.path.join(LAYOUT, f'layout_{slug}.json'), encoding='utf-8'))['fontFaces']:
            if f['family'] == 'Figtree':
                asset = f['asset']
                break
        if asset:
            break
    tt = TTFont(caminho('extracao', slug, 'assets', f'{asset}.woff2'))
    tt.flavor = None
    buf = io.BytesIO()
    tt.save(buf)
    buf.seek(0)
    font = ImageFont.truetype(buf, px)
    try:
        font.set_variation_by_axes([700])
    except Exception:  # Pillow sem suporte a fontes variáveis: fica a instância padrão
        pass
    return font


def main():
    os.makedirs(os.path.join(PNG, 'secoes'), exist_ok=True)
    os.makedirs(os.path.join(PNG, 'redline'), exist_ok=True)
    fonte = fonte_rotulo(9 * S)
    legenda = {}
    for fase in FASES:
        slug = fase['prancha']
        p = PR[slug]
        w, h = p['canvas']
        L = json.load(open(os.path.join(LAYOUT, f'layout_{slug}.json'), encoding='utf-8'))
        secoes = [f"{p['prefixo']}.{s}" for s in fase['secoes']]
        els = [(k, e) for k, e in L['elements'].items() if e.get('section') in secoes]
        # sobreposições de tela cheia (véu 'fade', que cobre o canvas) não definem a altura do recorte
        cheias = {s for s in secoes if L['sections'][s][3] >= h - 0.5 and len(secoes) > 1}
        ys = []
        for k, e in els:
            if e['section'] in cheias:
                continue
            for r in (e['abs'], e.get('vis')):
                if r:
                    ys += [r[1], r[1] + r[3]]
        y0 = max(0.0, min(ys) - MARGEM)
        y1 = min(float(h), max(ys) + MARGEM)
        full = Image.open(os.path.join(PNG, f'{slug}_{w}x{h}@{S}x.png')).convert('RGB')
        box = (0, round(y0 * S), w * S, round(y1 * S))
        crop = full.crop(box)
        crop.save(os.path.join(PNG, 'secoes', f"{fase['fase']}@{S}x.png"), optimize=True)
        red = crop.copy()
        dr = ImageDraw.Draw(red)
        leg = []
        for n, (k, e) in enumerate(els, start=1):
            x, y, ww, hh = e.get('vis') or e['abs']
            c = COR[e['type']]
            rx0, ry0 = x * S, (y - y0) * S
            dr.rectangle([rx0, ry0, rx0 + max(ww * S - 1, 1), ry0 + max(hh * S - 1, 1)], outline=c, width=2)
            t = str(n)
            tb = dr.textbbox((0, 0), t, font=fonte)
            tw, th = tb[2] - tb[0], tb[3] - tb[1]
            dr.rectangle([rx0, ry0, rx0 + tw + 6, ry0 + th + 6], fill=c)
            dr.text((rx0 + 3 - tb[0], ry0 + 3 - tb[1]), t, fill=(255, 255, 255), font=fonte)
            leg.append([n, k, e['type']])
        red.save(os.path.join(PNG, 'redline', f"{fase['fase']}_redline@{S}x.png"), optimize=True)
        legenda[fase['fase']] = {'prancha': slug, 'recorte_y': [round(y0, 2), round(y1, 2)], 'itens': leg}
        print(f"{fase['fase']:30s} y {y0:7.2f}–{y1:7.2f}  {len(leg):>3d} ids")
    with open(os.path.join(PNG, 'redline', 'legenda.json'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump(legenda, f, ensure_ascii=False, indent=1)
        f.write('\n')


if __name__ == '__main__':
    main()

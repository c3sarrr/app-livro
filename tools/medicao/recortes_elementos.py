#!/usr/bin/env python3
"""G01.8 — recortes @3x (do supersample 10×) dos elementos desenhados por CSS que viram CustomPainter no app
(gradientes cônicos/radiais, hachuras) → handoff_v2/referencia/png/elementos/<nome>@3x.png, para o teste visual
de cada pintor na G11. Recorte = caixa visual do elemento + 2 px.
Uso: python3 tools/medicao/recortes_elementos.py
"""
import json
import os

from PIL import Image

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
REF = os.path.join(RAIZ, 'handoff_v2', 'referencia')
S = 3
ITENS = [  # (prancha, id, nome)
    ('23_ajustes_caneta', 'pen.penPanel.picker.wheel', 'roda_de_cores'),
    ('23_ajustes_caneta', 'pen.penPanel.picker.brightness', 'brilho_degrade'),
    ('22_modo_anotacao', 'ann.island.colorWell', 'poco_de_cor_anel'),
    ('21_selecao_texto', 'r21.toolbar.colors.other', 'outra_cor_anel'),
    ('20_leitor_controles', 'r20.bottomIsland.scrubber', 'barra_posicao_hachura'),
    ('23_ajustes_caneta', 'pen.penPanel.size', 'espessura_hachura'),
    ('24_abrindo_espaco', 'sp.page.spaceOpener', 'espaco_hachura_roxa'),
    ('23_ajustes_caneta', 'pen.penPanel.preview', 'faixa_pautada_previa'),
    ('22_modo_anotacao', 'ann.deskEdge', 'borda_de_mesa_degrade'),
    ('20_leitor_controles', 'r20.fade', 'veu_pagina_esmaecida'),
    ('26b_tema_noite', 'r20.fade', 'veu_pagina_esmaecida_noite'),
]


def main():
    os.makedirs(os.path.join(REF, 'png', 'elementos'), exist_ok=True)
    pr = {p['slug']: p for p in json.load(open(os.path.join(AQUI, 'pranchas.json'), encoding='utf-8'))['pranchas']}
    for slug, id_, nome in ITENS:
        w, h = pr[slug]['canvas']
        L = json.load(open(os.path.join(REF, 'layout', f'layout_{slug}.json'), encoding='utf-8'))
        e = L['elements'][id_]
        x, y, ww, hh = e.get('vis') or e['abs']
        im = Image.open(os.path.join(REF, 'png', f'{slug}_{w}x{h}@{S}x.png'))
        box = (max(0, round((x - 2) * S)), max(0, round((y - 2) * S)), min(w * S, round((x + ww + 2) * S)), min(h * S, round((y + hh + 2) * S)))
        im.crop(box).save(os.path.join(REF, 'png', 'elementos', f'{nome}@{S}x.png'), optimize=True)
        print(f'{nome:30s} {id_:40s} {box}')


if __name__ == '__main__':
    main()

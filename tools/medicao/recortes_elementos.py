#!/usr/bin/env python3
"""G01.8 — recortes @3x (do supersample 10×) dos elementos desenhados por CSS que viram CustomPainter no app
(gradientes cônicos/radiais, hachuras) → handoff_v2/referencia/png/elementos/<nome>@3x.png, para o teste visual
de cada pintor na G11. Recorte = caixa visual do elemento + 2 px.
Uso: [CONJUNTO=inicio2] python3 tools/medicao/recortes_elementos.py
T02: pastas e lista de elementos pelo conjunto (ITENS_INICIO2; nos outros, ITENS_LEITOR, a lista da G01).
"""
import json
import os
import sys

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import NOME, caminho, indice  # noqa: E402

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
S = 3
ITENS_LEITOR = [  # (prancha, id, nome)
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
# T02 — Início e revisão: hachuras e degradês do CSS, e os dois gráficos em SVG que viram CustomPainter (svg_graficos)
ITENS_INICIO2 = [
    ('001_inicio', 'i01.today.week.bar0', 'barra_semana_hachura'),
    ('001_inicio', 'i01.today.week.bar6', 'barra_semana_hoje_hachura'),
    ('001_inicio', 'i01.club.progressBar', 'barra_clube_hachura'),
    ('001_inicio', 'i01.today.dial', 'mostrador_meta_diaria'),
    ('001_inicio', 'i01.alsoReading.card2.ring', 'anel_progresso_livro'),
    ('001_inicio', 'i01.bottomFade', 'degrade_inferior'),
    ('001b_inicio_lendo_agora', 'i01b.bottomFade', 'degrade_inferior_lendo_agora'),
    ('061_revisao_grifo_2_de_5', 'rv61.header.progress.step1', 'progresso_revisao_metade'),
    ('061_revisao_grifo_2_de_5', 'rv61.header.progress.step2', 'progresso_revisao_hachura'),
    ('061_revisao_grifo_2_de_5', 'rv61.deck.card.quote.mark', 'grifo_rosa_cartao'),
    ('062_revisao_fim', 'rv62.footer', 'degrade_rodape_revisao'),
    ('063_revisao_imagem_compartilhar', 'rv63.sheet.preview.quote.highlight', 'grifo_creme_previa'),
    # capas e cartões desenhados em CSS (div, borda, raio, círculo — não são <svg>): viram widgets compostos;
    # as do herói (Dom Casmurro) e da mini-barra (Brás Cubas com asas) são SVG (assets/illustrations/inicio2)
    ('001_inicio', 'i01.alsoReading.card1.cover', 'capa_bras_cubas_cartola'),
    ('001_inicio', 'i01.alsoReading.card2.cover', 'capa_orgulho_e_preconceito'),
    ('001_inicio', 'i01.forYou.item1.cover', 'capa_esau_e_jaco'),
    ('001_inicio', 'i01.forYou.item2.cover', 'capa_memorial_de_aires'),
    ('001_inicio', 'i01.forYou.item3.cover', 'capa_casa_de_pensao'),   # passa da borda (carrossel): recorte até x 390
    # (Quincas Borba e O Cortiço, do "Para você" da 01b, estão no DOM abaixo dos 844 px da prancha: sem imagem)
    ('001_inicio', 'i01.recent.row0.cover', 'capa_frankenstein'),
    ('001_inicio', 'i01.recent.row1.cover', 'capa_o_alienista'),
    ('001_inicio', 'i01.recent.row2.cover', 'capa_senhora'),
    ('001_inicio', 'i01.review.art', 'cartoes_revisao_inicio'),
    ('062_revisao_fim', 'rv62.summary.art', 'cartoes_revisao_fim'),
]
ITENS = {'inicio2': ITENS_INICIO2}.get(NOME, ITENS_LEITOR)


def main():
    os.makedirs(caminho('png', 'elementos'), exist_ok=True)
    pr = {p['slug']: p for p in indice()['pranchas']}
    for slug, id_, nome in ITENS:
        w, h = pr[slug]['canvas']
        L = json.load(open(caminho('layout', f'layout_{slug}.json'), encoding='utf-8'))
        e = L['elements'][id_]
        x, y, ww, hh = e.get('vis') or e['abs']
        im = Image.open(caminho('png', f'{slug}_{w}x{h}@{S}x.png'))
        box = (max(0, round((x - 2) * S)), max(0, round((y - 2) * S)), min(w * S, round((x + ww + 2) * S)), min(h * S, round((y + hh + 2) * S)))
        im.crop(box).save(caminho('png', 'elementos', f'{nome}@{S}x.png'), optimize=True)
        print(f'{nome:30s} {id_:40s} {box}')


if __name__ == '__main__':
    main()

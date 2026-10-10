#!/usr/bin/env python3
"""T02 · D-249 — confere cada fonte gerada por build_fonts.py contra a fonte de origem do arquivo, modelada pelo
HarfBuzz com as variações da instância (é o que o Chromium faz com a variável): mesmos glifos e clusters; avanços a
≤ 0,5 unidade da UPM do arquivo gerado (cada avanço é um valor arredondado) e offsets a ≤ 1,5 (a posição de um acento
soma até três âncoras arredondadas: a da base, a do acento e a do acento de baixo, no empilhamento das letras
vietnamitas decompostas) — mais a quantização do HarfBuzz (1/1024 de unidade de cada fonte). Na UPM 10000, 1,5 unidade
a 42 px = 0,006 px. As convertidas sem instanciar (Literata e Lora variáveis, Atkinson) têm de sair idênticas.
Arquivos: os três manifestos (fontes_v1.json, fontes_leitor.json, fontes_inicio2.json). Textos: todas as linhas medidas
nas pranchas (leitor e Início) e um corpus com latin-ext, vietnamita, cirílico, grego e símbolos; cada texto com e sem
ligaduras e com 'tnum'.
Uso: python3 tools/fonts/conferir_estaticas.py   (requer fonttools, brotli e uharfbuzz; código 1 se algo passar)
"""
import glob
import io
import json
import os
import re
import sys

import uharfbuzz as hb
from fontTools.ttLib import TTFont

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
sys.path.insert(0, AQUI)
sys.path.insert(0, os.path.join(RAIZ, 'tools', 'medicao'))
import build_fonts as bf  # noqa: E402

MANIFESTOS = ['fontes_v1.json', 'fontes_leitor.json', 'fontes_inicio2.json']
SUB = {v: k for k, v in bf.SFX.items()}
PESO = {v: k for k, v in bf.LABEL.items()}
LIM_AVANCO, LIM_OFFSET = 0.5, 1.5     # + quantização (ver o topo)
FEATURES = ({'kern': True}, {'kern': True, 'liga': False, 'clig': False, 'calt': False}, {'kern': True, 'tnum': True})
CORPUS = ['Ação, coração, informação — não há açúcar. fi fl ff ffi ffl ft fj tt ½ ¾ “aspas” ‘simples’ … 0123456789',
          'ÁÉÍÓÚÂÊÔÃÕÀÇ áéíóúâêôãõàç ÿ ñ ß Œœ Ææ ŁłŚśŹźŻżĄąĘę ŐőŰű Čč Řř Šš Žž Ğğ İı Şş',
          'Tiếng Việt: Ắắ Ằằ Ẳẳ Ẵẵ Ặặ Ấấ Ầầ Ẩẩ Ẫẫ Ậậ Ếế Ềề Ểể Ễễ Ệệ Ốố Ồồ Ổổ Ỗỗ Ộộ Ớớ Ờờ Ởở Ỡỡ Ợợ Ứứ Ừừ Ửử Ữữ Ựự Đđ',
          'Привет, мир — съешь же ещё этих мягких булок. Ελληνικά: Γειά σου κόσμε. ∑∫≈≠≤≥±×÷√∞ ←→↑↓ €£¥ №',
          'AVATAR WAVY Tyre LT LY PA To Te Ta Yo Ya Va Vo We Wa ky kv rv ry fr ft']


def origem(nome):
    """(fonte de origem, variações) da instância — o inverso dos nomes de build_fonts.py."""
    m = re.fullmatch(r'Figtree(\w*)-(\w+)\.ttf', nome)
    if m:
        return bf.src('Figtree', SUB[m.group(1)]), {'wght': PESO[m.group(2)]}
    m = re.fullmatch(r'Bricolage(\d+(?:_5)?)(\w*)-ExtraBold\.ttf', nome)
    if m:
        return bf.src('Bricolage', SUB[m.group(2)]), {'wght': 800, 'opsz': float(m.group(1).replace('_', '.'))}
    m = re.fullmatch(r'Literata(\d+(?:_5)?)(\w*)-(\w+)\.ttf', nome)
    if m:
        return (bf.src('Literata', SUB[m.group(2)]),
                {'wght': PESO[m.group(3)], 'opsz': float(m.group(1).replace('_', '.'))})
    m = re.fullmatch(r'Literata(Italic)?-VF(\w*)\.ttf', nome)
    if m:
        return bf.src('Literata', SUB[m.group(2)], 'italic' if m.group(1) else 'normal'), None
    m = re.fullmatch(r'Lora-VF(\w*)\.ttf', nome)
    if m:
        return bf.src('Lora', SUB[m.group(1)]), None
    m = re.fullmatch(r'AtkinsonHyperlegible(\w*)-(\w+)\.ttf', nome)
    if m:
        return bf.src(f'Atkinson{PESO[m.group(2)]}', SUB[m.group(1)]), None
    raise KeyError(nome)


_fontes = {}


def fonte(path, var=None):
    """(hb.Font, upem, nomes dos glifos) — WOFF2 descompactado em memória (o HarfBuzz não abre WOFF2)."""
    chave = (path, json.dumps(var, sort_keys=True))
    if chave not in _fontes:
        tt = TTFont(path)
        tt.flavor = None
        buf = io.BytesIO()
        tt.save(buf)
        face = hb.Face(hb.Blob(buf.getvalue()))
        f = hb.Font(face)
        if var:
            f.set_variations({k: float(v) for k, v in var.items()})
        f.scale = (face.upem * 1024, face.upem * 1024)
        _fontes[chave] = (f, face.upem, tt.getGlyphOrder())
    return _fontes[chave]


def modela(fonte_, texto, feats, up_gerada):
    """Glifos (nome, cluster) e posições (avanço, offset x, offset y) em unidades da UPM do arquivo gerado."""
    f, upem, ordem = fonte_
    buf = hb.Buffer()
    buf.add_str(texto)
    buf.guess_segment_properties()
    hb.shape(f, buf, feats)
    k = up_gerada / (upem * 1024)          # a escala da fonte é upem × 1024 (frações de unidade)
    return ([(ordem[i.codepoint], i.cluster) for i in buf.glyph_infos],
            [(p.x_advance * k, p.x_offset * k, p.y_offset * k) for p in buf.glyph_positions])


def main():
    textos = set(CORPUS)
    for f in (glob.glob(os.path.join(RAIZ, 'handoff_v2', 'referencia', 'layout', 'layout_*.json'))
              + glob.glob(os.path.join(RAIZ, 'docs', 'design', 'medicao', '*', 'layout', 'layout_*.json'))):
        for e in json.load(open(f, encoding='utf-8'))['elements'].values():
            for ln in e.get('lines', []) + e.get('linesAll', []):
                textos.add(ln['text'])
    textos = sorted(textos)
    falhas, linhas, modelagens = [], [], 0
    for man in MANIFESTOS:
        for item in json.load(open(os.path.join(AQUI, man), encoding='utf-8'))['arquivos']:
            nome = item['arquivo']
            src, var = origem(nome)
            gerada = fonte(os.path.join(RAIZ, 'assets', 'fonts', nome))
            ref = fonte(src, var)
            up = gerada[1]
            pior_av = pior_off = 0.0
            for t in textos:
                for feats in FEATURES:
                    ga, pa = modela(gerada, t, feats, up)
                    gb, pb = modela(ref, t, feats, up)
                    modelagens += 1
                    if ga != gb:
                        falhas.append(f'{nome}: glifos/clusters diferentes em {t[:30]!r} {feats}')
                        continue
                    for (a_av, a_x, a_y), (b_av, b_x, b_y) in zip(pa, pb):
                        pior_av = max(pior_av, abs(a_av - b_av))
                        pior_off = max(pior_off, abs(a_x - b_x), abs(a_y - b_y))
            exata = var is None
            q = up / gerada[1] / 1024 + up / ref[1] / 1024
            ok = (pior_av == 0 and pior_off == 0) if exata else (pior_av <= LIM_AVANCO + q and pior_off <= LIM_OFFSET + q)
            if not ok:
                falhas.append(f'{nome}: avanço {pior_av:.3f} u · offset {pior_off:.3f} u (UPM {up})')
            linhas.append((man, nome, 'convertida' if exata else 'instância', round(pior_av, 3), round(pior_off, 3), up))
    for man in MANIFESTOS:
        grupo = [x for x in linhas if x[0] == man]
        inst = [x for x in grupo if x[2] == 'instância']
        conv = [x for x in grupo if x[2] == 'convertida']
        print(f'{man:20s} {len(grupo):3d} arquivos · instâncias: {len(inst)}, maior diferença de avanço '
              f'{max((x[3] for x in inst), default=0):.3f} u e de offset {max((x[4] for x in inst), default=0):.3f} u'
              + (f' · convertidas: {len(conv)}, iguais: {sum(1 for x in conv if x[3] == 0 and x[4] == 0)}' if conv else ''))
    print(f'{len(textos)} textos × {len(FEATURES)} conjuntos de features · {modelagens} modelagens · '
          f'{"OK" if not falhas else f"{len(falhas)} FALHAS"}')
    for f in falhas[:20]:
        print('  ', f)
    sys.exit(1 if falhas else 0)


if __name__ == '__main__':
    main()

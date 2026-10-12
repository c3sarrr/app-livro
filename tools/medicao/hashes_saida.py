#!/usr/bin/env python3
"""G01.11 — sha256 de todas as saídas versionadas da G01 (ordem fixa), para conferir a reprodutibilidade.
T02: [CONJUNTO=inicio2] → as saídas do conjunto (pastas e arquivos do conjuntos.json; no leitor, a lista da G01).
"""
import hashlib
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import C, NOME  # noqa: E402

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
FONTES = 'assets/fonts'
if NOME == 'leitor':
    PASTAS = ['handoff_v2/referencia/layout', 'handoff_v2/referencia/png', 'handoff_v2/referencia/svg_tinta',
              'handoff_v2/referencia/svg_graficos', 'handoff_v2/fases', 'test/reference/leitor', 'assets/icons/leitor',
              'assets/illustrations/leitor', 'tools/medicao/idmaps']
    ARQS = ['handoff_v2/referencia/svg_catalogo.json', 'handoff_v2/referencia/tokens_leitor.json',
            'handoff_v2/referencia/mapa_widgets.json', 'tools/medicao/pranchas/extracao.json', 'tools/fonts/fontes_leitor.json',
            'tools/fonts/validacao_fontes.json']
elif 'hashes' in C:
    # T03: conjunto só de medidas (as larguras da 01): as pastas da lista, sem fases nem fontes
    PASTAS, ARQS = C['hashes'], []
else:
    # as fases do conjunto são os arquivos do índice (a pasta docs/design/fases é compartilhada com outros conjuntos)
    fases = [f['fase'] + '.md' for f in json.load(open(os.path.join(RAIZ, C['fasesIndice']), encoding='utf-8'))['fases']]
    # T13.13: o projeto não tem SVG de tinta e grava os desenhos numa pasta por área (`areas`)
    PASTAS = [C[k] for k in ('layout', 'png', 'svgTinta', 'svgGraficos', 'dart', 'idmaps') if k in C]
    for k in ('icones', 'ilustracoes'):
        PASTAS += [f"{C[k]}/{a}" for a in C['areas'].values()] if C.get('areas') else [C[k]]
    ARQS = [C[k] for k in ('svgCatalogo', 'tokens', 'mapa', 'tokensMd', 'fontesManifesto', 'validacaoFontes')] + \
        [C['extracao'] + '/extracao.json'] + [f"{C['fases']}/{f}" for f in fases + [C['fasesLeiaMe'][0]]]
lista = []
for p in PASTAS:
    for raiz, _, fs in os.walk(os.path.join(RAIZ, p)):
        lista += [os.path.relpath(os.path.join(raiz, f), RAIZ) for f in fs]
lista += ARQS
if 'hashes' not in C:
    lista += [f"{FONTES}/{a['arquivo']}" for a in json.load(open(os.path.join(RAIZ, C.get('fontesManifesto', 'tools/fonts/fontes_leitor.json'))))['arquivos']]
for rel in sorted(set(x.replace(os.sep, '/') for x in lista)):
    with open(os.path.join(RAIZ, rel), 'rb') as f:
        print(hashlib.sha256(f.read()).hexdigest(), rel)

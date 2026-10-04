#!/usr/bin/env python3
"""G01.11 — sha256 de todas as saídas versionadas da G01 (ordem fixa), para conferir a reprodutibilidade."""
import hashlib
import os

RAIZ = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
PASTAS = ['handoff_v2/referencia/layout', 'handoff_v2/referencia/png', 'handoff_v2/referencia/svg_tinta',
          'handoff_v2/referencia/svg_graficos', 'handoff_v2/fases', 'test/reference/leitor', 'assets/icons/leitor',
          'assets/illustrations/leitor', 'tools/medicao/idmaps']
ARQS = ['handoff_v2/referencia/svg_catalogo.json', 'handoff_v2/referencia/tokens_leitor.json',
        'handoff_v2/referencia/mapa_widgets.json', 'tools/medicao/pranchas/extracao.json', 'tools/fonts/fontes_leitor.json',
        'tools/fonts/validacao_fontes.json']
FONTES = 'assets/fonts'
lista = []
for p in PASTAS:
    for raiz, _, fs in os.walk(os.path.join(RAIZ, p)):
        lista += [os.path.relpath(os.path.join(raiz, f), RAIZ) for f in fs]
lista += ARQS
import json
lista += [f"{FONTES}/{a['arquivo']}" for a in json.load(open(os.path.join(RAIZ, 'tools/fonts/fontes_leitor.json')))['arquivos']]
for rel in sorted(set(x.replace(os.sep, '/') for x in lista)):
    with open(os.path.join(RAIZ, rel), 'rb') as f:
        print(hashlib.sha256(f.read()).hexdigest(), rel)

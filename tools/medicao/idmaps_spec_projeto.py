#!/usr/bin/env python3
"""T13 (R4) — ids semânticos das 41 telas do projeto (conjunto `projeto`): junta os módulos de cada etapa
(idmaps_spec_projeto_t14.py … _t18.py) em SPEC, SECOES e ESPECIAIS para o gerador
(CONJUNTO=projeto python3 tools/medicao/idmaps_spec.py [telas]).

Cada etapa entra aqui quando os ids dela ficam prontos (T13.4 a T13.8); uma tela não pode aparecer em dois módulos.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import idmaps_spec_projeto_t14 as t14  # noqa: E402

ETAPAS = [t14]

SPEC, SECOES, ESPECIAIS = {}, {}, set()
for _m in ETAPAS:
    _repetidas = set(SPEC) & set(_m.SPEC)
    if _repetidas:
        raise SystemExit(f'telas em dois módulos de ids: {sorted(_repetidas)}')
    SPEC.update(_m.SPEC)
    SECOES.update(_m.SECOES)
    ESPECIAIS |= _m.ESPECIAIS

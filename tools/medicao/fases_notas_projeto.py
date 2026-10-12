"""T13.12 — a parte ESCRITA À MÃO das fases L do projeto (leitura de designer, interações, dados, armadilhas,
subfases), um módulo por etapa: `fases_notas_projeto_t14.py` (Biblioteca), `_t15.py` (Scanner e busca), `_t16.py`
(Entrada e onboarding), `_t17.py` (Perfil, ajustes, conta, privacidade e notificações) e `_t18.py` (Cronômetro). A parte
medida (HTML literal, tabelas, linhas, diferenças, larguras, semântica, widgets, testes) é gerada por `gen_fases.py`
(`CONJUNTO=projeto`). As notas valem junto com as do design (`docs/design/projeto/NOTAS.md`).
"""
import importlib

NOTAS = {}
for _etapa in ('t14', 't15', 't16', 't17', 't18'):
    _m = importlib.import_module(f'fases_notas_projeto_{_etapa}')
    _repetidas = set(NOTAS) & set(_m.NOTAS)
    if _repetidas:
        raise SystemExit(f'fases repetidas em fases_notas_projeto_{_etapa}: {sorted(_repetidas)}')
    NOTAS.update(_m.NOTAS)

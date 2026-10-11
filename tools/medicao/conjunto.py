"""T02 — o conjunto de pranchas em medição (variável CONJUNTO; padrão: leitor) e os caminhos dele (conjuntos.json).

    from conjunto import C, RAIZ, AQUI, caminho
    C['indice'] → 'tools/medicao/pranchas.json' (relativo à raiz); caminho('layout') → absoluto.
"""
import json
import os

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.dirname(os.path.dirname(AQUI))
NOME = os.environ.get('CONJUNTO', 'leitor')
_TODOS = json.load(open(os.path.join(AQUI, 'conjuntos.json'), encoding='utf-8'))
if NOME not in _TODOS or NOME.startswith('_'):
    raise SystemExit(f'CONJUNTO desconhecido: {NOME} (há: {", ".join(k for k in _TODOS if not k.startswith("_"))})')
C = _TODOS[NOME]


def caminho(chave, *partes):
    """Caminho absoluto da saída/entrada [chave] do conjunto, com [partes] a mais."""
    return os.path.join(RAIZ, *C[chave].split('/'), *partes)


def indice():
    return json.load(open(caminho('indice'), encoding='utf-8'))

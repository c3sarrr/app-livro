"""Dumps do Open Library (https://openlibrary.org/developers/dumps).

Formato: `tipo \\t chave \\t revisão \\t última modificação \\t JSON` por linha. Notas e estantes:
`obra \\t edição (opcional) \\t valor \\t data`.

Os dumps têm dezenas de milhões de linhas: o JSON é lido em vários processos (lotes de linhas, na
ordem do arquivo — a saída é a mesma de uma leitura sequencial) e o processo principal só grava.
"""
from __future__ import annotations

import multiprocessing
import os
from collections import deque
from collections.abc import Callable, Iterator
from concurrent.futures import ProcessPoolExecutor
from dataclasses import dataclass, field
from pathlib import Path

from . import isbn as isbn_mod
from . import texto
from .fluxo import abrir_bytes, abrir_linhas, blocos, carregar_json

FONTE = "openlibrary"
LICENCA = "OL-sem-direitos"  # "The Internet Archive does not assert any new copyright…" (LICENCAS.md)

#: bytes por bloco enviado a um processo; processos (None = núcleos − 2, no máximo 8; 1 = sem paralelo).
#: O processo principal só lê blocos e grava: decodificar, separar as linhas e ler o JSON é dos
#: processos auxiliares (com os dumps reais, a leitura linha a linha no principal era o gargalo).
BLOCO_BYTES = 8 << 20
PROCESSOS: int | None = None


def _processos() -> int:
    if PROCESSOS is not None:
        return PROCESSOS
    return max(1, min(8, (os.cpu_count() or 2) - 2))


#: montagem das linhas finais de cada edição (autores pelos índices em memória do principal), feita nos
#: processos auxiliares — que a herdam pelo fork. Com os dumps reais, montar no principal o deixava no
#: limite (GIL) e os auxiliares ociosos (achado 17).
_MONTAGEM: Callable[[Edicao], list] | None = None
MONTADA = "edicao_montada"


def _lote(args: tuple[str, str | None, bytes]) -> tuple[list, int]:
    """Num processo auxiliar: bloco de linhas → (registros já transformados, nº de registros com
    formato inesperado — descartados e contados, nunca derrubam a execução)."""
    tipo, filtro, bloco = args
    montar = _MONTAGEM if tipo == MONTADA else None
    if tipo == MONTADA and montar is None:
        raise RuntimeError("edições montadas sem a montagem (o processo auxiliar não veio do fork)")
    f = _TRANSFORMACOES["edicao" if montar else tipo]
    saida = []
    estranhos = 0
    for linha in bloco.decode("utf-8", "replace").split("\n"):
        if not linha or (filtro and filtro not in linha):
            continue
        partes = linha.split("\t", 4)
        if len(partes) != 5:
            continue
        try:
            j = carregar_json(partes[4])
            r = f(partes[1], j) if isinstance(j, dict) else None
        except (ValueError, TypeError, AttributeError, KeyError):
            estranhos += 1
            continue
        if r is None:
            continue
        if montar is None:
            saida.append(r)
        else:
            saida.extend(montar(r))  # fora do try: erro na montagem é erro do programa, não do dump
    return saida, estranhos


def _em_paralelo(caminho: Path, tipo: str, filtro: str | None = None) -> Iterator:
    """Registros transformados de `tipo`, na ordem do arquivo, com no máximo 2 blocos por processo em
    andamento (o arquivo não é lido inteiro para a memória)."""
    n = _processos()
    # fork: os auxiliares herdam a montagem e os índices do principal (sem copiar — só leitura)
    contexto = multiprocessing.get_context("fork") if "fork" in multiprocessing.get_all_start_methods() else None
    if tipo == MONTADA and contexto is None:  # pragma: no cover - sem fork (fora do Linux): tudo no principal
        n = 1
    estranhos = 0

    def resultado(r: tuple[list, int]) -> list:
        nonlocal estranhos
        estranhos += r[1]
        return r[0]

    with abrir_bytes(caminho) as f:
        tarefas = ((tipo, filtro, b) for b in blocos(f, BLOCO_BYTES))
        if n <= 1:
            for t in tarefas:
                yield from resultado(_lote(t))
        else:
            with ProcessPoolExecutor(max_workers=n, mp_context=contexto) as pool:
                fila: deque = deque()
                for t in tarefas:
                    fila.append(pool.submit(_lote, t))
                    if len(fila) >= 2 * n:
                        yield from resultado(fila.popleft().result())
                while fila:
                    yield from resultado(fila.popleft().result())
    if estranhos:
        print(f"[openlibrary] {tipo}: {estranhos} registros com formato inesperado (descartados)", flush=True)


def _autor(chave: str, j: dict) -> tuple[str, str] | None:
    nome = texto.limpar(j.get("name") or j.get("personal_name"), 200)
    return (chave, nome) if nome else None


def _chave(v: object) -> str | None:
    """`{"key": "/authors/OL1A"}` ou, em registros antigos do dump, só `"/authors/OL1A"`."""
    if isinstance(v, dict):
        v = v.get("key")
    return v if isinstance(v, str) and v.startswith("/") else None


def _obra(chave: str, j: dict) -> tuple[str, str | None, list[str]]:
    autores_ = []
    for a in _lista(j.get("authors")):
        k = _chave(a.get("author")) if isinstance(a, dict) else None
        if k:
            autores_.append(k)
    return chave, texto.limpar(j.get("title")), autores_[:5]


def autores(caminho: Path) -> Iterator[tuple[str, str]]:
    return _em_paralelo(caminho, "autor")


def obras(caminho: Path) -> Iterator[tuple[str, str | None, list[str]]]:
    return _em_paralelo(caminho, "obra")


def contagens(caminho: Path) -> Iterator[tuple[str, str | None]]:
    """Notas (ratings) e estantes (reading-log): (obra, edição ou None) por linha."""
    with abrir_linhas(caminho) as linhas:
        for linha in linhas:
            partes = linha.rstrip("\n").split("\t")
            if not partes or not partes[0].startswith("/works/"):
                continue
            ed = partes[1] if len(partes) > 1 and partes[1].startswith("/books/") else None
            yield partes[0], ed


@dataclass
class Edicao:
    chave: str
    isbns: list[str]
    titulo: str
    subtitulo: str | None
    autores: list[str]  # chaves /authors/...
    obra: str | None
    editora: str | None
    ano: int | None
    paginas: int | None
    idioma: str | None
    capa: str | None
    pais: str | None
    extra: dict = field(default_factory=dict)


def _lista(v: object) -> list:
    """Campos de lista que, em registros antigos, vêm como valor solto."""
    if v is None:
        return []
    return v if isinstance(v, list) else [v]


def _edicao(chave: str, j: dict) -> Edicao | None:
    isbns: list[str] = []
    for bruto in _lista(j.get("isbn_13")) + _lista(j.get("isbn_10")):
        n = isbn_mod.normalizar(bruto)
        if n and n not in isbns:
            isbns.append(n)
    titulo = texto.limpar(j.get("title"))
    if not isbns or not titulo:
        return None
    autores_ = [k for k in (_chave(a) for a in _lista(j.get("authors"))) if k]
    obras_ = [k for k in (_chave(o) for o in _lista(j.get("works"))) if k]
    editoras = _lista(j.get("publishers"))
    capas = [c for c in _lista(j.get("covers")) if isinstance(c, int) and c > 0]
    idiomas = [texto.idioma_ol(x.get("key")) for x in _lista(j.get("languages")) if isinstance(x, dict)]
    idiomas = [i for i in idiomas if i]
    pais = j.get("publish_country")
    return Edicao(
        chave=chave,
        isbns=isbns,
        titulo=titulo,
        subtitulo=texto.limpar(j.get("subtitle")),
        autores=autores_[:5],
        obra=obras_[0] if obras_ else None,
        editora=texto.limpar(editoras[0], 200) if editoras and isinstance(editoras[0], str) else None,
        ano=texto.ano(j.get("publish_date")),
        paginas=texto.paginas(j.get("number_of_pages")),
        idioma=idiomas[0] if idiomas else None,
        capa=f"ol:{capas[0]}" if capas else None,
        pais=pais.strip() if isinstance(pais, str) and pais.strip() else None,
    )


def edicoes(caminho: Path) -> Iterator[Edicao]:
    """Só as edições com ISBN válido (as outras não servem ao scanner)."""
    return _em_paralelo(caminho, "edicao", filtro='"isbn_')


def edicoes_montadas(caminho: Path, montar: Callable[[Edicao], list]) -> Iterator:
    """As linhas que `montar` faz de cada edição com ISBN, na ordem do arquivo; `montar` roda nos processos
    auxiliares (que a herdam pelo fork, com tudo o que ela enxerga no principal)."""
    global _MONTAGEM
    _MONTAGEM = montar
    try:
        yield from _em_paralelo(caminho, MONTADA, filtro='"isbn_')
    finally:
        _MONTAGEM = None


_TRANSFORMACOES: dict[str, Callable[[str, dict], object]] = {"autor": _autor, "obra": _obra, "edicao": _edicao}

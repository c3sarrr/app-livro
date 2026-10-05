"""Dumps do Open Library (https://openlibrary.org/developers/dumps).

Formato: `tipo \\t chave \\t revisão \\t última modificação \\t JSON` por linha. Notas e estantes:
`obra \\t edição (opcional) \\t valor \\t data`.

Os dumps têm dezenas de milhões de linhas: o JSON é lido em vários processos (lotes de linhas, na
ordem do arquivo — a saída é a mesma de uma leitura sequencial) e o processo principal só grava.
"""
from __future__ import annotations

import os
from collections import deque
from collections.abc import Callable, Iterator
from concurrent.futures import ProcessPoolExecutor
from dataclasses import dataclass, field
from pathlib import Path

from . import isbn as isbn_mod
from . import texto
from .fluxo import abrir_linhas, carregar_json

FONTE = "openlibrary"
LICENCA = "OL-sem-direitos"  # "The Internet Archive does not assert any new copyright…" (LICENCAS.md)

#: linhas por lote enviado a um processo; processos (None = núcleos − 2, no máximo 8; 1 = sem paralelo)
LOTE_LINHAS = 4000
PROCESSOS: int | None = None


def _processos() -> int:
    if PROCESSOS is not None:
        return PROCESSOS
    return max(1, min(8, (os.cpu_count() or 2) - 2))


def _lote(args: tuple[str, list[str]]) -> list:
    """Num processo auxiliar: linhas → registros já transformados (None = descartado)."""
    tipo, linhas = args
    f = _TRANSFORMACOES[tipo]
    saida = []
    for linha in linhas:
        partes = linha.rstrip("\n").split("\t", 4)
        if len(partes) != 5:
            continue
        try:
            j = carregar_json(partes[4])
        except ValueError:
            continue
        r = f(partes[1], j)
        if r is not None:
            saida.append(r)
    return saida


def _em_paralelo(caminho: Path, tipo: str, filtro: str | None = None) -> Iterator:
    """Registros transformados de `tipo`, na ordem do arquivo, com no máximo 2 lotes por processo em
    andamento (o arquivo não é lido inteiro para a memória)."""
    n = _processos()
    with abrir_linhas(caminho) as linhas:
        def lotes() -> Iterator[tuple[str, list[str]]]:
            atual: list[str] = []
            for linha in linhas:
                if filtro and filtro not in linha:
                    continue
                atual.append(linha)
                if len(atual) >= LOTE_LINHAS:
                    yield tipo, atual
                    atual = []
            if atual:
                yield tipo, atual

        if n <= 1:
            for x in lotes():
                yield from _lote(x)
            return
        with ProcessPoolExecutor(max_workers=n) as pool:
            fila: deque = deque()
            for x in lotes():
                fila.append(pool.submit(_lote, x))
                if len(fila) >= 2 * n:
                    yield from fila.popleft().result()
            while fila:
                yield from fila.popleft().result()


def _autor(chave: str, j: dict) -> tuple[str, str] | None:
    nome = texto.limpar(j.get("name") or j.get("personal_name"), 200)
    return (chave, nome) if nome else None


def _obra(chave: str, j: dict) -> tuple[str, str | None, list[str]]:
    autores_ = []
    for a in j.get("authors") or []:
        k = (a.get("author") or {}).get("key") if isinstance(a, dict) else None
        if isinstance(k, str):
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


def _edicao(chave: str, j: dict) -> Edicao | None:
    isbns: list[str] = []
    for bruto in list(j.get("isbn_13") or []) + list(j.get("isbn_10") or []):
        n = isbn_mod.normalizar(bruto)
        if n and n not in isbns:
            isbns.append(n)
    titulo = texto.limpar(j.get("title"))
    if not isbns or not titulo:
        return None
    autores_ = [a["key"] for a in (j.get("authors") or []) if isinstance(a, dict) and isinstance(a.get("key"), str)]
    obras_ = [o["key"] for o in (j.get("works") or []) if isinstance(o, dict) and isinstance(o.get("key"), str)]
    editoras = j.get("publishers") or []
    capas = [c for c in (j.get("covers") or []) if isinstance(c, int) and c > 0]
    idiomas = [texto.idioma_ol(x.get("key")) for x in (j.get("languages") or []) if isinstance(x, dict)]
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


_TRANSFORMACOES: dict[str, Callable[[str, dict], object]] = {"autor": _autor, "obra": _obra, "edicao": _edicao}

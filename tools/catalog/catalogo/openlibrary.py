"""Dumps do Open Library (https://openlibrary.org/developers/dumps).

Formato: `tipo \\t chave \\t revisão \\t última modificação \\t JSON` por linha. Notas e estantes:
`obra \\t edição (opcional) \\t valor \\t data`.
"""
from __future__ import annotations

from collections.abc import Iterator
from dataclasses import dataclass, field
from pathlib import Path

from . import isbn as isbn_mod
from . import texto
from .fluxo import abrir_linhas, carregar_json

FONTE = "openlibrary"
LICENCA = "OL-sem-direitos"  # "The Internet Archive does not assert any new copyright…" (LICENCAS.md)


def _registros(caminho: Path, filtro: str | None = None) -> Iterator[tuple[str, dict]]:
    with abrir_linhas(caminho) as linhas:
        for linha in linhas:
            if filtro and filtro not in linha:
                continue
            partes = linha.rstrip("\n").split("\t", 4)
            if len(partes) != 5:
                continue
            try:
                yield partes[1], carregar_json(partes[4])
            except ValueError:
                continue


def autores(caminho: Path) -> Iterator[tuple[str, str]]:
    for chave, j in _registros(caminho):
        nome = texto.limpar(j.get("name") or j.get("personal_name"), 200)
        if nome:
            yield chave, nome


def obras(caminho: Path) -> Iterator[tuple[str, str | None, list[str]]]:
    for chave, j in _registros(caminho):
        autores_ = []
        for a in j.get("authors") or []:
            k = (a.get("author") or {}).get("key") if isinstance(a, dict) else None
            if isinstance(k, str):
                autores_.append(k)
        yield chave, texto.limpar(j.get("title")), autores_[:5]


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


def edicoes(caminho: Path) -> Iterator[Edicao]:
    """Só as edições com ISBN válido (as outras não servem ao scanner)."""
    for chave, j in _registros(caminho, filtro='"isbn_'):
        isbns: list[str] = []
        for bruto in list(j.get("isbn_13") or []) + list(j.get("isbn_10") or []):
            n = isbn_mod.normalizar(bruto)
            if n and n not in isbns:
                isbns.append(n)
        titulo = texto.limpar(j.get("title"))
        if not isbns or not titulo:
            continue
        autores_ = [
            a["key"] for a in (j.get("authors") or []) if isinstance(a, dict) and isinstance(a.get("key"), str)
        ]
        obras_ = [o["key"] for o in (j.get("works") or []) if isinstance(o, dict) and isinstance(o.get("key"), str)]
        editoras = j.get("publishers") or []
        capas = [c for c in (j.get("covers") or []) if isinstance(c, int) and c > 0]
        idiomas = [texto.idioma_ol(x.get("key")) for x in (j.get("languages") or []) if isinstance(x, dict)]
        idiomas = [i for i in idiomas if i]
        pais = j.get("publish_country")
        yield Edicao(
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

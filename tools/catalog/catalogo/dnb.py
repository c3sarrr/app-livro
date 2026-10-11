"""Títulos da Deutsche Nationalbibliothek (CC0 1.0) em N-Triples (`dnb-all_lds.nt.gz`).

As triplas de um mesmo recurso NÃO vêm todas juntas no dump (medido: 62.689 blocos para 39.121
sujeitos nas primeiras 400 mil linhas). Por isso `preparar` filtra só os predicados usados (grep) e
ordena por sujeito (sort externo, em disco); `titulos` lê o arquivo ordenado e fecha um registro
quando o sujeito muda. O texto vem em UTF-8 decomposto (NFD) — `texto.limpar` recompõe em NFC.
"""
from __future__ import annotations

import os
import re
import shutil
import subprocess
import tempfile
from collections.abc import Iterable, Iterator
from dataclasses import dataclass
from pathlib import Path

from . import isbn as isbn_mod
from . import texto
from .fluxo import abrir_linhas

FONTE = "dnb"
LICENCA = "CC0-1.0"

#: predicados usados (o resto é ignorado)
PREDICADOS = {
    "http://purl.org/ontology/bibo/isbn13": "isbn",
    "http://purl.org/ontology/bibo/isbn10": "isbn",
    "http://purl.org/ontology/bibo/isbn": "isbn",
    "http://purl.org/dc/elements/1.1/title": "titulo",
    "http://rdaregistry.info/Elements/u/P60493": "subtitulo",
    "http://rdaregistry.info/Elements/u/P60327": "responsabilidade",
    "http://purl.org/dc/elements/1.1/publisher": "editora",
    "http://purl.org/dc/terms/issued": "ano",
    "http://purl.org/dc/terms/language": "idioma",
    "http://iflastandards.info/ns/isbd/elements/P1053": "extensao",
}

_LINHA = re.compile(r'^(<[^>]*>|_:\S+)\s+<([^>]*)>\s+(.+?)\s*\.\s*$')
_LITERAL = re.compile(r'^"((?:[^"\\]|\\.)*)"(?:@[\w-]+|\^\^<[^>]*>)?$')
_ESCAPE = re.compile(r'\\(u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8}|[tbnrf"\'\\])')
_ISBN_NO_TEXTO = re.compile(r"[0-9][0-9\- ]{8,16}[0-9Xx]")
_SIMPLES = {"t": "\t", "b": "\b", "n": "\n", "r": "\r", "f": "\f", '"': '"', "'": "'", "\\": "\\"}
_PREFIXO_AUTORIA = re.compile(r"^(von|by|hrsg\.? von|herausgegeben von|übers\.? von|ed\.? by|edited by)\s+", re.I)
_COLCHETES = re.compile(r"\[[^\]]*\]?")
# fim de frase depois de uma palavra (não depois de uma inicial: "J. R. R. Tolkien")
_FIM_DE_FRASE = re.compile(r"(?<=\w\w)\.\s+")


def _desescapar(s: str) -> str:
    def troca(m: re.Match[str]) -> str:
        g = m.group(1)
        if g[0] in "uU":
            return chr(int(g[1:], 16))
        return _SIMPLES[g]

    return _ESCAPE.sub(troca, s)


def tripla(linha: str) -> tuple[str, str, str, bool] | None:
    """(sujeito, predicado, objeto, é_literal) ou None."""
    m = _LINHA.match(linha)
    if not m:
        return None
    s, p, o = m.groups()
    lit = _LITERAL.match(o)
    if lit:
        return s, p, _desescapar(lit.group(1)), True
    if o.startswith("<") and o.endswith(">"):
        return s, p, o[1:-1], False
    return s, p, o, False


@dataclass
class Titulo:
    isbns: list[str]
    titulo: str
    subtitulo: str | None
    autores: list[str]  # nomes (da menção de responsabilidade)
    editora: str | None
    ano: int | None
    paginas: int | None
    idioma: str | None


def autores_da_mencao(mencao: str | None) -> list[str]:
    """'Mo Hayder. Dt. von Rainer Schmidt' → ['Mo Hayder']; 'von Anna und Bernd' → ['Anna', 'Bernd']."""
    if not mencao:
        return []
    primeira = _COLCHETES.sub("", mencao).split(";")[0].strip()
    primeira = _PREFIXO_AUTORIA.sub("", primeira)
    primeira = _FIM_DE_FRASE.split(primeira)[0].strip()
    nomes = re.split(r"\s+(?:und|and|e)\s+|,\s+", primeira)
    out = [texto.limpar(re.sub(r"(?<=\w\w)\.\s*$", "", n), 200) for n in nomes]
    return [n for n in out if n][:5]


def _fechar(campos: dict[str, list[str]]) -> Titulo | None:
    isbns: list[str] = []
    for bruto in campos.get("isbn", []):
        for cand in _ISBN_NO_TEXTO.findall(bruto) or [bruto]:
            n = isbn_mod.normalizar(cand)
            if n and n not in isbns:
                isbns.append(n)
    titulo = texto.limpar((campos.get("titulo") or [None])[0])
    if not isbns or not titulo:
        return None
    idioma = None
    for uri in campos.get("idioma", []):
        idioma = texto.idioma_uri(uri)
        if idioma:
            break
    return Titulo(
        isbns=isbns,
        titulo=titulo,
        subtitulo=texto.limpar((campos.get("subtitulo") or [None])[0]),
        autores=autores_da_mencao((campos.get("responsabilidade") or [None])[0]),
        editora=texto.limpar((campos.get("editora") or [None])[0], 200),
        ano=texto.ano((campos.get("ano") or [None])[0]),
        paginas=texto.paginas((campos.get("extensao") or [None])[0]),
        idioma=idioma,
    )


def titulos_de_linhas(linhas: Iterable[str]) -> Iterator[Titulo]:
    atual: str | None = None
    campos: dict[str, list[str]] = {}
    for linha in linhas:
        t = tripla(linha)
        if t is None:
            continue
        s, p, o, _ = t
        if s != atual:
            if campos:
                r = _fechar(campos)
                if r:
                    yield r
            atual, campos = s, {}
        nome = PREDICADOS.get(p)
        if nome:
            campos.setdefault(nome, []).append(o)
    if campos:
        r = _fechar(campos)
        if r:
            yield r


def preparar(caminho_gz: Path, trabalho: Path) -> Path:
    """Triplas dos predicados usados, ordenadas por sujeito (em disco) → `dnb_ordenado.nt`."""
    trabalho.mkdir(parents=True, exist_ok=True)
    destino = trabalho / "dnb_ordenado.nt"
    padroes = trabalho / "dnb_predicados.txt"
    padroes.write_text("".join(f"<{p}>\n" for p in PREDICADOS), encoding="utf-8")
    tmp = trabalho / "sort_tmp"
    tmp.mkdir(exist_ok=True)
    descompactar = shutil.which("pigz") or shutil.which("gzip")
    env = {**os.environ, "LC_ALL": "C"}
    cmd = (
        f"{descompactar} -dc '{caminho_gz}' | grep -F -f '{padroes}' "
        f"| sort -s -k1,1 -S 2G --parallel={max(1, (os.cpu_count() or 2) // 2)} -T '{tmp}' > '{destino}.parte'"
    )
    subprocess.run(["bash", "-o", "pipefail", "-c", cmd], check=True, env=env)
    os.replace(f"{destino}.parte", destino)
    shutil.rmtree(tmp, ignore_errors=True)
    return destino


def titulos(caminho: Path, trabalho: Path | None = None) -> Iterator[Titulo]:
    """Registros da DNB a partir do dump (.gz: prepara antes) ou de um arquivo já ordenado."""
    caminho = Path(caminho)
    if caminho.suffix == ".gz":
        if trabalho is None:
            with tempfile.TemporaryDirectory() as d:
                ordenado = preparar(caminho, Path(d))
                with abrir_linhas(ordenado) as linhas:
                    yield from titulos_de_linhas(linhas)
            return
        caminho = preparar(caminho, trabalho)
    with abrir_linhas(caminho) as linhas:
        yield from titulos_de_linhas(linhas)

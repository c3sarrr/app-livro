"""Camada da borda: todos os ISBNs em arquivos por prefixo (`isbn/v1/<prefixo>.jsonl.gz`).

Prefixo de 7 dígitos; os que passam de `maximo` registros se dividem em prefixos mais longos
(o Worker procura o prefixo mais longo do índice que case com o ISBN). Índice: `isbn/v1/index.json`.
"""
from __future__ import annotations

import hashlib
from pathlib import Path

from .saida import gravar_json, gzip_deterministico, linha_json, registro_json
from .staging import Staging

PREFIXO_INICIAL = 7


def prefixos(st: Staging, maximo: int) -> list[str]:
    finais: list[str] = []
    pendentes = [
        (p, n) for p, n in st.db.execute(
            f"SELECT substr(isbn13, 1, {PREFIXO_INICIAL}), count(*) FROM rec GROUP BY 1 ORDER BY 1"
        )
    ]
    while pendentes:
        p, n = pendentes.pop(0)
        if n <= maximo or len(p) >= 12:
            finais.append(p)
            continue
        filhos = st.db.execute(
            f"SELECT substr(isbn13, 1, {len(p) + 1}), count(*) FROM rec WHERE isbn13 >= ? AND isbn13 < ? "
            "GROUP BY 1 ORDER BY 1",
            (p, p + "￿"),
        ).fetchall()
        pendentes = list(filhos) + pendentes
    return sorted(finais)


def gerar(st: Staging, destino: Path, versao: str, maximo: int = 4000) -> dict:
    base = destino / "isbn" / "v1"
    base.mkdir(parents=True, exist_ok=True)
    lista = prefixos(st, maximo)
    detalhes: dict[str, list] = {}
    total = 0
    idx = 0
    atual: list[bytes] = []

    def fechar(prefixo: str) -> None:
        nonlocal total
        dados = gzip_deterministico(b"".join(atual))
        (base / f"{prefixo}.jsonl.gz").write_bytes(dados)
        detalhes[prefixo] = [len(atual), len(dados), hashlib.sha256(dados).hexdigest()]
        total += len(atual)
        atual.clear()

    for linha in st.registros("ORDER BY isbn13"):
        isbn13 = linha[0]
        while not isbn13.startswith(lista[idx]):
            if atual:
                fechar(lista[idx])
            idx += 1
        atual.append(linha_json(registro_json(linha)))
    if atual:
        fechar(lista[idx])
    indice = {"formato": 1, "versao": versao, "prefixos": [p for p in lista if p in detalhes]}
    gravar_json(base / "index.json", indice)
    gravar_json(base / "shards.json", {"versao": versao, "shards": detalhes})
    return {"shards": len(detalhes), "registros": total, "maior": max((d[0] for d in detalhes.values()), default=0)}


def procurar(destino: Path, isbn13: str) -> dict | None:
    """O mesmo algoritmo do Worker (para testes): prefixo mais longo do índice → linha do ISBN."""
    import gzip
    import json

    base = destino / "isbn" / "v1"
    indice = json.loads((base / "index.json").read_text(encoding="utf-8"))["prefixos"]
    candidatos = [p for p in indice if isbn13.startswith(p)]
    if not candidatos:
        return None
    p = max(candidatos, key=len)
    with gzip.open(base / f"{p}.jsonl.gz", "rt", encoding="utf-8") as f:
        for linha in f:
            r = json.loads(linha)
            if r["i"] == isbn13:
                return r
    return None

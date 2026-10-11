"""Delta entre duas versões do `catalog.db` (atualização mensal sem baixar tudo de novo).

`delta-<de>-<para>.jsonl.gz`: 1ª linha = cabeçalho; depois `{"op":"put","r":{…}}` (inclui ou troca) e
`{"op":"del","i":"978…"}`. O app aplica numa transação e confere `conteudo_sha256` da versão nova.
"""
from __future__ import annotations

import hashlib
import sqlite3
from pathlib import Path

from .catalogo_db import COLUNAS_DB
from .saida import gzip_deterministico, linha_json, registro_json


def gerar(db_antigo: Path, db_novo: Path, de: str, para: str, destino: Path) -> dict:
    con = sqlite3.connect(db_novo)
    con.execute("ATTACH DATABASE ? AS a", (str(db_antigo),))
    cols = ", ".join(f"n.{c}" for c in COLUNAS_DB)
    diferente = " OR ".join(f"n.{c} IS NOT o.{c}" for c in COLUNAS_DB if c != "isbn13")
    puts = con.execute(
        f"SELECT {cols} FROM main.editions n LEFT JOIN a.editions o ON o.isbn13 = n.isbn13 "
        f"WHERE o.isbn13 IS NULL OR {diferente} ORDER BY n.isbn13"
    ).fetchall()
    dels = [r[0] for r in con.execute(
        "SELECT o.isbn13 FROM a.editions o WHERE NOT EXISTS (SELECT 1 FROM main.editions n WHERE n.isbn13 = o.isbn13) "
        "ORDER BY o.isbn13"
    )]
    con.close()
    linhas = [linha_json({"formato": 1, "de": de, "para": para, "put": len(puts), "del": len(dels)})]
    linhas += [linha_json({"op": "put", "r": registro_json(r)}) for r in puts]
    linhas += [linha_json({"op": "del", "i": i}) for i in dels]
    dados = gzip_deterministico(b"".join(linhas))
    caminho = destino / "catalog" / "v1" / para / f"delta-{de}.jsonl.gz"
    caminho.parent.mkdir(parents=True, exist_ok=True)
    caminho.write_bytes(dados)
    return {
        "de": de,
        "path": f"catalog/v1/{para}/delta-{de}.jsonl.gz",
        "bytes": len(dados),
        "sha256": hashlib.sha256(dados).hexdigest(),
        "put": len(puts),
        "del": len(dels),
    }

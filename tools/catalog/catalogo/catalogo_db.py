"""Camada do aparelho: `catalog.db` (SQLite, só leitura no app) com os N livros mais lidos.

Esquema (Anexo 02 §3.3, ampliado): `editions` + FTS5 de título e autores + gatilhos que mantêm o FTS
quando o app aplica um delta + `meta` (versão, contagem, hash do conteúdo).
"""
from __future__ import annotations

import hashlib
import json
import os
import sqlite3
from pathlib import Path

from .saida import gzip_arquivo, sha256_arquivo
from .staging import COLUNAS, Staging

FORMATO = 1

ESQUEMA = """
PRAGMA page_size = 4096;
CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL) WITHOUT ROWID;
CREATE TABLE editions (
  id             INTEGER PRIMARY KEY,
  isbn13         TEXT NOT NULL UNIQUE CHECK (length(isbn13) = 13),
  title          TEXT NOT NULL,
  subtitle       TEXT,
  authors        TEXT NOT NULL,          -- JSON: ["Machado de Assis"]
  publisher      TEXT,
  year           INTEGER,
  pages          INTEGER,
  language       TEXT,                   -- ISO 639-2/B (por, eng, ger…)
  cover_ref      TEXT,                   -- id da capa na fonte (ol:123); a capa não é republicada
  source         TEXT NOT NULL,
  source_license TEXT NOT NULL
);
CREATE VIRTUAL TABLE editions_fts USING fts5(
  title, authors, content='editions', content_rowid='id', tokenize='unicode61 remove_diacritics 2'
);
"""

GATILHOS = """
CREATE TRIGGER editions_ai AFTER INSERT ON editions BEGIN
  INSERT INTO editions_fts(rowid, title, authors) VALUES (new.id, new.title, new.authors);
END;
CREATE TRIGGER editions_ad AFTER DELETE ON editions BEGIN
  INSERT INTO editions_fts(editions_fts, rowid, title, authors) VALUES ('delete', old.id, old.title, old.authors);
END;
CREATE TRIGGER editions_au AFTER UPDATE ON editions BEGIN
  INSERT INTO editions_fts(editions_fts, rowid, title, authors) VALUES ('delete', old.id, old.title, old.authors);
  INSERT INTO editions_fts(rowid, title, authors) VALUES (new.id, new.title, new.authors);
END;
"""

#: colunas de `editions` na ordem de COLUNAS do staging
COLUNAS_DB = ("isbn13", "title", "subtitle", "authors", "publisher", "year", "pages", "language", "cover_ref",
              "source", "source_license")


def hash_conteudo(con: sqlite3.Connection, esquema: str = "main") -> str:
    """sha256 das linhas em ordem de ISBN — o mesmo cálculo que o app faz depois de aplicar um delta."""
    h = hashlib.sha256()
    cols = ", ".join(COLUNAS_DB)
    for linha in con.execute(f"SELECT {cols} FROM {esquema}.editions ORDER BY isbn13"):
        h.update("\x1f".join("" if v is None else str(v) for v in linha).encode())
        h.update(b"\n")
    return h.hexdigest()


def gerar(st: Staging, destino: Path, versao: str, top: int, criado_em: str, fontes: list[dict]) -> dict:
    pasta = destino / "catalog" / "v1" / versao
    pasta.mkdir(parents=True, exist_ok=True)
    db_path = pasta / "catalog.db"
    if db_path.exists():
        db_path.unlink()
    con = sqlite3.connect(db_path)
    con.executescript(ESQUEMA)
    cols = ", ".join(COLUNAS)
    linhas = st.db.execute(
        f"SELECT {cols} FROM (SELECT {cols} FROM rec ORDER BY pontos DESC, isbn13 LIMIT ?) ORDER BY isbn13",
        (top,),
    )
    con.executemany(
        f"INSERT INTO editions ({', '.join(COLUNAS_DB)}) VALUES ({','.join('?' * len(COLUNAS_DB))})", linhas
    )
    con.execute("INSERT INTO editions_fts(editions_fts) VALUES ('rebuild')")
    con.executescript(GATILHOS)
    registros = con.execute("SELECT count(*) FROM editions").fetchone()[0]
    conteudo = hash_conteudo(con)
    meta = {
        "formato": str(FORMATO),
        "versao": versao,
        "criado_em": criado_em,
        "registros": str(registros),
        "conteudo_sha256": conteudo,
        "fontes": json.dumps(fontes, ensure_ascii=False, sort_keys=True),
    }
    con.executemany("INSERT INTO meta VALUES (?, ?)", sorted(meta.items()))
    con.commit()
    con.execute("VACUUM")
    con.close()
    gz = pasta / "catalog.db.gz"
    gzip_arquivo(db_path, gz)
    return {
        "path": f"catalog/v1/{versao}/catalog.db.gz",
        "bytes": os.path.getsize(gz),
        "sha256": sha256_arquivo(gz),
        "db_bytes": os.path.getsize(db_path),
        "db_sha256": sha256_arquivo(db_path),
        "registros": registros,
        "conteudo_sha256": conteudo,
        "local": str(db_path),
    }

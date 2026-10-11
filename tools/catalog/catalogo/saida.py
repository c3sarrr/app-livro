"""Formato dos registros publicados (shards da borda, delta) e gravação determinística."""
from __future__ import annotations

import gzip
import hashlib
import io
import json
from pathlib import Path


def registro_json(linha: tuple) -> dict:
    """Linha de `rec` → JSON compacto do shard/delta (chaves curtas; nulos omitidos)."""
    isbn13, titulo, subtitulo, autores, editora, ano, paginas, idioma, capa, fonte, licenca = linha
    r: dict = {"i": isbn13, "t": titulo, "a": json.loads(autores) if autores else []}
    for k, v in (("s", subtitulo), ("p", editora), ("y", ano), ("n", paginas), ("l", idioma), ("c", capa)):
        if v is not None:
            r[k] = v
    r["f"] = fonte
    r["lic"] = licenca
    return r


def autores_json(autores: list[str]) -> str:
    """Coluna `authors`: JSON compacto, sem escapar o que não é ASCII — byte a byte o que o `jsonEncode`
    do Dart produz ao aplicar um delta no aparelho (o hash do conteúdo tem de fechar dos dois lados)."""
    return json.dumps(autores, ensure_ascii=False, separators=(",", ":"))


def linha_json(obj: dict) -> bytes:
    return (json.dumps(obj, ensure_ascii=False, separators=(",", ":"), sort_keys=True) + "\n").encode()


def gzip_deterministico(dados: bytes) -> bytes:
    """gzip sem data nem nome no cabeçalho: mesma entrada → mesmos bytes (hash reproduzível)."""
    buf = io.BytesIO()
    with gzip.GzipFile(filename="", mode="wb", fileobj=buf, mtime=0, compresslevel=9) as gz:
        gz.write(dados)
    return buf.getvalue()


def gzip_arquivo(origem: Path, destino: Path) -> None:
    with open(origem, "rb") as f, open(destino, "wb") as out:
        with gzip.GzipFile(filename="", mode="wb", fileobj=out, mtime=0, compresslevel=9) as gz:
            while bloco := f.read(1 << 20):
                gz.write(bloco)


def sha256_arquivo(caminho: Path) -> str:
    h = hashlib.sha256()
    with open(caminho, "rb") as f:
        while bloco := f.read(1 << 20):
            h.update(bloco)
    return h.hexdigest()


def gravar_json(caminho: Path, obj) -> None:
    caminho.parent.mkdir(parents=True, exist_ok=True)
    caminho.write_text(json.dumps(obj, ensure_ascii=False, indent=1, sort_keys=True) + "\n", encoding="utf-8")

"""Leitura em fluxo de arquivos .gz grandes (dumps de vários GB) sem carregar tudo na memória."""
from __future__ import annotations

import gzip
import io
import shutil
import subprocess
from collections.abc import Iterator
from contextlib import contextmanager
from pathlib import Path

try:  # orjson é bem mais rápido; json da biblioteca padrão é o reserva
    import orjson as _orjson

    def carregar_json(s: str | bytes):
        return _orjson.loads(s)
except ImportError:  # pragma: no cover - depende do ambiente
    import json as _json

    def carregar_json(s: str | bytes):
        return _json.loads(s)


@contextmanager
def abrir_linhas(caminho: Path) -> Iterator[Iterator[str]]:
    """Linhas de um .gz (via pigz/gzip do sistema quando houver — várias vezes mais rápido)."""
    caminho = Path(caminho)
    if caminho.suffix != ".gz":
        with open(caminho, encoding="utf-8", errors="replace") as f:
            yield f
        return
    prog = shutil.which("pigz") or shutil.which("gzip")
    if prog:
        p = subprocess.Popen([prog, "-dc", str(caminho)], stdout=subprocess.PIPE)
        assert p.stdout is not None
        texto = io.TextIOWrapper(p.stdout, encoding="utf-8", errors="replace")
        try:
            yield texto
        finally:
            texto.close()
            p.kill()
            p.wait()
        return
    with gzip.open(caminho, "rt", encoding="utf-8", errors="replace") as f:  # pragma: no cover
        yield f

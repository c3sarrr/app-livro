"""Leitura em fluxo de arquivos .gz grandes (dumps de vários GB) sem carregar tudo na memória."""
from __future__ import annotations

import gzip
import io
import shutil
import subprocess
from collections.abc import Iterator
from contextlib import contextmanager
from pathlib import Path
from typing import BinaryIO

try:  # orjson é bem mais rápido; json da biblioteca padrão é o reserva
    import orjson as _orjson

    def carregar_json(s: str | bytes):
        return _orjson.loads(s)
except ImportError:  # pragma: no cover - depende do ambiente
    import json as _json

    def carregar_json(s: str | bytes):
        return _json.loads(s)


def _descompressor() -> str | None:
    return shutil.which("pigz") or shutil.which("gzip")


@contextmanager
def _conferindo_fim(p: subprocess.Popen, saida, caminho: Path, prog: str) -> Iterator[None]:
    """Fecha o descompressor. Se quem lia chegou ao fim do fluxo, o código de saída tem de ser 0: um
    .gz cortado (download interrompido, disco cheio) não pode virar um catálogo pela metade em
    silêncio. Parar de ler antes do fim não é erro (o processo é encerrado)."""
    try:
        yield
    except BaseException:
        saida.close()
        p.kill()
        p.wait()
        raise
    no_fim = not saida.read(1)
    saida.close()
    if not no_fim:
        p.kill()
    codigo = p.wait()
    if no_fim and codigo != 0:
        raise RuntimeError(f"{Path(caminho).name}: a descompressão falhou ({Path(prog).name} saiu com {codigo}); "
                           "o arquivo está cortado ou corrompido — baixe de novo")


@contextmanager
def abrir_bytes(caminho: Path) -> Iterator[BinaryIO]:
    """O conteúdo descomprimido de um .gz como fluxo de bytes (pigz/gzip do sistema quando houver)."""
    caminho = Path(caminho)
    if caminho.suffix != ".gz":
        with open(caminho, "rb") as f:
            yield f
        return
    prog = _descompressor()
    if prog:
        p = subprocess.Popen([prog, "-dc", str(caminho)], stdout=subprocess.PIPE, bufsize=1 << 20)
        assert p.stdout is not None
        with _conferindo_fim(p, p.stdout, caminho, prog):
            yield p.stdout
        return
    with gzip.open(caminho, "rb") as f:  # pragma: no cover - o gzip do Python já acusa o arquivo cortado
        yield f


def blocos(f: BinaryIO, tamanho: int) -> Iterator[bytes]:
    """Blocos de ~`tamanho` bytes que sempre terminam numa quebra de linha (linha nunca dividida)."""
    resto = b""
    while True:
        dados = f.read(tamanho)
        if not dados:
            if resto:
                yield resto
            return
        dados = resto + dados
        corte = dados.rfind(b"\n")
        if corte < 0:
            resto = dados
            continue
        yield dados[: corte + 1]
        resto = dados[corte + 1 :]


@contextmanager
def abrir_linhas(caminho: Path) -> Iterator[Iterator[str]]:
    """Linhas de um .gz (via pigz/gzip do sistema quando houver — várias vezes mais rápido)."""
    caminho = Path(caminho)
    if caminho.suffix != ".gz":
        with open(caminho, encoding="utf-8", errors="replace") as f:
            yield f
        return
    prog = _descompressor()
    if prog:
        p = subprocess.Popen([prog, "-dc", str(caminho)], stdout=subprocess.PIPE)
        assert p.stdout is not None
        texto = io.TextIOWrapper(p.stdout, encoding="utf-8", errors="replace")
        with _conferindo_fim(p, texto, caminho, prog):
            yield texto
        return
    with gzip.open(caminho, "rt", encoding="utf-8", errors="replace") as f:  # pragma: no cover
        yield f

"""Regera test/fixtures/catalogo (o catálogo de teste do app) a partir dos dumps de amostra.

Uso: python3 tools/catalog/gerar_fixture_app.py   (da raiz do repositório ou de tools/catalog)
Determinístico: os mesmos bytes a cada execução (o teste do app confere os hashes do manifesto).
"""
from __future__ import annotations

import shutil
import sys
import tempfile
from argparse import Namespace
from pathlib import Path

AQUI = Path(__file__).resolve().parent
sys.path.insert(0, str(AQUI))
sys.path.insert(0, str(AQUI / "tests"))

from catalogo import pipeline  # noqa: E402
from conftest import escrever_dumps  # noqa: E402

ARQUIVOS = [
    "catalog/v1/2026-09-30.1/catalog.db.gz",
    "catalog/v1/2026-09-30.1/manifest.json",
    "catalog/v1/2026-10-31.1/catalog.db.gz",
    "catalog/v1/2026-10-31.1/manifest.json",
    "catalog/v1/2026-10-31.1/delta-2026-09-30.1.jsonl.gz",
]


def main() -> None:
    destino = AQUI.parent.parent / "test" / "fixtures" / "catalogo"
    with tempfile.TemporaryDirectory() as t:
        base = Path(t)
        for variante, data in ((1, "2026-09-30"), (2, "2026-10-31")):
            dumps = escrever_dumps(base / f"d{variante}", variante, data)
            pipeline.executar(Namespace(
                dumps=str(dumps), trabalho=str(base / f"t{variante}"), saida=str(base / "publicar"), top=50,
                peso_br=3, max_shard=2, revisao=1, deltas=3, sem_dnb=False, hash_dumps=False))
        for a in ARQUIVOS:
            (destino / a).parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(base / "publicar" / a, destino / a)
    print(f"fixture em {destino}")


if __name__ == "__main__":
    main()

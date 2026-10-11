"""Executa o pipeline: python -m catalogo.pipeline --dumps DIR --trabalho DIR --saida DIR [--top N]

Estágios do banco de trabalho (retomáveis: o que já foi feito é pulado): autores → obras →
popularidade → edições do Open Library → DNB → união. Depois, sempre: shards, catalog.db, deltas
(contra as versões anteriores encontradas em --saida) e o manifesto.
"""
from __future__ import annotations

import argparse
import re
import shutil
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

from . import catalogo_db, delta, shards
from .saida import gravar_json, sha256_arquivo
from .staging import Staging

LICENCAS = {
    "openlibrary": "Open Library — \"The Internet Archive does not assert any new copyright\" (LICENCAS.md)",
    "dnb": "CC0 1.0 (Deutsche Nationalbibliothek)",
}


def _mais_recente(pasta: Path, padrao: str) -> Path | None:
    achados = sorted(pasta.glob(padrao))
    return achados[-1] if achados else None


def _data(arquivo: Path) -> str:
    m = re.search(r"(\d{4}-\d{2}-\d{2})", arquivo.name)
    if m:
        return m.group(1)
    return datetime.fromtimestamp(arquivo.stat().st_mtime, timezone.utc).strftime("%Y-%m-%d")


def _log(msg: str) -> None:
    print(f"[{datetime.now(timezone.utc).strftime('%H:%M:%S')}] {msg}", flush=True)


def executar(args: argparse.Namespace) -> dict:
    dumps = Path(args.dumps)
    ol = {t: _mais_recente(dumps, f"ol_dump_{t}_*.txt.gz") for t in ("authors", "works", "editions", "ratings",
                                                                   "reading-log")}
    dnb_arq = None if args.sem_dnb else _mais_recente(dumps, "dnb-all_lds.nt.gz")
    if not ol["editions"]:
        raise SystemExit(f"sem o dump de edições do Open Library em {dumps}")
    data_ol = _data(ol["editions"])
    versao = f"{data_ol}.{args.revisao}"
    criado_em = f"{data_ol}T00:00:00Z"

    st = Staging(Path(args.trabalho) / "staging.db")
    for nome in getattr(args, "refazer", None) or []:
        _log(f"refazer {nome}: {', '.join(st.desfazer(nome))}")

    def assinatura(*arqs: Path | None) -> list:
        # o mesmo banco de trabalho com dumps novos (mês seguinte) refaz o que mudou — achado 2 da revisão
        return [[a.name, a.stat().st_size] for a in arqs if a]

    entradas = {
        "autores": assinatura(ol["authors"]),
        "obras": assinatura(ol["works"]),
        "popularidade": assinatura(ol["ratings"], ol["reading-log"]),
        "edicoes_ol": assinatura(ol["editions"]),
        "dnb": assinatura(dnb_arq),
        "unir": {"peso_br": args.peso_br},
    }
    for nome, sig in entradas.items():
        if st.feito(nome) and st.assinatura(nome) != sig:
            _log(f"{nome}: entradas mudaram — refazer {', '.join(st.desfazer(nome))}")
    t0 = time.time()
    estagios = [
        ("autores", lambda: st.carregar_autores(ol["authors"]) if ol["authors"] else 0),
        ("obras", lambda: st.carregar_obras(ol["works"]) if ol["works"] else 0),
        ("popularidade", lambda: st.carregar_popularidade(ol["ratings"], ol["reading-log"])),
        ("edicoes_ol", lambda: st.carregar_edicoes_ol(ol["editions"])),
        ("dnb", lambda: st.carregar_dnb(dnb_arq, Path(args.trabalho)) if dnb_arq else 0),
        ("unir", lambda: st.unir(args.peso_br)),
    ]
    for nome, f in estagios:
        if st.feito(nome):
            _log(f"{nome}: já feito")
            continue
        _log(f"{nome}…")
        st.limpar_estagio(nome)
        r = f()
        st.marcar(nome, {"resultado": r, "assinatura": entradas[nome]})
        _log(f"{nome}: {r} ({time.time() - t0:.0f} s)")

    saida = Path(args.saida)
    fontes = []
    for nome, arqs in (("openlibrary", [a for a in ol.values() if a]), ("dnb", [dnb_arq] if dnb_arq else [])):
        if not arqs:
            continue
        fontes.append({
            "fonte": nome,
            "licenca": LICENCAS[nome],
            "arquivos": [{"nome": a.name, "data": _data(a), "sha256": sha256_arquivo(a) if args.hash_dumps else None}
                         for a in arqs],
        })

    _log("shards…")
    info_shards = shards.gerar(st, saida, versao, args.max_shard)
    _log(f"shards: {info_shards}")
    _log("catalog.db…")
    info_db = catalogo_db.gerar(st, saida, versao, args.top, criado_em, fontes)
    _log(f"catalog.db: {info_db['registros']} registros, {info_db['bytes']} bytes comprimido")

    deltas = []
    raiz = saida / "catalog" / "v1"
    anteriores = sorted(p.name for p in raiz.iterdir() if p.is_dir() and p.name != versao and (p / "catalog.db").exists())
    for de in anteriores[-args.deltas:]:
        _log(f"delta {de} → {versao}…")
        deltas.append(delta.gerar(raiz / de / "catalog.db", Path(info_db["local"]), de, versao, saida))
    manifesto = {
        "formato": 1,
        "versao": versao,
        "criado_em": criado_em,
        "db": {k: v for k, v in info_db.items() if k != "local"},
        "deltas": deltas,
        "shards": {"index": "isbn/v1/index.json", **info_shards},
        "fontes": fontes,
        "parametros": {"top": args.top, "peso_br": args.peso_br, "max_shard": args.max_shard},
    }
    gravar_json(raiz / versao / "manifest.json", manifesto)
    shutil.copyfile(raiz / versao / "manifest.json", raiz / "manifest.json")
    st.fechar()
    _log(f"pronto: versão {versao} ({time.time() - t0:.0f} s)")
    return manifesto


def main(argv: list[str] | None = None) -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--dumps", required=True)
    p.add_argument("--trabalho", required=True)
    p.add_argument("--saida", required=True)
    p.add_argument("--top", type=int, default=600_000)
    p.add_argument("--peso-br", type=int, default=3)
    p.add_argument("--max-shard", type=int, default=4000)
    p.add_argument("--revisao", type=int, default=1)
    p.add_argument("--deltas", type=int, default=3, help="quantas versões anteriores ganham delta")
    p.add_argument("--sem-dnb", action="store_true")
    p.add_argument("--refazer", type=lambda s: [x for x in s.split(",") if x], default=[],
                   help="estágios a refazer, ex.: dnb (a DNB chegou depois de uma execução --sem-dnb)")
    p.add_argument("--hash-dumps", action=argparse.BooleanOptionalAction, default=True)
    executar(p.parse_args(argv))


if __name__ == "__main__":
    sys.exit(main())

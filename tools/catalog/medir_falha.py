"""G07.6 — taxa de falha final da busca por ISBN, camada por camada, com amostra real estratificada.

Estratos (fontes independentes do Open Library):
  br       — os ISBN brasileiros do spike S6 (Wikidata, 978-85/978-65) — mesma amostra do ADR-008;
  popular  — edições (Wikidata P212) de obras com 20+ artigos na Wikipédia, fora do Brasil;
  cauda    — edições de obras com 1 a 3 artigos na Wikipédia, fora do Brasil.
Camadas, na ordem do app (Anexo 02 §7, D-73): catalog.db (top-N do aparelho) → shards da borda (o
catálogo aberto inteiro) → APIs pela região do ISBN (BrasilAPI: Brasil = CBL + Mercado Editorial, depois
Open Library + Google Books; resto = Open Library + Google Books). A comunidade começa vazia.

Uso (Ubuntu do WSL, com internet; precisa de uma saída do pipeline):
  python3 medir_falha.py --saida /root/booknest_catalogo/publicar \\
      --amostra-br ../../spikes/S6_catalogo_isbn/dados/amostra_isbn.json \\
      --resultado ../../docs/progresso/medicao_g07/falha_isbn.json [--n 150]
Só biblioteca padrão.
"""
from __future__ import annotations

import argparse
import json
import random
import sqlite3
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from catalogo import shards  # noqa: E402
from catalogo.isbn import eh_brasil, normalizar  # noqa: E402

UA = {"User-Agent": "BookNest-G07/0.1 (medicao de cobertura de ISBN; projeto app livros)"}
SEMENTE = 20261005

SPARQL = """
SELECT ?isbn WHERE {{
  ?ed wdt:P212 ?isbn ; wdt:P629 ?obra .
  ?obra wikibase:sitelinks ?n .
  FILTER(?n >= {min} && ?n <= {max})
  FILTER(!STRSTARTS(?isbn, "978-85") && !STRSTARTS(?isbn, "978-65"))
}}
ORDER BY ?isbn
LIMIT 30000
"""


def pegar(url: str, tentativas: int = 3, espera: float = 2.0) -> tuple[int, object]:
    for i in range(tentativas):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60) as r:
                return r.status, json.loads(r.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            if e.code in (400, 404) or i == tentativas - 1:
                return e.code, None
        except Exception:  # noqa: BLE001 — rede: tenta de novo
            if i == tentativas - 1:
                return 0, None
        time.sleep(espera * (i + 1))
    return 0, None


def amostra_wikidata(minimo: int, maximo: int, n: int) -> tuple[list[str], int]:
    url = "https://query.wikidata.org/sparql?" + urllib.parse.urlencode(
        {"query": SPARQL.format(min=minimo, max=maximo), "format": "json"})
    st, j = pegar(url)
    isbns = set()
    for b in (j or {}).get("results", {}).get("bindings", []):
        i = normalizar(b["isbn"]["value"])
        if i and not eh_brasil(i):
            isbns.add(i)
    print(f"wikidata sitelinks {minimo}-{maximo}: HTTP {st}, {len(isbns)} ISBN distintos", flush=True)
    if not isbns:  # tempo esgotado no Wikidata: não mede um estrato vazio sem avisar
        raise SystemExit(f"amostra vazia do Wikidata (sitelinks {minimo}-{maximo}, HTTP {st}) — rode de novo")
    chaves = sorted(isbns)
    random.Random(SEMENTE).shuffle(chaves)
    return chaves[:n], len(isbns)


def brasilapi(isbn: str, provedores: list[str]) -> tuple[bool, str | None, int]:
    url = f"https://brasilapi.com.br/api/isbn/v1/{isbn}?providers={','.join(provedores)}"
    st, j = pegar(url)
    achou = st == 200 and bool((j or {}).get("title"))
    return achou, (j or {}).get("provider") if achou else None, st


def medir(isbns: list[str], saida: Path, db: sqlite3.Connection) -> list[dict]:
    linhas = []
    for k, isbn in enumerate(isbns):
        no_db = db.execute("SELECT 1 FROM editions WHERE isbn13 = ?", (isbn,)).fetchone() is not None
        no_shard = shards.procurar(saida, isbn) is not None
        tentativas = []
        api, provedor, erro_api = False, None, False
        ordem = [["cbl", "mercado-editorial"], ["open-library", "google-books"]] if eh_brasil(isbn) \
            else [["open-library", "google-books"]]
        for provs in ordem:
            achou, prov, st = brasilapi(isbn, provs)
            tentativas.append({"provedores": ",".join(provs), "status": st})
            time.sleep(0.4)
            if achou:
                api, provedor = True, prov
                break
            # 404/400 = não achou de verdade; o resto (429, 5xx, rede) = a medida ficou indeterminada
            erro_api = erro_api or st not in (200, 400, 404)
        linhas.append({"isbn": isbn, "catalog_db": no_db, "shards": no_shard, "api": api,
                       "api_provedor": provedor, "api_erro": erro_api and not api, "api_tentativas": tentativas})
        if k % 25 == 0:
            print(f"  {k}/{len(isbns)}", flush=True)
    return linhas


def resumir(linhas: list[dict]) -> dict:
    n = len(linhas)
    if n == 0:
        return {"n": 0}
    db = sum(l["catalog_db"] for l in linhas)
    borda = sum(l["catalog_db"] or l["shards"] for l in linhas)
    final = sum(l["catalog_db"] or l["shards"] or l["api"] for l in linhas)
    provs: dict[str, int] = {}
    for l in linhas:
        if l["api"] and not (l["catalog_db"] or l["shards"]):
            provs[l["api_provedor"] or "?"] = provs.get(l["api_provedor"] or "?", 0) + 1
    return {
        "n": n,
        "aparelho_catalog_db": {"acertos": db, "taxa_falha": round(1 - db / n, 3)},
        "gratis_aparelho_mais_borda": {"acertos": borda, "taxa_falha": round(1 - borda / n, 3)},
        "final_com_apis": {"acertos": final, "taxa_falha": round(1 - final / n, 3)},
        "apis_usadas_no_resto_por_provedor": provs,
        "consultas_externas_por_100_leituras": round(100 * (n - borda) / n, 1),
        # sem resposta conclusiva das APIs (429, 5xx, rede): contados como falha acima — a taxa real é
        # no máximo `taxa_falha` e no mínimo `taxa_falha - indeterminados / n`
        "indeterminados_api": sum(1 for l in linhas if l.get("api_erro") and not (l["catalog_db"] or l["shards"])),
    }


def main(argv: list[str] | None = None) -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--saida", required=True, help="pasta de saída do pipeline (shards e catalog/v1)")
    p.add_argument("--amostra-br", required=True)
    p.add_argument("--resultado", required=True)
    p.add_argument("--n", type=int, default=150, help="ISBNs por estrato internacional")
    a = p.parse_args(argv)
    saida = Path(a.saida)
    manifesto = json.loads((saida / "catalog" / "v1" / "manifest.json").read_text(encoding="utf-8"))
    db = sqlite3.connect(f"file:{saida / 'catalog' / 'v1' / manifesto['versao'] / 'catalog.db'}?mode=ro", uri=True)

    br = [l["isbn"] for l in json.loads(Path(a.amostra_br).read_text(encoding="utf-8"))["linhas"]]
    br = [i for i in (normalizar(x) for x in br) if i]
    pop, universo_pop = amostra_wikidata(20, 100000, a.n)
    cauda, universo_cauda = amostra_wikidata(1, 3, a.n)
    estratos = {"br": (br, len(br)), "popular": (pop, universo_pop), "cauda": (cauda, universo_cauda)}

    resultado = {"data": time.strftime("%Y-%m-%d"), "catalogo": manifesto["versao"],
                 "catalog_db_registros": manifesto["db"]["registros"], "estratos": {}}
    for nome, (isbns, universo) in estratos.items():
        print(f"{nome}: {len(isbns)} ISBNs", flush=True)
        linhas = medir(isbns, saida, db)
        resultado["estratos"][nome] = {"universo": universo, "resumo": resumir(linhas), "linhas": linhas}
    todas = [l for e in resultado["estratos"].values() for l in e["linhas"]]
    resultado["total"] = resumir(todas)
    Path(a.resultado).parent.mkdir(parents=True, exist_ok=True)
    Path(a.resultado).write_text(json.dumps(resultado, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(json.dumps({k: v["resumo"] for k, v in resultado["estratos"].items()} | {"total": resultado["total"]},
                     ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()

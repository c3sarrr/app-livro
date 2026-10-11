"""G07.6 — taxa de falha final da busca por ISBN, camada por camada, com amostra real estratificada.

Estratos (fontes independentes do Open Library):
  br       — os ISBN brasileiros do spike S6 (Wikidata, 978-85/978-65) — mesma amostra do ADR-008;
  popular  — edições (Wikidata P212) de obras com 20+ artigos na Wikipédia, fora do Brasil;
  cauda    — edições de obras com 1 a 3 artigos na Wikipédia, fora do Brasil.
Camadas, na ordem do app (Anexo 02 §7, D-73): catalog.db (top-N do aparelho) → shards da borda (o
catálogo aberto inteiro) → APIs pela região do ISBN, as mesmas da Edge Function `isbn-lookup` e só para o
que o catálogo aberto não tem (como no app): Brasil = BrasilAPI com CBL + Mercado Editorial, depois com
Open Library + Google Books; resto = API do Open Library, depois Google Books (a BrasilAPI responde 400
"ISBN inválido" para ISBN de fora do Brasil). Hardcover e ISBNdb ficam de fora (precisam de chave). A
comunidade começa vazia. 400/429/5xx/rede de uma API = medida indeterminada, nunca "não achou".

Uso (Ubuntu do WSL, com internet; precisa de uma saída do pipeline):
  python3 medir_falha.py --saida /root/booknest_catalogo/publicar \\
      --amostra-br ../../spikes/S6_catalogo_isbn/dados/amostra_isbn.json \\
      --resultado ../../docs/progresso/medicao_g07/falha_isbn.json [--n 150]
Só biblioteca padrão.
"""
from __future__ import annotations

import argparse
import json
import os
import random
import sqlite3
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from collections.abc import Callable
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from catalogo import shards  # noqa: E402
from catalogo.isbn import eh_brasil, normalizar, para_isbn10  # noqa: E402

UA = {"User-Agent": "BookNest-G07/0.1 (medicao de cobertura de ISBN; projeto app livros)"}
SEMENTE = 20261005

LIMITE = 30000
_FILTRO = """
  ?ed wdt:P212 ?isbn ; wdt:P629 ?obra .
  ?obra wikibase:sitelinks ?n .
  FILTER(?n >= {min} && ?n <= {max})
  FILTER(!STRSTARTS(?isbn, "978-85") && !STRSTARTS(?isbn, "978-65"))
"""
# ordem sorteada (hash com semente), não a do texto do ISBN: com o LIMIT, "ORDER BY ?isbn" deixava só 978-0/978-1
# e nenhum 979 no estrato da cauda (revisão 2, achado 2)
SPARQL = ("SELECT ?isbn WHERE {{" + _FILTRO + "}}\n"
          f'ORDER BY MD5(CONCAT(STR(?isbn), "{SEMENTE}"))\nLIMIT {LIMITE}')
SPARQL_TOTAL = "SELECT (COUNT(DISTINCT ?isbn) AS ?total) WHERE {{" + _FILTRO + "}}"


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


def _sparql(consulta: str) -> tuple[int, object]:
    return pegar("https://query.wikidata.org/sparql?" + urllib.parse.urlencode({"query": consulta, "format": "json"}))


def amostra_wikidata(minimo: int, maximo: int, n: int) -> tuple[list[str], dict]:
    """(amostra de n ISBNs, universo): a amostra sai de até LIMITE edições sorteadas pelo próprio Wikidata."""
    st, j = _sparql(SPARQL.format(min=minimo, max=maximo))
    linhas = (j or {}).get("results", {}).get("bindings", [])
    isbns = set()
    for b in linhas:
        i = normalizar(b["isbn"]["value"])
        if i and not eh_brasil(i):
            isbns.add(i)
    st_t, jt = _sparql(SPARQL_TOTAL.format(min=minimo, max=maximo))
    total = int(((jt or {}).get("results", {}).get("bindings") or [{}])[0].get("total", {}).get("value", -1))
    print(f"wikidata sitelinks {minimo}-{maximo}: HTTP {st}/{st_t}, {len(linhas)} linhas sorteadas de {total}, "
          f"{len(isbns)} ISBN distintos", flush=True)
    if not isbns:  # tempo esgotado no Wikidata: não mede um estrato vazio sem avisar
        raise SystemExit(f"amostra vazia do Wikidata (sitelinks {minimo}-{maximo}, HTTP {st}) — rode de novo")
    chaves = sorted(isbns)
    random.Random(SEMENTE).shuffle(chaves)
    return chaves[:n], {"isbns_sorteados": len(isbns), "edicoes_no_wikidata": total,
                        "sorteio_cortado_em": LIMITE if len(linhas) >= LIMITE else None}


def brasilapi(isbn: str, provedores: list[str]) -> tuple[bool, str | None, int]:
    url = f"https://brasilapi.com.br/api/isbn/v1/{isbn}?providers={','.join(provedores)}"
    st, j = pegar(url)
    achou = st == 200 and bool((j or {}).get("title"))
    # 200 sem título = "não achou", como na Edge Function (revisão 2, achado 8)
    return achou, (j or {}).get("provider") if achou else None, st if achou or st != 200 else 404


def openlibrary_api(isbn: str) -> tuple[bool, str | None, int]:
    st, j = pegar(f"https://openlibrary.org/api/books?bibkeys=ISBN:{isbn}&format=json&jscmd=data")
    achou = st == 200 and bool(((j or {}).get(f"ISBN:{isbn}") or {}).get("title"))
    # 200 sem o livro = não achou (a API responde {}): devolve 404 para contar como "não achou"
    return achou, "openlibrary" if achou else None, st if achou or st != 200 else 404


GOOGLE_BOOKS_KEY = os.environ.get("GOOGLE_BOOKS_KEY")  # sem chave o Google responde 429: fica de fora (como no app)


def google_books(isbn: str) -> tuple[bool, str | None, int]:
    chave = f"&key={urllib.parse.quote(GOOGLE_BOOKS_KEY)}" if GOOGLE_BOOKS_KEY else ""
    st, j = pegar(f"https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}&maxResults=10{chave}")
    dez = para_isbn10(isbn)

    def tem_o_isbn(v: dict) -> bool:
        ids = {str(x.get("identifier", "")).upper() for x in v.get("industryIdentifiers") or [] if isinstance(x, dict)}
        return bool(v.get("title")) and (isbn in ids or (dez is not None and dez in ids))

    volumes = [i.get("volumeInfo") or {} for i in (j or {}).get("items") or [] if isinstance(i, dict)]
    achou = st == 200 and any(tem_o_isbn(v) for v in volumes)
    return achou, "googlebooks" if achou else None, st if achou or st != 200 else 404


def fontes_externas(isbn: str) -> list[tuple[str, Callable[[], tuple[bool, str | None, int]]]]:
    """As fontes da Edge Function `isbn-lookup`, na ordem dela (sem as que precisam de chave)."""
    if eh_brasil(isbn):
        return [("brasilapi:br", lambda: brasilapi(isbn, ["cbl", "mercado-editorial"])),
                ("brasilapi:global", lambda: brasilapi(isbn, ["open-library", "google-books"]))]
    fontes = [("openlibrary", lambda: openlibrary_api(isbn))]
    if GOOGLE_BOOKS_KEY:
        fontes.append(("googlebooks", lambda: google_books(isbn)))
    return fontes


def medir(isbns: list[str], saida: Path, db: sqlite3.Connection) -> list[dict]:
    linhas = []
    for k, isbn in enumerate(isbns):
        no_db = db.execute("SELECT 1 FROM editions WHERE isbn13 = ?", (isbn,)).fetchone() is not None
        no_shard = shards.procurar(saida, isbn) is not None
        tentativas = []
        api, provedor, erro_api = False, None, False
        if not (no_db or no_shard):  # como no app: a camada externa só para o que o catálogo aberto não tem
            for nome, consultar in fontes_externas(isbn):
                achou, prov, st = consultar()
                tentativas.append({"fonte": nome, "status": st})
                time.sleep(0.4)
                if achou:
                    api, provedor = True, prov
                    break
                # 404 = não achou de verdade; o resto (400, 429, 5xx, rede) = a medida ficou indeterminada
                erro_api = erro_api or st != 404
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
    estratos = {"br": (br, {"isbns": len(br), "origem": "amostra do spike S6 (Wikidata, 978-85/978-65)"}),
                "popular": (pop, universo_pop), "cauda": (cauda, universo_cauda)}

    resultado = {"data": time.strftime("%Y-%m-%d"), "catalogo": manifesto["versao"],
                 "catalog_db_registros": manifesto["db"]["registros"], "estratos": {}}
    for nome, (isbns, universo) in estratos.items():
        print(f"{nome}: {len(isbns)} ISBNs", flush=True)
        linhas = medir(isbns, saida, db)
        resultado["estratos"][nome] = {"universo": universo, "resumo": resumir(linhas), "linhas": linhas}
    # os estratos têm frações de amostragem muito diferentes: a soma não é uma taxa do catálogo (só referência)
    todas = [l for e in resultado["estratos"].values() for l in e["linhas"]]
    resultado["total_nao_ponderado"] = resumir(todas)
    Path(a.resultado).parent.mkdir(parents=True, exist_ok=True)
    Path(a.resultado).write_text(json.dumps(resultado, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    resumos = {k: v["resumo"] for k, v in resultado["estratos"].items()}
    print(json.dumps(resumos | {"total_nao_ponderado": resultado["total_nao_ponderado"]},
                     ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()

"""G02 · prova do ADR-008 — taxa de falha da busca por ISBN com uma amostra real de livros brasileiros.

Amostra: ISBN-13 de editoras brasileiras (prefixos 978-65 e 978-85) tirados do Wikidata (edições com
ISBN-13, sorteio determinístico) — fonte independente do Open Library. (O Google Books sem chave
respondeu 429 a todas as buscas em 03/10/2026; o código continua aqui como alternativa.) Para cada ISBN:
  * Open Library (/isbn/{isbn}.json) — mesma base dos dumps CC0 que alimentam o catálogo próprio (camadas 2–3);
  * BrasilAPI (/api/isbn/v1/{isbn}) — 1ª API externa da camada 5 (agrega CBL, Mercado Editorial, Open Library
    e Google Books — por isso tende a achar o que veio do Google; viés registrado no ADR).
Só biblioteca padrão. Uso (precisa de internet): python3 amostra_isbn.py dados/amostra_isbn.json
"""
import json
import random
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

UA = {'User-Agent': 'BookNest-spike-G02/0.1 (avaliacao de cobertura de ISBN; contato: projeto app livros)'}
CONSULTAS = [
    'romance', 'história do brasil', 'receitas culinária', 'autoajuda', 'literatura infantil', 'fantasia',
    'biografia', 'poesia', 'direito civil', 'medicina', 'administração', 'religião', 'ficção científica',
    'contos', 'educação', 'psicologia', 'filosofia', 'economia', 'arte', 'música', 'esporte', 'política',
    'crônicas', 'suspense', 'didático matemática', 'quadrinhos', 'jovem adulto', 'negócios', 'saúde',
    'machado de assis',
]


def pegar(url, tentativas=3):
    for i in range(tentativas):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=20) as r:
                return r.status, json.loads(r.read().decode('utf-8'))
        except urllib.error.HTTPError as e:
            if e.code in (404, 400):
                return e.code, None
            if i == tentativas - 1:
                return e.code, None
        except Exception:
            if i == tentativas - 1:
                return 0, None
        time.sleep(2 * (i + 1))
    return 0, None


def amostra(n_max):
    isbns = {}
    for q in CONSULTAS:
        url = ('https://www.googleapis.com/books/v1/volumes?' +
               urllib.parse.urlencode({'q': q, 'langRestrict': 'pt', 'printType': 'books', 'maxResults': 40}))
        st, j = pegar(url)
        for it in (j or {}).get('items', []):
            for ident in it.get('volumeInfo', {}).get('industryIdentifiers', []):
                v = ident.get('identifier', '')
                if ident.get('type') == 'ISBN_13' and (v.startswith('97865') or v.startswith('97885')):
                    isbns.setdefault(v, {'consulta': q, 'titulo_google': it['volumeInfo'].get('title')})
        print(f'google "{q}": {st}, acumulado {len(isbns)}', flush=True)
        time.sleep(1)
    chaves = sorted(isbns)
    random.Random(20261003).shuffle(chaves)
    return {k: isbns[k] for k in chaves[:n_max]}


SPARQL = """
SELECT ?isbn ?titulo WHERE {
  ?ed wdt:P212 ?isbn .
  FILTER(STRSTARTS(?isbn, "978-65") || STRSTARTS(?isbn, "978-85"))
  OPTIONAL { ?ed rdfs:label ?titulo . FILTER(LANG(?titulo) = "pt" || LANG(?titulo) = "pt-br") }
}
LIMIT 20000
"""


def amostra_wikidata(n_max):
    url = 'https://query.wikidata.org/sparql?' + urllib.parse.urlencode({'query': SPARQL, 'format': 'json'})
    st, j = pegar(url)
    print(f'wikidata: {st}', flush=True)
    isbns = {}
    for b in (j or {}).get('results', {}).get('bindings', []):
        v = b['isbn']['value'].replace('-', '').strip()
        if len(v) == 13 and v.isdigit():
            isbns.setdefault(v, {'consulta': 'wikidata', 'titulo_wikidata': b.get('titulo', {}).get('value')})
    print(f'wikidata: {len(isbns)} ISBN-13 brasileiros distintos', flush=True)
    chaves = sorted(isbns)
    random.Random(20261003).shuffle(chaves)
    return {k: isbns[k] for k in chaves[:n_max]}, len(isbns)


def main(saida, n_max=300, fonte='wikidata'):
    if fonte == 'google':
        base, universo = amostra(n_max), None
    else:
        base, universo = amostra_wikidata(n_max)
    linhas = []
    for i, (isbn, info) in enumerate(base.items()):
        st_ol, ol = pegar(f'https://openlibrary.org/isbn/{isbn}.json')
        time.sleep(0.4)
        st_br, br = pegar(f'https://brasilapi.com.br/api/isbn/v1/{isbn}')
        time.sleep(0.4)
        linhas.append({
            'isbn': isbn, **info,
            'openlibrary': st_ol == 200, 'openlibrary_titulo': (ol or {}).get('title'),
            'brasilapi': st_br == 200, 'brasilapi_titulo': (br or {}).get('title'),
            'brasilapi_provedor': (br or {}).get('provider'), 'status': [st_ol, st_br],
        })
        if i % 25 == 0:
            print(f'{i}/{len(base)}', flush=True)
    n = len(linhas)
    ol = sum(l['openlibrary'] for l in linhas)
    br = sum(l['brasilapi'] for l in linhas)
    um = sum(l['openlibrary'] or l['brasilapi'] for l in linhas)
    prov = {}
    for l in linhas:
        if l['brasilapi']:
            prov[l['brasilapi_provedor']] = prov.get(l['brasilapi_provedor'], 0) + 1
    por_prefixo = {}
    for pfx in ('97865', '97885'):
        ls = [l for l in linhas if l['isbn'].startswith(pfx)]
        if ls:
            por_prefixo[pfx] = {'n': len(ls), 'openlibrary': sum(l['openlibrary'] for l in ls),
                                'brasilapi': sum(l['brasilapi'] for l in ls)}
    resumo = {
        'data': time.strftime('%Y-%m-%d'), 'fonte_da_amostra': fonte, 'universo': universo, 'amostra': n,
        'openlibrary_acertos': ol, 'openlibrary_taxa_falha': round(1 - ol / n, 3),
        'brasilapi_acertos': br, 'brasilapi_taxa_falha': round(1 - br / n, 3),
        'uniao_acertos': um, 'uniao_taxa_falha': round(1 - um / n, 3),
        'brasilapi_por_provedor': prov, 'por_prefixo': por_prefixo,
        'erros_de_rede': sum(1 for l in linhas if 0 in l['status']),
    }
    json.dump({'resumo': resumo, 'linhas': linhas}, open(saida, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(json.dumps(resumo, ensure_ascii=False, indent=1))


if __name__ == '__main__':
    main(sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 300, sys.argv[3] if len(sys.argv) > 3 else 'wikidata')

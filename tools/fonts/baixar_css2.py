#!/usr/bin/env python3
"""T13.2 (D-273) — baixa do Google Fonts o que as telas do projeto pedem e o arquivo antigo não traz.

1. As respostas do `css2` para as consultas das telas de um índice (`tools/medicao/pranchas_projeto.json`), como o
   Chrome as recebe (User-Agent de Chrome no Windows → `woff2` por subconjunto), em
   `tools/fonts/css2_projeto/<nome>.css`; a lista com URL, sha256 e data em `css2_projeto/consultas.json`.
2. Os binários das famílias que a tabela (`tools/medicao/fontes_css2.json`) não tem — na T13, só a Roboto 500 da 07 —
   nos subconjuntos latin, latin-ext e vietnamita (os que o app usa), em `tools/fonts/originais_v2/` com URL, família,
   estilo, subconjunto, pesos, sha256 e bytes no `manifesto.json`.
Nada mais é baixado: as outras famílias já existem localmente, e a conferência das versões (as URLs das respostas
novas contra as do manifesto) é do `test_extrair_dc.py`.

Rodar no Windows (o WSL da medição não usa a rede), da raiz do repositório:
  PYTHONIOENCODING=utf-8 python3 tools/fonts/baixar_css2.py tools/medicao/pranchas_projeto.json
"""
import datetime
import hashlib
import html
import json
import os
import re
import sys
import urllib.request

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(AQUI, '..', '..'))
sys.path.insert(0, os.path.join(RAIZ, 'tools', 'medicao'))
import fontes_css2  # noqa: E402

UA = ('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/141.0.0.0 Safari/537.36')
SUBCONJUNTOS_APP = ('latin', 'latin-ext', 'vietnamese')
SAIDA_CSS = os.path.join(AQUI, 'css2_projeto')
ORIGINAIS = os.path.join(AQUI, 'originais_v2')


def baixar(url):
    req = urllib.request.Request(url, headers={'User-Agent': UA})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def nome_da_consulta(href):
    """Um nome de arquivo estável para a consulta: as famílias fora do trio de sempre, ou 'base'."""
    familias, _ = fontes_css2.consulta(href)
    extra = []
    for nome, faces in familias:
        if nome in ('Bricolage Grotesque', 'Figtree', 'Instrument Serif'):
            continue
        pesos = '_'.join(f"{'i' if e == 'italic' else ''}{p.replace(' ', '-')}" for e, p in faces)
        extra.append(f"{nome.lower().replace(' ', '')}_{pesos}")
    return '__'.join(extra) or 'base'


def main(indice):
    cfg = json.load(open(indice, encoding='utf-8'))
    projeto = os.path.join(RAIZ, *cfg['projeto'].split('/'))
    consultas = {}
    for p in cfg['pranchas']:
        texto = open(os.path.join(projeto, *p['arquivo'].split('/')), encoding='utf-8').read()
        href = html.unescape(fontes_css2.href_da_tela(texto))
        consultas.setdefault(href, []).append(p['tela'])
    os.makedirs(SAIDA_CSS, exist_ok=True)
    hoje = datetime.date.today().isoformat()
    lista = []
    for href, telas in consultas.items():
        css = baixar(href)
        nome = nome_da_consulta(href)
        with open(os.path.join(SAIDA_CSS, f'{nome}.css'), 'wb') as f:
            f.write(css)
        lista.append({'arquivo': f'{nome}.css', 'url': href, 'telas': telas, 'sha256': hashlib.sha256(css).hexdigest(),
                      'bytes': len(css), 'baixado': hoje, 'userAgent': UA})
        print(f'{nome}.css  {len(css):>6d} B  telas {", ".join(telas)}')
    with open(os.path.join(SAIDA_CSS, 'consultas.json'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump({'_doc': 'T13.2 (D-273) — as respostas do css2 das consultas das telas do projeto, baixadas por '
                           'tools/fonts/baixar_css2.py com o User-Agent de um Chrome (woff2 por subconjunto).',
                   'consultas': sorted(lista, key=lambda c: c['arquivo'])}, f, ensure_ascii=False, indent=1)
        f.write('\n')

    # binários das famílias que a tabela não tem
    tabela = fontes_css2.tabela()
    man_arq = os.path.join(ORIGINAIS, 'manifesto.json')
    man = json.load(open(man_arq, encoding='utf-8'))
    for c in lista:
        for f in fontes_css2.faces_do_css(open(os.path.join(SAIDA_CSS, c['arquivo']), encoding='utf-8').read()):
            if f['familia'] in tabela['familias'] or f['subconjunto'] not in SUBCONJUNTOS_APP:
                continue
            nome = f"{f['familia'].replace(' ', '')}-{f['estilo']}-{f['peso'].replace(' ', '_')}-{f['subconjunto']}"
            if nome in man['arquivos']:
                continue
            dados = baixar(f['src'])
            with open(os.path.join(ORIGINAIS, f'{nome}.woff2'), 'wb') as g:
                g.write(dados)
            man['arquivos'][nome] = {'url': f['src'], 'familia': f['familia'], 'estilo': f['estilo'],
                                     'subset': f['subconjunto'], 'pesosCss': [f['peso']],
                                     'sha256': hashlib.sha256(dados).hexdigest(), 'bytes': len(dados),
                                     'baixado': hoje, 'origem': f"T13.2 — {c['arquivo']}"}
            print(f'{nome}.woff2  {len(dados):>6d} B  {f["src"]}')
    man['arquivos'] = dict(sorted(man['arquivos'].items()))
    with open(man_arq, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(man, f, ensure_ascii=False, indent=1)
        f.write('\n')


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])

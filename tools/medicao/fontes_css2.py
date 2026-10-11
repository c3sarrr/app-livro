#!/usr/bin/env python3
"""T13 (R2) — as `@font-face` que o Google Fonts (`css2`) devolve para a consulta de uma tela do projeto.

Os `.dc.html` de `docs/design/projeto/telas/` pedem as fontes ao Google (`<link href=".../css2?family=…">`); a medição
roda com a rede bloqueada. Este módulo monta, a partir da consulta, o mesmo texto que o `css2` devolveria — a ordem,
os pesos, os subconjuntos e os `unicode-range` — com o subconjunto latin apontando para o binário local e os outros
para o `gstatic`, exatamente como as exportações antigas embutiam (o latin vinha no arquivo; os outros ficavam na
rede e a medição os bloqueia).

Regras do `css2` (tiradas das respostas embutidas nas 35 exportações antigas e conferidas contra as respostas reais
das consultas novas — `tools/fonts/css2_projeto/`):
- as famílias em ordem alfabética, não na da consulta (a 26 pede a Atkinson por último e a resposta a traz primeiro);
  dentro da família, itálico antes do normal e peso crescente;
- peso discreto (`wght@400;500`) = uma face por peso; faixa (`wght@500..800`) = uma face com `font-weight: 500 800`;
  sem eixo `wght`, peso 400; `ital` 1 = itálico; o `opsz` não aparece na face;
- cada face se repete por subconjunto, na ordem da família, com o `unicode-range` dele; `font-stretch: 100%` só nas
  famílias que têm o eixo de largura (a Bricolage); `font-display: swap` quando a consulta pede `display=swap`.

A tabela (`tools/medicao/fontes_css2.json`) guarda, por família, a ordem dos subconjuntos, os `unicode-range`, o
`font-stretch` e de onde vem cada binário: o latin, um arquivo local; os outros, a URL do `gstatic`. Gerar de novo:
  PYTHONIOENCODING=utf-8 python3 tools/medicao/fontes_css2.py --tabela
Mostrar o CSS de uma tela:
  PYTHONIOENCODING=utf-8 python3 tools/medicao/fontes_css2.py --mostrar docs/design/projeto/telas/Login.dc.html
"""
import glob
import hashlib
import html
import json
import os
import re
import sys
from urllib.parse import parse_qs, unquote_plus, urlsplit

RAIZ = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
TABELA = os.path.join(RAIZ, 'tools', 'medicao', 'fontes_css2.json')
FONTES_DO_ARQUIVO = os.path.join(RAIZ, 'handoff_v2', 'referencia', 'fontes_do_arquivo')
ORIGINAIS = os.path.join(RAIZ, 'tools', 'fonts', 'originais_v2')
CSS2_PROJETO = os.path.join(RAIZ, 'tools', 'fonts', 'css2_projeto')
# As exportações antigas cujos helmets trazem as respostas do css2 (as pastas da extração, fora do git), da mais nova
# para a mais antiga: o Google muda os `unicode-range` com o tempo (o latin-ext da Bricolage e da Figtree ia até
# U+20C0 no arquivo do leitor, de setembro, e até U+20C4 nos da Início e do clube, de outubro, com o mesmo binário).
# Vale o da resposta mais nova (as baixadas na T13 primeiro); as mais antigas que diferem ficam em `_divergencias`.
HELMETS_ANTIGOS = [
    os.path.join(RAIZ, 'tools', 'medicao', 'pranchas_inicio2'),
    os.path.join(RAIZ, 'tools', 'medicao', 'tmp', 'r00', 'pranchas_clube'),
    os.path.join(RAIZ, 'tools', 'medicao', 'pranchas'),
]
LINK_CSS2 = re.compile(r'<link rel="stylesheet" href="(https://fonts\.googleapis\.com/css2\?[^"]*)">')


class FonteDesconhecida(Exception):
    """A consulta pede uma família, um estilo ou um subconjunto que a tabela não tem."""


def sha256(caminho):
    with open(caminho, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()


def rel(caminho):
    return os.path.relpath(caminho, RAIZ).replace(os.sep, '/')


# ───────────────────────── a consulta ─────────────────────────
def _peso(v):
    a, sep, b = v.partition('..')
    return f'{a} {b}' if sep else a


def consulta(href):
    """`href` do `<link>` (com ou sem `&amp;`) → (famílias, display). Cada família = (nome, [(estilo, peso)]), em
    ordem alfabética, com as faces ordenadas como o css2 (itálico antes, peso crescente)."""
    url = urlsplit(html.unescape(href))
    q = parse_qs(url.query, keep_blank_values=True)
    familias = []
    for spec in q.get('family', []):
        nome, _, eixos = spec.partition(':')
        nome = unquote_plus(nome)
        faces = set()
        if not eixos:
            faces.add(('normal', '400'))
        else:
            nomes, _, tuplas = eixos.partition('@')
            nomes = nomes.split(',')
            for t in tuplas.split(';'):
                v = dict(zip(nomes, t.split(',')))
                estilo = 'italic' if v.get('ital') == '1' else 'normal'
                faces.add((estilo, _peso(v['wght']) if 'wght' in v else '400'))
        ordem = sorted(faces, key=lambda f: (f[0] != 'italic', int(f[1].split()[0]), f[1]))
        familias.append((nome, ordem))
    display = q.get('display', [None])[0]
    return sorted(familias), display


def href_da_tela(texto):
    m = LINK_CSS2.search(texto)
    if not m:
        raise ValueError('sem <link> do css2 no <helmet>')
    return m.group(1)


# ───────────────────────── o CSS (o formato do css2) ─────────────────────────
FACE = re.compile(r'/\* ([\w-]+) \*/\s*@font-face \{([^}]*)\}')


def faces_do_css(texto):
    """CSS do css2 (ou o <style> de um helmet antigo) → lista de faces (dicts), na ordem do texto."""
    out = []
    for m in FACE.finditer(texto):
        d = {k: v.strip() for k, v in re.findall(r'\s*([\w-]+):\s*([^;]+);', m.group(2))}
        src = re.search(r'url\(([^)]*)\)', d['src']).group(1).strip('"\'')
        out.append({'subconjunto': m.group(1), 'familia': d['font-family'].strip("'"), 'estilo': d['font-style'],
                    'peso': d['font-weight'], 'stretch': d.get('font-stretch'), 'display': d.get('font-display'),
                    'src': src, 'unicodeRange': d['unicode-range']})
    return out


def css(faces, url_local):
    """Faces → o texto no formato do css2. `url_local(caminho)` dá o `url()` de um binário local."""
    blocos = []
    for f in faces:
        src = f['src']
        u = src if src.startswith('http') else url_local(src)
        linhas = [f"  font-family: '{f['familia']}';", f"  font-style: {f['estilo']};", f"  font-weight: {f['peso']};"]
        if f.get('stretch'):
            linhas.append(f"  font-stretch: {f['stretch']};")
        if f.get('display'):
            linhas.append(f"  font-display: {f['display']};")
        linhas += [f"  src: url({u}) format('woff2');", f"  unicode-range: {f['unicodeRange']};"]
        blocos.append(f"/* {f['subconjunto']} */\n@font-face {{\n" + '\n'.join(linhas) + '\n}\n')
    return ''.join(blocos)


# ───────────────────────── a tabela ─────────────────────────
def tabela():
    with open(TABELA, encoding='utf-8') as f:
        return json.load(f)


def _chave(familia, estilo, subconjunto):
    return f'{familia}|{estilo}|{subconjunto}'


def faces(href, tab=None):
    """A consulta de uma tela → as faces do css2 (src = caminho local relativo à raiz no latin, URL nos outros)."""
    tab = tab or tabela()
    familias, display = consulta(href)
    out = []
    for nome, lista in familias:
        fam = tab['familias'].get(nome)
        if not fam:
            raise FonteDesconhecida(f'família {nome!r} fora da tabela')
        for estilo, peso in lista:
            for sub in fam['subconjuntos']:
                fontes = tab['binarios'].get(_chave(nome, estilo, sub))
                if not fontes:
                    raise FonteDesconhecida(f'{nome} {estilo} {sub}: sem binário na tabela')
                # variável: um binário para todos os pesos; estática: um por peso
                src = fontes.get(peso) or fontes.get('*')
                if not src:
                    raise FonteDesconhecida(f'{nome} {estilo} {peso} {sub}: sem binário para esse peso')
                out.append({'subconjunto': sub, 'familia': nome, 'estilo': estilo, 'peso': peso,
                            'stretch': fam.get('stretch'), 'display': display, 'src': src,
                            'unicodeRange': fam['unicodeRange'][sub]})
    return out


_LOCAIS = {}


def _binario_local(sha):
    """sha256 → o binário local (latin embutido nos arquivos antigos ou baixado em originais_v2)."""
    if not _LOCAIS:
        for pasta in (FONTES_DO_ARQUIVO, ORIGINAIS):
            for f in sorted(glob.glob(os.path.join(pasta, '*.woff2'))):
                _LOCAIS.setdefault(sha256(f), rel(f))
    return _LOCAIS.get(sha)


def _manifesto_por_url():
    with open(os.path.join(ORIGINAIS, 'manifesto.json'), encoding='utf-8') as f:
        man = json.load(f)['arquivos']
    return {v['url']: rel(os.path.join(ORIGINAIS, k + '.woff2')) for k, v in man.items()}


def gerar_tabela():
    """Junta as faces das respostas do css2 que temos: os helmets das exportações antigas e as respostas baixadas na
    T13. O latin vira caminho local (pelo sha256 do binário embutido ou pela URL no manifesto); os outros, a URL."""
    por_url = _manifesto_por_url()
    url_do_local = {v: k for k, v in por_url.items()}
    familias, binarios, divergencias = {}, {}, []
    fontes = []
    for arq in sorted(glob.glob(os.path.join(CSS2_PROJETO, '*.css'))):
        fontes.append((rel(arq), faces_do_css(open(arq, encoding='utf-8').read()), None))
    for pasta in HELMETS_ANTIGOS:
        for tpl in sorted(glob.glob(os.path.join(pasta, '*', 'template.html'))):
            texto = open(tpl, encoding='utf-8').read()
            hel = texto[texto.index('<helmet>'):texto.index('</helmet>')]
            fontes.append((rel(tpl), faces_do_css(hel), os.path.join(os.path.dirname(tpl), 'assets')))
    if not fontes:
        sys.exit('nenhuma resposta do css2 encontrada (as extrações antigas estão fora do git: rode a R00/T02)')
    for de, lista, assets in fontes:
        for f in lista:
            nome, sub = f['familia'], f['subconjunto']
            fam = familias.setdefault(nome, {'stretch': f['stretch'], 'subconjuntos': [], 'unicodeRange': {}})
            if sub not in fam['subconjuntos']:
                fam['subconjuntos'].append(sub)
            for campo, valor in (('stretch', f['stretch']),):
                if fam[campo] != valor:
                    sys.exit(f'{nome}: {campo} {fam[campo]!r} × {valor!r} ({de})')
            ur = fam['unicodeRange'].setdefault(sub, f['unicodeRange'])
            if ur != f['unicodeRange']:
                d = {'familia': nome, 'subconjunto': sub, 'unicodeRange': f['unicodeRange'],
                     'pasta': os.path.dirname(os.path.dirname(de))}
                if d not in divergencias:
                    divergencias.append(d)
            if f['src'].startswith('http'):
                src = por_url.get(f['src']) if sub == 'latin' else f['src']
                if not src:
                    # o latin das respostas novas que o arquivo antigo embutia (Bricolage, Figtree…): o binário
                    # local vem dos helmets antigos; a versão é conferida pelas URLs dos outros subconjuntos
                    continue
            else:
                src = _binario_local(sha256(os.path.join(assets, f['src'] + '.woff2')))
                if not src:
                    sys.exit(f'{nome} {f["estilo"]} {sub}: o binário embutido {f["src"]} não tem cópia local ({de})')
                if sub != 'latin':
                    # embutido numa exportação (o latin-ext da Figtree na 04), mas o css2 o serve pela URL
                    src = url_do_local.get(src)
                    if not src:
                        sys.exit(f'{nome} {f["estilo"]} {sub}: o embutido não está no manifesto ({de})')
            b = binarios.setdefault(_chave(nome, f['estilo'], sub), {})
            if b.get(f['peso'], src) != src:
                sys.exit(f'{nome} {f["estilo"]} {f["peso"]} {sub}: dois binários ({de})')
            b[f['peso']] = src
        for nome in {f['familia'] for f in lista}:
            seq = [f['subconjunto'] for f in lista if f['familia'] == nome]
            ordem = [s for s in familias[nome]['subconjuntos'] if s in seq]
            if [s for i, s in enumerate(seq) if s not in seq[:i]] != ordem:
                sys.exit(f'{nome}: ordem dos subconjuntos diferente em {de}')
    # Família variável: algum (estilo, subconjunto) com vários pesos no mesmo binário. Nela, cada (estilo,
    # subconjunto) de binário único vale para qualquer peso ('*') — é o que permite a Literata 600 da 06 com o
    # binário dos pesos 400 e 500. Família estática (a Atkinson) ou só com um peso (Instrument Serif, Roboto 500):
    # o peso fica explícito e outro peso falha.
    for nome, fam in familias.items():
        for k in [k for k in binarios if k.startswith(nome + '|')] or [nome]:
            estilo = k.split('|')[1] if '|' in k else 'normal'
            if 'latin' in fam['subconjuntos'] and _chave(nome, estilo, 'latin') not in binarios:
                sys.exit(f'{nome} {estilo}: sem binário latin local')
    variaveis = {k.split('|')[0] for k, b in binarios.items() if len(b) > 1 and len(set(b.values())) == 1}
    for k, b in binarios.items():
        if k.split('|')[0] in variaveis and len(set(b.values())) == 1:
            binarios[k] = {'*': next(iter(b.values()))}
    out = {'_doc': 'T13 (R2) — gerado por tools/medicao/fontes_css2.py --tabela a partir das respostas do css2 '
                   '(os helmets das exportações antigas e tools/fonts/css2_projeto/). Por família: a ordem dos '
                   'subconjuntos, os unicode-range e o font-stretch; binarios[família|estilo|subconjunto][peso] = '
                   'o binário (latin: caminho local; os outros: a URL do gstatic); "*" = variável, qualquer peso.',
           'familias': dict(sorted(familias.items())),
           'binarios': dict(sorted(binarios.items())),
           '_divergencias': divergencias}
    with open(TABELA, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print(f'{rel(TABELA)}: {len(familias)} famílias, {len(binarios)} (família, estilo, subconjunto)')


if __name__ == '__main__':
    if '--tabela' in sys.argv:
        gerar_tabela()
    elif '--mostrar' in sys.argv:
        tela = sys.argv[sys.argv.index('--mostrar') + 1]
        print(css(faces(href_da_tela(open(tela, encoding='utf-8').read())), lambda p: f'"{p}"'), end='')
    else:
        sys.exit(__doc__)

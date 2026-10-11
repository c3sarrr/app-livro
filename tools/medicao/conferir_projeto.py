#!/usr/bin/env python3
# R00 (R8) — confere as pranchas que já tinham versão exportada (e medida) contra o projeto completo do Claude Design
# (`docs/design/projeto/`): a família da Início (01, 01b, 60–63), o leitor (19–27b) e o clube (16).
#
# Compara o DOM normalizado (fora do <helmet>; atributos em ordem; `sc-camel-*` → camelCase; espaços colapsados;
# `data-props` como JSON ordenado; `style` sem o ';' final; o `<script src>` do suporte ignorado) e o CSS do <helmet>
# sem comentários nem `@font-face` (as fontes embutidas são da T13). Confere também que o `dc-runtime.js` do projeto
# contém, nessa ordem, os 3 scripts que renderizavam as pranchas antigas (React, ReactDOM e o runtime): é o
# `support.js` que os `.dc.html` chamam.
#
# Rodar da raiz do repositório (Python puro, sem Chromium):
#   PYTHONIOENCODING=utf-8 python3 tools/medicao/conferir_projeto.py [--projeto <pasta>] [--saida <arquivo.md>]
# Saída 1 quando alguma prancha ou o runtime difere. Rodar de novo quando o projeto mudar (ROTEIRO §5: a pasta nova
# `docs/design/projeto_<data>/` entra com `--projeto`).
import argparse
import json
import re
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]

# As extrações antigas (fora do git): as duas primeiras já existem desde a G01/T02; o clube é extraído para o tmp.
GRUPOS = [
    ('Início e revisão', RAIZ / 'tools/medicao/pranchas_inicio2', None),
    ('Leitor', RAIZ / 'tools/medicao/pranchas', None),
    ('Clube', RAIZ / 'tools/medicao/tmp/r00/pranchas_clube',
     ('docs/design/referencia/Redesign_mobile___App_de_leitura_2.html', 'tools/medicao/pranchas_clube.json')),
]

# Os 3 scripts das pranchas antigas, na ordem em que o `dc-runtime.js` os junta (iguais nas 6 da Início).
RUNTIME_ANTIGO = RAIZ / 'tools/medicao/pranchas_inicio2/001b_inicio_lendo_agora/assets'
SCRIPTS_ANTIGOS = [
    ('React', 'c022f7fc-5bed-47c7-b372-48467484beac.js'),
    ('ReactDOM', 'f0dfee88-ba21-4b23-8cb8-4214b878b1ed.js'),
    ('runtime', '46ba1a3a-c105-4464-967f-dee24eda1a9f.js'),
]


class Tokens(HTMLParser):
    """O DOM da prancha em tokens comparáveis (ver o cabeçalho)."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.out = []
        self.dentro_helmet = 0

    def handle_starttag(self, tag, attrs):
        if tag == 'helmet':
            self.dentro_helmet += 1
        if self.dentro_helmet:
            return
        norm = []
        for k, v in attrs:
            k = k.lower()
            v = v or ''
            if k.startswith('sc-camel-'):
                k = k[len('sc-camel-'):].replace('-', '')
            if k == 'data-props':
                v = json.dumps(json.loads(v), sort_keys=True)
            if k == 'style':
                v = re.sub(r'\s+', ' ', v).strip().rstrip(';')
            if tag == 'script' and k == 'src':
                v = 'SUPORTE'  # o id do bundle (antigas) × ./support.js (projeto)
            norm.append((k, v))
        self.out.append((tag, tuple(sorted(norm))))

    def handle_endtag(self, tag):
        if tag == 'helmet':
            self.dentro_helmet -= 1
        elif not self.dentro_helmet:
            self.out.append(('/', tag))

    def handle_data(self, data):
        d = re.sub(r'\s+', ' ', data).strip()
        if d and not self.dentro_helmet:
            self.out.append(('#', d))


def tokens(html):
    t = Tokens()
    t.feed(html)
    return t.out


def css_do_helmet(html):
    """O CSS do <helmet> sem comentários nem `@font-face`."""
    h = html[html.find('<helmet>'):html.find('</helmet>')]
    css = ' '.join(re.findall(r'<style>(.*?)</style>', h, re.S))
    css = re.sub(r'/\*.*?\*/', '', css, flags=re.S)
    css = re.sub(r'@font-face\s*{[^}]*}', '', css)
    return re.sub(r'\s+', ' ', css).strip()


def numero(texto):
    """'001b_inicio…' → '1b'; '23b_…' → '23b'; '01' → '1'; '102' → '102'."""
    m = re.match(r'0*(\d+)([a-d]?)', texto)
    return m.group(1) + m.group(2)


def catalogo(projeto):
    """número da tela → (número como o catálogo escreve, arquivo `.dc.html`); as 3 da 83 não entram (nenhuma tinha
    versão antiga)."""
    tabela = {}
    for linha in (projeto / 'CATALOGO.md').read_text(encoding='utf-8').splitlines():
        m = re.match(r'\| Page \d+ \| (\d{2,3}[a-d]?) · .*?\| `(telas/[^`]+)`', linha)
        if m:
            tabela.setdefault(numero(m.group(1)), (m.group(1), m.group(2)))
    return tabela


def extrair_se_faltar(pasta, origem):
    if origem is None or (pasta / 'extracao.json').exists():
        return
    bundle, indice = origem
    subprocess.run([sys.executable, str(RAIZ / 'tools/medicao/extrair_bundle.py'), str(RAIZ / bundle), str(pasta),
                    '--aninhado', str(RAIZ / indice)], check=True, stdout=subprocess.DEVNULL)


def primeira_diferenca(a, b):
    for i, (x, y) in enumerate(zip(a, b)):
        if x != y:
            return f'token {i}: {x!r} × {y!r}'
    return f'tamanhos {len(a)} × {len(b)}'


def conferir(projeto):
    cat = catalogo(projeto)
    linhas, iguais, total = [], 0, 0
    for grupo, pasta, origem in GRUPOS:
        extrair_se_faltar(pasta, origem)
        for antiga in sorted(p for p in pasta.iterdir() if (p / 'template.html').exists()):
            total += 1
            achada = cat.get(numero(antiga.name))
            if achada is None:
                linhas.append((grupo, numero(antiga.name), antiga.name, '—', 0, 'sem tela no catálogo', '', 'DIFERE'))
                continue
            n, arquivo = achada
            velho = (antiga / 'template.html').read_text(encoding='utf-8')
            novo = (projeto / arquivo).read_text(encoding='utf-8')
            tv, tn = tokens(velho), tokens(novo)
            dom = 'igual' if tv == tn else primeira_diferenca(tv, tn)
            css = 'igual' if css_do_helmet(velho) == css_do_helmet(novo) else 'difere'
            ok = dom == 'igual' and css == 'igual'
            iguais += ok
            linhas.append((grupo, n, antiga.name, arquivo, len(tn), dom, css, 'igual' if ok else 'DIFERE'))
    return linhas, iguais, total


def conferir_runtime(projeto):
    runtime = (projeto / 'dc-runtime.js').read_bytes()
    pos, achados = 0, []
    for nome, arquivo in SCRIPTS_ANTIGOS:
        parte = (RUNTIME_ANTIGO / arquivo).read_bytes().strip()
        i = runtime.find(parte, pos)
        achados.append((nome, len(parte), i >= 0))
        if i >= 0:
            pos = i + len(parte)
    return achados


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--projeto', default=str(RAIZ / 'docs/design/projeto'))
    ap.add_argument('--saida', default=str(RAIZ / 'docs/design/medicao/projeto/conferencia_projeto.md'))
    args = ap.parse_args()
    projeto = Path(args.projeto).resolve()

    linhas, iguais, total = conferir(projeto)
    runtime = conferir_runtime(projeto)
    runtime_ok = all(ok for _, _, ok in runtime)

    md = [
        '# Conferência — as pranchas medidas × o projeto completo',
        '',
        '> Gerado por `tools/medicao/conferir_projeto.py` (R00, R8). Não editar à mão: rodar o script de novo.',
        f'> Projeto: `{projeto.relative_to(RAIZ).as_posix()}`.',
        '',
        f'**{iguais}/{total} iguais** (DOM normalizado e CSS do `<helmet>` sem as `@font-face`). '
        f'Runtime: o `dc-runtime.js` {"contém" if runtime_ok else "NÃO contém"} os 3 scripts das pranchas antigas, '
        'na ordem — é o `support.js` que os `.dc.html` chamam.',
        '',
        '| Grupo | Nº | Extração antiga | `.dc.html` do projeto | Tokens | DOM | CSS | Resultado |',
        '|---|---|---|---|---|---|---|---|',
    ]
    for grupo, n, antiga, arquivo, ntok, dom, css, res in linhas:
        md.append(f'| {grupo} | {n} | `{antiga}` | `{arquivo}` | {ntok} | {dom} | {css} | {res} |')
    md += ['', '| Script antigo | Bytes | No `dc-runtime.js` (na ordem) |', '|---|---|---|']
    for nome, tamanho, ok in runtime:
        md.append(f'| {nome} | {tamanho} | {"sim" if ok else "NÃO"} |')
    md += ['', '## Renderização', '',
           'Prova de que o mesmo DOM renderiza igual (R00): `tools/medicao/renderizar_dc.js` monta a tela com o '
           '`dc-runtime.js` como `support.js` e as fontes embutidas e, com `--antiga`, renderiza a exportação antiga nas '
           'mesmas condições; `tools/compare_images.py` compara os dois PNG. Resultado de 11/10/2026 para a 01b @3x: '
           '**0 pixels diferentes**. A referência medida da T02 sai do zoom 10: o `.dc.html` no zoom 10 dá o mesmo '
           'layout do JSON medido (o "pág. 159 de 256" com 108,97 px e o "E-BOOK" na 2ª linha); no zoom 1 o avanço das '
           'letras arredonda (107,97 px) e o "E-BOOK" cabe na 1ª linha — por isso a T13 mede com o método da T02.']
    saida = Path(args.saida).resolve()
    saida.parent.mkdir(parents=True, exist_ok=True)
    saida.write_text('\n'.join(md) + '\n', encoding='utf-8', newline='\n')

    print(f'{iguais}/{total} iguais · runtime {"contém os 3" if runtime_ok else "DIFERE"} · {saida.relative_to(RAIZ).as_posix()}')
    for grupo, n, antiga, arquivo, ntok, dom, css, res in linhas:
        if res != 'igual':
            print(f'  DIFERE {grupo} {n} {arquivo}: DOM {dom} · CSS {css}')
    return 0 if iguais == total and runtime_ok else 1


if __name__ == '__main__':
    sys.exit(main())

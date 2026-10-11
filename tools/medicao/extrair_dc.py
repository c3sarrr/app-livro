#!/usr/bin/env python3
"""T13.1 — extrai as telas do projeto (`docs/design/projeto/telas/*.dc.html`) para a pasta que o pipeline de medição
da G01/T02 já sabe medir, uma por tela:

  <saída>/<slug>/original.html   a tela que renderiza sozinha no Chromium com a rede bloqueada: o `.dc.html` com o
                                 `<link>` do css2 trocado por um `<style>` com as `@font-face` (R2: o latin local em
                                 `assets/<id>.woff2`, os outros subconjuntos no gstatic, como o css2 serve)
  <saída>/<slug>/template.html   o mesmo HTML com o `url()` do latin = o id do binário (como as exportações antigas:
                                 `build_layout.py` lê as faces daqui e `recortar.py` abre `assets/<id>.woff2`)
  <saída>/<slug>/support.js      o `dc-runtime.js` do projeto (é o `./support.js` que o `.dc.html` chama — R00)
  <saída>/<slug>/assets/         os binários latin que a tela usa
  <saída>/<slug>/props.json      as props do `data-props` (com o `$preview`)
e <saída>/extracao.json com os sha256 de tudo e o que foi conferido.

O `<helmet>` continua com 3 filhos (o `preconnect`, o `<style>` das faces e o `<style>` da tela): o runtime numera os
elementos (`data-dc-tpl`) a partir deles, então o quadro fica no tpl 4 e a numeração é a das exportações antigas.

Conferido por tela: o sha256 do `.dc.html` com o do `CATALOGO.md` (12 primeiros), o título e o tamanho do catálogo,
o `$preview` e o `canvas` do índice. Uso (da raiz do repositório; Python puro):
  PYTHONIOENCODING=utf-8 python3 tools/medicao/extrair_dc.py <índice.json> <saída>
"""
import hashlib
import json
import os
import re
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import fontes_css2  # noqa: E402

RAIZ = fontes_css2.RAIZ
LINHA_CATALOGO = re.compile(r'^\| Page \d+ \| (.+?) \| `(telas/[^`]+)` \| (\d+)×(\d+) \| `([0-9a-f]{12})` \|$')


def sha(dados):
    return hashlib.sha256(dados).hexdigest()


def ler_bytes(caminho):
    with open(caminho, 'rb') as f:
        return f.read()


def catalogo(projeto):
    """arquivo → (título, [w, h], sha12) do `CATALOGO.md` do projeto."""
    out = {}
    with open(os.path.join(projeto, 'CATALOGO.md'), encoding='utf-8') as f:
        for linha in f:
            m = LINHA_CATALOGO.match(linha.rstrip('\n'))
            if m:
                out[m.group(2)] = (m.group(1), [int(m.group(3)), int(m.group(4))], m.group(5))
    return out


def props(texto):
    m = re.search(r"<script type=\"text/x-dc\" data-dc-script data-props='([^']*)'>", texto)
    if not m:
        raise ValueError('sem o <script type="text/x-dc" data-props>')
    return json.loads(m.group(1))


def id_binario(caminho):
    return os.path.splitext(os.path.basename(caminho))[0]


def montar(texto, tabela=None):
    """O `.dc.html` → (original, template, faces). Só o `<link>` do css2 muda."""
    href = fontes_css2.href_da_tela(texto)
    faces = fontes_css2.faces(href, tabela)
    link = f'<link rel="stylesheet" href="{href}">'
    if texto.count(link) != 1:
        raise ValueError('o <link> do css2 não aparece uma única vez')
    orig = fontes_css2.css(faces, lambda p: f'assets/{id_binario(p)}.woff2')
    tpl = fontes_css2.css(faces, lambda p: f'"{id_binario(p)}"')
    return (texto.replace(link, f'<style>{orig}</style>'), texto.replace(link, f'<style>{tpl}</style>'), faces)


def escrever(caminho, dados):
    os.makedirs(os.path.dirname(caminho), exist_ok=True)
    with open(caminho, 'wb') as f:
        f.write(dados)
    return sha(dados)


def extrair(indice, saida):
    with open(indice, encoding='utf-8') as f:
        cfg = json.load(f)
    projeto = os.path.join(RAIZ, *cfg['projeto'].split('/'))
    cat = catalogo(projeto)
    runtime = ler_bytes(os.path.join(projeto, 'dc-runtime.js'))
    tabela = fontes_css2.tabela()
    tabela_bytes = ler_bytes(fontes_css2.TABELA)
    erros = []
    rel = {'projeto': cfg['projeto'], 'runtime_sha256': sha(runtime), 'tabela_fontes_sha256': sha(tabela_bytes),
           'pranchas': {}}
    for p in cfg['pranchas']:
        slug, arq = p['slug'], p['arquivo']
        bruto = ler_bytes(os.path.join(projeto, *arq.split('/')))
        texto = bruto.decode('utf-8')
        titulo, tam, sha12 = cat.get(arq, (None, None, None))
        if sha12 is None:
            erros.append(f'{slug}: {arq} fora do CATALOGO.md')
        elif sha(bruto)[:12] != sha12:
            erros.append(f'{slug}: sha256 {sha(bruto)[:12]} ≠ {sha12} do CATALOGO.md')
        if titulo is not None and titulo != p['titulo']:
            erros.append(f'{slug}: título "{p["titulo"]}" ≠ "{titulo}" do CATALOGO.md')
        pr = props(texto)
        pv = [pr.get('$preview', {}).get('width'), pr.get('$preview', {}).get('height')]
        if not (pv == tam == p['canvas']):
            erros.append(f'{slug}: $preview {pv} × CATALOGO {tam} × índice {p["canvas"]}')
        try:
            original, template, faces = montar(texto, tabela)
        except (ValueError, fontes_css2.FonteDesconhecida) as e:
            erros.append(f'{slug}: {e}')
            continue
        dest = os.path.join(saida, slug)
        shutil.rmtree(dest, ignore_errors=True)
        h = {'original.html': escrever(os.path.join(dest, 'original.html'), original.encode('utf-8')),
             'template.html': escrever(os.path.join(dest, 'template.html'), template.encode('utf-8')),
             'support.js': escrever(os.path.join(dest, 'support.js'), runtime),
             'props.json': escrever(os.path.join(dest, 'props.json'),
                                    (json.dumps(pr, ensure_ascii=False, indent=1) + '\n').encode('utf-8'))}
        for src in sorted({f['src'] for f in faces if not f['src'].startswith('http')}):
            b = ler_bytes(os.path.join(RAIZ, *src.split('/')))
            h[f'assets/{id_binario(src)}.woff2'] = escrever(os.path.join(dest, 'assets', f'{id_binario(src)}.woff2'), b)
        rel['pranchas'][slug] = {'arquivo': arq, 'sha256': sha(bruto), 'titulo': titulo, 'canvas': p['canvas'],
                                 'props': sorted(k for k in pr if not k.startswith('$')),
                                 'consulta': fontes_css2.href_da_tela(texto), 'arquivos': dict(sorted(h.items()))}
        print(f'{slug:34s} {len(bruto):>7d} B  sha={sha(bruto)[:12]}  faces={len(faces):>2d}  canvas={p["canvas"]}')
    os.makedirs(saida, exist_ok=True)
    with open(os.path.join(saida, 'extracao.json'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump(rel, f, ensure_ascii=False, indent=1)
        f.write('\n')
    if erros:
        print('\nERROS:\n  ' + '\n  '.join(erros))
        return 1
    print(f'\nOK: {len(cfg["pranchas"])} telas extraídas; conferidos sha256, títulos, tamanhos e $preview.')
    return 0


if __name__ == '__main__':
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    sys.exit(extrair(sys.argv[1], sys.argv[2]))

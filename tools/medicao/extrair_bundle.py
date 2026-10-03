#!/usr/bin/env python3
"""Extrai o HTML real e os assets de um bundle do Claude Design — simples (v1) ou aninhado (v2).

Modo simples (igual à v1, usado na Início):
    python3 tools/medicao/extrair_bundle.py "<bundle>.html" saida/
    → saida/template.html (HTML da tela com {{props}}) + saida/assets/<uuid>.<ext>

Modo aninhado (arquivo com várias pranchas — telas 19–27b):
    python3 tools/medicao/extrair_bundle.py "<bundle>.html" tools/medicao/pranchas/ \
        --aninhado tools/medicao/pranchas.json
    O bundle raiz tem __bundler/page_order; cada página é OUTRO bundle (manifest/template próprios,
    runtime dc-runtime + React, props {{paper}}/{{brand}}/{{ink}}) guardado no manifest da raiz.
    Para cada prancha de pranchas.json:
      <saida>/<slug>/original.html   bundle da prancha, byte a byte (renderiza sozinho no Chromium)
      <saida>/<slug>/template.html   HTML da prancha com {{props}}
      <saida>/<slug>/assets/<uuid>.<ext>
      <saida>/<slug>/props.json      definição das props (data-props do <script type="text/x-dc">)
    e <saida>/extracao.json com sha256 de tudo (para a conferência de reprodutibilidade).
    Confere: uuids de pranchas.json == page_order, títulos == <h2> da raiz, canvas == $preview.

Listar as pranchas do arquivo (para montar pranchas.json):
    python3 tools/medicao/extrair_bundle.py "<bundle>.html" --listar

Só biblioteca padrão do Python (3.9+).
"""
import base64
import gzip
import hashlib
import html as htmllib
import json
import os
import re
import sys

EXT = {
    'text/html': 'html', 'application/javascript': 'js', 'text/javascript': 'js',
    'text/css': 'css', 'image/svg+xml': 'svg', 'image/png': 'png', 'image/jpeg': 'jpg',
    'font/woff2': 'woff2', 'font/woff': 'woff', 'font/ttf': 'ttf', 'application/json': 'json',
}


def grab(s, t):
    m = re.search(r'<script type="__bundler/' + re.escape(t) + r'">(.*?)</script>', s, re.S)
    return m.group(1) if m else None


def decode(entry):
    data = base64.b64decode(entry['data'])
    return gzip.decompress(data) if entry.get('compressed') else data


def sha(b):
    return hashlib.sha256(b).hexdigest()


def write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'wb') as f:
        f.write(data)
    return sha(data)


def extract_single(bundle_text, out):
    """Extrai template + assets de UM bundle. Devolve {caminho relativo: sha256}."""
    manifest = json.loads(grab(bundle_text, 'manifest'))
    template = json.loads(grab(bundle_text, 'template'))
    hashes = {}
    for uuid in sorted(manifest):
        entry = manifest[uuid]
        ext = EXT.get(entry['mime'], entry['mime'].split('/')[-1])
        rel = f'assets/{uuid}.{ext}'
        hashes[rel] = write(os.path.join(out, rel), decode(entry))
    hashes['template.html'] = write(os.path.join(out, 'template.html'), template.encode('utf-8'))
    return hashes, template


def root_boards(root_template):
    """[(uuid, título do <h2>, largura, altura)] na ordem da página raiz."""
    boards = []
    for m in re.finditer(r'<section class="board"><h2>(.*?)</h2><iframe src="about:blank#([0-9a-f-]{36})"'
                         r'[^>]*width="(\d+)" height="(\d+)"', root_template):
        boards.append((m.group(2), htmllib.unescape(m.group(1)), int(m.group(3)), int(m.group(4))))
    return boards


def props_of(template):
    m = re.search(r'<script type="text/x-dc"[^>]*data-props="([^"]*)"', template)
    return json.loads(htmllib.unescape(m.group(1))) if m else {}


def main():
    args = sys.argv[1:]
    src = args[0]
    s = open(src, encoding='utf-8').read()
    page_order = json.loads(grab(s, 'page_order') or '[]')
    if '--listar' in args:
        manifest = json.loads(grab(s, 'manifest'))
        root_tpl = json.loads(grab(s, 'template'))
        for uuid, title, w, h in root_boards(root_tpl):
            nested = decode(manifest[uuid]).decode('utf-8')
            pv = props_of(json.loads(grab(nested, 'template'))).get('$preview', {})
            print(f'{uuid}  {w}x{h}  preview={pv.get("width")}x{pv.get("height")}  {title}')
        return
    out = args[1]
    if '--aninhado' not in args:
        if page_order:
            sys.exit('Este bundle tem páginas aninhadas (page_order). Use --aninhado pranchas.json.')
        hashes, _ = extract_single(s, out)
        for k, v in hashes.items():
            print(v[:12], k)
        return

    cfg = json.load(open(args[args.index('--aninhado') + 1], encoding='utf-8'))
    pranchas = cfg['pranchas']
    manifest = json.loads(grab(s, 'manifest'))
    root_tpl = json.loads(grab(s, 'template'))
    boards = {u: (t, w, h) for u, t, w, h in root_boards(root_tpl)}
    erros = []
    if [p['uuid'] for p in pranchas] != page_order:
        erros.append('a ordem/uuids de pranchas.json não batem com __bundler/page_order')
    report = {'fonte': os.path.basename(src), 'fonte_sha256': sha(s.encode('utf-8')), 'pranchas': {}}
    for p in pranchas:
        uuid, slug = p['uuid'], p['slug']
        if uuid not in manifest:
            erros.append(f'{slug}: uuid {uuid} ausente do manifest')
            continue
        raw = decode(manifest[uuid])
        dest = os.path.join(out, slug)
        hashes = {'original.html': write(os.path.join(dest, 'original.html'), raw)}
        nested = raw.decode('utf-8')
        if json.loads(grab(nested, 'page_order') or '[]'):
            erros.append(f'{slug}: a prancha tem páginas aninhadas de novo (não suportado)')
        h2, tpl = extract_single(nested, dest)
        hashes.update(h2)
        props = props_of(tpl)
        hashes['props.json'] = write(os.path.join(dest, 'props.json'),
                                     (json.dumps(props, ensure_ascii=False, indent=1) + '\n').encode('utf-8'))
        title, bw, bh = boards.get(uuid, (None, None, None))
        pv = props.get('$preview', {})
        if title != p['titulo']:
            erros.append(f'{slug}: título "{title}" ≠ "{p["titulo"]}"')
        if [bw, bh] != p['canvas'] or [pv.get('width'), pv.get('height')] != p['canvas']:
            erros.append(f'{slug}: canvas iframe={bw}x{bh} $preview={pv.get("width")}x{pv.get("height")} '
                         f'≠ {p["canvas"]}')
        report['pranchas'][slug] = {'uuid': uuid, 'titulo': title, 'canvas': p['canvas'],
                                    'props': sorted(k for k in props if not k.startswith('$')),
                                    'arquivos': dict(sorted(hashes.items()))}
        print(f'{slug:24s} {len(raw):>8d} B  original={hashes["original.html"][:12]}  '
              f'props={report["pranchas"][slug]["props"]}  canvas={p["canvas"]}')
    with open(os.path.join(out, 'extracao.json'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump(report, f, ensure_ascii=False, indent=1)
        f.write('\n')
    if erros:
        print('\nERROS:\n  ' + '\n  '.join(erros))
        sys.exit(1)
    print(f'\nOK: {len(pranchas)} pranchas extraídas; conferidos page_order, títulos e canvas.')


if __name__ == '__main__':
    main()

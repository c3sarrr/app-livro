#!/usr/bin/env python3
"""Extrai o HTML real e os assets (fontes woff2, scripts) de um bundle do Claude Design.
Uso: python3 extrair_bundle.py "Redesign mobile — App de leitura.html" saida/
Gera saida/template.html (o HTML da tela, com {{props}} e sc-camel-view-box = viewBox)
e saida/assets/<uuid>.<ext>. Requer: pip install fonttools brotli (para converter woff2 -> ttf).
"""
import base64, gzip, json, os, re, sys
src, out = sys.argv[1], sys.argv[2]
os.makedirs(os.path.join(out, 'assets'), exist_ok=True)
s = open(src, encoding='utf-8').read()
def grab(t):
    m = re.search(r'<script type="__bundler/' + t + r'">(.*?)</script>', s, re.S)
    return m.group(1) if m else None
manifest = json.loads(grab('manifest'))
template = json.loads(grab('template'))
for uuid, entry in manifest.items():
    data = base64.b64decode(entry['data'])
    if entry.get('compressed'):
        data = gzip.decompress(data)
    ext = entry['mime'].split('/')[-1].replace('javascript', 'js')
    open(os.path.join(out, 'assets', f'{uuid}.{ext}'), 'wb').write(data)
    print(uuid, entry['mime'], len(data))
open(os.path.join(out, 'template.html'), 'w', encoding='utf-8').write(template)
print('template.html', len(template))

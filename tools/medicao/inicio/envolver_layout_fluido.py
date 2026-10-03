"""Converte a saída crua de widths.js (id → [x, y, w, h] de TODOS os ids) no formato usado por
compare_images.py (--layout) e por gen_reference_dart.py (--flat): {meta, sections, elements}.

Uso: python3 envolver_layout_fluido.py layout_w360_cru.json layout_inicio.json 360 > layout_w360.json
Mantém só os ids que existem como widget em kRefLayout (sem trechos inline e sem frame/main),
na mesma ordem de layout_inicio.json.
"""
import json
import sys

raw_path, base_path, width = sys.argv[1], sys.argv[2], int(sys.argv[3])
raw = json.load(open(raw_path, encoding='utf-8'))
base = json.load(open(base_path, encoding='utf-8'))
keep = [k for k, v in base['elements'].items() if v.get('type') != 'inline' and 'section' in v]
els = {k: raw[k] for k in keep}
out = {
    'meta': {
        'source': base['meta']['source'],
        'canvas': [width, base['meta']['canvas'][1]],
        'units': 'CSS px = dp lógico',
        'measuredWith': 'Chromium (Playwright 1.56) zoom 100, --font-render-hinting=none; mesma marcação com a largura do canvas alterada',
        'note': 'Validação SECUNDÁRIA (FASE 13, tolerância ±1,0). elements = id → [x, y, w, h] absolutos (retângulo de layout, sem rotação).',
    },
    'sections': {s: els[s] for s in base['sections']},
    'elements': els,
}
json.dump(out, sys.stdout, ensure_ascii=False, indent=1)

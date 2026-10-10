#!/usr/bin/env python3
"""T02 — compara os layout_*.json de duas pastas (a G01 commitada × uma rodada nova) campo a campo.
Uso: python3 tools/medicao/comparar_layouts.py <pasta_a> <pasta_b>  → por prancha: nº de diferenças, a maior numérica e
as primeiras; código 1 se houver diferença.
"""
import json
import os
import sys


def difs(a, b, p=''):
    out = []
    if isinstance(a, dict) and isinstance(b, dict):
        for k in sorted(set(a) | set(b)):
            if k not in a or k not in b:
                out.append((p + '/' + k, 'ausente', k in a, k in b))
            else:
                out += difs(a[k], b[k], p + '/' + k)
    elif isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            out.append((p, 'tamanho', len(a), len(b)))
        else:
            for i, (x, y) in enumerate(zip(a, b)):
                out += difs(x, y, f'{p}[{i}]')
    elif isinstance(a, (int, float)) and isinstance(b, (int, float)) and not isinstance(a, bool):
        if abs(a - b) > 1e-9:
            out.append((p, a, b))
    elif a != b:
        out.append((p, str(a)[:70], str(b)[:70]))
    return out


def main():
    da, db = sys.argv[1], sys.argv[2]
    tem = False
    for f in sorted(x for x in os.listdir(da) if x.startswith('layout_') and x.endswith('.json')):
        fb = os.path.join(db, f)
        if not os.path.exists(fb):
            print(f'{f}: falta em {db}')
            tem = True
            continue
        d = difs(json.load(open(os.path.join(da, f), encoding='utf-8')), json.load(open(fb, encoding='utf-8')))
        num = [abs(x[1] - x[2]) for x in d if len(x) == 3 and isinstance(x[1], (int, float)) and isinstance(x[2], (int, float))]
        print(f'{f:42s} {len(d):>5d} diferenças' + (f'  maior numérica {max(num):.4f}' if num else ''))
        for x in d[:4]:
            print('    ', x)
        tem = tem or bool(d)
    sys.exit(1 if tem else 0)


if __name__ == '__main__':
    main()

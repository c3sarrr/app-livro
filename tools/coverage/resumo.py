"""Resumo de cobertura por pasta a partir de coverage/lcov.info (gerado por `flutter test --coverage`).

PROMPT MESTRE §4.5: cobertura ≥ 85 % em `domain/` e `application/` dos módulos novos.

Uso:  python3 tools/coverage/resumo.py [--minimo 85] prefixo [prefixo ...]
      ex.: python3 tools/coverage/resumo.py lib/core/data lib/features/library/domain
Sai com código 1 se algum prefixo ficar abaixo do mínimo.
"""
import argparse
import pathlib
import sys


def ler_lcov(caminho):
    arquivos = {}
    atual = None
    for linha in pathlib.Path(caminho).read_text(encoding='utf-8').splitlines():
        if linha.startswith('SF:'):
            atual = linha[3:].replace('\\', '/')
            arquivos[atual] = [0, 0]
        elif linha.startswith('DA:') and atual:
            _, hits = linha[3:].split(',')[:2]
            arquivos[atual][0] += 1
            arquivos[atual][1] += 1 if int(hits) > 0 else 0
    return arquivos


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--minimo', type=float, default=85.0)
    ap.add_argument('--lcov', default='coverage/lcov.info')
    ap.add_argument('prefixos', nargs='+')
    a = ap.parse_args()
    arquivos = ler_lcov(a.lcov)
    falhou = False
    for prefixo in a.prefixos:
        sel = {f: v for f, v in arquivos.items() if prefixo in f and not f.endswith('.g.dart')}
        total = sum(v[0] for v in sel.values())
        cobertas = sum(v[1] for v in sel.values())
        pct = 100.0 * cobertas / total if total else 0.0
        ok = pct >= a.minimo
        falhou |= not ok
        print(f'{"OK " if ok else "BAIXA"} {pct:6.2f} %  {cobertas:5d}/{total:<5d}  {prefixo}  ({len(sel)} arquivos)')
        for f, (t, c) in sorted(sel.items(), key=lambda kv: kv[1][1] / max(kv[1][0], 1)):
            if t and 100.0 * c / t < a.minimo:
                print(f'        {100.0 * c / t:6.2f} %  {c}/{t}  {f}')
    sys.exit(1 if falhou else 0)


if __name__ == '__main__':
    main()

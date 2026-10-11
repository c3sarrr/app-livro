#!/usr/bin/env python3
"""T13.9 (D-272) — onde a tela deixa de ser fluida nas outras larguras: cada id medido a 360 e a 430 contra o mesmo id
a 390 (o conjunto base, `conjuntoBase` no conjuntos.json). É informação para a etapa da tela, não um gate.

Problemas (no eixo x ou y, em px; o que é novo ou maior que a 390 por mais de TOL — `novo` = não acontecia a 390;
o que já acontecia e só cresce com a largura é do desenho, como a fileira que rola e perde mais 30 px a 360):
  sai do quadro     — a caixa passa da borda do quadro (o quadro corta). Só o de fora: o filho que sai junto com o
                      pai (por até o mesmo tanto) não entra;
  passa do pai      — a caixa passa da caixa do pai medido (o pai de verdade, pela árvore do template): `cortado` se o
                      pai tem overflow hidden/clip, `rola` se auto/scroll, `vaza` se visible;
  texto passa       — uma linha de texto passa da caixa do próprio elemento (sem reticências: com elas, é o efeito);
  invade o vizinho  — dois irmãos (o mesmo pai) na mesma fileira passam a se sobrepor, sem se sobrepor a 390 (camadas
                      do desenho, como o escurecido sob a folha, crescem com a largura); trecho inline fica fora (a
                      caixa dele é a união das linhas);
  reticências       — o texto passa a não caber e vira "…".
Cada item diz se o elemento (e o pai ou o vizinho) tem largura fixa (a mesma nas três larguras, ±0,01).

Saída: <pasta das medições>/fluidez.json — {tela: [itens]} na ordem do índice, todas as telas (lista vazia = fluida).
Uso: CONJUNTO=projeto_larguras python3 tools/medicao/fluidez.py
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import AQUI, C, RAIZ, caminho, indice  # noqa: E402
from esboco import esboco  # noqa: E402

TOL = 0.05
ESPECIAIS = ('frame', 'main')
CORTE = {'hidden': 'cortado', 'clip': 'cortado', 'auto': 'rola', 'scroll': 'rola'}


def lay(pasta, slug):
    with open(os.path.join(pasta, f'layout_{slug}.json'), encoding='utf-8') as f:
        return json.load(f)['elements']


def caixa(e):
    x, y, w, h = e['abs']
    return x, y, x + w, y + h


def fora(dentro, fora_):
    """Quanto a caixa `dentro` passa da caixa `fora_` em x e em y (0 = cabe)."""
    (a0, b0, a1, b1), (c0, d0, c1, d1) = dentro, fora_
    return max(0.0, c0 - a0, a1 - c1), max(0.0, d0 - b0, b1 - d1)


def r2(v):
    return round(v + 0.0, 2)


def pais(base, els):
    """id → o id do ancestral medido mais próximo (pela árvore do template; None no quadro)."""
    tpl_id = {e['tpl']: k for k, e in els.items()}
    nos = {n['tpl']: n for n in esboco(base)}
    out = {}
    for k, e in els.items():
        t = nos[e['tpl']]['parent']
        while t is not None and t not in tpl_id:
            t = nos[t]['parent']
        out[k] = tpl_id.get(t)
    return out


def analisar(p, larguras, el0):
    W, H = p['canvas']
    el = larguras[W]
    pre = p['prefixo']
    pai = pais(p['base'], el)
    quadro = (0.0, 0.0, float(W), float(H))
    quadro0 = (0.0, 0.0, 390.0, float(H))
    especial = {f'{pre}.{s}' for s in ESPECIAIS}

    def fixa(k):
        ws = [e[k]['abs'][2] for e in (*larguras.values(), el0)]
        return max(ws) - min(ws) <= 0.01

    itens = []

    def item(k, tipo, eixo, px, px0, **extra):
        itens.append({'id': k, 'tipo': tipo, 'eixo': eixo, 'px': r2(px), 'px390': r2(px0), 'novo': px0 <= TOL,
                      'larguraFixa': fixa(k), **extra})

    ids = [k for k, e in el.items() if 'section' in e]
    for k in ids:
        e, e0 = el[k], el0[k]
        b, b0 = caixa(e), caixa(e0)
        # sai do quadro (só o de fora: o filho que sai junto com o pai não entra)
        q, q0 = fora(b, quadro), fora(b0, quadro0)
        pk = pai[k]
        qp = fora(caixa(el[pk]), quadro) if pk and pk not in especial else (0.0, 0.0)
        for i, eixo in enumerate('xy'):
            if q[i] > q0[i] + TOL and q[i] > qp[i] + TOL:
                item(k, 'sai do quadro', eixo, q[i], q0[i])
        # passa do pai
        if pk and pk not in especial:
            f, f0 = fora(b, caixa(el[pk])), fora(b0, caixa(el0[pk]))
            ov = el[pk].get('style', {}).get('overflow', 'visible')
            for i, eixo in enumerate('xy'):
                if f[i] > f0[i] + TOL:
                    item(k, 'passa do pai', eixo, f[i], f0[i], pai=pk, corte=CORTE.get(ov, 'vaza'),
                         paiLarguraFixa=fixa(pk))
        # texto passa da caixa do próprio elemento
        if e.get('lines') and not e.get('ellipsis'):
            def tx(rec, bx):
                return max(0.0, bx[0] - min(ln['left'] for ln in rec['lines']),
                           max(ln['right'] for ln in rec['lines']) - bx[2])
            t, t0 = tx(e, b), tx(e0, b0)
            if t > t0 + TOL:
                item(k, 'texto passa', 'x', t, t0)
        if e.get('ellipsis') and not e0.get('ellipsis'):
            item(k, 'reticências', 'x', 0, 0)
    # irmãos na mesma fileira que passam a se sobrepor
    filhos = {}
    for k in ids:
        filhos.setdefault(pai[k], []).append(k)
    for irmaos in filhos.values():
        for i, a in enumerate(irmaos):
            for c in irmaos[i + 1:]:
                def sob(els):
                    A, B = caixa(els[a]), caixa(els[c])
                    if min(A[3], B[3]) - max(A[1], B[1]) <= 1:
                        return 0.0
                    return max(0.0, min(A[2], B[2]) - max(A[0], B[0]))
                if 'inline' in (el[a]['type'], el[c]['type']):
                    continue
                s, s0 = sob(el), sob(el0)
                if s > TOL and s0 <= TOL:
                    item(a, 'invade o vizinho', 'x', s, s0, vizinho=c, vizinhoLarguraFixa=fixa(c))
    return itens


def main():
    idx = indice()['pranchas']
    with open(os.path.join(AQUI, 'conjuntos.json'), encoding='utf-8') as f:
        base = json.load(f)[C['conjuntoBase']]
    lay_base = os.path.join(RAIZ, *base['layout'].split('/'))
    out = {}
    for p in idx:
        irmas = {q['largura']: lay(caminho('layout'), q['slug']) for q in idx if q['base'] == p['base']}
        itens = analisar(p, irmas, lay(lay_base, p['base']))
        out[p['slug']] = itens
        resumo = {}
        for it in itens:
            resumo[it['tipo']] = resumo.get(it['tipo'], 0) + 1
        print(f"{p['slug']:40s} {len(itens):3d} {resumo if resumo else 'fluida'}")
    doc = {'_doc': __doc__.strip().split('\n\n')[0].replace('\n', ' '), 'TOL': TOL, 'telas': out}
    with open(os.path.join(os.path.dirname(caminho('layout')), 'fluidez.json'), 'w', encoding='utf-8',
              newline='\n') as f:
        json.dump(doc, f, ensure_ascii=False, indent=1)
        f.write('\n')


if __name__ == '__main__':
    main()

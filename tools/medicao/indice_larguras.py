#!/usr/bin/env python3
"""T13.9 (D-272) — o índice das larguras de um conjunto: cada prancha do índice base vira uma entrada por largura, que
abre a extração e o idmap da prancha base e troca a largura do quadro antes de medir e fotografar (CSS fluido, como a
T03 fez com a 01 em pranchas_inicio2_larguras.json).

Vai para cada entrada: tela `<tela>w<L>`, slug `<slug>_w<L>`, base = o slug base, o prefixo, a etapa, o arquivo, o
título com a largura, o canvas com a largura trocada (a altura do quadro não muda), `largura`, as fontes de reserva
declaradas (R8: o texto é o mesmo) e o zoom da referência (D-279: o arredondamento é da tela, não da largura). A
faixa da R3 (`convergenciaFaixa`) não vai: o defeito de raster cai em outro lugar quando a largura muda — cada largura
ganha a sua, com o motivo, se o gate pedir.

Uso: python3 tools/medicao/indice_larguras.py <índice base> <índice das larguras> <largura>…
     (o projeto: tools/medicao/pranchas_projeto.json tools/medicao/pranchas_projeto_larguras.json 360 430)
Refazer o índice mantém as faixas da R3 já gravadas nele.
"""
import json
import os
import sys

COPIAR = ['prefixo', 'etapa', 'arquivo']
ZOOM = ['zoomBase', 'zoomConvergencia', '_zoom']
R3 = ['convergenciaFaixa', '_convergencia']


def ler(arq):
    with open(arq, encoding='utf-8') as f:
        return json.load(f)


def main():
    base_arq, saida, larguras = sys.argv[1], sys.argv[2], [int(x) for x in sys.argv[3:]]
    if not larguras:
        sys.exit(__doc__)
    base = ler(base_arq)
    antigas = {}
    if os.path.exists(saida):
        antigas = {p['slug']: p for p in ler(saida)['pranchas']}
    out = {'_doc': (f'T13.9 (D-272) — as pranchas de {base_arq} a {", ".join(map(str, larguras))} px de largura: cada '
                    'entrada abre a extração e o idmap de "base" e troca a largura do quadro para "largura" antes de '
                    'medir e fotografar (CSS fluido, como a T03). Gerado por tools/medicao/indice_larguras.py (não '
                    'editar à mão, salvo as faixas da R3, que ele mantém).')}
    out.update({k: v for k, v in base.items() if k not in ('_doc', 'pranchas')})
    out['pranchas'] = []
    for p in base['pranchas']:
        for L in larguras:
            q = {'tela': f"{p['tela']}w{L}", 'slug': f"{p['slug']}_w{L}", 'base': p['slug']}
            q.update({k: p[k] for k in COPIAR if k in p})
            q['titulo'] = f"{p['titulo']} — largura {L}"
            q['canvas'] = [L, p['canvas'][1]]
            q['largura'] = L
            q['previa'] = ''
            if 'reserva' in p:
                q['reserva'] = p['reserva']
            q.update({k: p[k] for k in ZOOM if k in p})
            velha = antigas.get(q['slug'], {})
            q.update({k: velha[k] for k in R3 if k in velha})
            out['pranchas'].append(q)
    with open(saida, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print(f"{saida}: {len(out['pranchas'])} pranchas ({len(base['pranchas'])} × {len(larguras)} larguras)")


if __name__ == '__main__':
    main()

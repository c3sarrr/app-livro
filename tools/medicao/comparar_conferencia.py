#!/usr/bin/env python3
"""T13.3 (R3) — a prova da ferramenta: as 19 telas que já tinham medição (01, 01b, 60–63 e 19–27b), extraídas do
projeto (`.dc.html`) e medidas de novo (`CONJUNTO=projeto_conferencia_<grupo> ATE=referencias rodar_tudo.sh`),
comparadas com o que está commitado (`compararCom` do conjunto).

- layout (`layout_*.json`, `text_dependency.json`, `knife_edges.json`): campo a campo. Mudam pelo método, e saem
  da comparação estrita com a descrição no relatório: no `meta`, a origem (`source`) e a frase do método
  (`measuredWith`); e a lista `fontFaces` (as `@font-face` com binário local) — a exportação antiga embutia as faces
  que o navegador tinha carregado (na Início, também o latin-ext da Figtree), a extração nova embute todas as faces
  latin da consulta. As fontes que cada nó usa de fato (`platformFonts`, dentro dos elementos) entram na comparação.
- PNGs (telas @1x/@2x/@3x, recortes por seção, redlines): byte a byte; os `elementos/` saem do
  `recortes_elementos.py`, que roda depois das referências e fica fora da prova. Num redline diferente, a diferença
  é explicada só se todo pixel diferente estiver dentro de um rótulo numerado (os números usam a 1ª face da Figtree
  do layout, que é uma das `fontFaces`); o relatório diz se cada face dos rótulos tem os dígitos.
- idmaps e referências Dart geradas: byte a byte (no índice Dart da Início, a linha do título cita o projeto).
Saída: `docs/design/medicao/projeto/conferencia_medicao.md`; código 1 se algo diferir sem explicação.
Rodar no WSL (Pillow, numpy e fontTools): MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'python3 tools/medicao/comparar_conferencia.py'
"""
import hashlib
import json
import os
import sys

import numpy as np
from fontTools.ttLib import TTFont
from PIL import Image

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.normpath(os.path.join(AQUI, '..', '..'))
SAIDA = os.path.join(RAIZ, 'docs', 'design', 'medicao', 'projeto', 'conferencia_medicao.md')
META_ESPERADA = {'source', 'measuredWith'}
S = 3  # escala dos recortes e redlines (recortar.py)
ROTULO = (72, 42)  # px @3x: maior caixa de rótulo possível (3 dígitos a 27 px + 6 de folga), a partir do canto


def abs_(rel):
    return os.path.join(RAIZ, *rel.split('/'))


def sha(caminho):
    with open(caminho, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()


def carregar(caminho):
    with open(caminho, encoding='utf-8') as f:
        return json.load(f)


def diferencas(a, b, caminho='', out=None):
    """Caminhos onde dois JSON diferem (no máximo 20)."""
    out = [] if out is None else out
    if len(out) >= 20:
        return out
    if isinstance(a, dict) and isinstance(b, dict):
        for k in sorted(set(a) | set(b)):
            if k not in a or k not in b:
                out.append(f'{caminho}/{k} só de um lado')
            else:
                diferencas(a[k], b[k], f'{caminho}/{k}', out)
    elif isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            out.append(f'{caminho}: {len(a)} × {len(b)} itens')
        for i, (x, y) in enumerate(zip(a, b)):
            diferencas(x, y, f'{caminho}[{i}]', out)
    elif a != b:
        out.append(f'{caminho}: {str(a)[:60]} × {str(b)[:60]}')
    return out


def subconjunto(cmap):
    """O subconjunto do Google pelo que o binário cobre: o latin-ext tem o 'Ā' (e também mapeia letras básicas, as
    bases dos acentos); o latin tem o 'A' e não o 'Ā'."""
    return 'latin-ext' if 0x100 in cmap else 'latin' if 0x41 in cmap else 'outro'


def face(extracao, slug, f):
    """(descrição, tem os dígitos) de uma `fontFace` do layout, pelo binário local."""
    cmap = TTFont(os.path.join(extracao, slug, 'assets', f['asset'] + '.woff2')).getBestCmap()
    w = f['weight'][0] if f['weight'][0] == f['weight'][1] else f"{f['weight'][0]}–{f['weight'][1]}"
    return f"{f['family']} {f['style']} {w} ({subconjunto(cmap)})", all(c in cmap for c in range(0x30, 0x3A))


def normalizar_layout(d):
    """O layout sem o que muda pelo método: `meta.source`/`measuredWith` e a lista `fontFaces` (devolvidos à parte)."""
    d = json.loads(json.dumps(d))
    meta = {k: d['meta'].pop(k) for k in META_ESPERADA if k in d.get('meta', {})}
    return d, meta, d.pop('fontFaces', [])


def rotulo_de(layout_dir, extracao, slugs):
    """A face dos números dos redlines, como recortar.fonte_rotulo: a 1ª Figtree do layout da 20 (leitor) ou da 1ª
    prancha que a declara."""
    for slug in (['20_leitor_controles'] if '20_leitor_controles' in slugs else slugs):
        for f in carregar(os.path.join(layout_dir, f'layout_{slug}.json'))['fontFaces']:
            if f['family'] == 'Figtree':
                return face(extracao, slug, f)
    return None


def mascara_rotulos(legenda, layout_dir, fase, forma):
    """Os cantos de cada id numerado no redline da fase (onde o recortar.py desenha o rótulo)."""
    info = legenda[fase]
    els = carregar(os.path.join(layout_dir, f"layout_{info['prancha']}.json"))['elements']
    y0 = info['recorte_y'][0]
    m = np.zeros(forma, bool)
    for _, k, _ in info['itens']:
        x, y = (els[k].get('vis') or els[k]['abs'])[:2]
        rx, ry = int(x * S), int((y - y0) * S)
        m[max(ry, 0):ry + ROTULO[1], max(rx, 0):rx + ROTULO[0]] = True
    return m


def comparar_png(a, b, mascara=None):
    """None = iguais; senão (texto, explicada): explicada = todo pixel diferente está dentro da máscara."""
    if sha(a) == sha(b):
        return None
    ia, ib = np.asarray(Image.open(a).convert('RGBA')), np.asarray(Image.open(b).convert('RGBA'))
    if ia.shape != ib.shape:
        return f'tamanho {ia.shape[1]}×{ia.shape[0]} × {ib.shape[1]}×{ib.shape[0]}', False
    d = np.abs(ia.astype(int) - ib.astype(int)).max(axis=2) > 0
    texto = f'{int(d.sum())} px diferentes'
    if mascara is None:
        return texto, False
    fora = int((d & ~mascara(d.shape)).sum())
    return texto + f', {fora} fora dos rótulos', fora == 0


def main():
    todos = carregar(os.path.join(AQUI, 'conjuntos.json'))
    linhas, ruins = [], 0
    for grupo, antigo in (('inicio2', 'inicio2'), ('leitor', 'leitor')):
        C = todos[f'projeto_conferencia_{grupo}']
        ref = C['compararCom']
        ext_nova, ext_velha = abs_(C['extracao']), abs_(todos[antigo]['extracao'])
        idx = carregar(abs_(C['indice']))
        slugs = [p['slug'] for p in idx['pranchas']]
        cont = {'layout': [0, 0], 'png': [0, 0], 'idmaps': [0, 0], 'dart': [0, 0]}
        problemas, explicadas, metas = [], [], set()
        faces = {'antes': {}, 'agora': {}}
        # layout
        for f in sorted(os.listdir(abs_(ref['layout']))):
            novo = os.path.join(abs_(C['layout']), f)
            cont['layout'][0] += 1
            if not os.path.exists(novo):
                problemas.append(f'layout/{f} não foi gerado')
                continue
            a, b = carregar(os.path.join(abs_(ref['layout']), f)), carregar(novo)
            if f.startswith('layout_'):
                slug = f[len('layout_'):-len('.json')]
                a, ma, fa = normalizar_layout(a)
                b, mb, fb = normalizar_layout(b)
                metas |= {f'{k}: {ma.get(k)!s:.40} → {mb.get(k)!s:.60}' for k in META_ESPERADA if ma.get(k) != mb.get(k)}
                for lado, ext, lista in (('antes', ext_velha, fa), ('agora', ext_nova, fb)):
                    faces[lado][slug] = [face(ext, slug, x)[0] for x in lista]
            d = diferencas(a, b)
            if d:
                problemas.append(f'layout/{f}: ' + '; '.join(d[:5]))
            else:
                cont['layout'][1] += 1
        # PNGs (telas, seções, redlines; elementos/ fica de fora)
        base_ref = abs_(ref['png'])
        legenda = carregar(os.path.join(abs_(C['png']), 'redline', 'legenda.json'))
        for raiz, _, fs in os.walk(base_ref):
            rel = os.path.relpath(raiz, base_ref)
            if rel.split(os.sep)[0] == 'elementos':
                continue
            for f in sorted(fs):
                if not any(f.startswith(s) for s in slugs) and rel == '.':
                    continue
                cont['png'][0] += 1
                novo = os.path.join(abs_(C['png']), rel, f)
                if not os.path.exists(novo):
                    problemas.append(f'png/{rel}/{f} não foi gerado')
                    continue
                fase = f[:-len('_redline@3x.png')] if rel == 'redline' and f.endswith('_redline@3x.png') else None
                masc = (lambda forma, fase=fase: mascara_rotulos(legenda, abs_(C['layout']), fase, forma)) if fase else None
                r = comparar_png(os.path.join(raiz, f), novo, masc)
                if r is None:
                    cont['png'][1] += 1
                elif r[1]:
                    explicadas.append(f'png/{rel}/{f}: {r[0]}')
                else:
                    problemas.append(f'png/{rel}/{f}: {r[0]}')
        # idmaps
        for s in slugs:
            cont['idmaps'][0] += 1
            a, b = os.path.join(abs_(ref['idmaps']), f'{s}.json'), os.path.join(abs_(C['idmaps']), f'{s}.json')
            if os.path.exists(b) and sha(a) == sha(b):
                cont['idmaps'][1] += 1
            else:
                problemas.append(f'idmaps/{s}.json difere')
        # referências Dart geradas (os *_test.dart são escritos à mão)
        for f in sorted(os.listdir(abs_(ref['dart']))):
            if not f.endswith('.dart') or f.endswith('_test.dart'):
                continue
            a, b = os.path.join(abs_(ref['dart']), f), os.path.join(abs_(C['dart']), f)
            cont['dart'][0] += 1
            if not os.path.exists(b):
                problemas.append(f'dart/{f} não foi gerado')
                continue
            la, lb = open(a, encoding='utf-8').read().splitlines(), open(b, encoding='utf-8').read().splitlines()
            dif = [i for i, (x, y) in enumerate(zip(la, lb)) if x != y]
            titulo = [i for i in dif if la[i].startswith('// Índice das referências') and 'projeto' in lb[i]]
            if len(la) != len(lb) or set(dif) - set(titulo):
                problemas.append(f'dart/{f}: {len(set(dif) - set(titulo))} linhas diferentes')
            else:
                cont['dart'][1] += 1
                if titulo:
                    metas.add(f'{f}: a linha do título cita o projeto')
        rotulos = (rotulo_de(abs_(ref['layout']), ext_velha, slugs), rotulo_de(abs_(C['layout']), ext_nova, slugs))
        ruins += len(problemas)
        linhas.append((grupo, idx, cont, problemas, explicadas, sorted(metas), faces, rotulos))
    with open(SAIDA, 'w', encoding='utf-8', newline='\n') as f:
        f.write('# Conferência — as telas já medidas, medidas de novo pelo projeto (`.dc.html`)\n\n'
                '> Gerado por `tools/medicao/comparar_conferencia.py` (T13.3, R3). Não editar à mão: rodar de novo.\n'
                '> As telas extraídas do projeto por `extrair_dc.py` e medidas com o pipeline da G01/T02 '
                '(`CONJUNTO=projeto_conferencia_<grupo> ATE=referencias`), contra o que está commitado. Os layouts '
                'são comparados campo a campo sem o que muda pelo método (a origem, a frase do método e a lista '
                '`fontFaces`, descrita abaixo); as fontes que cada nó usa de fato (`platformFonts`) entram na '
                'comparação.\n\n'
                '| Grupo | Telas | Layouts iguais | PNGs iguais | PNGs com diferença explicada | idmaps iguais | '
                'Referências Dart iguais |\n|---|---|---|---|---|---|---|\n')
        for grupo, idx, cont, problemas, explicadas, metas, faces, rotulos in linhas:
            c = list(cont.values())
            f.write(f"| {grupo} | {len(idx['pranchas'])} | {c[0][1]}/{c[0][0]} | {c[1][1]}/{c[1][0]} | "
                    f"{len(explicadas)} | {c[2][1]}/{c[2][0]} | {c[3][1]}/{c[3][0]} |\n")
        for grupo, idx, cont, problemas, explicadas, metas, faces, rotulos in linhas:
            f.write(f'\n## {grupo}\n\n')
            f.write('O que muda por definição (a origem é outro arquivo):\n\n' + ''.join(f'- {m}\n' for m in metas) + '\n')
            f.write('As faces com binário local (`fontFaces`), antes → agora (só as telas em que mudam):\n\n')
            mudam = [s for s in faces['antes'] if faces['antes'][s] != faces['agora'].get(s)]
            for s in mudam:
                so_a = [x for x in faces['antes'][s] if x not in faces['agora'][s]]
                so_b = [x for x in faces['agora'][s] if x not in faces['antes'][s]]
                f.write(f"- {s}: {len(faces['antes'][s])} → {len(faces['agora'][s])}"
                        + (f"; só antes: {', '.join(so_a)}" if so_a else '') + (f"; só agora: {', '.join(so_b)}" if so_b else '') + '\n')
            if not mudam:
                f.write('- nenhuma tela muda.\n')
            f.write('\nA face dos números dos redlines (a 1ª Figtree do layout, `recortar.py`): '
                    + ' → '.join(f"{r[0]}, {'com' if r[1] else '**sem**'} os dígitos" if r else '—' for r in rotulos) + '.\n\n')
            if explicadas:
                f.write('Diferenças explicadas (todo pixel diferente dentro de um rótulo numerado do redline):\n\n'
                        + ''.join(f'- {e}\n' for e in explicadas) + '\n')
            f.write('Diferenças sem explicação: ' + ('nenhuma.\n' if not problemas else '\n\n' + ''.join(f'- {p}\n' for p in problemas)))
    print(open(SAIDA, encoding='utf-8').read())
    return 1 if ruins else 0


if __name__ == '__main__':
    sys.exit(main())

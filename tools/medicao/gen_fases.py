#!/usr/bin/env python3
"""G01.9 — gera os arquivos de fase L19…L27b em handoff_v2/fases/ no formato da v1
(design_handoff/fases/F05_hero_continuar_lendo.md): HTML literal, tabela pixel a pixel (Nº do redline),
linhas de texto com baseline, leitura de designer, semântica, widgets sugeridos, armadilhas, diferenças em
relação à prancha base (23/23b/24/24b × 22; 26b × 20), subfases, testes e checklist.
Parte medida: layout/*.json, text_dependency/knife_edges, png/redline/legenda.json, mapa_widgets.json,
svg_catalogo.json. Parte escrita à mão: tools/medicao/fases_notas.py.
Uso: [CONJUNTO=inicio2] python3 tools/medicao/gen_fases.py
T02: as pastas, as notas (fasesNotas), a trilha e o índice vêm do conjunto (conjuntos.json).
T13.12 (projeto): as props de cada tela no CSS literal (a mesma prop tem outro padrão noutra tela: o halo da 17 e da
17b); a seção "Nas outras larguras" (a fluidez e os fios de navalha a 360 e 430 da T13.9, das saídas do conjunto das
larguras); o teste das larguras; o nome da fase que gera. Os outros conjuntos saem com os mesmos bytes.
"""
import importlib
import json
import os
import re
import sys
import textwrap

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import NOME, C, caminho, indice  # noqa: E402
from esboco import esboco  # noqa: E402

NOTAS = importlib.import_module(C['fasesNotas']).NOTAS
AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
LAYOUT, PNG = caminho('layout'), caminho('png')
OUT = caminho('fases')
PR = {p['slug']: p for p in indice()['pranchas']}
FASES = json.load(open(caminho('fasesIndice'), encoding='utf-8'))['fases']
LEG = json.load(open(os.path.join(PNG, 'redline', 'legenda.json'), encoding='utf-8'))
DEP = json.load(open(os.path.join(LAYOUT, 'text_dependency.json'), encoding='utf-8'))
KNI = json.load(open(os.path.join(LAYOUT, 'knife_edges.json'), encoding='utf-8'))
MAPA = json.load(open(caminho('mapa'), encoding='utf-8'))
PROPS_PADRAO = {'paper': '#F8F1E4', 'brand': '#B6ACE4', 'ink': '#FF552E', 'weekColor': '#B6ACE4'}
# como as fases citam as referências: no leitor, relativo a handoff_v2/ (como na G01); nos outros, a partir da raiz
REF_PNG = 'referencia/png' if not C['png'].startswith('docs/') else C['png']
REF_LAYOUT = 'referencia/layout' if not C['layout'].startswith('docs/') else C['layout']
REF_DART = 'test/reference/leitor' if C['dart'].startswith('tools/') else C['dart']
PROJETO = NOME == 'projeto'
# T13.12: as fases do leitor (handoff_v2, só leitura, e as conferências dele — os mesmos conjuntos do leitor no
# rodar_tudo.sh) saem como na G01 (G01 305/305); as três correções da T13.12 valem para a Início e o projeto: a caixa
# visual dos elementos com transform com os números (saía "{fmt(...)}" literal), o bloco só do elemento quando outro
# vem antes na mesma linha (html_literal) e a linha "Nenhuma diferença" quando a seção reaproveitada não muda nada
LEGADO_G01 = NOME in ('leitor', 'leitor_conferencia', 'projeto_conferencia_leitor')
GERADO_EM = 'T13.12' if PROJETO else 'G01.9'
MAPA_DE = 'T13.12' if PROJETO else 'G01.10'
# T13.9: o conjunto das larguras do projeto (a fluidez e os fios de navalha a 360 e 430)
LARG = None
if PROJETO:
    with open(os.path.join(AQUI, 'conjuntos.json'), encoding='utf-8') as _fh:
        _todos = json.load(_fh)
    _cl = next(v for v in _todos.values() if isinstance(v, dict) and v.get('conjuntoBase') == NOME)
    LARG = {'layout': _cl['layout'], 'dart': _cl['dart'],
            'fluidez': json.load(open(os.path.join(RAIZ, os.path.dirname(_cl['layout']), 'fluidez.json'), encoding='utf-8'))['telas'],
            'facas': json.load(open(os.path.join(RAIZ, _cl['layout'], 'knife_edges.json'), encoding='utf-8'))}


def tags(t):
    """No projeto (T13.12), as tags (`<rect>`, `<text>`…) do texto entre crases: o Markdown as leria como HTML."""
    return re.sub('(?<!`)(<[A-Za-z/][^<>`]*>)(?!`)', lambda m: '`' + m.group(1) + '`', t) if PROJETO else t


def fmt(v):
    s = f'{v:.2f}'.rstrip('0').rstrip('.')
    return s if s != '-0' else '0'


def esc(s):
    return s.replace('|', '\\|')


def tipografia(e):
    f = e.get('style', {}).get('font')
    if not f:
        return ''
    fam = {'Bricolage Grotesque': 'Bricolage', 'Instrument Serif': 'Instrument Serif'}.get(f['family'], f['family'])
    op = f" (opsz {fmt(f['opsz'])})" if 'opsz' in f else ''
    it = ' itálico' if f['style'] == 'italic' else ''
    w = f['weightCss'] if f['weightRendered'] == f['weightCss'] else f"{f['weightCss']}→**{f['weightRendered'] or 800}**"
    ex = ' tnum' if 'tnum' in f.get('features', []) else ''
    return f"{fam}{op}{it} {fmt(f['size'])}/{f['lineHeight']} peso {w} ls {f['letterSpacing']} {f['color']}{ex}"


def css_lit(css, props=PROPS_PADRAO):
    css = re.sub(r'\{\{(\w+)\}\}', lambda m: f'{{{{{m.group(1)}}}}} (padrão {props.get(m.group(1), "?")})', css)
    return esc(css) if css else '—'


def html_literal(slug, ids_secoes, im, sem_elemento=None):
    nodes = {n['tpl']: n for n in esboco(slug)}
    tpl_of = {v: int(k) for k, v in im['ids'].items()}
    # T13.5: a seção sem contêiner (a Busca) entra pelos ids de topo dela, na ordem do arquivo
    ids_secoes = [i for sid in ids_secoes for i in ((sem_elemento or {}).get(sid) or [sid])]
    with open(caminho('extracao', slug, 'template.html'), encoding='utf-8') as _fh:
        texto = _fh.read()
    partes, vistos = [], []
    for sid in ids_secoes:
        t = tpl_of[sid]
        # pula seções que já estão dentro de outra seção desta fase (ex.: página dentro do véu não ocorre, mas por garantia)
        if any(nodes[t]['ini'] >= nodes[v]['ini'] and nodes[t]['fim'] <= nodes[v]['fim'] for v in vistos):
            continue
        vistos.append(t)
        n = nodes[t]
        ini = texto.rfind('\n', 0, n['ini']) + 1
        recuo = texto[ini:n['ini']]
        # T13.12: outro elemento antes na mesma linha (os confetes da 16, ids de topo de uma seção sem contêiner): só
        # este elemento, com o recuo da linha — antes cada bloco levava junto os irmãos anteriores
        if not LEGADO_G01:
            recuo = recuo[:len(recuo) - len(recuo.lstrip())]
        bloco = recuo + texto[n['ini']:n['fim']]
        if n.get('comment'):
            bloco = recuo + f"<!-- {n['comment']} -->\n" + bloco
        partes.append(textwrap.dedent(bloco))
    return '\n\n'.join(partes)


def tabela_secao(L, sec, leg_idx, ids_com_widget, props=PROPS_PADRAO):
    sr = L['sections'][sec]
    W, H = L['meta']['canvas']
    linhas = [f"Seção `{sec}` — retângulo absoluto no canvas {W}×{H}: **x={fmt(sr[0])}, y={fmt(sr[1])}, w={fmt(sr[2])}, h={fmt(sr[3])}**. "
              'Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). '
              'Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.\n',
              '| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |',
              '|---|---|---|---|---|---|---|---|---|']
    extras = []
    for k, e in L['elements'].items():
        if e.get('section') != sec:
            continue
        x, y, w, h = e['rel']
        tol = ' ±1' if k in ids_com_widget else ''
        linhas.append(f"| {leg_idx.get(k, '—')} | `{k}`{tol} | {e['type']} | {fmt(x)} | {fmt(y)} | {fmt(w)} | {fmt(h)} | `{css_lit(e.get('css', ''), props)}` | {tipografia(e)} |")
        if e.get('vis'):
            v = e['vis']
            tf = e['style'].get('transform')
            # T13.12: o trecho dos números era string comum desde a G01 (saía "{fmt(...)}" literal, sem os números); o
            # leitor guarda esse texto (LEGADO_G01, acima)
            numeros = (f" = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])}" if not LEGADO_G01
                       else " = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])}")
            extras.append(f"- `{k}`: caixa visual " + (f"com `transform: {tf}`" if tf else 'deslocada pelo transform de um ancestral') + numeros + " (relativa à seção).")
    if extras:
        linhas += ['', '**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**'] + extras
    tl = []
    for k, e in L['elements'].items():
        if e.get('section') != sec or e['type'] == 'inline':
            continue
        fonte, rot = (e['linesAll'], ' *(composto)*') if e.get('linesAll') else (e.get('lines') or [], '')
        for i, ln in enumerate(fonte):
            nota = ' *(oculta: recortada)*' if ln.get('oculta') else ''
            tl.append(f"| `{k}`{rot} | {i + 1} | {esc(ln['text'])}{nota} | {fmt(ln['baseline'] - sr[1])} | {fmt(ln['left'] - sr[0])} | {fmt(ln['right'] - sr[0])} | {fmt(ln['right'] - ln['left'])} |")
    if tl:
        linhas += ['', '**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**', '',
                   '| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |', '|---|---|---|---|---|---|---|'] + tl
    return '\n'.join(linhas)


def diferencas(base_slug, slug, secoes, relativo=False):
    """Ids de mesmo nome (sem o prefixo) entre a prancha e a base cuja geometria/estilo/texto mudam.
    relativo (T02, reusa.relativoASecao): a seção que só muda de lugar (ex.: na 01b tudo abaixo do cartão da revisão
    sobe 205,15) vira uma linha só; os ids dela são comparados já descontado esse deslocamento."""
    with open(os.path.join(LAYOUT, f'layout_{base_slug}.json'), encoding='utf-8') as _fh:
        A = json.load(_fh)
    with open(os.path.join(LAYOUT, f'layout_{slug}.json'), encoding='utf-8') as _fh:
        B = json.load(_fh)
    pa, pb = PR[base_slug]['prefixo'], PR[slug]['prefixo']
    ea = {k[len(pa) + 1:]: v for k, v in A['elements'].items() if 'section' in v}
    eb = {k[len(pb) + 1:]: v for k, v in B['elements'].items() if 'section' in v}
    rows, so_a, so_b = [], [], []
    for s in secoes:
        ks = sorted(set(k for k in list(ea) + list(eb) if k == s or k.startswith(s + '.')), key=lambda k: (eb.get(k) or ea.get(k))['tpl'])
        dx = dy = 0.0
        if relativo and f'{pa}.{s}' in A['sections'] and f'{pb}.{s}' in B['sections']:
            sa_, sb_ = A['sections'][f'{pa}.{s}'], B['sections'][f'{pb}.{s}']
            dx, dy = sb_[0] - sa_[0], sb_[1] - sa_[1]
            if abs(dx) > 0.005 or abs(dy) > 0.005:
                rows.append(f"| `{pb}.{s}` (seção inteira) | {esc(f'muda de lugar: x {fmt(dx)}, y {fmt(dy)} (abaixo, os ids dela já descontado esse deslocamento)')} |")
        for k in ks:
            a, b = ea.get(k), eb.get(k)
            if a and not b:
                so_a.append(k)
                continue
            if b and not a:
                so_b.append(k)
                continue
            mud = []
            if any(abs(x + d - y) > 0.005 for x, y, d in zip(a['abs'], b['abs'], (dx, dy, 0, 0))):
                mud.append(f"retângulo {[fmt(x) for x in a['abs']]} → {[fmt(x) for x in b['abs']]}")
            sa, sb = dict(a.get('style', {})), dict(b.get('style', {}))
            for key in sorted(set(sa) | set(sb)):
                if sa.get(key) != sb.get(key):
                    va, vb = sa.get(key), sb.get(key)
                    if key == 'font' and va and vb:
                        dif = [f"{kk}: {va.get(kk)} → {vb.get(kk)}" for kk in sorted(set(va) | set(vb)) if va.get(kk) != vb.get(kk)]
                        mud.append('fonte ' + '; '.join(dif))
                    else:
                        mud.append(f"{key}: {json.dumps(va, ensure_ascii=False)} → {json.dumps(vb, ensure_ascii=False)}")
            ta = ' / '.join(l['text'] for l in (a.get('linesAll') or a.get('lines') or []))
            tb = ' / '.join(l['text'] for l in (b.get('linesAll') or b.get('lines') or []))
            if ta != tb:
                mud.append(f"texto «{ta[:60]}» → «{tb[:60]}»")
            if mud:
                rows.append(f"| `{pb}.{k}` | {esc('; '.join(mud))[:600]} |")
    return rows, so_a, so_b


def larguras(slug, ids_fase):
    """T13.9 (D-272): o que muda nesta fase a 360 e 430 — a fluidez (sai do quadro, passa do pai, texto passa,
    invade o vizinho, reticências) e os fios de navalha de cada largura, só dos ids da fase."""
    ids = set(ids_fase)
    linhas, facas = [], []
    for w in (360, 430):
        chave = f'{slug}_w{w}'
        for it in LARG['fluidez'].get(chave, []):
            if it['id'] not in ids:
                continue
            extra = []
            if it.get('pai'):
                extra.append(f"pai `{it['pai']}` ({it['corte']}{', largura fixa' if it.get('paiLarguraFixa') else ''})")
            if it.get('vizinho'):
                extra.append(f"vizinho `{it['vizinho']}`")
            linhas.append(f"| {w} | `{it['id']}` | {it['tipo']} ({it['eixo']}) | {fmt(it['px'])} | {fmt(it['px390'])} | "
                          f"{'**sim**' if it['novo'] else 'não'} | {'sim' if it['larguraFixa'] else 'não'} | {esc('; '.join(extra))} |")
        for k, info in LARG['facas'].get(chave, {}).items():
            if k not in ids:
                continue
            for r in info['riscos']:
                est = fmt(r['estouroComProxima']) if r['estouroComProxima'] is not None else '—'
                sob = f"{fmt(r['sobra'])} px" if r['sobra'] is not None else 'sem limite (não quebra ao crescer)'
                est_txt = (f'estouro com a próxima palavra {est} px' if r['estouroComProxima'] is not None
                           else 'sem palavra seguinte (D-275: a linha única quebra se crescer)')
                facas.append(f"- A {w}: fio de navalha em `{k}` linha {r['linha']} «{r['texto']}»: sobra {sob} · {est_txt}.")
    out = ['## Nas outras larguras (360 e 430 — T13.9, D-272)', '',
           f"Referências: `{LARG['layout']}/layout_{slug}_w{{360,430}}.json` · `{LARG['dart']}/reference_layout_{slug}_w{{360,430}}.dart`. "
           'Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com '
           'quanto passa e quanto já passava a 390.', '']
    if linhas:
        out += ['| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |',
                '|---|---|---|---|---|---|---|---|'] + linhas + ['']
    if facas:
        out += facas + ['']
    if not linhas and not facas:
        out += ['- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de '
                'navalha a 360 ou a 430.', '']
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    indice = []
    for fase in FASES:
        f, slug = fase['fase'], fase['prancha']
        p = PR[slug]
        n = NOTAS[f]
        with open(os.path.join(LAYOUT, f'layout_{slug}.json'), encoding='utf-8') as _fh:
            L = json.load(_fh)
        props = {**PROPS_PADRAO, **L['meta']['props']} if PROJETO else PROPS_PADRAO
        with open(caminho('idmaps', f'{slug}.json'), encoding='utf-8') as _fh:
            im = json.load(_fh)
        secoes = [f"{p['prefixo']}.{s}" for s in fase['secoes']]
        leg_idx = {k: i for i, k, _ in LEG[f]['itens']}
        dep = DEP[slug]
        tdx = {k for k, v in dep.items() if v['x'] or v['w']}
        W, H = p['canvas']
        y0, y1 = LEG[f]['recorte_y']
        ids_fase = [k for k, e in L['elements'].items() if e.get('section') in secoes]
        out = [f"# FASE {f.split('_')[0]} — {fase['titulo']}", '',
               f"> Tela {p['tela']} · prancha `{slug}` ({p['titulo']}, canvas {W}×{H}) · executada na **{n['g']}** ({C['fasesTrilha']}).",
               f"> Referências: `{REF_PNG}/secoes/{f}@3x.png` · `{REF_PNG}/redline/{f}_redline@3x.png` (Nº = tabelas abaixo) · "
               f"`{REF_PNG}/{slug}_{W}x{H}@{{1,2,3}}x.png` · `{REF_LAYOUT}/layout_{slug}.json` · `{REF_DART}/reference_layout_{slug}.dart` (`kRef{p['tela']}`).",
               f"> Arquivos sugeridos: " + ', '.join(f'`lib/{a}`' for a in n['arquivos']) + '.',
               f"> Gerado por `tools/medicao/gen_fases.py` ({GERADO_EM}). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.", '',
               n['contexto'], '', '---', '',
               '## HTML literal da seção', '',
               ('Props do componente: ' + ', '.join(f"`{{{{{k}}}}}` = padrão `{v}`" for k, v in L['meta']['props'].items()) + '.'
                if L['meta']['props'] or not PROJETO else 'Props do componente: nenhuma (as cores desta tela são fixas).'), '',
               '```html', html_literal(slug, secoes, im, L['meta'].get('secoesSemElemento')), '```', '',
               '## Especificação pixel a pixel', '']
        for s in secoes:
            out += [tabela_secao(L, s, leg_idx, tdx, props), '']
        out += ['`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).', '',
                '## Leitura de designer (detalhes críticos)', ''] + [f'{i + 1}. {t}' for i, t in enumerate(n['leitura'])] + ['']
        # armadilhas automáticas
        arm = list(n.get('armadilhas', []))
        # T13.12: as seções reaproveitadas da base (só no projeto) também são desta prancha, e o fio de navalha delas
        # é desta fase (a fileira do autor da 17b não cabia em nenhuma)
        reusadas = [f"{p['prefixo']}.{s}" for s in fase['reusa']['secoes']] if PROJETO and fase.get('reusa') else []
        for k, info in KNI.get(slug, {}).items():
            reusada = any(k == s or k.startswith(s + '.') for s in reusadas)
            if any(k == s or k.startswith(s + '.') for s in secoes) or reusada:
                onde = f" (seção reaproveitada da {PR[fase['reusa']['base']]['tela']}; o risco é desta prancha)" if reusada else ''
                for r in info['riscos']:
                    est = fmt(r['estouroComProxima']) if r['estouroComProxima'] is not None else '—'
                    est_txt = (f'estouro com a próxima palavra {est} px' if r['estouroComProxima'] is not None or not PROJETO
                               else 'sem palavra seguinte (D-275: a linha única quebra se crescer)')
                    # D-280: sobra null = a linha não quebra ao crescer
                    sob = f"{fmt(r['sobra'])} px" if r['sobra'] is not None else 'sem limite (não quebra ao crescer)'
                    if info.get('fileiras'):  # D-278: a fileira de um flex-wrap (projeto)
                        arm.append(f"Fio de navalha na fileira {r['linha']} de `{k}`{onde} (flex-wrap) «{r['texto']}»: sobra {fmt(r['sobra'])} px · estouro com o 1º item da fileira seguinte {est} px — no Flutter (`Wrap`), as fileiras mudam com uma diferença mínima de largura.")
                    else:
                        arm.append(f"Fio de navalha em `{k}`{onde} linha {r['linha']} «{r['texto']}»: sobra {sob} · {est_txt}.")
        for k in ids_fase:
            e = L['elements'][k]
            if e.get('fallback'):
                arm.append(f"`{k}` usa glifo de fonte do sistema ({', '.join(e['fallback'])}) — no navegador o resultado depende da máquina.")
            if e.get('style', {}).get('mask'):
                arm.append(f"`{k}` tem máscara `{e['style']['mask']}` → `ShaderMask`.")
            if e.get('style', {}).get('mixBlendMode'):
                arm.append(f"`{k}` usa `mix-blend-mode: {e['style']['mixBlendMode']}`.")
        ocultas = [k for k in ids_fase if any(l.get('oculta') for l in (L['elements'][k].get('lines') or []) + (L['elements'][k].get('linesAll') or []))]
        if ocultas:
            arm.append('Linhas recortadas por `overflow` (existem no layout, não aparecem): ' + ', '.join(f'`{k}`' for k in ocultas) + '.')
        out += ['## Armadilhas', ''] + ([f'- {tags(a)}' for a in arm] if arm else ['- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).']) + ['']
        if LARG:
            out += larguras(slug, ids_fase)
        # diferenças em relação à base
        if fase.get('reusa'):
            base = fase['reusa']['base']
            rows, so_a, so_b = diferencas(base, slug, fase['reusa']['secoes'], fase['reusa'].get('relativoASecao', False))
            out += [f"## Diferenças em relação à prancha {PR[base]['tela']} (seções reutilizadas: {', '.join(fase['reusa']['secoes'])})", '',
                    f"Estas seções são as mesmas widgets da {PR[base]['tela']} (fases {', '.join(sorted({x['fase'] for x in FASES if x['prancha'] == base}))}); "
                    'abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).', '']
            if rows:
                out += ['| Key | o que muda |', '|---|---|'] + rows + ['']
            if so_a:
                out += ['Só na base: ' + ', '.join(f'`{k}`' for k in so_a) + '.', '']
            if so_b:
                out += ['Só nesta prancha: ' + ', '.join(f'`{k}`' for k in so_b) + '.', '']
            if not LEGADO_G01 and not (rows or so_a or so_b):
                # T13.12: o título da 30 na 30c — sem esta linha a seção ficava só com o cabeçalho
                out += [f"Nenhuma diferença: todos os ids das seções reutilizadas são idênticos aos da {PR[base]['tela']}.", '']
        # semântica
        sem = [(k, MAPA[slug][k].get('semantica')) for k in ids_fase if MAPA[slug].get(k, {}).get('semantica')]
        if sem:
            out += ['## Semântica (do arquivo)', '', '| Key | role | rótulo | outros |', '|---|---|---|---|']
            for k, s in sem:
                outros = ', '.join(f'{a}={b}' for a, b in s.items() if a not in ('role', 'label'))
                out.append(f"| `{k}` | {s.get('role', '')} | {esc(s.get('label', ''))} | {esc(outros)} |")
            out.append('')
        # widgets
        wd = [(k, MAPA[slug][k]) for k in ids_fase if not MAPA[slug][k]['widget'].startswith('layout') and MAPA[slug][k]['widget'] != 'AppText']
        if wd:
            out += [f'## Widgets e pintores sugeridos (mapa da {MAPA_DE})', '',
                    'Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:', '',
                    '| Key | widget / pintor | observação |', '|---|---|---|']
            out += [f"| `{k}` | {esc(v['widget'])} | {esc(tags(v.get('obs', '')))} |" for k, v in wd] + ['']
        out += ['## Interações', ''] + [f'- {t}' for t in n['interacoes']] + ['', '## Dados', ''] + [f'- {t}' for t in n['dados']] + ['',
                '## Subfases', ''] + [f"- **{f.split('_')[0]}.{i + 1}** {t}" for i, t in enumerate(n['subfases'])] + ['']
        secs_txt = ', '.join(f"'{s}'" for s in secoes)
        out += ['## Testes da fase', '',
                f"- Geometria: para cada seção ({secs_txt}), todos os ids de `kRef{p['tela']}.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).",
                '- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.',
                '- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).',
                f"- Visual: golden da prancha contra `{REF_PNG}/{slug}_{W}x{H}@3x.png` no recorte da fase (y {fmt(y0)}–{fmt(y1)}) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).",
                '- Semântica: rótulos/roles da tabela acima (exceções da D-51).',
                '- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).'] + (
                [f"- Larguras: a mesma tela a 360 e a 430 contra `kRef{p['tela']}w360` e `kRef{p['tela']}w430` (`{LARG['dart']}/`), "
                 'com as tolerâncias da geometria.'] if LARG else []) + ['',
                '## Checklist de aceite', ''] + [f"- [ ] {f.split('_')[0]}.{i + 1} {t}" for i, t in enumerate(n['subfases'])] + [
                f"- [ ] Geometria {len([k for k in ids_fase if L['elements'][k]['type'] != 'inline'])}/{len([k for k in ids_fase if L['elements'][k]['type'] != 'inline'])} · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK",
                '- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes',
                '- [ ] Relatório da fase com lado a lado e heatmap inspecionados', '']
        texto = '\n'.join(out)
        with open(os.path.join(OUT, f'{f}.md'), 'w', encoding='utf-8', newline='\n') as fh:
            fh.write(texto)
        indice.append((f, fase['titulo'], n['g'], p['tela'], len(ids_fase), len(texto)))
        print(f'{f:30s} {len(ids_fase):>4d} ids  {len(texto) // 1024:>4d} KB')
    # índice
    arq, titulo, intro, tokens_md = C['fasesLeiaMe']
    idx = [f'# {titulo}', '', intro, '',
           f'Tokens novos e mapa id → widget{" (insumo da G11)" if arq == "LEIA-ME.md" else ""}: `{tokens_md}`.', '',
           f'| Fase | O que é | Fase {"G" if arq == "LEIA-ME.md" else "T"} | Tela | ids |', '|---|---|---|---|---|']
    idx += [f'| [{f}]({f}.md) | {t} | {g} | {tela} | {n} |' for f, t, g, tela, n, _ in indice]
    with open(os.path.join(OUT, arq), 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(idx) + '\n')


if __name__ == '__main__':
    main()

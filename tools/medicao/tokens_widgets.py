#!/usr/bin/env python3
"""G01.10 — tokens novos e mapa id → widget das telas 19–27b, para a G11 (design system do leitor).
Entradas: handoff_v2/referencia/layout/layout_*.json, svg_catalogo.json e os tokens atuais do app
(lib/core/design_system/tokens/app_colors.dart, app_radii.dart, app_shadows.dart, app_strokes.dart,
app_typography.dart — lidos como texto).
Saída:
  handoff_v2/referencia/tokens_leitor.json   cores, raios, sombras, bordas, estilos de texto (com usos e se já
                                             existem no app) + nome proposto para cada token novo
  handoff_v2/referencia/mapa_widgets.json    id → widget/pintor sugerido, semântica e observação
Uso: [CONJUNTO=inicio2] python3 tools/medicao/tokens_widgets.py [pasta_dos_tokens_dart]   (padrão: lib/core/design_system/tokens)
T02: entradas e saídas pelo conjunto (layout, svgCatalogo, tokens, mapa, tokensMd); os textos do L00 e os nomes
propostos de cor por conjunto (no leitor, os da G01).
"""
import collections
import glob
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import NOME, C, caminho  # noqa: E402

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
TOK = sys.argv[1] if len(sys.argv) > 1 else os.path.join(RAIZ, 'lib', 'core', 'design_system', 'tokens')
HEX = re.compile(r'#[0-9A-F]{6}(?:@[0-9.]+)?')

# nomes propostos para as cores que ainda não existem em AppColors (conferidos com o Anexo 01)
NOMES_COR = {
    '#F8F1E4': 'paperCream', '#FFFDF8': 'paperWhite', '#EEDDBF': 'paperSepia', '#1F1B17': 'paperNight',
    '#2A2520': 'bookText (Creme) · ilha da Noite', '#E3D9C6': 'bookTextNight', '#EDE3D1': 'inkNight',
    '#0B0A08': 'shadowNight', '#A89D8B': 'readerFooter', '#6F665B': 'inkLabel', '#CFC3AE': 'dashLine',
    '#E9DFCC': 'hatchReader', '#8E83C4': 'lavenderDeep', '#4A3622': 'bookTextSepia', '#8A8073': 'inkSoft',
    '#3B3631': 'nightSurface2', '#F7F0E3': 'paper', '#EFE5D3': 'ruleLine', '#FFFFFF': 'white',
}
# T02 — as cores novas da Início e da revisão (a chave é a cor sem o alfa: só aparece onde o token ainda não existe)
NOMES_COR_INICIO2 = {
    '#E4DACA': 'reviewLineNeutral (traços dos cartõezinhos da revisão)', '#FFC1C6': 'highlightPink @ 0,95 (grifo da revisão)',
    '#E1EDD0': 'tagReadBg (pílula "Lido")', '#2E5314': 'tagReadText (pílula "Lido")',
    '#FFFAF1': 'surface @ 0,85 (fita da nota)', '#3E2A2D': 'shareInkPink (textos da prévia rosa)',
    '#B9AE9C': 'miniBarKicker ("LENDO · PAPEL")', '#1A1714': 'ink @ 0,25 / 0,35 (sombras do CTA e da mini-barra)',
    '#2B2521': 'scrimShare (fundo da 63)', '#D9CFBD': 'sheetHandle', '#EDE4D3': 'toggleDivider', '#F1E7D5': 'toggleTrackOff',
}
if NOME == 'inicio2':
    NOMES_COR = {**NOMES_COR, **NOMES_COR_INICIO2}


def dart_colors():
    path = os.path.join(TOK, 'app_colors.dart')
    if not os.path.exists(path):
        return {}
    out = {}
    for m in re.finditer(r'static const Color (\w+) = Color\(0x([0-9A-Fa-f]{8})\)', open(path, encoding='utf-8').read()):
        a, rgb = int(m.group(2)[:2], 16), m.group(2)[2:].upper()
        key = f'#{rgb}' if a == 255 else f'#{rgb}@{round(a / 255, 2):g}'
        out.setdefault(key, m.group(1))
    return out


def dart_numbers(arquivo, padrao):
    path = os.path.join(TOK, arquivo)
    if not os.path.exists(path):
        return {}
    return {float(m.group(2)): m.group(1) for m in re.finditer(padrao, open(path, encoding='utf-8').read())}


def cores_do_estilo(sty):
    vals = []
    for k in ('bg', 'bgImage', 'shadow', 'mask'):
        if k in sty:
            vals += HEX.findall(sty[k]) if isinstance(sty[k], str) else []
    b = sty.get('border')
    if isinstance(b, str):
        vals += HEX.findall(b)
    elif isinstance(b, dict):
        for v in b.values():
            vals += HEX.findall(v)
    if 'font' in sty:
        vals.append(sty['font']['color'])
    return vals


def main():
    existentes = dart_colors()
    radii = dart_numbers('app_radii.dart', r'static const double (\w+) = ([0-9.]+)')
    strokes = dart_numbers('app_strokes.dart', r'static const double (\w+) = ([0-9.]+)')
    sombras_dart = {m.group(1): (float(m.group(2)), float(m.group(3))) for m in re.finditer(
        r'static const Offset (\w+) = Offset\(([0-9.]+), ([0-9.]+)\)', open(os.path.join(TOK, 'app_shadows.dart'), encoding='utf-8').read())} \
        if os.path.exists(os.path.join(TOK, 'app_shadows.dart')) else {}
    tipo_v1 = set()
    tp = os.path.join(TOK, 'app_typography.dart')
    if os.path.exists(tp):
        for m in re.finditer(r'AppFonts\.(figtree|bricolage|serif)\(\s*([0-9.]+)(?:,\s*FontWeight\.w(\d+))?', open(tp, encoding='utf-8').read()):
            fam = {'figtree': 'Figtree', 'bricolage': 'Bricolage Grotesque', 'serif': 'Instrument Serif'}[m.group(1)]
            tipo_v1.add((fam, float(m.group(2)), int(m.group(3) or (800 if fam == 'Bricolage Grotesque' else 400))))
    cat = json.load(open(caminho('svgCatalogo'), encoding='utf-8'))
    cores = collections.defaultdict(lambda: {'usos': 0, 'pranchas': set(), 'exemplos': []})
    raios = collections.defaultdict(lambda: {'usos': 0, 'exemplos': []})
    bordas = collections.defaultdict(lambda: {'usos': 0, 'exemplos': []})
    sombras = collections.defaultdict(lambda: {'usos': 0, 'exemplos': []})
    textos = collections.defaultdict(lambda: {'usos': 0, 'pranchas': set(), 'exemplos': []})
    mapa = {}
    for f in sorted(glob.glob(caminho('layout', 'layout_*.json'))):
        L = json.load(open(f, encoding='utf-8'))
        slug = L['meta']['prancha']
        tela = slug.split('_')[0]
        for k, e in L['elements'].items():
            sty = e.get('style', {})
            for c in cores_do_estilo(sty):
                d = cores[c]
                d['usos'] += 1
                d['pranchas'].add(tela)
                if len(d['exemplos']) < 4 and k not in d['exemplos']:
                    d['exemplos'].append(k)
            r = sty.get('radius')
            if r:
                key = r if isinstance(r, str) else ' '.join(r)
                raios[key]['usos'] += 1
                if len(raios[key]['exemplos']) < 3:
                    raios[key]['exemplos'].append(k)
            b = sty.get('border')
            if b:
                for side in ([b] if isinstance(b, str) else b.values()):
                    if side != '0':
                        w, st = side.split(' ')[:2]
                        bordas[f'{w} {st}']['usos'] += 1
                        if len(bordas[f'{w} {st}']['exemplos']) < 3:
                            bordas[f'{w} {st}']['exemplos'].append(k)
            s = sty.get('shadow')
            if s:
                sombras[s]['usos'] += 1
                if len(sombras[s]['exemplos']) < 3:
                    sombras[s]['exemplos'].append(k)
            fo = sty.get('font')
            if fo and (e.get('lines') or e.get('linesAll') or e['type'] == 'inline'):
                tk = (fo['family'], fo['size'], fo['weightCss'], fo['style'], fo['lineHeight'], fo['letterSpacing'],
                      fo['color'], ','.join(fo.get('features', [])))
                d = textos[tk]
                d['usos'] += 1
                d['pranchas'].add(tela)
                if len(d['exemplos']) < 4:
                    d['exemplos'].append(k)
            if 'section' in e or e.get('type') == 'box':
                mapa.setdefault(slug, {})[k] = widget(k, e, cat, slug)
    tokens = {
        'cores': [{'cor': c, 'existe': existentes.get(c), 'nomeProposto': None if c in existentes else NOMES_COR.get(c.split('@')[0], '—'),
                   'usos': d['usos'], 'pranchas': sorted(d['pranchas']), 'exemplos': d['exemplos']}
                  for c, d in sorted(cores.items(), key=lambda kv: -kv[1]['usos'])],
        'raios': [{'raio': r, 'existe': radii.get(float(r[:-2])) if re.fullmatch(r'[0-9.]+px', r) else None, **d}
                  for r, d in sorted(raios.items(), key=lambda kv: -kv[1]['usos'])],
        'bordas': [{'borda': b, 'existe': strokes.get(float(b.split('px')[0])), **d} for b, d in sorted(bordas.items(), key=lambda kv: -kv[1]['usos'])],
        'sombras': [{'sombra': s, **d} for s, d in sorted(sombras.items(), key=lambda kv: -kv[1]['usos'])],
        'sombrasExistentes': {k: list(v) for k, v in sombras_dart.items()},
        'estilosDeTexto': [{'familia': k[0], 'tamanho': k[1], 'peso': k[2], 'estilo': k[3], 'alturaLinha': k[4],
                            'espacamento': k[5], 'cor': k[6], 'recursos': k[7] or None,
                            'familiaETamanhoNaV1': (k[0], k[1], min(k[2], 700) if k[0] == 'Figtree' else k[2]) in tipo_v1,
                            'usos': d['usos'], 'pranchas': sorted(d['pranchas']), 'exemplos': d['exemplos']}
                           for k, d in sorted(textos.items(), key=lambda kv: (kv[0][0], kv[0][1], kv[0][2]))],
    }
    with open(caminho('tokens'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump(tokens, f, ensure_ascii=False, indent=1)
        f.write('\n')
    with open(caminho('mapa'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump(mapa, f, ensure_ascii=False, indent=1)
        f.write('\n')
    novos = [c for c in tokens['cores'] if not c['existe']]
    print(f"cores: {len(tokens['cores'])} ({len(novos)} novas) · raios: {len(tokens['raios'])} · bordas: {len(tokens['bordas'])} · "
          f"sombras: {len(tokens['sombras'])} · estilos de texto: {len(tokens['estilosDeTexto'])} · "
          f"ids no mapa: {sum(len(v) for v in mapa.values())}")


def classe(arquivo, c):
    """Classe de tokens do app para o SVG, pela pasta (T02: a Início reusa os da v1 e do leitor)."""
    pasta = os.path.dirname(arquivo)
    if pasta == 'assets/icons':
        return 'AppIcons'
    if pasta == 'assets/icons/leitor':
        return 'AppIconsLeitor'
    if pasta == 'assets/illustrations/leitor':
        return 'AppIllustrationsLeitor'
    return C.get('classeIcones' if c == 'ic' else 'classeIlustracoes', 'AppIconsLeitor' if c == 'ic' else 'AppIllustrationsLeitor')


def widget(k, e, cat, slug):
    sty = e.get('style', {})
    t = e['type']
    role = e.get('role')
    aria = e.get('aria')
    uso = cat['usos'].get(k, {}).get(slug)
    w = obs = None
    if t == 'icon' and uso:
        c = cat['arquivos'][uso['arquivo']]['categoria']
        nome = os.path.basename(uso['arquivo'])[:-4]
        w = {'ic': f'AppSvg({classe(uso["arquivo"], c)}.{nome}, size: {uso["tamanho"][0]:g})',
             'il': f'AppSvg({classe(uso["arquivo"], c)}.{nome}, size: {uso["tamanho"][0]:g}×{uso["tamanho"][1]:g})',
             'tinta': f'InkStrokesPainter (traços da fixture: {nome})',
             'graf': f'CustomPainter ({nome})'}[c]
        if uso.get('coresDinamicas'):
            obs = 'cores dinâmicas: ' + ', '.join(f'{a} = {b}' for a, b in uso['coresDinamicas'].items())
        if uso.get('armadilha'):
            obs = (obs + ' · ' if obs else '') + uso['armadilha']
    elif t == 'inline':
        w = 'TextSpan dentro do AppText.rich do pai'
    elif t == 'text':
        w = 'AppText'
    else:
        bgimg = sty.get('bgImage', '')
        radius = sty.get('radius')
        circ = radius == '50%' or (isinstance(radius, str) and radius.endswith('px') and abs(e['abs'][2] - e['abs'][3]) < 0.01
                                   and float(radius[:-2]) * 2 >= e['abs'][2] - 0.01)
        if 'repeating-linear-gradient' in bgimg:
            w = 'HatchPainter (hachura 135°) dentro do contorno'
        elif 'conic-gradient' in bgimg and 'radial-gradient' in bgimg:
            w = 'ColorWheelPainter (cônico HSV + radial branco)'
        elif 'conic-gradient' in bgimg:
            w = 'ConicRingPainter (anel arco-íris)'
        elif 'linear-gradient' in bgimg:
            w = 'DecoratedBox(LinearGradient)'
        elif t == 'box+text' and radius == '999px':
            w = 'Pill / CountBadge (NeoBox com raio de pílula + AppText)'
        elif circ and ('bg' in sty or 'border' in sty):
            w = 'CircleIconButton / NeoBox circular'
        elif 'bg' in sty or 'border' in sty or 'shadow' in sty:
            w = 'NeoBox' + (' + AppText' if t == 'box+text' else '')
        else:
            w = 'layout (Row/Column/Stack/Padding/SizedBox)'
        if sty.get('mask'):
            obs = 'ShaderMask com o degradê da máscara: ' + sty['mask']
        if sty.get('transform'):
            obs = (obs + ' · ' if obs else '') + f"Transform: {sty['transform']}"
    sem = {}
    if aria:
        sem['label'] = aria
    if role:
        sem['role'] = role
    if e.get('ariaAttrs'):
        sem.update(e['ariaAttrs'])
    out = {'widget': w}
    if sem:
        out['semantica'] = sem
    if obs:
        out['obs'] = obs
    return out


# textos do L00 por conjunto: (cabeçalho até as cores, parágrafo dos pintores, onde está o mapa)
TEXTOS_MD = {'leitor': (
    ['# L00 — Tokens novos e mapa id → widget (insumo da G11)', '',
           '> Gerado por `tools/medicao/tokens_widgets.py` (G01.10) a partir das medições das 13 pranchas e dos tokens atuais do app '
           '(`lib/core/design_system/tokens/`). Dados completos: `referencia/tokens_leitor.json` e `referencia/mapa_widgets.json`.', '',
           '## O que a G11 precisa mudar no design system (achados da medição)', '',
           '- `AppFonts.bricolage` arredonda o tamanho para escolher a família (`size.round()`): 15,5 viraria 16. As famílias novas são `Bricolage15_5`, `Bricolage17`, `Bricolage23` — usar o tamanho exato (opsz = font-size).',
           '- `AppFonts.figtree` aceita só 400–700 (D-14, Início). Nas telas 19–27b o 800 é real (D-16): família `Figtree` ganha o w800 (`Figtree-ExtraBold.ttf`); a Início continua pedindo w700 para o CSS 800. O CSS 900 da 23b renderiza 800.',
           '- Literata: estáticas por tamanho para a interface (sumário, cartões da 25, prévias) e a variável (`LiterataVF`) para o texto do livro (D-17, spike S1).',
           '- Sombras "anel" (`box-shadow: 0 0 0 Npx`) = `BoxShadow(spreadRadius: N, blurRadius: 0)`; aro duplo = duas sombras.',
           '- Cores `brand` e `ink` são props (dinâmicas) também dentro de SVG (catálogo de SVGs → `coresDinamicas`).',
           '- Tema Noite: tokens próprios (tabela de diferenças da `L26b_tema_noite.md`), nada de inversão automática.', ''],
    'Pintores novos sugeridos para a G11: `HatchPainter` com cores do leitor (barra de posição, espessura, espaço roxo), `ColorWheelPainter` (roda HSV), '
    '`ConicRingPainter` (poço de cor e "outra cor"), onda do fim do preenchimento (`svg_graficos/onda_preenchimento_barra.svg`), anel de progresso do capítulo, '
    'pintor de tinta (traços da fixture, `svg_tinta/`), pintor de grifo (fundo por altura, sublinhado, ondulado) e máscaras (`ShaderMask`) da faixa de tipos e da lista de capítulos. '
    'Recortes de referência visual em `referencia/png/elementos/`.',
    'referencia/mapa_widgets.json'),
    'inicio2': (
    ['# L00 — Início e revisão: tokens novos e mapa id → widget (insumo das T03–T05)', '',
     '> Gerado por `tools/medicao/tokens_widgets.py` (T02, `CONJUNTO=inicio2`) a partir das medições das 6 pranchas (01, 01b, 60, '
     '61, 62, 63) e dos tokens atuais do app (`lib/core/design_system/tokens/`). Dados completos: '
     '`docs/design/medicao/inicio2/tokens_inicio2.json` e `docs/design/medicao/inicio2/mapa_widgets.json`.', '',
     '## O que as T03–T05 precisam no design system (achados da medição)', '',
     '- Fontes (D-246): nas 01, 01b e 60 a Figtree 800/900 renderiza **700** (o arquivo declara até 700 — `AppFonts.figtree` como hoje); '
     'nas 61–63 o 800 é real (`Figtree-ExtraBold.ttf`, já existe; 900 → 800).',
     '- Famílias novas geradas na T02 (`tools/fonts/fontes_inicio2.json`): `Bricolage14` (63), `Bricolage32` (62), `Literata15` '
     'Regular (62; a família já tinha o Medium) e `Literata22` (61) — `AppFonts.bricolageOpsz`, `literataStatic` e o pubspec ganham '
     'esses tamanhos na fase que os usa. A Bricolage 11 usa a 12 (o eixo opsz começa em 12). A Instrument Serif é estática: os '
     'tamanhos novos (20, 24, 25, 40 e 64 itálico) usam os arquivos que já existem.',
     '- SVG: 16 desenhos já existem como asset (Início v1 e leitor) e o catálogo aponta para eles; 27 novos em '
     '`assets/icons/inicio2/`, `assets/illustrations/inicio2/` e dois gráficos em `docs/design/medicao/inicio2/svg_graficos/` '
     '(anel do livro e mostrador da meta → CustomPainter). Classes propostas: `AppIconsInicio` e `AppIllustrationsInicio`.',
     '- Capas: só a do herói (Dom Casmurro) e a da mini-barra (Brás Cubas com asas) são SVG — com `<text>` e `slice` (armadilha no '
     'catálogo); as demais capas e os cartões da revisão são CSS (div, borda, raio, círculo) → widgets compostos.',
     '- Sombras "anel": o aro coral do "pausar" (`0 0 0 3 #FF552E`) e o aro duplo da cor marcada na 63 = `BoxShadow(spreadRadius: N, '
     'blurRadius: 0)`; aro duplo = duas sombras.',
     '- Grifo por linha (`box-decoration-break: clone`) em rosa 95 % (61, 62) e creme (63): o pintor de grifo do leitor (G13) serve.',
     '- `{{brand}}` (lavanda) pinta o herói, o Início ativo, o progresso da mini-barra, o "Mais vezes", o segmento atual da 61, a '
     'pílula da sequência na 62 e o botão do interruptor ligado na 63 — sempre a prop, nunca a cor fixa.', ''],
    'Pintores sugeridos: `HatchPainter` (semana, clube, segmentos da revisão), mostrador da meta e anel do livro '
    '(`svg_graficos/`), pintor de grifo por linha (61, 62, 63), degradês inferiores (`DecoratedBox(LinearGradient)`: 150/55 % na '
    '01, 240/48 % na 01b, rodapé da 62) e o `RepaintBoundary` da prévia da 63 (a imagem compartilhada). Recortes de referência '
    'visual (capas em CSS, cartões da revisão, hachuras, degradês) em `docs/design/medicao/inicio2/png/elementos/`.',
    'docs/design/medicao/inicio2/mapa_widgets.json')}


def markdown():
    """L00 do conjunto (tokensMd; no leitor, handoff_v2/fases/L00_tokens_e_widgets.md) — resumo legível dos tokens e
    do mapa id → widget."""
    T = json.load(open(caminho('tokens'), encoding='utf-8'))
    M = json.load(open(caminho('mapa'), encoding='utf-8'))
    cab, pintores, ref_mapa = TEXTOS_MD.get(NOME, TEXTOS_MD['leitor'])
    out = cab + [
           f"## Cores ({len(T['cores'])}; {sum(1 for c in T['cores'] if not c['existe'])} ainda não existem em `AppColors`)", '',
           '| cor | já existe | nome proposto | usos | telas | exemplo |', '|---|---|---|---|---|---|']
    for c in T['cores']:
        out.append(f"| `{c['cor']}` | {c['existe'] or '—'} | {c['nomeProposto'] or ''} | {c['usos']} | {', '.join(c['pranchas'])} | `{c['exemplos'][0]}` |")
    out += ['', 'Notas: `@a` = alfa; cores de degradê (roda de cores, véus) entram como paradas do gradiente do pintor, não como tokens soltos. '
            '`#000000@0` = `transparent` dos degradês.', '',
            '## Raios', '', '| raio | já existe | usos | exemplos |', '|---|---|---|---|']
    out += [f"| {r['raio']} | {r['existe'] or '—'} | {r['usos']} | {', '.join(f'`{x}`' for x in r['exemplos'])} |" for r in T['raios']]
    out += ['', '## Bordas', '', '| borda | já existe (AppStrokes) | usos | exemplos |', '|---|---|---|---|']
    out += [f"| {b['borda']} | {b['existe'] or '—'} | {b['usos']} | {', '.join(f'`{x}`' for x in b['exemplos'])} |" for b in T['bordas']]
    out += ['', '## Sombras (todas sem desfoque)', '', '| sombra | usos | exemplos |', '|---|---|---|']
    out += [f"| `{s['sombra']}` | {s['usos']} | {', '.join(f'`{x}`' for x in s['exemplos'])} |" for s in T['sombras']]
    out += ['', f"## Estilos de texto ({len(T['estilosDeTexto'])} combinações medidas)", '',
            '| família | tamanho | peso | altura | ls | cor | extra | família+tamanho na v1 | usos | exemplo |', '|---|---|---|---|---|---|---|---|---|---|']
    for t in T['estilosDeTexto']:
        out.append(f"| {t['familia']}{' itálico' if t['estilo'] == 'italic' else ''} | {t['tamanho']:g} | {t['peso']} | {t['alturaLinha']} | {t['espacamento']} | `{t['cor']}` | "
                   f"{t['recursos'] or ''} | {'sim' if t['familiaETamanhoNaV1'] else '**novo**'} | {t['usos']} | `{t['exemplos'][0]}` |")
    cont = collections.Counter(v['widget'].split(' (')[0].split('(')[0].strip() for p in M.values() for v in p.values())
    out += ['', '## Mapa id → widget (resumo)', '',
            f'Cada id de cada prancha tem um widget/pintor sugerido em `{ref_mapa}` (e por fase nos arquivos L). Contagem por tipo:', '',
            '| widget / pintor | ids |', '|---|---|'] + [f'| {w} | {n} |' for w, n in cont.most_common()]
    out += ['', pintores, '']
    os.makedirs(os.path.dirname(caminho('tokensMd')), exist_ok=True)
    with open(caminho('tokensMd'), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(out) + '\n')
    print(os.path.basename(caminho('tokensMd')), len(out), 'linhas')


if __name__ == '__main__':
    main()
    markdown()

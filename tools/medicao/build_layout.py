#!/usr/bin/env python3
"""G01.4 — monta handoff_v2/referencia/layout/layout_<slug>.json a partir da medição crua
(tools/medicao/tmp/medicao/<slug>/medida.json), no formato da v1 (meta / sections / elements) com extras:
  vis        retângulo visual (com transform) quando difere do de layout
  linesAll   linhas do texto COMPOSTO (texto do elemento + filhos inline), p.ex. o parágrafo do leitor
  css        CSS declarado no arquivo, literal (com {{props}}), tirado do template
  platformFonts  fontes reais usadas pelo Chromium (aponta fallback do sistema)
Confere: tag e texto direto de cada id medidos == template (esboco.py); todos os ids medidos.
Uso: python3 tools/medicao/build_layout.py [todas|19,20…]
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import caminho, indice  # noqa: E402
from esboco import esboco  # noqa: E402

AQUI = os.path.dirname(__file__)
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
CFG = indice()
OUT = caminho('layout')
# eixos das fontes variáveis embutidas no arquivo (fvar, conferido com fontTools)
OPSZ = {'Literata': (7.0, 72.0), 'Bricolage Grotesque': (12.0, 96.0)}
TRANSP = ('rgba(0, 0, 0, 0)', 'transparent')


def hexcolor(s):
    def rep(m):
        p = [x.strip() for x in m.group(1).split(',')]
        r, g, b = [int(float(x)) for x in p[:3]]
        a = float(p[3]) if len(p) > 3 else 1.0
        h = f'#{r:02X}{g:02X}{b:02X}'
        return h if a == 1.0 else f'{h}@{a:g}'
    return re.sub(r'rgba?\(([^)]+)\)', rep, s)


def r2(v):
    return round(v, 2)


def font_faces(slug):
    tpl = open(caminho('extracao', slug, 'template.html'), encoding='utf-8').read()
    faces = []
    for m in re.finditer(r'@font-face\s*\{(.*?)\}', tpl, re.S):
        b = m.group(1)
        src = re.search(r'src:\s*url\(([^)]+)\)', b).group(1).strip('"\'')
        if src.startswith('http'):
            continue
        w = re.search(r'font-weight:\s*([^;]+);', b).group(1).split()
        faces.append({'family': re.search(r"font-family:\s*'([^']+)'", b).group(1),
                      'weight': [int(w[0]), int(w[-1])],
                      'style': re.search(r'font-style:\s*([^;]+);', b).group(1).strip(), 'asset': src})
    return faces


def style_summary(cs):
    sty = {}
    if cs['backgroundColor'] not in TRANSP:
        sty['bg'] = hexcolor(cs['backgroundColor'])
    if cs['backgroundImage'] != 'none':
        sty['bgImage'] = hexcolor(cs['backgroundImage'])
    sides = []
    for s in ('Top', 'Right', 'Bottom', 'Left'):
        w, st, c = cs[f'border{s}Width'], cs[f'border{s}Style'], cs[f'border{s}Color']
        sides.append('0' if st == 'none' or w == '0px' else f'{w} {st} {hexcolor(c)}')
    if any(b != '0' for b in sides):
        sty['border'] = sides[0] if len(set(sides)) == 1 else dict(zip(('top', 'right', 'bottom', 'left'), sides))
    rad = [cs[f'border{c}Radius'] for c in ('TopLeft', 'TopRight', 'BottomRight', 'BottomLeft')]
    if any(r != '0px' for r in rad):
        sty['radius'] = rad[0] if len(set(rad)) == 1 else rad
    if cs['boxShadow'] != 'none':
        sty['shadow'] = hexcolor(cs['boxShadow'])
    for k, d in (('opacity', '1'), ('mixBlendMode', 'normal'), ('filter', 'none'), ('zIndex', 'auto')):
        if cs[k] != d:
            sty[k] = cs[k]
    pad = ' '.join(cs[f'padding{s}'] for s in ('Top', 'Right', 'Bottom', 'Left'))
    if pad != '0px 0px 0px 0px':
        sty['padding'] = pad
    if cs['overflow'] != 'visible':
        sty['overflow'] = cs['overflow']
    mask = cs.get('webkitMaskImage') if cs.get('webkitMaskImage') not in (None, 'none') else cs.get('maskImage')
    if mask and mask != 'none':
        sty['mask'] = hexcolor(mask)
    if cs.get('clipPath') not in (None, 'none'):
        sty['clipPath'] = cs['clipPath']
    if cs['position'] == 'absolute':
        sty['position'] = {k: cs[k] for k in ('top', 'right', 'bottom', 'left') if cs[k] != 'auto'}
    if cs['transform'] != 'none':
        sty['transformMatrix'] = cs['transform']
    if cs['boxSizing'] == 'content-box' and any(b != '0' for b in sides):
        sty['boxSizing'] = 'content-box (tamanho externo = conteúdo + padding + bordas)'
    return sty


def font_summary(cs, faces):
    fam = cs['fontFamily'].split(',')[0].strip().strip('"\'')
    size = float(cs['fontSize'][:-2])
    w = int(cs['fontWeight'])
    st = cs['fontStyle']
    match = [f for f in faces if f['family'] == fam and f['style'] == st and f['weight'][0] <= w <= f['weight'][1]]
    font = {'family': fam, 'size': size, 'weightCss': w, 'weightRendered': w if match else None,
            'style': st, 'lineHeight': cs['lineHeight'], 'letterSpacing': cs['letterSpacing'],
            'color': hexcolor(cs['color'])}
    if not match:
        font['nota'] = 'peso/estilo sem @font-face correspondente → o navegador sintetiza ou usa o mais próximo'
    if fam in OPSZ and cs['fontOpticalSizing'] == 'auto':
        lo, hi = OPSZ[fam]
        font['opsz'] = max(lo, min(hi, size))
    feats = []
    if 'tabular-nums' in cs['fontVariantNumeric']:
        feats.append('tnum')
    if cs['fontFeatureSettings'] != 'normal':
        feats.append(cs['fontFeatureSettings'])
    if feats:
        font['features'] = feats
    if cs['fontVariationSettings'] != 'normal':
        font['variation'] = cs['fontVariationSettings']
    for k, d in (('textAlign', ('start', 'left')), ('textIndent', ('0px',)), ('textTransform', ('none',)),
                 ('whiteSpace', ('normal',)), ('textOverflow', ('clip',)), ('textWrapStyle', ('auto',)),
                 ('textDecorationLine', ('none',)), ('wordSpacing', ('0px',)), ('verticalAlign', ('baseline',))):
        if cs[k] not in d:
            font[k] = cs[k]
    return font


def build(p):
    slug, pre = p['slug'], p['prefixo']
    base = p.get('base', slug)  # T03: as larguras da 01 usam a extração e o idmap da prancha base
    m = json.load(open(caminho('tmp', 'medicao', slug, 'medida.json'), encoding='utf-8'))
    im = json.load(open(caminho('idmaps', f'{base}.json'), encoding='utf-8'))
    nodes = {str(n['tpl']): n for n in esboco(base)}
    faces = font_faces(base)
    erros = []
    if m['faltando']:
        erros.append(f'ids sem elemento: {m["faltando"]}')
    if m.get('errosJs'):
        erros.append(f'erros de JS: {m["errosJs"]}')
    E, LINES, ALL, NAT, ST, VIS, PF = m['elems'], m['lines'], m['linesAll'], m['natural'], m['styles'], m['vis'], m['plataforma']
    for tpl, id_ in im['ids'].items():
        n, e = nodes[tpl], E[id_]
        if n['tag'] != e['tag']:
            erros.append(f'{id_}: tag medida {e["tag"]} ≠ template {n["tag"]}')
        if (e.get('text') or '') != re.sub(r'\s+', ' ', n['text']).strip() and '{{' not in n['text']:
            erros.append(f'{id_}: texto medido «{e.get("text")}» ≠ template «{n["text"]}»')
    secoes = im['secoes']

    def section_of(k):
        best = None
        for s in secoes:
            if k == s or k.startswith(s + '.'):
                if best is None or len(s) > len(best):
                    best = s
        return best
    props = json.load(open(caminho('extracao', base, 'props.json'), encoding='utf-8'))
    # T13: as telas do projeto (formato dc) vêm de um .dc.html cada, com as fontes do css2 embutidas (extrair_dc.py)
    dc = CFG.get('formato') == 'dc'
    out = {'meta': {
        'source': p['arquivo'] if dc else os.path.basename(CFG['fonte']), 'prancha': slug, 'titulo': p['titulo'],
        'canvas': p['canvas'], 'prefixo': pre, 'units': 'CSS px = dp lógico',
        'measuredWith': 'Chromium 141 (Playwright 1.56), --font-render-hinting=none, zoom 100 (geometria e estilos), '
                        + ('tela isolada do projeto (.dc.html com as fontes do css2 embutidas)' if dc
                           else 'prancha isolada do bundle aninhado') + ', rede bloqueada; bordas exatas (1.5/1.2)',
        'props': {k: v['default'] for k, v in props.items() if not k.startswith('$')},
        'note': 'abs = retângulo de layout (transforms neutralizados) no canvas; rel = relativo ao canto superior '
                'esquerdo da seção; vis = caixa visual com transform (só quando difere); baseline = topo do glifo + '
                'ascent medido (fontMetrics).'},
        'sections': {}, 'elements': {}, 'fontMetrics': m['fontMetrics'], 'fontFaces': faces}
    for s in secoes:
        e = E[s]
        out['sections'][s] = [r2(e['x']), r2(e['y']), r2(e['w']), r2(e['h'])]
    order = sorted(im['ids'].items(), key=lambda kv: int(kv[0]))
    for tpl, k in order:
        e = E[k]
        cs = ST[k]
        rec = {'tpl': int(tpl)}
        abs_ = [r2(e['x']), r2(e['y']), r2(e['w']), r2(e['h'])]
        if k in im.get('especiais', [f'{pre}.frame']):
            rec.update({'type': 'box', 'tag': e['tag'], 'abs': abs_, 'style': style_summary(cs)})
            out['elements'][k] = rec
            continue
        sec = section_of(k)
        sr = out['sections'][sec]
        parent_tpl = nodes[tpl]['parent']
        parent_id = im['ids'].get(str(parent_tpl)) if parent_tpl else None
        has_text = k in LINES
        if e['tag'] == 'svg':
            typ = 'icon'
        elif cs['display'] == 'inline' and parent_id and parent_id in ALL and has_text:
            typ = 'inline'
        elif has_text:
            sty0 = style_summary(cs)
            typ = 'box+text' if ('bg' in sty0 or 'border' in sty0 or 'bgImage' in sty0) else 'text'
        else:
            typ = 'box'
        rec.update({'section': sec, 'type': typ, 'tag': e['tag'], 'abs': abs_,
                    'rel': [r2(e['x'] - sr[0]), r2(e['y'] - sr[1]), abs_[2], abs_[3]]})
        v = VIS.get(k)
        if v and any(abs(a - b) > 0.005 for a, b in zip(v, [e['x'], e['y'], e['w'], e['h']])):
            rec['vis'] = [r2(x) for x in v]
        sty = style_summary(cs)
        if e.get('transform'):
            sty['transform'] = e['transform']
        if has_text or k in ALL or typ == 'inline':
            sty['font'] = font_summary(cs, faces)
        rec['style'] = sty
        css = re.sub(r'\s+', ' ', nodes[tpl]['style']).strip().rstrip(';')
        if css:
            rec['css'] = css
        # recorte: ancestral (ou o próprio) com overflow ≠ visible → linhas fora dele ficam marcadas 'oculta'
        clip, t_ = None, tpl
        while t_ is not None:
            cid = im['ids'].get(str(t_))
            if cid and ST[cid]['overflow'] != 'visible' and cid != k:
                ce = E[cid]
                clip = (ce['y'], ce['y'] + ce['h'], ce['x'], ce['x'] + ce['w'])
                break
            t_ = nodes[str(t_)]['parent']
        for key, src in (('lines', LINES), ('linesAll', ALL)):
            if k in src:
                rec[key] = [{'text': ln['text'], 'left': r2(ln['left']), 'right': r2(ln['right']),
                             'top': r2(ln['top']), 'bottom': r2(ln['bottom']), 'baseline': r2(ln['baseline']),
                             'baselineRel': r2(ln['baseline'] - sr[1]),
                             **({'baselineSpread': ln['baselineSpread']} if ln['baselineSpread'] > 0.01 else {}),
                             **({'oculta': True} if clip and (ln['top'] >= clip[1] - 0.01 or ln['bottom'] <= clip[0] + 0.01
                                                               or ln['left'] >= clip[3] - 0.01 or ln['right'] <= clip[2] + 0.01) else {})}
                            for ln in src[k]]
        if k in NAT:
            rec['naturalWidth'] = NAT[k]['maxContent']
            rec['minContentWidth'] = NAT[k]['minContent']
            # reticências efetivas: text-overflow ellipsis E o texto não cabe na caixa de conteúdo
            pad = sum(float(cs[f'padding{s_}'][:-2]) + float(cs[f'border{s_}Width'][:-2]) for s_ in ('Left', 'Right'))
            if cs['textOverflow'] == 'ellipsis' and NAT[k]['maxContent'] - pad > e['w'] - pad + 0.01:
                rec['ellipsis'] = True
        for a in ('aria', 'role', 'text'):
            if e.get(a):
                rec[a] = e[a]
        attrs = nodes[tpl]['attrs']
        sem = {a: attrs[a] for a in attrs if a.startswith('aria-') and a != 'aria-label'}
        if sem:
            rec['ariaAttrs'] = sem
        if k in PF:
            rec['platformFonts'] = PF[k]
            if any(not f['custom'] for f in PF[k]):
                rec['fallback'] = [f'{f["family"]} ({f["glyphs"]} glifo(s))' for f in PF[k] if not f['custom']]
        out['elements'][k] = rec
    # T13 (R8): no projeto, nenhum texto cai em fonte de reserva além do que o índice declara (`reserva`: id sem o
    # prefixo → motivo e se é informativo); o informativo (texto que o sistema desenha, não o app) fica marcado
    if dc:
        reserva = p.get('reserva', {})
        for k, rec in out['elements'].items():
            curto = k[len(pre) + 1:]
            if 'fallback' not in rec:
                continue
            if curto not in reserva:
                erros.append(f'{k}: fonte de reserva fora do R8 ({", ".join(rec["fallback"])})')
            elif reserva[curto].get('informativo'):
                rec['informativo'] = reserva[curto]['motivo']
        for curto in reserva:
            if 'fallback' not in out['elements'].get(f'{pre}.{curto}', {}):
                erros.append(f'{pre}.{curto}: a reserva declarada no índice não apareceu na medição')
    os.makedirs(OUT, exist_ok=True)
    with open(os.path.join(OUT, f'layout_{slug}.json'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
        f.write('\n')
    tipos = {}
    for r in out['elements'].values():
        tipos[r['type']] = tipos.get(r['type'], 0) + 1
    return out, erros, tipos


def main():
    arg = sys.argv[1] if len(sys.argv) > 1 else 'todas'
    sel = CFG['pranchas'] if arg == 'todas' else [p for p in CFG['pranchas'] if p['tela'] in arg.split(',') or p['slug'] in arg.split(',')]
    falhas = 0
    for p in sel:
        out, erros, tipos = build(p)
        falhas += len(erros)
        print(f"{p['slug']:24s} {len(out['elements']):>4d} elementos {tipos}" + (f'  ERROS: {erros}' if erros else ''))
    if falhas:
        sys.exit(1)
    print('OK')


if __name__ == '__main__':
    main()

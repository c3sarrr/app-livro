import json, re
L=json.load(open('layout_inicio.json')); leg=json.load(open('redline_legend.json')); IS=json.load(open('inline_styles.json'))
BRAND={'hero','nav.home'}; WEEK={f'today.week.bar{i}.fill' for i in range(6)}
def hexify(s):
    def rep(m):
        p=[x.strip() for x in m.group(1).split(',')]
        r,g,b=[int(float(x)) for x in p[:3]]
        a=float(p[3]) if len(p)>3 else None
        return f'#{r:02X}{g:02X}{b:02X}' if a is None else f'rgba({r},{g},{b},{a:g})'
    return re.sub(r'rgba?\(([^)]+)\)',rep,s)
def fmt(v):
    s=f'{v:.2f}'.rstrip('0').rstrip('.')
    return s if s!='-0' else '0'
phase_of={'header':'F03_header','headline':'F04_headline','hero':'F05_hero','alsoReading':'F06_tambem_lendo','today':'F07_seu_dia','forYou':'F08_para_voce','club':'F09_clube','recent':'F10_recem_chegados','nav':'F11_nav_fade','bottomFade':'F11_nav_fade'}
def typo(e):
    f=e.get('style',{}).get('font')
    if not f: return ''
    w=f['weightCss']; wr=f['weightRendered']
    wt=f"{w}" if w==wr else f"{w}→**{wr}**"
    fam={'Bricolage Grotesque':'Bricolage','Figtree':'Figtree','Instrument Serif':'Instrument Serif'}[f['family']]
    op=f" (opsz {f['opsz']})" if 'opsz' in f else ''
    it=' itálico' if f['style']=='italic' else ''
    return f"{fam}{op}{it} {fmt(f['size'])}/{f['lineHeight']} peso {wt} ls {f['letterSpacing']} {f['color']}"
out={}
for sec in ['header','headline','hero','alsoReading','today','forYou','club','recent','nav','bottomFade']:
    ph=phase_of[sec]; idx={k:i for i,k,t in leg[ph]}; sr=L['sections'][sec]
    rows=[f"Seção `{sec}` — retângulo absoluto no canvas 390×2390: **x={fmt(sr[0])}, y={fmt(sr[1])}, w={fmt(sr[2])}, h={fmt(sr[3])}**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.\n",
          '| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |',
          '|---|---|---|---|---|---|---|---|---|']
    for k,e in L['elements'].items():
        if e.get('section')!=sec: continue
        x,y,w,h=e['rel']
        css=hexify(IS[k]['cssText']).strip().rstrip(';')
        if k in BRAND: css=css.replace('background: #B6ACE4','background: {{brand}} (padrão #B6ACE4)')
        if k in WEEK: css=css.replace('background: #B6ACE4','background: {{weekColor}} (padrão #B6ACE4)')
        css=css.replace('|','\\|')
        if not css: css='—'
        rows.append(f"| {idx.get(k,'—')} | `{k}` | {e['type']} | {fmt(x)} | {fmt(y)} | {fmt(w)} | {fmt(h)} | `{css}` | {typo(e)} |")
    tl=[]
    for k,e in L['elements'].items():
        if e.get('section')!=sec or not e.get('lines'): continue
        for i,l in enumerate(e['lines']):
            note=' *(reticências)*' if 'ellipsis' in e else ''
            tl.append(f"| `{k}` | {i+1} | {l['text']}{note} | {fmt(l['baseline']-sr[1])} | {fmt(l['left']-sr[0])} | {fmt(l['right']-sr[0])} | {fmt(l['right']-l['left'])} |")
    if tl:
        rows+=['\n**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**\n','| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |','|---|---|---|---|---|---|---|']+tl
    out[sec]='\n'.join(rows)
json.dump(out,open('gen/tables.json','w'),ensure_ascii=False,indent=1)
print({k:len(v) for k,v in out.items()})

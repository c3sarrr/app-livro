import json, re
L=json.load(open('layout_z100.json')); S=json.load(open('styles_z100.json'))
E=L['elems']; LINES=L['lines']; NAT=L['natural']; ST=S['styles']
SECTIONS=['header','headline','hero','alsoReading','today','forYou','club','recent','bottomFade','nav']
INLINE={'headline.serif','today.title.serif','club.title.serif','today.goalText.sentence.strong','today.footer.text.strong'}
ASC={'Figtree':0.95,'Bricolage Grotesque':0.93,'Instrument Serif':0.99}
DESC={'Figtree':0.25,'Bricolage Grotesque':0.27,'Instrument Serif':0.31}
def rgb2hex(s):
    m=re.match(r'rgba?\(([^)]+)\)',s)
    if not m: return s
    p=[x.strip() for x in m.group(1).split(',')]
    r,g,b=[int(float(x)) for x in p[:3]]
    a=float(p[3]) if len(p)>3 else 1.0
    h=f'#{r:02X}{g:02X}{b:02X}'
    return h if a==1.0 else f'{h}@{a:g}'
def section_of(k):
    for s in SECTIONS:
        if k==s or k.startswith(s+'.'): return s
    return None
out={'meta':{'source':'Redesign mobile — App de leitura.html','canvas':[390,2390],'units':'CSS px = dp lógico','measuredWith':'Chromium (Playwright 1.56) zoom 100, --font-render-hinting=none; bordas exatas (1.5/1.2)','note':'rel = relativo ao canto superior esquerdo da seção (border-box)'},'sections':{},'elements':{}}
for s in SECTIONS:
    e=E[s]; out['sections'][s]=[round(e['x'],2),round(e['y'],2),round(e['w'],2),round(e['h'],2)]
for k,e in E.items():
    if k in ('frame','main'): 
        out['elements'][k]={'type':'box','abs':[e['x'],e['y'],round(e['w'],2),round(e['h'],2)]}
        continue
    sec=section_of(k); sr=out['sections'][sec]
    st=ST[k]; f=e['font']
    has_text = k in LINES
    tag=e['tag']
    if k in INLINE: typ='inline'
    elif tag=='svg': typ='icon'
    elif has_text:
        deco = (st['bg']!='rgba(0, 0, 0, 0)') or any(not side.startswith('0px') for side in st['border'].split(' | '))
        typ='box+text' if deco else 'text'
    else: typ='box'
    rec={'section':sec,'type':typ,'tag':tag,
         'abs':[round(e['x'],2),round(e['y'],2),round(e['w'],2),round(e['h'],2)],
         'rel':[round(e['x']-sr[0],2),round(e['y']-sr[1],2),round(e['w'],2),round(e['h'],2)]}
    # style summary
    sty={}
    if st['bg'] not in ('rgba(0, 0, 0, 0)',): sty['bg']=rgb2hex(st['bg'])
    if st['bgImage']!='none': sty['bgImage']=st['bgImage']
    sides=st['border'].split(' | ')
    bs=[]
    for side in sides:
        parts=side.split(' ',2)
        if parts[0]!='0px': bs.append(f"{parts[0]} {parts[1]} {rgb2hex(parts[2])}")
        else: bs.append('0')
    if any(b!='0' for b in bs):
        sty['border']=bs[0] if len(set(bs))==1 else {'top':bs[0],'right':bs[1],'bottom':bs[2],'left':bs[3]}
    rad=st['radius'].split(' ')
    if any(r!='0px' for r in rad): sty['radius']=rad[0] if len(set(rad))==1 else rad
    if st['shadow']!='none': sty['shadow']=re.sub(r'rgb\((\d+), (\d+), (\d+)\)', lambda m: rgb2hex(m.group(0)), st['shadow'])
    if st['opacity']!='1': sty['opacity']=st['opacity']
    if st['padding']!='0px 0px 0px 0px': sty['padding']=st['padding']
    if st['overflow'] not in ('visible',): sty['overflow']=st['overflow']
    if st['position'] in ('absolute','relative') and st['position']=='absolute':
        sty['position']={kk:st[kk] for kk in ('top','right','bottom','left') if st[kk]!='auto'}
    if st['transform']: sty['transform']=st['transform']
    if st['boxSizing']=='content-box' and any(b!='0' for b in bs): sty['boxSizing']='content-box (tamanho externo = conteúdo + bordas)'
    if has_text or typ=='inline':
        fam=f['family']; size=float(f['size'][:-2]); w=int(f['weight'])
        eff=w
        if fam=='Figtree' and w>700: eff=700
        if fam=='Figtree' and w<400: eff=400
        font={'family':fam,'size':size,'weightCss':w,'weightRendered':eff,'style':f['style'],'lineHeight':f['lineHeight'],'letterSpacing':f['letterSpacing'],'color':rgb2hex(f['color'])}
        if fam=='Bricolage Grotesque': font['opsz']=max(12,min(96,round(size)))
        sty['font']=font
    rec['style']=sty
    if has_text:
        fam=f['family']; size=float(f['size'][:-2])
        ls=[]
        for ln in LINES[k]:
            base=round(ln['top']+ASC[fam]*size,2)
            ls.append({'text':ln['text'],'left':ln['left'],'right':ln['right'],'baseline':base,'baselineRel':round(base-sr[1],2)})
        rec['lines']=ls
        if k in NAT: rec['naturalWidth']=NAT[k]['maxContent']
    if e.get('aria'): rec['aria']=e['aria']
    if e.get('text'): rec['text']=e['text']
    out['elements'][k]=rec
json.dump(out,open('layout_inicio.json','w'),ensure_ascii=False,indent=1)
print('ok', len(out['elements']))
# quick checks
for k in ['headline','hero.chapterPill','today.goalText.sentence','recent.row1.tag','hero.cover.author','nav.home']:
    print(k, json.dumps(out['elements'][k],ensure_ascii=False)[:400])

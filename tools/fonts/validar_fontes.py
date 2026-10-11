#!/usr/bin/env python3
"""G01.7 — confere as fontes geradas contra o navegador: para cada linha de texto medida nas 13 pranchas
(layout_<slug>.json), mede a largura com HarfBuzz usando o TTF que o app vai usar (estática da v1 ou da v2)
e compara com a largura medida no Chromium (right − left; inclui o letter-spacing do último caractere).
Também mede a Literata VARIÁVEL com opsz = tamanho (prévia do spike S1).
Regras de forma iguais às do Chromium: kerning ligado; letter-spacing ≠ 0 desliga 'liga' e 'clig' (D-282);
tabular-nums → 'tnum'. Linhas com glifo de fallback do sistema (ex.: "≈") ficam de fora e são listadas.
Saída: tools/fonts/validacao_fontes.json + resumo; código 1 se alguma linha passar de 0,05 px.
T02: as medições e a saída pelo conjunto (layout, validacaoFontes); a Figtree usa o maior peso que a prancha
declara (01/01b/60 vão até 700 → o CSS 800 é 700, D-246; 19–27b e 61–63 até 800) e a Bricolage abaixo de 12 px usa
a instância 12 (o eixo opsz começa em 12).
T13 (CONJUNTO=projeto e projeto_larguras, R6): a Bricolage 700 (a 15 dos Detalhes) e a Roboto 500 (o botão do Google da
07); quando a 1ª família do CSS não tem @font-face na página (o 'Google Sans' da 07), vale a 1ª da lista que tem — é
a que o Chromium usa. A Literata itálica não tem estática (nenhuma tela a usa): falha em vez de medir com a normal.
Uso: [CONJUNTO=inicio2|projeto|projeto_larguras] python3 tools/fonts/validar_fontes.py   (requer uharfbuzz)
"""
import glob
import json
import os
import sys

import uharfbuzz as hb

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
sys.path.insert(0, os.path.join(RAIZ, 'tools', 'medicao'))
from conjunto import C, caminho  # noqa: E402

FONTS = os.path.join(RAIZ, 'assets', 'fonts')
TRECHOS = bool(C.get('validacaoTrechos'))   # T02: confere também os trechos inline e o texto próprio contíguo
# D-282: com letter-spacing ≠ 0 o Blink desliga só as ligaduras comuns ('liga' e 'clig'; a 'dlig' já vem desligada e
# a 'calt' continua) — o mesmo que o AppFonts faz no app. Até a T13.10 este script desligava também 'dlig' e 'calt': nas
# 1349 linhas com espaçamento de todos os conjuntos a diferença é 0.
SEM_LIGADURAS = {'liga': False, 'clig': False}
LIMITE = 0.05
LABEL = {400: 'Regular', 500: 'Medium', 600: 'SemiBold', 700: 'Bold', 800: 'ExtraBold'}
_cache = {}


def num(v):
    return str(int(v)) if float(v) == int(v) else str(v).replace('.', '_')


def arquivo(fam, estilo, peso, tam, figtree_max=800):
    """(arquivo TTF, variações) que o app usa para este estilo do CSS."""
    if fam == 'Figtree':
        w = min(peso, figtree_max)            # 900 → 800: o @font-face do arquivo vai até 800 (700 na Início)
        return f'Figtree-{LABEL[w]}.ttf', None
    if fam == 'Bricolage Grotesque':
        return f'Bricolage{num(max(tam, 12))}-{LABEL[peso]}.ttf', None
    if fam == 'Literata':
        if estilo == 'italic':
            raise KeyError('Literata itálica (sem estática no app)')
        return f'Literata{num(tam)}-{LABEL[peso]}.ttf', None
    if fam == 'Roboto':
        return f'Roboto-{LABEL[peso]}.ttf', None
    if fam == 'Instrument Serif':
        return f"InstrumentSerif-{'Italic' if estilo == 'italic' else 'Regular'}.ttf", None
    if fam == 'Lora':
        return 'Lora-VF.ttf', {'wght': peso}
    if fam == 'Atkinson Hyperlegible':
        return f'AtkinsonHyperlegible-{LABEL[peso]}.ttf', None
    raise KeyError(fam)


def familia(L, e, fo):
    """A família que o Chromium usa: a 1ª do CSS se a página tem @font-face dela; senão, a 1ª da lista do CSS do
    elemento que tem (T13: o 'Google Sans', 'Roboto' do botão do Google da 07 → Roboto)."""
    faces = {ff['family'] for ff in L['fontFaces']}
    if fo['family'] in faces:
        return fo['family']
    for decl in reversed(e.get('css', '').split(';')):
        nome, _, valor = decl.partition(':')
        if nome.strip() == 'font-family':
            for f in valor.split(','):
                f = f.strip().strip('"').strip("'")
                if f in faces:
                    return f
            break
    return fo['family']


def hb_font(path, var):
    key = (path, json.dumps(var, sort_keys=True))
    if key not in _cache:
        blob = hb.Blob.from_file_path(path)
        face = hb.Face(blob)
        font = hb.Font(face)
        if var:
            font.set_variations({k: float(v) for k, v in var.items()})
        font.scale = (face.upem * 1024, face.upem * 1024)   # avanços com fração (padrão = unidades inteiras)
        _cache[key] = (font, face.upem * 1024)
    return _cache[key]


def largura(path, var, texto, tam, ls, tnum):
    font, upem = hb_font(path, var)
    buf = hb.Buffer()
    buf.add_str(texto)
    buf.guess_segment_properties()
    feats = {'kern': True}
    if ls:
        feats.update(SEM_LIGADURAS)
    if tnum:
        feats['tnum'] = True
    hb.shape(font, buf, feats)
    adv = sum(p.x_advance for p in buf.glyph_positions) * tam / upem
    return adv + ls * len(texto)


# ── T13 (R6): a conferência por trecho (conjuntos com validacaoPorTrecho: projeto e projeto_larguras) ──────────────
# Toda linha de texto das telas entra, também a composta de trechos com fontes diferentes (o "248" em 800 no meio do
# "seguidores" em 600 da 05, a marca da busca na 28b, a palavra espaçada da 59): a linha inteira é dividida nos trechos
# de cada elemento (o dono e os descendentes medidos na mesma linha de base), os trechos vizinhos com a mesma fonte se
# juntam (o Chromium modela por fonte, não por elemento) e a largura é a soma dos trechos modelados mais o recuo
# (padding + borda + margem) dos trechos inline que fica entre o primeiro e o último glifo da linha — a marca "Capitu"
# da 28b tem 1 px de cada lado. A largura do Chromium vem da medida crua (3 casas, <tmp>/medicao/<tela>/medida.json):
# o layout arredonda cada borda a 2 casas, o que sozinho põe até 0,01 px na diferença (o "Q" da 30b: 10,310 cru,
# 10,32 no layout; a estática dá 10,309). Cada linha também é modelada com a fonte de origem (a variável do arquivo
# com as variações da instância, como o Chromium): a diferença estática × origem é a da fonte, sem a medida no meio.
# O glifo que a fonte do trecho não tem (o "≈" da 17b, a "→" da 28c e da 30b) é modelado com a reserva do peso — a
# família BookNestApprox (D-54, D-281); só o texto informativo do R8 (o botão da Apple, o teclado do sistema) fica de
# fora, listado.
POR_TRECHO = bool(C.get('validacaoPorTrecho'))
# R6: as linhas das 41 telas ≤ 0,01 px do Chromium (a medida crua tem 3 casas); o código de saída reprova acima disso.
# Os conjuntos antigos continuam com o 0,05 da G01 (as saídas deles não mudam).
LIMITE_TRECHO = 0.01


def _px(v):
    return float(v[:-2]) if v.endswith('px') else 0.0


def recuo(st, lado):
    """Padding + borda + margem horizontais de um lado ('Left'/'Right') pelo estilo computado."""
    return _px(st[f'padding{lado}']) + _px(st[f'border{lado}Width']) + _px(st[f'margin{lado}'])


def chave_trecho(fo):
    return (fo['family'], fo['style'], fo['weightCss'], fo['size'], fo['letterSpacing'], tuple(fo.get('features', [])))


RESERVA = {600: 'BookNestApprox-SemiBold.otf', 700: 'BookNestApprox-Bold.ttf', 800: 'BookNestApprox-ExtraBold.otf'}
_cmaps = {}


def cmap(nome):
    if nome not in _cmaps:
        from fontTools.ttLib import TTFont
        _cmaps[nome] = set(TTFont(os.path.join(FONTS, nome)).getBestCmap())
    return _cmaps[nome]


def por_cobertura(texto, nome, peso):
    """O texto em trechos (texto, arquivo): o caractere que a fonte não tem vai para a reserva do peso — a família
    BookNestApprox (D-54, D-281), os glifos da Inter que o Chromium usa no lugar."""
    out = []
    for ch in texto:
        f = nome
        if ord(ch) not in cmap(nome):
            f = RESERVA[peso]
            if ord(ch) not in cmap(f):
                raise KeyError(f'{ch!r} nem em {nome} nem em {f}')
        if out and out[-1][1] == f:
            out[-1][0] += ch
        else:
            out.append([ch, f])
    return out


def origem_da_estatica(nome):
    """(fonte de origem, variações) do arquivo do app — a do conferir_estaticas.py; a Instrument Serif é estática no
    arquivo (a origem é o próprio binário: latin do arquivo/originais_v2)."""
    import conferir_estaticas as ce
    try:
        return ce.origem(nome)
    except KeyError:
        pass
    ext = os.path.join(AQUI, 'originais_v2')
    inter = '/usr/share/fonts/opentype/inter'     # a reserva: a Inter 4.0 do WSL, a que o Chromium usou (D-281)
    return {'BookNestApprox-SemiBold.otf': (os.path.join(inter, 'Inter-SemiBold.otf'), None),
            'BookNestApprox-Bold.ttf': (os.path.join(inter, 'Inter-Bold.otf'), None),
            'BookNestApprox-ExtraBold.otf': (os.path.join(inter, 'Inter-ExtraBold.otf'), None),
            'InstrumentSerif-Regular.ttf': (os.path.join(ext, 'InstrumentSerif-normal-400-latin.woff2'), None),
            'InstrumentSerif-Italic.ttf': (os.path.join(RAIZ, 'handoff_v2', 'referencia', 'fontes_do_arquivo',
                                                        'InstrumentSerif-Italic-latin.woff2'), None)}[nome]


def largura_origem(nome, texto, tam, ls, tnum):
    import conferir_estaticas as ce
    src, var = origem_da_estatica(nome)
    f, upem, _ = ce.fonte(src, var)
    buf = hb.Buffer()
    buf.add_str(texto)
    buf.guess_segment_properties()
    feats = {'kern': True}
    if ls:
        feats.update(SEM_LIGADURAS)
    if tnum:
        feats['tnum'] = True
    hb.shape(f, buf, feats)
    return sum(p.x_advance for p in buf.glyph_positions) * tam / (upem * 1024) + ls * len(texto)


def ancestrais(els, base):
    """id → os ids medidos acima dele, do mais perto ao mais longe (pela árvore do template)."""
    from esboco import esboco
    tpl_id = {e['tpl']: k for k, e in els.items()}
    nos = {n['tpl']: n for n in esboco(base)}
    out = {}
    for k, e in els.items():
        cadeia, t = [], nos[e['tpl']]['parent']
        while t is not None:
            if t in tpl_id:
                cadeia.append(tpl_id[t])
            t = nos[t]['parent']
        out[k] = cadeia
    return out


def espacos_de_borda(base):
    """tpl → (o texto do elemento começa com um espaço que é dele, termina com um que é dele), pelo template literal:
    o espaço conta quando o vizinho de fora da tag não é espaço (senão o branco colapsa no de fora)."""
    from esboco import esboco
    from conjunto import caminho as cam
    with open(cam('extracao', base, 'template.html'), encoding='utf-8') as f:
        texto = f.read()
    out = {}
    for n in esboco(base):
        bloco = texto[n['ini']:n['fim']]
        aspas, a = None, 0
        for a, ch in enumerate(bloco):            # o fim da tag de abertura (fora de aspas)
            if aspas:
                aspas = None if ch == aspas else aspas
            elif ch in ('"', "'"):
                aspas = ch
            elif ch == '>':
                break
        meio = bloco[a + 1:bloco.rfind('</')] if bloco.rfind('</') > a else ''
        fora_antes = texto[n['ini'] - 1] if n['ini'] else ''
        fora_depois = texto[n['fim']] if n['fim'] < len(texto) else ''
        out[n['tpl']] = (meio[:1].isspace() and not fora_antes.isspace(),
                         meio[-1:].isspace() and not fora_depois.isspace())
    return out



def juntar_trechos(partes, els):
    """Os trechos (texto, id) em runs [texto, id do 1º, fonte]: os vizinhos com a mesma fonte se juntam — o Chromium
    modela por fonte, não por elemento (o kerning do par na borda entre dois elementos da mesma fonte conta)."""
    runs = []
    for txt, d in partes:
        fd = els[d]['style']['font']
        if runs and chave_trecho(runs[-1][2]) == chave_trecho(fd):
            runs[-1][0] += txt
        else:
            runs.append([txt, d, fd])
    return runs

def trechos_da_linha(dono, R, els, M, anc, brancas):
    """Os trechos (texto, id) da linha crua R do dono e o recuo dos descendentes entre o 1º e o último glifo."""
    T = R['text']
    quem = [dono] * len(T)
    span = {dono: (0, len(T))}
    perto = lambda ln: abs(ln['baseline'] - R['baseline']) <= 1 and ln['left'] >= R['left'] - 0.5 and \
        ln['right'] <= R['right'] + 0.5
    desc = []
    for d, cadeia in anc.items():
        if dono not in cadeia or not els[d].get('style', {}).get('font'):
            continue
        fonte_linhas = M['linesAll'].get(d) or M['lines'].get(d) or []
        nesta = [ln for ln in fonte_linhas if perto(ln)]
        if nesta:
            desc.append((cadeia.index(dono), nesta[0]['left'], d, nesta[0], fonte_linhas))
    cursor = {}
    extra = 0.0
    for prof, _, d, ln, todas in sorted(desc):
        pai = next(a for a in anc[d] if a in span)
        ini, fim = span[pai]
        i = T.find(ln['text'], max(ini, cursor.get(pai, ini)), fim)
        if i < 0:
            raise ValueError(f'{d}: «{ln["text"]}» fora da linha «{T}» de {dono}')
        j = i + len(ln['text'])
        st = M['styles'][d]
        # o espaço da borda que é do elemento: a medição apara o texto de cada elemento, o template não (o "ISBN<span>
        # do verso.</span>" da 69 e o "está<span> desligada para nós.</span>" da 41 — o espaço é da Instrument Serif)
        com_espaco_antes, com_espaco_depois = brancas[els[d]['tpl']]
        if i > ini and T[i - 1] == ' ' and com_espaco_antes and ln is todas[0]:
            i -= 1
        if j < fim and T[j] == ' ' and com_espaco_depois and ln is todas[-1]:
            j += 1
        cursor[pai] = j
        span[d] = (i, j)
        for x in range(i, j):
            quem[x] = d
        if i > 0 and ln is todas[0]:
            extra += recuo(st, 'Left')
        if j < len(T) and ln is todas[-1]:
            extra += recuo(st, 'Right')
    partes = []
    for x, d in enumerate(quem):
        if partes and partes[-1][1] == d:
            partes[-1][0] += T[x]
        else:
            partes.append([T[x], d])
    return partes, extra, sorted(span)


def main_por_trecho():
    from conjunto import indice
    base_de = {p['slug']: p.get('base', p['slug']) for p in indice()['pranchas']}
    res, fora, total = [], [], 0
    for f in sorted(glob.glob(caminho('layout', 'layout_*.json'))):
        L = json.load(open(f, encoding='utf-8'))
        slug = L['meta']['prancha']
        M = json.load(open(caminho('tmp', 'medicao', slug, 'medida.json'), encoding='utf-8'))
        els = L['elements']
        anc = ancestrais(els, base_de[slug])
        brancas = espacos_de_borda(base_de[slug])
        figtree_max = max(ff['weight'][1] for ff in L['fontFaces'] if ff['family'] == 'Figtree')
        # dono da linha composta = quem tem texto próprio e trechos de descendentes; sem texto próprio, os descendentes
        # medidos são conferidos por eles mesmos (o texto que não é de nenhum id fica listado)
        donos = {k for k, e in els.items() if e.get('linesAll') and M['lines'].get(k)}
        for k, e in els.items():
            if not e.get('linesAll') or k in donos or any(a in donos for a in anc[k]):
                continue
            for i, R in enumerate(M['linesAll'][k]):
                # o texto da linha = o dos descendentes conferidos: a linha composta de um dono, as próprias dos outros
                junto = ''.join(ln['text'] for d in els if k in anc[d] and not any(a in donos for a in anc[d])
                                for ln in ((M['linesAll'] if d in donos else M['lines']).get(d) or [])
                                if abs(ln['baseline'] - R['baseline']) <= 1)
                if sorted(junto.replace(' ', '')) != sorted(R['text'].replace(' ', '')):
                    onde = 'texto do desenho SVG, que fica no arquivo' if e['type'] == 'icon' else 'texto sem id'
                    fora.append(f'{slug} {k} L{i + 1} ({onde}: «{R["text"]}»)')
        for k, e in els.items():
            fo = e.get('style', {}).get('font')
            if not fo or any(a in donos for a in anc[k]):
                continue                       # sem texto, ou conferido na linha composta do dono
            composta = k in donos
            linhas = M['linesAll'][k] if composta else (M['lines'].get(k) or [])
            if not linhas:
                continue
            envolvidos = [k] + [d for d in els if k in anc[d]]
            # R8: o texto informativo (o app não desenha: o botão da Apple, o teclado do sistema) fica de fora; o resto
            # com glifo de fora da fonte (o "≈" da 17b, a "→" da 28c e da 30b) vai para a reserva do peso (D-54, D-281)
            informativos = [d for d in envolvidos if els[d].get('fallback') and els[d].get('informativo')]
            if informativos:
                fora.append(f'{slug} {k} (informativo, R8: fonte do sistema em {", ".join(informativos)})')
                continue
            for i, R in enumerate(linhas):
                if composta:
                    partes, extra, ids = trechos_da_linha(k, R, els, M, anc, brancas)
                else:
                    partes, extra, ids = [[R['text'], k]], 0.0, [k]
                runs = juntar_trechos(partes, els)
                w = wv = extra
                trechos = []
                for txt, d, fd in runs:
                    ls = 0.0 if fd['letterSpacing'] == 'normal' else float(fd['letterSpacing'][:-2])
                    tnum = 'tnum' in fd.get('features', [])
                    nome, var = arquivo(familia(L, els[d], fd), fd['style'], fd['weightCss'], fd['size'], figtree_max)
                    for sub, arq in por_cobertura(txt, nome, fd['weightCss']):
                        w += largura(os.path.join(FONTS, arq), var if arq == nome else None, sub, fd['size'], ls, tnum)
                        wv += largura_origem(arq, sub, fd['size'], ls, tnum)
                        trechos.append({'texto': sub, 'id': d, 'fonte': arq, 'tamanho': fd['size'], 'ls': ls,
                                        'tnum': tnum})
                chrome = round(R['right'] - R['left'], 3)
                total += 1
                item = {'prancha': slug, 'id': k, 'linha': i + 1, 'texto': R['text'],
                        'fonte': ' + '.join(dict.fromkeys(t['fonte'] for t in trechos)),
                        'chromium': chrome, 'harfbuzz': round(w, 4), 'diferenca': round(w - chrome, 4),
                        'estaticaMenosOrigem': round(w - wv, 4)}
                item['trechos'] = trechos         # o teste do Flutter monta a linha com eles (tamanho, ls, tnum)
                if extra:
                    item['recuo'] = round(extra, 3)
                res.append(item)
    res.sort(key=lambda r: -abs(r['diferenca']))
    piores = [r for r in res if abs(r['diferenca']) > LIMITE_TRECHO]
    resumo = {'linhas': total, 'compostas': sum(1 for r in res if len(r['trechos']) > 1 or 'recuo' in r),
              'maxDiferenca': max(abs(r['diferenca']) for r in res), 'acimaDoLimite': len(piores),
              'limite': LIMITE_TRECHO, 'maxEstaticaMenosOrigem': max(abs(r['estaticaMenosOrigem']) for r in res),
              'foraDaConferencia': fora}
    with open(caminho('validacaoFontes'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump({'resumo': resumo, 'linhas': res}, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print(json.dumps(resumo, ensure_ascii=False, indent=1))
    for r in res[:8]:
        print(f"  {r['diferenca']:+.4f}  {r['fonte']:32s} {r['id']} L{r['linha']} «{r['texto'][:40]}»")
    sys.exit(1 if piores else 0)


def main():
    if POR_TRECHO:
        return main_por_trecho()
    res, piores, fora, total = [], [], [], 0
    for f in sorted(glob.glob(caminho('layout', 'layout_*.json'))):
        L = json.load(open(f, encoding='utf-8'))
        slug = L['meta']['prancha']
        figtree_max = max(ff['weight'][1] for ff in L['fontFaces'] if ff['family'] == 'Figtree')
        chave = lambda f_: (f_['family'], f_['style'], f_['weightCss'], f_['size'], f_['letterSpacing'])
        for k, e in L['elements'].items():
            fo = e.get('style', {}).get('font')
            if not fo or not e.get('lines'):
                continue
            linhas = e['lines']
            if e['type'] == 'inline':
                # T02 (validacaoTrechos): o trecho inline com fonte própria (ou cujo pai não tem texto fora dele, como o
                # <mark> do grifo da 61/62) é conferido pelas próprias linhas; no leitor, pelas linhas do pai
                pai = L['elements'].get(k.rsplit('.', 1)[0], {})
                fp = pai.get('style', {}).get('font')
                if not (TRECHOS and (not fp or chave(fp) != chave(fo) or not pai.get('lines'))):
                    continue
            elif e.get('linesAll'):
                # texto composto: só confere se os filhos inline usam a MESMA fonte (ex.: parágrafo do leitor
                # com grifos); 'lines' sozinho não serve (a extensão inclui o texto dos filhos)
                filhos = [v for kk, v in L['elements'].items() if kk.startswith(k + '.') and v['type'] == 'inline']
                if any(chave(v['style']['font']) != chave(fo) for v in filhos):
                    fora.append(f'{k} (texto composto com fontes diferentes)')
                    if not TRECHOS:
                        continue
                    # T02: o texto próprio entra quando é contíguo — começo ou fim da linha completa (ex.: "Revisão" de
                    # "Revisão feita."); os trechos dos filhos são conferidos por eles mesmos
                    todas = {round(x['baseline'], 2): x['text'] for x in e['linesAll']}
                    linhas = [x for x in e['lines'] if (todas.get(round(x['baseline'], 2)) or '').startswith(x['text'])
                              or (todas.get(round(x['baseline'], 2)) or '').endswith(x['text'])]
                    if not linhas:
                        continue
                else:
                    linhas = e['linesAll']
            if e.get('fallback'):
                fora.append(f'{k} (fallback do sistema: {", ".join(e["fallback"])})')
                continue
            ls = 0.0 if fo['letterSpacing'] == 'normal' else float(fo['letterSpacing'][:-2])
            tnum = 'tnum' in fo.get('features', [])
            nome, var = arquivo(familia(L, e, fo), fo['style'], fo['weightCss'], fo['size'], figtree_max)
            path = os.path.join(FONTS, nome)
            for i, ln in enumerate(linhas):
                chrome = ln['right'] - ln['left']
                w = largura(path, var, ln['text'], fo['size'], ls, tnum)
                d = round(w - chrome, 4)
                total += 1
                item = {'prancha': slug, 'id': k, 'linha': i + 1, 'texto': ln['text'], 'fonte': nome,
                        'chromium': round(chrome, 3), 'harfbuzz': round(w, 3), 'diferenca': d}
                res.append(item)
                if fo['family'] == 'Literata':
                    vf = os.path.join(FONTS, 'Literata-VF.ttf')
                    wv = largura(vf, {'opsz': fo['size'], 'wght': fo['weightCss']}, ln['text'], fo['size'], ls, tnum)
                    item['variavel'] = round(wv, 3)
                    item['diferencaVariavel'] = round(wv - chrome, 4)
    res.sort(key=lambda r: -abs(r['diferenca']))
    piores = [r for r in res if abs(r['diferenca']) > LIMITE]
    lit = [r for r in res if 'diferencaVariavel' in r]
    resumo = {'linhas': total, 'maxDiferenca': max(abs(r['diferenca']) for r in res),
              'acimaDoLimite': len(piores), 'limite': LIMITE,
              'literataVariavelMaxDiferenca': max(abs(r['diferencaVariavel']) for r in lit) if lit else None,
              'foraDaConferencia': fora}
    with open(caminho('validacaoFontes'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump({'resumo': resumo, 'linhas': res}, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print(json.dumps(resumo, ensure_ascii=False, indent=1))
    for r in res[:8]:
        print(f"  {r['diferenca']:+.4f}  {r['fonte']:32s} {r['id']} L{r['linha']} «{r['texto'][:40]}»")
    sys.exit(1 if piores else 0)


if __name__ == '__main__':
    main()

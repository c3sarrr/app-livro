#!/usr/bin/env python3
"""G01.7 — confere as fontes geradas contra o navegador: para cada linha de texto medida nas 13 pranchas
(layout_<slug>.json), mede a largura com HarfBuzz usando o TTF que o app vai usar (estática da v1 ou da v2)
e compara com a largura medida no Chromium (right − left; inclui o letter-spacing do último caractere).
Também mede a Literata VARIÁVEL com opsz = tamanho (prévia do spike S1).
Regras de forma iguais às do Chromium: kerning ligado; letter-spacing ≠ 0 desliga ligaduras opcionais;
tabular-nums → 'tnum'. Linhas com glifo de fallback do sistema (ex.: "≈") ficam de fora e são listadas.
Saída: tools/fonts/validacao_fontes.json + resumo; código 1 se alguma linha passar de 0,05 px.
T02: as medições e a saída pelo conjunto (layout, validacaoFontes); a Figtree usa o maior peso que a prancha
declara (01/01b/60 vão até 700 → o CSS 800 é 700, D-246; 19–27b e 61–63 até 800) e a Bricolage abaixo de 12 px usa
a instância 12 (o eixo opsz começa em 12).
Uso: [CONJUNTO=inicio2] python3 tools/fonts/validar_fontes.py   (requer uharfbuzz)
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
        return f'Bricolage{num(max(tam, 12))}-ExtraBold.ttf', None
    if fam == 'Literata':
        return f'Literata{num(tam)}-{LABEL[peso]}.ttf', None
    if fam == 'Instrument Serif':
        return f"InstrumentSerif-{'Italic' if estilo == 'italic' else 'Regular'}.ttf", None
    if fam == 'Lora':
        return 'Lora-VF.ttf', {'wght': peso}
    if fam == 'Atkinson Hyperlegible':
        return f'AtkinsonHyperlegible-{LABEL[peso]}.ttf', None
    raise KeyError(fam)


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
        feats.update({'liga': False, 'clig': False, 'dlig': False, 'calt': False})
    if tnum:
        feats['tnum'] = True
    hb.shape(font, buf, feats)
    adv = sum(p.x_advance for p in buf.glyph_positions) * tam / upem
    return adv + ls * len(texto)


def main():
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
            nome, var = arquivo(fo['family'], fo['style'], fo['weightCss'], fo['size'], figtree_max)
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

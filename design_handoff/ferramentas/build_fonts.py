#!/usr/bin/env python3
"""
build_fonts.py — gera as fontes ESTÁTICAS do app Flutter a partir dos MESMOS
binários embutidos no arquivo "Redesign mobile — App de leitura.html"
(woff2 do Google Fonts -> ttf). Resultado validado: larguras de texto com
desvio < 0,01 px vs. o navegador.

POR QUE ESTÁTICAS (e não variáveis)?
- Bricolage Grotesque do arquivo é VARIÁVEL (eixos opsz 12–96, wght 200–800).
  O navegador aplica optical sizing automático: opsz = font-size em px
  (ex.: 42px -> opsz 42; 11px -> opsz 12 por clamp). O Flutter NÃO faz isso
  sozinho. Por isso geramos 1 instância por tamanho usado (wght 800).
- Figtree do arquivo é VARIÁVEL (wght 300–900, default 300 = Light). O
  @font-face do arquivo só declara 400/500/600/700, então os pedidos de 800
  são RENDERIZADOS como 700. Geramos 400/500/600/700.
- Instrument Serif já é estática (Regular e Italic): só convertemos.

POR QUE NÃO MESCLAR OS SUBSETS (latin + latin-ext)?
- O fontTools.merge quebra o kerning por classes (ex.: par "AV" perde o kern
  e "MACHADO DE ASSIS" fica +0,16 px mais largo). Mantemos os subsets
  separados e usamos fontFamilyFallback no Flutter — exatamente como o
  navegador faz com unicode-range.

POR QUE UPM 10000?
- O instanciador arredonda coordenadas/avanços para inteiros da UPM. Com a
  UPM 1000 original o erro é até 0,0005 em; com 10000 cai 10x.

Uso:   python3 build_fonts.py <pasta_ttfs_extraidos> <pasta_saida>
Req.:  pip install fonttools brotli
Novo tamanho de Bricolage no futuro? Acrescente em BRICOLAGE_OPSZ e rode de novo.
"""
import sys, os
from fontTools.ttLib import TTFont
from fontTools.ttLib.scaleUpem import scale_upem
from fontTools.varLib import instancer

SRC = sys.argv[1] if len(sys.argv) > 1 else '.'
OUT = sys.argv[2] if len(sys.argv) > 2 else 'out'
os.makedirs(OUT, exist_ok=True)
HI_UPEM = 10000

BRICOLAGE_OPSZ = [12, 18, 20, 22, 24, 26, 34, 42]          # 11px usa opsz 12 (clamp)
FIGTREE_WEIGHTS = {400: 'Regular', 500: 'Medium', 600: 'SemiBold', 700: 'Bold'}
SUBSETS = {'latin': '', 'latin-ext': 'Ext', 'vietnamese': 'Vi'}  # sufixo de família

def finalize(font, family, style_label, weight, italic=False):
    name = font['name']
    for nid in (1, 2, 3, 4, 6, 16, 17, 21, 22, 25):
        name.removeNames(nameID=nid)
    sub = 'Italic' if italic else 'Regular'
    ps = (family + '-' + style_label).replace(' ', '')
    for nid, val in ((1, family), (2, sub), (3, ps + ';static'), (4, f'{family} {style_label}'), (6, ps)):
        name.setName(val, nid, 3, 1, 0x409)
    os2 = font['OS/2']; os2.usWeightClass = weight
    # fsSelection: bit0 ITALIC, bit5 BOLD (só no peso 700), bit6 REGULAR (só 400 não-itálico)
    fs = os2.fsSelection & ~((1 << 0) | (1 << 5) | (1 << 6))
    if italic: fs |= 1 << 0
    if weight == 700: fs |= 1 << 5
    if weight == 400 and not italic: fs |= 1 << 6
    os2.fsSelection = fs
    font['head'].macStyle = (1 if weight == 700 else 0) | (2 if italic else 0)
    for t in ('STAT', 'MVAR', 'HVAR', 'VVAR', 'fvar', 'gvar', 'avar', 'cvar'):
        if t in font: del font[t]

def instance(path, coords):
    f = TTFont(path)
    scale_upem(f, HI_UPEM)
    return instancer.instantiateVariableFont(f, coords)

# Bricolage Grotesque — wght 800, 1 arquivo por opsz e por subset
for opsz in BRICOLAGE_OPSZ:
    for sub, sfx in SUBSETS.items():
        g = instance(os.path.join(SRC, f'Bricolage-{sub}.ttf'), {'wght': 800, 'opsz': opsz})
        fam = f'Bricolage{opsz}{sfx}'
        finalize(g, fam, 'ExtraBold', 800)
        out = os.path.join(OUT, f'Bricolage{opsz}{sfx}-ExtraBold.ttf'); g.save(out); print('ok', out)

# Figtree — 400/500/600/700 (800 do CSS renderiza como 700!)
for w, label in FIGTREE_WEIGHTS.items():
    for sub in ('latin', 'latin-ext'):
        sfx = SUBSETS[sub]
        g = instance(os.path.join(SRC, f'Figtree-{sub}.ttf'), {'wght': w})
        finalize(g, f'Figtree{sfx}', label, w)
        out = os.path.join(OUT, f'Figtree{sfx}-{label}.ttf'); g.save(out); print('ok', out)

# Instrument Serif — Regular e Italic (já estáticas)
for style in ('Regular', 'Italic'):
    for sub in ('latin', 'latin-ext'):
        sfx = SUBSETS[sub]
        f = TTFont(os.path.join(SRC, f'InstrumentSerif-{style}-{sub}.ttf'))
        finalize(f, f'InstrumentSerif{sfx}', style, 400, italic=(style == 'Italic'))
        out = os.path.join(OUT, f'InstrumentSerif{sfx}-{style}.ttf'); f.save(out); print('ok', out)

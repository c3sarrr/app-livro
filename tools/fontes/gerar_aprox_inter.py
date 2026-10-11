# D-54 (G12): só o glifo "≈" (U+2248) da Inter Bold 4.0 (OFL, github.com/rsms/inter, release v4.0,
# extras/ttf/Inter-Bold.ttf), numa família própria ("BookNestApprox") que a Figtree usa quando não tem o glifo.
# D-281 (T13.10): a mesma família nos pesos que as telas do projeto pedem — SemiBold (o "≈" da 17b, texto em 600) e
# ExtraBold (a "→" das dicas da 28c e do "não incomodar" da 30b, texto em 800) —, cada uma com o "≈" e a "→" (U+2192),
# recortadas da Inter 4.0 instalada no WSL (pacote fonts-inter 4.0+ds-1, /usr/share/fonts/opentype/inter/
# Inter-{SemiBold,ExtraBold}.otf, "Version 4.000;git-a52131595": a mesma build da Bold da D-54 e a fonte que o Chromium
# usou na medição). Saem .otf (contornos CFF, como a origem). A Bold da D-54 não muda.
# Reprodutível: o mesmo arquivo de entrada dá os mesmos bytes (as datas do 'head' não mudam).
# Uso: python tools/fontes/gerar_aprox_inter.py <Inter-Peso.ttf|otf> <saída> [Peso] [código hex…]
#      sem peso e códigos: Bold e 2248 (a D-54); a T13.10:
#      … Inter-SemiBold.otf assets/fonts/BookNestApprox-SemiBold.otf SemiBold 2248 2192
#      … Inter-ExtraBold.otf assets/fonts/BookNestApprox-ExtraBold.otf ExtraBold 2248 2192
import sys

from fontTools import subset
from fontTools.ttLib import TTFont

src, dst = sys.argv[1], sys.argv[2]
peso = sys.argv[3] if len(sys.argv) > 3 else 'Bold'
codigos = [int(c, 16) for c in sys.argv[4:]] or [0x2248]
opts = subset.Options()
opts.layout_features = []
opts.name_IDs = ['*']
opts.name_languages = ['*']
opts.notdef_outline = True
opts.recalc_timestamp = False
opts.glyph_names = False
font = TTFont(src, recalcTimestamp=False)
s = subset.Subsetter(opts)
s.populate(unicodes=codigos)
s.subset(font)
# Bold (e Regular) entram no par família/estilo de quatro membros; os outros pesos levam o peso no nome da família
# legada (1) e o par tipográfico (16/17), como a Inter de origem
ribbi = peso in ('Regular', 'Bold')
for rec in font['name'].names:
    if rec.nameID == 1:
        rec.string = 'BookNestApprox' if ribbi else f'BookNestApprox {peso}'
    elif rec.nameID == 16:
        rec.string = 'BookNestApprox'
    elif rec.nameID == 2:
        rec.string = peso if ribbi else 'Regular'
    elif rec.nameID == 17:
        rec.string = peso
    elif rec.nameID == 4:
        rec.string = f'BookNestApprox {peso}'
    elif rec.nameID == 6:
        rec.string = f'BookNestApprox-{peso}'
if 'CFF ' in font:
    cff = font['CFF '].cff
    cff.fontNames = [f'BookNestApprox-{peso}']
    top = cff.topDictIndex[0]
    top.FullName = f'BookNestApprox {peso}'
    top.FamilyName = 'BookNestApprox'
font.save(dst)

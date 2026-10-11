# D-54 (G12): só o glifo "≈" (U+2248) da Inter Bold 4.0 (OFL, github.com/rsms/inter, release v4.0,
# extras/ttf/Inter-Bold.ttf), numa família própria ("BookNestApprox") que a Figtree usa quando não tem o glifo.
# Reprodutível: o mesmo arquivo de entrada dá os mesmos bytes (as datas do 'head' não mudam).
# Uso: python tools/fontes/gerar_aprox_inter.py <Inter-Bold.ttf> assets/fonts/BookNestApprox-Bold.ttf
import sys

from fontTools import subset
from fontTools.ttLib import TTFont

src, dst = sys.argv[1], sys.argv[2]
opts = subset.Options()
opts.layout_features = []
opts.name_IDs = ['*']
opts.name_languages = ['*']
opts.notdef_outline = True
opts.recalc_timestamp = False
opts.glyph_names = False
font = TTFont(src, recalcTimestamp=False)
s = subset.Subsetter(opts)
s.populate(unicodes=[0x2248])
s.subset(font)
for rec in font['name'].names:
    if rec.nameID in (1, 16):
        rec.string = 'BookNestApprox'
    elif rec.nameID in (2, 17):
        rec.string = 'Bold'
    elif rec.nameID == 4:
        rec.string = 'BookNestApprox Bold'
    elif rec.nameID == 6:
        rec.string = 'BookNestApprox-Bold'
font.save(dst)

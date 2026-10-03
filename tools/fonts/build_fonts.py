#!/usr/bin/env python3
"""build_fonts.py (v2, G01.7) — fontes do leitor (telas 19–27b) a partir dos MESMOS binários do arquivo
"Redesign mobile — App de leitura (1).html":
  latin      → handoff_v2/referencia/fontes_do_arquivo/*.woff2 (embutidos no arquivo)
  demais     → tools/fonts/originais_v2/*.woff2 (as URLs fonts.gstatic.com que o arquivo referencia;
               manifesto com URL e sha256 em tools/fonts/originais_v2/manifesto.json)
Saída em assets/fonts/ (ainda NÃO registradas no pubspec — o registro, os estilos e os testes de
largura no Flutter são da G11; o bloco proposto fica em tools/fonts/pubspec_fonts_leitor.yaml).

Regras herdadas da v1 (design_handoff/ferramentas/build_fonts.py):
- Estáticas instanciadas com UPM 10000 (erro de arredondamento 10× menor); 1 família por tamanho quando a
  fonte tem optical size (o navegador usa opsz = font-size; o Flutter não faz isso sozinho).
- Subconjuntos NÃO são mesclados (o merge do fontTools quebra o kerning por classes): família base + Ext/Vi…
  e fontFamilyFallback no Flutter, como o navegador faz com unicode-range.
Novidades da v2:
- Figtree 800 é real nestas telas (D-16): Figtree{,Ext}-ExtraBold.ttf. ⚠ Na Início o 800 continua 700
  (D-14) — na G11 a w800 entra numa família própria ou a Início passa a pedir w700 explicitamente.
  Figtree 900 (só "ressaca" do estilo Ondulado da 23b) renderiza como 800: o @font-face só vai até 800.
- Bricolage 15,5 / 17 / 23 (w800) — tamanhos novos.
- Literata: estáticas por (tamanho, peso) usados nas telas + a fonte VARIÁVEL (opsz 7–72, wght 400–900,
  normal e itálico, 7 subconjuntos) para o spike S1 e para o texto do livro (D-17/D-18).
- Lora: SÓ a variável convertida (WOFF2 → TTF, sem instanciar nem renomear): o OFL da Lora tem
  Reserved Font Name "Lora", e instanciar seria uma versão modificada que não pode usar o nome.
  O padrão da variável é wght 400 = o peso usado na tela 26.
- Atkinson Hyperlegible: estática no arquivo → só conversão (Regular 400 e Bold 700, latin + latin-ext).
- Instrument Serif: as estáticas da v1 já cobrem (Regular/Italic, latin/latin-ext).
Uso: python3 tools/fonts/build_fonts.py   (requer fonttools e brotli)
"""
import io
import json
import os

from fontTools.ttLib import TTFont
from fontTools.ttLib.scaleUpem import scale_upem
from fontTools.varLib import instancer

AQUI = os.path.dirname(os.path.abspath(__file__))
RAIZ = os.path.abspath(os.path.join(AQUI, '..', '..'))
ARQ = os.path.join(RAIZ, 'handoff_v2', 'referencia', 'fontes_do_arquivo')
EXT = os.path.join(AQUI, 'originais_v2')
OUT = os.path.join(RAIZ, 'assets', 'fonts')
HI_UPEM = 10000

# sufixo de família por subconjunto (v1: '', Ext, Vi)
SFX = {'latin': '', 'latin-ext': 'Ext', 'vietnamese': 'Vi', 'cyrillic': 'Cyr', 'cyrillic-ext': 'CyrExt',
       'greek': 'Gr', 'greek-ext': 'GrExt', 'math': 'Math', 'symbols': 'Sym'}
UI_SUBSETS = ('latin', 'latin-ext', 'vietnamese')

BRICOLAGE_OPSZ = [15.5, 17, 23]                       # novos (12…42 já existem desde a v1)
# Literata usada nas telas 19–27b: peso → tamanhos (opsz = tamanho)
LITERATA = {400: [15.5, 16, 16.5, 17, 18, 20.5, 26], 500: [15, 17, 19, 25]}
LABEL = {400: 'Regular', 500: 'Medium', 600: 'SemiBold', 700: 'Bold', 800: 'ExtraBold'}


def src(familia, subset, estilo='normal'):
    embutidas = ('Figtree', 'Bricolage', 'Literata', 'Lora', 'Atkinson400')
    if subset == 'latin' and estilo == 'normal' and familia in embutidas:
        nome = {'Figtree': 'Figtree-latin-var-wght', 'Bricolage': 'BricolageGrotesque-latin-var-opsz-wght',
                'Literata': 'Literata-latin-var-opsz-wght', 'Lora': 'Lora-latin-var-wght',
                'Atkinson400': 'AtkinsonHyperlegible-Regular-latin'}[familia]
        return os.path.join(ARQ, nome + '.woff2')
    nome = {'Figtree': 'Figtree-normal-400_800', 'Bricolage': 'BricolageGrotesque-normal-500-800',
            'Literata': f'Literata-{estilo}-' + ('400_500' if estilo == 'normal' else '400'),
            'Lora': 'Lora-normal-400_500', 'Atkinson400': 'AtkinsonHyperlegible-normal-400',
            'Atkinson700': 'AtkinsonHyperlegible-normal-700'}[familia]
    return os.path.join(EXT, f'{nome}-{subset}.woff2')


def num(v):
    """15.5 → '15_5'; 17 → '17' (nome de família sem ponto)."""
    return str(int(v)) if float(v) == int(v) else str(v).replace('.', '_')


def finalize(font, family, style_label, weight, italic=False):
    """Igual à v1: renomeia a família (instâncias estáticas = versões modificadas, OFL sem RFN)."""
    name = font['name']
    for nid in (1, 2, 3, 4, 6, 16, 17, 21, 22, 25):
        name.removeNames(nameID=nid)
    sub = 'Italic' if italic else 'Regular'
    ps = (family + '-' + style_label).replace(' ', '')
    for nid, val in ((1, family), (2, sub), (3, ps + ';static'), (4, f'{family} {style_label}'), (6, ps)):
        name.setName(val, nid, 3, 1, 0x409)
    os2 = font['OS/2']
    os2.usWeightClass = weight
    fs = os2.fsSelection & ~((1 << 0) | (1 << 5) | (1 << 6))
    if italic:
        fs |= 1 << 0
    if weight == 700:
        fs |= 1 << 5
    if weight == 400 and not italic:
        fs |= 1 << 6
    os2.fsSelection = fs
    font['head'].macStyle = (1 if weight == 700 else 0) | (2 if italic else 0)
    for t in ('STAT', 'MVAR', 'HVAR', 'VVAR', 'fvar', 'gvar', 'avar', 'cvar'):
        if t in font:
            del font[t]


def save(font, nome, log):
    path = os.path.join(OUT, nome)
    buf = io.BytesIO()
    font.flavor = None
    font.recalcTimestamp = False      # mantém head.modified do binário de origem → bytes reprodutíveis
    font.save(buf, reorderTables=True)
    data = buf.getvalue()
    with open(path, 'wb') as f:
        f.write(data)
    log.append({'arquivo': nome, 'bytes': len(data)})
    print(f'ok {nome:44s} {len(data):>7d} B')


def instance(path, coords):
    f = TTFont(path)
    scale_upem(f, HI_UPEM)
    g = instancer.instantiateVariableFont(f, coords)
    avancos_do_hvar(g, path, coords)
    return g


def avancos_do_hvar(estatica, path, coords):
    """Avanços da instância = os que o HarfBuzz calcula pelo HVAR (é o que o Chromium usa).
    O instanciador do fontTools aplica os deltas do gvar (pontos fantasmas), que na Literata diferem do HVAR em
    até 0,0009 em (0,018 px por glifo a 20,5 px) — o bastante para a página do leitor sair 0,08–0,13 px por linha
    do navegador. Com o HVAR a diferença cai para a resolução da UPM 10000."""
    import uharfbuzz as hb
    ttf = TTFont(path)                 # o HarfBuzz não abre WOFF2: descompacta para TTF em memória
    ttf.flavor = None
    buf = io.BytesIO()
    ttf.save(buf)
    face = hb.Face(hb.Blob(buf.getvalue()))
    font = hb.Font(face)
    font.set_variations({k: float(v) for k, v in coords.items()})
    escala = face.upem * 1024
    font.scale = (escala, escala)
    hmtx = estatica['hmtx']
    order = estatica.getGlyphOrder()
    for gid, nome in enumerate(order):
        adv = font.get_glyph_h_advance(gid) / 1024 * (HI_UPEM / face.upem)
        lsb = hmtx.metrics[nome][1]
        hmtx.metrics[nome] = (int(round(adv)), lsb)
    estatica['hhea'].advanceWidthMax = max(a for a, _ in hmtx.metrics.values())


def main():
    os.makedirs(OUT, exist_ok=True)
    log = []
    # Figtree 800 (latin + latin-ext)
    for sub in ('latin', 'latin-ext'):
        g = instance(src('Figtree', sub), {'wght': 800})
        finalize(g, f'Figtree{SFX[sub]}', 'ExtraBold', 800)
        save(g, f'Figtree{SFX[sub]}-ExtraBold.ttf', log)
    # Bricolage — wght 800, 1 família por opsz e por subconjunto
    for opsz in BRICOLAGE_OPSZ:
        for sub in UI_SUBSETS:
            g = instance(src('Bricolage', sub), {'wght': 800, 'opsz': opsz})
            fam = f'Bricolage{num(opsz)}{SFX[sub]}'
            finalize(g, fam, 'ExtraBold', 800)
            save(g, f'{fam}-ExtraBold.ttf', log)
    # Literata estática — 1 família por tamanho (opsz = tamanho), pesos 400/500 dentro dela
    for w, tamanhos in LITERATA.items():
        for t in tamanhos:
            for sub in UI_SUBSETS:
                g = instance(src('Literata', sub), {'wght': w, 'opsz': t})
                fam = f'Literata{num(t)}{SFX[sub]}'
                finalize(g, fam, LABEL[w], w)
                save(g, f'{fam}-{LABEL[w]}.ttf', log)
    # Literata variável (normal e itálico, todos os subconjuntos do arquivo) — só conversão
    for estilo, subs in (('normal', ('latin', 'latin-ext', 'vietnamese', 'cyrillic', 'cyrillic-ext', 'greek', 'greek-ext')),
                         ('italic', ('latin', 'latin-ext', 'vietnamese', 'cyrillic', 'cyrillic-ext', 'greek', 'greek-ext'))):
        for sub in subs:
            g = TTFont(src('Literata', sub, estilo))
            save(g, f"Literata{'Italic' if estilo == 'italic' else ''}-VF{SFX[sub]}.ttf", log)
    # Lora variável — só conversão (Reserved Font Name "Lora")
    for sub in ('latin', 'latin-ext', 'vietnamese', 'cyrillic', 'cyrillic-ext', 'math', 'symbols'):
        g = TTFont(src('Lora', sub))
        save(g, f'Lora-VF{SFX[sub]}.ttf', log)
    # Atkinson Hyperlegible — estática, só conversão
    for w, chave, subs in ((400, 'Atkinson400', ('latin', 'latin-ext')), (700, 'Atkinson700', ('latin', 'latin-ext'))):
        for sub in subs:
            g = TTFont(src(chave, sub))
            save(g, f'AtkinsonHyperlegible{SFX[sub]}-{LABEL[w]}.ttf', log)
    with open(os.path.join(AQUI, 'fontes_leitor.json'), 'w', encoding='utf-8', newline='\n') as f:
        json.dump({'gerado_por': 'tools/fonts/build_fonts.py', 'arquivos': log}, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print(f'{len(log)} arquivos')


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""G01.3 — ids semânticos das pranchas 19–27b (fonte única dos idmaps).

Cada prancha = lista (tag, id) na ORDEM DO TEMPLATE (pré-ordem), a partir do elemento 4 (o frame),
ignorando o interior dos <svg> (os <svg> em si entram). O gerador confere a tag de cada posição contra
o template — qualquer desalinhamento para a geração. id None = elemento não medido.
O prefixo da prancha (pranchas.json) é acrescentado na frente: 'page.text' → 'r19.page.text'.

Convenções (iguais às da v1): camelCase em inglês; o caminho segue a hierarquia visual
(seção.grupo.item.parte); `.icon` = SVG de ícone, `.art` = ilustração, `.circle` = círculo do botão,
`.label` = texto separado do botão, `.badge` = contador, `.pill` = pílula de destaque.
Seções (recortes, tabelas e fases) = SECOES[slug]; todo id começa com o nome de uma seção, ou é um
contêiner especial sem seção (ESPECIAIS: 'frame' e o <main> da 25).

Uso: python3 tools/medicao/idmaps_spec.py            → gera tools/medicao/idmaps/<slug>.json e confere
     python3 tools/medicao/idmaps_spec.py --mostrar 22 → lista tpl, tag, id e texto para revisão
T02: com CONJUNTO=inicio2 a especificação vem do módulo do conjunto (conjuntos.json → idmapsSpec, com SPEC, SECOES
e ESPECIAIS) e a saída vai para a pasta idmaps dele; o gerador é este.
"""
import importlib
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from conjunto import C, caminho, indice  # noqa: E402
from esboco import esboco  # noqa: E402

AQUI = os.path.dirname(__file__)


def pref(base, items):
    return [(t, f'{base}.{n}' if n else base) for t, n in items]


# ───────────────────────── blocos comuns ─────────────────────────
FOOTER = [('div', 'footer'), ('span', 'footer.pageLabel'), ('span', 'footer.percent')]

TOP_ISLAND = pref('topIsland', [
    ('header', ''), ('a', 'close'), ('svg', 'close.icon'),
    ('span', 'titleBlock'), ('span', 'title'), ('span', 'author'),
    ('button', 'search'), ('svg', 'search.icon'),
    ('button', 'bookmark'), ('svg', 'bookmark.icon'),
])


def tool(name, badge=False):
    r = [('button', name), ('span', f'{name}.circle'), ('svg', f'{name}.icon')]
    return r + ([('span', f'{name}.badge')] if badge else [])


BOTTOM_ISLAND = pref('bottomIsland', [
    ('section', ''),
    ('div', 'scrubber'), ('span', 'scrubber.track'), ('span', 'scrubber.fill'), ('svg', 'scrubber.fill.wave'),
    ('span', 'scrubber.knob'), ('span', 'scrubber.bubble'), ('span', 'scrubber.bubble.tail'),
    ('div', 'progressRow'), ('span', 'progressRow.position'), ('strong', 'progressRow.position.percent'),
    ('span', 'progressRow.timeLeft'),
    ('div', 'tools'), ('button', 'tools.font'), ('span', 'tools.font.circle'),
    *pref('tools', tool('theme') + tool('notes', badge=True) + tool('annotate') + tool('toc')),
])

TIME_CHIP = [('span', 'timeChip'), ('svg', 'timeChip.icon')]

READER_CONTROLS = ([('div', 'frame'), ('article', 'page'), ('p', 'page.text')] + FOOTER + [('div', 'fade')]
                   + TOP_ISLAND + BOTTOM_ISLAND + TIME_CHIP)

# modo anotação (22–24b)
MODE_PILL = [('div', 'modePill'), ('span', 'modePill.iconCircle'), ('svg', 'modePill.icon'),
             ('span', 'modePill.texts'), ('span', 'modePill.title'), ('span', 'modePill.subtitle'),
             ('button', 'done'), ('svg', 'done.icon')]

TOOL_SHELF = pref('toolShelf', [('div', '')] + [x for n in ('pen', 'marker', 'eraser', 'lasso', 'line', 'space')
                                                 for x in (('button', n), ('svg', f'{n}.art'))])


def island(ativa):
    """Ilha da barra de anotação; `ativa` = ferramenta cujo rótulo tem a pílula brand."""
    labels = [('div', 'labels')]
    for n in ('pen', 'marker', 'eraser', 'lasso', 'line', 'space'):
        labels.append(('span', f'labels.{n}'))
        if n == ativa:
            labels.append(('span', f'labels.{n}.pill'))
    return pref('island', [('section', '')] + labels + [
        ('div', 'row'), ('button', 'colorWell'), ('span', 'colorWell.ink'),
        ('div', 'width'), ('button', 'width.thin'), ('span', 'width.thin.dot'),
        ('button', 'width.medium'), ('span', 'width.medium.dot'),
        ('button', 'width.thick'), ('span', 'width.thick.dot'),
        ('span', 'spacer'), ('button', 'undo'), ('svg', 'undo.icon'), ('button', 'redo'), ('svg', 'redo.icon'),
    ])


HAND_HIGHLIGHT = [('span', 'handHighlight'), ('svg', 'handHighlight.stroke')]
CIRCLED = [('span', 'circled'), ('svg', 'circled.ellipse'), ('svg', 'circled.flourish')]
WAVY = [('span', 'wavy'), ('svg', 'wavy.wave')]
DOUBLE = [('span', 'doubleUnderline'), ('span', 'doubleUnderline.line1'), ('span', 'doubleUnderline.line2')]


def ann_page(*marks):
    return [('div', 'frame'), ('article', 'page'), ('p', 'page.text')] + pref('page.text', [x for m in marks for x in m])


DESK_EDGE = [('div', 'deskEdge')]

# ───────────────────────── pranchas ─────────────────────────
SPEC = {}
SECOES = {}

SPEC['19_leitor_limpo'] = [('div', 'frame'), ('article', 'page'), ('p', 'page.text')] + FOOTER
SECOES['19_leitor_limpo'] = ['page', 'footer']

SPEC['20_leitor_controles'] = READER_CONTROLS
SECOES['20_leitor_controles'] = ['page', 'footer', 'fade', 'topIsland', 'bottomIsland', 'timeChip']
SPEC['26b_tema_noite'] = READER_CONTROLS
SECOES['26b_tema_noite'] = SECOES['20_leitor_controles']

SPEC['21_selecao_texto'] = [
    ('div', 'frame'), ('article', 'page'), ('p', 'page.text'),
    ('mark', 'page.text.highlight'),
    ('span', 'page.text.orphanLabel'),          # aria-label "Trecho selecionado" sem fundo (achado da G01)
    ('span', 'page.text.toolbarAnchor'),
    *pref('toolbar', [
        ('span', ''),
        ('span', 'colors'), ('span', 'colors.label'), ('span', 'colors.swatches'),
        ('button', 'colors.yellow'), ('button', 'colors.pink'), ('button', 'colors.green'), ('button', 'colors.lavender'),
        ('button', 'colors.other'), ('span', 'colors.other.center'), ('svg', 'colors.other.icon'),
        ('button', 'colors.underline'), ('svg', 'colors.underline.icon'),
        ('span', 'actions'),
        ('button', 'actions.note'), ('svg', 'actions.note.icon'),
        ('button', 'actions.copy'), ('svg', 'actions.copy.icon'),
        ('button', 'actions.share'), ('svg', 'actions.share.icon'),
        ('button', 'actions.search'), ('svg', 'actions.search.icon'),
    ]),
    ('span', 'page.text.handleStart'), ('span', 'page.text.handleStart.stem'), ('span', 'page.text.handleStart.knob'),
    ('span', 'page.text.selection'),
    ('span', 'page.text.handleEnd'), ('span', 'page.text.handleEnd.stem'), ('span', 'page.text.handleEnd.knob'),
] + FOOTER
SECOES['21_selecao_texto'] = ['page', 'toolbar', 'footer']

SPEC['22_modo_anotacao'] = (
    ann_page(HAND_HIGHLIGHT, CIRCLED,
             WAVY + [('span', 'wavy.touchRing'), ('span', 'wavy.touchDot')], DOUBLE)
    + DESK_EDGE + MODE_PILL + TOOL_SHELF + island('pen'))
SECOES['22_modo_anotacao'] = ['page', 'deskEdge', 'modePill', 'done', 'toolShelf', 'island']

PEN_PANEL = pref('penPanel', [
    ('section', ''), ('span', 'arrow'),
    ('div', 'header'), ('span', 'header.texts'), ('span', 'title'), ('span', 'subtitle'),
    ('button', 'close'), ('svg', 'close.icon'),
    ('div', 'preview'), ('svg', 'preview.art'),
    ('div', 'tipLabel'), ('div', 'tips'),
    ('button', 'tips.ballpoint'), ('svg', 'tips.ballpoint.sample'),
    ('button', 'tips.fountain'), ('svg', 'tips.fountain.sample'),
    ('button', 'tips.brush'), ('svg', 'tips.brush.sample'),
    ('div', 'sizeHeader'), ('span', 'sizeHeader.label'), ('span', 'sizeHeader.value'),
    ('div', 'size'), ('span', 'size.minDot'), ('span', 'size.slider'), ('span', 'size.slider.fill'),
    ('span', 'size.slider.knob'), ('span', 'size.maxDot'),
    ('div', 'colorLabel'), ('div', 'favorites'),
    ('button', 'favorites.coral'), ('button', 'favorites.purple'), ('button', 'favorites.blue'),
    ('button', 'favorites.green'), ('button', 'favorites.gold'), ('button', 'favorites.black'),
    ('button', 'favorites.add'), ('svg', 'favorites.add.icon'),
    ('div', 'picker'), ('span', 'picker.wheel'), ('span', 'picker.wheel.cursor'),
    ('span', 'picker.side'), ('span', 'picker.brightnessLabel'),
    ('span', 'picker.brightness'), ('span', 'picker.brightness.knob'),
    ('span', 'picker.hex'), ('span', 'picker.hex.swatch'), ('span', 'picker.hex.value'),
])

ANN_PAGE_23 = ann_page(HAND_HIGHLIGHT, CIRCLED, WAVY, DOUBLE)
SPEC['23_ajustes_caneta'] = (ANN_PAGE_23 + DESK_EDGE + MODE_PILL + [('div', 'fade')] + TOOL_SHELF
                             + island('pen') + PEN_PANEL)
SECOES['23_ajustes_caneta'] = ['page', 'deskEdge', 'modePill', 'done', 'fade', 'toolShelf', 'island', 'penPanel']


def mk_color(n):
    return [('button', f'colors.{n}'), ('span', f'colors.{n}.swatch'), ('span', f'colors.{n}.texts'),
            ('span', f'colors.{n}.label'), ('span', f'colors.{n}.count')]


MARKER_PANEL = pref('markerPanel', [
    ('section', ''), ('span', 'arrow'),
    ('div', 'header'), ('span', 'header.texts'), ('span', 'title'), ('span', 'subtitle'),
    ('button', 'close'), ('svg', 'close.icon'),
    ('div', 'preview'), ('span', 'preview.highlight'),
    ('div', 'styleLabel'), ('div', 'styles'),
    ('button', 'styles.fill'), ('span', 'styles.fill.sample'), ('span', 'styles.fill.sample.word'),
    ('button', 'styles.underline'), ('span', 'styles.underline.sample'), ('span', 'styles.underline.sample.word'),
    ('button', 'styles.wavy'), ('span', 'styles.wavy.sample'), ('span', 'styles.wavy.sample.word'),
    ('div', 'colorsHeader'), ('span', 'colorsHeader.label'), ('a', 'colorsHeader.editLabels'),
    ('div', 'colors'), *mk_color('yellow'), *mk_color('pink'), *mk_color('green'), *mk_color('lavender'),
    ('div', 'heightLabel'), ('div', 'heights'),
    ('button', 'heights.low'), ('span', 'heights.low.sample'),
    ('button', 'heights.medium'), ('span', 'heights.medium.sample'),
    ('button', 'heights.high'), ('span', 'heights.high.sample'),
    ('div', 'tip'), ('svg', 'tip.icon'), ('span', 'tip.text'), ('strong', 'tip.text.strong'),
])
SPEC['23b_ajustes_marcatexto'] = (ANN_PAGE_23 + DESK_EDGE + MODE_PILL + [('div', 'fade')] + TOOL_SHELF
                                  + island('marker') + MARKER_PANEL)
SECOES['23b_ajustes_marcatexto'] = ['page', 'deskEdge', 'modePill', 'done', 'fade', 'toolShelf', 'island',
                                    'markerPanel']

SPACE_OPENER = pref('page.spaceOpener', [
    ('div', ''), ('span', 'area'), ('span', 'seam'), ('span', 'seamDotLeft'), ('span', 'seamDotRight'),
    ('svg', 'trail'), ('span', 'finger'), ('span', 'sizeChip'), ('svg', 'sizeChip.icon'),
])
SPEC['24_abrindo_espaco'] = (
    ann_page(HAND_HIGHLIGHT, CIRCLED) + SPACE_OPENER
    + [('p', 'page.textBelow')] + pref('page.textBelow', WAVY + DOUBLE)
    + DESK_EDGE + MODE_PILL + TOOL_SHELF + island('space'))
SECOES['24_abrindo_espaco'] = ['page', 'deskEdge', 'modePill', 'done', 'toolShelf', 'island']

HAND_NOTE = pref('page.handNote', [
    ('div', ''), ('span', 'tag'), ('svg', 'tag.icon'), ('span', 'rule1'), ('span', 'rule2'),
    ('span', 'actions'), ('button', 'actions.collapse'), ('svg', 'actions.collapse.icon'),
    ('button', 'actions.delete'), ('svg', 'actions.delete.icon'),
    ('svg', 'ink'), ('span', 'hint'), ('button', 'handle'), ('span', 'handle.bar1'), ('span', 'handle.bar2'),
])
SPEC['24b_nota_mao'] = (
    ann_page(HAND_HIGHLIGHT, CIRCLED) + HAND_NOTE
    + [('p', 'page.textBelow')] + pref('page.textBelow', WAVY + DOUBLE)
    + DESK_EDGE + MODE_PILL + TOOL_SHELF + island('pen'))
SECOES['24b_nota_mao'] = ['page', 'deskEdge', 'modePill', 'done', 'toolShelf', 'island']


def card_head(kinds, more=True):
    """Cabeçalho do cartão da tela 25: rótulos de tipo (cada um com bolinha), separador, data, mais opções."""
    r = [('div', 'head')]
    for i, k in enumerate(kinds):
        r.append(('span', f'head.{k}'))
        if i == 0:
            r.append(('span', f'head.{k}.dot'))
        else:
            pass
    return r


def hl_card(n, kinds, body):
    """Cartão n da lista da tela 25. kinds = rótulos (o 1º tem a bolinha de cor); body = itens do corpo."""
    head = [('div', 'head'), ('span', f'head.{kinds[0]}'), ('span', f'head.{kinds[0]}.dot')]
    for k in kinds[1:]:
        head.append(('span', f'head.{k}'))
    head += [('span', 'head.sep'), ('span', 'head.date'), ('button', 'head.more'), ('svg', 'head.more.icon')]
    return pref(f'list.card{n}', [('article', '')] + head + [('div', 'body')] + body)


def page_sep(n, here=False):
    r = [('h2', f'list.sep{n}'), ('span', f'list.sep{n}.label')]
    if here:
        r.append(('svg', f'list.sep{n}.label.icon'))
    return r + [('span', f'list.sep{n}.rule')]


NOTE = [('div', 'body.note'), ('span', 'body.note.tape'), ('span', 'body.note.label'), ('span', 'body.note.text')]

SPEC['25_grifos_notas'] = [
    ('div', 'frame'),
    ('div', 'topBar'), ('a', 'topBar.back'), ('svg', 'topBar.back.icon'),
    ('button', 'topBar.export'), ('svg', 'topBar.export.icon'),
    ('svg', 'sparkle'),
    ('main', 'main'),
    ('h1', 'title'), ('span', 'title.serif'),
    ('p', 'subtitle'), ('strong', 'subtitle.strong'),
    ('label', 'search'), ('svg', 'search.icon'), ('input', 'search.input'),
    ('div', 'types'),
    ('button', 'types.all'), ('span', 'types.all.count'),
    ('button', 'types.highlights'), ('span', 'types.highlights.count'),
    ('button', 'types.notes'), ('span', 'types.notes.count'),
    ('button', 'types.handwritten'), ('span', 'types.handwritten.count'),
    ('button', 'types.drawings'), ('span', 'types.drawings.count'),
    ('div', 'filters'), ('div', 'filters.colors'), ('span', 'filters.colors.label'),
    ('button', 'filters.colors.yellow'), ('button', 'filters.colors.pink'), ('button', 'filters.colors.green'),
    ('button', 'filters.colors.lavender'), ('button', 'filters.colors.coral'),
    ('button', 'filters.clubOnly'), ('span', 'filters.clubOnly.circle'), ('svg', 'filters.clubOnly.icon'),
    ('section', 'list'),
    *page_sep(1),
    *hl_card(1, ['highlight'], [('p', 'body.quote'), ('span', 'body.quote.context'), ('mark', 'body.quote.mark')]),
    *page_sep(2),
    *hl_card(2, ['highlight', 'note'], [('p', 'body.quote'), ('mark', 'body.quote.mark')] + NOTE),
    *page_sep(3),
    *hl_card(3, ['highlight'], [('p', 'body.quote'), ('span', 'body.quote.context'), ('mark', 'body.quote.mark')]),
    *page_sep(4),
    *hl_card(4, ['highlight'], [('p', 'body.quote'), ('span', 'body.quote.context'), ('mark', 'body.quote.mark')]),
    *page_sep(5),
    *hl_card(5, ['highlight', 'note'], [('p', 'body.quote'), ('mark', 'body.quote.mark')] + NOTE + [
        ('div', 'body.club'), ('a', 'body.club.chip'), ('svg', 'body.club.chip.icon'),
        ('span', 'body.club.chip.replies')]),
    *page_sep(6, here=True),
    *hl_card(6, ['highlight'], [('p', 'body.quote'), ('span', 'body.quote.context'),
                                ('span', 'body.quote.ink'), ('svg', 'body.quote.ink.stroke'),
                                ('span', 'body.quote.after')]),
    *hl_card(7, ['drawing', 'handwritten'], [
        ('p', 'body.quote'), ('span', 'body.quote.ink'), ('svg', 'body.quote.ink.ellipse'),
        ('span', 'body.quote.after'),
        ('div', 'body.handNote'), ('span', 'body.handNote.tag'), ('svg', 'body.handNote.tag.icon'),
        ('span', 'body.handNote.rule1'), ('span', 'body.handNote.rule2'), ('svg', 'body.handNote.ink')]),
    *hl_card(8, ['drawings'], [
        ('p', 'body.quote'), ('span', 'body.quote.before'), ('span', 'body.quote.ink1'),
        ('svg', 'body.quote.ink1.wave'), ('span', 'body.quote.between'), ('span', 'body.quote.ink2'),
        ('span', 'body.quote.ink2.line1'), ('span', 'body.quote.ink2.line2'), ('span', 'body.quote.after')]),
    ('div', 'end'), ('p', 'end.text'), ('br', None), ('a', 'end.cta'), ('span', 'end.cta.label'),
]
SECOES['25_grifos_notas'] = ['topBar', 'sparkle', 'title', 'subtitle', 'search', 'types', 'filters', 'list', 'end']

SPEC['26_ajustes_leitura'] = [
    ('div', 'frame'), ('article', 'page'), ('p', 'page.text'),
    ('span', 'livePill'), ('span', 'livePill.dot'),
    *pref('sheet', [
        ('section', ''), ('span', 'grabber'),
        ('div', 'header'), ('h1', 'title'), ('span', 'title.serif'), ('button', 'close'), ('svg', 'close.icon'),
        ('div', 'size'), ('button', 'size.smaller'), ('span', 'size.steps'),
        *[('span', f'size.step{i}') for i in range(1, 8)],
        ('button', 'size.larger'),
        ('div', 'fontLabel'), ('div', 'fonts'),
        *[x for n in ('literata', 'lora', 'figtree', 'atkinson')
          for x in (('button', f'fonts.{n}'), ('span', f'fonts.{n}.sample'), ('span', f'fonts.{n}.name'),
                    ('span', f'fonts.{n}.caption'))],
        ('div', 'paperLabel'), ('div', 'papers'),
        ('button', 'papers.cream'), ('span', 'papers.cream.card'), ('span', 'papers.cream.sample'),
        ('span', 'papers.cream.line1'), ('span', 'papers.cream.line2'), ('span', 'papers.cream.check'),
        ('svg', 'papers.cream.check.icon'), ('span', 'papers.cream.name'),
        *[x for n in ('white', 'sepia', 'night')
          for x in (('button', f'papers.{n}'), ('span', f'papers.{n}.card'), ('span', f'papers.{n}.sample'),
                    ('span', f'papers.{n}.line1'), ('span', f'papers.{n}.line2'), ('span', f'papers.{n}.name'))],
        ('div', 'spacingLabel'), ('div', 'spacing'),
        *[x for n in ('tight', 'medium', 'loose') for x in (('button', f'spacing.{n}'), ('svg', f'spacing.{n}.icon'))],
        ('div', 'marginsLabel'), ('div', 'margins'),
        *[x for n in ('narrow', 'medium', 'wide') for x in (('button', f'margins.{n}'), ('svg', f'margins.{n}.icon'))],
    ]),
]
SECOES['26_ajustes_leitura'] = ['page', 'livePill', 'sheet']

TOC_HEAD = pref('sheet', [
    ('section', ''), ('span', 'grabber'),
    ('div', 'header'), ('span', 'header.texts'), ('h1', 'title'), ('span', 'subtitle'),
    ('button', 'close'), ('svg', 'close.icon'),
    ('div', 'tabs'), ('button', 'tabs.chapters'), ('span', 'tabs.chapters.count'),
    ('button', 'tabs.bookmarks'), ('svg', 'tabs.bookmarks.icon'), ('span', 'tabs.bookmarks.count'),
])


def marks(n, parts):
    return [('span', f'marks'), ('span', 'marks.symbols')] + [('span', f'marks.{p}') for p in parts] + [('span', 'marks.count')]


def chap(i, *, marks_parts=None, read=True):
    r = [('li', ''), ('a', 'link'), ('span', 'numeral'), ('span', 'title')]
    if marks_parts is not None:
        r += marks(i, marks_parts)
    r += [('span', 'page')]
    r += [('span', 'read'), ('svg', 'read.icon')] if read else [('span', 'status')]
    return pref(f'sheet.chapters.ch{i}', r)


SPEC['27_sumario'] = [
    ('div', 'frame'), ('article', 'page'), ('p', 'page.text'), ('div', 'fade'),
    *TOC_HEAD,
    *pref('sheet.club', [('a', ''), ('span', 'flag'), ('svg', 'flag.icon'), ('span', 'texts'),
                         ('span', 'kicker'), ('span', 'goal'), ('span', 'arrow'), ('svg', 'arrow.icon')]),
    ('nav', 'sheet.chapters'), ('ul', 'sheet.chapters.list'),
    *chap(25, marks_parts=['highlight']),
    *chap(26), *chap(27), *chap(28), *chap(29), *chap(30),
    *chap(31, marks_parts=['highlight', 'note']),
    *pref('sheet.chapters.ch32', [
        ('li', ''), ('a', 'link'), ('span', 'row'), ('span', 'numeral'), ('span', 'title'), ('span', 'page'),
        ('svg', 'progressRing'),
        ('span', 'meta'), ('span', 'youAreHere'), ('svg', 'youAreHere.icon'),
        ('span', 'marks'), ('span', 'marks.symbols'), ('span', 'marks.highlight'), ('span', 'marks.ink'),
        ('span', 'marks.handwritten'), ('svg', 'marks.handwritten.icon'), ('span', 'marks.count'),
    ]),
    *chap(33, read=False), *chap(34, read=False), *chap(35, read=False), *chap(36, read=False),
    *chap(37, read=False),
]
SECOES['27_sumario'] = ['page', 'fade', 'sheet']


def bm(i, here=False):
    r = [('li', ''), ('div', 'row'), ('a', 'link'), ('span', 'head'), ('span', 'head.page'), ('span', 'head.chapter')]
    if here:
        r.append(('span', 'head.here'))
    r += [('span', 'excerpt'), ('span', 'date'), ('button', 'ribbon'), ('svg', 'ribbon.icon')]
    return pref(f'sheet.bookmarks.item{i}', r)


SPEC['27b_sumario_marcadas'] = [
    ('div', 'frame'), ('article', 'page'), ('p', 'page.text'), ('div', 'fade'),
    *TOC_HEAD,
    ('nav', 'sheet.bookmarks'), ('ul', 'sheet.bookmarks.list'),
    *bm(1), *bm(2), *bm(3, here=True),
    ('p', 'sheet.hint'), ('span', 'sheet.hint.iconWrap'), ('svg', 'sheet.hint.icon'), ('span', 'sheet.hint.text'),
]
SECOES['27b_sumario_marcadas'] = ['page', 'fade', 'sheet']


ESPECIAIS = {'frame', 'main'}

# ───────────────────────── gerador ─────────────────────────
def nos_medidos(slug):
    """Pré-ordem do template a partir do frame (tpl 4), sem o interior dos <svg>."""
    nodes = esboco(slug)
    by = {n['tpl']: n for n in nodes}

    def dentro_de_svg(n):
        p = n['parent']
        while p is not None:
            if by[p]['tag'] == 'svg':
                return True
            p = by[p]['parent']
        return False
    return [n for n in nodes if n['tpl'] >= 4 and not dentro_de_svg(n)]


def gerar(slug, prefixo, SPEC=None, SECOES=None, ESPECIAIS=None):
    SPEC, SECOES, ESPECIAIS = SPEC or globals()['SPEC'], SECOES or globals()['SECOES'], ESPECIAIS or globals()['ESPECIAIS']
    spec = SPEC[slug]
    nos = nos_medidos(slug)
    erros = []
    if len(nos) != len(spec):
        erros.append(f'{slug}: {len(nos)} elementos no template × {len(spec)} na especificação')
    idmap, ids = {}, set()
    for i, (n, (tag, nome)) in enumerate(zip(nos, spec)):
        if n['tag'] != tag:
            erros.append(f'{slug}: posição {i} tpl {n["tpl"]}: template <{n["tag"]}> «{n["text"][:30]}» × spec <{tag}> {nome}')
            break
        if nome is None:
            continue
        full = f'{prefixo}.{nome}'
        if full in ids:
            erros.append(f'{slug}: id repetido {full}')
        ids.add(full)
        if nome not in ESPECIAIS and not any(nome == s or nome.startswith(s + '.') for s in SECOES[slug]):
            erros.append(f'{slug}: {full} fora de qualquer seção')
        idmap[str(n['tpl'])] = full
    return idmap, erros


def especificacao():
    """(SPEC, SECOES, ESPECIAIS) do conjunto: as deste arquivo no leitor; as do módulo idmapsSpec nos outros."""
    if C['idmapsSpec'] == 'idmaps_spec':
        return SPEC, SECOES, ESPECIAIS
    m = importlib.import_module(C['idmapsSpec'])
    return m.SPEC, m.SECOES, m.ESPECIAIS


def main():
    cfg = indice()
    SPEC, SECOES, ESPECIAIS = especificacao()
    if '--mostrar' in sys.argv:
        alvo = sys.argv[sys.argv.index('--mostrar') + 1]
        p = next(p for p in cfg['pranchas'] if alvo in (p['tela'], p['slug']))
        spec = SPEC.get(p['slug'], [])
        for i, n in enumerate(nos_medidos(p['slug'])):
            t, nome = spec[i] if i < len(spec) else ('?', '?')
            a = n['attrs'].get('aria-label', '')
            print(f"{n['tpl']:>4} {n['tag']:8s} {('OK ' if t == n['tag'] else '≠≠ ' + t):10s} {nome or '—':48s} {a[:30]:30s} {n['text'][:40]}")
        return
    os.makedirs(caminho('idmaps'), exist_ok=True)
    todos = []
    total = 0
    for p in cfg['pranchas']:
        idmap, erros = gerar(p['slug'], p['prefixo'], SPEC, SECOES, ESPECIAIS)
        todos += erros
        total += len(idmap)
        with open(caminho('idmaps', f"{p['slug']}.json"), 'w', encoding='utf-8', newline='\n') as f:
            json.dump({'prancha': p['slug'], 'prefixo': p['prefixo'],
                       'secoes': [f"{p['prefixo']}.{s}" for s in SECOES[p['slug']]],
                       'especiais': sorted(f"{p['prefixo']}.{e}" for e in ESPECIAIS if f"{p['prefixo']}.{e}" in idmap.values()),
                       'ids': idmap},
                      f, ensure_ascii=False, indent=1)
            f.write('\n')
        print(f"{p['slug']:24s} {len(idmap):>4d} ids  {len(erros)} erro(s)")
    if todos:
        print('\n'.join(todos))
        sys.exit(1)
    print(f'OK: {total} ids em {len(cfg["pranchas"])} pranchas')


if __name__ == '__main__':
    main()

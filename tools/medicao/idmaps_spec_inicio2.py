#!/usr/bin/env python3
"""T02 — ids semânticos das pranchas da Início e da revisão (01, 01b, 60, 61, 62, 63).

Mesmo formato do idmaps_spec.py (o gerador é o dele: CONJUNTO=inicio2 python3 tools/medicao/idmaps_spec.py): cada
prancha = lista (tag, id) na ordem do template, sem o interior dos <svg>; id None = elemento não medido (os <br>).

Os ids da Início seguem os da v1 (design_handoff/referencia/layout/layout_inicio.json) onde o elemento é o mesmo — a
T03 troca a suíte da v1 pela da 01 nova (D-240) e o app já usa essas chaves. O que é novo: `header.search` (a lupa),
`hero.pagePill`/`hero.formatPill`, `alsoReading.card*.play`/`.meta` (o livro de papel), `today.readNow`
(o "Ler agora"), a seção `review` (o cartão "Seus grifos de hoje"), `forYou.item*.cover.*` com os desenhos novos e a
`miniBar` da 01b (o cronômetro).

As 01, 01b e 60 são a mesma página: a 60 é a 01 rolada 930 px (o `transform` do <main>), com os mesmos 296 elementos;
a 01b tem 844 de altura, o "pausar" no Brás Cubas, nenhum cartão da revisão, outros dois livros no "Para você"
(Quincas Borba e O Cortiço, sem o <br>) e a mini-barra do cronômetro entre o degradê e a barra de navegação.
"""


def pref(base, items):
    # '' = o próprio base; None = elemento sem id (os <br>)
    return [(t, None if n is None else f'{base}.{n}' if n else base) for t, n in items]


# ───────────────────────── a Início (01, 01b, 60) ─────────────────────────
HEADER = [
    ('header', 'header'), ('div', 'header.identity'), ('div', 'header.avatar'), ('div', 'header.greetingColumn'),
    ('span', 'header.greeting'), ('span', 'header.name'),
    ('div', 'header.actions'), ('a', 'header.search'), ('svg', 'header.search.icon'),
    ('button', 'header.bell'), ('svg', 'header.bell.icon'), ('span', 'header.bell.dot'),
]

HEADLINE = [('h1', 'headline'), ('br', None), ('span', 'headline.serif')]

HERO = pref('hero', [
    ('section', ''), ('svg', 'sparkleLarge'), ('svg', 'sparkleSmall'),
    ('div', 'topRow'), ('div', 'cover'), ('svg', 'cover.art'), ('div', 'cover.spine'),
    ('div', 'meta'), ('div', 'meta.top'), ('span', 'pills'), ('span', 'pagePill'), ('span', 'formatPill'),
    ('div', 'titleBlock'), ('h2', 'title'), ('span', 'author'),
    ('div', 'meta.bottom'), ('div', 'progressRow'), ('span', 'percent'), ('span', 'timeLeft'),
    ('div', 'progressBar'), ('div', 'progressFill'),
    ('div', 'actions'), ('a', 'cta'), ('svg', 'cta.icon'), ('span', 'cta.label'),
    ('button', 'notesButton'), ('svg', 'notesButton.icon'), ('span', 'notesButton.badge'),
])

ALSO_READING = pref('alsoReading', [
    ('section', ''), ('div', 'header'), ('h3', 'title'), ('span', 'count'), ('div', 'grid'),
    # o livro de papel: a capa é o link; o botão redondo inicia (ou pausa, na 01b) o cronômetro
    ('div', 'card1'), ('div', 'card1.top'), ('a', 'card1.cover'), ('div', 'card1.cover.spine'),
    ('div', 'card1.cover.hat'), ('div', 'card1.cover.brim'), ('div', 'card1.cover.title'), ('br', None),
    ('button', 'card1.play'), ('svg', 'card1.play.icon'),
    ('div', 'card1.textBlock'), ('span', 'card1.title'), ('span', 'card1.author'),
    ('span', 'card1.meta'), ('svg', 'card1.meta.icon'),
    ('a', 'card2'), ('div', 'card2.top'), ('div', 'card2.cover'), ('div', 'card2.cover.spine'),
    ('div', 'card2.cover.circle'), ('div', 'card2.cover.title'), ('br', None),
    ('div', 'card2.ring'), ('svg', 'card2.ring.svg'), ('span', 'card2.ring.label'),
    ('div', 'card2.textBlock'), ('span', 'card2.title'), ('span', 'card2.author'),
    ('span', 'card2.meta'), ('svg', 'card2.meta.icon'),
])

TODAY = pref('today', [
    ('section', ''), ('div', 'decoCircleLarge'), ('div', 'decoCircleSmall'),
    ('div', 'header'), ('h3', 'title'), ('span', 'title.serif'), ('span', 'streakPill'), ('svg', 'streakPill.icon'),
    ('div', 'goalRow'), ('div', 'dial'), ('svg', 'dial.svg'), ('div', 'dial.center'), ('span', 'dial.value'),
    ('span', 'dial.caption'),
    ('div', 'goalText'), ('p', 'goalText.sentence'), ('strong', 'goalText.sentence.strong'),
    ('a', 'readNow'), ('svg', 'readNow.icon'), ('span', 'readNow.label'),
    ('div', 'chips'), ('span', 'chip.sessions'), ('span', 'chip.highlights'),
    ('div', 'week'), ('div', 'week.header'), ('span', 'week.title'), ('span', 'week.total'),
    ('div', 'week.chart'), ('div', 'week.goalLine'),
    *[x for i in range(7) for x in (('div', f'week.bar{i}'), ('div', f'week.bar{i}.fill'))],
    ('div', 'week.labels'), *[('span', f'week.label{i}') for i in range(7)],
    ('div', 'footer'), ('svg', 'footer.icon'), ('span', 'footer.text'), ('strong', 'footer.text.strong'),
])


def review_card(i):
    return [('span', f'art.card{i}')] + [('span', f'art.card{i}.line{j}') for j in range(4)]


REVIEW = pref('review', [
    ('section', ''), ('span', 'art'), *review_card(1), *review_card(2), *review_card(3), ('svg', 'art.sparkle'),
    ('span', 'textBlock'), ('span', 'kicker'), ('span', 'title'), ('span', 'title.serif'), ('span', 'subtitle'),
    ('a', 'cta'), ('svg', 'cta.icon'), ('span', 'cta.label'),
])


def for_you(lendo):
    # item 2 e 3: Memorial de Aires e Casa de Pensão na 01/60; Quincas Borba e O Cortiço (sem <br>) na 01b
    item3_titulo = [('div', 'item3.cover.title')] + ([] if lendo else [('br', None)])
    return pref('forYou', [
        ('section', ''), ('div', 'header'), ('h3', 'title'), ('a', 'seeAll'), ('svg', 'seeAll.icon'),
        ('span', 'reasonChip'), ('svg', 'reasonChip.icon'), ('div', 'carousel'),
        ('a', 'item1'), ('div', 'item1.cover'), ('div', 'item1.cover.spine'), ('div', 'item1.cover.blob'),
        ('div', 'item1.cover.title'), ('br', None), ('div', 'item1.cover.author'),
        ('div', 'item1.textBlock'), ('span', 'item1.title'), ('span', 'item1.author'),
        ('a', 'item2'), ('div', 'item2.cover'), ('div', 'item2.cover.spine'), ('div', 'item2.cover.lines'),
        ('div', 'item2.cover.line1'), ('div', 'item2.cover.line2'), ('div', 'item2.cover.line3'),
        ('div', 'item2.cover.textBlock'), ('div', 'item2.cover.title'), ('br', None), ('div', 'item2.cover.author'),
        ('div', 'item2.textBlock'), ('span', 'item2.title'), ('span', 'item2.author'),
        ('a', 'item3'), ('div', 'item3.cover'), ('div', 'item3.cover.spine'), ('div', 'item3.cover.archOuter'),
        ('div', 'item3.cover.archInner'), ('div', 'item3.cover.textBlock'), *item3_titulo,
        ('div', 'item3.cover.author'),
        ('div', 'item3.textBlock'), ('span', 'item3.title'), ('span', 'item3.author'),
    ])


CLUB = pref('club', [
    ('section', ''), ('div', 'ticket'), ('div', 'body'), ('div', 'topRow'), ('span', 'pill'), ('div', 'avatars'),
    *[('span', f'avatar{i}') for i in range(4)],
    ('div', 'titleBlock'), ('h3', 'title'), ('br', None), ('span', 'title.serif'), ('span', 'subtitle'),
    ('div', 'progressBlock'), ('div', 'progressTrack'), ('div', 'progressBar'), ('div', 'progressFill'),
    ('span', 'youMarker'), ('div', 'progressLabels'), ('span', 'groupLabel'), ('span', 'youLabel'),
    ('a', 'cta'), ('svg', 'cta.icon'), ('span', 'cta.label'), ('span', 'cta.badge'),
    ('div', 'stub'), ('span', 'stub.label'), ('div', 'stub.date'), ('span', 'stub.weekday'), ('span', 'stub.day'),
    ('span', 'stub.month'), ('span', 'stub.time'),
    ('span', 'notchTop'), ('span', 'notchBottom'),
])


def recent_row(i, cover):
    return pref(f'row{i}', [('div', ''), ('div', 'cover'), *[('div', f'cover.{c}') for c in cover],
                            ('a', 'textBlock'), ('span', 'title'), ('span', 'subtitle'), ('span', 'tag'),
                            ('button', 'more'), ('svg', 'more.icon')])


RECENT = pref('recent', [
    ('section', ''), ('div', 'header'), ('h3', 'title'), ('a', 'libraryLink'), ('svg', 'libraryLink.icon'),
    ('div', 'list'),
    *recent_row(0, ['moon', 'bar']), *recent_row(1, ['spine', 'ring', 'dot']), *recent_row(2, ['spine', 'arch']),
])

BOTTOM_FADE = [('div', 'bottomFade')]

# 01b: a sessão do cronômetro em andamento (toque abre o cronômetro — sem prancha, D-243 b)
MINI_BAR = pref('miniBar', [
    ('a', ''), ('span', 'progress'), ('span', 'cover'), ('svg', 'cover.art'),
    ('span', 'texts'), ('span', 'kicker'), ('span', 'kicker.dot'), ('span', 'title'),
    ('span', 'time'), ('button', 'pause'), ('svg', 'pause.icon'),
])


def nav_item(nome):
    return [('a', f'nav.{nome}'), ('svg', f'nav.{nome}.icon'), ('span', f'nav.{nome}.label')]


NAV = [('nav', 'nav'), *nav_item('home'), *nav_item('library'),
       ('a', 'nav.scanner'), ('span', 'nav.scanner.fab'), ('svg', 'nav.scanner.icon'), ('span', 'nav.scanner.label'),
       *nav_item('clubs'), *nav_item('profile')]


def inicio(lendo):
    return [('div', 'frame'), ('main', 'main'), *HEADER, *HEADLINE, *HERO, *ALSO_READING, *TODAY,
            *([] if lendo else REVIEW), *for_you(lendo), *CLUB, *RECENT, *BOTTOM_FADE,
            *(MINI_BAR if lendo else []), *NAV]


SECOES_INICIO = ['header', 'headline', 'hero', 'alsoReading', 'today', 'review', 'forYou', 'club', 'recent',
                 'bottomFade', 'nav']

SPEC = {
    '001_inicio': inicio(lendo=False),
    '001b_inicio_lendo_agora': inicio(lendo=True),
    '060_inicio_grifos_de_hoje': inicio(lendo=False),
}
SECOES = {
    '001_inicio': SECOES_INICIO,
    '001b_inicio_lendo_agora': [s for s in SECOES_INICIO if s != 'review'] + ['miniBar'],
    '060_inicio_grifos_de_hoje': SECOES_INICIO,
}

# ───────────────────────── a revisão (61, 62) ─────────────────────────
REVIEW_HEADER = pref('header', [
    ('header', ''), ('div', 'bar'), ('button', 'close'), ('svg', 'close.icon'),
    ('span', 'title'), ('span', 'title.serif'), ('span', 'counter'),
    ('div', 'progressBlock'), ('div', 'progress'), *[('span', f'progress.step{i}') for i in range(5)],
])


def book_row(base):
    # a linha do livro do cartão: lombada de 12×17, "Dom Casmurro · pág. 6" e a etiqueta com a bolinha da cor
    return pref(base, [('div', ''), ('span', 'book'), ('span', 'book.spine'), ('span', 'book.label'),
                       ('span', 'tag'), ('span', 'tag.dot')])


SPEC['061_revisao_grifo_2_de_5'] = [
    ('div', 'frame'), *REVIEW_HEADER,
    *pref('deck', [
        ('div', ''), ('span', 'behind2'), ('span', 'behind1'),
        ('article', 'card'), *book_row('card.top'),
        ('p', 'card.quote'), ('mark', 'card.quote.mark'),
        ('span', 'card.note'), ('span', 'card.note.tape'), ('span', 'card.note.label'), ('span', 'card.note.text'),
        ('span', 'card.spacer'),
        ('div', 'card.footer'), ('span', 'card.footer.when'), ('span', 'card.footer.reviewed'),
    ]),
    ('p', 'swipeHint'),
    *pref('actions', [
        ('div', ''), ('div', 'frequency'), ('button', 'less'), ('svg', 'less.icon'), ('button', 'more'),
        ('svg', 'more.icon'),
        ('div', 'row'), ('button', 'note'), ('svg', 'note.icon'), ('button', 'share'), ('svg', 'share.icon'),
        ('button', 'next'), ('span', 'next.label'), ('svg', 'next.icon'),
    ]),
]
SECOES['061_revisao_grifo_2_de_5'] = ['header', 'deck', 'swipeHint', 'actions']


def done_card(i):
    return pref(f'art.card{i}', [('span', ''), ('span', 'line0'), ('span', 'line1'), ('span', 'line2'),
                                 ('span', 'check'), ('svg', 'check.icon')])


SPEC['062_revisao_fim'] = [
    ('div', 'frame'), *REVIEW_HEADER,
    *pref('summary', [
        ('main', ''), ('div', 'art'), *[x for i in range(1, 6) for x in done_card(i)],
        ('h1', 'title'), ('span', 'title.serif'),
        ('span', 'streakPill'), ('svg', 'streakPill.icon'),
        ('div', 'stats'), *[x for n in ('more', 'less', 'newNote')
                            for x in (('span', f'stats.{n}'), ('span', f'stats.{n}.value'), ('span', f'stats.{n}.label'))],
        ('section', 'newNote'), *book_row('newNote.top'),
        ('p', 'newNote.quote'), ('mark', 'newNote.quote.mark'),
        ('span', 'newNote.note'), ('span', 'newNote.note.tape'), ('span', 'newNote.note.label'),
        ('span', 'newNote.note.text'),
        ('div', 'tomorrow'), ('svg', 'tomorrow.icon'), ('span', 'tomorrow.text'), ('strong', 'tomorrow.text.strong'),
    ]),
    *pref('footer', [
        ('div', ''), ('button', 'cta'), ('svg', 'cta.icon'), ('span', 'cta.label'),
        ('p', 'settings'), ('a', 'settings.link'),
    ]),
]
SECOES['062_revisao_fim'] = ['header', 'summary', 'footer']

# ───────────────────────── a imagem para compartilhar (63) ─────────────────────────
SWATCHES = ['cream', 'yellow', 'pink', 'green', 'lavender', 'ink']
SPEC['063_revisao_imagem_compartilhar'] = [
    ('div', 'frame'), ('div', 'scrim'),
    *pref('sheet', [
        ('section', ''), ('span', 'handle'),
        ('div', 'header'), ('span', 'title'), ('span', 'title.serif'), ('button', 'close'), ('svg', 'close.icon'),
        ('div', 'previewWrap'), ('div', 'preview'), ('svg', 'preview.sparkle'), ('span', 'preview.quoteMark'),
        ('p', 'preview.quote'), ('span', 'preview.quote.highlight'), ('span', 'preview.spacer'),
        ('span', 'preview.book'), ('span', 'preview.author'),
        ('span', 'preview.footer'), ('span', 'preview.footer.handle'), ('span', 'preview.footer.brand'),
        ('span', 'preview.footer.brand.mark'), ('svg', 'preview.footer.brand.icon'),
        ('div', 'colors'), *[('button', f'colors.{c}') for c in SWATCHES],
        ('div', 'toggles'),
        ('div', 'toggles.note'), ('span', 'toggles.note.label'), ('button', 'toggles.note.switch'),
        ('span', 'toggles.note.switch.knob'),
        ('div', 'toggles.handle'), ('span', 'toggles.handle.label'), ('button', 'toggles.handle.switch'),
        ('span', 'toggles.handle.switch.knob'),
        ('div', 'actions'),
        *[x for n in ('save', 'stories', 'copy', 'more')
          for x in (('button', f'actions.{n}'), ('span', f'actions.{n}.tile'), ('svg', f'actions.{n}.icon'))],
    ]),
]
SECOES['063_revisao_imagem_compartilhar'] = ['scrim', 'sheet']

ESPECIAIS = {'frame', 'main'}

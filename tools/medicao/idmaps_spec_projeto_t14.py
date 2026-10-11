#!/usr/bin/env python3
"""T13.4 (R4) — ids semânticos das telas da etapa 7 · T14 (Biblioteca e Detalhes): 02, 36, 17 e 17b.

Mesmo formato do idmaps_spec.py: cada prancha = lista (tag, id) na ordem do template (`data-dc-tpl` a partir do quadro,
tpl 4), sem o interior dos <svg>; id None = elemento não medido (os <br>). Junto das outras etapas em
idmaps_spec_projeto.py (o gerador: CONJUNTO=projeto python3 tools/medicao/idmaps_spec.py).

- 02 · Biblioteca: título, busca e filtros, coleções (3 cartões com a pilha de lombadas), as abas de status (presas
  enquanto a estante rola), ordenar e grade/lista, e a estante de 4 prateleiras com 3 livros cada (`shelf.book1` …
  `book12`, na ordem de leitura; a 4ª prateleira continua por baixo da navegação, só as capas). As capas são CSS: os
  nomes das peças dizem a forma (circle, ring, dot, arch…). A navegação tem os mesmos ids da Início (01).
- 36 · Biblioteca vazia: o título, a prateleira desenhada (4 lugares tracejados, o livro rosa e a etiqueta
  "o seu aqui?"), a chamada, o texto e as três ações; o degradê e a navegação como na 02.
- 17 · Detalhes do livro físico e 17b · Detalhes do e-book (telas irmãs: os mesmos nomes onde o desenho é o mesmo).
  O cartão do meio muda — `session` (o cronômetro, no físico) e `progress` (a página e a porcentagem, no e-book) —, e
  em `highlights` o físico tem a contagem, a legenda com a câmera, "Fotografar um trecho" e a enquete do clube; o
  e-book tem "Ver os 12" e o ingresso do próximo encontro.
"""


def pref(base, items):
    # '' = o próprio base; None = elemento sem id (os <br>)
    return [(t, None if n is None else f'{base}.{n}' if n else base) for t, n in items]


# ───────────────────────── a navegação e o degradê (02, 36; os ids da Início) ─────────────────────────
def nav_item(nome):
    return [('a', f'nav.{nome}'), ('svg', f'nav.{nome}.icon'), ('span', f'nav.{nome}.label')]


NAV = [('nav', 'nav'), *nav_item('home'), *nav_item('library'),
       ('a', 'nav.scanner'), ('span', 'nav.scanner.fab'), ('svg', 'nav.scanner.icon'), ('span', 'nav.scanner.label'),
       *nav_item('clubs'), *nav_item('profile')]
BOTTOM_FADE = [('div', 'bottomFade')]

# ───────────────────────── 02 · Biblioteca ─────────────────────────
B02_HEADER = pref('header', [
    ('header', ''), ('h1', 'title'), ('span', 'title.serif'), ('button', 'add'), ('svg', 'add.icon'),
])

B02_SEARCH = pref('search', [
    ('div', ''), ('label', 'field'), ('svg', 'field.icon'), ('input', 'field.input'),
    ('button', 'filters'), ('svg', 'filters.icon'),
])


def collection(i, lombadas, faixa):
    # a pilha de lombadas (div) com a faixa de cada uma (span) — a 3ª coleção (PDFs) não tem faixa
    pilha = [x for j in range(1, lombadas + 1)
             for x in ([('div', f'pile.spine{j}')] + ([('span', f'pile.spine{j}.band')] if faixa else []))]
    return pref(f'collections.card{i}', [
        ('a', ''), ('div', 'pile'), *pilha, ('div', 'textBlock'), ('span', 'title'), ('span', 'count'),
    ])


B02_COLLECTIONS = [
    *pref('collections', [('section', ''), ('div', 'header'), ('h2', 'title'), ('a', 'seeAll'), ('svg', 'seeAll.icon'),
                          ('div', 'carousel')]),
    *collection(1, 4, True), *collection(2, 4, True), *collection(3, 3, False),
]

STATUS_TABS = ['all', 'reading', 'wantToRead', 'read', 'favorites', 'abandoned']
B02_STATUS = [('div', 'statusTabs'),
              *[x for n in STATUS_TABS for x in (('button', f'statusTabs.{n}'), ('span', f'statusTabs.{n}.count'))]]

B02_SORT_VIEW = pref('sortView', [
    ('div', ''), ('button', 'sort'), ('svg', 'sort.icon'), ('span', 'sort.prefix'), ('svg', 'sort.chevron'),
    ('div', 'toggle'), ('button', 'toggle.grid'), ('svg', 'toggle.grid.icon'),
    ('button', 'toggle.list'), ('svg', 'toggle.list.icon'),
])


def capa_texto(titulo_br, autor=True):
    # o bloco do título e do autor no pé da capa (o título em Instrument Serif, quebrado com <br> em 2 linhas)
    return [('div', 'cover.textBlock'), ('div', 'cover.title'), *([('br', None)] if titulo_br else []),
            *([('div', 'cover.author')] if autor else [])]


def info(extra):
    # o texto debaixo da capa: título, autor e o que muda por livro (progresso, etiqueta ou notas)
    return [('div', 'info'), ('span', 'info.title'), ('span', 'info.author'), *extra]


PROGRESSO = [('div', 'info.progress'), ('div', 'info.progress.bar'), ('div', 'info.progress.fill'),
             ('span', 'info.progress.percent')]
ETIQUETA = [('span', 'info.tag')]
ETIQUETA_LIDO = [('span', 'info.tag'), ('svg', 'info.tag.icon')]


def livro_lendo(n, pecas, titulo_br=True):
    # 1ª prateleira (lendo): a capa e a fita coral (svg) num invólucro; embaixo, a barra de progresso
    return pref(f'shelf.book{n}', [
        ('a', ''), ('div', 'coverWrap'), ('div', 'cover'), *[('div', f'cover.{p}') for p in pecas],
        *capa_texto(titulo_br), ('svg', 'ribbon'), *info(PROGRESSO),
    ])


def livro(n, pecas, titulo, extra):
    # 2ª e 3ª prateleiras: a capa direto no link; o pé da capa (título/autor, ou só o título e o selo PDF) por livro
    return pref(f'shelf.book{n}', [('a', ''), ('div', 'cover'), *[('div', f'cover.{p}') for p in pecas], *titulo,
                                   *info(extra)])


def livro_baixo(n, pecas, titulo_br):
    # 4ª prateleira (por baixo da navegação): só a capa, com o título solto no pé
    return pref(f'shelf.book{n}', [('a', ''), ('div', 'cover'), *[('div', f'cover.{p}') for p in pecas],
                                   ('div', 'cover.title'), *([('br', None)] if titulo_br else [])])


def prateleira(r, livros):
    # a tábua (div absoluta, top 158,5) e a grade de 3 colunas
    return [('div', f'shelf.row{r}'), ('div', f'shelf.row{r}.plank'), ('div', f'shelf.row{r}.grid'), *livros]


SELO_PDF = [('span', 'cover.formatBadge')]
B02_SHELF = [
    ('div', 'shelf'),
    *prateleira(1, [
        *livro_lendo(1, ['spine', 'circle', 'ring']),                   # Dom Casmurro, 62%
        *livro_lendo(2, ['spine', 'arch']),                             # Mrs. Dalloway, 34%
        *livro_lendo(3, ['spine', 'ring', 'dot']),                      # Orgulho e Preconceito, 81%
    ]),
    *prateleira(2, [
        *livro(4, ['spine', 'archOutline', 'arch'], capa_texto(False), ETIQUETA),               # Senhora · Novo
        *livro(5, ['spine', 'ringOuter', 'ringInner', 'dot'],                                   # O Alienista · PDF, Lido
               [('div', 'cover.title'), ('br', None), *SELO_PDF], ETIQUETA_LIDO),
        *livro(6, ['circle', 'ring'], capa_texto(True), ETIQUETA),                              # Frankenstein · Quero ler
    ]),
    *prateleira(3, [
        # Teoria Literária: a apostila em PDF (folha clara com o rótulo, o título, as linhas e o grifo amarelo)
        *pref('shelf.book7', [
            ('a', ''), ('div', 'cover'), ('span', 'cover.kicker'), ('span', 'cover.title'), ('br', None),
            ('div', 'cover.lines'), ('span', 'cover.lines.line1'), ('span', 'cover.lines.line2'),
            ('span', 'cover.lines.highlight'), ('span', 'cover.lines.line3'), ('span', 'cover.lines.line4'),
            ('span', 'cover.lines.line5'), ('span', 'cover.formatBadge'),
            ('div', 'info'), ('span', 'info.title'), ('span', 'info.source'), ('span', 'info.notes'),
            ('svg', 'info.notes.icon'),
        ]),
        *livro(8, ['spine', 'bars', 'bars.bar1', 'bars.bar2', 'bars.bar3'], capa_texto(True), ETIQUETA_LIDO),  # Quincas
        *livro(9, ['spine', 'arch', 'door'], capa_texto(False), ETIQUETA_LIDO),                                # Cortiço
    ]),
    *prateleira(4, [
        *livro_baixo(10, ['spine', 'capsule'], False),                  # Iracema
        *livro_baixo(11, ['spine', 'slash', 'circle'], True),           # Crime e Castigo
        *livro_baixo(12, ['spine', 'oval', 'seam'], True),              # A Metamorfose
    ]),
]

SPEC = {
    '002_biblioteca': [('div', 'frame'), ('main', 'main'), *B02_HEADER, *B02_SEARCH, *B02_COLLECTIONS, *B02_STATUS,
                       *B02_SORT_VIEW, *B02_SHELF, *BOTTOM_FADE, *NAV],
}
SECOES = {
    '002_biblioteca': ['header', 'search', 'collections', 'statusTabs', 'sortView', 'shelf', 'bottomFade', 'nav'],
}

# ───────────────────────── 36 · Biblioteca vazia ─────────────────────────
SPEC['036_biblioteca_vazia'] = [
    ('div', 'frame'), ('main', 'main'),
    ('h1', 'title'), ('br', None), ('span', 'title.serif'),
    *pref('illustration', [
        ('div', ''), *[('span', f'slot{i}') for i in range(1, 5)],
        ('span', 'book'), ('svg', 'book.icon'), ('span', 'tag'), ('span', 'plank'),
    ]),
    ('h2', 'heading'), ('br', None), ('span', 'heading.serif'), ('p', 'body'),
    *pref('actions', [
        ('div', ''), ('a', 'scan'), ('svg', 'scan.icon'), ('span', 'scan.label'),
        ('div', 'row'), ('a', 'search'), ('svg', 'search.icon'), ('a', 'ebook'), ('svg', 'ebook.icon'),
    ]),
    *BOTTOM_FADE, *NAV,
]
SECOES['036_biblioteca_vazia'] = ['title', 'illustration', 'heading', 'body', 'actions', 'bottomFade', 'nav']

# ───────────────────────── 17 e 17b · Detalhes do livro ─────────────────────────
D_HALO = [('div', 'halo'), ('div', 'halo.center')]

D_HEADER = pref('header', [
    ('header', ''), ('a', 'back'), ('svg', 'back.icon'), ('span', 'actions'),
    ('button', 'share'), ('svg', 'share.icon'), ('button', 'more'), ('svg', 'more.icon'),
])

D_COVER = pref('cover', [
    ('div', ''), ('div', 'book'), ('svg', 'book.art'), ('span', 'book.spine'),
    ('span', 'formatTag'), ('svg', 'formatTag.icon'),
    ('svg', 'sparkleLarge'), ('svg', 'sparkleSmall'),
    ('button', 'change'), ('svg', 'change.icon'), ('span', 'plank'),
])

D_TITLE = [('h1', 'title'), ('br', None), ('span', 'title.serif')]

D_META = pref('meta', [
    ('div', ''), ('span', 'author'), ('span', 'dot'), ('span', 'year'), ('span', 'format'), ('svg', 'format.icon'),
])

D_STATUS = pref('status', [('div', ''), ('button', 'wantToRead'), ('button', 'reading'), ('button', 'read')])

# 17: o cronômetro (o livro de papel conta minutos; a página é opcional)
D17_SESSION = pref('session', [
    ('section', ''), ('div', 'top'), ('svg', 'ring'), ('div', 'textBlock'), ('div', 'today'),
    ('span', 'today.goal'), ('div', 'total'),
    ('button', 'start'), ('svg', 'start.icon'), ('span', 'start.label'),
    ('div', 'page'), ('span', 'page.text'), ('strong', 'page.text.strong'), ('span', 'page.text.optional'),
    ('a', 'page.update'), ('svg', 'page.update.icon'),
])

# 17b: o progresso do e-book (salvo sozinho)
D17B_PROGRESS = pref('progress', [
    ('section', ''), ('div', 'top'), ('div', 'textBlock'), ('div', 'kicker'), ('div', 'page'),
    ('span', 'page.total'), ('div', 'percent'),
    ('div', 'bar'), ('span', 'bar.track'), ('span', 'bar.fill'), ('svg', 'bar.fill.edge'),
    ('div', 'timeLeft'),
    ('div', 'actions'), ('button', 'continue'), ('svg', 'continue.icon'), ('span', 'continue.label'),
    ('button', 'highlights'), ('svg', 'highlights.icon'), ('span', 'highlights.badge'),
])

D_MOOD = pref('mood', [
    ('section', ''), ('div', 'header'), ('h2', 'title'), ('span', 'voters'),
    ('div', 'card'), ('div', 'tags'), *[x for i in range(1, 5) for x in (('span', f'tag{i}'), ('span', f'tag{i}.percent'))],
    ('div', 'paceLabel'), ('div', 'pace'), ('span', 'pace.slow'), ('span', 'pace.medium'),
    ('span', 'pace.medium.percent'), ('span', 'pace.fast'),
    ('div', 'splitLabels'), ('span', 'splitLabels.characters'), ('span', 'splitLabels.plot'),
    ('div', 'split'), ('span', 'split.track'), ('span', 'split.fill'), ('svg', 'split.fill.edge'),
])

D_SYNOPSIS = pref('synopsis', [
    ('section', ''), ('div', 'header'), ('h2', 'title'), ('p', 'text'), ('a', 'text.more'),
    ('div', 'facts'), *[x for i in range(1, 5)
                        for x in (('div', f'fact{i}'), ('div', f'fact{i}.label'), ('div', f'fact{i}.value'))],
])

D_CLUB_TEXT = [('span', 'club.textBlock'), ('span', 'club.kicker'), ('span', 'club.title'), ('span', 'club.meta')]

D17_HIGHLIGHTS = pref('highlights', [
    ('section', ''), ('div', 'header'), ('h2', 'title'), ('span', 'count'),
    ('figure', 'quote'), ('blockquote', 'quote.text'), ('span', 'quote.text.mark'),
    ('figcaption', 'quote.caption'), ('svg', 'quote.caption.icon'),
    ('button', 'photograph'), ('svg', 'photograph.icon'),
    # a enquete do clube: o selo "1º" e a seta
    ('a', 'club'), ('span', 'club.rank'), *D_CLUB_TEXT, ('svg', 'club.chevron'),
])

D17B_HIGHLIGHTS = pref('highlights', [
    ('section', ''), ('div', 'header'), ('h2', 'title'), ('a', 'seeAll'),
    ('figure', 'quote'), ('blockquote', 'quote.text'), ('span', 'quote.text.mark'),
    ('figcaption', 'quote.caption'),
    # o ingresso do próximo encontro: o canhoto com a data (dia da semana, dia, mês e hora)
    ('a', 'club'), ('span', 'club.date'), ('span', 'club.date.weekday'), ('span', 'club.date.day'),
    ('span', 'club.date.monthTime'), *D_CLUB_TEXT,
])


def detalhes(meio, grifos):
    return [('div', 'frame'), *D_HALO, ('main', 'main'), *D_HEADER, *D_COVER, *D_TITLE, *D_META, *D_STATUS, *meio,
            *D_MOOD, *D_SYNOPSIS, *grifos]


SECOES_DETALHES = ['halo', 'header', 'cover', 'title', 'meta', 'status', 'mood', 'synopsis', 'highlights']
SPEC['017_detalhes_fisico'] = detalhes(D17_SESSION, D17_HIGHLIGHTS)
SPEC['017b_detalhes_ebook'] = detalhes(D17B_PROGRESS, D17B_HIGHLIGHTS)
SECOES['017_detalhes_fisico'] = SECOES_DETALHES[:6] + ['session'] + SECOES_DETALHES[6:]
SECOES['017b_detalhes_ebook'] = SECOES_DETALHES[:6] + ['progress'] + SECOES_DETALHES[6:]

ESPECIAIS = {'frame', 'main'}

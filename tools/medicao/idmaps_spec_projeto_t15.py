#!/usr/bin/env python3
"""T13.5 (R4) — ids semânticos das telas da etapa 8 · T15 (Scanner e Busca): 03, 39, 40, 41, 42, 69, 69b, 28, 28b,
28c e 28d.

Mesmo formato do idmaps_spec.py: cada prancha = lista (tag, id) na ordem do template (`data-dc-tpl` a partir do quadro,
tpl 4), sem o interior dos <svg>; id None = elemento não medido (os <br>). Junto das outras etapas em
idmaps_spec_projeto.py (o gerador: CONJUNTO=projeto python3 tools/medicao/idmaps_spec.py).

- Scanner (03, 39, 40, 41, 42, 69, 69b; telas irmãs, os mesmos nomes onde o desenho é o mesmo): a câmera congelada
  (`camera`: o verso do livro e a etiqueta do código), o escurecido fora da moldura (`dim`), o realce do código lido
  (`detected`, com o selo), os cantos da moldura (`corners`), o chip de estado (`status`) e a barra do topo
  (`controls`: fechar, Código | Digitar e a lanterna — na aba Digitar, a ajuda). A folha que sobe (`sheet`) muda por
  estado; as peças comuns têm o mesmo nome: a alça, o chip e o ISBN do topo, o livro (`sheet.book`, 03 e 42), o
  desenho com o texto ao lado (`sheet.lead`, 39 e 40), o "Salvar como", a ação principal (`sheet.actions.primary`:
  Adicionar à biblioteca, Adicionar à mão, Iniciar leitura) com "escanear de novo", e o rodapé com o link.
  41 e 69/69b não têm câmera: o fundo (`backdrop`) é listrado ou pontilhado. 69/69b: o título, a etiqueta do ISBN
  (`sticker`: as fitas, o cartão com os dígitos e o código de barras que se imprime) e, embaixo, a barra de teclas do
  app (`toolbar`) sobre o teclado numérico do sistema (`keypad`, desenhado com a fonte do sistema: informativo, R8).
- Busca (28, 28b, 28c): a mesma barra de busca (`searchBar`; com o X de limpar quando há texto, 28b e 28c). 28 ·
  Explorar: recentes, os 8 climas, os 8 gêneros (cada um com o livrinho inclinado) e "Em alta nos clubes" (4 livros;
  a capa do Cortiço é o prédio com as 12 janelas, as outras são desenho). 28b · Resultados: as abas, os livros, os
  clubes, os trechos (os `mark` são a palavra buscada) e o cartão do scanner. 28c · Nada encontrado.
- 28d · Adicionar à mão: o topo, a capa automática (com a troca, a etiqueta, as fotos e as 5 cores), o formulário e o
  botão.
"""


def pref(base, items):
    # '' = o próprio base; None = elemento sem id (os <br>)
    return [(t, None if n is None else f'{base}.{n}' if n else base) for t, n in items]


SPEC, SECOES = {}, {}

# ───────────────────────── Scanner: as peças comuns ─────────────────────────


def camera(anel):
    # o verso do livro (a lombada escura, a citação e o autor desfocados; na 03, o selo redondo) e a etiqueta do código
    return pref('camera', [
        ('div', ''), ('div', 'book'), ('div', 'book.spine'), ('div', 'book.quote'), ('div', 'book.author'),
        *([('div', 'book.ring')] if anel else []),
        ('div', 'label'), ('span', 'label.isbn'), ('svg', 'label.barcode'),
    ])


DIM = [('div', 'dim')]
DETECTED = pref('detected', [('div', ''), ('span', 'badge'), ('svg', 'badge.icon')])
CORNERS = [('svg', 'corners')]
STATUS = pref('status', [('div', ''), ('span', 'chip'), ('span', 'chip.badge'), ('svg', 'chip.badge.icon')])


def controls(direita):
    # a barra do topo: fechar, Código | Digitar e, à direita, a lanterna (câmera) ou a ajuda (aba Digitar)
    return pref('controls', [
        ('div', ''), ('button', 'close'), ('svg', 'close.icon'),
        ('div', 'mode'), ('button', 'mode.code'), ('svg', 'mode.code.icon'),
        ('button', 'mode.type'), ('svg', 'mode.type.icon'),
        ('button', direita), ('svg', f'{direita}.icon'),
    ])


SHEET_TOP = [('span', 'handle'), ('div', 'top'), ('span', 'chip'), ('svg', 'chip.icon'), ('span', 'isbn')]
SAVE_AS = [('span', 'saveAs.label'), ('div', 'saveAs.options'), ('button', 'saveAs.options.wantToRead'),
           ('button', 'saveAs.options.reading'), ('button', 'saveAs.options.read')]
FOOTER = [('p', 'footer'), ('a', 'footer.link')]


def acoes(tag_primaria, rotulo_span):
    # a ação principal (com o ícone e, quando o texto vem num <span>, o rótulo) e o botão redondo de escanear de novo
    return [('div', 'actions'), (tag_primaria, 'actions.primary'), ('svg', 'actions.primary.icon'),
            *([('span', 'actions.primary.label')] if rotulo_span else []),
            ('button', 'actions.scanAgain'), ('svg', 'actions.scanAgain.icon')]


def livro_capa():
    # a capa CSS do Brás Cubas (a lombada, a elipse escura, o título e o autor)
    return [('a', 'book'), ('div', 'book.cover'), ('div', 'book.cover.spine'), ('div', 'book.cover.ellipse'),
            ('div', 'book.cover.title'), ('div', 'book.cover.author'), ('div', 'book.textBlock'),
            ('h2', 'book.title'), ('span', 'book.author')]


LEAD = [('div', 'lead'), ('svg', 'lead.art'), ('span', 'lead.textBlock'), ('span', 'lead.title'),
        ('span', 'lead.title.serif'), ('span', 'lead.body')]

SCANNER_CAMERA = ['camera', 'dim', 'detected', 'corners', 'status', 'controls', 'sheet']

# ───────────────────────── 03 · Livro encontrado ─────────────────────────
SPEC['003_scanner_encontrado'] = [
    ('div', 'frame'), *camera(True), *DIM, *DETECTED, *CORNERS, *STATUS, *controls('torch'),
    *pref('sheet', [
        ('section', ''), *SHEET_TOP,
        *livro_capa(), ('span', 'book.meta'),
        # a coleção em que o livro entra (a pilha de 3 lombadas e o check de incluído)
        ('span', 'book.collection'), ('span', 'book.collection.pile'),
        *[('span', f'book.collection.pile.spine{i}') for i in range(1, 4)],
        ('span', 'book.collection.check'), ('svg', 'book.collection.check.icon'),
        ('svg', 'book.chevron'),
        *SAVE_AS, *acoes('button', True), *FOOTER,
    ]),
]
SECOES['003_scanner_encontrado'] = SCANNER_CAMERA

# ───────────────────────── 39 · Mirando ─────────────────────────
SPEC['039_scanner_mirando'] = [
    ('div', 'frame'), *camera(False), *DIM, *CORNERS, ('div', 'scanLine'), *STATUS, *controls('torch'),
    *pref('sheet', [
        ('section', ''), ('span', 'handle'), *LEAD,
        # as duas dicas em pílula (4 s e 8 s sem leitura)
        ('div', 'tips'), ('span', 'tips.light'), ('span', 'tips.distance'), *FOOTER,
    ]),
]
SECOES['039_scanner_mirando'] = ['camera', 'dim', 'corners', 'scanLine', 'status', 'controls', 'sheet']

# ───────────────────────── 40 · Livro não encontrado ─────────────────────────
SPEC['040_scanner_nao_encontrado'] = [
    ('div', 'frame'), *camera(False), *DIM, *DETECTED, *CORNERS, *STATUS, *controls('torch'),
    *pref('sheet', [('section', ''), *SHEET_TOP, *LEAD, *SAVE_AS, *acoes('a', True), *FOOTER]),
]
SECOES['040_scanner_nao_encontrado'] = SCANNER_CAMERA

# ───────────────────────── 41 · Sem permissão de câmera ─────────────────────────
SPEC['041_scanner_sem_permissao'] = [
    ('div', 'frame'), ('div', 'backdrop'), *CORNERS, *controls('torch'),
    *pref('sheet', [
        ('section', ''), ('span', 'handle'), ('div', 'art'), ('svg', 'art.image'),
        ('h2', 'title'), ('span', 'title.serif'), ('p', 'body'),
        # o caminho nos ajustes, num chip tracejado
        ('div', 'path'), ('svg', 'path.icon'), ('span', 'path.text'), ('strong', 'path.text.strong'),
        ('a', 'openSettings'), ('a', 'typeIsbn'), ('svg', 'typeIsbn.icon'),
    ]),
]
SECOES['041_scanner_sem_permissao'] = ['backdrop', 'corners', 'controls', 'sheet']

# ───────────────────────── 42 · Já está na estante ─────────────────────────
SPEC['042_scanner_na_estante'] = [
    ('div', 'frame'), *camera(False), *DIM, *DETECTED, *CORNERS, *STATUS, *controls('torch'),
    *pref('sheet', [
        ('section', ''), *SHEET_TOP,
        *livro_capa(),
        # a barra de progresso (a trilha com o preenchimento), a porcentagem e a página
        ('span', 'book.progress'), ('span', 'book.progress.bar'), ('span', 'book.progress.bar.fill'),
        ('span', 'book.progress.percent'), ('span', 'book.reading'), ('strong', 'book.reading.page'),
        ('svg', 'book.chevron'),
        # o quanto falta para a meta do dia
        ('div', 'goal'), ('svg', 'goal.ring'), ('span', 'goal.text'), ('strong', 'goal.text.strong'),
        *acoes('button', True), *FOOTER,
    ]),
]
SECOES['042_scanner_na_estante'] = SCANNER_CAMERA

# ───────────────────────── 69 e 69b · Digitar o ISBN ─────────────────────────
HEADING = pref('heading', [('div', ''), ('h1', 'title'), ('span', 'title.serif'), ('p', 'body')])


def tecla(n, letras):
    return [('span', f'key{n}'), ('span', f'key{n}.digit'), *([('span', f'key{n}.letters')] if letras else [])]


# o teclado numérico do sistema: 1, 2–9 (com as letras), o lugar vazio, 0 e apagar
KEYPAD = pref('keypad', [
    ('div', ''), *tecla(1, False), *[x for n in range(2, 10) for x in tecla(n, True)],
    ('span', 'blank'), *tecla(0, False), ('span', 'delete'), ('svg', 'delete.icon'),
])


def toolbar(meio):
    # a barra do app sobre o teclado: o X (com "dígito final" em 2 linhas), colar ou apagar tudo, e esconder
    return pref('toolbar', [
        ('div', ''), ('button', 'x'), ('span', 'x.key'), ('span', 'x.caption'), ('br', None),
        ('button', meio), ('svg', f'{meio}.icon'), ('span', 'spacer'), ('button', 'hide'), ('svg', 'hide.icon'),
    ])


def sticker(tremida, digitos, depois):
    # a etiqueta inclinada: (69b: as marcas de tremida) as 2 fitas, o cartão e, embaixo dela, as notas
    return pref('sticker', [
        ('div', ''), ('div', 'tilt'),
        *([('svg', 'shakeLeft'), ('svg', 'shakeRight')] if tremida else []),
        ('span', 'tapeLeft'), ('span', 'tapeRight'),
        ('section', 'card'), ('div', 'card.top'), ('span', 'card.kind'), ('svg', 'card.kind.icon'),
        ('span', 'card.count'), ('span', 'card.count.total'),
        # os dígitos: o número com os 2 hífens de dentro, o hífen antes do último e o lugar do último
        ('div', 'card.digits'), ('span', 'card.digits.number'), ('span', 'card.digits.number.dash1'),
        ('span', 'card.digits.number.dash2'), ('span', 'card.digits.dash3'), *digitos,
        *depois,
        ('div', 'notes'), ('p', 'notes.line'), ('p', 'notes.noIsbn'), ('a', 'notes.noIsbn.link'),
    ])


DIGITAR_SECOES = ['backdrop', 'controls', 'heading', 'sticker', 'toolbar', 'keypad']

SPEC['069_scanner_digitar_isbn'] = [
    ('div', 'frame'), ('div', 'backdrop'), *controls('help'), *HEADING,
    *sticker(False,
             # o lugar vazio do dígito final, com o cursor
             [('span', 'card.digits.slot'), ('span', 'card.digits.slot.caret')],
             [('p', 'card.hint'), ('strong', 'card.hint.key'),
              ('div', 'card.barcode'), ('svg', 'card.barcode.bars'), ('span', 'card.barcode.prefix')]),
    *toolbar('paste'), *KEYPAD,
]
SECOES['069_scanner_digitar_isbn'] = DIGITAR_SECOES

SPEC['069b_scanner_isbn_nao_confere'] = [
    ('div', 'frame'), ('div', 'backdrop'), *controls('help'), *HEADING,
    *sticker(True,
             # o X digitado, que não confere
             [('span', 'card.digits.check')],
             [('p', 'card.alert'), ('svg', 'card.alert.icon'), ('span', 'card.alert.text'),
              ('div', 'card.barcode'), ('svg', 'card.barcode.bars')]),
    *toolbar('clearAll'), *KEYPAD,
]
SECOES['069b_scanner_isbn_nao_confere'] = DIGITAR_SECOES

# ───────────────────────── Busca: a barra de busca (28, 28b, 28c) ─────────────────────────


def search_bar(limpar):
    return pref('searchBar', [
        ('div', ''), ('a', 'back'), ('svg', 'back.icon'),
        ('label', 'field'), ('svg', 'field.icon'), ('input', 'field.input'),
        *([('button', 'field.clear'), ('svg', 'field.clear.icon')] if limpar else []),
        ('a', 'scan'), ('svg', 'scan.icon'),
    ])


def cabecalho(secao, extra_tag, extra):
    # a linha do título da seção: o h2 e, à direita, um link ou uma nota
    return pref(secao, [('div', 'header'), ('h2', 'title'), (extra_tag, extra)])


# ───────────────────────── 28 · Explorar ─────────────────────────


def genero(i):
    # o cartão do gênero: o nome e o livrinho inclinado no canto (a lombada e as 2 linhas do título)
    return pref(f'genres.tile{i}', [
        ('a', ''), ('span', 'label'), ('span', 'book'), ('span', 'book.spine'),
        ('span', 'book.line1'), ('span', 'book.line2'),
    ])


def em_alta(i, capa):
    # o livro do carrossel: a capa (a lombada, o desenho e o texto da capa), o título, o autor e o selo de clubes
    return pref(f'trending.book{i}', [
        ('a', ''), ('span', 'cover'), ('span', 'cover.spine'), *capa,
        ('span', 'cover.textBlock'), ('span', 'cover.title'), ('span', 'cover.author'),
        ('span', 'title'), ('span', 'author'), ('span', 'clubs'), ('svg', 'clubs.icon'),
    ])


SPEC['028_busca_explorar'] = [
    ('div', 'frame'), *search_bar(False), ('svg', 'sparkle'), ('main', 'main'),
    ('h1', 'title'), ('br', None), ('span', 'title.serif'),
    *cabecalho('recent', 'a', 'clear'), ('div', 'recent.list'),
    *[x for i in range(1, 4) for x in (('a', f'recent.item{i}'), ('svg', f'recent.item{i}.icon'))],
    *cabecalho('mood', 'span', 'voters'), ('div', 'mood.chips'), *[('a', f'mood.chips.chip{i}') for i in range(1, 9)],
    *cabecalho('genres', 'a', 'seeAll'), ('div', 'genres.grid'), *[x for i in range(1, 9) for x in genero(i)],
    ('div', 'trending.header'), ('h2', 'trending.title'), ('p', 'trending.subtitle'), ('div', 'trending.carousel'),
    # O Cortiço: o prédio com as 12 janelas (3 fileiras de 4); os outros 3: desenho em <svg>
    *em_alta(1, [('span', f'cover.window{j}') for j in range(1, 13)]),
    *[x for i in range(2, 5) for x in em_alta(i, [('svg', 'cover.art')])],
]
SECOES['028_busca_explorar'] = ['searchBar', 'sparkle', 'title', 'recent', 'mood', 'genres', 'trending']

# ───────────────────────── 28b · Resultados ─────────────────────────
TABS = ['all', 'books', 'clubs', 'highlights']


def capa_resultado(base):
    return pref(base, [('span', 'cover'), ('span', 'cover.spine'), ('svg', 'cover.art'), ('span', 'textBlock')])


SPEC['028b_busca_resultados'] = [
    ('div', 'frame'), *search_bar(True), ('main', 'main'),
    ('div', 'tabs'), *[x for n in TABS for x in (('button', f'tabs.{n}'), ('span', f'tabs.{n}.count'))],
    *cabecalho('books', 'a', 'seeAll'), ('div', 'books.list'),
    # Dom Casmurro (na estante: o chip, o progresso e onde "Capitu" aparece) e o livro com "Capitu" no título
    ('a', 'books.result1'), *capa_resultado('books.result1'),
    *pref('books.result1', [
        ('span', 'title'), ('span', 'author'), ('span', 'status'), ('span', 'status.chip'),
        ('span', 'status.progress'), ('span', 'match'), ('mark', 'match.mark'), ('span', 'open'), ('svg', 'open.icon'),
    ]),
    ('a', 'books.result2'), *capa_resultado('books.result2'),
    *pref('books.result2', [
        ('span', 'title'), ('mark', 'title.mark'), ('span', 'author'), ('span', 'meta'),
        ('button', 'add'), ('svg', 'add.icon'),
    ]),
    *cabecalho('clubs', 'a', 'seeAll'), ('div', 'clubs.list'),
    # o seu clube (o selo de participante) e um clube aberto (Entrar)
    *pref('clubs.club1', [
        ('div', ''), ('span', 'avatar'), ('svg', 'avatar.icon'), ('a', 'link'), ('span', 'name'),
        ('mark', 'name.mark'), ('span', 'meta'), ('span', 'member'), ('svg', 'member.icon'),
    ]),
    *pref('clubs.club2', [
        ('div', ''), ('span', 'avatar'), ('svg', 'avatar.icon'), ('a', 'link'), ('span', 'name'),
        ('mark', 'name.mark'), ('span', 'meta'), ('button', 'join'),
    ]),
    *cabecalho('highlights', 'span', 'privacy'), ('div', 'highlights.list'),
    *pref('highlights.quote1', [
        ('a', ''), ('span', 'text'), ('mark', 'text.mark1'), ('mark', 'text.mark2'),
        ('span', 'source'), ('span', 'source.dot'),
    ]),
    *pref('highlights.quote2', [('a', ''), ('span', 'text'), ('mark', 'text.mark'), ('span', 'source'),
                                ('span', 'source.dot')]),
    *pref('scanCard', [
        ('a', ''), ('span', 'badge'), ('svg', 'badge.icon'), ('span', 'textBlock'), ('span', 'title'),
        ('span', 'subtitle'), ('svg', 'chevron'),
    ]),
]
SECOES['028b_busca_resultados'] = ['searchBar', 'tabs', 'books', 'clubs', 'highlights', 'scanCard']

# ───────────────────────── 28c · Nada encontrado ─────────────────────────
SPEC['028c_busca_nada_encontrado'] = [
    ('div', 'frame'), *search_bar(True), ('main', 'main'), ('svg', 'illustration'),
    ('h1', 'title'), ('span', 'title.serif'), ('p', 'body'), ('strong', 'body.query'),
    ('a', 'actions.scan'), ('svg', 'actions.scan.icon'),
    ('a', 'actions.manual'), ('svg', 'actions.manual.icon'), ('span', 'actions.manual.label'),
    # as dicas: o rótulo e a lista (cada item com a seta coral)
    ('div', 'tips'), ('span', 'tips.label'), ('ul', 'tips.list'),
    *[x for i in range(1, 4) for x in (('li', f'tips.tip{i}'), ('span', f'tips.tip{i}.arrow'))],
]
SECOES['028c_busca_nada_encontrado'] = ['searchBar', 'illustration', 'title', 'body', 'actions', 'tips']

# ───────────────────────── 28d · Adicionar à mão ─────────────────────────


def campo(nome, opcional, extra=()):
    return pref(f'form.{nome}', [
        ('label', 'label'), *([('span', 'label.optional')] if opcional else []),
        ('div', 'field'), ('input', 'field.input'), *extra,
    ])


def opcoes(nome, botoes):
    return pref(f'form.{nome}', [('span', 'label'), ('div', 'options'), *[('button', f'options.{b}') for b in botoes]])


SPEC['028d_adicionar_a_mao'] = [
    ('div', 'frame'),
    *pref('header', [('div', ''), ('a', 'close'), ('svg', 'close.icon'), ('span', 'badge')]),
    ('main', 'main'), ('h1', 'title'), ('br', None), ('span', 'title.serif'),
    *pref('cover', [
        ('div', ''), ('div', 'preview'),
        # a capa automática (a lombada, o desenho, o título e o autor), o botão de trocar e a etiqueta
        ('span', 'preview.book'), ('span', 'preview.book.spine'), ('svg', 'preview.book.art'),
        ('span', 'preview.book.textBlock'), ('span', 'preview.book.title'), ('span', 'preview.book.author'),
        ('button', 'preview.change'), ('svg', 'preview.change.icon'), ('span', 'preview.tag'),
        ('div', 'options'), ('button', 'options.camera'), ('svg', 'options.camera.icon'),
        ('button', 'options.gallery'), ('svg', 'options.gallery.icon'), ('span', 'options.colorLabel'),
        ('div', 'options.colors'), *[('button', f'options.colors.swatch{i}') for i in range(1, 6)],
    ]),
    ('div', 'form'),
    *campo('title', False), *campo('author', True),
    *opcoes('format', ['paper', 'ebook']),
    *campo('pages', True), ('p', 'form.pages.hint'),
    *campo('isbn', True, [('a', 'field.scan'), ('svg', 'field.scan.icon')]),
    *opcoes('saveAs', ['wantToRead', 'reading', 'read']),
    ('button', 'submit'), ('svg', 'submit.icon'), ('span', 'submit.label'), ('p', 'footnote'),
]
SECOES['028d_adicionar_a_mao'] = ['header', 'title', 'cover', 'form', 'submit', 'footnote']

ESPECIAIS = {'frame', 'main'}

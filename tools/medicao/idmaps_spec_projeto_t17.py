#!/usr/bin/env python3
"""T13.7 (R4) — ids semânticos das telas da etapa 10 · T17 (Perfil, ajustes e notificações): 05, 64, 65, 06, 58, 59,
56, 30, 30b e 30c.

Mesmo formato do idmaps_spec.py: cada prancha = lista (tag, id) na ordem do template (`data-dc-tpl` a partir do quadro,
tpl 4), sem o interior dos <svg>; id None = elemento não medido (os <br>). Junto das outras etapas em
idmaps_spec_projeto.py (o gerador: CONJUNTO=projeto python3 tools/medicao/idmaps_spec.py).

- Notificações (30, 30b, 30c; telas irmãs): a barra de cima (`top`: o voltar e, na 30 e na 30c, "marcar tudo como
  lido" e os ajustes), o título (`headline`, com a parte serifada) e o conteúdo. Na 30, as duas listas (`today` e
  `week`: o título com o traço e os avisos `itemN`, cada um com o ícone, o título, a hora, o ponto de "não lida", a
  linha de baixo e o botão de ação). Na 30b, os cartões de ajuste (`reading`, `topics`, `quiet`): cada linha com chave tem o
  ícone, o texto (`textBlock`, `title`, `body`) e a chave (`switch`, com a bolinha `switch.thumb` e o visto quando
  ligada). Na 30c, o desenho, o texto de "tudo em dia" (`empty`) e o lembrete marcado (`reminder`).
- Ajustes (06, 58, 59, 56): o voltar (`top`), o título (`headline`) e os cartões; as linhas com chave usam os mesmos
  nomes das Notificações. A 06 tem a navegação da Início (aba Perfil marcada).
- Perfil (05, 64, 65): o perfil, a edição e a troca de um dos 4 livros favoritos.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from idmaps_spec_projeto_t14 import BOTTOM_FADE, NAV  # noqa: E402


def pref(base, items):
    # '' = o próprio base; None = elemento sem id (os <br>)
    return [(t, None if n is None else f'{base}.{n}' if n else base) for t, n in items]


SPEC, SECOES = {}, {}

# ───────────────────────── peças comuns ─────────────────────────
HEADLINE = [('h1', 'headline'), ('br', None), ('span', 'headline.serif')]


def chave(base, *, icone, ligada, tag='div', icone_svg=True):
    """Uma linha com chave liga/desliga: o ícone (opcional), o texto (título e linha de baixo) e a chave, com a
    bolinha e, se ligada, o visto dentro dela."""
    return pref(base, [
        (tag, ''),
        *([('span', 'icon'), *([('svg', 'icon.art')] if icone_svg else [])] if icone else []),
        ('span', 'textBlock'), ('span', 'title'), ('span', 'body'),
        ('button', 'switch'), ('span', 'switch.thumb'), *([('svg', 'switch.thumb.icon')] if ligada else []),
    ])


# ───────────────────────── Notificações (30, 30b, 30c) ─────────────────────────
def topo_avisos():
    # o voltar à esquerda; à direita, "marcar tudo como lido" e os ajustes de lembretes e avisos
    return pref('top', [
        ('div', ''), ('a', 'back'), ('svg', 'back.icon'), ('span', 'actions'),
        ('button', 'markRead'), ('svg', 'markRead.icon'), ('a', 'settings'), ('svg', 'settings.icon'),
    ])


TOPO_VOLTAR = pref('top', [('div', ''), ('a', 'back'), ('svg', 'back.icon')])


def aviso(base, *, nao_lida=False, texto=(), acao=False):
    """Um aviso da lista: o cartão (o <a>), o ícone colorido, a coluna de texto (`textBlock`: o título com a hora e
    o ponto de "não lida", a linha de baixo `body` com o que vem dentro dela) e o botão de ação."""
    return pref(base, [
        ('li', ''), ('a', 'card'), ('span', 'icon'), ('svg', 'icon.art'),
        ('span', 'textBlock'), ('span', 'head'), ('span', 'title'), ('span', 'time'),
        *([('span', 'time.unread')] if nao_lida else []),
        ('span', 'body'), *texto,
        *([('span', 'action')] if acao else []),
    ])


def lista_avisos(secao, itens):
    # o título da lista (h2 com o traço tracejado) e a lista
    return [('h2', f'{secao}.label'), ('span', f'{secao}.label.rule'), ('ul', f'{secao}.list'),
            *[x for i, kw in enumerate(itens, 1) for x in aviso(f'{secao}.list.item{i}', **kw)]]


AVATARES = [('span', 'body.avatars'), *[('span', f'body.avatars.avatar{i}') for i in range(1, 4)]]

# ───────────────────────── 30 · Notificações ─────────────────────────
SPEC['030_notificacoes'] = [
    ('div', 'frame'), *topo_avisos(), ('svg', 'sparkle'), ('main', 'main'), *HEADLINE,
    ('p', 'summary'), ('strong', 'summary.count'),
    *lista_avisos('today', [
        dict(nao_lida=True, texto=[('strong', 'body.author')]),
        dict(nao_lida=True, acao=True),
        dict(),
        dict(texto=AVATARES),
    ]),
    *lista_avisos('week', [dict(acao=True), dict(acao=True), dict()]),
    ('p', 'footnote'),
]
SECOES['030_notificacoes'] = ['top', 'sparkle', 'headline', 'summary', 'today', 'week', 'footnote']

# ───────────────────────── 30b · Lembretes e avisos (ajustes) ─────────────────────────
DIAS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']

SPEC['030b_notificacoes_ajustes'] = [
    ('div', 'frame'), *TOPO_VOLTAR, ('main', 'main'), *HEADLINE,
    # o lembrete de leitura: a chave, o horário, os dias, "só se eu ainda não li" e a prévia do aviso
    ('section', 'reading'), *chave('reading.head', icone=True, ligada=True),
    *pref('reading', [
        ('div', 'time'), ('span', 'time.value'), ('span', 'time.hint'),
        ('div', 'daysLabel'), ('div', 'days'), *[('button', f'days.{d}') for d in DIAS],
    ]),
    *chave('reading.smart', icone=False, ligada=True),
    *pref('reading', [
        ('div', 'previewLabel'), ('div', 'preview'), ('span', 'preview.appIcon'), ('span', 'preview.textBlock'),
        ('span', 'preview.meta'), ('span', 'preview.meta.app'), ('span', 'preview.meta.time'),
        ('span', 'preview.title'), ('span', 'preview.body'),
    ]),
    # avisar sobre: 5 linhas com chave (as 3 primeiras ligadas)
    ('section', 'topics'), ('div', 'topics.label'),
    *chave('topics.club', icone=True, ligada=True),
    *chave('topics.polls', icone=True, ligada=True),
    *chave('topics.achievements', icone=True, ligada=True),
    *chave('topics.streak', icone=True, ligada=False),
    *chave('topics.social', icone=True, ligada=False),
    # não incomodar: a chave e o intervalo (das → até)
    ('section', 'quiet'), *chave('quiet.head', icone=True, ligada=True),
    *pref('quiet.range', [
        ('div', ''), ('span', 'from'), ('span', 'from.label'), ('span', 'from.value'), ('span', 'arrow'),
        ('span', 'to'), ('span', 'to.label'), ('span', 'to.value'),
    ]),
    ('p', 'quiet.note'),
]
SECOES['030b_notificacoes_ajustes'] = ['top', 'headline', 'reading', 'topics', 'quiet']

# ───────────────────────── 30c · Notificações, tudo em dia ─────────────────────────
SPEC['030c_notificacoes_vazia'] = [
    ('div', 'frame'), *topo_avisos(), ('main', 'main'), *HEADLINE,
    # o adesivo do sino dormindo em cima do livro
    ('svg', 'illustration'),
    ('h2', 'empty.title'), ('span', 'empty.title.dot'), ('p', 'empty.body'),
    ('a', 'empty.cta'), ('svg', 'empty.cta.icon'),
    *pref('reminder', [('div', ''), ('span', 'icon'), ('svg', 'icon.art'), ('span', 'text'), ('strong', 'text.time')]),
]
SECOES['030c_notificacoes_vazia'] = ['top', 'headline', 'illustration', 'empty', 'reminder']


# ───────────────────────── 06 · Ajustes ─────────────────────────
def tema(nome, marcado):
    # uma opção de tema das páginas: a página em miniatura (o "Aa" e 3 linhas; o selo de marcado) e o nome
    return pref(f'reading.theme.{nome}', [
        ('button', ''), ('span', 'preview'), ('span', 'preview.sample'),
        *[('span', f'preview.line{i}') for i in range(1, 4)],
        *([('span', 'preview.check'), ('svg', 'preview.check.icon')] if marcado else []),
        ('span', 'label'),
    ])


def meta(nome):
    # um cartão de meta: o rótulo, o número com a unidade e os botões de menos e mais
    return pref(f'goals.{nome}', [
        ('div', ''), ('span', 'label'), ('span', 'value'), ('span', 'value.number'), ('span', 'value.unit'),
        ('span', 'stepper'), ('button', 'stepper.minus'), ('svg', 'stepper.minus.icon'),
        ('button', 'stepper.plus'), ('svg', 'stepper.plus.icon'),
    ])


def link_ajuste(base):
    # uma linha de "Mais ajustes": o ícone redondo, o título, a linha de baixo e a seta
    return pref(base, [('a', ''), ('span', 'icon'), ('svg', 'icon.art'), ('span', 'textBlock'), ('span', 'title'),
                       ('span', 'body'), ('svg', 'chevron')])


def link_ajuda(base):
    return pref(base, [('a', ''), ('svg', 'icon'), ('span', 'label'), ('svg', 'chevron')])


SPEC['006_ajustes'] = [
    ('div', 'frame'), ('main', 'main'), *TOPO_VOLTAR, ('h1', 'headline'), ('span', 'headline.serif'),
    *pref('search', [('label', ''), ('svg', 'icon'), ('input', 'input')]),
    # a conta, como uma capa de livro: a lombada, o avatar, o nome, o e-mail e o selo "dados só neste celular"
    *pref('account', [
        ('a', ''), ('span', 'spine'), ('span', 'spineLine'), ('span', 'avatar'), ('span', 'textBlock'),
        ('span', 'name'), ('span', 'email'), ('span', 'badge'), ('svg', 'badge.icon'), ('svg', 'chevron'),
    ]),
    *pref('plan', [
        ('a', ''), ('span', 'icon'), ('svg', 'icon.art'), ('span', 'textBlock'), ('span', 'head'), ('span', 'title'),
        ('span', 'tag'), ('span', 'body'), ('svg', 'chevron'),
    ]),
    # Leitura: o tema das páginas, a fonte, o tamanho do texto, o modo de virar páginas e a tela acesa
    *pref('reading', [
        ('section', ''), ('div', 'header'), ('h2', 'header.title'), ('a', 'header.reset'), ('div', 'card'),
        ('span', 'themeLabel'), ('div', 'theme'),
    ]),
    *tema('light', False), *tema('sepia', True), *tema('dark', False),
    *pref('reading', [
        ('a', 'font'), ('span', 'font.textBlock'), ('span', 'font.title'), ('span', 'font.body'),
        ('span', 'font.value'), ('svg', 'font.chevron'),
        ('div', 'size'), ('div', 'size.head'), ('span', 'size.title'), ('span', 'size.value'), ('div', 'size.row'),
        ('span', 'size.small'), ('div', 'size.slider'), ('span', 'size.slider.track'),
        ('span', 'size.slider.fill'), ('span', 'size.slider.thumb'), ('span', 'size.large'),
        ('div', 'paging'), ('span', 'paging.title'), ('div', 'paging.toggle'), ('button', 'paging.toggle.paged'),
        ('button', 'paging.toggle.scroll'),
    ]),
    *chave('reading.screenOn', icone=False, ligada=True),
    # Metas e lembretes: as duas metas, o lembrete com o horário e a proteção da sequência
    *pref('goals', [('section', ''), ('h2', 'title'), ('span', 'title.serif'), ('div', 'card'), ('div', 'grid')]),
    *meta('yearly'), *meta('daily'),
    *pref('goals.reminder', [
        ('div', ''), ('span', 'textBlock'), ('span', 'title'), ('span', 'body'), ('span', 'controls'),
        ('button', 'time'), ('button', 'switch'), ('span', 'switch.thumb'), ('svg', 'switch.thumb.icon'),
    ]),
    *pref('goals.streak', [
        ('div', ''), ('span', 'textBlock'), ('span', 'title'), ('svg', 'title.icon'), ('span', 'body'),
        ('button', 'switch'), ('span', 'switch.thumb'), ('svg', 'switch.thumb.icon'),
    ]),
    *pref('more', [('section', ''), ('h2', 'title'), ('div', 'list')]),
    *[x for n in ('notifications', 'privacy', 'library', 'scanner', 'appearance', 'language')
      for x in link_ajuste(f'more.list.{n}')],
    *pref('help', [('section', ''), ('h2', 'title'), ('div', 'list')]),
    *[x for n in ('center', 'contact', 'terms') for x in link_ajuda(f'help.list.{n}')],
    *pref('footer', [
        ('div', ''), ('button', 'signOut'), ('svg', 'signOut.icon'), ('button', 'delete'), ('span', 'version'),
        ('svg', 'version.icon'),
    ]),
    *BOTTOM_FADE, *NAV,
]
SECOES['006_ajustes'] = ['top', 'headline', 'search', 'account', 'plan', 'reading', 'goals', 'more', 'help', 'footer',
                         'bottomFade', 'nav']

# ───────────────────────── 58 · Conta, 59 · Excluir conta, 56 · Privacidade ─────────────────────────
# o voltar num <header> (e não num <div>, como na 06)
TOPO_HEADER = pref('top', [('header', ''), ('button', 'back'), ('svg', 'back.icon')])


def secao(base):
    # uma seção com o título (h2) e a nota ao lado, e o cartão com a lista
    return pref(base, [('section', ''), ('div', 'header'), ('h2', 'header.title'), ('span', 'header.note'),
                       ('div', 'list')])


def contador():
    # à direita da linha: o número (pedidos, aparelhos, bloqueadas) e a seta
    return [('span', 'trail'), ('span', 'trail.count'), ('svg', 'trail.chevron')]


def linha(base, *, tag='a', fim=(('svg', 'chevron'),)):
    # uma linha da lista: o ícone, o título, a linha de baixo e o que vem à direita (a seta, por padrão)
    return pref(base, [(tag, ''), ('span', 'icon'), ('svg', 'icon.art'), ('span', 'textBlock'), ('span', 'title'),
                       ('span', 'body'), *fim])


SPEC['058_conta'] = [
    ('div', 'frame'), *TOPO_HEADER, ('main', 'main'), ('h1', 'headline'), ('span', 'headline.serif'),
    # a conta, como uma capa de livro (a mesma da 06), com o "Editar"
    *pref('account', [
        ('section', ''), ('span', 'spine'), ('span', 'spineLine'), ('span', 'avatar'), ('span', 'textBlock'),
        ('span', 'name'), ('span', 'handle'), ('button', 'edit'),
    ]),
    *secao('signIn'), *linha('signIn.list.email'), *linha('signIn.list.password'), *linha('signIn.list.connected'),
    *secao('sync'), *linha('sync.list.devices', fim=contador()),
    *chave('sync.list.offline', icone=True, ligada=False),
    *secao('data'), *linha('data.list.export'), *linha('data.list.import'),
    ('button', 'signOut'), ('svg', 'signOut.icon'),
    ('a', 'delete'), ('svg', 'delete.icon'), ('span', 'delete.label'),
]
SECOES['058_conta'] = ['top', 'headline', 'account', 'signIn', 'sync', 'data', 'signOut', 'delete']

PERDAS = ['books', 'highlights', 'reviews', 'lists', 'streak', 'clubs']

SPEC['059_excluir_conta'] = [
    ('div', 'frame'), *TOPO_HEADER, ('main', 'main'), ('h1', 'headline'), ('span', 'headline.serif'), ('p', 'lead'),
    # o que vai embora junto: 6 números
    ('div', 'losses'), *[x for n in PERDAS for x in pref(f'losses.{n}', [('span', ''), ('span', 'value'),
                                                                        ('span', 'label')])],
    ('p', 'clubsNote'),
    # antes de excluir: baixar os dados ou dar uma pausa
    ('div', 'alternatives'), *linha('alternatives.download'), *linha('alternatives.pause'),
    # digitar EXCLUIR: o rótulo com a palavra, o campo (com o cursor) e o aviso dos 30 dias
    *pref('confirm', [
        ('section', ''), ('span', 'label'), ('span', 'label.word'), ('div', 'field'), ('span', 'field.caret'),
        ('p', 'note'), ('strong', 'note.deadline'),
    ]),
    # o botão preso embaixo (ainda bloqueado) e a dica
    *pref('bottom', [('div', ''), ('button', 'delete'), ('svg', 'delete.icon'), ('p', 'hint')]),
]
SECOES['059_excluir_conta'] = ['top', 'headline', 'lead', 'losses', 'clubsNote', 'alternatives', 'confirm', 'bottom']


def tipo_perfil(nome, marcado):
    # um dos dois tipos de perfil: o círculo de escolha (com o visto quando marcado), o ícone, o nome e a explicação
    return pref(f'profileType.{nome}', [
        ('button', ''), ('span', 'radio'), *([('svg', 'radio.icon')] if marcado else []), ('span', 'icon'),
        ('svg', 'icon.art'), ('span', 'title'), ('span', 'body'),
    ])


def quem_ve(base):
    # uma linha de "Quem vê o quê": o ícone, o texto e o botão com o público (o ícone e a seta)
    return linha(base, tag='div', fim=(('button', 'audience'), ('svg', 'audience.icon'), ('svg', 'audience.chevron')))


SPEC['056_privacidade'] = [
    ('div', 'frame'), *TOPO_HEADER, ('main', 'main'), ('h1', 'headline'), ('span', 'headline.serif'), ('p', 'lead'),
    ('div', 'profileType'), *tipo_perfil('open', False), *tipo_perfil('closed', True),
    *secao('visibility'),
    *[x for n in ('shelf', 'reviews', 'highlights', 'page', 'lists', 'stats') for x in quem_ve(f'visibility.list.{n}')],
    *secao('people'), *linha('people.list.requests', fim=contador()),
    *chave('people.list.findByEmail', icone=True, ligada=False),
    *linha('people.list.blocked', fim=contador()),
    *pref('blockNote', [('div', ''), ('svg', 'icon'), ('span', 'text'), ('strong', 'text.lead')]),
]
SECOES['056_privacidade'] = ['top', 'headline', 'lead', 'profileType', 'visibility', 'people', 'blockNote']


# ───────────────────────── 05 · Perfil ─────────────────────────
def lendo(i, enfeites):
    # um livro de "Lendo agora": a capa (a arte com a lombada, os enfeites e o título; o marcador de página por cima)
    # e o progresso embaixo
    return pref(f'reading.grid.book{i}', [
        ('a', ''), ('span', 'cover'), ('span', 'cover.art'), ('span', 'cover.spine'),
        *[('span', f'cover.{e}') for e in enfeites], ('span', 'cover.title'), ('br', None),
        ('svg', 'cover.bookmark'), ('span', 'caption'),
    ])


def favorito(i, enfeites, quebra):
    # um dos 4 livros que me definem: a capa em pé na prateleira (a lombada, os enfeites e o título)
    return pref(f'favorites.shelf.books.book{i}', [
        ('a', ''), ('span', 'spine'), *[('span', e) for e in enfeites], ('span', 'title'),
        *([('br', None)] if quebra else []),
    ])


def selo(i, numero):
    # uma conquista: a medalha (o desenho e, no meio, o número com a unidade ou um ícone) e o nome em 2 linhas
    meio = [('span', 'medal.center'), ('span', 'medal.center.number'), ('span', 'medal.center.unit')] if numero \
        else [('span', 'medal.center'), ('svg', 'medal.center.icon')]
    return pref(f'achievements.grid.badge{i}', [
        ('div', ''), ('span', 'medal'), ('svg', 'medal.art'), *meio, ('span', 'label'), ('br', None),
    ])


def atividade(i, meio):
    # um item da atividade: o ícone redondo, o texto com o livro em negrito, o que vem no meio e quando
    return pref(f'activity.item{i}', [
        ('div', ''), ('span', 'icon'), ('svg', 'icon.art'), ('div', 'textBlock'), ('span', 'text'),
        ('strong', 'text.book'), *meio, ('span', 'time'),
    ])


ESTATISTICAS = ['pages', 'hours', 'streak', 'genre']

SPEC['005_perfil'] = [
    ('div', 'frame'), ('main', 'main'),
    *pref('top', [('header', ''), ('span', 'handle'), ('button', 'settings'), ('svg', 'settings.icon')]),
    # a capa do perfil: a lombada, a edição, o avatar com a sequência, o nome, a bio e os números
    *pref('hero', [
        ('section', ''), ('span', 'spine'), ('span', 'spineLine'), ('span', 'edition'), ('br', None),
        ('div', 'avatar'), ('div', 'avatar.circle'), ('span', 'avatar.streak'), ('svg', 'avatar.streak.icon'),
        ('h1', 'name'), ('br', None), ('span', 'name.serif'), ('p', 'bio'),
        ('div', 'stats'), ('span', 'stats.text'), ('strong', 'stats.followers'), ('strong', 'stats.following'),
        ('br', None), ('strong', 'stats.clubs'), ('strong', 'stats.books'), ('span', 'stats.arrow'),
        ('svg', 'stats.arrow.icon'),
    ]),
    # a carteirinha inclinada: a faixa de cima, o código de barras, o tracejado, as metas e o carimbo
    *pref('card', [
        ('a', ''), ('span', 'header'), ('span', 'header.title'), ('span', 'header.number'), ('span', 'body'),
        ('span', 'code'), ('svg', 'code.bars'), ('span', 'code.text'), ('span', 'divider'), ('span', 'goals'),
        ('span', 'goals.daily'), ('span', 'goals.yearly'), ('svg', 'stamp'),
    ]),
    *pref('actions', [('div', ''), ('button', 'edit'), ('svg', 'edit.icon'), ('button', 'share'),
                      ('svg', 'share.icon')]),
    *pref('tabs', [
        ('div', ''), ('button', 'summary'), ('button', 'reviews'), ('span', 'reviews.count'),
        ('button', 'highlights'), ('span', 'highlights.count'), ('button', 'lists'), ('span', 'lists.count'),
    ]),
    *pref('reading', [('section', ''), ('div', 'header'), ('h2', 'header.title'), ('a', 'header.all'),
                      ('svg', 'header.all.icon'), ('div', 'grid')]),
    *lendo(1, ['circle']), *lendo(2, ['arch']), *lendo(3, ['ring', 'dot']),
    # 2026 em leitura: a meta (24 de 30, 2 à frente), a estante com 24 lombadas e 6 vagas, os números e o link
    *pref('year', [
        ('section', ''), ('h2', 'title'), ('span', 'title.serif'), ('div', 'goal'), ('div', 'goal.count'),
        ('span', 'goal.count.number'), ('span', 'goal.count.label'), ('br', None), ('span', 'goal.ahead'),
        ('svg', 'goal.ahead.icon'), ('div', 'shelf'), ('div', 'shelf.books'),
        *[x for i in range(1, 25) for x in (('span', f'shelf.books.book{i}'), ('span', f'shelf.books.book{i}.line'))],
        *[('span', f'shelf.books.slot{i}') for i in range(1, 7)],
        ('span', 'shelf.plank'), ('div', 'stats'),
        *[x for n in ESTATISTICAS for x in (('div', f'stats.{n}'), ('span', f'stats.{n}.value'),
                                            ('span', f'stats.{n}.label'))],
        ('a', 'more'), ('svg', 'more.icon'),
    ]),
    # os 4 livros que me definem, em pé na prateleira
    *pref('favorites', [('section', ''), ('div', 'header'), ('h2', 'header.title'), ('span', 'header.title.serif'),
                        ('a', 'header.edit'), ('div', 'shelf'), ('div', 'shelf.books')]),
    *favorito(1, ['lines', 'lines.line1', 'lines.line2', 'lines.line3'], True),
    *favorito(2, ['arch', 'door'], False), *favorito(3, ['band'], False), *favorito(4, ['oval', 'seam'], True),
    ('span', 'favorites.shelf.plank'),
    # as conquistas: 4 medalhas e a próxima, com a barra
    *pref('achievements', [('section', ''), ('div', 'header'), ('div', 'header.titleGroup'), ('h2', 'header.title'),
                           ('span', 'header.count'), ('a', 'header.all'), ('svg', 'header.all.icon'),
                           ('div', 'grid')]),
    *selo(1, True), *selo(2, False), *selo(3, False), *selo(4, True),
    *pref('achievements.next', [
        ('div', ''), ('div', 'head'), ('span', 'title'), ('strong', 'title.goal'), ('span', 'remaining'),
        ('span', 'bar'), ('span', 'bar.fill'), ('svg', 'bar.fill.edge'),
    ]),
    ('section', 'activity'), ('h2', 'activity.title'),
    *atividade(1, []),
    *atividade(2, [('span', 'quote'), ('span', 'quote.highlight')]),
    *atividade(3, [('span', 'rating'), *[('svg', f'rating.star{i}') for i in range(1, 6)], ('span', 'review')]),
    *BOTTOM_FADE, *NAV,
]
SECOES['005_perfil'] = ['top', 'hero', 'card', 'actions', 'tabs', 'reading', 'year', 'favorites', 'achievements',
                        'activity', 'bottomFade', 'nav']

# ───────────────────────── 64 · Editar perfil, 65 · trocar um dos 4 ─────────────────────────
# o topo da edição: fechar sem salvar, o título e o espaço do outro lado; a prévia ao vivo da capa do perfil
TOPO_EDICAO = pref('top', [('header', ''), ('button', 'close'), ('svg', 'close.icon'), ('span', 'title'),
                           ('span', 'spacer')])
PREVIA = pref('preview', [
    ('section', ''), ('span', 'spine'), ('span', 'spineLine'), ('span', 'label'), ('div', 'avatar'),
    ('div', 'avatar.circle'), ('button', 'avatar.change'), ('svg', 'avatar.change.icon'),
    ('h2', 'name'), ('br', None), ('span', 'name.serif'), ('p', 'bio'),
    ('span', 'tags'), ('span', 'tags.pronouns'), ('span', 'tags.genres'),
])
CORES = ['lavender', 'pink', 'lightGreen', 'yellow', 'gold', 'coral', 'blue', 'green', 'purple', 'cream', 'ink']


def campo(nome, *, dica, valor):
    # um campo do formulário: o rótulo com o contador (ou a dica) e a caixa com o valor e o espaço que sobra
    return pref(f'fields.{nome}', [
        ('label', ''), ('span', 'head'), ('span', 'head.title'), ('span', 'head.hint' if dica else 'head.counter'),
        ('span', 'field'), ('span', 'field.value'), *valor,
    ])


def escolha(base, nomes, marcados):
    # uma fileira de botões de escolha; os marcados têm o visto
    return [x for n in nomes for x in [('button', f'{base}.{n}'), *([('svg', f'{base}.{n}.icon')]
                                                                   if n in marcados else [])]]


def capa(base, enfeites, quebra):
    # a capa em miniatura: a lombada, os enfeites e o título
    return pref(base, [('span', ''), ('span', 'spine'), *[(t, e) for t, e in enfeites], ('span', 'title'),
                       *([('br', None)] if quebra else [])])


LINHAS = [('span', 'lines'), ('span', 'lines.line1'), ('span', 'lines.line2'), ('span', 'lines.line3')]


def vaga(i, enfeites, quebra):
    # um dos 4 livros na edição: a capa com o número e o botão de trocar; embaixo, a alça de arrastar
    b = f'favorites.grid.slot{i}'
    return [('div', b), ('span', f'{b}.book'), *capa(f'{b}.book.cover', enfeites, quebra),
            ('span', f'{b}.book.rank'), ('button', f'{b}.book.swap'), ('svg', f'{b}.book.swap.icon'),
            ('span', f'{b}.handle'), ('svg', f'{b}.handle.icon')]


SPEC['064_editar_perfil'] = [
    ('div', 'frame'), *TOPO_EDICAO, ('main', 'main'), *PREVIA,
    # a cor da capa: o arco-íris (qualquer cor) e as 11 cores
    ('div', 'colorLabel'), ('div', 'colors'), ('button', 'colors.custom'), ('span', 'colors.custom.dot'),
    ('svg', 'colors.custom.dot.icon'), *[('button', f'colors.{c}') for c in CORES],
    *pref('avatarType', [('div', ''), ('span', 'label'), ('div', 'toggle'), ('button', 'toggle.photo'),
                         ('svg', 'toggle.photo.icon'), ('button', 'toggle.initial')]),
    ('div', 'fields'),
    *campo('name', dica=False, valor=[('span', 'field.spacer')]),
    *campo('handle', dica=True, valor=[('span', 'field.value.at'), ('span', 'field.spacer'), ('span', 'field.status'),
                                        ('svg', 'field.status.icon')]),
    *campo('bio', dica=False, valor=[('span', 'field.value.caret'), ('span', 'field.spacer')]),
    ('div', 'pronounsHeader'), ('span', 'pronounsHeader.title'), ('span', 'pronounsHeader.hint'),
    ('div', 'pronouns'), *escolha('pronouns', ['she', 'he', 'they', 'custom', 'none'], {'she'}),
    ('div', 'genresHeader'), ('span', 'genresHeader.title'), ('span', 'genresHeader.hint'),
    ('div', 'genres'), *escolha('genres', ['classics', 'romance', 'stories', 'poetry', 'scifi', 'fantasy',
                                           'nonfiction', 'mystery'], {'classics', 'romance', 'stories'}),
    ('div', 'favoritesHeader'), ('span', 'favoritesHeader.title'), ('span', 'favoritesHeader.title.serif'),
    ('span', 'favoritesHeader.hint'),
    ('div', 'favorites'), ('div', 'favorites.grid'),
    *vaga(1, LINHAS, True), *vaga(2, [('span', 'arch'), ('span', 'door')], False),
    *vaga(3, [('span', 'band')], False), *vaga(4, [('span', 'oval'), ('span', 'seam')], True),
    # o botão de salvar preso embaixo
    *pref('bottom', [('div', ''), ('button', 'save'), ('svg', 'save.icon'), ('span', 'save.label'), ('p', 'note')]),
]
SECOES['064_editar_perfil'] = ['top', 'preview', 'colorLabel', 'colors', 'avatarType', 'fields', 'pronounsHeader',
                               'pronouns', 'genresHeader', 'genres', 'favoritesHeader', 'favorites', 'bottom']


def opcao(i, enfeites, quebra, fim):
    # um livro para pôr no lugar: a capa, o título, o autor, as 5 estrelas e, à direita, a escolha (ou a etiqueta)
    b = f'sheet.options.option{i}'
    return [('div', b), ('span', f'{b}.thumb'), *capa(f'{b}.thumb.cover', enfeites, quebra),
            ('span', f'{b}.textBlock'), ('span', f'{b}.title'), ('span', f'{b}.author'), ('span', f'{b}.rating'),
            *[('svg', f'{b}.rating.star{s}') for s in range(1, 6)], *[(t, f'{b}.{n}') for t, n in fim]]


SPEC['065_editar_perfil_trocar'] = [
    ('div', 'frame'), *TOPO_EDICAO, ('main', 'main'), *PREVIA,
    # o escurecido e a folha de trocar o 3º livro
    ('div', 'scrim'),
    *pref('sheet', [
        ('section', ''), ('span', 'handle'), ('div', 'head'), ('span', 'head.current'),
        *capa('head.current.cover', [('span', 'band')], False), ('span', 'head.current.rank'),
        ('span', 'head.textBlock'), ('span', 'head.title'), ('span', 'head.title.serif'), ('span', 'head.body'),
        ('label', 'search'), ('svg', 'search.icon'), ('span', 'search.placeholder'),
        ('span', 'optionsLabel'), ('div', 'options'),
    ]),
    *opcao(1, [('span', 'square')], True, [('span', 'radio'), ('svg', 'radio.icon')]),
    *opcao(2, [('svg', 'star')], True, [('span', 'radio')]),
    *opcao(3, [('span', 'oval'), ('span', 'seam')], True, [('span', 'tag')]),
    *opcao(4, LINHAS, True, [('span', 'radio')]),
    ('span', 'sheet.spacer'), ('button', 'sheet.confirm'), ('svg', 'sheet.confirm.icon'), ('span', 'sheet.confirm.label'),
]
SECOES['065_editar_perfil_trocar'] = ['top', 'preview', 'scrim', 'sheet']

ESPECIAIS = {'frame', 'main'}

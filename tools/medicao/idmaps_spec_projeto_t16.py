#!/usr/bin/env python3
"""T13.6 (R4) — ids semânticos das telas da etapa 9 · T16 (Entrada e onboarding): 35, 07, 08, 09, 09b, 10, 11, 12, 13,
13b, 14, 15, 16 e 36a.

Mesmo formato do idmaps_spec.py: cada prancha = lista (tag, id) na ordem do template (`data-dc-tpl` a partir do quadro,
tpl 4), sem o interior dos <svg>; id None = elemento não medido (os <br>). Junto das outras etapas em
idmaps_spec_projeto.py (o gerador: CONJUNTO=projeto python3 tools/medicao/idmaps_spec.py).

- Entrada (35, 07, 08, 09, 09b, 10, 11; telas irmãs, os mesmos nomes onde o desenho é o mesmo): as ondas do fundo
  (`waves`), o voltar (`back`), os adesivos de cima (`badge`, o selo redondo; `cover`, a capa do Login; `envelope`;
  `padlock`; `card`, a carteirinha do Cadastro) com os brilhos (`sparkleLarge`, claro; `sparkleSmall`, escuro), a
  marca "BookNest" (`wordmark`, na 35 e na 07) e a folha de baixo (`sheet`: o título com a parte serifada, o texto, o
  formulário e as ações). Os campos de senha têm os mesmos nomes no Cadastro, no Entrar e na Nova senha
  (`sheet.form.password.field.dots` são os pontos; o cursor só quando o campo tem foco). Os botões da Google e da Apple
  (07) usam as fontes das marcas: a Roboto (baixada, D-273) e a da Apple (do sistema: informativo, R8).
- Onboarding (12, 13, 13b, 14, 15): a faixa de ondas (`waves`), o topo com o passo e a barra (`top`), o título
  (`heading`, com o brilho) e o texto (`lead`), o conteúdo de cada passo e o "Continuar" (`continue`). A 13b é a 14
  com a dica do scanner por cima (`coach`: o foco no botão, o anel, a seta, "é aqui!" e o cartão).
- 16 · Carteirinha pronta: as ondas, os confetes, a carteirinha (`card`), o carimbo (`stamp`) e a folha.
- 36a · Início no primeiro acesso: o cabeçalho e o título da Início (os mesmos ids da 01), o cartão do primeiro livro,
  a meta de hoje, o convite de clube, o degradê e a navegação (os ids da Início).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from idmaps_spec_projeto_t14 import BOTTOM_FADE, NAV  # noqa: E402


def pref(base, items):
    # '' = o próprio base; None = elemento sem id (os <br>)
    return [(t, None if n is None else f'{base}.{n}' if n else base) for t, n in items]


SPEC, SECOES = {}, {}

# ───────────────────────── Entrada: as peças comuns ─────────────────────────
WAVES = [('svg', 'waves')]
BACK = [('a', 'back'), ('svg', 'back.icon')]
SPARKLES = [('svg', 'sparkleLarge'), ('svg', 'sparkleSmall')]
WORDMARK = pref('wordmark', [('div', ''), ('h1', 'label'), ('span', 'label.book'), ('span', 'label.nest')])


def titulo(tag):
    # o título da folha: a parte em Bricolage, o <br> e a parte em Instrument Serif
    return [(tag, 'title'), ('br', None), ('span', 'title.serif')]


def senha(foco):
    # o campo de senha (os pontos; com foco, o grupo com o cursor), o input escondido e o olho
    pontos = [('span', 'field.value'), ('span', 'field.dots'), ('span', 'field.caret')] if foco else [
        ('span', 'field.dots')]
    return [('div', 'field'), *pontos, ('input', 'field.input'), ('button', 'field.reveal'),
            ('svg', 'field.reveal.icon')]


FORCA = pref('strength', [('div', ''), ('span', 'bar'), ('span', 'bar.fill'), ('svg', 'bar.fill.edge'),
                          ('span', 'label')])


def regras(n):
    return [('ul', 'rules'), *[x for i in range(1, n + 1)
                               for x in (('li', f'rules.rule{i}'), ('span', f'rules.rule{i}.check'),
                                         ('svg', f'rules.rule{i}.check.icon'))]]


SUBMIT = [('button', 'submit'), ('span', 'submit.label'), ('svg', 'submit.icon')]
LEGAL = [('p', 'legal'), ('a', 'legal.terms'), ('a', 'legal.privacy')]

# ───────────────────────── 35 · Abertura ─────────────────────────
SPEC['035_abertura'] = [
    ('div', 'frame'), *WAVES,
    # o carimbo que pousa no meio: os raios e o selo girado
    *pref('stamp', [('div', ''), ('svg', 'rays'), ('div', 'badge'), ('svg', 'badge.art')]),
    *SPARKLES, *WORDMARK,
    *pref('loading', [('div', ''), ('span', 'fill'), ('svg', 'fill.edge')]),
]
SECOES['035_abertura'] = ['waves', 'stamp', 'sparkleLarge', 'sparkleSmall', 'wordmark', 'loading']

# ───────────────────────── 07 · Login ─────────────────────────
SPEC['007_login'] = [
    ('div', 'frame'), *WAVES,
    # a capa ilustrada (o olho e o mar), o selo, os brilhos e a marca
    *pref('cover', [('div', ''), ('svg', 'art'), ('span', 'spine')]), ('svg', 'badge'), *SPARKLES, *WORDMARK,
    *pref('sheet', [
        ('section', ''), *titulo('h2'), ('p', 'lead'),
        # os botões: Google e Apple com o lugar do logo oficial (tracejado), e o e-mail
        ('div', 'buttons'), ('button', 'buttons.google'), ('span', 'buttons.google.logo'),
        ('button', 'buttons.apple'), ('span', 'buttons.apple.logo'),
        ('button', 'buttons.email'), ('svg', 'buttons.email.icon'), ('span', 'buttons.email.label'),
        ('p', 'signIn'), ('a', 'signIn.link'), *LEGAL,
    ]),
]
SECOES['007_login'] = ['waves', 'cover', 'badge', 'sparkleLarge', 'sparkleSmall', 'wordmark', 'sheet']

# ───────────────────────── 08 · Cadastro ─────────────────────────
SPEC['008_cadastro'] = [
    ('div', 'frame'), *WAVES, *BACK, ('svg', 'sparkleLarge'),
    # a carteirinha que se preenche enquanto a pessoa digita (o topo, o nome, o número e o carimbo)
    *pref('card', [
        ('div', ''), ('div', 'header'), ('span', 'header.label'), ('svg', 'header.icon'),
        ('div', 'body'), ('div', 'name'), ('div', 'number'), ('span', 'stamp'), ('svg', 'stamp.icon'),
    ]),
    *pref('sheet', [
        ('main', ''), *titulo('h1'), ('p', 'lead'), ('form', 'form'),
        *pref('form', [
            ('label', 'name.label'), ('div', 'name.field'), ('input', 'name.field.input'), ('p', 'name.hint'),
            ('label', 'email.label'), ('div', 'email.field'), ('input', 'email.field.input'),
            ('span', 'email.field.valid'), ('svg', 'email.field.valid.icon'),
            ('label', 'password.label'), *pref('password', senha(True)),
            *FORCA, *regras(2),
            # novidades por e-mail: começa desmarcado
            ('label', 'newsletter'), ('input', 'newsletter.input'), ('span', 'newsletter.box'),
            *SUBMIT,
        ]),
        *LEGAL,
    ]),
]
SECOES['008_cadastro'] = ['waves', 'back', 'sparkleLarge', 'card', 'sheet']

# ───────────────────────── 09 e 09b · Entrar ─────────────────────────


def entrar(erro):
    return [
        ('div', 'frame'), *WAVES, *BACK, ('svg', 'badge'), *SPARKLES,
        *pref('sheet', [
            ('main', ''), *titulo('h1'), ('p', 'lead'), ('form', 'form'),
            *pref('form', [
                ('label', 'email.label'), ('div', 'email.field'), ('input', 'email.field.input'),
                ('div', 'password.header'), ('label', 'password.label'), ('a', 'password.forgot'),
                *pref('password', senha(not erro)),
                # 09b: o aviso de senha incorreta (o "!" e o texto)
                *([('p', 'alert'), ('span', 'alert.badge'), ('span', 'alert.text')] if erro else []),
                *SUBMIT,
            ]),
            # "ou" e o código por e-mail (amarelo depois do erro)
            ('div', 'divider'), ('span', 'divider.lineLeft'), ('span', 'divider.label'), ('span', 'divider.lineRight'),
            ('button', 'code'), ('svg', 'code.icon'), ('p', 'signUp'), ('a', 'signUp.link'),
        ]),
    ]


SPEC['009_entrar'] = entrar(False)
SPEC['009b_entrar_senha_incorreta'] = entrar(True)
SECOES['009_entrar'] = SECOES['009b_entrar_senha_incorreta'] = [
    'waves', 'back', 'badge', 'sparkleLarge', 'sparkleSmall', 'sheet']

# ───────────────────────── 10 · Código de 6 dígitos ─────────────────────────
SPEC['010_codigo'] = [
    ('div', 'frame'), *WAVES, *BACK, ('svg', 'envelope'), *SPARKLES,
    *pref('sheet', [
        ('main', ''), *titulo('h1'), ('p', 'lead'), ('strong', 'lead.email'),
        # um input só (invisível) desenhado como 6 peças: 3, o traço e 3 (a 5ª com o cursor, a 6ª vazia)
        ('label', 'code.label'), ('input', 'code.input'),
        ('div', 'code'), ('div', 'code.group1'),
        *[('span', f'code.digit{i}') for i in range(1, 4)],
        ('span', 'code.dash'), ('span', 'code.dash.bar'),
        ('div', 'code.group2'), ('span', 'code.digit4'), ('span', 'code.digit5'), ('span', 'code.digit5.caret'),
        ('span', 'code.digit6'),
        # reenviar (o relógio que esvazia e o tempo)
        ('div', 'resend'), ('svg', 'resend.timer'), ('span', 'resend.text'), ('span', 'resend.text.time'),
        ('div', 'help'), ('p', 'help.spam'), ('svg', 'help.spam.icon'),
        ('button', 'help.openMail'), ('svg', 'help.openMail.icon'), ('span', 'help.openMail.label'),
    ]),
]
SECOES['010_codigo'] = ['waves', 'back', 'envelope', 'sparkleLarge', 'sparkleSmall', 'sheet']

# ───────────────────────── 11 · Nova senha ─────────────────────────
SPEC['011_nova_senha'] = [
    ('div', 'frame'), *WAVES, *BACK, ('svg', 'padlock'), *SPARKLES,
    *pref('sheet', [
        ('main', ''), *titulo('h1'), ('p', 'lead'), ('strong', 'lead.email'), ('form', 'form'),
        *pref('form', [
            # o e-mail num campo escondido (para o gerenciador de senhas)
            ('input', 'username'),
            ('label', 'password.label'), *pref('password', senha(True)),
            *FORCA, *regras(3),
            # sair dos outros aparelhos (começa ligado)
            ('div', 'devices'), ('span', 'devices.textBlock'), ('span', 'devices.title'), ('span', 'devices.body'),
            ('button', 'devices.switch'), ('span', 'devices.switch.thumb'), ('svg', 'devices.switch.thumb.icon'),
            *SUBMIT,
        ]),
        ('p', 'notice'), ('svg', 'notice.icon'),
    ]),
]
SECOES['011_nova_senha'] = ['waves', 'back', 'padlock', 'sparkleLarge', 'sparkleSmall', 'sheet']

# ───────────────────────── Onboarding: as peças comuns ─────────────────────────


def topo(voltar, preenchimento=True):
    # o topo: (do 2º passo em diante) voltar, "n de 4", a barra ondulada e "Pular"
    return pref('top', [
        ('div', ''), *([('a', 'back'), ('svg', 'back.icon')] if voltar else []),
        ('span', 'step'), ('span', 'progress'),
        *([('span', 'progress.fill'), ('svg', 'progress.fill.edge')] if preenchimento else []),
        ('a', 'skip'),
    ])


HEADING = pref('heading', [('div', ''), *titulo('h1'), ('svg', 'sparkle')])


def continuar(contagem):
    return pref('continue', [('button', ''), ('span', 'label'), *([('span', 'count')] if contagem else []),
                             ('svg', 'icon')])


def inicio_onboarding(voltar, preenchimento=True):
    return [('div', 'frame'), *WAVES, ('main', 'main'), *topo(voltar, preenchimento), *HEADING, ('p', 'lead')]


# ───────────────────────── 12 · Meta de leitura ─────────────────────────


def minutos(i, marcada):
    return pref(f'daily.option{i}', [
        ('button', ''), ('svg', 'art'), ('span', 'textBlock'), ('span', 'minutes'), ('span', 'hint'),
        ('span', 'radio'), *([('svg', 'radio.icon')] if marcada else []),
    ])


SPEC['012_onboarding_meta'] = [
    *inicio_onboarding(False),
    ('div', 'daily'), *[x for i in range(1, 5) for x in minutos(i, i == 3)],
    # a meta do ano (amarela): menos, o número e mais
    *pref('yearly', [
        ('section', ''), ('span', 'textBlock'), ('span', 'title'), ('span', 'hint'),
        ('div', 'stepper'), ('button', 'stepper.minus'), ('svg', 'stepper.minus.icon'), ('output', 'stepper.value'),
        ('button', 'stepper.plus'), ('svg', 'stepper.plus.icon'),
    ]),
    *continuar(False),
]
SECOES['012_onboarding_meta'] = ['waves', 'top', 'heading', 'lead', 'daily', 'yearly', 'continue']

# ───────────────────────── 13 · Gêneros ─────────────────────────
SPEC['013_onboarding_generos'] = [
    *inicio_onboarding(True),
    # os 15 gêneros (os marcados com o check escuro; os outros com o "+" colorido) e "Mais gêneros"
    ('div', 'genres'),
    *[x for i in range(1, 16) for x in (('button', f'genres.chip{i}'), ('span', f'genres.chip{i}.badge'),
                                       ('svg', f'genres.chip{i}.badge.icon'))],
    ('button', 'genres.more'), ('svg', 'genres.more.icon'),
    *continuar(True),
]
SECOES['013_onboarding_generos'] = ['waves', 'top', 'heading', 'lead', 'genres', 'continue']

# ───────────────────────── 14 e 13b · Primeiros livros (e a dica do scanner) ─────────────────────────
SEARCH = pref('search', [('div', ''), ('label', 'field'), ('svg', 'field.icon'), ('input', 'field.input'),
                         ('button', 'scan'), ('svg', 'scan.icon')])

# a dica do scanner (13b): o foco no botão (com o véu), o anel tracejado, a seta, "é aqui!" e o cartão com a fita
COACH = pref('coach', [
    ('span', 'spotlight'), ('span', 'ring'), ('svg', 'arrow'), ('span', 'tag'),
    ('section', 'card'), ('span', 'card.tape'), ('div', 'card.row'), ('svg', 'card.art'), ('div', 'card.textBlock'),
    ('h2', 'card.title'), ('span', 'card.title.serif'), ('p', 'card.body'),
    ('div', 'card.actions'), ('button', 'card.actions.dismiss'), ('button', 'card.actions.try'),
    ('svg', 'card.actions.try.icon'), ('span', 'card.actions.try.label'),
])

# o desenho de cada capa sugerida (CSS): o sol e o anel; o brilho; as 3 linhas; a estrela; as listras; o arco e a porta
ARTES = [
    [('div', 'cover.sun'), ('div', 'cover.ring')],
    [('div', 'cover.glow')],
    [('div', 'cover.lines'), *[('div', f'cover.lines.line{j}') for j in range(1, 4)]],
    [('svg', 'cover.star')],
    [('div', 'cover.stripes')],
    [('div', 'cover.arch'), ('div', 'cover.door')],
]


def sugestao(i):
    # o livro sugerido: o selo (check nos 3 já na estante, "+" nos outros) e a capa com o título (2 linhas, com <br>,
    # menos O Cortiço) e o autor
    return pref(f'suggestions.book{i}', [
        ('button', ''), ('span', 'wrap'), ('span', 'toggle'), ('svg', 'toggle.icon'),
        ('span', 'cover'), ('span', 'cover.spine'), *ARTES[i - 1],
        ('span', 'cover.textBlock'), ('span', 'cover.title'), *([('br', None)] if i != 6 else []),
        ('span', 'cover.author'),
    ])


SUGESTOES = [('div', 'suggestions.header'), ('h2', 'suggestions.title'), ('span', 'suggestions.note'),
             ('div', 'suggestions.grid'), *[x for i in range(1, 7) for x in sugestao(i)]]

SPEC['014_onboarding_primeiros_livros'] = [*inicio_onboarding(True), *SEARCH, *SUGESTOES, *continuar(True)]
SECOES['014_onboarding_primeiros_livros'] = ['waves', 'top', 'heading', 'lead', 'search', 'suggestions', 'continue']

SPEC['013b_onboarding_dica_scanner'] = [*inicio_onboarding(True), *SEARCH, *COACH, *SUGESTOES, *continuar(True)]
SECOES['013b_onboarding_dica_scanner'] = ['waves', 'top', 'heading', 'lead', 'search', 'coach', 'suggestions',
                                          'continue']

# ───────────────────────── 15 · Foto e @ ─────────────────────────
SPEC['015_onboarding_foto'] = [
    # o 4º passo: a barra já cheia (sem o preenchimento à parte)
    *inicio_onboarding(True, preenchimento=False),
    *pref('photo', [
        ('div', ''), ('div', 'avatarWrap'), ('span', 'avatar'), ('button', 'add'), ('svg', 'add.icon'),
        ('div', 'info'), ('span', 'info.titleRow'), ('span', 'info.title'), ('span', 'info.optional'),
        ('span', 'info.hint'), ('button', 'info.gallery'), ('svg', 'info.gallery.icon'),
    ]),
    # o @ sugerido pelo nome (com o cursor), conferido enquanto digita
    *pref('username', [
        ('label', 'label'), ('div', 'field'), ('span', 'field.at'), ('span', 'field.value'),
        ('span', 'field.text'), ('span', 'field.caret'), ('input', 'field.input'),
        ('span', 'field.valid'), ('svg', 'field.valid.icon'),
        ('p', 'status'), ('span', 'status.chip'), ('span', 'status.rule'),
    ]),
    *pref('bio', [
        ('div', 'header'), ('span', 'header.labelRow'), ('label', 'label'), ('span', 'optional'), ('span', 'counter'),
        ('div', 'field'), ('textarea', 'field.input'), ('svg', 'field.icon'), ('p', 'hint'),
    ]),
    *continuar(False),
]
SECOES['015_onboarding_foto'] = ['waves', 'top', 'heading', 'lead', 'photo', 'username', 'bio', 'continue']

# ───────────────────────── 16 · Carteirinha pronta ─────────────────────────
SPEC['016_onboarding_carteirinha'] = [
    ('div', 'frame'), *WAVES,
    # os confetes: 6 brilhos coloridos, 2 bolinhas e 2 tracinhos
    *[('svg', f'confetti.sparkle{i}') for i in range(1, 7)],
    ('span', 'confetti.dotCoral'), ('span', 'confetti.dotCream'),
    ('span', 'confetti.dashGreen'), ('span', 'confetti.dashLavender'),
    *pref('card', [
        ('article', ''), ('div', 'header'), ('span', 'header.label'), ('span', 'header.number'),
        ('div', 'body'), ('div', 'identity'), ('span', 'avatar'), ('div', 'nameBlock'), ('div', 'name'),
        ('div', 'handle'),
        ('div', 'goals'), ('div', 'goals.daily'), ('div', 'goals.daily.label'), ('div', 'goals.daily.value'),
        ('div', 'goals.yearly'), ('div', 'goals.yearly.label'), ('div', 'goals.yearly.value'),
        ('div', 'genres'), *[('span', f'genres.genre{i}') for i in range(1, 4)], ('span', 'genres.more'),
        ('div', 'footer'), ('div', 'footer.code'), ('svg', 'footer.code.bars'), ('div', 'footer.code.text'),
    ]),
    ('svg', 'stamp'),
    *pref('sheet', [
        ('section', ''), *titulo('h1'), ('p', 'lead'),
        ('button', 'start'), ('svg', 'start.icon'), ('span', 'start.label'),
        ('button', 'share'), ('svg', 'share.icon'),
    ]),
]
SECOES['016_onboarding_carteirinha'] = ['waves', 'confetti', 'card', 'stamp', 'sheet']

# ───────────────────────── 36a · Início no primeiro acesso ─────────────────────────
# o cabeçalho e o título com os ids da Início (01); o sino sem o ponto (nada não lido)
HEADER = [
    ('header', 'header'), ('div', 'header.identity'), ('div', 'header.avatar'), ('div', 'header.greetingColumn'),
    ('span', 'header.greeting'), ('span', 'header.name'),
    ('div', 'header.actions'), ('a', 'header.search'), ('svg', 'header.search.icon'),
    ('button', 'header.bell'), ('svg', 'header.bell.icon'),
]

SPEC['036a_inicio_primeiro_acesso'] = [
    ('div', 'frame'), ('main', 'main'), *HEADER, ('h1', 'headline'), ('br', None), ('span', 'headline.serif'),
    *pref('firstBook', [
        # a prateleira desenhada: 3 lugares tracejados, a tábua e o brilho
        ('section', ''), ('div', 'illustration'), *[('span', f'illustration.slot{i}') for i in range(1, 4)],
        ('span', 'illustration.plank'), ('svg', 'illustration.sparkle'),
        ('span', 'kicker'), ('h2', 'title'), ('p', 'body'),
        ('a', 'cta'), ('span', 'cta.label'), ('svg', 'cta.icon'),
        ('div', 'shortcuts'), ('a', 'shortcuts.scan'), ('svg', 'shortcuts.scan.icon'),
        ('a', 'shortcuts.search'), ('svg', 'shortcuts.search.icon'),
        ('a', 'shortcuts.ebook'), ('svg', 'shortcuts.ebook.icon'),
    ]),
    # a meta de hoje, ainda vazia (o anel com o "0")
    *pref('today', [('section', ''), ('svg', 'ring'), ('span', 'textBlock'), ('span', 'title'), ('span', 'body')]),
    *pref('club', [
        ('a', ''), ('span', 'badge'), ('svg', 'badge.icon'), ('span', 'textBlock'), ('span', 'title'),
        ('span', 'body'), ('svg', 'chevron'),
    ]),
    *BOTTOM_FADE, *NAV,
]
SECOES['036a_inicio_primeiro_acesso'] = ['header', 'headline', 'firstBook', 'today', 'club', 'bottomFade', 'nav']

ESPECIAIS = {'frame', 'main'}

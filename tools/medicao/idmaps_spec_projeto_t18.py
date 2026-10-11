#!/usr/bin/env python3
"""T13.8 (R4) — ids semânticos das telas da etapa 11 · T18 (o cronômetro de leitura): 18 e 18b.

Mesmo formato do idmaps_spec.py: cada prancha = lista (tag, id) na ordem do template (`data-dc-tpl` a partir do quadro,
tpl 4), sem o interior dos <svg>; id None = elemento não medido (os <br>). Junto das outras etapas em
idmaps_spec_projeto.py (o gerador: CONJUNTO=projeto python3 tools/medicao/idmaps_spec.py).

- Cronômetro (18): a barra de cima (`top`: minimizar, "SESSÃO 7" e o som ambiente), o livro (`book`: a capa inclinada,
  o título e o autor), o relógio (`timer`: o anel desenhado, o estado com o ponto, o tempo e "Hoje: 26 de 30 min"), as
  duas etiquetas (`chips`: a meta e a sequência), os três controles (`controls`: Trecho, Pausar e Encerrar — cada um com
  o botão, o ícone e o rótulo), "Anotar um pensamento" (`note`) e o aviso de bloquear a tela (`lockHint`).
- Fim da sessão (18b): a 18 por baixo com os mesmos nomes (o tempo é outro), o escurecido (`scrim`), os confetes
  (`confetti`, sem contêiner: as estrelinhas e os dois pedaços, como na 16) e a folha (`sheet`): a alça, o selo da meta
  (`stamp`, o texto em curva fica no desenho), "SESSÃO ENCERRADA", o título com a parte serifada, os três números
  (`stats`: a sessão, o dia e a sequência — cada um com o ícone redondo, o valor e o rótulo), a página onde parou
  (`pageHeader`, com "Opcional", e `page`: anterior, o campo com "pág.", o número e o input escondido, próxima), o
  quanto avançou (`progress`), "Salvar sessão" e "Pular a página".
"""


def pref(base, items):
    # '' = o próprio base; None = elemento sem id (os <br>)
    return [(t, None if n is None else f'{base}.{n}' if n else base) for t, n in items]


SPEC, SECOES = {}, {}


def controle(nome):
    # um controle: o grupo, o botão redondo, o ícone e o rótulo embaixo
    return pref(f'controls.{nome}', [('div', ''), ('button', 'button'), ('svg', 'icon'), ('span', 'label')])


CRONOMETRO = [
    ('div', 'frame'), ('main', 'main'),
    *pref('top', [('header', ''), ('button', 'minimize'), ('svg', 'minimize.icon'), ('span', 'session'),
                  ('button', 'sound'), ('svg', 'sound.icon')]),
    *pref('book', [('div', ''), ('div', 'cover'), ('svg', 'cover.art'), ('div', 'textBlock'), ('div', 'title'),
                   ('div', 'author')]),
    *pref('timer', [('div', ''), ('svg', 'ring'), ('div', 'center'), ('span', 'status'), ('span', 'status.dot'),
                    ('span', 'time'), ('span', 'today'), ('strong', 'today.minutes')]),
    *pref('chips', [('div', ''), ('span', 'goal'), ('svg', 'goal.icon'), ('span', 'streak'), ('svg', 'streak.icon')]),
    ('div', 'controls'), *controle('photo'), *controle('pause'), *controle('end'),
    *pref('note', [('div', ''), ('button', 'button'), ('svg', 'button.icon')]),
    *pref('lockHint', [('p', ''), ('svg', 'icon')]),
]
SECOES_CRONOMETRO = ['top', 'book', 'timer', 'chips', 'controls', 'note', 'lockHint']

SPEC['018_cronometro'] = CRONOMETRO
SECOES['018_cronometro'] = SECOES_CRONOMETRO


def numero(nome):
    # um dos três números da folha: o cartão, o ícone redondo (com o desenho), o valor e o rótulo
    return pref(f'sheet.stats.{nome}', [('div', ''), ('span', 'icon'), ('svg', 'icon.art'), ('span', 'value'),
                                        ('span', 'label')])


SPEC['018b_fim_da_sessao'] = [
    *CRONOMETRO,
    ('div', 'scrim'),
    *[('svg', f'confetti.sparkle{i}') for i in range(1, 4)],
    ('span', 'confetti.dashLavender'), ('span', 'confetti.dotCoral'),
    *pref('sheet', [('section', ''), ('span', 'handle'), ('svg', 'stamp'), ('div', 'label'), ('h1', 'title'),
                    ('br', None), ('span', 'title.serif'), ('div', 'stats')]),
    *numero('session'), *numero('today'), *numero('streak'),
    *pref('sheet', [
        ('div', 'pageHeader'), ('label', 'pageHeader.label'), ('span', 'pageHeader.optional'),
        ('div', 'page'), ('button', 'page.prev'), ('svg', 'page.prev.icon'), ('div', 'page.field'),
        ('span', 'page.field.prefix'), ('span', 'page.field.value'), ('input', 'page.field.input'),
        ('button', 'page.next'), ('svg', 'page.next.icon'),
        ('p', 'progress'), ('strong', 'progress.added'),
        ('button', 'save'), ('span', 'save.label'), ('button', 'skip'),
    ]),
]
SECOES['018b_fim_da_sessao'] = [*SECOES_CRONOMETRO, 'scrim', 'confetti', 'sheet']

ESPECIAIS = {'frame', 'main'}

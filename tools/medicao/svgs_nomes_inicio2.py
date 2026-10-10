"""T02 — nomes e notas dos <svg> da Início e da revisão (01, 01b, 60, 61, 62, 63), lidos pelo exportar_svgs.py
quando CONJUNTO=inicio2 (conjuntos.json → svgNomes). Mesmo formato das tabelas da G01 (leitor), mais OPCOES.

Os desenhos que já existem como asset (mesmo SVG, comparado por C14N) não são copiados: o catálogo aponta para o
arquivo existente (ic_bell, ic_sparkle_*, ic_book_open, ic_highlighter, ic_flame, ic_arrow_right, ic_message_circle,
ic_more_horizontal e os ic_nav_* da Início v1; ic_share e ic_close_round do leitor). Os nomes novos não repetem nome
de arquivo existente (ex.: a lupa da Início não é a ic_search do leitor → ic_search_home).
"""

DOC = ('T02 — os <svg> das 6 pranchas da Início e da revisão (tools/medicao/tmp/inicio2/svgs.json), com as cores '
       'aplicadas e sem duplicatas; os que já existem como asset apontam para o arquivo existente (reuso).')

# primeiro id de cada desenho → (destino, nome-base). O sufixo de variante vem de VARIANTE (cor distintiva).
NOMES = {
    'i01.header.search.icon': ('ic', 'ic_search_home'),
    'i01.header.bell.icon': ('ic', 'ic_bell'),
    'i01.hero.sparkleLarge': ('ic', 'ic_sparkle_outline'),
    'i01.hero.sparkleSmall': ('ic', 'ic_sparkle_solid'),
    'i01.hero.cover.art': ('il', 'il_capa_dom_casmurro'),
    'i01.hero.cta.icon': ('ic', 'ic_book_open'),
    'i01.hero.notesButton.icon': ('ic', 'ic_highlighter'),
    'i01.alsoReading.card1.play.icon': ('ic', 'ic_play'),
    'i01.alsoReading.card1.meta.icon': ('ic', 'ic_book_paper'),
    'i01.alsoReading.card2.ring.svg': ('graf', 'anel_progresso_livro'),
    'i01.today.streakPill.icon': ('ic', 'ic_flame'),
    'i01.today.dial.svg': ('graf', 'mostrador_meta_diaria'),
    'i01.today.readNow.icon': ('ic', 'ic_stopwatch'),
    'i01.review.art.sparkle': ('ic', 'ic_sparkle_amarelo'),
    'i01.forYou.seeAll.icon': ('ic', 'ic_arrow_right'),
    'i01.club.cta.icon': ('ic', 'ic_message_circle'),
    'i01.recent.row0.more.icon': ('ic', 'ic_more_horizontal'),
    'i01.nav.home.icon': ('ic', 'ic_nav_home_active'),
    'i01.nav.library.icon': ('ic', 'ic_nav_library'),
    'i01.nav.scanner.icon': ('ic', 'ic_nav_scanner'),
    'i01.nav.clubs.icon': ('ic', 'ic_nav_clubs'),
    'i01.nav.profile.icon': ('ic', 'ic_nav_profile'),
    'i01b.alsoReading.card1.play.icon': ('ic', 'ic_pause'),   # na 01b o mesmo botão mostra "pausar"
    'i01b.miniBar.cover.art': ('il', 'il_capa_bras_cubas_asas'),
    'rv61.header.close.icon': ('ic', 'ic_close_bold'),
    'rv61.actions.less.icon': ('ic', 'ic_minus'),
    'rv61.actions.more.icon': ('ic', 'ic_plus_bold'),
    'rv61.actions.note.icon': ('ic', 'ic_pencil_edit'),
    'rv61.actions.share.icon': ('ic', 'ic_share'),
    'rv61.actions.next.icon': ('ic', 'ic_arrow_next'),
    'rv62.summary.art.card1.check.icon': ('ic', 'ic_check_tiny'),
    'rv62.summary.streakPill.icon': ('ic', 'ic_sparkle_selo'),
    'rv62.summary.tomorrow.icon': ('ic', 'ic_calendar'),
    'rv62.footer.cta.icon': ('ic', 'ic_book_read'),
    'rv63.sheet.close.icon': ('ic', 'ic_close_round'),
    'rv63.sheet.preview.sparkle': ('ic', 'ic_sparkle_previa'),
    'rv63.sheet.actions.save.icon': ('ic', 'ic_download'),
    'rv63.sheet.actions.stories.icon': ('ic', 'ic_stories'),
    'rv63.sheet.actions.copy.icon': ('ic', 'ic_copy_text'),
    'rv63.sheet.actions.more.icon': ('ic', 'ic_more_circles'),
}
VARIANTE = {'#FED170': 'amarelo', '#FFFAF1': 'creme', '#1A1714': 'tinta'}
# nenhum <svg> destas pranchas usa {{props}} (conferido nos 6 templates: {{brand}} e {{weekColor}} ficam fora dos <svg>)
DINAMICAS = {}
_TEXTO_CAPA = ('tem <text> (Instrument Serif 19 no título; Figtree 700 5,2 no autor{extra}, em unidades do viewBox 96×144) '
               'e preserveAspectRatio="xMidYMid slice" (escala {escala}): o flutter_svg desenha <text> com a fonte do '
               'sistema e não faz "slice" → no app, o desenho sem os textos (BoxFit.cover) e os textos com AppText por '
               'cima, nas mesmas posições × escala; a capa fica dentro de uma caixa girada ({giro}) — o tamanho do '
               'catálogo é o do layout, sem o giro.')
ARMADILHAS = {
    'i01.hero.cover.art': _TEXTO_CAPA.format(extra='', escala='max(101/96, 153/144) = 1,0625', giro='rotate(-3deg)'),
    'i01b.miniBar.cover.art': _TEXTO_CAPA.format(extra='; Figtree 800 4,6 em "MEMÓRIAS PÓSTUMAS DE"',
                                                 escala='max(29,6/96, 45,6/144) = 0,3167', giro='rotate(-5deg)'),
    'i01.alsoReading.card2.ring.svg': 'stroke-dasharray = progresso do livro (91,6 de 113,1 = 2π·18 → 81 %) com '
                                      'rotate(-90): anel desenhado por CustomPainter com o valor real (o rótulo "81%" '
                                      'é texto da página, não do SVG).',
    'i01.today.dial.svg': 'mostrador da meta: anel de progresso r 44 / traço 10 com dasharray 165,9 de 276,5 '
                          '(= 18 de 30 min → 60 %), marcas r 44 com dasharray 1,5 + 7,71 = 2π·44/30 (uma por minuto da '
                          'meta, opacidade 0,35) e a bolinha coral (r 6) na ponta do arco: CustomPainter com '
                          'minutos/meta reais; a posição da bolinha é calculada (aqui 30,1 / 91,6).',
    'i01b.alsoReading.card1.play.icon': 'o "pausar": no Brás Cubas da 01b tem o id do "play" da 01 (alsoReading.card1.play: '
                                        'um botão com dois estados, cronômetro parado/rodando — não dois widgets), amarelo '
                                        '16; a mini-barra usa o mesmo desenho em tinta 18 (ic_pause_tinta).',
    'rv62.summary.art.card1.check.icon': 'o selo fica num cartão girado (rotate(-10deg) e outros): tamanho de uso 10 '
                                         '(atributo e layout); o retângulo visível de 11,6 é o do giro.',
}
OPCOES = {
    'reusar': True,             # desenho igual a um asset existente (C14N) → o catálogo aponta para ele, sem cópia
    'normalizarIds': True,      # ids internos do arquivo (home-dc-iris, homelendo-dc-iris) → dc-iris: mesmo desenho
    'alturaPercentual': True,   # height="100%" → altura do layout (o flutter_svg não resolve porcentagem)
    'tamanhoLayout': True,      # tamanho = o do layout (sem os giros), não o retângulo visível do svgs.js
}

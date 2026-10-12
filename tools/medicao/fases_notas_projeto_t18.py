"""T13.12 — notas escritas à mão das fases L da T18: o Cronômetro de leitura (18) e o Fim da sessão (18b), que substituem
a folha mínima da T04 (`features/reading_session/`: o controlador, a mini-barra e a folha, D-256 a D-266). A parte medida
é gerada por `gen_fases.py` (`CONJUNTO=projeto`); a nota do design fica em `docs/design/projeto/NOTAS.md`
(cronometro-flutter).
"""
from fases_notas_projeto_comum import DADOS, FONTES, VERIFICACAO

G = 'T18'
D243B = ('sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em '
         '`docs/design/estados_sem_design.md`) — confirmar na pergunta da T18 (ROTEIRO §2b)')
ESCURO = ('A tela é escura (o fundo da prancha, para não brilhar ao lado do livro de papel — a nota do design): os botões '
          '`#2B2621` com a borda 1,5 creme a 0,85, os textos `#F7F0E3` e os secundários `#B9AE9C`.')
PROPS = ('As três cores com nome da prancha (`meta.props`): `arc` #FED170 (o arco do anel e a etiqueta da meta), `goal` '
         '#ABCF82 (o selo e o cartão de hoje) e `brand` #B6ACE4 (o anel de 4 em volta do campo da página) — no app vêm '
         'dos tokens.')
TNUM = ('O tempo usa algarismos tabulares (`font-variant-numeric: tabular-nums`; no app, `withTabularFigures()`, D-282): '
        '08:42 e 12:31 têm a mesma largura (184,25). O número do "Hoje" não: o "30" é 0,54 mais largo que o "26" e a '
        'linha continua centrada.')

NOTAS = {
    'L18_1_topo_e_tempo': {
        'g': G, 'arquivos': ['features/reading_session/presentation/timer/timer_screen.dart',
                             'features/reading_session/presentation/timer/timer_top_bar.dart',
                             'features/reading_session/presentation/timer/timer_dial.dart',
                             'core/design_system/painters/timer_ring_painter.dart'],
        'contexto': 'Cronômetro (18), em cima: a barra (minimizar com o tempo andando, "SESSÃO 7", o som ambiente '
                    '"Chuva"), o livro de papel (a capa girada, o título e "Machado de Assis · livro físico") e o relógio '
                    '— o mostrador com os 60 traços, o anel da meta de hoje, "LENDO", o tempo 08:42 e "Hoje: 26 de 30 min". '
                    'Substitui a folha mínima da T04.',
        'leitura': [
            'A coluna é centrada em x = 195, com 18 entre o topo, o livro, o relógio e as etiquetas.',
            'Topo de 48 (`align-self: stretch`, `space-between`): minimizar (48, a seta para baixo 22 traço 2,2), "SESSÃO '
            '7" 12/800 ls 1,6 `#B9AE9C` e o som (pílula de 40, padding 0/14/0/11, gap 7, a nuvem de chuva 17 e "Chuva" '
            '13/800).',
            'Livro 18 abaixo (gap 14): a capa 46 × 69 (raio 3/7/7/3, borda 1,5 creme, sombra 3/3 preta) girada −5°, com o '
            'desenho da capa (SVG `slice`); "Memórias Póstumas de Brás Cubas" 15,5/800 `lh 1,25` e o autor com o formato '
            '13/600 `#B9AE9C`, 3 abaixo.',
            'Relógio 18 abaixo, 300 × 300 (`role="timer"`): o círculo de raio 146 `#221E1A` com a borda 1,5 creme a 0,85; '
            'os 60 traços (12 grossos de 2 a 0,9 e 48 finos de 1,2 a 0,35, pontas redondas); o trilho de raio 112 (10 '
            '`#3A332C`) e o arco `{{arc}}` de 10 com a ponta redonda, começando no alto.',
            'No meio: "LENDO" 11,5/800 ls 1,8 `#B9AE9C` com a bolinha coral 8; o tempo Bricolage 74/800 `lh 1` ls −2 '
            '`tnum`, 6 abaixo; "Hoje: 26 de 30 min" 14/600 `#B9AE9C` com o "26" 800 creme, 8 abaixo.',
            ESCURO,
            FONTES,
        ],
        'interacoes': [
            'Minimizar → fecha a tela e o tempo continua: volta para onde estava, com a mini-barra da T04 (D-256); tocar '
            'na mini-barra reabre o cronômetro.',
            'Som ambiente → escolher e tocar chuva, café ou lareira (a nota do design) — a escolha e o tocador não têm '
            'prancha nem pacote no app: ' + D243B + '; o áudio é pergunta da T18.',
            'O relógio anda a cada segundo (o `second_ticker.dart` da T04), também com a tela bloqueada ou o app minimizado '
            '(a nota do design pede a notificação fixa no Android e a Live Activity no iPhone — pergunta da T18).',
        ],
        'dados': [
            'A sessão aberta (`OpenPaperSession`) e o livro de papel (`paper_book_source.dart`): o tempo desta sessão, o '
            'número da sessão do livro ("SESSÃO 7" = as sessões já gravadas + 1), o título, o autor e o formato.',
            '"Hoje" = os minutos do dia (todas as sessões, papel e e-book) contra a meta diária (`ReadingGoals`); o arco é '
            'essa fração.',
            DADOS,
        ],
        'armadilhas': [
            'O arco da prancha tem 626,3 de 703,7 (89%), mas 26 de 30 dá 86,7%: o desenho não bate com o número. No app o '
            'arco é o progresso real; a fixture que reproduz a prancha e a regra (fração exata ou o arco da prancha) é '
            'pergunta da T18.',
            TNUM,
            'A capa girada desenha fora da própria caixa (a referência guarda a caixa sem o giro e a visível, `vis`).',
            'O arco é `stroke-dasharray` girado −90°: `CustomPainter` com o valor real (o mapa de widgets), não o SVG.',
            PROPS,
        ],
        'subfases': ['Tela escura e a coluna centrada', 'Topo: minimizar, sessão e som', 'Livro com a capa girada',
                     'Relógio: mostrador, traços e arco', 'Estado, tempo e hoje', VERIFICACAO],
    },
    'L18_2_controles': {
        'g': G, 'arquivos': ['features/reading_session/presentation/timer/timer_screen.dart',
                             'features/reading_session/presentation/timer/timer_controls.dart'],
        'contexto': 'Cronômetro (18), embaixo: as etiquetas "Faltam 4 min para a meta" e "12 dias", os três controles '
                    '(Trecho, Pausar maior no meio, Encerrar), "Anotar um pensamento" tracejado e o aviso "Pode bloquear a '
                    'tela: o tempo continua.".',
        'leitura': [
            'Etiquetas 18 abaixo do relógio (flex-wrap, gap 8, centradas): pílulas de 34, borda 1,5 creme, 13/800 preto — '
            'a da meta em `{{arc}}` com o alvo 16, a da sequência coral com o fogo 16.',
            'Controles no fundo (`margin-top: auto`, padding 0/6, `space-between`, alinhados pelo topo): colunas de 86 com '
            'o botão e o rótulo 12,5/700 `#B9AE9C`, 8 abaixo; Trecho e Encerrar com o círculo 58 escuro (a câmera 22; o '
            'quadrado creme 18); Pausar com o círculo 86 creme, sem borda, o anel de 5 `#3A332C` (sombra) e as duas barras '
            'pretas 30, com o rótulo creme.',
            '"Anotar um pensamento" 14 abaixo: pílula de 36, padding 0/14/0/11, sem fundo, tracejado 1,5 creme a 0,6, o '
            'lápis 15 e 13/700 creme.',
            'O aviso 14 abaixo: 12,5/600 `#8F8577` com o cadeado 14 (gap 7); o aviso termina 34 acima do fundo.',
            ESCURO,
            FONTES,
        ],
        'interacoes': [
            'Pausar → pausa (o rótulo vira "Continuar" e o ícone o play — sem prancha: ' + D243B + '); o mesmo `toggle` do '
            'controlador da T04.',
            'Encerrar → abre o Fim da sessão (18b) por cima, com o tempo parado.',
            'Trecho → a câmera (`image_picker`) para fotografar o trecho do livro de papel; onde a foto fica (um grifo '
            'de foto, sem prancha) é pergunta da T18.',
            'Anotar um pensamento → a nota da sessão: a folha não tem prancha aqui — ' + D243B + ' (ou a folha de nota do '
            'leitor, `note_sheet.dart`, se a T18 decidir).',
        ],
        'dados': [
            '"Faltam N min para a meta" = a meta diária − os minutos de hoje (some ou muda quando bate: o texto da meta '
            'batida durante a sessão não tem prancha — pergunta da T18); "12 dias" = a sequência.',
            DADOS,
        ],
        'armadilhas': [
            'Os três controles se alinham pelo topo, com 40 entre eles e o do meio maior (86 contra 58): os rótulos ficam '
            'em alturas diferentes, como na prancha.',
            'O anel do Pausar é `box-shadow` (0 0 0 5): fica fora do círculo de 86 e não ocupa espaço.',
            'As etiquetas quebram com `flex-wrap`, mas sobram 55,8 na fileira: nenhum fio de navalha (D-278).',
            PROPS,
        ],
        'subfases': ['Etiquetas da meta e da sequência', 'Os três controles', 'Anotar e o aviso de bloquear',
                     VERIFICACAO],
    },
    'L18b_fim_da_sessao': {
        'g': G, 'arquivos': ['features/reading_session/presentation/timer/end_session_sheet.dart',
                             'features/reading_session/presentation/timer/goal_stamp.dart',
                             'features/reading_session/application/paper_end_form.dart'],
        'contexto': 'Fim da sessão (18b): o cronômetro por baixo do escurecido, os confetes e a folha — o selo verde "meta '
                    'do dia batida" girado saindo da borda, "SESSÃO ENCERRADA", "12 minutos e meta batida!", os três '
                    'números (12:31 nesta sessão, 30/30 min hoje, 12 dias seguidos), a página onde parou com menos e mais, '
                    '"Salvar sessão" e "Pular a página".',
        'leitura': [
            'Por baixo, a 18 inteira com o tempo 12:31 e "Hoje: 30 de 30 min" (a tabela "Diferenças"); o escurecido '
            '(`#0C0A08` a 0,62) e os confetes (as três estrelinhas e os dois pedaços, soltos no quadro).',
            'Folha (`left/right/bottom 0`, `z-index 4`): padding 12/20/34, raio 32/32/0/0, `#FFFAF1`, só a borda de cima '
            '1,5; a alça 44 × 5 `#CFC3AE`; o selo 104 (viewBox 112) em `right 18 · top −46`, girado 10°.',
            '"SESSÃO ENCERRADA" 11,5/800 ls 1,6 `#6F665B`, 16 abaixo; "12 minutos" Bricolage 32/800 `lh 0,98` ls −1 + '
            'quebra + "e meta batida!" Instrument Serif itálico 42, 6 abaixo.',
            'Números 18 abaixo (gap 8, `flex 1 1 0`): padding 12/10/11, raio 18, borda 1,5 (`#F7F0E3`, `{{goal}}`, '
            'coral), o ícone num círculo 30, o valor Bricolage 21/800 `nowrap` `tnum` e o rótulo 12/700 `#3E3832`.',
            'Página 20 abaixo: "Em que página você parou?" 15/800 e "Opcional" (22, borda 1,5 `#CFC3AE`, 11/800); a '
            'fileira (gap 10, 10 abaixo): menos (52, `#FFFAF1`), o campo de 64 (raio 18, borda 1,5, o anel `{{brand}}` de '
            '4) com "pág." 14/700 e o "88" Bricolage 38/800 `tnum`, e mais (52, preto).',
            '"Antes: pág. 74 · +14 páginas hoje" 13/600 centrado, 10 abaixo; "Salvar sessão" (54, preto, 16/800), 18 '
            'abaixo; "Pular a página" (44, sem fundo, 14,5/800 sublinhado), 6 abaixo.',
            FONTES,
        ],
        'interacoes': [
            'Menos e mais → a página (1 a N, a regra da T04, `paper_end_form.dart`); tocar no número abre o teclado '
            'numérico (a nota do design).',
            'Salvar sessão → encerra e grava a sessão com a página (o `end(page:)` da T04); a tela fecha e volta para onde '
            'estava.',
            'Pular a página → grava só os minutos (o `end()` sem página).',
            'Arrastar a alça para baixo ou tocar no escurecido → volta ao cronômetro sem encerrar (se o tempo fica '
            'parado ou volta a andar é pergunta da T18).',
            'Com a meta batida: o selo, os confetes e a vibração leve (a nota do design); sem a meta, a folha sem o selo e '
            'o título sem "e meta batida!" — sem prancha: ' + D243B + '.',
        ],
        'dados': [
            'Os três números: o tempo desta sessão, os minutos de hoje contra a meta e a sequência. A página vem sugerida '
            'pela última anotada (a nota do design) e o "Antes" é a página da sessão anterior; "+14 páginas" = a página '
            '− a anterior.',
            'O livro sem o total de páginas: a folha da T04 pede o total; aqui não há esse campo na prancha — pergunta da '
            'T18.',
            DADOS,
        ],
        'armadilhas': [
            'A 18b não é outra tela: a folha abre por cima do cronômetro, que fica igual por baixo do escurecido. Por baixo '
            'da folha a etiqueta ainda diz "Faltam 4 min para a meta" — fica escondida, e no app vale o estado real.',
            TNUM + ' Os três números da folha e o da página também são `tnum`.',
            'O input da página é de 1 px e invisível, mas o navegador dá a ele a borda e o recuo padrão (9 × 7) e, '
            'absoluto num flex sem posição, o põe no centro do campo: o número mostrado é um `<span>`, não o input. No '
            'app, um `TextField` estilizado com o número, sem a caixa de 1 px.',
            'O selo, a capa e o pedaço lilás dos confetes são girados (a referência guarda a caixa sem o giro e a visível, '
            '`vis`); o texto em curva do selo ("META DO DIA · BATIDA") fica no desenho (`<textPath>`, o mapa de widgets).',
            'A borda de cima da folha com o raio só em cima faz o Skia do Chromium desenhar um bloco no canto em alguns '
            'zooms (R3): a referência foi conferida por faixa (`convergenciaFaixa`, y 290–335) — no app não há o defeito.',
            PROPS,
        ],
        'subfases': ['Escurecido, confetes e a moldura da folha', 'Selo, título e os três números',
                     'Página onde parou (menos, campo, mais)', 'Salvar e pular', VERIFICACAO],
    },
}

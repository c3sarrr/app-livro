"""T02 — parte ESCRITA À MÃO das fases L da Início e da revisão (leitura de designer, interações, dados, armadilhas,
subfases). A parte medida (HTML literal, tabelas, linhas, diferenças, semântica, widgets, testes) é gerada por
gen_fases.py (CONJUNTO=inicio2). Referências: o plano `docs/progresso/PLANO_FIDELIDADE_TELAS.md` (T03–T05, D-240…D-247),
a Início da v1 (`design_handoff/referencia/layout/layout_inicio.json`: os ids são os mesmos onde o elemento é o mesmo)
e os achados da T02.
"""

FONTES_INICIO = ('Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree '
                 'renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é '
                 'sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).')
FONTES_REVISAO = ('Fontes desta prancha: a Figtree vai até 800 (D-246: 800 **real**, `Figtree-ExtraBold.ttf`; 900 '
                  'renderiza 800); Bricolage 800 com a família do tamanho; Literata estática por tamanho (D-104).')
D243B = 'sem ação (D-243 b): o elemento fica idêntico à prancha, o toque não faz nada, um teste documenta e o item entra em `docs/design/estados_sem_design.md`'

NOTAS = {
    'L01a1_cabecalho': {
        'g': 'T03', 'arquivos': ['features/home/presentation/sections/header_section.dart', 'features/home/presentation/sections/headline_section.dart'],
        'contexto': 'Cabeçalho da Início nova: avatar, saudação e, à direita, dois botões redondos — a lupa (nova) e o sino '
                    'com o ponto coral. Abaixo, o título "Continue / sua história." (igual à v1).',
        'leitura': [
            'Cabeçalho 350 × 48, `space-between`. Identidade: avatar 44 (círculo `#FED170`, borda 1,5, "M" Bricolage 18/800) + '
            'coluna (gap 1) com "Boa noite," Figtree 13/500 `#5B544B` e "Marina" Figtree 16/700 ls −0,1.',
            'Ações (gap 8): **lupa** e sino, ambos círculos 48 `#FFFAF1` com borda 1,5. Ícones 22: `ic_search_home` (novo, '
            'traço 1,9) e `ic_bell` (o da v1). O ponto do sino é `content-box`: 9 + borda 1,5 `#FFFAF1` = 12 por fora, '
            'em `top 9 · right 11`, coral `#FF552E`.',
            'Título: Bricolage 42/800, `line-height 0,98`, ls −1,4; "sua história." em Instrument Serif itálico 50 ls −0,6 '
            '(inline) — 2 linhas, mesma composição da v1, 24 abaixo do cabeçalho.',
            'O que muda em relação à v1: só o grupo `header.actions` (antes o sino ficava sozinho).',
            FONTES_INICIO,
        ],
        'interacoes': [f'Lupa → {D243B} (busca = C14, sem prancha).', 'Sino e avatar → como hoje (G08/G21).'],
        'dados': ['Saudação pela hora e nome do perfil (como na v1); ponto do sino = há notificação não lida.'],
        'subfases': ['Cabeçalho com lupa e sino', 'Título "Continue sua história."', 'Lupa sem ação (D-243 b) + estados_sem_design', 'Verificação + relatório'],
    },
    'L01a2_heroi': {
        'g': 'T03', 'arquivos': ['features/home/presentation/sections/continue_reading_hero.dart', 'features/home/presentation/covers/dom_casmurro_cover.dart'],
        'contexto': 'Herói "Continuar lendo" do Dom Casmurro com a capa nova (o olho e o mar), as pílulas "pág. 159 de 256" '
                    'e "E-BOOK" no lugar da pílula de capítulo da v1 e o contador de anotações "12".',
        'leitura': [
            'Cartão: fundo `{{brand}}` (padrão `#B6ACE4`), borda 1,5, raio 28, sombra dura 4/4, padding 20 → 350 × 282,8 '
            '(a v1 tinha 275: +7,8 pelas duas pílulas, que quebram em 2 linhas).',
            'Capa 104 × 156 **girada −3°** (`Transform.rotate` no centro; a tabela traz o retângulo de layout, a caixa visual vem '
            'abaixo dela), raio 4/10/10/4, borda 1,5, sombra 3/3, `overflow: hidden`: desenho `il_capa_dom_casmurro.svg` '
            '(101 × 153, `slice`) e, por cima, a lombada de 7 px `rgba(0,0,0,.22)`.',
            'Pílulas (`wrap`, gap 6): "pág. 159 de 256" Figtree 12/700, padding 5/10, `#FFFAF1`, borda 1,5, raio 999; '
            '"E-BOOK" Figtree 11/900 (→ 700), ls 0,8, padding 5/8, `#FED170`. A 2ª desce para a linha de baixo (181 de largura útil).',
            'Título Bricolage 24/800 `lh 1,05` ls −0,6 + autor Figtree 14/500 `#2F2A40`; "62%" Bricolage 26/800 e "~2h 10min" '
            'Figtree 12/600 alinhados pela baseline (`space-between`); barra de 10 com o preenchimento `#1A1714` em 62 %.',
            'Ações (gap 10): CTA preto de 54 (livro aberto 20 `#F7F0E3` + "Continuar lendo" Figtree 16/700) e o botão 54 dos '
            'destaques (marca-texto 22) com o contador amarelo "12" (Figtree 11/800 → 700, `top/right −4`, mín. 22).',
            'Brilhos da v1: `ic_sparkle_outline` 30 (`top 18 · right 18`) e `ic_sparkle_solid` 14 (`top 54 · right 50`).',
            FONTES_INICIO,
        ],
        'interacoes': ['CTA → abre o leitor na posição salva (como hoje).', 'Botão dos destaques → os grifos do livro (tela 25), como hoje.'],
        'dados': ['"pág. 159 de 256" = página de referência atual e total (G10); "E-BOOK" = formato do livro (a regra para PDF '
                  'e papel fica no plano da T03); "12" = anotações do livro (D-241: o mundo do leitor); "62%" e "~2h 10min" como hoje.',
                  'A capa desenhada só na fixture; capas reais seguem a D-79.'],
        'armadilhas': ['A capa tem `<text>` (Instrument Serif e Figtree) e `preserveAspectRatio="xMidYMid slice"`: o flutter_svg '
                       'usa a fonte do sistema e não faz "slice" → desenho sem os textos (BoxFit.cover) + textos em `AppText` '
                       'nas posições do viewBox × 1,0625 (catálogo de SVGs).',
                       '"Continuar lendo" sai 0,0528 px mais largo que o Chromium com a `Figtree-Bold.ttf` da v1 (validação de '
                       'fontes da T02; limite 0,05) — dentro da tolerância de geometria; decisão no relatório T02.'],
        'subfases': ['Cartão e grade do herói', 'Capa nova (SVG sem textos + AppText, giro −3°)', 'Pílulas página e formato',
                     'Título, progresso e tempo', 'Ações e contador', 'Verificação + relatório'],
    },
    'L01a3_tambem_lendo': {
        'g': 'T03', 'arquivos': ['features/home/presentation/sections/also_reading_section.dart', 'features/home/presentation/covers/memorias_postumas_cover.dart',
                                 'features/home/presentation/covers/pride_prejudice_cover.dart'],
        'contexto': '"Também lendo 3": Brás Cubas (livro de papel, com o "play" do cronômetro e "Papel · 3h 40min") e '
                    'Orgulho e Preconceito (papel, anel de 81 % e "Papel · pág. 344").',
        'leitura': [
            'Título Bricolage 18/800 ls −0,3 + contador preto 22 ("3", Figtree 12/800 → 700); grade de 2 colunas (gap 12), '
            '30 abaixo do título.',
            'Cartão 169 × 153,81: padding 0/14/14, raio 22, `#FFFAF1`, borda 1,5, sem sombra. A capa (54 × 81, raio 3/7/7/3, '
            'borda 1,5, sombra 2/2) **sobe 22** (`margin-top −22`, sai pela borda de cima) e gira: −4° no Brás Cubas, +3° no Orgulho.',
            'Capa do Brás Cubas em CSS (não é SVG): fundo `#058CD7`, lombada 5 `rgba(0,0,0,.18)`, cartola = retângulo 18 × 16 '
            '(raio 2/2/0/0) + aba 28 × 5 elíptica, ambas `#1A1714`; "Brás / Cubas" Instrument Serif 11 `lh 0,95` `#FED170`. '
            'Orgulho e Preconceito: `#FFC1C6`, círculo 20 com borda 1,5, título Instrument Serif 9 `#1A1714` (2 linhas).',
            '"Play": círculo 46 preto (12 abaixo do topo da faixa) com o triângulo amarelo 18 (`ic_play`). Anel: 46 '
            '(`anel_progresso_livro`: r 18, traço 5, trilho `#EAE1CF`, 81 %) + "81%" Figtree 11/800 (→ 700) no centro.',
            'Título Figtree 15/700 `nowrap` + reticências: "Orgulho e Preconceito" não cabe em 138 e aparece "Orgulho e '
            'Precon…" (a tabela traz o texto inteiro; o PNG mostra o cortado). Autor 13/500 `#5B544B`.',
            'Pílula meta (6 abaixo): fundo `#F7F0E3`, borda 1,2 `#E2D7C4`, raio 999, padding 3/8/3/6, livro de papel 12 '
            '(`ic_book_paper`) + "Papel · 3h 40min" Figtree 11,5/700.',
            FONTES_INICIO,
        ],
        'interacoes': [f'"Play" → aparece na T03 {D243B}; ganha ação na T04 (D-247: começa a sessão do cronômetro).',
                       'Capa do Brás Cubas (link) e cartão do Orgulho (link) → página do livro, como hoje.'],
        'dados': ['"3" = livros em leitura além do herói (a grade mostra 2 — regra do contador no plano da T03, como a v1 fazia).',
                  '"Papel · 3h 40min" e "Papel · pág. 344": formato papel + tempo ou página — a regra (tempo lido? restante?) '
                  'fica para o plano da T03 (já listada no PLANO_FIDELIDADE_TELAS); "81%" = progresso.'],
        'armadilhas': ['Reticências do Flutter (`TextOverflow.ellipsis`) têm de cortar no mesmo ponto: "Orgulho e Precon…".',
                       'Capas giradas saem pela borda de cima do cartão: o cartão não pode recortar (`clipBehavior: none`).'],
        'subfases': ['Título e contador', 'Cartões e capas giradas (Brás Cubas com cartola, Orgulho)', '"Play" (sem ação) e anel 81 %',
                     'Título com reticências e pílula "Papel"', 'Verificação + relatório'],
    },
    'L01a4_seu_dia': {
        'g': 'T03', 'arquivos': ['features/home/presentation/sections/reading_day_card.dart'],
        'contexto': 'Cartão amarelo "Seu dia de leitura": meta (18 de 30 min), o botão novo "Ler agora", as pílulas '
                    '"2 sessões" e "2 destaques", a semana e o selo.',
        'leitura': [
            'Cartão `#FED170`, borda 1,5, raio 28, sombra 4/4, padding 18, `overflow: hidden` (os dois círculos decorativos '
            '150 e 98, borda 1,5 `rgba(26,23,20,.14)`, saem pelo canto superior direito e são recortados).',
            'Cabeçalho: "Seu dia de" Bricolage 20/800 ls −0,4 + "leitura" Instrument Serif itálico 23; pílula "12 dias" '
            '(32 de altura, `#FFFAF1`, borda 1,5, chama 17 + Figtree 13/800 → 700).',
            'Mostrador 112 (`mostrador_meta_diaria`: CustomPainter — anel r 44 traço 10 em 60 %, 30 marcas, bolinha coral) com '
            '"18" Bricolage 34/800 ls −1 e "de 30 min" Figtree 11/700 `#4A4238` no centro.',
            'Coluna (gap 10): "Faltam **12 min** para fechar / a meta de hoje." Figtree 15/600 `lh 1,3` (`text-wrap: pretty`; '
            'o forte 800 → 700); **"Ler agora"** (novo): pílula preta 40, padding 0/14/0/11, cronômetro 17 amarelo '
            '(`ic_stopwatch`) + Figtree 14/800 (→ 700) `#F7F0E3`; pílulas "2 sessões" e "2 destaques" (Figtree 12/700, '
            'fundo `rgba(255,250,241,.7)`, borda 1,2).',
            'Semana (igual à v1): caixa `#FFFAF1` raio 22; barras 33,14 × 80 com hachura 135° `#EFE6D4`/`#FFFAF1` (3/7) e o '
            'preenchimento lavanda; a de hoje com hachura `#FDE2B2` e preenchimento coral de 24; linha da meta tracejada a 45 %.',
            'O que muda em relação à v1: "Ler agora" e "2 sessões" (no lugar da pílula de páginas); o texto da meta sobe e a '
            'linha fica 13,8 mais alta.',
            FONTES_INICIO,
        ],
        'interacoes': [f'"Ler agora" → aparece na T03 {D243B}; ganha ação na T04 (D-247).', 'Pílulas e semana: informativas.'],
        'dados': ['Minutos de hoje (18) e meta (30) como hoje; "N sessões" = sessões de `reading_sessions` de hoje; "2 destaques" '
                  'como hoje; semana: 32, 45, 30, 22, 38, 55 e 18 (= 4h 00min, do rótulo `aria` do gráfico).'],
        'subfases': ['Cartão e cabeçalho com a sequência', 'Mostrador (CustomPainter)', 'Texto da meta e "Ler agora" (sem ação)',
                     'Pílulas "N sessões" e destaques', 'Semana e selo', 'Verificação + relatório'],
    },
    'L01a5_revisao': {
        'g': 'T03', 'arquivos': ['features/home/presentation/sections/review_card.dart'],
        'contexto': 'Seção nova: cartão "Seus grifos de hoje" com a arte dos três cartões de grifo e o botão "Revisar". '
                    'Aparece com a fixture e some com dados reais até a T05 (D-247).',
        'leitura': [
            'Cartão `#FFFAF1`, borda 1,5, raio 28, sombra 4/4, padding 16, linha (gap 14) alinhada ao centro → 350 × 165,15.',
            'Arte 104 × 112: três cartõezinhos (62 × 82, 62 × 82 e 66 × 90; raio 10, borda 1,5, sombra 2/2, padding 10/8, '
            'gap 5) girados −12°, +8° e −2° (ordem de pintura: verde, rosa, lavanda por cima); em cada um, 4 traços de 5 '
            '(raio 3) em 90/70/82/55 % — os dois primeiros na cor do grifo (`#ABCF82`, `#FFC1C6`, `#B6ACE4`), os outros '
            '`#E4DACA` (cor nova). Brilho amarelo 26 (`ic_sparkle_amarelo`) em `right −2 · top −4`.',
            'Texto (gap 4): "REVISÃO · 5 GRIFOS · 2 MIN" Figtree 11/800 (→ 700) ls 1 `#6F665B`; "Seus grifos" Bricolage 20/800 '
            '`lh 1,05` ls −0,5 + "de hoje" Instrument Serif itálico 24; "De Dom Casmurro, Quincas Borba / e Iracema." Figtree '
            '12,5/600 `lh 1,35` `#5B544B` (2 linhas).',
            '"Revisar": pílula preta 40 (6 acima), padding 0/16/0/12, brilho amarelo 15 (`ic_sparkle_solid_amarelo`) + '
            'Figtree 14/800 (→ 700) `#F7F0E3`.',
            FONTES_INICIO,
        ],
        'interacoes': [f'"Revisar" e o cartão → {D243B} até a T05 (rota `/revisao`).'],
        'dados': ['D-247: com a fixture `t01` (testes de fidelidade) o cartão aparece; com dados reais some até a T05. '
                  '"5 grifos · 2 min" e os livros do subtítulo vêm do baralho do dia (T05).'],
        'subfases': ['Cartão e arte dos três cartões (giros)', 'Textos e "Revisar"', 'Regra D-247 (fixture × dados reais)', 'Verificação + relatório'],
    },
    'L01a6_para_voce': {
        'g': 'T03', 'arquivos': ['features/home/presentation/sections/for_you_section.dart', 'features/home/presentation/covers/'],
        'contexto': '"Para você" com a pílula do motivo e três capas novas: Esaú e Jacó, Memorial de Aires e Casa de Pensão '
                    '(na v1: Memórias Póstumas, Quincas Borba, O Cortiço).',
        'leitura': [
            'Cabeçalho 44: "Para você" Bricolage 24/800 ls −0,6 × "Ver tudo" Figtree 14/700 + seta 18; pílula "Porque você lê '
            'Machado de Assis" (Figtree 13/600, borda 1,5, brilho 14) 14 abaixo.',
            'Carrossel com `margin 4 −20 0` e `padding 0 20`, `overflow: hidden`: itens de 116 (gap 14); o 3º passa da borda '
            '(até x 396) e é recortado em 390.',
            'Capas em CSS (116 × 174, raio 4/10/10/4, borda 1,5, lombada 7): **Esaú e Jacó** — fundo coral `#FF552E`, mancha '
            'preta elíptica 123 × 116 (`left 20 · right −30 · bottom −58`), "Esaú / e Jacó" Instrument Serif 22 `lh 0,95` '
            '`#1A1714`, autor Figtree 6,5/700 ls 0,14 em **coral** (o "M" fica coral sobre coral, fora da mancha: no PNG lê-se '
            '"ACHADO DE ASSIS" — fiel ao arquivo). **Memorial de Aires** — `#058CD7`, três traços creme de 6 (100/70/40 %), '
            'título 26 `lh 0,9` `#FFFAF1`. **Casa de Pensão** — `#00995E`, arco amarelo 68 × 80 (raio 34/34/0/0) com o vão '
            'verde 28 × 46 (raio 14/14/0/0), título 26 creme.',
            'Título do livro Figtree 14/700 (reticências no 1º) e autor 13/500 `#5B544B`.',
            FONTES_INICIO,
        ],
        'interacoes': ['Capa/item → página do livro; "Ver tudo" → como hoje.'],
        'dados': ['Recomendações como hoje (G21); as capas desenhadas só na fixture (D-79).'],
        'subfases': ['Cabeçalho e motivo', 'Carrossel (recorte do 3º item)', 'Capas novas (Esaú e Jacó, Memorial de Aires, Casa de Pensão)', 'Verificação + relatório'],
    },
    'L01a7_clube': {
        'g': 'T03', 'arquivos': ['features/home/presentation/sections/book_club_ticket.dart'],
        'contexto': 'O ingresso do clube "Leitoras de Capitu" — igual ao da v1 (F09), com o subtítulo "Dom Casmurro · até o '
                    'cap. 50" (D-241: os números do clube).',
        'leitura': [
            'Mesmo desenho, medidas e pintores da v1 (o ticket com recortes, a hachura do progresso `#EFE6D4`/`#FFFAF1`, o '
            'marcador "M" em 62 % e o grupo em 54 %, a ponta rosa com "QUI 24 SET 20h").',
            'Diferenças em relação à v1: o subtítulo ("até o cap. 50") e a posição na página (a Início ficou mais alta).',
            FONTES_INICIO,
        ],
        'interacoes': ['Como hoje (G21): o cartão e "Abrir discussão" abrem o clube.'],
        'dados': ['D-241: capítulo do clube 50 (o mesmo do mundo do leitor e do clube); demais números como hoje.'],
        'subfases': ['Ticket com o subtítulo novo', 'Verificação + relatório (diferenças só de posição)'],
    },
    'L01a8_recem_chegados': {
        'g': 'T03', 'arquivos': ['features/home/presentation/sections/recently_added_section.dart'],
        'contexto': '"Recém-chegados": Frankenstein ("Quero ler"), O Alienista (agora **"Lido"**, pílula verde nova) e '
                    'Senhora (agora em **papel**).',
        'leitura': [
            'Lista `#FFFAF1` raio 24, padding 4/8/4/14; linhas de 91 com divisória 1 `#E9E1D2`; capas 44 × 66 (raio 3/7/7/3, '
            'borda 1,2) iguais às da v1.',
            'Pílula **"Lido"**: fundo `#E1EDD0`, texto `#2E5314` (cores novas), Figtree 12/700, padding 5/10, `nowrap` — na v1 '
            'era "Quero / ler" em 2 linhas; agora o bloco de texto ganha largura (154,3) e o subtítulo cabe em 1 linha.',
            '"José de Alencar · Papel" (era EPUB). Botão ⋯ 44 com `ic_more_horizontal` 20.',
            FONTES_INICIO,
        ],
        'interacoes': [f'⋯ → {D243B} (como na D-243: menus ⋯).', 'Linha → página do livro, como hoje.'],
        'dados': ['Estado do livro → pílula: "Quero ler" (lavanda), "Lido" (verde), "Novo" (bege); formato no subtítulo, '
                  'incluindo "Papel".'],
        'subfases': ['Pílula "Lido" e formato "Papel"', 'Verificação + relatório'],
    },
    'L01a9_barra': {
        'g': 'T03', 'arquivos': ['features/shell/presentation/floating_nav_bar.dart', 'features/shell/presentation/bottom_fade.dart', 'features/shell/presentation/scanner_fab.dart'],
        'contexto': 'O degradê do fim da página e a barra de navegação (Início ativo) — iguais à v1.',
        'leitura': [
            'Degradê: 150 de altura presos ao fundo, `#F7F0E3` de 0 % a opaco em 55 %, sem toque (`pointer-events: none`).',
            'Barra: `left/right 16 · bottom 30`, 358 × 70, padding 8, raio 28, `#FFFAF1`, borda 1,5, sombra 0/4; 5 colunas '
            '(gap 4); Início ativo com fundo `{{brand}}`, borda 1,5 e raio 20; o FAB do scanner (60, `#FED170`, sombra 0/4) '
            'sobe 30 acima da barra. Rótulos Figtree 11 (ativo 800 → 700; os outros 600 `#5B544B`; Scanner 700).',
            'A barra e o degradê ficam presos ao fundo da tela (o `<main>` rola por baixo).',
            FONTES_INICIO,
        ],
        'interacoes': ['Como hoje (shell da G08).'],
        'dados': ['—'],
        'subfases': ['Degradê e barra (sem mudança visual)', 'Verificação + relatório'],
    },
    'L01b_lendo_agora': {
        'g': 'T04', 'arquivos': ['features/reading_session/presentation/session_mini_bar.dart', 'features/home/presentation/sections/also_reading_section.dart'],
        'contexto': 'A Início com uma sessão de leitura do livro de papel em andamento: o cartão do Brás Cubas em "pausar" com '
                    'o anel coral e a mini-barra do cronômetro acima da barra de navegação. Sem o cartão da revisão.',
        'leitura': [
            'Prancha de 844 (a mesma página da 01, cortada na tela): o que passa de 844 existe no layout mas não aparece no PNG '
            '(ex.: Quincas Borba e O Cortiço no "Para você", que só aqui trocam Memorial de Aires e Casa de Pensão).',
            'Cartão do Brás Cubas: o botão do "play" (mesmo id `alsoReading.card1.play`) mostra **pausar** — `ic_pause` amarelo '
            '16 (o play era 18) e um **aro coral de 3** (`box-shadow 0 0 0 3 #FF552E` → `BoxShadow(spreadRadius: 3)`); '
            'rótulo "Pausar leitura de Brás Cubas".',
            'Mini-barra: `left/right 16 · bottom 130` (30 acima da barra), 358 × 66, padding 0/10/0/12, raio 22, `#1A1714`, '
            'borda 1,5 `#1A1714`, sombra 0/4 `rgba(26,23,20,.35)`, `overflow: hidden`. No topo, progresso de 4 `{{brand}}` em **89 %** (raio 0/4/4/0, '
            'dentro da borda).',
            'Capa 32 × 48 girada −5° (borda 1,2 `#F7F0E3`, raio 2/5/5/2): `il_capa_bras_cubas_asas.svg` (Brás Cubas com asas, '
            '`slice` 0,3167). Textos: "● LENDO · PAPEL" Figtree 10,5/800 (→ 700) ls 1,4 `#B9AE9C` com o ponto coral 7; '
            '"Brás Cubas" Figtree 15/800 (→ 700) `#F7F0E3` com reticências.',
            'Tempo "08:42" Bricolage 24/800 ls −0,6 **tabular** `#F7F0E3`; pausar: círculo 44 `#F7F0E3` com `ic_pause_tinta` 18.',
            'Degradê inferior maior: 240 de altura, opaco em 48 % (na 01: 150 e 55 %) — no app, `features/shell/presentation/bottom_fade.dart` com a altura do estado.',
            FONTES_INICIO,
        ],
        'interacoes': ['Pausar (cartão ou mini-barra) → pausa a sessão; o mesmo botão retoma (T04).',
                       f'Toque na mini-barra → {D243B} até a tela do cronômetro (C15).',
                       'Fim da sessão com a página do papel: D-243 a (mínimo da D-23).'],
        'dados': ['"08:42" = tempo da sessão aberta (sobrevive ao app fechado); 89 % = meta do dia contando a sessão '
                  '((18 + 8,7) ÷ 30); "LENDO · PAPEL" = formato do livro; rótulo da mini-barra "Sessão em andamento: Brás Cubas, '
                  '8 minutos e 42 segundos. Abrir cronômetro".',
                  'Sem o cartão da revisão: a 01b mostra a Início sem a seção (D-247), por isso tudo abaixo sobe 205,15.'],
        'armadilhas': ['A capa da mini-barra é SVG com `<text>` (Figtree 800 4,6 e 700 5,2; Instrument Serif 17,5) em '
                       'escala 0,3167: textos em `AppText` por cima ou o desenho sem textos (catálogo de SVGs).',
                       'O tempo atualiza a cada segundo com números tabulares: largura fixa, sem "pular".'],
        'subfases': ['Estado "pausar" do cartão (ícone + aro coral)', 'Mini-barra (fundo, progresso 89 %, capa girada)',
                     'Textos e tempo tabular', 'Degradê de 240', 'Toques (pausar; mini-barra D-243 b)', 'Verificação + relatório'],
    },
    'L60_grifos_de_hoje': {
        'g': 'T03', 'arquivos': ['features/home/presentation/home_screen.dart'],
        'contexto': 'A Início rolada até o cartão "Seus grifos de hoje": o fim do "Seu dia", o cartão da revisão e o começo '
                    'do "Para você". É um caso de teste de viewport (rolagem 930), não uma tela nova.',
        'leitura': [
            'A prancha é a 01 com `transform: translateY(-930px)` no `<main>`: os 296 elementos são os mesmos e o retângulo de '
            '**layout** (medido sem transform) é igual ao da 01; o que muda é a caixa visual (930 acima). No app: a mesma '
            'Início com `ScrollController` em 930 (as tabelas trazem as caixas visuais, deslocadas pelo transform).',
            'A barra de navegação e o degradê ficam presos ao fundo da tela de 844 (na 01, ao fundo da página de 2650): '
            'no app, fora da área que rola.',
            'Nada muda de desenho em relação às fases L01a4–L01a6 (diferenças abaixo: nenhuma).',
            FONTES_INICIO,
        ],
        'interacoes': ['Rolagem da Início; os toques são os das fases L01a.'],
        'dados': ['Os mesmos da 01 (fixture `t60` = `t01`, D-241).'],
        'subfases': ['Golden da Início rolada 930 (viewport 390 × 844)', 'Barra e degradê fixos durante a rolagem', 'Verificação + relatório'],
    },
    'L61_revisao_grifo': {
        'g': 'T05', 'arquivos': ['features/review/presentation/review_screen.dart', 'features/review/presentation/review_card.dart'],
        'contexto': 'Tela cheia da revisão diária: grifo 2 de 5 do Dom Casmurro, com o baralho, a nota do grifo, a dica de '
                    'deslizar e os botões "Menos vezes", "Mais vezes", nota, compartilhar e "Próximo".',
        'leitura': [
            'Cabeçalho (`left/right 20 · top 58`): fechar 48 (círculo `#FFFAF1`, `ic_close_bold` 20); "Revisão de" Bricolage '
            '17/800 ls −0,3 + "hoje" Instrument Serif itálico 20 (centrado); "2 de 5" Figtree 13/800 tabular, alinhado à '
            'direita numa caixa de 48. Progresso 12 abaixo: 5 segmentos 66 × 10 (gap 5, raio 999, borda 1,3) — feito verde '
            '`#ABCF82`, atual metade `{{brand}}`/metade `#FFFAF1` (degradê com parada dura em 50 %), os demais com hachura '
            '135° `#E9DFCC`/`#FFFAF1` (3/7).',
            'Baralho (`left/right 24 · top 156`, 342 × 452): atrás, um cartão lavanda girado −4° (deslocado 2/6) e um verde '
            'girado +5° (6/10), raio 26, borda 1,5, sombra 3/3; o cartão da frente `#FFFAF1`, sombra 4/4, padding 18/18/16.',
            'Topo do cartão: lombada 12 × 17 `#552CB7` + "Dom Casmurro · pág. 6" Figtree 11,5/800 (reticências); etiqueta '
            '"personagem" (24 de altura, borda 1,2, bolinha rosa 11).',
            'Grifo em **Literata 22/400** `lh 1,55` `#2A2520` (família nova `Literata22`), 4 linhas; fundo rosa '
            '`rgba(255,193,198,.95)` de 14 % a 92 % da linha, raio 3, **por linha** (`box-decoration-break: clone`).',
            'Nota: caixa amarela `#FED170` raio 10, borda 1,5, sombra 2/2, **girada −1,2°**, até 230 de largura; fita creme '
            '38 × 14 `rgba(255,250,241,.85)` com borda 1,2 a −8 do topo; "NOTA" Figtree 10/800 ls 1 `#5B4A1C`; texto 13/700 '
            '`lh 1,35`.',
            'Rodapé do cartão (tracejado 1 `#CFC3AE`): "Você grifou há 17 dias" × "revisto 1 vez", Figtree 12/700 `#8A8073`. '
            'Dica "deslize o cartão para o próximo" (12/700 `#8A8073`, centrada em y 626).',
            'Ações (`bottom 30`): "− Menos vezes" (`#FFFAF1`) e "+ Mais vezes" (`{{brand}}` com sombra 2/2 — destacado), 50 de '
            'altura, Figtree 14/800; depois nota (lápis 20) e compartilhar (`ic_share`) em círculos 52 e "Próximo" preto '
            'Figtree 15,5/800 com a seta amarela 18.',
            FONTES_REVISAO,
        ],
        'interacoes': ['Deslizar o cartão / "Próximo" → próximo grifo (o baralho anda; a barra de progresso também).',
                       '"Menos vezes" / "Mais vezes" → muda a frequência do grifo (regra de agendamento no plano da T05).',
                       'Lápis → editor da nota do leitor (D-23); compartilhar → folha "Compartilhar grifo" (63).',
                       'Fechar → sai da revisão (volta à Início).'],
        'dados': ['"2 de 5" = posição no baralho do dia (5 por dia); "há 17 dias" = hoje − data do grifo; "revisto 1 vez" = '
                  'contagem de revisões; etiqueta e cor do grifo; nota do grifo (tudo da T05, D-244).'],
        'armadilhas': ['"Mais vezes" destacado sem estado semântico (sem `aria-pressed`): é o estado escolhido ou o sugerido? '
                       'Perguntar no plano da T05 antes de decidir a semântica.',
                       'O grifo é um fundo por linha (não um retângulo único): reutilizar o pintor de grifo do leitor (G13).'],
        'subfases': ['Cabeçalho e progresso de 5', 'Baralho (cartões girados atrás)', 'Cartão: topo, grifo Literata 22, nota girada',
                     'Rodapé do cartão e dica', 'Ações', 'Deslizar e animação', 'Verificação + relatório'],
    },
    'L62_revisao_fim': {
        'g': 'T05', 'arquivos': ['features/review/presentation/review_done_screen.dart'],
        'contexto': 'Fim da revisão: "Revisão feita." com os cinco cartões conferidos, a sequência de 7 dias, os números da '
                    'sessão, a nota nova e a próxima revisão; no rodapé, "Voltar a ler · pág. 159".',
        'leitura': [
            'Cabeçalho igual ao da 61 com "5 de 5" e os cinco segmentos verdes.',
            'Arte 290 × 92: cinco cartõezinhos 50 × 66 (raio 9, borda 1,4, sombra 2/2, girados), três traços de 4 (raio 2; cor '
            'do grifo + `#E4DACA`) e o selo verde 18 (`right/bottom −7`, borda 1,2) com o visto 10 (`ic_check_tiny`).',
            '"Revisão" Bricolage **32**/800 `lh 0,98` ls −1 (família nova `Bricolage32`) + "feita." Instrument Serif itálico 40, '
            'centrado. Pílula `{{brand}}` "7 dias seguidos revisando" (brilho amarelo 16 `ic_sparkle_selo` + Figtree 13/800).',
            'Números (3 colunas, gap 8): "2 mais vezes", "1 menos vezes" (`#FFFAF1`) e "1 nota nova" (`#FED170`) — valor '
            'Bricolage 22/800, rótulo Figtree 12/700; raio 16, borda 1,5.',
            'Nota nova ("Sua nota nova"): cartão raio 22, sombra 3/3, padding 14; topo igual ao da 61; grifo em **Literata 15/400** '
            '`lh 1,5` (família `Literata15`, peso novo) com o fundo rosa por linha; nota amarela (sem giro) "NOTA NOVA · HOJE" + '
            'texto 13/700 em 2 linhas.',
            'Próxima revisão: caixa tracejada 1,3 `#8A7F63` raio 18, calendário 18 + "**Amanhã, 8h:** mais 5, com “A vida é '
            'uma ópera” de volta — você pediu mais vezes." Figtree 13/600 `lh 1,4` `#3D3830` (o forte 900 → 800 `#1A1714`).',
            'Rodapé preso ao fundo (`z-index 5`), degradê de transparente a `#F7F0E3` em 30 %: CTA preto 56 com sombra 0/4 '
            '`rgba(26,23,20,.25)`, livro aberto amarelo 19 (`ic_book_read`) + "Voltar a ler · pág. 159" Figtree 15,5/800; '
            '"Mudar horário e quantidade" 12,5/600 `#6F665B` com o link 800 sublinhado (offset 3).',
            FONTES_REVISAO,
        ],
        'interacoes': ['"Voltar a ler · pág. 159" → abre o leitor nessa posição.', f'"Mudar horário e quantidade" → {D243B} (C17).',
                       'Fechar → Início.'],
        'dados': ['Números da sessão (mais/menos vezes, notas novas), sequência de dias revisando, a nota escrita hoje, a próxima '
                  'revisão (hora, quantidade e o grifo que volta) e a página atual do livro (T05, D-244/D-245).'],
        'armadilhas': ['O rodapé com degradê fica por cima do conteúdo (a caixa da próxima revisão termina 16 acima dele).',
                       'O progresso declara `aria-valuenow="6"` com máximo 5 (na 61: 2 de 5) — o arquivo passa do máximo no '
                       'fim; no app o natural é 5 de 5: confirmar no plano da T05 (semântica não se inventa).'],
        'subfases': ['Cabeçalho completo', 'Arte dos cinco cartões conferidos', 'Título, sequência e números', 'Nota nova (Literata 15)',
                     'Próxima revisão', 'Rodapé fixo com degradê', 'Verificação + relatório'],
    },
    'L63_compartilhar_grifo': {
        'g': 'T05', 'arquivos': ['features/review/presentation/share_highlight_sheet.dart', 'features/review/presentation/highlight_image.dart'],
        'contexto': 'Folha "Compartilhar grifo" sobre fundo escuro: a prévia da imagem (rosa), as seis cores, os interruptores '
                    'de nota e @ e as ações Salvar, Stories, Copiar texto e Mais.',
        'leitura': [
            'Fundo `#2B2521` na tela toda (`aria-hidden`; sem desfoque). Folha a partir de y 50 até o fim: `#F7F0E3`, raio '
            '32/32/0/0, só a borda de cima (1,5), padding 12/20/30; alça 40 × 5 `#D9CFBD` raio 3.',
            'Cabeçalho 44: "Compartilhar" Bricolage 20/800 ls −0,4 + "grifo" Instrument Serif itálico 24; fechar 44 '
            '(`ic_close_round`, o do leitor).',
            'Prévia 222 × 394 (centrada, 14 abaixo): `#FFC1C6` (a cor escolhida), raio 18, borda 1,5, sombra 5/5, padding '
            '22/20/18; brilho amarelo 30 (`ic_sparkle_previa`) em `top/right 16`; aspas Instrument Serif itálico 64 `lh 0,6` '
            '(caixa de 30); grifo em **Instrument Serif itálico 25** `lh 1,08` ls −0,2, 5 linhas, com o trecho "atar as duas / '
            'pontas da vida" sobre fundo creme de 55 % a 92 % da linha.',
            'Base da prévia: "Dom Casmurro" Bricolage **14**/800 (família nova `Bricolage14`) e "Machado de Assis · pág. 6" '
            'Figtree 11/700 `#3E2A2D`; rodapé tracejado 1,2: "grifado por / @marinacosta" (Figtree 10/800, 2 linhas) e a marca '
            '"BookNest" (círculo 16 `#1A1714` com o brilho creme 9 + Bricolage 11/800, que usa a família 12).',
            'Cores (`radiogroup` "Cor do fundo"): 6 círculos 34 (gap 12) — creme, amarelo, rosa (marcado: aro duplo '
            '`0 0 0 2,5 #FFFAF1` + `0 0 0 4 #1A1714` = duas `BoxShadow` com `spreadRadius`), verde, lavanda, tinta.',
            'Interruptores (caixa `#FFFAF1`, borda 1,5 `#E2D7C4`, raio 18): "Mostrar minha nota" desligado (trilho `#F1E7D5`, '
            'botão à esquerda) e "Mostrar meu @" ligado (trilho `#1A1714`, botão `{{brand}}` à direita); 52 × 32, botão 23.',
            'Ações (4 colunas): azulejos 52 raio 18 (Salvar em `#FED170`, os outros `#FFFAF1`) com ícones 22 (`ic_download`, '
            '`ic_stories`, `ic_copy_text`, `ic_more_circles`) e rótulos Figtree 12/700.',
            FONTES_REVISAO,
        ],
        'interacoes': ['Cor → muda o fundo da prévia; interruptores → mostram ou escondem a nota e o @ na imagem.',
                       'Salvar → salva a imagem gerada no aparelho; Stories e Mais → compartilhamento do sistema; Copiar texto → '
                       'área de transferência (dependência nova para salvar/compartilhar: a confirmar no plano da T05).',
                       'Fechar ou arrastar a folha para baixo → fecha.'],
        'dados': ['Texto do grifo, trecho destacado, livro, autor, página, @ do perfil, nota (oculta aqui) e a cor escolhida.'],
        'armadilhas': ['A imagem compartilhada é a prévia renderizada (ex.: `RepaintBoundary` → PNG): o mesmo widget, nas '
                       'mesmas medidas, não uma segunda implementação.',
                       'Na medição, o supersample de zoom ≥ 16 desenha uma faixa preta na borda de cima da folha (defeito do '
                       'Skia com borda só em cima + raio); a referência é o zoom 10, correto (relatório T02).'],
        'subfases': ['Fundo e folha', 'Prévia (citação, destaque, rodapé com a marca)', 'Cores (radiogroup)', 'Interruptores',
                     'Ações', 'Geração da imagem', 'Verificação + relatório'],
    },
}

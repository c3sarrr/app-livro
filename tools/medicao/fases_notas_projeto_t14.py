"""T13.12 — notas escritas à mão das fases L da T14: Biblioteca (02), Biblioteca vazia (36) e Detalhes do livro
físico e e-book (17, 17b). A parte medida é gerada por `gen_fases.py` (`CONJUNTO=projeto`); as notas do design ficam em
`docs/design/projeto/NOTAS.md` (detalhes-flutter, estados-flutter, revisao-consistencia, telas-faltando).
"""
from fases_notas_projeto_comum import DADOS, FONTES, VERIFICACAO, sem_destino

G = 'T14'
D243B = ('sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em '
         '`docs/design/estados_sem_design.md`) — confirmar na pergunta da T14 (ROTEIRO §2b)')

NOTAS = {
    'L02_1_cabecalho': {
        'g': G, 'arquivos': ['features/library/presentation/library_screen.dart',
                             'features/library/presentation/sections/library_header.dart'],
        'contexto': 'Topo da Biblioteca (02): o título "Sua biblioteca." numa linha só, o botão redondo de adicionar e, '
                    'embaixo, a busca em pílula com o botão dos filtros. A tela entra no lugar do placeholder da aba '
                    '(`/biblioteca`), que hoje só tem o bloco de importar da G09 (D-87).',
        'leitura': [
            'Cabeçalho 350 × 52 (`min-height`), `space-between`, gap 12: "Sua" Bricolage 36/800 `lh 1` ls −1,2 e '
            '"biblioteca." Instrument Serif itálico 46 ls −0,6 (inline), `white-space: nowrap` — uma linha de 234,9, '
            'baseline 41,64.',
            'Adicionar: círculo 48 `#FFFAF1`, borda 1,5, sem sombra, com o "+" de 22 (traço 2): '
            '`AppIconsBiblioteca.plusCabecalho`.',
            'Busca 20 abaixo: pílula de 52 (`flex 1` → 288 de largura), padding 0/18/0/16, gap 10, com a lupa 20 '
            '(`AppIconsLeitor.search`) e o campo em Figtree 15/500; à direita, o botão dos filtros, círculo 52 com o '
            'ícone de 22 (traço 1,9).',
            'Nenhuma sombra nesta faixa: título, adicionar, busca e filtros são planos (só a borda de 1,5).',
            FONTES,
        ],
        'interacoes': [
            'Adicionar (+) → as formas de pôr um livro na estante (as mesmas da 36: Escanear, Buscar, E-book ou PDF). A '
            'prancha não desenha esse menu: abrir o importar que já existe (D-87) ou seguir a D-243 b (idêntico, sem '
            'ação, teste, `estados_sem_design.md`) é pergunta da T14 (ROTEIRO §2b).',
            'Busca → filtra a estante na hora por título, autor ou nota, no aparelho (sem servidor), dentro da aba de '
            'status escolhida; teclado com "Buscar" e o X de limpar do sistema.',
            'Filtros → ' + D243B + '.',
        ],
        'dados': ['Nada desta fase vem do banco: título, rótulos e o texto de exemplo são textos do app. A busca lê os '
                  'livros da estante (título, autor e notas das anotações).'],
        'armadilhas': [
            '"Título, autor ou nota" é o `placeholder` do `<input>` (não é texto medido): a cor é a padrão do Chromium '
            'e não está declarada na prancha. No app, `hintText` em 15/500 com a cor tirada da referência @3x e a '
            'posição do campo (x 47,5 na seção, altura 49).',
        ],
        'subfases': ['A tela da Biblioteca no lugar do placeholder (rota `/biblioteca`)', 'Cabeçalho: título e Adicionar',
                     'Busca local e o botão dos filtros', VERIFICACAO],
    },
    'L02_2_colecoes': {
        'g': G, 'arquivos': ['features/library/presentation/sections/collections_section.dart',
                             'features/library/presentation/widgets/spine_pile.dart'],
        'contexto': 'Coleções: o título com "Ver todas" e um carrossel de cartões de 200 × 84 (Clássicos brasileiros '
                    '· 14 livros, Clube Capitu · 6 livros, Faculdade · 9 PDFs), cada um com uma pilha de 3 ou 4 '
                    'lombadas em CSS. O 3º cartão sai pela direita: o carrossel corta na borda.',
        'leitura': [
            'Seção 22 abaixo da busca, coluna com gap 8: "Coleções" Bricolage 20/800 ls −0,4 e "Ver todas" Figtree '
            '14/700 com a seta 18 (gap 4), numa linha de 44 de altura (a área de toque).',
            'Carrossel com `margin 0 −20` e `padding 0 20 4`, gap 12, `overflow: hidden` (a prancha não rola): no app, '
            '`ListView` horizontal com o mesmo recuo de 20 e o corte na borda da tela. Cartões 200 × 84, raio 22, '
            '`#FFFAF1`, borda 1,5, sem sombra, padding 0/14/0/12, gap 12.',
            'A pilha (58 × 58, coluna com `justify-content: flex-end`): lombadas de 13 de altura, borda 1,2, raio 3, '
            'larguras em % do quadrado (80, 100, 88, 96…) com recuos à esquerda; as de baixo sobem 1,2 (`margin-top '
            '−1,2`: as bordas se sobrepõem) e a de cima gira (−6°, 5°, −4°). A faixa do meio de cada lombada tem 2 de '
            'altura (top 4,5, raio 2) em `#FED170`, `#FFFAF1` ou `#1A1714` a 0,55; a pilha da Faculdade (PDFs) tem 3 '
            'lombadas lisas, sem faixa.',
            'Texto do cartão: nome Figtree 14/700 `lh 1,2` e contagem 12,5/500 `#5B544B`, gap 3, `min-width: 0`.',
            FONTES,
        ],
        'interacoes': [
            '"Ver todas" → Coleções · ver todas: tela que falta (D-268), da própria T14 — perguntar, buscar 3–5 '
            'referências, desenhar a prancha em `docs/design/novas/` e esperar o "sim" antes do Flutter (ROTEIRO §5).',
            'Cartão → a coleção aberta: também sem prancha; entra na mesma pergunta da T14 (a tela das coleções).',
            'Carrossel: arrasto horizontal (na prancha, parado no começo).',
        ],
        'dados': [
            'Coleções = as listas de livros da pessoa (o nome e quantos livros; "PDFs" quando são todos PDF). O app ainda '
            'não tem coleção no banco local: a tabela nova e a regra das cores da pilha (as do cartão, como na prancha, '
            'ou as das capas) são perguntas da T14; sem o dado, a seção segue a D-247 (fixture nos testes, some com '
            'dados reais até existir).',
            DADOS,
        ],
        'armadilhas': [
            'A lombada de cima gira no centro (`transform`): a tabela traz o retângulo sem o giro; o desenho girado é o '
            'da referência @3x.',
        ],
        'subfases': ['Título e Ver todas', 'Cartão da coleção com a pilha de lombadas', 'Carrossel cortado na borda',
                     VERIFICACAO],
    },
    'L02_3_status_e_ordem': {
        'g': G, 'arquivos': ['features/library/presentation/sections/status_tabs.dart',
                             'features/library/presentation/sections/sort_view_bar.dart'],
        'contexto': 'As abas de status (Todos 86 · Lendo 4 · Quero ler 26 · Lidos 52 · Favoritos 12 · Abandonados 4), '
                    'presas no topo enquanto a estante rola, e a linha de ordenar ("Ordenar: Recentes") com o seletor '
                    'grade/lista.',
        'leitura': [
            'Abas: fila de 42 de altura, gap 8, com `margin 18 −20 0` e `padding 2 20 4`, `overflow: hidden`. A '
            'marcada: fundo `{{brand}}`, borda 1,5 preta, sombra dura 2/2, padding 0/8/0/16, gap 8, "Todos" Figtree '
            '14/800 e o contador em pílula (mín. 28 × 26, `#FFFAF1`, borda 1,2, 12/800).',
            'As outras: `#FFFAF1` com borda 1,5 **`#E2D7C4`** (bege, não preta), sem sombra, padding 0/14/0/16, gap 7, '
            'rótulo 14/600 e o número solto 12/700 `#6F665B`. A partir de "Lidos" as abas saem do quadro (a fila corta).',
            'Ordenar, 10 abaixo: botão de 44 de altura com `margin-left −10` (o ícone fica a 10 da margem), ícone 18 + '
            '"Ordenar:" 14/500 `#5B544B` + "Recentes" 14/700 + a seta 16 (traço 2,2), gap 6.',
            'Grade/lista: pílula de 44, padding 3, gap 2, borda 1,5; a opção marcada é um círculo 44 de largura '
            '(altura da pílula menos o padding) em `{{brand}}`, borda 1,5, com a grade de quadrados preenchidos '
            '`#FFFAF1`; a lista fica sem fundo nem borda.',
            FONTES,
        ],
        'interacoes': [
            'Aba → filtra a estante pelo status; a contagem de cada uma vem do banco.',
            'As abas ficam presas no topo quando a estante rola (o comentário da prancha: "pinned while the shelf '
            'scrolls"): `SliverPersistentHeader` fixo, e a fila rola de lado (a 360 já corta na 4ª aba).',
            'Ordenar → o menu das ordens não tem prancha: ' + D243B + '.',
            'Grade/lista → a vista em lista não tem prancha: ' + D243B + '.',
        ],
        'dados': [
            'Contagens do banco local: Todos = Lendo + Quero ler + Lidos + Abandonados (4 + 26 + 52 + 4 = 86, a revisão '
            'de consistência do design); Favoritos conta à parte (o livro favorito também tem um status).',
            'O `ShelfStatus` já tem os quatro status (`abandoned` incluído); "favorito" ainda não existe no '
            '`user_books` — o campo novo é pergunta da T14 (sem ele, a aba segue a D-247).',
            DADOS,
        ],
        'armadilhas': [
            'Marcar uma aba muda borda (preta × bege), sombra, padding (16/8 × 16/14), gap (8 × 7), peso (800 × 600) e '
            'o contador (pílula × número solto) — não é só a cor: um widget com os dois estados, e o golden das duas '
            'pontas (a marcada e uma desmarcada).',
        ],
        'subfases': ['Abas de status com as contagens', 'Abas presas ao rolar', 'Ordenar e grade/lista', VERIFICACAO],
    },
    'L02_4_estante': {
        'g': G, 'arquivos': ['features/library/presentation/sections/shelf_section.dart',
                             'features/library/presentation/widgets/shelf_book.dart',
                             'features/library/presentation/covers/library_covers.dart'],
        'contexto': 'A estante: 4 prateleiras de 3 livros (grade de 3 colunas, gap 14, 30 entre as prateleiras), cada '
                    'uma sobre uma tábua `{{shelf}}`. Embaixo da capa: título, autor e, conforme o livro, a barra de '
                    'progresso, a etiqueta de status (Novo, Lido, Quero ler) ou as notas. A 4ª prateleira continua por '
                    'baixo da navegação.',
        'leitura': [
            'Grade `repeat(3, minmax(0,1fr))`, gap 14 → colunas de 107,33. Capa 107,33 × 160, raio 4/9/9/4, borda 1,5, '
            '`overflow: hidden`, com a lombada de 7 em preto translúcido (a opacidade muda por livro: .10 a .22). A '
            'tábua: `left/right −5`, top 158,5, 11 de altura, raio 6, borda 1,5, sombra dura 0/3.',
            'Capas em CSS (formas, não SVG): círculo e anel (Dom Casmurro), arco (Mrs. Dalloway, Senhora), anéis '
            'concêntricos (O Alienista), traços (Quincas Borba), porta (O Cortiço), meia-lua (Iracema), barra girada '
            '24° pelo canto (Crime e Castigo), oval partido (A Metamorfose). Título Instrument Serif 19–24 `lh 0,9–0,95` '
            'e autor 6,5/700 ls 0,14em, em `left 15 · right 8 · bottom 12`.',
            'Lendo (1ª prateleira): a fita coral 16 × 30 (`fitaMarcador`) sai 8 acima da capa, `right 12`; embaixo, a '
            'barra 40 × 7 (hachura 135° `#E4DACA`/`#FFFAF1`, borda 1,2, preenchimento `#FF552E`) e "62%" 12/800, gap 6.',
            'Info 26 abaixo da capa (coluna, gap 3): título 14/700 `lh 1,2` e autor 12,5/500 `#5B544B` em uma linha '
            'com reticências. Etiquetas 11,5/700 em pílula (padding 4/9): Novo `#EFE7D7`/`#4A4238`; Lido '
            '`#E1EDD0`/`#2E5314` com o visto 12 (padding 4/9/4/7, gap 4); Quero ler `#ECE7FA`/`#3B2D86`. PDF: a '
            'etiqueta 9/800 ls 0,04em dentro da capa (`left 12 · bottom 9`, raio 6, borda 1,2).',
            'A apostila (Teoria Literária) é outra capa: fundo `#FFFDF8`, "UNIDADE 2" 6,5/800, "Teoria / Literária" '
            '13/800, seis linhas de texto falsas (3 de altura, `#DCD2C1`) com uma grifada (7 de altura, `#FED170`, '
            '`margin −2 0`) e, no lugar da etiqueta, o marca-texto 14 e "18 notas" 12/800.',
            FONTES,
        ],
        'interacoes': [
            'Livro → os Detalhes (17 no papel, 17b no e-book e no PDF), nesta etapa (`AppRoutes.livro`).',
            'Segurar o livro (as opções) → ' + D243B + '.',
        ],
        'dados': [
            'Cada livro: título curto (D-270), autor, formato (papel, e-book, PDF), status e, no Lendo, a porcentagem — '
            'e-book pela posição salva; papel pela última página anotada ÷ páginas (Orgulho e Preconceito: 344 de 424 = '
            '81 %). Sem página no papel, a barra não tem dado: o que mostrar é pergunta da T14.',
            'Capas: as da fixture como widgets (como as da Início, `features/home/presentation/covers/`); com dados '
            'reais, a capa do catálogo ou a foto da pessoa (D-79).',
            DADOS,
        ],
        'armadilhas': [
            'Cada capa tem formas em px dentro de uma caixa de largura fluida: as presas por `left`/`right` esticam com a '
            'coluna e as de `width` fixa não — a 360 o arco e a porta de O Cortiço invadem o título (abaixo). No app, '
            'as formas acompanham a largura da coluna como o CSS (não um desenho fixo de 107,33).',
            'A prancha ainda mostra Senhora ("Novo") e Frankenstein ("Quero ler"), que a revisão de consistência do '
            'design (`NOTAS.md`, itens 2 e 3) diz ter trocado por O Guarani e Crime e Castigo: a fixture da tela segue a '
            'prancha (D-34); a coerência com o mundo de referência (D-88) é pergunta da T14.',
            'A 4ª prateleira passa por baixo do degradê e da navegação (os livros 10–12 aparecem sem a info): no app a '
            'estante rola, e o fim da lista para acima da navegação (o recuo do shell, `shell_insets.dart`).',
        ],
        'subfases': ['Prateleira: a grade de 3 e a tábua', 'As 12 capas da fixture como widgets',
                     'Info: título, autor, progresso, etiquetas e notas', 'Rolagem e o fim por baixo da navegação',
                     VERIFICACAO],
    },
    'L02_5_barra': {
        'g': G, 'arquivos': ['features/shell/presentation/floating_nav_bar.dart',
                             'features/shell/presentation/bottom_fade.dart'],
        'contexto': 'O degradê de 170 que deixa a estante passar por baixo da navegação e a barra de 5 itens com a '
                    'Biblioteca marcada — a navegação da Início (F11, G05), agora com a aba Biblioteca ativa.',
        'leitura': [
            'Degradê: 170 de altura, de `rgba(247,240,227,0)` a `#F7F0E3` em 60 % (de cima para baixo), '
            '`pointer-events: none` — não bloqueia o toque nos livros.',
            'Navegação: `left/right 16 · bottom 30`, 70 de altura, padding 8, raio 28, `#FFFAF1`, borda 1,5, sombra dura '
            '0/4; grade de 5 colunas, gap 4. Itens: ícone 22 + rótulo 11/600 `#5B544B`, gap 3, raio 20.',
            'A ativa (Biblioteca): fundo `{{brand}}`, borda 1,5, o ícone das lombadas preenchido de `#FFFAF1` e o rótulo '
            '11/800 ls −0,2. O Scanner: círculo 60 `#FED170` (borda 1,5, sombra 0/4) 30 acima do item, ícone 28, '
            'rótulo 11/700 com `padding-bottom 2`.',
            FONTES,
        ],
        'interacoes': ['Navegação como hoje (G05, F11): Início, Clubes e Perfil trocam de aba; o Scanner abre em tela '
                       'cheia (`/scanner`); a aba ativa segue o comportamento atual das abas.'],
        'dados': ['A aba ativa sai da rota (`/biblioteca`); nada mais é dado.'],
        'armadilhas': [
            'É o componente da Início (`FloatingNavBar`): só muda a aba ativa — a geometria é a mesma (a referência '
            'confere a 36 × 02: a mesma navegação presa ao fundo, −796).',
            'O degradê da 02 (170, de cima para baixo, até 60 %) não é o da 36 (130, de baixo para cima, até 55 %): '
            '`BottomFade` com os parâmetros de cada tela.',
        ],
        'subfases': ['Degradê da Biblioteca', 'Navegação com a Biblioteca ativa', VERIFICACAO],
    },
    'L36_biblioteca_vazia': {
        'g': G, 'arquivos': ['features/library/presentation/empty_library.dart',
                             'features/library/presentation/library_screen.dart'],
        'contexto': 'Biblioteca vazia (36): sem nenhum livro, o título grande, a prateleira tracejada com o livro rosa '
                    '"o seu aqui?", a frase "A estante está esperando o primeiro livro." e as ações — Escanear '
                    '(amarelo, a principal), Buscar e E-book ou PDF. A navegação continua igual.',
        'leitura': [
            'Título em 2 linhas (não é o da 02): "Sua" Bricolage 42/800 `lh 0,98` ls −1,4, quebra, e "biblioteca." '
            'Instrument Serif itálico 50 ls −0,6 — a composição do título da Início.',
            'Desenho 300 × 190, centrado, 26 abaixo (`role=img`, "Uma prateleira vazia esperando livros"): 4 lugares '
            'tracejados (borda 1,8 `dashed #A69C8F`, raio 4/8/8/4, alturas 120, 104, 128 e 98, o 4º girado −10°), o '
            'livro rosa 52 × 74 (`#FFC1C6`, sombra 3/3, girado −8° pela base esquerda) com a estrela 36 `#FED170`, a '
            'pílula "o seu aqui?" 11,5/800 girada 6° e a tábua de 16 (`left/right −6`, sombra 0/4).',
            'Frase: Bricolage 26/800 `lh 1,02` ls −0,6, centrada, e "o primeiro livro." Instrument Serif itálico 30; o '
            'texto 14,5/600 `lh 1,45` `#5B544B`, `max-width 300`, 8 abaixo.',
            'Ações (coluna, gap 10, 18 abaixo): "Escanear meu primeiro livro" com 54 de altura, `#FED170`, sombra 3/3, '
            'ícone 20 + 15,5/800; embaixo, duas pílulas de 50 lado a lado (`1fr 1fr`, gap 10), `#FFFAF1`, sem sombra, '
            'ícone 18 + 14/800: Buscar e E-book ou PDF.',
            'Degradê de 130, de baixo para cima (`#F7F0E3` até 55 %), e a navegação igual à da 02 (Biblioteca ativa).',
            FONTES,
        ],
        'interacoes': [
            'Escanear meu primeiro livro → o Scanner (`/scanner`); a tela nova do Scanner é da T15.',
            sem_destino(G, 'Buscar → a Busca (28), da T15'),
            'E-book ou PDF → o importar que já existe (o seletor de arquivos da G09, D-21 e D-87).',
            'Navegação: como na 02.',
        ],
        'dados': ['A tela aparece quando a estante não tem nenhum livro (nenhum `user_book`) e some sozinha quando o '
                  'primeiro entra.', DADOS],
        'armadilhas': [
            'O tracejado dos lugares é `border: dashed` do CSS (o navegador escolhe o traço pela borda de 1,8): no app, '
            'um pintor de borda tracejada com o padrão medido na referência @3x — não é um SVG (os tracejados do '
            'catálogo, D-285, são outros).',
            'O livro rosa gira pela base esquerda (`transform-origin: bottom left`) e a pílula pelo centro: a tabela '
            'traz as caixas sem o giro.',
        ],
        'subfases': ['Estado vazio no lugar da estante', 'Prateleira tracejada e o livro "o seu aqui?"', 'Frase e ações',
                     'Degradê e navegação', VERIFICACAO],
    },
    'L17_1_capa': {
        'g': G, 'arquivos': ['features/library/presentation/details/book_details_screen.dart',
                             'features/library/presentation/details/details_cover.dart',
                             'features/library/presentation/details/sunburst_halo.dart'],
        'contexto': 'Detalhes do livro físico (17, Brás Cubas): o sol retrô verde atrás, a barra do topo (voltar, '
                    'compartilhar, mais) e a capa girada −3° sobre a tábua amarela, com a etiqueta "PAPEL", dois '
                    'brilhos e o selo de trocar a capa. É a tela que abre ao tocar num livro da Biblioteca.',
        'leitura': [
            'Sol: círculo 330 centrado em x 195, top 58, `repeating-conic-gradient` de 9° em 9° entre `{{halo}}` (verde '
            '`#ABCF82` na 17, lavanda `#B6ACE4` na 17b) e `#FFFAF1`, borda 1,5 — 20 raios de cada cor a partir do topo, '
            'no sentido horário: `ConicRingPainter`.',
            'Barra do topo de 48: voltar à esquerda; compartilhar e "mais" à direita (gap 8). Círculos 48 `#FFFAF1`, '
            'borda 1,5, sem sombra; ícones 20 (traço 2,2 no voltar, 2 nos outros).',
            'Capa 176 × 264 (top 22 na área de 330, `margin-left −88`), raio 5/14/14/5, borda 1,5, sombra dura 6/6, '
            'girada −3° no centro: o desenho do Brás Cubas com asas (o mesmo da Início, `coverBrasCubasWings`) e a '
            'lombada de 10 `rgba(0,0,0,.2)`.',
            'Etiqueta "PAPEL": pílula de 30, `#FED170`, borda 1,5, sombra 2/2, ícone 14 + 11,5/900 (→ 800) ls 1,1, '
            'girada 9°, em `left 50% + 52 · top 10`. Brilhos: creme 26 (`left 22 · top 200`) e preto 16 (`right 24 · '
            'top 86`). Trocar a capa: círculo 42, sombra 2/2, ícone 20, em `left 50% + 64 · top 250`, por cima da capa '
            '(`z-index 1`).',
            'Tábua: `left/right −6`, top 292, 16 de altura, raio 4, `{{shelf}}`, borda 1,5, sombra 0/4.',
            FONTES,
        ],
        'interacoes': [
            'Voltar → a tela anterior (a Biblioteca, a Início ou a Busca).',
            'Compartilhar → ' + D243B + ' (ou a folha do sistema, se a T14 decidir).',
            '"Mais opções" (⋯) → ' + D243B + '.',
            'Trocar a capa → tela que falta (D-268), da própria T14 (ROTEIRO §5). Pela nota do design: fotografar a '
            'capa da edição que a pessoa tem, escolher da galeria ou voltar para a capa original; a foto fica só para ela.',
        ],
        'dados': [
            'Capa: a do catálogo ou a foto da pessoa (D-79); a etiqueta diz o formato do livro (PAPEL, E-BOOK…).',
            'O sol e o cartão do meio seguem o formato: verde no papel (17), lavanda no e-book (17b) — no app, pelos '
            'tokens, não fixos no widget.',
            DADOS,
        ],
        'armadilhas': [
            'O desenho da capa tem `<text>` e `slice` (ver o mapa de widgets): `AppSvg` sem os textos em `BoxFit.cover` '
            'e os textos em `AppText` por cima, nas posições do viewBox × a escala — como o herói da Início.',
            'O sol vem antes no HTML e fica por baixo da barra e da capa; rola com a tela (é conteúdo, não fundo fixo).',
        ],
        'subfases': ['A tela dos Detalhes na rota do livro (`AppRoutes.livro`)', 'Sol retrô (ConicRingPainter)',
                     'Barra do topo', 'Capa girada na tábua, etiqueta, brilhos e trocar a capa', VERIFICACAO],
    },
    'L17_2_titulo_e_status': {
        'g': G, 'arquivos': ['features/library/presentation/details/details_title.dart',
                             'features/library/presentation/details/status_selector.dart'],
        'contexto': 'O título do livro em duas fontes ("Memórias Póstumas / de Brás Cubas"), a linha do autor '
                    '(Machado de Assis · 1881 e a pílula "Livro físico · 208 páginas") e o seletor de status Quero ler '
                    '/ Lendo / Lido.',
        'leitura': [
            'Título 2 abaixo da área da capa: Bricolage 34/800 `lh 0,98` ls −1,1, quebra, e Instrument Serif itálico 44 '
            'ls −0,5 — 2 linhas, 350 de largura, 76,44 de altura.',
            'Linha do autor (flex-wrap, gap 8/10, 10 abaixo): "Machado de Assis" 15/700, o ponto 4 × 4 `#1A1714`, '
            '"1881" 15/600 `#5B544B` e a pílula de 28 (borda 1,5 `#E2D7C4`, padding 0/10/0/8, ícone 14 `#3E3832` + '
            '12,5/700 `#3E3832`).',
            'Status 18 abaixo: pílula de 48 (padding 3, borda 1,5, `#FFFAF1`), 3 colunas iguais, gap 2; a marcada em '
            '`{{brand}}` com borda 1,5 e 14/800, as outras sem fundo, 14/600 `#5B544B`.',
            FONTES,
        ],
        'interacoes': [
            'Status → muda na hora (Quero ler, Lendo, Lido) e salva no banco local; "Lido" marca o fim da leitura. O que '
            'mais muda com o "Lido" (resenha, conquistas) é das etapas delas.',
            'Autor e ano: sem toque (a prancha não os marca como link).',
        ],
        'dados': ['Título, autor, ano e páginas do catálogo (ou do cadastro à mão, 28d); formato e status do '
                  '`user_book`.', DADOS],
        'armadilhas': [
            'Os Detalhes mostram o título completo ("Memórias Póstumas de Brás Cubas"); o curto ("Brás Cubas") é o das '
            'listas e da Início — o campo do título curto chega nesta etapa (D-270), editável e preenchido pelo catálogo.',
            'O status "Abandonado" existe na Biblioteca (aba) mas não no seletor de 3: como marcar e desmarcar o '
            'abandonado é pergunta da T14.',
        ],
        'subfases': ['Título em duas fontes', 'Autor, ano e formato (flex-wrap)', 'Seletor de status ligado ao banco',
                     VERIFICACAO],
    },
    'L17_3_sessao': {
        'g': G, 'arquivos': ['features/library/presentation/details/reading_session_card.dart'],
        'contexto': 'Livro físico: o cartão amarelo da sessão de leitura — o anel com os minutos de hoje (18 de 30), o '
                    'total no livro (3 h 40 min em 6 sessões), o botão preto "Iniciar leitura" e a linha tracejada '
                    '"Parou na pág. 74 · opcional" com "Atualizar". No papel o app conta minutos, não páginas (nota do '
                    'design).',
        'leitura': [
            'Cartão 18 abaixo do status: padding 16, raio 24, `#FED170`, borda 1,5, sombra dura 4/4.',
            'Linha de cima (gap 14): o anel SVG 58 (viewBox 46: disco `#FFFAF1` r 18 com borda 1,5; trilho r 13 '
            '`#EAD9A6` de traço 5; o arco preto `dasharray 49 81,7`, girado −90°: 60 % de 30 min); ao lado, "18" '
            'Bricolage 22/800 `lh 1,05` ls −0,5 + "de 30 min hoje" Figtree 15/700 `#3E3832` e, 4 abaixo, "Neste '
            'livro: 3 h 40 min em 6 sessões" 13/600 `#3E3832`.',
            '"Iniciar leitura", 14 abaixo: 54 de altura, largura toda, `#1A1714`, o cronômetro 21 em `#FED170` + '
            '16/800 `#F7F0E3`, gap 10.',
            'Página, 10 abaixo: padding 10/12, raio 16, `rgba(255,250,241,.7)`, borda 1,5 `dashed '
            'rgba(26,23,20,.45)`; "Parou na" 13/600 `#3E3832` + "pág. 74" 800 `#1A1714` + "· opcional" `#6F665B`; '
            '"Atualizar" em pílula de 32, `#FFFAF1`, borda 1,5, lápis 14 + 12,5/800.',
            FONTES,
        ],
        'interacoes': [
            'Iniciar leitura → o cronômetro do livro de papel que já existe (T04: a mini-barra e a folha mínima); a tela '
            'do cronômetro (18) chega na T18.',
            'Atualizar → a página onde parou: a prancha não desenha o campo. A página é dado do produto (D-243 a: o '
            'mínimo da D-23, como a página da folha mínima da T04) — confirmar na pergunta da T14.',
        ],
        'dados': [
            '"18 de 30 min hoje" = os minutos de hoje (papel e e-book) e a meta do dia; "Neste livro" = a soma das '
            'sessões deste livro e quantas são (3 h 40 min em 6, a revisão de consistência); "pág. 74" = a última página '
            'anotada (opcional).',
            'Livro sem página anotada: a linha não tem prancha para esse caso — o texto é pergunta da T14.',
            DADOS,
        ],
        'armadilhas': [
            'O arco é o `dasharray` (49 de 81,7 = 2π · 13) a partir do topo: no app, um pintor de arco com o ângulo '
            'minutos ÷ meta e a ponta redonda — não o `stroke-dasharray` do flutter_svg (D-285).',
            'A borda da página é `dashed` com cor translúcida: pintor de tracejado com o padrão da referência @3x.',
            'O "pág. 74" em 800 dentro do texto em 600: a caixa é do tamanho do texto (sobra 0, T13.4) — o `AppText.rich` '
            'com os três pesos, sem largura fixa.',
        ],
        'subfases': ['Cartão com o anel da meta de hoje', 'Iniciar leitura ligado ao cronômetro da T04',
                     'Página opcional e Atualizar', VERIFICACAO],
    },
    'L17_4_clima': {
        'g': G, 'arquivos': ['features/library/presentation/details/book_mood_section.dart'],
        'contexto': 'O clima do livro votado pelos leitores (estilo StoryGraph, nota do design): os humores mais '
                    'votados em pílulas coloridas com a porcentagem, o ritmo (Lento / Médio / Rápido) e a barra '
                    'personagens × trama (81 % × 19 %).',
        'leitura': [
            '"Clima do livro" Bricolage 20/800 e "1,2 mil leitores" 12,5/700 `#6F665B` na mesma linha, pela baseline '
            '(`space-between`), 30 abaixo do cartão anterior.',
            'Cartão 12 abaixo: padding 16, raio 22, `#FFFAF1`, borda 1,5, sem sombra. Humores (flex-wrap, gap 8): '
            'pílulas de 32, padding 0/12, borda 1,5, 13,5/800 + a porcentagem 12/700 `#3E3832` (gap 6) — irônico '
            '`#FFC1C6`, reflexivo `#FED170`, engraçado `#ABCF82`, sombrio `#FFFAF1`.',
            '"RITMO" 11/800 ls 1,2 `#6F665B`, 16 abaixo; a régua de 3 (padding 3, borda 1,5 `#E2D7C4`, gap 2): o mais '
            'votado em `{{brand}}` com borda 1,5 e "Médio 64%" (13/800 + 11,5/700); os outros sem fundo, 13/600 '
            '`#6F665B`, com borda transparente de 1,5 (a mesma altura de 34).',
            'Personagens × trama, 16 abaixo: os rótulos 11/800 ls 1,2 nas pontas e, 6 abaixo, a barra de 16 (borda 1,5, '
            'hachura 135° `#E9DFCC`/`#FFFAF1` 3/7) com o rosa até 81 % e a ponta ondulada de 10 × 15.',
            FONTES,
        ],
        'interacoes': ['Nenhum toque na prancha (é leitura). Votar no clima fica nas resenhas (T20).'],
        'dados': [
            'Votos dos leitores no catálogo (humor, ritmo, personagens × trama) e quantos votaram. A fonte desses votos '
            'ainda não existe no app: D-247 — com dados reais a seção some até haver a fonte, e a fixture continua nos '
            'testes (a fonte é pergunta da T14).',
            DADOS,
        ],
        'armadilhas': [
            'A ponta ondulada é um SVG com `preserveAspectRatio="none"` e `vector-effect: non-scaling-stroke`: no app, a '
            'borda ondulada das barras do catálogo de SVGs, esticada na altura, com o traço sem escalar.',
            'A cor de cada humor é a do clima em todo o app (a nota do design: "a mesma cor de cada clima em todo o '
            'app") — uma tabela só de climas e cores, a mesma da Busca (28) e das resenhas.',
            'Com outros humores a fileira muda (flex-wrap): a 17b já quebra de outro jeito (misterioso, reflexivo / '
            'romântico, tenso).',
        ],
        'subfases': ['Título e leitores', 'Pílulas de humor (flex-wrap)', 'Ritmo e personagens × trama', VERIFICACAO],
    },
    'L17_5_sinopse': {
        'g': G, 'arquivos': ['features/library/presentation/details/synopsis_section.dart'],
        'contexto': 'A sinopse em Literata com "Ler mais" no fim do parágrafo e a ficha em 4 casas (páginas, publicado, '
                    'formato, ISBN) entre duas linhas pretas, com divisórias tracejadas.',
        'leitura': [
            '"Sinopse" Bricolage 20/800 ls −0,4, 30 abaixo do clima; o texto 10 abaixo em Literata 15,5/400 `lh 1,6` '
            '`#2B2621`, com "Ler mais" no fim, inline, em Figtree 14/800 sublinhado (offset 3).',
            'Ficha 14 abaixo: grade de 2 colunas, borda de cima e de baixo 1,5 preta; casas com padding 10/0; a da '
            'direita com a borda esquerda 1,5 `dashed #CFC3AE` e recuo 14; a 2ª fileira com a borda de cima tracejada. '
            'Rótulo 10,5/800 ls 1,1 `#6F665B` e valor 14,5/800 `tnum`, 3 abaixo, `nowrap`.',
            'Valores: 208 · 1881 · Brochura · 978-65-5921-104-3 (na 17b: 256 · 1899 · E-book · DIREITOS Domínio '
            'público).',
            FONTES,
        ],
        'interacoes': [
            'Ler mais → o texto inteiro no lugar. O estado aberto não tem prancha (o parágrafo cresce e o "Ler mais" '
            'some, ou vira "Ler menos") — confirmar na T14.',
            'Ficha: sem toque.',
        ],
        'dados': ['Sinopse, páginas, ano, formato da edição e ISBN do catálogo (ou do cadastro à mão); no e-book de '
                  'domínio público, a 4ª casa diz DIREITOS · Domínio público.', DADOS],
        'armadilhas': [
            '"Ler mais" é um link dentro do parágrafo (outra família e peso no meio da Literata): `AppText.rich` com o '
            '`TextSpan` em Figtree e o toque num recognizer; a quebra das linhas depende das duas fontes juntas.',
            'O sublinhado tem `text-underline-offset: 3px`, que o `TextDecoration` do Flutter não tem: desenhar a linha '
            'à parte e conferir posição e espessura na referência @3x.',
            'As divisórias tracejadas encontram as bordas pretas nos cantos: pintor de tracejado, não `Border` do Flutter.',
        ],
        'subfases': ['Sinopse com Ler mais', 'Ficha de 4 casas', VERIFICACAO],
    },
    'L17_6_grifos_e_clube': {
        'g': G, 'arquivos': ['features/library/presentation/details/details_highlights_section.dart',
                             'features/library/presentation/details/club_poll_card.dart'],
        'contexto': 'Livro físico: "Seus grifos" (3 trechos) com o último grifo — fotografado, em Instrument Serif com o '
                    'marca-texto amarelo e "Fotografado da pág. 9" —, o botão tracejado "Fotografar um trecho" e o '
                    'cartão rosa do clube: o livro lidera a votação do próximo livro.',
        'leitura': [
            '"Seus grifos" Bricolage 20/800 e "3 trechos" 12,5/700 `#6F665B` (baseline), 30 abaixo da sinopse.',
            'Grifo: padding 16/16/14, raio 20, `#FFFAF1`, borda 1,5, sem sombra; citação Instrument Serif itálico 21 '
            '`lh 1,35` com o marca-texto em cada linha (`linear-gradient`: transparente até 52 %, `#FED170` de 52 % a '
            '92 %, `box-decoration-break: clone`); a legenda 10 abaixo, câmera 14 + "Fotografado da pág. 9" 12,5/700 '
            '`#6F665B`.',
            '"Fotografar um trecho", 10 abaixo: 48 de altura, sem fundo, borda 1,5 `dashed #1A1714`, câmera 18 + 14,5/800.',
            'Clube, 16 abaixo: padding 14, raio 20, `#FFC1C6`, sombra dura 3/3, gap 12 — o círculo 44 com "1º" '
            'Bricolage 18/800; "LEITORAS DE CAPITU" 11/800 ls 1,1 `#5B2A33`, "Lidera a votação do próximo livro do '
            'clube" 14,5/800 `lh 1,3` e "5 votos · fecha terça" 12,5/600 `#3E3832`; a seta à direita (traço 2,4).',
            FONTES,
        ],
        'interacoes': [
            'Grifo → os grifos do livro (a tela 25, `AppRoutes.destaques`).',
            'Fotografar um trecho → câmera e leitura de texto no aparelho (OCR offline, nota do design); a tela da '
            'captura não tem prancha: ' + D243B + '.',
            sem_destino(G, 'Cartão do clube → a Enquete (47–49), da T11'),
        ],
        'dados': [
            '"3 trechos" = os grifos deste livro; o mostrado é o mais recente, com a origem (fotografado) e a página.',
            'O cartão aparece quando um clube da pessoa tem este livro numa enquete aberta. O app ainda não tem enquete '
            '(é da T11): D-247 — com dados reais o cartão some até lá, e a fixture continua nos testes.',
            DADOS,
        ],
        'armadilhas': [
            'O marca-texto cobre de 52 % a 92 % da altura de cada linha (não da caixa): no app, o marca-texto por linha '
            'dos grifos (`marked_quote.dart`), conferindo as alturas na referência @3x.',
            'A seta do clube encolhe no flex (20 → 16,43, ver o mapa de widgets): decidir na T14 se o app repete.',
        ],
        'subfases': ['Seus grifos com o último trecho', 'Fotografar um trecho', 'Cartão da enquete do clube',
                     VERIFICACAO],
    },
    'L17b_1_progresso': {
        'g': G, 'arquivos': ['features/library/presentation/details/ebook_progress_card.dart',
                             'features/library/presentation/details/book_details_screen.dart'],
        'contexto': 'Detalhes do e-book (17b, Dom Casmurro): as seções da 17 (sol lavanda, capa, título, status, clima, '
                    'sinopse) e, no lugar do cartão da sessão, o cartão lavanda do progresso — onde parou (pág. 159 de '
                    '256), 62 % em Instrument Serif, a barra, o tempo para terminar, "Continuar lendo" e os grifos (12).',
        'leitura': [
            'Cartão 18 abaixo do status: padding 16, raio 24, `{{brand}}`, borda 1,5, sombra 4/4. Em cima '
            '(`align-items: flex-end`, `space-between`): "ONDE VOCÊ PAROU" 11/800 ls 1,2 `#2C2452` e, 4 abaixo, '
            '"Pág. 159" Bricolage 22/800 + "de 256" 15/700 `#2C2452`; à direita, "62%" Instrument Serif itálico 44 '
            '`lh 0,9`.',
            'Barra, 12 abaixo: 16 de altura, borda 1,5, hachura 135° `#CFC6EE`/`#FFFAF1`, o preto até 62 % com a ponta '
            'ondulada (o desenho do clima, em preto).',
            '"≈ 2 h 10 min para terminar · salvo sozinho" 13/600 `#2C2452`, 8 abaixo; os botões 14 abaixo (gap 10): '
            '"Continuar lendo" (`flex 1`, 54, preto, livro aberto 20 `#F7F0E3` + 16/800) e o círculo 54 dos grifos '
            'com o marca-texto 22 e o contador "12" (pílula 22, `#FED170`, 11/800, `top/right −4`).',
            'O que muda da 17 (a tabela "Diferenças"): o sol lavanda, a capa roxa, o título maior (40 e 52, "Dom / '
            'Casmurro": tudo desce 13,72), "E-BOOK" na etiqueta, o ano e o formato, os climas (misterioso, reflexivo, '
            'romântico, tenso) e a sinopse com uma linha a menos (a ficha sobe 41,94).',
            FONTES,
        ],
        'interacoes': [
            'Continuar lendo → o leitor na posição salva (`AppRoutes.leitor`).',
            'Grifos (12) → os grifos do livro (a tela 25, `AppRoutes.destaques`).',
            'As outras seções como na 17.',
        ],
        'dados': [
            '"Pág. 159 de 256" e "62%" = a posição salva do leitor (a página de referência e o total, G10); "≈ 2 h 10 '
            'min" = o tempo que falta (o cálculo da Início); "12" = as anotações do livro (D-241). O progresso salva '
            'sozinho: nada para atualizar à mão.',
            'A 17b serve ao e-book e ao PDF; o sol e o cartão em lavanda vêm de `{{halo}}` e `{{brand}}`.',
            DADOS,
        ],
        'armadilhas': [
            'O "≈" não existe na Figtree: o Chromium o desenha com a Inter SemiBold do sistema (R8, declarado no índice). '
            'No app o Flutter cai na fonte de reserva do aparelho — trocar por "~" (como a Início: "~2h 10min") ou '
            'embutir o glifo é pergunta da T14 (a largura da linha muda).',
        ],
        'subfases': ['Detalhes do e-book: as seções da 17 com as diferenças', 'Cartão do progresso',
                     'Continuar lendo e grifos ligados', VERIFICACAO],
    },
    'L17b_2_grifos_e_clube': {
        'g': G, 'arquivos': ['features/library/presentation/details/details_highlights_section.dart',
                             'features/library/presentation/details/club_meeting_card.dart'],
        'contexto': 'E-book: "Seus grifos" com "Ver os 12", um grifo do leitor ("…olhos de cigana oblíqua e '
                    'dissimulada.", pág. 121, em amarelo) — sem o botão de fotografar — e o cartão-ingresso do próximo '
                    'encontro do clube (QUI 24 SET · 20h).',
        'leitura': [
            '"Seus grifos" Bricolage 20/800 e "Ver os 12" 13/800 sublinhado (offset 3), `nowrap`, na mesma baseline.',
            'Grifo igual ao da 17 (padding 16/16/14, raio 20), a citação em 1 linha; a legenda sem ícone: "pág. 121 · '
            'grifado em amarelo" 12,5/700 `#6F665B`.',
            'Encontro, 16 abaixo: `align-items: stretch`, raio 20, `#FFFAF1`, sombra 3/3, `overflow: hidden`. A data à '
            'esquerda: 84 de largura, `#FFC1C6`, borda direita 1,5 `dashed`, "QUI" 11/800 ls 1, "24" Bricolage 28/800 '
            '`lh 1` e "SET · 20h" 11/800. À direita (padding 12/14): "LEITORAS DE CAPITU" 11/800 ls 1,1 `#6F665B`, '
            '"Encontro até o cap. 50" 14,5/800 e, 4 abaixo, "Grupo 54% · você 62%" 12,5/600 `#3E3832`.',
            FONTES,
        ],
        'interacoes': [
            'Ver os 12 → os grifos do livro (a tela 25).',
            'Grifo → o trecho no leitor (`AppRoutes.leitor` com `goTo`, G19).',
            sem_destino(G, 'Cartão do encontro → o Encontro do clube (70), da T10'),
        ],
        'dados': [
            'O grifo mostrado é o mais recente do livro, com a página e a cor; "12" = as anotações do livro.',
            'O encontro aparece quando um clube da pessoa lê este livro e tem encontro marcado: o dado já existe '
            '(`ClubCard.nextMeeting`, os clubes da G); "Grupo 54% · você 62%" = o progresso médio do clube e o seu.',
            DADOS,
        ],
        'armadilhas': [
            'A cor do marca-texto é a do grifo ("grifado em amarelo"): no app, a cor real da anotação (as 4 do leitor), '
            'e a legenda diz a cor.',
            'A borda tracejada entre a data e o texto é vertical: pintor de tracejado.',
        ],
        'subfases': ['Seus grifos com Ver os 12', 'Grifo do leitor', 'Cartão do encontro do clube', VERIFICACAO],
    },
}

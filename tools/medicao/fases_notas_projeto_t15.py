"""T13.12 — notas escritas à mão das fases L da T15: Scanner (03, 39, 40, 41, 42, 69, 69b), Busca (28, 28b, 28c) e
Adicionar à mão (28d). A parte medida é gerada por `gen_fases.py` (`CONJUNTO=projeto`); as notas do design ficam em
`docs/design/projeto/NOTAS.md` (scanner-flutter, digitar-flutter, busca-flutter). O Scanner já existe desde a G07 (o
provisório, `features/scanner/`, com os estados da D-76): a T15 troca o desenho e mantém a lógica de leitura.
"""
from fases_notas_projeto_comum import DADOS, FONTES, VERIFICACAO, sem_destino

G = 'T15'
D243B = ('sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em '
         '`docs/design/estados_sem_design.md`) — confirmar na pergunta da T15 (ROTEIRO §2b)')
FOLHA = ('A folha (a mesma nas 03, 39, 40, 41 e 42): `left/right/bottom 10`, padding 10/18/22, raio 30/30/44/44, '
         '`#FFFAF1`, borda 1,5, sombra dura 0/4; a alça 40 × 5 `#D9CFBD` (raio 3) centrada no topo. É um `Align` '
         'no fundo da tela (não um `showModalBottomSheet`), para a câmera continuar visível atrás (nota do design).')
SALVAR_COMO = ('"Salvar como" 12/700 `#5B544B` e, 8 abaixo, a régua de 48 (padding 3, borda 1,5, 3 colunas, gap 2): o '
               'marcado em `{{brand}}` com borda 1,5 e 14/800; os outros sem fundo, 14/600 `#5B544B`.')
ACOES = ('Ações 16 abaixo (gap 10): o botão preto de 54 (`flex 1`, ícone 20 `#F7F0E3` + 16/700) e o círculo 54 de '
         'escanear de novo (a seta circular 22); por último, 14 abaixo, a linha centrada 13,5/500 `#5B544B` com o link '
         '800 sublinhado (offset 3).')

NOTAS = {
    'L03_1_camera': {
        'g': G, 'arquivos': ['features/scanner/presentation/scanner_screen.dart',
                             'features/scanner/presentation/scanner_camera.dart',
                             'features/scanner/presentation/scanner_frame.dart'],
        'contexto': 'Scanner com o livro encontrado (03): a câmera parada no quadro em que o código foi lido (o verso '
                    'coral do Brás Cubas com a etiqueta do ISBN), o escuro fora da moldura, o contorno amarelo no '
                    'código lido com o selo de visto, os cantos da mira e o chip "Código lido".',
        'leitura': [
            'A câmera da prancha é cena: fundo `radial-gradient(120% 75% at 50% 32%, #4A413A, #2B2521 55%, #191512)`, o '
            'verso do livro 430 × 560 girado −5° com degradê coral e sombra `0 30 60 rgba(0,0,0,.45)`, o texto '
            'desfocado (`filter: blur`) e a etiqueta do ISBN 196 × 104. No app tudo isso é a imagem da câmera ao vivo '
            '(o mapa de widgets: fica só como referência da fixture).',
            'Escuro fora da moldura: a caixa 280 × 160 em `left 55 · top 181`, raio 22, com `box-shadow: 0 0 0 1200px '
            'rgba(20,17,15,.58)` — no app, `ClipPath` invertido (a moldura arredondada fora) com a camada a 58 % '
            '(a nota do design fala em 45 % e desfoque de 6 fora da moldura: a prancha não desfoca — pergunta da T15).',
            'Código lido: o contorno 206 × 114 em `left 92 · top 205`, raio 10, borda 3 `{{reticle}}` com o filete '
            'preto de 1,5 por fora e por dentro (duas sombras), girado −5° como o código; o selo 28 `{{reticle}}` com o '
            'visto 15 (traço 3,2) em `top/right −14`.',
            'Cantos: SVG 290 × 170 em `left 50 · top 176` (`miraScanner`): os 4 cantos de raio 22, traço preto 10 e, por '
            'cima, traço `{{reticle}}` 5,5, pontas redondas.',
            'Chip "Código lido" centrado em top 126: 36 de altura, padding 0/14/0/6, gap 8, `{{reticle}}`, borda 1,5, '
            'sombra 2/2, 14/800, com o círculo preto 24 e o visto 13 `#FED170` (`role=status`: texto e ícone, nunca só a '
            'cor).',
            FONTES,
        ],
        'interacoes': [
            'Ao aceitar o código (2 quadros seguidos com o mesmo EAN-13 978/979): pausar a câmera, vibração leve, cantos e '
            'contorno amarelos, o chip e a folha sobem; `SemanticsService.announce("Código lido")` (regras da nota do '
            'design).',
            'Outros códigos (preço, código interno) são ignorados; repetidos por 3 s mostram a dica "Esse parece ser o '
            'código de preço" (nota do design; a dica não tem prancha — o texto segue a nota).',
        ],
        'dados': ['O ISBN lido e o livro do catálogo (`isbn_resolver.dart`, as camadas da G07); a cena da câmera é só da '
                  'fixture.', DADOS],
        'armadilhas': [
            'O contorno e o selo giram −5° (como o código na cena): no app o contorno segue o retângulo do código '
            'detectado pelo leitor (a posição e o ângulo reais), não um giro fixo.',
            '`{{reticle}}` é cor de estado: amarelo (lido) nas 03, 40 e 42; outra cor na mira (39). Os cantos usam a '
            'troca de cor do `AppSvg` (cores dinâmicas no mapa).',
        ],
        'subfases': ['Câmera ao vivo e o escuro fora da moldura', 'Cantos da mira (cores por estado)',
                     'Contorno do código lido e o selo', 'Chip de estado anunciado', VERIFICACAO],
    },
    'L03_2_controles': {
        'g': G, 'arquivos': ['features/scanner/presentation/scanner_top_bar.dart'],
        'contexto': 'A barra do topo do Scanner (igual em todos os estados): fechar, o seletor "Código | Digitar" (como '
                    'adicionar) e a lanterna. Na 69 o "Digitar" fica marcado e a lanterna dá lugar ao "?".',
        'leitura': [
            'Barra em `left/right 20 · top 58`, 48 de altura, `space-between`. Fechar e lanterna: círculos 48 `#FFFAF1`, '
            'borda 1,5, sem sombra; X 20 (traço 2,2) e o raio 20 (traço 1,9).',
            'Seletor: pílula de 48 (padding 3, gap 2, borda 1,5, `#FFFAF1`); cada opção com padding 0/14/0/12, gap 7, '
            'ícone 18 + rótulo 14. A marcada em `{{brand}}` com borda 1,5 e 800; a outra sem fundo, 600.',
            'O ícone de "Código" são 6 barras com traços de 2, 1,2 e 2,4 (o desenho de um código de barras); o de '
            '"Digitar", um teclado.',
            FONTES,
        ],
        'interacoes': [
            'Fechar → sai do Scanner (volta para onde abriu).',
            'Código | Digitar → troca de aba: Digitar pausa a câmera e abre o campo do ISBN (69); voltar para Código tira '
            'o foco do campo e religa a câmera; o que foi digitado fica guardado até fechar o Scanner (nota do design).',
            'Lanterna → liga e desliga (`Semantics(toggled)`, 48 × 48); sem permissão de câmera fica apagada (41).',
        ],
        'dados': ['Nada vem do banco: o estado do seletor e da lanterna é da tela.'],
        'armadilhas': [
            'A largura de cada opção depende do peso do rótulo (800 marcado × 600): trocar a aba muda as duas larguras '
            '(a 69 mostra a troca na tabela "Diferenças") — não fixar a largura.',
        ],
        'subfases': ['Fechar e lanterna', 'Seletor Código | Digitar', VERIFICACAO],
    },
    'L03_3_folha': {
        'g': G, 'arquivos': ['features/scanner/presentation/sheets/scanner_sheet.dart',
                             'features/scanner/presentation/sheets/found_sheet.dart'],
        'contexto': 'A folha do livro encontrado: o chip verde "Livro encontrado" com o ISBN, o livro (capa, título, '
                    'autor, formato e a coleção sugerida), "Salvar como" (Quero ler marcado), "Adicionar à biblioteca", '
                    'escanear outro e "Não é este livro? Buscar pelo título".',
        'leitura': [
            FOLHA,
            'Topo, 12 abaixo da alça (`space-between`): o chip de 26 `#E1EDD0`/`#2E5314`, padding 0/10/0/8, visto 13 + '
            '12/800; à direita "ISBN 978-65-5921-104-3" 12/600 `#5B544B` `tnum`.',
            'Livro, 16 abaixo (gap 14): capa 84 × 126 (raio 3/8/8/3, borda 1,5, sombra 3/3, coral com a lombada 6 e a '
            'meia-lua preta, título Instrument Serif 14,5 `lh 0,95` e autor 5,5/700 ls 0,14em); ao lado, o título '
            'Bricolage 19/800 `lh 1,1` ls −0,4, o autor 14/600 e "Livro físico · 208 páginas" 12,5/500, gap 3; a seta '
            '20 à direita.',
            'A coleção, 8 abaixo: pílula de 30 (padding 0/6/0/9, gap 7, borda 1,5), a mini pilha de 3 lombadas (5 de '
            'altura, borda 1, raio 1,5, sobrepostas 1), "Clássicos brasileiros" 12,5/700 `nowrap` e o visto em círculo '
            '18 `{{brand}}` (rótulo "Incluído").',
            SALVAR_COMO + ' A 18 abaixo do livro.',
            ACOES,
            FONTES,
        ],
        'interacoes': [
            'Livro → os Detalhes (17), feitos na T14.',
            'Coleção → o livro entra na coleção sugerida (o visto); trocar ou tirar a coleção não tem prancha: '
            + D243B + '.',
            'Salvar como → o status com que o livro entra (Quero ler por padrão aqui; "Lendo" na 40).',
            'Adicionar à biblioteca → grava o livro com o status e a coleção; depois, o que a tela mostra (a 03 não '
            'desenha o "adicionado") segue o estado `ScanAdded` de hoje — confirmar na T15.',
            'Escanear outro livro → volta para a mira (39).',
            'Buscar pelo título → a Busca (28), com o campo vazio.',
        ],
        'dados': ['Título, autor, formato, páginas, ISBN e capa do catálogo; a coleção sugerida pelo gênero ou pelas '
                  'coleções da pessoa (a regra é pergunta da T15; as coleções nascem na T14).', DADOS],
        'armadilhas': [
            'A capa da folha é a capa da fixture em CSS (84 × 126; na 42, 72 × 108 com o título em 12,5): com dados reais, '
            'a capa do catálogo (D-79).',
            'A 360 a pílula da coleção passa 11,59 do bloco de texto (abaixo): `nowrap` com o nome inteiro — decidir na '
            'T15 se encolhe com reticências.',
        ],
        'subfases': ['A folha comum do Scanner (posição, alça, raio)', 'Topo: chip e ISBN', 'Livro e coleção',
                     'Salvar como e as ações', VERIFICACAO],
    },
    'L39_mirando': {
        'g': G, 'arquivos': ['features/scanner/presentation/scan_line.dart',
                             'features/scanner/presentation/sheets/aiming_sheet.dart'],
        'contexto': 'Scanner mirando (39): a câmera viva, a linha coral que varre a moldura, o chip "Procurando o '
                    'código…" e a folha baixa que ensina com um desenho — "Vire o livro de costas." —, as duas dicas e '
                    '"Código apagado? Digitar o ISBN".',
        'leitura': [
            'Linha: `left/right 70 · top 246`, 3 de altura, raio 2, `#FF552E`, com o filete preto de 1,5 e o brilho '
            '`0 0 18 4 rgba(255,85,46,.45)` (duas sombras).',
            FOLHA,
            'Desenho 86 × 104 (`livroCodigoBarras`): o livro lavanda de costas com a sombra dura, as linhas de texto a '
            '35 %, a etiqueta com as barras e o retângulo tracejado coral em volta do código; ao lado (gap 14), "Vire o '
            'livro" Bricolage 20/800 `lh 1,05` + " de costas." Instrument Serif itálico 23 e o texto 13,5/600 `lh 1,4` '
            '`#5B544B`, 6 abaixo.',
            'Dicas, 14 abaixo, depois da linha tracejada (borda de cima 1,5 `dashed #CFC3AE`, padding-top 12): pílulas de '
            '30 `#F7F0E3`, borda 1,3, padding 0/11, 12,5/700 (flex-wrap, gap 8). Embaixo, "Código apagado? Digitar o '
            'ISBN".',
            'O que muda da 03 (tabela "Diferenças"): a etiqueta da câmera desfocada (`blur 1.4`) e o chip "Procurando o '
            'código…" em `#FFFAF1` (200,7 de largura, ícone 14).',
            FONTES,
        ],
        'interacoes': [
            'Linha: `AnimationController.repeat(reverse: true)`, 1,6 s ida e volta de cima a baixo da moldura, sem '
            'piscar; parada no meio com `disableAnimations` (nota do design).',
            'Dicas: aparecem só depois de alguns segundos sem leitura (4 s "Pouca luz? Ligue a lanterna", 8 s "Afaste um '
            'palmo"); tocar na primeira liga a lanterna; os timers são cancelados a cada leitura e no dispose.',
            'Digitar o ISBN → a aba Digitar (69).',
        ],
        'dados': ['Nada vem do banco; as dicas dependem do tempo sem leitura.'],
        'armadilhas': [
            'O tracejado coral do desenho tem `stroke-dasharray`: o registro de tracejados (`svgDashes`, D-285) lê o '
            'arquivo sem esse traço e o pinta por cima como o Chromium (ver o mapa de widgets).',
            'As dicas da prancha aparecem as duas juntas (o estado depois de 8 s); antes de 4 s a folha não tem a faixa '
            'das dicas — a altura da folha muda; o estado sem dicas não tem prancha (a folha encolhe; confirmar na T15).',
        ],
        'subfases': ['Linha que varre (com o modo sem animação)', 'Folha de dicas com o desenho',
                     'Dicas por tempo e o atalho Digitar', VERIFICACAO],
    },
    'L40_nao_encontrado': {
        'g': G, 'arquivos': ['features/scanner/presentation/sheets/not_found_sheet.dart'],
        'contexto': 'Livro não encontrado (40): o código foi lido, mas o ISBN não está na base. A folha não trata como '
                    'erro: o chip rosa "Fora da nossa base" com o ISBN, a capa em branco com o "?", "Esse ainda não está '
                    'aqui.", "Salvar como" (Lendo) e "Adicionar à mão".',
        'leitura': [
            FOLHA,
            'Topo (flex-wrap, gap 6/8): o chip de 26 `#FFE9E4` **com borda** 1,2 (o "Livro encontrado" da 03 não tem), '
            'o ícone de alerta 13 (traço 2,6) e "Fora da nossa base" 12/800 `nowrap`; o ISBN 12/600 `tnum`.',
            'Desenho 84 × 110 (`livroInterrogacao`, `overflow: visible`): o livro verde com sombra dura, o quadro '
            'tracejado com o "?" em Instrument Serif itálico 26 e a estrela 0,9; ao lado, "Esse ainda não" Bricolage '
            '21/800 ls −0,5 + " está aqui." Instrument Serif itálico 24 e o texto 13,5/600 `lh 1,4`.',
            SALVAR_COMO + ' Aqui "Lendo" vem marcado (a nota do design), 16 abaixo do desenho.',
            ACOES + ' O botão diz "Adicionar à mão" e é um link (a prancha usa `<a>`).',
            'O que muda da 03 na câmera: o verso verde (outro livro), a citação com uma linha a menos e o autor "EDIÇÃO '
            'INDEPENDENTE".',
            FONTES,
        ],
        'interacoes': [
            'Adicionar à mão → a tela 28d com o ISBN e o status preenchidos (a capa pode ser fotografada lá).',
            'Escanear de novo → a mira (39).',
            'Buscar pelo título → a Busca (28), para o caso de ter lido o código errado (o de uma etiqueta de preço).',
            '`SemanticsService.announce("Livro não encontrado")` ao mostrar a folha.',
        ],
        'dados': [
            'O ISBN lido; o resto é texto do app.',
            'O app de hoje, sem o livro, oferece digitar os dados e enviar à comunidade (`ScanNotFound` com as '
            'sugestões); o design diz que o livro à mão fica privado e que o app oferece juntar quando o ISBN aparecer '
            'na base — qual regra vale é pergunta da T15.',
            DADOS,
        ],
        'armadilhas': [
            'O chip tem borda e o da 03 não: o ícone anda 1,2 (a borda de 1,2) — não é o mesmo widget com outra cor.',
            'O desenho tem `<text>` (o "?") e um tracejado: `AppSvg` sem o texto, o "?" em `AppText` e o tracejado '
            'pelo registro `svgDashes` (o mapa de widgets).',
        ],
        'subfases': ['Folha "fora da nossa base" (chip com borda, desenho)', 'Salvar como em Lendo',
                     'Adicionar à mão com o ISBN preenchido', VERIFICACAO],
    },
    'L41_sem_permissao': {
        'g': G, 'arquivos': ['features/scanner/presentation/sheets/permission_sheet.dart'],
        'contexto': 'Sem permissão de câmera (41): o fundo escuro listrado no lugar da câmera, os cantos e a lanterna '
                    'apagados (0,35) e a folha que explica sem culpa — "A câmera está desligada para nós." —, o caminho '
                    'nos ajustes num chip tracejado, "Abrir os ajustes do celular" e "Digitar o ISBN".',
        'leitura': [
            'Fundo: `repeating-linear-gradient(135deg, #221D19 0 10px, #1E1A17 10px 20px)` na tela inteira (listras de '
            '10); os cantos e a lanterna da 03 com opacidade 0,35.',
            FOLHA,
            'Desenho 150 × 120 centrado, 16 abaixo da alça: a câmera amarela com a lente lavanda e o cadeado rosa '
            '(sombras duras deslocadas 3–4), e a estrela creme.',
            'Título centrado 14 abaixo: "A câmera está" Bricolage 25/800 `lh 1,02` ls −0,6 + " desligada para nós." '
            'Instrument Serif itálico 29; o texto 14/600 `lh 1,45`, margem 8/6.',
            'O caminho, 14 abaixo: padding 10/12, raio 16, `#F7F0E3`, borda 1,3 `dashed`, a engrenagem 18 + "Ajustes do '
            'celular › BookNest › **Câmera**" 13/700 (800 no último).',
            'Botões: "Abrir os ajustes do celular" 54, `#FED170`, sombra 3/3, 16/800, sem ícone; "Digitar o ISBN" 50, '
            '`#FFFAF1`, sem sombra, teclado 18 + 15/800, 10 abaixo.',
            FONTES,
        ],
        'interacoes': [
            'Abrir os ajustes do celular → os ajustes do app no sistema; ao voltar (`resumed`), checar de novo e religar a '
            'câmera sozinho (nota do design).',
            'Digitar o ISBN → a aba Digitar (69), que não depende da câmera.',
            'A permissão é pedida na primeira abertura, com a explicação antes do pedido do sistema; negada → esta tela; '
            'negada de vez → o botão abre os ajustes.',
        ],
        'dados': ['O caminho mostrado depende do sistema (Android e iPhone dizem diferente): o texto por plataforma é '
                  'pergunta da T15; a prancha mostra o do iPhone.'],
        'armadilhas': [
            'O chip do caminho tem borda tracejada (`dashed` 1,3) e o "›" vem da Figtree: conferir o glifo e o '
            'espaçamento na referência @3x.',
            'A 430 o texto fica num fio de navalha (sobra 0,84, abaixo).',
        ],
        'subfases': ['Fundo listrado e controles apagados', 'Folha da permissão', 'Ajustes do sistema e a volta',
                     VERIFICACAO],
    },
    'L42_na_estante': {
        'g': G, 'arquivos': ['features/scanner/presentation/sheets/on_shelf_sheet.dart'],
        'contexto': 'Já está na estante (42): o mesmo Brás Cubas, semanas depois. Em vez de duplicar, o chip lavanda "Já '
                    'está na sua estante", o livro com a barra de progresso (pág. 74 de 208 · 36 %), a meta do dia (18 de '
                    '30 min) e "Iniciar leitura" — escanear vira o atalho mais rápido para uma sessão.',
        'leitura': [
            FOLHA,
            'Topo (flex-wrap): o chip de 26 `{{brand}}` com borda 1,2, as lombadas 13 e "Já está na sua estante" 12/800; '
            'o ISBN à direita.',
            'Livro, 14 abaixo: capa 72 × 108 (a mesma da 03, menor: título 12,5), título Bricolage 18/800, "Machado de '
            'Assis · físico" 13/600; a barra 9 de altura (`flex 1`, borda 1,3, hachura `#E4DACA`/`#FFFAF1`, coral até '
            '36 % com a borda direita 1,3) + "36%" 12,5/800 `tnum`; "Lendo · **pág. 74** de 208" 12,5/600.',
            'Meta, 14 abaixo: padding 10/12, raio 16, `#F7F0E3`, borda 1,3 `dashed #CFC3AE`, o anel 34 (r 12, traço 6, '
            '60 %) e "**18 de 30 min hoje.** Faltam 12 para a meta do dia; a sequência de 12 dias já está garantida." '
            '13/600 `lh 1,35`.',
            ACOES + ' O botão preto é "Iniciar leitura" com o cronômetro 21 amarelo.',
            FONTES,
        ],
        'interacoes': [
            'Livro → os Detalhes (17).',
            'Iniciar leitura → o cronômetro neste livro (o de hoje, da T04; a tela 18 chega na T18).',
            'Escanear outro → a mira (39).',
            'Adicionar mesmo assim → uma segunda edição do livro; a confirmação não tem prancha: ' + D243B + '.',
            'Variações da nota do design (sem prancha, mesmo layout): livro Lido → o botão "Ler de novo"; em Quero ler → '
            '"Começar a ler", que muda o status para Lendo.',
        ],
        'dados': [
            'O livro da estante (D-77: o ISBN já está numa linha ativa — `ScanOnShelf`, nada vai para a rede), a página e '
            'o total (36 %), os minutos de hoje, a meta e a sequência.',
            '"a sequência de 12 dias já está garantida": o dia conta com 5 min (a regra das estatísticas); o texto muda '
            'quando ainda não está garantida — o outro texto é pergunta da T15.',
            DADOS,
        ],
        'armadilhas': [
            'O ícone de "Iniciar leitura" tem 21 (o de "Adicionar" tem 20) e desce 0,5 a mais (T13.5): não reaproveitar o '
            'botão da 03 com outro ícone sem conferir.',
            'O anel é `stroke-dasharray` do progresso: `CustomPainter` com o valor real (o mapa de widgets).',
        ],
        'subfases': ['Folha "já está na estante"', 'Livro com o progresso', 'Meta do dia', 'Iniciar leitura e as '
                     'variações (Lido, Quero ler)', VERIFICACAO],
    },
    'L69_1_titulo_e_etiqueta': {
        'g': G, 'arquivos': ['features/scanner/presentation/isbn_typing/isbn_typing_view.dart',
                             'features/scanner/presentation/isbn_typing/isbn_sticker.dart',
                             'features/scanner/presentation/isbn_typing/barcode_painter.dart'],
        'contexto': 'Digitar o ISBN (69): a aba Digitar com a câmera pausada (fundo escuro com pontinhos), "Digite o '
                    'ISBN do verso." e a etiqueta de código de barras que se imprime enquanto a pessoa digita — o caso '
                    'de um livro de sebo com o ISBN-10 (85-08-06294-X), 9 de 10 dígitos, faltando o final.',
        'leitura': [
            'Fundo: pontos `radial-gradient(rgba(255,250,241,.09) 1px, transparent 1.4px)` a cada 18 sobre o escuro do '
            'Scanner.',
            'Título em `left/right 24 · top 128`: "Digite o ISBN" Bricolage 27/800 `lh 1,05` ls −0,6 `#FFFAF1` + " do '
            'verso." Instrument Serif itálico 31 `#FED170`; o texto 13,5/600 `lh 1,4` `#CFC6B8`, 6 abaixo.',
            'Etiqueta em `left/right 22 · top 226`, girada −1,5°: padding 16/16/14, raio 22, `#FFFAF1`, borda 1,5, sombra '
            '5/5; duas fitas 74 × 22 (listras de 7/3 amarelas e rosa, bordas tracejadas a 25 %) giradas −24° e 21°, por '
            'cima (`z-index 2`).',
            'Dentro: o chip "ISBN-10 · edição antiga" (26, `#F7F0E3`, borda 1,2, 12/800) e "9 de 10" 13/800 `tnum`; o '
            'número Bricolage 32/800 `lh 1` ls 0,5 `tnum` com os hífens `#A79C8B` e a casa do dígito que falta (30 × 38, '
            'raio 9, borda 1,6 `dashed`, `#FFF3CF`, o cursor coral 2,5 × 24); "Falta o dígito final: um número ou X." '
            '13/600 com o X em destaque (`#FED170`, borda 1, raio 5).',
            'Barras, 14 abaixo da linha tracejada: SVG 267 × 74 — o 978 em roxo `#552CB7` (o app completa), os dígitos '
            'digitados em preto, a casa que falta hachurada e tracejada com o "?" `#8B8173`, e "978 · o app completa '
            'sozinho" 11/800 roxo.',
            'Embaixo, 16 abaixo da etiqueta: "Completou, a gente confere e já busca." 13/600 e "Livro sem ISBN? **Buscar '
            'pelo título**" 13,5/500, ambos `#CFC6B8` (o link `#FFFAF1`).',
            FONTES,
        ],
        'interacoes': [
            'Um `TextField` invisível (opacidade 0) com foco próprio; a etiqueta é desenhada do controller (teclado, '
            'colar, desfazer e leitor de tela funcionam sozinhos). Cada dígito novo imprime as suas barras (7 módulos, '
            '120 ms, `TweenAnimationBuilder`); os hífens entram pela tabela oficial de faixas (nota do design).',
            'Começa com 978/979 → ISBN-13 (conta até 13); outro começo → ISBN-10 (conta até 10, X só na 10ª). Ao '
            'completar, confere o dígito: certo → cantos amarelos, vibração, "Buscando…" e a folha da 03, 40 ou 42; '
            'errado → a 69b. Antes de completar, nunca mostra erro.',
            '"?" (no lugar da lanterna) → a folha curta de onde fica o ISBN: ' + D243B + '.',
            'Buscar pelo título → a Busca (28).',
        ],
        'dados': ['Os dígitos digitados (guardados até fechar o Scanner); o ISBN-10 vira 978 + 9 dígitos + novo dígito, '
                  'e os dois ficam salvos no livro (nota do design). A conferência usa `features/catalog/domain/isbn.dart`.',
                  DADOS],
        'armadilhas': [
            'As barras da prancha são o estado da fixture: no app, `CustomPainter` com os 95 módulos do EAN-13 e quantos '
            'já foram impressos, e os dígitos em `AppText` (o mapa de widgets).',
            'As fitas passam da etiqueta e, a 360, a da direita sai do quadro (abaixo): `clipBehavior: Clip.none` e '
            'decidir na T15 se acompanham a largura.',
            'A semântica da etiqueta é um texto só ("ISBN digitado: 85-08-06294, 9 de 10 dígitos. Falta o dígito '
            'final."), anunciado a cada mudança — não os pedaços desenhados.',
        ],
        'subfases': ['Fundo e título da aba Digitar', 'Etiqueta: chip, contagem e número com hífens',
                     'Barras impressas por dígito (CustomPainter)', 'Conferência e busca ao completar', VERIFICACAO],
    },
    'L69_2_teclado': {
        'g': G, 'arquivos': ['features/scanner/presentation/isbn_typing/isbn_keys_bar.dart'],
        'contexto': 'A barra de teclas do app (X "dígito final", Colar e esconder o teclado) presa em cima do teclado '
                    'numérico do sistema — o teclado do sistema aparece na prancha só como contexto.',
        'leitura': [
            'Barra em top 538 (logo acima do teclado), 56 de altura, padding 0/12, gap 8, `#FFFAF1`, borda de cima 1,5, '
            'raio 20/20/0/0.',
            'X: 42 de altura, padding 0/14/0/12, raio 13, `#FED170`, borda 1,5, sombra 2/2, "X" Bricolage 22/800 + '
            '"dígito / final" 11,5/700 `lh 1,1` em 2 linhas.',
            'Colar: pílula de 42, padding 0/14/0/11, `#FFFAF1`, borda 1,5, prancheta 18 + 14/800; um espaço flexível; '
            'esconder: círculo 44 `#F7F0E3` com o teclado e a seta 21.',
            'O teclado (top 594 até o fim): é o do sistema, desenhado na prancha com a fonte do sistema — o app não o '
            'desenha.',
            FONTES,
        ],
        'interacoes': [
            'X → acrescenta "X" sem tirar o foco; amarelo só quando faz sentido (ISBN-10 com 9 dígitos); fora disso '
            'apagado, e o leitor de tela diz "só para ISBN de 10 dígitos" (nota do design).',
            'Colar → aparece quando há algo copiado; aceita qualquer formato e guarda só os dígitos e o X.',
            'Esconder teclado → tira o foco; a barra desce junto (`bottom: viewInsets`).',
        ],
        'dados': ['O conteúdo da área de transferência (só para mostrar o Colar).'],
        'armadilhas': [
            'O teclado da prancha é o do iPhone desenhado com a fonte do sistema (as reservas R8 abaixo): fica fora dos '
            'testes de fidelidade — o golden recorta até a barra (y < 594) ou usa o teclado real do aparelho; '
            'confirmar na T15.',
            'A barra fica presa ao teclado: a posição 538 é a da prancha com o teclado de 250; no app, '
            '`bottom: MediaQuery.viewInsetsOf(context).bottom`.',
        ],
        'subfases': ['Barra de teclas presa ao teclado', 'X condicional, Colar e esconder', VERIFICACAO],
    },
    'L69b_nao_confere': {
        'g': G, 'arquivos': ['features/scanner/presentation/isbn_typing/isbn_sticker.dart',
                             'features/scanner/presentation/isbn_typing/isbn_keys_bar.dart'],
        'contexto': 'ISBN não confere (69b): a etiqueta treme uma vez e fica girada −3°, com as marcas rosa do tremor, o X '
                    'digitado na casa rosa, o aviso "Esse número não confere." e, embaixo, "O erro mais comum: dois '
                    'vizinhos trocados." O X da barra apaga e Colar vira "Apagar tudo".',
        'leitura': [
            'A mesma etiqueta da 69 girada −3° (não −1,5°), com duas marcas de tremor (SVG 14 × 60, traço rosa 2,4) dos '
            'dois lados, `left −18 · top 96` e `right −18 · top 120`.',
            '"10 de 10"; o número 85-08-06924 com o X numa casa de 32 × 40 (raio 9, borda 1,6 contínua, `#FFC1C6`, '
            'sombra 2/2).',
            'Aviso, 10 abaixo (`role=alert`): padding 6/10, raio 12, `#FFE9E4`, borda 1,2, ícone 17 + "Esse número não '
            'confere." 13,5/800 `nowrap`.',
            'Barras: a hachura rosa (`#FFE1E4`/`#FFC1C6`) na casa final, o contorno tracejado preto e o "!" `#C2364A` no '
            'lugar do "?"; o 9 e o 2 trocados nos dígitos.',
            'Na barra: o X em `#F7F0E3` a 0,4 sem sombra; "Apagar tudo" no lugar de "Colar".',
            FONTES,
        ],
        'interacoes': [
            'Tremor uma vez (nenhum com "reduzir movimento"); `SemanticsService.announce("Esse número não confere")`.',
            'Nada é buscado e nada se apaga sozinho; corrigir qualquer dígito confere de novo.',
            'Apagar tudo → limpa o campo e volta para a 69.',
        ],
        'dados': ['A conta do dígito: ISBN-10 com pesos de 10 a 2, módulo 11, X = 10; ISBN-13 com pesos 1 e 3, módulo 10 '
                  '(nota do design).'],
        'armadilhas': [
            'As marcas do tremor e as fitas passam da etiqueta (0,6 acima, no catálogo): `Clip.none`.',
            'O aviso faz a etiqueta crescer: o texto de baixo começa 8 abaixo (não 16) — a coluna inteira muda.',
        ],
        'subfases': ['Etiqueta no estado "não confere" (giro, casa rosa, aviso)', 'Barra: X apagado e Apagar tudo',
                     'Tremor e anúncio', VERIFICACAO],
    },
    'L28_1_busca_e_titulo': {
        'g': G, 'arquivos': ['features/search/presentation/search_screen.dart',
                             'features/search/presentation/sections/search_bar.dart'],
        'contexto': 'Busca, antes de digitar (28): a barra de cima (voltar, o campo "Livro, autor ou ISBN" e o botão '
                    'amarelo do Scanner), o brilho lavanda e o título "O que vamos ler agora?". Abre pela lupa da Início '
                    '(ao lado do sino).',
        'leitura': [
            'Barra em `left/right 16 · top 54`, gap 8, `z-index 2`: voltar 48 (`#FFFAF1`, sombra 2/2), o campo de 50 '
            '(`flex 1`, padding 0/14, gap 9, lupa 20 `#6F665B`, texto 15,5/600) e o Scanner 48 `#FED170` com sombra 2/2 e '
            'o ícone 21.',
            'Brilho lavanda 26 em `left 330 · top 136`.',
            'Título: "O que vamos" Bricolage 36/800 `lh 0,98` ls −1,1, quebra, "ler agora?" Instrument Serif itálico 44 '
            'ls −0,4.',
            FONTES,
        ],
        'interacoes': [
            'Voltar → a tela de onde abriu (a Início).',
            'Campo → resultados enquanto digita (espera ~300 ms), na 28b; o trecho buscado grifado em amarelo.',
            'Scanner → a tela do Scanner.',
        ],
        'dados': ['Nada vem do banco nesta faixa.'],
        'armadilhas': [
            '"Livro, autor ou ISBN" é o `placeholder` (cor padrão do Chromium, não declarada): `hintText` com a cor da '
            'referência @3x.',
            'Na 28b o campo ganha o anel `{{brand}}` de 4 (foco) e o X de limpar, e a lupa encolhe (abaixo, na L28b_1).',
        ],
        'subfases': ['A tela da Busca e a lupa da Início ligada', 'Barra de busca', 'Brilho e título', VERIFICACAO],
    },
    'L28_2_recentes_e_clima': {
        'g': G, 'arquivos': ['features/search/presentation/sections/recent_searches.dart',
                             'features/search/presentation/sections/mood_chips.dart'],
        'contexto': 'Busca (Explorar): as buscas recentes (capitu, Clarice Lispector, romance de época) com "Limpar" e '
                    '"Pelo clima", oito pílulas coloridas votadas pelos leitores (Leve, Tenso, Para chorar, De uma '
                    'sentada…).',
        'leitura': [
            '"Buscas recentes" Bricolage 21/800 ls −0,4 e "Limpar" 13/800 sublinhado (offset 3), 24 abaixo do título.',
            'Recentes (flex-wrap, gap 8, 12 abaixo): pílulas de 38, padding 0/13/0/10, `#FFFAF1`, borda 1,5, sem sombra, '
            'o relógio 16 `#6F665B` + 14/700 `nowrap`.',
            '"Pelo clima" + "votos dos leitores" 12,5/700 `#6F665B`, 30 abaixo; as pílulas (flex-wrap, gap 9/8) de 42, '
            'padding 0/15, borda 1,5, **sombra 2/2**, 14,5/800: amarelo, lavanda, rosa e verde se repetem na ordem.',
            FONTES,
        ],
        'interacoes': [
            'Recente → busca o termo de novo; Limpar → apaga as recentes (sem confirmação na prancha).',
            'Clima → os livros com esse clima: a lista não tem prancha — ' + D243B + '.',
        ],
        'dados': [
            'Buscas recentes salvas no aparelho (nota do design); a prancha mostra 3 — quantas guardar e mostrar é '
            'pergunta da T15.',
            'Climas: os mesmos dos Detalhes (17), com as mesmas cores em todo o app; os votos ainda não têm fonte (ver a '
            'L17_4).',
            DADOS,
        ],
        'armadilhas': [
            'As cores dos climas aqui (Leve amarelo, Tenso lavanda…) e as dos humores da 17 (irônico rosa, reflexivo '
            'amarelo…) precisam sair de uma tabela só de clima → cor; conferir que "Reflexivo" é lavanda aqui e amarelo '
            'na 17 — a divergência é do design e é pergunta da T15.',
        ],
        'subfases': ['Buscas recentes com Limpar', 'Pílulas de clima (flex-wrap)', VERIFICACAO],
    },
    'L28_3_generos': {
        'g': G, 'arquivos': ['features/search/presentation/sections/genre_tiles.dart'],
        'contexto': 'Busca (Explorar): os 8 gêneros em blocos coloridos de 2 colunas (Romance, Fantasia, Clássicos '
                    'brasileiros, Suspense, Ficção científica, Poesia, Não ficção, Quadrinhos), cada um com um livrinho '
                    'inclinado no canto, e "Ver todos".',
        'leitura': [
            '"Gêneros" Bricolage 21/800 e "Ver todos" 13/800 sublinhado, 30 abaixo dos climas.',
            'Grade de 2 colunas (gap 10), blocos de 96: padding 13/14, raio 20, borda 1,5, sombra 2/2, `overflow: '
            'hidden`; o nome Bricolage 17/800 `lh 1,05` ls −0,3, `max-width 92` (quebra em 2 linhas), branco creme nos '
            'fundos escuros (Suspense, Ficção científica).',
            'O livrinho: 52 × 72 em `right −12 · bottom −18`, raio 4/8/8/4, borda 1,5, sombra dura −3/3 (para a '
            'esquerda), girado 16° ou −14° alternando; a lombada de 1,5 a 6 da borda e duas linhas pretas de 3 (a 2ª a 0,6).',
            FONTES,
        ],
        'interacoes': [
            'Gênero → os livros do gênero: a lista não tem prancha — ' + D243B + '.',
            'Ver todos → a lista completa dos gêneros (a mesma do Onboarding, "Mais gêneros"): sem prancha — ' + D243B + '.',
        ],
        'dados': ['Os mesmos gêneros do Onboarding (13); a ordem e as cores são do app.'],
        'armadilhas': [
            '"Quadrinhos" não cabe nos 92 de `max-width` e passa 3,10 (T13.5): o navegador deixa vazar; o Flutter quebra a '
            'palavra no meio. Medir com a largura máxima e deixar a linha passar (sem quebra dentro da palavra).',
            'O livrinho é cortado pelo bloco (`overflow: hidden`) e a sombra dele vai para a esquerda: `ClipRRect` no bloco '
            'com o livrinho girado dentro.',
        ],
        'subfases': ['Grade dos gêneros', 'Livrinho inclinado no canto', VERIFICACAO],
    },
    'L28_4_em_alta': {
        'g': G, 'arquivos': ['features/search/presentation/sections/trending_carousel.dart'],
        'contexto': 'Busca (Explorar): "Em alta nos clubes" — livros que mais clubes começaram esta semana — num carrossel '
                    'de capas de 124 × 176 com o título, o autor e a pílula rosa "38 clubes".',
        'leitura': [
            '"Em alta nos clubes" Bricolage 21/800, 30 abaixo dos gêneros; o texto 13,5/600 `#5B544B`, 4 abaixo.',
            'Carrossel com `margin 14 −16 0` e `padding 0 16 6`, gap 14, `overflow: hidden`: itens de 128 com a capa de '
            '124 × 176 (raio 6/12/12/6, borda 1,5, sombra 3/3), a lombada de 1,5 a 7 da borda e o título Bricolage 17/800 '
            '+ autor 10/700 a 0,8 dentro, embaixo.',
            'Embaixo da capa: título 14/800, autor 12,5/600 `#6F665B` e a pílula de 26 `#FFC1C6` (borda 1,3, padding '
            '0/9/0/6, as pessoas 13 + "38 clubes" 11,5/800).',
            'Capas da fixture: O Cortiço (as janelas em CSS), Iracema, Policarpo Quaresma e A Hora da Estrela (desenhos '
            'SVG que ocupam a largura da capa).',
            FONTES,
        ],
        'interacoes': [
            'Livro → os detalhes do livro do catálogo; um livro que não está na estante não tem prancha de Detalhes '
            '(a 17 é a do livro da pessoa) — pergunta da T15.',
        ],
        'dados': ['"Livros que mais clubes começaram esta semana" vem do servidor (a contagem de clubes por livro na '
                  'semana); a consulta ainda não existe: D-247 — com dados reais a seção some até haver a fonte '
                  '(pergunta da T15), e a fixture continua nos testes.', DADOS],
        'armadilhas': [
            'As ilustrações de Iracema, Policarpo e A Hora da Estrela têm `width="100%"`: no app ocupam a caixa da capa '
            '(Iracema esticada, `BoxFit.fill`; as outras com `contain`), como diz o mapa de widgets.',
        ],
        'subfases': ['Título e texto', 'Carrossel de capas com a contagem de clubes', VERIFICACAO],
    },
    'L28b_1_abas_e_livros': {
        'g': G, 'arquivos': ['features/search/presentation/search_results.dart',
                             'features/search/presentation/results/result_tabs.dart',
                             'features/search/presentation/results/book_result_row.dart'],
        'contexto': 'Resultados da busca ("capitu", 28b): as abas por tipo (Tudo 18 · Livros 9 · Clubes 6 · Seus trechos '
                    '3) com a máscara que apaga a direita, e os livros — Dom Casmurro, que já está na estante, com a seta, '
                    'e um livro novo com o "+".',
        'leitura': [
            'Abas (`margin 0 −16`, padding 4/16, gap 8, `overflow: hidden`) com a máscara `linear-gradient(90deg, #000 '
            '88%, transparente)`: pílulas de 38, padding 0/13, borda 1,5, 13,5/800; a marcada em `{{brand}}` com sombra '
            '2/2 e o número `#3B3466`; as outras `#FFFAF1` com o número `#8A8073`.',
            '"Livros" Bricolage 21/800 e "Ver os 9", 20 abaixo; linhas com padding 12/0 e a borda de baixo 1,2 `dashed '
            '#D9CCB4`, gap 14.',
            'Linha: capa 58 × 84 (raio 6/12/12/6, sombra 2/2, o desenho centrado); o título em Literata 18/500 `lh 1,2`, '
            'o autor 13/600; "NA SUA ESTANTE" (pílula de 24 `#ABCF82`, borda 1,3, 11/800) + "e-book · 62%" 12/700; a '
            'linha do porquê 12/600 `#8A8073` com "Capitu" grifado (`mark`: amarelo de 55 % para baixo).',
            'À direita: a seta num círculo preto 44 (o livro da estante) ou o "+" num círculo `#FFFAF1` 44 (o novo).',
            'O que muda da 28 na barra: o anel de foco `{{brand}}` de 4, o X de limpar e a lupa encolhida.',
            FONTES,
        ],
        'interacoes': [
            'Aba → filtra por tipo; "Ver os 9" → a aba Livros.',
            'Livro da estante → os Detalhes (17).',
            '"+" → adiciona o livro à estante: com que status e se abre a folha do Scanner (03) é pergunta da T15.',
            'X do campo → limpa e volta para o Explorar (28).',
        ],
        'dados': ['Livros do catálogo (a API de livros "a definir" na nota do design; hoje, as camadas do catálogo da '
                  'G07), guardados em cache; "NA SUA ESTANTE" e o progresso do banco local; o grifo amarelo marca o termo '
                  'buscado no título e na linha do porquê.', DADOS],
        'armadilhas': [
            'Com o X de limpar, a lupa do campo encolhe no flex (20 → 16,78 de largura; a altura fica 20 — T13.5): '
            'decidir na T15 se o app repete.',
            'A máscara das abas (`ShaderMask`) apaga as últimas 12 %: a aba "Seus trechos" fica meio apagada na borda.',
            'O grifo do termo (`mark`) é um degradê de 55 % para baixo, `padding 0 1`: o `TextSpan` com fundo não faz '
            'meia altura — pintar por trás das letras (como o marca-texto dos grifos).',
        ],
        'subfases': ['Abas por tipo com a máscara', 'Linha de livro (na estante × novo)', 'Termo grifado', VERIFICACAO],
    },
    'L28b_2_clubes_e_trechos': {
        'g': G, 'arquivos': ['features/search/presentation/results/club_result_row.dart',
                             'features/search/presentation/results/highlight_result_card.dart',
                             'features/search/presentation/results/scan_card.dart'],
        'contexto': 'Resultados: os clubes (Leitoras de Capitu, o seu, com o visto verde; Capitu sem spoiler, aberto, com '
                    '"Entrar"), "Nos seus trechos" (só você vê), dois grifos do Dom Casmurro, e o cartão tracejado "Tem o '
                    'livro de papel na mão?".',
        'leitura': [
            '"Clubes" + "Ver os 6", 30 abaixo dos livros; linhas com a borda tracejada embaixo, gap 12: o avatar 50 (raio '
            '16, `#FFC1C6`, as pessoas 24), o nome 15,5/800 com o termo grifado e "Seu clube · 11 pessoas · qui 24/9" '
            '12,5/600; à direita o visto em círculo 40 `#ABCF82` ("Você participa") ou "Entrar" (pílula preta de 40, '
            '13,5/800).',
            '"Nos seus trechos" + "só você vê"; cartões com 10 entre eles: padding 12/14, raio 16, `#FFFAF1`, borda 1,5, '
            'o trecho em Literata 15,5 `lh 1,55` `#2A2520` com "Capitu" grifado e, 8 abaixo, a bolinha 10 da cor do grifo '
            '+ "Dom Casmurro · pág. 152" 12/700.',
            'Cartão do Scanner, 22 abaixo: padding 14/16, raio 20, borda 1,5 `dashed`, o círculo amarelo 42, "Tem o livro '
            'de papel na mão?" 14,5/800 + "Escaneie o código de barras e pronto" 12,5/600 e a seta 18.',
            FONTES,
        ],
        'interacoes': [
            sem_destino(G, 'Clube → a aba do clube (04), da T07'),
            sem_destino(G, 'Entrar → entrar no clube aberto (a T07/T12)'),
            'Trecho → o trecho no leitor (`AppRoutes.leitor` com `goTo`).',
            'Cartão do Scanner → a tela do Scanner.',
        ],
        'dados': ['Clubes do nosso servidor (os dados da G); trechos = os grifos e notas da própria pessoa, buscados no '
                  'aparelho (só ela vê); a cor da bolinha é a do grifo.', DADOS],
        'armadilhas': [
            'O avatar dos dois clubes é o mesmo ícone na prancha: com dados reais, o selo e a cor de cada clube (o Criar '
            'clube, 33) — o widget recebe o desenho do clube.',
        ],
        'subfases': ['Linhas de clube (participa × Entrar)', 'Nos seus trechos', 'Cartão do Scanner', VERIFICACAO],
    },
    'L28c_nada_encontrado': {
        'g': G, 'arquivos': ['features/search/presentation/search_nothing_found.dart'],
        'contexto': 'Nada encontrado (28c): a figurinha do livro com a lupa, "Nada por aqui… ainda.", o texto com o termo '
                    'buscado ("receitas da vó cida"), "Escanear o código de barras" (amarelo), "Adicionar à mão" (preto) '
                    'e o quadro tracejado das dicas.',
        'leitura': [
            'Desenho 210 × 170 centrado, 26 abaixo da barra (`buscaNadaEncontrado`, `overflow: visible`), com o "?" em '
            'Instrument Serif 44.',
            'Título centrado 18 abaixo: "Nada por aqui" Bricolage 30/800 `lh 1` ls −0,8 + "… ainda." Instrument Serif '
            'itálico 36; o texto 14,5/600 `lh 1,45`, `max-width 300`, `text-wrap: pretty`, com o termo entre aspas em '
            '800 `#1A1714`.',
            'Botões de 56 (gap 12, 22 abaixo): Escanear `#FED170` com sombra 3/3 e o ícone 22; Adicionar à mão preto com '
            'o "+" 20 `#F7F0E3`; ambos 16/800.',
            'Dicas, 24 abaixo: padding 14/16, raio 18, borda 1,5 `dashed`; "DICAS" 11/800 ls 1,2 `#6F665B` e a lista '
            '(gap 7, 14/600 `lh 1,35`) com a seta "→" coral 800 em cada item (gap 8).',
            FONTES,
        ],
        'interacoes': [
            'Escanear o código de barras → o Scanner.',
            'Adicionar à mão → a 28d com o título já preenchido pelo que foi buscado.',
        ],
        'dados': ['O termo buscado (exato, entre aspas); o resto é texto do app.'],
        'armadilhas': [
            'O "→" não existe na Figtree 800: o Chromium usa a Inter ExtraBold do sistema (R8, abaixo). No app, a seta '
            'vira um ícone ou um glifo de fonte embutida — pergunta da T15 (a largura do item muda).',
            'A 3ª dica fica num fio de navalha (0,45, abaixo): o `<li>` é flex com a seta como outro item — a '
            'largura da frase é a do `<li>` menos a seta e o gap (D-280).',
            '`text-wrap: pretty` muda as quebras no Chromium: as linhas da tabela são as do navegador — conferir as '
            'quebras no app com o termo da fixture.',
        ],
        'subfases': ['Figurinha e título', 'Texto com o termo', 'Escanear e Adicionar à mão', 'Dicas', VERIFICACAO],
    },
    'L28d_1_topo_e_capa': {
        'g': G, 'arquivos': ['features/library/presentation/manual_book/add_manual_screen.dart',
                             'features/library/presentation/manual_book/auto_cover.dart'],
        'contexto': 'Adicionar à mão (28d): o fechar, a etiqueta "Livro fora da base", o título "Adicionar à mão." e a '
                    'capa automática (cor + título e autor) girada −3°, com o selo de trocar a capa, "Fotografar capa", '
                    '"Da galeria" e as 5 cores.',
        'leitura': [
            'Topo em `left/right 16 · top 54`, 48 de altura: fechar 48 (sombra 2/2, X 18 traço 2,4) e a etiqueta de 30 '
            '(padding 0/12, borda 1,5, 12/800).',
            'Título: "Adicionar" Bricolage 34/800 `lh 0,98` ls −1, quebra, "à mão." Instrument Serif itálico 42 ls −0,4.',
            'Capa 124 × 180, 20 abaixo, raio 6/14/14/6, borda 1,5, sombra 4/4, girada −3°: a cor escolhida, a lombada de '
            '1,5 a 8, o desenho do bolo (122 × 90) e, embaixo, o título Bricolage 17/800 `lh 0,98` + o autor 10,5/700 a '
            '0,8. A etiqueta "capa automática" (24, `#FED170`, 10,5/800) centrada 14 abaixo; o selo de trocar 40 em '
            '`right −12 · top −10`.',
            'À direita (gap 8): "Fotografar capa" (48, raio 16, sombra 2/2) e "Da galeria" (48, sem sombra), ícone 19 + '
            '14/800; "OU ESCOLHA A COR" 11/800 ls 1,2; 5 círculos de 28 (gap 8) com a marcada no anel duplo (`0 0 0 2.5 '
            '#FFFAF1, 0 0 0 4 #1A1714`).',
            FONTES,
        ],
        'interacoes': [
            'Fechar → sai sem salvar; com mudanças, confirmar o descarte (sem prancha: ' + D243B + ').',
            'Trocar a capa → a mesma escolha da tela "Trocar a capa" da T14 (Fotografar, Galeria ou voltar para a capa '
            'automática).',
            'Fotografar capa → câmera com recorte automático; Da galeria → as fotos do aparelho.',
            'Cor → a capa automática muda na hora (título e autor por cima).',
        ],
        'dados': ['A capa automática é gerada do título, do autor e da cor (sem foto); a foto fica só com a pessoa. O '
                  'desenho do meio (o bolo da fixture): como escolher (por gênero, sorteado ou sem desenho) é pergunta da '
                  'T15.', DADOS],
        'armadilhas': [
            'A etiqueta "capa automática" usa `translateX(-50%)` (centrada pela própria largura): no app, `Align` '
            'centrado, não um deslocamento fixo.',
            'Só a capa gira (−3°): o selo de trocar e a etiqueta são irmãos dela e ficam retos.',
        ],
        'subfases': ['Topo e título', 'Capa automática girada com a etiqueta e o selo', 'Fotografar, galeria e as cores',
                     VERIFICACAO],
    },
    'L28d_2_formulario': {
        'g': G, 'arquivos': ['features/library/presentation/manual_book/manual_book_form.dart'],
        'contexto': 'Adicionar à mão: o formulário — Título (preenchido com o que foi buscado), Autor, Formato (Papel | '
                    'E-book), Número de páginas, ISBN (com o botão amarelo de ler pela câmera), Salvar como (Lendo) — o '
                    'botão "Adicionar à estante" e a nota "ficam só com você".',
        'leitura': [
            'Rótulos 13,5/800 `lh 18` (" · opcional" 600 `#8A8073`); campos de 52, 6 abaixo do rótulo, 14 entre os '
            'grupos: padding 0/14/0/16, raio 16, `#F7F0E3`, borda 1,5, texto 16/600.',
            'Formato e Salvar como: réguas de 50 (padding 3, gap 3, `#F7F0E3`), a marcada em `{{brand}}` com borda 1,5 e '
            '14/800, as outras com borda transparente de 1,5 e 14/700.',
            'Páginas: o campo tem 150 de largura e, 6 abaixo, "Sem ele, o app conta só os minutos de leitura." 12,5/500 '
            '`lh 16` `#6F665B`. ISBN: o campo com `padding-right 6` e o botão 40 × 40 (raio 12, `#FED170`, borda 1,5, '
            'ícone 19).',
            'Botão "Adicionar à estante", 26 abaixo: largura toda, 56, preto, "+" 20 + 16/800; a nota centrada 12,5/600 '
            '`lh 1,4`, 10 abaixo.',
            FONTES,
        ],
        'interacoes': [
            'Só o título é obrigatório; o botão sem título não tem prancha (a prancha mostra o formulário preenchido) — '
            'pergunta da T15.',
            'Ler o ISBN com a câmera → o Scanner na aba Código, que devolve o ISBN para o campo.',
            'Adicionar à estante → grava o livro privado na estante (formato, páginas, ISBN, status) e vai para os '
            'Detalhes do livro.',
            'Teclado: o formulário rola e o botão continua alcançável.',
        ],
        'dados': ['Título vindo da busca (28c) ou o ISBN vindo do Scanner (40); formato começa em Papel, status em Lendo '
                  '(nota do design). Livro à mão é privado; se o mesmo ISBN aparecer na base depois, o app oferece juntar '
                  'sem perder minutos, grifos e notas (o fluxo de juntar não tem prancha).', DADOS],
        'armadilhas': [
            '"ex.: 120" e "978-…" são `placeholder` (cor padrão do Chromium): `hintText` com a cor da referência @3x.',
            'Sem páginas, o livro de papel conta só minutos (a barra de progresso da Biblioteca não tem dado — a mesma '
            'pergunta da L02_4).',
        ],
        'subfases': ['Campos de texto (título, autor, páginas, ISBN)', 'Réguas de formato e status',
                     'Adicionar à estante (livro privado)', VERIFICACAO],
    },
}

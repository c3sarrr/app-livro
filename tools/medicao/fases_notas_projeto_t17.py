"""T13.12 — notas escritas à mão das fases L da T17: Perfil (05), Editar perfil (64, 65), Ajustes (06), Conta (58),
Excluir conta (59), Privacidade (56) e Notificações (30, 30b, 30c). A parte medida é gerada por `gen_fases.py`
(`CONJUNTO=projeto`); as notas do design ficam em `docs/design/projeto/NOTAS.md` (perfil-abas-flutter, editar-flutter,
privacidade-flutter, notificacoes-flutter, revisao-consistencia, telas-faltando). A conta já existe desde a G05
(`features/account/`: entrar, idade, @, sair, excluir e exportar — D-65, D-69); a aba Perfil hoje é o placeholder com o
bloco da conta (D-69) e `/notificacoes` é um placeholder.
"""
from fases_notas_projeto_comum import DADOS, FONTES, VERIFICACAO, sem_destino

G = 'T17'
D243B = ('sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em '
         '`docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b)')
FALTA = ('tela que falta (D-268), da própria T17 — perguntar, buscar 3–5 referências, desenhar a prancha em '
         '`docs/design/novas/` e esperar o "sim" antes do Flutter (ROTEIRO §5)')
CHAVE_A = ('A chave dos Ajustes e dos Lembretes (`role="switch"`): 54 × 32, raio cheio, borda 1,5; ligada, o trilho '
           '`{{brand}}` e a bolinha `#FFFAF1` de 24 (borda 1,5) a 2,5 da direita, com o visto de 11 (traço 3,6). É um '
           'dos dois desenhos de chave da T17 — o outro está na Conta e na Privacidade (52 × 32, sem visto).')
CHAVE_B = ('A chave da Conta e da Privacidade: 52 × 32, a bolinha de 23 sem visto; ligada, o trilho preto e a bolinha '
           'na cor da marca. É o 2º desenho de chave da T17 (o 1º, 54 × 32 com o visto, fica nos Ajustes e nos '
           'Lembretes).')
DUAS_CHAVES = ('As chaves têm dois desenhos na T17 (54 × 32 com o visto nos Ajustes e nos Lembretes; 52 × 32 sem visto, '
               'trilho preto, na Conta e na Privacidade): no app, um widget com as duas variantes '
               '(`core/design_system/widgets/app_switch.dart`), cada tela com a sua, como a prancha. Unificar seria '
               'melhoria além do design (ROTEIRO §2b): só como proposta, com "Manter igual ao design".')
TOPO_CONTA = ('O topo da Conta, da Excluir conta e da Privacidade: o voltar de 48 (`#FFFAF1`, borda 1,5, sem sombra, seta '
              '20 traço 2,2) em `left/right 20 · top 58`; o título 58 abaixo do topo da tela: Bricolage 34/800 '
              '`lh 0,98` ls −1,1 + Instrument Serif itálico 42 ls −0,5.')
LISTA = ('As listas da Conta e da Privacidade: o título da seção Bricolage 20/800 ls −0,5 com o rótulo à direita 12,5/700 '
         '`#8A8073` (pode ser vazio, como em Entrar e Pessoas), 10 acima do cartão; o cartão com padding 2/14, raio 24, '
         '`#FFFAF1`, borda 1,5, sem sombra; cada linha `min-height 64`, padding 8/0, gap 12 — o círculo 38 colorido com '
         'o ícone 18, o título 15/700 `lh 1,2`, a descrição 12,5/500 `#5B544B` e, à direita, a seta, a contagem ou a '
         'chave; o fio de 1 `#EAE1D0` entre as linhas.')
LINHA_AJUSTE = ('As linhas dos Ajustes: `min-height 66` (56 na Ajuda), gap 12, o fio de 1 `#EAE1D0` entre elas; o círculo '
                '38 colorido com o ícone 18 (na Ajuda, o ícone 20 solto), o título 15/700 e a descrição 12,5/500 '
                '`#5B544B` (`min-width: 0`), e a seta 18 (traço 2,2).')
TOPO_NOTIF = ('O topo das Notificações: `left/right 16 · top 54` (4 mais para fora e para cima que o das outras telas da '
              'T17), os botões de 48 com sombra dura 2/2: voltar à esquerda e, à direita (gap 8), "Marcar tudo como '
              'lido" (o duplo visto 21) e a engrenagem 20 "Ajustes de lembretes e avisos".')
AVISO = ('O aviso: o quadrado 44 de raio 14 na cor do tipo (Clube `#FFC1C6`, Lembrete `#FED170`, Conquistas `#ABCF82`, '
         'Social `#B6ACE4`) com o ícone; o título 14,5/800 `lh 1,3` (`flex 1`) e, na mesma linha pela base, o tempo 12/700 '
         '`#8A8073` `nowrap`; o texto 13,5/600 `lh 1,4` `#5B544B`, 3 abaixo; a ação, quando tem, numa pílula de 36, 10 '
         'abaixo (preta em "Ler agora", creme nas outras). Não lido = cartão (padding 12, raio 20, `#FFFAF1`, borda 1,5, '
         'sombra 2/2, 10 acima) com a bolinha coral 9 (borda 1,2) depois do tempo; lido = liso, padding 12/12, o fio '
         'tracejado 1,2 `#D9CCB4` embaixo.')

NOTAS = {
    'L05_1_capa': {
        'g': G, 'arquivos': ['features/profile/presentation/profile_screen.dart',
                             'features/profile/presentation/sections/profile_cover.dart',
                             'features/profile/presentation/sections/library_card.dart',
                             'features/profile/presentation/sections/profile_tabs.dart'],
        'contexto': 'Perfil (05), em cima: o @ com a engrenagem dos Ajustes, a capa do perfil em forma de livro (lombada, '
                    '"EDIÇÃO 2026 / LEITORA Nº 0052", o avatar M girado com a sequência, o nome, a bio e os números), a '
                    'carteirinha de leitora girada, "Editar perfil" e "Compartilhar", e as abas Resumo, Resenhas, Grifos e '
                    'Listas. A tela entra no lugar do placeholder da aba (`/perfil`, hoje com o bloco da conta, D-69).',
        'leitura': [
            'Topo de 48: "@marinacosta" 15/800 e o botão "Configurações" (48, `#FFFAF1`, borda 1,5, sem sombra, '
            'engrenagem 22 traço 1,8).',
            'Capa 16 abaixo: `min-height 322`, padding 18/20/18/34, raio 8/26/26/8, `{{cover}}`, borda 1,5, sombra 5/5, '
            '`overflow: hidden`; a lombada (16 de largura, preto a 0,12) e o vinco (1,5 em `left 19`, preto a 0,28).',
            '"EDIÇÃO 2026 / LEITORA Nº 0052" 10/800 ls 0,14em `lh 1,6` `#2C2452`, `max-width 170`; o avatar em '
            '`top 26 · right 22`: o círculo 96 `#FED170` (borda 1,5, sombra 3/3) girado −6° com o "M" Instrument Serif '
            'itálico 60 e a pílula coral da sequência (30 de altura, sombra 2/2, girada 7°, o fogo e "12" 13/800) em '
            '`left −12 · bottom −2`.',
            'Nome 72 abaixo: "Marina" Bricolage 46/800 `lh 0,92` ls −1,6 + quebra + "Costa" Instrument Serif itálico 58 '
            '`lh 0,95` ls −0,8; a bio 14,5/600 `lh 1,35` `#2C2452`, `max-width 270`, `text-wrap: pretty`, 12 abaixo.',
            'Números 18 abaixo, pela base com o colofão (o círculo preto 34): 12,5/600 `lh 1,5` `#2C2452` com os números '
            'em 800 preto, em duas linhas ("248 seguidores · 180 seguindo" / "3 clubes · 52 livros lidos").',
            'Carteirinha 20 abaixo, girada −1,2°: raio 16, `#FFFAF1`, borda 1,5, sombra 4/4; a faixa de 28 em `{{card}}` '
            '("CARTEIRINHA DE LEITORA" e "Nº 0052" 10/800, `tnum`); o corpo pautado (`repeating-linear-gradient`, uma '
            'linha `#EFE6D5` a cada 20) com o código de barras 92 × 24, "0052 · 2026 · BN" 8,5/800, o tracejado vertical, '
            '"30 min/dia" Bricolage 17/800, "24 livros em 2026" 12/600 e o carimbo 46 girado −12°.',
            'Botões 20 abaixo, em grade de 2 (gap 10): pílulas de 48, `#FFFAF1`, borda 1,5, 14,5/800 com o ícone.',
            'Abas 18 abaixo (`tablist`, margem −20 até as bordas, padding 2/20/4, gap 8, `overflow: hidden`): pílulas de '
            '42, 14/600 com a contagem 12/700 `#6F665B`; a escolhida `{{brand}}` 14/800, borda 1,5 preta e sombra 2/2; '
            'as outras com a borda `#E2D7C4`.',
            FONTES,
        ],
        'interacoes': [
            'Engrenagem → os Ajustes (06), empilhados dentro da aba Perfil (a navegação continua: a 06 mostra a nav).',
            'Editar perfil → a 64. Compartilhar → ' + D243B + ' (ou a folha do sistema com o link do perfil, se a T17 '
            'decidir).',
            'Carteirinha → Carteirinha aberta (compartilhar como imagem): ' + FALTA + '.',
            sem_destino(G, '"248 seguidores" e "180 seguindo" → Seguidores e Seguindo (89, 90), da T22'),
            '"3 clubes" → a aba Clubes; "52 livros lidos" → a Biblioteca (02) com o filtro Lido (os dois existem na '
            'T17) — confirmar na pergunta da T17.',
            sem_destino(G, 'Abas Resenhas, Grifos e Listas → as abas 43, 44 e 45, da T20; a nota do design pede '
                           '`NestedScrollView` com a capa colapsando e as abas presas, que a T20 completa'),
        ],
        'dados': [
            'O @ e o nome são os da conta (`AccountSummary`); a bio, os números e a sequência, do perfil '
            '(`ProfileFull`, `social_models.dart`); seguidores e seguindo, do social (`follow_repository.dart`). O nº da '
            'leitora e o ano da carteirinha são os do cadastro (a 16 da T16); a meta diária e os livros do ano vêm das '
            'metas (`ReadingGoals`).',
            'A cor da capa (`{{cover}}`) e o avatar (inicial ou foto) são escolhas da 64; a cor da carteirinha (`{{card}}`) '
            'é a do cadastro (a 16).',
            DADOS,
        ],
        'armadilhas': [
            'A aba Listas já passa da tela a 390 (31,38, e 61,38 a 360) e a contagem dela some sob o `overflow` (abaixo): '
            'no app, abas que rolam (`TabBar(isScrollable: true)`, a nota do design), paradas no começo como a prancha.',
            'A capa tem altura mínima (322) e cresce com a bio: o avatar é absoluto e não empurra o nome (o nome desce 72 '
            'fixos). A 360 o "EDIÇÃO 2026" invade o avatar em 9 (abaixo): o app reproduz o CSS.',
            'A linha de números dá a largura da própria caixa (o `<span>` cresce com ela, D-280): não é fio de navalha.',
            'A carteirinha girada −1,2° desenha fora da própria caixa (a referência guarda a caixa sem o giro e a '
            'visível); o toque segue a caixa girada.',
        ],
        'subfases': ['Topo e capa do perfil (lombada, avatar com a sequência, nome, bio e números)',
                     'Carteirinha de leitora', 'Editar perfil e Compartilhar', 'Abas', VERIFICACAO],
    },
    'L05_2_lendo_e_ano': {
        'g': G, 'arquivos': ['features/profile/presentation/sections/reading_now_section.dart',
                             'features/profile/presentation/sections/year_section.dart',
                             'features/profile/presentation/sections/year_shelf.dart'],
        'contexto': 'Perfil (05), no Resumo: "Lendo agora" com 3 capas e o marcador de fita, e o cartão amarelo "2026 em '
                    'leitura" — 24 de 30 livros na meta do ano, "2 à frente", a estante do ano (24 lombadas e 6 vagas '
                    'tracejadas) e os quatro números do ano.',
        'leitura': [
            '"Lendo agora" 28 abaixo das abas: o título Bricolage 20/800 ls −0,4 e "Ver os 4" (44 de altura, 14/700, seta '
            '18); a grade de 3 (gap 14), cada livro com a capa de 132 (raio 3/8/8/3, borda 1,5, a lombada de 6) e o '
            'marcador de fita 14 × 26 por cima, e o rótulo 12,5/800, 8 abaixo.',
            'Cartão do ano 32 abaixo: padding 18, raio 28, `#FED170`, borda 1,5, sombra 4/4, gap 16; "2026 em" Bricolage '
            '22/800 + "leitura" Instrument Serif 27; o "24" Bricolage 58/800 `lh 0,85` ls −2 com "de 30 livros / na meta '
            'do ano" 14/700 `#3D3524`; a pílula "2 à frente" (30, `#FFFAF1`, 12/800) presa embaixo à direita.',
            'Estante: a fileira de 48 (flex pela base, gap 2, padding 0/4) com as 24 lombadas (`flex 1 1 0`, alturas da '
            'prancha de 38 a 47, raio 2/2/1/1, borda 1,2, a faixa de 2 a 60% no topo) e as 6 vagas de 44 tracejadas '
            '(1,2 `#8A7F63`), todas de 8,1667 de largura; a tábua de 9 (`#FFFAF1`, borda 1,5, sombra 0/2), subindo 1,2.',
            'Números em grade de 2 (gap 8): padding 12/12/11, raio 18, `#FFFAF1`, borda 1,5, sem sombra; o valor '
            'Bricolage 25/800 ls −0,6 (o gênero, Instrument Serif itálico 27) e o rótulo 12,5/600 `#5B544B`.',
            '"Ver estatísticas completas" (44, margem −6/0/−8, 14/800, seta 18) fecha o cartão.',
            FONTES,
        ],
        'interacoes': [
            'Capa → os Detalhes do livro (17/17b, da T14); se o e-book abre direto o leitor, é pergunta da T17.',
            '"Ver os 4" → a Biblioteca (02) com o filtro Lendo, se a T17 decidir; senão, ' + D243B + '.',
            sem_destino(G, '"Ver estatísticas completas" → as Estatísticas (29), da T21'),
        ],
        'dados': [
            'Lendo agora = os livros com o status Lendo (`ShelfStatus.reading`), os 3 mais recentes, e o total no '
            '"Ver os N"; o rótulo é a porcentagem e, no 1º, a página ("62% · pág. 159"); nos outros, só a porcentagem — a '
            'regra (o 1º, o mais recente, ou quando cabe) é pergunta da T17.',
            'O ano: os livros terminados no ano (`ProfileNumbers.booksReadYear`) contra a meta do ano (o mesmo campo da 12, '
            'da T16, em `ReadingGoals`); "N à frente" = lidos − meta × a fração do ano que passou, arredondado. O texto '
            'quando está atrás do ritmo não tem prancha — pergunta da T17.',
            'Uma lombada por livro lido no ano (a cor da capa do livro) e uma vaga por livro que falta; as alturas da '
            'prancha são as da fixture — no app, a altura de cada lombada sai do livro (o número de páginas, numa faixa '
            'de 38 a 47) ou de uma sequência fixa: pergunta da T17. Com mais lidos que a meta, as vagas somem e as '
            'lombadas estreitam (a fileira é `flex 1 1 0`).',
            'Páginas lidas, horas e maior sequência vêm das sessões (papel e e-book) e da sequência; o gênero do ano, do '
            'gênero dos livros terminados — enquanto o livro não tiver gênero no banco, o item segue a D-247.',
            DADOS,
        ],
        'armadilhas': [
            'A estante tem 24 lombadas e 6 vagas de 8,1667 (`flex 1 1 0`, gap 2): no app, `Expanded` na mesma ordem — '
            'a largura é a mesma para lombada e vaga, e a borda de 1,2 fica dentro (`box-sizing: border-box`).',
            'A tábua sobe 1,2 sobre a fileira (`margin-top −1,2`): as lombadas encostam na tábua por cima.',
            'As capas desta seção são CSS (formas absolutas em px e o título com `<br>`), como as da Biblioteca: as formas '
            'presas por `left`/`right` esticam com a coluna; o título com quebra imposta ("Mrs.<br>Dalloway") não é fio de '
            'navalha (D-280).',
        ],
        'subfases': ['Lendo agora: as 3 capas, o marcador e o rótulo', 'Cartão do ano: o número e a pílula',
                     'Estante do ano (lombadas e vagas)', 'Os quatro números e o link', VERIFICACAO],
    },
    'L05_3_favoritos_e_conquistas': {
        'g': G, 'arquivos': ['features/profile/presentation/sections/favorites_section.dart',
                             'features/profile/presentation/sections/achievements_section.dart'],
        'contexto': 'Perfil (05), no Resumo: "Quatro que me definem" (4 capas na prateleira) e as Conquistas — "12 de 30", '
                    'quatro medalhas (o selo de sequência, o hexágono, o círculo e o losango) e a próxima ("14 dias '
                    'seguidos", faltam 2) com a barra listrada.',
        'leitura': [
            'Favoritos 36 abaixo do cartão do ano: "Quatro que me" Bricolage 20/800 + "definem" Instrument Serif 25 e '
            '"Editar" (44, 14/700); a grade de 4 (gap 10, padding 0/2) com as capas de 118 (raio 3/7/7/3, borda 1,5, a '
            'lombada de 5, o título Instrument Serif 15–18 `lh 0,9`) e a prateleira de 11 em `{{shelf}}` (borda 1,5, '
            'sombra 0/3), 5 para fora de cada lado e subindo 1,5.',
            'Conquistas 38 abaixo: "Conquistas" Bricolage 20/800 com "12 de 30" 13/700 `#5B544B` pela base (gap 8), e '
            '"Ver todas" com a seta 18; a grade de 4 (gap 6), cada medalha numa área 72 × 72 com o desenho de 68 e a '
            'sombra dura de 3 (o SVG da prancha), o miolo (o "12 DIAS" Bricolage 22 + 8/800 ls 0,1em, o ícone 26 ou o '
            '"200 GRIFOS") e o rótulo 12/700 `lh 1,25` em duas linhas, 8 abaixo.',
            'Próxima: padding 12/14, raio 18, tracejado 1,5 `#8A7F63`, gap 8; "Próxima: 14 dias seguidos" 13/700 com o '
            'nome em 800, e "faltam 2" 12/700 `#5B544B` `nowrap`; a barra de 16 (borda 1,5, hachura `#E9DFCC`/`#FFFAF1` '
            '3/7) com o preenchimento coral de 86% e a ponta ondulada (o SVG 10 × 13 esticado na altura).',
            FONTES,
        ],
        'interacoes': [
            'Capa → os Detalhes do livro (17/17b, da T14).',
            '"Editar" → a 64, já no bloco dos 4 (rolada até ele), se a T17 decidir; senão, a 64 do começo.',
            sem_destino(G, '"Ver todas" e as medalhas → as Conquistas (79), da T21'),
        ],
        'dados': [
            'Os 4 que me definem são escolhidos na 64 (ordem 1–4). O app ainda não guarda favoritos: o campo novo (no '
            'perfil, no servidor) é pergunta da T17; sem o dado, a seção segue a D-247.',
            'As conquistas (quantas de quantas, as 4 mais recentes e a próxima com o que falta) são da T21: até lá, a '
            'seção segue a D-247 (fixture nos testes, some com dados reais); a sequência que já existe (12 dias) pode '
            'alimentar o 1º selo e a próxima — pergunta da T17.',
            DADOS,
        ],
        'armadilhas': [
            'A barra da próxima conquista é a mesma régua da Início (a hachura e a ponta ondulada, D-285 para os traços): '
            'o preenchimento de 86% é proporção da largura, com a ponta de 10 saindo 5 para a direita.',
            'As medalhas são SVG com a sombra desenhada como uma 2ª forma deslocada 3/3: entram pelo `AppSvg`, sem '
            '`BoxShadow`.',
            'A 360 o título "O Cortiço" da 2ª capa fica num fio de navalha (0,04, abaixo): uma linha só, que quebra se '
            'crescer.',
        ],
        'subfases': ['Quatro que me definem: capas e prateleira', 'Conquistas: título, grade de medalhas',
                     'Próxima conquista com a barra', VERIFICACAO],
    },
    'L05_4_atividade': {
        'g': G, 'arquivos': ['features/profile/presentation/sections/recent_activity_section.dart',
                             'features/shell/presentation/floating_nav_bar.dart',
                             'features/shell/presentation/bottom_fade.dart'],
        'contexto': 'Perfil (05), no fim do Resumo: a atividade recente (desenhou em Dom Casmurro, grifou com a citação '
                    'marcada, terminou Quincas Borba com 4 estrelas e a resenha), o degradê do fim e a navegação com o '
                    'Perfil marcado.',
        'leitura': [
            '"Atividade recente" Bricolage 20/800, 6 acima da lista; cada item com padding 12/0, gap 12 e o fio de 1 '
            '`#E4DACA` (o último sem fio): o círculo 36 colorido (borda 1,5) com o ícone 18 e o texto em coluna.',
            'O texto: a frase 14/500 `lh 1,35` com o livro em 800; a citação Instrument Serif itálico 19 `lh 1,15` com o '
            'marca-texto `#FED170` dos 45% de baixo (`linear-gradient`); as estrelas 15 (gap 2: 4 douradas `#F2A815` e 1 '
            'vazia); a resenha 14/500 `lh 1,4` `#3D3830`; e o quando 12/600 `#6F665B`.',
            'O degradê de 150 no fundo (transparente → `#F7F0E3` em 55%) e a navegação flutuante: a mesma da Início (o '
            'shell), com o Perfil marcado (`{{brand}}`, borda 1,5, o ícone cheio `#FFFAF1`, 11/800).',
            FONTES,
        ],
        'interacoes': [
            'Item do desenho e do grifo → os grifos do livro (25, `/livro/:bookId/destaques`) no trecho, se a T17 '
            'decidir; o clube citado ("no clube Leitoras de Capitu") não é um link na prancha.',
            sem_destino(G, 'Item da resenha → a Resenha aberta (74), da T20'),
            'Navegação: as abas do shell (Perfil marcado); o Scanner abre o scanner (`/scanner`).',
        ],
        'dados': [
            'A atividade = os últimos eventos da pessoa (grifo, desenho, livro terminado com a nota e a resenha), do mais '
            'novo ao mais velho, com o tempo relativo ("Hoje", "Ontem", "Há 3 dias"). Desenho e grifo vêm do banco local '
            '(os grifos do leitor); a resenha e a nota são da T20 — até lá, esse tipo de item segue a D-247. Quantos itens '
            'mostrar é pergunta da T17.',
            DADOS,
        ],
        'armadilhas': [
            'O marca-texto da citação é um degradê duro de 55% atrás do texto inline (quebra junto com a linha): no app, '
            'o mesmo componente da citação marcada da Início e dos grifos (`marked_quote.dart`), não um fundo de caixa.',
            'O "4 de 5 estrelas" é o rótulo do grupo; as estrelas são decorativas.',
        ],
        'subfases': ['Atividade recente: os três tipos de item', 'Degradê e navegação com o Perfil marcado',
                     VERIFICACAO],
    },
    'L64_1_previa_e_cor': {
        'g': G, 'arquivos': ['features/profile/presentation/edit/edit_profile_screen.dart',
                             'features/profile/presentation/edit/profile_preview.dart',
                             'features/profile/presentation/edit/cover_color_picker.dart',
                             'features/profile/application/profile_draft.dart'],
        'contexto': 'Editar perfil (64), em cima: o fechar e o título, a prévia ao vivo da capa do perfil (a capa-livro '
                    'em miniatura com o avatar e a câmera, o nome, a bio e as etiquetas), as 11 cores da capa com a roda '
                    'de qualquer cor e o tipo de avatar (Foto ou Inicial M).',
        'leitura': [
            'Topo em `left/right 20 · top 58`, 48 de altura: o fechar (48, `#FFFAF1`, borda 1,5, o X 20 traço 2,2), '
            '"Editar perfil" Bricolage 17/800 ls −0,3 no meio e o espaço de 48 à direita.',
            'Prévia 14 abaixo: `min-height 196`, padding 14/16/14/28, raio 8/22/22/8, `{{cover}}`, borda 1,5, sombra 5/5, '
            'a lombada de 13 e o vinco em `left 16`; "PRÉVIA AO VIVO" 9,5/800 ls 0,14em `#2C2452`; o avatar 70 (girado '
            '−6°, "M" Instrument Serif 44) em `top/right 16` com a câmera 30 em `right −6 · bottom −4`; o nome Bricolage '
            '32/800 + "Costa" Instrument Serif 39, 34 abaixo; a bio 13/600 `max-width 250`; as etiquetas de 22 (10,5/800 '
            'o pronome, 10,5/700 os gêneros sobre creme a 0,6).',
            '"COR DA CAPA" 11/800 ls 1,2 `#6F665B`, 22 abaixo; a fileira das cores (`radiogroup`, margem −20, padding '
            '4/20/4/22, gap 9, `overflow: hidden` e a máscara que apaga os 14% da direita): a roda 32 (`conic-gradient` '
            'das 9 cores, o "+" num círculo 14) e as 11 cores de 32; a escolhida com o anel duplo (2,5 `#F7F0E3` + 4 '
            'preto).',
            '"AVATAR" 14 abaixo, com o seletor à direita (`radiogroup`, 40 de altura, padding 3, duas colunas de 92, '
            'raio cheio, borda 1,5): "Foto" 13/600 `#5B544B` com a câmera 14 e "Inicial M" `{{brand}}` 13/800.',
            FONTES,
        ],
        'interacoes': [
            'Fechar → volta ao Perfil; com mudanças, pergunta "Descartar alterações?" (a nota do design) — a folha da '
            'pergunta não tem prancha: ' + D243B + ' (ou o diálogo do app, se a T17 decidir).',
            'Câmera do avatar e "Foto" → o seletor de imagem do sistema e o recorte redondo (a nota do design: 512 px no '
            'servidor); "Inicial" → a inicial do nome.',
            'Cor → a prévia muda na hora (a mesma variável nos Ajustes, 06); a roda → ' + D243B + ' (o seletor de qualquer '
            'cor não tem prancha).',
        ],
        'dados': [
            'Um rascunho do perfil (`ProfileDraft`, a nota do design) que a prévia escuta; salvar faz uma gravação só. A '
            'cor da capa, o tipo de avatar e a foto são campos novos do perfil (no servidor): pergunta da T17.',
            'As 11 cores são a paleta do Clube (33) — no app, os tokens da paleta, com o nome de cada uma no rótulo.',
            DADOS,
        ],
        'armadilhas': [
            'A fileira das cores passa da tela já a 390 (o Roxo, o Creme e a Tinta ficam fora, sob a máscara; a 360 '
            'também o Verde, abaixo): no app, rolagem horizontal com a máscara por cima (`ShaderMask`), parada no começo.',
            'O anel duplo da cor escolhida é sombra (`box-shadow` 0 0 0 2,5 e 0 0 0 4): fica fora da bolinha de 32 e o '
            'padding de 4 da fileira é o que o mostra inteiro.',
            'A prévia usa os mesmos componentes da capa do Perfil (05) em escala menor, não um desenho à parte: o que muda '
            'na 64 aparece igual na 05.',
        ],
        'subfases': ['Topo e rascunho do perfil', 'Prévia ao vivo', 'Cores da capa', 'Tipo de avatar', VERIFICACAO],
    },
    'L64_2_campos': {
        'g': G, 'arquivos': ['features/profile/presentation/edit/identity_fields.dart',
                             'features/profile/presentation/edit/choice_pills.dart'],
        'contexto': 'Editar perfil (64), no meio: os campos Nome (12/40), @ de usuária ("é seu", troca a cada 30 dias) e '
                    'Bio (51/120, em foco com o cursor), os pronomes (ela/dela marcado, Escrever, Não mostrar) e os '
                    'gêneros favoritos (até 5, 3 escolhidos, cada um com a sua cor).',
        'leitura': [
            'Campos 22 abaixo do avatar, gap 14: o rótulo 11/800 ls 1,2 `#6F665B` com o contador 11,5/700 `#8A8073` à '
            'direita; a caixa `min-height 52` (84 na bio, padding 12/14), padding 0/14, raio 16, `#FFFAF1`, borda 1,5; o '
            'texto 15,5/600 `lh 1,45`.',
            'O @: o "@" em `#8A8073` e, à direita, "é seu" 12/800 `#2E5314` com o visto 13; a bio em foco tem a sombra '
            '3/3 e o cursor coral 2 × 18 depois do texto.',
            '"PRONOMES" / "opcional" e "GÊNEROS FAVORITOS" / "até 5 · 3 escolhidos", 20 abaixo; as pílulas (flex-wrap, '
            'gap 8, 8 abaixo) de 38, padding 0/13, 13,5/600 `nowrap`, borda 1,5 `#E2D7C4`; a escolhida com borda preta, '
            '800, o visto 14 à esquerda (padding 0/13/0/9) e a cor: `{{brand}}` no pronome, a do gênero nos gêneros '
            '(`#FED170`, `#FFC1C6`, `#ABCF82`).',
            FONTES,
        ],
        'interacoes': [
            'Nome: até 40, o contador acompanha. Bio: até 120, o contador acompanha.',
            '@: checagem ao vivo com espera de 400 ms ("é seu", "disponível", "já existe, tente…", a nota do design); só '
            'troca a cada 30 dias — os estados de carregando, disponível e erro não têm prancha: ' + D243B + '.',
            'Pronomes: uma escolha só (Escrever abre o campo do pronome escrito, sem prancha: ' + D243B + ').',
            'Gêneros: até 5; o 6º não marca (o aviso não tem prancha: ' + D243B + ').',
        ],
        'dados': [
            'Nome e @ são os da conta (`AccountSummary`; o @ pela `chooseHandle` que já existe); bio, pronomes e gêneros '
            'são do perfil — os gêneros são os mesmos do Onboarding (13, da T16). A regra dos 30 dias do @ e os pronomes '
            'são campos novos: pergunta da T17.',
            DADOS,
        ],
        'armadilhas': [
            'Os pronomes estão num `radiogroup` com botões `role="checkbox"`: no app, escolha única com a semântica de '
            'grupo exclusivo (`inMutuallyExclusiveGroup`), como o design pede; os gêneros são `checkbox` de verdade.',
            'O rótulo do campo do @ diz "@ DE USUÁRIA": o gênero do texto segue o do perfil — a regra para os outros '
            '(USUÁRIO, a forma neutra) é pergunta da T17.',
        ],
        'subfases': ['Campos Nome, @ e Bio com os contadores', 'Pronomes', 'Gêneros favoritos', VERIFICACAO],
    },
    'L64_3_quatro_e_salvar': {
        'g': G, 'arquivos': ['features/profile/presentation/edit/favorites_editor.dart',
                             'features/profile/presentation/edit/edit_profile_screen.dart'],
        'contexto': 'Editar perfil (64), embaixo: os 4 que me definem com o número, o lápis de trocar e a alça de arrastar '
                    '("segure para reordenar"), e o "Salvar alterações" preso no fundo com o aviso de que quem segue vê a '
                    'capa nova na hora.',
        'leitura': [
            '"Quatro que me" Bricolage 18/800 + "definem" Instrument Serif 22, com "segure para reordenar" 11,5/700 '
            '`#8A8073`, 22 abaixo; a grade de 4 (`justify-items: center`, gap 8), 14 abaixo.',
            'Cada livro: a capa 66 × 99 (raio 3/6/6/3, borda 1,5, a lombada de 4, o título Instrument Serif 11,8–13,4 '
            '`lh 0,92`), o número num círculo preto de 22 em `left/top −7` (11/800 `#FFFAF1`), o lápis num círculo 30 '
            '`#FFFAF1` (borda 1,5) em `right/bottom −8` e, 6 abaixo, a alça de 18 (os 6 pontos 1,4).',
            'Fundo preso (`left/right/bottom 0`, `z-index 5`, padding 26/20/28, o degradê do creme a 30%): "Salvar '
            'alterações" 56, preto, sem borda, sombra 0/4 preta a 0,25, o visto `#ABCF82` 19 e o texto 16/800 `#F7F0E3`; '
            'o aviso 12,5/600 `#6F665B` centrado, 10 abaixo.',
            FONTES,
        ],
        'interacoes': [
            'Lápis → a folha "Trocar um dos 4" (65) daquele número.',
            'Segurar e arrastar → reordena (o número acompanha a posição); no leitor de tela, as ações "mover para a '
            'esquerda/direita" (a nota do design).',
            'Salvar alterações → grava o rascunho e volta ao Perfil; sem mudanças, o botão fica como está (o estado '
            'apagado não tem prancha: ' + D243B + ').',
        ],
        'dados': ['Os 4 livros do perfil, na ordem (o mesmo campo da 05); só livros que a pessoa terminou.', DADOS],
        'armadilhas': [
            'O número e o lápis saem da capa (−7 e −8): `Clip.none` no livro, e o toque do lápis vale também fora da '
            'capa.',
            'O "Salvar" fica por cima do conteúdo: o fim da rolagem precisa do espaço dele (o degradê de 26 + 56 + o aviso '
            '+ 28), senão os 4 ficam por baixo.',
        ],
        'subfases': ['Os 4 com número, lápis e alça', 'Reordenar (arrastar e as ações de acessibilidade)',
                     'Salvar preso no fundo', VERIFICACAO],
    },
    'L65_trocar_livro': {
        'g': G, 'arquivos': ['features/profile/presentation/edit/swap_favorite_sheet.dart'],
        'contexto': 'Editar perfil, trocar um dos 4 (65): a 64 por baixo do escurecido e a folha "Trocar o 3º livro" — o '
                    'livro de hoje (Iracema, que volta para a estante), a busca nos 52 lidos, as melhores notas (4 opções '
                    'com estrelas, a já escolhida apagada) e "Pôr Vidas Secas no lugar".',
        'leitura': [
            'Por baixo, o topo e a prévia da 64 (a tabela "Diferenças"); o escurecido preto a 0,5 por cima de tudo.',
            'Folha em `left/right/bottom 10 · top 150`: padding 10/16/18, raio 32/32/44/44, `#FFFAF1`, borda 1,5, sombra '
            '0/4, coluna; a alça 40 × 5 `#D9CFBD`; a cabeça (gap 12, 12 abaixo): a capa 40 × 60 com o número e "Trocar" '
            'Bricolage 21/800 + "o 3º livro" Instrument Serif 25, e "Hoje é Iracema · ela volta para a estante" 12,5/600.',
            'Busca 14 abaixo: pílula de 48, `#F7F0E3`, borda 1,5, a lupa 18 e "Buscar nos seus 52 lidos".',
            '"SUAS MELHORES NOTAS" 11/800 ls 1, 14 abaixo; as opções (`radiogroup`, gap 8): cada uma com padding '
            '8/12/8/8, raio 18, a capinha, o título e o autor, as 5 estrelas e o rádio; a escolhida `{{brand}}` com '
            'sombra 2/2; a que já está nos 4 apagada com "já é o nº 4".',
            'O botão no fundo (`flex-grow` antes dele): 54, preto, 15,5/800, o ícone de troca `#FED170`.',
            FONTES,
        ],
        'interacoes': [
            'Opção → escolhe o livro (a já escolhida não marca); o botão diz o nome ("Pôr Vidas Secas no lugar").',
            'Buscar → filtra os lidos pelo título e pelo autor.',
            'Botão → troca no rascunho da 64 e fecha a folha; arrastar a alça para baixo ou tocar no escurecido fecha '
            'sem trocar.',
        ],
        'dados': [
            'Os livros que a pessoa terminou (52), as melhores notas primeiro (a nota de cada livro é da T20: até lá, a '
            'ordem e as estrelas seguem a D-247, com os lidos mais recentes no lugar — pergunta da T17).',
            DADOS,
        ],
        'armadilhas': [
            'A folha tem `top 150` fixo e o fundo a 10: a altura depende da tela (684 a 844). Em telas baixas, a lista '
            'das opções rola dentro da folha e o botão fica no fundo.',
            'A capinha da 2ª opção tem o título em duas linhas com `<br>` e a 2ª ("da Estrela") fica num fio de navalha '
            '(0,64): a 2ª linha é uma palavra só, que quebra se crescer.',
            'O escurecido cobre a 64 inteira, inclusive o topo dela: o fechar da 64 não responde com a folha aberta.',
        ],
        'subfases': ['Escurecido e moldura da folha', 'Cabeça: o livro de hoje', 'Busca e opções com estrelas',
                     'Botão de trocar', VERIFICACAO],
    },
    'L06_1_conta': {
        'g': G, 'arquivos': ['features/settings/presentation/settings_screen.dart',
                             'features/settings/presentation/sections/settings_account_card.dart',
                             'features/settings/presentation/sections/plan_card.dart'],
        'contexto': 'Ajustes (06), em cima: o voltar para o Perfil, "Seus ajustes.", a busca nos ajustes, o cartão da '
                    'conta com a linguagem de capa de livro (avatar, nome, e-mail, "Dados só neste celular") e o cartão '
                    'amarelo da assinatura (plano Grátis, conhecer o Pro).',
        'leitura': [
            'Voltar de 48 (sem sombra, seta 20); "Seus" Bricolage 36/800 `lh 1` ls −1,2 + "ajustes." Instrument Serif 46 '
            'ls −0,6, 16 abaixo.',
            'Busca 18 abaixo: pílula de 52, padding 0/18/0/16, gap 10, a lupa 20 e o campo 15/500 ("Buscar ajuste").',
            'Conta 18 abaixo: padding 16/16/16/30, raio 8/24/24/8, `{{cover}}`, borda 1,5, sombra 4/4, a lombada de 13 e '
            'o vinco em `left 16`; o avatar 58 girado −6° (sombra 2/2, "M" Instrument Serif 36); o nome Bricolage 20/800, '
            'o e-mail 13/600 `#2C2452` com reticências e a pílula "Dados só neste celular" (24, 11,5/800, o celular 12), '
            '5 abaixo; a seta 20 à direita.',
            'Assinatura 14 abaixo: padding 14/16, raio 22, `#FED170`, borda 1,5, sombra 3/3, gap 12; a estrela coral num '
            'círculo 42; "Assinatura" 15,5/800 com a pílula "Grátis" (22, 11/800) e "Conheça o Pro: estante na nuvem, em '
            'qualquer celular" 12,5/600 `#4A3B12`; a seta 20.',
            FONTES,
        ],
        'interacoes': [
            'Voltar → o Perfil (os Ajustes ficam empilhados na aba Perfil).',
            'Buscar → filtra as linhas dos Ajustes pelo título e pela descrição; o resultado não tem prancha: ' + D243B +
            '.',
            'Conta → a Conta (58).',
            sem_destino(G, 'Assinatura → os Planos do Pro (83), da T19 (hoje só o paywall de trabalho, D-230)'),
        ],
        'dados': [
            'Nome, e-mail e plano são os da conta (`AccountSummary`, `pro`); "Dados só neste celular" quando a conta não '
            'sincroniza (sem o Pro) — com o Pro, o texto e o ícone da sincronização (`sync_indicator.dart`) não têm '
            'prancha aqui: pergunta da T17. Sem conta, o cartão chama para entrar (sem prancha: ' + D243B + ').',
            DADOS,
        ],
        'armadilhas': [
            'O cartão da conta tem 107,6 de altura aqui e 93 na Conta (58): não é o mesmo componente (aqui o e-mail e a '
            'pílula, lá o @ e o botão Editar), só a mesma linguagem de capa.',
            'O e-mail corta com reticências (`nowrap` + `ellipsis`) e o nome não: um nome longo quebra a linha.',
        ],
        'subfases': ['Voltar, título e busca', 'Cartão da conta', 'Cartão da assinatura', VERIFICACAO],
    },
    'L06_2_leitura': {
        'g': G, 'arquivos': ['features/settings/presentation/sections/reading_settings_section.dart',
                             'core/design_system/widgets/app_switch.dart'],
        'contexto': 'Ajustes (06), Leitura: "Restaurar padrão", o tema das páginas (Claro, Sépia marcado, Escuro em '
                    'miniatura), a fonte do livro (Literata), o tamanho do texto (18 pt, a régua com A e A), virar páginas '
                    '(Paginado ou Contínuo) e manter a tela acesa.',
        'leitura': [
            '"Leitura" Bricolage 22/800 ls −0,5 com "Restaurar padrão" (44, 13,5/700 `#5B544B`); o cartão: padding 16, '
            'raio 24, `#FFFAF1`, borda 1,5, sem sombra.',
            'Tema (`radiogroup`, grade de 3, gap 10, 10 abaixo do rótulo 13/800): a miniatura de 86 (padding 10/11, raio '
            '14, borda 1,5, gap 6) com o "Aa" Literata 24 e as 3 linhas de 3 (100%, 86%, 64%) e o nome 13/600 embaixo; a '
            'marcada com borda 2,5, sombra 3/3, o visto num círculo 24 `{{brand}}` em `top/right −9` e o nome 13/800.',
            'Fonte do livro: linha de 56 (o fio de 1 `#EAE1D0` em cima): "Fonte do livro" 15/700 + "Feita para textos '
            'longos" 12,5/500 e, à direita, "Literata" Literata 16/600 e a seta 18.',
            'Tamanho: "Tamanho do texto" 15/700 e "18 pt" 13/800; a régua (`slider`, 30 de altura) com o "A" Literata 14 '
            'e o 24 nas pontas: o trilho de 10 hachurado, o preenchimento `{{brand}}` de 38% e o puxador 26 (sombra '
            '2/2).',
            'Virar páginas: o seletor de 40 ("Paginado" `{{brand}}` 13/800, "Contínuo" 13/600); Manter a tela acesa: '
            'título + "Enquanto um livro estiver aberto" e a chave.',
            CHAVE_A,
            FONTES,
        ],
        'interacoes': [
            'Tema, fonte, tamanho e virar páginas mudam os mesmos ajustes do leitor (a tela 26, `ReaderSettings`).',
            'Fonte do livro → a escolha da fonte: a da tela 26 (o leitor) ou uma lista própria — sem prancha aqui: ' +
            D243B + '.',
            'Restaurar padrão → volta aos padrões da tela 26 (`ReaderLook`); se pede confirmação, é pergunta da T17.',
            'Manter a tela acesa → liga ou desliga o `wakelock` do leitor (hoje sempre ligado com um livro aberto).',
        ],
        'dados': [
            'Os ajustes de leitura já existem (`reader_settings.dart`): o papel tem 4 opções no leitor (creme, branco, '
            'sépia, noite) e aqui 3 (Claro, Sépia, Escuro); o tamanho é um passo (D-20) e aqui pontos (12–28, 18 pt); '
            'não há modo contínuo nem a chave da tela acesa. Como juntar os dois é pergunta da T17.',
            DADOS,
        ],
        'armadilhas': [
            DUAS_CHAVES,
            'O visto da miniatura marcada sai da caixa (−9): `Clip.none` e o padding da grade para ele não cortar.',
            'A régua é `role="slider"` com o puxador decorativo: a semântica fica no slider (mín. 12, máx. 28, valor 18).',
        ],
        'subfases': ['Título e Restaurar padrão', 'Tema das páginas', 'Fonte e tamanho do texto',
                     'Virar páginas e a tela acesa (a chave)', VERIFICACAO],
    },
    'L06_3_metas': {
        'g': G, 'arquivos': ['features/settings/presentation/sections/goals_section.dart',
                             'core/design_system/widgets/app_switch.dart'],
        'contexto': 'Ajustes (06), Metas e lembretes: o cartão amarelo com a meta do ano (30 livros) e a diária (30 min), '
                    'cada uma com menos e mais, o lembrete para ler (todos os dias, 21:00, ligado) e a proteção da '
                    'sequência (1 dia de folga por semana).',
        'leitura': [
            '"Metas e" Bricolage 22/800 + "lembretes" Instrument Serif 27; o cartão: padding 16, raio 26, `#FED170`, borda '
            '1,5, sombra 4/4, gap 6.',
            'Metas em grade de 2 (gap 10): padding 12, raio 18, `#FFFAF1`, borda 1,5; o rótulo 12,5/700 `#5B544B`, o '
            'número Bricolage 32/800 ls −1 `lh 1` com a unidade 13/700 pela base e, 6 abaixo, o menos (40, `#FFFAF1`) e o '
            'mais (40, preto, o "+" `#FFFAF1`).',
            'Lembrete: padding 12/2, o fio de 1 preto a 0,16 embaixo; "Lembrete para ler" 15/700 + "Todos os dias" '
            '12,5/600 `#4A4030`; à direita (gap 8) o horário numa pílula de 36 (14/800 `tnum`) e a chave.',
            'Sequência: padding 12/2/4; o fogo coral 16 + "Proteger minha sequência" 15/700 e "1 dia de folga por semana '
            'sem zerar" 12,5/600 `lh 1,35`; a chave.',
            CHAVE_A,
            FONTES,
        ],
        'interacoes': [
            'Menos e mais → mudam a meta (do ano: o passo e os limites da 12, da T16; diária: 5 a 600, o passo é pergunta '
            'da T17); o valor grava na hora.',
            'Horário → o relógio do sistema para trocar (como na 30b).',
            'Chave do lembrete → liga ou desliga o lembrete (o mesmo da 30b). Chave da sequência → a regra da folga.',
        ],
        'dados': [
            'As metas são as de `ReadingGoals` (a diária já existe; a do ano é o campo da 12, da T16).',
            'O lembrete é o mesmo da 30b: aqui a prancha diz "Todos os dias" e 21:00, e a 30b diz 21:30 sem o sábado. No '
            'app é um lembrete só — as duas telas mostram o mesmo dado; a fixture de cada prancha segue a prancha (D-34) '
            'e a coerência (D-88) é pergunta da T17. O texto dos dias ("Todos os dias", "Dias úteis", a lista) é pergunta '
            'da T17.',
            'A proteção da sequência é regra nova (a sequência não zera com 1 dia sem ler por semana): pergunta da T17.',
            DADOS,
        ],
        'armadilhas': [
            DUAS_CHAVES,
            'O horário usa algarismos tabulares (`tnum`): `withTabularFigures()` (D-282).',
        ],
        'subfases': ['Cartão: as duas metas com menos e mais', 'Lembrete com o horário e a chave',
                     'Proteger a sequência', VERIFICACAO],
    },
    'L06_4_mais_e_ajuda': {
        'g': G, 'arquivos': ['features/settings/presentation/sections/more_settings_section.dart',
                             'features/settings/presentation/sections/help_section.dart',
                             'features/settings/presentation/sections/account_actions.dart'],
        'contexto': 'Ajustes (06), embaixo: Mais ajustes (Notificações, Privacidade, Biblioteca e dados, Scanner, Aparência '
                    'do app, Idioma e acessibilidade), Ajuda (central, fale com a gente, termos) e o rodapé — sair, excluir '
                    'e a versão; a navegação e o degradê do Perfil, presos ao fundo.',
        'leitura': [
            '"Mais ajustes" e "Ajuda" Bricolage 22/800, 34 entre as seções; os cartões: padding 4/14, raio 24, `#FFFAF1`, '
            'borda 1,5, sem sombra.',
            LINHA_AJUSTE,
            'Rodapé 30 abaixo (coluna centrada, gap 6): "Sair da conta" (52, largura toda, `#FFFAF1`, borda 1,5, 15/800, '
            'a porta 18); "Excluir conta" (44, sem fundo, 14/800 `#A3301A`); a versão 12/600 `#6F665B` com a estrelinha '
            '12.',
            'Por baixo, o degradê e a navegação da 05 (a tabela "Diferenças": os dois 110 acima, porque a página tem '
            '2400 e não 2510).',
            FONTES,
        ],
        'interacoes': [
            'Notificações → Lembretes e avisos (30b). Privacidade → a 56.',
            'Biblioteca e dados → as seções de Sincronização e Seus dados da Conta (58), se a T17 decidir; senão, ' +
            D243B + '.',
            'Scanner → ' + D243B + '.',
            'Aparência do app e Idioma e acessibilidade → Aparência e acessibilidade: ' + FALTA + '. Se é uma tela para '
            'as duas linhas ou duas, entra na mesma pergunta.',
            'Central de ajuda, Fale com a gente e Termos e privacidade → ' + D243B + ' (ou o link externo, se a T17 '
            'decidir).',
            'Sair da conta → sai (a `signOut` que já existe, com a escolha de apagar o que está no aparelho, D-65); a '
            'confirmação não tem prancha nesta tela.',
            'Excluir conta → a Excluir conta (59).',
        ],
        'dados': [
            'As descrições das linhas acompanham o estado ("Perfil fechado · 3 pedidos", "Automático · cor de destaque '
            'lavanda", "Português (Brasil) · texto maior"): cada uma vem do ajuste de verdade; os pedidos, do social.',
            'A versão é a do app (a do build; ler a versão em tempo de execução pede pacote novo, pergunta da T17), com o '
            'texto "feito para quem lê".',
            DADOS,
        ],
        'armadilhas': [
            'A navegação aparece nos Ajustes com o Perfil marcado: a 06 é rota filha da aba Perfil (no ramo do shell), '
            'não uma tela por cima de tudo como a Conta, a Privacidade e as Notificações.',
            'O fim da página precisa do espaço da navegação e do degradê (o recuo do shell, `shell_insets.dart`).',
        ],
        'subfases': ['Mais ajustes (as 6 linhas)', 'Ajuda', 'Rodapé: sair, excluir e a versão',
                     'Navegação e degradê presos ao fundo', VERIFICACAO],
    },
    'L58_conta': {
        'g': G, 'arquivos': ['features/settings/presentation/account/account_screen.dart',
                             'features/settings/presentation/account/settings_list_card.dart',
                             'core/design_system/widgets/app_switch.dart'],
        'contexto': 'Conta (58): o voltar aos ajustes, "Sua conta.", a capa da conta (avatar, nome, @ e nº da leitora, '
                    'Editar), Entrar (e-mail, senha, contas conectadas), Sincronização (aparelhos, baixar para ler sem '
                    'internet), Seus dados (exportar, importar CSV), sair e excluir.',
        'leitura': [
            TOPO_CONTA,
            'Capa 18 abaixo: padding 16/16/16/30, raio 8/24/24/8, `{{cover}}`, borda 1,5, sombra 4/4, a lombada e o '
            'vinco; o avatar 58 girado −6°; o nome Bricolage 20/800 e "@marinacosta · leitora nº 0052" 13/600 `#2C2452`; '
            'o "Editar" numa pílula de 36 (borda 1,3, 12,5/800).',
            LISTA,
            'Entrar: e-mail (confirmado), senha (trocada há 4 meses) e contas conectadas (login social ativo); '
            'Sincronização (rótulo "só neste celular"): aparelhos (com a contagem 1) e "Baixar livros para ler sem '
            'internet" com a chave; Seus dados (rótulo "é tudo seu"): exportar e importar de outro app.',
            '"Sair desta conta" 26 abaixo (52, `#FFFAF1`, borda 1,5, 15/800, a porta 18) e "Excluir conta" (48, 14/800 '
            '`#B83A1C` sublinhado com 3 de recuo, a lixeira 17), 10 abaixo.',
            CHAVE_B,
            FONTES,
        ],
        'interacoes': [
            'Voltar → os Ajustes. Editar → a 64.',
            'E-mail, senha e contas conectadas → ' + D243B + ' (as telas de trocar não têm prancha; a troca de senha usa '
            'as telas 10 e 11 da T16, se a T17 decidir).',
            'Aparelhos → ' + D243B + ' (mais aparelhos = o Pro, da T19).',
            'Chave de ler sem internet → guarda os e-books no aparelho (o que já acontece com os baixados).',
            'Exportar meus dados → Exportar meus dados: ' + FALTA + '. Importar de outro app → Importar CSV: ' + FALTA +
            '.',
            'Sair desta conta → a `signOut` (D-65). Excluir conta → a 59.',
        ],
        'dados': [
            'Conta (`AccountSummary`): o @, o nome e o nº da leitora; o e-mail e o "confirmado", da autenticação; o '
            'resto ("trocada há 4 meses", "login social ativo", os aparelhos — `otherSessions` — e os e-books guardados '
            'com o tamanho, "2 e-books guardados · 4,1 MB") vem do que o app já sabe; o que faltar é pergunta da T17.',
            'Exportar hoje é o JSON local pela folha do sistema (D-65), e a nota do design diz que o arquivo chega por '
            'e-mail: entra na tela que falta (Exportar meus dados).',
            DADOS,
        ],
        'armadilhas': [
            DUAS_CHAVES,
            'O cartão da conta tem 93 de altura aqui e 107,6 nos Ajustes (06): são componentes diferentes.',
            'A 360 a descrição das contas conectadas fica num fio de navalha (0,13) e, a 430, a da exportação (abaixo).',
        ],
        'subfases': ['Topo, título e capa da conta', 'Entrar', 'Sincronização com a chave', 'Seus dados',
                     'Sair e excluir', VERIFICACAO],
    },
    'L59_excluir_conta': {
        'g': G, 'arquivos': ['features/settings/presentation/account/delete_account_screen.dart'],
        'contexto': 'Excluir conta (59): "Excluir sua conta?" com tom calmo, os 6 blocos do que vai embora, o que acontece '
                    'nos clubes, duas saídas mais leves (baixar os dados, fazer uma pausa), digitar EXCLUIR e o botão '
                    'coral preso embaixo, apagado até terminar de digitar.',
        'leitura': [
            'O topo da Conta (a tabela "Diferenças"); "Excluir" Bricolage 34/800 + "sua conta?" Instrument Serif 42 e o '
            'texto 14/600 `lh 1,45` `#5B544B`, 8 abaixo.',
            'Perdas 16 abaixo (grade de 3, gap 8): padding 10/12, raio 16, borda 1,5, cada bloco na sua cor; o número '
            'Bricolage 22/800 `lh 1,05` e o rótulo 12/700. O texto dos clubes 12,5/600 `#3D3830`, 10 abaixo.',
            'Saídas 18 abaixo (gap 10): padding 12/14, raio 20, `#FFFAF1`, borda 1,5, o círculo 38 com o ícone, o título '
            'e a descrição; a 1ª com sombra 3/3, a 2ª sem.',
            'Confirmar 22 abaixo: padding 14, raio 22, `#FFE9E4`, borda 1,5; "Para confirmar, digite" 14/800 com o '
            '"EXCLUIR" numa etiqueta (`#FFFAF1`, borda 1,2, ls 1); o campo de 50 (raio 14, 16/800 ls 1,5) com "EXCL" e o '
            'cursor coral 2 × 20; o aviso dos 30 dias 12,5/600.',
            'Fundo preso como na 64: "Excluir minha conta" 56, coral, borda 1,5, opacidade 0,45 (`aria-disabled`), a '
            'lixeira 19, e "O botão libera quando você terminar de digitar." embaixo.',
            FONTES,
        ],
        'interacoes': [
            'Voltar → a Conta.',
            'Baixar meus dados antes → Exportar meus dados (a tela que falta, D-268, a mesma da 58).',
            'Prefere uma pausa? → esconder o perfil e parar os avisos por um tempo: ' + D243B + ' (a pausa é regra nova).',
            'Campo → compara com "EXCLUIR" sem diferenciar maiúsculas (a nota do design); o botão só libera quando bate.',
            'Excluir minha conta → a `deleteAccount` que já existe (D-65); depois a tela de despedida, sem prancha: ' +
            D243B + '.',
        ],
        'dados': [
            'Os 6 números (livros lidos, grifos, resenhas, listas, dias seguidos, clubes) são os da pessoa; os que ainda '
            'não existem (resenhas, listas) seguem a D-247. O texto dos clubes cita o clube e quem fica no lugar (o '
            'mundo do clube, T06–T12).',
            'Os 30 dias para voltar atrás: a exclusão de hoje (D-65) apaga na hora — o prazo é regra nova, pergunta da '
            'T17.',
            DADOS,
        ],
        'armadilhas': [
            'O botão apagado é opacidade 0,45 sobre o coral (a cor e a borda juntas), não outra cor; a referência guarda '
            'a caixa, não a opacidade.',
            'O campo mostra o texto digitado em maiúsculas com ls 1,5 e o cursor desenhado: no app, `TextField` com o '
            'estilo, não um texto fixo.',
            'A 360 o rótulo "dias seguidos" fica num fio de navalha (0,09, abaixo).',
        ],
        'subfases': ['Título, texto e os 6 blocos', 'Clubes e as duas saídas', 'Confirmar: digitar EXCLUIR',
                     'Botão preso embaixo (apagado e liberado)', VERIFICACAO],
    },
    'L56_privacidade': {
        'g': G, 'arquivos': ['features/settings/presentation/privacy/privacy_screen.dart',
                             'features/settings/presentation/account/settings_list_card.dart',
                             'core/design_system/widgets/app_switch.dart'],
        'contexto': 'Privacidade (56): "Sua privacidade.", a escolha entre perfil Aberto e Fechado (marcado), quem vê o quê '
                    '(6 partes, cada uma com a pílula de público), Pessoas (pedidos para seguir, me achar pelo e-mail, '
                    'bloqueadas) e o aviso tracejado do bloqueio.',
        'leitura': [
            TOPO_CONTA,
            'O texto 14/600 `lh 1,4`, 8 abaixo; o tipo de perfil 18 abaixo (`radiogroup`, grade de 2, gap 10): cartões de '
            '`min-height 118`, padding 14/12/12, raio 22, o rádio 24 em `top/right 10`, o título e a descrição; o '
            'escolhido com a borda preta e a cor (o outro com a borda `#E2D7C4`).',
            LISTA,
            'Quem vê o quê (rótulo "só seguidores aprovados"): cada parte com a pílula de público à direita (`aria-haspopup '
            'listbox`: Seguidores ou Só eu). Pessoas: pedidos (3), me achar pelo e-mail (a chave) e bloqueadas (1).',
            'O aviso 14 abaixo: padding 12/14, raio 18, tracejado 1,3 `#8A7F63`, o ícone 18 e o texto 12,5/600 com o '
            'começo em preto.',
            CHAVE_B,
            FONTES,
        ],
        'interacoes': [
            'Aberto e Fechado → muda o tipo do perfil; com o perfil fechado, "Todos" fica indisponível nas pílulas (a nota '
            'do design).',
            sem_destino(G, 'Pílula de público → a folha Quem vê (93–97), da T22'),
            sem_destino(G, 'Pedidos para seguir → a 57, e Bloqueadas → a 98, da T22'),
            'Me achar pelo e-mail → a chave grava na hora.',
        ],
        'dados': [
            'O tipo do perfil já existe (`AccountSummary.isPrivate`); o público por parte, o grifo padrão e o "me achar '
            'pelo e-mail" são um documento de configurações por pessoa (a nota do design), novo: pergunta da T17. O '
            'servidor filtra; o app só mostra.',
            'Pedidos e bloqueadas: as contagens do social (`follow_repository.dart`).',
            DADOS,
        ],
        'armadilhas': [
            DUAS_CHAVES,
            'Dois fios de navalha a 390 (as descrições de Grifos novos e de Me achar pelo e-mail, 0,42 e 0,50) e mais a '
            '360 (abaixo): as quebras dependem da largura exata da coluna da descrição.',
            'As linhas de "Quem vê o quê" não são links (a linha é `<div>`): só a pílula responde ao toque.',
        ],
        'subfases': ['Título, texto e o tipo de perfil', 'Quem vê o quê com as pílulas', 'Pessoas com a chave',
                     'Aviso do bloqueio', VERIFICACAO],
    },
    'L30_1_topo_e_hoje': {
        'g': G, 'arquivos': ['features/notifications/presentation/notifications_screen.dart',
                             'features/notifications/presentation/notifications_top_bar.dart',
                             'features/notifications/presentation/notification_tile.dart'],
        'contexto': 'Notificações (30), em cima: o topo (voltar, marcar tudo como lido, engrenagem), a estrelinha rosa, '
                    '"Novidades por aqui.", "2 novas · domingo, 20 de setembro" e os avisos de Hoje — dois não lidos em '
                    'cartão (o clube, o lembrete com "Ler agora") e dois lidos (o selo novo, as curtidas com avatares). A '
                    'tela entra no lugar do placeholder de `/notificacoes`.',
        'leitura': [
            TOPO_NOTIF,
            'A estrelinha rosa 24 em `left 318 · top 140`; "Novidades" Bricolage 36/800 `lh 0,98` ls −1,1 + quebra + '
            '"por aqui." Instrument Serif itálico 44; o resumo 14/600 `#5B544B` com "2 novas" em 800, 8 abaixo.',
            '"HOJE" 11,5/800 ls 1,3 `#6F665B` com o traço tracejado (1,5 `#CFC3AE`) até a borda, 18 acima e 10 abaixo.',
            AVISO,
            'As curtidas: os avatares de 22 (borda 1,3, 10/800) sobrepostos em −6, antes do livro.',
            FONTES,
        ],
        'interacoes': [
            'Voltar → a tela anterior (a Início, pelo sino). Engrenagem → a 30b.',
            'Marcar tudo como lido → tira os cartões e as bolinhas (os avisos ficam lisos); sem não lidos, o botão fica '
            'apagado (a 30c).',
            sem_destino(G, 'Aviso do clube → a Discussão da semana (31), da T08'),
            'Aviso do lembrete → "Ler agora" começa a sessão do último livro de papel (o cronômetro da T04, a mini-barra; '
            'a tela 18 chega na T18).',
            sem_destino(G, 'Selo novo → as Conquistas (79), da T21; curtidas → a resenha (74), da T20'),
        ],
        'dados': [
            'Os avisos: o app ainda não guarda notificações. Os lembretes são locais (a nota do design pede '
            '`flutter_local_notifications`, que o app ainda não tem — pacote novo é pergunta da T17); clube e social '
            'vêm do servidor (push, serviço a definir). Sem o dado, cada tipo segue a D-247.',
            'Agrupados por dia (Hoje, Esta semana); o tempo relativo ("20 min", "1 h", "sex"); a data do resumo pelo '
            'relógio do app; o número de novas = os não lidos.',
            DADOS,
        ],
        'armadilhas': [
            'A margem de 10 do cartão atravessa o `<li>` (colapsa): os 10 ficam entre os itens e, no 1º, se juntam aos '
            '10 de baixo do rótulo "Hoje" — 10, não 20, entre o rótulo e o 1º cartão.',
            'A seção Hoje não tem contêiner (o título e a lista soltos no `<main>`): a caixa dela é a união dos ids de '
            'topo (`meta.secoesSemElemento`).',
            '"Ler agora" está dentro do link do aviso (um `<span>`): no app, o aviso inteiro é o alvo e a pílula é um '
            'segundo alvo — confirmar na pergunta da T17.',
        ],
        'subfases': ['Topo com os três botões', 'Título e resumo', 'Hoje: avisos em cartão e lisos', VERIFICACAO],
    },
    'L30_2_semana': {
        'g': G, 'arquivos': ['features/notifications/presentation/notifications_screen.dart',
                             'features/notifications/presentation/notification_tile.dart'],
        'contexto': 'Notificações (30), embaixo: os avisos de Esta semana (a enquete com "Votar", o pedido aceito do Rafa '
                    'com "Seguir de volta", Ana entrou no clube), todos lidos, e a nota do fim ("Avisos com mais de 30 '
                    'dias somem sozinhos.").',
        'leitura': [
            '"ESTA SEMANA" como o "HOJE", 26 acima e 10 abaixo.',
            AVISO,
            'A nota do fim 22 abaixo, margem 8 dos lados: 12,5/600 `lh 1,4` `#8A8073`, centrada.',
            FONTES,
        ],
        'interacoes': [
            sem_destino(G, 'Enquete ("Votar") → a Enquete (47), da T11; Ana entrou → o clube (31), da T08'),
            sem_destino(G, 'Pedido aceito → o perfil do Rafa (51), da T22; "Seguir de volta" segue (o social já existe) '
                           'e o botão muda para o estado seguido, sem prancha'),
        ],
        'dados': ['Os avisos com mais de 30 dias saem da lista (a regra do texto do fim).', DADOS],
        'armadilhas': [
            'A seção Esta semana também não tem contêiner (como Hoje): a caixa é a união dos ids de topo.',
            'O dia da semana ("sex", "qui", "ter") vem da data do aviso; mais de 7 dias, a data curta — sem prancha: '
            'pergunta da T17.',
        ],
        'subfases': ['Esta semana', 'Nota do fim', VERIFICACAO],
    },
    'L30b_1_lembrete': {
        'g': G, 'arquivos': ['features/notifications/presentation/reminders_screen.dart',
                             'core/design_system/widgets/app_switch.dart'],
        'contexto': 'Lembretes e avisos (30b), em cima: o voltar, "Lembretes sem pressão." e o cartão do lembrete de '
                    'leitura — a chave, o horário 21:30, os dias da semana (sábado desligado), "Só se eu ainda não li hoje" '
                    'e a prévia de como o aviso chega.',
        'leitura': [
            'O voltar como o das Notificações (`left 16 · top 54`, sombra 2/2), sem os outros dois botões; "Lembretes" '
            'Bricolage 36/800 + quebra + "sem pressão." Instrument Serif 44.',
            'Cartão 18 abaixo: padding 16, raio 24, `#FFFAF1`, borda 1,5, sombra 3/3; a cabeça com o quadrado 38 de raio '
            '12 `#FED170`, "Lembrete de leitura" 16/800 + "No máximo um por dia" 12,5/600 `#6F665B` e a chave.',
            'Horário 14 abaixo: a caixa de 56 (padding 0/14, raio 16, `#F7F0E3`, borda 1,5, Bricolage 28/800 ls −0,5 '
            '`tnum`) e, ao lado, "Tocar no horário abre o relógio para trocar." 13/600.',
            '"EM QUAIS DIAS" 11/800 ls 1,2, 14 abaixo; os 7 dias (`group`, `space-between`, 8 abaixo): círculos 38 '
            '(borda 1,5, 13/800), marcados em `{{brand}}`.',
            'O "Só se eu ainda não li hoje" (o tracejado 1,5 `#CFC3AE` em cima, padding 12/0/0) com a chave; "VAI '
            'APARECER ASSIM" e a prévia (padding 11/12, raio 18, `#F1E7D5`, borda 1,5): o "B" num quadrado preto 34 de '
            'raio 10, "BookNest" e "21:30" 12/700, o título 14/800 e o texto 13/600.',
            CHAVE_A,
            FONTES,
        ],
        'interacoes': [
            'Voltar → as Notificações (30) ou os Ajustes (06), de onde veio.',
            'Chave do lembrete → liga ou desliga (o mesmo lembrete da 06).',
            'Horário → o relógio do sistema (`showTimePicker`) para trocar.',
            'Dias → marca e desmarca cada dia (o mínimo de dias marcados é pergunta da T17).',
            'Só se eu ainda não li hoje → com a meta batida no dia, o aviso não sai.',
        ],
        'dados': [
            'O lembrete (ligado, horário, dias, só se não leu) é novo: agendado como aviso local (pacote novo, pergunta da '
            'T17), no máximo um por dia.',
            'A prévia usa o texto de verdade do aviso: o que falta para a meta de hoje e o último livro de papel.',
            DADOS,
        ],
        'armadilhas': [
            DUAS_CHAVES,
            'A seção declara `margin-top` duas vezes (14 e 18): vale a última, 18.',
            'O horário e os dias são `<span>`/`button` no HTML, mas o horário não é botão: no app ele é o alvo que abre o '
            'relógio, com a semântica de botão.',
            'Os dias usam `aria-labelledby` e rótulos por extenso ("segunda"…): no app, `Semantics(label:)` com o nome do '
            'dia, não a letra.',
            'A 360 a descrição do "Só se eu ainda não li hoje" fica num fio de navalha (0,31 com a próxima palavra, '
            'abaixo).',
        ],
        'subfases': ['Voltar e título', 'Cartão: cabeça com a chave e o horário', 'Dias da semana',
                     'Só se não leu e a prévia do aviso', VERIFICACAO],
    },
    'L30b_2_avisos_e_silencio': {
        'g': G, 'arquivos': ['features/notifications/presentation/reminders_screen.dart',
                             'core/design_system/widgets/app_switch.dart'],
        'contexto': 'Lembretes e avisos (30b), embaixo: "Avisar sobre" com 5 chaves (mensagens do clube, enquetes e '
                    'encontros, conquistas ligadas; sequência em risco e seguidores desligadas) e "Não incomodar" das 22:30 '
                    'às 07:00, com a nota de que o cronômetro continua.',
        'leitura': [
            'Os dois cartões como o do lembrete (padding 16, raio 24, borda 1,5, sombra 3/3), 14 entre eles.',
            '"AVISAR SOBRE" 11/800 ls 1,2; as linhas (padding 12/0, o tracejado 1,2 `#D9CCB4` entre elas, gap 12): o '
            'quadrado 38 de raio 12 na cor do tipo, o título 15/800, a descrição 12,5/600 `lh 1,35` e a chave.',
            'Não incomodar: a cabeça com o quadrado roxo `#552CB7` e a chave; a grade `1fr auto 1fr` (gap 10, 14 abaixo) '
            'com "DAS" e "ATÉ" (11/800, a caixa 6 abaixo) — as caixas de 50 com Bricolage 24 `tnum` — e a seta 18/800 '
            '18 abaixo do topo; a nota 12,5/600 `#6F665B`, 12 abaixo.',
            CHAVE_A,
            FONTES,
        ],
        'interacoes': [
            'Cada chave → liga ou desliga aquele tipo de aviso (grava na hora).',
            'Chave do não incomodar → liga ou desliga o silêncio; DAS e ATÉ → o relógio do sistema para trocar.',
        ],
        'dados': [
            'Os padrões da nota do design: clube, enquetes e encontros e conquistas ligados; sequência em risco e '
            'seguidores e curtidas desligados; silêncio das 22:30 às 7:00. Os avisos do clube e do social dependem do push '
            '(serviço a definir); sem ele, as chaves gravam a preferência e o texto não muda.',
            DADOS,
        ],
        'armadilhas': [
            DUAS_CHAVES,
            'A seta "→" não existe na Figtree 800: o Chromium usa a Inter ExtraBold do sistema (R8, abaixo). No app, a '
            'seta vem da família de reserva (como o "→" das dicas da 28c): ícone ou glifo embutido é pergunta da T17.',
            'As caixas do horário declaram o tamanho duas vezes (28 e 56, depois 24 e 50): valem os últimos, 24 e 50.',
        ],
        'subfases': ['Avisar sobre (as 5 chaves)', 'Não incomodar: chave, das, até e a nota', VERIFICACAO],
    },
    'L30c_tudo_em_dia': {
        'g': G, 'arquivos': ['features/notifications/presentation/notifications_empty.dart',
                             'features/notifications/presentation/notifications_top_bar.dart'],
        'contexto': 'Notificações, tudo em dia (30c): o topo com o "marcar tudo como lido" apagado, o desenho do sininho '
                    'dormindo em cima do livro, "Tudo em dia.", o que vai aparecer ali, "Ajustar lembretes" e o lembrete '
                    'marcado para 21:30.',
        'leitura': [
            'O topo e o título da 30 (a tabela "Diferenças"); o marcar como lido com opacidade 0,35 (`disabled`).',
            'O desenho 230 × 200 centrado, 34 abaixo do topo (`overflow: visible`, o livro com a sombra dura).',
            '"Tudo em dia" Bricolage 28/800 ls −0,7 + o "." Instrument Serif 34, centrado, 22 abaixo; o texto 14,5/600 '
            '`lh 1,45` `#5B544B`, `max-width 290`, `text-wrap: pretty`, 10 abaixo.',
            '"Ajustar lembretes" 24 abaixo: pílula de 50 com a largura do conteúdo (`fit-content`), padding 0/20, '
            '`#FFFAF1`, borda 1,5, sombra 2/2, a engrenagem 18 e 15/800.',
            'O lembrete 30 abaixo: padding 14/16, raio 20, tracejado 1,5 preto, o quadrado 44 `#FED170` e "Seu lembrete '
            'de leitura está marcado para 21:30." 13,5/600 com o horário em 800.',
            FONTES,
        ],
        'interacoes': [
            'Voltar → a tela anterior. Engrenagem e "Ajustar lembretes" → a 30b.',
            'Marcar tudo como lido → apagado (não responde; `onPressed: null`).',
        ],
        'dados': [
            'A 30c é o estado da 30 sem avisos (nenhum nos 30 dias): mesma rota, outro conteúdo. O lembrete mostra o '
            'horário de verdade; com o lembrete desligado, o texto não tem prancha — pergunta da T17.',
            'Com tudo lido, o sino da Início fica sem a bolinha coral (a nota do design).',
            DADOS,
        ],
        'armadilhas': [
            'O apagado é opacidade 0,35 que a referência não guarda (só a caixa): no app, `Opacity` no botão inteiro, '
            'com a semântica de desabilitado.',
            'A seção do vazio não tem contêiner (o desenho, o título, o texto, o botão e o lembrete soltos): a caixa é a '
            'união dos ids de topo.',
            'O desenho sai da própria caixa (`overflow: visible`): `Clip.none`.',
        ],
        'subfases': ['Topo com o marcar como lido apagado', 'Desenho, título e texto', 'Ajustar lembretes e o lembrete',
                     VERIFICACAO],
    },
}

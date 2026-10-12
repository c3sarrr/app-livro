"""T13.12 — notas escritas à mão das fases L da T16: a Entrada — Abertura (35), Login (07), Cadastro (08), Entrar (09,
09b), Código (10), Nova senha (11), Onboarding (12, 13, 13b, 14, 15, 16) e a Início no primeiro acesso (36a). A parte
medida é gerada por `gen_fases.py` (`CONJUNTO=projeto`); as notas do design ficam em `docs/design/projeto/NOTAS.md`
(estados-flutter, login-google-slot, cadastro-flutter, entrar-flutter, codigo-flutter, novasenha-flutter,
onboarding-flutter). A conta já existe desde a G05 (`features/account/`, D-69: entrar, idade e @): a T16 troca o desenho
e mantém a autenticação.
"""
from fases_notas_projeto_comum import DADOS, FONTES, VERIFICACAO, sem_destino

G = 'T16'
D243B = ('sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em '
         '`docs/design/estados_sem_design.md`) — confirmar na pergunta da T16 (ROTEIRO §2b)')
FOLHA = ('A folha da entrada: `left/right/bottom 10` (e um `top` por tela), padding 24–26/20/20, raio 32/32/44/44, '
         '`#FFFAF1`, borda 1,5, sombra dura 0/4, coluna. O título é sempre Bricolage 32/800 `lh 0,98` ls −1 + quebra + '
         'Instrument Serif itálico 40–42 ls −0,4, e o texto de baixo 14,5/500 `lh 1,4–1,45` `#5B544B`, 8 abaixo.')
CAMPO = ('Campos: rótulo 13,5/800 `lh 18`; a caixa de 52, 6 abaixo, raio 16, borda 1,5, padding 0/16 (0/4/0/16 com o '
         'olho de 44), texto 16/600; o campo em foco é `#FFFAF1` com o anel `{{brand}}` de 4 (`box-shadow 0 0 0 4`), os '
         'outros `#F7F0E3`.')
VOLTAR = ('O voltar (48, `left 16 · top 58`, `#FFFAF1`, borda 1,5, sombra 2/2, seta 20 traço 2,2) fica por cima de tudo '
          '(`z-index 2`).')
TOPO_ONB = ('O topo do Onboarding: 48 de altura, gap 12 — "1 de 4" (pílula de 36, 13/800 `tnum`), a barra ondulada de 16 '
            '(`flex 1`, hachura `#E9DFCC`/`#FFFAF1` 3/7, preenchimento `{{progress}}` com a ponta ondulada) e "Pular" '
            '(pílula de 36, 13,5/800). A partir do passo 2 entra o voltar à esquerda e a pílula e o Pular perdem 1 de '
            'padding (a tabela "Diferenças").')

NOTAS = {
    'L35_abertura': {
        'g': G, 'arquivos': ['features/account/presentation/entry/splash_screen.dart',
                             'features/account/presentation/entry/stamp_badge.dart',
                             'features/account/presentation/entry/wordmark.dart'],
        'contexto': 'Abertura (35): o fundo de ondas, o carimbo amarelo "LEIA · GRIFE · CONVERSE" que pousa no meio com os '
                    'risquinhos de impacto, dois brilhos, a marca "Booknest" na etiqueta girada e a barrinha de carregar '
                    '(só se demorar mais de 1 s).',
        'leitura': [
            'Ondas: o SVG de viewBox 390 × 640 esticado em 390 × 844 (`preserveAspectRatio="none"`): no app, `BoxFit.fill` '
            'na altura da tela (o mapa de widgets).',
            'Carimbo: área 260 × 260 em `left 50% − 130 · top 210`; os raios de impacto (SVG 260, traços pretos 2,6) e, '
            'em `left/top 25`, o selo 210 × 210 (viewBox 124) girado −8°, com o texto em volta do círculo.',
            'Brilhos: creme 30 em `left 52 · top 196` e preto 20 em `left 318 · top 470`.',
            'Marca em top 520, centrada: padding 10/26/14, raio 24, `#FFFAF1`, borda 1,5, sombra 5/5, girada −3°, `lh 1`: '
            '"Book" Bricolage 46/800 ls −1,8 + "nest" Instrument Serif itálico 56 ls −0,8 (rótulo "BookNest").',
            'Barrinha em top 660: 120 × 12, centrada, hachura `#E9DFCC`/`#FFFAF1`, borda 1,5, o coral até 60 % com a ponta '
            'ondulada (`role=progressbar`, "Carregando").',
            FONTES,
        ],
        'interacoes': [
            'Sem toque. A animação (nota do design): o carimbo entra girando, encolhe de 1,15 para 1 e bate com um tremor '
            'curto, os risquinhos e vibração leve; depois sobe a marca. Total ≈ 1,2 s; a barrinha só aparece depois de '
            '1 s carregando; com o app em segundo plano, não mostra.',
            'O primeiro quadro é o splash nativo estático (fundo creme + carimbo, `flutter_native_splash`) e a animação '
            'continua no Flutter (`AnimationController`).',
        ],
        'dados': ['Nenhum dado: o progresso da barrinha é o carregamento do app (banco, sessão).'],
        'armadilhas': [
            'O texto do selo corre num `<textPath>` que o flutter_svg não faz: o desenho sem o texto e as letras '
            'distribuídas no arco por um pintor (ver o mapa de widgets).',
            'O selo do splash nativo é uma imagem estática: o primeiro quadro do Flutter tem de cair exatamente em cima '
            'dele (mesma posição e tamanho), senão a troca pula.',
            'A 360 as ondas (largura fixa 390) saem 30 do quadro (abaixo): decidir na T16 se acompanham a largura.',
        ],
        'subfases': ['Ondas e a marca', 'Carimbo (pintor do arco de letras) e brilhos', 'Animação de 1,2 s e a barrinha '
                     'depois de 1 s', 'Splash nativo igual ao 1º quadro', VERIFICACAO],
    },
    'L07_1_fundo_e_marca': {
        'g': G, 'arquivos': ['features/account/presentation/entry/login_screen.dart',
                             'features/account/presentation/entry/entry_waves.dart'],
        'contexto': 'Login (07), em cima: as ondas (as mesmas da 35, em 390 × 860), a capa ilustrada do Dom Casmurro '
                    '("olhos de ressaca") girada −12°, o selo "LEIA · GRIFE · CONVERSE" girado 12°, dois brilhos e a marca '
                    'Booknest na etiqueta.',
        'leitura': [
            'Ondas em 390 × 860 a partir do topo (sem esticar).',
            'Capa 104 × 156 em `left 30 · top 112`, raio 4/10/10/4, borda 1,5, sombra 4/4, girada −12°: o desenho do Dom '
            'Casmurro (o da Início, com o olho e o mar) e a lombada de 7 `rgba(0,0,0,.22)`.',
            'Selo 124 × 124 em `right 26 · top 104`, girado 12°; brilhos creme 34 (`left 300 · top 248`) e preto 20 (`left '
            '44 · top 286`).',
            'Marca em top 282, centrada: a mesma etiqueta da 35 (padding 10/26/14, raio 24, sombra 5/5, −3°).',
            FONTES,
        ],
        'interacoes': ['Nenhum toque nesta faixa (é decoração; tudo `aria-hidden`, salvo a marca).'],
        'dados': ['Nenhum dado.'],
        'armadilhas': [
            'A capa usa o desenho da Início com `<text>` e `slice`: `AppSvg` sem os textos e os textos em `AppText` (o '
            'mapa de widgets).',
            'As ondas e a marca são as mesmas da 35, 238 mais acima (a referência confere): um widget só de ondas e um '
            'de marca, com a posição por tela.',
        ],
        'subfases': ['Ondas (componente da entrada)', 'Capa ilustrada e selo', 'Marca e brilhos', VERIFICACAO],
    },
    'L07_2_folha': {
        'g': G, 'arquivos': ['features/account/presentation/entry/login_screen.dart',
                             'features/account/presentation/entry/social_sign_in_buttons.dart'],
        'contexto': 'Login, a folha: "Sua história começa aqui.", o texto, os botões oficiais do Google e da Apple (claros), '
                    '"Cadastrar com e-mail" (preto), "Já tem conta? Entrar" e os termos.',
        'leitura': [
            FOLHA + ' Aqui: `left/right/bottom 10`, padding 24/20/20, título 32 + 40.',
            'Botões (coluna, gap 10, 18 abaixo do texto), 50 de altura: Google `#FFFFFF`, borda 1 `#747775`, texto '
            '15/500 ls 0,1 `#1F1F1F` (a fonte do Google); Apple `#FFFFFF`, borda 1 preta, 15,5/500 ls −0,2 (a do '
            'sistema); os lugares dos logos são quadrados tracejados 20 × 20 em `left 16`, centrados na altura.',
            '"Cadastrar com e-mail": 50, preto, borda 1,5, o envelope 20 `#F7F0E3` + 15,5/800.',
            '"Já tem conta? Entrar": linha de 44, 6 abaixo, 14/600 com o link 800 sublinhado; os termos 12/500 `lh 1,45` '
            '`#6F665B`, centrados, `text-wrap: pretty`, com os dois links 700 sublinhados (offset 2).',
            FONTES,
        ],
        'interacoes': [
            'Continuar com o Google → o login nativo do Google (`native_sign_in.dart`, G05).',
            'Continuar com a Apple → só no iOS (no Android o botão não aparece: a folha encolhe — confirmar o desenho sem '
            'ele na T16).',
            'Cadastrar com e-mail → o Cadastro (08); Entrar → Entrar com e-mail (09).',
            'Termos de Uso e Política de Privacidade → as páginas dos documentos (os endereços são da G25/G27).',
        ],
        'dados': ['Nenhum dado; a folha leva à autenticação que já existe (Supabase, G05).'],
        'armadilhas': [
            'Os botões sociais seguem o kit de marca oficial (nota login-google-slot): os quadrados tracejados são o lugar '
            'dos logos oficiais — usar os arquivos dos kits, sem redesenhar. No Flutter, `SignInWithAppleButton(style: '
            'whiteOutlined, iconAlignment: left)` já desenha o logo.',
            'O Google pede a Google Sans, que não está no Google Fonts: a prancha cai na Roboto 500; o app usa a Roboto '
            '500 embutida (T13.10) ou o botão oficial do pacote — pergunta da T16. O texto da Apple usa a fonte do '
            'sistema (R8, abaixo): o botão oficial resolve.',
            '`text-wrap: pretty` nos termos: as quebras da tabela são as do Chromium — conferir no app.',
        ],
        'subfases': ['Folha com o título e o texto', 'Botões oficiais do Google e da Apple (kits de marca)',
                     'Cadastrar, Entrar e os termos', VERIFICACAO],
    },
    'L08_cadastro': {
        'g': G, 'arquivos': ['features/account/presentation/entry/sign_up_screen.dart',
                             'features/account/presentation/entry/library_card_preview.dart',
                             'features/account/presentation/entry/password_strength.dart'],
        'contexto': 'Cadastro por e-mail (08): o voltar, a carteirinha que se preenche com o nome enquanto a pessoa digita '
                    '(girada 5°) e a folha — "Crie sua conta.", Nome, E-mail (com o visto de válido), Senha em foco com o '
                    'olho, a barra de força, as regras, as novidades por e-mail e "Criar conta".',
        'leitura': [
            VOLTAR + ' O brilho creme 26 em `left 96 · top 104`.',
            'Carteirinha 172 × 108 em `right 20 · top 60`, raio 12, borda 1,5, sombra 4/4, girada 5°, `z-index 3`: o '
            'cabeçalho de 26 em `{{card}}` com "CARTEIRINHA DE LEITORA" 9/800 ls 1,1 e o brilho; as linhas pautadas '
            '(`#EAE1D0` a cada 18), "Marina Costa" Instrument Serif itálico 23 ls −0,3 e "Nº 0052 · DESDE 2026" 9/800 '
            'ls 0,8; o carimbo roxo 36 girado −14° saindo 9 por baixo.',
            FOLHA + ' Aqui: `top 150`, padding 26/20/20.',
            CAMPO + ' O e-mail tem o visto 24 `#ABCF82`; a senha mostra os pontos 18/800 ls 2,5 e o cursor 2 × 22 (o input '
            'real é escondido).',
            'Força: a barra de 14 (hachura, o verde até 76 % com a ponta ondulada) e "Forte" 13/800, 12 abaixo; as regras '
            '(flex-wrap, gap 6/14) com o visto em círculo 16 e 12,5/600 `#3E3832`; a caixa das novidades 22 × 22 (raio 7, '
            '`#F7F0E3`) desmarcada, 13,5/600, linha de 44.',
            '"Criar conta": 54, preto, 16/800 com a seta 20, 8 abaixo; os termos 12/500, 12 abaixo.',
            FONTES,
        ],
        'interacoes': [
            'A carteirinha atualiza o nome enquanto a pessoa digita (nota do design).',
            '`AutofillGroup` com name / email / newPassword; `TextInputAction.next` entre os campos; teclado de e-mail; '
            'o olho mostra a senha.',
            'Criar conta → cria a conta (G05) e vai direto para o Onboarding (12). Com o teclado aberto, o formulário rola '
            'e o botão fica visível.',
            'Voltar → o Login.',
        ],
        'dados': ['Nome, e-mail e senha digitados; a força da senha calculada no app (ex.: zxcvbn, nota do design); o '
                  'número da carteirinha ("Nº 0052", a revisão de consistência) vem da conta.', DADOS],
        'armadilhas': [
            'O brilho do cabeçalho da carteirinha encolhe no flex (12 → 9,97, ver o mapa de widgets): decidir na T16.',
            'O campo da senha desenha os pontos e o cursor: o `TextField` real fica escondido (opacidade 0) e os pontos '
            'são texto 18/800 ls 2,5 — o número de pontos acompanha o tamanho da senha.',
            'A conta da G05 pede a idade (D-69) e a prancha não tem esse passo: onde ele entra no fluxo novo é pergunta da '
            'T16.',
        ],
        'subfases': ['Carteirinha ao vivo', 'Folha: nome, e-mail e senha', 'Força, regras e novidades',
                     'Criar conta → Onboarding', VERIFICACAO],
    },
    'L09_entrar': {
        'g': G, 'arquivos': ['features/account/presentation/entry/sign_in_email_screen.dart'],
        'contexto': 'Entrar com e-mail (09): o voltar, o selo "DE VOLTA À LEITURA · BOOKNEST" girado −10°, dois brilhos e '
                    'a folha — "Que bom te ver de novo.", E-mail, Senha (com "Esqueci a senha"), Entrar, o "ou" e "Receber '
                    'código por e-mail", e "Ainda não tem conta? Criar conta" no pé.',
        'leitura': [
            VOLTAR + ' Selo 132 × 132 em `right 30 · top 78`, girado −10°, na cor `{{badge}}`; brilhos creme 30 e preto 18.',
            FOLHA + ' Aqui: `top 242`, padding 26/20/12.',
            CAMPO + ' "Esqueci a senha" 13,5/800 sublinhado na linha do rótulo da senha, com área de toque de 44 '
            '(`margin −13 −8 −13 0`).',
            '"Entrar": 54, preto, 18 abaixo; o "ou" Instrument Serif itálico 19 `#5B544B` entre dois traços de 1,5 '
            '`#E2D7C4` (gap 12), 14 abaixo; "Receber código por e-mail" 52, `#FFFAF1`, borda 1,5, sem sombra, envelope 20 '
            '+ 15,5/800, 14 abaixo.',
            'O pé "Ainda não tem conta? Criar conta" (44) vai para o fundo da folha (`margin-top: auto`).',
            FONTES,
        ],
        'interacoes': [
            '`AutofillGroup` com email / password (o gerenciador de senhas preenche).',
            'Entrar → entra e vai para a Início; a sessão fica salva (nota do design). Senha errada → a 09b.',
            'Esqueci a senha e Receber código por e-mail → a mesma tela do código (10).',
            'Criar conta → o Cadastro (08); voltar → o Login.',
        ],
        'dados': ['E-mail e senha; a autenticação da G05.'],
        'armadilhas': [
            'O selo usa `<textPath>` e a cor `{{badge}}` (o mapa de widgets): o mesmo pintor de arco da 35 e da 07.',
            'O pé fica no fundo da folha: a folha tem `top` e `bottom` fixos e o conteúdo é coluna — no app, `Spacer`/'
            '`Expanded` antes do pé; com o teclado aberto, o pé sobe com a rolagem.',
        ],
        'subfases': ['Selo e brilhos', 'Folha: e-mail, senha e Esqueci a senha', 'Entrar, "ou" e código por e-mail',
                     'Pé "Criar conta"', VERIFICACAO],
    },
    'L09b_senha_incorreta': {
        'g': G, 'arquivos': ['features/account/presentation/entry/sign_in_email_screen.dart'],
        'contexto': 'Entrar com a senha incorreta (09b): o campo da senha rosado com a sombra coral, o aviso "Senha '
                    'incorreta. Tente de novo ou entre com um código." e o botão do código em amarelo, para mostrar a '
                    'saída. O resto é a 09.',
        'leitura': [
            'Campo da senha: `#FFE9E4`, borda 1,5, sombra dura coral `3/3 #FF552E` (no lugar do anel de foco), os pontos '
            'sem o cursor ocupando o campo (260 de largura).',
            'Aviso, 12 abaixo (`role=alert`): o "!" num círculo coral 20 (12/900 → 800) e o texto 13,5/700 `lh 1,4` '
            '`#1A1714`, gap 8, `align-items: flex-start` (o círculo sobe 1).',
            '"Entrar" 16 abaixo do aviso (não 18); "Receber código por e-mail" em `#FED170` com sombra 3/3.',
            'O aviso faz o formulário crescer 47,8 (T13.6): tudo abaixo desce, e o pé continua no fundo.',
            FONTES,
        ],
        'interacoes': [
            'A mensagem é lida pelo leitor de tela (`role=alert`, `aria-invalid` no campo).',
            'A volta ao campo normal não tem prancha: se o aviso some ao editar a senha ou só na próxima tentativa é '
            'pergunta da T16.',
            'Receber código por e-mail → a tela do código (10).',
        ],
        'dados': ['O erro vem da autenticação (senha errada); outros erros (sem rede, conta inexistente) não têm prancha — '
                  'os textos são da T24 (estados do app) ou pergunta da T16.'],
        'armadilhas': [
            'O "!" do círculo é Figtree 900, que renderiza 800 (D-246).',
            'Os pontos da senha sem cursor ocupam o campo inteiro (260): com uma senha longa, cortar ou reticências não '
            'têm prancha — o `TextField` real faz a rolagem do texto.',
        ],
        'subfases': ['Campo rosado com a sombra coral', 'Aviso anunciado', 'Botão do código em amarelo', VERIFICACAO],
    },
    'L10_codigo': {
        'g': G, 'arquivos': ['features/account/presentation/entry/otp_code_screen.dart',
                             'features/account/presentation/entry/otp_tiles.dart'],
        'contexto': 'Código de 6 dígitos (10): o voltar, o envelope com a carta saindo (o código "482 7••"), dois brilhos e '
                    'a folha — "Confira seu e-mail.", o e-mail mascarado, as 6 peças (4 8 2 – 7, a peça em foco e a '
                    'vazia), o reenviar com a contagem (0:42), a dica do spam e "Abrir app de e-mail".',
        'leitura': [
            VOLTAR + ' Envelope 238 × 200 (viewBox 190 × 160) em `left 112 · top 168`, girado −7°, na cor `{{env}}`, com a '
            'carta passando 16 acima da caixa.',
            FOLHA + ' Aqui: `top 428`, padding 26/20/20; o e-mail "m••••@email.com" em 800 `nowrap`.',
            'Peças, 22 abaixo, centradas: dois grupos de 3 (gap 8) com o traço 10 × 2,5 no meio (26 de largura). Peça 44 × '
            '56, raio 12, borda 1,5, sombra 3/3, o dígito Bricolage 28/800; a em foco sem sombra, com o anel `{{brand}}` '
            'de 4 e o cursor 2 × 26; a vazia `#F7F0E3` com a borda 1,5 `dashed #A99E8C`.',
            'Reenviar (44, 14 abaixo): o anel 22 girado −90° (trilho `#EAE1D0`, o `{{brand}}` com `dasharray 53,4` e '
            '`offset 16`) + "Reenviar código em **0:42**" 14/600 (o tempo 800 `tnum`).',
            '"Não chegou? Olhe a caixa de spam." 13/600 com o ícone 16, 10 abaixo; "Abrir app de e-mail" 54, preto, 12 '
            'abaixo.',
            FONTES,
        ],
        'interacoes': [
            'Um `TextField` invisível (`AutofillHints.oneTimeCode`, numérico, 6) desenhado como 6 peças; colar preenche '
            'todas; no 6º dígito verifica sem botão (nota do design).',
            'Reenviar libera depois de 60 s (o anel mostra o que falta).',
            'Abrir app de e-mail → `url_launcher`.',
            'Código certo: vindo de "Esqueci a senha" → a Nova senha (11); vindo de "Receber código" → a Início. Código '
            'errado não tem prancha — pergunta da T16.',
        ],
        'dados': ['O e-mail da pessoa mascarado (a regra da máscara: a 1ª letra e o domínio); o código enviado pelo '
                  'servidor (autenticação sem senha da G05).', DADOS],
        'armadilhas': [
            'O rótulo do código é só Semantics (o `<label>` escondido "Código de 6 dígitos"): as peças são `aria-hidden`.',
            'O envelope tem `<text>` com o código ("482 7••"): no app, o código digitado de verdade em `AppText`, os que '
            'faltam em •; e a carta passa 16 acima da caixa (`Clip.none`) — o mapa de widgets.',
            'A 360 os dois grupos passam 4,5 do pai (abaixo): as peças têm largura fixa (44) — decidir na T16 se encolhem.',
        ],
        'subfases': ['Envelope e brilhos', 'Seis peças sobre um campo invisível', 'Reenviar com a contagem',
                     'Spam e abrir o e-mail', VERIFICACAO],
    },
    'L11_nova_senha': {
        'g': G, 'arquivos': ['features/account/presentation/entry/new_password_screen.dart'],
        'contexto': 'Nova senha (11): o voltar, o cadeado aberto girado 8°, dois brilhos e a folha — "Crie uma senha nova." '
                    'para a conta, o campo com o olho, a força "Muito forte", as 3 regras, a chave "Sair dos outros '
                    'aparelhos" (ligada) e "Salvar e entrar".',
        'leitura': [
            VOLTAR + ' Cadeado 140 × 158 em `left 184 · top 72`, girado 8°, na cor `{{lock}}`.',
            FOLHA + ' Aqui: `top 278`, padding 26/20/20; o e-mail da conta em 800 `nowrap`.',
            CAMPO + ' Força: a barra com o verde até 88 % e "Muito forte"; as regras 8 ou mais caracteres, Um número ou '
            'símbolo e Diferente da senha antiga.',
            'Outros aparelhos, 14 abaixo: padding 12/12/12/16, raio 18, `#F7F0E3`, borda 1,5; "Sair dos outros aparelhos" '
            '14,5/800 e o texto 12,5/500; a chave 54 × 32 `{{brand}}` com a bolinha 24 e o visto (o desenho dos '
            'Lembretes, T17).',
            '"Salvar e entrar" 54, 16 abaixo; o aviso com o escudo 15 + "Você vai receber um aviso por e-mail." 12,5/600, '
            '12 abaixo.',
            FONTES,
        ],
        'interacoes': [
            '`AutofillHints.newPassword` e o e-mail num campo oculto (`username`), para o gerenciador salvar na conta '
            'certa (nota do design).',
            '"Diferente da senha antiga" é conferida pelo servidor (nota do design): quando a regra ganha o visto (ao '
            'digitar ou ao salvar) é pergunta da T16.',
            'Sair dos outros aparelhos: começa ligado; a pessoa pode desligar.',
            'Salvar e entrar → entra direto na Início com o aviso rápido "Senha nova salva"; o app manda o e-mail.',
        ],
        'dados': ['O e-mail da conta, a senha nova, a força calculada no app.'],
        'armadilhas': [
            'A chave é a de 54 × 32 com o visto (o desenho dos Ajustes e dos Lembretes), não a de 52 × 32 da Conta: ver '
            'a armadilha das chaves da T17.',
            'A 360 o brilho pequeno sai 4 do quadro (abaixo).',
        ],
        'subfases': ['Cadeado e brilhos', 'Senha, força e regras', 'Outros aparelhos (a chave)', 'Salvar e entrar',
                     VERIFICACAO],
    },
    'L12_1_topo_e_meta_diaria': {
        'g': G, 'arquivos': ['features/account/presentation/onboarding/onboarding_flow.dart',
                             'features/account/presentation/onboarding/onboarding_top_bar.dart',
                             'features/account/presentation/onboarding/goal_step.dart'],
        'contexto': 'Onboarding 1/4 — Meta (12), em cima: a faixa de ondas, o topo com "1 de 4", a barra ondulada e '
                    '"Pular" (sem voltar: a conta já existe), "Quanto você quer ler por dia?" e as 4 opções de minutos '
                    'com os despertadores (30 min marcado).',
        'leitura': [
            'Ondas: faixa 390 × 150 com máscara e a linha ondulada preta de 2 em y 122.',
            TOPO_ONB,
            'Título 36 abaixo: Bricolage 34/800 `lh 0,98` ls −1,1 + Instrument Serif itálico 46 ls −0,5; o brilho amarelo '
            '26 em `right 10 · top 40`; o texto 14,5/500, 10 abaixo.',
            'Opções (`radiogroup`, gap 10, 18 abaixo): cada uma com `min-height 74`, padding 10/14/10/12, raio 20, borda '
            '1,5, gap 14 — o despertador 54 (girado −7°, 5°, −5°, 6°), "30 min" Bricolage 20/800 + a descrição 13/600, e '
            'o rádio 26. A marcada: `{{brand}}`, sombra 3/3, a descrição preta e o rádio preto com o visto 13.',
            FONTES,
        ],
        'interacoes': [
            'Opção → escolhe os minutos por dia (uma só).',
            'Pular → usa os valores padrão e avança (nota do design).',
            'O `PageView` do Onboarding não arrasta: avança pelo botão, e a barra ondulada anima entre os passos.',
        ],
        'dados': ['Os minutos alimentam o cartão "Seu dia de leitura" da Início (`ReadingGoals`, `reading_goals.dart`); '
                  'textos neutros, sem pressionar.', DADOS],
        'armadilhas': [
            'Os despertadores desenham fora da própria caixa (os risquinhos, 2,3 de cada lado): `Clip.none` (o mapa de '
            'widgets).',
            'A faixa de ondas tem largura fixa (390): a 360 sai 30 (abaixo).',
        ],
        'subfases': ['Fluxo do Onboarding (PageView sem arrastar) e o topo', 'Título', 'Opções de minutos', VERIFICACAO],
    },
    'L12_2_meta_do_ano': {
        'g': G, 'arquivos': ['features/account/presentation/onboarding/goal_step.dart'],
        'contexto': 'Onboarding 1/4 — Meta, embaixo: o cartão amarelo "Livros em 2026 · Cerca de 2 por mês" com o menos, o '
                    '24 e o mais, e o "Continuar" no fundo.',
        'leitura': [
            'Cartão 16 abaixo das opções: padding 14/12/14/16, raio 22, `#FED170`, borda 1,5, sem sombra; "Livros em 2026" '
            '14,5/800 e "Cerca de 2 por mês" 12,5/600 `#3E3832`.',
            'Contador (gap 6): menos (44, `#FFFAF1`, borda 1,5, traço 2,6) — "24" Bricolage 30/800 ls −0,8 `tnum`, mín. '
            '48, `aria-live` — mais (44, preto, o "+" `#FED170`).',
            '"Continuar" 54, preto, seta 20, no fundo (`margin-top: auto`).',
            FONTES,
        ],
        'interacoes': ['Menos e mais → muda a meta do ano (limites e passo: pergunta da T16); "Cerca de 2 por mês" acompanha '
                       '(meta ÷ 12, arredondado).', 'Continuar → o passo 2 (13).'],
        'dados': ['A meta de livros do ano (`ReadingGoals`); o ano corrente no rótulo.'],
        'armadilhas': ['"Cerca de N por mês" com metas pequenas (menos de 12 no ano) não tem texto na prancha — pergunta '
                       'da T16.'],
        'subfases': ['Cartão da meta do ano', 'Continuar no fundo', VERIFICACAO],
    },
    'L13_generos': {
        'g': G, 'arquivos': ['features/account/presentation/onboarding/genres_step.dart'],
        'contexto': 'Onboarding 2/4 — Gêneros (13): "O que você gosta de ler?", 15 gêneros em pílulas (4 escolhidos) e '
                    '"Mais gêneros", a lista apagando embaixo, e o "Continuar" com a contagem (4).',
        'leitura': [
            'O topo da 12 com o voltar e "2 de 4" (a tabela "Diferenças"); título Bricolage 34/800 + "gosta de ler?" '
            'Instrument Serif 46, o brilho rosa 24.',
            'Gêneros (flex-wrap, gap 9/8, 18 abaixo; `flex 1`, `overflow: hidden`, `padding-bottom 20`, a máscara que '
            'apaga os últimos 26): pílulas de 44, padding 0/14/0/7, gap 8, borda 1,5, 14/700 — o círculo 28 com o ícone '
            '15 do gênero (verde, rosa ou amarelo) ou, escolhido, o círculo preto com o visto 14 e o fundo `{{brand}}` com '
            'sombra 2/2.',
            '"Mais gêneros": pílula tracejada (borda 1,5 `dashed`) com o "+" 18.',
            '"Continuar" 54, 8 abaixo, com a contagem numa pílula de 24 `{{brand}}` (borda 1,5 `#F7F0E3`, 12,5/800).',
            FONTES,
        ],
        'interacoes': [
            'Gênero → marca e desmarca (checkbox); no mínimo 3: abaixo de 3, o botão fica apagado com "Escolha mais N" '
            '(nota do design; o estado apagado não tem prancha — o texto segue a nota).',
            'Mais gêneros → a lista completa: ' + D243B + '.',
            'A lista rola com o botão fixo embaixo.',
        ],
        'dados': ['Os gêneros escolhidos alimentam o "Para você" e as sugestões do passo 3; a lista de gêneros é a da Busca '
                  '(28).'],
        'armadilhas': [
            'A 3ª fileira (Mistério, Suspense, Terror) termina 0,97 antes da borda: com o texto um pouco mais largo o '
            '"Terror" desce e 15 ids descem junto (D-278, abaixo).',
            'A máscara apaga a lista por cima do que passa: `ShaderMask` no `Wrap` dentro de uma área rolável.',
        ],
        'subfases': ['Topo com voltar', 'Pílulas de gênero (Wrap) com a máscara', 'Continuar com a contagem e o mínimo de 3',
                     VERIFICACAO],
    },
    'L14_1_busca': {
        'g': G, 'arquivos': ['features/account/presentation/onboarding/first_books_step.dart'],
        'contexto': 'Onboarding 3/4 — Primeiros livros (14), em cima: "Comece sua estante.", o texto, a busca por título, '
                    'autor ou ISBN e o botão amarelo do Scanner.',
        'leitura': [
            'O topo com "3 de 4" e a barra em 75 %; título Bricolage 34/800 + "estante." Instrument Serif 46, o brilho '
            'verde 24; o texto 14,5/500.',
            'Busca, 16 abaixo (gap 10): a pílula de 52 (`flex 1`, padding 0/16, gap 10, lupa 20, texto 15/500) e o '
            'Scanner, círculo 52 `#FED170` com sombra 2/2 e o ícone 24.',
            FONTES,
        ],
        'interacoes': [
            'Busca → por título, autor ou ISBN (a busca do catálogo da T15); onde o resultado aparece aqui não tem '
            'prancha — pergunta da T16.',
            'Scanner → o Scanner; volta para o passo 3 com o livro adicionado.',
        ],
        'dados': ['O catálogo (T15) para a busca.'],
        'armadilhas': ['"Título, autor ou ISBN" é o `placeholder` (cor padrão do Chromium): `hintText` com a cor da '
                       'referência @3x.'],
        'subfases': ['Título e texto', 'Busca e Scanner', VERIFICACAO],
    },
    'L14_2_sugestoes': {
        'g': G, 'arquivos': ['features/account/presentation/onboarding/first_books_step.dart',
                             'features/account/presentation/onboarding/suggestion_cover.dart'],
        'contexto': 'Onboarding 3/4: "Sugestões para você · dos seus gêneros" — 6 capas em grade de 3 (3 já na estante, '
                    'com o visto lavanda e a sombra; 3 com o "+"), a grade apagando embaixo, e o "Continuar" com a contagem.',
        'leitura': [
            '"Sugestões para você" Bricolage 18/800 ls −0,3 e "dos seus gêneros" 12,5/700, 20 abaixo da busca.',
            'Grade de 3 (gap 20/12, 16 abaixo; padding 8/8/0/0 e `margin-right −8`, para o selo caber; máscara nos '
            'últimos 22): capas de 152 de altura (largura da coluna), raio 4/9/9/4, borda 1,5, a lombada de 7, título '
            'Instrument Serif 19 `lh 0,92` + autor 5,5/700.',
            'Na estante: sombra 3/3 e o selo 30 `{{brand}}` com o visto 14 em `right/top −8`; fora: sem sombra e o selo '
            '`#FFFAF1` com o "+" 14.',
            '"Continuar" com a contagem (3).',
            FONTES,
        ],
        'interacoes': [
            'Capa → adiciona ou tira da estante (o círculo vira visto lavanda e a capa ganha sombra); `aria-pressed` e o '
            'rótulo "Adicionar…"/"Remover… da estante".',
            'Continuar → o passo 4 (15). Não é obrigatório adicionar livros.',
            'Ao chegar no passo 3 pela primeira vez, a dica do scanner (13b).',
        ],
        'dados': ['Sugestões vindas dos gêneros escolhidos (o catálogo); o status com que os adicionados entram na estante é '
                  'pergunta da T16.', DADOS],
        'armadilhas': [
            'As capas da fixture são CSS (círculos, bolinhas, listras): com dados reais, a capa do catálogo (D-79).',
            'O selo passa 8 da capa: a grade tem o recuo de 8 à direita e no topo para o selo não ser cortado — no app, '
            '`Clip.none` ou o mesmo recuo.',
        ],
        'subfases': ['Grade de sugestões com a máscara', 'Selo de adicionar e tirar', 'Continuar com a contagem',
                     VERIFICACAO],
    },
    'L13b_dica_scanner': {
        'g': G, 'arquivos': ['features/account/presentation/onboarding/scanner_tip_overlay.dart'],
        'contexto': 'A dica do scanner (13b), por cima do passo 3: o escuro com o círculo de luz no botão amarelo, o anel '
                    'tracejado, a seta desenhada, "é aqui!" e o bilhete com a fita — "Tem o livro na mão?", Entendi e '
                    'Testar agora.',
        'leitura': [
            'Escuro: o círculo 76 em `left 286 · top −12` (relativo à busca) com `box-shadow: 0 0 0 1400px '
            'rgba(26,23,20,.82)`; o anel tracejado 90 (borda 2 `dashed #FFFAF1`) em volta.',
            'Seta: SVG 350 × 140 com a curva e a ponta em creme (traço 2,6 e 2,8).',
            '"é aqui!" em `left 92 · top 62`: pílula `#FED170`, padding 3/14/7, sombra 2/2, Instrument Serif itálico 25, '
            'girada −6°.',
            'Bilhete em top 146: padding 22/18/18, raio 24, `#FFFAF1`, borda 1,5, sombra 4/4, girado −1,5°; a fita 78 × 24 '
            '`{{brand}}` a 0,85 em cima (girada 3°); o livro de costas 46 × 60 girado −6°, "Tem o livro" Bricolage 22/800 '
            '+ "na mão?" Instrument Serif 26 e o texto 14/500; os botões de 48 (gap 10): Entendi (`flex 1`) e Testar '
            'agora (`flex 1,35`, preto, o ícone 18 amarelo).',
            FONTES,
        ],
        'interacoes': [
            'Aparece uma vez só, ao chegar no passo 3 (a flag fica salva no aparelho).',
            'Testar agora → o Scanner; Entendi → fecha e não mostra de novo; tocar fora do bilhete também fecha.',
            '`role=dialog` modal com título e texto ligados.',
        ],
        'dados': ['A flag "dica vista" no aparelho.'],
        'armadilhas': [
            'O círculo de luz é um `CustomPainter` com recorte (nota do design), no lugar exato do botão do Scanner da 14: '
            'calcular pela posição real do botão (não fixa).',
            'A 360 o círculo, o anel e a seta passam do quadro (abaixo): a posição segue o botão.',
        ],
        'subfases': ['Escuro com o recorte no botão', 'Seta, "é aqui!" e o bilhete', 'Uma vez só (flag) e os toques',
                     VERIFICACAO],
    },
    'L15_foto_e_arroba': {
        'g': G, 'arquivos': ['features/account/presentation/onboarding/profile_step.dart'],
        'contexto': 'Onboarding 4/4 — Foto e @ (15): "Quase lá! Seu perfil.", o avatar com a inicial M (girado −5°) e a '
                    'câmera, "Escolher da galeria", o nome de usuário com o visto e "Disponível", a frase sobre você '
                    '(0/80) e "Criar minha carteirinha".',
        'leitura': [
            'O topo com "4 de 4" e a barra toda em `{{progress}}` (sem hachura nem ponta); título "Quase lá!" + "Seu '
            'perfil." Instrument Serif 46.',
            'Foto, 22 abaixo (gap 20): o avatar 112 (`{{avatar}}`, borda 1,5, sombra 4/4, girado −5°, "M" Instrument '
            'Serif itálico 66) e a câmera 44 preta com a borda 3 `#F7F0E3` em `right −6 · bottom −4`; ao lado, "Foto de '
            'perfil" 15/800 + "Opcional" (pílula 22, borda `#CFC3AE`), o texto 13/500 e "Escolher da galeria" (40).',
            'Usuário, 24 abaixo: o campo em foco (anel `{{brand}}`): "@" 16/800 `#8A8073`, "marinacosta" 16/700, o cursor e '
            'o visto 24; embaixo, "Disponível" (pílula `#E1EDD0`/`#2E5314`) + "Letras, números, ponto e _" 500 '
            '`#6F665B` (`role=status`).',
            'Frase, 22 abaixo: rótulo + "Opcional" + "0/80" 12/700 `tnum`; a área de 76 (padding 13/16, `#F7F0E3`) com o '
            'lápis 18 no canto; o texto 12,5/500, 8 abaixo. "Criar minha carteirinha" 54 com a estrela amarela, no fundo.',
            FONTES,
        ],
        'interacoes': [
            'Câmera e Escolher da galeria → `image_picker` (câmera ou galeria); sem foto, a inicial.',
            '@ sugerido pelo nome e conferido enquanto digita (~400 ms depois da última tecla); em uso → "Já em uso" e '
            'chips com ideias parecidas (nota do design; esse estado não tem prancha).',
            'Frase opcional até 80 caracteres, mostrada no Perfil.',
            'Criar minha carteirinha → a carteirinha pronta (16).',
        ],
        'dados': ['Nome (do cadastro), o @ (a regra e a checagem da G05, D-69), a foto e a frase.', DADOS],
        'armadilhas': [
            'O input do @ é o `TextField` escondido atrás do texto desenhado (o "marinacosta" é um `<span>`): o input usa a '
            'fonte do sistema no navegador (R8, abaixo), mas não aparece — no app, o texto desenhado vem do controller.',
            '"Ex.: Leio um capítulo antes de dormir." é o `placeholder` do `textarea` (cor padrão do Chromium).',
        ],
        'subfases': ['Avatar e foto', '@ com a checagem ao vivo', 'Frase sobre você', 'Criar minha carteirinha',
                     VERIFICACAO],
    },
    'L16_carteirinha': {
        'g': G, 'arquivos': ['features/account/presentation/onboarding/library_card_ready.dart',
                             'features/account/presentation/entry/library_card.dart'],
        'contexto': 'Carteirinha pronta (16): as ondas, os confetes (estrelinhas, bolinhas e tracinhos), a carteirinha '
                    'girada −3° com o avatar, o nome, o @, as metas, os gêneros e o código de barras, o carimbo roxo que '
                    'bate em cima e a folha — "Sua carteirinha está pronta!", Começar a ler e Compartilhar carteirinha.',
        'leitura': [
            'Confetes (seção sem contêiner, 10 peças soltas): 6 estrelinhas (16 a 26, giradas), as bolinhas coral 14 e '
            'creme 10 e os tracinhos verde 30 × 8 e lavanda 26 × 8 (girados −24° e 18°).',
            'Carteirinha 330 de largura em `left 30 · top 116`, raio 18, borda 1,5, sombra 6/6, girada −3°: o cabeçalho de '
            '36 `{{card}}` ("CARTEIRINHA DE LEITORA" 11/800 ls 1,4 e "Nº 0052" `tnum`); o corpo pautado a cada 24 '
            '(padding 16/16/14): o avatar 70 (girado −5°, "M" 42), "Marina Costa" Instrument Serif itálico 32 e '
            '"@marinacosta" 14/700.',
            'As metas, 14 abaixo, entre bordas tracejadas: "META DIÁRIA 30 min" e "META EM 2026 24 livros" (rótulo 9,5/800 '
            'ls 1,1; valor Bricolage 22/800), separadas por uma borda tracejada; os gêneros (pílulas de 24, 11,5/800) com '
            '"+1"; o código de barras 150 × 30 e "0052 · 2026 · BN" 9,5/800 ls 1,6.',
            'Carimbo 98 × 98 em `left 250 · top 336`, girado −12°.',
            'Folha (`left/right/bottom 10`, padding 24/20/20): "Sua carteirinha" Bricolage 30/800 + "está pronta!" '
            'Instrument Serif 40; "Boas-vindas ao BookNest, Marina. Sua estante já tem 3 livros."; Começar a ler (54, '
            'preto) e Compartilhar carteirinha (50, `#FFFAF1`), gap 10.',
            FONTES,
        ],
        'interacoes': [
            'A carteirinha entra girando de leve; o carimbo bate com um tremor e vibração (`HapticFeedback.mediumImpact`); '
            'as estrelinhas caem como confete (nota do design).',
            'Começar a ler → a Início.',
            'Compartilhar carteirinha → gera a imagem (`RepaintBoundary` → PNG) para os stories e abre o '
            'compartilhar do sistema.',
        ],
        'dados': ['Foto, nome, @, metas, 3 gêneros (+N) e o número da carteirinha (Nº 0052) da conta; "Sua estante já tem '
                  '3 livros" conta os do passo 3 (sem livros, o texto muda — pergunta da T16).', DADOS],
        'armadilhas': [
            'Os confetes são 10 elementos soltos (seção sem contêiner, a união das caixas): cada um com a sua posição e '
            'giro; no HTML literal saem um por linha (o gerador cortava junto os irmãos da mesma linha — corrigido na '
            'T13.12).',
            'O carimbo tem `<textPath>` ("LEITORA Nº 0052 · BOOKNEST ·") e desenha fora da caixa (as linhas de movimento, '
            '18,5 à esquerda): o pintor do arco, o número real e `Clip.none` (o mapa de widgets).',
            'O código de barras é decorativo (sócia), não um código de verdade.',
        ],
        'subfases': ['Confetes (as 10 peças)', 'Carteirinha (o componente da 08, completo)', 'Carimbo que bate',
                     'Folha: Começar a ler e Compartilhar (imagem)', VERIFICACAO],
    },
    'L36a_inicio_primeiro_acesso': {
        'g': G, 'arquivos': ['features/home/presentation/sections/first_book_card.dart',
                             'features/home/presentation/sections/first_day_goal_card.dart',
                             'features/home/presentation/sections/club_invite_entry.dart'],
        'contexto': 'A Início no primeiro acesso (36a), quando a estante ainda está vazia: o cabeçalho (lupa e sino), "Sua '
                    'história começa aqui.", o cartão lavanda "Coloque seu primeiro livro na estante" com Montar minha '
                    'estante e os atalhos, a meta de hoje (0 de 30 min) e a entrada do convite de clube.',
        'leitura': [
            'Cabeçalho da Início (48): o avatar 44 "M", "Boa noite," 13/500 + "Marina" 16/700, a lupa e o sino 48 (sem o '
            'ponto). Título 18 abaixo: Bricolage 38/800 `lh 0,98` ls −1,2 + "começa aqui." Instrument Serif 46.',
            'Cartão 18 abaixo: padding 16, raio 28, `#B6ACE4`, sombra 4/4, `overflow: hidden`; o desenho 130 × 110 em '
            '`right 8 · top 10` (3 lombadas tracejadas a 45 %, a tábua amarela e a estrela creme); "PRIMEIRO PASSO" '
            '11/800 ls 1,2 `#3B3466`; o título Bricolage 25/800 `max-width 190`; o texto 13,5/600 `#2F2A4A`.',
            '"Montar minha estante" 54, preto, 16 abaixo; os 3 atalhos de 44 (grade de 3, gap 8): Escanear `#FED170`, '
            'Buscar e E-book `#FFFAF1`, ícones 16–17 + 13/800.',
            'Meta de hoje, 16 abaixo: padding 14/16, raio 24, `#FED170`, sem sombra; o anel 58 com as marcas (`dasharray '
            '1,5 5` a 0,4) e o "0"; "Meta de hoje: 30 min" Bricolage 17/800 + o texto 12,5/600 `#4A3C17`.',
            'Convite, 12 abaixo: padding 12/14, raio 22, borda 1,5 `dashed`, o quadrado 44 rosa (raio 14) com as pessoas, '
            '"Recebeu um convite de clube?" 14,5/800 + "Cole o link ou leia o QR code" 12,5/600 e a seta 18.',
            'A navegação com a aba Início ativa (a tabela "Diferenças" da 36: os rótulos de Início e Biblioteca trocam de '
            'peso).',
            FONTES,
        ],
        'interacoes': [
            'Montar minha estante → a Biblioteca (a 36, vazia); Escanear → o Scanner; Buscar → a Busca (28); E-book → o '
            'importar.',
            'Lupa → a Busca (28, feita na T15); sino → como hoje na Início (a tela 30 chega na T17).',
            sem_destino(G, 'Convite de clube → colar o link ou ler o QR (o fluxo de convite, T23)'),
            'O cartão some sozinho quando o primeiro livro entra (nota do design).',
        ],
        'dados': ['Aparece quando a estante está vazia (a pessoa pulou o passo 3); a meta do dia (30 min) do Onboarding; o '
                  'nome e a saudação como na Início.', DADOS],
        'armadilhas': [
            'Na navegação, os rótulos de Início e Biblioteca trocam de largura (a aba marcada vai em 800 com ls −0,2): não '
            'fixar a largura dos rótulos.',
            'O "0" do anel é `<text>` (Bricolage 15/800): `AppText` (o mapa de widgets).',
            'A 360 o desenho do cartão invade o título (27, abaixo): o título tem `max-width 190` e o desenho é fixo.',
        ],
        'subfases': ['Estado "estante vazia" na Início (troca o herói)', 'Cartão do primeiro livro com os atalhos',
                     'Meta de hoje vazia', 'Convite de clube', VERIFICACAO],
    },
}

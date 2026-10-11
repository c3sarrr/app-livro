# Notas do projeto no Claude Design

> As notas que o design deixou ao lado das pranchas (muitas com orientação para o Flutter). Copiadas do `canvas.json`.

## cadastro-flutter (Page 8)

Flutter: AutofillGroup com AutofillHints.name / email / newPassword; TextInputAction.next entre os campos; teclado de e-mail. Com o teclado aberto, o formulário rola e “Criar conta” fica visível. Força da senha calculada no app (ex.: pacote zxcvbn). Caixa de novidades começa desmarcada. A carteirinha atualiza o nome enquanto a pessoa digita. Depois de criar a conta, vai direto para o Onboarding.

## codigo-flutter (Page 11)

Flutter: um único TextField invisível (AutofillHints.oneTimeCode, teclado numérico, 6 dígitos) desenhado como 6 peças; colar um código preenche todas. No iPhone, o código que chega no app Mail aparece sozinho acima do teclado. Ao digitar o 6º número, verifica sem precisar de botão. “Reenviar” libera depois de 60 s. “Abrir app de e-mail” usa url_launcher. Se a pessoa veio de “Esqueci a senha”, o próximo passo é criar nova senha; se veio de “Receber código”, entra direto no Início.

## cronometro-flutter (Page 14)

Cronômetro: tela escura para não brilhar ao lado do livro de papel (economiza bateria em telas OLED). O tempo continua com o app minimizado ou a tela bloqueada: notificação fixa no Android (serviço em primeiro plano) e Live Activity no iPhone (tela de bloqueio e Dynamic Island). O anel amarelo é a meta de hoje (26 de 30 min); a bolinha mostra até onde chegou. Durante a sessão: fotografar trecho, anotar um pensamento e som ambiente (chuva, café, lareira). “Encerrar” abre a pergunta opcional da página, com “Pular”. Fim da sessão (18b): folha que sobe por cima do cronômetro escurecido, com o resumo (tempo, meta do dia, sequência) e o carimbo verde quando a meta é batida (confete + vibração leve). A página vem sugerida pela última anotada; “−” e “+” ajustam e tocar no número abre o teclado numérico. “Pular a página” salva só os minutos.

## detalhes-flutter (Page 14)

Livro físico é o padrão (entra pelo Scanner): o app conta minutos, não páginas. “Iniciar leitura” abre um cronômetro (continua com a tela bloqueada, via notificação fixa); os minutos somam na meta diária e na sequência. Ao parar, pergunta a página com “Pular” — a página é sempre opcional. Grifos de livro físico: “Fotografar um trecho” usa a câmera + leitura de texto (OCR) no próprio aparelho, que funciona offline. E-book: o progresso salva sozinho e “Continuar lendo” abre o Leitor. Clima do livro: votos dos leitores (humor, ritmo, personagens x trama), estilo StoryGraph. Trocar capa: o selo redondo com a câmera no pé da capa deixa a pessoa fotografar a capa da edição que ela tem (a da base pode ser de outra edição), escolher da galeria ou voltar para a capa original. A foto fica só para ela.

## entrar-flutter (Page 10)

Flutter: AutofillGroup com AutofillHints.email / password, para o gerenciador de senhas preencher sozinho. Ao errar a senha, o campo fica rosado com sombra coral e a mensagem é lida pelo leitor de tela; o botão “Receber código por e-mail” passa para amarelo para mostrar a saída. “Esqueci a senha” e “Receber código” levam para a mesma tela de código de 6 dígitos. A sessão fica salva: a pessoa não precisa entrar de novo a cada abertura do app.

## home-fisico (Page 1)

Início revisada para livro físico: o destaque mostra o e-book (Dom Casmurro) com selo E-BOOK e “Continuar lendo”; em “Também lendo”, livros de papel mostram um botão ▶ que abre o cronômetro direto, e a etiqueta “Papel · 3h 40min” (minutos) ou “Papel · pág. 344” (quando a pessoa anotou a página). No cartão amarelo, “Ler agora” abre o cronômetro com o último livro físico. Quando uma sessão estiver rodando, aparece uma barrinha “● Lendo Brás Cubas · 08:42” logo acima da navegação. A lupa no topo (ao lado do sino) abre a Busca (28).

## leitor-flutter (Page 15)

Leitor (e-book). Modo limpo: papel creme (#F8F1E4), Literata 20,5 px, entrelinha 1,72, margens de 28 px (≈ 35–40 caracteres por linha). Alinhado à esquerda (o Flutter não hifeniza sozinho; justificado abre “rios”). Sem capítulo: só “pág. 159 de 256” e “62%” bem apagados embaixo — página e porcentagem sempre existem no e-book. Toque na borda direita avança, na esquerda volta e no meio mostra os controles. Com controles: o texto esmaece e aparecem duas ilhas flutuantes — em cima, voltar, título, busca e marcador (fita coral = página marcada); embaixo, a barra em onda para arrastar até outra página (balão com o número), “62% do livro” e o tempo restante, e os atalhos Fonte, Tema, Grifos (12), Anotar e Sumário. No e-book o tempo conta sozinho para a meta (selo amarelo “18 min hoje”). Os controles somem após 3 s sem toque. Trecho na prancha: “Olhos de ressaca” (domínio público). Seleção de texto: segurar uma palavra seleciona; as alças roxas (#552CB7) ajustam o começo e o fim. O menu flutua acima do trecho (ou abaixo, se não couber): GRIFAR em 4 cores + sublinhado ondulado coral, e Nota, Copiar, Compartilhar (gera um cartão com a citação) e Buscar no livro. Grifos já salvos aparecem como marca-texto na metade de baixo da linha. Flutter: SelectableText.rich com contextMenuBuilder próprio.

## login-google-slot (Page 7)

Botões sociais (tema claro oficial). Google: fundo #FFFFFF, borda 1px #747775, texto #1F1F1F. Apple (só no iOS): estilo “white outline”, borda 1px #000, texto preto; no Flutter, SignInWithAppleButton(style: whiteOutlined, iconAlignment: left) já desenha o logo. Os quadrados tracejados (20×20) são o lugar dos logos oficiais: usar os arquivos dos kits de marca, sem redesenhar.

## novasenha-flutter (Page 12)

Flutter: campo com AutofillHints.newPassword e o e-mail num campo oculto (AutofillHints.username), para o gerenciador salvar a senha na conta certa. Um campo só, com o olho para mostrar a senha (igual ao Cadastro). A regra “Diferente da senha antiga” é conferida pelo servidor. “Sair dos outros aparelhos” começa ligado e a pessoa pode desligar. Ao salvar, entra direto no Início com um aviso rápido “Senha nova salva”, e o app manda um e-mail avisando da troca.

## onboarding-flutter (Page 13)

Onboarding em 4 passos + final: 1 Meta de leitura · 2 Gêneros · 3 Primeiros livros · 4 Foto e @ · Carteirinha pronta. Flutter: PageView sem arrastar (avança pelo botão), barra em onda animada entre os passos. Sem botão voltar no passo 1, porque a conta já existe. “Pular” usa os valores padrão. Os minutos alimentam o cartão amarelo “Seu dia de leitura” da Início; os textos são neutros, sem pressionar a pessoa. Passo 2: no mínimo 3 gêneros; o número no botão conta os escolhidos e, abaixo de 3, o botão fica apagado com “Escolha mais N”. A lista rola com o botão fixo embaixo; “Mais gêneros” abre a lista completa. Passo 3: sugestões vêm dos gêneros escolhidos; tocar na capa adiciona (círculo vira check lavanda e a capa ganha sombra). A lupa busca por título, autor ou ISBN, e o botão amarelo abre o Scanner. Não é obrigatório adicionar livros. Dica do scanner (13b): aparece uma vez só, ao chegar no passo 3. Tela escurecida com um círculo de luz no botão amarelo (CustomPainter com recorte), bilhete com fita e seta desenhada. “Testar agora” abre o Scanner; “Entendi” fecha e não mostra de novo (salvar a flag no aparelho). Tocar fora do bilhete também fecha. Passo 4: foto opcional (image_picker: câmera ou galeria); sem foto, avatar com a inicial. O @ vem sugerido a partir do nome e é conferido enquanto a pessoa digita (espera ~400 ms depois da última tecla); se já estiver em uso, mostra “Já em uso” e chips com ideias parecidas. Frase de leitora opcional (até 80 caracteres), mostrada no Perfil. Final: a carteirinha entra girando de leve e o carimbo roxo “bate” com um pequeno tremor e vibração (HapticFeedback.mediumImpact); estrelinhas caem como confete. Mostra foto, nome, @, metas, 3 gêneros (+N) e um código de barras de sócia decorativo. “Começar a ler” vai para a Início; “Compartilhar carteirinha” gera uma imagem (RepaintBoundary → PNG) para os stories.

## anotacao-flutter (Page 15)

Modo anotação (22): entra pelo atalho “Anotar” dos controles e sai em “Concluir”. Enquanto ele está ligado, o texto fica travado (não muda de fonte nem de quebra de linha) e 1 dedo desenha; 2 dedos movem a página (para escrever perto do rodapé) e viram a página. Ilha embaixo, na zona do polegar: as ferramentas parecem objetos de verdade guardados na barra — Caneta, Marcador, Borracha, Laço (seleciona e move traços), Reta (linha reta) e Espaço (abre lugar para escrever entre as linhas); a ativa sobe 12 px e o nome ganha a pílula lavanda. Linha de baixo: o poço de cor (anel com todas as cores em volta da cor atual, abre a mesma roda da seleção), 3 espessuras, Desfazer e Refazer (apagado quando não há o que refazer). Tocar de novo na ferramenta ativa abre os ajustes dela. Na prancha: marcador amarelo à mão livre, círculo e ondinhas com a caneta coral, linha reta dupla e um traço ondulado sendo desenhado agora (bolinha = ponta, círculo tracejado = dedo). Flutter: CustomPainter com traços suavizados que variam a espessura com a velocidade/pressão (pacote perfect_freehand); com caneta stylus, a mão apoiada na tela é ignorada (só PointerDeviceKind.stylus desenha). Cada traço é salvo preso ao trecho do texto (posição no e-book + deslocamento), não ao pixel, para continuar no lugar certo se a pessoa mudar a fonte depois. Marcador desenhado com BlendMode.multiply, para o texto continuar legível. Ajustes da caneta (23): abre ao tocar de novo na caneta ativa (como no Goodnotes), num balão que aponta para a caneta; a página esmaece, mas a barra de ferramentas continua visível. Mostra a prévia do traço numa faixa pautada, a ponta (Esferográfica = traço igual; Tinteiro = varia com a velocidade; Pincel = bem expressivo), a espessura de 0,3 a 4 mm, as cores favoritas (o “+” salva a cor atual; segurar e arrastar reordena) e a roda de cores: girar escolhe o tom, do centro para a borda a intensidade, mais a barra de brilho e o código da cor. Ao fechar, a caneta, a bolinha de cor e as 3 espessuras da barra já mostram o novo ajuste. Flutter: roda com CustomPainter (SweepGradient + RadialGradient) e HSVColor; ajustes salvos por ferramenta no aparelho. “Suavizar tremidas” fica ligado por padrão e mora nos Ajustes do app (não ocupa espaço no balão).

23b · Ajustes do marca-texto (logo abaixo da 23). Abre ao tocar de novo no Marcador, com a mesma folha e a mesma seta da caneta.
• Prévia com uma linha real da página (“Olhos de ressaca? Vá, de ressaca.”).
• Estilo: Fundo, Sublinhado ou Ondulado.
• Cores e rótulos: 4 cores fixas, cada uma com um nome dado pela pessoa (lindo, personagem, ideia, pro clube) e a contagem de grifos (5 + 3 + 2 + 2 = os 12 do Dom Casmurro). Os rótulos viram filtro nos Grifos (25) e no perfil (44). “Editar rótulos” abre uma folha com 4 campos de texto.
• Altura do fundo: Baixa, Média ou Alta. No sublinhado, vira espessura.
• Gruda nas palavras (sempre ligado): o traço se encaixa nos limites das palavras da linha e fica preso ao texto (posição de início e fim), por isso acompanha se a fonte ou o tamanho mudarem.
Flutter: o traço livre é convertido para TextRange com getPositionForOffset, usando o início e o fim, e é desenhado com getBoxesForSelection. Cada estilo é um painter (retângulo, linha ou onda senoidal). As cores com rótulo são guardadas no perfil e sincronizam entre os aparelhos.
Referências: Goodnotes (marca-texto reto), Kobo (cores de destaque).

## espaco-flutter (Page 15)

Espaço para escrever (24 e 24b): com a ferramenta Espaço, a pessoa encosta o dedo entre duas linhas e arrasta para baixo; o texto se afasta, abrindo um bloco do tamanho do arrasto (ideia do Active Canvas do Kindle Scribe); atalho: abrir 2 dedos na vertical. No momento de abrir (24): a linha roxa marca onde o texto foi “cortado” (sempre entre duas linhas, nunca no meio de uma), a área listrada cresce com o dedo e o balão preto mostra a altura em linhas (“3 linhas”) — a altura encaixa de linha em linha, com uma vibração leve a cada encaixe (HapticFeedback.selectionClick). Ao soltar (24b), a Caneta volta a ficar ativa para escrever no bloco. O bloco tem borda tracejada, etiqueta amarela “Nota à mão”, Recolher (vira um pequeno selo de caneta no fim da linha; tocar abre de novo) e Apagar, e uma alça embaixo para mudar a altura. Fica preso ao trecho (depois de “Vá, de ressaca.”), então continua no lugar certo se a fonte mudar; ao sair do Modo anotação a nota continua aberta no texto (pode ser recolhida pelo botão) e aparece também em Grifos e notas.

## grifos-flutter (Page 15)

Grifos e notas (25): abre pelo atalho Grifos (12) dos controles e pelo “Ver os 12” dos Detalhes. Lista na ordem do livro, agrupada por página (o selo coral marca onde a pessoa parou); cada cartão mostra o trecho com a marca do jeito que foi feita — marca-texto na cor usada, círculo e sublinhados da caneta, a nota à mão desenhada — com o resto da frase apagado para dar contexto. Notas escritas viram um bilhete amarelo com fita; grifos compartilhados mostram o chip rosa do clube com as respostas. Filtros: busca, tipo (Tudo, Grifos, Notas, À mão, Desenhos, com o número de cada), cor e “Só do clube”. Tocar no cartão abre o livro naquela página; “⋯” edita, compartilha como cartão de citação ou apaga. “Exportar” gera um arquivo de texto/Markdown com os trechos, as páginas e as notas (as notas à mão vão como imagem). Flutter: CustomScrollView com SliverList e cabeçalhos de página fixos (SliverPersistentHeader), filtros como SliverAppBar que some ao rolar; os cartões reaproveitam o mesmo pintor dos traços do leitor.

## aa-flutter (Page 15)

Ajustes de leitura (26): abre pelo atalho Aa (Fonte) dos controles, numa folha que sobe de baixo; a parte de cima da página continua à vista e muda ao vivo a cada toque (selo “prévia ao vivo”). Tamanho: botões A pequeno e A grande com 7 passos (o atual é o 4º, 20,5 px). Fonte: Literata (feita para tela, padrão), Lora (serifa clássica), Figtree (sem serifa, a mesma da interface) e Atkinson Hyperlegible (letras bem distintas, ajuda quem tem dislexia). Papel: Creme #F8F1E4 (padrão), Branco #FFFDF8, Sépia #EEDDBF com texto #4A3622 e Noite #1F1B17 com texto #EDE3D1 (a interface do leitor também escurece). Entrelinha em 3 opções — Justo 1,5 · Médio 1,72 · Solto 1,95 — e margens Estreita 18 px · Média 28 px · Larga 40 px. Texto sempre alinhado à esquerda. Os ajustes valem para todos os e-books e ficam salvos no aparelho e na conta. Mudar a fonte ou o tamanho não perde grifos nem desenhos, porque eles estão presos ao trecho do texto. Flutter: showModalBottomSheet com DraggableScrollableSheet; fontes com google_fonts (baixadas uma vez e guardadas para ler offline); o tema muda o ThemeData do leitor com AnimatedTheme. Tema Noite (26b): fundo #1F1B17, texto #E3D9C6 (nunca branco puro, para não ofuscar), ilhas #2A2520 com contorno creme #EDE3D1; as sombras duras ficam quase pretas e quem desenha a forma é o contorno. As cores de destaque continuam as mesmas (lavanda, coral, amarelo); peças amarelas mantêm texto escuro. O atalho “Tema” dos controles alterna Creme ↔ Noite com um toque (o ícone vira lua); a escolha completa fica em Aa. Pode seguir o modo escuro do sistema.

## sumario-flutter (Page 15)

Sumário (27): abre pelo atalho Sumário dos controles, numa folha que sobe (igual aos Ajustes de leitura) e já rolada no capítulo atual. Os capítulos vêm do índice do próprio e-book (EPUB); o app não “adivinha” capítulo no texto — só compara a página atual com as páginas de início do índice para marcar onde a pessoa está. Linha atual em cartão com contorno: selo coral “você está na pág. 159” e um anel coral com quanto do capítulo já foi lido. Capítulos lidos ganham o check verde pequeno; os próximos ficam sem nada. À direita de cada capítulo: as marcas daquele trecho empilhadas (cores dos grifos, bilhete amarelo = nota, caneta = nota à mão/desenho) e o total; tocar abre Grifos e notas filtrado no capítulo. Faixa rosa do clube no topo: meta do próximo encontro (“Até o cap. L · faltam 18”); tocar rola até o cap. L, que tem uma bandeirinha rosa na lista. Aba Marcadas (27b): as páginas com a fita coral, na ordem do livro — número da página, capítulo, as primeiras palavras da página e quando foi marcada; a página atual ganha sombra e o selo “você está aqui”. A fita coral de cada cartão tira a marca (com “Desfazer” num aviso rápido). Lista vazia mostra só a dica da fita. Tocar num capítulo fecha a folha e abre o livro ali. Flutter: DraggableScrollableSheet + ListView.builder com Scrollable.ensureVisible no capítulo atual; TabBar com 2 abas.

## busca-flutter (Page 16)

Busca (28): abre pela lupa nova no topo da Início (ao lado do sino) — a barra de baixo continua com 5 itens. Em cima, sempre: voltar, campo “Livro, autor ou ISBN” e o botão amarelo do Scanner. Antes de digitar (Explorar): buscas recentes (com Limpar), Pelo clima — chips com os votos dos leitores nos livros (leve, tenso, para chorar, de uma sentada…), Gêneros em blocos coloridos com um livrinho inclinado no canto (os mesmos do Onboarding; “Ver todos” abre a lista completa) e Em alta nos clubes (livros que mais clubes começaram na semana). Resultados (28b): aparecem enquanto digita (espera ~300 ms), com o trecho buscado grifado em amarelo. Abas Tudo / Livros / Clubes / Seus trechos. Livro que já está na estante mostra “NA SUA ESTANTE” e a seta para abrir; os outros têm “+” para adicionar. Clubes: check verde = você participa; “Entrar” nos clubes abertos. “Nos seus trechos” procura dentro dos grifos e notas da própria pessoa (só ela vê). No fim, atalho para o Scanner. Nada encontrado (28c): figurinha do livro com lupa, o texto buscado, “Escanear o código de barras” (amarelo) e “Adicionar à mão” (título, autor, páginas e foto da capa), mais dicas. Flutter: SearchAnchor/TextField com debounce; resultados de livros vêm da API de livros (a definir) e são guardados em cache; clubes e trechos vêm do nosso servidor; buscas recentes salvas no aparelho. Adicionar à mão (28d): o título já vem preenchido com o que foi buscado. Sem foto, o app cria uma capa automática no estilo do BookNest (cor escolhida + título e autor); “Fotografar capa” usa a câmera (com recorte automático) e “Da galeria” abre as fotos. Só o título é obrigatório; autor, páginas e ISBN são opcionais (sem páginas, o app conta só os minutos, como nos livros de papel). Formato começa em Papel; “Na estante como” começa em Lendo. O ISBN pode ser lido pela câmera (botão amarelo). Livros à mão ficam privados; se depois o mesmo ISBN aparecer na base de livros, o app oferece juntar os dois sem perder minutos, grifos e notas. O selo redondo com a câmera no canto da capa troca a capa a qualquer momento (Fotografar, Galeria ou voltar para a capa automática).

## estatisticas-flutter (Page 5)

Estatísticas (29): abre em “Ver estatísticas completas” no Perfil. Abas Semana / Mês / Ano (começa na semana; as setas trocam de período). Barras por dia com a linha tracejada coral da meta (30 min); estrelinha coral = bateu a meta; hoje em amarelo, ainda em andamento; dias abaixo da meta ficam listrados, sem vermelho nem bronca. Média por dia e melhor dia. Papel e e-book: minutos do cronômetro (livros de papel) e do leitor (e-book) — reforça que o livro físico é o principal. Sequência: 12 dias seguidos (recorde 41) e o calendário do mês — rosa = dias da sequência atual, bege = leu, tracejado = não leu, coral = hoje. Conta o dia com pelo menos 5 minutos, mesmo sem bater a meta. Gêneros e Clima das leituras (últimos 30 dias, pelos minutos), com uma sugestão leve para variar. A retrospectiva “Livros do ano” fica para o futuro e só aparece em dezembro — nada dela antes disso. Flutter: gráficos com fl_chart (BarChart) ou CustomPainter; o calendário é um GridView de 7 colunas; “Compartilhar” gera a imagem da semana (RepaintBoundary).

Mês e Ano: telas 77 e 78, logo abaixo desta.

## notificacoes-flutter (Page 17)

Notificações (30): abre no sino da Início (“2 novas”). Agrupadas por dia (Hoje / Esta semana); as não lidas ficam em cartão com contorno e bolinha coral, as lidas ficam lisas. Cada aviso diz o que aconteceu e onde, em 2 segundos de leitura. Tipos: Clube (rosa) — mensagens agrupadas (“3 mensagens”), enquete e quem entrou; Lembrete de leitura (amarelo) — gentil, com um único botão “Ler agora” que abre o cronômetro do último livro de papel; Conquistas (verde, estrelinha); Social (lavanda) — curtidas agrupadas com avatares e “Seguir de volta”. Tocar no aviso leva direto para a tela certa. Em cima: marcar tudo como lido e a engrenagem dos ajustes. Avisos com mais de 30 dias somem. Lembretes e avisos (30b): lembrete de leitura com horário (21:30), dias da semana e “Só se eu ainda não li hoje” (se bateu a meta, o aviso nem aparece); no máximo um por dia; prévia de como o aviso chega. Avisar sobre: clube, enquetes e encontros, conquistas ligados; sequência em risco e seguidores/curtidas desligados por padrão. Não incomodar das 22:30 às 7:00 (o cronômetro segue funcionando). Flutter: avisos locais (flutter_local_notifications) para os lembretes, que funcionam sem internet, e push do servidor (serviço a definir) para clube e social; agrupamento por canal no Android e threadIdentifier no iPhone. Tudo em dia (30c): sininho dormindo em cima de um livro, “Tudo em dia.” e o que vai aparecer ali; botão “Ajustar lembretes” e o lembrete do dia (21:30). O botão de marcar como lido fica apagado. O sino da Início fica sem a bolinha coral.

## clube-flutter (Page 4)

Clube (04) corrigido: Leitoras de Capitu está na semana 2 de 6 (caps. 26–50) e o encontro de quinta vai até o cap. 50; a trilha “Onde cada uma está” agora é por páginas (256), com a bandeirinha da meta em 80%. Discussão (31): abre na pergunta da semana. Respostas por curtidas ou recentes, com respostas em fio e trechos citados do livro (o mesmo cartão de grifo, com a página). Proteção contra spoiler: cada resposta guarda a página mais adiantada que ela cita ou que a autora tinha ao escrever; se for depois da sua página, fica borrada com listras rosa e “Fala da pág. 201 · você está na 159” + “Mostrar mesmo assim”. Caixa de resposta fixa embaixo, com o botão amarelo de citar trecho (abre seus grifos). Membros (32): ordenados por quem está mais à frente (ou nome, ou presença), barra de cada uma com a linha preta da meta do encontro e a presença (vai/talvez). Só a porcentagem é mostrada — grifos e notas continuam privados. “Sair do clube” fica no fim, em coral. Criar clube (33): nome e “Cores do clube” com prévia ao vivo — 3 escolhas separadas, cada uma com a paleta inteira (11 cores, rolando para o lado) + a roda para qualquer cor: o selo, o cartão do clube e do convite, e as barras de progresso (uma cor para todas, ou cada leitora escolhe a sua, que também vira a bolinha dela na trilha); primeiro livro, dividir em 4/6/8 semanas (calcula as páginas por semana e cria uma discussão por semana), dia e hora do encontro, online/presencial, “Só com convite” (padrão) ou Aberto (aparece na Busca) e a proteção contra spoiler ligada. Convite (34): cartão-ingresso na cor escolhida para o cartão (amarelo aqui) com o selo verde, o livro e um QR code; o mesmo cartão vira imagem para compartilhar. Link com validade de 7 dias e limite de pessoas (o domínio é provisório), “Mostrar QR” em tela cheia para encontros presenciais e convite direto para quem você segue. Flutter: QR com o pacote qr_flutter; compartilhar com share_plus; o borrado com ImageFiltered (ImageFilter.blur).

## estados-flutter (Page 18)

Abertura (35): fundo de ondas (o mesmo da tela de Login) e o carimbo amarelo “LEIA · GRIFE · CONVERSE” (o anel de letras fica limpo, sem traços por cima) que entra girando, encolhe de 1,15 para 1 e “bate” no papel com um tremor curto, risquinhos de impacto e vibração leve; depois sobe o wordmark Booknest. A barrinha em onda coral só aparece se carregar por mais de 1 s. Duração total ≈ 1,2 s; se o app já estiver aberto em segundo plano, não mostra. Flutter: flutter_native_splash gera o primeiro quadro estático (fundo creme + carimbo) e a animação continua em Flutter com AnimationController. Biblioteca vazia (36): prateleira com espaços tracejados e um livro rosa “o seu aqui?”; a ação principal é escanear o primeiro livro de papel (amarelo), com Buscar e “E-book ou PDF” como alternativas. A navegação continua igual. Sem internet (37): faixa preta discreta no topo enquanto estiver offline; no Clube, que depende de conexão, explica o que continua funcionando — cronômetro, e-books baixados e grifos/notas, que sincronizam depois — e oferece “Tentar de novo”. As outras abas mostram só a faixa. Erro genérico (38): ilustração do café derramado no livro, mensagem que tranquiliza (nada se perdeu), “Tentar de novo”, “Voltar para o Início” e o código do erro para copiar e mandar ao suporte. Flutter: connectivity_plus para detectar a rede; a faixa é um MaterialBanner animado; o erro usa um ErrorWidget próprio e registra o código. Início no primeiro acesso (36a): quando a estante ainda está vazia (a pessoa pulou o passo 3 do Onboarding), o lugar do “Continuar lendo” vira o cartão lavanda “Coloque seu primeiro livro na estante”; o botão principal “Montar minha estante” leva para a Biblioteca (36), e os atalhos Escanear, Buscar e E-book vão direto. O cartão da meta mostra 0 de 30 min e explica que o cronômetro começa com o primeiro livro; embaixo, entrada para quem recebeu convite de clube (colar link ou ler QR). Some sozinho quando o primeiro livro entra.

## scanner-flutter (Page 3)

Estados do Scanner (39–42). Mesma câmera, mesma barra do topo (Código | Digitar + lanterna) e a mesma folha que sobe de baixo da tela 03 — muda só o que a folha diz.

39 · Mirando. A câmera fica viva e levemente desfocada fora da moldura; dentro dela, a linha coral passa de cima a baixo (1,6 s, ida e volta, sem piscar). O chip “Procurando o código…” fica parado sobre a moldura. A folha baixa ensina com um desenho: um livro de costas com o código marcado em tracejado coral, e o texto “Vire o livro de costas”. Duas dicas em pílula aparecem só depois de alguns segundos sem leitura (4 s “Pouca luz? Ligue a lanterna”, 8 s “Afaste um palmo”); tocar na primeira já liga a lanterna. Embaixo, sempre visível: “Código apagado? Digitar o ISBN”, que troca para a aba Digitar.

40 · Livro não encontrado. O código foi lido (cantos e chip amarelos, selo de check no código, vibração curta), mas o ISBN não está na nossa base. A folha não trata isso como erro: chip rosa “Fora da nossa base” + o ISBN lido, a capa em branco com um “?” e o texto “Esse ainda não está aqui.” O “Salvar como” já vem em Lendo, e o botão principal “Adicionar à mão” abre a tela de Adicionar à mão com o ISBN e o status preenchidos (a capa pode ser fotografada ali). O botão redondo escaneia de novo; “Buscar pelo título” cobre o caso de ter lido o código errado (o de uma etiqueta de preço, por exemplo).

41 · Sem permissão de câmera. Fundo escuro listrado no lugar da câmera, cantos tracejados apagados e lanterna desativada. A folha explica sem culpa: “A câmera está desligada para nós”, diz para que ela serve (só ler o código; nenhuma foto é guardada ou enviada) e mostra o caminho exato num chip tracejado. Botão amarelo “Abrir os ajustes do celular” e, como saída que não depende da câmera, “Digitar o ISBN”.

42 · Já está na estante. O mesmo Brás Cubas da 03, semanas depois: a pessoa pega o livro físico e escaneia. Em vez de duplicar, a folha mostra o chip lavanda “Já está na sua estante”, a capa, a barra de progresso (pág. 74 de 208 · 36%) e o quanto falta para a meta do dia (18 de 30 min; a sequência de 12 dias já conta hoje). O botão principal vira “Iniciar leitura” e abre o cronômetro direto neste livro — escanear vira o atalho mais rápido para começar uma sessão. Tocar no livro abre os Detalhes. “É outra edição? Adicionar mesmo assim” cobre quem tem duas edições. Se o livro estiver como Lido, o botão vira “Ler de novo”; se estiver em Quero ler, vira “Começar a ler” e muda o status para Lendo.

Regras de leitura
• Só código de barras: EAN-13 com prefixo 978/979 (ISBN). Outros códigos (preço, código interno da livraria) são ignorados em silêncio e a linha continua passando; se a mesma leitura inválida se repetir por 3 s, aparece a dica “Esse parece ser o código de preço”.
• Leitura no próprio aparelho, sem enviar imagem. Confirmar o mesmo valor em 2 quadros seguidos antes de aceitar, para não ler errado.
• Ao aceitar: pausar a câmera, vibração leve, cantos ficam amarelos e a folha sobe.
• Sem internet: guardar o ISBN numa fila e mostrar “Vamos buscar quando a conexão voltar”; o livro entra como rascunho.

Flutter
• Uma única tela ScannerPage com um estado: mirando, lido, naoEncontrado, semPermissao, erroCamera. A folha é um AnimatedSwitcher dentro de um Align(bottom), não um showModalBottomSheet, para a câmera continuar visível atrás.
• Moldura e cantos num CustomPainter; a linha coral é um AnimationController.repeat(reverse: true) com Tween de top 0→1. Desligar a animação quando MediaQuery.disableAnimations for verdadeiro (a linha fica parada no meio).
• Desfoque fora da moldura: ClipPath invertido + BackdropFilter(ImageFilter.blur(sigma 6)) e uma camada escura a 45%.
• Dicas com Timer cancelado a cada nova leitura e no dispose. Lanterna: botão 48×48 com Semantics(toggled).
• Permissão: pedir só quando a pessoa abre o Scanner pela primeira vez (com a explicação antes do pedido do sistema). Negado → estado 41; negado de vez → o botão abre os ajustes do app. Ao voltar para o app (didChangeAppLifecycleState resumed), checar de novo e religar a câmera sozinho.
• Acessibilidade: anunciar “Código lido” e “Livro não encontrado” com SemanticsService.announce; a aba Digitar é sempre alcançável por leitor de tela, então ninguém depende da câmera.
• Pausar a câmera quando a tela perde o foco (rota coberta ou app em segundo plano) para poupar bateria.

Referências: Libib e Goodreads (escanear em lote e fallback por ISBN), StoryGraph (adicionar edição que falta), Bookshelf e Basmo (dicas de luz e distância), Apple Human Interface Guidelines e Material 3 (pedir permissão no momento do uso e explicar antes).

## perfil-abas-flutter (Page 5)

Abas do Perfil (43–46). Ao rolar o Perfil, a capa sobe e some; fica um cabeçalho compacto (avatar M, nome, @ e compartilhar) e as abas presas logo abaixo. A aba escolhida é lavanda com sombra dura e a barra rola sozinha para mantê-la à vista. Cada aba guarda a própria posição de rolagem.

43 · Resenhas. No topo, só quando existe: um cartão verde de “terminou há 2 dias” (O Alienista) com “Escrever” e um X para dispensar. Depois a média 4,4 em 8 resenhas, com estrelas e um histograma de meia em meia estrela (como no Letterboxd). Ordem: Recentes, Melhor nota, Mais curtidas, Com spoiler. Cada resenha mostra a capa, as estrelas com meia, a data, até 3 climas em pílula (a mesma cor de cada clima em todo o app) e 3 linhas de texto. Resenha com spoiler fica borrada até tocar em “Contém spoiler · tocar para ler”. Rodapé com curtir, comentar e “Ler tudo”.

44 · Grifos (mural). “214 grifos em 31 livros”, busca, filtro por livro, as 4 cores, “Com nota” e “Desenhos”. Mural em duas colunas, mais recentes primeiro. Cada cartão mantém a marca real (a mesma cor e o mesmo traço feitos no leitor), a nota amarela com fita, o selo do clube quando foi compartilhado e a página + data. Trechos curtos viram cartão inteiro colorido com letra grande (Ao vencedor, as batatas!). Desenhos à mão aparecem com o círculo e o sublinhado ondulado. Tocar abre o trecho no livro.

45 · Listas (leque). “Nova lista” no topo. A lista fixada ocupa a largura toda: leque de 5 capas sobre a cor da lista, descrição, público (Seguidores, porque o perfil é fechado), quantas pessoas salvaram e “12 de 18 lidos”. As outras ficam em grade de 2, com leque de 3 capas: ranking ganha números nas capas e lista privada ganha cadeado + fundo listrado. Embaixo, “Salvas de outras leitoras”. A cor do painel é escolhida ao criar a lista (a mesma paleta do Clube).

46 · Escrever resenha. Abre pelo cartão da 43, pelo fim do livro ou pelos Detalhes. Livro com selo “Lido em 18 set”. Nota com estrelas grandes: tocar de novo na mesma estrela alterna entre inteira e meia. Climas: até 3, e cada um escolhido ganha a própria cor e um check. Texto com contador e chave “Contém spoiler”. “Junte um grifo seu” puxa os grifos daquele livro; o escolhido vai no topo da resenha. “Quem vê”: Todos, Seguidores ou Só eu; com o perfil fechado, Todos fica travado e Seguidores vem marcado (ver 93). “Publicar resenha” fica preso embaixo, na zona do polegar; “Rascunho” salva sem publicar e o rascunho volta se a pessoa fechar o app.

Dados: 8 resenhas (média 4,4: uma 3,5; duas 4; três 4,5; duas 5), 214 grifos, 5 listas; O Alienista lido em 18 set ainda sem resenha. Os Grifos do Dom Casmurro batem com a tela 25.

Flutter
• Perfil: NestedScrollView com SliverAppBar (a capa colapsa até o cabeçalho compacto) e SliverPersistentHeader fixo com as abas. TabBar(isScrollable: true) leva a aba ativa para a área visível. Cada aba usa PageStorageKey para lembrar a rolagem.
• Resenhas: SliverList.builder. Estrelas com meia: um widget que desenha 5 estrelas e recorta a metade com ClipRect. Spoiler: ImageFiltered(blur) + Semantics(label: “Contém spoiler”), com o texto real escondido do leitor de tela até tocar.
• Grifos: grade em alvenaria (masonry) de duas colunas, carregada aos poucos (paginação de 30). A marca usa o mesmo componente do leitor, para a cor e o traço serem idênticos.
• Listas: leque = Stack com Transform.rotate(origem embaixo, ±9 a 11°) e sombra dura. A lista fixada é a primeira do SliverList; a grade usa SliverGrid com 2 colunas.
• Escrever: Form com estado local e salvamento do rascunho a cada pausa de digitação (debounce de 800 ms). A nota é um Semantics(slider) com aumentar/diminuir de 0,5 em 0,5. Os climas usam FilterChip com limite de 3 (o 4º faz o chip tremer e mostra “até 3”). O botão fica num bottomNavigationBar do Scaffold e respeita o teclado com MediaQuery.viewInsets.

Referências: StoryGraph (climas e meia estrela), Letterboxd (abas do perfil, histograma de notas, listas ranqueadas), Literal e Fable (citações e grifos no perfil).

## enquete-flutter (Page 4)

Enquete do próximo livro (47–50). A enquete passa por 3 fases: indicações → votação → resultado. Ela abre cedo, com o Dom Casmurro ainda na semana 2, para dar tempo de todo mundo arranjar o livro. A prévia no Clube (04) é o estado depois do seu voto.

47 · Criar enquete (quem organiza o clube). Título “Qual vai ser o próximo livro?”. Os livros entram de dois jeitos: “Cada uma indica” (com limite por pessoa) ou “Eu escolho”. Uma linha do tempo mostra os prazos: indicações até qua 16 set, votação até ter 22 set, resultado ter 22, 20h. As regras ficam à vista: 1 voto por pessoa (dá para mudar até fechar), parcial só depois de votar, empate vira desempate de 24 h só com os empatados, e um lembrete 1 dia antes de fechar para quem não votou. “Abrir enquete” avisa as 11 membras.

48 · Indicar um livro. É uma folha sobre a enquete em fase de indicações. Busca por título, autor ou ISBN, com o botão amarelo do Scanner ao lado. “Da sua estante” lista o que a pessoa está lendo ou quer ler; o livro que outra pessoa já indicou aparece apagado, com a etiqueta “já indicado”. “Por que ler?” é opcional (até 140 caracteres) e aparece no cartão de votação. Dá para trocar a indicação até o prazo.

49 · Votar (antes do voto). Mostra “8 de 11 votaram” com avatares, o prazo e um aviso: os números aparecem depois do seu voto, para ninguém votar no embalo. Cada candidato é um cartão grande com capa, autor, páginas e ritmo (páginas ÷ 6 semanas), quem indicou e o “por que ler”. Selos pessoais: “Na sua estante · Lendo” e “Você leu · 4,5 ★”. O cartão escolhido fica lavanda com check; o botão “Votar em …” fica preso embaixo.

50 · Resultado. Abre quando a enquete fecha: carimbo amarelo “ESCOLHIDO · LEITORAS DE CAPITU” batendo na capa (a mesma animação da abertura), com confetes. Depois vêm o plano (começa 26 out, 6 semanas, ~35 pág. por semana, 1º encontro qui 29 out até a pág. 35), “Como você vai ler?” (Já tenho / Vou arranjar / E-book; o app já marca Já tenho porque o livro está na estante) e a contagem final com barras onduladas na cor do clube e os avatares de quem votou. “Pôr na minha agenda” cria o lembrete na véspera.

Dados: Brás Cubas 6 (Marina, Ana, Júlia, Gabi, Helô, Dani), O Cortiço 4 (Lu, Rafa, Bia, Fê), Senhora 1 (Carol). Antes do voto da Marina eram 8 de 11; o Clube 04 mostra 9 de 11 com Brás Cubas em 5. Ajustei os Detalhes (“fecha terça”) e o aviso de enquete na central (“8 de 11 já votaram. Falta o seu”), para nenhum dos dois mostrar o parcial antes do voto.

Empate: se dois livros empatam no 1º lugar, a tela 50 vira “Deu empate!”, com os dois livros lado a lado e um desempate de 24 h; só esses dois entram e todo mundo vota de novo.

Flutter
• Um estado por enquete: indicacoes, votacao, desempate, fechada. Cada membra só recebe a contagem depois de votar; a regra fica no servidor, não só na tela.
• Votar: um RadioGroup de cartões (Semantics inMutuallyExclusiveGroup + checked); o botão fixo usa o título do livro escolhido. Trocar de voto é um PATCH, sem pedir confirmação.
• Linha do tempo (47): uma Row com pontos e uma linha tracejada (CustomPainter); as datas abrem o seletor de data e hora do sistema.
• Resultado: o carimbo usa AnimationController (rotação −30°→−14°, escala 1,15→1, vibração leve). Os confetes duram 1,2 s e somem quando o sistema pede menos movimento. As barras crescem de 0 até o valor final em 600 ms.
• Lembrete: notificação agendada no aparelho para a véspera do 1º encontro.

Referências: Bookclubs (enquetes com indicações e prazo), Goodreads (tópicos de votação de clubes), NearForm (voto em celular), RankedVote (empate e desempate).

## outro-perfil-flutter (Page 5)

Perfil de outra pessoa (51–54). O perfil de quem você visita usa a mesma capa de livro do seu, com a cor que a pessoa escolheu. Ele abre num caminho empilhado (botão de voltar e “…” para bloquear ou denunciar), sem a barra de navegação. Quem visita cai direto na aba “Em comum”.

51 · Júlia — Em comum. Na capa, o selo “Segue você” e, logo abaixo, “Seguindo” (lavanda) e “Convidar”. Abas: Em comum 21, Grifos 58, Resenhas 12, Listas 3. Conteúdo:
• Diagrama de Venn em estilo retrô: o círculo lavanda é seu (31 só seus), o verde é dela (66 só dela) e o meio listrado tem os 21 em comum. Os círculos têm tamanho proporcional a quanto cada uma leu (52 × 87). Frase: “notas parecidas em 15” (diferença de até meia estrela). “Ver os 21” abre a lista.
• Lendo as duas agora: uma barra só com os dois avatares, você na pág. 159 e ela na 172 (13 páginas à frente).
• Notas lado a lado: até 4 livros, com etiquetas “mesma nota” e “maior briga” (diferença de 2 estrelas ou mais), para puxar conversa.
• “Ela quer ler, você já leu”: O Alienista, com o botão Indicar.
• Clubes: vocês duas estão em Leitoras de Capitu. Como ela grifou 9 poemas da Lira dos Vinte Anos, aparece “Convidar para Poesia de domingo”.

52 · Júlia — Grifos públicos. Cabeçalho compacto com “Seguindo”. Abas presas. Mostra “58 grifos públicos em 19 livros”, os filtros e um aviso de que só aparece o que ela deixou público (notas privadas nunca saem do livro dela). O mural é o mesmo da tela 44. Grifo depois da sua página fica trancado: “À sua frente · abre quando você chegar na pág. 172”. O servidor nem envia o texto, só o tamanho e a cor, para o app desenhar as linhas borradas. Quando vocês duas grifaram o mesmo trecho, aparece o selo “Você também” com os dois avatares. O filtro “Os mesmos que eu” mostra só esses.

53 · Perfil fechado (Pedro). A capa vira papel listrado com o selo preto “PERFIL FECHADO”. Ficam visíveis só o nome, o @ e os seguidores. Ilustração de livro com cinta e cadeado. Texto: “A estante do Pedro está fechada.” O que dá para ver sem invadir: quem você segue e também o segue (Rafa) e as interações dele com você (curtiu sua resenha). “Pedir para seguir” fica preso embaixo. Depois do toque, o botão vira “Pedido enviado” (contorno) com a opção de cancelar.

54 · Os 21 em comum (abre em “Ver os 21”). O resumo divide os 21 livros em 4 com a mesma nota, 11 parecidas (meia estrela de diferença) e 6 diferentes. Ordens: Maior diferença (padrão, porque puxa conversa), Mesma nota, Título e Recentes. Cada linha tem um “haltere” numa régua de 0 a 5: o avatar M e o avatar J ligados por um traço; nota igual vira um ponto só, meio amarelo e meio verde, com “=”. Tocar abre o livro com as duas resenhas lado a lado. Flutter: o haltere é um CustomPainter de 128 px com Semantics “você 4,5, Júlia 2,5”.

Regras de privacidade
• Cada pessoa escolhe: perfil aberto ou fechado e, para cada grifo, se ele é público (o padrão é privado).
• A porcentagem no clube segue a tela 32: nunca mostra o que alguém grifou.
• O spoiler vale para todas: nada depois da sua página aparece, nem no perfil dos outros.

Flutter
• ProfilePage(userId) monta a tela conforme a relação: eu, seguindo, segue você, fechado ou bloqueado.
• Venn: CustomPainter com dois círculos, raio ∝ √livros, e a sobreposição recortada (Path.combine intersect) com listras. Semantics com a frase completa.
• Barra com dois avatares: Stack + Align(x = progresso*2−1). Um avatar fica acima e o outro abaixo, para não se cobrirem.
• Grifo trancado: um widget skeleton com ImageFiltered(blur 2.5), sem texto no estado. Semantics(label: “Grifo à sua frente, página 172”).
• Pedir para seguir: atualização otimista do botão; se falhar, volta e mostra um aviso.

Referências: Goodreads (comparar livros com amigos), StoryGraph (pedidos de “livros em comum”), Letterboxd (perfil público e privado).

## privacidade-flutter (Page 6)

Privacidade e conta (56–59). Tudo sai dos Ajustes (06): a linha “Privacidade · Perfil fechado · 3 pedidos” e o cartão da conta no topo.

56 · Privacidade. Começa com a escolha grande entre Aberto e Fechado (fechado = só quem você aprova vê o perfil). Depois vem “Quem vê o quê”: cada parte tem a sua pílula de público (Todos, Seguidores ou Só eu). Com o perfil fechado, “Todos” fica indisponível e o app explica por quê.
• Estante e lendo agora: Seguidores
• Resenhas: Seguidores
• Grifos novos: Só eu (padrão). Dá para abrir grifo por grifo pelo menu do grifo.
• Página onde você está: Seguidores. Nos clubes, só a porcentagem aparece (tela 32).
• Listas: Seguidores. Cada lista ainda pode ser só sua.
• Metas e estatísticas: Só eu
Em Pessoas ficam os pedidos para seguir (3), “Me achar pelo e-mail” (desligado) e Bloqueadas (1). Um aviso tracejado explica que bloquear some dos dois lados: nenhuma das duas vê perfil, grifos ou resenhas da outra, e no clube as mensagens dela ficam recolhidas.

57 · Pedidos para seguir. Cada pedido é um cartão com o contexto que ajuda a decidir: quem vocês seguem em comum, livros em comum, “está com você no clube” ou “nada em comum ainda”. Botões Aceitar (preto) e Recusar (contorno). O “…” traz bloquear e denunciar. Quem é aceito vira um cartão verde com “Seguir de volta”. Recusar é silencioso, e a pessoa só pode pedir de novo depois de 30 dias.

58 · Conta. Cartão-capa com o @ e o número da carteirinha. Entrar: e-mail confirmado, senha e contas conectadas (sem logos). Sincronização: 3 aparelhos e o download de e-books para ler sem internet. Seus dados: exportar (livros e sessões em planilha, grifos e resenhas em texto) e importar de outro app por CSV. “Sair desta conta” vem em contorno e “Excluir conta” como link vermelho escuro, longe do polegar.

59 · Excluir conta. Tom calmo (“Sem pressa”). Mostra em 6 blocos coloridos o que vai embora: 52 livros, 214 grifos, 8 resenhas, 5 listas, 12 dias seguidos e 3 clubes. Nos clubes, as mensagens viram “leitora que saiu” e Leitoras de Capitu continua com a Ana. Antes de excluir, oferece duas saídas mais leves: baixar os dados e fazer uma pausa (esconder o perfil e parar os avisos). Para confirmar, a pessoa digita EXCLUIR. O botão coral só libera depois disso. A conta some na hora para os outros, mas dá para voltar atrás em 30 dias entrando de novo; depois, tudo é apagado de vez.

Flutter
• Privacidade: um único documento de configurações por pessoa (aberto, público por seção, grifoPadrao). O servidor filtra por público; o app só mostra.
• Pílulas de público: showModalBottomSheet com RadioListTile; opção desabilitada com motivo no subtitle.
• Pedidos: AnimatedList. Aceitar ou recusar remove o cartão com animação e pode ser desfeito por 5 s num SnackBar.
• Excluir conta: TextField que compara com “EXCLUIR” sem diferenciar maiúsculas; o botão usa onPressed: null até bater. Depois, a conta passa para o estado pendingDeletion, a sessão sai e aparece a tela de despedida. É obrigatório nas lojas oferecer exclusão de conta dentro do app.
• Exportar: o job roda no servidor e o arquivo .zip chega por e-mail.

Referências: StoryGraph (notas privadas por padrão e conta privada), Apple Developer (exclusão de conta dentro do app) e guias sobre os direitos do titular na LGPD (exportar e apagar dados).

## revisao-flutter (Page 1)

Revisão diária dos grifos (60–63). São 5 grifos por dia, cerca de 2 minutos, de todos os livros. A ideia é relembrar o que você marcou, sem virar tarefa.

60 · Início — grifos de hoje. Na Início (01), o cartão “Seus grifos de hoje” fica entre “Seu dia de leitura” e “Para você”: um baralho de 3 cartões nas cores dos rótulos, “REVISÃO · 5 GRIFOS · 2 MIN”, de quais livros vêm e o botão “Revisar”. Depois de revisar, o cartão vira “Feito ✓ · volta amanhã às 8h” e encolhe. Aproveitei para corrigir “Para você”, que recomendava Quincas Borba e O Cortiço, livros que a Marina já leu; agora mostra Memorial de Aires e Casa de Pensão.

61 · Revisão — cartão 2 de 5. A barra de 5 segmentos mostra o progresso (verde = feito, lavanda = atual). O cartão grande tem os outros por baixo, rodados, nas cores dos próximos. Dentro: livro e página, o rótulo da cor (personagem), o trecho com a marca real, a nota antiga em post-it e o rodapé “Você grifou há 17 dias · revisto 1 vez”. Ações na zona do polegar:
• Menos vezes / Mais vezes: ajustam de quanto em quanto tempo o grifo volta.
• Escrever nota: abre uma nota nova, que se junta à antiga.
• Compartilhar: abre a tela 63.
• Próximo: igual a deslizar o cartão. Nenhuma ação depende só do gesto.

62 · Fim da revisão. Os 5 mini-cartões com check, “Revisão feita.” e o selo lavanda “7 dias seguidos revisando” (sequência própria, que não mistura com a de leitura). Resumo: 2 mais vezes, 1 menos vezes, 1 nota nova. A nota nova aparece no próprio grifo. Prévia de amanhã: às 8h, com “A vida é uma ópera” de volta porque você pediu mais vezes. Botões: “Voltar a ler · pág. 159” e “Mudar horário e quantidade”.

63 · Imagem para compartilhar. Uma folha escura com a prévia 9:16. Aspas grandes, o trecho em serifa itálica com uma faixa clara atrás da parte mais forte, livro e página, “grifado por @marinacosta” e a marca BookNest. Fundo em 6 cores (creme, as 4 dos rótulos e tinta), com a cor do rótulo como padrão. Chaves para mostrar a nota e o @. Destinos: Salvar, Stories, Copiar texto e Mais (sem logos).

Como escolhe os 5: a cada dia, mistura grifos novos (menos de 7 dias), esquecidos (nunca revistos) e os marcados “mais vezes”. Espaçamento leve: 1, 3, 7, 21 e 60 dias. “Mais vezes” encurta o próximo intervalo e “menos vezes” alonga; se você tocar menos vezes duas vezes, o grifo sai da revisão. Grifos de livros com spoiler do clube só entram depois que você passa da página.

Flutter
• O baralho é um Stack com 3 cartões, e o de cima é Dismissible/Draggable com rotação proporcional ao arrasto. Ao soltar, o cartão voa e o próximo sobe com AnimatedSlide.
• O agendamento roda no servidor: um job diário gera a lista e o app só baixa os 5 ids, que funcionam sem internet. Lembrete local às 8h (ajustável).
• A imagem usa RepaintBoundary.toImage(pixelRatio 3) em 1080×1920 e vai para o compartilhamento do sistema. “Copiar texto” copia o trecho, o livro e a página.
• Acessibilidade: cada cartão tem Semantics com o trecho completo; os botões cobrem todos os gestos; com movimento reduzido, a troca de cartão vira um fade.

Referências: Readwise (revisão diária e repetição espaçada “Mastery”) e Kindle/Kobo (grifos coloridos).

## editar-flutter (Page 5)

Editar perfil (64–65). Abre no botão “Editar perfil” do Perfil (05) e no “Editar” do cartão da Conta (58).

64 · Editar perfil. No topo, a capa-livro em miniatura com “PRÉVIA AO VIVO”: tudo o que muda embaixo aparece na hora (cor, inicial, nome, bio, pronomes e gêneros). O botão de câmera no avatar abre a escolha entre foto e inicial.
• Cor da capa: a mesma paleta de 11 cores do Clube (33) mais a roda para qualquer cor; a escolhida ganha anel duplo. A prévia e os Ajustes (06) usam a mesma variável.
• Avatar: Foto ou Inicial (padrão: Inicial M, amarela).
• Nome (até 40 caracteres), @ com checagem ao vivo (“é seu”, “disponível” ou “já existe, tente…”; só pode trocar a cada 30 dias) e Bio (até 120, contador).
• Pronomes (opcional): ela/dela, ele/dele, elu/delu, Escrever ou Não mostrar.
• Gêneros favoritos: até 5, cada um com a sua cor; aparecem como etiqueta na capa.
• Quatro que me definem: os 4 livros numerados, com lápis para trocar e alça para arrastar (segure e arraste para reordenar; para leitor de tela, “mover para a esquerda/direita”).
“Salvar alterações” fica preso embaixo. Fechar com mudanças pergunta “Descartar alterações?”.

65 · Trocar um dos 4. É uma folha sobre a tela 64. No topo, o livro que sai (Iracema, nº 3), com o aviso de que ele volta para a estante. Busca nos 52 lidos. “Suas melhores notas” vem primeiro (5 ★ e 4,5 ★); o livro que já está nos 4 aparece apagado com a etiqueta “já é o nº 4”. O botão diz exatamente o que vai acontecer: “Pôr Vidas Secas no lugar”.

Flutter
• Um ProfileDraft (cópia do perfil) com ChangeNotifier. A prévia escuta o rascunho; salvar faz um único PATCH; PopScope pede confirmação se houver mudanças.
• @: debounce de 400 ms e consulta de disponibilidade; mostra estados de carregando, ok e erro dentro do campo.
• Os 4: ReorderableListView horizontal (ou ReorderableWrap) com handle e Semantics com ações customizadas de mover.
• Foto: seletor de imagem do sistema + recorte circular; a imagem vai para o servidor em 512 px.

Referências: Letterboxd (os 4 favoritos no perfil, trocados com um toque).

## listas-flutter (Page 5)

Lista aberta (66–68). A lista “Machado do começo ao fim” (45) agora tem conteúdo de verdade: os 9 romances de Machado na ordem em que ele escreveu (Ressurreição 1872 → Memorial de Aires 1908). O leque da tela 45 mostra os 3 primeiros.

66 · Lista aberta. A capa da lista fica no painel lavanda (a cor escolhida para a lista), com o leque das 5 primeiras capas numeradas. Embaixo: “RANKING · 9 LIVROS · PÚBLICA”, o título, a descrição, “por você · 12 salvaram” e uma barra de 9 casas que mostra o seu andamento na lista (verde = lido, coral = lendo, listrado = quero ler): 4 lidos, 2 lendo, 3 quero ler. Botões “Editar ordem” e “Adicionar livro”. Cada item tem um número editorial enorme (contorno com sombra lavanda), a capa, o título, o ano, o seu status (Lido · 3,5 ★ / Lendo · pág. 74 / Quero ler) e a sua nota curta em serifa itálica. Quem salvou a lista vê o próprio status em cada livro, não o seu.
Os dados batem: Brás Cubas na pág. 74, Dom Casmurro em 62%, Helena 3 ★ (tela 54), Quincas Borba 4 ★, e Esaú e Jacó e Memorial de Aires em Quero ler (são os recomendados na Início).

67 · Editar ordem. Cancelar / Editar lista / Pronto. Nome da lista editável, chave “Numerada (ranking)” e “Quem vê”. Cada linha tem alça, número, capa, título, a nota (ou “+ adicionar nota”) e “−” para tirar da lista. Durante o arraste, o cartão levantado gira levemente e ganha sombra maior; no lugar onde ele vai cair aparece um espaço listrado: “solte aqui · vira o nº 4”. Os números dos outros mudam ao vivo.

68 · Adicionar à lista. Uma folha aberta a partir de um livro (Casa de Pensão, nos Detalhes ou na busca). “Nova lista com este livro” vem no topo; depois as suas listas com miniatura das capas e cor, em multiseleção. Numa lista com ranking, o livro entra no fim (“vira o nº 19”) e a ordem pode ser ajustada depois. O botão conta quantas listas recebem o livro: “Salvar em 1 lista”.

Flutter
• Lista aberta: CustomScrollView com SliverToBoxAdapter (capa) + SliverList. Os números grandes são Text com Paint de contorno (foreground stroke) e Shadow lavanda.
• Editar: ReorderableListView.builder com buildDefaultDragHandles: false e ReorderableDragStartListener na alça. O proxyDecorator aplica a rotação de −1,5° e a sombra. Para leitor de tela, cada item tem as ações “mover para cima/baixo”.
• Remover: Dismissible ou botão “−”, com SnackBar “Desfazer” por 5 s.
• Adicionar: showModalBottomSheet com CheckboxListTile customizado; o salvamento é um único POST com os ids das listas.

Referências: Letterboxd (listas ranqueadas e notas por item).

## revisao-consistencia (Page 19)

Revisão de consistência (2 out). Conferi os números, datas, status e nomes de todas as 82 telas. Esta lista mostra o que não batia e foi corrigido direto nas telas.

O QUE FOI CORRIGIDO
1. O Alienista: estava “Quero ler” na Biblioteca (02) e nos Recém-chegados da Início (01, 01b), mas a Marina terminou em 18 set (43, 46, 51). Agora aparece como “Lido”.
2. Frankenstein: estava “Quero ler” (01, 02), mas tinha resenha (43) e nota (54). Troquei por Crime e Castigo, que já era Lido na 02 (4,5 ★ · sombrio, intenso).
3. Senhora: aparece como “Novo” na 01/02 e como Quero ler na Enquete (48), mas tinha nota na 54. Troquei por O Guarani.
4. Lendo agora: são 4 livros (Dom Casmurro e-book, Brás Cubas papel, Orgulho e Preconceito papel, Mrs. Dalloway). Biblioteca: Lendo 3→4 e Quero ler 24→26 (4 + 26 + 52 + 4 = 86 = Todos). Início: “Também lendo” 2→3 (01, 01b, 60). Perfil: o link virou “Ver os 4”.
5. Orgulho e Preconceito é papel (01: pág. 344), mas a 48 dizia e-book. Agora: “papel · pág. 344 de 424”.
6. Perfil (05), atividade “Hoje: escaneou Brás Cubas e salvou em Quero ler”: brigava com “Lendo · pág. 74” (17, 42, 66). Agora: “Desenhou à mão em Dom Casmurro, pág. 159”, que bate com a 25 e a 44.
7. “LEITORA DESDE 2019” (05) contra a carteirinha “Nº 0052 · desde 2026” (08, 16). Agora: “LEITORA Nº 0052”; a Júlia ficou com “Nº 0031”.
8. Grifos do Dom Casmurro: o selo dos Detalhes e-book (17b) dizia 14; o resto do app diz 12. Agora: 12.
9. Perfil fechado (56) contra a notificação “Rafa começou a seguir você”. Agora: “Você aceitou o pedido do Rafa”.
10. “Para você” (01) recomendava Quincas Borba e O Cortiço, que ela já leu. Agora: Memorial de Aires e Casa de Pensão.
11. Enquete: os Detalhes diziam “fecha domingo” → “fecha terça”; o aviso da central não revela mais quem lidera antes do voto.
12. A lista “Me fizeram chorar no ônibus” (45) tinha Frankenstein e Orgulho (não lidos) → Vidas Secas, Iracema e A Hora da Estrela.
13. As cores dos avatares das membras na Enquete agora são as mesmas da tela 32.

CONFERIDO E JÁ CERTO
• Dom Casmurro: pág. 159 de 256 · 62% em mais de 20 telas. Grifos: 12 no livro e 214 no total.
• Sequência de 12 dias, recorde de 41, “mais 2 dias para o selo de 14”.
• Hoje 18 de 30 min. Cronômetro 8:42 → 26/30 (18) e +12:31 → 30/30 (18b). A semana soma 4 h (29).
• Clube: semana 2 de 6, caps. 26–50, qui 24/9 às 20h, 11 pessoas, grupo em 54%, Júlia em 67% = pág. 172.
• Brás Cubas: 208 pág., parou na 74, 3 h 40 em 6 sessões (01, 17, 42, 18b).
• Enquete: 8 → 9 de 11 votos; Brás 5 → 6 no resultado. Resenhas: 8, média 4,4. 52 lidos e 24 de 30 na meta.

## telas-faltando (Page 19)

Telas faltando (9). No mapa, aparecem como cartões tracejados com “+”. A prioridade considera de quantos lugares a tela é aberta e se ela trava algum fluxo.

ALTA: nenhuma. As três (Digitar o ISBN, Encontro do clube e Resenha aberta) já foram feitas.

MÉDIA
• Enquete · deu empate (desempate de 24 h): regra da 47.
• Revisão · escrever nota: 61.
• Exportar meus dados (LGPD): 58 e 59.
• Importar CSV de outro app: 58.
• Aparência e acessibilidade: 06.
• Trocar a capa (fotografar a sua edição): selo em 17 e 17b.
• Busca dentro do livro: Leitor (20).

BAIXA
• Carteirinha aberta (compartilhar como imagem): 05 e 16.
• Coleções · ver todas: 02.

FUTURO (combinado): Livros do ano, que só aparece em dezembro.

Feito em 2 out: Digitar o ISBN (69–69b), Encontro do clube (70–73) e Resenha aberta (74–76). Os três fluxos mais usados (adicionar livro, clube e social) estão completos. Depois: Estatísticas · mês e ano (77–78), Conquistas (79–82), Plano Pro (83–88), Seguidores e seguindo (89–92), Escolher público (93–97), Bloqueadas (98–101) e Quem votou em… (102–104). Sugestão para a próxima: Exportar meus dados (LGPD), que abre da 58 e da 59.

## digitar-flutter (Page 3)

69 e 69b · Digitar o ISBN (aba). A barra do topo é a mesma do Scanner, agora com “Digitar” marcado. Ao trocar de aba, a câmera pausa para poupar bateria. A lanterna dá lugar ao “?”, que abre uma folha curta mostrando onde o ISBN costuma estar: no verso, embaixo das barras, ou na ficha catalográfica, nas primeiras páginas.

A etiqueta. O campo é uma etiqueta de código de barras que se desenha enquanto a pessoa digita. Cada dígito novo “imprime” as suas barras (7 módulos do EAN-13, 120 ms), e o número grande ganha os hífens sozinho. O que ainda falta fica listrado e tracejado, então dá para ver quanto falta sem ler o contador.

O caso da tela: um livro de sebo com o ISBN-10 só na ficha catalográfica (85-08-06294-X). Como não começa com 978 nem 979, o app entende que é ISBN-10, mostra o chip “ISBN-10 · edição antiga” e conta até 10. O 978 entra sozinho, em roxo, com a legenda “o app completa sozinho”. A última barra (o dígito de conferência do EAN) só aparece quando o último caractere for digitado e conferido.

Teclado: o numérico do sistema, com uma barra do app colada em cima.
• X “dígito final”: fica amarelo só quando faz sentido (ISBN-10 com 9 dígitos digitados). Fora disso fica apagado, e o leitor de tela diz “só para ISBN de 10 dígitos”.
• Colar: aparece quando há algo copiado. Aceita qualquer formato (“ISBN 85-08-06294-X”, com espaços ou pontos) e guarda só os dígitos e o X.
• Esconder teclado.

Busca sozinha ao completar 10 ou 13 caracteres:
• Confere o dígito final. No ISBN-10: pesos de 10 a 2, módulo 11, e X vale 10. No ISBN-13: pesos 1 e 3, módulo 10.
• Se conferir: cantos da etiqueta amarelos, vibração leve, chip “Buscando…” e o teclado desce. Sobe a mesma folha da 03 (encontrado), da 40 (fora da base) ou da 42 (já está na estante).
• Se não conferir (69b): a etiqueta treme uma vez (sem tremor se o celular pedir menos movimento) e a casa final fica rosa. Na etiqueta aparece “Esse número não confere.” e, embaixo, “O erro mais comum: dois vizinhos trocados”. No exemplo, o 9 e o 2 trocaram de lugar (85-08-06924-X em vez de 85-08-06294-X), e o dígito de conferência pega isso. A barra de conferência fica rosa, o X apaga e “Colar” vira “Apagar tudo”. Nada é buscado e nada se apaga sozinho; ao corrigir qualquer dígito, confere de novo.
• Antes de completar, nunca mostra erro.

Regras do número
• Começa com 978 ou 979 → ISBN-13 (conta até 13). Qualquer outro começo → ISBN-10.
• O ISBN-10 vira 978 + 9 dígitos + novo dígito final, e é isso que vai para a busca e fica salvo no livro. O ISBN-10 original fica guardado junto, porque é ele que está impresso.
• Hífens pela tabela oficial de faixas da Agência Internacional do ISBN, que vem dentro do app e se atualiza junto com ele. Se a faixa não for conhecida, o número aparece sem hífens.
• Brasil: 978-85 nos livros até 2020 e 978-65 a partir de 2020.
• Livro sem ISBN (comum antes dos anos 1970): “Buscar pelo título”.

Flutter
• Um TextField de verdade, invisível (opacidade 0), com FocusNode próprio. A etiqueta é desenhada a partir do controller, então teclado, colar, desfazer e leitor de tela funcionam sem trabalho extra.
• keyboardType: TextInputType.number, com FilteringTextInputFormatter.allow(RegExp('[0-9Xx]')) e um formatter próprio que limita o tamanho a 10 ou 13 e só aceita X na 10ª posição.
• Barra do X: um widget no Stack, em bottom: MediaQuery.viewInsetsOf(context).bottom, que sobe e desce com o teclado. Tocar no X acrescenta 'X' ao texto sem tirar o foco.
• As barras são um CustomPainter que recebe os 95 módulos e quantos já foram “impressos”. A animação de cada dígito é um TweenAnimationBuilder.
• Semantics da etiqueta: “ISBN, 9 de 10 dígitos: 8 5 0 8 0 6 2 9 4. Falta o dígito final.” Anunciar “Número confere, buscando” e “Esse número não confere” com SemanticsService.announce.
• Ao voltar para a aba Código: tirar o foco do campo e religar a câmera. O que foi digitado fica guardado até fechar o Scanner.

Referências: Libib (campo de ISBN dentro do próprio scanner), CLZ Books (fila de ISBNs), W3C (aceitar vários formatos), PublishNews (troca de 978-85 para 978-65).

## encontro-flutter (Page 4)

Encontro do clube (70–73). O ingresso pequeno da 04 e da Início abre a 70. Na 32, o cartão “Encontro até o cap. 50” abre a mesma tela.

70 · Detalhe (dom 20 set, 4 dias antes). O ingresso aparece em tamanho grande:
• Parte de cima, no rosa do clube: “Encontro 2 de 6”, o dia enorme (24 · QUI SET), das 20h às 21h30, a pauta e “Online · Anfitriã: Ana”.
• Depois da serrilha, o canhoto creme: “Admite 1 leitora · Marina · Nº 0052”, com um carimbo de tinta roxo que passa por cima da serrilha. O carimbo tem anel duplo, “Leitoras de Capitu” e “Confirmada · 24 set” em arco e “VOU” no centro. Em Talvez, o anel fica tracejado; em Não vou, o carimbo some.
Embaixo do ingresso:
• Você vai?: Vou / Talvez / Não vou, e “Mandar um recado para a Ana”, que abre a 72.
• Sua leitura até quinta: cap. 32 de 26–50 (pág. 159). Faltam 18 capítulos, uns 5 por dia. “Continuar na pág. 159” abre o Leitor.
• Chamada do clube: o botão fica listrado e trancado até 19h45 (15 min antes). Lembretes na véspera, às 20h, e na hora de abrir.
• Perguntas: só perguntas, na ordem da anfitriã. São 4, e a primeira é a pergunta da semana. “Sugerir uma pergunta” manda a sugestão para a Ana aprovar. Aviso: só vale o que acontece até o cap. 50.
• Quem vai: Vão 8, Talvez 3, Não vão 0. As três listas aparecem sempre, mesmo vazias.

71 · Na hora (qui 24, 19h47). Cartão amarelo “Sala aberta desde 19h45”:
• anel de contagem (13 min para começar);
• quem já está na sala (Ana, Rafa e Júlia);
• botão grande “Entrar na chamada”. Câmera e microfone são escolhidos ao entrar.
Se a meta foi cumprida, aparece o selo verde. As perguntas ficam à mão, em versão compacta. “Vou atrasar uns minutos” avisa o clube com uma mensagem pronta; “Não vou conseguir” abre a 72 já em Não vou.

72 · Mudar presença. Uma folha sobre a 70 com três opções grandes, um recado opcional (até 140 caracteres) e quem vê o recado (Só a Ana / O clube todo). A linha “Com a mudança: 7 vão · 4 talvez” mostra o efeito antes de salvar. Um recado só para a Ana aparece para ela na lista de membras, ao lado do nome.

73 · Depois (qui 24, 21h40).
• O ingresso volta sem o canhoto (borda rasgada) e com o carimbo verde “FUI”, no mesmo desenho (“Presente · 24 set” no arco de baixo). O canhoto vai para a carteirinha (2 de 6).
• Quem foi: 9 de 11. A Lu, que estava em Talvez, apareceu.
• O que conversamos: 3 perguntas marcadas pela anfitriã, com a anotação dela embaixo da primeira. A 4ª fica para a semana 3.
• Semana que vem: o ingresso pequeno do encontro 3 (qui 1 out, caps. 51–75), ainda sem resposta.

Regras
• A presença só muda até o começo. Depois disso, quem entrou na sala conta como presente.
• O lembrete da véspera segue a opção “Enquetes e encontros” dos Lembretes (30b).
• O encontro fica “encerrado” quando a anfitriã fecha a sala, ou 30 min depois do horário final.

Flutter
• EncontroPage com o estado calculado pelo relógio: antes (70), salaAberta (71, de 15 min antes até o fim) e encerrado (73). Um Timer.periodic de 30 s recalcula; não precisa consultar a rede para isso.
• Ingresso: a serrilha e as mordidas laterais são um ClipPath com dois círculos subtraídos. O carimbo é um CustomPainter: os anéis, o texto em arco (um TextPainter por letra, girado ao longo do círculo) e um desgaste de tinta com semente fixa por encontro, para não mudar a cada redesenho. Ao confirmar, ele “bate” na tela: escala de 1,15 para 1 com um leve tremor (sem animação se disableAnimations).
• A borda rasgada da 73 é um ClipPath em zigue-zague.
• Presença: SegmentedButton customizado, com atualização otimista. Se falhar, volta ao valor anterior e mostra um SnackBar.
• Folha 72: showModalBottomSheet(isScrollControlled: true), com Padding de viewInsets por causa do teclado.
• “Entrar na chamada” abre o link do clube fora do app.
• Lembretes: notificações locais agendadas no aparelho, para a véspera e para a abertura. Marcar Não vou cancela as duas.
• Acessibilidade: o ingresso é um único Semantics com a frase completa. O anel da 71 diz quantos minutos faltam quando recebe o foco.

Referências: Bookclubs (botão da chamada 15 min antes), Apple Invites (recado junto da resposta), análise do Partiful (mostrar quem não vai), Fable (perguntas e conversa sem spoiler), Pinterest (ingressos retrô e carimbos circulares, de passaporte e de tinta).

## resenha-flutter (Page 5)

Resenha aberta (74–76). Abre do “Ler tudo” na 43 e do aviso “Pedro e mais 4 curtiram sua resenha” na 30. O aviso já abre a tela rolada até as curtidas.

74 · Resenha aberta. O topo é em estilo revista: o grifo escolhido na 46 vira a citação de abertura, em serifa itálica grande, com marca-texto amarelo e aspas coral (“Ao vencido, ódio ou compaixão; ao vencedor, as batatas.” · pág. 12).
Depois da linha tracejada vêm a capa, o título, o autor e o ano, as 4 ★, a data e os climas (irônico, reflexivo). Em seguida, o texto inteiro, em 16 px com entrelinha 1,6.
A faixa de curtidas mostra 3 rostos e “Pedro, Júlia e mais 12 curtiram” (abre a 76), mais os botões de curtir (14) e comentar (3).
• Comentários em fio de 1 nível: a resposta fica recuada, com uma linha à esquerda. Quem responde a uma resposta continua no mesmo fio, com @menção. A ordem padrão é dos mais antigos para os mais novos, como uma conversa, e dá para trocar para “mais curtidos”.
• Spoiler: o app sabe quem terminou o livro. Quem terminou vê o comentário normal, com a etiqueta preta “Spoiler · aparece porque você terminou”. Quem não terminou vê o texto borrado, com a pílula “Contém spoiler · tocar para ler”, a mesma da 43. Quem não tem o livro como Lido conta como quem não terminou.
• O campo de comentário fica fixo embaixo, com o olho riscado para marcar spoiler.

75 · Responder comentário. A lista rola até o comentário respondido ficar logo acima do campo, destacado em lavanda; o resto fica apagado. O campo mostra “Respondendo a Pedro” (o x cancela) e a menção @Pedro já vem como chip. O botão de enviar fica amarelo quando há texto. Como o comentário original é spoiler, a resposta já vem marcada como spoiler, e dá para desligar.

76 · Quem curtiu. Uma folha alta sobre a resenha: “14 curtidas na resenha.”, separadas em Hoje (as 5 do aviso) e Antes (9). Cada linha tem avatar, nome, relação (vocês se seguem, segue você, Leitoras de Capitu, anfitriã do clube) e o botão Seguindo ou Seguir de volta. Quem vê a resenha segue a regra da Privacidade (56); por isso só aparecem seguidoras e gente do clube.

Regras
• Até 1 000 caracteres por comentário. Dá para editar por 15 min, e aparece “editado”.
• A autora da resenha pode apagar qualquer comentário; quem comentou pode apagar o próprio.
• Curtir a própria resenha não conta.
• Os avisos de curtida chegam agrupados (“Pedro e mais 4”), como na 30.

Flutter
• ResenhaPage: CustomScrollView com SliverToBoxAdapter (citação, livro e texto) e um SliverList para os fios. O campo fica fixo em Scaffold.bottomNavigationBar, com Padding de viewInsets para subir com o teclado.
• Marca-texto da citação: TextPainter.getBoxesForSelection devolve uma caixa por linha, e cada caixa ganha o seu pedaço amarelo.
• Fio: um Column por comentário principal. As respostas ficam num Padding à esquerda, com uma borda só do lado esquerdo.
• Menção: o campo guarda os ids das menções separado do texto, e o chip é um WidgetSpan.
• Spoiler borrado: ImageFiltered(ImageFilter.blur) + ExcludeSemantics no texto. O botão “tocar para ler” continua acessível.
• Responder: depois que o teclado abre, Scrollable.ensureVisible leva até o comentário respondido.
• Curtir é otimista, com HapticFeedback.lightImpact.

Referências: StoryGraph (spoiler longo vira uma tarja que cansa; melhor borrão + tocar), Letterboxd e Goodreads (curtidas e comentários com resposta embaixo da resenha), Pinterest (citações em destaque de revista).

## estatisticas-mes-ano (Page 5)

Estatísticas · Mês e Ano (77–78). Usam as mesmas abas e setas da 29. No período atual, a seta para frente fica apagada.

77 · Mês (setembro de 2026, até dom 20).
• Topo: “Lido em setembro: 10 h 40 min”, o chip “13 dias na meta” e uma comparação gentil (“1 h 10 a mais que agosto até o dia 20”). Quando o número for menor, aparece só ele, sem seta e sem vermelho.
• Barras dos 30 dias:
  – lavanda: bateu a meta;
  – listrado: leu menos que a meta;
  – tracinho: não leu (dias 4 e 8);
  – tracejado: dias que ainda vêm;
  – amarelo: hoje.
  Linhas finas separam as semanas, que começam na segunda. A soma bate com a 29: de 14 a 20 set são 4 h.
• Média de 32 min por dia, leitura em 18 de 20 dias e melhor dia no dom 6 (61 min).
• Terminados: Helena (6 set, 3 ★), Quincas Borba (17 set, 4 ★) e O Alienista (18 set). O Alienista ainda não tem resenha, e “Resenhar” abre a 46.
• Onde foram os minutos: 7 livros, com barras verdes para papel (5 h 40) e lavanda para e-book (5 h 00). O Alienista lidera porque foi lido inteiro no mês (2 h 50, como na 46).
• Sequência: 12 dias desde 9 set, recorde de 41. O calendário continua na aba Semana.

78 · Ano (2026 até agora).
• Estante da meta: 30 lombadas em duas prateleiras, 24 coloridas (lidos) e 6 tracejadas (faltam). Uma bandeirinha coral marca onde o ritmo da meta estaria hoje (22). O texto diz que faltam 6 livros até dezembro, um a cada 17 dias, e compara de forma gentil com 2025.
• Livros por mês em pilhas pequenas, com out–dez tracejados. Horas por mês: 123 h 40 no ano, com setembro em amarelo porque ainda não acabou. Média de 28 min por dia, melhor mês em julho (17 h) e recorde de 41 dias.
• Tamanho dos livros (curtos, médios e longos) e autores mais lidos, com um convite para a lista “Machado do começo ao fim” (faltam 5 romances).
• Nada de retrospectiva aqui: “Livros do ano” só aparece em dezembro.

Regras
• A comparação só aparece quando há dados do período anterior no mesmo ponto (o mesmo dia do mês ou do ano).
• Dia com menos de 5 min não conta como dia de leitura, igual à sequência.
• As páginas são opcionais. O tamanho dos livros usa o número de páginas da edição quando ele existe; livros sem esse número ficam fora do gráfico.

Flutter
• Uma StatsPage com TabBar (Semana / Mês / Ano) e um PageView por período. Cada período é um FutureBuilder sobre um resumo calculado no aparelho a partir das sessões. Períodos fechados ficam em cache; só o atual é recalculado.
• Barras: um único CustomPainter desenha as 30 barras, a linha da meta e os separadores, o que é mais leve que 30 widgets. Tocar numa barra mostra o dia e os minutos.
• Estante: um Wrap de lombadas. A altura e a largura de cada uma vêm do id do livro, para não mudarem a cada abertura. Tocar numa lombada abre o livro.
• Semantics: cada gráfico tem um rótulo com os números, e as listas são lidas normalmente.

Referências: StoryGraph (livros por mês, tamanho e clima), Goodreads (à frente ou atrás do ritmo da meta), Bookly (tempo por sessão; falta o horário do dia), Pinterest (rastreadores de leitura em forma de estante).

## conquistas-flutter (Page 5)

Conquistas (79–82): um álbum de figurinhas. Abre do “Ver todas” no Perfil (05) e do aviso “Selo novo” (30).

79 · Álbum. No topo: “12 de 30 coladas”, 3 brilhantes, 1 repetida e uma tira de 30 casas (com cor = colada; tracejada = falta). Abas Álbum | Quase lá. São cinco páginas com 6 figurinhas cada, numeradas de 01 a 30:
• Ritmo no compasso: Sequência (selo vivo, nível 12, ×2), Um mês sem parar (brilhante, 31 mar), Cem dias na meta, Coruja 7/10, Madrugadora 1/10, Maratona (melhor dia 2 h 10, de 3 h).
• Livros na estante: 10 clássicos brasileiros, Tijolão (brilhante, Crime e Castigo), Volta ao mundo 3/5, Meta do ano 24/30, Machado do começo ao fim 4/9, Releitura.
• Grifos na margem: Primeiro grifo, Mão de lápis (200), Arco-íris (as 4 cores), Desenhista 6/10, Revisora 3/7, Mil grifos 214/1000.
• Clube em roda: Voz do clube, Anfitriã (brilhante, Poesia de domingo), Presença 1/3, Eleitora 0/3, Leitura conjunta (semana 2 de 6), Ponte 1/3.
• Descobertas no caminho: Resenhista 8/10, Querida (22 curtidas na Metamorfose), Garimpeira de sebo (ISBN-10, como na 69), Scanner de bolso e 2 secretas.
Figurinha colada: borda branca de recorte, sombra dura, leve inclinação e um reflexo. Brilhante: fundo holográfico em tons pastel. Figurinha que falta: contorno tracejado no formato dela, desenho apagado, número, dica e barra de progresso.

80 · Quase lá. As 9 mais perto, ordenadas pelo que falta. A figurinha vai aparecendo de baixo para cima: a parte colorida é o progresso, e a linha coral marca até onde ela já chegou. Quando dá para avançar agora, a linha traz um atalho: Resenhar O Alienista (vai a 9/10), Ver a estante (78), Ver o encontro (70), Votar agora (49).

81 · Detalhe. A figurinha grande (Um mês sem parar) sobre raios amarelos e confete, com o número, o grupo e “brilhante”. O verso da figurinha, em papel pautado azul, traz a data, a maior sequência (41 dias, mar–abr), a raridade (8% das leitoras) e os livros terminados nesses dias. “Fixar no perfil” troca uma das 4 figurinhas do Perfil; “Compartilhar” gera a imagem da figurinha.

82 · Figurinha nova. Raios coral, confete e o pacotinho de figurinhas rasgado, com a figurinha subindo de dentro dele. É o nível 12 da Sequência, repetida ×2 (já tinha vindo na sequência de março), com o próximo nível embaixo (14, faltam 2). “Colar no álbum” leva até a casa 01 e cola a figurinha com animação.

Regras
• A Sequência é um selo vivo: cada sequência sobe de nível (3, 7, 12, 14, 21, 30…). Ganhar de novo um nível numa nova sequência gera uma repetida. Quando a sequência acaba, não tem bronca.
• Nenhuma conquista some ou expira. As secretas mostram só ??? até serem ganhas.
• O aviso “Selo novo” segue a opção “Conquistas” nos Lembretes (30b).

Flutter
• ConquistasPage com TabBar (Álbum, Quase lá). Cada página do álbum é um Card com um GridView de 3 colunas (shrinkWrap, dentro de um CustomScrollView).
• Figurinha: um widget Sticker(formato, arte, estado). Um CustomPainter desenha o recorte (um Path por formato), a borda branca, a sombra e o reflexo; a arte é um SVG local. Brilhante: ShaderMask com LinearGradient e um leve movimento pelo giroscópio (desligado se disableAnimations).
• Figurinha que falta: o mesmo Path com borda tracejada e a arte com ColorFilter cinza a 15%.
• Quase lá: um ClipRect com heightFactor igual ao progresso, sobre a versão colorida.
• Figurinha nova: Hero da figurinha até a casa 01 do álbum. O pacote rasga com um AnimationController de 300 ms e HapticFeedback.mediumImpact.
• Semantics: cada casa diz nome, número e estado (“colada em 31 mar” ou “falta: 7 de 10 noites”).

Referências: Pinterest (álbuns de figurinhas, pins de esmalte de livros, patches e merit badges, badges de jogo), Apple Fitness (grupos e bloqueadas em cinza), Duolingo (críticas à troca da trilha de progresso por uma estante de troféus; aqui ficam as duas).

## pro-decisoes (Page 20)

Plano Pro (83–88). Decisões combinadas em 3 out, antes de desenhar.

PREÇOS (conferidos)
• Mensal: R$ 9,99 por mês.
• Anual: R$ 79,99 por ano (R$ 6,67 por mês). A economia é de R$ 39,89, ou 33%, contra 12 × R$ 9,99 = R$ 119,88.
• A frase “pague 8 meses, leve 12” saiu: 8 × R$ 9,99 = R$ 79,92, que não é igual a R$ 79,99.
• Teste grátis de 7 dias nos dois planos. O botão e a linha de baixo dizem quando começa a cobrança.

O QUE É GRÁTIS E O QUE É PRO
• Grátis: dados só neste celular (quem desinstala perde), até 3 clubes e compartilhamento por link e texto.
• Dentro do clube nada muda: membros (32), discussão e encontros continuam iguais. O que pede o Pro é o perfil completo de outra leitora (51) e os grifos públicos dela (52).
• Pro: dados na nuvem e sincronizados entre aparelhos, guardados por 12 meses se a pessoa cancelar. Também libera perfis e grifos de outras leitoras, Estatísticas de Mês e Ano com comparação (77–78), clubes ilimitados e cartões com imagem para compartilhar (63, 81 e a carteirinha).

HISTÓRIA NO CANVAS
A Marina é grátis. Ela bate no bloqueio do perfil da Júlia (85) e das Estatísticas (86), assina o mensal com 7 dias de teste (84), vê a 87 e cuida da assinatura na 88, que oferece “Mudar para o anual”. As telas 51, 52, 77 e 78 mostram o lado Pro.

FIGURINHA “LEITORA PRO”
Fica fora das 30 do álbum, numa capa especial que só aparece para quem é Pro. O “12 de 30” não muda.

CAMINHO
Ajustes › Assinatura: um item novo no topo dos Ajustes (06), com o selo Pro. No app, o nome da área é “Ajustes”, não “Configurações”.

REGRAS
• Não inventar números: nada de usuários, avaliações ou depoimentos.
• Preço, renovação e cancelamento aparecem legíveis sem rolar. No anual, o valor cobrado (R$ 79,99 por ano) é maior que o equivalente mensal, como pede o Google Play.
• O X fica sempre visível no topo à esquerda.
• Termos, Privacidade e Restaurar compras ficam na própria tela, como pede a Apple.

TOPO DA 83, DUAS VARIAÇÕES (ao lado)
• A · Carteirinha em destaque: um painel lilás com raios e a carteirinha Pro (faixa lilás e selo PRO com estrela) bem grande.
• B · Grátis × Pro: a carteirinha grátis (faixa coral, “só neste celular”) fica atrás, e a Pro vem na frente. Em cima, dois celulares ligados por uma nuvem.
ESCOLHIDA: B. Botão “Começar 7 dias grátis”, com os dois planos lado a lado logo acima (R$ 9,99 e R$ 79,99).

Referências: Google Play (termos de assinatura visíveis; anual sem destacar o valor mensal), Apple (dados da assinatura, Termos, Privacidade, Restaurar), ScreensDesign (anual como padrão, selo de economia com base clara, X sempre à mão), Pinterest (telas de assinatura).

## pro-flutter (Page 20)

Plano Pro · as telas (83–88)

83 · Planos, com o anual marcado. Tela cheia, sem a barra de baixo. O X redondo fica no topo à esquerda e nunca some. No topo (variação B): dois celulares ligados por uma nuvem e as duas carteirinhas — a grátis (“só neste celular”) atrás e a Pro (“na nuvem”, selo PRO) na frente. Título “Sua estante, em qualquer lugar.” e 5 benefícios, cada um com uma figurinha pequena.
Painel preso embaixo, sempre à vista: Anual e Mensal lado a lado. O anual vem marcado (amarelo, sombra dura, etiqueta torta “Melhor valor · 33% off”), com R$ 79,99 por ano em destaque e R$ 6,67 por mês menor. Botão “Começar 7 dias grátis” e, logo abaixo, “Depois, R$ 79,99 por ano. 1ª cobrança em 27 set. Cancele antes e não paga nada.” Depois: “Agora não”, “Grátis: seus dados ficam só neste celular.”, a frase de renovação e Termos · Privacidade · Restaurar compras. Tudo cabe em 844 px, sem rolar.

84 · Mensal marcado. O mensal fica amarelo e a linha muda para “Depois, R$ 9,99 por mês.” O anual mantém a etiqueta, sem pressão.

85 · Perfil da Júlia bloqueado. Nome, foto e números ficam (21 em comum, 58 grifos, 12 resenhas); o resto fica embaçado, com um cadeado. Folha igual à de “quem curtiu” (76): “Veja tudo de Júlia com o Pro”, “Conhecer o Pro” e “Agora não”, mais a lembrança de que no clube nada muda.

86 · Estatísticas com Mês e Ano bloqueados. Cadeado nas duas abas, prévia embaçada do mês e o cartão amarelo “Seu mês de setembro, completo, no Pro”. A semana (29) continua grátis.

87 · Bem-vinda ao Pro. No padrão da 82: raios lilás, o pacote “Edição especial · Pro” e a figurinha holográfica “Leitora Pro” (fora das 30). Mostra o que subiu para a nuvem (52 livros, 214 grifos, 8 resenhas), o fim do teste (27 set) e “Voltar para minha estante”.

88 · Gerenciar assinatura (Ajustes › Assinatura). Pro · Mensal “em teste grátis”, próxima cobrança 27 set 2026, R$ 9,99/mês. “Seus dados: na nuvem · guardamos por 12 meses se você cancelar.” Cartão amarelo para mudar para o anual, Restaurar compras, Gerenciar na loja (cancelar é na loja) e Excluir conta em vermelho escuro, longe do polegar.

ESTADO GRÁTIS NAS TELAS QUE JÁ EXISTIAM
• Ajustes (06): selo “Dados só neste celular” e a linha nova “Assinatura · Grátis”.
• Conta (58): Sincronização “só neste celular”; aparelhos: “Só este celular · mais aparelhos com o Pro”.
• Sem internet (37): “Ficam guardados neste celular”.
• Estatísticas (29): cadeado pequeno em Mês e Ano.

FLUTTER
• Compras pelo plugin oficial do Flutter para compras no app (App Store e Google Play). Os dois produtos, com 7 dias de teste, ficam cadastrados nas lojas, e o preço na tela vem da loja já no formato local; nada de preço fixo no código.
• O recibo é validado no servidor, que grava na conta o direito “pro” (ativo, em teste, fim do teste, renova em). O app só lê esse estado. Os avisos da loja atualizam renovação, cancelamento e reembolso.
• Paywall: Scaffold sem a barra de abas; a parte de cima rola, e o painel de compra fica fixo embaixo, para preço e termos nunca dependerem de rolagem. O plano escolhido mora num ValueNotifier; o botão mostra carregando enquanto a loja abre.
• Bloqueios (85, 86): a própria tela com ImageFiltered (blur) a partir de um ponto; a folha usa showModalBottomSheet.
• Nuvem: ao assinar, o que está no celular sobe numa fila em segundo plano. Se cancelar, o app volta a guardar só no celular e a cópia na nuvem fica 12 meses.
• Frequência: o paywall só abre quando a pessoa toca numa função Pro ou em Assinatura. Depois de “Agora não”, o mesmo bloqueio não abre a tela sozinho.

Referências: Apple (App Review 3.1.2, assinaturas), Google Play (política de assinaturas), ScreensDesign e Pinterest (telas de assinatura).

## seguidores-flutter (Page 5)

Seguidores e seguindo (89–92). Abrem pelos números do Perfil (05): “248 seguidores” abre a 89 e “180 seguindo” abre a 90. Na Júlia (51), “312 seguidores” abre a 92.

89 · Seguidores. Título “Sua roda de leitura.” e as abas Seguidores 248 | Seguindo 180, com busca embaixo. Como o perfil da Marina é fechado, a faixa amarela “3 pedidos para seguir · Tomás, Nina e Bia esperam” fica no topo e abre os Pedidos (57); os nomes são os mesmos da Privacidade (56).
Lista em ordem A–Z, com letras grandes em serifa itálica e um índice fino na lateral (letras sem ninguém ficam apagadas: K, W, X, Y). Cada pessoa mostra só um contexto, nesta prioridade: clube em comum › livros em comum › pessoa em comum › “segue você”. Nunca aparece “não segue você”.
Quem a Marina ainda não segue ganha “Seguir de volta”. Todas as linhas têm o “⋯” (ver perfil, remover, bloquear).

90 · Seguindo, no meio da rolagem. O título encolhe para a barra (“Sua roda de leitura”) e as abas ficam presas no topo. O dedo está no índice (círculo tracejado), no J: aparece o balão lilás com a letra, a lista pula para o J e o cabeçalho “J” fica preso. Cada linha tem “Seguindo”; tocar pergunta “Deixar de seguir?”.

91 · Remover seguidora. Folha sobre a 89 com a Antônia: “Remover Antônia dos seguidores?” e três respostas:
• ela não recebe aviso;
• como o perfil é fechado, para ver de novo a estante, as resenhas e as listas ela precisa pedir para seguir;
• no clube nada muda.
Botão coral “Remover Antônia” e “Cancelar”. Bloquear continua no “⋯” e no perfil dela.

92 · Seguidores da Júlia (Pro). Mesmo desenho, com o @julia.le no topo, “A roda da Júlia.” e as abas 312 | 205. A faixa verde “Você também segue 12 · Lu, Ana, Carol e mais 9” filtra só essas pessoas. Os botões são do ponto de vista da Marina (Seguir / Seguindo). No plano grátis, tocar em “312 seguidores” abre a folha do Pro (85). A sua própria lista é sempre grátis.

DADOS
• Os números vêm do Perfil (05): 248 e 180. A Júlia tem 312 (51).
• Estão na lista quem curtiu a resenha (76), porque, com perfil fechado, só seguidores veem as resenhas. Com isso, a 76 foi corrigida: o Pedro segue a Marina, mas ela não segue ele. O perfil dele é fechado (53), então o botão é “Pedir para seguir”.
• Bia, Tomás e Nina ainda são pedidos e não aparecem como seguidores.

FLUTTER
• NestedScrollView com SliverAppBar (o título grande encolhe) e TabBar presa num SliverPersistentHeader. Cada aba é um CustomScrollView com uma SliverList por letra e um cabeçalho fixo.
• A–Z sem diferenciar acento: Antônia fica no A e Júlia no J (comparação sem acento e sem maiúsculas). A lista vem do servidor em páginas, com cursor.
• Índice: uma coluna com GestureDetector (onVerticalDragUpdate). A posição do dedo vira uma letra; se a letra está vazia, vai para a próxima com gente. Pula com o ScrollController e dá um toque leve (HapticFeedback.selectionClick) a cada letra. O balão aparece só durante o arraste. No leitor de tela, cada letra é um botão “Ir para J”.
• Busca por nome ou @, com espera de 300 ms; em listas grandes, busca no servidor.
• Seguir, seguir de volta e deixar de seguir mudam na hora e voltam atrás se der erro. Remover tira a linha com AnimatedList e mostra “Antônia saiu dos seus seguidores · Desfazer” por 5 s.
• Quem vê as listas segue o perfil: aberto, todos; fechado, só seguidores aprovados. Contas bloqueadas nunca aparecem.

Referências: Pinterest (remover seguidor pelo “⋯” e deixar de seguir na própria lista), Instagram (o teste da lista “Amigos” só com mútuos teve reação ruim, então o BookNest não destaca quem não segue de volta), pedidos de “remover seguidor” no Spotify e no Bluesky, Mobbin (telas de seguidores) e Pinterest (ideias de listas).

## publico-flutter (Page 6)

Escolher público (93–97). Uma folha só, usada em todo lugar onde aparece “Quem vê”: as pílulas da Privacidade (56), a pílula da lista (67) e o menu ⋯ do livro (17). Na Escrever resenha (46), a escolha continua em linha, com os mesmos três níveis.

OS TRÊS NÍVEIS (cartões grandes, cada um com a sua cor e a sua figurinha recortada, como no álbum: Todos amarelo com o globo, Seguidores verde com as duas leitoras, Só eu rosa com o cadeado no escudo. As figurinhas têm 66 px e saem pela borda de cima, à esquerda. Os outros cartões ficam num tom claro da mesma cor; o escolhido ganha a cor cheia, borda mais grossa, sombra dura, uma leve inclinação e o selo preto “ESCOLHIDO”)
• Todos: qualquer pessoa no BookNest, mesmo sem seguir você.
• Seguidores: com o perfil fechado, as 248 pessoas que você aprovou; com o perfil aberto, as 248 que seguem você.
• Só eu: fica no seu perfil com um cadeado, e ninguém mais vê.
Com o perfil fechado, Todos fica TRAVADO (contorno tracejado e a figurinha só em silhueta, como as que faltam no álbum), com “Seu perfil é fechado” e o atalho “Abrir meu perfil”, que leva à escolha Aberto/Fechado no topo da 56. O X fica sempre no topo e o voltar do sistema também fecha a folha.

93 · Quem vê suas resenhas. Abre na pílula “Resenhas · Seguidores” da 56 e muda o padrão das próximas resenhas. Na hora de publicar, cada resenha ainda pode ter o seu.

94 · E as 8 já publicadas? Ao trocar para Só eu, a mesma folha (sem abrir outra por cima) pergunta o que muda. Mostra as capas das resenhas e duas saídas, também com figurinhas:
• Só as novas: as 8 continuam para Seguidores.
• As 8 também: elas saem do perfil para os outros; curtidas e comentários ficam guardados e voltam se ela abrir de novo.
“Voltar e manter Seguidores” desfaz a troca. Se não há nada publicado, a pergunta não aparece.

95 · Quem vê esta lista. Abre na pílula da 67 e vale só para “Machado do começo ao fim”. Seguidores podem ver e salvar.

96 · Variação com o perfil aberto. Todos fica livre e, quando escolhido, avisa: aparece na busca de listas e qualquer pessoa pode salvar.

97 · Quem vê este livro. No ⋯ do livro (17), Brás Cubas em Só eu. Ele continua contando nas metas, na sequência e nas estatísticas, mas some da estante, do “lendo agora” e das atividades para os outros. No clube, a votação não muda, porque o livro é do clube.

CORREÇÕES (o perfil da Marina é fechado)
• 46: Seguidores vem marcado, e Todos aparece travado com uma linha explicando.
• 67: a pílula agora diz Seguidores.
• 45: as listas mostram “Seguidores” no lugar de “pública”. A “Faculdade” continua “só eu”.

FLUTTER
• showModalBottomSheet com isScrollControlled e useSafeArea. Cada cartão é um Radio com Semantics(inMutuallyExclusiveGroup). O travado usa onChanged: null e explica o motivo no rótulo de acessibilidade.
• Um enum Publico {todos, seguidores, soEu}. O servidor guarda o padrão por tipo (estante, resenhas, listas, grifos) e o valor de cada item, e filtra no servidor; o app só mostra.
• 94: AnimatedSwitcher troca o conteúdo da mesma folha. “As 8 também” é uma atualização em lote no servidor, com “Desfazer” num SnackBar por 5 s.
• Livro em Só eu: as estatísticas e metas leem todos os livros da pessoa; o que os outros veem passa pelo filtro de público.
• Se a pessoa fechar o perfil, tudo que estava em Todos passa a valer como Seguidores; ao abrir de novo, volta ao que era.

Referências: Facebook (padrão mais seguro e aviso antes de publicar para todos), NN/g sobre folhas (X visível, voltar do sistema fecha, não empilhar folhas) e StoryGraph (pedido de esconder um livro sem tirar das metas).

## bloqueadas-flutter (Page 6)

Bloqueadas (98–101). Abre na Privacidade (56): “Bloqueadas · Somem dos dois lados · 1”.

98 · Quem você bloqueou. Um cartão rosa explica a regra: bloquear some dos dois lados (nenhuma das duas vê o perfil, os grifos ou as resenhas da outra) e a pessoa não recebe aviso. Na lista, a Renata Viana (@re.viana, desde 2 ago). A foto fica escondida: no lugar dela, um círculo tracejado com o olho cortado, para a imagem não reaparecer sem querer. Botão “Desbloquear” em contorno. Embaixo, o caminho para bloquear: perfil da pessoa › ⋯ › Bloquear (ou o ⋯ de uma linha em Seguidores, 89). Quem você bloqueia some da busca, das sugestões, dos seguidores e das notificações.

99 · Desbloquear a Renata? Folha com três respostas:
• ela volta a achar seu perfil, mas, como ele é fechado, só vê a estante se você aprovar um pedido;
• ela não recebe aviso;
• nada volta sozinho: ela não volta a seguir, e o que ficou escondido continua escondido.
Botão escuro “Desbloquear Renata” e “Cancelar”.

100 · Bloquear a Renata? Abre no ⋯ (amarelo) do perfil dela, que é fechado. O fundo mostra o contexto: nenhuma pessoa em comum e “Você recusou um pedido dela em julho”. A folha explica o que muda (se ela seguia você, deixa de seguir; não pode pedir de novo; no clube, as mensagens dela ficam recolhidas só para você). Botão coral “Bloquear Renata”, “Cancelar” e o link “Algo grave? Denunciar também”.

101 · Variação: se ela estivesse no clube. Na discussão (31), a mensagem vira um bloco tracejado: “Mensagem recolhida · 40 min · De alguém que você bloqueou” e o botão “Mostrar só desta vez”. Uma linha avisa que só a Marina vê assim; para o resto do clube a conversa segue normal. A Renata não está em nenhum clube da Marina, por isso a contagem continua 1 e a lista de membros (32) não muda.

FLUTTER
• Um documento de bloqueios por pessoa, guardado no servidor. As consultas de perfil, busca, seguidores, notificações e grifos públicos já vêm filtradas nos dois sentidos; o app não precisa esconder nada sozinho.
• Bloquear apaga o vínculo de seguir nos dois sentidos e os pedidos pendentes, numa única operação no servidor.
• Na lista, o avatar é um widget próprio (sem carregar a imagem da pessoa). Desbloquear remove a linha com AnimatedList e mostra um SnackBar.
• Clube: a mensagem continua no fio para todo mundo; só o widget da Marina troca o conteúdo por um bloco recolhido. “Mostrar só desta vez” guarda a escolha só enquanto a tela está aberta.
• Bloquear é diferente de remover seguidora (91): remover é silencioso e a pessoa pode pedir de novo; bloquear impede tudo.

Referências: X (o bloqueio não avisa e, ao desbloquear, é preciso seguir de novo), Instagram (desbloquear não devolve seguidores nem curtidas), Signal (Ajustes › Privacidade › Bloqueados, com desbloquear na própria lista) e o padrão de mensagem bloqueada com “mostrar” em apps de chat em grupo.

## votos-flutter (Page 4)

Quem votou em… (102–104). Abre ao tocar nos avatares de um livro: na prévia da enquete no Clube (04) e na contagem final do Resultado (50). É uma folha só, com uma aba por livro, e abre na aba do livro tocado.

102 · Enquete aberta. “9 de 11 votaram · fecha ter, 20h”. Abas Memórias 5 | O Cortiço 3 | Senhora 1. Na aba aberta: a capa, a barra ondulada na cor do clube (5 de 9) e as pessoas, da mais recente para a mais antiga, com o dia e a hora do voto: Marina (você, hoje 9h), Gabi (sáb 10h), Helô (sex 13h), Júlia (qui 21h) e Ana (anfitriã, qui 9h). No fim, “Faltam Dani e Fê”, com avatares tracejados e a hora do lembrete automático da 47 (seg, 20h). Sem botão de cutucar. Os votos só aparecem para quem já votou (a mesma regra da 49), e dá para mudar o voto até fechar.

103 · Resultado. “11 de 11 votaram · fechou ter 22, 20h”. A aba Memórias ganha o selo VENCEU. Na aba O Cortiço: Fê (seg 20h30, depois do lembrete), Bia (dom 18h), Rafa (sex 22h) e Lu (qui 8h). Os votos ficam visíveis só para as 11 do clube.

104 · Variação: voto secreto. Se a anfitriã ligar “Voto secreto” ao criar a enquete (47), a folha mostra 9 avatares listrados, sem nomes, e o carimbo lilás SECRETO. Ficam só as barras com os números, e o selo “seu voto” no livro da Marina, que só ela vê. Nem a anfitriã sabe quem votou em quê.

DADOS (iguais à 04, à 49 e à 50)
• Antes do voto da Marina: 8 de 11. Depois: 9 de 11, com Memórias 5 (Marina, Ana, Júlia, Gabi e Helô), O Cortiço 3 (Lu, Rafa e Bia) e Senhora 1 (Carol). Faltavam Dani e Fê.
• No final: Memórias 6 (mais a Dani), O Cortiço 4 (mais a Fê) e Senhora 1.

FLUTTER
• showModalBottomSheet com DraggableScrollableSheet. TabBar com 3 abas e a contagem em cada uma; initialIndex = livro tocado.
• Cada voto é um documento {pessoa, livro, quando}; mudar de voto troca o livro e a hora. A lista vem ordenada pela hora, da mais nova para a mais antiga.
• Regra no servidor: quem ainda não votou recebe só os totais (sem nomes) e nem isso antes de votar; no voto secreto, ninguém recebe nomes, só os totais e o próprio voto.
• O lembrete de seg 20h é um aviso agendado pelo servidor para quem ainda não votou.

Referências: Telegram (enquete com votos visíveis ou anônima, escolhida na criação), WhatsApp (“Ver votos”, com nomes e hora por opção) e Pinterest (telas de resultado de enquete com avatares).

## convites-pro (Page 20)

Convites do Pro para quem é grátis (105–111). Aparecem de vez em quando, em momentos de valor, e falam só do mensal: “Teste 7 dias grátis. Depois, R$ 9,99 por mês. Cancele quando quiser.” O botão abre os Planos com o mensal marcado (84).

REGRAS
• No máximo 1 convite por semana. “Agora não” (ou o X) pausa aquele convite por 14 dias.
• Nunca durante a leitura (leitor, cronômetro, modo anotação) nem no meio de um fluxo.
• O 4º clube (106) e o celular novo (111) não contam na regra da semana: aparecem quando a pessoa precisa, porque são um limite e uma informação.
• Sempre com saída visível: X ou “Agora não”, e uma alternativa sem pagar quando existe (sair de um clube, exportar e importar, ver só a semana).
• Sem números inventados: só dados da própria Marina (52 livros, 214 grifos, 8 resenhas, 3 clubes, 58 grifos públicos da Júlia, 24º livro de 2026).

105 · Fim da sessão (folha sobre a 18b, depois de “Salvar sessão”). Figurinha da nuvem e “Sua leitura de hoje está só neste celular”. Um recibo mostra 52 livros, 214 grifos e desenhos, 8 resenhas, com “Guardado em: só este celular”. Explica o risco real do plano grátis (quebrar, trocar ou apagar o app) e o que o Pro resolve.

106 · 4º clube. A Júlia chamou a Marina para o Russos de cabeceira (4 leitoras, 1º livro em votação). O cartão amarelo avisa antes de travar: “Você já está em 3 clubes”, com os 3 (Leitoras de Capitu, Sci-fi às quartas e Poesia de domingo). Saídas: “Entrar com o Pro · 7 dias grátis”, “Sair de um clube e entrar” e “Agora não · o convite vale por 7 dias”.

107 · Cartão no Início. Entre “Seu dia de leitura” e “Seus grifos de hoje”, um cartão lilás “Dica do Pro”, com um benefício por vez. Este é “A Júlia tem 58 grifos públicos”: dois grifos embaçados e o cadeado “Grifos de outras leitoras são do Pro”. O X esconde por 14 dias.

108 · Resumo do mês (qui, 1º de outubro). Tela cheia lilás com raios, “Setembro acabou.” e a capa da revista do mês embaçada (horas, livros, melhor dia, horário) com o selo PRO. “Ver meu setembro”, “Agora não” e “Ver só a semana” (a semana continua grátis).

109 · Livro lido. Comemoração de O Alienista: carimbo verde LIDO (Machado de Assis · 18 set 2026), 2 h 50 min, 24º livro de 2026, “Escrever resenha” (46) e “Só dar a nota”. No pé, um convite pequeno: “Seu 2026 mês a mês, com comparação”, com “Conhecer o Pro” e X.

110 · Compartilhar (grátis). Folha sobre Grifos e notas (25): a prévia do texto com “link do grifo no BookNest”, e Copiar link, Enviar texto, Mais apps. Embaixo, a faixa lilás com o cartão com imagem travado (o mesmo da 63): “Compartilhe como cartão com imagem”.

111 · Celular novo. Ao entrar num celular novo, a estante chega vazia, e o app explica: a conta, os seguidores e os clubes já estão aqui, mas os livros, grifos e resenhas ficaram no celular antigo. Dois caminhos: 1) trazer tudo com o Pro (assinar e abrir o app no celular antigo, que manda tudo para a nuvem); 2) trazer por arquivo (exportar em Conta, importar aqui). “Começar do zero aqui” fica por último.

FLUTTER
• Um ConviteService decide se mostra: lê o último convite exibido, as pausas de 14 dias por tipo e a tela atual. O servidor manda a lista de convites ligados (dá para desligar um sem nova versão do app).
• O texto do preço vem da loja (o mensal já formatado em reais); o teste de 7 dias também vem da oferta da loja.
• 107 é um widget no feed; 105, 109 e 110 usam showModalBottomSheet; 106, 108 e 111 são rotas cheias com o X no topo.
• 111: ao entrar, o app compara o aparelho com o último que salvou dados; se for outro e a conta for grátis, abre esta tela em vez da estante vazia.

Correção junto: na 04, o 3º clube da Marina agora é o Poesia de domingo (o clube que ela criou na 33), no lugar do “Clube do escritório”. Assim ela tem os mesmos 3 clubes do Perfil (05).

Referências: Eleken (tipos de paywall, com prévia e timing nos momentos de progresso), Appcues (o Spotify trata o limite como “você descobriu um recurso Premium” e avisa antes de travar), Smashing e NN/g (sempre mostrar o motivo e a saída) e Pinterest (cartões e faixas de upgrade premium).

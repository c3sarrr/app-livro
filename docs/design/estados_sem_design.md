# Estados sem design (D-21)

Telas e estados que o app precisa ter **antes** de o design chegar. Regra da D-21: nada de inventar
layout — só texto Figtree, botões em pílula com borda de tinta (o mesmo vocabulário dos CTAs da
Início), campos numa caixa de borda de tinta e a paleta do design system. Quando o design desenhar
cada item abaixo, a implementação troca os primitivos de `lib/features/account/presentation/account_widgets.dart`
pela tela desenhada e o item sai desta lista.

Primitivos usados (todos em `account_widgets.dart`):

| Primitivo | Aparência |
|---|---|
| `AccountHeading` | Figtree 18/700, tinta, marcado como cabeçalho para o leitor de tela |
| `AccountText` | Figtree 15/400, tinta (ou `inkMuted` quando secundário) |
| `AccountButton` | pílula, borda tinta `AppStrokes.regular`; tons: principal = `sun`, secundário = `surface`, perigo = `blush`; desabilitado = 50% de opacidade; sem ripple (D-04) |
| `AccountField` | caixa `surface` com borda tinta e raio 16; texto Figtree 16/500; dica em `inkMuted` |
| `AccountNotice` | Figtree 14/600; erro em `flame`, confirmação em `emerald`; anunciado pelo leitor de tela |

## G05 — conta (D-64…D-69)

### Aba Perfil — bloco mínimo da conta (D-69)

Fica **abaixo** do título "Perfil" (que continua no centro, como o placeholder da D-07) e acima da barra
de navegação; rola se não couber.

| Estado | Conteúdo |
|---|---|
| Carregando | "Carregando a conta…" |
| Convidado, versão sem servidor | texto sobre os dados ficarem no aparelho · "Conta indisponível nesta versão." · botão "Exportar meus dados" |
| Convidado | texto sobre os dados ficarem no aparelho · "Entrar ou criar conta" (principal) · "Exportar meus dados" |
| Convidado com dados guardados de contas que saíram | "Há N itens guardados de contas que saíram deste aparelho…" · "Apagar dados de contas que saíram" → confirmação (perigo) · "Cancelar" |
| Com conta | "@handle" · "Exportar meus dados" · "Sair" · "Excluir conta" (perigo) |
| Com conta, cadastro incompleto | + "Concluir cadastro" (principal) |
| Com conta, servidor sem resposta | motivo (ex.: "Sem conexão…") · "Tentar de novo" |
| Confirmar saída | explicação · "Sair e manter neste aparelho" (principal) · "Sair e apagar deste aparelho" (perigo) · "Cancelar" |
| Confirmar exclusão | explicação (imediata, não dá para desfazer) · "Excluir e apagar também deste aparelho" (perigo) · "Excluir e manter meus dados neste aparelho" (perigo) · "Cancelar" |
| Avisos | "Arquivo com os seus dados pronto." · "Arquivo pronto só com o que está neste aparelho…" (a parte da conta não veio: sem internet, limite do dia) · "Conta excluída." · "Dados apagados deste aparelho." · erros das falhas tipadas |

### Entrar ou criar conta (`/entrar`, tela cheia)

| Etapa | Conteúdo |
|---|---|
| Idade — conferindo | "Conferindo a idade…" (sinal da loja) |
| Idade — data de nascimento | "Qual é a sua data de nascimento?" · explicação (13+; a data não sai do aparelho nem fica guardada) · campo DD/MM/AAAA · "Continuar" · aviso de data inválida |
| Idade — menor de 13 | "O BookNest é para 13 anos ou mais" · pode seguir sem conta; neste aparelho, outra data não destrava (só o sinal da loja) |
| Idade — Play Store pede verificação | "Confirme sua idade na Play Store" · instrução · "Conferir de novo" |
| Método | explicação do Grátis (dados no aparelho) · campo e-mail · "Receber código por e-mail" (principal) · "Entrar com Google" · "Entrar com Apple" |
| Código | campo "Código de 6 dígitos" · "Entrar" (principal) · "Reenviar código" · "Trocar e-mail" |
| Sempre | botão "Fechar" no topo · avisos (código enviado, erros) |

### Concluir cadastro (`/conta/cadastro`, tela cheia)

| Estado | Conteúdo |
|---|---|
| Falta a faixa etária | a mesma etapa de idade de "Entrar" |
| Menor de 13 com conta | a mensagem de 13+ · "Excluir a conta" (perigo) · "Sair da conta" |
| Falta o @ | explicação da regra (3–30: minúsculas, números, ponto, _) · campo "Seu @" · "Salvar @" (principal) · erros (@ em uso, fora da regra, termo proibido) |
| Sem conta / servidor sem resposta | texto · "Tentar de novo" |

### E-mail do código de acesso

`supabase/templates/codigo_de_acesso.html` — HTML simples com o código de 6 dígitos (usado no Supabase
local e como base do modelo da nuvem). O design do e-mail é um item do design.

## G06 — sincronização do Pro e e-books na nuvem

### Indicador discreto da sincronização (bloco da conta, abaixo do @)

Uma linha de `AccountText` secundário (`inkMuted`), anunciada pelo leitor de tela quando muda
(`lib/features/account/presentation/sync_indicator.dart`). No Grátis não aparece nada.

| Estado | Texto |
|---|---|
| Virando Pro (envio inicial) | "Enviando sua biblioteca para a nuvem… N%" |
| Conectando | "Conectando à nuvem…" |
| Enviando ou recebendo | "Sincronizando…" |
| Em dia | "Sincronizado" |
| Sem conexão | "Sem conexão com a nuvem." · com fila: "Sem conexão: N alterações esperando para ir à nuvem." |
| Relógio do aparelho ≥ 5 min adiantado | "O relógio do aparelho está N min adiantado. Acerte a hora nos ajustes do sistema." |
| O Pro acabou | "O Pro terminou: a sincronização parou e seus dados continuam neste aparelho." |

### Confirmar saída com alterações não enviadas (Pro)

Acima dos botões de "Confirmar saída": "Há N alterações ainda não enviadas à nuvem: se apagar deste
aparelho, elas se perdem."

### E-books na nuvem

O serviço existe (`lib/core/sync/ebook_cloud.dart`: enviar retomável e baixar sob demanda), mas o
**botão** ("Guardar na nuvem" / "Baixar") fica para a tela do livro — ainda sem design (G09 em diante).

## G07 — scanner e catálogo (D-73…D-77)

### Scanner (`/scanner`, tela cheia, por cima das abas — D-08)

Provisório até o design das telas 01–18 (D-76, aprovado em 04/10). De cima para baixo: "Fechar" · título
"Escanear livro" · **câmera num cartão** (fundo tinta, borda tinta `AppStrokes.regular`, raio `AppRadii.card`,
sombra dura `AppShadows.hard4`, proporção 4:3, moldura de mira `paper` de 2 px e raio 14 no centro) · texto de
ajuda · **pílulas** "Digitar ISBN" e "Lanterna" (`surface` com borda tinta; ligada = `sun`; a "Lanterna" some
se o aparelho não tem) · **cartão de resultado** (`surface`, borda tinta, raio `AppRadii.cardM`, sombra
`AppShadows.hard3`; anunciado pelo leitor de tela).

| Estado | Conteúdo |
|---|---|
| Mirando | ajuda "Aponte para o código de barras da contracapa." |
| Código que não é de livro | aviso "Esse código não é de um livro." (a câmera continua) |
| Digitar ISBN | campo "ISBN (10 ou 13 dígitos)" · "Buscar" (principal) · erro "Esse número não é um ISBN válido. Confira os dígitos." |
| Procurando | cartão: "Procurando o ISBN 978…" |
| Achou | cartão: título · "Autor · Editora · ano" · "Adicionar à estante" (principal) |
| Já está na estante (D-77) | cartão: "Este livro já está na sua estante." · título · autor · "Escanear outro" — nada vai para a rede |
| Não achou | cartão: "Não achamos o ISBN 978…" · sugestões pendentes da comunidade (caixa `paper` com borda, raio 16: "Sugestão da comunidade · N confirmações" ou "Sua sugestão (esperando confirmações)", título, autor · editora, "Confirmar e adicionar" — só com conta e em sugestão de outra pessoa) · "Adicione este livro: digite os dados ou leia a capa." · "Ler a capa" · campos "Título", "Autor (separe vários com ;)", "Editora (opcional)" · "Adicionar à estante" (principal) · com conta: "Adicionar e enviar ao catálogo" + "O envio leva o ISBN, o título, o autor e a editora para o catálogo da comunidade. Seu nome não aparece para ninguém." · "Escanear outro" |
| Ler a capa | "Confira o que foi lido da capa antes de adicionar." · "Não deu para ler a capa. Digite o título e o autor." |
| Adicionado | "Adicionado à sua estante." · título · autor · resultado do envio ("Enviado ao catálogo da comunidade. Ele entra no catálogo depois de 2 confirmações de outras pessoas." / "Sua confirmação foi registrada. Obrigado por ajudar o catálogo." / "Com a sua confirmação, o livro entrou no catálogo da comunidade." / "Este livro já estava no catálogo.") ou "O livro está na estante, mas o envio ao catálogo não foi: <motivo>" · "Escanear outro" (principal) |
| Sem rede / limite do dia | "Sem conexão. Tente de novo quando a internet voltar." ou "Limite de consultas de hoje atingido. Tente amanhã ou digite os dados do livro." · "Tentar de novo" (principal) · "Digitar os dados" |
| Contribuir sem faixa etária | "Confirme sua idade no Perfil para contribuir com o catálogo." |
| Sem permissão da câmera | no cartão: "Câmera sem permissão"; ajuda: "Sem acesso à câmera. Permita a câmera nos ajustes do aparelho ou digite o ISBN." |
| Câmera indisponível | no cartão: "Câmera indisponível"; ajuda: "A câmera não abriu. Digite o ISBN do livro." |

Livro sem autor conhecido entra na estante como "Autoria desconhecida" (o servidor exige o campo).

## G08 — Início com dados reais (D-78…D-85)

Os estados abaixo usam o vocabulário da própria Início (não os primitivos da conta): a caixa do cartão
"Continuar lendo" (`brand`, borda tinta 1,5, raio `AppRadii.card`, sombra `AppShadows.hard4`, os dois brilhos) e a
**pílula tinta** de 54 do "Continuar lendo" (`InkPillButton`: ícone 20 no tom `paper` + Figtree 16/700 `surface`).
O caminho "com dados" do arquivo não muda.

| Estado | Conteúdo |
|---|---|
| Estante vazia (D-78) | título "Comece *sua história.*" · cartão: "Sua estante está vazia" (Bricolage do título do livro) · "Escaneie o código de barras de um livro para começar." (Figtree 14 `inkPlum`) · pílula "Escanear livro" (ícone do scanner) → `/scanner` · "Seu dia de leitura" zerado · Também lendo, Para você, Clube e Recém-chegados não aparecem (cada uma some junto com o gap de antes dela) |
| Livros na estante, nenhum em leitura (D-85) | "Comece *sua história.*" · cartão: "Nada em leitura agora" · "Escolha um livro da sua estante para começar." · pílula "Ver biblioteca" (ícone da Biblioteca) → aba Biblioteca · Recém-chegados com os livros |
| Convidado (D-84) | cabeçalho: "Boa noite" (sem vírgula, sem a linha do nome) · círculo `sun` com o ícone de pessoa no lugar da inicial · sininho sem o ponto |
| Meta do dia batida (D-83) | "Meta de hoje cumprida." no lugar de "Faltam N min para fechar a meta de hoje." |
| Selo alcançado (D-83) | "Selo de **N dias** conquistado" no lugar de "Mais N dias para o selo de N dias" |
| Exemplar físico (D-85) | Recém-chegados: "Autor · Físico" |
| Livro real sem foto (D-79) | capa gerada na moldura da seção: cor de fundo, forma (sol, arco, anel ou linhas) e título em Instrument Serif + autor em maiúsculas, derivados do livro (sempre a mesma para o mesmo livro); miniatura só com cor e forma; trocada pela foto quando ela chega |
| Livro real com título longo | herói: título em até 3 linhas e autor em 1; Para você: título em até 2 linhas e autor em 1; Recém-chegados: título e subtítulo em até 2 linhas — com "…" |
| Também lendo com 1 livro | o cartão fica na metade da largura, como os dois do arquivo; o contador mostra o total de livros em leitura (até 2 cartões) |
| Livro sem capítulos / sem estimativa | sem a pílula "Cap. N de M"; sem o "~Xh YYmin" |
| Carregando (D-85) | cabeçalho (conta + relógio) · depois de 400 ms, "Carregando sua estante…" (Figtree 14 `inkPlum`, centralizado) |
| Erro (D-85) | cabeçalho · "Não deu para abrir sua estante." (Figtree 15/700) · pílula "Tentar de novo" |

## G09 — importação (D-86…D-93)

### Aba Biblioteca — bloco mínimo de importar (D-87)

Fica **abaixo** do título "Biblioteca" (que continua no centro, como o placeholder da D-07), como o bloco da
conta no Perfil (D-69), com os mesmos primitivos. Sem lista de livros: ela espera o design das telas 01–18.

| Estado | Conteúdo |
|---|---|
| Parado | "Traga seus livros em EPUB ou PDF." · "Importar livro (EPUB ou PDF)" (principal) → seletor do sistema (só .epub e .pdf) |
| Importando | o mesmo, com o botão desabilitado · "Importando «nome do arquivo»…" (`inkMuted`) |
| Pronto | aviso verde "«Título» está na sua estante." (o livro aparece na Início em Recém-chegados, com "Novo" — D-88) |
| Pronto, páginas fixas (D-92) | aviso vermelho "Este livro tem páginas fixas; a leitura dele ainda não está pronta no BookNest." |
| Já na estante | aviso verde "Esse livro já está na sua estante." |
| Não é EPUB nem PDF | aviso vermelho "Esse arquivo não é um EPUB nem um PDF." |
| Danificado | "Não deu para abrir esse arquivo. Ele pode estar danificado." |
| Protegido (DRM ou senha — Anexo 03 §2) | "Este arquivo tem proteção e não pode ser aberto." |
| Sem espaço | "Não há espaço no aparelho para guardar este livro." |
| Falha inesperada | "Não deu para importar agora. Tente de novo." (o erro vai para o relatório de falhas, sem dado da pessoa) |

### "Abrir com" / "Compartilhar" (D-87)

O arquivo chega por qualquer app do sistema (gerenciador de arquivos, e-mail, navegador). Com o BookNest aberto
em qualquer aba, o app vai para a Biblioteca e o bloco acima mostra "Importando…" e depois o resultado. Com o app
fechado, ele abre e faz o mesmo. Vários arquivos de uma vez entram um depois do outro.

### Capa do livro importado (D-90)

A capa que vem no arquivo (a do EPUB; a 1ª página do PDF) aparece na moldura da seção, sem rede. Sem ela, a foto
da fonte pelo ISBN (D-79) e, sem nenhuma, a capa gerada da G08.

## G21 — clubes ligados aos pontos já desenhados (docs/progresso/G21.md §5)

As telas do clube (04, 31, 32, 33, 34, 70–73) vêm pela Trilha T, com o HTML. Até lá, o que a G21 mostra sem prancha
fica na tela 25 e segue as folhas da própria 25 (D-23; o padrão da folha da nota — D-131): o véu, o cartão a 14 das
bordas, raio 28, borda 1,5 e sombra dura; o título em caixa alta (Figtree 11/800, como "pág. 6 · GRIFO + NOTA");
os botões em pílula de 48 (`sheetButton`). As pílulas de aviso são o aviso do leitor (`leitor.aviso`, 2 s).

### "Mais opções" da 25 — o Compartilhar no clube

| Estado | Conteúdo |
|---|---|
| Cartão com texto (um grifo com trecho) | "Compartilhar no clube" |
| Cartão sem texto (desenho, nota à mão, marca-texto feito à mão) | a opção não aparece |
| Já compartilhado | "Já está em Leitoras de Capitu", apagado (não publica de novo); sem o nome do clube no aparelho, "Já está no clube" |

### As pílulas do compartilhar

| Caso | Texto |
|---|---|
| Sem conta | "Entre na sua conta para compartilhar." |
| Sem rede | "Sem conexão. Tente de novo." |
| Nenhum clube lê o livro | "Nenhum clube seu está lendo este livro." |
| Publicado | "Compartilhado em Leitoras de Capitu." |
| Outra falha | "Não deu para compartilhar. Tente de novo." |

### Folha "Antes de publicar" (D-222)

Aparece no primeiro compartilhar (e se a versão das regras mudar). Título "ANTES DE PUBLICAR"; "As regras da
comunidade, por enquanto:" (Figtree 14/800) e as regras provisórias até a G25 (Figtree 14/600, `inkMuted`):
- "Respeito: nada de ataque, ódio ou assédio."
- "Spoiler com cuidado: o app esconde o que está à frente de quem lê."
- "Nada de conteúdo sexual, spam ou propaganda."
- "Denúncias são vistas em até 24 horas; o que quebra as regras sai do ar."

Botões: "Aceitar e continuar" (cheio na cor da marca, sombra 2/2) e "Agora não". O véu é o "Agora não".

### Folha "Compartilhar em…"

Quando mais de um clube lê o livro. Título "COMPARTILHAR EM…"; um botão por clube (do encontro mais próximo): a
bolinha de 14 na cor do clube, com a borda de tinta, e o nome; depois "Fechar".

### Sininho da Início (D-212)

O ponto que o arquivo já desenha aparece com notificações não lidas; o toque continua como hoje (a tela das
notificações vem pela Trilha T).

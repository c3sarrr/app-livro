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

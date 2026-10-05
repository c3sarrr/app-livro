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

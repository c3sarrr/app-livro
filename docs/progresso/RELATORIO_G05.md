# Relatório da FASE G05 — Conta, login e direitos do titular

Data: 04/10/2026 · branch `feat/g05-conta` (a partir de `feat/g04-supabase`) · nada enviado ao GitHub nem à
nuvem (D-63). Evidências de cada subfase: `docs/progresso/G05.md`.
Decisões usadas (respondidas por você em 04/10): Q3 = sim · Q4 = A · idade = sinal da loja + nascimento ·
login = código agora, chaves depois · cada conta tem a sua biblioteca · bloco mínimo no Perfil (D-64…D-69).
Uma decisão nova saiu da revisão e precisa da sua confirmação: **D-70** (abaixo).

## Antes da fase

Os documentos do handoff ainda descreviam o desenho de sincronização reprovado no S2 (prompt mestre §4.3.8 e
itens da G06; Anexo 02 §1.7, §3.1, §6.2, §6.3). Alinhei tudo ao ADR-002/003.

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G05.1 Login | e-mail com código de 6 dígitos (sem link), Google e Apple (idToken; Apple pelo navegador no Android com deep link `booknest://login-callback`); sessão e PKCE no Keychain/Keystore | testes sobre o cliente **real** do Supabase + **ponta a ponta no Supabase local** (código lido no Mailpit) |
| G05.2 Convidado e dados por conta | o app funciona sem conta; ao entrar, o que foi feito como convidado passa para a conta **depois** que o servidor a confirma; sair guarda ou apaga; conta excluída fora do app devolve os dados ao convidado; o convidado pode apagar dados guardados de contas que saíram | `local_library_test`, `account_controller_test` |
| G05.3 Idade (ECA Digital) | sinal da loja primeiro, data de nascimento só como apoio (não sai do aparelho nem fica guardada); servidor guarda faixa + fonte; adolescente com perfil fechado | `14_conta_e_idade` (25) + testes do app |
| G05.4 Telas mínimas (D-21) | `/entrar`, `/conta/cadastro` (idade e @) e o bloco no Perfil abaixo do título | `account_screens_test` (11), `router_test`; estados listados em `docs/design/estados_sem_design.md` |
| G05.5 Excluir e exportar | excluir no app (apagar ou manter no aparelho) e **página web** de pedido de exclusão (`site/excluir-conta/`); exportação servidor + aparelho num JSON | Deno: `delete-account` (8), página (8) |
| G05.6 Privacidade do Grátis | teste que grava cada pedido HTTP da pilha real e reprova endpoint fora de login/perfil ou qualquer dado pessoal (título, trecho, nota, id/sha do livro, data de nascimento); roda também na rede de verdade | controle de mutação: Grátis sincronizando e exportação subindo o aparelho — **os dois reprovam** |

Números finais: `flutter analyze` sem problemas · `flutter test` **870 verdes** (1 ignorado: o de integração,
verde com `--tags integracao`) · `supabase test db` **15 arquivos, 412 testes** · `db lint` limpo · Edge
Functions **55 unitários + 8 de integração** · página web **8** · controles de mutação do app **8/8** e do SQL
da idade **4/4**.

## Revisão independente

Um agente separado leu tudo sem editar. Foram 10 achados. Corrigi 9, cada um com teste (e controle de
mutação nos principais); 1 ficou registrado para a G06/G16.

| # | Achado | O que fiz |
|---|---|---|
| 1 (alta) | A fonte da faixa vem do app: um adolescente virava adulto chamando a RPC com "play_signal"; conta sem faixa ficava aberta; outra data destravava o "menor de 13" | Pela RPC a faixa só fica mais protegida (**D-70**); conta nova nasce com perfil fechado; "menor de 13" registrado no aparelho e a checagem aprovada antes é anulada; no cadastro, menor de 13 com conta só pode excluir ou sair |
| 2 (alta) | Os dados do convidado passavam para a conta antes de o servidor confirmá-la — com conta já excluída, ficavam presos | Só passam com a conta confirmada; conta excluída devolve ao convidado; o convidado apaga dados guardados de contas que saíram; falha inesperada mostra "Tentar de novo" (não fica carregando) |
| 3 | A página web revelava se um e-mail tem conta (formato antigo de erro do Auth) | Cabeçalho de versão da API + qualquer recusa 4xx responde igual ao sucesso |
| 4 | A tela de login travava se o servidor não respondesse depois do código | Fecha e o Perfil mostra o motivo com "Tentar de novo" |
| 5 | `delete-account`: erro sem resposta (sem CORS) e token de sessão encerrada aceito | Resposta 500 sempre (com CORS); sessão conferida no Auth (`getUser`) |
| 6 | Exportar falhava inteiro sem internet | O aparelho é exportado e o arquivo diz o que ficou de fora |
| 7 | Mapeamento de erros: 23505 virava "@ em uso" em qualquer pedido; 42501 deslogava | Só na troca do @; 42501 é erro do servidor; a RPC da idade usa `on conflict` |
| 8 | Fila de upload e operações sociais pendentes não são limpas ao trocar de dono | **Registrado para a G06/G16** (ainda não existem no app) |
| 9 | Backup do Android levaria o banco do Grátis para a nuvem | `allowBackup=false` + `dataExtractionRules` (nuvem e troca de aparelho). iOS (iCloud) precisa de Mac — pendente |
| 10 | Código do e-mail valendo 1 hora | 10 minutos e 60 s entre e-mails para o mesmo endereço |

## Decisão para você confirmar

**D-70 — a faixa etária só fica mais protegida pelo app.** O app não tem como provar a idade (o sinal da
loja chega por ele), então pela RPC a faixa só se mantém ou fica mais nova. Consequência: quem completa
16 ou 18 continua na faixa antiga até existir uma reverificação (proponho definir na G25, com o advogado). Hoje
isso só afeta o padrão "perfil fechado" — a pessoa pode abrir o perfil ela mesma.

## O que fica pendente (registrado)

- **Q9 — hospedagem/domínio:** publicar `site/excluir-conta/` (exigência do Google Play) e liberar a origem.
- **Nuvem (D-63):** clientes OAuth do Google (Web/iOS), conta Apple Developer, modelo do e-mail e `otp_expiry`.
- **iOS (precisa de Mac):** entitlement da Apple para a faixa etária e excluir o banco do backup do iCloud.
- **G06:** limpar a fila de upload ao trocar de dono; dois livros com o mesmo arquivo depois de juntar.
- **G16:** escritas sociais exigirem faixa registrada; operações sociais pendentes por dono.

## Commits

Ver `git log feat/g04-supabase..feat/g05-conta` (um por subfase, mensagens em português).

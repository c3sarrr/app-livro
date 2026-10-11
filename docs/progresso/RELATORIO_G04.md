# Relatório da FASE G04 — Supabase: migrations, RLS, testes, Edge Functions

Data: 04/10/2026 · branch `feat/g04-supabase` (a partir de `feat/g03-dominio`) · nada enviado ao GitHub nem
à nuvem (D-63). Evidências de cada subfase: `docs/progresso/G04.md`.
Decisões usadas (respondidas por você em 04/10): Q20 = sim · Q25 = A · Q26 = A · Docker no Ubuntu do WSL ·
Ubuntu movido para o D: e sobras do Docker Desktop apagadas · Q6 = só local agora (D-60…D-63).

## Resultado

| Subfase | Entrega | Prova |
|---|---|---|
| G04.0 Ambiente | Docker Engine 29.8 no Ubuntu do WSL (disco em `D:\WSL\Ubuntu`), Supabase CLI 2.119.0, Postgres **17.11** local; avisos do drift resolvidos | C: de 10,7 → 15,7 GB livres; `supabase start` e `db reset` limpos |
| G04.1 Migrations | `supabase/config.toml` (API só `public`, sem exposição automática) + **15 migrations** (8 do SQL de referência por assunto + 7 da G04); toda migration termina com REVOKE dos padrões + GRANT por coluna | `verificar_migrations.py` 15/15; `supabase db lint --level warning --fail-on warning` **limpo**; contrato de colunas da G03 agora lido da migration |
| G04.2 pgTAP | 23 testes de fumaça + **1 permitido e 1 negado para cada uma das 59 políticas** + matriz de privilégios (tabela, coluna, função) | **14 arquivos, 387 testes, todos verdes** no Postgres 17.11 (`supabase test db`) e no 16 do contêiner; controle de mutação nos testes de privilégio (6/6) e da revisão (25/25) |
| G04.3 Rotinas e pendências do SQL | 9 rotinas do pg_cron com nomes e horários (Edge Functions por `pg_net`, URL e chave no Vault); encontros com fuso; notificações por gatilho; moderação; exportação | `08`, `11`; agendador ponta a ponta testado (pg_cron → pg_net → gateway → função) |
| G04.4 Edge Functions | 8 funções Deno/TS (`revenuecat-webhook`, `isbn-lookup`, `ebook-upload-url`, `export-data`, `delete-account`, `email-sender`, `purge-storage`, `push-sender`) | **51 testes unitários + 8 de integração** com o Supabase local; `deno fmt/lint/check` limpos |
| G04.5 Ambientes e CI | `env/{dev,stg,prod}.example.json` (só chaves públicas); `.github/workflows/banco.yml` (forma das migrations, lint, pgTAP, Deno, gitleaks) e `cold-backup.yml` (desligado até a produção) | gitleaks 8.30.1 local: histórico (44 commits) e os 115 arquivos novos/alterados **sem vazamento**; 1 falso positivo (chave RSA gerada na hora no teste do push) ajustado no código e registrado em `.gitleaksignore`. O CI não rodou no GitHub (nada foi enviado) |
| G04.6 Desempenho | carga de **100 mil usuários** (500 mil seguidas, 10 mil clubes, 606 mil posts e respostas de clube, 1 milhão de notificações, 200 mil edições) e `EXPLAIN (ANALYZE, BUFFERS)` como o app consulta (papel `authenticated` + RLS no plano) | tabela abaixo |
| G04.7 Revisão e relatório | revisão independente (agente separado, só leitura) → migration `revisao_g04` | tabela da revisão abaixo |

Commits: `afad8c1` G04.0 · `2ddf380` G04.1 · `83d467a` G04.2 · `5fad28b` G04.3 · `1f0f556` G04.4 · G04.5 · G04.6 ·
G04.7 (revisão) · G04.7 (este relatório).

### Consultas quentes (Postgres 17.11 local, 100 mil usuários; 3 rodadas)

| Consulta (Anexo 02 §10) | Meta | Medido |
|---|---|---|
| Feed do clube, 1ª página (keyset, 20) | < 30 ms | 1,1–1,2 ms (página seguinte 0,5–0,6) |
| Respostas de um post | < 20 ms | 0,28–0,32 ms |
| Notificações não lidas (sino) | < 10 ms | 0,14–0,20 ms (lista: 0,07–0,08) |
| Prévia de perfil (RPC) | < 20 ms | 2,6–3,0 ms |
| Busca no catálogo (trigramas, sem acento) | < 80 ms | 9,0–9,7 ms (plano de dentro da função: 4,6–6,4) |
| RPC de sync, lote de 500 operações | p95 < 400 ms | **p50 47–48 ms, p95 63–154 ms** (antes da migration `sincronizacao_em_lote`: p50 238, p95 459, máx. 1.345) |

A RPC em lote resolve o item 7 do ADR-003 (o spike S2 tinha medido p95 de 424–559 ms).

## Defeitos achados pelos testes da G04 (corrigidos)

- Apagar o próprio post/resposta falhava: o Postgres confere a política de leitura na linha **nova** do UPDATE.
- Faltava política para o autor apagar a própria resposta no clube.
- Contadores de comentários, posts e respostas não descontavam o que foi apagado.
- E-mail com mais de 60 caracteres antes do @ derrubava o cadastro.
- Faltavam índices em chaves estrangeiras.
- A RPC de sync passava da meta de 400 ms em lotes de 500.

## Revisão independente

Um agente separado leu tudo (migrations, testes, funções, anexos) sem editar nada. Foram 15 achados mais um detalhe do lote. Cada correção tem um teste que reproduz o problema, e o teste falha com o código antigo (controle de mutação). Os testes estão em `13_revisao_g04.test.sql`.

| # | Achado | O que fiz |
|---|---|---|
| 1 (alta) | O autor desfazia o "ocultar" da moderação (`deleted_at` é dele). Ocultar perfil não limpava nome nem @, e falhava se o nome tivesse um termo proibido | Criei `moderated_at`, que só o servidor grava, e um gatilho que impede o autor de editar ou restaurar. Ocultar perfil agora zera nome ("Leitor"), @, bio e foto. O filtro de termos também olha o @ |
| 2 (alta) | Transferência no RevenueCat (`TRANSFER`, sem `app_user_id`) era ignorada: o dono anterior continuava Pro e o novo não ganhava. A chave "produto@data" podia colidir entre duas pessoas | Aplico as contas de `transferred_from` e `transferred_to`. O dono anterior é recalculado na hora. Assinatura que sumiu do estado sai do banco. A chave sem id da loja passou a ser por usuário |
| 3 | Quem é seguido alternava pendente e aceito: contador forjado e push em laço | O dono só aceita (de pendente para aceito). Curtida, seguir e pedido repetidos geram no máximo 1 notificação por dia |
| 4 | Termo proibido no e-mail impedia o cadastro | O nome provisório vira "Leitor" |
| 5 | A cota de 2 GiB usava o tamanho que o cliente informa | Criei reservas de upload: cada URL ativa conta 200 MiB, e perto do limite vale um único último upload pelo tamanho informado. **Fica para a G06:** o dono ainda pode gerar um link de download de validade longa (o plano está no ADR-003) |
| 6 | O purge apagava sem o aviso de 30 dias ter sido **entregue** | O prazo conta do aviso entregue: e-mail enviado ou, sem e-mail, a notificação no app. Se o e-mail falhar 5 vezes, vale a notificação. O aviso de quem voltou a ser Pro sai da fila |
| 7 | Teste de retenção era falso positivo | Corrigido. Agora ele pega a regra removida |
| 8 | A limpeza do Storage apagava os e-books de quem voltou a ser Pro | A limpeza pula essas pessoas |
| 9 | Partições das sessões sem RLS nem privilégios | As partições ganharam RLS e GRANT explícitos, inclusive as novas. O teste de privilégios agora confere as partições |
| 10 | Um estado do RevenueCat buscado antes podia sobrescrever o mais novo | Registro a hora da busca, e o estado mais velho é ignorado (`billing.rc_fetch_state`) |
| 11 | O agrupamento de push engolia o lembrete de encontro | Só as respostas do clube se agrupam |
| 12 | O token de push ficava preso à conta anterior do aparelho | Registro só pela RPC `register_device_token`. O token passa para a conta que entrou |
| 13 | O código de convite era escolhido pelo cliente, e quem estava bloqueado entrava no clube | O código é gerado pelo servidor (12 caracteres aleatórios). Quem foi bloqueado pelo dono não entra |
| 14 | Terceiros viam pedidos pendentes | Terceiros veem só os aceitos |
| 15 | O webhook guardava e-mail e atributos do assinante para sempre | Guarda só o mínimo, e os eventos são apagados junto com a conta |
| lote | Empate de HLC no mesmo id escolhia uma versão ao acaso | Vence a primeira da lista (igual ao caminho de uma em uma) |

## Incidente (sem dano ao projeto)

Um script auxiliar meu (`wsl.ps1`) sobrescreveu o próprio arquivo que executava, e isso virou um laço que criava processos sem parar no Ubuntu do WSL. Parei tudo com `wsl --shutdown` e apaguei os arquivos temporários. Nenhum arquivo do projeto foi afetado. O script agora grava em `<nome>.wsl.sh` separado.

## Preciso da sua decisão

| # | O quê | Por quê agora |
|---|---|---|
| **Q3** | Modo convidado: dá para usar o app **sem conta** (tudo no aparelho)? | É o 2º item da G05 (Conta e login). Recomendação do D-25: **sim** |
| Q9 | Domínio e e-mail remetente | Sem o provedor de e-mail configurado, o purge de retenção fica parado (de forma segura: nada é apagado sem aviso entregue). Só é necessário antes da 1ª retenção real, 12 meses depois do 1º Pro vencido |
| Q21–Q24, Q7, Q8 | Continuam abertas (relatório G02) | Bloqueiam G06, G07, G09–G11, G24 |

## O que a G04 não resolve

- **Projetos na nuvem** (`booknest-dev/stg/prod`, São Paulo): pendentes por decisão (D-63). O CI nunca rodou no GitHub.
- **G06:**
  - Os 8 cenários do spike S2 com o serviço PowerSync de verdade e o conector Dart.
  - Download de e-book por URL curta, depois retirar a política SELECT do bucket.
  - Papel próprio do PowerSync nas partições.
  - O item da G06 no prompt mestre ainda fala em `publish_via_partition_root`, que o ADR-003 descartou (o serviço recusa).
- **G05:** login (Apple, Google, e-mail), exclusão de conta pelo app e o teste que falha se o Grátis enviar dado pessoal pela rede.
- **Segredos de produção** (RevenueCat, Resend, FCM, ISBNdb, Hardcover): só entram nos projetos na nuvem. No local, `supabase/functions/.env` fica fora do git.

## Ferramentas e skills

No início conferi os plugins e skills disponíveis e usei estes:

- **Supabase**, o plugin que você instalou pelo cartão. Usei a skill de boas práticas e o changelog: segurança da RLS, `security definer` fora do `public`, `migration new` pela CLI e lint.
- **TDD**: teste antes do código. Na revisão, o arquivo de testes novo falhou antes da migration existir. Depois, desfiz cada correção, uma de cada vez (25 controles de mutação), e os testes falharam em todas.

Também usei: Supabase CLI 2.119.0, Postgres 17.11 (WSL) e 16 (contêiner), pgTAP 1.3.3, Deno 2.9, gitleaks 8.30.1 e Docker Engine 29.8.

Qualidade do app Flutter (o contrato de colunas agora lê a migration): `dart format` **0** mudanças (248 arquivos) · `flutter analyze` **sem problemas** · **`flutter test` = 782 verdes**.

## Próxima fase

**G05: Conta, login e direitos do titular.** A Q3 (modo convidado) precisa de resposta antes do 2º item.

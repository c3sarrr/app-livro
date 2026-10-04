# ADR-001 — Backend: Supabase (plano Pro) em São Paulo (`sa-east-1`)

- **Status:** aceita (G02) · aguarda a aprovação da G02
- **Data:** 03/10/2026
- **Prova:** SQL de referência `handoff_v2/sql/01_schema_booknest.sql` — **23/23** testes de fumaça (`02_testes_rls.sql`), refeitos hoje num Postgres 16 limpo; o mesmo SQL, **sem nenhuma mudança**, sustentou a replicação do PowerSync e a RPC de sync no S2 e o webhook no S5.

## Contexto

O app precisa de Auth (Apple, Google, e-mail OTP), Postgres com RLS para social/clubes/billing/dados Pro,
Storage (avatares, e-books do Pro), funções de servidor (webhook, exclusão de conta, e-mail, push) e rotinas
agendadas — com dados no Brasil (LGPD) e custo fixo baixo.

## Decisão

1. **Supabase Pro** em **`sa-east-1`**, Postgres **17** (o hospedado; `uuidv7()` nativo só no 18 → a função do SQL),
   3 projetos (`booknest-dev`, `-stg`, `-prod`); dev local com `supabase start` (Docker).
2. Só o esquema `public` exposto no PostgREST; `personal`, `billing`, `private` fechados; regras de permissão em
   funções `security definer` com `search_path = ''`; REVOKE dos privilégios padrão + GRANT por coluna (Anexo 02 §5.4).
3. **Edge Functions** (Deno) para tudo que usa segredo: `revenuecat-webhook` (S5), `delete-account`, `isbn-lookup`,
   `ebook-upload-url`, `export-data`, `email-sender`, `purge-storage`, `push-sender`; acesso a `billing`/`private`
   pela `SUPABASE_DB_URL`.
4. **pg_cron** para partições, `refresh_sync_access`, retenção e limpezas (Anexo 02 §8).

## Evidências

| Prova | Resultado |
|---|---|
| `02_testes_rls.sql` (Postgres 16 + stub com os privilégios padrão do Supabase) | **23/23 OK** — inclui JWT forjado, chave `anon`, escalada de papel, contador forjado, partições, retenção, folga de 7 dias do bucket |
| S2 (sincronização) | publicação lógica + serviço PowerSync replicando `personal.*` e `billing.sync_access`; RPC `sync_apply_changes` com 10 mil linhas, recusas e erros transitórios |
| S5 (pagamentos) | Edge Function contra `billing.*` com reconciliação, idempotência e `refresh_sync_access` |
| Preço (03/10/2026) | Pro **US$ 25/mês** por organização: 8 GB de disco/projeto (US$ 0,125/GB a mais), 250 GB de saída, **100 mil MAU**, 2 mi de invocações de Edge Function, 100 GB de Storage, US$ 10/mês de créditos de computação (1 instância Micro). O Free pausa projetos após 1 semana sem uso → dev/stg em Free só com cuidado |

## Consequências

- Postgres 17 no Supabase × 16 nos testes locais: a G04 repete os 23 testes (como pgTAP) com `supabase start`.
- RPC de sync: p95 de 424–559 ms por lote de 500 no Postgres local (ADR-003) → otimização na G04.
- O `refresh_sync_access()` global chamado pelo webhook vira uma versão por usuário na G04 (ADR-007).

## Alternativas consideradas

- **Firebase/Firestore:** sem SQL/RLS relacional, regras de segurança menos expressivas para clubes e billing,
  sync próprio do Firestore não serve ao modelo Grátis-só-local; região `southamerica-east1` existe.
- **Postgres próprio (VM) + PostgREST/Auth próprios:** mais barato em escala, mas operação (backup, Auth,
  Storage, atualizações) cai sobre o projeto. Fica como saída se o custo do Supabase pesar (o SQL é portável).
- **Neon/AWS RDS + Auth0/Cognito:** mais peças e contratos para o mesmo resultado.

## Pendências

- **Q6:** criar os projetos `booknest-dev/stg/prod` (e conferir se a pasta "chave senha superbase postgrer" do
  Desktop é um projeto existente) — chaves só em `.env` local, nunca no chat.

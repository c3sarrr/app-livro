# Anexo 02 — Arquitetura de dados (aparelho, nuvem, sincronização, catálogo)

> Parte do pacote `handoff_v2/` · versão 2.0 · 03/10/2026
> SQL de referência: `sql/01_schema_booknest.sql` (validado num Postgres 16 local: `sql/00_stub_supabase_local.sql` — que reproduz os privilégios padrão do Supabase — + `sql/02_testes_rls.sql` → **23/23 testes OK** em 03/10/2026, incluindo ataques com JWT forjado e a chave pública `anon`).
> Base de produto: doc do projeto `monetizacao/plano_gratis_vs_pro.md` (v3) — Grátis guarda dados pessoais só no celular; Pro sincroniza na nuvem e guarda 12 meses depois de cancelar; scanner sem limite; catálogo fora do Supabase.

---

## 1. Princípios (valem para toda decisão de dados)

1. **Local primeiro.** Toda conta (Grátis ou Pro) lê e escreve num SQLite no aparelho. O app funciona offline por completo para leitura, grifos, tinta, metas e estatísticas.
2. **O Grátis nunca envia dados pessoais.** Estante, posição, sessões, grifos, notas, tinta, marcadores e preferências do Grátis não saem do aparelho. O que vai ao servidor para o Grátis é só **social** (perfil, números públicos agregados, posts, clubes) — e só quando a pessoa publica.
3. **O Pro sincroniza o mesmo esquema.** As tabelas pessoais do aparelho e do schema `personal` têm as mesmas colunas. Virar Pro = começar a sincronizar; deixar de ser Pro = parar (dados da nuvem guardados 12 meses).
4. **O servidor manda no que é compartilhado e no dinheiro.** Social, clubes, direitos de assinatura e limites são decididos no Postgres (RLS + funções), nunca só no app.
5. **O catálogo de livros não mora no banco transacional.** ISBN e busca ampla ficam em arquivos estáticos (R2 + Workers) e no aparelho; o Postgres guarda só os livros **referenciados** por dados sociais/Pro.
6. **IDs gerados no aparelho** (UUIDv7, ordenáveis por tempo) — permitem criar offline e sincronizar sem colisão.
7. **Tudo que é apagado vira tombstone** (`deleted_at` + novo `version_hlc`) — inclusive no Grátis (que escreve nas mesmas tabelas, sem fila): senão, quem volta a assinar dentro dos 12 meses "ressuscitaria" na nuvem o que apagou enquanto estava no Grátis. A remoção física acontece por rotina (retenção) ou por exclusão de conta.
8. **Privacidade por padrão** (LGPD): coleta mínima, finalidade clara, exclusão imediata a pedido, exportação dos próprios dados.

## 2. Onde mora cada dado

| Dado | Aparelho (todas as contas) | Supabase — todas as contas | Supabase — só Pro | R2/Workers | Storage |
|---|---|---|---|---|---|
| Arquivo do e-book (EPUB/PDF) | ✅ `files/books/<sha256>.<ext>` | — | — | — | ✅ opcional (bucket `ebooks`, cota 2 GB) |
| Estante (`user_books`) | ✅ | — | ✅ `personal.user_books` | — | — |
| Posição de leitura | ✅ | — | ✅ | — | — |
| Sessões de leitura (tempo) | ✅ | — | ✅ (particionada por mês) | — | — |
| Grifos, notas, nota à mão, desenhos | ✅ | — | ✅ | — | — |
| Camadas de tinta (traços) | ✅ | — | ✅ (`strokes_b64`) | — | — |
| Marcadores (páginas marcadas) | ✅ | — | ✅ | — | — |
| Ajustes de leitura, caneta, metas, rótulos | ✅ | — | ✅ | — | — |
| Perfil, @, foto, visibilidade | cache | ✅ `public.profiles` | — | — | ✅ `avatars` |
| Números públicos do perfil | calcula | ✅ `profile_stats` (agregados) | — | — | — |
| Seguidores, bloqueios | cache | ✅ | — | — | — |
| Resenhas/citações/listas publicadas | cache | ✅ `public.posts` | — | — | — |
| Clubes, membros, encontros, posts, respostas | cache | ✅ | — | — | — |
| Notificações, tokens de push | — | ✅ | — | — | — |
| Assinatura e direitos | cache do RevenueCat | ✅ `billing.*` (só servidor) | — | — | — |
| Catálogo (300 mil–1 mi ISBNs mais comuns) | ✅ SQLite separado (`catalog.db`) | — | — | ✅ origem | — |
| Catálogo completo (dumps abertos) | — | — | — | ✅ shards por prefixo | — |
| Livros referenciados (social/Pro) | cache | ✅ `catalog.editions` | — | — | — |

## 3. Banco local (aparelho)

### 3.1 Motor

- **SQLite** gerenciado pelo SDK do **PowerSync** (`powersync` no pub.dev), com **drift** por cima (via `drift_sqlite_async`) para consultas tipadas, DAOs e testes.
- **Risco crítico a eliminar (revisão independente):** o cliente do PowerSync **apaga do aparelho** as linhas de um bucket que deixou de valer (perdeu o Pro) e aplica as exclusões do servidor (purge de 12 meses). Isso pode destruir a única cópia dos dados. Além disso, escrever em tabelas sincronizadas sem nunca conectar faz a fila `ps_crud` crescer sem fim. Por isso:
  1. **Decidido no spike S2 (ADR-002/003, Q20 aceita em 04/10/2026):** as 10 tabelas pessoais são **tabelas próprias** do drift (as *raw tables* do PowerSync), as mesmas para Grátis e Pro. O `put` do PowerSync é um upsert com LWW (`version_hlc`) que guarda colunas desconhecidas em `_extras`; o **`delete` do PowerSync não apaga** (só registra) — o modelo usa só exclusão lógica, então perder o bucket nunca apaga dado do aparelho.
  2. **Fila só no Pro:** os gatilhos que alimentam a fila de upload (`ps_crud`) ficam ligados só no modo Pro; o Grátis nunca enfileira nada (fila 0, nenhuma conexão).
  3. **Virar Pro:** ligar os gatilhos, reenfileirar todas as linhas locais (inclusive os tombstones) como `PUT` com a linha inteira e conectar. **Voltar a ser Pro** (antes ou depois do purge) é o mesmo caminho; o LWW resolve o que já existia na nuvem.
  4. **Perder o Pro:** desligar os gatilhos e desconectar (`disconnectAndClear(clearLocal: false)`) na expiração prevista (RevenueCat), no `pro_required` do upload ou na checagem periódica. Nada é copiado e nada é apagado.
  5. **Rede de segurança no servidor:** `billing.sync_access` mantém o acesso por **7 dias** depois do fim do Pro (o upload já é bloqueado na hora por `can_sync`).
  6. **Regra do HLC:** toda escrita faz `receive` da versão lida antes do `send` (porta única `LocalVersioning.write`); um gatilho recusa versão local menor que a gravada. O padrão antigo ("views `localOnly` ↔ sincronizadas") foi **reprovado** no S2: em modo avião ele apagou 10.000 → 0 linhas.
- Plano B (se o PowerSync falhar na G06): drift puro + sincronização própria, com o mesmo esquema e a mesma RPC (ADR-003).

### 3.2 Tabelas pessoais (espelho de `personal.*`)

`user_books`, `reading_positions`, `reading_sessions`, `bookmarks`, `ink_layers`, `annotations`, `highlight_labels`, `reader_settings`, `pen_presets`, `reading_goals` — **mesmas colunas e mesmos CHECKs** do SQL (§4 do arquivo SQL). Tipos no SQLite: `uuid`/`timestamptz`/`jsonb` viram `TEXT` (ISO-8601 UTC, JSON texto); `numeric` vira `REAL`/`TEXT` conforme o caso (progressão como `TEXT` decimal para não perder precisão no round-trip). Um teste de contrato compara as colunas do `Schema` local com `information_schema.columns` do Postgres (falha se divergirem).

### 3.3 Tabelas só locais

| Tabela | Para quê |
|---|---|
| `local_files` | caminho do arquivo do livro, tamanho, sha256, estado do upload (Pro) |
| `book_content_index` | por livro: hash do conteúdo, itens do *spine*, contagem de caracteres por item, sumário (JSON), mapa de páginas de referência (versão `ref_page_version`) |
| `page_layout_cache` | quebras de página por (livro, hash dos ajustes, tamanho da tela, versão das fontes) |
| `annotations_fts` | FTS5 sobre texto do grifo + texto da nota (busca da tela 25), mantida por triggers |
| `catalog_cache` | respostas de ISBN/busca já vistas (com origem e licença — o que vem de ISBNdb/Google **não** vai para o catálogo compartilhado) |
| `kv` | preferências do app (tema `brand`, onboarding visto, último aviso de Pro…) |
| `social_cache` | perfil, clubes, posts recentes (para abrir offline) |
| `pending_social_ops` | ações sociais feitas offline (publicar post, responder no clube) — reenvio com idempotência |
| `sync_rejections` | operações que o servidor recusou (`rejected` da RPC): tabela, id, motivo, data — para diagnóstico e reparo; nunca reenviadas sem correção |

Banco do catálogo (`catalog.db`, separado, só leitura): `editions(isbn13 PK, title, authors, publisher, year, pages, language, cover_ref, source)` + índice FTS5 do título; baixado em segundo plano no Wi-Fi; atualizado por diferença mensal.

### 3.4 IDs e relógio

- `id`: UUIDv7 (`Uuid().v7()` do pacote `uuid`). No servidor, `private.uuid_generate_v7()`.
- `version_hlc`: relógio lógico híbrido em texto ordenável `"<ms_unix 16 dígitos>-<contador 4 dígitos>-<device_id>"`. Regras: `send()` = `max(agora, último.ms)`, contador +1 se o ms repetiu; `receive(remoto)` = avança para o maior. Persistir o último HLC no `kv`. Teste: 10 mil eventos em 3 aparelhos simulados com relógios defasados ±5 min → ordem total estável e monotônica por aparelho.
- `device_id`: UUID aleatório gerado na instalação (não é identificador de publicidade).

### 3.5 Migrações locais

- Tabelas sincronizadas: mudar o `Schema` do PowerSync (sem migração destrutiva; colunas novas = nulas). Tabelas só locais: migrações do drift com teste de migração (`drift_dev schema steps` + testes gerados) de **todas** as versões anteriores para a atual.
- Nunca apagar dados do Grátis numa migração (são a única cópia).

## 4. Modelo de domínio

### 4.1 Entidades pessoais (resumo; colunas completas no SQL)

- **UserBook** — um livro na estante (e-book, PDF ou físico). `format`, `status` (`want_to_read`/`reading`/`finished`/`abandoned`), `content_sha256` (dedupe e validade das âncoras), `ref_pages_total` + `ref_page_version`, `chapters_total`, `edition_id` (se casou com o catálogo).
- **ReadingPosition** — 1 por livro: localizador (Anexo 03 §5), página de referência, capítulo, progressão 0–1.
- **ReadingSession** — tempo de leitura: `active_seconds`, `source` (`auto` = e-book "contando sozinho", `timer` = livro físico, `manual`), páginas de/até.
- **Bookmark** — página marcada (fita): localizador + página de referência + excerto.
- **Annotation** — item da tela 25. `kind`: `highlight` (grifo, texto ou "à mão livre" convertido), `note` (nota de texto ligada a um grifo por `parent_id`), `handwriting` (nota à mão dentro de um espaço aberto), `drawing` (traços da caneta sobre o texto). `group_id` = cartão da tela 25. `shared_club_post_id` = compartilhado no clube.
- **InkLayer** — traços: `over_text` (ancorado em palavras) ou `space` (espaço aberto entre linhas, `space_lines`, `collapsed`). Traços no codec BNK1 (Anexo 03 §9.6) em base64.
- **HighlightLabel** — rótulo por cor ("lindo", "personagem", "ideia", "pro clube").
- **ReaderSettings**, **PenPresets**, **ReadingGoals** — 1 linha por usuário.

### 4.2 Contagens (sempre derivadas, nunca armazenadas)

- "Grifos 12" (tela 20) = `count(annotations where user_book_id = X and deleted_at is null)`.
- Filtros da tela 25: Grifos = `kind='highlight'`; Notas = `kind='note'`; À mão = `kind='handwriting'`; Desenhos = `kind='drawing'`.
- Marcas por capítulo (tela 27) = número de anotações com `chapter_index = c`; os **símbolos** seguem o arquivo, um por (tipo, cor), na ordem grifo → nota → desenho → nota à mão, no máximo 3: grifo = círculo na cor do grifo; nota = quadradinho amarelo inclinado −6°; desenho = círculo na cor da tinta; nota à mão = círculo claro com ícone de caneta coral. Confere com o arquivo: XXV → 1 símbolo (círculo amarelo), XXXI → 2 (círculo lavanda + quadradinho), XXXII → 3 (círculo amarelo + círculo coral + caneta) com o número 5.
- Rótulos (tela 23b) = grifos com a cor em todos os livros (D-40).
- Início: minutos hoje, sequência, páginas hoje, grifos hoje, semana — de `reading_sessions` e `annotations` no fuso do usuário (todas as contas, localmente).

### 4.3 Agrupamento em cartões (`group_id`)

Regra determinística aplicada **na criação** (e guardada, para não mudar depois):
1. Nota de texto → mesmo grupo do grifo pai.
2. Ao concluir uma sessão do modo anotação, os traços `drawing` da mesma página são agrupados quando a distância vertical entre as caixas de linha das âncoras é ≤ 2 linhas; um `handwriting` (espaço aberto) entra no grupo do desenho cuja âncora está na linha imediatamente acima da costura.
3. Grifos feitos fora do modo anotação → grupo próprio.

Casos de aceite (tela 25, pág. 159): elipse em "Olhos de ressaca?" + nota à mão depois de "Vá, de ressaca." = 1 cartão "DESENHO · À MÃO"; ondulado em "fluido misterioso" + duplo em "a vaga que se retira" = 1 cartão "2 DESENHOS"; grifo à mão livre em "olhos de Capitu" = cartão próprio. Teste com o layout da página 159 da fixture.

## 5. Servidor (Supabase, região São Paulo `sa-east-1`)

### 5.1 Projetos e ambientes

- 3 projetos: `booknest-dev`, `booknest-stg`, `booknest-prod` (Pro plan no prod; dev local via `supabase start` com Docker).
- Postgres **17** (o Supabase hospedado ainda não oferece o 18 — discussão pública do Supabase, jun/2026) → sem `uuidv7()` nativo; usar a função do SQL.
- Repositório: `supabase/migrations/*.sql` (geradas a partir do SQL de referência, uma por assunto), `supabase/tests/*.sql` (pgTAP), `supabase/functions/*` (Edge Functions em Deno/TypeScript), `supabase/seed.sql` (dados de dev — nunca dados reais).
- API exposta (PostgREST): só `public` (tabelas sociais + RPCs). `personal`, `billing`, `private` **não** são expostos; `catalog` é lido por RPC (`public.search_editions`).

### 5.2 Esquemas e tabelas

Ver `sql/01_schema_booknest.sql`. Resumo:

| Esquema | Tabelas |
|---|---|
| `catalog` | `authors`, `works`, `work_authors`, `editions`, `community_submissions`, `submission_confirmations` |
| `billing` | `subscriptions`, `entitlements`, `webhook_events`, `sync_access` |
| `private` | `account_lifecycle`, `email_outbox`, `quota_usage` + funções |
| `public` | `profiles`, `profile_stats`, `follows`, `user_blocks`, `posts`, `post_comments`, `post_likes`, `clubs`, `club_members`, `club_invites`, `club_meetings`, `club_posts`, `club_post_replies`, `notifications`, `device_tokens`, `content_reports` |
| `personal` | `user_books`, `reading_positions`, `reading_sessions` (particionada), `bookmarks`, `ink_layers`, `annotations`, `highlight_labels`, `reader_settings`, `pen_presets`, `reading_goals` |

### 5.3 Regras implementadas no banco (e testadas)

| Regra | Onde | Teste |
|---|---|---|
| Grátis não sincroniza dados pessoais | `public.sync_apply_changes` exige `private.can_sync` | OK 05 |
| Dono imposto pelo servidor (sem spoof de `user_id`) | RPC sobrescreve `user_id` com `auth.uid()` | OK 02 |
| Last-writer-wins por linha | `version_hlc` no `ON CONFLICT … WHERE` | OK 03 |
| Exclusão = tombstone | `DELETE` → `deleted_at` | OK 04 |
| Lista branca de tabelas na sincronização | RPC | OK 06 |
| Grátis cria 1 clube; Pro ilimitado (com trava contra criação simultânea) | trigger `clubs_before_insert` + advisory lock | OK 07/08 |
| Só membros veem/respondem no clube | RLS + trigger que herda `club_id` | OK 09/10 |
| Ver conteúdo de outros perfis = Pro (perfil fechado só com aprovação; bloqueio esconde) | `private.can_view_profile_content` | OK 11/12 |
| Prévia do Grátis não vaza o texto (só tamanho); perfil fechado não mostra nem os metadados | `public.profile_preview` | OK 11/19 |
| Uso justo nas consultas externas | `private.consume_quota` | OK 14 |
| Sem escalada de papel e sem contador forjado (privilégios padrão do Supabase revogados; GRANT por coluna) | seção 10 do SQL | OK 15 |
| A chave pública `anon` não lê nada nem chama RPCs | REVOKE + GRANT só para `authenticated` | OK 16 |
| Referência a linha de outro usuário recusada (FK composta `(id, user_id)`), HLC no futuro recusado, jsonb em texto convertido, lote parcial (uma linha ruim não trava a fila), `started_at` imutável e dentro das partições | `sync_apply_changes` + FKs compostas | OK 17 |
| Clube público: entrar sem convite ("participar de todos") | `public.join_public_club` | OK 18 |
| Partições mensais sem partição default | `private.ensure_session_partitions` | OK 20 |
| Retenção 12 meses: aviso **≥ 30 dias antes** do purge, mesmo com a rotina atrasada; revogar sync | `private.run_retention`, `refresh_sync_access` | OK 21 |
| Exclusão de conta do dono: clube passa ao membro mais antigo; posts do autor viram "apagados" e as respostas dos outros ficam | trigger `profiles_before_delete` | OK 22 |
| Bucket do PowerSync mantido 7 dias após o fim do Pro (upload bloqueado na hora); partição de sessão criada sob demanda pela RPC; erros transitórios relançados (não viram recusa) | `refresh_sync_access`, `ensure_session_partition_for`, `sync_apply_changes` | OK 23 |

Pendências do SQL (fazer na G04, com teste): `public.publish_my_stats` (já existe) ligado à tela de perfil; RPC `delete_my_account` (Edge Function com service role: RevenueCat + Storage + `auth.admin.deleteUser`); `club_meetings` com fuso; moderação (`content_reports` → painel interno); notificações por trigger + `pg_net` → Edge Function de push.

**Feito na G04** (migrations em `supabase/migrations`, testes em `supabase/tests/database`): exclusão de conta pela Edge Function `delete-account` (RevenueCat → Storage → Auth; fila `private.storage_purge_queue` como rede); `club_meetings.timezone` (IANA validado) com remarcar/desmarcar; moderação (denúncia única aberta, `private.moderation_queue` com prazo de 24 h, `private.moderate_report`, termos proibidos em `private.blocked_terms`); notificações criadas por gatilho e enviadas pela `push-sender` (pg_cron a cada minuto via `pg_net`; agrupamento por clube em 10 min); exportação `public.export_my_data`. Correções achadas nos testes da G04: apagar (deleted_at) o próprio conteúdo, contadores que descontam o apagado, índices das chaves estrangeiras, nome provisório do cadastro e RPC de sync em lote (p95 de 500 operações: 459 → ~63 ms). Ver `docs/progresso/RELATORIO_G04.md`.

**Revisão independente da G04** (migration `revisao_g04`, testes em `13_revisao_g04.test.sql`): conteúdo ocultado pela moderação ganha `moderated_at` (só servidor) e o autor não edita nem restaura; ocultar perfil zera nome ("Leitor"), @, bio e foto; o filtro de termos olha também o @; nome provisório com termo proibido vira "Leitor" (o cadastro não falha); seguir: o dono do perfil só aceita (pendente → aceito) e terceiros não veem pedidos pendentes; curtida/seguir/pedido repetidos geram no máximo 1 notificação por dia; token de push só pela RPC `public.register_device_token` (o token passa para a conta que entrou no aparelho); código de convite gerado pelo servidor (12 caracteres) e bloqueado pelo dono não entra no clube; RevenueCat: `TRANSFER` aplica as contas de origem e destino, assinatura que sumiu do estado sai do banco, o dono anterior é recalculado na hora, a chave "produto@data" é por usuário e um estado buscado antes do último aplicado é ignorado (`billing.rc_fetch_state`); cota de e-books com reservas (`private.ebook_upload_reservations`: cada URL ativa conta 200 MiB; perto do limite, um último upload pelo tamanho informado); retenção: o prazo de 30 dias conta do aviso **entregue** (e-mail enviado ou, sem e-mail, a notificação no app); a limpeza do Storage pula quem voltou a ser Pro; partições das sessões com RLS e privilégios explícitos; push agrupa só respostas do clube; o webhook não guarda atributos do assinante e os eventos somem com a conta.

**Feito na G05** (migration `conta_e_idade`, testes em `14_conta_e_idade.test.sql`): faixa etária da conta em `private.account_age` (só a **faixa** — `13_15`, `16_17`, `18_plus` — e a **fonte** — `play_signal`, `apple_signal`, `birthdate`; nunca a data de nascimento), gravada pela RPC `public.set_my_age_band` (menor de 13 recusado com `underage`; a data de nascimento não sobrescreve faixa já registrada, o sinal da loja sim; menor de 18 tem o perfil fechado por padrão — D-66); `public.my_account()` devolve o resumo da conta para o app (@, nome, visibilidade, se o @ ainda é o provisório "leitor_…", faixa, Pro); o @ no formato do provisório é reservado ao servidor (gatilho `profiles_handle_reserved`); `export_my_data` passa a `format_version` 2, com a faixa etária. A Edge Function `delete-account` aceita CORS **só** da origem da página web de exclusão (`EXCLUSAO_WEB_ORIGEM`). Ver `docs/progresso/RELATORIO_G05.md`.

**Antes da G06** (migration `social_exige_faixa`, testes em `15_social_exige_faixa.test.sql` — D-72): o social exige a faixa etária registrada — gatilho `private.require_age_band` em seguir, posts, comentários, curtidas, clubes, membros (inclusive pelas RPCs de entrar), convites, encontros, posts e respostas de clube; abrir o próprio perfil também (`private.public_profile_requires_age`). Denunciar, bloquear e registrar o aparelho continuam livres; rotinas sem usuário no JWT não são afetadas.

### 5.4 RLS — padrões obrigatórios

- RLS **ligada em todas** as tabelas; tabela sem política = só `service_role`.
- `auth.uid()` sempre como `(select auth.uid())` (avaliado uma vez por consulta).
- Lógica de permissão em funções `security definer` com `set search_path = ''`, com índice nas colunas consultadas (`club_members(user_id)`, `follows(followee_id, status)`, `user_blocks(blocked_id)`…).
- **Privilégios padrão do Supabase:** tudo que é criado em `public` nasce com `ALL` para `anon`/`authenticated` e funções com `EXECUTE` para `PUBLIC`. Toda migration termina revogando isso (`REVOKE … FROM anon, authenticated, public` + `ALTER DEFAULT PRIVILEGES … REVOKE`) e concedendo **por coluna** (`GRANT INSERT (…)`, `GRANT UPDATE (…)`): o cliente nunca escreve contadores, `role`, `status` de assinatura, `club_id` de resposta. O stub local reproduz os padrões do Supabase para o teste pegar regressões.
- Toda regra nova entra com teste pgTAP de **acesso negado** (usuário errado, Grátis, não membro, bloqueado).

## 6. Sincronização Pro (PowerSync)

### 6.1 Fluxo

```
App (SQLite) ──escreve──▶ fila CRUD do PowerSync (ps_crud)
     │                          │ uploadData() em lotes ≤ 500
     │                          ▼
     │                 RPC public.sync_apply_changes(jsonb)  ← Supabase (JWT do usuário)
     │                          │  LWW por version_hlc · dono imposto · exige Pro
     │                          │  devolve {applied, skipped, rejected[]}: o app tira as recusadas
     │                          │  da fila, guarda em `sync_rejections` (local) e manda ao Sentry;
     │                          │  erros transitórios (trava, deadlock, recurso) derrubam o lote
     │                          │  inteiro → o app repete com recuo (nada se perde)
     ▼                          ▼
PowerSync Service ◀── replicação lógica ── Postgres (personal.*, billing.sync_access)
     │  bucket "pessoal" só para quem tem sync_access.granted
     └────────────▶ baixa para todos os aparelhos do usuário
```

### 6.2 Regras de sincronização (Sync Streams — ADR-003, provadas no S2)

```yaml
config: { edition: 3 }            # bucket_definitions é legado no serviço PowerSync 1.27
with:
  pro: SELECT user_id FROM billing.sync_access WHERE user_id = auth.user_id() AND granted = true
streams:
  pessoal:
    auto_subscribe: true
    queries:
      - SELECT * FROM personal.user_books        WHERE user_id IN pro
      - SELECT * FROM personal.reading_positions WHERE user_id IN pro
      - SELECT * FROM personal."reading_sessions_%" AS reading_sessions WHERE user_id IN pro
      - SELECT * FROM personal.bookmarks         WHERE user_id IN pro
      - SELECT * FROM personal.ink_layers        WHERE user_id IN pro
      - SELECT * FROM personal.annotations       WHERE user_id IN pro
      - SELECT * FROM personal.highlight_labels  WHERE user_id IN pro
      - SELECT * FROM personal.reader_settings   WHERE user_id IN pro
      - SELECT * FROM personal.pen_presets       WHERE user_id IN pro
      - SELECT * FROM personal.reading_goals     WHERE user_id IN pro
```

Notas: nomes **qualificados** pelo esquema; publicação lógica `powersync` **sem** `publish_via_partition_root` (o serviço recusa: `PSYNC_S1143`) — cada partição de `reading_sessions` chega com o próprio nome e o curinga `reading_sessions_%` junta todas (partições novas entram sozinhas; conferido por pgTAP na G04); o PowerSync exige coluna `id` única por linha (ok — UUIDv7); linhas com `deleted_at` **são** enviadas (é assim que a exclusão chega aos outros aparelhos; a UI filtra `deleted_at is null`); o upload é sempre `PUT` com a linha inteira (sem `PATCH`); tombstones com mais de 90 dias podem ser podados depois que todos os aparelhos do usuário confirmaram (G06).

### 6.3 Momentos

- **Virar Pro:** ligar a fila (§3.1), reenfileirar tudo como `PUT`, autenticar o PowerSync com o JWT do Supabase e subir em lotes de até 500, com progresso discreto. Conflito impossível na primeira subida (ids únicos).
- **Segundo aparelho:** entrar com a conta → baixar o bucket → baixar os e-books do Storage sob demanda (só metadados de início).
- **Cancelou/expirou:** o app desliga a fila e desconecta na expiração prevista (§3.1) — nada é copiado nem apagado; no servidor, o webhook atualiza `entitlements`, o upload para na hora e `refresh_sync_access` revoga o bucket 7 dias depois. Nada local é apagado. Dados na nuvem: 12 meses (`run_retention`).
- **Assinou de novo:** dentro de 12 meses → reenfileira tudo como `PUT` e reconecta (o LWW reconcilia); depois do purge → mesma coisa, a nuvem é repovoada a partir do aparelho.
- **Excluir conta:** apaga tudo no servidor imediatamente (LGPD), inclusive Storage e RevenueCat; o app pergunta se apaga também os dados locais.

### 6.4 E-books na nuvem (Pro, opcional)

Bucket privado `ebooks`, caminho `<user_id>/<user_book_id>/<sha256>.<ext>`; **sem política de INSERT** para o cliente: o upload só acontece por URL assinada emitida pela Edge Function `ebook-upload-url`, que confere o Pro e a cota de 2 GB (upload direto burlaria a cota); retomada de upload só se o S2 provar que funciona com URL assinada; download sob demanda no outro aparelho; deduplicação por sha256 dentro da conta.

## 7. Catálogo e scanner (custo quase zero com 10+ scans por pessoa por dia)

Camadas (doc de monetização v3, implementação na G07):

1. **Leitura do código** — `mobile_scanner` (ML Kit no Android, Vision no iOS), offline, sem chave. Validação ISBN-10/ISBN-13 (dígito verificador), conversão 10→13, prefixos 978/979 (atenção a 978-65 — editoras brasileiras recentes).
2. **No aparelho** — `catalog.db` com 300 mil–1 milhão de ISBNs mais comuns (36–120 MB comprimido; download em segundo plano no Wi-Fi; delta mensal) + tudo que a própria pessoa já escaneou.
3. **Catálogo próprio na borda** — dumps CC0 (Open Library; DNB) → arquivos por prefixo de ISBN no R2 (ex.: `isbn/v1/9788535.jsonl.gz` com todos os ISBNs do prefixo) servidos por um Cloudflare Worker com cache; sem banco.
4. **Comunidade** — "adicionar este livro": OCR do título da capa no aparelho (`google_mlkit_text_recognition`), a pessoa confirma → `catalog.community_submissions`; 2 confirmações independentes → `approved` → entra no catálogo compartilhado.
5. **APIs externas (último recurso)** — Edge Function `isbn-lookup`: BrasilAPI → Hardcover → ISBNdb (pago, só se o volume pedir), com `private.consume_quota` (Grátis 30/dia, Pro 150/dia). Resultado vai para a estante da pessoa, **não** para o catálogo compartilhado (termos do ISBNdb/Google). Google Books só exibição ao vivo, sem guardar.

Pipeline de dados (`tools/catalog/`, Python): baixar dumps → filtrar/normalizar (NFC, ISBN-13, autores) → gerar `catalog.db` (top-N por popularidade/edições BR) e os shards do R2 → manifestos com hash → publicar. Licença por registro (`source`, `source_license`).

## 8. Rotinas agendadas (pg_cron + Edge Functions)

| Rotina | Frequência | O que faz |
|---|---|---|
| `private.ensure_session_partitions(3)` | diário, 03:07 | garante as partições mensais de 2026-01 até 3 meses à frente (não há partição `default`: sessão fora do intervalo `[2024-01-01, agora + 1 dia]` é recusada pela RPC; 2024–2025 ficam numa partição histórica) |
| `private.refresh_sync_access()` | a cada 15 min | concede/revoga o bucket pessoal conforme `entitlements` (revoga 7 dias após o fim do Pro) |
| `private.run_retention()` | diário, 06:17 | ciclo de 12 meses: aviso 30 dias antes, purge, e-mail |
| `email-sender` (Edge Function) | a cada 5 min | envia `private.email_outbox` (Resend) |
| `purge-storage` (Edge Function) | diário | apaga `ebooks/<user_id>/` de quem foi purgado/excluído |
| `quota-cleanup` | diário | apaga `quota_usage` com mais de 30 dias |
| `cold-backup` (Edge Function/Action) | semanal | exporta dump lógico criptografado para armazenamento frio (R2) |
| `push-sender` (Edge Function) | a cada minuto | envia o push das notificações novas (G04) |
| `private.queue_meeting_reminders()` | de hora em hora (:05) | lembrete "encontro do clube amanhã" (G04) |
| `private.prune_notifications()` | diário | apaga notificações lidas com mais de 90 dias (G04) |

Na G04 os nomes e horários (UTC) ficaram na migration `agendamentos`; o `cold-backup` roda no GitHub Actions (`.github/workflows/cold-backup.yml`), porque o `pg_dump` não roda dentro do banco nem numa Edge Function.

## 9. Volumes estimados (para dimensionar — revisar com dados do beta)

Premissas: 1 milhão de usuários/mês, 30 % ativos por dia, 5 % Pro (50 mil), Pro ativo: 3 sessões/dia, 20 anotações/mês, 5 camadas de tinta/mês (~4 KB cada).

| Tabela (servidor) | Linhas/mês | Tamanho/mês | Observação |
|---|---|---|---|
| `personal.reading_sessions` | ~1,35 mi | ~300 MB c/ índices | particionada por mês (consultas e manutenção); a retenção é por usuário |
| `personal.annotations` | ~1 mi | ~400 MB | índice por (livro, página) |
| `personal.ink_layers` | ~250 mil | ~1 GB | maior consumidor; limite 256 KB por camada |
| `public.club_posts` + respostas | ~2–5 mi | ~1–2 GB | depende da adoção de clubes |
| `public.notifications` | ~10 mi | ~2 GB | podar lidas com > 90 dias |

O Grátis não gera linhas pessoais no servidor — é isso que mantém o custo baixo (ver tabela de custos do doc de monetização). PowerSync Pro (US$ 49/mês) inclui 1.000 clientes simultâneos e 30 GB sincronizados/mês; US$ 30 por 1.000 clientes extras (preços consultados em 03/10/2026).

## 10. Consultas quentes e índices (gate de desempenho na G26)

| Consulta | Índice | Meta (p95, prod) |
|---|---|---|
| Feed do clube (keyset por `created_at desc, id`) | `club_posts_club_idx` (parcial, sem apagados) | < 30 ms |
| Respostas de um post | `club_post_replies_post_idx` | < 20 ms |
| Notificações não lidas | `notifications_unread_idx` (parcial) | < 10 ms |
| Prévia de perfil | PK + `posts_author_idx` | < 20 ms |
| Busca no catálogo referenciado | `editions_title_trgm_idx` (GIN trigram, sem acento) | < 80 ms |
| Upload de sync (500 ops) | PKs + índices `(user_id, updated_at)` | < 400 ms |

Paginação sempre por **keyset** (nunca `OFFSET` em listas grandes). Todo SQL novo: `EXPLAIN (ANALYZE, BUFFERS)` anexado ao relatório da fase.

## 11. Segurança

- Chave `service_role` **só** em Edge Functions/CI (segredos do Supabase/GitHub); o app usa a chave pública (anon) + JWT do usuário.
- Segredos fora do git (`.env.*` no `.gitignore`; `--dart-define-from-file` só com chaves públicas); varredura `gitleaks` no CI.
- Webhook do RevenueCat com cabeçalho `Authorization` secreto + idempotência por `event_id`.
- Limites de taxa: Edge Functions com cota por usuário; Worker do catálogo com limite por IP.
- Backups: diários do Supabase (Pro) + exportação semanal criptografada; teste de restauração trimestral (documentado).
- Ameaças (STRIDE) e checklist OWASP MASVS na G25.

## 12. LGPD (mapa de dados — base para a política de privacidade; não é parecer jurídico)

| Categoria | Exemplos | Onde | Base legal (proposta) | Retenção |
|---|---|---|---|---|
| Conta | e-mail, provedor de login | Supabase Auth | execução de contrato | até excluir a conta |
| Faixa etária (G05, D-66) | faixa (13–15, 16–17, 18+) e fonte (loja ou data informada) — **sem** a data de nascimento (usada só no aparelho para calcular a faixa e não guardada) | `private.account_age` | cumprimento de obrigação legal (ECA Digital) — confirmar na G25 | até excluir a conta |
| Perfil público | @, nome, foto, bio, números | `public.*` | execução de contrato | até excluir |
| Conteúdo social | posts, clubes, respostas | `public.*` | execução de contrato | até excluir (ou o autor apagar) |
| Dados pessoais de leitura (Pro) | estante, grifos, tinta, sessões | `personal.*` | execução de contrato | assinatura + 12 meses |
| Dados pessoais de leitura (Grátis) | idem | só no aparelho | — (não coletados) | até desinstalar |
| Assinatura | produto, status, datas | `billing.*`, RevenueCat | contrato / obrigação legal | prazo fiscal (confirmar com contador) |
| Diagnóstico | falhas, desempenho | Sentry | legítimo interesse | 90 dias |
| Analytics de produto | eventos anônimos | PostHog (opt-in) | consentimento | 12 meses |

Direitos do titular dentro do app: ver/baixar os próprios dados (exportação — D-24), corrigir perfil, excluir conta (imediato, inclusive dentro dos 12 meses), revogar consentimento de analytics. Também: indicar o **encarregado (DPO)** e um canal de contato; **plano de resposta a incidentes** (registro, avaliação de risco e comunicação à ANPD e aos titulares no prazo da regulamentação vigente — conferir a Resolução CD/ANPD nº 15/2024); **crianças e adolescentes:** o app tem conteúdo social → verificar as obrigações vigentes (Lei 15.211/2025, "ECA Digital", e regras das lojas) — idade mínima, verificação etária, controles; decidir com advogado na G25. **Transferência internacional:** RevenueCat, Sentry, PostHog, Cloudflare, Google (FCM) e possivelmente o PowerSync Cloud processam fora do Brasil → declarar na política (LGPD art. 33) e preferir regiões BR/UE quando houver; a região do PowerSync é critério do ADR-003 (self-host em `sa-east-1` se não houver região adequada). Backups do sistema desligados para o banco local: `android:allowBackup="false"` **e** `android:dataExtractionRules` (Android 12+: a transferência aparelho-a-aparelho ignora o `allowBackup`) excluindo o banco e os livros; no iOS, `NSURLIsExcludedFromBackupKey` nos arquivos do banco — senão o "só neste celular" do Grátis deixa de ser verdade.

## 13. Testes do banco

- `sql/02_testes_rls.sql` (fumaça, 23/23 passando) → vira pgTAP: um arquivo por esquema, cobrindo **cada política** com caso permitido e negado.
- Teste de contrato aparelho ↔ servidor (colunas iguais).
- Teste de sincronização com 2 aparelhos simulados (G06): offline nos dois, edições cruzadas, reconexão → estado igual nos dois e no servidor.
- Teste de carga (k6) da RPC de sync e do Worker do catálogo (G26).

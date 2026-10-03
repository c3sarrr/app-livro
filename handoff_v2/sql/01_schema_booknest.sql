-- =====================================================================================
-- BookNest — esquema do banco (Supabase / Postgres 17)            versão 0.1 · 03/10/2026
-- Rascunho de referência do Anexo 02. Validado (23/23 testes) num Postgres 16 local com o stub
-- 00_stub_supabase_local.sql (que reproduz os privilégios padrão do Supabase) + 02_testes_rls.sql
-- (isolamento entre usuários, LWW, Grátis bloqueado, limites, ataques com JWT forjado, retenção).
--
-- Na G04 este arquivo é QUEBRADO em migrations (`supabase/migrations/<timestamp>_*.sql`) e
-- coberto por testes pgTAP (`supabase/tests/*.sql`). Não aplique este arquivo inteiro em produção.
--
-- Esquemas
--   public    → social (todas as contas): perfis, seguidores, posts, clubes, notificações
--   personal  → dados pessoais. Grátis: NUNCA chegam aqui (só SQLite no aparelho).
--               Pro: sincronizados (PowerSync lê por replicação; escrita só pela RPC
--               public.sync_apply_changes, operação por operação, com recusas devolvidas).
--   catalog   → catálogo de livros REFERENCIADO (o catálogo completo fica em R2/Workers)
--   billing   → assinaturas e direitos (só service_role / Edge Functions)
--   private   → funções e tabelas internas (nunca expostas pela API)
--
-- Convenções
--   * ids = UUIDv7 gerados no aparelho (pacote `uuid`, Uuid().v7()); no servidor,
--     private.uuid_generate_v7() (o Postgres 17 do Supabase ainda não tem uuidv7() nativo).
--   * Datas em timestamptz (UTC). Fuso de exibição = profiles.timezone.
--   * Tabelas sincronizadas têm updated_at, deleted_at (tombstone) e version_hlc
--     (relógio lógico híbrido "0001727218800000-0000-<device>" — comparação lexicográfica).
--   * Domínios fechados = text + CHECK (evolui sem ALTER TYPE).
--   * RLS ligada em TODAS as tabelas. auth.uid() sempre dentro de (select …) (cache por query).
-- =====================================================================================

create schema if not exists private;
create schema if not exists personal;
create schema if not exists catalog;
create schema if not exists billing;

-- -------------------------------------------------------------------------------------
-- 0. Utilitários
-- -------------------------------------------------------------------------------------

create or replace function private.uuid_generate_v7() returns uuid
language plpgsql volatile set search_path = '' as $$
declare
  v_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_b  bytea  := extensions.gen_random_bytes(16);
begin
  v_b := set_byte(v_b, 0, ((v_ms >> 40) & 255)::int);
  v_b := set_byte(v_b, 1, ((v_ms >> 32) & 255)::int);
  v_b := set_byte(v_b, 2, ((v_ms >> 24) & 255)::int);
  v_b := set_byte(v_b, 3, ((v_ms >> 16) & 255)::int);
  v_b := set_byte(v_b, 4, ((v_ms >> 8) & 255)::int);
  v_b := set_byte(v_b, 5, (v_ms & 255)::int);
  v_b := set_byte(v_b, 6, (get_byte(v_b, 6) & 15) | 112);   -- versão 7
  v_b := set_byte(v_b, 8, (get_byte(v_b, 8) & 63) | 128);   -- variante RFC 9562
  return encode(v_b, 'hex')::uuid;
end $$;

-- unaccent não é IMMUTABLE; este invólucro permite índice funcional.
create or replace function private.f_unaccent(text) returns text
language sql immutable parallel safe strict set search_path = '' as $$
  select extensions.unaccent('extensions.unaccent'::regdictionary, $1)
$$;

create or replace function private.touch_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- -------------------------------------------------------------------------------------
-- 1. Catálogo referenciado (só livros que aparecem em dados sociais ou de assinantes)
-- -------------------------------------------------------------------------------------

create table catalog.authors (
  id             uuid primary key default private.uuid_generate_v7(),
  name           text not null check (char_length(name) between 1 and 200),
  sort_name      text,
  ol_author_key  text unique,
  created_at     timestamptz not null default now()
);

create table catalog.works (
  id                   uuid primary key default private.uuid_generate_v7(),
  title                text not null check (char_length(title) between 1 and 500),
  original_language    text,
  first_published_year smallint,
  ol_work_key          text unique,
  created_at           timestamptz not null default now()
);

create table catalog.work_authors (
  work_id    uuid not null references catalog.works(id) on delete cascade,
  author_id  uuid not null references catalog.authors(id) on delete cascade,
  position   smallint not null default 0,
  primary key (work_id, author_id)
);
create index work_authors_author_idx on catalog.work_authors (author_id);

create table catalog.editions (
  id              uuid primary key default private.uuid_generate_v7(),
  work_id         uuid references catalog.works(id) on delete set null,
  isbn13          text unique check (isbn13 ~ '^97[89][0-9]{10}$'),
  isbn10          text check (isbn10 ~ '^[0-9]{9}[0-9X]$'),
  title           text not null check (char_length(title) between 1 and 500),
  subtitle        text,
  publisher       text,
  published_year  smallint,
  language        text,
  pages           integer check (pages > 0),
  chapters_total  integer check (chapters_total > 0),
  cover_ref       text,                       -- id de capa da fonte (não republicamos capas)
  source          text not null check (source in ('openlibrary','dnb','community','brasilapi','hardcover','isbndb','manual')),
  source_license  text,                       -- ex.: 'CC0'; ISBNdb/Google NÃO entram aqui (termos)
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index editions_work_idx on catalog.editions (work_id);
create index editions_title_trgm_idx on catalog.editions
  using gin (private.f_unaccent(lower(title)) extensions.gin_trgm_ops);
create trigger editions_touch before update on catalog.editions
  for each row execute function private.touch_updated_at();

-- Camada 3 do scanner: "adicionar este livro" (OCR da capa + confirmação comunitária)
create table catalog.community_submissions (
  id              uuid primary key default private.uuid_generate_v7(),
  isbn13          text not null check (isbn13 ~ '^97[89][0-9]{10}$'),
  title           text not null check (char_length(title) between 1 and 500),
  authors         text not null check (char_length(authors) between 1 and 500),
  publisher       text,
  submitted_by    uuid references auth.users(id) on delete set null,
  status          text not null default 'pending' check (status in ('pending','approved','rejected')),
  confirmations   integer not null default 0,
  created_at      timestamptz not null default now()
);
create index community_submissions_isbn_idx on catalog.community_submissions (isbn13, status);
create index community_submissions_user_idx on catalog.community_submissions (submitted_by);

create table catalog.submission_confirmations (
  submission_id uuid not null references catalog.community_submissions(id) on delete cascade,
  user_id       uuid not null references auth.users(id) on delete cascade,
  created_at    timestamptz not null default now(),
  primary key (submission_id, user_id)
);
create index submission_confirmations_user_idx on catalog.submission_confirmations (user_id);

-- -------------------------------------------------------------------------------------
-- 2. Assinatura e direitos (escrito só pelo webhook do RevenueCat → Edge Function)
-- -------------------------------------------------------------------------------------

create table billing.subscriptions (
  id                       uuid primary key default private.uuid_generate_v7(),
  user_id                  uuid not null references auth.users(id) on delete cascade,
  store                    text not null check (store in ('app_store','play_store','promotional','test_store')),
  product_id               text not null,                  -- App Store: booknest_pro_mensal|anual · Play: booknest_pro:mensal|anual
  entitlement              text not null default 'pro',
  period_type              text not null check (period_type in ('trial','intro','normal','promotional')),
  status                   text not null check (status in ('active','in_grace_period','in_billing_retry','cancelled','expired','paused','refunded')),
  will_renew               boolean not null,
  current_period_starts_at timestamptz not null,
  current_period_ends_at   timestamptz not null,
  grace_period_ends_at     timestamptz,
  original_transaction_id  text not null,
  environment              text not null check (environment in ('sandbox','production')),
  last_event_at            timestamptz not null,
  updated_at               timestamptz not null default now(),
  unique (store, original_transaction_id)
);
create index subscriptions_user_idx on billing.subscriptions (user_id);

create table billing.entitlements (
  user_id                uuid not null references auth.users(id) on delete cascade,
  entitlement            text not null,
  active_until           timestamptz not null,           -- inclui período de carência da loja
  environment            text not null default 'production' check (environment in ('sandbox','production')),
                                                         -- sandbox LIBERA o Pro (revisão da Apple e TestFlight
                                                         -- compram em sandbox) mas fica fora dos relatórios — D-48
  source_subscription_id uuid references billing.subscriptions(id) on delete set null,
  updated_at             timestamptz not null default now(),
  primary key (user_id, entitlement)
);

-- Idempotência do webhook: cada event.id do RevenueCat é processado uma vez só.
create table billing.webhook_events (
  event_id      text primary key,
  event_type    text not null,
  app_user_id   text,
  payload       jsonb not null,
  received_at   timestamptz not null default now(),
  processed_at  timestamptz,
  error         text
);

-- Ciclo de vida do Pro (retenção de 12 meses após o fim do Pro — LGPD na política de privacidade)
create table private.account_lifecycle (
  user_id          uuid primary key references auth.users(id) on delete cascade,
  pro_ended_at     timestamptz,
  purge_after      timestamptz,          -- pro_ended_at + 12 meses
  warning_sent_at  timestamptz,          -- aviso por e-mail 30 dias antes
  purged_at        timestamptz
);

create table private.email_outbox (
  id          uuid primary key default private.uuid_generate_v7(),
  user_id     uuid references auth.users(id) on delete cascade,
  template    text not null check (template in ('retention_warning','retention_purged','welcome','export_ready')),
  payload     jsonb not null default '{}',
  created_at  timestamptz not null default now(),
  sent_at     timestamptz
);
create index email_outbox_pending_idx on private.email_outbox (created_at) where sent_at is null;

create or replace function private.user_is_pro(p_user uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from billing.entitlements e
    where e.user_id = p_user and e.entitlement = 'pro' and e.active_until > now()
  )
$$;

create or replace function private.is_pro() returns boolean
language sql stable security definer set search_path = '' as $$
  select private.user_is_pro((select auth.uid()))
$$;

-- Pode sincronizar = é Pro (a carência da loja já está dentro de active_until).
create or replace function private.can_sync(p_user uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select private.user_is_pro(p_user)
$$;

-- Quem pode receber o bucket pessoal do PowerSync. TABELA (não view): o PowerSync só replica
-- tabelas e as regras de sync não avaliam now(). Mantida pelo webhook e por
-- private.refresh_sync_access() (pg_cron a cada 15 min).
-- O bucket continua concedido por 7 DIAS depois do fim do Pro: assim o app tem folga para se
-- desconectar e copiar os dados para as tabelas localOnly ANTES de o PowerSync remover o bucket
-- (o que apagaria as linhas do aparelho). Upload já é bloqueado na hora por private.can_sync.
create table billing.sync_access (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  granted     boolean not null,
  updated_at  timestamptz not null default now()
);

create or replace function private.refresh_sync_access() returns void
language plpgsql security definer set search_path = '' as $$
begin
  insert into billing.sync_access as s (user_id, granted, updated_at)
  select e.user_id, e.active_until + interval '7 days' > now(), now()
    from billing.entitlements e where e.entitlement = 'pro'
  on conflict (user_id) do update set granted = excluded.granted, updated_at = now()
   where s.granted is distinct from excluded.granted;
end $$;

-- -------------------------------------------------------------------------------------
-- 3. Social (todas as contas)
-- -------------------------------------------------------------------------------------

create table public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  handle        text not null unique check (handle ~ '^[a-z0-9_.]{3,30}$'),
  display_name  text not null check (char_length(display_name) between 1 and 60),
  avatar_path   text,
  bio           text check (char_length(bio) <= 280),
  visibility    text not null default 'public' check (visibility in ('public','private')),
  timezone      text not null default 'America/Sao_Paulo',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create trigger profiles_touch before update on public.profiles
  for each row execute function private.touch_updated_at();

-- Números públicos do perfil (o Grátis publica só agregados; nunca a estante/grifos crus).
create table public.profile_stats (
  user_id           uuid primary key references public.profiles(id) on delete cascade,
  books_read_total  integer not null default 0 check (books_read_total >= 0),
  books_read_year   integer not null default 0 check (books_read_year >= 0),
  reading_now       integer not null default 0 check (reading_now >= 0),
  streak_days       integer not null default 0 check (streak_days >= 0),
  followers_count   integer not null default 0,
  following_count   integer not null default 0,
  posts_count       integer not null default 0,
  updated_at        timestamptz not null default now()
);

create table public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  followee_id uuid not null references public.profiles(id) on delete cascade,
  status      text not null default 'accepted' check (status in ('pending','accepted')),
  created_at  timestamptz not null default now(),
  primary key (follower_id, followee_id),
  check (follower_id <> followee_id)
);
create index follows_followee_idx on public.follows (followee_id, status);

create table public.user_blocks (
  blocker_id uuid not null references public.profiles(id) on delete cascade,
  blocked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id)
);
create index user_blocks_blocked_idx on public.user_blocks (blocked_id);

-- Resenhas, citações (grifos publicados) e listas no perfil
create table public.posts (
  id            uuid primary key default private.uuid_generate_v7(),
  author_id     uuid not null references public.profiles(id) on delete cascade,
  kind          text not null check (kind in ('review','quote','list')),
  edition_id    uuid references catalog.editions(id) on delete set null,
  work_id       uuid references catalog.works(id) on delete set null,
  rating        smallint check (rating between 1 and 5),
  quote_text    text check (char_length(quote_text) <= 1200),
  body          text check (char_length(body) <= 5000),
  likes_count    integer not null default 0,
  comments_count integer not null default 0,
  created_at    timestamptz not null default now(),
  edited_at     timestamptz,
  deleted_at    timestamptz
);
create index posts_author_idx on public.posts (author_id, created_at desc) where deleted_at is null;
create index posts_work_idx on public.posts (work_id, created_at desc) where deleted_at is null;

create table public.post_comments (
  id          uuid primary key default private.uuid_generate_v7(),
  post_id     uuid not null references public.posts(id) on delete cascade,
  author_id   uuid not null references public.profiles(id) on delete cascade,
  body        text not null check (char_length(body) between 1 and 2000),
  created_at  timestamptz not null default now(),
  deleted_at  timestamptz
);
create index post_comments_post_idx on public.post_comments (post_id, created_at);
create index post_comments_author_idx on public.post_comments (author_id);

create table public.post_likes (
  post_id    uuid not null references public.posts(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);
create index post_likes_user_idx on public.post_likes (user_id);

-- Clubes do livro ----------------------------------------------------------------------

create table public.clubs (
  id                 uuid primary key default private.uuid_generate_v7(),
  owner_id           uuid not null references public.profiles(id) on delete cascade,
  name               text not null check (char_length(name) between 1 and 60),
  name_highlight     text,                 -- trecho do nome em destaque ("Capitu" em "Leitoras de Capitu")
  work_id            uuid references catalog.works(id) on delete set null,
  edition_id         uuid references catalog.editions(id) on delete set null,
  privacy            text not null default 'invite' check (privacy in ('public','invite')),
  goal_chapter       integer check (goal_chapter > 0),         -- "Até o cap. L" → 50
  goal_chapter_label text,                                     -- rótulo como no livro: "L"
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  check (name_highlight is null or position(name_highlight in name) > 0)
);
create index clubs_owner_idx on public.clubs (owner_id);
create trigger clubs_touch before update on public.clubs
  for each row execute function private.touch_updated_at();

create table public.club_members (
  club_id              uuid not null references public.clubs(id) on delete cascade,
  user_id              uuid not null references public.profiles(id) on delete cascade,
  role                 text not null default 'member' check (role in ('owner','moderator','member')),
  progress_chapter     integer check (progress_chapter >= 0),       -- publicado pelo membro
  progress_ratio       numeric(5,4) check (progress_ratio between 0 and 1),
  progress_updated_at  timestamptz,
  last_read_post_at    timestamptz,                                -- mensagens não lidas no ticket
  joined_at            timestamptz not null default now(),
  primary key (club_id, user_id)
);
create index club_members_user_idx on public.club_members (user_id);

create table public.club_invites (
  code        text primary key check (code ~ '^[A-Za-z0-9]{8,16}$'),
  club_id     uuid not null references public.clubs(id) on delete cascade,
  created_by  uuid not null references public.profiles(id) on delete cascade,
  expires_at  timestamptz not null,
  max_uses    integer not null default 50 check (max_uses > 0),
  uses        integer not null default 0
);
create index club_invites_club_idx on public.club_invites (club_id);
create index club_invites_created_by_idx on public.club_invites (created_by);

create table public.club_meetings (
  id             uuid primary key default private.uuid_generate_v7(),
  club_id        uuid not null references public.clubs(id) on delete cascade,
  starts_at      timestamptz not null,                 -- "QUI 24/9"
  location       text check (char_length(location) <= 200),
  until_chapter  integer check (until_chapter > 0),
  created_by     uuid references public.profiles(id) on delete set null,
  created_at     timestamptz not null default now()
);
create index club_meetings_club_idx on public.club_meetings (club_id, starts_at);
create index club_meetings_created_by_idx on public.club_meetings (created_by);

-- Posts do clube: discussão ou grifo compartilhado ("Leitoras de Capitu · 3 respostas")
create table public.club_posts (
  id             uuid primary key default private.uuid_generate_v7(),
  club_id        uuid not null references public.clubs(id) on delete cascade,
  author_id      uuid references public.profiles(id) on delete set null,   -- conta excluída: post vira "apagado" e as respostas dos outros ficam
  kind           text not null check (kind in ('discussion','shared_highlight')),
  chapter_index  integer not null check (chapter_index >= 0),   -- nível de spoiler (D-36)
  ref_page       integer check (ref_page > 0),
  quote_text     text check (char_length(quote_text) <= 1200),  -- cópia do trecho (sem âncora privada)
  quote_color    text check (quote_color ~ '^#[0-9A-F]{6}$'),
  body           text check (char_length(body) <= 5000),
  replies_count  integer not null default 0,
  created_at     timestamptz not null default now(),
  edited_at      timestamptz,
  deleted_at     timestamptz,
  check (kind <> 'shared_highlight' or quote_text is not null or deleted_at is not null)
);
create index club_posts_club_idx on public.club_posts (club_id, created_at desc) where deleted_at is null;
create index club_posts_author_idx on public.club_posts (author_id);

create table public.club_post_replies (
  id          uuid primary key default private.uuid_generate_v7(),
  post_id     uuid not null references public.club_posts(id) on delete cascade,
  club_id     uuid not null references public.clubs(id) on delete cascade,   -- desnormalizado p/ RLS
  author_id   uuid not null references public.profiles(id) on delete cascade,
  body        text not null check (char_length(body) between 1 and 2000),
  created_at  timestamptz not null default now(),
  deleted_at  timestamptz
);
create index club_post_replies_post_idx on public.club_post_replies (post_id, created_at);
create index club_post_replies_club_idx on public.club_post_replies (club_id);
create index club_post_replies_author_idx on public.club_post_replies (author_id);

-- Notificações e aparelhos -------------------------------------------------------------

create table public.notifications (
  id          uuid primary key default private.uuid_generate_v7(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  type        text not null check (type in ('follow','follow_request','post_like','post_comment','club_reply','club_meeting','club_invite','retention_warning','system')),
  actor_id    uuid references public.profiles(id) on delete cascade,
  club_id     uuid references public.clubs(id) on delete cascade,
  post_id     uuid,
  payload     jsonb not null default '{}',
  created_at  timestamptz not null default now(),
  read_at     timestamptz
);
create index notifications_user_idx on public.notifications (user_id, created_at desc);
create index notifications_unread_idx on public.notifications (user_id) where read_at is null;
create index notifications_actor_idx on public.notifications (actor_id);
create index notifications_club_idx on public.notifications (club_id);

create table public.device_tokens (
  token        text primary key,
  user_id      uuid not null references public.profiles(id) on delete cascade,
  platform     text not null check (platform in ('android','ios')),
  app_version  text,
  updated_at   timestamptz not null default now()
);
create index device_tokens_user_idx on public.device_tokens (user_id);

create table public.content_reports (
  id           uuid primary key default private.uuid_generate_v7(),
  reporter_id  uuid not null references public.profiles(id) on delete cascade,
  target_type  text not null check (target_type in ('profile','post','post_comment','club','club_post','club_post_reply')),
  target_id    uuid not null,
  reason       text not null check (reason in ('spam','harassment','hate','sexual','spoiler','other')),
  details      text check (char_length(details) <= 1000),
  status       text not null default 'open' check (status in ('open','actioned','dismissed')),
  created_at   timestamptz not null default now()
);
create index content_reports_reporter_idx on public.content_reports (reporter_id);
create index content_reports_open_idx on public.content_reports (created_at) where status = 'open';

-- Limites de uso justo (consultas externas do scanner, criação de conteúdo, etc.)
create table private.quota_usage (
  user_id    uuid not null references auth.users(id) on delete cascade,
  quota_key  text not null,
  day        date not null,
  used       integer not null default 0,
  primary key (user_id, quota_key, day)
);

-- -------------------------------------------------------------------------------------
-- 4. Dados pessoais (Pro). Mesmas colunas das tabelas do SQLite do aparelho.
--    Toda referência entre tabelas pessoais é por chave COMPOSTA (id, user_id): FKs não
--    passam por RLS, então sem isso um usuário poderia apontar para a linha de outro.
-- -------------------------------------------------------------------------------------

create table personal.user_books (
  id                    uuid primary key,
  user_id               uuid not null references auth.users(id) on delete cascade,
  edition_id            uuid references catalog.editions(id) on delete set null,
  title                 text not null check (char_length(title) between 1 and 500),
  author_display        text not null check (char_length(author_display) between 1 and 500),
  format                text not null check (format in ('epub','pdf','physical')),
  status                text not null check (status in ('want_to_read','reading','finished','abandoned')),
  content_sha256        text check (content_sha256 ~ '^[0-9a-f]{64}$'),
  file_bytes            bigint check (file_bytes >= 0),
  storage_object_path   text,                         -- e-book na nuvem (Pro, opcional, cota 2 GB)
  ref_pages_total       integer check (ref_pages_total > 0),
  ref_page_version      smallint,
  chapters_total        integer check (chapters_total > 0),
  cover_ref             text,
  rating                smallint check (rating between 1 and 5),
  added_at              timestamptz not null,
  started_at            timestamptz,
  finished_at           timestamptz,
  last_opened_at        timestamptz,
  created_at            timestamptz not null,
  updated_at            timestamptz not null,
  deleted_at            timestamptz,
  version_hlc           text not null,
  unique (id, user_id)
);
create index user_books_user_idx on personal.user_books (user_id, updated_at);
create unique index user_books_user_sha_uq on personal.user_books (user_id, content_sha256)
  where content_sha256 is not null and deleted_at is null;
create index user_books_edition_idx on personal.user_books (edition_id);

-- id = user_book_id (1 posição por livro)
create table personal.reading_positions (
  id            uuid primary key,
  user_id       uuid not null references auth.users(id) on delete cascade,
  locator       jsonb not null check (jsonb_typeof(locator) = 'object'),   -- Anexo 03 §5
  ref_page      integer not null check (ref_page > 0),
  chapter_index integer not null check (chapter_index >= 0),
  progression   numeric(6,5) not null check (progression between 0 and 1),
  device_id     text,
  created_at    timestamptz not null,
  updated_at    timestamptz not null,
  deleted_at    timestamptz,
  version_hlc   text not null,
  foreign key (id, user_id) references personal.user_books (id, user_id) on delete cascade
);
create index reading_positions_user_idx on personal.reading_positions (user_id, updated_at);

-- Particionada por mês. SEM partição default: sessão fora das partições existentes é
-- recusada pela RPC (que valida o intervalo antes). Partições: histórica 2024–2025 + mensais
-- a partir de 2026-01, sempre com 3 meses de folga (private.ensure_session_partitions).
create table personal.reading_sessions (
  id              uuid not null,
  user_id         uuid not null references auth.users(id) on delete cascade,
  user_book_id    uuid not null,
  started_at      timestamptz not null,
  ended_at        timestamptz not null,
  active_seconds  integer not null check (active_seconds between 0 and 86400),
  ref_page_from   integer,
  ref_page_to     integer,
  pages_viewed    integer check (pages_viewed >= 0),
  source          text not null check (source in ('auto','timer','manual')),
  device_id       text,
  created_at      timestamptz not null,
  updated_at      timestamptz not null,
  deleted_at      timestamptz,
  version_hlc     text not null,
  primary key (id, started_at),
  check (ended_at >= started_at),
  foreign key (user_book_id, user_id) references personal.user_books (id, user_id) on delete cascade
) partition by range (started_at);
create index reading_sessions_user_idx on personal.reading_sessions (user_id, started_at desc);
create index reading_sessions_id_idx on personal.reading_sessions (id);
create index reading_sessions_book_idx on personal.reading_sessions (user_book_id, user_id);
create table personal.reading_sessions_hist partition of personal.reading_sessions
  for values from ('2024-01-01') to ('2026-01-01');

create table personal.bookmarks (
  id             uuid primary key,
  user_id        uuid not null references auth.users(id) on delete cascade,
  user_book_id   uuid not null,
  locator        jsonb not null check (jsonb_typeof(locator) = 'object'),
  ref_page       integer not null check (ref_page > 0),
  chapter_index  integer not null check (chapter_index >= 0),
  excerpt        text check (char_length(excerpt) <= 280),
  created_at     timestamptz not null,
  updated_at     timestamptz not null,
  deleted_at     timestamptz,
  version_hlc    text not null,
  foreign key (user_book_id, user_id) references personal.user_books (id, user_id) on delete cascade
);
create index bookmarks_user_idx on personal.bookmarks (user_id, updated_at);
create index bookmarks_book_idx on personal.bookmarks (user_book_id, user_id, ref_page) where deleted_at is null;

-- Camadas de tinta: traços sobre o texto (ancorados em palavras) ou dentro de um espaço aberto
create table personal.ink_layers (
  id             uuid primary key,
  user_id        uuid not null references auth.users(id) on delete cascade,
  user_book_id   uuid not null,
  kind           text not null check (kind in ('over_text','space')),
  anchor         jsonb not null check (jsonb_typeof(anchor) = 'object'),
  space_lines    smallint check (space_lines between 1 and 12),          -- D-41
  collapsed      boolean not null default false,
  strokes_b64    text not null,                       -- codec BNK1 em base64 (Anexo 03 §9.6)
  stroke_count   integer not null check (stroke_count >= 0),
  codec_version  smallint not null default 1,
  created_at     timestamptz not null,
  updated_at     timestamptz not null,
  deleted_at     timestamptz,
  version_hlc    text not null,
  unique (id, user_id),
  foreign key (user_book_id, user_id) references personal.user_books (id, user_id) on delete cascade,
  check ((kind = 'space') = (space_lines is not null)),
  check (octet_length(strokes_b64) <= 349528)          -- ≈ 256 KiB binários
);
create index ink_layers_user_idx on personal.ink_layers (user_id, updated_at);
create index ink_layers_book_idx on personal.ink_layers (user_book_id, user_id) where deleted_at is null;

-- Grifos, notas, notas à mão e desenhos (cada item conta 1 no "Tudo 12" da tela 25)
create table personal.annotations (
  id                   uuid primary key,
  user_id              uuid not null references auth.users(id) on delete cascade,
  user_book_id         uuid not null,
  kind                 text not null check (kind in ('highlight','note','handwriting','drawing')),
  parent_id            uuid,
  group_id             uuid not null,                  -- um cartão da tela 25 = um grupo
  source               text not null default 'selection' check (source in ('selection','ink')),
  anchor               jsonb not null check (jsonb_typeof(anchor) = 'object'),
  ref_page             integer not null check (ref_page > 0),
  chapter_index        integer not null check (chapter_index >= 0),
  color                text check (color ~ '^#[0-9A-F]{6}$'),
  style                text check (style in ('fill','underline','wavy')),
  fill_height          text check (fill_height in ('low','medium','high')),
  note_text            text check (char_length(note_text) <= 10000),
  ink_layer_id         uuid,
  shared_club_post_id  uuid references public.club_posts(id) on delete set null,
  created_at           timestamptz not null,
  updated_at           timestamptz not null,
  deleted_at           timestamptz,
  version_hlc          text not null,
  unique (id, user_id),
  foreign key (user_book_id, user_id) references personal.user_books (id, user_id) on delete cascade,
  foreign key (parent_id, user_id) references personal.annotations (id, user_id) on delete cascade,
  foreign key (ink_layer_id, user_id) references personal.ink_layers (id, user_id) on delete cascade,
  check ((kind = 'note') = (note_text is not null)),
  check (kind not in ('handwriting','drawing') or ink_layer_id is not null),
  check (kind <> 'highlight' or (color is not null and style is not null))
);
create index annotations_user_idx on personal.annotations (user_id, updated_at);
create index annotations_book_page_idx on personal.annotations (user_book_id, user_id, ref_page) where deleted_at is null;
create index annotations_parent_idx on personal.annotations (parent_id, user_id);
create index annotations_ink_idx on personal.annotations (ink_layer_id, user_id);
create index annotations_shared_idx on personal.annotations (shared_club_post_id);

-- Rótulos das cores do marca-texto ("lindo", "personagem", "ideia", "pro clube")
create table personal.highlight_labels (
  id           uuid primary key,
  user_id      uuid not null references auth.users(id) on delete cascade,
  color        text not null check (color ~ '^#[0-9A-F]{6}$'),
  label        text not null check (char_length(label) between 1 and 24),
  sort         smallint not null default 0,
  created_at   timestamptz not null,
  updated_at   timestamptz not null,
  deleted_at   timestamptz,
  version_hlc  text not null
);
create unique index highlight_labels_user_color_uq on personal.highlight_labels (user_id, color) where deleted_at is null;

-- 1 linha por usuário (id = user_id)
create table personal.reader_settings (
  id            uuid primary key references auth.users(id) on delete cascade,
  user_id       uuid not null references auth.users(id) on delete cascade,
  font_step     smallint not null default 4 check (font_step between 1 and 7),
  font_family   text not null default 'literata' check (font_family in ('literata','lora','figtree','atkinson')),
  paper         text not null default 'creme' check (paper in ('creme','branco','sepia','noite')),
  line_spacing  text not null default 'medio' check (line_spacing in ('justo','medio','solto')),
  margins       text not null default 'media' check (margins in ('estreita','media','larga')),
  created_at    timestamptz not null,
  updated_at    timestamptz not null,
  deleted_at    timestamptz,
  version_hlc   text not null,
  check (id = user_id)
);

create table personal.pen_presets (
  id                   uuid primary key references auth.users(id) on delete cascade,
  user_id              uuid not null references auth.users(id) on delete cascade,
  pen_tip              text not null default 'ballpoint' check (pen_tip in ('ballpoint','fountain','brush')),
  pen_width_mm         numeric(3,1) not null default 1.2 check (pen_width_mm between 0.3 and 4.0),  -- slider do arquivo
  pen_color            text not null default '#FF552E' check (pen_color ~ '^#[0-9A-F]{6}$'),
  favorite_colors      jsonb not null default '["#FF552E","#552CB7","#058CD7","#00995E","#F2A815","#1A1714"]',
  stroke_size          text not null default 'medium' check (stroke_size in ('thin','medium','thick')),
  highlighter_style    text not null default 'fill' check (highlighter_style in ('fill','underline','wavy')),
  highlighter_height   text not null default 'medium' check (highlighter_height in ('low','medium','high')),
  highlighter_color    text not null default '#FED170' check (highlighter_color ~ '^#[0-9A-F]{6}$'),
  created_at           timestamptz not null,
  updated_at           timestamptz not null,
  deleted_at           timestamptz,
  version_hlc          text not null,
  check (id = user_id),
  check (jsonb_typeof(favorite_colors) = 'array' and jsonb_array_length(favorite_colors) <= 12)
);

create table personal.reading_goals (
  id                  uuid primary key references auth.users(id) on delete cascade,
  user_id             uuid not null references auth.users(id) on delete cascade,
  daily_minutes       smallint not null default 30 check (daily_minutes between 5 and 600),
  badge_target_days   smallint not null default 7 check (badge_target_days between 1 and 365),
  created_at          timestamptz not null,
  updated_at          timestamptz not null,
  deleted_at          timestamptz,
  version_hlc         text not null,
  check (id = user_id)
);

-- -------------------------------------------------------------------------------------
-- 5. Funções auxiliares de RLS (security definer; índices nas colunas consultadas)
-- -------------------------------------------------------------------------------------

create or replace function private.is_club_member(p_club uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.club_members m
                 where m.club_id = p_club and m.user_id = (select auth.uid()))
$$;

create or replace function private.is_club_admin(p_club uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.club_members m
                 where m.club_id = p_club and m.user_id = (select auth.uid())
                   and m.role in ('owner','moderator'))
$$;

create or replace function private.is_blocked_between(p_a uuid, p_b uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.user_blocks b
                 where (b.blocker_id = p_a and b.blocked_id = p_b)
                    or (b.blocker_id = p_b and b.blocked_id = p_a))
$$;

-- Pode ver o conteúdo completo do perfil? (regra do Pro — monetização v3)
create or replace function private.can_view_profile_content(p_owner uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select
    p_owner = (select auth.uid())
    or (
      private.is_pro()
      and not private.is_blocked_between(p_owner, (select auth.uid()))
      and exists (
        select 1 from public.profiles p
        where p.id = p_owner
          and (p.visibility = 'public'
               or exists (select 1 from public.follows f
                          where f.follower_id = (select auth.uid()) and f.followee_id = p_owner
                            and f.status = 'accepted'))
      )
    )
$$;

-- -------------------------------------------------------------------------------------
-- 6. Regras de negócio no banco (triggers)
-- -------------------------------------------------------------------------------------

-- Grátis cria 1 clube; Pro cria ilimitados. O dono vira membro 'owner'.
create or replace function private.clubs_before_insert() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  -- serializa criações do mesmo dono (sem isso, 2 inserts simultâneos passariam do limite)
  perform pg_advisory_xact_lock(hashtextextended('clubs_owner:' || new.owner_id::text, 0));
  if not private.user_is_pro(new.owner_id)
     and exists (select 1 from public.clubs c where c.owner_id = new.owner_id) then
    raise exception 'free_club_limit' using errcode = 'P0001',
      hint = 'O plano Grátis cria 1 clube. Assine o Pro para criar mais.';
  end if;
  return new;
end $$;
create trigger clubs_before_insert before insert on public.clubs
  for each row execute function private.clubs_before_insert();

create or replace function private.clubs_after_insert() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.club_members (club_id, user_id, role) values (new.id, new.owner_id, 'owner');
  return new;
end $$;
create trigger clubs_after_insert after insert on public.clubs
  for each row execute function private.clubs_after_insert();

-- Seguir perfil fechado vira pedido pendente (o cliente não escolhe o status).
create or replace function private.follows_before_insert() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if private.is_blocked_between(new.follower_id, new.followee_id) then
    raise exception 'blocked' using errcode = 'P0001';
  end if;
  select case when p.visibility = 'private' then 'pending' else 'accepted' end
    into new.status from public.profiles p where p.id = new.followee_id;
  return new;
end $$;
create trigger follows_before_insert before insert on public.follows
  for each row execute function private.follows_before_insert();

create or replace function private.follows_counters() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' and new.status = 'accepted' then
    update public.profile_stats set followers_count = followers_count + 1 where user_id = new.followee_id;
    update public.profile_stats set following_count = following_count + 1 where user_id = new.follower_id;
  elsif tg_op = 'UPDATE' and old.status = 'pending' and new.status = 'accepted' then
    update public.profile_stats set followers_count = followers_count + 1 where user_id = new.followee_id;
    update public.profile_stats set following_count = following_count + 1 where user_id = new.follower_id;
  elsif tg_op = 'DELETE' and old.status = 'accepted' then
    update public.profile_stats set followers_count = greatest(followers_count - 1, 0) where user_id = old.followee_id;
    update public.profile_stats set following_count = greatest(following_count - 1, 0) where user_id = old.follower_id;
  end if;
  return null;
end $$;
create trigger follows_counters after insert or update or delete on public.follows
  for each row execute function private.follows_counters();

create or replace function private.club_replies_counter() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    update public.club_posts set replies_count = replies_count + 1 where id = new.post_id;
  elsif tg_op = 'DELETE' then
    update public.club_posts set replies_count = greatest(replies_count - 1, 0) where id = old.post_id;
  end if;
  return null;
end $$;
create trigger club_replies_counter after insert or delete on public.club_post_replies
  for each row execute function private.club_replies_counter();

-- A resposta herda o club_id do post (o cliente não pode apontar para outro clube).
create or replace function private.club_reply_set_club() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  select p.club_id into new.club_id from public.club_posts p where p.id = new.post_id;
  if new.club_id is null then raise exception 'post_not_found' using errcode = 'P0001'; end if;
  return new;
end $$;
create trigger club_reply_set_club before insert on public.club_post_replies
  for each row execute function private.club_reply_set_club();

-- Exclusão de conta: os clubes do dono passam para o membro mais antigo (moderador primeiro);
-- clube sem outros membros é apagado. Assim os posts dos outros membros não somem.
create or replace function private.profiles_before_delete() returns trigger
language plpgsql security definer set search_path = '' as $$
declare r record; v_heir uuid;
begin
  for r in select c.id from public.clubs c where c.owner_id = old.id loop
    select m.user_id into v_heir from public.club_members m
     where m.club_id = r.id and m.user_id <> old.id
     order by (m.role = 'moderator') desc, m.joined_at, m.user_id
     limit 1;
    if v_heir is null then
      delete from public.clubs where id = r.id;
    else
      update public.clubs set owner_id = v_heir where id = r.id;
      update public.club_members set role = 'owner' where club_id = r.id and user_id = v_heir;
    end if;
  end loop;
  -- posts do clube viram "apagados" (conteúdo removido — LGPD), mantendo as respostas dos outros
  update public.club_posts
     set body = null, quote_text = null, quote_color = null, deleted_at = coalesce(deleted_at, now())
   where author_id = old.id;
  return old;
end $$;
create trigger profiles_before_delete before delete on public.profiles
  for each row execute function private.profiles_before_delete();

-- Contadores de curtidas, comentários e posts (o cliente não escreve contadores)
create or replace function private.post_counters() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_table_name = 'post_likes' then
    if tg_op = 'INSERT' then update public.posts set likes_count = likes_count + 1 where id = new.post_id;
    else update public.posts set likes_count = greatest(likes_count - 1, 0) where id = old.post_id; end if;
  elsif tg_table_name = 'post_comments' then
    if tg_op = 'INSERT' then update public.posts set comments_count = comments_count + 1 where id = new.post_id;
    else update public.posts set comments_count = greatest(comments_count - 1, 0) where id = old.post_id; end if;
  elsif tg_table_name = 'posts' then
    if tg_op = 'INSERT' then update public.profile_stats set posts_count = posts_count + 1 where user_id = new.author_id;
    else update public.profile_stats set posts_count = greatest(posts_count - 1, 0) where user_id = old.author_id; end if;
  end if;
  return null;
end $$;
create trigger post_likes_counter after insert or delete on public.post_likes
  for each row execute function private.post_counters();
create trigger post_comments_counter after insert or delete on public.post_comments
  for each row execute function private.post_counters();
create trigger posts_counter after insert or delete on public.posts
  for each row execute function private.post_counters();

-- Novo usuário do Auth → perfil + estatísticas zeradas
create or replace function private.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, handle, display_name)
  values (new.id,
          'leitor_' || right(replace(new.id::text, '-', ''), 12),   -- parte aleatória do uuid; o app pede o @ no onboarding
          coalesce(split_part(new.email, '@', 1), 'Leitor'));
  insert into public.profile_stats (user_id) values (new.id);
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function private.handle_new_user();

-- -------------------------------------------------------------------------------------
-- 7. RLS
-- -------------------------------------------------------------------------------------

alter table catalog.authors                  enable row level security;
alter table catalog.works                    enable row level security;
alter table catalog.work_authors             enable row level security;
alter table catalog.editions                 enable row level security;
alter table catalog.community_submissions    enable row level security;
alter table catalog.submission_confirmations enable row level security;
alter table billing.subscriptions            enable row level security;
alter table billing.entitlements             enable row level security;
alter table billing.webhook_events           enable row level security;
alter table billing.sync_access              enable row level security;
alter table private.account_lifecycle        enable row level security;
alter table private.email_outbox             enable row level security;
alter table private.quota_usage              enable row level security;
alter table public.profiles                  enable row level security;
alter table public.profile_stats             enable row level security;
alter table public.follows                   enable row level security;
alter table public.user_blocks               enable row level security;
alter table public.posts                     enable row level security;
alter table public.post_comments             enable row level security;
alter table public.post_likes                enable row level security;
alter table public.clubs                     enable row level security;
alter table public.club_members              enable row level security;
alter table public.club_invites              enable row level security;
alter table public.club_meetings             enable row level security;
alter table public.club_posts                enable row level security;
alter table public.club_post_replies         enable row level security;
alter table public.notifications             enable row level security;
alter table public.device_tokens             enable row level security;
alter table public.content_reports           enable row level security;
alter table personal.user_books              enable row level security;
alter table personal.reading_positions       enable row level security;
alter table personal.reading_sessions        enable row level security;
alter table personal.bookmarks               enable row level security;
alter table personal.ink_layers              enable row level security;
alter table personal.annotations             enable row level security;
alter table personal.highlight_labels        enable row level security;
alter table personal.reader_settings         enable row level security;
alter table personal.pen_presets             enable row level security;
alter table personal.reading_goals           enable row level security;
-- billing.*, private.*: sem políticas = só service_role (bypassrls) acessa.

-- Catálogo: leitura para todos os autenticados; escrita só service_role / Edge Functions.
create policy catalog_authors_read  on catalog.authors      for select to authenticated using (true);
create policy catalog_works_read    on catalog.works        for select to authenticated using (true);
create policy catalog_wa_read       on catalog.work_authors for select to authenticated using (true);
create policy catalog_editions_read on catalog.editions     for select to authenticated using (true);
create policy submissions_read on catalog.community_submissions for select to authenticated using (true);
create policy submissions_insert on catalog.community_submissions for insert to authenticated
  with check (submitted_by = (select auth.uid()) and status = 'pending' and confirmations = 0);
create policy confirmations_insert on catalog.submission_confirmations for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy confirmations_read on catalog.submission_confirmations for select to authenticated
  using (user_id = (select auth.uid()));

-- Perfis: o básico é público para autenticados (a "prévia" do Grátis); bloqueio esconde.
create policy profiles_read on public.profiles for select to authenticated
  using (not private.is_blocked_between(id, (select auth.uid())));
create policy profiles_update_own on public.profiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy profile_stats_read on public.profile_stats for select to authenticated
  using (not private.is_blocked_between(user_id, (select auth.uid())));
-- escrita dos números: só pela RPC public.publish_my_stats

create policy follows_read on public.follows for select to authenticated
  using (follower_id = (select auth.uid()) or followee_id = (select auth.uid())
         or private.can_view_profile_content(follower_id)      -- lista "seguindo" de alguém
         or private.can_view_profile_content(followee_id));    -- lista "seguidores" de alguém
create policy follows_insert on public.follows for insert to authenticated
  with check (follower_id = (select auth.uid()));
create policy follows_delete on public.follows for delete to authenticated
  using (follower_id = (select auth.uid()) or followee_id = (select auth.uid()));
create policy follows_accept on public.follows for update to authenticated
  using (followee_id = (select auth.uid())) with check (followee_id = (select auth.uid()));

create policy blocks_own on public.user_blocks for all to authenticated
  using (blocker_id = (select auth.uid())) with check (blocker_id = (select auth.uid()));

-- Posts do perfil: dono sempre; os outros só Pro (e respeitando perfil fechado/bloqueio).
create policy posts_read on public.posts for select to authenticated
  using (deleted_at is null and private.can_view_profile_content(author_id));
create policy posts_insert on public.posts for insert to authenticated
  with check (author_id = (select auth.uid()));
create policy posts_update_own on public.posts for update to authenticated
  using (author_id = (select auth.uid())) with check (author_id = (select auth.uid()));

-- Comentários e curtidas nas resenhas: monetização v3 → todos podem comentar/curtir nas
-- PRÓPRIAS resenhas; ler resenhas alheias exige Pro (herda posts_read via EXISTS).
create policy post_comments_read on public.post_comments for select to authenticated
  using (deleted_at is null and exists (select 1 from public.posts p where p.id = post_id));
create policy post_comments_insert on public.post_comments for insert to authenticated
  with check (author_id = (select auth.uid()) and exists (select 1 from public.posts p where p.id = post_id));
create policy post_comments_delete_own on public.post_comments for update to authenticated
  using (author_id = (select auth.uid())) with check (author_id = (select auth.uid()));
create policy post_likes_read on public.post_likes for select to authenticated
  using (exists (select 1 from public.posts p where p.id = post_id));
create policy post_likes_write on public.post_likes for insert to authenticated
  with check (user_id = (select auth.uid()) and exists (select 1 from public.posts p where p.id = post_id));
create policy post_likes_delete on public.post_likes for delete to authenticated
  using (user_id = (select auth.uid()));

-- Clubes: membros veem tudo do clube; clubes públicos aparecem para todos.
create policy clubs_read on public.clubs for select to authenticated
  using (privacy = 'public' or private.is_club_member(id));
create policy clubs_insert on public.clubs for insert to authenticated
  with check (owner_id = (select auth.uid()));
create policy clubs_update_admin on public.clubs for update to authenticated
  using (private.is_club_admin(id)) with check (private.is_club_admin(id));

create policy club_members_read on public.club_members for select to authenticated
  using (private.is_club_member(club_id));
create policy club_members_update_self on public.club_members for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy club_members_leave on public.club_members for delete to authenticated
  using ((user_id = (select auth.uid()) and role <> 'owner')            -- dono não "sai": transfere
         or (private.is_club_admin(club_id) and role <> 'owner'));        -- moderador não remove o dono
-- entrar no clube: só pela RPC public.join_club(code) (valida convite)

create policy club_invites_admin on public.club_invites for all to authenticated
  using (private.is_club_admin(club_id)) with check (private.is_club_admin(club_id) and created_by = (select auth.uid()));

create policy club_meetings_read on public.club_meetings for select to authenticated
  using (private.is_club_member(club_id));
create policy club_meetings_admin on public.club_meetings for insert to authenticated
  with check (private.is_club_admin(club_id) and created_by = (select auth.uid()));

create policy club_posts_read on public.club_posts for select to authenticated
  using (deleted_at is null and private.is_club_member(club_id));
create policy club_posts_insert on public.club_posts for insert to authenticated
  with check (author_id = (select auth.uid()) and private.is_club_member(club_id));
create policy club_posts_update_own on public.club_posts for update to authenticated
  using (author_id = (select auth.uid())) with check (author_id = (select auth.uid()));

create policy club_replies_read on public.club_post_replies for select to authenticated
  using (deleted_at is null and private.is_club_member(club_id));
create policy club_replies_insert on public.club_post_replies for insert to authenticated
  with check (author_id = (select auth.uid()));
-- (o trigger club_reply_set_club define club_id a partir do post; a checagem de membro
--  acontece no WITH CHECK abaixo, avaliado DEPOIS dos triggers BEFORE)
create policy club_replies_insert_member on public.club_post_replies as restrictive for insert to authenticated
  with check (private.is_club_member(club_id));

create policy notifications_own on public.notifications for select to authenticated
  using (user_id = (select auth.uid()));
create policy notifications_mark_read on public.notifications for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy device_tokens_own on public.device_tokens for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy reports_insert on public.content_reports for insert to authenticated
  with check (reporter_id = (select auth.uid()));

-- Dados pessoais: o dono LÊ (defesa em profundidade; o caminho normal é o PowerSync).
-- ESCRITA direta proibida: só pela RPC public.sync_apply_changes (LWW + exige Pro).
create policy own_read on personal.user_books        for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.reading_positions for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.reading_sessions  for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.bookmarks         for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.ink_layers        for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.annotations       for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.highlight_labels  for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.reader_settings   for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.pen_presets       for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.reading_goals     for select to authenticated using (user_id = (select auth.uid()));

-- Storage: e-books do Pro em bucket PRIVADO "ebooks", caminho "<user_id>/<user_book_id>/<sha256>.<ext>"
create policy ebooks_owner_read on storage.objects for select to authenticated
  using (bucket_id = 'ebooks' and (storage.foldername(name))[1] = (select auth.uid())::text);
-- SEM política de INSERT: o upload só acontece por URL assinada emitida pela Edge Function
-- `ebook-upload-url`, que confere o Pro e a cota de 2 GB antes (upload direto burlaria a cota).
create policy ebooks_owner_delete on storage.objects for delete to authenticated
  using (bucket_id = 'ebooks' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- -------------------------------------------------------------------------------------
-- 8. RPCs expostas
-- -------------------------------------------------------------------------------------

-- 8.1 Sincronização (upload do PowerSync). Lote ≤ 500 operações.
--     Operação: {"table","op":"PUT"|"PATCH"|"DELETE","id","data":{...},"hlc"}
--     * last-writer-wins por linha com version_hlc (comparação byte a byte, COLLATE "C");
--     * dono, id e versão impostos pelo servidor; HLC no futuro (> agora + 5 min) é recusado;
--     * colunas jsonb que chegam como TEXTO (assim o SQLite/PowerSync manda) são convertidas;
--     * cada operação roda no próprio bloco (savepoint): uma linha inválida NÃO trava o lote —
--       volta em "rejected" com o motivo, e o app tira da fila e registra (Anexo 02 §6.1).
create or replace function public.sync_apply_changes(p_changes jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_uid       uuid := (select auth.uid());
  v_op        jsonb;
  v_table     text;
  v_kind      text;
  v_id        uuid;
  v_hlc       text;
  v_data      jsonb;
  v_existing  jsonb;
  v_cols      text;
  v_set       text;
  v_conflict  text;
  v_rows      integer;
  v_col       text;
  v_applied   integer := 0;
  v_skipped   integer := 0;
  v_rejected  jsonb := '[]'::jsonb;
  v_max_ms    bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint + 300000;
begin
  if v_uid is null then
    raise exception 'unauthenticated' using errcode = '28000';
  end if;
  if not private.can_sync(v_uid) then
    raise exception 'pro_required' using errcode = 'P0001';
  end if;
  if jsonb_typeof(p_changes) <> 'array' or jsonb_array_length(p_changes) > 500 then
    raise exception 'invalid_batch' using errcode = '22023';
  end if;

  for v_op in select value from jsonb_array_elements(p_changes) loop
    begin
      v_table := v_op ->> 'table';
      v_kind  := v_op ->> 'op';
      v_hlc   := v_op ->> 'hlc';
      if v_table is null or v_table not in ('user_books','reading_positions','reading_sessions','bookmarks','ink_layers',
                         'annotations','highlight_labels','reader_settings','pen_presets','reading_goals') then
        raise exception 'table_not_allowed: %', v_table using errcode = '22023';
      end if;
      if v_kind is null or v_kind not in ('PUT','PATCH','DELETE') then
        raise exception 'invalid_op' using errcode = '22023';
      end if;
      v_id := (v_op ->> 'id')::uuid;
      if v_id is null or v_hlc is null
         or v_hlc !~ '^[0-9]{16}-[0-9]{4}-[A-Za-z0-9_-]{1,64}$'
         or left(v_hlc, 16)::bigint > v_max_ms then
        raise exception 'invalid_hlc' using errcode = '22023';
      end if;

      v_conflict := case when v_table = 'reading_sessions' then 'id, started_at' else 'id' end;

      if v_kind = 'DELETE' then
        execute format(
          'update personal.%1$I set deleted_at = now(), updated_at = now(), version_hlc = $1
             where id = $2 and user_id = $3 and version_hlc collate "C" < $1 collate "C"', v_table)
          using v_hlc, v_id, v_uid;
        get diagnostics v_rows = row_count;
      else
        v_data := coalesce(v_op -> 'data', '{}'::jsonb);
        if jsonb_typeof(v_data) <> 'object' then
          raise exception 'invalid_data' using errcode = '22023';
        end if;

        -- jsonb enviado como texto pelo SQLite → objeto/array de verdade
        for v_col in
          select a.attname from pg_catalog.pg_attribute a
           where a.attrelid = format('personal.%I', v_table)::regclass
             and a.attnum > 0 and not a.attisdropped
             and a.atttypid = 'jsonb'::regtype
        loop
          if jsonb_typeof(v_data -> v_col) = 'string' then
            v_data := jsonb_set(v_data, array[v_col], (v_data ->> v_col)::jsonb);
          end if;
        end loop;

        execute format('select to_jsonb(t) from personal.%1$I t where t.id = $1 limit 1', v_table)
          into v_existing using v_id;
        if v_existing is not null and (v_existing ->> 'user_id')::uuid <> v_uid then
          raise exception 'id_conflict' using errcode = '22023';   -- id de outra pessoa
        end if;

        if v_kind = 'PATCH' then
          if v_existing is null then
            raise exception 'patch_missing_row' using errcode = '22023';
          end if;
          v_data := v_existing || v_data;
        end if;

        if v_table = 'reading_sessions' then
          -- chave de partição imutável e dentro das partições existentes
          if v_existing is not null
             and (v_data ->> 'started_at')::timestamptz <> (v_existing ->> 'started_at')::timestamptz then
            raise exception 'started_at_immutable' using errcode = '22023';
          end if;
          if (v_data ->> 'started_at')::timestamptz < '2024-01-01'::timestamptz
             or (v_data ->> 'started_at')::timestamptz > now() + interval '1 day' then
            raise exception 'started_at_out_of_range' using errcode = '22023';
          end if;
          perform private.ensure_session_partition_for((v_data ->> 'started_at')::timestamptz);
        end if;

        v_data := v_data || jsonb_build_object('id', v_id, 'user_id', v_uid, 'version_hlc', v_hlc);

        select string_agg(quote_ident(a.attname), ', ' order by a.attnum),
               string_agg(format('%1$I = excluded.%1$I', a.attname), ', ' order by a.attnum)
                 filter (where a.attname not in ('id','user_id','created_at','started_at'))
          into v_cols, v_set
          from pg_catalog.pg_attribute a
         where a.attrelid = format('personal.%I', v_table)::regclass
           and a.attnum > 0 and not a.attisdropped
           and v_data ? a.attname;        -- só colunas enviadas: as ausentes ficam com o DEFAULT

        execute format(
          'insert into personal.%1$I as t (%2$s)
             select %2$s from jsonb_populate_record(null::personal.%1$I, $1)
           on conflict (%3$s) do update set %4$s
             where t.user_id = $2 and t.version_hlc collate "C" < excluded.version_hlc collate "C"',
          v_table, v_cols, v_conflict, v_set)
          using v_data, v_uid;
        get diagnostics v_rows = row_count;
      end if;

      if v_rows > 0 then v_applied := v_applied + 1; else v_skipped := v_skipped + 1; end if;
    exception when others then
      -- Erros TRANSITÓRIOS não podem virar recusa (o app tiraria a operação da fila e o dado
      -- se perderia): conflito de serialização/deadlock (40xxx), falta de recurso (53xxx),
      -- trava indisponível (55P03), cancelamento/desligamento (57xxx) → o lote inteiro falha e
      -- o app tenta de novo com recuo exponencial.
      if left(sqlstate, 2) in ('40', '53', '57') or sqlstate = '55P03' then
        raise;
      end if;
      v_rejected := v_rejected || jsonb_build_object(
        'table', v_op ->> 'table', 'id', v_op ->> 'id', 'error', sqlerrm, 'code', sqlstate,
        'retryable', false);
    end;
  end loop;

  return jsonb_build_object('applied', v_applied, 'skipped', v_skipped, 'rejected', v_rejected);
end $$;

-- 8.2 Estado do Pro para o app (o app confia no RevenueCat para UX; o servidor confia nisto)
create or replace function public.my_entitlement() returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'pro', coalesce(bool_or(e.active_until > now()), false),
    'active_until', max(e.active_until))
  from billing.entitlements e
  where e.user_id = (select auth.uid()) and e.entitlement = 'pro'
$$;

-- 8.3 Prévia de perfil para o Grátis: NÃO devolve o texto das resenhas (só tamanho e data),
--     para o "desfocado" não poder ser revertido no aparelho.
create or replace function public.profile_preview(p_handle text) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', p.id, 'handle', p.handle, 'display_name', p.display_name,
    'avatar_path', p.avatar_path, 'visibility', p.visibility,
    'stats', to_jsonb(s) - 'user_id',
    'recent_posts', case when p.visibility = 'public' or p.id = (select auth.uid())
                           or exists (select 1 from public.follows f
                                       where f.follower_id = (select auth.uid()) and f.followee_id = p.id
                                         and f.status = 'accepted')
      then coalesce((
       select jsonb_agg(jsonb_build_object('id', x.id, 'kind', x.kind,
                                           'chars', char_length(coalesce(x.body, x.quote_text, '')),
                                           'created_at', x.created_at) order by x.created_at desc)
       from (select * from public.posts po
             where po.author_id = p.id and po.deleted_at is null
             order by po.created_at desc limit 3) x), '[]'::jsonb)
      else '[]'::jsonb end)
  from public.profiles p
  join public.profile_stats s on s.user_id = p.id
  where p.handle = lower(p_handle)
    and not private.is_blocked_between(p.id, (select auth.uid()))
$$;

-- 8.3b Busca no catálogo referenciado (trigramas, sem acento). O catálogo completo é
--      buscado pelo Worker (Anexo 02 §7); esta RPC cobre títulos já referenciados.
create or replace function public.search_editions(p_query text, p_limit integer default 20)
returns setof catalog.editions
language sql stable security invoker set search_path = '' as $$
  select e.* from catalog.editions e
   where private.f_unaccent(lower(e.title)) operator(extensions.%) private.f_unaccent(lower(p_query))
   order by extensions.similarity(private.f_unaccent(lower(e.title)), private.f_unaccent(lower(p_query))) desc,
            e.id
   limit least(greatest(p_limit, 1), 50)
$$;

-- 8.4 Publicar os números do perfil (o aparelho calcula; limite de 1 vez por minuto)
create or replace function public.publish_my_stats(
  p_books_read_total integer, p_books_read_year integer, p_reading_now integer, p_streak_days integer)
returns void language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid());
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if least(p_books_read_total, p_books_read_year, p_reading_now, p_streak_days) < 0
     or p_books_read_year > p_books_read_total or p_streak_days > 36600 then
    raise exception 'invalid_stats' using errcode = '22023';
  end if;
  update public.profile_stats
     set books_read_total = p_books_read_total, books_read_year = p_books_read_year,
         reading_now = p_reading_now, streak_days = p_streak_days, updated_at = now()
   where user_id = v_uid and updated_at < now() - interval '1 minute';
end $$;

-- 8.5 Uso justo (chamada pelas Edge Functions com service_role)
create or replace function private.consume_quota(p_user uuid, p_key text, p_limit integer)
returns boolean language plpgsql security definer set search_path = '' as $$
declare v_used integer;
begin
  insert into private.quota_usage as q (user_id, quota_key, day, used)
  values (p_user, p_key, (now() at time zone 'America/Sao_Paulo')::date, 1)
  on conflict (user_id, quota_key, day) do update set used = q.used + 1
    where q.used < p_limit
  returning used into v_used;
  return v_used is not null;
end $$;

-- 8.6 Entrar num clube por convite
create or replace function public.join_club(p_code text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_club uuid; v_uid uuid := (select auth.uid());
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  update public.club_invites set uses = uses + 1
   where code = p_code and expires_at > now() and uses < max_uses
  returning club_id into v_club;
  if v_club is null then raise exception 'invalid_invite' using errcode = 'P0001'; end if;
  insert into public.club_members (club_id, user_id) values (v_club, v_uid)
  on conflict do nothing;
  return v_club;
end $$;

-- 8.7 Entrar num clube PÚBLICO (sem convite) — "participar de todos" do plano Grátis
create or replace function public.join_public_club(p_club uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid());
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not exists (select 1 from public.clubs c where c.id = p_club and c.privacy = 'public') then
    raise exception 'club_not_public' using errcode = 'P0001';
  end if;
  insert into public.club_members (club_id, user_id) values (p_club, v_uid) on conflict do nothing;
end $$;

-- -------------------------------------------------------------------------------------
-- 9. Rotinas agendadas (pg_cron no Supabase — ver Anexo 02 §8)
-- -------------------------------------------------------------------------------------

-- Partição de um mês (criada sob demanda pela RPC de sync — nunca falta partição mesmo se o
-- pg_cron parar)
create or replace function private.ensure_session_partition_for(p_ts timestamptz)
returns void language plpgsql security definer set search_path = '' as $$
declare v_start date := date_trunc('month', p_ts)::date; v_name text;
begin
  if v_start < date '2026-01-01' then return; end if;            -- 2024–2025: partição histórica
  v_name := format('reading_sessions_%s', to_char(v_start, 'YYYY_MM'));
  if to_regclass(format('personal.%I', v_name)) is null then
    perform pg_advisory_xact_lock(hashtextextended('sessions_partition:' || v_name, 0));
    if to_regclass(format('personal.%I', v_name)) is null then
      execute format('create table personal.%I partition of personal.reading_sessions
                        for values from (%L) to (%L)',
                     v_name, v_start, (v_start + interval '1 month')::date);
    end if;
  end if;
end $$;

-- Partições mensais das sessões (de 2026-01 até N meses à frente; idempotente)
create or replace function private.ensure_session_partitions(p_months_ahead integer default 3)
returns void language plpgsql security definer set search_path = '' as $$
declare v_start date := date '2026-01-01'; v_end date; v_name text;
begin
  v_end := (date_trunc('month', now()) + make_interval(months => p_months_ahead))::date;
  while v_start <= v_end loop
    v_name := format('reading_sessions_%s', to_char(v_start, 'YYYY_MM'));
    if to_regclass(format('personal.%I', v_name)) is null then
      execute format('create table personal.%I partition of personal.reading_sessions
                        for values from (%L) to (%L)',
                     v_name, v_start, (v_start + interval '1 month')::date);
    end if;
    v_start := (v_start + interval '1 month')::date;
  end loop;
end $$;
select private.ensure_session_partitions(3);

-- Retenção de 12 meses após o fim do Pro. Garantia: o aviso sai ≥ 30 dias ANTES do purge,
-- mesmo que a rotina tenha ficado parada (o purge espera warning_sent_at + 30 dias).
create or replace function private.run_retention() returns void
language plpgsql security definer set search_path = '' as $$
begin
  -- 1. quem perdeu o Pro entra no ciclo
  insert into private.account_lifecycle (user_id, pro_ended_at, purge_after)
  select e.user_id, e.active_until, e.active_until + interval '12 months'
    from billing.entitlements e
   where e.entitlement = 'pro' and e.active_until <= now()
  on conflict (user_id) do update
     set pro_ended_at = excluded.pro_ended_at, purge_after = excluded.purge_after,
         warning_sent_at = null, purged_at = null
   where private.account_lifecycle.pro_ended_at is distinct from excluded.pro_ended_at;

  -- 2. quem voltou a ser Pro sai do ciclo
  delete from private.account_lifecycle l where private.user_is_pro(l.user_id);

  -- 3. aviso (30 dias antes do purge previsto)
  insert into private.email_outbox (user_id, template, payload)
  select l.user_id, 'retention_warning',
         jsonb_build_object('purge_after', greatest(l.purge_after, now() + interval '30 days'))
    from private.account_lifecycle l
   where l.purged_at is null and l.warning_sent_at is null
     and l.purge_after <= now() + interval '30 days';
  update private.account_lifecycle set warning_sent_at = now()
   where purged_at is null and warning_sent_at is null and purge_after <= now() + interval '30 days';

  -- 4. purge: vencido E avisado há ≥ 30 dias. user_books leva junto (ON DELETE CASCADE)
  --    posições, sessões, marcadores, camadas de tinta e anotações. Storage: a Edge Function
  --    `purge-storage` lê os e-mails 'retention_purged' e apaga "ebooks/<user_id>/".
  create temporary table if not exists _due (user_id uuid primary key) on commit drop;
  delete from _due;
  insert into _due
  select user_id from private.account_lifecycle
   where purged_at is null and purge_after <= now()
     and warning_sent_at is not null and warning_sent_at <= now() - interval '30 days';

  delete from personal.user_books x       using _due d where x.user_id = d.user_id;
  delete from personal.highlight_labels x using _due d where x.user_id = d.user_id;
  delete from personal.reader_settings x  using _due d where x.user_id = d.user_id;
  delete from personal.pen_presets x      using _due d where x.user_id = d.user_id;
  delete from personal.reading_goals x    using _due d where x.user_id = d.user_id;

  insert into private.email_outbox (user_id, template) select user_id, 'retention_purged' from _due;
  update private.account_lifecycle l set purged_at = now() from _due d where l.user_id = d.user_id;
end $$;

-- -------------------------------------------------------------------------------------
-- 10. Permissões
--     ATENÇÃO: no Supabase, objetos criados em `public` recebem por padrão ALL para anon e
--     authenticated (e funções têm EXECUTE para PUBLIC). Sem os REVOKE abaixo, os GRANTs por
--     coluna não valem nada (ex.: membro mudando o próprio `role` para 'owner'). O stub local
--     reproduz esses padrões para os testes pegarem a regressão.
-- -------------------------------------------------------------------------------------

revoke all on all tables    in schema public from anon, authenticated;
revoke all on all functions in schema public from public, anon, authenticated;
alter default privileges in schema public revoke all on tables from anon, authenticated;
alter default privileges in schema public revoke execute on functions from public, anon, authenticated;

revoke all on schema billing from anon, authenticated;
revoke all on schema private from anon;
revoke all on all functions in schema private from public;
alter default privileges in schema private revoke execute on functions from public;

grant usage on schema public, catalog, personal to authenticated;
grant usage on schema private to authenticated;                     -- só para as funções de RLS/defaults
grant execute on function private.uuid_generate_v7(), private.is_pro(), private.user_is_pro(uuid), private.can_sync(uuid),
  private.is_club_member(uuid), private.is_club_admin(uuid), private.is_blocked_between(uuid, uuid),
  private.can_view_profile_content(uuid), private.f_unaccent(text) to authenticated;

grant select on all tables in schema catalog to authenticated;
grant insert (isbn13, title, authors, publisher, submitted_by) on catalog.community_submissions to authenticated;
grant insert (submission_id, user_id) on catalog.submission_confirmations to authenticated;
grant select on all tables in schema personal to authenticated;     -- RLS limita ao dono

-- leitura (as linhas visíveis são decididas pela RLS)
grant select on public.profiles, public.profile_stats, public.follows, public.user_blocks,
  public.posts, public.post_comments, public.post_likes, public.clubs, public.club_members,
  public.club_invites, public.club_meetings, public.club_posts, public.club_post_replies,
  public.notifications, public.device_tokens to authenticated;

-- escrita por COLUNA (contadores, status, papéis e datas de servidor ficam de fora)
grant update (handle, display_name, avatar_path, bio, visibility, timezone) on public.profiles to authenticated;
grant insert (follower_id, followee_id) on public.follows to authenticated;
grant update (status) on public.follows to authenticated;
grant delete on public.follows to authenticated;
grant insert (blocker_id, blocked_id) on public.user_blocks to authenticated;
grant delete on public.user_blocks to authenticated;
grant insert (author_id, kind, edition_id, work_id, rating, quote_text, body) on public.posts to authenticated;
grant update (rating, quote_text, body, edited_at, deleted_at) on public.posts to authenticated;
grant insert (post_id, author_id, body) on public.post_comments to authenticated;
grant update (deleted_at) on public.post_comments to authenticated;
grant insert (post_id, user_id) on public.post_likes to authenticated;
grant delete on public.post_likes to authenticated;
grant insert (owner_id, name, name_highlight, work_id, edition_id, privacy, goal_chapter, goal_chapter_label) on public.clubs to authenticated;
grant update (name, name_highlight, privacy, goal_chapter, goal_chapter_label) on public.clubs to authenticated;
grant update (progress_chapter, progress_ratio, progress_updated_at, last_read_post_at) on public.club_members to authenticated;
grant delete on public.club_members to authenticated;
grant insert (code, club_id, created_by, expires_at, max_uses) on public.club_invites to authenticated;
grant update (expires_at, max_uses) on public.club_invites to authenticated;
grant delete on public.club_invites to authenticated;
grant insert (club_id, starts_at, location, until_chapter, created_by) on public.club_meetings to authenticated;
grant insert (club_id, author_id, kind, chapter_index, ref_page, quote_text, quote_color, body) on public.club_posts to authenticated;
grant update (body, edited_at, deleted_at) on public.club_posts to authenticated;
grant insert (post_id, author_id, body) on public.club_post_replies to authenticated;
grant update (deleted_at) on public.club_post_replies to authenticated;
grant update (read_at) on public.notifications to authenticated;
grant insert (token, user_id, platform, app_version) on public.device_tokens to authenticated;
grant update (user_id, platform, app_version, updated_at) on public.device_tokens to authenticated;
grant delete on public.device_tokens to authenticated;
grant insert (reporter_id, target_type, target_id, reason, details) on public.content_reports to authenticated;

-- RPCs: só usuários autenticados (anon com a chave pública NÃO chama nada)
grant execute on function public.sync_apply_changes(jsonb), public.my_entitlement(),
  public.profile_preview(text), public.publish_my_stats(integer, integer, integer, integer),
  public.join_club(text), public.join_public_club(uuid), public.search_editions(text, integer)
  to authenticated;

grant usage on schema private, billing, personal, catalog to service_role;
grant all on all tables in schema private, billing, personal, catalog, public to service_role;
grant execute on all functions in schema private to service_role;
grant execute on all functions in schema public to service_role;

-- =====================================================================================
-- BookNest · migration 04 — social (todas as contas): perfis, seguidores, bloqueios, posts,
-- clubes, notificações, aparelhos, denúncias e uso justo. Origem: SQL §3, §5, §6, §7 (parte
-- social) e §8.3–8.7. Regras de negócio em gatilhos; RLS com funções security definer.
-- =====================================================================================

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

-- índices das chaves estrangeiras que o rascunho não tinha (advisor "unindexed foreign keys")
create index posts_edition_idx on public.posts (edition_id);
create index clubs_work_idx on public.clubs (work_id);
create index clubs_edition_idx on public.clubs (edition_id);

-- RLS ligada em todas as tabelas -----------------------------------------------------------
alter table public.profiles          enable row level security;
alter table public.profile_stats     enable row level security;
alter table public.follows           enable row level security;
alter table public.user_blocks       enable row level security;
alter table public.posts             enable row level security;
alter table public.post_comments     enable row level security;
alter table public.post_likes        enable row level security;
alter table public.clubs             enable row level security;
alter table public.club_members      enable row level security;
alter table public.club_invites      enable row level security;
alter table public.club_meetings     enable row level security;
alter table public.club_posts        enable row level security;
alter table public.club_post_replies enable row level security;
alter table public.notifications     enable row level security;
alter table public.device_tokens     enable row level security;
alter table public.content_reports   enable row level security;
alter table private.quota_usage      enable row level security;   -- sem política: só service_role

-- -------------------------------------------------------------------------------------
-- Funções auxiliares de RLS (security definer; índices nas colunas consultadas)
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
-- Regras de negócio no banco (gatilhos)
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

-- Contador de respostas = respostas NÃO apagadas (apagar é deleted_at; o DELETE de verdade só
-- acontece em cascata). (G04: antes, apagar uma resposta não baixava o contador.)
create or replace function private.club_replies_counter() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_delta integer;
begin
  v_delta := (case when tg_op <> 'DELETE' and new.deleted_at is null then 1 else 0 end)
           - (case when tg_op <> 'INSERT' and old.deleted_at is null then 1 else 0 end);
  if v_delta <> 0 then
    update public.club_posts set replies_count = greatest(replies_count + v_delta, 0)
     where id = coalesce(new.post_id, old.post_id);
  end if;
  return null;
end $$;
create trigger club_replies_counter after insert or delete or update of deleted_at on public.club_post_replies
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

-- Contadores de curtidas, comentários e posts (o cliente não escreve contadores). Comentários e
-- posts contam só os NÃO apagados (deleted_at) — G04: antes, apagar não baixava os contadores.
create or replace function private.post_counters() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_delta integer;
begin
  if tg_table_name = 'post_likes' then
    if tg_op = 'INSERT' then update public.posts set likes_count = likes_count + 1 where id = new.post_id;
    else update public.posts set likes_count = greatest(likes_count - 1, 0) where id = old.post_id; end if;
    return null;
  end if;
  v_delta := (case when tg_op <> 'DELETE' and new.deleted_at is null then 1 else 0 end)
           - (case when tg_op <> 'INSERT' and old.deleted_at is null then 1 else 0 end);
  if v_delta = 0 then return null; end if;
  if tg_table_name = 'post_comments' then
    update public.posts set comments_count = greatest(comments_count + v_delta, 0)
     where id = coalesce(new.post_id, old.post_id);
  else
    update public.profile_stats set posts_count = greatest(posts_count + v_delta, 0)
     where user_id = coalesce(new.author_id, old.author_id);
  end if;
  return null;
end $$;
create trigger post_likes_counter after insert or delete on public.post_likes
  for each row execute function private.post_counters();
create trigger post_comments_counter after insert or delete or update of deleted_at on public.post_comments
  for each row execute function private.post_counters();
create trigger posts_counter after insert or delete or update of deleted_at on public.posts
  for each row execute function private.post_counters();

-- Novo usuário do Auth → perfil + estatísticas zeradas
create or replace function private.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, handle, display_name)
  values (new.id,
          'leitor_' || right(replace(new.id::text, '-', ''), 12),   -- parte aleatória do uuid; o app pede o @ no onboarding
          -- nome provisório = parte local do e-mail, cortada em 60 (CHECK do display_name); sem
          -- e-mail (telefone, Apple sem e-mail) ou vazio → "Leitor". Antes da G04 um e-mail com mais
          -- de 60 caracteres antes do @ derrubava o cadastro.
          coalesce(nullif(left(split_part(coalesce(new.email, ''), '@', 1), 60), ''), 'Leitor'));
  insert into public.profile_stats (user_id) values (new.id);
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function private.handle_new_user();

-- -------------------------------------------------------------------------------------
-- Políticas
-- -------------------------------------------------------------------------------------

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
-- (G04) o autor continua vendo o próprio post apagado: o Postgres confere a política de SELECT
-- também na linha NOVA de um UPDATE com WHERE — sem isso o "apagar" (deleted_at) do próprio post
-- falhava com "new row violates row-level security policy".
create policy posts_read on public.posts for select to authenticated
  using (author_id = (select auth.uid())
         or (deleted_at is null and private.can_view_profile_content(author_id)));
create policy posts_insert on public.posts for insert to authenticated
  with check (author_id = (select auth.uid()));
create policy posts_update_own on public.posts for update to authenticated
  using (author_id = (select auth.uid())) with check (author_id = (select auth.uid()));

-- Comentários e curtidas nas resenhas: monetização v3 → todos podem comentar/curtir nas
-- PRÓPRIAS resenhas; ler resenhas alheias exige Pro (herda posts_read via EXISTS).
create policy post_comments_read on public.post_comments for select to authenticated
  using (author_id = (select auth.uid())
         or (deleted_at is null and exists (select 1 from public.posts p where p.id = post_id)));
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
  using (private.is_club_member(club_id) and (deleted_at is null or author_id = (select auth.uid())));
create policy club_posts_insert on public.club_posts for insert to authenticated
  with check (author_id = (select auth.uid()) and private.is_club_member(club_id));
create policy club_posts_update_own on public.club_posts for update to authenticated
  using (author_id = (select auth.uid())) with check (author_id = (select auth.uid()));

create policy club_replies_read on public.club_post_replies for select to authenticated
  using (private.is_club_member(club_id) and (deleted_at is null or author_id = (select auth.uid())));
create policy club_replies_insert on public.club_post_replies for insert to authenticated
  with check (author_id = (select auth.uid()));
-- (o trigger club_reply_set_club define club_id a partir do post; a checagem de membro
--  acontece no WITH CHECK abaixo, avaliado DEPOIS dos triggers BEFORE)
create policy club_replies_insert_member on public.club_post_replies as restrictive for insert to authenticated
  with check (private.is_club_member(club_id));
-- (G04) faltava: sem política de UPDATE o autor não conseguia apagar (deleted_at) a própria resposta
create policy club_replies_update_own on public.club_post_replies for update to authenticated
  using (author_id = (select auth.uid())) with check (author_id = (select auth.uid()));

create policy notifications_own on public.notifications for select to authenticated
  using (user_id = (select auth.uid()));
create policy notifications_mark_read on public.notifications for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy device_tokens_own on public.device_tokens for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy reports_insert on public.content_reports for insert to authenticated
  with check (reporter_id = (select auth.uid()));

-- -------------------------------------------------------------------------------------
-- RPCs expostas
-- -------------------------------------------------------------------------------------

-- Prévia de perfil para o Grátis: NÃO devolve o texto das resenhas (só tamanho e data),
-- para o "desfocado" não poder ser revertido no aparelho.
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

-- Publicar os números do perfil (o aparelho calcula; limite de 1 vez por minuto)
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

-- Uso justo (chamada pelas Edge Functions com service_role)
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

-- Entrar num clube por convite
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

-- Entrar num clube PÚBLICO (sem convite) — "participar de todos" do plano Grátis
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
-- Permissões
--   ATENÇÃO: sem os REVOKE, os GRANTs por coluna não valem nada (ex.: membro mudando o próprio
--   `role` para 'owner'; contador forjado). O cliente nunca escreve contadores, `role`, `status`
--   de seguidor no INSERT, `club_id` de resposta nem datas de servidor.
-- -------------------------------------------------------------------------------------
revoke all on public.profiles, public.profile_stats, public.follows, public.user_blocks,
  public.posts, public.post_comments, public.post_likes, public.clubs, public.club_members,
  public.club_invites, public.club_meetings, public.club_posts, public.club_post_replies,
  public.notifications, public.device_tokens, public.content_reports, private.quota_usage
  from public, anon, authenticated;
revoke execute on function
  private.is_club_member(uuid), private.is_club_admin(uuid), private.is_blocked_between(uuid, uuid),
  private.can_view_profile_content(uuid), private.clubs_before_insert(), private.clubs_after_insert(),
  private.follows_before_insert(), private.follows_counters(), private.club_replies_counter(),
  private.club_reply_set_club(), private.profiles_before_delete(), private.post_counters(),
  private.handle_new_user(), private.consume_quota(uuid, text, integer),
  public.profile_preview(text), public.publish_my_stats(integer, integer, integer, integer),
  public.join_club(text), public.join_public_club(uuid)
  from public, anon, authenticated;

-- funções usadas por políticas de RLS (avaliadas como o usuário)
grant execute on function private.is_club_member(uuid), private.is_club_admin(uuid),
  private.is_blocked_between(uuid, uuid), private.can_view_profile_content(uuid) to authenticated;

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
grant execute on function public.profile_preview(text), public.publish_my_stats(integer, integer, integer, integer),
  public.join_club(text), public.join_public_club(uuid) to authenticated;

grant all on public.profiles, public.profile_stats, public.follows, public.user_blocks,
  public.posts, public.post_comments, public.post_likes, public.clubs, public.club_members,
  public.club_invites, public.club_meetings, public.club_posts, public.club_post_replies,
  public.notifications, public.device_tokens, public.content_reports, private.quota_usage
  to service_role;
grant execute on function
  private.is_club_member(uuid), private.is_club_admin(uuid), private.is_blocked_between(uuid, uuid),
  private.can_view_profile_content(uuid), private.consume_quota(uuid, text, integer),
  public.profile_preview(text), public.publish_my_stats(integer, integer, integer, integer),
  public.join_club(text), public.join_public_club(uuid)
  to service_role;

-- =====================================================================================
-- BookNest · G21.2 — termos, bloqueio no clube e moderação (D-52; docs/progresso/G21.md §2; D-220–D-223).
-- =====================================================================================

-- Termos (D-222): quem não aceitou a versão atual não publica. A versão fica numa configuração do servidor.
create table private.settings (
  key         text primary key check (key ~ '^[a-z_]{3,40}$'),
  value       text not null,
  updated_at  timestamptz not null default now()
);
alter table private.settings enable row level security;   -- sem política: só service_role
insert into private.settings (key, value) values ('terms_version', '2026-10-provisorio');

create table private.terms_acceptances (     -- o histórico (LGPD): cada versão aceita, com a data
  user_id      uuid not null references auth.users(id) on delete cascade,
  version      text not null,
  accepted_at  timestamptz not null default now(),
  primary key (user_id, version)
);
alter table private.terms_acceptances enable row level security;

create or replace function private.terms_version() returns text
language sql stable security definer set search_path = '' as $$
  select s.value from private.settings s where s.key = 'terms_version'
$$;

create or replace function public.my_terms() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_version text := private.terms_version();
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  return jsonb_build_object('version', v_version, 'accepted', exists (
    select 1 from private.terms_acceptances t where t.user_id = v_me and t.version = v_version));
end $$;

create or replace function public.accept_terms(p_version text) returns void
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid());
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if p_version is distinct from private.terms_version() then
    raise exception 'stale_terms' using errcode = '22023';
  end if;
  insert into private.terms_acceptances (user_id, version) values (v_me, p_version) on conflict do nothing;
end $$;

-- Vale só para pedidos com usuário no JWT (como a faixa etária): rotinas do servidor não são barradas.
create or replace function private.require_terms() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid());
begin
  if v_me is not null and not exists (
       select 1 from private.terms_acceptances t where t.user_id = v_me and t.version = private.terms_version()) then
    raise exception 'terms_required' using errcode = 'P0001',
      hint = 'Aceite as regras da comunidade para publicar.';
  end if;
  return new;
end $$;
create trigger posts_require_terms before insert on public.posts
  for each row execute function private.require_terms();
create trigger post_comments_require_terms before insert on public.post_comments
  for each row execute function private.require_terms();
create trigger clubs_require_terms before insert on public.clubs
  for each row execute function private.require_terms();
create trigger club_posts_require_terms before insert on public.club_posts
  for each row execute function private.require_terms();
create trigger club_post_replies_require_terms before insert on public.club_post_replies
  for each row execute function private.require_terms();
create trigger meeting_notes_require_terms before insert or update of body on public.meeting_notes
  for each row execute function private.require_terms();

-- Bloqueio dentro do clube (D-223): o que a pessoa bloqueada escreveu some nos dois sentidos.
drop policy club_posts_read on public.club_posts;
create policy club_posts_read on public.club_posts for select to authenticated
  using (private.is_club_member(club_id) and (deleted_at is null or author_id = (select auth.uid()))
         and (author_id is null or not private.is_blocked_between(author_id, (select auth.uid()))));
drop policy club_replies_read on public.club_post_replies;
create policy club_replies_read on public.club_post_replies for select to authenticated
  using (private.is_club_member(club_id) and (deleted_at is null or author_id = (select auth.uid()))
         and not private.is_blocked_between(author_id, (select auth.uid())));
drop policy club_likes_read on public.club_likes;
create policy club_likes_read on public.club_likes for select to authenticated
  using (private.is_club_member(club_id) and not private.is_blocked_between(user_id, (select auth.uid())));

-- não responde a quem está bloqueado (o post nem aparece; isto fecha o id adivinhado)
create or replace function private.club_reply_not_blocked() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_author uuid;
begin
  select p.author_id into v_author from public.club_posts p where p.id = new.post_id;
  if v_author is not null and private.is_blocked_between(v_author, new.author_id) then
    raise exception 'blocked' using errcode = 'P0001';
  end if;
  return new;
end $$;
create trigger club_post_replies_not_blocked before insert on public.club_post_replies
  for each row execute function private.club_reply_not_blocked();

-- Quem modera (D-220): sem política, só o service_role mexe; a Edge Function `moderacao` confere aqui.
create table private.moderators (
  user_id   uuid primary key references auth.users(id) on delete cascade,
  added_at  timestamptz not null default now()
);
alter table private.moderators enable row level security;

create or replace function private.is_moderator(p_user uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from private.moderators m where m.user_id = p_user)
$$;

-- A fila com o conteúdo de cada denúncia (o painel mostra o texto para decidir).
create or replace function private.moderation_snapshot(p_limit integer default 100) returns jsonb
language sql stable security definer set search_path = '' as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', q.id, 'target_type', q.target_type, 'target_id', q.target_id, 'reason', q.reason, 'details', q.details,
    'created_at', q.created_at, 'age_hours', floor(extract(epoch from q.age) / 3600)::integer,
    'sla_breached', q.sla_breached,
    'content', case q.target_type
      when 'post'            then (select concat_ws(' — ', p.quote_text, p.body) from public.posts p where p.id = q.target_id)
      when 'post_comment'    then (select c.body from public.post_comments c where c.id = q.target_id)
      when 'club_post'       then (select concat_ws(' — ', p.quote_text, p.body) from public.club_posts p where p.id = q.target_id)
      when 'club_post_reply' then (select r.body from public.club_post_replies r where r.id = q.target_id)
      when 'profile'         then (select concat_ws(' — ', p.display_name, p.bio) from public.profiles p where p.id = q.target_id)
      when 'club'            then (select concat_ws(' — ', c.name, c.category) from public.clubs c where c.id = q.target_id)
    end) order by q.created_at), '[]'::jsonb)
  from (select * from private.moderation_queue limit p_limit) q
$$;

-- O e-mail do dia (D-221): havendo denúncia aberta, um e-mail para cada pessoa que modera.
alter table private.email_outbox drop constraint email_outbox_template_check;
alter table private.email_outbox add constraint email_outbox_template_check
  check (template in ('retention_warning','retention_purged','welcome','export_ready','moderation_digest'));

create or replace function private.queue_moderation_digest() returns integer
language plpgsql security definer set search_path = '' as $$
declare v_open integer; v_breached integer; v_oldest timestamptz; v_count integer;
begin
  select count(*), count(*) filter (where q.sla_breached), min(q.created_at)
    into v_open, v_breached, v_oldest from private.moderation_queue q;
  if v_open = 0 then return 0; end if;
  insert into private.email_outbox (user_id, template, payload)
  select m.user_id, 'moderation_digest',
         jsonb_build_object('open', v_open, 'breached', v_breached, 'oldest', v_oldest)
    from private.moderators m;
  get diagnostics v_count = row_count;
  return v_count;
end $$;
select cron.schedule('booknest-moderacao-diaria', '0 12 * * *', $$select private.queue_moderation_digest()$$);

-- Privilégios ---------------------------------------------------------------------------
revoke execute on function private.terms_version(), private.require_terms(), private.club_reply_not_blocked(),
  public.my_terms(), public.accept_terms(text), private.is_moderator(uuid), private.moderation_snapshot(integer),
  private.queue_moderation_digest()
  from public, anon, authenticated;
grant execute on function public.my_terms(), public.accept_terms(text) to authenticated, service_role;
grant execute on function private.is_moderator(uuid), private.moderation_snapshot(integer),
  private.queue_moderation_digest() to service_role;
grant all on private.settings, private.terms_acceptances, private.moderators to service_role;

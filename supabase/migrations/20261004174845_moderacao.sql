-- =====================================================================================
-- BookNest · migration 11 — moderação do conteúdo social (D-52; Anexo 02 §5.3, pendência da G04):
-- denúncia única por pessoa e alvo, fila interna com prazo de 24 h, decisão que oculta o
-- conteúdo e filtro de termos proibidos na publicação. O painel interno (equipe) usa o
-- service_role: private.moderation_queue e private.moderate_report(). Os termos ficam em
-- private.blocked_terms (gerenciados pela equipe; a lista não vai para o código).
-- =====================================================================================

alter table public.content_reports
  add column resolved_at     timestamptz,
  add column resolved_by     text check (char_length(resolved_by) <= 100),   -- moderador (equipe, não é conta do app)
  add column resolution_note text check (char_length(resolution_note) <= 1000);
create unique index content_reports_open_uq on public.content_reports (reporter_id, target_type, target_id)
  where status = 'open';

-- Fila para o painel: denúncias abertas, as mais antigas primeiro, com o prazo de 24 h.
create view private.moderation_queue with (security_invoker = true) as
select r.id, r.target_type, r.target_id, r.reason, r.details, r.reporter_id, r.created_at,
       now() - r.created_at as age,
       r.created_at < now() - interval '24 hours' as sla_breached,
       count(*) over (partition by r.target_type, r.target_id) as reports_for_target
  from public.content_reports r
 where r.status = 'open'
 order by r.created_at;

-- Decisão: 'hide' oculta o conteúdo (deleted_at; perfil: limpa bio e foto) e encerra TODAS as
-- denúncias abertas do mesmo alvo; 'dismiss' encerra só esta.
create or replace function private.moderate_report(p_report uuid, p_decision text, p_moderator text,
  p_note text default null) returns void
language plpgsql security definer set search_path = '' as $$
declare r public.content_reports;
begin
  if p_decision not in ('hide', 'dismiss') then
    raise exception 'invalid_decision' using errcode = '22023';
  end if;
  select * into r from public.content_reports where id = p_report for update;
  if r.id is null or r.status <> 'open' then
    raise exception 'report_not_open' using errcode = 'P0001';
  end if;
  if p_decision = 'dismiss' then
    update public.content_reports set status = 'dismissed', resolved_at = now(), resolved_by = p_moderator,
           resolution_note = p_note where id = p_report;
    return;
  end if;
  case r.target_type
    when 'post'            then update public.posts             set deleted_at = coalesce(deleted_at, now()) where id = r.target_id;
    when 'post_comment'    then update public.post_comments     set deleted_at = coalesce(deleted_at, now()) where id = r.target_id;
    when 'club_post'       then update public.club_posts        set deleted_at = coalesce(deleted_at, now()) where id = r.target_id;
    when 'club_post_reply' then update public.club_post_replies set deleted_at = coalesce(deleted_at, now()) where id = r.target_id;
    when 'profile'         then update public.profiles          set bio = null, avatar_path = null where id = r.target_id;
    else null;   -- 'club': decisão manual da equipe (sem ação automática)
  end case;
  update public.content_reports set status = 'actioned', resolved_at = now(), resolved_by = p_moderator,
         resolution_note = p_note
   where target_type = r.target_type and target_id = r.target_id and status = 'open';
end $$;

-- Termos proibidos: minúsculos e sem acento; casam palavra inteira no texto sem acento.
create table private.blocked_terms (
  term        text primary key check (term ~ '^[a-z0-9]+( [a-z0-9]+)*$' and char_length(term) between 2 and 60),
  created_at  timestamptz not null default now()
);
alter table private.blocked_terms enable row level security;   -- sem política: só service_role

create or replace function private.has_blocked_term(p_text text) returns boolean
language sql stable security definer set search_path = '' as $$
  select p_text is not null and exists (
    select 1 from private.blocked_terms b
     where private.f_unaccent(lower(p_text)) ~ ('\m' || b.term || '\M'))
$$;

create or replace function private.reject_blocked_terms() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v jsonb := to_jsonb(new); v_texto text;
begin
  -- (to_jsonb: a mesma função serve a tabelas com colunas diferentes)
  v_texto := case tg_table_name
    when 'profiles' then concat_ws(' ', v ->> 'display_name', v ->> 'bio')
    when 'clubs'    then v ->> 'name'
    else v ->> 'body'                                -- quote_text é trecho do livro: não filtra
  end;
  if private.has_blocked_term(v_texto) then
    raise exception 'content_blocked' using errcode = 'P0001',
      hint = 'O texto tem um termo que não é permitido nas regras da comunidade.';
  end if;
  return new;
end $$;
create trigger profiles_blocked_terms before insert or update of display_name, bio on public.profiles
  for each row execute function private.reject_blocked_terms();
create trigger posts_blocked_terms before insert or update of body on public.posts
  for each row execute function private.reject_blocked_terms();
create trigger post_comments_blocked_terms before insert or update of body on public.post_comments
  for each row execute function private.reject_blocked_terms();
create trigger clubs_blocked_terms before insert or update of name on public.clubs
  for each row execute function private.reject_blocked_terms();
create trigger club_posts_blocked_terms before insert or update of body on public.club_posts
  for each row execute function private.reject_blocked_terms();
create trigger club_post_replies_blocked_terms before insert or update of body on public.club_post_replies
  for each row execute function private.reject_blocked_terms();

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke all on private.moderation_queue, private.blocked_terms from public, anon, authenticated;
revoke execute on function private.moderate_report(uuid, text, text, text), private.has_blocked_term(text),
  private.reject_blocked_terms() from public, anon, authenticated;
grant select on private.moderation_queue to service_role;
grant all on private.blocked_terms to service_role;
grant execute on function private.moderate_report(uuid, text, text, text), private.has_blocked_term(text) to service_role;

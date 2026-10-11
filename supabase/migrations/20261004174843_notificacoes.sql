-- =====================================================================================
-- BookNest · migration 10 — notificações criadas pelo banco (Anexo 02 §5.3, pendência da G04):
-- seguir/pedido, curtida, comentário, resposta no clube e lembrete de encontro. O push sai pela
-- Edge Function `push-sender`, chamada pelo pg_cron a cada minuto (migration de agendamentos):
-- ela lê as notificações com push_sent_at nulo, agrupa (no máximo 1 push por clube a cada
-- 10 min — G21) e marca o envio. Ninguém é notificado pela própria ação nem por quem bloqueou.
-- =====================================================================================

alter table public.notifications add column push_sent_at timestamptz;
create index notifications_push_pending_idx on public.notifications (created_at) where push_sent_at is null;
create index notifications_post_idx on public.notifications (post_id);

alter table public.club_meetings add column reminder_sent_at timestamptz;   -- lembrete "encontro amanhã"
create index club_meetings_reminder_idx on public.club_meetings (starts_at) where reminder_sent_at is null;

create or replace function private.notify(p_user uuid, p_type text, p_actor uuid default null,
  p_club uuid default null, p_post uuid default null, p_payload jsonb default '{}'::jsonb) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if p_user is null or p_user = p_actor then return; end if;
  if p_actor is not null and private.is_blocked_between(p_user, p_actor) then return; end if;
  insert into public.notifications (user_id, type, actor_id, club_id, post_id, payload)
  values (p_user, p_type, p_actor, p_club, p_post, coalesce(p_payload, '{}'::jsonb));
end $$;

create or replace function private.notify_on_follow() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    perform private.notify(new.followee_id,
      case when new.status = 'pending' then 'follow_request' else 'follow' end, new.follower_id);
  elsif old.status = 'pending' and new.status = 'accepted' then
    -- avisa quem pediu que o pedido foi aceito
    perform private.notify(new.follower_id, 'follow', new.followee_id, null, null, '{"accepted": true}'::jsonb);
  end if;
  return null;
end $$;
create trigger follows_notify after insert or update of status on public.follows
  for each row execute function private.notify_on_follow();

create or replace function private.notify_on_post_activity() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_author uuid; v jsonb := to_jsonb(new);   -- curtida tem user_id; comentário, author_id
begin
  select p.author_id into v_author from public.posts p where p.id = new.post_id;
  if tg_table_name = 'post_likes' then
    perform private.notify(v_author, 'post_like', (v ->> 'user_id')::uuid, null, new.post_id);
  else
    perform private.notify(v_author, 'post_comment', (v ->> 'author_id')::uuid, null, new.post_id);
  end if;
  return null;
end $$;
create trigger post_likes_notify after insert on public.post_likes
  for each row execute function private.notify_on_post_activity();
create trigger post_comments_notify after insert on public.post_comments
  for each row execute function private.notify_on_post_activity();

create or replace function private.notify_on_club_reply() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_author uuid;
begin
  select p.author_id into v_author from public.club_posts p where p.id = new.post_id;
  perform private.notify(v_author, 'club_reply', new.author_id, new.club_id, new.post_id);
  return null;
end $$;
create trigger club_post_replies_notify after insert on public.club_post_replies
  for each row execute function private.notify_on_club_reply();

-- Lembrete "o encontro do clube é amanhã": encontros que começam entre 23 h e 25 h a partir de
-- agora (a rotina roda de hora em hora); cada encontro é lembrado uma vez só.
create or replace function private.queue_meeting_reminders() returns integer
language plpgsql security definer set search_path = '' as $$
declare v_count integer := 0; r record;
begin
  for r in
    update public.club_meetings m set reminder_sent_at = now()
     where m.reminder_sent_at is null
       and m.starts_at between now() + interval '23 hours' and now() + interval '25 hours'
    returning m.id, m.club_id, m.starts_at, m.timezone, m.created_by
  loop
    perform private.notify(cm.user_id, 'club_meeting', null, r.club_id, null,
              jsonb_build_object('meeting_id', r.id, 'starts_at', r.starts_at, 'timezone', r.timezone))
       from public.club_members cm where cm.club_id = r.club_id;
    v_count := v_count + 1;
  end loop;
  return v_count;
end $$;

-- Encontro remarcado → o lembrete vale para a data nova
create or replace function private.meeting_rescheduled() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.starts_at is distinct from old.starts_at then new.reminder_sent_at := null; end if;
  return new;
end $$;
create trigger club_meetings_rescheduled before update of starts_at on public.club_meetings
  for each row execute function private.meeting_rescheduled();

-- -------------------------------------------------------------------------------------
-- Permissões (colunas novas não ganham GRANT: push_sent_at e reminder_sent_at são do servidor)
-- -------------------------------------------------------------------------------------
revoke execute on function private.notify(uuid, text, uuid, uuid, uuid, jsonb), private.notify_on_follow(),
  private.notify_on_post_activity(), private.notify_on_club_reply(), private.queue_meeting_reminders(),
  private.meeting_rescheduled() from public, anon, authenticated;
grant execute on function private.notify(uuid, text, uuid, uuid, uuid, jsonb), private.queue_meeting_reminders()
  to service_role;

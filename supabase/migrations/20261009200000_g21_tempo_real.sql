-- =====================================================================================
-- BookNest · G21.2 — o tempo real do clube (D-225; docs/progresso/G21.md §2). Um aviso sem conteúdo
-- ("mudou") no canal privado club:<id> a cada post, resposta ou curtida; o app relê o resumo. Só os
-- membros leem o tópico. Broadcast (escala melhor que o Postgres Changes); o app só abre o canal com
-- a 25 ou uma tela do clube aberta.
-- =====================================================================================

create or replace function private.club_ping() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  perform realtime.send(jsonb_build_object('t', tg_table_name), 'changed',
                        'club:' || coalesce(new.club_id, old.club_id)::text, true);
  return null;
end $$;
create trigger club_posts_ping after insert or update of body, deleted_at, status, position, host_note
  on public.club_posts for each row execute function private.club_ping();
create trigger club_post_replies_ping after insert or update of body, deleted_at
  on public.club_post_replies for each row execute function private.club_ping();
create trigger club_likes_ping after insert or delete on public.club_likes
  for each row execute function private.club_ping();

-- O membro do clube do tópico 'club:<uuid>' (o uuid é conferido antes do cast: tópico inválido = não).
create or replace function private.club_topic_member(p_topic text) returns boolean
language sql stable security definer set search_path = '' as $$
  select p_topic ~ '^club:[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
     and private.is_club_member(substr(p_topic, 6)::uuid)
$$;
create policy club_pings_read on realtime.messages for select to authenticated
  using (realtime.messages.extension = 'broadcast' and private.club_topic_member((select realtime.topic())));

revoke execute on function private.club_ping(), private.club_topic_member(text) from public, anon, authenticated;
grant execute on function private.club_topic_member(text) to authenticated;

-- =====================================================================================
-- BookNest · G21 (revisão independente): o que o app publica sozinho volta dizendo se gravou, e as leitoras que já
-- eram de um clube antes da G21 ganham a cor da paleta.
-- - publish_progress (R9) e publish_my_stats (R10) ignoram a 2ª chamada no mesmo minuto; agora devolvem `true`
--   quando gravaram e `false` quando ignoraram — o app só marca como publicada a que o servidor gravou (antes, a
--   ignorada ficava marcada e a posição nova não subia mais).
-- - club_members.color entrou na G21 sem valor para as linhas que já existiam; o gatilho só pinta no insert.
-- =====================================================================================

drop function public.publish_progress(uuid, numeric, integer);
create function public.publish_progress(p_club uuid, p_ratio numeric, p_chapter integer) returns boolean
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid());
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_member(p_club) then raise exception 'not_member' using errcode = '42501'; end if;
  if p_ratio is null or p_ratio < 0 or p_ratio > 1 or (p_chapter is not null and p_chapter < 0) then
    raise exception 'invalid_progress' using errcode = '22023';
  end if;
  update public.club_members
     set progress_ratio = round(p_ratio, 4), progress_chapter = p_chapter, progress_updated_at = now()
   where club_id = p_club and user_id = v_me
     and (progress_updated_at is null or progress_updated_at < now() - interval '1 minute');
  return found;
end $$;

drop function public.publish_my_stats(integer, integer, integer, integer);
create function public.publish_my_stats(
  p_books_read_total integer, p_books_read_year integer, p_reading_now integer, p_streak_days integer)
returns boolean language plpgsql security definer set search_path = '' as $$
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
  return found;
end $$;

-- A cor de quem não tem (a regra do gatilho club_member_color, na ordem de chegada): a 1ª livre da paleta; acabou a
-- paleta, recomeça pela ordem. Devolve quantas pintou.
create or replace function private.backfill_member_colors() returns integer
language plpgsql security definer set search_path = '' as $$
declare
  v_palette constant text[] := array['#B6ACE4','#ABCF82','#FED170','#FFC1C6','#FFFAF1','#058CD7','#F2A815'];
  r record;
  v_color text;
  v_count integer;
  n integer := 0;
begin
  for r in select m.club_id, m.user_id from public.club_members m where m.color is null
            order by m.club_id, m.joined_at, m.user_id loop
    select u.p into v_color from unnest(v_palette) with ordinality as u(p, i)
     where not exists (select 1 from public.club_members x where x.club_id = r.club_id and x.color = u.p)
     order by u.i limit 1;
    if v_color is null then
      select count(*) into v_count from public.club_members x where x.club_id = r.club_id and x.color is not null;
      v_color := v_palette[(v_count % array_length(v_palette, 1)) + 1];
    end if;
    update public.club_members set color = v_color where club_id = r.club_id and user_id = r.user_id;
    n := n + 1;
  end loop;
  return n;
end $$;

revoke all on function public.publish_progress(uuid, numeric, integer),
  public.publish_my_stats(integer, integer, integer, integer), private.backfill_member_colors()
  from public, anon, authenticated;
grant execute on function public.publish_progress(uuid, numeric, integer),
  public.publish_my_stats(integer, integer, integer, integer) to authenticated, service_role;
grant execute on function private.backfill_member_colors() to service_role;

select private.backfill_member_colors();

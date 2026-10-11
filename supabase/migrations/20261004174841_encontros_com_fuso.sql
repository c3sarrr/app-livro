-- =====================================================================================
-- BookNest · migration 09 — encontros do clube com fuso horário (Anexo 02 §5.3, pendência da G04)
-- e validação do fuso do perfil. "QUI 24/9 · 19h" é starts_at mostrado no fuso do encontro (o
-- de quem marcou; padrão America/Sao_Paulo) — membros em outro fuso veem a mesma hora local do
-- encontro e, opcionalmente, a conversão (app). Também: o dono/moderador passa a poder
-- remarcar e desmarcar (antes só criava).
-- =====================================================================================

alter table public.club_meetings add column timezone text not null default 'America/Sao_Paulo';

-- Fuso IANA válido (um CHECK não pode consultar pg_timezone_names; vale para INSERT e UPDATE)
create or replace function private.check_timezone() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if not private.is_valid_timezone(new.timezone) then
    raise exception 'invalid_timezone' using errcode = '22023',
      hint = 'Use um fuso IANA, por exemplo America/Sao_Paulo.';
  end if;
  return new;
end $$;
create trigger club_meetings_timezone before insert or update of timezone on public.club_meetings
  for each row execute function private.check_timezone();
create trigger profiles_timezone before insert or update of timezone on public.profiles
  for each row execute function private.check_timezone();

create policy club_meetings_admin_update on public.club_meetings for update to authenticated
  using (private.is_club_admin(club_id)) with check (private.is_club_admin(club_id));
create policy club_meetings_admin_delete on public.club_meetings for delete to authenticated
  using (private.is_club_admin(club_id));

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke execute on function private.check_timezone() from public, anon, authenticated;
grant insert (timezone) on public.club_meetings to authenticated;
grant update (starts_at, location, until_chapter, timezone) on public.club_meetings to authenticated;
grant delete on public.club_meetings to authenticated;

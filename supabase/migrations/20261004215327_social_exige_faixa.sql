-- =====================================================================================
-- BookNest · migration 17 — o social exige a faixa etária registrada (pendência da G16 antecipada
-- antes da G06; D-66/D-70). Conta sem faixa é tratada como de menor até confirmar a idade: não
-- publica, não comenta, não curte, não segue, não cria nem entra em clube e não abre o perfil.
-- Denunciar, bloquear e registrar o aparelho continuam livres (proteção). Vale só para pedidos com
-- usuário no JWT (auth.uid()); rotinas do servidor (sem usuário) não são afetadas.
-- =====================================================================================

create or replace function private.require_age_band() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid());
begin
  if v_uid is not null and not exists (select 1 from private.account_age a where a.user_id = v_uid) then
    raise exception 'age_required' using errcode = 'P0001',
      hint = 'Confirme sua idade para participar dos clubes e posts.';
  end if;
  return new;
end $$;

create trigger follows_require_age before insert on public.follows
  for each row execute function private.require_age_band();
create trigger posts_require_age before insert on public.posts
  for each row execute function private.require_age_band();
create trigger post_comments_require_age before insert on public.post_comments
  for each row execute function private.require_age_band();
create trigger post_likes_require_age before insert on public.post_likes
  for each row execute function private.require_age_band();
create trigger clubs_require_age before insert on public.clubs
  for each row execute function private.require_age_band();
create trigger club_members_require_age before insert on public.club_members
  for each row execute function private.require_age_band();
create trigger club_invites_require_age before insert on public.club_invites
  for each row execute function private.require_age_band();
create trigger club_meetings_require_age before insert on public.club_meetings
  for each row execute function private.require_age_band();
create trigger club_posts_require_age before insert on public.club_posts
  for each row execute function private.require_age_band();
create trigger club_post_replies_require_age before insert on public.club_post_replies
  for each row execute function private.require_age_band();

-- Abrir o próprio perfil também exige a faixa (a conta nasce fechada — migration 16).
create or replace function private.public_profile_requires_age() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.visibility = 'public' and old.visibility is distinct from 'public'
     and new.id = (select auth.uid())
     and not exists (select 1 from private.account_age a where a.user_id = new.id) then
    raise exception 'age_required' using errcode = 'P0001',
      hint = 'Confirme sua idade antes de abrir o perfil.';
  end if;
  return new;
end $$;
create trigger profiles_public_requires_age before update of visibility on public.profiles
  for each row execute function private.public_profile_requires_age();

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke execute on function private.require_age_band(), private.public_profile_requires_age()
  from public, anon, authenticated;

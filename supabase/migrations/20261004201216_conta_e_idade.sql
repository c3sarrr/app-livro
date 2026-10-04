-- =====================================================================================
-- BookNest · migration 16 — conta (G05): faixa etária (D-66), resumo da conta para o app e o @
-- provisório reservado. O servidor guarda só a FAIXA e a FONTE (nunca a data de nascimento — ECA
-- Digital: o dado da verificação só serve para ela). Adolescente (13–17) e conta ainda sem faixa =
-- perfil fechado por padrão; pela RPC a faixa só fica mais protegida (revisão da G05).
-- =====================================================================================

create table private.account_age (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  band        text not null check (band in ('13_15', '16_17', '18_plus')),
  source      text not null check (source in ('play_signal', 'apple_signal', 'birthdate')),
  checked_at  timestamptz not null default now()
);
alter table private.account_age enable row level security;   -- sem política: só pelas funções abaixo

-- Conta nova nasce com o perfil FECHADO: até a faixa etária ser registrada, ela é tratada como de
-- menor (D-66, padrão protetivo do ECA Digital). Igual à da revisão G04, só muda a visibilidade.
create or replace function private.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_nome text;
begin
  v_nome := coalesce(nullif(left(split_part(coalesce(new.email, ''), '@', 1), 60), ''), 'Leitor');
  if private.has_blocked_term(v_nome) then v_nome := 'Leitor'; end if;
  insert into public.profiles (id, handle, display_name, visibility)
  values (new.id, 'leitor_' || right(replace(new.id::text, '-', ''), 12), v_nome, 'private');
  insert into public.profile_stats (user_id) values (new.id);
  return new;
end $$;

-- Ordem das faixas: quanto menor, mais protegida.
create or replace function private.age_band_rank(p_band text) returns int
language sql immutable set search_path = '' as $$
  select case p_band when '13_15' then 1 when '16_17' then 2 when '18_plus' then 3 end
$$;

-- Registra a faixa etária de quem chama. O cliente só consegue manter ou PROTEGER MAIS (faixa mais
-- nova): a fonte vem do próprio app e não é prova, então ninguém passa de adolescente a adulto por
-- esta RPC — essa troca precisa de uma verificação que o app não forja (fluxo da G25, com o advogado).
-- 1ª faixa: adulto abre o perfil (o padrão do adulto é público); menor mantém fechado. Menor de 13
-- não tem conta (o app nem chega a pedir o login).
create or replace function public.set_my_age_band(p_band text, p_source text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid()); v_atual private.account_age; v_nova boolean := false;
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if p_band = 'under_13' then
    raise exception 'underage' using errcode = 'P0001', hint = 'O BookNest é para 13 anos ou mais.';
  end if;
  if coalesce(p_band, '') not in ('13_15', '16_17', '18_plus')
     or coalesce(p_source, '') not in ('play_signal', 'apple_signal', 'birthdate') then
    raise exception 'invalid_age' using errcode = '22023';
  end if;
  insert into private.account_age (user_id, band, source) values (v_uid, p_band, p_source)
  on conflict (user_id) do nothing
  returning * into v_atual;
  v_nova := v_atual.user_id is not null;
  if not v_nova then
    select * into v_atual from private.account_age where user_id = v_uid for update;
    if private.age_band_rank(p_band) < private.age_band_rank(v_atual.band) then
      update private.account_age set band = p_band, source = p_source, checked_at = now()
       where user_id = v_uid returning * into v_atual;
    end if;
  end if;
  if v_atual.band <> '18_plus' then
    update public.profiles set visibility = 'private' where id = v_uid and visibility <> 'private';
  elsif v_nova then
    update public.profiles set visibility = 'public' where id = v_uid and visibility <> 'public';
  end if;
  return jsonb_build_object('band', v_atual.band, 'source', v_atual.source, 'minor', v_atual.band <> '18_plus');
end $$;

-- Resumo da conta para o app (uma chamada depois do login): @, se o @ ainda é o provisório,
-- visibilidade, faixa etária e Pro.
create or replace function public.my_account() returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', p.id, 'handle', p.handle, 'display_name', p.display_name, 'visibility', p.visibility,
    'handle_provisional', p.handle ~ '^leitor_[0-9a-f]{12,23}$',
    'age_band', (select a.band from private.account_age a where a.user_id = p.id),
    'pro', private.user_is_pro(p.id))
  from public.profiles p
  where p.id = (select auth.uid())
$$;

-- O @ no formato do provisório ("leitor_<hex>") é do servidor (cadastro e moderação): o cliente não
-- escolhe um assim (evita ocupar o provisório de outra conta). SECURITY INVOKER: current_user é
-- quem fez o UPDATE.
create or replace function private.handle_reserved_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if new.handle is distinct from old.handle and new.handle ~ '^leitor_'
     and current_user in ('authenticated', 'anon') then
    raise exception 'handle_reserved' using errcode = '22023',
      hint = 'O @ "leitor_…" é reservado. Escolha outro.';
  end if;
  return new;
end $$;
create trigger profiles_handle_reserved before update of handle on public.profiles
  for each row execute function private.handle_reserved_guard();

-- Exportação (LGPD): inclui a faixa etária guardada (formato 2).
create or replace function public.export_my_data() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid()); v_out jsonb;
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.consume_quota(v_uid, 'export_data', 3) then
    raise exception 'quota_exceeded' using errcode = 'P0001';
  end if;
  select jsonb_build_object(
    'format_version', 2,
    'generated_at', now(),
    'account', (select jsonb_build_object('id', u.id, 'email', u.email, 'created_at', u.created_at) from auth.users u where u.id = v_uid),
    'profile', (select to_jsonb(p) from public.profiles p where p.id = v_uid),
    'profile_stats', (select to_jsonb(s) - 'user_id' from public.profile_stats s where s.user_id = v_uid),
    'posts', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at) from public.posts x where x.author_id = v_uid), '[]'),
    'post_comments', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at) from public.post_comments x where x.author_id = v_uid), '[]'),
    'post_likes', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at) from public.post_likes x where x.user_id = v_uid), '[]'),
    'following', coalesce((select jsonb_agg(jsonb_build_object('followee_id', x.followee_id, 'status', x.status, 'created_at', x.created_at))
                            from public.follows x where x.follower_id = v_uid), '[]'),
    'followers', coalesce((select jsonb_agg(jsonb_build_object('follower_id', x.follower_id, 'status', x.status, 'created_at', x.created_at))
                            from public.follows x where x.followee_id = v_uid), '[]'),
    'blocks', coalesce((select jsonb_agg(jsonb_build_object('blocked_id', x.blocked_id, 'created_at', x.created_at))
                         from public.user_blocks x where x.blocker_id = v_uid), '[]'),
    'clubs_owned', coalesce((select jsonb_agg(to_jsonb(x)) from public.clubs x where x.owner_id = v_uid), '[]'),
    'club_memberships', coalesce((select jsonb_agg(to_jsonb(x) - 'user_id') from public.club_members x where x.user_id = v_uid), '[]'),
    'club_posts', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at) from public.club_posts x where x.author_id = v_uid), '[]'),
    'club_post_replies', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at) from public.club_post_replies x where x.author_id = v_uid), '[]'),
    'notifications', coalesce((select jsonb_agg(to_jsonb(x) - 'user_id' order by x.created_at) from public.notifications x where x.user_id = v_uid), '[]'),
    'devices', coalesce((select jsonb_agg(jsonb_build_object('platform', x.platform, 'app_version', x.app_version, 'updated_at', x.updated_at))
                          from public.device_tokens x where x.user_id = v_uid), '[]'),
    'reports_made', coalesce((select jsonb_agg(jsonb_build_object('target_type', x.target_type, 'target_id', x.target_id, 'reason', x.reason,
                               'details', x.details, 'status', x.status, 'created_at', x.created_at))
                               from public.content_reports x where x.reporter_id = v_uid), '[]'),
    'subscriptions', coalesce((select jsonb_agg(to_jsonb(x) - 'user_id') from billing.subscriptions x where x.user_id = v_uid), '[]'),
    'entitlements', coalesce((select jsonb_agg(to_jsonb(x) - 'user_id') from billing.entitlements x where x.user_id = v_uid), '[]'),
    'age', (select jsonb_build_object('band', x.band, 'source', x.source, 'checked_at', x.checked_at)
              from private.account_age x where x.user_id = v_uid),
    'personal', jsonb_build_object(
      'user_books', coalesce((select jsonb_agg(to_jsonb(x)) from personal.user_books x where x.user_id = v_uid), '[]'),
      'reading_positions', coalesce((select jsonb_agg(to_jsonb(x)) from personal.reading_positions x where x.user_id = v_uid), '[]'),
      'reading_sessions', coalesce((select jsonb_agg(to_jsonb(x)) from personal.reading_sessions x where x.user_id = v_uid), '[]'),
      'bookmarks', coalesce((select jsonb_agg(to_jsonb(x)) from personal.bookmarks x where x.user_id = v_uid), '[]'),
      'ink_layers', coalesce((select jsonb_agg(to_jsonb(x)) from personal.ink_layers x where x.user_id = v_uid), '[]'),
      'annotations', coalesce((select jsonb_agg(to_jsonb(x)) from personal.annotations x where x.user_id = v_uid), '[]'),
      'highlight_labels', coalesce((select jsonb_agg(to_jsonb(x)) from personal.highlight_labels x where x.user_id = v_uid), '[]'),
      'reader_settings', coalesce((select jsonb_agg(to_jsonb(x)) from personal.reader_settings x where x.user_id = v_uid), '[]'),
      'pen_presets', coalesce((select jsonb_agg(to_jsonb(x)) from personal.pen_presets x where x.user_id = v_uid), '[]'),
      'reading_goals', coalesce((select jsonb_agg(to_jsonb(x)) from personal.reading_goals x where x.user_id = v_uid), '[]')))
  into v_out;
  return v_out;
end $$;

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke all on private.account_age from public, anon, authenticated;
grant all on private.account_age to service_role;
revoke execute on function public.set_my_age_band(text, text), public.my_account(), private.handle_reserved_guard(),
  public.export_my_data(), private.handle_new_user(), private.age_band_rank(text) from public, anon, authenticated;
grant execute on function public.set_my_age_band(text, text), public.my_account(), public.export_my_data() to authenticated;
grant execute on function public.set_my_age_band(text, text), public.my_account(), public.export_my_data() to service_role;

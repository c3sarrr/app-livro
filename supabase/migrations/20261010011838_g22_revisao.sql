-- G22.7 — o que a revisão independente achou no servidor (docs/progresso/G22.md, Revisão):
-- D-237: a Test Store do RevenueCat só dá Pro a conta da lista de teste (private.billing_test_accounts) — ou a qualquer
--        conta com a chave do Supabase local ligada, que só o seed.sql liga (o seed não roda na produção). A chave de
--        teste vai em todo build de depuração; sem isso, quem tivesse uma compraria o Pro "de graça" na produção.
--        O sandbox das lojas continua liberando (D-48).
-- D-238: o other_sessions só conta a sessão usada nos últimos 30 dias (o app desinstalado sem sair não é outro
--        aparelho para sempre).
create table private.billing_config (
  id                    boolean primary key default true check (id),
  test_store_grants_pro boolean not null default false
);
insert into private.billing_config default values;
alter table private.billing_config enable row level security;   -- sem política: só service_role
revoke all on private.billing_config from public, anon, authenticated;
grant all on private.billing_config to service_role;

create or replace function private.rc_recompute_entitlement(p_user uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare v_until timestamptz; v_env text; v_source uuid;
begin
  select greatest(x.current_period_ends_at, coalesce(x.grace_period_ends_at, x.current_period_ends_at)),
         x.environment, x.id
    into v_until, v_env, v_source
    from billing.subscriptions x
   where x.user_id = p_user and x.entitlement = 'pro' and x.status <> 'refunded'
     -- D-237: a Test Store só vale para conta de teste (ou com a chave do Supabase local)
     and (x.store <> 'test_store'
          or exists (select 1 from private.billing_test_accounts t where t.user_id = p_user)
          or coalesce((select c.test_store_grants_pro from private.billing_config c), false))
   order by 1 desc limit 1;

  if v_until is null then
    -- sem assinatura válida (reembolso, transferência): o Pro termina agora
    update billing.entitlements set active_until = least(active_until, now()), updated_at = now()
     where user_id = p_user and entitlement = 'pro';
  else
    insert into billing.entitlements as e (user_id, entitlement, active_until, environment, source_subscription_id, updated_at)
    values (p_user, 'pro', v_until, v_env, v_source, now())
    on conflict (user_id, entitlement) do update set active_until = excluded.active_until,
      environment = excluded.environment, source_subscription_id = excluded.source_subscription_id, updated_at = now();
  end if;

  -- acesso ao sync na hora (o refresh_sync_access de 15 em 15 min cobre o resto)
  insert into billing.sync_access as a (user_id, granted, updated_at)
  select e.user_id, e.active_until + interval '7 days' > now(), now()
    from billing.entitlements e where e.user_id = p_user and e.entitlement = 'pro'
  on conflict (user_id) do update set granted = excluded.granted, updated_at = now();
end $$;

-- R7, D-235 e D-238: quantas OUTRAS sessões a conta usou nos últimos 30 dias (o session_id do JWT é a desta
-- chamada; a sessão só por senha é a que o Auth abre sozinho no cadastro). Nada da outra sessão sai.
create or replace function public.my_account() returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', p.id, 'handle', p.handle, 'display_name', p.display_name, 'visibility', p.visibility,
    'handle_provisional', p.handle ~ '^leitor_[0-9a-f]{12,23}$',
    'age_band', (select a.band from private.account_age a where a.user_id = p.id),
    'pro', private.user_is_pro(p.id),
    'other_sessions', (select count(*) from auth.sessions s
                        where s.user_id = p.id
                          and s.id is distinct from nullif((select auth.jwt()) ->> 'session_id', '')::uuid
                          and (s.not_after is null or s.not_after > now())
                          and greatest(s.created_at, s.updated_at, s.refreshed_at at time zone 'UTC')
                              > now() - interval '30 days'
                          and not (exists (select 1 from auth.mfa_amr_claims c
                                            where c.session_id = s.id and c.authentication_method = 'password')
                                   and not exists (select 1 from auth.mfa_amr_claims c
                                                    where c.session_id = s.id
                                                      and c.authentication_method <> 'password'))))
  from public.profiles p
  where p.id = (select auth.uid())
$$;

revoke execute on function public.my_account() from public, anon;
grant execute on function public.my_account() to authenticated, service_role;

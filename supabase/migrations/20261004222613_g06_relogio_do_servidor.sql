-- =====================================================================================
-- BookNest · G06 — hora do servidor no estado do Pro (ADR-003, pendência da G06).
-- A RPC sync_apply_changes recusa versão (HLC) mais de 5 min à frente do relógio do servidor
-- (invalid_hlc). O app mede a defasagem do relógio do aparelho com a hora que vem aqui (consultada
-- a cada credencial do PowerSync), corrige os HLC novos e avisa a pessoa. clock_timestamp(): a hora
-- da resposta, não a do início da transação.
-- =====================================================================================

create or replace function public.my_entitlement() returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'pro', coalesce(bool_or(e.active_until > now()), false),
    'active_until', max(e.active_until),
    'server_time_ms', floor(extract(epoch from clock_timestamp()) * 1000)::bigint)
  from billing.entitlements e
  where e.user_id = (select auth.uid()) and e.entitlement = 'pro'
$$;

revoke execute on function public.my_entitlement() from public, anon;
grant execute on function public.my_entitlement() to authenticated, service_role;

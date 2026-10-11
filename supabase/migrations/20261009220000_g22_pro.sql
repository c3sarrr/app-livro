-- =====================================================================================
-- BookNest · G22 — o Pro (docs/progresso/G22.md §1): as contas de teste da D-48 e o aviso de compra sandbox em conta
-- comum no e-mail do dia; o other_sessions do my_account (o gatilho do 2º aparelho, R7).
-- =====================================================================================

create table private.billing_test_accounts (
  user_id  uuid primary key references auth.users(id) on delete cascade,
  note     text check (char_length(note) <= 200),
  added_at timestamptz not null default now()
);
alter table private.billing_test_accounts enable row level security;
revoke all on private.billing_test_accounts from public, anon, authenticated;
grant all on private.billing_test_accounts to service_role;

-- O e-mail do dia (D-221) passa a sair também quando uma conta comum (fora da lista) tem assinatura sandbox mexida nas
-- últimas 24 h (D-48). O e-mail leva só quantas contas.
create or replace function private.queue_moderation_digest() returns integer
language plpgsql security definer set search_path = '' as $$
declare v_open integer; v_breached integer; v_oldest timestamptz; v_sandbox integer; v_count integer;
begin
  select count(*), count(*) filter (where q.sla_breached), min(q.created_at)
    into v_open, v_breached, v_oldest from private.moderation_queue q;
  select count(distinct s.user_id) into v_sandbox
    from billing.subscriptions s
   where s.environment = 'sandbox' and s.updated_at > now() - interval '24 hours'
     and not exists (select 1 from private.billing_test_accounts t where t.user_id = s.user_id);
  if v_open = 0 and v_sandbox = 0 then return 0; end if;
  insert into private.email_outbox (user_id, template, payload)
  select m.user_id, 'moderation_digest',
         jsonb_build_object('open', v_open, 'breached', v_breached, 'oldest', v_oldest, 'sandbox_accounts', v_sandbox)
    from private.moderators m;
  get diagnostics v_count = row_count;
  return v_count;
end $$;

-- R7: quantas OUTRAS sessões ativas a conta tem (o session_id do JWT é a desta chamada). Nada da outra sessão sai.
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
                          and (s.not_after is null or s.not_after > now())))
  from public.profiles p
  where p.id = (select auth.uid())
$$;

revoke execute on function private.queue_moderation_digest() from public, anon, authenticated;
grant execute on function private.queue_moderation_digest() to service_role;
revoke execute on function public.my_account() from public, anon;
grant execute on function public.my_account() to authenticated, service_role;

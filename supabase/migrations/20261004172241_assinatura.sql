-- =====================================================================================
-- BookNest · migration 03 — assinatura e direitos (escritos só pelo webhook do RevenueCat →
-- Edge Function `revenuecat-webhook`), ciclo de retenção e fila de e-mails. Origem: SQL §2 + §8.2.
-- billing.* e private.*: RLS ligada e SEM políticas = só service_role (bypassrls) acessa.
-- =====================================================================================

create table billing.subscriptions (
  id                       uuid primary key default private.uuid_generate_v7(),
  user_id                  uuid not null references auth.users(id) on delete cascade,
  store                    text not null check (store in ('app_store','play_store','promotional','test_store')),
  product_id               text not null,                  -- App Store: booknest_pro_mensal|anual · Play: booknest_pro:mensal|anual
  entitlement              text not null default 'pro',
  period_type              text not null check (period_type in ('trial','intro','normal','promotional')),
  status                   text not null check (status in ('active','in_grace_period','in_billing_retry','cancelled','expired','paused','refunded')),
  will_renew               boolean not null,
  current_period_starts_at timestamptz not null,
  current_period_ends_at   timestamptz not null,
  grace_period_ends_at     timestamptz,
  original_transaction_id  text not null,
  environment              text not null check (environment in ('sandbox','production')),
  last_event_at            timestamptz not null,
  updated_at               timestamptz not null default now(),
  unique (store, original_transaction_id)
);
create index subscriptions_user_idx on billing.subscriptions (user_id);

create table billing.entitlements (
  user_id                uuid not null references auth.users(id) on delete cascade,
  entitlement            text not null,
  active_until           timestamptz not null,           -- inclui período de carência da loja
  environment            text not null default 'production' check (environment in ('sandbox','production')),
                                                         -- sandbox LIBERA o Pro (revisão da Apple e TestFlight
                                                         -- compram em sandbox) mas fica fora dos relatórios — D-48
  source_subscription_id uuid references billing.subscriptions(id) on delete set null,
  updated_at             timestamptz not null default now(),
  primary key (user_id, entitlement)
);
create index entitlements_source_idx on billing.entitlements (source_subscription_id);

-- Idempotência do webhook: cada event.id do RevenueCat é processado uma vez só.
create table billing.webhook_events (
  event_id      text primary key,
  event_type    text not null,
  app_user_id   text,
  payload       jsonb not null,
  received_at   timestamptz not null default now(),
  processed_at  timestamptz,
  error         text
);

-- Ciclo de vida do Pro (retenção de 12 meses após o fim do Pro — LGPD na política de privacidade)
create table private.account_lifecycle (
  user_id          uuid primary key references auth.users(id) on delete cascade,
  pro_ended_at     timestamptz,
  purge_after      timestamptz,          -- pro_ended_at + 12 meses
  warning_sent_at  timestamptz,          -- aviso por e-mail 30 dias antes
  purged_at        timestamptz
);

create table private.email_outbox (
  id          uuid primary key default private.uuid_generate_v7(),
  user_id     uuid references auth.users(id) on delete cascade,
  template    text not null check (template in ('retention_warning','retention_purged','welcome','export_ready')),
  payload     jsonb not null default '{}',
  created_at  timestamptz not null default now(),
  attempts    integer not null default 0,     -- tentativas da Edge Function `email-sender`
  last_error  text,
  sent_at     timestamptz
);
create index email_outbox_pending_idx on private.email_outbox (created_at) where sent_at is null;
create index email_outbox_user_idx on private.email_outbox (user_id);

create or replace function private.user_is_pro(p_user uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from billing.entitlements e
    where e.user_id = p_user and e.entitlement = 'pro' and e.active_until > now()
  )
$$;

create or replace function private.is_pro() returns boolean
language sql stable security definer set search_path = '' as $$
  select private.user_is_pro((select auth.uid()))
$$;

-- Pode sincronizar = é Pro (a carência da loja já está dentro de active_until).
create or replace function private.can_sync(p_user uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select private.user_is_pro(p_user)
$$;

-- Quem pode receber os dados pessoais pelo PowerSync (parâmetro do stream "pessoal" — ADR-003).
-- TABELA (não view): o PowerSync só replica tabelas e as regras de sync não avaliam now().
-- Mantida pelo webhook e por private.refresh_sync_access() (pg_cron a cada 15 min).
-- Continua concedido por 7 DIAS depois do fim do Pro (folga para o app se desconectar); o
-- upload é bloqueado na hora por private.can_sync. No aparelho, a remoção do bucket não apaga
-- nada (ADR-002: `delete` que só registra).
create table billing.sync_access (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  granted     boolean not null,
  updated_at  timestamptz not null default now()
);

create or replace function private.refresh_sync_access() returns void
language plpgsql security definer set search_path = '' as $$
begin
  insert into billing.sync_access as s (user_id, granted, updated_at)
  select e.user_id, e.active_until + interval '7 days' > now(), now()
    from billing.entitlements e where e.entitlement = 'pro'
  on conflict (user_id) do update set granted = excluded.granted, updated_at = now()
   where s.granted is distinct from excluded.granted;
end $$;

-- Estado do Pro para o app (o app confia no RevenueCat para UX; o servidor confia nisto)
create or replace function public.my_entitlement() returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'pro', coalesce(bool_or(e.active_until > now()), false),
    'active_until', max(e.active_until))
  from billing.entitlements e
  where e.user_id = (select auth.uid()) and e.entitlement = 'pro'
$$;

-- RLS: ligada e sem políticas (só service_role) -----------------------------------------
alter table billing.subscriptions     enable row level security;
alter table billing.entitlements      enable row level security;
alter table billing.webhook_events    enable row level security;
alter table billing.sync_access       enable row level security;
alter table private.account_lifecycle enable row level security;
alter table private.email_outbox      enable row level security;

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke all on billing.subscriptions, billing.entitlements, billing.webhook_events, billing.sync_access,
  private.account_lifecycle, private.email_outbox from public, anon, authenticated;
revoke execute on function private.user_is_pro(uuid), private.is_pro(), private.can_sync(uuid),
  private.refresh_sync_access(), public.my_entitlement() from public, anon, authenticated;

-- funções usadas por políticas de RLS (avaliadas como o usuário)
grant execute on function private.is_pro(), private.user_is_pro(uuid), private.can_sync(uuid) to authenticated;
grant execute on function public.my_entitlement() to authenticated;

grant all on billing.subscriptions, billing.entitlements, billing.webhook_events, billing.sync_access,
  private.account_lifecycle, private.email_outbox to service_role;
grant execute on function private.user_is_pro(uuid), private.is_pro(), private.can_sync(uuid),
  private.refresh_sync_access(), public.my_entitlement() to service_role;

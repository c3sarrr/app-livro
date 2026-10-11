-- =====================================================================================
-- BookNest · migration 07 — retenção de 12 meses após o fim do Pro (LGPD; Anexo 04 §8) e fila
-- de limpeza do Storage (e-books de quem foi purgado ou excluiu a conta). Origem: SQL §9.
-- Agendada pelo pg_cron (migration de agendamentos); a Edge Function `purge-storage` consome a fila.
-- =====================================================================================

-- Fila de limpeza do bucket "ebooks" (pasta "<user_id>/"). SEM chave estrangeira: a conta pode já
-- ter sido apagada do Auth quando a função rodar.
create table private.storage_purge_queue (
  user_id       uuid primary key,
  reason        text not null check (reason in ('retention', 'account_deleted')),
  requested_at  timestamptz not null default now(),
  attempts      integer not null default 0,
  last_error    text,
  done_at       timestamptz
);
create index storage_purge_queue_pending_idx on private.storage_purge_queue (requested_at) where done_at is null;
alter table private.storage_purge_queue enable row level security;   -- sem política: só service_role

create or replace function private.queue_storage_purge(p_user uuid, p_reason text) returns void
language sql security definer set search_path = '' as $$
  insert into private.storage_purge_queue as q (user_id, reason)
  values (p_user, p_reason)
  on conflict (user_id) do update
     set reason = excluded.reason, requested_at = now(), attempts = 0, last_error = null, done_at = null
$$;

-- Conta excluída (pela Edge Function `delete-account` ou pelo painel) → limpa os e-books também.
create or replace function private.on_auth_user_deleted() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  perform private.queue_storage_purge(old.id, 'account_deleted');
  return old;
end $$;
create trigger on_auth_user_deleted after delete on auth.users
  for each row execute function private.on_auth_user_deleted();

-- Retenção de 12 meses após o fim do Pro. Garantia: o aviso sai ≥ 30 dias ANTES do purge,
-- mesmo que a rotina tenha ficado parada (o purge espera warning_sent_at + 30 dias).
create or replace function private.run_retention() returns void
language plpgsql security definer set search_path = '' as $$
declare v_due uuid[];
begin
  -- 1. quem perdeu o Pro entra no ciclo
  insert into private.account_lifecycle (user_id, pro_ended_at, purge_after)
  select e.user_id, e.active_until, e.active_until + interval '12 months'
    from billing.entitlements e
   where e.entitlement = 'pro' and e.active_until <= now()
  on conflict (user_id) do update
     set pro_ended_at = excluded.pro_ended_at, purge_after = excluded.purge_after,
         warning_sent_at = null, purged_at = null
   where private.account_lifecycle.pro_ended_at is distinct from excluded.pro_ended_at;

  -- 2. quem voltou a ser Pro sai do ciclo
  delete from private.account_lifecycle l where private.user_is_pro(l.user_id);

  -- 3. aviso (30 dias antes do purge previsto)
  insert into private.email_outbox (user_id, template, payload)
  select l.user_id, 'retention_warning',
         jsonb_build_object('purge_after', greatest(l.purge_after, now() + interval '30 days'))
    from private.account_lifecycle l
   where l.purged_at is null and l.warning_sent_at is null
     and l.purge_after <= now() + interval '30 days';
  update private.account_lifecycle set warning_sent_at = now()
   where purged_at is null and warning_sent_at is null and purge_after <= now() + interval '30 days';

  -- 4. purge: vencido E avisado há ≥ 30 dias. user_books leva junto (ON DELETE CASCADE)
  --    posições, sessões, marcadores, camadas de tinta e anotações; os e-books vão para a fila
  --    do Storage. (G04: sem tabela temporária — o `supabase db lint` não enxerga tabela criada
  --    dentro da função.)
  select coalesce(array_agg(user_id), '{}') into v_due
    from private.account_lifecycle
   where purged_at is null and purge_after <= now()
     and warning_sent_at is not null and warning_sent_at <= now() - interval '30 days';
  if cardinality(v_due) = 0 then return; end if;

  delete from personal.user_books       where user_id = any (v_due);
  delete from personal.highlight_labels where user_id = any (v_due);
  delete from personal.reader_settings  where user_id = any (v_due);
  delete from personal.pen_presets      where user_id = any (v_due);
  delete from personal.reading_goals    where user_id = any (v_due);

  insert into private.email_outbox (user_id, template) select u, 'retention_purged' from unnest(v_due) u;
  perform private.queue_storage_purge(u, 'retention') from unnest(v_due) u;
  update private.account_lifecycle set purged_at = now() where user_id = any (v_due);
end $$;

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke all on private.storage_purge_queue from public, anon, authenticated;
revoke execute on function private.run_retention(), private.queue_storage_purge(uuid, text),
  private.on_auth_user_deleted() from public, anon, authenticated;
grant all on private.storage_purge_queue to service_role;
grant execute on function private.run_retention(), private.queue_storage_purge(uuid, text) to service_role;

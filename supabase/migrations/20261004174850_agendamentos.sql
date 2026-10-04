-- =====================================================================================
-- BookNest · migration 13 — rotinas agendadas (Anexo 02 §8) com pg_cron; as que são Edge
-- Functions são chamadas por pg_net com a chave secreta do agendador (Vault). Horários em UTC
-- (o pg_cron do Supabase roda em UTC; Brasília = UTC−3).
--
-- | rotina                      | quando (UTC)        | o quê                                        |
-- |-----------------------------|---------------------|----------------------------------------------|
-- | booknest-particoes-sessoes  | 03:07 todo dia      | partições mensais das sessões (3 meses)      |
-- | booknest-acesso-sync        | a cada 15 min       | concede/revoga o acesso ao PowerSync         |
-- | booknest-retencao           | 06:17 todo dia      | ciclo de 12 meses: aviso, purge, e-mail      |
-- | booknest-email-sender       | a cada 5 min        | Edge Function email-sender (Resend)          |
-- | booknest-purge-storage      | 04:37 todo dia      | Edge Function purge-storage (fila)           |
-- | booknest-limpeza-cota       | 03:47 todo dia      | apaga uso de cota com mais de 30 dias        |
-- | booknest-push-sender        | todo minuto         | Edge Function push-sender (notificações)     |
-- | booknest-lembrete-encontros | :05 de toda hora    | lembrete "encontro amanhã" (notificação)     |
-- | booknest-poda-notificacoes  | 03:57 todo dia      | apaga notificações lidas com mais de 90 dias |
-- | cold-backup                 | domingo 05:23       | GitHub Actions (.github/workflows/cold-backup.yml): pg_dump não roda no banco |
--
-- Configuração por ambiente (NÃO vai em migration): no Vault, `booknest_project_url` (URL do
-- projeto; no local, http://supabase_kong_booknest:8000) e `booknest_scheduler_key` (chave
-- secreta do agendador). Local: tools/supabase/configurar_agendador_local.sh. Sem as duas, as
-- rotinas de Edge Function só registram um aviso.
-- =====================================================================================

create extension if not exists pg_cron;
create extension if not exists pg_net with schema extensions;

create or replace function private.invoke_edge_function(p_function text, p_body jsonb default '{}'::jsonb)
returns bigint
language plpgsql security definer set search_path = '' as $$
declare v_url text; v_key text;
begin
  if p_function !~ '^[a-z0-9-]{1,64}$' then
    raise exception 'invalid_function' using errcode = '22023';
  end if;
  select s.decrypted_secret into v_url from vault.decrypted_secrets s where s.name = 'booknest_project_url';
  select s.decrypted_secret into v_key from vault.decrypted_secrets s where s.name = 'booknest_scheduler_key';
  if v_url is null or v_key is null then
    raise warning 'agendador sem configuração no Vault (booknest_project_url, booknest_scheduler_key): % não foi chamada',
      p_function;
    return null;
  end if;
  return net.http_post(
    url := rtrim(v_url, '/') || '/functions/v1/' || p_function,
    body := coalesce(p_body, '{}'::jsonb),
    headers := jsonb_build_object('Content-Type', 'application/json', 'apikey', v_key),
    timeout_milliseconds := 10000);
end $$;

create or replace function private.cleanup_quota_usage() returns integer
language plpgsql security definer set search_path = '' as $$
declare n integer;
begin
  delete from private.quota_usage where day < (now() at time zone 'America/Sao_Paulo')::date - 30;
  get diagnostics n = row_count;
  return n;
end $$;

create or replace function private.prune_notifications() returns integer
language plpgsql security definer set search_path = '' as $$
declare n integer;
begin
  delete from public.notifications where read_at is not null and created_at < now() - interval '90 days';
  get diagnostics n = row_count;
  return n;
end $$;

-- cron.schedule com o mesmo nome substitui o agendamento (idempotente)
select cron.schedule('booknest-particoes-sessoes',  '7 3 * * *',    $$select private.ensure_session_partitions(3)$$);
select cron.schedule('booknest-acesso-sync',        '*/15 * * * *', $$select private.refresh_sync_access()$$);
select cron.schedule('booknest-retencao',           '17 6 * * *',   $$select private.run_retention()$$);
select cron.schedule('booknest-email-sender',       '*/5 * * * *',  $$select private.invoke_edge_function('email-sender')$$);
select cron.schedule('booknest-purge-storage',      '37 4 * * *',   $$select private.invoke_edge_function('purge-storage')$$);
select cron.schedule('booknest-limpeza-cota',       '47 3 * * *',   $$select private.cleanup_quota_usage()$$);
select cron.schedule('booknest-push-sender',        '* * * * *',    $$select private.invoke_edge_function('push-sender')$$);
select cron.schedule('booknest-lembrete-encontros', '5 * * * *',    $$select private.queue_meeting_reminders()$$);
select cron.schedule('booknest-poda-notificacoes',  '57 3 * * *',   $$select private.prune_notifications()$$);

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke execute on function private.invoke_edge_function(text, jsonb), private.cleanup_quota_usage(),
  private.prune_notifications() from public, anon, authenticated;
grant execute on function private.invoke_edge_function(text, jsonb), private.cleanup_quota_usage(),
  private.prune_notifications() to service_role;

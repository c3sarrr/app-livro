-- =====================================================================================
-- BookNest · migration 18 — papel de leitura do serviço PowerSync (G06, ADR-003, D-71). O serviço
-- replica a publicação `powersync` e consulta as tabelas dos Sync Streams: precisa de REPLICATION,
-- de BYPASSRLS (lê as linhas de todos os assinantes, filtradas pelos streams) e de SELECT — só nas
-- tabelas sincronizadas. Nasce SEM login: a senha é dada fora do git (script local
-- tools/powersync/subir_local.sh; na nuvem, no painel). Partições novas das sessões recebem o SELECT
-- (partição não herda GRANT — pendência da revisão da G04).
-- =====================================================================================

do $$
begin
  if not exists (select 1 from pg_catalog.pg_roles where rolname = 'powersync_role') then
    create role powersync_role with replication bypassrls nologin;
  end if;
end $$;

grant usage on schema personal, billing to powersync_role;
grant select on all tables in schema personal to powersync_role;   -- inclui as partições que já existem
grant select on billing.sync_access to powersync_role;

create or replace function private.secure_session_partition(p_name text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  execute format('alter table personal.%I enable row level security', p_name);
  execute format('revoke all on personal.%I from public, anon, authenticated', p_name);
  execute format('grant all on personal.%I to service_role', p_name);
  if exists (select 1 from pg_catalog.pg_roles where rolname = 'powersync_role') then
    execute format('grant select on personal.%I to powersync_role', p_name);
  end if;
end $$;

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke execute on function private.secure_session_partition(text) from public, anon, authenticated;

-- =====================================================================================
-- BookNest · migration 01 — fundação: esquemas, extensões e utilitários
-- Origem: handoff_v2/sql/01_schema_booknest.sql §0 (cabeçalho e convenções valem para todas as
-- migrations). Esquemas: public (social), personal (dados pessoais do Pro), catalog (catálogo
-- referenciado), billing (assinaturas) e private (interno). Só `public` é exposto pela API.
--
-- Convenções
--   * ids = UUIDv7 gerados no aparelho; no servidor, private.uuid_generate_v7().
--   * Datas em timestamptz (UTC). Fuso de exibição = profiles.timezone.
--   * Domínios fechados = text + CHECK (evolui sem ALTER TYPE).
--   * RLS ligada em TODAS as tabelas. auth.uid() sempre dentro de (select …).
--   * Toda migration TERMINA com o bloco "Permissões": revoga os privilégios padrão do
--     Supabase/Postgres dos objetos que ela cria e concede só o previsto (por coluna). O teste
--     supabase/tests/database/90_privilegios.test.sql falha se sobrar privilégio fora da lista.
-- =====================================================================================

create schema if not exists private;
create schema if not exists personal;
create schema if not exists catalog;
create schema if not exists billing;

create extension if not exists pgcrypto with schema extensions;
create extension if not exists pg_trgm  with schema extensions;
create extension if not exists unaccent with schema extensions;

create or replace function private.uuid_generate_v7() returns uuid
language plpgsql volatile set search_path = '' as $$
declare
  v_ms bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint;
  v_b  bytea  := extensions.gen_random_bytes(16);
begin
  v_b := set_byte(v_b, 0, ((v_ms >> 40) & 255)::int);
  v_b := set_byte(v_b, 1, ((v_ms >> 32) & 255)::int);
  v_b := set_byte(v_b, 2, ((v_ms >> 24) & 255)::int);
  v_b := set_byte(v_b, 3, ((v_ms >> 16) & 255)::int);
  v_b := set_byte(v_b, 4, ((v_ms >> 8) & 255)::int);
  v_b := set_byte(v_b, 5, (v_ms & 255)::int);
  v_b := set_byte(v_b, 6, (get_byte(v_b, 6) & 15) | 112);   -- versão 7
  v_b := set_byte(v_b, 8, (get_byte(v_b, 8) & 63) | 128);   -- variante RFC 9562
  return encode(v_b, 'hex')::uuid;
end $$;

-- unaccent não é IMMUTABLE; este invólucro permite índice funcional.
create or replace function private.f_unaccent(text) returns text
language sql immutable parallel safe strict set search_path = '' as $$
  select extensions.unaccent('extensions.unaccent'::regdictionary, $1)
$$;

create or replace function private.touch_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- Fuso IANA válido? (usado por gatilhos: um CHECK não pode consultar pg_timezone_names)
create or replace function private.is_valid_timezone(p_tz text) returns boolean
language sql stable parallel safe set search_path = '' as $$
  select p_tz is not null and exists (select 1 from pg_catalog.pg_timezone_names n where n.name = p_tz)
$$;

-- -------------------------------------------------------------------------------------
-- Permissões
--   Os padrões do Supabase dão ALL em tudo que o `postgres` cria em `public` para anon,
--   authenticated e service_role (projetos antigos; os novos já nascem sem isso — changelog de
--   28/04/2026). As 3 linhas abaixo desfazem esses padrões POR ESQUEMA para os objetos futuros.
--   O EXECUTE para PUBLIC em funções é padrão GLOBAL do Postgres e não sai por esquema: cada
--   migration revoga o das funções que cria (e o teste de privilégios confere).
-- -------------------------------------------------------------------------------------
alter default privileges in schema public revoke all on tables    from anon, authenticated;
alter default privileges in schema public revoke all on sequences from anon, authenticated;
alter default privileges in schema public revoke execute on functions from public, anon, authenticated;

revoke all on schema private, personal, catalog, billing from public, anon, authenticated;
grant usage on schema private  to authenticated;   -- só para as funções de RLS/defaults (EXECUTE caso a caso)
grant usage on schema personal to authenticated;   -- leitura do dono (RLS)
grant usage on schema catalog  to authenticated;   -- leitura do catálogo referenciado
grant usage on schema private, personal, catalog, billing to service_role;

revoke execute on function private.uuid_generate_v7(), private.f_unaccent(text),
  private.touch_updated_at(), private.is_valid_timezone(text) from public, anon, authenticated;
grant execute on function private.uuid_generate_v7(), private.f_unaccent(text) to authenticated;
grant execute on function private.uuid_generate_v7(), private.f_unaccent(text),
  private.touch_updated_at(), private.is_valid_timezone(text) to service_role;

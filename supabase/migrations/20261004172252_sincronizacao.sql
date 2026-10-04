-- =====================================================================================
-- BookNest · migration 06 — sincronização Pro: RPC de upload (PowerSync → sync_apply_changes),
-- partições mensais das sessões e publicação lógica do PowerSync. Origem: SQL §8.1 + §9
-- (partições) + spike S2 (publicação — ADR-003).
-- =====================================================================================

-- Sincronização (upload do PowerSync). Lote ≤ 500 operações. O app manda sempre PUT com a linha
--     inteira (ADR-003); PATCH continua aceito (compatibilidade e testes).
--     Operação: {"table","op":"PUT"|"PATCH"|"DELETE","id","data":{...},"hlc"}
--     * last-writer-wins por linha com version_hlc (comparação byte a byte, COLLATE "C");
--     * dono, id e versão impostos pelo servidor; HLC no futuro (> agora + 5 min) é recusado;
--     * colunas jsonb que chegam como TEXTO (assim o SQLite/PowerSync manda) são convertidas;
--     * cada operação roda no próprio bloco (savepoint): uma linha inválida NÃO trava o lote —
--       volta em "rejected" com o motivo, e o app tira da fila e registra (Anexo 02 §6.1).
create or replace function public.sync_apply_changes(p_changes jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_uid       uuid := (select auth.uid());
  v_op        jsonb;
  v_table     text;
  v_kind      text;
  v_id        uuid;
  v_hlc       text;
  v_data      jsonb;
  v_existing  jsonb;
  v_cols      text;
  v_set       text;
  v_conflict  text;
  v_rows      integer;
  v_col       text;
  v_applied   integer := 0;
  v_skipped   integer := 0;
  v_rejected  jsonb := '[]'::jsonb;
  v_max_ms    bigint := floor(extract(epoch from clock_timestamp()) * 1000)::bigint + 300000;
begin
  if v_uid is null then
    raise exception 'unauthenticated' using errcode = '28000';
  end if;
  if not private.can_sync(v_uid) then
    raise exception 'pro_required' using errcode = 'P0001';
  end if;
  if jsonb_typeof(p_changes) <> 'array' or jsonb_array_length(p_changes) > 500 then
    raise exception 'invalid_batch' using errcode = '22023';
  end if;

  for v_op in select value from jsonb_array_elements(p_changes) loop
    begin
      v_table := v_op ->> 'table';
      v_kind  := v_op ->> 'op';
      v_hlc   := v_op ->> 'hlc';
      if v_table is null or v_table not in ('user_books','reading_positions','reading_sessions','bookmarks','ink_layers',
                         'annotations','highlight_labels','reader_settings','pen_presets','reading_goals') then
        raise exception 'table_not_allowed: %', v_table using errcode = '22023';
      end if;
      if v_kind is null or v_kind not in ('PUT','PATCH','DELETE') then
        raise exception 'invalid_op' using errcode = '22023';
      end if;
      v_id := (v_op ->> 'id')::uuid;
      if v_id is null or v_hlc is null
         or v_hlc !~ '^[0-9]{16}-[0-9]{4}-[A-Za-z0-9_-]{1,64}$'
         or left(v_hlc, 16)::bigint > v_max_ms then
        raise exception 'invalid_hlc' using errcode = '22023';
      end if;

      v_conflict := case when v_table = 'reading_sessions' then 'id, started_at' else 'id' end;

      if v_kind = 'DELETE' then
        execute format(
          'update personal.%1$I set deleted_at = now(), updated_at = now(), version_hlc = $1
             where id = $2 and user_id = $3 and version_hlc collate "C" < $1 collate "C"', v_table)
          using v_hlc, v_id, v_uid;
        get diagnostics v_rows = row_count;
      else
        v_data := coalesce(v_op -> 'data', '{}'::jsonb);
        if jsonb_typeof(v_data) <> 'object' then
          raise exception 'invalid_data' using errcode = '22023';
        end if;

        -- jsonb enviado como texto pelo SQLite → objeto/array de verdade
        for v_col in
          select a.attname from pg_catalog.pg_attribute a
           where a.attrelid = format('personal.%I', v_table)::regclass
             and a.attnum > 0 and not a.attisdropped
             and a.atttypid = 'jsonb'::regtype
        loop
          if jsonb_typeof(v_data -> v_col) = 'string' then
            v_data := jsonb_set(v_data, array[v_col], (v_data ->> v_col)::jsonb);
          end if;
        end loop;

        execute format('select to_jsonb(t) from personal.%1$I t where t.id = $1 limit 1', v_table)
          into v_existing using v_id;
        if v_existing is not null and (v_existing ->> 'user_id')::uuid <> v_uid then
          raise exception 'id_conflict' using errcode = '22023';   -- id de outra pessoa
        end if;

        if v_kind = 'PATCH' then
          if v_existing is null then
            raise exception 'patch_missing_row' using errcode = '22023';
          end if;
          v_data := v_existing || v_data;
        end if;

        if v_table = 'reading_sessions' then
          -- chave de partição imutável e dentro das partições existentes
          if v_existing is not null
             and (v_data ->> 'started_at')::timestamptz <> (v_existing ->> 'started_at')::timestamptz then
            raise exception 'started_at_immutable' using errcode = '22023';
          end if;
          if (v_data ->> 'started_at')::timestamptz < '2024-01-01'::timestamptz
             or (v_data ->> 'started_at')::timestamptz > now() + interval '1 day' then
            raise exception 'started_at_out_of_range' using errcode = '22023';
          end if;
          perform private.ensure_session_partition_for((v_data ->> 'started_at')::timestamptz);
        end if;

        v_data := v_data || jsonb_build_object('id', v_id, 'user_id', v_uid, 'version_hlc', v_hlc);

        select string_agg(quote_ident(a.attname), ', ' order by a.attnum),
               string_agg(format('%1$I = excluded.%1$I', a.attname), ', ' order by a.attnum)
                 filter (where a.attname not in ('id','user_id','created_at','started_at'))
          into v_cols, v_set
          from pg_catalog.pg_attribute a
         where a.attrelid = format('personal.%I', v_table)::regclass
           and a.attnum > 0 and not a.attisdropped
           and v_data ? a.attname;        -- só colunas enviadas: as ausentes ficam com o DEFAULT

        execute format(
          'insert into personal.%1$I as t (%2$s)
             select %2$s from jsonb_populate_record(null::personal.%1$I, $1)
           on conflict (%3$s) do update set %4$s
             where t.user_id = $2 and t.version_hlc collate "C" < excluded.version_hlc collate "C"',
          v_table, v_cols, v_conflict, v_set)
          using v_data, v_uid;
        get diagnostics v_rows = row_count;
      end if;

      if v_rows > 0 then v_applied := v_applied + 1; else v_skipped := v_skipped + 1; end if;
    exception when others then
      -- Erros TRANSITÓRIOS não podem virar recusa (o app tiraria a operação da fila e o dado
      -- se perderia): conflito de serialização/deadlock (40xxx), falta de recurso (53xxx),
      -- trava indisponível (55P03), cancelamento/desligamento (57xxx) → o lote inteiro falha e
      -- o app tenta de novo com recuo exponencial.
      if left(sqlstate, 2) in ('40', '53', '57') or sqlstate = '55P03' then
        raise;
      end if;
      v_rejected := v_rejected || jsonb_build_object(
        'table', v_op ->> 'table', 'id', v_op ->> 'id', 'error', sqlerrm, 'code', sqlstate,
        'retryable', false);
    end;
  end loop;

  return jsonb_build_object('applied', v_applied, 'skipped', v_skipped, 'rejected', v_rejected);
end $$;

-- Partição de um mês (criada sob demanda pela RPC de sync — nunca falta partição mesmo se o
-- pg_cron parar). Sem partição default: sessão fora de [2024-01-01, agora + 1 dia] é recusada.
create or replace function private.ensure_session_partition_for(p_ts timestamptz)
returns void language plpgsql security definer set search_path = '' as $$
declare v_start date := date_trunc('month', p_ts)::date; v_name text;
begin
  if v_start < date '2026-01-01' then return; end if;            -- 2024–2025: partição histórica
  v_name := format('reading_sessions_%s', to_char(v_start, 'YYYY_MM'));
  if to_regclass(format('personal.%I', v_name)) is null then
    perform pg_advisory_xact_lock(hashtextextended('sessions_partition:' || v_name, 0));
    if to_regclass(format('personal.%I', v_name)) is null then
      execute format('create table personal.%I partition of personal.reading_sessions
                        for values from (%L) to (%L)',
                     v_name, v_start, (v_start + interval '1 month')::date);
    end if;
  end if;
end $$;

-- Partições mensais das sessões (de 2026-01 até N meses à frente; idempotente)
create or replace function private.ensure_session_partitions(p_months_ahead integer default 3)
returns void language plpgsql security definer set search_path = '' as $$
declare v_start date := date '2026-01-01'; v_end date; v_name text;
begin
  v_end := (date_trunc('month', now()) + make_interval(months => p_months_ahead))::date;
  while v_start <= v_end loop
    v_name := format('reading_sessions_%s', to_char(v_start, 'YYYY_MM'));
    if to_regclass(format('personal.%I', v_name)) is null then
      execute format('create table personal.%I partition of personal.reading_sessions
                        for values from (%L) to (%L)',
                     v_name, v_start, (v_start + interval '1 month')::date);
    end if;
    v_start := (v_start + interval '1 month')::date;
  end loop;
end $$;
select private.ensure_session_partitions(3);

-- Publicação lógica para o PowerSync: tabelas pessoais + billing.sync_access (parâmetro do
-- stream "pessoal"). SEM publish_via_partition_root (o serviço recusa: PSYNC_S1143): cada
-- partição de reading_sessions chega com o próprio nome e o stream as junta com o curinga
-- personal."reading_sessions_%" (partições novas entram sozinhas) — ADR-003, spike S2.
create publication powersync for table
  personal.user_books, personal.reading_positions, personal.reading_sessions, personal.bookmarks,
  personal.ink_layers, personal.annotations, personal.highlight_labels, personal.reader_settings,
  personal.pen_presets, personal.reading_goals, billing.sync_access;


-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke execute on function public.sync_apply_changes(jsonb), private.ensure_session_partition_for(timestamptz),
  private.ensure_session_partitions(integer) from public, anon, authenticated;
grant execute on function public.sync_apply_changes(jsonb) to authenticated;
grant execute on function public.sync_apply_changes(jsonb), private.ensure_session_partition_for(timestamptz),
  private.ensure_session_partitions(integer) to service_role;

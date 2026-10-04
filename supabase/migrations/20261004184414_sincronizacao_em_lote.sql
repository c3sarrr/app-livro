-- =====================================================================================
-- BookNest · migration 14 — RPC de sincronização em lote (ADR-003, item 7). Medido na G04.6 com
-- 100 mil usuários (Postgres 17 local): lotes de 500 operações de uma em uma tinham p50 238 ms e
-- p95 459 ms (meta do Anexo 02 §10: p95 < 400 ms). Mesma assinatura, mesmas regras e mesmas
-- recusas; os PUTs comuns passam a ser gravados por grupo (tabela + conjunto de colunas).
-- =====================================================================================

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
  v_grupo     record;
  v_feitos    integer[] := '{}'::integer[];
  v_linhas    jsonb;
  v_jcols     text[];
  v_conflito  boolean;
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

  -- ---------------------------------------------------------------------------------
  -- Caminho em LOTE (G04 — ADR-003 item 7): PUTs da mesma tabela com o mesmo conjunto de colunas
  -- (o app manda a linha inteira) viram UM insert … on conflict por grupo, com as mesmas regras
  -- (dono e versão impostos pelo servidor; LWW por version_hlc). Por id fica a maior versão do
  -- lote — o estado final é o mesmo da aplicação uma a uma; as cópias mais velhas contam como
  -- "skipped". Qualquer coisa fora do comum (HLC inválido, id de outra pessoa, erro de CHECK/FK
  -- numa linha) devolve o grupo inteiro ao caminho de uma em uma abaixo, que isola e recusa só a
  -- linha ruim. Sessões (chave de partição), PATCH e DELETE vão sempre pelo caminho de uma em uma.
  -- ---------------------------------------------------------------------------------
  for v_grupo in
    select o.value ->> 'table' as tabela, s.assinatura,
           jsonb_agg(o.value || jsonb_build_object('_i', o.ordinality) order by o.ordinality) as ops,
           array_agg(o.ordinality::integer) as ordinais, count(*)::integer as n
      from jsonb_array_elements(p_changes) with ordinality o
      cross join lateral (select string_agg(k, ',' order by k) as assinatura
                            from jsonb_object_keys(case when jsonb_typeof(o.value -> 'data') = 'object' then o.value -> 'data' end) k) s
     where jsonb_typeof(p_changes) = 'array'
       and o.value ->> 'op' = 'PUT'
       and o.value ->> 'table' in ('user_books','reading_positions','bookmarks','ink_layers','annotations',
                                   'highlight_labels','reader_settings','pen_presets','reading_goals')
       and jsonb_typeof(o.value -> 'data') = 'object'
     group by 1, 2
    having count(*) >= 2
  loop
    begin
      if exists (select 1 from jsonb_array_elements(v_grupo.ops) x
                  where coalesce(x ->> 'id', '') !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
                     or coalesce(x ->> 'hlc', '') !~ '^[0-9]{16}-[0-9]{4}-[A-Za-z0-9_-]{1,64}$'
                     or left(x ->> 'hlc', 16)::bigint > v_max_ms) then
        continue;                                    -- recusas individuais no caminho de uma em uma
      end if;
      execute format('select exists (select 1 from personal.%I t where t.id = any ($1) and t.user_id <> $2)', v_grupo.tabela)
        into v_conflito
        using (select array_agg((x ->> 'id')::uuid) from jsonb_array_elements(v_grupo.ops) x), v_uid;
      if v_conflito then continue; end if;            -- id de outra pessoa → id_conflict, uma a uma

      select coalesce(array_agg(a.attname::text), '{}') into v_jcols
        from pg_catalog.pg_attribute a
       where a.attrelid = format('personal.%I', v_grupo.tabela)::regclass
         and a.attnum > 0 and not a.attisdropped and a.atttypid = 'jsonb'::regtype;
      select jsonb_agg(d.linha) into v_linhas from (
        select distinct on (x ->> 'id')
               (x -> 'data')
               || coalesce((select jsonb_object_agg(c, ((x -> 'data') ->> c)::jsonb)
                              from unnest(v_jcols) c where jsonb_typeof((x -> 'data') -> c) = 'string'), '{}'::jsonb)
               || jsonb_build_object('id', x ->> 'id', 'user_id', v_uid, 'version_hlc', x ->> 'hlc') as linha
          from jsonb_array_elements(v_grupo.ops) x
         order by x ->> 'id', (x ->> 'hlc') collate "C" desc, (x ->> '_i')::integer) d;   -- empate: a 1ª da lista

      select string_agg(quote_ident(a.attname), ', ' order by a.attnum),
             string_agg(format('%1$I = excluded.%1$I', a.attname), ', ' order by a.attnum)
               filter (where a.attname not in ('id','user_id','created_at','started_at'))
        into v_cols, v_set
        from pg_catalog.pg_attribute a
       where a.attrelid = format('personal.%I', v_grupo.tabela)::regclass
         and a.attnum > 0 and not a.attisdropped
         and a.attname = any (string_to_array(v_grupo.assinatura, ',') || array['id', 'user_id', 'version_hlc']);

      execute format(
        'insert into personal.%1$I as t (%2$s)
           select %2$s from jsonb_populate_recordset(null::personal.%1$I, $1)
         on conflict (id) do update set %3$s
           where t.user_id = $2 and t.version_hlc collate "C" < excluded.version_hlc collate "C"',
        v_grupo.tabela, v_cols, v_set)
        using v_linhas, v_uid;
      get diagnostics v_rows = row_count;
      v_applied := v_applied + v_rows;
      v_skipped := v_skipped + v_grupo.n - v_rows;
      v_feitos := v_feitos || v_grupo.ordinais;
    exception when others then
      if left(sqlstate, 2) in ('40', '53', '57') or sqlstate = '55P03' then
        raise;                                       -- transitório: o lote inteiro falha (o app repete)
      end if;
      -- erro de alguma linha: o grupo é refeito de uma em uma (só a linha ruim é recusada)
    end;
  end loop;

  -- ---------------------------------------------------------------------------------
  -- Caminho de uma em uma (o restante do lote)
  -- ---------------------------------------------------------------------------------
  for v_op in select value from jsonb_array_elements(p_changes) with ordinality
               where not (ordinality::integer = any (v_feitos)) loop
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


-- -------------------------------------------------------------------------------------
-- Permissões (a função foi recriada: os GRANTs continuam, os padrões são revogados de novo)
-- -------------------------------------------------------------------------------------
revoke execute on function public.sync_apply_changes(jsonb) from public, anon;
grant execute on function public.sync_apply_changes(jsonb) to authenticated, service_role;

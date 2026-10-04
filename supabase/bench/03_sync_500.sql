-- =====================================================================================
-- G04.6 — RPC de upload do PowerSync com lotes de 500 operações (Anexo 02 §10: p95 < 400 ms).
-- leitor20 (Pro, 10 livros): 30 lotes de 500 PUT (300 anotações novas, 150 marcadores novos e
-- 50 livros reenviados com versão nova — o formato que o app manda, ADR-003). Cada lote é um
-- comando separado, com o tempo medido no servidor.
-- =====================================================================================
\set ON_ERROR_STOP on
\pset pager off
create temp table tempos (lote int, ms numeric, aplicadas int, recusadas int);
grant all on tempos to authenticated;
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-7000-8000-000000000014', 'role', 'authenticated')::text, false);

create or replace function pg_temp.lote(k int) returns jsonb language sql as $$
  with livros as (
    select id, row_number() over (order by id) r from personal.user_books where user_id = '00000000-0000-7000-8000-000000000014')
  select jsonb_agg(op) from (
    select jsonb_build_object('table', 'annotations', 'op', 'PUT', 'id', gen_random_uuid(),
             'hlc', lpad((1790000000000 + k * 1000 + i)::text, 16, '0') || '-0000-bench',
             'data', jsonb_build_object('user_book_id', (select id from livros where r = 1 + i % 10), 'kind', 'highlight',
               'group_id', gen_random_uuid(), 'anchor', '{"v":1,"spine":3,"start":10,"end":40}', 'ref_page', 1 + i,
               'chapter_index', i % 148, 'color', '#FED170', 'style', 'fill', 'fill_height', 'medium',
               'created_at', now(), 'updated_at', now(), 'deleted_at', null)) op
      from generate_series(1, 300) i
    union all
    select jsonb_build_object('table', 'bookmarks', 'op', 'PUT', 'id', gen_random_uuid(),
             'hlc', lpad((1790000000000 + k * 1000 + 300 + i)::text, 16, '0') || '-0000-bench',
             'data', jsonb_build_object('user_book_id', (select id from livros where r = 1 + i % 10), 'locator', '{"v":1}',
               'ref_page', i, 'chapter_index', i % 148, 'excerpt', 'trecho', 'created_at', now(), 'updated_at', now()))
      from generate_series(1, 150) i
    union all
    select jsonb_build_object('table', 'user_books', 'op', 'PUT', 'id', l.id,
             'hlc', lpad((1790000000000 + k * 1000 + 450 + i)::text, 16, '0') || '-0000-bench',
             'data', jsonb_build_object('title', 'Livro reenviado', 'author_display', 'Autor', 'format', 'epub', 'status', 'reading',
               'added_at', now(), 'created_at', now(), 'updated_at', now()))
      from generate_series(1, 50) i join livros l on l.r = 1 + i % 10) x
$$;

set role authenticated;
do $$
declare k int; t0 timestamptz; r jsonb; b jsonb;
begin
  for k in 1..30 loop
    b := pg_temp.lote(k);
    t0 := clock_timestamp();
    r := public.sync_apply_changes(b);
    insert into tempos values (k, extract(epoch from clock_timestamp() - t0) * 1000,
                               (r ->> 'applied')::int, jsonb_array_length(r -> 'rejected'));
  end loop;
end $$;
reset role;
select count(*) lotes, sum(aplicadas) aplicadas, sum(recusadas) recusadas,
       round((percentile_cont(0.5) within group (order by ms))::numeric, 1) p50_ms,
       round((percentile_cont(0.95) within group (order by ms))::numeric, 1) p95_ms,
       round(max(ms), 1) max_ms
  from tempos;

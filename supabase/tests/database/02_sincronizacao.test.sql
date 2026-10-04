-- Sincronização Pro (RPC public.sync_apply_changes): fumaça OK 02–06 e 17 do rascunho + casos novos.
begin;
create extension if not exists pgtap with schema extensions;
select plan(26);

-- A = Pro, B = Grátis, C = Grátis
insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000000a', 'pro', now() + interval '27 days');
select private.refresh_sync_access();

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;

-- ---------------------------------------------------------------- OK 02: Pro grava; dono imposto
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');

select is(public.sync_apply_changes($j$[
 {"table":"user_books","op":"PUT","id":"01927a00-0000-7000-8000-000000000001","hlc":"0001726862400000-0000-dev1",
  "data":{"title":"Dom Casmurro","author_display":"Machado de Assis","format":"epub","status":"reading",
          "content_sha256":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
          "ref_pages_total":256,"ref_page_version":1,"chapters_total":148,
          "added_at":"2026-09-01T12:00:00Z","created_at":"2026-09-01T12:00:00Z","updated_at":"2026-09-01T12:00:00Z",
          "user_id":"00000000-0000-7000-8000-00000000000b"}},
 {"table":"annotations","op":"PUT","id":"01927a00-0000-7000-8000-000000000101","hlc":"0001726862400000-0001-dev1",
  "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","kind":"highlight","group_id":"01927a00-0000-7000-8000-000000000201",
          "anchor":{"v":1,"spine":3,"start":120,"end":198,"quote":{"exact":"que eu conheço de vista e de chapéu."}},
          "ref_page":3,"chapter_index":0,"color":"#FED170","style":"fill","fill_height":"medium",
          "created_at":"2026-09-02T22:00:00Z","updated_at":"2026-09-02T22:00:00Z"}},
 {"table":"reading_sessions","op":"PUT","id":"01927a00-0000-7000-8000-000000000301","hlc":"0001726862400000-0002-dev1",
  "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","started_at":"2026-09-20T19:30:00Z","ended_at":"2026-09-20T19:48:00Z",
          "active_seconds":1080,"source":"auto","created_at":"2026-09-20T19:48:00Z","updated_at":"2026-09-20T19:48:00Z"}}
]$j$::jsonb), '{"applied": 3, "skipped": 0, "rejected": []}'::jsonb, 'OK 02 lote do Pro aplicado inteiro');
select is((select count(*)::int from personal.user_books), 1, 'OK 02 A vê o próprio livro');
select is((select user_id from personal.user_books), '00000000-0000-7000-8000-00000000000a'::uuid,
  'OK 02 dono imposto pelo servidor (user_id falsificado foi trocado pelo do token)');

-- ---------------------------------------------------------------- OK 03: last-writer-wins
select is((public.sync_apply_changes($j$[
 {"table":"annotations","op":"PATCH","id":"01927a00-0000-7000-8000-000000000101","hlc":"0001726862300000-0000-dev2","data":{"color":"#FFC1C6"}}
]$j$::jsonb) ->> 'skipped')::int, 1, 'OK 03 escrita mais velha é ignorada (skipped)');
select is((select color from personal.annotations), '#FED170', 'OK 03 LWW: a versão antiga não sobrescreve');
select public.sync_apply_changes($j$[
 {"table":"annotations","op":"PATCH","id":"01927a00-0000-7000-8000-000000000101","hlc":"0001726862500000-0000-dev2","data":{"color":"#ABCF82"}}
]$j$::jsonb);
select is((select color from personal.annotations), '#ABCF82', 'OK 03 LWW: a escrita nova vence');
select is((select version_hlc from personal.annotations), '0001726862500000-0000-dev2', 'OK 03 a versão gravada é a do HLC enviado');

-- ---------------------------------------------------------------- OK 04: DELETE = tombstone
select public.sync_apply_changes($j$[
 {"table":"annotations","op":"DELETE","id":"01927a00-0000-7000-8000-000000000101","hlc":"0001726862600000-0000-dev1"}
]$j$::jsonb);
select ok((select deleted_at is not null from personal.annotations), 'OK 04 DELETE vira tombstone (deleted_at)');
select is((public.sync_apply_changes($j$[
 {"table":"annotations","op":"DELETE","id":"01927a00-0000-7000-8000-000000000101","hlc":"0001726862550000-0000-dev3"}
]$j$::jsonb) ->> 'skipped')::int, 1, 'DELETE com versão mais velha é ignorado');

-- ---------------------------------------------------------------- OK 05: Grátis bloqueado e isolado
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select throws_ok($$ select public.sync_apply_changes('[]'::jsonb) $$, 'P0001', 'pro_required',
  'OK 05 Grátis não sincroniza (pro_required)');
select is((select count(*)::int from personal.user_books), 0, 'OK 05 B não vê livros de A');
select is((select count(*)::int from personal.annotations), 0, 'OK 05 B não vê grifos de A');

-- ---------------------------------------------------------------- OK 06 e validações do lote
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is((public.sync_apply_changes('[{"table":"profiles","op":"PUT","id":"01927a00-0000-7000-8000-000000000999","hlc":"0001726862400000-0000-dev1","data":{}}]'::jsonb)
  -> 'rejected' -> 0 ->> 'code'), '22023', 'OK 06 tabela fora da lista branca recusada');
select throws_ok($$ select public.sync_apply_changes((select jsonb_agg('{}'::jsonb) from generate_series(1, 501))) $$,
  '22023', 'invalid_batch', 'lote com mais de 500 operações recusado inteiro');
select throws_ok($$ select public.sync_apply_changes('{"table":"user_books"}'::jsonb) $$,
  '22023', 'invalid_batch', 'lote que não é lista recusado');
select is((public.sync_apply_changes('[{"table":"bookmarks","op":"MERGE","id":"01927a00-0000-7000-8000-000000000402","hlc":"0001726862400000-0000-dev1","data":{}}]'::jsonb)
  -> 'rejected' -> 0 ->> 'error'), 'invalid_op', 'operação desconhecida recusada');

-- ---------------------------------------------------------------- OK 17: ataques e formatos
reset role;
insert into personal.user_books (id, user_id, title, author_display, format, status, added_at, created_at, updated_at, version_hlc)
values ('01927a00-0000-7000-8000-0000000000c1', '00000000-0000-7000-8000-00000000000c', 'Livro do Caio', 'Autor', 'epub', 'reading',
        now(), now(), now(), '0001726862400000-0000-devc');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is((public.sync_apply_changes($j$[
  {"table":"reading_positions","op":"PUT","id":"01927a00-0000-7000-8000-0000000000c1","hlc":"0001726862400000-0009-dev1",
   "data":{"locator":{"v":1},"ref_page":1,"chapter_index":0,"progression":0.1,"created_at":"2026-09-20T10:00:00Z","updated_at":"2026-09-20T10:00:00Z"}}
]$j$::jsonb) -> 'rejected' -> 0 ->> 'code'), '23503', 'OK 17 referência à linha de outro usuário recusada (FK composta)');
select is((public.sync_apply_changes($j$[
  {"table":"user_books","op":"PUT","id":"01927a00-0000-7000-8000-0000000000c1","hlc":"0001726862400000-0010-dev1",
   "data":{"title":"Roubado","author_display":"X","format":"epub","status":"reading","added_at":"2026-09-20T10:00:00Z","created_at":"2026-09-20T10:00:00Z","updated_at":"2026-09-20T10:00:00Z"}}
]$j$::jsonb) -> 'rejected' -> 0 ->> 'error'), 'id_conflict', 'id de linha de outra pessoa recusado (id_conflict)');
select is((public.sync_apply_changes($j$[
  {"table":"annotations","op":"PATCH","id":"01927a00-0000-7000-8000-000000000101","hlc":"9999999999999999-0000-dev1","data":{"color":"#FFC1C6"}}
]$j$::jsonb) -> 'rejected' -> 0 ->> 'error'), 'invalid_hlc', 'OK 17 HLC do futuro distante recusado');
select is((public.sync_apply_changes(format($j$[
  {"table":"annotations","op":"PATCH","id":"01927a00-0000-7000-8000-000000000101","hlc":"%s-0000-dev1","data":{"color":"#FFC1C6"}}
]$j$, lpad((floor(extract(epoch from clock_timestamp()) * 1000)::bigint + 600000)::text, 16, '0'))::jsonb) -> 'rejected' -> 0 ->> 'error'),
  'invalid_hlc', 'HLC 10 min à frente do relógio do servidor recusado');

select is(public.sync_apply_changes($j$[
    {"table":"bookmarks","op":"PUT","id":"01927a00-0000-7000-8000-000000000401","hlc":"0001726862700000-0000-dev1",
     "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","locator":"{\"v\":1,\"spine\":12,\"offset\":5321}",
             "ref_page":159,"chapter_index":31,"excerpt":"Retórica dos namorados, dá-me uma comparação exata e poética…",
             "created_at":"2026-09-20T22:00:00Z","updated_at":"2026-09-20T22:00:00Z"}},
    {"table":"pen_presets","op":"PUT","id":"00000000-0000-7000-8000-00000000000a","hlc":"0001726862700000-0001-dev1",
     "data":{"pen_color":"vermelho","created_at":"2026-09-20T22:00:00Z","updated_at":"2026-09-20T22:00:00Z"}}
  ]$j$::jsonb) - 'rejected', '{"applied": 1, "skipped": 0}'::jsonb, 'OK 17 lote parcial: a linha inválida não trava a válida');
select is((select jsonb_typeof(locator) from personal.bookmarks where id = '01927a00-0000-7000-8000-000000000401'), 'object',
  'OK 17 JSON que chega como texto (SQLite) vira objeto');
select is(jsonb_array_length(public.sync_apply_changes($j$[
    {"table":"reading_sessions","op":"PATCH","id":"01927a00-0000-7000-8000-000000000301","hlc":"0001726862800000-0000-dev1",
     "data":{"started_at":"2026-09-21T19:30:00Z"}},
    {"table":"reading_sessions","op":"PUT","id":"01927a00-0000-7000-8000-000000000302","hlc":"0001726862800000-0001-dev1",
     "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","started_at":"2031-01-01T10:00:00Z","ended_at":"2031-01-01T10:20:00Z",
             "active_seconds":1200,"source":"auto","created_at":"2026-09-20T22:00:00Z","updated_at":"2026-09-20T22:00:00Z"}},
    {"table":"reading_sessions","op":"PUT","id":"01927a00-0000-7000-8000-000000000303","hlc":"0001726862800000-0002-dev1",
     "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","started_at":"2023-12-31T10:00:00Z","ended_at":"2023-12-31T10:20:00Z",
             "active_seconds":1200,"source":"auto","created_at":"2026-09-20T22:00:00Z","updated_at":"2026-09-20T22:00:00Z"}}
  ]$j$::jsonb) -> 'rejected'), 3, 'OK 17 started_at imutável; sessão no futuro e antes de 2024 recusadas');
select is((select count(*)::int from personal.reading_sessions where id = '01927a00-0000-7000-8000-000000000301'), 1,
  'OK 17 sem linha duplicada de sessão');

-- a partição do mês é criada sob demanda pela RPC (sem partição default)
select is((public.sync_apply_changes(format($j$[
    {"table":"reading_sessions","op":"PUT","id":"01927a00-0000-7000-8000-000000000304","hlc":"0001726862800000-0003-dev1",
     "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","started_at":"%1$s","ended_at":"%1$s",
             "active_seconds":0,"source":"timer","created_at":"%1$s","updated_at":"%1$s"}}
  ]$j$, to_char(now() at time zone 'utc', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'))::jsonb) ->> 'applied')::int, 1, 'sessão de agora entra na partição do mês');

-- sem login
select pg_temp.como(null);
select throws_ok($$ select public.sync_apply_changes('[]'::jsonb) $$, '28000', 'unauthenticated', 'sem login a RPC recusa');

reset role;
select * from finish();
rollback;

-- RPC de sincronização — caminho em LOTE (migration sincronizacao_em_lote): mesmas regras e mesmas
-- recusas do caminho de uma em uma, agora com grupos grandes de PUT.
begin;
create extension if not exists pgtap with schema extensions;
select plan(15);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000000a', 'pro', now() + interval '30 days');
insert into personal.user_books (id, user_id, title, author_display, format, status, added_at, created_at, updated_at, version_hlc) values
  ('01927a00-0000-7000-8000-000000000001', '00000000-0000-7000-8000-00000000000a', 'Livro da Ana', 'X', 'epub', 'reading', now(), now(), now(), '0001790000000000-0000-a'),
  ('01927a00-0000-7000-8000-0000000000c1', '00000000-0000-7000-8000-00000000000c', 'Livro do Caio', 'X', 'epub', 'reading', now(), now(), now(), '0001790000000000-0000-c');
create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
-- n anotações (PUT, linha inteira) do livro da Ana; a âncora vai como TEXTO, como o SQLite manda
create function pg_temp.anotacoes(n int, base bigint, cor text default '#FED170') returns jsonb language sql as $$
  select jsonb_agg(jsonb_build_object('table', 'annotations', 'op', 'PUT',
           'id', ('01927a00-0000-7000-8000-' || lpad(to_hex(1000 + i), 12, '0'))::uuid,
           'hlc', lpad((base + i)::text, 16, '0') || '-0000-dev1',
           'data', jsonb_build_object('user_book_id', '01927a00-0000-7000-8000-000000000001', 'kind', 'highlight',
             'group_id', gen_random_uuid(), 'anchor', '{"v":1,"spine":3}', 'ref_page', i, 'chapter_index', 0,
             'color', case when i = 7 then cor else '#FED170' end, 'style', 'fill', 'fill_height', 'medium',
             'created_at', '2026-10-01T00:00:00Z', 'updated_at', '2026-10-01T00:00:00Z', 'deleted_at', null,
             'user_id', '00000000-0000-7000-8000-00000000000a')) order by i)
    from generate_series(1, n) i
$$;

set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');

select is(public.sync_apply_changes(pg_temp.anotacoes(300, 1790000001000)), '{"applied": 300, "skipped": 0, "rejected": []}'::jsonb,
  '300 PUTs da mesma tabela gravados em lote');
select is((select count(*)::int from personal.annotations where user_id = '00000000-0000-7000-8000-00000000000a'), 300,
  'gravadas na conta da sessão (user_id de outra conta é recusado — 19_revisao_g06)');
select is((select count(*)::int from personal.annotations where jsonb_typeof(anchor) = 'object'), 300,
  'âncora em texto vira objeto também no lote');
select is((public.sync_apply_changes(pg_temp.anotacoes(300, 1790000000500)) ->> 'skipped')::int, 300,
  'reenvio com versões mais velhas: tudo ignorado (LWW)');
select is((public.sync_apply_changes(pg_temp.anotacoes(300, 1790000002000)) ->> 'applied')::int, 300,
  'versões mais novas: tudo atualizado');
select is((select min(version_hlc) from personal.annotations), '0001790000002001-0000-dev1', 'a versão gravada é a do lote');

-- uma linha ruim (CHECK de cor) não trava as outras: o grupo é refeito de uma em uma
select is(public.sync_apply_changes(pg_temp.anotacoes(300, 1790000003000, 'vermelho')) - 'rejected',
  '{"applied": 299, "skipped": 0}'::jsonb, 'cor inválida numa linha: 299 gravadas');
select is(jsonb_array_length(public.sync_apply_changes(pg_temp.anotacoes(300, 1790000003000, 'vermelho')) -> 'rejected'), 1,
  'e só ela é recusada');

-- o mesmo id duas vezes no lote: fica a maior versão
select is(public.sync_apply_changes($j$[
  {"table":"bookmarks","op":"PUT","id":"01927a00-0000-7000-8000-000000000b01","hlc":"0001790000004002-0000-dev1",
   "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","locator":{"v":1},"ref_page":2,"chapter_index":0,"excerpt":"nova","created_at":"2026-10-01T00:00:00Z","updated_at":"2026-10-01T00:00:00Z"}},
  {"table":"bookmarks","op":"PUT","id":"01927a00-0000-7000-8000-000000000b01","hlc":"0001790000004001-0000-dev1",
   "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","locator":{"v":1},"ref_page":1,"chapter_index":0,"excerpt":"velha","created_at":"2026-10-01T00:00:00Z","updated_at":"2026-10-01T00:00:00Z"}}
]$j$::jsonb) - 'rejected', '{"applied": 1, "skipped": 1}'::jsonb, 'mesmo id duas vezes: 1 gravado, 1 ignorado');
select is((select excerpt from personal.bookmarks where id = '01927a00-0000-7000-8000-000000000b01'), 'nova', 'vence a maior versão, não a última da lista');
-- prova de que o caminho em lote rodou: de uma em uma, duas versões crescentes do mesmo id contariam
-- "applied: 2"; em lote só a maior é gravada
select is(public.sync_apply_changes($j$[
  {"table":"bookmarks","op":"PUT","id":"01927a00-0000-7000-8000-000000000b02","hlc":"0001790000004101-0000-dev1",
   "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","locator":{"v":1},"ref_page":1,"chapter_index":0,"excerpt":"1","created_at":"2026-10-01T00:00:00Z","updated_at":"2026-10-01T00:00:00Z"}},
  {"table":"bookmarks","op":"PUT","id":"01927a00-0000-7000-8000-000000000b02","hlc":"0001790000004102-0000-dev1",
   "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","locator":{"v":1},"ref_page":1,"chapter_index":0,"excerpt":"2","created_at":"2026-10-01T00:00:00Z","updated_at":"2026-10-01T00:00:00Z"}}
]$j$::jsonb) - 'rejected', '{"applied": 1, "skipped": 1}'::jsonb, 'caminho em lote em uso (versões crescentes do mesmo id: 1 gravada)');

-- id de outra pessoa dentro de um grupo: só ele é recusado (id_conflict)
select is((select array_agg(e ->> 'error') from jsonb_array_elements(public.sync_apply_changes($j$[
  {"table":"user_books","op":"PUT","id":"01927a00-0000-7000-8000-0000000000c1","hlc":"0001790000005001-0000-dev1",
   "data":{"title":"Roubado","author_display":"X","format":"epub","status":"reading","added_at":"2026-10-01T00:00:00Z","created_at":"2026-10-01T00:00:00Z","updated_at":"2026-10-01T00:00:00Z"}},
  {"table":"user_books","op":"PUT","id":"01927a00-0000-7000-8000-000000000001","hlc":"0001790000005002-0000-dev1",
   "data":{"title":"Livro da Ana (editado)","author_display":"X","format":"epub","status":"reading","added_at":"2026-10-01T00:00:00Z","created_at":"2026-10-01T00:00:00Z","updated_at":"2026-10-01T00:00:00Z"}}
]$j$::jsonb) -> 'rejected') e), array['id_conflict'], 'id de outra pessoa no lote: recusado (id_conflict)');
select is((select title from personal.user_books where id = '01927a00-0000-7000-8000-000000000001'), 'Livro da Ana (editado)', 'o resto do grupo é gravado');
reset role;
select is((select title from personal.user_books where id = '01927a00-0000-7000-8000-0000000000c1'), 'Livro do Caio', 'a linha da outra pessoa fica intacta');
set local role authenticated;

-- HLC do futuro num grupo: o grupo vai de uma em uma e só ele é recusado
select is((select array_agg(e ->> 'error') from jsonb_array_elements(public.sync_apply_changes(
  pg_temp.anotacoes(2, 1790000006000) || jsonb_build_array(jsonb_set(pg_temp.anotacoes(1, 9999999999000) -> 0, '{id}', '"01927a00-0000-7000-8000-000000009999"'))
) -> 'rejected') e), array['invalid_hlc'], 'HLC do futuro no lote: só ele é recusado');

reset role;
select * from finish();
rollback;

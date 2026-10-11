-- T04 (D-244) — o cronômetro do livro de papel no servidor, pelo caminho da sincronização do Pro (a RPC de lote da
-- G04/G06): o que o encerramento grava no aparelho (R7) — a sessão `timer`, a posição com o localizador de papel
-- `{"v":1,"kind":"paper","refPage":N}` e o total de páginas e o `last_opened_at` do livro — chega e volta intacto; de
-- outra conta, do Grátis e sem login, não; 86 401 s ativos são recusados (o limite de 24 h da R2). Nenhuma migração
-- nova: o esquema da G04 já aceita tudo isso.
begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

-- A = Pro (o dono do livro de papel), C = Pro (outra conta), G = Grátis
insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com'),
  ('00000000-0000-7000-8000-000000000006', 'gil@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until) values
  ('00000000-0000-7000-8000-00000000000a', 'pro', now() + interval '30 days'),
  ('00000000-0000-7000-8000-00000000000c', 'pro', now() + interval '30 days');
select private.refresh_sync_access();

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;

-- o lote do encerramento (R7): o livro de papel, a sessão de 8 min 42 s e a página 120 de 368 — agora (a partição do
-- mês é criada pela RPC)
create function pg_temp.encerramento(segundos int default 522) returns jsonb language sql as $$
  select format($j$[
   {"table":"user_books","op":"PUT","id":"01927a00-0000-7000-8000-0000000b0001","hlc":"0001726862400000-0000-dev1",
    "data":{"title":"Memórias Póstumas de Brás Cubas","author_display":"Machado de Assis","format":"physical",
            "status":"reading","ref_pages_total":368,"last_opened_at":"%1$s",
            "added_at":"2026-09-01T12:00:00Z","created_at":"2026-09-01T12:00:00Z","updated_at":"%1$s"}},
   {"table":"reading_sessions","op":"PUT","id":"01927a00-0000-7000-8000-0000000b0101","hlc":"0001726862400000-0001-dev1",
    "data":{"user_book_id":"01927a00-0000-7000-8000-0000000b0001","started_at":"%2$s","ended_at":"%1$s",
            "active_seconds":%3$s,"ref_page_to":120,"source":"timer","created_at":"%1$s","updated_at":"%1$s"}},
   {"table":"reading_positions","op":"PUT","id":"01927a00-0000-7000-8000-0000000b0001","hlc":"0001726862400000-0002-dev1",
    "data":{"locator":{"v":1,"kind":"paper","refPage":120},"ref_page":120,"chapter_index":0,"progression":0.32609,
            "created_at":"%1$s","updated_at":"%1$s"}}
  ]$j$,
    to_char(now() at time zone 'utc', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    to_char((now() - interval '9 minutes') at time zone 'utc', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'),
    segundos)::jsonb
$$;

set local role authenticated;

-- ---------------------------------------------------------------- o dono (Pro): aceito e lido de volta intacto
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is(public.sync_apply_changes(pg_temp.encerramento()), '{"applied": 3, "skipped": 0, "rejected": []}'::jsonb,
  'o encerramento do dono: o livro, a sessão timer e a posição de papel gravados');
select is((select (source, active_seconds, ref_page_from, ref_page_to, pages_viewed)::text from personal.reading_sessions
           where id = '01927a00-0000-7000-8000-0000000b0101'),
  '(timer,522,,120,)', 'a sessão volta como foi: timer, 522 s, sem página de início, página 120');
select is((select locator from personal.reading_positions where id = '01927a00-0000-7000-8000-0000000b0001'),
  '{"v":1,"kind":"paper","refPage":120}'::jsonb, 'o localizador de papel volta intacto (objeto, não texto)');
select is((select (ref_page, chapter_index, progression)::text from personal.reading_positions
           where id = '01927a00-0000-7000-8000-0000000b0001'),
  '(120,0,0.32609)', 'a posição: página 120, capítulo 0, progresso 120 ÷ 368 em 5 casas');
select is((select (format, ref_pages_total, last_opened_at is not null)::text from personal.user_books
           where id = '01927a00-0000-7000-8000-0000000b0001'),
  '(physical,368,t)', 'o livro: papel, 368 páginas e o last_opened_at do encerramento (D-260, D-261)');
select is((select user_id from personal.reading_sessions where id = '01927a00-0000-7000-8000-0000000b0101'),
  '00000000-0000-7000-8000-00000000000a'::uuid, 'o dono é o do token');

-- ---------------------------------------------------------------- 24 h: 86 401 s é recusado
select is((public.sync_apply_changes(format($j$[
   {"table":"reading_sessions","op":"PUT","id":"01927a00-0000-7000-8000-0000000b0102","hlc":"0001726862400000-0003-dev1",
    "data":{"user_book_id":"01927a00-0000-7000-8000-0000000b0001","started_at":"%1$s","ended_at":"%1$s",
            "active_seconds":86401,"source":"timer","created_at":"%1$s","updated_at":"%1$s"}}
  ]$j$, to_char(now() at time zone 'utc', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'))::jsonb) -> 'rejected' -> 0 ->> 'code'), '23514',
  '86 401 s ativos: recusada pelo CHECK (o limite de 24 h — R2)');
select is((select count(*)::int from personal.reading_sessions where id = '01927a00-0000-7000-8000-0000000b0102'), 0,
  'e não gravada');
select is((public.sync_apply_changes(format($j$[
   {"table":"reading_sessions","op":"PUT","id":"01927a00-0000-7000-8000-0000000b0103","hlc":"0001726862400000-0004-dev1",
    "data":{"user_book_id":"01927a00-0000-7000-8000-0000000b0001","started_at":"%1$s","ended_at":"%1$s",
            "active_seconds":86400,"source":"timer","created_at":"%1$s","updated_at":"%1$s"}}
  ]$j$, to_char(now() at time zone 'utc', 'YYYY-MM-DD"T"HH24:MI:SS"Z"'))::jsonb) ->> 'applied')::int, 1,
  '86 400 s (o limite exato): aceita');

-- ---------------------------------------------------------------- outra conta (Pro): negado
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from personal.reading_sessions), 0, 'C não lê as sessões de A (RLS)');
select is((select count(*)::int from personal.reading_positions), 0, 'C não lê a posição de A (RLS)');
select is((select array_agg(e ->> 'error' order by e ->> 'error') from jsonb_array_elements(
    public.sync_apply_changes(pg_temp.encerramento()) -> 'rejected') e),
  array['id_conflict', 'id_conflict', 'id_conflict'],
  'o mesmo lote vindo de C: os três recusados (os ids são das linhas de A)');
select is((select ref_page_to from personal.reading_sessions where id = '01927a00-0000-7000-8000-0000000b0101'), null::int,
  'como C, nada aparece (e as linhas de A ficam intactas — conferido abaixo)');
reset role;
select is((select (active_seconds, ref_page_to)::text from personal.reading_sessions
           where id = '01927a00-0000-7000-8000-0000000b0101'), '(522,120)', 'a sessão de A intacta');
set local role authenticated;

-- ---------------------------------------------------------------- Grátis e sem login: negado
select pg_temp.como('00000000-0000-7000-8000-000000000006');
select throws_ok($$ select public.sync_apply_changes(pg_temp.encerramento()) $$, 'P0001', 'pro_required',
  'o Grátis não sincroniza a sessão do papel (os dados dele não saem do aparelho)');
select pg_temp.como(null);
select throws_ok($$ select public.sync_apply_changes(pg_temp.encerramento()) $$, '28000', 'unauthenticated',
  'sem login a RPC recusa');

reset role;
select * from finish();
rollback;

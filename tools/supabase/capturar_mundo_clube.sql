-- G21.3 — as respostas reais dos resumos do clube para o mundo das pranchas (como a Marina), gravadas em
-- test/fixtures/clube/*.json para os testes do app (o formato que o servidor devolve de verdade). Roda numa
-- transação desfeita no fim: o banco local não fica com o mundo. Uso (na raiz, no WSL):
--   psql "$DB_URL" -X -q -f tools/supabase/capturar_mundo_clube.sql
\set ON_ERROR_STOP on
\pset tuples_only on
\pset format unaligned
begin;
\ir ../../supabase/tests/database/_mundo_clube.psql
select set_config('request.jwt.claims', json_build_object('sub', pg_temp.leitora(3), 'role', 'authenticated')::text, true);
set local role authenticated;
\o test/fixtures/clube/my_clubs.json
select jsonb_pretty(public.my_clubs());
\o test/fixtures/clube/club_overview.json
select jsonb_pretty(public.club_overview('00000000-0000-7000-8000-00000c200001'));
\o test/fixtures/clube/week_thread.json
select jsonb_pretty(public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'likes', null, null, 3));
\o test/fixtures/clube/meeting_overview.json
select jsonb_pretty(public.meeting_overview('00000000-0000-7000-8000-00000c400002'));
\o test/fixtures/clube/club_members_overview.json
select jsonb_pretty(public.club_members_overview('00000000-0000-7000-8000-00000c200001'));
\o test/fixtures/clube/club_post_summaries.json
select jsonb_pretty(public.club_post_summaries(array['00000000-0000-7000-8000-00000c600008',
  '00000000-0000-7000-8000-00000c600001']::uuid[]));
\o test/fixtures/clube/my_terms.json
select jsonb_pretty(public.my_terms());
\o
rollback;

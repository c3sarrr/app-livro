-- =====================================================================================
-- G21.1 — o tempo dos resumos do clube sobre o clube grande (04_clube_grande.sql), como uma leitora
-- (papel authenticated + JWT). Metas do Anexo 02 §10: o feed < 30 ms; as respostas < 20 ms.
-- Cada resumo roda 7 vezes; vale a mediana (a 1ª esquenta o cache).
-- =====================================================================================
\set ON_ERROR_STOP on
\pset pager off
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-7000-8000-00000b100007', 'role', 'authenticated')::text, false);
set role authenticated;
create temp table tempos (rpc text, ms numeric);
do $$
declare
  t0 timestamptz; v jsonb; c jsonb;
  ids uuid[] := array(select id from public.club_posts where kind = 'shared_highlight' limit 100)
                || array(select id from public.club_posts where kind = 'question' limit 20)
                || array(select gen_random_uuid() from generate_series(1, 80));
begin
  for i in 1 .. 7 loop
    t0 := clock_timestamp(); v := public.my_clubs();
    insert into tempos values ('my_clubs', extract(epoch from clock_timestamp() - t0) * 1000);
    t0 := clock_timestamp(); v := public.club_overview('00000000-0000-7000-8000-00000b200001');
    insert into tempos values ('club_overview', extract(epoch from clock_timestamp() - t0) * 1000);
    t0 := clock_timestamp(); v := public.week_thread('00000000-0000-7000-8000-00000b200001', 2, 'likes');
    insert into tempos values ('week_thread likes (1ª página)', extract(epoch from clock_timestamp() - t0) * 1000);
    c := v -> 'next_cursor';
    t0 := clock_timestamp(); v := public.week_thread('00000000-0000-7000-8000-00000b200001', 2, 'likes', null, c);
    insert into tempos values ('week_thread likes (2ª página)', extract(epoch from clock_timestamp() - t0) * 1000);
    t0 := clock_timestamp(); v := public.week_thread('00000000-0000-7000-8000-00000b200001', 2, 'recent');
    insert into tempos values ('week_thread recent', extract(epoch from clock_timestamp() - t0) * 1000);
    t0 := clock_timestamp();
    v := public.meeting_overview((select id from public.club_meetings where week_no = 2 and reading_id = '00000000-0000-7000-8000-00000b300001'));
    insert into tempos values ('meeting_overview', extract(epoch from clock_timestamp() - t0) * 1000);
    t0 := clock_timestamp(); v := public.club_members_overview('00000000-0000-7000-8000-00000b200001');
    insert into tempos values ('club_members_overview', extract(epoch from clock_timestamp() - t0) * 1000);
    t0 := clock_timestamp(); v := public.club_post_summaries(ids);
    insert into tempos values ('club_post_summaries (200 ids)', extract(epoch from clock_timestamp() - t0) * 1000);
  end loop;
end $$;
select rpc, round(percentile_cont(0.5) within group (order by ms)::numeric, 1) as mediana_ms,
       round(max(ms), 1) as pior_ms
  from tempos group by rpc order by rpc;

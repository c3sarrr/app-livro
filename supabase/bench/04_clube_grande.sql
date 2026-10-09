-- =====================================================================================
-- G21.1 — um clube grande para medir os resumos (Anexo 02 §10): 50 leitoras, o Dom Casmurro em 6
-- semanas, um encontro por semana com as 50 presenças, 20 perguntas, 2.000 respostas (1.000 na pergunta
-- da semana 2, com 200 filhas), 100 grifos compartilhados (30 do mesmo trecho) e 1.500 curtidas.
-- Roda como postgres no banco LOCAL (sem RLS); o medir_clube.sh recria o banco antes e depois.
-- Ids: 00000b10NNNN as leitoras; 00000b200001 o clube; 00000b300001 a leitura.
-- =====================================================================================
\set ON_ERROR_STOP on
create function pg_temp.l(n integer) returns uuid language sql immutable as $$
  select ('00000000-0000-7000-8000-00000b10' || lpad(n::text, 4, '0'))::uuid
$$;
insert into catalog.works (id, title) values ('00000000-0000-7000-8000-00000b0a0002', 'Dom Casmurro');
insert into catalog.editions (id, work_id, isbn13, title, pages, source)
values ('00000000-0000-7000-8000-00000b0a0003', '00000000-0000-7000-8000-00000b0a0002', '9788535900002', 'Dom Casmurro', 256,
        'manual');
insert into auth.users (id, email) select pg_temp.l(n), 'grande' || n || '@bench.local' from generate_series(1, 50) n;
insert into private.account_age (user_id, band, source) select pg_temp.l(n), '18_plus', 'birthdate' from generate_series(1, 50) n;
insert into public.clubs (id, owner_id, name, privacy, meeting_weekday, meeting_time, meeting_minutes, meeting_mode)
values ('00000000-0000-7000-8000-00000b200001', pg_temp.l(1), 'Clube grande', 'invite', 4, '20:00', 90, 'online');
insert into public.club_members (club_id, user_id, progress_ratio, joined_at, last_read_post_at)
select '00000000-0000-7000-8000-00000b200001', pg_temp.l(n), round((n % 97) / 100.0, 2), now() - interval '40 days' + n * interval '1 minute',
       now() - interval '2 days'
  from generate_series(2, 50) n;
insert into public.club_readings (id, club_id, work_id, edition_id, status, starts_on, weeks)
values ('00000000-0000-7000-8000-00000b300001', '00000000-0000-7000-8000-00000b200001',
        '00000000-0000-7000-8000-00000b0a0002', '00000000-0000-7000-8000-00000b0a0003', 'current', current_date - 10, 6);
insert into public.club_weeks (reading_id, club_id, week_no, from_chapter, to_chapter)
select '00000000-0000-7000-8000-00000b300001', '00000000-0000-7000-8000-00000b200001', k, (k - 1) * 25 + 1, least(k * 25, 148)
  from generate_series(1, 6) k;
insert into public.club_meetings (club_id, reading_id, week_no, starts_at, ends_at, mode, created_by)
select '00000000-0000-7000-8000-00000b200001', '00000000-0000-7000-8000-00000b300001', k,
       now() + (k - 2) * interval '7 days' + interval '4 days', now() + (k - 2) * interval '7 days' + interval '4 days 90 minutes',
       'online', pg_temp.l(1)
  from generate_series(1, 6) k;
insert into public.meeting_rsvps (meeting_id, user_id, club_id, answer)
select m.id, pg_temp.l(n), m.club_id, (array['vou', 'talvez', 'nao_vou'])[(n % 3) + 1]
  from public.club_meetings m, generate_series(1, 50) n where m.club_id = '00000000-0000-7000-8000-00000b200001';
insert into public.club_posts (club_id, author_id, kind, chapter_index, reading_id, week_no, position, status, body, created_at)
select '00000000-0000-7000-8000-00000b200001', pg_temp.l((q % 50) + 1), 'question', least(((q % 6) + 1) * 25, 148) - 1,
       '00000000-0000-7000-8000-00000b300001', (q % 6) + 1, (q / 6) + 1, 'open', 'Pergunta ' || q, now() - interval '10 days'
  from generate_series(0, 19) q;
-- 1.000 respostas na 1ª pergunta da semana 2; 800 espalhadas nas outras; 200 filhas
insert into public.club_post_replies (post_id, author_id, body, likes_count, created_at)
select (select id from public.club_posts where reading_id = '00000000-0000-7000-8000-00000b300001' and week_no = 2
         order by position limit 1), pg_temp.l((i % 50) + 1), 'Resposta ' || i, 0, now() - interval '9 days' + i * interval '10 minutes'
  from generate_series(1, 1000) i;
insert into public.club_post_replies (post_id, author_id, body, created_at)
select p.id, pg_temp.l((i % 50) + 1), 'Resposta ' || i, now() - interval '8 days' + i * interval '5 minutes'
  from generate_series(1, 800) i
  join lateral (select id from public.club_posts where reading_id = '00000000-0000-7000-8000-00000b300001'
                 order by id offset (i % 20) limit 1) p on true;
insert into public.club_post_replies (post_id, author_id, parent_reply_id, body, created_at)
select r.post_id, pg_temp.l((i % 50) + 1), r.id, 'Filha ' || i, now() - interval '1 day' + i * interval '1 minute'
  from generate_series(1, 200) i
  join lateral (select id, post_id from public.club_post_replies where body = 'Resposta ' || (i * 5) and parent_reply_id is null
                 order by created_at limit 1) r on true;
insert into public.club_posts (club_id, author_id, kind, chapter_index, ref_page, quote_text, quote_color, reading_id, week_no,
                               spoiler_ratio, spoiler_page, created_at)
select '00000000-0000-7000-8000-00000b200001', pg_temp.l((g % 50) + 1), 'shared_highlight', 24, 121,
       case when g < 30 then 'olhos de cigana oblíqua e dissimulada' else 'Trecho ' || g end, '#B6ACE4',
       '00000000-0000-7000-8000-00000b300001', 1, 0.47, 121, now() - g * interval '1 hour'
  from generate_series(0, 99) g;
insert into public.club_likes (target_type, target_id, user_id)
select 'reply', r.id, pg_temp.l(n)
  from (select id, row_number() over (order by created_at) rn from public.club_post_replies
         where club_id = '00000000-0000-7000-8000-00000b200001' and parent_reply_id is null limit 100) r,
       generate_series(1, 15) n;
analyze public.club_members, public.club_meetings, public.meeting_rsvps, public.club_posts, public.club_post_replies, public.club_likes;

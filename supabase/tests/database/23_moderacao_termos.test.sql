-- G21.2 — termos pelo servidor (D-222), bloqueio dentro do clube (D-223), quem modera, a fila com o conteúdo
-- denunciado e o e-mail do dia (D-52, D-220, D-221). docs/progresso/G21.md §2.
begin;
create extension if not exists pgtap with schema extensions;
select plan(44);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-0000000000a1', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000b2', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000c3', 'caio@exemplo.com');
insert into private.account_age (user_id, band, source)
select id, '18_plus', 'birthdate' from auth.users on conflict (user_id) do nothing;
insert into catalog.works (id, title) values ('00000000-0000-7000-8000-00000000e001', 'Dom Casmurro');
insert into catalog.editions (id, work_id, isbn13, title, source) values
  ('00000000-0000-7000-8000-00000000e002', '00000000-0000-7000-8000-00000000e001', '9788535902778', 'Dom Casmurro', 'manual');

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;

-- o clube da Ana (Bia e Caio dentro), a leitura com 1 semana e o encontro dela; um post de cada e a resposta do Caio
insert into public.clubs (id, owner_id, name) values
  ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000a1', 'Clube da Ana');
insert into public.club_members (club_id, user_id) values
  ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000b2'),
  ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000c3');
insert into public.club_readings (id, club_id, edition_id, work_id, starts_on, weeks) values
  ('00000000-0000-7000-8000-00000000f002', '00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-00000000e002',
   '00000000-0000-7000-8000-00000000e001', current_date, 1);
insert into public.club_weeks (reading_id, club_id, week_no, from_chapter, to_chapter) values
  ('00000000-0000-7000-8000-00000000f002', '00000000-0000-7000-8000-00000000f001', 1, 1, 10);
insert into public.club_meetings (id, club_id, reading_id, week_no, starts_at, ends_at, created_by) values
  ('00000000-0000-7000-8000-00000000f003', '00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-00000000f002',
   1, now() + interval '2 days', now() + interval '2 days 90 minutes', '00000000-0000-7000-8000-0000000000a1');
insert into public.club_posts (id, club_id, author_id, kind, chapter_index, body) values
  ('00000000-0000-7000-8000-00000000f0a1', '00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000a1',
   'discussion', 0, 'O post da Ana.'),
  ('00000000-0000-7000-8000-00000000f0b2', '00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000b2',
   'discussion', 0, 'O post da Bia.'),
  ('00000000-0000-7000-8000-00000000f0c3', '00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000c3',
   'discussion', 0, 'O post do Caio, que vai ser denunciado.');
insert into public.club_post_replies (id, post_id, author_id, body) values
  ('00000000-0000-7000-8000-00000000f0c4', '00000000-0000-7000-8000-00000000f0a1', '00000000-0000-7000-8000-0000000000c3',
   'A resposta do Caio.');
insert into public.posts (id, author_id, kind, body) values
  ('00000000-0000-7000-8000-00000000f0a5', '00000000-0000-7000-8000-0000000000a1', 'review', 'A resenha da Ana.');

-- ---------------------------------------------------------------- termos (D-222)
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select is(public.my_terms(), '{"version": "2026-10-provisorio", "accepted": false}'::jsonb, 'my_terms: ainda não aceitou');
select throws_ok($$ insert into public.posts (author_id, kind, body)
                    values ('00000000-0000-7000-8000-0000000000b2', 'review', 'Resenha') $$,
  'P0001', 'terms_required', 'sem aceitar, não publica resenha');
select throws_ok($$ insert into public.post_comments (post_id, author_id, body)
                    values ('00000000-0000-7000-8000-00000000f0a5', '00000000-0000-7000-8000-0000000000b2', 'Oi') $$,
  'P0001', 'terms_required', 'nem comenta');
select throws_ok($$ insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-0000000000b2', 'Clube') $$,
  'P0001', 'terms_required', 'nem cria clube direto');
select throws_ok($$ select public.create_club(jsonb_build_object('name', 'Clube', 'reading', jsonb_build_object(
                      'edition_id', '00000000-0000-7000-8000-00000000e002', 'weeks', '[{"from": 1, "to": 10}]'::jsonb))) $$,
  'P0001', 'terms_required', 'nem pelo create_club');
select throws_ok($$ insert into public.club_posts (club_id, author_id, kind, chapter_index, body)
                    values ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000b2', 'discussion', 0, 'Oi') $$,
  'P0001', 'terms_required', 'nem posta no clube');
select throws_ok($$ insert into public.club_post_replies (post_id, author_id, body)
                    values ('00000000-0000-7000-8000-00000000f0a1', '00000000-0000-7000-8000-0000000000b2', 'Oi') $$,
  'P0001', 'terms_required', 'nem responde');
select throws_ok($$ select public.suggest_question('00000000-0000-7000-8000-00000000f001', 1, 'Uma pergunta?') $$,
  'P0001', 'terms_required', 'nem sugere pergunta');
select throws_ok($$ select public.share_highlight('00000000-0000-7000-8000-00000000f001', 'Um trecho.', '#B6ACE4', 3, 1, 0.1) $$,
  'P0001', 'terms_required', 'nem compartilha grifo');
select throws_ok($$ select public.set_rsvp('00000000-0000-7000-8000-00000000f003', 'vou', 'Chego tarde.') $$,
  'P0001', 'terms_required', 'nem manda recado');
select lives_ok($$ select public.set_rsvp('00000000-0000-7000-8000-00000000f003', 'vou') $$,
  'presença sem recado não é publicação');
select throws_ok($$ select public.accept_terms('2025-velha') $$, '22023', 'stale_terms', 'só aceita a versão atual');
select lives_ok($$ select public.accept_terms('2026-10-provisorio') $$, 'aceita os termos');
select is(public.my_terms(), '{"version": "2026-10-provisorio", "accepted": true}'::jsonb, 'my_terms: aceitou');
select lives_ok($$ insert into public.posts (author_id, kind, body)
                   values ('00000000-0000-7000-8000-0000000000b2', 'review', 'Resenha') $$, 'aceitou: publica resenha');
select lives_ok($$ insert into public.club_posts (club_id, author_id, kind, chapter_index, body)
                   values ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000b2', 'discussion', 0, 'Oi') $$,
  'e posta no clube');
select lives_ok($$ select public.set_rsvp('00000000-0000-7000-8000-00000000f003', 'vou', 'Chego tarde.') $$,
  'e manda recado');
reset role;
update private.settings set value = '2026-11' where key = 'terms_version';
set local role authenticated;
select throws_ok($$ insert into public.club_posts (club_id, author_id, kind, chapter_index, body)
                    values ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000b2', 'discussion', 0, 'Oi') $$,
  'P0001', 'terms_required', 'versão nova: pede de novo');
select lives_ok($$ select public.accept_terms('2026-11') $$, 'aceita a nova');
reset role;
select is((select array_agg(version order by version) from private.terms_acceptances
            where user_id = '00000000-0000-7000-8000-0000000000b2'), array['2026-10-provisorio', '2026-11'],
  'o histórico guarda as duas versões (LGPD)');
select set_config('request.jwt.claims', '', true);
select lives_ok($$ insert into public.club_posts (club_id, author_id, kind, chapter_index, body)
                   values ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000c3', 'discussion', 0, 'Rotina') $$,
  'rotina do servidor (sem usuário no JWT) não é barrada');
select set_config('request.jwt.claims', '{"role": "authenticated"}', true);
select throws_ok($$ select public.accept_terms('2026-11') $$, '28000', 'unauthenticated', 'sem conta, nada');

-- ---------------------------------------------------------------- bloqueio dentro do clube (D-223)
insert into private.terms_acceptances (user_id, version) select id, '2026-11' from auth.users on conflict do nothing;
insert into public.club_likes (target_type, target_id, user_id)
values ('post', '00000000-0000-7000-8000-00000000f0b2', '00000000-0000-7000-8000-0000000000c3');
insert into public.user_blocks (blocker_id, blocked_id)
values ('00000000-0000-7000-8000-0000000000a1', '00000000-0000-7000-8000-0000000000c3');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select is((select count(*)::int from public.club_posts where author_id = '00000000-0000-7000-8000-0000000000c3'), 0,
  'a Ana bloqueou o Caio: não vê os posts dele no clube');
select is((select count(*)::int from public.club_post_replies where author_id = '00000000-0000-7000-8000-0000000000c3'), 0,
  'nem as respostas');
select is((select count(*)::int from public.club_likes where user_id = '00000000-0000-7000-8000-0000000000c3'), 0,
  'nem as curtidas');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select is((select count(*)::int from public.club_posts where author_id = '00000000-0000-7000-8000-0000000000a1'), 0,
  'e o Caio não vê os da Ana (nos dois sentidos)');
select throws_ok($$ insert into public.club_post_replies (post_id, author_id, body)
                    values ('00000000-0000-7000-8000-00000000f0a1', '00000000-0000-7000-8000-0000000000c3', 'Oi') $$,
  'P0001', 'blocked', 'nem responde a ela, mesmo sabendo o id');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select is((select count(*)::int from public.club_posts where author_id = '00000000-0000-7000-8000-0000000000c3'), 2,
  'a Bia, que não bloqueou ninguém, vê os do Caio');
reset role;
delete from public.user_blocks where blocker_id = '00000000-0000-7000-8000-0000000000a1';
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select is((select count(*)::int from public.club_posts where author_id = '00000000-0000-7000-8000-0000000000c3'), 2,
  'desbloqueou: tudo volta');

-- ---------------------------------------------------------------- quem modera e o e-mail do dia (D-220, D-221)
reset role;
select set_config('request.jwt.claims', '', true);
select ok(not private.is_moderator('00000000-0000-7000-8000-0000000000a1'), 'quem não está na lista não modera');
insert into private.moderators (user_id) values
  ('00000000-0000-7000-8000-0000000000a1'), ('00000000-0000-7000-8000-0000000000b2');
select ok(private.is_moderator('00000000-0000-7000-8000-0000000000a1'), 'na lista, modera');
select is(private.queue_moderation_digest(), 0, 'sem denúncia aberta, nenhum e-mail');
select is((select count(*)::int from private.email_outbox where template = 'moderation_digest'), 0, 'e nada na fila');
insert into public.content_reports (reporter_id, target_type, target_id, reason, created_at) values
  ('00000000-0000-7000-8000-0000000000b2', 'club_post', '00000000-0000-7000-8000-00000000f0c3', 'spam',
   now() - interval '25 hours'),
  ('00000000-0000-7000-8000-0000000000b2', 'club_post_reply', '00000000-0000-7000-8000-00000000f0c4', 'harassment',
   now() - interval '2 hours'),
  ('00000000-0000-7000-8000-0000000000c3', 'club', '00000000-0000-7000-8000-00000000f001', 'other',
   now() - interval '1 hour');
select is(jsonb_array_length(private.moderation_snapshot()), 3, 'a fila tem as 3 abertas');
select is(private.moderation_snapshot() -> 0 ->> 'content', 'O post do Caio, que vai ser denunciado.',
  'a mais antiga primeiro, com o texto denunciado');
select is(private.moderation_snapshot() -> 0 ->> 'sla_breached', 'true', 'e passou de 24 h');
select is(private.moderation_snapshot() -> 0 ->> 'age_hours', '25', 'há 25 h');
select is(private.moderation_snapshot() -> 1 ->> 'content', 'A resposta do Caio.', 'a resposta denunciada');
select is(private.moderation_snapshot() -> 1 ->> 'sla_breached', 'false', 'dentro do prazo');
select is(private.moderation_snapshot() -> 2 ->> 'content', 'Clube da Ana', 'o clube denunciado');
select is(private.queue_moderation_digest(), 2, 'um e-mail para cada pessoa que modera');
select is((select array_agg(payload - 'oldest' order by user_id) from private.email_outbox where template = 'moderation_digest'),
  array['{"open": 3, "breached": 1}'::jsonb, '{"open": 3, "breached": 1}'::jsonb], 'as contagens no e-mail');
select is((select count(*)::int from cron.job where jobname = 'booknest-moderacao-diaria' and schedule = '0 12 * * *'), 1,
  'o agendamento diário às 9h de Brasília');
select is((select count(*)::int from private.email_outbox where template = 'moderation_digest' and payload ? 'oldest'), 2,
  'com a data da mais antiga');

select * from finish();
rollback;

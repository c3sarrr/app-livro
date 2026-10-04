-- Pendências do SQL fechadas na G04: encontros com fuso, notificações criadas pelo banco,
-- moderação (denúncia única, fila, decisão, termos proibidos).
begin;
create extension if not exists pgtap with schema extensions;
select plan(29);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com');
update public.profiles set handle = 'caio', visibility = 'private' where id = '00000000-0000-7000-8000-00000000000c';
create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
insert into public.clubs (id, owner_id, name) values ('01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000b', 'Clube X');
insert into public.club_members (club_id, user_id) values ('01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000a');

-- ---------------------------------------------------------------- encontros com fuso
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select lives_ok($$ insert into public.club_meetings (club_id, starts_at, created_by, timezone)
  values ('01927a00-0000-7000-8000-0000000000f1', now() + interval '24 hours', '00000000-0000-7000-8000-00000000000b', 'Europe/Lisbon') $$,
  'encontro com fuso IANA válido');
select is((select timezone from public.club_meetings), 'Europe/Lisbon', 'o fuso do encontro fica gravado');
select throws_ok($$ insert into public.club_meetings (club_id, starts_at, created_by, timezone)
  values ('01927a00-0000-7000-8000-0000000000f1', now(), '00000000-0000-7000-8000-00000000000b', 'Brasilia/Centro') $$,
  '22023', 'invalid_timezone', 'fuso inválido recusado');
insert into public.club_meetings (club_id, starts_at, created_by)
values ('01927a00-0000-7000-8000-0000000000f1', now() + interval '10 days', '00000000-0000-7000-8000-00000000000b');
select is((select timezone from public.club_meetings where starts_at > now() + interval '9 days'), 'America/Sao_Paulo',
  'sem fuso informado vale America/Sao_Paulo');
select throws_ok($$ update public.profiles set timezone = 'GMT-3 do Brasil' where id = '00000000-0000-7000-8000-00000000000b' $$,
  '22023', 'invalid_timezone', 'fuso do perfil também é validado');
reset role;

-- ---------------------------------------------------------------- lembrete de encontro
select is(private.queue_meeting_reminders(), 1, 'lembrete do encontro de amanhã enfileirado');
select is((select count(*)::int from public.notifications where type = 'club_meeting'), 2, 'os 2 membros recebem o lembrete');
select is(private.queue_meeting_reminders(), 0, 'cada encontro é lembrado uma vez só');
update public.club_meetings set starts_at = now() + interval '23 hours 30 minutes' where timezone = 'Europe/Lisbon';
select is(private.queue_meeting_reminders(), 1, 'encontro remarcado ganha lembrete novo');
delete from public.notifications;

-- ---------------------------------------------------------------- notificações automáticas
insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000a', '00000000-0000-7000-8000-00000000000b');
select is((select type from public.notifications where user_id = '00000000-0000-7000-8000-00000000000b'), 'follow', 'seguir perfil aberto → "follow" para quem foi seguido');
insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000a', '00000000-0000-7000-8000-00000000000c');
select is((select type from public.notifications where user_id = '00000000-0000-7000-8000-00000000000c'), 'follow_request', 'perfil fechado → "follow_request"');
update public.follows set status = 'accepted' where followee_id = '00000000-0000-7000-8000-00000000000c';
select is((select payload ->> 'accepted' from public.notifications where user_id = '00000000-0000-7000-8000-00000000000a' and type = 'follow'), 'true',
  'pedido aceito → aviso para quem pediu');
insert into public.posts (id, author_id, kind, body) values ('01927a00-0000-7000-8000-0000000000b1', '00000000-0000-7000-8000-00000000000b', 'review', 'Resenha');
insert into public.post_likes (post_id, user_id) values ('01927a00-0000-7000-8000-0000000000b1', '00000000-0000-7000-8000-00000000000a');
insert into public.post_comments (post_id, author_id, body) values ('01927a00-0000-7000-8000-0000000000b1', '00000000-0000-7000-8000-00000000000a', 'boa');
insert into public.post_likes (post_id, user_id) values ('01927a00-0000-7000-8000-0000000000b1', '00000000-0000-7000-8000-00000000000b');
select is((select array_agg(type order by type) from public.notifications where user_id = '00000000-0000-7000-8000-00000000000b' and post_id is not null),
  array['post_comment', 'post_like'], 'curtida e comentário notificam o autor — curtir o próprio post não');
insert into public.club_posts (id, club_id, author_id, kind, chapter_index, body)
values ('01927a00-0000-7000-8000-0000000000e1', '01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000b', 'discussion', 1, 'oi');
insert into public.club_post_replies (post_id, author_id, body) values ('01927a00-0000-7000-8000-0000000000e1', '00000000-0000-7000-8000-00000000000a', 'olá');
select is((select club_id from public.notifications where type = 'club_reply'), '01927a00-0000-7000-8000-0000000000f1'::uuid, 'resposta no clube notifica o autor do post (com o clube)');
insert into public.user_blocks (blocker_id, blocked_id) values ('00000000-0000-7000-8000-00000000000b', '00000000-0000-7000-8000-00000000000a');
delete from public.post_likes where user_id = '00000000-0000-7000-8000-00000000000a';
-- (a curtida anterior "envelhece" 2 dias: sem isso a regra de 1 notificação por dia esconderia o bloqueio)
update public.notifications set created_at = created_at - interval '2 days' where type = 'post_like';
insert into public.post_likes (post_id, user_id) values ('01927a00-0000-7000-8000-0000000000b1', '00000000-0000-7000-8000-00000000000a');
select is((select count(*)::int from public.notifications where type = 'post_like'), 1, 'quem bloqueou não recebe notificação do bloqueado');
select ok((select bool_and(push_sent_at is null) from public.notifications), 'notificação nova aguarda o push (push_sent_at nulo)');

-- ---------------------------------------------------------------- moderação
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
insert into public.content_reports (reporter_id, target_type, target_id, reason)
values ('00000000-0000-7000-8000-00000000000a', 'post', '01927a00-0000-7000-8000-0000000000b1', 'spam');
select throws_ok($$ insert into public.content_reports (reporter_id, target_type, target_id, reason)
  values ('00000000-0000-7000-8000-00000000000a', 'post', '01927a00-0000-7000-8000-0000000000b1', 'hate') $$,
  '23505', null, 'uma denúncia aberta por pessoa e alvo');
select throws_ok($$ select 1 from public.content_reports $$, '42501', null, 'quem denuncia não lê a fila de denúncias');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
insert into public.content_reports (reporter_id, target_type, target_id, reason)
values ('00000000-0000-7000-8000-00000000000c', 'post', '01927a00-0000-7000-8000-0000000000b1', 'harassment');
reset role;
select is((select reports_for_target::int from private.moderation_queue limit 1), 2, 'fila: 2 denúncias do mesmo alvo');
select ok(not (select bool_or(sla_breached) from private.moderation_queue), 'fila: dentro do prazo de 24 h');
update public.content_reports set created_at = now() - interval '25 hours' where reporter_id = '00000000-0000-7000-8000-00000000000a';
select ok((select bool_or(sla_breached) from private.moderation_queue), 'fila: denúncia com mais de 24 h fica marcada');
select throws_ok($$ select private.moderate_report((select id from public.content_reports limit 1), 'apagar_tudo', 'mod') $$,
  '22023', 'invalid_decision', 'decisão desconhecida recusada');
select private.moderate_report((select id from public.content_reports where reporter_id = '00000000-0000-7000-8000-00000000000a'), 'hide', 'moderadora@booknest', 'spam evidente');
select ok((select deleted_at is not null from public.posts where id = '01927a00-0000-7000-8000-0000000000b1'), '"hide" oculta o post denunciado');
select is((select count(*)::int from public.content_reports where status = 'actioned'), 2, '"hide" encerra todas as denúncias abertas do alvo');
select throws_ok($$ select private.moderate_report((select id from public.content_reports limit 1), 'dismiss', 'mod') $$,
  'P0001', 'report_not_open', 'denúncia encerrada não é decidida de novo');

-- termos proibidos (lista gerenciada pela equipe; aqui um termo de teste)
insert into private.blocked_terms (term) values ('palavrao');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select throws_ok($$ insert into public.posts (author_id, kind, body) values ('00000000-0000-7000-8000-00000000000a', 'review', 'Que PALAVRÃO!') $$,
  'P0001', 'content_blocked', 'termo proibido barrado (sem acento, sem caixa)');
select lives_ok($$ insert into public.posts (author_id, kind, body) values ('00000000-0000-7000-8000-00000000000a', 'review', 'palavraozinho é outra palavra') $$,
  'casa só a palavra inteira');
select lives_ok($$ insert into public.posts (author_id, kind, quote_text) values ('00000000-0000-7000-8000-00000000000a', 'quote', 'um palavrão do livro') $$,
  'trecho do livro (quote_text) não é filtrado');
select throws_ok($$ update public.profiles set bio = 'sou palavrao' where id = '00000000-0000-7000-8000-00000000000a' $$,
  'P0001', 'content_blocked', 'vale também para a bio do perfil');
reset role;

select * from finish();
rollback;

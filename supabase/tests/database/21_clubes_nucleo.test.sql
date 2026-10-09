-- G21.1 — o núcleo do clube (docs/progresso/G21.md §1): o livro em semanas, um encontro por semana, a presença com
-- recado, as perguntas na ordem da anfitriã, as respostas em um nível, as curtidas, a cor de cada leitora, o
-- progresso publicado, o grifo compartilhado e as permissões (cada caso permitido com o negado ao lado).
begin;
create extension if not exists pgtap with schema extensions;
select plan(68);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-0000000000a1', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000b2', 'julia@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000c3', 'caio@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000d4', 'rafa@exemplo.com');
-- G21.2 (D-222): publicar exige os termos aceitos; aqui todos aceitaram a versão atual
insert into private.terms_acceptances (user_id, version) select id, private.terms_version() from auth.users
on conflict do nothing;
insert into private.account_age (user_id, band, source)
select id, '18_plus', 'birthdate' from auth.users on conflict (user_id) do nothing;
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-0000000000a1', 'pro', now() + interval '27 days');
insert into catalog.works (id, title) values ('00000000-0000-7000-8000-00000000e001', 'Dom Casmurro');
insert into catalog.editions (id, work_id, isbn13, title, pages, source) values
  ('00000000-0000-7000-8000-00000000e002', '00000000-0000-7000-8000-00000000e001', '9788535902778', 'Dom Casmurro', 256,
   'manual');

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
-- o Dom Casmurro em 6 semanas (caps. 1–25 … 126–148), às quintas 20h por 90 min, online, a partir de amanhã
create function pg_temp.clube(p_nome text) returns jsonb language sql as $$
  select jsonb_build_object(
    'name', p_nome, 'name_highlight', case when position('Capitu' in p_nome) > 0 then 'Capitu' end,
    'category', 'Clássicos brasileiros', 'privacy', 'invite',
    'meeting', jsonb_build_object('weekday', 4, 'time', '20:00', 'minutes', 90, 'mode', 'online',
                                  'timezone', 'America/Sao_Paulo'),
    'reading', jsonb_build_object('edition_id', '00000000-0000-7000-8000-00000000e002', 'starts_on', current_date + 1,
      'weeks', jsonb_build_array(
        jsonb_build_object('from', 1, 'to', 25), jsonb_build_object('from', 26, 'to', 50),
        jsonb_build_object('from', 51, 'to', 75), jsonb_build_object('from', 76, 'to', 100),
        jsonb_build_object('from', 101, 'to', 125), jsonb_build_object('from', 126, 'to', 148))))
$$;

create temp table t (club uuid, reading uuid) on commit drop;
create temp table t_code (code text) on commit drop;
create temp table t_q (id uuid, n int) on commit drop;
create temp table t_s (id uuid, quem text) on commit drop;
create temp table t_r (id uuid, quem text) on commit drop;
grant all on t, t_code, t_q, t_s, t_r to authenticated;

-- ---------------------------------------------------------------- create_club
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select lives_ok($$ insert into t (club) select public.create_club(pg_temp.clube('Leitoras de Capitu')) $$,
  'create_club cria o clube');
reset role;
update t set reading = (select r.id from public.club_readings r where r.club_id = t.club);
create temp table t_m on commit drop as
  select m.id, m.week_no from public.club_meetings m where m.reading_id = (select reading from t);
grant select on t_m to authenticated;

select is((select status from public.club_readings where id = (select reading from t)), 'current',
  'a leitura nasce atual');
select is((select work_id from public.club_readings where id = (select reading from t)),
  '00000000-0000-7000-8000-00000000e001'::uuid, 'a obra vem da edição (D-213)');
select results_eq(
  $$ select week_no, from_chapter, to_chapter from public.club_weeks where reading_id = (select reading from t)
      order by week_no $$,
  $$ values (1, 1, 25), (2, 26, 50), (3, 51, 75), (4, 76, 100), (5, 101, 125), (6, 126, 148) $$,
  'as 6 semanas contíguas');
select results_eq(
  $$ select week_no, extract(dow from starts_at at time zone 'America/Sao_Paulo')::int,
            to_char(starts_at at time zone 'America/Sao_Paulo', 'HH24:MI'),
            (extract(epoch from ends_at - starts_at) / 60)::int, until_chapter, mode
       from public.club_meetings where reading_id = (select reading from t) order by week_no $$,
  $$ values (1, 4, '20:00', 90, 25, 'online'), (2, 4, '20:00', 90, 50, 'online'), (3, 4, '20:00', 90, 75, 'online'),
            (4, 4, '20:00', 90, 100, 'online'), (5, 4, '20:00', 90, 125, 'online'),
            (6, 4, '20:00', 90, 148, 'online') $$,
  'um encontro por semana: quinta, 20h de Brasília, 90 min, até o fim da semana');
select is(
  (select array_agg((starts_at at time zone 'America/Sao_Paulo')::date - (current_date + 1) order by week_no)
     from public.club_meetings where reading_id = (select reading from t)),
  (select array_agg(((4 - extract(dow from current_date + 1)::int + 7) % 7) + 7 * k order by k)
     from generate_series(0, 5) k),
  'a 1ª quinta a partir do início e depois de 7 em 7 dias');
select is((select color from public.club_members where club_id = (select club from t) and role = 'owner'), '#B6ACE4',
  'a anfitriã ganha a 1ª cor da paleta');
select hasnt_column('public', 'clubs', 'goal_chapter', 'a meta do clube saiu: é a semana atual');

set local role authenticated;
select throws_ok(
  $$ select public.create_club(jsonb_set(pg_temp.clube('Buraco'), '{reading,weeks,1,from}', '27')) $$,
  '22023', 'invalid_weeks', 'semanas com buraco são recusadas');
select throws_ok(
  $$ select public.create_club(jsonb_set(pg_temp.clube('Treze'), '{reading,weeks}',
       (select jsonb_agg(jsonb_build_object('from', i, 'to', i)) from generate_series(1, 13) i))) $$,
  '22023', 'invalid_weeks', 'mais de 12 semanas são recusadas');
select throws_ok($$ select public.create_club(pg_temp.clube('Sem livro') #- '{reading,edition_id}') $$,
  '22023', 'invalid_book', 'sem livro, nada');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select lives_ok($$ select public.create_club(pg_temp.clube('Clube do Caio')) $$, 'o Grátis cria o 1º clube');
select throws_ok($$ select public.create_club(pg_temp.clube('Segundo do Caio')) $$,
  'P0001', 'free_club_limit', 'o Grátis não cria o 2º, nem pelo create_club');
select set_config('request.jwt.claims', '{"role": "authenticated"}', true);
select throws_ok($$ select public.create_club(pg_temp.clube('Sem conta')) $$,
  '28000', 'unauthenticated', 'sem conta, nada');

-- ---------------------------------------------------------------- convite
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select lives_ok($$ insert into t_code select public.create_invite((select club from t)) $$,
  'a anfitriã cria o convite');
select ok((select code ~ '^[A-Za-z0-9]{8,16}$' from t_code), 'o convite é um código');
select is((select max_uses from public.club_invites where code = (select code from t_code)), 12, 'até 12 pessoas');
select is((select expires_at from public.club_invites where code = (select code from t_code)),
  now() + interval '7 days', 'vale por 7 dias');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select throws_ok($$ select public.create_invite((select club from t)) $$, '42501', 'not_allowed',
  'só a anfitriã convida');
select is(public.join_club((select code from t_code)), (select club from t), 'a Júlia entra pelo convite');
select is((select color from public.club_members
            where club_id = (select club from t) and user_id = '00000000-0000-7000-8000-0000000000b2'),
  '#ABCF82', 'a 2ª leitora ganha a 2ª cor');
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select lives_ok($$ select public.revoke_invite((select code from t_code)) $$, 'a anfitriã desativa o convite');
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
select throws_ok($$ select public.join_club((select code from t_code)) $$, 'P0001', 'invalid_invite',
  'convite desativado não entra');
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
delete from t_code;
insert into t_code select public.create_invite((select club from t), 1, 1);
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
select is(public.join_club((select code from t_code)), (select club from t), 'o Rafa entra por outro convite');

-- ---------------------------------------------------------------- presença e recado
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select is(public.set_rsvp((select id from t_m where week_no = 2), 'vou', 'Saio tarde do trabalho na quinta.', 'host'),
  '{"vou": 1, "talvez": 0, "nao_vou": 0}'::jsonb, 'a Júlia vai; a contagem volta');
select is(public.set_rsvp((select id from t_m where week_no = 2), 'talvez'),
  '{"vou": 0, "talvez": 1, "nao_vou": 0}'::jsonb, 'mudar quando quiser');
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
select is((select count(*)::int from public.meeting_notes), 0, 'o recado "Só a Ana" não aparece para as outras');
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select is((select body from public.meeting_notes), 'Saio tarde do trabalho na quinta.',
  'a anfitriã lê o recado (e mudar a presença sem recado não o apagou)');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select public.set_rsvp((select id from t_m where week_no = 2), 'vou', null, 'club');
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
select is((select count(*)::int from public.meeting_notes), 1, 'o recado "O clube todo" aparece para as outras');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select public.set_rsvp((select id from t_m where week_no = 2), 'vou', '');
reset role;
select is((select count(*)::int from public.meeting_notes where user_id = '00000000-0000-7000-8000-0000000000b2'), 0,
  'recado vazio apaga');
update public.club_meetings set starts_at = now() - interval '3 hours', ends_at = now() - interval '90 minutes'
 where id = (select id from t_m where week_no = 1);
set local role authenticated;
select throws_ok($$ select public.set_rsvp((select id from t_m where week_no = 1), 'vou') $$,
  'P0001', 'meeting_over', 'encontro que já acabou não recebe presença');
select throws_ok($$ select public.set_rsvp((select id from t_m where week_no = 2), 'sim') $$,
  '22023', 'invalid_rsvp', 'resposta fora da lista');
select throws_like(
  $$ insert into public.meeting_rsvps (meeting_id, user_id, club_id, answer)
     values ((select id from t_m where week_no = 2), '00000000-0000-7000-8000-0000000000b2', (select club from t), 'vou') $$,
  '%permission denied%', 'a presença só pela RPC');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select throws_ok($$ select public.set_rsvp((select id from t_m where week_no = 2), 'vou') $$,
  '42501', 'not_member', 'quem não é do clube não responde');

-- ---------------------------------------------------------------- perguntas
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
insert into t_q select public.suggest_question((select club from t), 2, 'Os “olhos de ressaca”: é amor ou é medo?'), 1;
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
insert into t_q select public.suggest_question((select club from t), 2, 'Bentinho é um narrador confiável?'), 2;
select results_eq($$ select n, position, status, chapter_index from public.club_posts p join t_q using (id) order by n $$,
  $$ values (1, 1, 'open', 49), (2, 2, 'open', 49) $$, 'cada sugestão entra no fim da fila, aberta, até o cap. 50');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select throws_ok($$ select public.order_questions((select club from t), 2,
                     array[(select id from t_q where n = 2), (select id from t_q where n = 1)]) $$,
  '42501', 'not_allowed', 'só a anfitriã ordena');
select throws_ok($$ select public.suggest_question((select club from t), 9, 'Semana que não existe?') $$,
  '22023', 'invalid_week', 'só nas semanas da leitura');
select throws_like(
  $$ insert into public.club_posts (club_id, author_id, kind, chapter_index, body)
     values ((select club from t), '00000000-0000-7000-8000-0000000000b2', 'question', 0, 'pergunta direta') $$,
  '%row-level security%', 'a pergunta só pela RPC');
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
select throws_ok($$ select public.order_questions((select club from t), 2, array[(select id from t_q where n = 2)]) $$,
  '22023', 'invalid_order', 'a ordem traz todas as perguntas da semana');
select lives_ok($$ select public.order_questions((select club from t), 2,
                     array[(select id from t_q where n = 2), (select id from t_q where n = 1)]) $$,
  'a anfitriã põe a dela primeiro');
select is((select position from public.club_posts where id = (select id from t_q where n = 2)), 1,
  'a pergunta da Ana virou a 1ª ("Pergunta da semana")');
select lives_ok($$ select public.set_question_status((select id from t_q where n = 2), 'discussed',
                     'Na contagem final, 7 acham que não, 2 acham que sim.') $$, 'a anfitriã marca a conversada');
select results_eq($$ select status, host_note from public.club_posts where id = (select id from t_q where n = 2) $$,
  $$ values ('discussed', 'Na contagem final, 7 acham que não, 2 acham que sim.') $$, 'o estado e a anotação');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select throws_ok($$ select public.set_question_status((select id from t_q where n = 1), 'postponed') $$,
  '42501', 'not_allowed', 'só a anfitriã marca');

-- ---------------------------------------------------------------- grifo compartilhado (D-217, D-219)
insert into t_s select public.share_highlight((select club from t), '…olhos de cigana oblíqua e dissimulada.',
  '#B6ACE4', 121, 25, 0.4727), 'julia';
select results_eq(
  $$ select kind, week_no, chapter_index, ref_page, spoiler_page, spoiler_ratio, quote_text
       from public.club_posts where id = (select id from t_s where quem = 'julia') $$,
  $$ values ('shared_highlight', 1, 24, 121, 121, 0.4727::numeric, '…olhos de cigana oblíqua e dissimulada.') $$,
  'o grifo: o trecho, a semana do capítulo, a página e a posição de quem compartilhou');
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
insert into t_s select public.share_highlight((select club from t), 'Olhos de cigana oblíqua e dissimulada',
  '#FFC1C6', 121, 25, 0.47), 'rafa';
select is((select count(distinct quote_key)::int from public.club_posts where id in (select id from t_s)), 1,
  'o mesmo trecho com outra pontuação e maiúscula dá a mesma chave (D-219)');
select throws_ok($$ select public.share_highlight((select club from t), '  ', '#B6ACE4', 121, 25, 0.47) $$,
  '22023', 'invalid_share', 'trecho vazio não vai');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select throws_ok($$ select public.share_highlight((select club from t), 'x', '#B6ACE4', 1, 1, 0) $$,
  '42501', 'not_member', 'quem não é do clube não compartilha');

-- ---------------------------------------------------------------- respostas em um nível
select pg_temp.como('00000000-0000-7000-8000-0000000000a1');
insert into public.club_post_replies (post_id, author_id, body, quote_text, quote_color, quote_page, spoiler_ratio,
                                      spoiler_page)
values ((select id from t_q where n = 2), '00000000-0000-7000-8000-0000000000a1',
        'Repara que quem fala dos “olhos de cigana” é o José Dias.', 'olhos de cigana oblíqua e dissimulada.',
        '#B6ACE4', 121, 0.6, 152);
reset role;
insert into t_r select id, 'ana' from public.club_post_replies where author_id = '00000000-0000-7000-8000-0000000000a1';
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select lives_ok($$ insert into public.club_post_replies (post_id, author_id, parent_reply_id, body)
                   values ((select id from t_q where n = 2), '00000000-0000-7000-8000-0000000000b2',
                           (select id from t_r where quem = 'ana'), 'Boa!') $$, 'responder a uma resposta');
select is((select replies_count from public.club_post_replies where id = (select id from t_r where quem = 'ana')), 1,
  'a resposta conta as filhas');
select is((select replies_count from public.club_posts where id = (select id from t_q where n = 2)), 2,
  'o post conta todas');
reset role;
insert into t_r select id, 'julia' from public.club_post_replies where author_id = '00000000-0000-7000-8000-0000000000b2';
set local role authenticated;
select throws_ok($$ insert into public.club_post_replies (post_id, author_id, parent_reply_id, body)
                    values ((select id from t_q where n = 2), '00000000-0000-7000-8000-0000000000b2',
                            (select id from t_r where quem = 'julia'), 'neta') $$,
  'P0001', 'reply_depth', 'um nível só');

-- ---------------------------------------------------------------- curtidas
select pg_temp.como('00000000-0000-7000-8000-0000000000d4');
select lives_ok($$ insert into public.club_likes (target_type, target_id, user_id)
                   values ('post', (select id from t_s where quem = 'julia'), '00000000-0000-7000-8000-0000000000d4') $$,
  'curtir um post');
select is((select likes_count from public.club_posts where id = (select id from t_s where quem = 'julia')), 1,
  'o contador sobe');
select throws_ok($$ insert into public.club_likes (target_type, target_id, user_id)
                    values ('post', (select id from t_s where quem = 'julia'), '00000000-0000-7000-8000-0000000000d4') $$,
  '23505', null, 'curtir de novo não conta duas');
delete from public.club_likes where target_id = (select id from t_s where quem = 'julia');
select is((select likes_count from public.club_posts where id = (select id from t_s where quem = 'julia')), 0,
  'descurtir desce');
select lives_ok($$ insert into public.club_likes (target_type, target_id, user_id)
                   values ('reply', (select id from t_r where quem = 'ana'), '00000000-0000-7000-8000-0000000000d4') $$,
  'curtir uma resposta');
select is((select likes_count from public.club_post_replies where id = (select id from t_r where quem = 'ana')), 1,
  'o contador da resposta sobe');
select throws_like($$ insert into public.club_likes (target_type, target_id, user_id, club_id)
                      values ('post', (select id from t_s where quem = 'rafa'), '00000000-0000-7000-8000-0000000000d4',
                              (select club from t)) $$,
  '%permission denied%', 'o clube da curtida vem do servidor');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select throws_like($$ insert into public.club_likes (target_type, target_id, user_id)
                      values ('post', (select id from t_s where quem = 'julia'), '00000000-0000-7000-8000-0000000000c3') $$,
  '%row-level security%', 'quem não é do clube não curte');

-- ---------------------------------------------------------------- progresso e lido
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select lives_ok($$ select public.publish_progress((select club from t), 0.67, 34) $$, 'publicar o progresso');
select public.publish_progress((select club from t), 0.70, 36);
select results_eq(
  $$ select progress_ratio, progress_chapter from public.club_members
      where club_id = (select club from t) and user_id = '00000000-0000-7000-8000-0000000000b2' $$,
  $$ values (0.67::numeric, 34) $$, 'no mesmo minuto, a 2ª publicação não muda nada');
select throws_ok($$ select public.publish_progress((select club from t), 1.5, 1) $$,
  '22023', 'invalid_progress', 'fração fora de 0–1');
select throws_like($$ update public.club_members set progress_ratio = 0.99
                      where user_id = '00000000-0000-7000-8000-0000000000b2' $$,
  '%permission denied%', 'o progresso só pela RPC');
select lives_ok($$ select public.mark_club_read((select club from t)) $$, 'marcar o clube como lido');
select is((select last_read_post_at from public.club_members
            where club_id = (select club from t) and user_id = '00000000-0000-7000-8000-0000000000b2'), now(),
  'o lido é agora');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select throws_ok($$ select public.publish_progress((select club from t), 0.1, 1) $$,
  '42501', 'not_member', 'quem não é do clube não publica');

-- ---------------------------------------------------------------- sair
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
delete from public.club_members where club_id = (select club from t) and user_id = '00000000-0000-7000-8000-0000000000b2';
reset role;
select is((select count(*)::int from public.meeting_rsvps where user_id = '00000000-0000-7000-8000-0000000000b2'), 0,
  'quem sai leva a presença junto');

select * from finish();
rollback;

-- G21.1 — os resumos do clube (docs/progresso/G21.md §1, R4–R6, R11, R12): cada número das pranchas 04, 31, 32 e
-- 70 sai do mundo do clube, e as telas concordam entre si (as mesmas 11 leitoras, o mesmo % do grupo, as mesmas
-- presenças, a mesma meta). O bloqueio some com o que a pessoa escreveu e as contagens descem junto (D-223).
begin;
create extension if not exists pgtap with schema extensions;
select plan(55);
\ir _mundo_clube.psql

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
create temp table r (nome text primary key, j jsonb) on commit drop;
grant all on r to authenticated;

set local role authenticated;
select pg_temp.como(pg_temp.leitora(3));   -- a Marina
insert into r values
  ('meus', public.my_clubs()),
  ('clube', public.club_overview('00000000-0000-7000-8000-00000c200001')),
  ('fio', public.week_thread('00000000-0000-7000-8000-00000c200001', 2)),
  ('encontro', public.meeting_overview('00000000-0000-7000-8000-00000c400002')),
  ('membros', public.club_members_overview('00000000-0000-7000-8000-00000c200001')),
  ('chips', public.club_post_summaries(array['00000000-0000-7000-8000-00000c600008',
                                             '00000000-0000-7000-8000-00000c600001',
                                             '00000000-0000-7000-8000-0000000000ff']::uuid[]));
create function pg_temp.x(p text) returns jsonb language sql as $$ select j from r where nome = p $$;
create function pg_temp.iniciais(p jsonb) returns text language sql as $$
  select string_agg(e ->> 'initial', '' order by o) from jsonb_array_elements(p) with ordinality as a(e, o)
$$;

-- ---------------------------------------------------------------- my_clubs (o ticket, a faixa, a folha)
select is(jsonb_array_length(pg_temp.x('meus')), 1, 'a Marina está num clube');
select is(pg_temp.x('meus') -> 0 ->> 'members_count', '11', '11 leitoras');
select is(pg_temp.x('meus') -> 0 -> 'participants',
  '[{"initial": "A", "color": "#B6ACE4"}, {"initial": "J", "color": "#ABCF82"}, {"initial": "L", "color": "#FFC1C6"}]',
  'as 3 primeiras sem mim: a anfitriã e depois a ordem de chegada (A J L)');
select is(pg_temp.x('meus') -> 0 -> 'me', '{"initial": "M", "color": "#FED170"}', 'eu: M, amarelo');
select is(pg_temp.x('meus') -> 0 -> 'reading' ->> 'title', 'Dom Casmurro', 'o livro');
select is(pg_temp.x('meus') -> 0 -> 'reading' ->> 'author', 'Machado de Assis', 'a autora do livro (o autor)');
select is(pg_temp.x('meus') -> 0 -> 'reading' -> 'isbns', '["9788508140912", "9788535902778"]',
  'os ISBN-13 das edições da obra (D-213)');
select is(pg_temp.x('meus') -> 0 -> 'reading' -> 'current_week',
  '{"no": 2, "from": 26, "to": 50, "from_label": null, "to_label": null}', 'a semana atual é a do próximo encontro (R4)');
select is(pg_temp.x('meus') -> 0 -> 'next_meeting' -> 'counts', '{"vou": 8, "talvez": 3, "nao_vou": 0}',
  '8 confirmadas · 3 talvez');
select is(pg_temp.x('meus') -> 0 -> 'next_meeting' ->> 'mine', 'vou', 'eu vou');
select is((pg_temp.x('meus') -> 0 ->> 'group_progress')::numeric, 0.5373, 'Grupo 54% (R5)');
select is((pg_temp.x('meus') -> 0 ->> 'my_progress')::numeric, 0.62, 'Você 62%');
select is(pg_temp.x('meus') -> 0 ->> 'unread', '3', '3 não lidas (R6)');

-- ---------------------------------------------------------------- club_overview (a 04)
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 0 ->> 'comments', '48', 'semana 1: 48 comentários');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 0 ->> 'new', '0', 'semana 1: nada novo');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 1 ->> 'new', '3', 'semana 2: 3 novos');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 1 -> 'question' ->> 'body',
  'Bentinho é um narrador confiável?', 'a pergunta da semana');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 1 -> 'question' -> 'author' ->> 'host', 'true',
  'PERGUNTA DA SEMANA · ANA (a anfitriã)');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 1 -> 'question' ->> 'replies', '12', '12 respostas');
select is(pg_temp.x('clube') -> 'reading' -> 'weeks_list' -> 2 -> 'question', 'null', 'a semana 3 sem pergunta ainda');
select is(pg_temp.iniciais(pg_temp.x('clube') -> 'members'), 'RJALMBCDFGH', 'onde cada uma está, da mais à frente');
select is(pg_temp.x('clube') -> 'shared' -> 0 -> 'author' ->> 'name', 'Ana', 'Ana grifou em Dom Casmurro');
select is(pg_temp.x('clube') -> 'shared' -> 0 ->> 'same_passage', '7', '7 leitoras grifaram (R11)');
select is(pg_temp.x('clube') -> 'shared' -> 0 ->> 'likes', '9', '♥9');
select is(pg_temp.x('clube') -> 'shared' -> 0 ->> 'replies', '4', '💬4');

-- ---------------------------------------------------------------- week_thread (a 31)
select is(pg_temp.iniciais((select jsonb_agg(e -> 'author' order by o)
                              from jsonb_array_elements(pg_temp.x('fio') -> 'replies') with ordinality as a(e, o)
                             where o <= 5)),
  'JALMR', 'mais curtidas: Júlia 9, Ana 6, Lu 4, Marina 2, Rafa 1');
select is(pg_temp.x('fio') -> 'question' ->> 'new', '3', '12 respostas · 3 novas');
select is(pg_temp.x('fio') -> 'replies' -> 0 ->> 'replies', '2', 'a Júlia tem 2 respostas');
select is(pg_temp.x('fio') -> 'replies' -> 1 -> 'quote' ->> 'page', '121', 'a Ana cita a pág. 121');
select is(pg_temp.x('fio') -> 'replies' -> 4 -> 'spoiler', '{"page": 201, "ratio": 0.78}',
  'o Rafa fala da pág. 201 (D-218)');
select is(pg_temp.x('fio') -> 'replies' -> 3 -> 'author' ->> 'me', 'true', 'a da Marina é minha');
select is(jsonb_array_length(public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'likes', null,
            public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'likes', null, null, 3) -> 'next_cursor', 3)
            -> 'replies'), 3, 'a 2ª página continua de onde a 1ª parou');
select is((public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'likes', null,
            public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'likes', null, null, 3) -> 'next_cursor', 3)
            -> 'replies' -> 0 -> 'author' ->> 'name'), 'Marina', 'e começa pela Marina');
select is(pg_temp.iniciais((select jsonb_agg(e -> 'author' order by o) from jsonb_array_elements(
            public.week_thread('00000000-0000-7000-8000-00000c200001', 2, 'recent', '00000000-0000-7000-8000-00000c700001')
              -> 'replies') with ordinality as a(e, o))),
  'BA', 'as filhas da Júlia, das mais recentes');

-- ---------------------------------------------------------------- meeting_overview (a 70) e club_members_overview (a 32)
select is(pg_temp.iniciais(pg_temp.x('encontro') -> 'people' -> 'vou'), 'RJAMBCFG', 'vão: Rafa, Júlia, Ana, você…');
select is(pg_temp.iniciais(pg_temp.x('encontro') -> 'people' -> 'talvez'), 'LDH', 'talvez: Lu, Dani e Helô');
select is((select string_agg(left(e ->> 'body', 12), ' | ' order by o)
             from jsonb_array_elements(pg_temp.x('encontro') -> 'questions') with ordinality as a(e, o)),
  'Bentinho é u | Os “olhos de | O que o José | Por que a Ca', 'as perguntas na ordem da Ana');
select is(pg_temp.iniciais(pg_temp.x('membros') -> 'members'), 'RJALMBCDFGH', 'membros, da mais à frente');

-- ---------------------------------------------------------------- relações entre as telas
select is(jsonb_build_array(pg_temp.x('meus') -> 0 -> 'members_count', pg_temp.x('clube') -> 'club' -> 'members_count',
                            to_jsonb(jsonb_array_length(pg_temp.x('membros') -> 'members'))),
  '[11, 11, 11]', 'as mesmas 11 leitoras no ticket, na 04 e na 32');
select is(jsonb_build_array(pg_temp.x('clube') -> 'next_meeting' -> 'counts', pg_temp.x('encontro') -> 'meeting' -> 'counts'),
  '[{"vou": 8, "talvez": 3, "nao_vou": 0}, {"vou": 8, "talvez": 3, "nao_vou": 0}]', 'as mesmas presenças na 04 e na 70');
select is(jsonb_build_array(pg_temp.x('meus') -> 0 -> 'reading' -> 'current_week' -> 'to',
                            pg_temp.x('encontro') -> 'meeting' -> 'agenda' -> 'to'),
  '[50, 50]', 'a mesma meta: o cap. 50 no ticket, na faixa e na pauta');

-- ---------------------------------------------------------------- o chip da 25
select is(pg_temp.x('chips'), '[{"id": "00000000-0000-7000-8000-00000c600001", "club_id": "00000000-0000-7000-8000-00000c200001", "replies": 4, "club_name": "Leitoras de Capitu"}, {"id": "00000000-0000-7000-8000-00000c600008", "club_id": "00000000-0000-7000-8000-00000c200001", "replies": 3, "club_name": "Leitoras de Capitu"}]',
  '"Leitoras de Capitu · 3 respostas"; o post que não existe não volta');

-- ---------------------------------------------------------------- bloqueio (D-223, R12)
insert into public.user_blocks (blocker_id, blocked_id) values (pg_temp.leitora(3), pg_temp.leitora(5));
select is(public.week_thread('00000000-0000-7000-8000-00000c200001', 2) -> 'question' ->> 'replies', '11',
  'bloqueei o Rafa: 11 respostas');
select is(position('R' in pg_temp.iniciais((select jsonb_agg(e -> 'author' order by o) from jsonb_array_elements(
            public.week_thread('00000000-0000-7000-8000-00000c200001', 2) -> 'replies') with ordinality as a(e, o)))),
  0, 'a resposta do Rafa sumiu');
select is(public.club_overview('00000000-0000-7000-8000-00000c200001') -> 'shared' -> 0 ->> 'same_passage', '6',
  '6 leitoras grifaram (sem o Rafa)');
select is(public.club_overview('00000000-0000-7000-8000-00000c200001') -> 'shared' -> 0 ->> 'replies', '3',
  '💬3 (a do Rafa sumiu)');
select is(public.my_clubs() -> 0 ->> 'members_count', '11', 'as leitoras continuam 11 (bloqueio não tira do clube)');

-- ---------------------------------------------------------------- quem não é do clube
-- R5: quem nunca publicou não entra na média do grupo (uma 12ª leitora acabou de entrar), mas conta como leitora
reset role;
insert into auth.users (id, email) values (pg_temp.leitora(12), 'nova@mundo.clube');
insert into public.club_members (club_id, user_id) values ('00000000-0000-7000-8000-00000c200001', pg_temp.leitora(12));
set local role authenticated;
select pg_temp.como(pg_temp.leitora(3));
select is((public.my_clubs() -> 0 ->> 'group_progress')::numeric, 0.5373,
  'a recém-chegada sem progresso não puxa o grupo para baixo (R5)');
select is(public.my_clubs() -> 0 ->> 'members_count', '12', 'mas já conta entre as leitoras');

select pg_temp.como('00000000-0000-7000-8000-0000000000ff');
select throws_ok($$ select public.club_overview('00000000-0000-7000-8000-00000c200001') $$, '42501', 'not_member',
  'quem não é do clube não vê a 04');
select throws_ok($$ select public.meeting_overview('00000000-0000-7000-8000-00000c400002') $$, '42501', 'not_member',
  'nem o encontro');
select throws_ok($$ select public.week_thread('00000000-0000-7000-8000-00000c200001', 2) $$, '42501', 'not_member',
  'nem a discussão');
select is(public.club_post_summaries(array['00000000-0000-7000-8000-00000c600008']::uuid[]), '[]'::jsonb,
  'nem o chip');
select is(public.my_clubs(), '[]'::jsonb, 'sem clube, a lista vazia');
select set_config('request.jwt.claims', '{"role": "authenticated"}', true);
select throws_ok($$ select public.my_clubs() $$, '28000', 'unauthenticated', 'sem conta, nada');

select * from finish();
rollback;

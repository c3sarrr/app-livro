-- Clubes: limite do Grátis, membros, convites, respostas, clube público e herança na exclusão de
-- conta (fumaça OK 07–10, 18 e 22 do rascunho).
begin;
create extension if not exists pgtap with schema extensions;
select plan(19);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000000a', 'pro', now() + interval '27 days');

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;

-- ---------------------------------------------------------------- OK 07: Grátis cria 1 clube
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select lives_ok($$ insert into public.clubs (owner_id, name, name_highlight, goal_chapter, goal_chapter_label)
  values ('00000000-0000-7000-8000-00000000000b', 'Leitoras de Capitu', 'Capitu', 50, 'L') $$, 'OK 07 Grátis cria o 1º clube');
select throws_ok($$ insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000b', 'Segundo clube') $$,
  'P0001', 'free_club_limit', 'OK 07 Grátis não cria o 2º clube');
select is((select role from public.club_members where user_id = '00000000-0000-7000-8000-00000000000b'), 'owner',
  'OK 07 o dono entra como membro owner');
select throws_ok($$ insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000a', 'Clube alheio') $$,
  '42501', null, 'ninguém cria clube em nome de outra pessoa');

-- ---------------------------------------------------------------- OK 08: Pro cria vários
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000a', 'Clube 1 da Ana');
insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000a', 'Clube 2 da Ana');
select is((select count(*)::int from public.clubs where owner_id = '00000000-0000-7000-8000-00000000000a'), 2, 'OK 08 Pro cria vários clubes');
select is((select count(*)::int from public.clubs where name = 'Leitoras de Capitu'), 0, 'OK 08 clube por convite invisível para não membro');

-- ---------------------------------------------------------------- OK 09: não membro
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
insert into public.club_invites (club_id, created_by, expires_at)             -- o código é gerado pelo servidor
select id, '00000000-0000-7000-8000-00000000000b', now() + interval '7 days'
  from public.clubs where name = 'Leitoras de Capitu';
insert into public.club_posts (club_id, author_id, kind, chapter_index, ref_page, quote_text, quote_color, body)
select id, '00000000-0000-7000-8000-00000000000b', 'shared_highlight', 31, 152,
       'Capitu era Capitu, isto é, uma criatura mui particular, mais mulher do que eu era homem.', '#B6ACE4',
       'Levar para o encontro de quinta.'
  from public.clubs where name = 'Leitoras de Capitu';
reset role;
create temp table t_post on commit drop as select id from public.club_posts;
create temp table t_convite on commit drop as select code from public.club_invites;
grant select on t_post, t_convite to authenticated;
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.club_posts), 0, 'OK 09 não membro não vê os posts do clube');
select throws_like($$ insert into public.club_post_replies (post_id, author_id, body)
  values ((select id from t_post), '00000000-0000-7000-8000-00000000000c', 'intrusa') $$,
  '%row-level security%', 'OK 09 não membro não responde (mesmo sabendo o id do post)');

-- ---------------------------------------------------------------- OK 10: convite e resposta
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select throws_ok($$ select public.join_club('ERRADO123') $$, 'P0001', 'invalid_invite', 'convite inexistente recusado');
select isnt(public.join_club((select code from t_convite)), null, 'OK 10 entra no clube pelo convite');
insert into public.club_post_replies (post_id, author_id, body)
select p.id, '00000000-0000-7000-8000-00000000000a', 'Concordo!' from public.club_posts p;
select is((select replies_count from public.club_posts), 1, 'OK 10 contador de respostas');
select is((select club_id from public.club_post_replies), (select club_id from public.club_posts), 'OK 10 club_id herdado do post');

-- ---------------------------------------------------------------- OK 18: clube público
reset role;
create temp table t_club on commit drop as select id from public.clubs where name = 'Clube 2 da Ana';
grant select on t_club to authenticated;
set local role authenticated;
update public.clubs set privacy = 'public' where name = 'Clube 1 da Ana';
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select lives_ok($$ select public.join_public_club((select id from public.clubs where name = 'Clube 1 da Ana')) $$,
  'OK 18 entra em clube público sem convite');
select ok(private.is_club_member((select id from public.clubs where name = 'Clube 1 da Ana')), 'OK 18 virou membro');
select throws_ok($$ select public.join_public_club((select id from t_club)) $$, 'P0001', 'club_not_public',
  'OK 18 clube por convite exige código');

-- ---------------------------------------------------------------- OK 22: exclusão de conta do dono
reset role;
delete from auth.users where id = '00000000-0000-7000-8000-00000000000b';
select is((select owner_id from public.clubs where name = 'Leitoras de Capitu'), '00000000-0000-7000-8000-00000000000a'::uuid,
  'OK 22 o clube passa ao membro mais antigo');
select is((select m.role from public.club_members m join public.clubs c on c.id = m.club_id
           where c.name = 'Leitoras de Capitu' and m.user_id = '00000000-0000-7000-8000-00000000000a'), 'owner', 'OK 22 e ele vira owner');
select is((select count(*)::int from public.club_post_replies), 1, 'OK 22 a resposta dos outros continua');
select ok((select deleted_at is not null and body is null and quote_text is null from public.club_posts),
  'OK 22 o post de quem saiu vira "apagado" (conteúdo removido)');

select * from finish();
rollback;

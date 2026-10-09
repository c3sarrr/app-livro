-- G21.2 — o tempo real do clube (D-225; docs/progresso/G21.md §2): um aviso sem conteúdo ("mudou") no canal
-- privado club:<id> a cada post, resposta, curtida ou edição; os contadores não mandam aviso; só os membros leem
-- o tópico (a política em realtime.messages olha o realtime.topic() que o Realtime põe ao autorizar o canal).
begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-0000000000a1', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000b2', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000c3', 'caio@exemplo.com');
insert into private.account_age (user_id, band, source)
select id, '18_plus', 'birthdate' from auth.users on conflict (user_id) do nothing;
insert into private.terms_acceptances (user_id, version) select id, private.terms_version() from auth.users
on conflict do nothing;

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
create function pg_temp.avisos() returns integer language sql as $$
  select count(*)::integer from realtime.messages
   where topic = 'club:00000000-0000-7000-8000-00000000f001' and event = 'changed'
$$;

insert into public.clubs (id, owner_id, name) values
  ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000a1', 'Clube da Ana');
insert into public.club_members (club_id, user_id) values
  ('00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000b2');

insert into public.club_posts (id, club_id, author_id, kind, chapter_index, body) values
  ('00000000-0000-7000-8000-00000000f0a1', '00000000-0000-7000-8000-00000000f001', '00000000-0000-7000-8000-0000000000a1',
   'discussion', 0, 'O post da Ana.');
select is(pg_temp.avisos(), 1, 'o post manda um aviso no canal do clube');
select is((select payload - 'id' from realtime.messages where topic = 'club:00000000-0000-7000-8000-00000000f001' limit 1),
  '{"t": "club_posts"}'::jsonb, 'o aviso não leva o texto, só a tabela');
select ok((select bool_and(private and extension = 'broadcast') from realtime.messages
            where topic = 'club:00000000-0000-7000-8000-00000000f001'), 'canal privado, por Broadcast');
insert into public.club_post_replies (post_id, author_id, body) values
  ('00000000-0000-7000-8000-00000000f0a1', '00000000-0000-7000-8000-0000000000b2', 'A resposta da Bia.');
select is(pg_temp.avisos(), 2, 'a resposta manda um; o contador do post não manda outro');
insert into public.club_likes (target_type, target_id, user_id) values
  ('post', '00000000-0000-7000-8000-00000000f0a1', '00000000-0000-7000-8000-0000000000b2');
select is(pg_temp.avisos(), 3, 'a curtida manda um; o contador não manda outro');
update public.club_posts set body = 'O post da Ana, editado.' where id = '00000000-0000-7000-8000-00000000f0a1';
select is(pg_temp.avisos(), 4, 'editar manda um');

set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select set_config('realtime.topic', 'club:00000000-0000-7000-8000-00000000f001', true);
select is(pg_temp.avisos(), 4, 'a membro lê os avisos do clube');
select pg_temp.como('00000000-0000-7000-8000-0000000000c3');
select is(pg_temp.avisos(), 0, 'quem não é do clube não lê');
select pg_temp.como('00000000-0000-7000-8000-0000000000b2');
select set_config('realtime.topic', 'club:nao-e-um-uuid', true);
select is((select count(*)::integer from realtime.messages), 0, 'tópico inválido: nada, e sem erro');

select * from finish();
rollback;

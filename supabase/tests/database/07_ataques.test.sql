-- Ataques com a chave pública e com o JWT de um usuário comum (fumaça OK 15 e 16 do rascunho).
begin;
create extension if not exists pgtap with schema extensions;
select plan(11);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com');
create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000b', 'Clube da Bia');
insert into public.club_members (club_id, user_id) select id, '00000000-0000-7000-8000-00000000000a' from public.clubs;

-- ---------------------------------------------------------------- OK 15: GRANT por coluna
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select throws_ok($$ update public.club_members set role = 'owner' where user_id = '00000000-0000-7000-8000-00000000000a' $$,
  '42501', null, 'OK 15 membro não se promove a owner');
select throws_ok($$ insert into public.posts (author_id, kind, body, likes_count) values ('00000000-0000-7000-8000-00000000000a', 'review', 'x', 1000000) $$,
  '42501', null, 'OK 15 contador forjado recusado');
select throws_ok($$ update public.profile_stats set followers_count = 99999 $$, '42501', null, 'números do perfil só pela RPC');
select throws_ok($$ insert into public.club_post_replies (post_id, club_id, author_id, body) values (gen_random_uuid(), gen_random_uuid(), '00000000-0000-7000-8000-00000000000a', 'x') $$,
  '42501', null, 'o cliente não escolhe o club_id da resposta');
select throws_ok($$ insert into billing.entitlements (user_id, entitlement, active_until) values ('00000000-0000-7000-8000-00000000000a', 'pro', 'infinity') $$,
  '42501', null, 'ninguém se dá o Pro');
select throws_ok($$ select private.refresh_sync_access() $$, '42501', null, 'rotina interna não é chamável pelo app');
select throws_ok($$ insert into personal.user_books (id, user_id, title, author_display, format, status, added_at, created_at, updated_at, version_hlc)
  values (gen_random_uuid(), '00000000-0000-7000-8000-00000000000a', 'x', 'y', 'epub', 'reading', now(), now(), now(), 'z') $$,
  '42501', null, 'escrita direta em personal.* proibida (só pela RPC)');
reset role;

-- ---------------------------------------------------------------- OK 16: anon não faz nada
set local role anon;
select throws_ok($$ select public.profile_preview('bia') $$, '42501', null, 'OK 16 anon não chama RPC');
select throws_ok($$ select 1 from public.profiles limit 1 $$, '42501', null, 'OK 16 anon não lê perfis');
select throws_ok($$ select public.my_entitlement() $$, '42501', null, 'anon não consulta o Pro');
select throws_ok($$ select 1 from personal.user_books limit 1 $$, '42501', null, 'anon não enxerga o esquema pessoal');
reset role;

select * from finish();
rollback;

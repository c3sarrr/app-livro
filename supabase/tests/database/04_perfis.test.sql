-- Perfis: criação automática, Pro vê / Grátis só prévia, perfil fechado, contadores
-- (fumaça OK 01, 11, 12 e 19 do rascunho) e o nome provisório do cadastro.
begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000000a', 'pro', now() + interval '27 days');

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;

-- ---------------------------------------------------------------- OK 01: gatilho do Auth
select is((select count(*)::int from public.profiles), 3, 'OK 01 perfil criado pelo gatilho do Auth');
select is((select count(*)::int from public.profile_stats), 3, 'OK 01 estatísticas zeradas criadas');
select matches((select handle from public.profiles where id = '00000000-0000-7000-8000-00000000000a'),
  '^leitor_[0-9a-f]{12}$', '@ provisório "leitor_<12 hex>" (o app pede o @ no onboarding)');
select is((select display_name from public.profiles where id = '00000000-0000-7000-8000-00000000000a'), 'ana',
  'nome provisório = parte local do e-mail');
insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-0000000000e1', repeat('x', 70) || '@exemplo.com'),
  ('00000000-0000-7000-8000-0000000000e2', null);
select is((select char_length(display_name) from public.profiles where id = '00000000-0000-7000-8000-0000000000e1'), 60,
  'e-mail com mais de 60 caracteres antes do @ não derruba o cadastro (nome cortado em 60)');
select is((select display_name from public.profiles where id = '00000000-0000-7000-8000-0000000000e2'), 'Leitor',
  'sem e-mail (telefone, Apple) o nome provisório é "Leitor"');

update public.profiles set handle = 'ana' where id = '00000000-0000-7000-8000-00000000000a';
update public.profiles set handle = 'bia' where id = '00000000-0000-7000-8000-00000000000b';
update public.profiles set handle = 'caio', visibility = 'private' where id = '00000000-0000-7000-8000-00000000000c';

-- ---------------------------------------------------------------- OK 11: Grátis só prévia
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
insert into public.posts (author_id, kind, body, rating) values ('00000000-0000-7000-8000-00000000000b', 'review', 'Capitu é o livro.', 5);
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
insert into public.posts (author_id, kind, body) values ('00000000-0000-7000-8000-00000000000c', 'review', 'Perfil fechado.');
select is((select count(*)::int from public.posts), 1, 'OK 11 Grátis só vê os próprios posts');
select is((public.profile_preview('bia') -> 'recent_posts' -> 0 ->> 'chars')::int, 17, 'OK 11 a prévia traz só o tamanho');
select doesnt_match(public.profile_preview('bia')::text, 'Capitu é o livro', 'OK 11 a prévia não vaza o texto');

-- ---------------------------------------------------------------- OK 12: perfil fechado e contadores
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is((select count(*)::int from public.posts where author_id = '00000000-0000-7000-8000-00000000000b'), 1, 'OK 12 Pro vê perfil aberto');
select is((select count(*)::int from public.posts where author_id = '00000000-0000-7000-8000-00000000000c'), 0,
  'OK 12 Pro não vê perfil fechado sem aprovação');
insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000a', '00000000-0000-7000-8000-00000000000c');
select is((select status from public.follows), 'pending', 'OK 12 seguir perfil fechado vira pedido pendente');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
update public.follows set status = 'accepted' where followee_id = '00000000-0000-7000-8000-00000000000c';
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is((select count(*)::int from public.posts where author_id = '00000000-0000-7000-8000-00000000000c'), 1,
  'OK 12 depois do aceite o Pro vê o perfil fechado');
select is((select followers_count from public.profile_stats where user_id = '00000000-0000-7000-8000-00000000000c'), 1,
  'OK 12 contador de seguidores');

-- ---------------------------------------------------------------- OK 19: prévia de perfil fechado
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is(jsonb_array_length(public.profile_preview('caio') -> 'recent_posts'), 0, 'OK 19 prévia de perfil fechado sem metadados de posts');
select is(public.profile_preview('naoexiste'), null, 'prévia de @ inexistente é vazia');

reset role;
select * from finish();
rollback;

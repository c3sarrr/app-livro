-- G06.0 (pendência da G16 antecipada): o social exige a faixa etária registrada. Conta sem faixa não
-- publica, não comenta, não curte, não segue, não cria nem entra em clube e não abre o perfil;
-- denunciar e bloquear continuam livres; rotinas do servidor (sem usuário no JWT) não são afetadas.
begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com');
insert into private.account_age (user_id, band, source) values
  ('00000000-0000-7000-8000-00000000000a', '18_plus', 'play_signal'),
  ('00000000-0000-7000-8000-00000000000c', '13_15', 'birthdate');
create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
insert into public.posts (id, author_id, kind, body)
values ('01927a00-0000-7000-8000-0000000000a1', '00000000-0000-7000-8000-00000000000a', 'review', 'post da Ana');
insert into public.clubs (id, owner_id, name, privacy)
values ('01927a00-0000-7000-8000-0000000000c1', '00000000-0000-7000-8000-00000000000a', 'Clube Aberto', 'public');

set local role authenticated;
-- ---------------------------------------------------------------- Bia: conta SEM faixa
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select throws_ok($$ insert into public.posts (author_id, kind, body) values ('00000000-0000-7000-8000-00000000000b', 'review', 'oi') $$,
  'P0001', 'age_required', 'sem faixa: não publica');
select throws_ok($$ insert into public.post_comments (post_id, author_id, body) values ('01927a00-0000-7000-8000-0000000000a1', '00000000-0000-7000-8000-00000000000b', 'oi') $$,
  'P0001', 'age_required', 'sem faixa: não comenta');
select throws_ok($$ insert into public.post_likes (post_id, user_id) values ('01927a00-0000-7000-8000-0000000000a1', '00000000-0000-7000-8000-00000000000b') $$,
  'P0001', 'age_required', 'sem faixa: não curte');
select throws_ok($$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000b', '00000000-0000-7000-8000-00000000000a') $$,
  'P0001', 'age_required', 'sem faixa: não segue');
select throws_ok($$ insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000b', 'Meu clube') $$,
  'P0001', 'age_required', 'sem faixa: não cria clube');
select throws_ok($$ select public.join_public_club('01927a00-0000-7000-8000-0000000000c1') $$,
  'P0001', 'age_required', 'sem faixa: não entra em clube (nem pela RPC)');
select throws_ok($$ update public.profiles set visibility = 'public' where id = '00000000-0000-7000-8000-00000000000b' $$,
  'P0001', 'age_required', 'sem faixa: não abre o perfil');
select lives_ok($$ insert into public.content_reports (reporter_id, target_type, target_id, reason) values ('00000000-0000-7000-8000-00000000000b', 'post', '01927a00-0000-7000-8000-0000000000a1', 'spam') $$,
  'sem faixa: denunciar continua livre (proteção)');
select lives_ok($$ insert into public.user_blocks (blocker_id, blocked_id) values ('00000000-0000-7000-8000-00000000000b', '00000000-0000-7000-8000-00000000000a') $$,
  'sem faixa: bloquear continua livre (proteção)');
select lives_ok($$ delete from public.user_blocks where blocker_id = '00000000-0000-7000-8000-00000000000b' $$, 'desfaz o bloqueio');

-- registrou a idade: libera
select is(public.set_my_age_band('18_plus', 'birthdate') ->> 'band', '18_plus', 'Bia confirma a idade');
select lives_ok($$ insert into public.posts (author_id, kind, body) values ('00000000-0000-7000-8000-00000000000b', 'review', 'agora sim') $$,
  'com faixa: publica');
select lives_ok($$ select public.join_public_club('01927a00-0000-7000-8000-0000000000c1') $$, 'com faixa: entra no clube aberto');

-- ---------------------------------------------------------------- Caio: adolescente (tem faixa)
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select lives_ok($$ insert into public.posts (author_id, kind, body) values ('00000000-0000-7000-8000-00000000000c', 'review', 'gostei') $$,
  'adolescente com faixa participa (com os padrões protetivos)');
reset role;

-- ---------------------------------------------------------------- rotina do servidor (sem usuário)
select set_config('request.jwt.claims', '{"role":"service_role"}', true);
select lives_ok($$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000a', '00000000-0000-7000-8000-00000000000c') $$,
  'sem usuário no JWT (servidor): a regra não se aplica');
select ok(not has_function_privilege('authenticated', 'private.require_age_band()', 'execute'),
  'o cliente não chama a função da regra');

select * from finish();
rollback;

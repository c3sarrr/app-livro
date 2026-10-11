-- G05 — conta: faixa etária (D-66: sinal da loja + nascimento; o servidor guarda só a faixa e a fonte),
-- resumo da conta para o app e o @ provisório reservado.
begin;
create extension if not exists pgtap with schema extensions;
select plan(25);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000000a', 'pro', now() + interval '30 days');
create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;

set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');

-- ---------------------------------------------------------------- resumo da conta
select is(public.my_account() ->> 'handle_provisional', 'true', 'conta nova: o @ ainda é o provisório (o app pede a escolha)');
select is(public.my_account() ->> 'pro', 'true', 'o resumo diz se é Pro');
select is(public.my_account() ->> 'age_band', null, 'sem faixa etária registrada ainda');
select is(public.my_account() ->> 'visibility', 'private',
  'conta sem faixa nasce com o perfil fechado (tratada como de menor até registrar a idade)');

-- ---------------------------------------------------------------- faixa etária
select is(public.set_my_age_band('18_plus', 'play_signal') ->> 'band', '18_plus', 'sinal da loja registrado');
select is(public.my_account() ->> 'age_band', '18_plus', 'o resumo mostra a faixa');
select is(public.my_account() ->> 'visibility', 'public', 'adulto: a 1ª faixa abre o perfil (padrão do adulto)');
select throws_ok($$ select public.set_my_age_band('12', 'birthdate') $$, '22023', 'invalid_age', 'faixa inválida recusada');
select throws_ok($$ select public.set_my_age_band('under_13', 'birthdate') $$, 'P0001', 'underage', 'menor de 13 não tem conta');
select throws_ok($$ select public.set_my_age_band('18_plus', 'selfie') $$, '22023', 'invalid_age', 'fonte desconhecida recusada');
select is(public.set_my_age_band('16_17', 'apple_signal') ->> 'band', '16_17', 'faixa mais nova (mais protegida) é aceita');
select is(public.my_account() ->> 'visibility', 'private', 'virou menor: o perfil fecha');

select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is(public.set_my_age_band('13_15', 'birthdate') ->> 'minor', 'true', 'adolescente pela data de nascimento');
select is((select visibility from public.profiles where id = '00000000-0000-7000-8000-00000000000b'), 'private',
  'adolescente: perfil fechado por padrão (D-66)');
select is(public.set_my_age_band('18_plus', 'birthdate') ->> 'band', '13_15',
  'a data de nascimento não troca uma faixa já registrada (o adolescente não vira adulto digitando outra data)');
select is(public.set_my_age_band('18_plus', 'play_signal') ->> 'band', '13_15',
  'nem um "sinal da loja" vindo do app passa de adolescente a adulto (a fonte não é prova)');
select is(public.set_my_age_band('16_17', 'apple_signal') ->> 'band', '13_15', 'nem para a faixa seguinte');
select throws_ok($$ insert into private.account_age (user_id, band, source) values ('00000000-0000-7000-8000-00000000000b', '18_plus', 'birthdate') $$,
  '42501', null, 'o cliente não escreve a tabela da faixa');

-- ---------------------------------------------------------------- @ provisório reservado
select throws_ok($$ update public.profiles set handle = 'leitor_0000000000ab' where id = '00000000-0000-7000-8000-00000000000b' $$,
  '22023', 'handle_reserved', 'o cliente não escolhe um @ no formato do provisório');
select lives_ok($$ update public.profiles set handle = 'bia.le' where id = '00000000-0000-7000-8000-00000000000b' $$, 'escolhe o próprio @');
select is(public.my_account() ->> 'handle_provisional', 'false', 'depois da escolha o @ deixa de ser provisório');
reset role;

-- ---------------------------------------------------------------- exportação e exclusão
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is((public.export_my_data() -> 'age' ->> 'band'), '13_15', 'a exportação (LGPD) inclui a faixa etária guardada');
reset role;
delete from auth.users where id = '00000000-0000-7000-8000-00000000000b';
select is((select count(*)::int from private.account_age where user_id = '00000000-0000-7000-8000-00000000000b'), 0,
  'conta excluída leva a faixa etária');

-- ---------------------------------------------------------------- sem login
set local role anon;
select throws_ok($$ select public.my_account() $$, '42501', null, 'anon não chama o resumo da conta');
reset role;
set local role authenticated;
select set_config('request.jwt.claims', '{"role":"authenticated"}', true);
select throws_ok($$ select public.set_my_age_band('18_plus', 'birthdate') $$, '28000', 'unauthenticated', 'sem usuário no JWT: recusado');
reset role;

select * from finish();
rollback;

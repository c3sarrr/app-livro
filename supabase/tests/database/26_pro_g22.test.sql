-- G22.1 — o servidor do Pro (docs/progresso/G22.md §1): as contas de teste (só o service_role), o aviso de sandbox no
-- e-mail do dia (D-48), o other_sessions do my_account (R7) e a cota do "conferir agora".
begin;
create extension if not exists pgtap with schema extensions;
select plan(23);

create function pg_temp.conta(n integer) returns uuid language sql immutable as $$
  select ('00000000-0000-7000-8000-0000000d' || lpad(n::text, 4, '0'))::uuid
$$;
insert into auth.users (id, email)
select pg_temp.conta(n), 'pro' || n || '@g22.teste' from generate_series(1, 3) n;
insert into private.moderators (user_id) values (pg_temp.conta(3));
create function pg_temp.sub(u uuid, env text, tid text) returns void language sql as $$
  insert into billing.subscriptions (user_id, store, product_id, period_type, status, will_renew,
    current_period_starts_at, current_period_ends_at, original_transaction_id, environment, last_event_at)
  values (u, 'test_store', 'booknest_pro_mensal', 'trial', 'active', true, now(), now() + interval '7 days', tid, env,
    now())
$$;

-- ------------------------------------------------------------ as contas de teste
select has_table('private', 'billing_test_accounts', 'a lista de contas de teste existe');
select is((select count(*)::int from information_schema.role_table_grants
            where table_schema = 'private' and table_name = 'billing_test_accounts'
              and grantee in ('anon', 'authenticated')), 0, 'só o service_role mexe na lista');

-- ------------------------------------------------------------ o aviso de sandbox no e-mail do dia (D-48)
-- o teste não depende do que a semente ou outro arquivo deixou (tudo volta no rollback)
delete from billing.subscriptions where environment = 'sandbox';
delete from private.email_outbox where template = 'moderation_digest';
select is(private.queue_moderation_digest(), 0, 'sem denúncia e sem sandbox: nenhum e-mail');

select pg_temp.sub(pg_temp.conta(1), 'sandbox', 'teste-1');
insert into private.billing_test_accounts (user_id, note) values (pg_temp.conta(1), 'revisão');
select is(private.queue_moderation_digest(), 0, 'sandbox de conta de teste não avisa');

select pg_temp.sub(pg_temp.conta(2), 'sandbox', 'comum-2');
select is(private.queue_moderation_digest(), 1, 'sandbox de conta comum: um e-mail para quem modera');
select is((select payload ->> 'sandbox_accounts' from private.email_outbox
            where template = 'moderation_digest' order by created_at desc limit 1), '1',
  'o e-mail diz quantas contas, não quais');
select is((select payload ->> 'open' from private.email_outbox
            where template = 'moderation_digest' order by created_at desc limit 1), '0',
  'e que não há denúncia aberta');
select ok((select payload::text not like '%' || pg_temp.conta(2)::text || '%' from private.email_outbox
            where template = 'moderation_digest' order by created_at desc limit 1), 'o id da conta não vai no e-mail');

update billing.subscriptions set updated_at = now() - interval '25 hours' where original_transaction_id = 'comum-2';
delete from private.email_outbox where template = 'moderation_digest';
select is(private.queue_moderation_digest(), 0, 'o sandbox de mais de 24 h já foi avisado');

-- ------------------------------------------------------------ other_sessions (R7)
insert into auth.sessions (id, user_id, created_at, updated_at)
values ('00000000-0000-7000-8000-00000e000001', pg_temp.conta(1), now(), now()),
       ('00000000-0000-7000-8000-00000e000002', pg_temp.conta(1), now(), now());
set local role authenticated;
select set_config('request.jwt.claims', json_build_object('sub', pg_temp.conta(1), 'role', 'authenticated',
  'session_id', '00000000-0000-7000-8000-00000e000001')::text, true);
select is(public.my_account() ->> 'other_sessions', '1', 'uma outra sessão ativa (o 2º aparelho)');
select set_config('request.jwt.claims', json_build_object('sub', pg_temp.conta(2), 'role', 'authenticated',
  'session_id', '00000000-0000-7000-8000-00000e000003')::text, true);
select is(public.my_account() ->> 'other_sessions', '0', 'conta com uma sessão só: nenhuma outra');
reset role;

-- D-235: com a confirmação de e-mail desligada, o Auth abre sozinho uma sessão no cadastro por código (método só
-- "password", que o app não usa) antes de mandar o código; ela não é outro aparelho. A de outro aparelho conta.
insert into auth.sessions (id, user_id, created_at, updated_at)
values ('00000000-0000-7000-8000-00000e000004', pg_temp.conta(1), now(), now());
insert into auth.mfa_amr_claims (id, session_id, created_at, updated_at, authentication_method)
values (gen_random_uuid(), '00000000-0000-7000-8000-00000e000004', now(), now(), 'password');
set local role authenticated;
select set_config('request.jwt.claims', json_build_object('sub', pg_temp.conta(1), 'role', 'authenticated',
  'session_id', '00000000-0000-7000-8000-00000e000001')::text, true);
select is(public.my_account() ->> 'other_sessions', '1', 'a sessão só por senha (a do cadastro) não conta');
reset role;
insert into auth.sessions (id, user_id, created_at, updated_at)
values ('00000000-0000-7000-8000-00000e000005', pg_temp.conta(1), now(), now());
insert into auth.mfa_amr_claims (id, session_id, created_at, updated_at, authentication_method)
values (gen_random_uuid(), '00000000-0000-7000-8000-00000e000005', now(), now(), 'otp');
set local role authenticated;
select set_config('request.jwt.claims', json_build_object('sub', pg_temp.conta(1), 'role', 'authenticated',
  'session_id', '00000000-0000-7000-8000-00000e000001')::text, true);
select is(public.my_account() ->> 'other_sessions', '2', 'a sessão por código de outro aparelho conta');
reset role;

-- D-238: a sessão sem uso há mais de 30 dias (o app desinstalado sem sair) não conta; a que renovou o login conta
insert into auth.sessions (id, user_id, created_at, updated_at, refreshed_at)
values ('00000000-0000-7000-8000-00000e000006', pg_temp.conta(1), now() - interval '40 days',
        now() - interval '40 days', (now() - interval '31 days') at time zone 'UTC'),
       ('00000000-0000-7000-8000-00000e000007', pg_temp.conta(1), now() - interval '40 days',
        now() - interval '40 days', (now() - interval '1 day') at time zone 'UTC');
set local role authenticated;
select set_config('request.jwt.claims', json_build_object('sub', pg_temp.conta(1), 'role', 'authenticated',
  'session_id', '00000000-0000-7000-8000-00000e000001')::text, true);
select is(public.my_account() ->> 'other_sessions', '3',
  'a sessão parada há 31 dias não conta; a que renovou ontem conta');
reset role;
update auth.sessions set refreshed_at = null, updated_at = now() - interval '29 days'
 where id = '00000000-0000-7000-8000-00000e000006';
set local role authenticated;
select set_config('request.jwt.claims', json_build_object('sub', pg_temp.conta(1), 'role', 'authenticated',
  'session_id', '00000000-0000-7000-8000-00000e000001')::text, true);
select is(public.my_account() ->> 'other_sessions', '4', 'usada há 29 dias ainda conta');
reset role;

-- ------------------------------------------------------------ D-237: a Test Store só dá Pro a conta de teste
select is((select count(*)::int from information_schema.role_table_grants
            where table_schema = 'private' and table_name = 'billing_config'
              and grantee in ('anon', 'authenticated')), 0, 'só o service_role mexe na configuração da cobrança');
update private.billing_config set test_store_grants_pro = false;   -- como na produção
select private.rc_recompute_entitlement(pg_temp.conta(2));
select is(public.entitlement_of(pg_temp.conta(2)) ->> 'pro', 'false', 'Test Store em conta comum não dá Pro');
select private.rc_recompute_entitlement(pg_temp.conta(1));
select is(public.entitlement_of(pg_temp.conta(1)) ->> 'pro', 'true', 'Test Store em conta da lista de teste dá Pro');
insert into billing.subscriptions (user_id, store, product_id, period_type, status, will_renew,
  current_period_starts_at, current_period_ends_at, original_transaction_id, environment, last_event_at)
values (pg_temp.conta(3), 'play_store', 'booknest_pro:mensal', 'normal', 'active', true, now(),
  now() + interval '30 days', 'GPA.teste-3', 'sandbox', now());
select private.rc_recompute_entitlement(pg_temp.conta(3));
select is(public.entitlement_of(pg_temp.conta(3)) ->> 'pro', 'true', 'o sandbox das lojas segue a D-48: dá Pro');
update private.billing_config set test_store_grants_pro = true;   -- o seed.sql do Supabase local
select private.rc_recompute_entitlement(pg_temp.conta(2));
select is(public.entitlement_of(pg_temp.conta(2)) ->> 'pro', 'true',
  'com a chave do Supabase local ligada, a Test Store dá Pro a qualquer conta');

-- ------------------------------------------------------------ a cota do "conferir agora"
select ok(private.consume_quota(pg_temp.conta(2), 'pro_sync', 30), '1ª chamada do dia passa');
select ok((select bool_and(private.consume_quota(pg_temp.conta(2), 'pro_sync', 30)) from generate_series(1, 29)),
  'até a 30ª passa');
select ok(not private.consume_quota(pg_temp.conta(2), 'pro_sync', 30), 'a 31ª é recusada');

select * from finish();
rollback;

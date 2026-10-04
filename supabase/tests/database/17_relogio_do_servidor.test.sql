-- G06 — o estado do Pro leva a hora do servidor (o app mede o relógio do aparelho com ela: a RPC de
-- sincronização recusa versão mais de 5 min no futuro).
begin;
create extension if not exists pgtap with schema extensions;
select plan(7);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000001a', 'pro@exemplo.com'),
  ('00000000-0000-7000-8000-00000000001b', 'gratis@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000001a', 'pro', now() + interval '30 days');
create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;

set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000001a');
select is(public.my_entitlement() ->> 'pro', 'true', 'Pro: pro = true');
select ok(abs((public.my_entitlement() ->> 'server_time_ms')::bigint
              - floor(extract(epoch from clock_timestamp()) * 1000)::bigint) < 5000,
  'server_time_ms = hora do servidor em ms');
select ok((public.my_entitlement() ->> 'active_until')::timestamptz > now() + interval '29 days',
  'fim previsto do Pro (o app agenda a checagem)');

select pg_temp.como('00000000-0000-7000-8000-00000000001b');
select is(public.my_entitlement() ->> 'pro', 'false', 'Grátis: pro = false');
select ok((public.my_entitlement() ->> 'server_time_ms') is not null, 'a hora vem também para o Grátis');

reset role;
select ok(not has_function_privilege('anon', 'public.my_entitlement()', 'execute'), 'anon não chama');
select ok(has_function_privilege('authenticated', 'public.my_entitlement()', 'execute'), 'quem está logado chama');

select * from finish();
rollback;

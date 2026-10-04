-- Rotinas agendadas (pg_cron) e chamada das Edge Functions pelo agendador (pg_net + Vault).
begin;
create extension if not exists pgtap with schema extensions;
select plan(8);

select set_eq($$ select jobname || ' ' || schedule from cron.job where jobname like 'booknest-%' $$,
  $$ values ('booknest-particoes-sessoes 7 3 * * *'), ('booknest-acesso-sync */15 * * * *'), ('booknest-retencao 17 6 * * *'),
            ('booknest-email-sender */5 * * * *'), ('booknest-purge-storage 37 4 * * *'), ('booknest-limpeza-cota 47 3 * * *'),
            ('booknest-push-sender * * * * *'), ('booknest-lembrete-encontros 5 * * * *'), ('booknest-poda-notificacoes 57 3 * * *') $$,
  'as 9 rotinas do Anexo 02 §8 (+ push e lembrete) agendadas com nome e horário');
select is((select command from cron.job where jobname = 'booknest-retencao'), 'select private.run_retention()', 'a retenção chama run_retention');

-- sem configuração no Vault: não chama nada (só avisa)
select is(private.invoke_edge_function('email-sender'), null, 'sem URL/chave no Vault a função não é chamada');
select throws_ok($$ select private.invoke_edge_function('../../auth/v1/admin') $$, '22023', 'invalid_function', 'nome de função inválido recusado');

-- com configuração: requisição na fila do pg_net com a chave no cabeçalho apikey
select vault.create_secret('http://supabase_kong_booknest:8000/', 'booknest_project_url');
select vault.create_secret('chave-do-agendador-de-teste', 'booknest_scheduler_key');
select isnt(private.invoke_edge_function('purge-storage', '{"lote": 1}'), null, 'com o Vault configurado a chamada é enfileirada');
select is((select url from net.http_request_queue order by id desc limit 1), 'http://supabase_kong_booknest:8000/functions/v1/purge-storage', 'URL da função');
select is((select headers ->> 'apikey' from net.http_request_queue order by id desc limit 1), 'chave-do-agendador-de-teste', 'chave secreta no cabeçalho apikey');

insert into auth.users (id, email) values ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com');
insert into private.quota_usage (user_id, quota_key, day, used) values
  ('00000000-0000-7000-8000-00000000000b', 'isbn_externo', current_date - 40, 3),
  ('00000000-0000-7000-8000-00000000000b', 'isbn_externo', current_date, 1);
select is(private.cleanup_quota_usage(), 1, 'limpeza da cota apaga só o que passou de 30 dias');

select * from finish();
rollback;

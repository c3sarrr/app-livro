-- Partições das sessões e retenção de 12 meses após o fim do Pro (fumaça OK 20, 21 e 23).
begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000d', 'duda@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000000a', 'pro', now() + interval '27 days');
insert into personal.user_books (id, user_id, title, author_display, format, status, added_at, created_at, updated_at, version_hlc) values
  ('01927a00-0000-7000-8000-000000000001', '00000000-0000-7000-8000-00000000000a', 'Dom Casmurro', 'Machado', 'epub', 'reading', now(), now(), now(), '0001726862400000-0000-dev1'),
  ('01927a00-0000-7000-8000-0000000000c1', '00000000-0000-7000-8000-00000000000c', 'Livro do Caio', 'Autor', 'epub', 'reading', now(), now(), now(), '0001726862400000-0000-devc');
insert into personal.reading_sessions (id, user_id, user_book_id, started_at, ended_at, active_seconds, source, created_at, updated_at, version_hlc)
values ('01927a00-0000-7000-8000-000000000301', '00000000-0000-7000-8000-00000000000a', '01927a00-0000-7000-8000-000000000001',
        '2025-03-01T10:00:00Z', '2025-03-01T10:20:00Z', 1200, 'auto', now(), now(), '0001726862400000-0001-dev1');
insert into personal.reader_settings (id, user_id, created_at, updated_at, version_hlc)
values ('00000000-0000-7000-8000-00000000000a', '00000000-0000-7000-8000-00000000000a', now(), now(), '0001726862400000-0002-dev1');

-- ---------------------------------------------------------------- OK 20: partições
select private.ensure_session_partitions(2);
select isnt(to_regclass(format('personal.reading_sessions_%s', to_char(now(), 'YYYY_MM'))), null, 'OK 20 partição do mês corrente');
select isnt(to_regclass(format('personal.reading_sessions_%s', to_char(now() + interval '2 months', 'YYYY_MM'))), null, 'OK 20 folga de 2 meses à frente');
select is(to_regclass('personal.reading_sessions_default'), null, 'OK 20 sem partição default');
select throws_ok($$ insert into personal.reading_sessions (id, user_id, user_book_id, started_at, ended_at, active_seconds, source, created_at, updated_at, version_hlc)
  values (gen_random_uuid(), '00000000-0000-7000-8000-00000000000a', '01927a00-0000-7000-8000-000000000001', '2023-06-01', '2023-06-01', 0, 'auto', now(), now(), 'x') $$,
  '23514', null, 'sessão fora das partições é recusada pelo banco');
drop table if exists personal.reading_sessions_2026_01;
select private.ensure_session_partition_for('2026-01-15T12:00:00Z');
select isnt(to_regclass('personal.reading_sessions_2026_01'), null, 'OK 23 partição criada sob demanda');

-- ---------------------------------------------------------------- OK 23: folga de 7 dias
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000000d', 'pro', now() - interval '2 days');
select private.refresh_sync_access();
select ok((select granted from billing.sync_access where user_id = '00000000-0000-7000-8000-00000000000d'), 'OK 23 bucket mantido na folga de 7 dias');
select ok(not private.can_sync('00000000-0000-7000-8000-00000000000d'), 'OK 23 mas o upload já é bloqueado');

-- ---------------------------------------------------------------- OK 21: retenção
update billing.entitlements set active_until = now() - interval '13 months' where user_id = '00000000-0000-7000-8000-00000000000a';
select private.refresh_sync_access();
select private.run_retention();
select is((select count(*)::int from personal.user_books where user_id = '00000000-0000-7000-8000-00000000000a'), 1,
  'OK 21 vencido mas sem aviso: ainda não apaga');
select is((select count(*)::int from private.email_outbox where template = 'retention_warning'), 1, 'OK 21 aviso enfileirado');
select ok(not (select granted from billing.sync_access where user_id = '00000000-0000-7000-8000-00000000000a'),
  'OK 21 sync revogado (passou da folga)');
update private.account_lifecycle set warning_sent_at = now() - interval '31 days' where user_id = '00000000-0000-7000-8000-00000000000a';
select private.run_retention();
select is((select count(*)::int from personal.user_books where user_id = '00000000-0000-7000-8000-00000000000a')
        + (select count(*)::int from personal.reading_sessions where user_id = '00000000-0000-7000-8000-00000000000a')
        + (select count(*)::int from personal.reader_settings where user_id = '00000000-0000-7000-8000-00000000000a'), 0,
  'OK 21 30 dias depois do aviso: livros, sessões (cascata) e preferências apagados');
select is((select count(*)::int from personal.user_books where user_id = '00000000-0000-7000-8000-00000000000c'), 1,
  'OK 21 dados de outro usuário intactos');
select is((select count(*)::int from private.email_outbox where template = 'retention_purged'), 1, 'OK 21 e-mail de exclusão enfileirado');
select is((select reason from private.storage_purge_queue where user_id = '00000000-0000-7000-8000-00000000000a' and done_at is null), 'retention',
  'os e-books de quem foi purgado vão para a fila do Storage');
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-00000000000c', 'pro', now() - interval '1 day');
update billing.entitlements set active_until = now() + interval '1 month' where user_id = '00000000-0000-7000-8000-00000000000c';
select private.run_retention();
select is((select count(*)::int from private.account_lifecycle where user_id = '00000000-0000-7000-8000-00000000000c'), 0,
  'quem voltou a ser Pro sai do ciclo de retenção');
delete from auth.users where id = '00000000-0000-7000-8000-00000000000d';
select is((select reason from private.storage_purge_queue where user_id = '00000000-0000-7000-8000-00000000000d'), 'account_deleted',
  'conta excluída → e-books na fila do Storage (a fila não depende da conta existir)');

select * from finish();
rollback;

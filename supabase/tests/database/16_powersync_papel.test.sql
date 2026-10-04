-- G06 — papel do serviço PowerSync: replica e lê SÓ o que é sincronizado (tabelas pessoais e o acesso
-- ao sync); sem login até alguém dar a senha fora do git; partição nova das sessões já nasce legível.
begin;
create extension if not exists pgtap with schema extensions;
select plan(12);

select ok((select rolreplication from pg_roles where rolname = 'powersync_role'), 'replica (REPLICATION)');
select ok((select rolbypassrls from pg_roles where rolname = 'powersync_role'), 'lê todos os assinantes (BYPASSRLS)');
select ok(not (select rolcanlogin from pg_roles where rolname = 'powersync_role'), 'nasce sem login (senha fora do git)');
select ok(not (select rolsuper from pg_roles where rolname = 'powersync_role'), 'não é superusuário');

select ok(has_table_privilege('powersync_role', 'personal.user_books', 'select'), 'lê as tabelas pessoais');
select ok(has_table_privilege('powersync_role', 'billing.sync_access', 'select'), 'lê o acesso ao sync (stream "pro")');
select ok(not has_table_privilege('powersync_role', 'personal.user_books', 'insert')
          and not has_table_privilege('powersync_role', 'personal.user_books', 'update')
          and not has_table_privilege('powersync_role', 'personal.user_books', 'delete'), 'não escreve nada');
select ok(not has_table_privilege('powersync_role', 'billing.entitlements', 'select'), 'não lê a assinatura');
select ok(not has_table_privilege('powersync_role', 'public.profiles', 'select'), 'não lê o social');
select is((select count(*)::int from pg_class c join pg_namespace n on n.oid = c.relnamespace
            where n.nspname = 'personal' and c.relkind in ('r', 'p')
              and not has_table_privilege('powersync_role', c.oid, 'select')), 0,
  'toda tabela pessoal (e partição) que existe é legível');

select private.ensure_session_partition_for(now() + interval '14 months');
select ok(has_table_privilege('powersync_role',
            format('personal.reading_sessions_%s', to_char(date_trunc('month', now() + interval '14 months'), 'YYYY_MM')),
            'select'), 'partição nova das sessões já nasce legível para o serviço');
select is((select count(*)::int from pg_publication_tables where pubname = 'powersync'
            and schemaname = 'personal' and tablename = format('reading_sessions_%s',
              to_char(date_trunc('month', now() + interval '14 months'), 'YYYY_MM'))), 1,
  'e entra na publicação sozinha (pela raiz particionada)');

select * from finish();
rollback;

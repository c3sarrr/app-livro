-- Estrutura: convenções que valem para todo objeto (Anexo 02 §5.4) — falham quando algo novo
-- chega sem segui-las.
begin;
create extension if not exists pgtap with schema extensions;
select plan(10);

select ok(to_regnamespace('personal') is not null and to_regnamespace('catalog') is not null
          and to_regnamespace('billing') is not null and to_regnamespace('private') is not null,
  'os esquemas personal, catalog, billing e private existem');

select is_empty($$ select p.oid::regprocedure::text from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                    where n.nspname in ('public', 'personal', 'catalog', 'billing', 'private')
                      and not exists (select 1 from pg_depend d where d.classid = 'pg_proc'::regclass and d.objid = p.oid and d.deptype = 'e')
                      and (p.proconfig is null or not ('search_path=""' = any(p.proconfig))) $$,
  'toda função nossa fixa search_path vazio (sem sequestro de search_path)');

select is_empty($$ select c.conrelid::regclass::text || '.' || c.conname from pg_constraint c
                    where c.contype = 'f' and c.connamespace::regnamespace::text in ('public', 'personal', 'catalog', 'billing', 'private')
                      and not (select relispartition from pg_class where oid = c.conrelid)
                      and not exists (select 1 from pg_index i where i.indrelid = c.conrelid
                                        and (i.indkey::int2[])[0:array_length(c.conkey, 1) - 1] = c.conkey) $$,
  'toda chave estrangeira tem índice (exclusão em cascata sem varrer a tabela)');

select is_empty($$ select n.nspname || '.' || c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
                    where n.nspname in ('public', 'personal', 'catalog', 'billing', 'private') and c.relkind in ('r', 'p')
                      and not c.relispartition
                      and not exists (select 1 from pg_constraint k where k.conrelid = c.oid and k.contype = 'p') $$,
  'toda tabela tem chave primária (exigência da replicação lógica do PowerSync e do Realtime)');

-- as 10 tabelas pessoais seguem o contrato do aparelho: id, user_id e as 4 colunas de versão
select is_empty($$ select t from unnest(array['user_books', 'reading_positions', 'reading_sessions', 'bookmarks', 'ink_layers',
                      'annotations', 'highlight_labels', 'reader_settings', 'pen_presets', 'reading_goals']) t
                    where (select count(*) from information_schema.columns c
                            where c.table_schema = 'personal' and c.table_name = t
                              and c.column_name in ('id', 'user_id', 'created_at', 'updated_at', 'deleted_at', 'version_hlc')) <> 6 $$,
  'tabelas pessoais com id, user_id, created_at, updated_at, deleted_at e version_hlc');

select set_eq($$ select r.prrelid::regclass::text from pg_publication_rel r join pg_publication p on p.oid = r.prpubid
                 where p.pubname = 'powersync' $$,
  $$ values ('personal.user_books'), ('personal.reading_positions'), ('personal.reading_sessions'), ('personal.bookmarks'),
            ('personal.ink_layers'), ('personal.annotations'), ('personal.highlight_labels'), ('personal.reader_settings'),
            ('personal.pen_presets'), ('personal.reading_goals'), ('billing.sync_access') $$,
  'publicação do PowerSync = 10 tabelas pessoais + billing.sync_access');
select ok(not (select pubviaroot from pg_publication where pubname = 'powersync'),
  'publicação sem publish_via_partition_root (o PowerSync recusa — ADR-003)');
select is_empty($$ select i.inhrelid::regclass::text from pg_inherits i where i.inhparent = 'personal.reading_sessions'::regclass
                    except select schemaname || '.' || tablename from pg_publication_tables where pubname = 'powersync' $$,
  'toda partição das sessões (inclusive as criadas depois) é replicada com o próprio nome');

select is((select count(*)::int from pg_inherits where inhparent = 'personal.reading_sessions'::regclass
            and inhrelid::regclass::text = 'personal.reading_sessions_default'), 0, 'sessões sem partição default');
select ok((select not public from storage.buckets where id = 'ebooks'), 'bucket ebooks existe e é privado');

select * from finish();
rollback;

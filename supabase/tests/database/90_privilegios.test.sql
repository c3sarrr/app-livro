-- Privilégios: falha se anon/authenticated/PUBLIC tiverem qualquer privilégio além do previsto
-- (Anexo 02 §5.4). Nos projetos antigos do Supabase tudo em `public` nascia com ALL para anon e
-- authenticated; cada migration revoga isso e concede só o previsto — este teste é a rede.
-- Para mudar um privilégio: mudar a migration E a lista abaixo (de propósito).
begin;
create extension if not exists pgtap with schema extensions;
select plan(7);

create temp view privilegios_de_tabela as
select coalesce(r.rolname, 'PUBLIC') as papel, n.nspname || '.' || c.relname as objeto, a.privilege_type as priv
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  cross join lateral aclexplode(coalesce(c.relacl, acldefault('r', c.relowner))) a
  left join pg_roles r on r.oid = a.grantee
 where n.nspname in ('public', 'personal', 'catalog', 'billing', 'private')
   and c.relkind in ('r', 'p', 'v', 'm', 'f', 'S')
   and (a.grantee = 0 or r.rolname in ('anon', 'authenticated'));

create temp view privilegios_de_coluna as
select coalesce(r.rolname, 'PUBLIC') as papel, n.nspname || '.' || c.relname || '.' || at.attname as objeto, a.privilege_type as priv
  from pg_attribute at
  join pg_class c on c.oid = at.attrelid
  join pg_namespace n on n.oid = c.relnamespace
  cross join lateral aclexplode(at.attacl) a
  left join pg_roles r on r.oid = a.grantee
 where n.nspname in ('public', 'personal', 'catalog', 'billing', 'private')
   and at.attnum > 0 and not at.attisdropped and at.attacl is not null
   and (a.grantee = 0 or r.rolname in ('anon', 'authenticated'));

create temp view privilegios_de_funcao as
select coalesce(r.rolname, 'PUBLIC') as papel,
       n.nspname || '.' || p.proname || '(' || oidvectortypes(p.proargtypes) || ')' as objeto, a.privilege_type as priv
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  cross join lateral aclexplode(coalesce(p.proacl, acldefault('f', p.proowner))) a
  left join pg_roles r on r.oid = a.grantee
 where n.nspname in ('public', 'personal', 'catalog', 'billing', 'private')
   and not exists (select 1 from pg_depend d where d.classid = 'pg_proc'::regclass and d.objid = p.oid and d.deptype = 'e')
   and (a.grantee = 0 or r.rolname in ('anon', 'authenticated'));

-- ---------------------------------------------------------------- tabelas
select set_eq($$ select papel || ' ' || priv || ' ' || objeto from privilegios_de_tabela $$,
  $$ select 'authenticated SELECT ' || t from unnest(array[
       'public.profiles', 'public.profile_stats', 'public.follows', 'public.user_blocks', 'public.posts',
       'public.post_comments', 'public.post_likes', 'public.clubs', 'public.club_members', 'public.club_invites',
       'public.club_meetings', 'public.club_posts', 'public.club_post_replies', 'public.notifications', 'public.device_tokens',
       'catalog.authors', 'catalog.works', 'catalog.work_authors', 'catalog.editions', 'catalog.community_submissions',
       'catalog.submission_confirmations',
       'personal.user_books', 'personal.reading_positions', 'personal.reading_sessions', 'personal.bookmarks',
       'personal.ink_layers', 'personal.annotations', 'personal.highlight_labels', 'personal.reader_settings',
       'personal.pen_presets', 'personal.reading_goals']) t
     union all
     select 'authenticated DELETE ' || t from unnest(array[
       'public.follows', 'public.user_blocks', 'public.post_likes', 'public.club_members', 'public.club_invites',
       'public.club_meetings', 'public.device_tokens']) t $$,
  'tabelas: só SELECT/DELETE previstos para authenticated; nada para anon nem PUBLIC');

-- ---------------------------------------------------------------- colunas (INSERT/UPDATE por coluna)
select set_eq($$ select papel || ' ' || priv || ' ' || objeto from privilegios_de_coluna $$,
  $$ select 'authenticated ' || g.priv || ' ' || g.tabela || '.' || c
       from (values
         ('UPDATE', 'public.profiles', array['handle', 'display_name', 'avatar_path', 'bio', 'visibility', 'timezone']),
         ('INSERT', 'public.follows', array['follower_id', 'followee_id']),
         ('UPDATE', 'public.follows', array['status']),
         ('INSERT', 'public.user_blocks', array['blocker_id', 'blocked_id']),
         ('INSERT', 'public.posts', array['author_id', 'kind', 'edition_id', 'work_id', 'rating', 'quote_text', 'body']),
         ('UPDATE', 'public.posts', array['rating', 'quote_text', 'body', 'edited_at', 'deleted_at']),
         ('INSERT', 'public.post_comments', array['post_id', 'author_id', 'body']),
         ('UPDATE', 'public.post_comments', array['deleted_at']),
         ('INSERT', 'public.post_likes', array['post_id', 'user_id']),
         ('INSERT', 'public.clubs', array['owner_id', 'name', 'name_highlight', 'work_id', 'edition_id', 'privacy', 'goal_chapter', 'goal_chapter_label']),
         ('UPDATE', 'public.clubs', array['name', 'name_highlight', 'privacy', 'goal_chapter', 'goal_chapter_label']),
         ('UPDATE', 'public.club_members', array['progress_chapter', 'progress_ratio', 'progress_updated_at', 'last_read_post_at']),
         ('INSERT', 'public.club_invites', array['code', 'club_id', 'created_by', 'expires_at', 'max_uses']),
         ('UPDATE', 'public.club_invites', array['expires_at', 'max_uses']),
         ('INSERT', 'public.club_meetings', array['club_id', 'starts_at', 'location', 'until_chapter', 'created_by', 'timezone']),
         ('UPDATE', 'public.club_meetings', array['starts_at', 'location', 'until_chapter', 'timezone']),
         ('INSERT', 'public.club_posts', array['club_id', 'author_id', 'kind', 'chapter_index', 'ref_page', 'quote_text', 'quote_color', 'body']),
         ('UPDATE', 'public.club_posts', array['body', 'edited_at', 'deleted_at']),
         ('INSERT', 'public.club_post_replies', array['post_id', 'author_id', 'body']),
         ('UPDATE', 'public.club_post_replies', array['deleted_at']),
         ('UPDATE', 'public.notifications', array['read_at']),
         ('INSERT', 'public.device_tokens', array['token', 'user_id', 'platform', 'app_version']),
         ('UPDATE', 'public.device_tokens', array['user_id', 'platform', 'app_version', 'updated_at']),
         ('INSERT', 'public.content_reports', array['reporter_id', 'target_type', 'target_id', 'reason', 'details']),
         ('INSERT', 'catalog.community_submissions', array['isbn13', 'title', 'authors', 'publisher', 'submitted_by']),
         ('INSERT', 'catalog.submission_confirmations', array['submission_id', 'user_id'])
       ) as g(priv, tabela, colunas), unnest(g.colunas) c $$,
  'colunas: o cliente só escreve as colunas previstas (contadores, papéis, status e datas de servidor ficam de fora)');

-- ---------------------------------------------------------------- funções
select set_eq($$ select papel || ' ' || objeto from privilegios_de_funcao $$,
  $$ select 'authenticated ' || f from unnest(array[
       'public.sync_apply_changes(jsonb)', 'public.my_entitlement()', 'public.profile_preview(text)',
       'public.publish_my_stats(integer, integer, integer, integer)', 'public.join_club(text)',
       'public.join_public_club(uuid)', 'public.search_editions(text, integer)', 'public.export_my_data()',
       'private.uuid_generate_v7()', 'private.f_unaccent(text)', 'private.is_pro()', 'private.user_is_pro(uuid)',
       'private.can_sync(uuid)', 'private.is_club_member(uuid)', 'private.is_club_admin(uuid)',
       'private.is_blocked_between(uuid, uuid)', 'private.can_view_profile_content(uuid)']) f $$,
  'funções: anon e PUBLIC não executam nada; authenticated só as RPCs e as funções usadas pela RLS');

-- ---------------------------------------------------------------- esquemas
select ok(not has_schema_privilege('anon', 'personal', 'usage') and not has_schema_privilege('anon', 'catalog', 'usage')
          and not has_schema_privilege('anon', 'billing', 'usage') and not has_schema_privilege('anon', 'private', 'usage'),
  'anon não enxerga os esquemas personal, catalog, billing e private');
select ok(not has_schema_privilege('authenticated', 'billing', 'usage'), 'authenticated não enxerga billing');
select ok(has_schema_privilege('service_role', 'billing', 'usage') and has_schema_privilege('service_role', 'private', 'usage'),
  'service_role (Edge Functions) enxerga billing e private');

-- toda tabela dos nossos esquemas tem RLS ligada (partições herdam a da tabela particionada)
select is_empty($$ select n.nspname || '.' || c.relname from pg_class c join pg_namespace n on n.oid = c.relnamespace
                    where n.nspname in ('public', 'personal', 'catalog', 'billing', 'private')
                      and c.relkind in ('r', 'p') and not c.relispartition and not c.relrowsecurity $$,
  'RLS ligada em todas as tabelas');

select * from finish();
rollback;

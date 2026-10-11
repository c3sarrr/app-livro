-- =====================================================================================
-- G04.6 — EXPLAIN (ANALYZE, BUFFERS) das consultas quentes (Anexo 02 §10) sobre os dados de
-- 01_dados_sinteticos.sql, como o app consulta: papel authenticated + JWT (a RLS entra no plano).
-- Quem consulta: leitor10 (Grátis, dono do Clube 1). Sync: leitor20 (Pro).
-- =====================================================================================
\set ON_ERROR_STOP on
\pset pager off
select set_config('request.jwt.claims', json_build_object('sub', '00000000-0000-7000-8000-00000000000a', 'role', 'authenticated')::text, false);
set role authenticated;

\echo '### 1. Feed do clube — 1ª página (keyset, 20 por página) — meta < 30 ms'
explain (analyze, buffers, timing, summary)
select id, author_id, kind, chapter_index, body, created_at, replies_count
  from public.club_posts
 where club_id = '00000000-0000-7000-8000-0000000f4241' and deleted_at is null
 order by created_at desc, id desc limit 20;
select created_at as cursor_em, id as cursor_id
  from public.club_posts where club_id = '00000000-0000-7000-8000-0000000f4241' and deleted_at is null
 order by created_at desc, id desc offset 19 limit 1 \gset
\echo '### 1b. Feed do clube — página seguinte (keyset)'
explain (analyze, buffers, timing, summary)
select id, author_id, kind, chapter_index, body, created_at, replies_count
  from public.club_posts
 where club_id = '00000000-0000-7000-8000-0000000f4241' and deleted_at is null
   and (created_at, id) < (:'cursor_em'::timestamptz, :'cursor_id'::uuid)
 order by created_at desc, id desc limit 20;

select id as post_id from public.club_posts where club_id = '00000000-0000-7000-8000-0000000f4241'
 order by created_at desc limit 1 \gset
\echo '### 2. Respostas de um post — meta < 20 ms'
explain (analyze, buffers, timing, summary)
select id, author_id, body, created_at from public.club_post_replies
 where post_id = :'post_id' and deleted_at is null order by created_at limit 50;

\echo '### 3. Notificações não lidas (contador do sino) — meta < 10 ms'
explain (analyze, buffers, timing, summary)
select count(*) from public.notifications where read_at is null;

\echo '### 3b. Lista de notificações (20 mais recentes)'
explain (analyze, buffers, timing, summary)
select id, type, actor_id, club_id, post_id, payload, created_at, read_at
  from public.notifications order by created_at desc limit 20;

\echo '### 4. Prévia de perfil (RPC security definer) — meta < 20 ms'
explain (analyze, buffers, timing, summary) select public.profile_preview('leitor4');

\echo '### 5. Busca no catálogo referenciado (trigramas, sem acento) — meta < 80 ms'
explain (analyze, buffers, timing, summary) select id, title from public.search_editions('memorias postumas');
\echo '### 5b. A mesma busca, com o plano de dentro da função (SQL com search_path fixo não é "inline")'
explain (analyze, buffers, timing, summary)
select e.id, e.title from catalog.editions e
 where private.f_unaccent(lower(e.title)) operator(extensions.%) private.f_unaccent(lower('memorias postumas'))
 order by extensions.similarity(private.f_unaccent(lower(e.title)), private.f_unaccent(lower('memorias postumas'))) desc, e.id
 limit 20;

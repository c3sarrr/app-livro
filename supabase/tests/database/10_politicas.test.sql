-- Uma verificação PERMITIDA e uma NEGADA para CADA política de RLS (Anexo 02 §5.4 e §13).
-- O último teste confere que nenhuma política do banco ficou fora desta lista.
-- Usuários: A = Pro · B = Grátis · C = Grátis · D = Pro (bloqueado por A).
begin;
create extension if not exists pgtap with schema extensions;
select plan(124);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000c', 'caio@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000d', 'duda@exemplo.com');
-- G06.0: o social exige a faixa etária registrada (migration social_exige_faixa); aqui são adultos
insert into private.account_age (user_id, band, source)
select id, '18_plus', 'birthdate' from auth.users on conflict (user_id) do nothing;
insert into billing.entitlements (user_id, entitlement, active_until) values
  ('00000000-0000-7000-8000-00000000000a', 'pro', now() + interval '30 days'),
  ('00000000-0000-7000-8000-00000000000d', 'pro', now() + interval '30 days');
update public.profiles set handle = 'ana'  where id = '00000000-0000-7000-8000-00000000000a';
update public.profiles set handle = 'bia'  where id = '00000000-0000-7000-8000-00000000000b';
update public.profiles set handle = 'caio' where id = '00000000-0000-7000-8000-00000000000c';
update public.profiles set handle = 'duda' where id = '00000000-0000-7000-8000-00000000000d';

-- ids fixos
create temp table ids (nome text primary key, id uuid) on commit drop;
insert into ids values
  ('post_a', '01927a00-0000-7000-8000-0000000000a1'), ('post_b', '01927a00-0000-7000-8000-0000000000b1'),
  ('clube_x', '01927a00-0000-7000-8000-0000000000f1'), ('clube_pub', '01927a00-0000-7000-8000-0000000000f2'),
  ('cpost_a', '01927a00-0000-7000-8000-0000000000e1'), ('envio_a', '01927a00-0000-7000-8000-0000000000d1');
grant select on ids to authenticated, anon;

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
create function pg_temp.id(p text) returns uuid language sql stable as $$ select id from ids where nome = p $$;
-- linhas afetadas por um comando (UPDATE/DELETE negado pela RLS afeta 0 linhas, sem erro)
create function pg_temp.linhas(p_sql text) returns integer language plpgsql as $$
declare n integer; begin execute p_sql; get diagnostics n = row_count; return n; end $$;

-- dados (como postgres, sem RLS)
insert into public.user_blocks (blocker_id, blocked_id) values ('00000000-0000-7000-8000-00000000000a', '00000000-0000-7000-8000-00000000000d');
insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000a', '00000000-0000-7000-8000-00000000000b');
insert into public.posts (id, author_id, kind, body) values
  (pg_temp.id('post_a'), '00000000-0000-7000-8000-00000000000a', 'review', 'Resenha da Ana'),
  (pg_temp.id('post_b'), '00000000-0000-7000-8000-00000000000b', 'review', 'Resenha da Bia');
insert into public.post_comments (post_id, author_id, body) values (pg_temp.id('post_a'), '00000000-0000-7000-8000-00000000000a', 'comentário da Ana');
insert into public.post_likes (post_id, user_id) values (pg_temp.id('post_b'), '00000000-0000-7000-8000-00000000000b');
insert into public.clubs (id, owner_id, name) values (pg_temp.id('clube_x'), '00000000-0000-7000-8000-00000000000b', 'Clube X');
insert into public.clubs (id, owner_id, name, privacy) values (pg_temp.id('clube_pub'), '00000000-0000-7000-8000-00000000000d', 'Clube Público', 'public');
insert into public.club_members (club_id, user_id) values (pg_temp.id('clube_x'), '00000000-0000-7000-8000-00000000000a');
insert into public.club_invites (code, club_id, created_by, expires_at) values ('CONVITEX1', pg_temp.id('clube_x'), '00000000-0000-7000-8000-00000000000b', now() + interval '1 day');
insert into public.club_meetings (club_id, starts_at, created_by) values (pg_temp.id('clube_x'), now() + interval '3 days', '00000000-0000-7000-8000-00000000000b');
insert into public.club_posts (id, club_id, author_id, kind, chapter_index, body) values
  (pg_temp.id('cpost_a'), pg_temp.id('clube_x'), '00000000-0000-7000-8000-00000000000a', 'discussion', 3, 'post da Ana no clube');
insert into public.club_post_replies (post_id, author_id, body) values (pg_temp.id('cpost_a'), '00000000-0000-7000-8000-00000000000b', 'resposta da Bia');
insert into public.notifications (user_id, type) values
  ('00000000-0000-7000-8000-00000000000a', 'system'), ('00000000-0000-7000-8000-00000000000b', 'system');
insert into public.device_tokens (token, user_id, platform) values ('token-da-ana', '00000000-0000-7000-8000-00000000000a', 'android');
insert into catalog.authors (name) values ('Machado de Assis');
insert into catalog.works (title) values ('Dom Casmurro');
insert into catalog.work_authors (work_id, author_id) select w.id, a.id from catalog.works w, catalog.authors a;
insert into catalog.editions (title, source) values ('Dom Casmurro', 'openlibrary');
insert into catalog.community_submissions (id, isbn13, title, authors, submitted_by)
values (pg_temp.id('envio_a'), '9786500000001', 'Livro Novo', 'Autora', '00000000-0000-7000-8000-00000000000a');
insert into catalog.submission_confirmations (submission_id, user_id) values (pg_temp.id('envio_a'), '00000000-0000-7000-8000-00000000000a');
insert into personal.user_books (id, user_id, title, author_display, format, status, added_at, created_at, updated_at, version_hlc) values
  ('01927a00-0000-7000-8000-000000000a01', '00000000-0000-7000-8000-00000000000a', 'Livro A', 'X', 'epub', 'reading', now(), now(), now(), '0001726862400000-0000-a'),
  ('01927a00-0000-7000-8000-000000000c01', '00000000-0000-7000-8000-00000000000c', 'Livro C', 'X', 'epub', 'reading', now(), now(), now(), '0001726862400000-0000-c');
insert into personal.reading_positions (id, user_id, locator, ref_page, chapter_index, progression, created_at, updated_at, version_hlc)
select id, user_id, '{"v":1}', 1, 0, 0.5, now(), now(), version_hlc from personal.user_books;
insert into personal.reading_sessions (id, user_id, user_book_id, started_at, ended_at, active_seconds, source, created_at, updated_at, version_hlc)
select gen_random_uuid(), user_id, id, '2025-05-01', '2025-05-01', 60, 'auto', now(), now(), version_hlc from personal.user_books;
insert into personal.bookmarks (id, user_id, user_book_id, locator, ref_page, chapter_index, created_at, updated_at, version_hlc)
select gen_random_uuid(), user_id, id, '{"v":1}', 1, 0, now(), now(), version_hlc from personal.user_books;
insert into personal.ink_layers (id, user_id, user_book_id, kind, anchor, strokes_b64, stroke_count, created_at, updated_at, version_hlc)
select gen_random_uuid(), user_id, id, 'over_text', '{"v":1}', '', 0, now(), now(), version_hlc from personal.user_books;
insert into personal.annotations (id, user_id, user_book_id, kind, group_id, anchor, ref_page, chapter_index, color, style, created_at, updated_at, version_hlc)
select gen_random_uuid(), user_id, id, 'highlight', gen_random_uuid(), '{"v":1}', 1, 0, '#FED170', 'fill', now(), now(), version_hlc from personal.user_books;
insert into personal.highlight_labels (id, user_id, color, label, created_at, updated_at, version_hlc)
select gen_random_uuid(), user_id, '#FED170', 'lindo', now(), now(), version_hlc from personal.user_books;
insert into personal.reader_settings (id, user_id, created_at, updated_at, version_hlc) select user_id, user_id, now(), now(), version_hlc from personal.user_books;
insert into personal.pen_presets (id, user_id, created_at, updated_at, version_hlc) select user_id, user_id, now(), now(), version_hlc from personal.user_books;
insert into personal.reading_goals (id, user_id, created_at, updated_at, version_hlc) select user_id, user_id, now(), now(), version_hlc from personal.user_books;
insert into storage.objects (bucket_id, name) values
  ('ebooks', '00000000-0000-7000-8000-00000000000a/01927a00-0000-7000-8000-000000000a01/livro.epub'),
  ('ebooks', '00000000-0000-7000-8000-00000000000c/01927a00-0000-7000-8000-000000000c01/livro.epub');

set local role authenticated;

-- =====================================================================================
-- catalog.*
-- =====================================================================================
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is((select count(*)::int from catalog.authors), 1, 'catalog_authors_read: autenticado lê');
select is((select count(*)::int from catalog.works), 1, 'catalog_works_read: autenticado lê');
select is((select count(*)::int from catalog.work_authors), 1, 'catalog_wa_read: autenticado lê');
select is((select count(*)::int from catalog.editions), 1, 'catalog_editions_read: autenticado lê');
select is((select count(*)::int from catalog.community_submissions), 1, 'submissions_read: autenticado lê');
select lives_ok($$ insert into catalog.community_submissions (isbn13, title, authors, submitted_by)
  values ('9786500000002', 'Outro', 'Autor', '00000000-0000-7000-8000-00000000000b') $$, 'submissions_insert: sugere em nome próprio');
select throws_like($$ insert into catalog.community_submissions (isbn13, title, authors, submitted_by)
  values ('9786500000003', 'Falso', 'Autor', '00000000-0000-7000-8000-00000000000a') $$, '%row-level security%',
  'submissions_insert: não sugere em nome de outra pessoa');
select lives_ok($$ insert into catalog.submission_confirmations (submission_id, user_id) values (pg_temp.id('envio_a'), '00000000-0000-7000-8000-00000000000b') $$,
  'confirmations_insert: confirma em nome próprio');
select throws_like($$ insert into catalog.submission_confirmations (submission_id, user_id) values (pg_temp.id('envio_a'), '00000000-0000-7000-8000-00000000000c') $$,
  '%row-level security%', 'confirmations_insert: não confirma por outra pessoa');
select is((select count(*)::int from catalog.submission_confirmations where user_id = '00000000-0000-7000-8000-00000000000b'), 1,
  'confirmations_read: vê a própria confirmação');
select is((select count(*)::int from catalog.submission_confirmations where user_id = '00000000-0000-7000-8000-00000000000a'), 0,
  'confirmations_read: não vê a de outra pessoa');
reset role; set local role anon;
select throws_ok($$ select count(*) from catalog.editions $$, '42501', null, 'catálogo: anon não lê (as 5 políticas de leitura são só para autenticados)');
reset role; set local role authenticated;

-- =====================================================================================
-- public.profiles, profile_stats
-- =====================================================================================
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is((select count(*)::int from public.profiles where handle = 'bia'), 1, 'profiles_read: vê o perfil de outra pessoa');
select is((select count(*)::int from public.profiles where handle = 'duda'), 0, 'profiles_read: perfil bloqueado some');
select is(pg_temp.linhas($$ update public.profiles set bio = 'oi' where id = '00000000-0000-7000-8000-00000000000a' $$), 1,
  'profiles_update_own: edita o próprio');
select is(pg_temp.linhas($$ update public.profiles set bio = 'invadido' where id = '00000000-0000-7000-8000-00000000000b' $$), 0,
  'profiles_update_own: não edita o de outra pessoa');
select is((select count(*)::int from public.profile_stats where user_id = '00000000-0000-7000-8000-00000000000b'), 1, 'profile_stats_read: vê os números de outra pessoa');
select is((select count(*)::int from public.profile_stats where user_id = '00000000-0000-7000-8000-00000000000d'), 0, 'profile_stats_read: os do bloqueado somem');

-- =====================================================================================
-- public.follows
-- =====================================================================================
select is((select count(*)::int from public.follows), 1, 'follows_read: vê o próprio seguir');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.follows), 0, 'follows_read: Grátis não vê a lista de seguidores alheia');
select lives_ok($$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000c', '00000000-0000-7000-8000-00000000000a') $$,
  'follows_insert: segue em nome próprio');
select throws_like($$ insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000b', '00000000-0000-7000-8000-00000000000c') $$,
  '%row-level security%', 'follows_insert: não faz outra pessoa seguir');
select is(pg_temp.linhas($$ delete from public.follows where follower_id = '00000000-0000-7000-8000-00000000000a' and followee_id = '00000000-0000-7000-8000-00000000000b' $$), 0,
  'follows_delete: terceiro não desfaz o seguir dos outros');
select is(pg_temp.linhas($$ delete from public.follows where follower_id = '00000000-0000-7000-8000-00000000000c' $$), 1,
  'follows_delete: desfaz o próprio seguir');
reset role;
update public.profiles set visibility = 'private' where handle = 'bia';
delete from public.follows;
insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000a', '00000000-0000-7000-8000-00000000000b');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is(pg_temp.linhas($$ update public.follows set status = 'accepted' where follower_id = '00000000-0000-7000-8000-00000000000a' $$), 0,
  'follows_accept: quem pediu não aceita o próprio pedido');
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is(pg_temp.linhas($$ update public.follows set status = 'accepted' where followee_id = '00000000-0000-7000-8000-00000000000b' $$), 1,
  'follows_accept: o dono do perfil aceita');
reset role;
update public.profiles set visibility = 'public' where handle = 'bia';
set local role authenticated;

-- =====================================================================================
-- public.user_blocks
-- =====================================================================================
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select lives_ok($$ insert into public.user_blocks (blocker_id, blocked_id) values ('00000000-0000-7000-8000-00000000000b', '00000000-0000-7000-8000-00000000000c') $$,
  'blocks_own: bloqueia em nome próprio');
select throws_like($$ insert into public.user_blocks (blocker_id, blocked_id) values ('00000000-0000-7000-8000-00000000000c', '00000000-0000-7000-8000-00000000000b') $$,
  '%row-level security%', 'blocks_own: não bloqueia em nome de outra pessoa');
select is((select count(*)::int from public.user_blocks), 1, 'blocks_own: vê só os próprios bloqueios (não o de A contra D)');
reset role; delete from public.user_blocks where blocker_id = '00000000-0000-7000-8000-00000000000b'; set local role authenticated;

-- =====================================================================================
-- public.posts, post_comments, post_likes
-- =====================================================================================
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is((select count(*)::int from public.posts where id = pg_temp.id('post_b')), 1, 'posts_read: Pro vê o post de perfil aberto');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.posts where id = pg_temp.id('post_b')), 0, 'posts_read: Grátis não vê o post alheio');
select lives_ok($$ insert into public.posts (author_id, kind, body) values ('00000000-0000-7000-8000-00000000000c', 'review', 'meu') $$, 'posts_insert: publica em nome próprio');
select throws_like($$ insert into public.posts (author_id, kind, body) values ('00000000-0000-7000-8000-00000000000a', 'review', 'falso') $$,
  '%row-level security%', 'posts_insert: não publica em nome de outra pessoa');
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is(pg_temp.linhas($$ update public.posts set body = 'editado' where id = pg_temp.id('post_a') $$), 1, 'posts_update_own: edita o próprio');
select is(pg_temp.linhas($$ update public.posts set body = 'vandalizado' where id = pg_temp.id('post_b') $$), 0,
  'posts_update_own: Pro vê mas não edita o post alheio');
select is(pg_temp.linhas($$ update public.posts set deleted_at = now() where id = pg_temp.id('post_a') $$), 1,
  'posts_update_own: apaga (deleted_at) o próprio post — a política de leitura deixa o autor ver o apagado');
select is((select count(*)::int from public.post_comments where post_id = pg_temp.id('post_a')), 1, 'post_comments_read: vê comentário de post visível');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.post_comments where post_id = pg_temp.id('post_a')), 0, 'post_comments_read: Grátis não vê comentários de post alheio');
select throws_like($$ insert into public.post_comments (post_id, author_id, body) values (pg_temp.id('post_a'), '00000000-0000-7000-8000-00000000000c', 'oi') $$,
  '%row-level security%', 'post_comments_insert: não comenta em post que não vê');
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select lives_ok($$ insert into public.post_comments (post_id, author_id, body) values (pg_temp.id('post_b'), '00000000-0000-7000-8000-00000000000a', 'boa!') $$,
  'post_comments_insert: comenta em post visível');
select is(pg_temp.linhas($$ update public.post_comments set deleted_at = now() where author_id = '00000000-0000-7000-8000-00000000000a' and post_id = pg_temp.id('post_a') $$), 1,
  'post_comments_delete_own: apaga o próprio comentário');
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is(pg_temp.linhas($$ update public.post_comments set deleted_at = now() where author_id = '00000000-0000-7000-8000-00000000000a' $$), 0,
  'post_comments_delete_own: não apaga o comentário de outra pessoa (nem no próprio post)');
select is((select count(*)::int from public.post_likes where post_id = pg_temp.id('post_b')), 1, 'post_likes_read: vê curtidas do próprio post');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.post_likes), 0, 'post_likes_read: Grátis não vê curtidas de post alheio');
select throws_like($$ insert into public.post_likes (post_id, user_id) values (pg_temp.id('post_b'), '00000000-0000-7000-8000-00000000000c') $$,
  '%row-level security%', 'post_likes_write: não curte post que não vê');
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select lives_ok($$ insert into public.post_likes (post_id, user_id) values (pg_temp.id('post_b'), '00000000-0000-7000-8000-00000000000a') $$, 'post_likes_write: curte post visível');
select is(pg_temp.linhas($$ delete from public.post_likes where user_id = '00000000-0000-7000-8000-00000000000b' $$), 0, 'post_likes_delete: não desfaz a curtida alheia');
select is(pg_temp.linhas($$ delete from public.post_likes where user_id = '00000000-0000-7000-8000-00000000000a' $$), 1, 'post_likes_delete: desfaz a própria');

-- =====================================================================================
-- clubes
-- =====================================================================================
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is((select count(*)::int from public.clubs where id = pg_temp.id('clube_x')), 1, 'clubs_read: membro vê o clube por convite');
select is((select count(*)::int from public.clubs where id = pg_temp.id('clube_pub')), 1, 'clubs_read: todos veem o clube público');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.clubs where id = pg_temp.id('clube_x')), 0, 'clubs_read: não membro não vê o clube por convite');
select lives_ok($$ insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000c', 'Clube do Caio') $$, 'clubs_insert: cria em nome próprio');
select throws_like($$ insert into public.clubs (owner_id, name) values ('00000000-0000-7000-8000-00000000000d', 'Clube falso') $$,
  '%row-level security%', 'clubs_insert: não cria em nome de outra pessoa');
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is(pg_temp.linhas($$ update public.clubs set goal_chapter = 10 where id = pg_temp.id('clube_x') $$), 1, 'clubs_update_admin: o dono edita');
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is(pg_temp.linhas($$ update public.clubs set goal_chapter = 99 where id = pg_temp.id('clube_x') $$), 0, 'clubs_update_admin: membro comum não edita');
select is((select count(*)::int from public.club_members where club_id = pg_temp.id('clube_x')), 2, 'club_members_read: membro vê os membros');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.club_members where club_id = pg_temp.id('clube_x')), 0, 'club_members_read: não membro não vê');
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is(pg_temp.linhas($$ update public.club_members set progress_chapter = 5 where club_id = pg_temp.id('clube_x') and user_id = '00000000-0000-7000-8000-00000000000a' $$), 1,
  'club_members_update_self: publica o próprio progresso');
select is(pg_temp.linhas($$ update public.club_members set progress_chapter = 99 where club_id = pg_temp.id('clube_x') and user_id = '00000000-0000-7000-8000-00000000000b' $$), 0,
  'club_members_update_self: não mexe no progresso de outra pessoa');
select is(pg_temp.linhas($$ delete from public.club_members where club_id = pg_temp.id('clube_x') and user_id = '00000000-0000-7000-8000-00000000000b' $$), 0,
  'club_members_leave: membro não remove o dono');
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is(pg_temp.linhas($$ delete from public.club_members where club_id = pg_temp.id('clube_x') and user_id = '00000000-0000-7000-8000-00000000000b' $$), 0,
  'club_members_leave: o dono não "sai" (transfere)');
select lives_ok($$ insert into public.club_invites (club_id, created_by, expires_at) values (pg_temp.id('clube_x'), '00000000-0000-7000-8000-00000000000b', now() + interval '1 day') $$,
  'club_invites_admin: o dono cria convite (o código é gerado pelo servidor)');
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select throws_like($$ insert into public.club_invites (club_id, created_by, expires_at) values (pg_temp.id('clube_x'), '00000000-0000-7000-8000-00000000000a', now() + interval '1 day') $$,
  '%row-level security%', 'club_invites_admin: membro comum não cria convite');
select is((select count(*)::int from public.club_invites), 0, 'club_invites_admin: membro comum não vê os convites');
select is((select count(*)::int from public.club_meetings), 1, 'club_meetings_read: membro vê os encontros');
select throws_like($$ insert into public.club_meetings (club_id, starts_at, created_by) values (pg_temp.id('clube_x'), now() + interval '9 days', '00000000-0000-7000-8000-00000000000a') $$,
  '%row-level security%', 'club_meetings_admin: membro comum não marca encontro');
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select lives_ok($$ insert into public.club_meetings (club_id, starts_at, created_by) values (pg_temp.id('clube_x'), now() + interval '9 days', '00000000-0000-7000-8000-00000000000b') $$,
  'club_meetings_admin: o dono marca encontro');
select is(pg_temp.linhas($$ update public.club_meetings set location = 'Biblioteca' where club_id = pg_temp.id('clube_x') $$), 2,
  'club_meetings_admin_update: o dono remarca/edita');
select is(pg_temp.linhas($$ delete from public.club_meetings where club_id = pg_temp.id('clube_x') and starts_at > now() + interval '8 days' $$), 1,
  'club_meetings_admin_delete: o dono desmarca');
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is(pg_temp.linhas($$ update public.club_meetings set location = 'Bar' where club_id = pg_temp.id('clube_x') $$), 0,
  'club_meetings_admin_update: membro comum não edita');
select is(pg_temp.linhas($$ delete from public.club_meetings where club_id = pg_temp.id('clube_x') $$), 0,
  'club_meetings_admin_delete: membro comum não desmarca');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.club_meetings), 0, 'club_meetings_read: não membro não vê');
select is((select count(*)::int from public.club_posts), 0, 'club_posts_read: não membro não vê os posts');
select throws_like($$ insert into public.club_posts (club_id, author_id, kind, chapter_index, body) values (pg_temp.id('clube_x'), '00000000-0000-7000-8000-00000000000c', 'discussion', 1, 'oi') $$,
  '%row-level security%', 'club_posts_insert: não membro não posta');
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is((select count(*)::int from public.club_posts), 1, 'club_posts_read: membro vê os posts');
select lives_ok($$ insert into public.club_posts (club_id, author_id, kind, chapter_index, body) values (pg_temp.id('clube_x'), '00000000-0000-7000-8000-00000000000b', 'discussion', 1, 'oi') $$,
  'club_posts_insert: membro posta');
select is(pg_temp.linhas($$ update public.club_posts set body = 'mudado' where id = pg_temp.id('cpost_a') $$), 0, 'club_posts_update_own: não edita o post de outro membro');
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is(pg_temp.linhas($$ update public.club_posts set body = 'editado' where id = pg_temp.id('cpost_a') $$), 1, 'club_posts_update_own: edita o próprio');
select is(pg_temp.linhas($$ update public.club_posts set deleted_at = now() where id = pg_temp.id('cpost_a') $$), 1, 'club_posts_update_own: apaga o próprio');
select is(pg_temp.linhas($$ update public.club_posts set deleted_at = null where id = pg_temp.id('cpost_a') $$), 1, '(desfaz para os próximos casos)');
select is((select count(*)::int from public.club_post_replies), 1, 'club_replies_read: membro vê as respostas');
select lives_ok($$ insert into public.club_post_replies (post_id, author_id, body) values (pg_temp.id('cpost_a'), '00000000-0000-7000-8000-00000000000a', 'eu') $$,
  'club_replies_insert(+_member): membro responde em nome próprio');
select is(pg_temp.linhas($$ update public.club_post_replies set deleted_at = now() where author_id = '00000000-0000-7000-8000-00000000000b' $$), 0,
  'club_replies_update_own: não apaga a resposta de outro membro');
select is(pg_temp.linhas($$ update public.club_post_replies set deleted_at = now() where author_id = '00000000-0000-7000-8000-00000000000a' $$), 1,
  'club_replies_update_own: apaga a própria resposta');
select is((select replies_count from public.club_posts where id = pg_temp.id('cpost_a')), 1, 'o contador de respostas desconta a apagada');
select throws_like($$ insert into public.club_post_replies (post_id, author_id, body) values (pg_temp.id('cpost_a'), '00000000-0000-7000-8000-00000000000b', 'falso') $$,
  '%row-level security%', 'club_replies_insert: não responde em nome de outra pessoa');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.club_post_replies), 0, 'club_replies_read: não membro não vê');
select throws_like($$ insert into public.club_post_replies (post_id, author_id, body) values (pg_temp.id('cpost_a'), '00000000-0000-7000-8000-00000000000c', 'intrusa') $$,
  '%row-level security%', 'club_replies_insert_member (restritiva): não membro não responde');

-- =====================================================================================
-- notificações, aparelhos, denúncias
-- =====================================================================================
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is((select count(*)::int from public.notifications where type = 'system'), 1, 'notifications_own: vê só as próprias');
select ok((select bool_and(user_id = '00000000-0000-7000-8000-00000000000a') from public.notifications), 'notifications_own: nenhuma de outra pessoa');
select is(pg_temp.linhas($$ update public.notifications set read_at = now() where user_id = '00000000-0000-7000-8000-00000000000a' and type = 'system' $$), 1, 'notifications_mark_read: marca as próprias');
select is(pg_temp.linhas($$ update public.notifications set read_at = now() where user_id = '00000000-0000-7000-8000-00000000000b' $$), 0, 'notifications_mark_read: não marca as alheias');
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is((select count(*)::int from public.notifications where user_id = '00000000-0000-7000-8000-00000000000a'), 0, 'notifications_own: não vê as de outra pessoa');
select is((select count(*)::int from public.device_tokens), 0, 'device_tokens_own: não vê o aparelho de outra pessoa');
-- (registro só pela RPC public.register_device_token — 13_revisao_g04; aqui leitura e exclusão)
select is(pg_temp.linhas($$ delete from public.device_tokens where token = 'token-da-ana' $$), 0, 'device_tokens_own: não apaga o aparelho de outra pessoa');
select public.register_device_token('token-da-bia', 'ios');
select is(pg_temp.linhas($$ delete from public.device_tokens where token = 'token-da-bia' $$), 1, 'device_tokens_own: apaga o próprio');
select lives_ok($$ insert into public.content_reports (reporter_id, target_type, target_id, reason) values ('00000000-0000-7000-8000-00000000000b', 'post', pg_temp.id('post_a'), 'spam') $$,
  'reports_insert: denuncia em nome próprio');
select throws_like($$ insert into public.content_reports (reporter_id, target_type, target_id, reason) values ('00000000-0000-7000-8000-00000000000c', 'post', pg_temp.id('post_a'), 'spam') $$,
  '%row-level security%', 'reports_insert: não denuncia em nome de outra pessoa');

-- =====================================================================================
-- personal.* (own_read nas 10 tabelas) — A vê as próprias linhas e não as de C
-- =====================================================================================
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is((select count(*)::int from personal.user_books        where user_id = '00000000-0000-7000-8000-00000000000a'), 1, 'own_read user_books: vê as próprias');
select is((select count(*)::int from personal.user_books        where user_id = '00000000-0000-7000-8000-00000000000c'), 0, 'own_read user_books: não vê as de outra pessoa');
select is((select count(*)::int from personal.reading_positions where user_id = '00000000-0000-7000-8000-00000000000a'), 1, 'own_read reading_positions: vê');
select is((select count(*)::int from personal.reading_positions where user_id = '00000000-0000-7000-8000-00000000000c'), 0, 'own_read reading_positions: não vê');
select is((select count(*)::int from personal.reading_sessions  where user_id = '00000000-0000-7000-8000-00000000000a'), 1, 'own_read reading_sessions: vê');
select is((select count(*)::int from personal.reading_sessions  where user_id = '00000000-0000-7000-8000-00000000000c'), 0, 'own_read reading_sessions: não vê');
select is((select count(*)::int from personal.bookmarks         where user_id = '00000000-0000-7000-8000-00000000000a'), 1, 'own_read bookmarks: vê');
select is((select count(*)::int from personal.bookmarks         where user_id = '00000000-0000-7000-8000-00000000000c'), 0, 'own_read bookmarks: não vê');
select is((select count(*)::int from personal.ink_layers        where user_id = '00000000-0000-7000-8000-00000000000a'), 1, 'own_read ink_layers: vê');
select is((select count(*)::int from personal.ink_layers        where user_id = '00000000-0000-7000-8000-00000000000c'), 0, 'own_read ink_layers: não vê');
select is((select count(*)::int from personal.annotations       where user_id = '00000000-0000-7000-8000-00000000000a'), 1, 'own_read annotations: vê');
select is((select count(*)::int from personal.annotations       where user_id = '00000000-0000-7000-8000-00000000000c'), 0, 'own_read annotations: não vê');
select is((select count(*)::int from personal.highlight_labels  where user_id = '00000000-0000-7000-8000-00000000000a'), 1, 'own_read highlight_labels: vê');
select is((select count(*)::int from personal.highlight_labels  where user_id = '00000000-0000-7000-8000-00000000000c'), 0, 'own_read highlight_labels: não vê');
select is((select count(*)::int from personal.reader_settings   where user_id = '00000000-0000-7000-8000-00000000000a'), 1, 'own_read reader_settings: vê');
select is((select count(*)::int from personal.reader_settings   where user_id = '00000000-0000-7000-8000-00000000000c'), 0, 'own_read reader_settings: não vê');
select is((select count(*)::int from personal.pen_presets       where user_id = '00000000-0000-7000-8000-00000000000a'), 1, 'own_read pen_presets: vê');
select is((select count(*)::int from personal.pen_presets       where user_id = '00000000-0000-7000-8000-00000000000c'), 0, 'own_read pen_presets: não vê');
select is((select count(*)::int from personal.reading_goals     where user_id = '00000000-0000-7000-8000-00000000000a'), 1, 'own_read reading_goals: vê');
select is((select count(*)::int from personal.reading_goals     where user_id = '00000000-0000-7000-8000-00000000000c'), 0, 'own_read reading_goals: não vê');

-- =====================================================================================
-- storage.objects (bucket ebooks)
-- =====================================================================================
select is((select count(*)::int from storage.objects where bucket_id = 'ebooks' and name like '00000000-0000-7000-8000-00000000000a/%'), 1, 'ebooks_owner_read: vê o próprio e-book');
select is((select count(*)::int from storage.objects where bucket_id = 'ebooks' and name like '00000000-0000-7000-8000-00000000000c/%'), 0, 'ebooks_owner_read: não vê o de outra pessoa');
-- o Supabase bloqueia DELETE em storage.objects fora da API do Storage (gatilho protect_delete);
-- a API liga esta chave na própria sessão — aqui ela é ligada para testar só a RLS.
select set_config('storage.allow_delete_query', 'true', true);
select is(pg_temp.linhas($$ delete from storage.objects where bucket_id = 'ebooks' and name like '00000000-0000-7000-8000-00000000000c/%' $$), 0, 'ebooks_owner_delete: não apaga o de outra pessoa');
select is(pg_temp.linhas($$ delete from storage.objects where bucket_id = 'ebooks' and name like '00000000-0000-7000-8000-00000000000a/%' $$), 1, 'ebooks_owner_delete: apaga o próprio');
select throws_like($$ insert into storage.objects (bucket_id, name) values ('ebooks', '00000000-0000-7000-8000-00000000000a/x/y.epub') $$,
  '%row-level security%', 'sem política de INSERT: upload direto proibido (só por URL assinada)');

reset role;
-- =====================================================================================
-- Toda política do banco está coberta acima (política nova sem teste → este teste falha)
-- =====================================================================================
select set_eq(
  $$ select schemaname || '.' || tablename || '.' || policyname from pg_policies
      where schemaname in ('public', 'personal', 'catalog', 'billing', 'private')
         or (schemaname = 'storage' and policyname like 'ebooks%') $$,
  $$ values
    ('catalog.authors.catalog_authors_read'), ('catalog.works.catalog_works_read'), ('catalog.work_authors.catalog_wa_read'),
    ('catalog.editions.catalog_editions_read'), ('catalog.community_submissions.submissions_read'),
    ('catalog.community_submissions.submissions_insert'), ('catalog.submission_confirmations.confirmations_insert'),
    ('catalog.submission_confirmations.confirmations_read'),
    ('public.profiles.profiles_read'), ('public.profiles.profiles_update_own'), ('public.profile_stats.profile_stats_read'),
    ('public.follows.follows_read'), ('public.follows.follows_insert'), ('public.follows.follows_delete'), ('public.follows.follows_accept'),
    ('public.user_blocks.blocks_own'),
    ('public.posts.posts_read'), ('public.posts.posts_insert'), ('public.posts.posts_update_own'),
    ('public.post_comments.post_comments_read'), ('public.post_comments.post_comments_insert'), ('public.post_comments.post_comments_delete_own'),
    ('public.post_likes.post_likes_read'), ('public.post_likes.post_likes_write'), ('public.post_likes.post_likes_delete'),
    ('public.clubs.clubs_read'), ('public.clubs.clubs_insert'), ('public.clubs.clubs_update_admin'),
    ('public.club_members.club_members_read'), ('public.club_members.club_members_update_self'), ('public.club_members.club_members_leave'),
    ('public.club_invites.club_invites_admin'),
    ('public.club_meetings.club_meetings_read'), ('public.club_meetings.club_meetings_admin'),
    ('public.club_meetings.club_meetings_admin_update'), ('public.club_meetings.club_meetings_admin_delete'),
    ('public.club_posts.club_posts_read'), ('public.club_posts.club_posts_insert'), ('public.club_posts.club_posts_update_own'),
    ('public.club_post_replies.club_replies_read'), ('public.club_post_replies.club_replies_insert'), ('public.club_post_replies.club_replies_insert_member'), ('public.club_post_replies.club_replies_update_own'),
    ('public.notifications.notifications_own'), ('public.notifications.notifications_mark_read'),
    ('public.device_tokens.device_tokens_own'), ('public.content_reports.reports_insert'),
    ('personal.user_books.own_read'), ('personal.reading_positions.own_read'), ('personal.reading_sessions.own_read'),
    ('personal.bookmarks.own_read'), ('personal.ink_layers.own_read'), ('personal.annotations.own_read'),
    ('personal.highlight_labels.own_read'), ('personal.reader_settings.own_read'), ('personal.pen_presets.own_read'),
    ('personal.reading_goals.own_read'),
    ('storage.objects.ebooks_owner_read'), ('storage.objects.ebooks_owner_delete') $$,
  'toda política de RLS tem caso permitido e negado neste arquivo');

select * from finish();
rollback;

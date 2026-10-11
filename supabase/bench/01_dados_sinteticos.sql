-- =====================================================================================
-- G04.6 — dados sintéticos para medir as consultas quentes (Anexo 02 §10). SÓ no banco LOCAL
-- (tools/supabase/medir_consultas.sh confere a URL). Volume: 100 mil usuários (5 % Pro), com
-- social, clubes, notificações, catálogo referenciado e dados pessoais dos Pro.
-- Gatilhos desligados durante a carga (session_replication_role = replica): os dados já nascem
-- coerentes (perfis, contadores e membros gerados aqui).
-- =====================================================================================
\set ON_ERROR_STOP on
set session_replication_role = replica;
set synchronous_commit = off;
select setseed(0.20261004);

-- usuários: u(n) = '00000000-0000-7000-8000-' || lpad(to_hex(n), 12, '0')
create or replace function pg_temp.u(n bigint) returns uuid language sql immutable as
$$ select ('00000000-0000-7000-8000-' || lpad(to_hex(n), 12, '0'))::uuid $$;

insert into auth.users (id, email, created_at)
select pg_temp.u(n), 'leitor' || n || '@bench.booknest', now() - (n % 700) * interval '1 day'
  from generate_series(1, 100000) n;
insert into public.profiles (id, handle, display_name, visibility, created_at, updated_at)
select pg_temp.u(n), 'leitor' || n, 'Leitor ' || n, case when n % 10 = 0 then 'private' else 'public' end, now(), now()
  from generate_series(1, 100000) n;
insert into public.profile_stats (user_id, books_read_total, books_read_year, reading_now, streak_days)
select pg_temp.u(n), n % 200, n % 30, n % 4, n % 50 from generate_series(1, 100000) n;
insert into billing.entitlements (user_id, entitlement, active_until)
select pg_temp.u(n), 'pro', now() + interval '30 days' from generate_series(1, 100000) n where n % 20 = 0;
insert into billing.sync_access (user_id, granted) select user_id, true from billing.entitlements;

-- catálogo referenciado: 200 mil edições com títulos de 2 a 4 pseudopalavras (sílabas do português),
-- para a busca por trigramas ter a seletividade de um catálogo de verdade
create or replace function pg_temp.palavra(semente bigint) returns text language sql immutable as $$
  select string_agg((array['ba','ca','de','fi','go','lu','ma','ne','po','ri','sa','te','vo','xa','zu','lha','nho','que',
                           'ção','rra','bri','cla','dro','flo','gra','pla','tri','sem','mor','tas'])[1 + abs(hashtext(semente || ':' || k)) % 30], '')
    from generate_series(1, 2 + (semente % 3)::int) k
$$;
insert into catalog.editions (title, source)
select initcap(concat_ws(' ', pg_temp.palavra(n * 3), pg_temp.palavra(n * 3 + 1),
                         case when n % 2 = 0 then pg_temp.palavra(n * 3 + 2) end)), 'openlibrary'
  from generate_series(1, 200000) n;
insert into catalog.editions (title, source) values ('Dom Casmurro', 'openlibrary'), ('Memórias Póstumas de Brás Cubas', 'openlibrary');

-- social: 3 posts por usuário ativo (1/3 dos usuários), 5 seguidas por usuário, curtidas e comentários
insert into public.posts (id, author_id, kind, body, created_at)
select gen_random_uuid(), pg_temp.u(1 + (n % 33334) * 3), 'review', 'Resenha ' || n, now() - (n % 365) * interval '1 day'
  from generate_series(1, 100000) n;
insert into public.follows (follower_id, followee_id, status, created_at)
select distinct on (a, b) pg_temp.u(a), pg_temp.u(b), 'accepted', now()
  from (select a, 1 + ((a::bigint * 7919 + k * 104729) % 100000) b
          from generate_series(1, 100000) a, generate_series(1, 5) k) x
 where a <> b;
insert into public.post_likes (post_id, user_id)
select distinct on (p.id, u) p.id, pg_temp.u(u)
  from (select id, row_number() over () r from public.posts) p
  cross join lateral (select 1 + ((p.r * 31 + k) % 100000) u from generate_series(1, 3) k) l;
insert into public.post_comments (post_id, author_id, body, created_at)
select p.id, pg_temp.u(1 + (p.r * 17 % 100000)), 'comentário', now() - (p.r % 100) * interval '1 hour'
  from (select id, row_number() over () r from public.posts) p where p.r % 2 = 0;

-- clubes: 10 mil clubes, 10 membros cada; 200 mil posts e 500 mil respostas
insert into public.clubs (id, owner_id, name, privacy, created_at, updated_at)
select pg_temp.u(1000000 + n), pg_temp.u(n * 10), 'Clube ' || n, case when n % 4 = 0 then 'public' else 'invite' end, now(), now()
  from generate_series(1, 10000) n;
insert into public.club_members (club_id, user_id, role)
select pg_temp.u(1000000 + c), pg_temp.u(case when k = 0 then c * 10 else 1 + ((c * 13 + k * 7) % 100000) end),
       case when k = 0 then 'owner' else 'member' end
  from generate_series(1, 10000) c, generate_series(0, 9) k
on conflict do nothing;
insert into public.club_posts (id, club_id, author_id, kind, chapter_index, body, created_at)
select gen_random_uuid(), pg_temp.u(1000000 + 1 + (n % 10000)), pg_temp.u((1 + (n % 10000)) * 10), 'discussion', n % 148,
       'post ' || n, now() - (n % 2000) * interval '1 hour'
  from generate_series(1, 200000) n;
-- o Clube 1 é movimentado (2 mil posts) para a 2ª página do feed ter o que mostrar
insert into public.club_posts (id, club_id, author_id, kind, chapter_index, body, created_at)
select gen_random_uuid(), pg_temp.u(1000001), pg_temp.u(1 + n % 9), 'discussion', n % 148, 'post ' || n, now() - n * interval '7 minutes'
  from generate_series(1, 2000) n;
insert into public.club_post_replies (post_id, club_id, author_id, body, created_at)
select p.id, p.club_id, p.author_id, 'resposta', p.created_at + k * interval '1 minute'
  from (select id, club_id, author_id, created_at, row_number() over () r from public.club_posts) p
  cross join generate_series(1, 3) k
 where p.r % 6 < 5 and (p.r + k) % 5 <> 0;

-- notificações: 10 por usuário (1 milhão), metade lida
insert into public.notifications (user_id, type, created_at, read_at, push_sent_at)
select pg_temp.u(1 + (n % 100000)), 'post_like', now() - (n % 1000) * interval '1 hour',
       case when n % 2 = 0 then now() end, now()
  from generate_series(1, 1000000) n;

-- dados pessoais dos 5 mil Pro: 10 livros, 40 anotações, 60 sessões cada
insert into personal.user_books (id, user_id, title, author_display, format, status, added_at, created_at, updated_at, version_hlc)
select pg_temp.u(2000000 + n), pg_temp.u(20 * (1 + (n % 5000))), 'Livro ' || n, 'Autor', 'epub', 'reading',
       now(), now(), now(), '0001790000000000-0000-bench'
  from generate_series(0, 49999) n;
insert into personal.annotations (id, user_id, user_book_id, kind, group_id, anchor, ref_page, chapter_index, color, style, created_at, updated_at, version_hlc)
select gen_random_uuid(), b.user_id, b.id, 'highlight', gen_random_uuid(), '{"v":1}', 1 + k * 3, k, '#FED170', 'fill', now(), now(), b.version_hlc
  from personal.user_books b, generate_series(1, 4) k;
select private.ensure_session_partitions(3);
insert into personal.reading_sessions (id, user_id, user_book_id, started_at, ended_at, active_seconds, source, created_at, updated_at, version_hlc)
select gen_random_uuid(), b.user_id, b.id, s, s + interval '20 minutes', 1200, 'auto', now(), now(), b.version_hlc
  from personal.user_books b,
       lateral (select date_trunc('day', now()) - (k * interval '5 days') - interval '3 hours' s from generate_series(0, 5) k) d;

set session_replication_role = origin;
analyze;
select (select count(*) from auth.users) usuarios, (select count(*) from public.posts) posts, (select count(*) from public.follows) seguidas,
       (select count(*) from public.club_posts) posts_clube, (select count(*) from public.club_post_replies) respostas,
       (select count(*) from public.notifications) notificacoes, (select count(*) from catalog.editions) edicoes,
       (select count(*) from personal.annotations) anotacoes, (select count(*) from personal.reading_sessions) sessoes;

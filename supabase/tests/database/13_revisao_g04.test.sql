-- Revisão independente da G04 (migration revisao_g04): cada achado corrigido tem aqui o ataque ou o
-- defeito reproduzido. Usuários: A = Pro · B = Grátis · C = Grátis (perfil fechado) · D = Pro.
begin;
create extension if not exists pgtap with schema extensions;
select plan(66);

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
-- G05: conta nova nasce com o perfil fechado até registrar a faixa etária (D-66); aqui são adultos de perfil aberto
update public.profiles set visibility = 'public';
update public.profiles set handle = 'caio', visibility = 'private' where id = '00000000-0000-7000-8000-00000000000c';
create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
create function pg_temp.linhas(p_sql text) returns integer language plpgsql as $$
declare n integer; begin execute p_sql; get diagnostics n = row_count; return n; end $$;

-- =====================================================================================
-- #1 (ALTA) moderação: o autor não desfaz o "ocultar"; ocultar perfil limpa nome e @
-- =====================================================================================
insert into public.posts (id, author_id, kind, body) values
  ('01927a00-0000-7000-8000-0000000000b1', '00000000-0000-7000-8000-00000000000b', 'review', 'resenha denunciada'),
  ('01927a00-0000-7000-8000-0000000000b2', '00000000-0000-7000-8000-00000000000b', 'review', 'outra resenha');
insert into public.clubs (id, owner_id, name) values ('01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000b', 'Clube K');
insert into public.club_members (club_id, user_id) values ('01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000a');
insert into public.club_posts (id, club_id, author_id, kind, chapter_index, body)
values ('01927a00-0000-7000-8000-0000000000e1', '01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000b', 'discussion', 1, 'oi');
insert into public.club_post_replies (id, post_id, author_id, body)
values ('01927a00-0000-7000-8000-0000000000e2', '01927a00-0000-7000-8000-0000000000e1', '00000000-0000-7000-8000-00000000000a', 'resposta denunciada');
insert into public.content_reports (reporter_id, target_type, target_id, reason) values
  ('00000000-0000-7000-8000-00000000000a', 'post', '01927a00-0000-7000-8000-0000000000b1', 'hate'),
  ('00000000-0000-7000-8000-00000000000b', 'club_post_reply', '01927a00-0000-7000-8000-0000000000e2', 'harassment');
select private.moderate_report(id, 'hide', 'moderadora@booknest') from public.content_reports where status = 'open';
select ok((select moderated_at is not null and deleted_at is not null from public.posts where id = '01927a00-0000-7000-8000-0000000000b1'),
  '"hide" marca o post como moderado (além de ocultar)');
select is((select posts_count from public.profile_stats where user_id = '00000000-0000-7000-8000-00000000000b'), 1,
  'o post moderado sai do contador do autor');
select is((select count(*)::int from pg_trigger where tgname like '%\_moderation\_guard' and not tgisinternal), 4,
  'a trava vale para posts, comentários, posts do clube e respostas');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select throws_ok($$ update public.posts set deleted_at = null where id = '01927a00-0000-7000-8000-0000000000b1' $$,
  'P0001', 'content_moderated', 'o autor NÃO restaura o post ocultado pela moderação');
select throws_ok($$ update public.posts set body = 'trocado' where id = '01927a00-0000-7000-8000-0000000000b1' $$,
  'P0001', 'content_moderated', 'nem edita o texto do post moderado');
select throws_ok($$ update public.posts set moderated_at = null where id = '01927a00-0000-7000-8000-0000000000b1' $$,
  '42501', null, 'moderated_at é só do servidor (sem GRANT)');
select is(pg_temp.linhas($$ update public.posts set deleted_at = now() where id = '01927a00-0000-7000-8000-0000000000b2' $$)
        + pg_temp.linhas($$ update public.posts set deleted_at = null where id = '01927a00-0000-7000-8000-0000000000b2' $$), 2,
  'o autor continua apagando e restaurando o que ELE apagou');
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select throws_ok($$ update public.club_post_replies set deleted_at = null where id = '01927a00-0000-7000-8000-0000000000e2' $$,
  'P0001', 'content_moderated', 'resposta do clube moderada também não volta');
reset role;

-- perfil: o nome provisório tem um termo que a equipe proibiu DEPOIS
update public.profiles set display_name = 'Caio Feio', bio = 'bio', avatar_path = 'avatars/caio.png'
 where id = '00000000-0000-7000-8000-00000000000c';
insert into private.blocked_terms (term) values ('feio');
insert into public.content_reports (reporter_id, target_type, target_id, reason)
values ('00000000-0000-7000-8000-00000000000a', 'profile', '00000000-0000-7000-8000-00000000000c', 'harassment');
select lives_ok($$ select private.moderate_report(id, 'hide', 'moderadora@booknest') from public.content_reports where status = 'open' $$,
  'ocultar perfil funciona mesmo com termo proibido no nome atual');
select is((select row(display_name, bio, avatar_path)::text from public.profiles where id = '00000000-0000-7000-8000-00000000000c'),
  row('Leitor', null::text, null::text)::text, 'ocultar perfil: nome volta a "Leitor", bio e foto saem');
select matches((select handle from public.profiles where id = '00000000-0000-7000-8000-00000000000c'), '^leitor_[0-9a-f]{12}$',
  'ocultar perfil: o @ volta ao provisório');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select throws_ok($$ update public.profiles set handle = 'caio.feio' where id = '00000000-0000-7000-8000-00000000000c' $$,
  'P0001', 'content_blocked', 'o filtro de termos vale também para o @ (separado por ponto ou _)');
reset role;

-- =====================================================================================
-- #4 cadastro com termo proibido no e-mail não derruba o Auth
-- =====================================================================================
select lives_ok($$ insert into auth.users (id, email) values ('00000000-0000-7000-8000-00000000000e', 'feio.silva@exemplo.com') $$,
  'cadastro com termo proibido antes do @ não falha');
select is((select display_name from public.profiles where id = '00000000-0000-7000-8000-00000000000e'), 'Leitor',
  'o nome provisório vira "Leitor"');

-- =====================================================================================
-- #3 seguidores: só pendente → aceito; notificações repetidas não viram enxurrada
-- =====================================================================================
insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000a', '00000000-0000-7000-8000-00000000000c');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is(pg_temp.linhas($$ update public.follows set status = 'accepted' where followee_id = '00000000-0000-7000-8000-00000000000c' $$), 1,
  'o dono do perfil aceita o pedido');
select is(pg_temp.linhas($$ update public.follows set status = 'pending' where followee_id = '00000000-0000-7000-8000-00000000000c' $$), 0,
  'aceito não volta a pendente (sem laço pendente ↔ aceito)');
reset role;
select is((select followers_count from public.profile_stats where user_id = '00000000-0000-7000-8000-00000000000c'), 1,
  'o contador de seguidores não é forjado');
insert into public.posts (id, author_id, kind, body) values ('01927a00-0000-7000-8000-0000000000c1', '00000000-0000-7000-8000-00000000000c', 'review', 'r');
insert into public.post_likes (post_id, user_id) values ('01927a00-0000-7000-8000-0000000000c1', '00000000-0000-7000-8000-00000000000a');
delete from public.post_likes where user_id = '00000000-0000-7000-8000-00000000000a';
insert into public.post_likes (post_id, user_id) values ('01927a00-0000-7000-8000-0000000000c1', '00000000-0000-7000-8000-00000000000a');
select is((select count(*)::int from public.notifications where user_id = '00000000-0000-7000-8000-00000000000c' and type = 'post_like'), 1,
  'curtir/descurtir em laço: 1 notificação por dia');
insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000b', '00000000-0000-7000-8000-00000000000c');
delete from public.follows where follower_id = '00000000-0000-7000-8000-00000000000b';
insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000b', '00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.notifications where user_id = '00000000-0000-7000-8000-00000000000c' and type = 'follow_request'
                                                    and actor_id = '00000000-0000-7000-8000-00000000000b'), 1,
  'pedir/desfazer em laço: 1 pedido notificado por dia');

-- #14 a lista "seguindo" de alguém não mostra pedidos pendentes a terceiros
insert into public.follows (follower_id, followee_id) values ('00000000-0000-7000-8000-00000000000b', '00000000-0000-7000-8000-00000000000a');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000d');
select is((select array_agg(followee_id) from public.follows where follower_id = '00000000-0000-7000-8000-00000000000b'),
  array['00000000-0000-7000-8000-00000000000a'::uuid], 'terceiro vê só os aceitos (o pedido B → C não aparece)');
select pg_temp.como('00000000-0000-7000-8000-00000000000c');
select is((select count(*)::int from public.follows where follower_id = '00000000-0000-7000-8000-00000000000b'
                                                 and followee_id = '00000000-0000-7000-8000-00000000000c'), 1,
  'quem recebeu o pedido continua vendo o pedido');
reset role;

-- =====================================================================================
-- #2 / #10 RevenueCat: transferência, chave por usuário, estado que sumiu, busca atrasada
-- =====================================================================================
create function pg_temp.sub(p_store text, p_otid text, p_status text default 'active') returns jsonb language sql as $$
  select jsonb_build_array(jsonb_build_object('store', p_store, 'product_id', 'booknest_pro:mensal', 'period_type', 'normal',
    'status', p_status, 'will_renew', true, 'starts_at', now() - interval '1 day', 'ends_at', now() + interval '29 days',
    'grace_ends_at', null, 'original_transaction_id', p_otid, 'environment', 'production'))
$$;
insert into auth.users (id, email) values ('00000000-0000-7000-8000-0000000000a2', 'ana2@exemplo.com'),
                                          ('00000000-0000-7000-8000-0000000000a3', 'ana3@exemplo.com');
select private.rc_apply_subscriber('00000000-0000-7000-8000-0000000000a2', pg_temp.sub('play_store', 'GPA.9'));
select is(private.rc_apply_subscriber('00000000-0000-7000-8000-0000000000a3', pg_temp.sub('play_store', 'GPA.9')) ->> 'pro', 'true',
  'compra restaurada em outra conta: o novo dono vira Pro');
select is(public.entitlement_of('00000000-0000-7000-8000-0000000000a2') ->> 'pro', 'false',
  'e o dono anterior perde o Pro na hora (uma compra = uma conta)');
select private.rc_apply_subscriber('00000000-0000-7000-8000-0000000000a2', pg_temp.sub('app_store', 'booknest_pro:mensal@2026-10-01T00:00:00Z'));
select private.rc_apply_subscriber('00000000-0000-7000-8000-0000000000a3', pg_temp.sub('app_store', 'booknest_pro:mensal@2026-10-01T00:00:00Z'));
select is((select count(distinct user_id)::int from billing.subscriptions where original_transaction_id like 'booknest_pro:mensal@%'), 2,
  'chave sem id da loja (produto@data) é por usuário: compras no mesmo segundo não colidem');
select is(public.entitlement_of('00000000-0000-7000-8000-0000000000a2') ->> 'pro', 'true', 'as duas contas continuam Pro');
select private.rc_apply_subscriber('00000000-0000-7000-8000-0000000000a3', '[]');
select is((select count(*)::int from billing.subscriptions where user_id = '00000000-0000-7000-8000-0000000000a3'), 0,
  'assinatura que sumiu do estado do RevenueCat (transferida) sai do banco');
select is(public.entitlement_of('00000000-0000-7000-8000-0000000000a3') ->> 'pro', 'false', 'e o Pro dela acaba');
select private.rc_apply_subscriber('00000000-0000-7000-8000-0000000000a3', pg_temp.sub('play_store', 'GPA.10'), now(), '2026-10-04T12:00:00Z');
select is(private.rc_apply_subscriber('00000000-0000-7000-8000-0000000000a3', '[]', now(), '2026-10-04T11:59:00Z') ->> 'stale', 'true',
  'estado buscado ANTES do último aplicado é ignorado (webhooks em paralelo)');
select is(public.entitlement_of('00000000-0000-7000-8000-0000000000a3') ->> 'pro', 'true', 'o Pro não é revogado pelo estado velho');
select private.rc_apply_subscriber('00000000-0000-7000-8000-0000000000a3', '[]', now(), '2026-10-04T12:01:00Z');
select is(public.entitlement_of('00000000-0000-7000-8000-0000000000a3') ->> 'pro', 'false', 'estado mais novo vale');

-- #15 o payload do webhook guarda o mínimo e some com a conta
select private.rc_begin_event('{"id":"evt-r1","type":"RENEWAL","app_user_id":"00000000-0000-7000-8000-0000000000a2",
  "subscriber_attributes":{"$email":{"value":"ana2@exemplo.com"}},"aliases":["$RCAnonymousID:x"]}');
select private.rc_begin_event('{"id":"evt-t1","type":"TRANSFER","transferred_from":["00000000-0000-7000-8000-0000000000a2"],
  "transferred_to":["00000000-0000-7000-8000-0000000000a3"]}');
select ok(not (select payload ? 'subscriber_attributes' or payload ? 'aliases' from billing.webhook_events where event_id = 'evt-r1'),
  'atributos do assinante (e-mail etc.) e apelidos não são guardados');
delete from auth.users where id = '00000000-0000-7000-8000-0000000000a2';
select is((select count(*)::int from billing.webhook_events where event_id in ('evt-r1', 'evt-t1')), 0,
  'conta excluída leva os eventos do webhook (inclusive transferências)');

-- =====================================================================================
-- #5 cota de 2 GiB: reservas pendentes contam o tamanho máximo do arquivo
-- =====================================================================================
insert into personal.user_books (id, user_id, title, author_display, format, status, content_sha256, added_at, created_at, updated_at, version_hlc)
select ('01927a00-0000-7000-8000-' || lpad(to_hex(i), 12, '0'))::uuid, '00000000-0000-7000-8000-00000000000a', 'Livro ' || i, 'X', 'epub',
       'reading', lpad(to_hex(i), 64, '0'), now(), now(), now(), '0001790000000000-0000-dev1'
  from generate_series(1, 11) i;
insert into personal.user_books (id, user_id, title, author_display, format, status, content_sha256, added_at, created_at, updated_at, version_hlc)
select ('01927a00-0000-7000-8000-' || lpad(to_hex(256 + i), 12, '0'))::uuid, '00000000-0000-7000-8000-00000000000d', 'Livro ' || i, 'X', 'pdf',
       'reading', lpad(to_hex(256 + i), 64, '0'), now(), now(), now(), '0001790000000000-0000-dev1'
  from generate_series(1, 2) i;
create function pg_temp.reservar(p_user uuid, i int, p_bytes bigint) returns text language sql as $$
  select private.ebook_upload_slot(p_user, ('01927a00-0000-7000-8000-' || lpad(to_hex(i), 12, '0'))::uuid, lpad(to_hex(i), 64, '0'), p_bytes)
$$;
select is((select count(x.r)::int from (select pg_temp.reservar('00000000-0000-7000-8000-00000000000a', i, 1) as r from generate_series(1, 10) i) x), 10,
  '10 uploads pendentes cabem (10 × 200 MiB ≤ 2 GiB)');
select throws_ok($$ select pg_temp.reservar('00000000-0000-7000-8000-00000000000a', 11, 1) $$, 'P0001', 'quota_exceeded',
  'o 11º é recusado: o tamanho informado (1 byte) não vale para a cota');
select lives_ok($$ select pg_temp.reservar('00000000-0000-7000-8000-00000000000a', 1, 1) $$,
  'pedir de novo a URL do mesmo arquivo troca a reserva (não conta duas vezes)');
update private.ebook_upload_reservations set expires_at = now() - interval '1 second'
 where user_id = '00000000-0000-7000-8000-00000000000a';
select lives_ok($$ select pg_temp.reservar('00000000-0000-7000-8000-00000000000a', 11, 1) $$,
  'reserva vencida (URL de 2 h expirou) deixa de contar');
insert into storage.objects (bucket_id, name, metadata)
values ('ebooks', '00000000-0000-7000-8000-00000000000d/antigo/x.pdf', '{"size": 2000000000}');
select lives_ok($$ select pg_temp.reservar('00000000-0000-7000-8000-00000000000d', 257, 100000000) $$,
  'perto do limite: um último upload vale pelo tamanho informado');
select throws_ok($$ select pg_temp.reservar('00000000-0000-7000-8000-00000000000d', 258, 1000) $$, 'P0001', 'quota_exceeded',
  'mas só um "último upload" por vez');

-- =====================================================================================
-- #6 retenção: o purge só conta o aviso ENTREGUE; sem e-mail, o aviso é no app
-- =====================================================================================
insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-000000000071', 'gil@exemplo.com'),
  ('00000000-0000-7000-8000-000000000072', null),
  ('00000000-0000-7000-8000-000000000073', 'ivo@exemplo.com'),
  ('00000000-0000-7000-8000-000000000074', 'jo@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until)
select u, 'pro', now() - interval '13 months' from unnest(array['00000000-0000-7000-8000-000000000071', '00000000-0000-7000-8000-000000000072',
  '00000000-0000-7000-8000-000000000073', '00000000-0000-7000-8000-000000000074']::uuid[]) u;
select private.run_retention();
select is((select count(*)::int from private.email_outbox where template = 'retention_warning' and user_id = '00000000-0000-7000-8000-000000000071'), 1,
  'aviso por e-mail enfileirado');
select is((select warning_sent_at from private.account_lifecycle where user_id = '00000000-0000-7000-8000-000000000071'), null,
  'enfileirar NÃO conta como aviso dado (o relógio dos 30 dias não começa)');
select is((select count(*)::int from public.notifications where type = 'retention_warning' and user_id = '00000000-0000-7000-8000-000000000071'), 1,
  'o aviso também aparece no app (notificação + push)');
select private.finish_email(id) from private.email_outbox where template = 'retention_warning' and user_id = '00000000-0000-7000-8000-000000000071';
select isnt((select warning_sent_at from private.account_lifecycle where user_id = '00000000-0000-7000-8000-000000000071'), null,
  'e-mail entregue → aviso dado');
select ok((select warning_sent_at is not null from private.account_lifecycle where user_id = '00000000-0000-7000-8000-000000000072')
          and not exists (select 1 from private.email_outbox where user_id = '00000000-0000-7000-8000-000000000072'),
  'sem e-mail (Apple/telefone): a notificação no app é o aviso');
update private.email_outbox set attempts = 5 where user_id = '00000000-0000-7000-8000-000000000073';
select private.run_retention();
select isnt((select warning_sent_at from private.account_lifecycle where user_id = '00000000-0000-7000-8000-000000000073'), null,
  'e-mail que falhou 5 vezes: vale a notificação, com 30 dias a partir de agora');
select is((select count(*)::int from private.email_outbox where template = 'retention_warning' and user_id = '00000000-0000-7000-8000-000000000071'), 1,
  'rodar de novo não repete o aviso');
update billing.entitlements set active_until = now() + interval '1 month' where user_id = '00000000-0000-7000-8000-000000000074';
select is((select count(*)::int from private.claim_emails(100) where user_id = '00000000-0000-7000-8000-000000000074'), 0,
  'voltou a ser Pro: o aviso pendente não é enviado');
select private.run_retention();
select is((select count(*)::int from private.email_outbox where user_id = '00000000-0000-7000-8000-000000000074' and sent_at is null), 0,
  'e sai da fila');

-- #8 purge do Storage de quem voltou a ser Pro não apaga os e-books
select private.queue_storage_purge('00000000-0000-7000-8000-000000000074', 'retention');
select private.queue_storage_purge('00000000-0000-7000-8000-000000000073', 'retention');
select is((select array_agg(user_id) from private.claim_storage_purges(10)
             where user_id in ('00000000-0000-7000-8000-000000000073', '00000000-0000-7000-8000-000000000074')),
  array['00000000-0000-7000-8000-000000000073'::uuid], 'a fila do Storage pula a limpeza de quem voltou a ser Pro');
select is((select count(*)::int from private.storage_purge_queue where user_id = '00000000-0000-7000-8000-000000000074'), 0,
  'e a descarta (os e-books reenviados ficam)');

-- =====================================================================================
-- #9 partições das sessões: RLS ligada e privilégios explícitos também nas novas
-- =====================================================================================
drop table if exists personal.reading_sessions_2026_02;
select private.ensure_session_partition_for('2026-02-15T12:00:00Z');
select ok((select relrowsecurity from pg_class where oid = 'personal.reading_sessions_2026_02'::regclass), 'partição nova nasce com RLS');
select ok(not has_table_privilege('authenticated', 'personal.reading_sessions_2026_02', 'select')
          and not has_table_privilege('anon', 'personal.reading_sessions_2026_02', 'select'),
  'partição nova: nada para anon/authenticated (a leitura é pela tabela particionada)');
select ok(has_table_privilege('service_role', 'personal.reading_sessions_2026_02', 'select')
          and has_table_privilege('service_role', 'personal.reading_sessions_2026_02', 'insert')
          and has_table_privilege('service_role', 'personal.reading_sessions_2026_02', 'delete'),
  'partição nova: service_role lê e escreve');
select is_empty($$ select c.relname from pg_inherits i join pg_class c on c.oid = i.inhrelid
                    where i.inhparent = 'personal.reading_sessions'::regclass and not c.relrowsecurity $$,
  'todas as partições existentes ficaram com RLS');

-- =====================================================================================
-- #11 agrupamento de push: só respostas do clube se agrupam
-- =====================================================================================
update public.notifications set push_sent_at = now();
insert into public.notifications (user_id, type, club_id, push_sent_at) values
  ('00000000-0000-7000-8000-00000000000a', 'club_reply', '01927a00-0000-7000-8000-0000000000f1', now() - interval '5 minutes');
insert into public.notifications (user_id, type, club_id) values
  ('00000000-0000-7000-8000-00000000000a', 'club_meeting', '01927a00-0000-7000-8000-0000000000f1');
select is((select array_agg(type) from private.claim_pushes(100)), array['club_meeting'],
  'lembrete de encontro sai mesmo com resposta do clube nos últimos 10 min');

-- =====================================================================================
-- #12 aparelho trocado de conta: o token passa para quem entrou
-- =====================================================================================
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select lives_ok($$ select public.register_device_token('tok-compartilhado', 'android', '1.0.0') $$, 'registra o aparelho');
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select lives_ok($$ select public.register_device_token('tok-compartilhado', 'android', '1.0.0') $$, 'outra conta entra no mesmo aparelho');
select throws_ok($$ select public.register_device_token('tok', 'windows') $$, '22023', 'invalid_device', 'plataforma inválida recusada');
select throws_ok($$ insert into public.device_tokens (token, user_id, platform) values ('t', '00000000-0000-7000-8000-00000000000b', 'ios') $$,
  '42501', null, 'registro direto na tabela fechado (só pela RPC)');
reset role;
select is((select user_id from public.device_tokens where token = 'tok-compartilhado'), '00000000-0000-7000-8000-00000000000b'::uuid,
  'o token é de quem entrou por último (pushes da conta anterior param)');

-- =====================================================================================
-- #13 convites: código gerado pelo servidor; bloqueado não entra
-- =====================================================================================
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select lives_ok($$ insert into public.club_invites (club_id, created_by, expires_at)
  values ('01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000b', now() + interval '1 day') $$,
  'o dono cria o convite sem escolher o código');
select matches((select code from public.club_invites limit 1), '^[A-Za-z0-9]{12}$', 'código aleatório de 12 caracteres');
select throws_ok($$ insert into public.club_invites (code, club_id, created_by, expires_at)
  values ('CAPITU2026', '01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000b', now() + interval '1 day') $$,
  '42501', null, 'o cliente não escolhe o código (adivinhável)');
reset role;
insert into public.user_blocks (blocker_id, blocked_id) values ('00000000-0000-7000-8000-00000000000b', '00000000-0000-7000-8000-00000000000e');
insert into public.clubs (id, owner_id, name, privacy) values ('01927a00-0000-7000-8000-0000000000f2', '00000000-0000-7000-8000-00000000000d', 'Público', 'public');
insert into public.user_blocks (blocker_id, blocked_id) values ('00000000-0000-7000-8000-00000000000d', '00000000-0000-7000-8000-00000000000e');
create temp table codigo as select code from public.club_invites limit 1;
grant select on codigo to authenticated;
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000e');
select throws_ok($$ select public.join_club((select code from codigo)) $$, 'P0001', 'blocked', 'bloqueado pelo dono não entra por convite');
select throws_ok($$ select public.join_public_club('01927a00-0000-7000-8000-0000000000f2') $$, 'P0001', 'blocked',
  'nem em clube público');
reset role;

-- =====================================================================================
-- Lote do sync: mesmo id e mesmo HLC duas vezes → fica a PRIMEIRA (igual ao caminho de uma em uma)
-- =====================================================================================
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
select is(public.sync_apply_changes($j$[
  {"table":"bookmarks","op":"PUT","id":"01927a00-0000-7000-8000-000000000b01","hlc":"0001790000004001-0000-dev1",
   "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","locator":{"v":1},"ref_page":1,"chapter_index":0,"excerpt":"primeira","created_at":"2026-10-01T00:00:00Z","updated_at":"2026-10-01T00:00:00Z"}},
  {"table":"bookmarks","op":"PUT","id":"01927a00-0000-7000-8000-000000000b01","hlc":"0001790000004001-0000-dev1",
   "data":{"user_book_id":"01927a00-0000-7000-8000-000000000001","locator":{"v":1},"ref_page":2,"chapter_index":0,"excerpt":"segunda","created_at":"2026-10-01T00:00:00Z","updated_at":"2026-10-01T00:00:00Z"}}
]$j$::jsonb) - 'rejected', '{"applied": 1, "skipped": 1}'::jsonb, 'mesmo id e mesmo HLC: 1 gravado, 1 ignorado');
select is((select excerpt from personal.bookmarks where id = '01927a00-0000-7000-8000-000000000b01'), 'primeira',
  'empate de HLC: vence a primeira da lista (determinístico)');
reset role;

select * from finish();
rollback;

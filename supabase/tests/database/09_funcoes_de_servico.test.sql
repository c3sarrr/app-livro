-- Funções de banco das Edge Functions (migration funcoes_de_servico).
begin;
create extension if not exists pgtap with schema extensions;
select plan(32);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000000a', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com');
create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;

-- ---------------------------------------------------------------- RevenueCat
select is(private.rc_begin_event('{"id":"evt-1","type":"INITIAL_PURCHASE","app_user_id":"00000000-0000-7000-8000-00000000000a"}'), 'new', 'evento novo: processar');
select is(private.rc_begin_event('{"id":"evt-1","type":"INITIAL_PURCHASE"}'), 'retry', 'evento repetido que falhou antes: processar de novo');
select private.rc_finish_event('evt-1');
select is(private.rc_begin_event('{"id":"evt-1","type":"INITIAL_PURCHASE"}'), 'done', 'evento já processado: responder 200 sem refazer');
select throws_ok($$ select private.rc_begin_event('{"type":"TEST"}') $$, '22023', 'event_without_id', 'evento sem id recusado');
select private.rc_finish_event('evt-2-inexistente', 'erro qualquer');
select private.rc_begin_event('{"id":"evt-3","type":"RENEWAL"}');
select private.rc_finish_event('evt-3', 'falhou');
select is((select error from billing.webhook_events where event_id = 'evt-3'), 'falhou', 'erro registrado (o RevenueCat reenvia)');

select is(private.rc_apply_subscriber('00000000-0000-7000-8000-00000000000a', jsonb_build_array(jsonb_build_object(
    'store', 'play_store', 'product_id', 'booknest_pro:mensal', 'period_type', 'normal', 'status', 'active',
    'will_renew', true, 'starts_at', now() - interval '1 day', 'ends_at', now() + interval '29 days', 'grace_ends_at', null,
    'original_transaction_id', 'GPA.1', 'environment', 'production'))) ->> 'pro', 'true', 'assinatura ativa → Pro');
select ok((select granted from billing.sync_access where user_id = '00000000-0000-7000-8000-00000000000a'), 'Pro ganha o acesso ao sync na hora');
select private.rc_apply_subscriber('00000000-0000-7000-8000-00000000000a', jsonb_build_array(jsonb_build_object(
    'store', 'play_store', 'product_id', 'booknest_pro:mensal', 'period_type', 'normal', 'status', 'in_grace_period',
    'will_renew', true, 'starts_at', now() - interval '31 days', 'ends_at', now() - interval '1 day', 'grace_ends_at', now() + interval '15 days',
    'original_transaction_id', 'GPA.1', 'environment', 'production')));
select ok((select active_until > now() + interval '14 days' from billing.entitlements where user_id = '00000000-0000-7000-8000-00000000000a'),
  'carência da loja mantém o Pro até o fim da carência');
select is((select count(*)::int from billing.subscriptions), 1, 'a mesma assinatura é atualizada (loja + transação original)');
select is(private.rc_apply_subscriber('00000000-0000-7000-8000-00000000000a', jsonb_build_array(jsonb_build_object(
    'store', 'play_store', 'product_id', 'booknest_pro:mensal', 'period_type', 'normal', 'status', 'refunded',
    'will_renew', false, 'starts_at', now() - interval '31 days', 'ends_at', now() + interval '1 day', 'grace_ends_at', null,
    'original_transaction_id', 'GPA.1', 'environment', 'production'))) ->> 'pro', 'false', 'reembolso → o Pro termina agora');
select is(private.rc_apply_subscriber('00000000-0000-7000-8000-00000000000a', jsonb_build_array(jsonb_build_object(
    'store', 'app_store', 'product_id', 'booknest_pro_anual', 'period_type', 'trial', 'status', 'active',
    'will_renew', true, 'starts_at', now(), 'ends_at', now() + interval '7 days', 'grace_ends_at', null,
    'original_transaction_id', '2000000001', 'environment', 'sandbox'))) ->> 'pro', 'true', 'assinou de novo (teste grátis, sandbox) → Pro');
select is((select environment from billing.entitlements where user_id = '00000000-0000-7000-8000-00000000000a'), 'sandbox',
  'sandbox libera o Pro mas fica marcado (D-48)');
select throws_ok($$ select private.rc_apply_subscriber('00000000-0000-7000-8000-0000000000ff', '[]') $$, 'P0001', 'unknown_user',
  'assinante que não é usuário do app é recusado');

-- ---------------------------------------------------------------- e-books na nuvem
insert into personal.user_books (id, user_id, title, author_display, format, status, content_sha256, added_at, created_at, updated_at, version_hlc) values
  ('01927a00-0000-7000-8000-000000000a01', '00000000-0000-7000-8000-00000000000a', 'Livro', 'X', 'epub', 'reading', repeat('a', 64), now(), now(), now(), 'v'),
  ('01927a00-0000-7000-8000-000000000a02', '00000000-0000-7000-8000-00000000000a', 'Físico', 'X', 'physical', 'reading', null, now(), now(), now(), 'v');
select is(private.ebook_upload_slot('00000000-0000-7000-8000-00000000000a', '01927a00-0000-7000-8000-000000000a01', repeat('a', 64), 1000),
  '00000000-0000-7000-8000-00000000000a/01927a00-0000-7000-8000-000000000a01/' || repeat('a', 64) || '.epub', 'caminho do upload: <usuário>/<livro>/<sha256>.<ext>');
select throws_ok($$ select private.ebook_upload_slot('00000000-0000-7000-8000-00000000000b', '01927a00-0000-7000-8000-000000000a01', repeat('a', 64), 1000) $$,
  'P0001', 'pro_required', 'Grátis não guarda e-book na nuvem');
select throws_ok($$ select private.ebook_upload_slot('00000000-0000-7000-8000-00000000000a', '01927a00-0000-7000-8000-000000000a02', repeat('a', 64), 1000) $$,
  'P0001', 'book_not_found', 'livro físico não tem arquivo');
select throws_ok($$ select private.ebook_upload_slot('00000000-0000-7000-8000-00000000000a', '01927a00-0000-7000-8000-000000000a01', repeat('b', 64), 1000) $$,
  'P0001', 'sha_mismatch', 'o arquivo tem de ser o do livro (sha256)');
insert into storage.objects (bucket_id, name, metadata) values
  ('ebooks', '00000000-0000-7000-8000-00000000000a/outro/x.pdf', '{"size": 2147000000}');
select throws_ok($$ select private.ebook_upload_slot('00000000-0000-7000-8000-00000000000a', '01927a00-0000-7000-8000-000000000a01', repeat('a', 64), 1000000) $$,
  'P0001', 'quota_exceeded', 'cota de 2 GiB medida no próprio Storage');

-- ---------------------------------------------------------------- e-mails
insert into private.email_outbox (user_id, template) values
  ('00000000-0000-7000-8000-00000000000a', 'retention_warning'), ('00000000-0000-7000-8000-00000000000b', 'welcome');
select is((select array_agg(email order by email) from private.claim_emails(10)), array['ana@exemplo.com', 'bia@exemplo.com'], 'e-mails pendentes com o endereço do Auth');
select private.finish_email(id) from private.email_outbox where template = 'welcome';
update private.email_outbox set attempts = 5 where template = 'retention_warning';
select is((select count(*)::int from private.claim_emails(10)), 0, 'enviado sai da fila; 5 tentativas = desiste');

-- ---------------------------------------------------------------- limpeza do Storage
select private.queue_storage_purge('00000000-0000-7000-8000-0000000000dd', 'account_deleted');
select is((select reason from private.claim_storage_purges(5)), 'account_deleted', 'fila de limpeza entregue à Edge Function');
select private.finish_storage_purge('00000000-0000-7000-8000-0000000000dd');
select is((select count(*)::int from private.claim_storage_purges(5)), 0, 'feito sai da fila');

-- ---------------------------------------------------------------- push (agrupamento por clube)
insert into public.device_tokens (token, user_id, platform) values ('tok-ana', '00000000-0000-7000-8000-00000000000a', 'android');
insert into public.clubs (id, owner_id, name) values ('01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000b', 'Clube X');
delete from public.notifications;
insert into public.notifications (user_id, type, club_id, actor_id) values
  ('00000000-0000-7000-8000-00000000000a', 'club_reply', '01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000b'),
  ('00000000-0000-7000-8000-00000000000a', 'club_reply', '01927a00-0000-7000-8000-0000000000f1', '00000000-0000-7000-8000-00000000000b'),
  ('00000000-0000-7000-8000-00000000000a', 'follow', null, '00000000-0000-7000-8000-00000000000b');
create temp table envio as select * from private.claim_pushes(100);
select is((select count(*)::int from envio), 2, '2 respostas no mesmo clube viram 1 push; o "follow" sai à parte');
select is((select tokens from envio limit 1), array['tok-ana'], 'o push leva os aparelhos da pessoa');
select is((select club_name from envio where type = 'club_reply'), 'Clube X', 'com o nome do clube');
select is((select count(*)::int from public.notifications where push_sent_at is null), 0, 'todas marcadas (a agrupada como "grouped")');
insert into public.notifications (user_id, type, club_id) values ('00000000-0000-7000-8000-00000000000a', 'club_reply', '01927a00-0000-7000-8000-0000000000f1');
select is((select count(*)::int from private.claim_pushes(100)), 0, 'nova resposta no clube dentro de 10 min: sem push');
select private.drop_device_token('tok-ana');
select is((select count(*)::int from public.device_tokens), 0, 'aparelho inválido removido');

-- ---------------------------------------------------------------- exportação (LGPD)
insert into public.posts (author_id, kind, body) values ('00000000-0000-7000-8000-00000000000a', 'review', 'minha resenha'),
                                                      ('00000000-0000-7000-8000-00000000000b', 'review', 'da bia');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000a');
create temp table exportado as select public.export_my_data() as j;
select is((select j -> 'account' ->> 'email' from exportado), 'ana@exemplo.com', 'exporta a conta de quem pede');
select is((select jsonb_array_length(j -> 'posts') from exportado), 1, 'só os próprios posts');
select is((select jsonb_array_length(j -> 'personal' -> 'user_books') from exportado), 2, 'inclui os dados pessoais guardados no servidor');
select public.export_my_data(); select public.export_my_data();
select throws_ok($$ select public.export_my_data() $$, 'P0001', 'quota_exceeded', 'no máximo 3 exportações por dia');
reset role;

select * from finish();
rollback;

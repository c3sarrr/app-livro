-- G06 — achados da revisão independente: linha de outra conta é recusada pela RPC (não vai para a
-- conta da sessão); a sincronização não rebaixa o caminho do e-book na nuvem; arquivo sem livro ativo
-- vai para a fila de exclusão.
begin;
create extension if not exists pgtap with schema extensions;
select plan(12);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000003a', 'a@exemplo.com'),
  ('00000000-0000-7000-8000-00000000003b', 'b@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until) values
  ('00000000-0000-7000-8000-00000000003a', 'pro', now() + interval '30 days'),
  ('00000000-0000-7000-8000-00000000003b', 'pro', now() + interval '30 days');
create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
create function pg_temp.livro(p_id text, p_dono text, p_hlc text, p_titulo text, p_caminho text default null) returns jsonb
language sql as $$
  select jsonb_build_object('table', 'user_books', 'op', 'PUT', 'id', p_id, 'hlc', p_hlc, 'data',
    -- a linha INTEIRA, como o aparelho manda (caminho nulo explícito)
    jsonb_build_object('user_id', p_dono, 'title', p_titulo, 'author_display', 'A', 'format', 'epub',
      'status', 'reading', 'content_sha256', repeat('a', 64), 'storage_object_path', p_caminho,
      'added_at', '2026-10-01T12:00:00Z', 'created_at', '2026-10-01T12:00:00Z', 'updated_at', '2026-10-01T12:00:00Z'))
$$;

-- ---------------------------------------------------------------- dono da linha ≠ dono da sessão
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000003b');
select is(
  public.sync_apply_changes(jsonb_build_array(
    pg_temp.livro('01927a00-0000-7000-8000-00000000a301', '00000000-0000-7000-8000-00000000003a', '0001790000000000-0000-x', 'De A'),
    pg_temp.livro('01927a00-0000-7000-8000-00000000b301', '00000000-0000-7000-8000-00000000003b', '0001790000000000-0000-x', 'De B'))) -> 'rejected',
  '[{"id": "01927a00-0000-7000-8000-00000000a301", "code": "22023", "error": "owner_mismatch", "table": "user_books", "retryable": false}]'::jsonb,
  'linha com o user_id de outra conta: recusada (owner_mismatch)');
reset role;
select is((select count(*)::int from personal.user_books where user_id = '00000000-0000-7000-8000-00000000003b'), 1,
  'só a linha da própria conta foi gravada');
select is((select count(*)::int from personal.user_books where id = '01927a00-0000-7000-8000-00000000a301'), 0,
  'a da outra conta não entrou em lugar nenhum');
select ok(not has_function_privilege('authenticated', 'private.sync_apply_changes_core(jsonb)', 'execute'),
  'o núcleo da RPC não é chamado direto pelo cliente');

-- ---------------------------------------------------------------- caminho do e-book não é rebaixado
-- A tem o livro com o arquivo na nuvem (versão v1)
insert into personal.user_books (id, user_id, title, author_display, format, status, content_sha256, storage_object_path,
                                 added_at, created_at, updated_at, version_hlc) values
  ('01927a00-0000-7000-8000-00000000a302', '00000000-0000-7000-8000-00000000003a', 'L', 'A', 'epub', 'reading', repeat('a', 64),
   '00000000-0000-7000-8000-00000000003a/01927a00-0000-7000-8000-00000000a302/' || repeat('a', 64) || '.epub',
   now(), now(), now(), '0001790000000001-0000-dev1');
insert into storage.objects (bucket_id, name) values
  ('ebooks', '00000000-0000-7000-8000-00000000003a/01927a00-0000-7000-8000-00000000a302/' || repeat('a', 64) || '.epub');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000003a');
-- o aparelho 2 (que não sabia do arquivo) manda uma versão MAIS NOVA sem o caminho
select is((public.sync_apply_changes(jsonb_build_array(
  pg_temp.livro('01927a00-0000-7000-8000-00000000a302', '00000000-0000-7000-8000-00000000003a', '0001790000000009-0000-dev2', 'Aberto no 2'))) ->> 'applied')::int,
  1, 'a versão mais nova do aparelho 2 é aplicada');
reset role;
select is((select title from personal.user_books where id = '01927a00-0000-7000-8000-00000000a302'), 'Aberto no 2', 'os dados novos ficam');
select is((select storage_object_path from personal.user_books where id = '01927a00-0000-7000-8000-00000000a302'),
  '00000000-0000-7000-8000-00000000003a/01927a00-0000-7000-8000-00000000a302/' || repeat('a', 64) || '.epub',
  'o caminho do arquivo na nuvem NÃO vira NULL');
select is((select count(*)::int from private.ebook_object_deletions), 0, 'e o arquivo não vai para a fila de exclusão');
-- caminho para um arquivo que não existe (ou de outro livro): também não muda
update personal.user_books set storage_object_path = '00000000-0000-7000-8000-00000000003a/01927a00-0000-7000-8000-00000000a302/' || repeat('9', 64) || '.epub'
 where id = '01927a00-0000-7000-8000-00000000a302';
select is((select count(*)::int from private.ebook_object_deletions), 0, 'caminho para arquivo inexistente: ignorado, nada na fila');

-- ---------------------------------------------------------------- arquivos sem livro ativo
-- envio que terminou com o livro já apagado: o arquivo novo vai para a fila
insert into storage.objects (bucket_id, name) values
  ('ebooks', '00000000-0000-7000-8000-00000000003a/01927a00-0000-7000-8000-00000000a303/' || repeat('b', 64) || '.epub');
insert into personal.user_books (id, user_id, title, author_display, format, status, content_sha256, deleted_at,
                                 added_at, created_at, updated_at, version_hlc) values
  ('01927a00-0000-7000-8000-00000000a303', '00000000-0000-7000-8000-00000000003a', 'L3', 'A', 'epub', 'reading', repeat('b', 64), now(),
   now(), now(), now(), '0001790000000001-0000-dev1');
update personal.user_books set storage_object_path = '00000000-0000-7000-8000-00000000003a/01927a00-0000-7000-8000-00000000a303/' || repeat('b', 64) || '.epub'
 where id = '01927a00-0000-7000-8000-00000000a303';
select is((select count(*)::int from private.ebook_object_deletions where path like '%a303%'), 1,
  'arquivo de livro já apagado: vai para a fila');
-- objeto esquecido há mais de 7 dias, sem livro e sem envio em andamento: a reconciliação o pega
insert into storage.objects (bucket_id, name, created_at) values
  ('ebooks', '00000000-0000-7000-8000-00000000003a/esquecido/x.epub', now() - interval '8 days'),
  ('ebooks', '00000000-0000-7000-8000-00000000003a/recente/x.epub', now() - interval '1 day');
select is((select count(*)::int from private.claim_ebook_deletions(50) c where c.path like '%esquecido%'), 1,
  'objeto sem livro há 7 dias: entra na fila e é entregue');
select is((select count(*)::int from private.ebook_object_deletions where path like '%recente%' or path like '%a302%'), 0,
  'o recente (envio pode estar terminando) e o do livro ativo ficam');

select * from finish();
rollback;

-- G06 — e-books na nuvem: o caminho para baixar só sai para o Pro dono do livro ativo (nunca o arquivo
-- de outra pessoa, mesmo com storage_object_path forjado pela sincronização); livro apagado ou arquivo
-- trocado entra na fila de exclusão do servidor; exclusão desfeita não apaga.
begin;
create extension if not exists pgtap with schema extensions;
select plan(16);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-00000000002a', 'pro@exemplo.com'),
  ('00000000-0000-7000-8000-00000000002b', 'outra@exemplo.com'),
  ('00000000-0000-7000-8000-00000000002c', 'gratis@exemplo.com');
insert into billing.entitlements (user_id, entitlement, active_until) values
  ('00000000-0000-7000-8000-00000000002a', 'pro', now() + interval '30 days'),
  ('00000000-0000-7000-8000-00000000002b', 'pro', now() + interval '30 days');

-- livro 1: com arquivo na nuvem · livro 2: caminho forjado apontando para o arquivo da OUTRA pessoa
-- livro 3: caminho certo, arquivo que não existe · livro 4: do Grátis
insert into personal.user_books (id, user_id, title, author_display, format, status, content_sha256, storage_object_path,
                                 added_at, created_at, updated_at, version_hlc) values
  ('01927a00-0000-7000-8000-00000000a001', '00000000-0000-7000-8000-00000000002a', 'L1', 'A', 'epub', 'reading', repeat('a', 64),
   '00000000-0000-7000-8000-00000000002a/01927a00-0000-7000-8000-00000000a001/' || repeat('a', 64) || '.epub',
   now(), now(), now(), '0001790000000000-0000-t'),
  ('01927a00-0000-7000-8000-00000000a002', '00000000-0000-7000-8000-00000000002a', 'L2', 'A', 'epub', 'reading', repeat('b', 64),
   '00000000-0000-7000-8000-00000000002b/01927a00-0000-7000-8000-00000000b001/' || repeat('c', 64) || '.epub',
   now(), now(), now(), '0001790000000000-0000-t'),
  ('01927a00-0000-7000-8000-00000000a003', '00000000-0000-7000-8000-00000000002a', 'L3', 'A', 'pdf', 'reading', repeat('d', 64),
   '00000000-0000-7000-8000-00000000002a/01927a00-0000-7000-8000-00000000a003/' || repeat('d', 64) || '.pdf',
   now(), now(), now(), '0001790000000000-0000-t'),
  ('01927a00-0000-7000-8000-00000000c001', '00000000-0000-7000-8000-00000000002c', 'L4', 'A', 'epub', 'reading', repeat('e', 64),
   '00000000-0000-7000-8000-00000000002c/01927a00-0000-7000-8000-00000000c001/' || repeat('e', 64) || '.epub',
   now(), now(), now(), '0001790000000000-0000-t');
insert into storage.objects (bucket_id, name) values
  ('ebooks', '00000000-0000-7000-8000-00000000002a/01927a00-0000-7000-8000-00000000a001/' || repeat('a', 64) || '.epub'),
  ('ebooks', '00000000-0000-7000-8000-00000000002b/01927a00-0000-7000-8000-00000000b001/' || repeat('c', 64) || '.epub'),
  ('ebooks', '00000000-0000-7000-8000-00000000002c/01927a00-0000-7000-8000-00000000c001/' || repeat('e', 64) || '.epub');

-- ---------------------------------------------------------------- download
select is(private.ebook_download_path('00000000-0000-7000-8000-00000000002a', '01927a00-0000-7000-8000-00000000a001'),
  '00000000-0000-7000-8000-00000000002a/01927a00-0000-7000-8000-00000000a001/' || repeat('a', 64) || '.epub',
  'Pro, dono, livro ativo: o caminho do arquivo');
select throws_ok($$ select private.ebook_download_path('00000000-0000-7000-8000-00000000002a', '01927a00-0000-7000-8000-00000000a002') $$,
  'P0001', 'book_not_found', 'caminho forjado para o arquivo de outra pessoa: recusado');
select throws_ok($$ select private.ebook_download_path('00000000-0000-7000-8000-00000000002b', '01927a00-0000-7000-8000-00000000a001') $$,
  'P0001', 'book_not_found', 'o livro de outra pessoa: recusado');
select throws_ok($$ select private.ebook_download_path('00000000-0000-7000-8000-00000000002a', '01927a00-0000-7000-8000-00000000a003') $$,
  'P0001', 'file_not_found', 'arquivo que não está na nuvem');
select throws_ok($$ select private.ebook_download_path('00000000-0000-7000-8000-00000000002c', '01927a00-0000-7000-8000-00000000c001') $$,
  'P0001', 'pro_required', 'Grátis não baixa da nuvem');

-- ---------------------------------------------------------------- exclusão pelo servidor
update personal.user_books set deleted_at = now(), version_hlc = '0001790000000001-0000-t'
 where id = '01927a00-0000-7000-8000-00000000a001';
select is((select count(*)::int from private.ebook_object_deletions
            where path like '00000000-0000-7000-8000-00000000002a/01927a00-0000-7000-8000-00000000a001/%'), 1,
  'livro apagado (pela sincronização): o arquivo entra na fila');
select throws_ok($$ select private.ebook_download_path('00000000-0000-7000-8000-00000000002a', '01927a00-0000-7000-8000-00000000a001') $$,
  'P0001', 'book_not_found', 'livro apagado não baixa');
-- o arquivo novo já subiu (o caminho só muda para um arquivo que existe — revisão da G06)
insert into storage.objects (bucket_id, name) values
  ('ebooks', '00000000-0000-7000-8000-00000000002a/01927a00-0000-7000-8000-00000000a003/' || repeat('f', 64) || '.pdf');
update personal.user_books set storage_object_path = '00000000-0000-7000-8000-00000000002a/01927a00-0000-7000-8000-00000000a003/' || repeat('f', 64) || '.pdf'
 where id = '01927a00-0000-7000-8000-00000000a003';
select is((select count(*)::int from private.ebook_object_deletions
            where path = '00000000-0000-7000-8000-00000000002a/01927a00-0000-7000-8000-00000000a003/' || repeat('d', 64) || '.pdf'), 1,
  'arquivo trocado: o antigo entra na fila');
update personal.user_books set deleted_at = now() where id = '01927a00-0000-7000-8000-00000000a002';
select is((select count(*)::int from private.ebook_object_deletions where user_id = '00000000-0000-7000-8000-00000000002a'
            and path like '00000000-0000-7000-8000-00000000002b/%'), 0,
  'caminho de outra pessoa nunca entra na fila (nem com a linha forjada)');

select is((select count(*)::int from private.claim_ebook_deletions(10)), 2, 'a função recebe o lote');
select is((select count(*)::int from private.claim_ebook_deletions(10)), 2, 'sem resposta, volta no próximo (tentativas contadas)');
select private.finish_ebook_deletion('00000000-0000-7000-8000-00000000002a/01927a00-0000-7000-8000-00000000a003/' || repeat('d', 64) || '.pdf');
select private.finish_ebook_deletion('00000000-0000-7000-8000-00000000002a/01927a00-0000-7000-8000-00000000a001/' || repeat('a', 64) || '.epub', 'storage 500');
select is((select last_error from private.ebook_object_deletions), 'storage 500', 'falha fica registrada; feito sai da fila');
-- exclusão desfeita (versão mais nova restaurou o livro): o arquivo volta a ser usado e não é apagado
update personal.user_books set deleted_at = null, version_hlc = '0001790000000002-0000-t'
 where id = '01927a00-0000-7000-8000-00000000a001';
select is((select count(*)::int from private.claim_ebook_deletions(10)), 0, 'exclusão desfeita: o arquivo não é apagado');

-- ---------------------------------------------------------------- privilégios
select ok(not has_function_privilege('authenticated', 'private.ebook_download_path(uuid, uuid)', 'execute'),
  'o cliente não chama o caminho direto (só a Edge Function)');
select ok(not has_function_privilege('authenticated', 'private.claim_ebook_deletions(integer)', 'execute'),
  'o cliente não mexe na fila');
select ok(not has_table_privilege('authenticated', 'private.ebook_object_deletions', 'select'), 'nem lê a fila');

select * from finish();
rollback;

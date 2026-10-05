-- G07 — camada da comunidade ("adicionar este livro", D-74) e o ISBN-13 na estante (D-77).
-- Envio e confirmação só pelas RPCs; quem enviou fica oculto; 2 confirmações de OUTRAS contas →
-- aprovado → edição `community` no catálogo; conta excluída leva os envios e as confirmações dela.
begin;
create extension if not exists pgtap with schema extensions;
select plan(49);

insert into auth.users (id, email) values
  ('00000000-0000-7000-8000-0000000007a1', 'ana@exemplo.com'),
  ('00000000-0000-7000-8000-0000000007b1', 'bia@exemplo.com'),
  ('00000000-0000-7000-8000-0000000007c1', 'caio@exemplo.com'),
  ('00000000-0000-7000-8000-0000000007d1', 'duda@exemplo.com'),
  ('00000000-0000-7000-8000-0000000007e1', 'sem.idade@exemplo.com');
insert into private.account_age (user_id, band, source) values
  ('00000000-0000-7000-8000-0000000007a1', '18_plus', 'birthdate'),
  ('00000000-0000-7000-8000-0000000007b1', '18_plus', 'birthdate'),
  ('00000000-0000-7000-8000-0000000007c1', '13_15', 'birthdate'),
  ('00000000-0000-7000-8000-0000000007d1', '18_plus', 'birthdate');
create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;
create temp table ids (nome text primary key, id uuid);
grant all on ids to authenticated;

-- ---------------------------------------------------------------- ISBN
select ok(private.isbn13_valid('9786530000017') and private.isbn13_valid('9791000000015'), 'ISBN-13 com dígito certo (978 e 979)');
select ok(not private.isbn13_valid('9786530000018') and not private.isbn13_valid('abc') and not private.isbn13_valid(null)
          and not private.isbn13_valid('9776530000017'), 'dígito errado, texto, nulo e prefixo fora de 978/979: inválidos (sem erro)');
select is(private.isbn10_of('9786530000024'), '653000002X', 'ISBN-10 equivalente (com X)');
select is(private.isbn10_of('9791000000015'), null, '979 não tem ISBN-10');
select is(private.catalog_clean(E'  Dom\t Casmurro  '), 'Dom Casmurro', 'texto do envio: espaços colapsados e sem pontas');

-- ---------------------------------------------------------------- envio
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000007e1');
select throws_ok($$ select public.catalog_submit('9786530000017', 'Livro', 'Autora') $$, 'P0001', 'age_required',
  'conta sem faixa etária não contribui (D-72)');
select throws_ok($$ select public.catalog_confirm('01927a00-0000-7000-8000-000000000001') $$, 'P0001', 'age_required',
  'nem confirma');
select set_config('request.jwt.claims', '{"role":"authenticated"}', true);
select throws_ok($$ select public.catalog_by_isbn('9786530000017') $$, '28000', 'unauthenticated', 'consulta exige sessão');

select pg_temp.como('00000000-0000-7000-8000-0000000007a1');
select throws_ok($$ select public.catalog_submit('9786530000018', 'Livro', 'Autora') $$, '22023', 'invalid_isbn', 'ISBN com dígito errado recusado');
select throws_ok($$ select public.catalog_submit('9786530000017', '   ', 'Autora') $$, '22023', 'invalid_fields', 'título vazio recusado');
select throws_ok($$ select public.catalog_by_isbn('123') $$, '22023', 'invalid_isbn', 'consulta com ISBN inválido recusada');

insert into ids select 'envio_ana', (public.catalog_submit('9786530000017', ' Memórias  do Livro ', 'Ana Autora; Bia Coautora', 'Editora X') ->> 'submission_id')::uuid;
select is((select status from catalog.community_submissions where id = (select id from ids where nome = 'envio_ana')), 'pending',
  'Ana envia: fica pendente');
select is(public.catalog_submit('9786530000017', 'Outro título', 'Outra') ->> 'submission_id',
  (select id::text from ids where nome = 'envio_ana'), 'reenvio da mesma pessoa devolve o envio que já existe');
reset role;
select is((select used from private.quota_usage where user_id = '00000000-0000-7000-8000-0000000007a1' and quota_key = 'catalog_contribution'), 1,
  'o reenvio não gasta a cota');
select is((select title from catalog.community_submissions where id = (select id from ids where nome = 'envio_ana')), 'Memórias do Livro',
  'o título é guardado limpo e o reenvio não troca os dados');
set local role authenticated;

-- Duda envia o mesmo ISBN com OUTRO título: um pendente concorrente
select pg_temp.como('00000000-0000-7000-8000-0000000007d1');
insert into ids select 'envio_duda', (public.catalog_submit('9786530000017', 'Título Errado', 'Alguém') ->> 'submission_id')::uuid;
select isnt((select id from ids where nome = 'envio_duda'), (select id from ids where nome = 'envio_ana'), 'título diferente: outro envio pendente');

-- ---------------------------------------------------------------- consulta (quem enviou fica oculto)
select pg_temp.como('00000000-0000-7000-8000-0000000007b1');
select is(jsonb_array_length(public.catalog_by_isbn('9786530000017') -> 'pending'), 2, 'Bia vê as 2 sugestões pendentes');
select is(public.catalog_by_isbn('9786530000017') -> 'edition', 'null'::jsonb, 'ainda não há edição no catálogo');
select ok(not exists (select 1 from jsonb_array_elements(public.catalog_by_isbn('9786530000017') -> 'pending') p
                       where p ? 'submitted_by' or (p ->> 'mine')::boolean),
  'a consulta não diz quem enviou (e nenhuma é da Bia)');
select pg_temp.como('00000000-0000-7000-8000-0000000007a1');
select is((select count(*)::int from jsonb_array_elements(public.catalog_by_isbn('9786530000017') -> 'pending') p
            where (p ->> 'mine')::boolean), 1, 'a Ana reconhece o próprio envio (mine)');
select throws_ok(format('select public.catalog_confirm(%L)', (select id from ids where nome = 'envio_ana')), 'P0001', 'own_submission',
  'quem enviou não confirma o próprio envio');

-- ---------------------------------------------------------------- confirmações e aprovação
select pg_temp.como('00000000-0000-7000-8000-0000000007b1');
select is(public.catalog_confirm((select id from ids where nome = 'envio_ana')) ->> 'status', 'confirmed', 'Bia confirma (1ª confirmação)');
select is(public.catalog_confirm((select id from ids where nome = 'envio_ana')) ->> 'status', 'confirmed', 'confirmar de novo não conta duas vezes');
select is((select confirmations from catalog.community_submissions where id = (select id from ids where nome = 'envio_ana')), 1,
  '1 confirmação independente: ainda pendente');
select is((select (p ->> 'confirmed_by_me')::boolean from jsonb_array_elements(public.catalog_by_isbn('9786530000017') -> 'pending') p
            where p ->> 'id' = (select id::text from ids where nome = 'envio_ana')), true, 'a consulta mostra que a Bia já confirmou');
select throws_ok($$ select public.catalog_confirm('01927a00-0000-7000-8000-000000000001') $$, 'P0002', 'not_found', 'envio inexistente');

-- Caio "envia" o mesmo título (outra caixa e sem acento): vale como a 2ª confirmação → aprovado
select pg_temp.como('00000000-0000-7000-8000-0000000007c1');
create temp table resposta_caio as select public.catalog_submit('9786530000017', 'MEMORIAS DO LIVRO', 'Ana Autora') as j;
select is((select j ->> 'status' from resposta_caio), 'approved', 'o mesmo título de outra conta conta como confirmação: aprovado');
select is((select j -> 'edition' -> 'authors' from resposta_caio), '["Ana Autora", "Bia Coautora"]'::jsonb,
  'a edição aprovada vem com os autores na ordem do envio');
reset role;
select is((select source || ' ' || source_license || ' ' || isbn10 || ' ' || publisher from catalog.editions where isbn13 = '9786530000017'),
  'community CC0 6530000011 Editora X', 'edição no catálogo compartilhado: fonte community, CC0, ISBN-10 calculado');
select is((select status from catalog.community_submissions where id = (select id from ids where nome = 'envio_ana')), 'approved', 'envio aprovado');
select is((select status from catalog.community_submissions where id = (select id from ids where nome = 'envio_duda')), 'rejected',
  'o pendente concorrente do mesmo ISBN é recusado');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000007d1');
select is(public.catalog_by_isbn('9786530000017') -> 'edition' ->> 'title', 'Memórias do Livro', 'a consulta agora devolve a edição');
select is(jsonb_array_length(public.catalog_by_isbn('9786530000017') -> 'pending'), 0, 'e nenhuma sugestão pendente');
select is(public.catalog_submit('9786530000017', 'Qualquer', 'Alguém') ->> 'status', 'exists', 'enviar um ISBN que já está no catálogo: exists');
select pg_temp.como('00000000-0000-7000-8000-0000000007b1');
select is((select (j ->> 'status') || ' · ' || (j -> 'edition' ->> 'title') || ' · ' || (j -> 'edition' ->> 'source')
             from (select public.catalog_confirm((select id from ids where nome = 'envio_duda')) as j) x),
  'rejected · Memórias do Livro · community',
  'confirmar um envio já recusado (lista desatualizada): devolve a edição que ficou, sem gastar a cota');
select pg_temp.como('00000000-0000-7000-8000-0000000007d1');

-- ---------------------------------------------------------------- cota (20/dia, envio + confirmação)
reset role;
update private.quota_usage set used = 20 where user_id = '00000000-0000-7000-8000-0000000007d1' and quota_key = 'catalog_contribution';
set local role authenticated;
select throws_ok($$ select public.catalog_submit('9786530000024', 'Livro Dois', 'Autora') $$, 'P0001', 'quota_exceeded',
  'mais de 20 contribuições no dia: recusado');
reset role;
select private.refund_quota('00000000-0000-7000-8000-0000000007d1', 'catalog_contribution');
select is((select used from private.quota_usage where user_id = '00000000-0000-7000-8000-0000000007d1' and quota_key = 'catalog_contribution'), 19,
  'refund_quota devolve uma consulta do dia (isbn-lookup com todas as fontes fora do ar)');
select ok(not has_function_privilege('authenticated', 'private.refund_quota(uuid, text)', 'execute')
          and not has_function_privilege('authenticated', 'private.lock_catalog_isbn(text)', 'execute'),
  'o cliente não devolve cota nem pega a trava do catálogo');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000007d1');

-- ---------------------------------------------------------------- exportação (LGPD)
select pg_temp.como('00000000-0000-7000-8000-0000000007b1');
create temp table exportado as select public.export_my_data() as j;
select is((select j ->> 'format_version' from exportado), '2', 'a exportação continua no formato 2');
select is((select jsonb_array_length(j -> 'catalog_contributions' -> 'confirmations') from exportado), 1,
  'a exportação traz as confirmações da pessoa');
select pg_temp.como('00000000-0000-7000-8000-0000000007a1');
select is((select (j -> 'catalog_contributions' -> 'submissions' -> 0) ? 'submitted_by' from (select public.export_my_data() as j) x), false,
  'e os envios dela (sem repetir o id da conta em cada um)');
select is((select j -> 'catalog_contributions' -> 'submissions' -> 0 ->> 'isbn13' from (select public.export_my_data() as j) x), '9786530000017',
  'o envio aparece na exportação de quem enviou');

-- ---------------------------------------------------------------- excluir a conta
select pg_temp.como('00000000-0000-7000-8000-0000000007b1');
insert into ids select 'envio_bia', (public.catalog_submit('9786530000031', 'Livro Três', 'Autor Três') ->> 'submission_id')::uuid;
select pg_temp.como('00000000-0000-7000-8000-0000000007c1');
select is(public.catalog_confirm((select id from ids where nome = 'envio_bia')) ->> 'status', 'confirmed', 'Caio confirma o envio da Bia');
reset role;
delete from auth.users where id = '00000000-0000-7000-8000-0000000007c1';
select is((select confirmations from catalog.community_submissions where id = (select id from ids where nome = 'envio_bia')), 0,
  'conta excluída: a confirmação dela some e o contador volta');
delete from auth.users where id in ('00000000-0000-7000-8000-0000000007a1', '00000000-0000-7000-8000-0000000007b1');
select is((select count(*)::int from catalog.community_submissions
            where id in (select id from ids where nome in ('envio_ana', 'envio_bia'))), 0,
  'conta excluída: os envios dela somem (pendentes e aprovados)');
select is((select count(*)::int from catalog.editions where isbn13 = '9786530000017'), 1,
  'o livro aprovado fica no catálogo, sem dono');

-- ---------------------------------------------------------------- D-77: ISBN-13 na estante
select throws_ok($$ insert into personal.user_books (id, user_id, title, author_display, format, status, isbn13, added_at, created_at, updated_at, version_hlc)
  values ('01927a00-0000-7000-8000-0000000007f1', '00000000-0000-7000-8000-0000000007d1', 'L', 'A', 'physical', 'want_to_read', '123', now(), now(), now(), '0001790000000000-0000-x') $$,
  '23514', null, 'isbn13 da estante com formato errado: recusado');
insert into billing.entitlements (user_id, entitlement, active_until)
values ('00000000-0000-7000-8000-0000000007d1', 'pro', now() + interval '30 days');
set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-0000000007d1');
select is((public.sync_apply_changes(jsonb_build_array(jsonb_build_object('table', 'user_books', 'op', 'PUT',
  'id', '01927a00-0000-7000-8000-0000000007f2', 'hlc', '0001790000000000-0000-x', 'data', jsonb_build_object(
    'user_id', '00000000-0000-7000-8000-0000000007d1', 'title', 'Físico', 'author_display', 'A', 'format', 'physical',
    'status', 'want_to_read', 'isbn13', '9786530000017', 'added_at', '2026-10-05T12:00:00Z',
    'created_at', '2026-10-05T12:00:00Z', 'updated_at', '2026-10-05T12:00:00Z')))) ->> 'applied')::int, 1,
  'a sincronização (Pro) leva o isbn13 da estante');
reset role;
select is((select isbn13 from personal.user_books where id = '01927a00-0000-7000-8000-0000000007f2'), '9786530000017', 'isbn13 gravado no servidor');

select * from finish();
rollback;

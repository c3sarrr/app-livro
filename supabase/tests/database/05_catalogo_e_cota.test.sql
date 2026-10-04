-- Catálogo referenciado (busca sem acento) e uso justo (fumaça OK 13 e 14 do rascunho).
begin;
create extension if not exists pgtap with schema extensions;
select plan(7);

insert into auth.users (id, email) values ('00000000-0000-7000-8000-00000000000b', 'bia@exemplo.com');
insert into catalog.editions (isbn13, title, source, source_license) values
  ('9788535910663', 'Dom Casmurro', 'openlibrary', 'CC0'),
  ('9788525406626', 'Memórias Póstumas de Brás Cubas', 'openlibrary', 'CC0');

create function pg_temp.como(p uuid) returns void language sql as $$
  select set_config('request.jwt.claims', json_build_object('sub', p, 'role', 'authenticated')::text, true)
$$;

set local role authenticated;
select pg_temp.como('00000000-0000-7000-8000-00000000000b');
select is((select title from public.search_editions('memorias postumas') limit 1), 'Memórias Póstumas de Brás Cubas',
  'OK 13 busca por trigramas sem acento');
select is((select count(*)::int from public.search_editions('dom casmurro', 500)), 1, 'o limite é cortado em 50 e a busca é precisa');
select throws_ok($$ insert into catalog.editions (title, source) values ('Pirata', 'manual') $$, '42501', null,
  'o cliente não escreve no catálogo');
reset role;

select ok((select bool_and(private.consume_quota('00000000-0000-7000-8000-00000000000b', 'isbn_externo', 30))
             from generate_series(1, 30)), 'OK 14 30 consultas externas no dia do Grátis');
select ok(not private.consume_quota('00000000-0000-7000-8000-00000000000b', 'isbn_externo', 30), 'OK 14 a 31ª é recusada');
select ok(private.consume_quota('00000000-0000-7000-8000-00000000000b', 'outra_cota', 30), 'cotas diferentes são contadas à parte');
select is((select used from private.quota_usage where quota_key = 'isbn_externo'), 30, 'a recusa não incrementa o uso');

select * from finish();
rollback;

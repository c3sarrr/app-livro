-- =====================================================================================
-- BookNest · migration 02 — catálogo referenciado (só livros que aparecem em dados sociais ou
-- de assinantes; o catálogo completo fica no R2/Workers — Anexo 02 §7). Origem: SQL §1 + §8.3b.
-- Leitura para autenticados (pela RPC public.search_editions; o esquema não é exposto na API);
-- escrita só service_role / Edge Functions, exceto as sugestões da comunidade.
-- =====================================================================================

create table catalog.authors (
  id             uuid primary key default private.uuid_generate_v7(),
  name           text not null check (char_length(name) between 1 and 200),
  sort_name      text,
  ol_author_key  text unique,
  created_at     timestamptz not null default now()
);

create table catalog.works (
  id                   uuid primary key default private.uuid_generate_v7(),
  title                text not null check (char_length(title) between 1 and 500),
  original_language    text,
  first_published_year smallint,
  ol_work_key          text unique,
  created_at           timestamptz not null default now()
);

create table catalog.work_authors (
  work_id    uuid not null references catalog.works(id) on delete cascade,
  author_id  uuid not null references catalog.authors(id) on delete cascade,
  position   smallint not null default 0,
  primary key (work_id, author_id)
);
create index work_authors_author_idx on catalog.work_authors (author_id);

create table catalog.editions (
  id              uuid primary key default private.uuid_generate_v7(),
  work_id         uuid references catalog.works(id) on delete set null,
  isbn13          text unique check (isbn13 ~ '^97[89][0-9]{10}$'),
  isbn10          text check (isbn10 ~ '^[0-9]{9}[0-9X]$'),
  title           text not null check (char_length(title) between 1 and 500),
  subtitle        text,
  publisher       text,
  published_year  smallint,
  language        text,
  pages           integer check (pages > 0),
  chapters_total  integer check (chapters_total > 0),
  cover_ref       text,                       -- id de capa da fonte (não republicamos capas)
  source          text not null check (source in ('openlibrary','dnb','community','brasilapi','hardcover','isbndb','manual')),
  source_license  text,                       -- ex.: 'CC0'; ISBNdb/Google NÃO entram aqui (termos)
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index editions_work_idx on catalog.editions (work_id);
create index editions_title_trgm_idx on catalog.editions
  using gin (private.f_unaccent(lower(title)) extensions.gin_trgm_ops);
create trigger editions_touch before update on catalog.editions
  for each row execute function private.touch_updated_at();

-- Camada 3 do scanner: "adicionar este livro" (OCR da capa + confirmação comunitária)
create table catalog.community_submissions (
  id              uuid primary key default private.uuid_generate_v7(),
  isbn13          text not null check (isbn13 ~ '^97[89][0-9]{10}$'),
  title           text not null check (char_length(title) between 1 and 500),
  authors         text not null check (char_length(authors) between 1 and 500),
  publisher       text,
  submitted_by    uuid references auth.users(id) on delete set null,
  status          text not null default 'pending' check (status in ('pending','approved','rejected')),
  confirmations   integer not null default 0,
  created_at      timestamptz not null default now()
);
create index community_submissions_isbn_idx on catalog.community_submissions (isbn13, status);
create index community_submissions_user_idx on catalog.community_submissions (submitted_by);

create table catalog.submission_confirmations (
  submission_id uuid not null references catalog.community_submissions(id) on delete cascade,
  user_id       uuid not null references auth.users(id) on delete cascade,
  created_at    timestamptz not null default now(),
  primary key (submission_id, user_id)
);
create index submission_confirmations_user_idx on catalog.submission_confirmations (user_id);

-- RLS --------------------------------------------------------------------------------
alter table catalog.authors                  enable row level security;
alter table catalog.works                    enable row level security;
alter table catalog.work_authors             enable row level security;
alter table catalog.editions                 enable row level security;
alter table catalog.community_submissions    enable row level security;
alter table catalog.submission_confirmations enable row level security;

create policy catalog_authors_read  on catalog.authors      for select to authenticated using (true);
create policy catalog_works_read    on catalog.works        for select to authenticated using (true);
create policy catalog_wa_read       on catalog.work_authors for select to authenticated using (true);
create policy catalog_editions_read on catalog.editions     for select to authenticated using (true);
create policy submissions_read on catalog.community_submissions for select to authenticated using (true);
create policy submissions_insert on catalog.community_submissions for insert to authenticated
  with check (submitted_by = (select auth.uid()) and status = 'pending' and confirmations = 0);
create policy confirmations_insert on catalog.submission_confirmations for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy confirmations_read on catalog.submission_confirmations for select to authenticated
  using (user_id = (select auth.uid()));

-- Busca no catálogo referenciado (trigramas, sem acento). O catálogo completo é buscado pelo
-- Worker (Anexo 02 §7); esta RPC cobre títulos já referenciados.
create or replace function public.search_editions(p_query text, p_limit integer default 20)
returns setof catalog.editions
language sql stable security invoker set search_path = '' as $$
  select e.* from catalog.editions e
   where private.f_unaccent(lower(e.title)) operator(extensions.%) private.f_unaccent(lower(p_query))
   order by extensions.similarity(private.f_unaccent(lower(e.title)), private.f_unaccent(lower(p_query))) desc,
            e.id
   limit least(greatest(p_limit, 1), 50)
$$;

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke all on catalog.authors, catalog.works, catalog.work_authors, catalog.editions,
  catalog.community_submissions, catalog.submission_confirmations from public, anon, authenticated;
revoke execute on function public.search_editions(text, integer) from public, anon, authenticated;

grant select on catalog.authors, catalog.works, catalog.work_authors, catalog.editions,
  catalog.community_submissions, catalog.submission_confirmations to authenticated;
grant insert (isbn13, title, authors, publisher, submitted_by) on catalog.community_submissions to authenticated;
grant insert (submission_id, user_id) on catalog.submission_confirmations to authenticated;
grant execute on function public.search_editions(text, integer) to authenticated;

grant all on catalog.authors, catalog.works, catalog.work_authors, catalog.editions,
  catalog.community_submissions, catalog.submission_confirmations to service_role;
grant execute on function public.search_editions(text, integer) to service_role;

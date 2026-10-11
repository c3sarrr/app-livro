-- =====================================================================================
-- BookNest · G07 — catálogo e scanner reais (Anexo 02 §7, ADR-008).
--  1. D-77: a estante guarda o ISBN-13 do exemplar (`personal.user_books.isbn13`). Sincroniza como
--     as outras colunas (a RPC de sincronização e o PowerSync leem o catálogo do Postgres).
--  2. D-74: camada da comunidade ("adicionar este livro") só pelas RPCs abaixo — o cliente não
--     escreve direto nas tabelas; quem enviou fica oculto para os outros; exige a faixa etária
--     (D-72); cota diária. 2 confirmações independentes (de outras contas) → aprovado → entra em
--     catalog.editions (fonte `community`) e os outros pendentes do mesmo ISBN são recusados.
--  3. Ao excluir a conta, os envios e as confirmações dela somem (o livro já aprovado fica no
--     catálogo, sem dono). A exportação (LGPD) inclui as contribuições.
-- =====================================================================================

-- ------------------------------------------------------------------------------------- 1
alter table personal.user_books
  add column isbn13 text check (isbn13 ~ '^97[89][0-9]{10}$');
-- sem UNIQUE: dois aparelhos offline podem guardar o mesmo exemplar; o app avisa ("já está na
-- estante") e uma recusa 23505 na sincronização prenderia a fila
create index user_books_user_isbn_idx on personal.user_books (user_id, isbn13)
  where isbn13 is not null and deleted_at is null;

-- ------------------------------------------------------------------------------------- 2
-- ISBN-13 válido (dígito verificador) e o ISBN-10 equivalente (só 978)
create or replace function private.isbn13_valid(p text) returns boolean
language sql immutable set search_path = '' as $$
  select case when p ~ '^97[89][0-9]{10}$' then
    (select sum(substr(p, i, 1)::int * case when i % 2 = 1 then 1 else 3 end)
       from generate_series(1, 13) i) % 10 = 0
  else false end
$$;

create or replace function private.isbn10_of(p text) returns text
language sql immutable set search_path = '' as $$
  select case when p ~ '^978[0-9]{10}$' then
    substr(p, 4, 9) || (select case c when 10 then 'X' else c::text end
                          from (select (11 - (sum(substr(p, 3 + i, 1)::int * (11 - i)) % 11)) % 11 as c
                                  from generate_series(1, 9) i) x)
  end
$$;

-- Uma escrita da comunidade por ISBN de cada vez (envio, confirmação e aprovação): sem isto, duas
-- confirmações simultâneas do mesmo envio se travavam (deadlock — achado 3 da revisão da G07) e duas
-- aprovações de envios rivais disputavam a mesma edição.
create or replace function private.lock_catalog_isbn(p_isbn13 text) returns void
language sql volatile set search_path = '' as $$
  select pg_advisory_xact_lock(hashtextextended('booknest.catalogo:' || p_isbn13, 0))
$$;

-- texto do envio: NFC, espaços colapsados, sem pontas; vazio → null
create or replace function private.catalog_clean(p text) returns text
language sql immutable set search_path = '' as $$
  select nullif(btrim(regexp_replace(normalize(coalesce(p, ''), nfc), '\s+', ' ', 'g')), '')
$$;

-- As pessoas não leem quem enviou (D-74): leitura direta só das colunas públicas; a escrita é só
-- pelas RPCs (security definer).
drop policy submissions_insert on catalog.community_submissions;
drop policy confirmations_insert on catalog.submission_confirmations;
revoke all on catalog.community_submissions, catalog.submission_confirmations from authenticated;
grant select (id, isbn13, title, authors, publisher, status, confirmations, created_at)
  on catalog.community_submissions to authenticated;
grant select on catalog.submission_confirmations to authenticated;   -- política: só as próprias

-- ao excluir a conta, os envios dela somem (as confirmações já tinham `on delete cascade`)
alter table catalog.community_submissions
  drop constraint community_submissions_submitted_by_fkey,
  add constraint community_submissions_submitted_by_fkey
    foreign key (submitted_by) references auth.users(id) on delete cascade;

-- o contador acompanha as confirmações (inclusive as que somem com a conta de quem confirmou)
create or replace function private.count_confirmations() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_id uuid := coalesce(new.submission_id, old.submission_id);
begin
  update catalog.community_submissions s
     set confirmations = (select count(*) from catalog.submission_confirmations c where c.submission_id = v_id)
   where s.id = v_id;
  return null;
end $$;
create trigger submission_confirmations_count
  after insert or delete on catalog.submission_confirmations
  for each row execute function private.count_confirmations();

-- aprova o envio pendente que já tem 2 confirmações: cria obra, autores e edição (fonte community)
-- e recusa os outros pendentes do mesmo ISBN. Devolve o status final do envio.
create or replace function private.catalog_settle(p_submission uuid) returns text
language plpgsql security definer set search_path = '' as $$
declare s catalog.community_submissions; v_work uuid; v_author uuid; v_nome text; v_pos smallint := 0;
begin
  select * into s from catalog.community_submissions where id = p_submission for update;
  if s.id is null or s.status <> 'pending' or s.confirmations < 2 then
    return coalesce(s.status, 'missing');
  end if;
  if not exists (select 1 from catalog.editions e where e.isbn13 = s.isbn13) then
    insert into catalog.works (title) values (s.title) returning id into v_work;
    foreach v_nome in array regexp_split_to_array(s.authors, '\s*[;·]\s*') loop
      v_nome := left(private.catalog_clean(v_nome), 200);
      continue when v_nome is null;
      select a.id into v_author from catalog.authors a where a.name = v_nome order by a.created_at limit 1;
      if v_author is null then
        insert into catalog.authors (name) values (v_nome) returning id into v_author;
      end if;
      insert into catalog.work_authors (work_id, author_id, position) values (v_work, v_author, v_pos)
      on conflict do nothing;
      v_pos := v_pos + 1;
      v_author := null;
    end loop;
    insert into catalog.editions (work_id, isbn13, isbn10, title, publisher, source, source_license)
    values (v_work, s.isbn13, private.isbn10_of(s.isbn13), s.title, s.publisher, 'community', 'CC0')
    on conflict (isbn13) do nothing;
  end if;
  update catalog.community_submissions set status = 'approved' where id = s.id;
  update catalog.community_submissions set status = 'rejected'
   where isbn13 = s.isbn13 and status = 'pending' and id <> s.id;
  return 'approved';
end $$;

-- edição do catálogo no formato do app (CatalogBook.fromJson)
create or replace function private.catalog_edition_json(p_isbn13 text) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'isbn13', e.isbn13, 'title', e.title, 'subtitle', e.subtitle,
    'authors', coalesce((select jsonb_agg(a.name order by wa.position, a.name)
                           from catalog.work_authors wa join catalog.authors a on a.id = wa.author_id
                          where wa.work_id = e.work_id), '[]'::jsonb),
    'publisher', e.publisher, 'year', e.published_year, 'pages', e.pages, 'language', e.language,
    'cover_ref', e.cover_ref, 'source', e.source, 'source_license', e.source_license)
    from catalog.editions e where e.isbn13 = p_isbn13
$$;

-- Camada da comunidade na consulta do app: a edição (se houver) e até 5 sugestões pendentes, sem
-- quem enviou. Só o ISBN vai na chamada (lista branca do Grátis).
create or replace function public.catalog_by_isbn(p_isbn13 text) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid());
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.isbn13_valid(p_isbn13) then raise exception 'invalid_isbn' using errcode = '22023'; end if;
  return jsonb_build_object(
    'edition', private.catalog_edition_json(p_isbn13),
    'pending', coalesce((
      select jsonb_agg(jsonb_build_object(
               'id', s.id, 'title', s.title, 'authors', s.authors, 'publisher', s.publisher,
               'confirmations', s.confirmations, 'mine', s.submitted_by = v_uid,
               'confirmed_by_me', exists (select 1 from catalog.submission_confirmations c
                                           where c.submission_id = s.id and c.user_id = v_uid))
               order by s.confirmations desc, s.created_at, s.id)
        from (select * from catalog.community_submissions x
               where x.isbn13 = p_isbn13 and x.status = 'pending'
               order by x.confirmations desc, x.created_at, x.id limit 5) s), '[]'::jsonb));
end $$;

-- confirmação de um envio de OUTRA pessoa (toque explícito); idempotente
create or replace function private.catalog_confirm_as(p_uid uuid, p_submission uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare s catalog.community_submissions; v_isbn text; v_status text;
begin
  select x.isbn13 into v_isbn from catalog.community_submissions x where x.id = p_submission;
  if v_isbn is null then raise exception 'not_found' using errcode = 'P0002'; end if;
  perform private.lock_catalog_isbn(v_isbn);
  -- relido sob a trava: o status pode ter mudado (envio rival aprovado) enquanto esperava
  select * into s from catalog.community_submissions where id = p_submission for update;
  if s.id is null then raise exception 'not_found' using errcode = 'P0002'; end if;
  if s.submitted_by = p_uid then raise exception 'own_submission' using errcode = 'P0001'; end if;
  if s.status <> 'pending' then
    -- já aprovado ou recusado (outro envio do mesmo ISBN entrou): devolve a edição que ficou
    return jsonb_build_object('status', s.status, 'submission_id', s.id,
                              'edition', private.catalog_edition_json(s.isbn13));
  end if;
  if not exists (select 1 from catalog.submission_confirmations c
                  where c.submission_id = s.id and c.user_id = p_uid) then
    if not private.consume_quota(p_uid, 'catalog_contribution', 20) then
      raise exception 'quota_exceeded' using errcode = 'P0001';
    end if;
    insert into catalog.submission_confirmations (submission_id, user_id) values (s.id, p_uid);
  end if;
  v_status := private.catalog_settle(s.id);
  return jsonb_build_object('status', case v_status when 'approved' then 'approved' else 'confirmed' end,
                            'submission_id', s.id,
                            'edition', case v_status when 'approved' then private.catalog_edition_json(s.isbn13) end);
end $$;

create or replace function public.catalog_confirm(p_submission uuid) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid());
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not exists (select 1 from private.account_age a where a.user_id = v_uid) then
    raise exception 'age_required' using errcode = 'P0001', hint = 'Confirme sua idade para contribuir com o catálogo.';
  end if;
  return private.catalog_confirm_as(v_uid, p_submission);
end $$;

-- "Adicionar este livro" (D-74): ISBN + título + autor(es) + editora, só com toque explícito.
-- Devolve {status: exists | pending | confirmed | approved, submission_id?, edition?}.
create or replace function public.catalog_submit(p_isbn13 text, p_title text, p_authors text, p_publisher text default null)
returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := (select auth.uid());
  v_title text := private.catalog_clean(p_title);
  v_authors text := private.catalog_clean(p_authors);
  v_publisher text := private.catalog_clean(p_publisher);
  v_id uuid;
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not exists (select 1 from private.account_age a where a.user_id = v_uid) then
    raise exception 'age_required' using errcode = 'P0001', hint = 'Confirme sua idade para contribuir com o catálogo.';
  end if;
  if not private.isbn13_valid(p_isbn13) then raise exception 'invalid_isbn' using errcode = '22023'; end if;
  if v_title is null or char_length(v_title) > 500 or v_authors is null or char_length(v_authors) > 500
     or char_length(v_publisher) > 200 then
    raise exception 'invalid_fields' using errcode = '22023';
  end if;
  perform private.lock_catalog_isbn(p_isbn13);

  if exists (select 1 from catalog.editions e where e.isbn13 = p_isbn13) then
    return jsonb_build_object('status', 'exists', 'edition', private.catalog_edition_json(p_isbn13));
  end if;
  -- reenvio da mesma pessoa: devolve o que já existe (sem gastar a cota)
  select s.id into v_id from catalog.community_submissions s
   where s.isbn13 = p_isbn13 and s.status = 'pending' and s.submitted_by = v_uid limit 1;
  if v_id is not null then
    return jsonb_build_object('status', 'pending', 'submission_id', v_id);
  end if;
  -- outra pessoa já enviou o mesmo título: vale como confirmação dela
  select s.id into v_id from catalog.community_submissions s
   where s.isbn13 = p_isbn13 and s.status = 'pending'
     and private.f_unaccent(lower(s.title)) = private.f_unaccent(lower(v_title))
   order by s.confirmations desc, s.created_at limit 1;
  if v_id is not null then
    return private.catalog_confirm_as(v_uid, v_id);
  end if;

  if not private.consume_quota(v_uid, 'catalog_contribution', 20) then
    raise exception 'quota_exceeded' using errcode = 'P0001';
  end if;
  insert into catalog.community_submissions (isbn13, title, authors, publisher, submitted_by)
  values (p_isbn13, v_title, v_authors, v_publisher, v_uid) returning id into v_id;
  return jsonb_build_object('status', 'pending', 'submission_id', v_id);
end $$;

-- A Edge Function isbn-lookup devolve a consulta da cota quando nenhuma fonte respondeu (todas fora do
-- ar): a pessoa não paga por uma falha de terceiros (achado 9 da revisão da G07).
create or replace function private.refund_quota(p_user uuid, p_key text) returns void
language sql security definer set search_path = '' as $$
  update private.quota_usage set used = greatest(used - 1, 0)
   where user_id = p_user and quota_key = p_key
     and day = (now() at time zone 'America/Sao_Paulo')::date
$$;

-- ------------------------------------------------------------------------------------- 3
-- Exportação (LGPD): o núcleo da G05 continua igual; a versão pública acrescenta as contribuições
alter function public.export_my_data() rename to export_my_data_core;
alter function public.export_my_data_core() set schema private;

create or replace function public.export_my_data() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid()); v_out jsonb;
begin
  v_out := private.export_my_data_core();   -- autenticação e cota (3/dia) ficam no núcleo
  return v_out || jsonb_build_object(
    'catalog_contributions', jsonb_build_object(
      'submissions', coalesce((select jsonb_agg(to_jsonb(s) - 'submitted_by' order by s.created_at)
                                 from catalog.community_submissions s where s.submitted_by = v_uid), '[]'::jsonb),
      'confirmations', coalesce((select jsonb_agg(jsonb_build_object('submission_id', c.submission_id,
                                                                     'created_at', c.created_at) order by c.created_at)
                                   from catalog.submission_confirmations c where c.user_id = v_uid), '[]'::jsonb)));
end $$;

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke execute on function private.isbn13_valid(text), private.isbn10_of(text), private.catalog_clean(text),
  private.lock_catalog_isbn(text), private.refund_quota(uuid, text),
  private.count_confirmations(), private.catalog_settle(uuid), private.catalog_edition_json(text),
  private.catalog_confirm_as(uuid, uuid), private.export_my_data_core(),
  public.catalog_by_isbn(text), public.catalog_confirm(uuid), public.catalog_submit(text, text, text, text),
  public.export_my_data()
  from public, anon, authenticated;
grant execute on function public.catalog_by_isbn(text), public.catalog_confirm(uuid),
  public.catalog_submit(text, text, text, text), public.export_my_data() to authenticated;
grant execute on function private.isbn13_valid(text), private.isbn10_of(text), private.catalog_clean(text),
  private.lock_catalog_isbn(text), private.refund_quota(uuid, text), private.catalog_settle(uuid), private.catalog_edition_json(text), private.catalog_confirm_as(uuid, uuid),
  private.export_my_data_core(),
  public.catalog_by_isbn(text), public.catalog_confirm(uuid), public.catalog_submit(text, text, text, text),
  public.export_my_data() to service_role;

-- =====================================================================================
-- BookNest · G06 — e-books na nuvem (Pro, opcional): download por URL CURTA emitida pelo servidor e
-- exclusão pelo servidor (pendência do ADR-003 / achado #5 da revisão da G04).
-- Antes: o dono podia gerar link assinado de validade longa direto no Storage (política SELECT) e
-- apagar arquivos (política DELETE). Agora o cliente não toca no bucket:
--   upload   → URL assinada da Edge Function `ebook-upload-url` (Pro + cota — G04), simples ou
--              retomável (TUS em /upload/resumable/sign com o token — provado na G06);
--   download → URL de 5 min da Edge Function `ebook-download-url` (Pro, dono, livro ativo);
--   exclusão → livro apagado (ou arquivo trocado) entra na fila private.ebook_object_deletions,
--              esvaziada pela Edge Function `purge-storage` (pg_cron).
-- =====================================================================================

drop policy if exists ebooks_owner_read on storage.objects;
drop policy if exists ebooks_owner_delete on storage.objects;

-- -------------------------------------------------------------------------------------
-- Caminho para baixar: Pro, dono, livro ativo e o arquivo existe. O caminho vem da linha
-- sincronizada (o cliente escreve storage_object_path pela RPC): só vale dentro da pasta da
-- própria conta e do próprio livro — nunca o arquivo de outra pessoa.
-- -------------------------------------------------------------------------------------
create or replace function private.ebook_download_path(p_user uuid, p_user_book uuid) returns text
language plpgsql stable security definer set search_path = '' as $$
declare v_path text;
begin
  if not private.can_sync(p_user) then
    raise exception 'pro_required' using errcode = 'P0001';
  end if;
  select b.storage_object_path into v_path
    from personal.user_books b
   where b.id = p_user_book and b.user_id = p_user and b.deleted_at is null;
  if v_path is null or left(v_path, 74) <> p_user::text || '/' || p_user_book::text || '/' then
    raise exception 'book_not_found' using errcode = 'P0001';
  end if;
  if not exists (select 1 from storage.objects o where o.bucket_id = 'ebooks' and o.name = v_path) then
    raise exception 'file_not_found' using errcode = 'P0001';
  end if;
  return v_path;
end $$;

-- -------------------------------------------------------------------------------------
-- Fila de exclusão de arquivos avulsos (a pasta inteira da conta continua na
-- private.storage_purge_queue — retenção e exclusão da conta).
-- -------------------------------------------------------------------------------------
create table private.ebook_object_deletions (
  path          text primary key,
  user_id       uuid not null,             -- sem FK: a conta pode sumir antes (a pasta toda sai pela outra fila)
  requested_at  timestamptz not null default now(),
  attempts      integer not null default 0,
  last_error    text
);
create index ebook_object_deletions_pending_idx on private.ebook_object_deletions (requested_at);
alter table private.ebook_object_deletions enable row level security;   -- sem política: só service_role

-- livro apagado (exclusão lógica que chega pela sincronização) ou arquivo trocado → o antigo sai
create or replace function private.queue_ebook_object_deletion() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if old.storage_object_path is not null
     and left(old.storage_object_path, 37) = old.user_id::text || '/'
     and ((new.deleted_at is not null and old.deleted_at is null)
          or new.storage_object_path is distinct from old.storage_object_path) then
    insert into private.ebook_object_deletions (path, user_id)
    values (old.storage_object_path, old.user_id)
    on conflict (path) do nothing;
  end if;
  return null;
end $$;
create trigger user_books_ebook_object_deletion
  after update of deleted_at, storage_object_path on personal.user_books
  for each row execute function private.queue_ebook_object_deletion();

-- Reserva um lote para a função apagar. Caminho que voltou a ser usado por um livro ativo
-- (exclusão desfeita por uma versão mais nova) sai da fila sem apagar nada.
create or replace function private.claim_ebook_deletions(p_limit integer default 100)
returns table (path text)
language plpgsql security definer set search_path = '' as $$
begin
  delete from private.ebook_object_deletions d
   where exists (select 1 from personal.user_books b
                  where b.storage_object_path = d.path and b.deleted_at is null);
  return query
  with fila as (
    select d.path from private.ebook_object_deletions d
     where d.attempts < 10
     order by d.requested_at
     limit least(greatest(p_limit, 1), 500)
     for update skip locked)
  update private.ebook_object_deletions d set attempts = d.attempts + 1
    from fila where d.path = fila.path
  returning d.path;
end $$;

create or replace function private.finish_ebook_deletion(p_path text, p_error text default null) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if p_error is null then
    delete from private.ebook_object_deletions where path = p_path;
  else
    update private.ebook_object_deletions set last_error = left(p_error, 300) where path = p_path;
  end if;
end $$;

-- -------------------------------------------------------------------------------------
-- Permissões: só o servidor (Edge Functions com a chave secreta)
-- -------------------------------------------------------------------------------------
revoke all on private.ebook_object_deletions from public, anon, authenticated;
grant all on private.ebook_object_deletions to service_role;
revoke execute on function private.ebook_download_path(uuid, uuid), private.queue_ebook_object_deletion(),
  private.claim_ebook_deletions(integer), private.finish_ebook_deletion(text, text)
  from public, anon, authenticated;
grant execute on function private.ebook_download_path(uuid, uuid), private.claim_ebook_deletions(integer),
  private.finish_ebook_deletion(text, text) to service_role;

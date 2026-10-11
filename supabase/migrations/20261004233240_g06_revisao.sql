-- =====================================================================================
-- BookNest · G06 — achados da revisão independente da fase.
--  1. O caminho do e-book na nuvem (user_books.storage_object_path) não é rebaixado pela
--     sincronização: um PUT mais novo de um aparelho que não sabia do arquivo (caminho NULL) ou que
--     guardava um caminho que já não existe gravaria NULL/lixo e o arquivo bom iria para a fila de
--     exclusão. Agora o caminho só muda para um arquivo que EXISTE na pasta da conta e do livro.
--  2. Arquivo sem dono: upload que termina com o livro já apagado (o gatilho só via o caminho antigo)
--     e objetos que nenhum livro ativo usa há 7 dias (reconciliação no claim) vão para a fila.
--  3. sync_apply_changes: linha cujo user_id não é o da sessão é RECUSADA (owner_mismatch) em vez de
--     ser gravada na conta de quem chamou (troca de conta no meio de um upload).
-- =====================================================================================

-- ------------------------------------------------------------------------------------- 1
create or replace function private.keep_ebook_path() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.storage_object_path is distinct from old.storage_object_path
     and (new.storage_object_path is null
          or left(new.storage_object_path, 74) <> new.user_id::text || '/' || new.id::text || '/'
          or not exists (select 1 from storage.objects o
                          where o.bucket_id = 'ebooks' and o.name = new.storage_object_path)) then
    new.storage_object_path := old.storage_object_path;
  end if;
  return new;
end $$;
create trigger user_books_keep_ebook_path
  before update of storage_object_path on personal.user_books
  for each row execute function private.keep_ebook_path();

-- ------------------------------------------------------------------------------------- 2
create or replace function private.queue_ebook_object_deletion() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  -- o arquivo antigo: livro apagado agora ou arquivo trocado
  if old.storage_object_path is not null
     and left(old.storage_object_path, 37) = old.user_id::text || '/'
     and ((new.deleted_at is not null and old.deleted_at is null)
          or new.storage_object_path is distinct from old.storage_object_path) then
    insert into private.ebook_object_deletions (path, user_id)
    values (old.storage_object_path, old.user_id)
    on conflict (path) do nothing;
  end if;
  -- o arquivo novo de um livro que já está apagado (envio que terminou depois da exclusão)
  if new.deleted_at is not null and new.storage_object_path is not null
     and new.storage_object_path is distinct from old.storage_object_path
     and left(new.storage_object_path, 37) = new.user_id::text || '/' then
    insert into private.ebook_object_deletions (path, user_id)
    values (new.storage_object_path, new.user_id)
    on conflict (path) do nothing;
  end if;
  return null;
end $$;

create or replace function private.claim_ebook_deletions(p_limit integer default 100)
returns table (path text)
language plpgsql security definer set search_path = '' as $$
begin
  -- reconciliação: arquivo que nenhum livro ativo usa, sem envio em andamento, há 7 dias
  insert into private.ebook_object_deletions (path, user_id)
  select o.name, (split_part(o.name, '/', 1))::uuid
    from storage.objects o
   where o.bucket_id = 'ebooks'
     and o.created_at < now() - interval '7 days'
     and split_part(o.name, '/', 1) ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
     and not exists (select 1 from personal.user_books b
                      where b.storage_object_path = o.name and b.deleted_at is null)
     and not exists (select 1 from private.ebook_upload_reservations r where r.path = o.name)
   limit 500
  on conflict on constraint ebook_object_deletions_pkey do nothing;

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

-- ------------------------------------------------------------------------------------- 3
-- A RPC em lote (G04) continua igual, agora como núcleo privado; a pública confere o dono de cada
-- operação antes.
alter function public.sync_apply_changes(jsonb) rename to sync_apply_changes_core;
alter function public.sync_apply_changes_core(jsonb) set schema private;

create or replace function public.sync_apply_changes(p_changes jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_uid       uuid := (select auth.uid());
  v_ok        jsonb := '[]'::jsonb;
  v_recusadas jsonb := '[]'::jsonb;
  v_op        jsonb;
  v_res       jsonb;
begin
  if v_uid is not null and jsonb_typeof(p_changes) = 'array' then
    for v_op in select value from jsonb_array_elements(p_changes) loop
      if jsonb_typeof(v_op -> 'data') = 'object'
         and (v_op -> 'data') ? 'user_id'
         and (v_op -> 'data' ->> 'user_id') is distinct from v_uid::text then
        v_recusadas := v_recusadas || jsonb_build_object(
          'table', v_op ->> 'table', 'id', v_op ->> 'id', 'error', 'owner_mismatch',
          'code', '22023', 'retryable', false);
      else
        v_ok := v_ok || jsonb_build_array(v_op);
      end if;
    end loop;
  else
    v_ok := p_changes;   -- sem sessão ou lote malformado: o núcleo recusa como antes
  end if;
  v_res := private.sync_apply_changes_core(v_ok);
  return jsonb_set(v_res, '{rejected}', coalesce(v_res -> 'rejected', '[]'::jsonb) || v_recusadas);
end $$;

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke execute on function private.keep_ebook_path(), private.sync_apply_changes_core(jsonb)
  from public, anon, authenticated;
revoke execute on function public.sync_apply_changes(jsonb) from public, anon;
grant execute on function public.sync_apply_changes(jsonb) to authenticated;
grant execute on function private.sync_apply_changes_core(jsonb) to service_role;

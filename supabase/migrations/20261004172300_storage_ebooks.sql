-- =====================================================================================
-- BookNest · migration 08 — e-books na nuvem (Pro, opcional): bucket PRIVADO "ebooks",
-- caminho "<user_id>/<user_book_id>/<sha256>.<ext>" (Anexo 02 §6.4). Origem: SQL §7 (Storage).
-- =====================================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('ebooks', 'ebooks', false, 209715200,                       -- 200 MiB por arquivo
        array['application/epub+zip', 'application/pdf'])
on conflict (id) do nothing;

create policy ebooks_owner_read on storage.objects for select to authenticated
  using (bucket_id = 'ebooks' and (storage.foldername(name))[1] = (select auth.uid())::text);
-- SEM política de INSERT: o upload só acontece por URL assinada emitida pela Edge Function
-- `ebook-upload-url`, que confere o Pro e a cota de 2 GB antes (upload direto burlaria a cota).
create policy ebooks_owner_delete on storage.objects for delete to authenticated
  using (bucket_id = 'ebooks' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- -------------------------------------------------------------------------------------
-- Permissões: storage.objects é do Supabase (privilégios dele); aqui só as políticas acima.
-- -------------------------------------------------------------------------------------

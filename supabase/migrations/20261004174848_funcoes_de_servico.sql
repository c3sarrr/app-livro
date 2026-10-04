-- =====================================================================================
-- BookNest · migration 12 — funções usadas pelas Edge Functions (conexão direta ao banco com o
-- papel do servidor; nada disto é exposto pela API). Cada função faz o trabalho de banco de uma
-- Edge Function, para a regra ficar testável em pgTAP e a função Deno ficar fina:
--   revenuecat-webhook → rc_begin_event / rc_apply_subscriber / rc_finish_event
--   ebook-upload-url   → ebook_upload_slot          email-sender  → claim_emails / finish_email
--   purge-storage      → claim_storage_purges / finish_storage_purge
--   push-sender        → claim_pushes / drop_device_token
--   export-data        → public.export_my_data (o próprio usuário, com cota diária)
-- =====================================================================================

-- ------------------------------------------------------------------ RevenueCat (Anexo 04 §5)
-- Idempotência: 'new' (processar), 'retry' (chegou antes e falhou: processar de novo) ou 'done'.
create or replace function private.rc_begin_event(p_event jsonb) returns text
language plpgsql security definer set search_path = '' as $$
declare v_id text := p_event ->> 'id'; v_processed timestamptz; v_inserted boolean;
begin
  if v_id is null or v_id = '' then raise exception 'event_without_id' using errcode = '22023'; end if;
  insert into billing.webhook_events (event_id, event_type, app_user_id, payload)
  values (v_id, coalesce(p_event ->> 'type', 'UNKNOWN'), p_event ->> 'app_user_id', p_event)
  on conflict (event_id) do nothing
  returning true into v_inserted;
  if v_inserted then return 'new'; end if;
  select processed_at into v_processed from billing.webhook_events where event_id = v_id;
  return case when v_processed is null then 'retry' else 'done' end;
end $$;

create or replace function private.rc_finish_event(p_event_id text, p_error text default null) returns void
language sql security definer set search_path = '' as $$
  update billing.webhook_events
     set processed_at = case when p_error is null then now() end, error = p_error
   where event_id = p_event_id
$$;

-- Estado atual do assinante (já normalizado pela Edge Function a partir da API do RevenueCat —
-- nunca confiar na ordem dos eventos). p_subs = lista de assinaturas:
--   {store, product_id, period_type, status, will_renew, starts_at, ends_at, grace_ends_at,
--    original_transaction_id, environment}
-- O direito "pro" vale até o maior fim (com carência) entre as assinaturas que liberam o Pro.
create or replace function private.rc_apply_subscriber(p_user uuid, p_subs jsonb, p_event_at timestamptz default now())
returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_until timestamptz; v_env text; v_source uuid; s jsonb;
begin
  if jsonb_typeof(p_subs) <> 'array' then raise exception 'invalid_subscriptions' using errcode = '22023'; end if;
  if not exists (select 1 from auth.users u where u.id = p_user) then
    raise exception 'unknown_user' using errcode = 'P0001';
  end if;
  for s in select value from jsonb_array_elements(p_subs) loop
    insert into billing.subscriptions as t (user_id, store, product_id, period_type, status, will_renew,
      current_period_starts_at, current_period_ends_at, grace_period_ends_at, original_transaction_id,
      environment, last_event_at, updated_at)
    values (p_user, s ->> 'store', s ->> 'product_id', s ->> 'period_type', s ->> 'status',
      (s ->> 'will_renew')::boolean, (s ->> 'starts_at')::timestamptz, (s ->> 'ends_at')::timestamptz,
      (s ->> 'grace_ends_at')::timestamptz, s ->> 'original_transaction_id', s ->> 'environment',
      p_event_at, now())
    on conflict (store, original_transaction_id) do update set
      user_id = excluded.user_id, product_id = excluded.product_id, period_type = excluded.period_type,
      status = excluded.status, will_renew = excluded.will_renew,
      current_period_starts_at = excluded.current_period_starts_at,
      current_period_ends_at = excluded.current_period_ends_at,
      grace_period_ends_at = excluded.grace_period_ends_at, environment = excluded.environment,
      last_event_at = greatest(t.last_event_at, excluded.last_event_at), updated_at = now();
  end loop;

  select greatest(x.current_period_ends_at, coalesce(x.grace_period_ends_at, x.current_period_ends_at)),
         x.environment, x.id
    into v_until, v_env, v_source
    from billing.subscriptions x
   where x.user_id = p_user and x.entitlement = 'pro' and x.status <> 'refunded'
   order by 1 desc limit 1;

  if v_until is null then
    -- sem assinatura válida (ex.: reembolso): o Pro termina agora
    update billing.entitlements set active_until = least(active_until, now()), updated_at = now()
     where user_id = p_user and entitlement = 'pro';
  else
    insert into billing.entitlements as e (user_id, entitlement, active_until, environment, source_subscription_id, updated_at)
    values (p_user, 'pro', v_until, v_env, v_source, now())
    on conflict (user_id, entitlement) do update set active_until = excluded.active_until,
      environment = excluded.environment, source_subscription_id = excluded.source_subscription_id, updated_at = now();
  end if;

  -- acesso ao sync deste usuário na hora (o refresh_sync_access de 15 em 15 min cobre o resto)
  insert into billing.sync_access as a (user_id, granted, updated_at)
  select e.user_id, e.active_until + interval '7 days' > now(), now()
    from billing.entitlements e where e.user_id = p_user and e.entitlement = 'pro'
  on conflict (user_id) do update set granted = excluded.granted, updated_at = now();

  return public.entitlement_of(p_user);
end $$;

-- Estado do Pro de um usuário (mesmo formato de public.my_entitlement — só para o servidor)
create or replace function public.entitlement_of(p_user uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('pro', coalesce(bool_or(e.active_until > now()), false), 'active_until', max(e.active_until))
    from billing.entitlements e where e.user_id = p_user and e.entitlement = 'pro'
$$;

-- ------------------------------------------------------------------ e-books na nuvem (Anexo 02 §6.4)
-- Reserva o caminho do upload: Pro, livro do próprio usuário, sha256 do livro e cota de 2 GiB
-- medida no próprio Storage (o tamanho que o cliente informa não é confiável para a cota).
create or replace function private.ebook_upload_slot(p_user uuid, p_user_book uuid, p_sha256 text, p_bytes bigint)
returns text
language plpgsql security definer set search_path = '' as $$
declare v_book personal.user_books; v_used bigint; v_ext text; v_path text;
begin
  if not private.can_sync(p_user) then raise exception 'pro_required' using errcode = 'P0001'; end if;
  if p_sha256 !~ '^[0-9a-f]{64}$' or p_bytes is null or p_bytes <= 0 then
    raise exception 'invalid_file' using errcode = '22023';
  end if;
  select * into v_book from personal.user_books b where b.id = p_user_book and b.user_id = p_user and b.deleted_at is null;
  if v_book.id is null or v_book.format not in ('epub', 'pdf') then
    raise exception 'book_not_found' using errcode = 'P0001';
  end if;
  if v_book.content_sha256 is distinct from p_sha256 then
    raise exception 'sha_mismatch' using errcode = 'P0001';
  end if;
  v_ext := v_book.format;
  v_path := format('%s/%s/%s.%s', p_user, p_user_book, p_sha256, v_ext);
  select coalesce(sum((o.metadata ->> 'size')::bigint), 0) into v_used
    from storage.objects o
   where o.bucket_id = 'ebooks' and o.name like p_user::text || '/%' and o.name <> v_path;
  if v_used + p_bytes > 2147483648 then
    raise exception 'quota_exceeded' using errcode = 'P0001',
      hint = format('usado %s de 2147483648 bytes', v_used);
  end if;
  return v_path;
end $$;

-- ------------------------------------------------------------------ e-mails (fila private.email_outbox)
-- Pega até p_limit e-mails pendentes (até 5 tentativas), sem disputar com outra execução.
create or replace function private.claim_emails(p_limit integer default 50)
returns table (id uuid, user_id uuid, email text, template text, payload jsonb)
language sql security definer set search_path = '' as $$
  with fila as (
    select o.id from private.email_outbox o
     where o.sent_at is null and o.attempts < 5
     order by o.created_at
     limit least(greatest(p_limit, 1), 500)
     for update skip locked)
  update private.email_outbox o set attempts = o.attempts + 1
    from fila where o.id = fila.id
  returning o.id, o.user_id, (select u.email from auth.users u where u.id = o.user_id)::text, o.template, o.payload
$$;

create or replace function private.finish_email(p_id uuid, p_error text default null) returns void
language sql security definer set search_path = '' as $$
  update private.email_outbox set sent_at = case when p_error is null then now() end, last_error = p_error
   where id = p_id
$$;

-- ------------------------------------------------------------------ limpeza do Storage
create or replace function private.claim_storage_purges(p_limit integer default 20)
returns table (user_id uuid, reason text)
language sql security definer set search_path = '' as $$
  with fila as (
    select q.user_id from private.storage_purge_queue q
     where q.done_at is null and q.attempts < 10
     order by q.requested_at
     limit least(greatest(p_limit, 1), 200)
     for update skip locked)
  update private.storage_purge_queue q set attempts = q.attempts + 1
    from fila where q.user_id = fila.user_id
  returning q.user_id, q.reason
$$;

create or replace function private.finish_storage_purge(p_user uuid, p_error text default null) returns void
language sql security definer set search_path = '' as $$
  update private.storage_purge_queue set done_at = case when p_error is null then now() end, last_error = p_error
   where user_id = p_user
$$;

-- ------------------------------------------------------------------ push
-- Notificações ainda sem push (últimas 24 h). Agrupamento: no máximo 1 push por pessoa e clube a
-- cada 10 min — as demais do mesmo clube são marcadas como enviadas sem push (o app mostra todas
-- na lista). Marca antes de enviar (no máximo uma tentativa por notificação).
create or replace function private.claim_pushes(p_limit integer default 200)
returns table (notification_id uuid, user_id uuid, type text, actor_handle text, club_name text,
               payload jsonb, tokens text[])
language plpgsql security definer set search_path = '' as $$
#variable_conflict use_column
begin
  return query
  with travadas as (
    select n.id from public.notifications n
     where n.push_sent_at is null and n.created_at > now() - interval '24 hours'
     order by n.created_at
     limit least(greatest(p_limit, 1), 1000)
     for update skip locked),
  fila as (
    select n.id, n.user_id, n.club_id,
           row_number() over (partition by n.user_id, n.club_id order by n.created_at) as ordem
      from public.notifications n join travadas t on t.id = n.id),
  decisao as (
    select f.id, f.user_id,
           f.club_id is null or (f.ordem = 1 and not exists (
             select 1 from public.notifications x
              where x.user_id = f.user_id and x.club_id = f.club_id and x.id <> f.id
                and x.push_sent_at > now() - interval '10 minutes' and coalesce(x.payload ->> 'push', 'sent') = 'sent'))
             as enviar
      from fila f),
  marcadas as (
    update public.notifications n
       set push_sent_at = now(),
           payload = case when d.enviar then n.payload else n.payload || '{"push": "grouped"}'::jsonb end
      from decisao d where n.id = d.id
    returning n.id, n.user_id, n.type, n.actor_id, n.club_id, n.payload, d.enviar)
  select m.id, m.user_id, m.type, (select p.handle from public.profiles p where p.id = m.actor_id),
         (select c.name from public.clubs c where c.id = m.club_id), m.payload,
         array(select t.token from public.device_tokens t where t.user_id = m.user_id order by t.updated_at desc)
    from marcadas m
   where m.enviar;
end $$;

create or replace function private.drop_device_token(p_token text) returns void
language sql security definer set search_path = '' as $$
  delete from public.device_tokens where token = p_token
$$;

-- ------------------------------------------------------------------ exportação (LGPD — D-24)
-- Tudo o que o SERVIDOR guarda sobre quem chama (o que fica só no aparelho o app exporta à parte).
-- Até 3 exportações por dia.
create or replace function public.export_my_data() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid()); v_out jsonb;
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.consume_quota(v_uid, 'export_data', 3) then
    raise exception 'quota_exceeded' using errcode = 'P0001';
  end if;
  select jsonb_build_object(
    'format_version', 1,
    'generated_at', now(),
    'account', (select jsonb_build_object('id', u.id, 'email', u.email, 'created_at', u.created_at) from auth.users u where u.id = v_uid),
    'profile', (select to_jsonb(p) from public.profiles p where p.id = v_uid),
    'profile_stats', (select to_jsonb(s) - 'user_id' from public.profile_stats s where s.user_id = v_uid),
    'posts', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at) from public.posts x where x.author_id = v_uid), '[]'),
    'post_comments', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at) from public.post_comments x where x.author_id = v_uid), '[]'),
    'post_likes', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at) from public.post_likes x where x.user_id = v_uid), '[]'),
    'following', coalesce((select jsonb_agg(jsonb_build_object('followee_id', x.followee_id, 'status', x.status, 'created_at', x.created_at))
                            from public.follows x where x.follower_id = v_uid), '[]'),
    'followers', coalesce((select jsonb_agg(jsonb_build_object('follower_id', x.follower_id, 'status', x.status, 'created_at', x.created_at))
                            from public.follows x where x.followee_id = v_uid), '[]'),
    'blocks', coalesce((select jsonb_agg(jsonb_build_object('blocked_id', x.blocked_id, 'created_at', x.created_at))
                         from public.user_blocks x where x.blocker_id = v_uid), '[]'),
    'clubs_owned', coalesce((select jsonb_agg(to_jsonb(x)) from public.clubs x where x.owner_id = v_uid), '[]'),
    'club_memberships', coalesce((select jsonb_agg(to_jsonb(x) - 'user_id') from public.club_members x where x.user_id = v_uid), '[]'),
    'club_posts', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at) from public.club_posts x where x.author_id = v_uid), '[]'),
    'club_post_replies', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at) from public.club_post_replies x where x.author_id = v_uid), '[]'),
    'notifications', coalesce((select jsonb_agg(to_jsonb(x) - 'user_id' order by x.created_at) from public.notifications x where x.user_id = v_uid), '[]'),
    'devices', coalesce((select jsonb_agg(jsonb_build_object('platform', x.platform, 'app_version', x.app_version, 'updated_at', x.updated_at))
                          from public.device_tokens x where x.user_id = v_uid), '[]'),
    'reports_made', coalesce((select jsonb_agg(jsonb_build_object('target_type', x.target_type, 'target_id', x.target_id, 'reason', x.reason,
                               'details', x.details, 'status', x.status, 'created_at', x.created_at))
                               from public.content_reports x where x.reporter_id = v_uid), '[]'),
    'subscriptions', coalesce((select jsonb_agg(to_jsonb(x) - 'user_id') from billing.subscriptions x where x.user_id = v_uid), '[]'),
    'entitlements', coalesce((select jsonb_agg(to_jsonb(x) - 'user_id') from billing.entitlements x where x.user_id = v_uid), '[]'),
    'personal', jsonb_build_object(
      'user_books', coalesce((select jsonb_agg(to_jsonb(x)) from personal.user_books x where x.user_id = v_uid), '[]'),
      'reading_positions', coalesce((select jsonb_agg(to_jsonb(x)) from personal.reading_positions x where x.user_id = v_uid), '[]'),
      'reading_sessions', coalesce((select jsonb_agg(to_jsonb(x)) from personal.reading_sessions x where x.user_id = v_uid), '[]'),
      'bookmarks', coalesce((select jsonb_agg(to_jsonb(x)) from personal.bookmarks x where x.user_id = v_uid), '[]'),
      'ink_layers', coalesce((select jsonb_agg(to_jsonb(x)) from personal.ink_layers x where x.user_id = v_uid), '[]'),
      'annotations', coalesce((select jsonb_agg(to_jsonb(x)) from personal.annotations x where x.user_id = v_uid), '[]'),
      'highlight_labels', coalesce((select jsonb_agg(to_jsonb(x)) from personal.highlight_labels x where x.user_id = v_uid), '[]'),
      'reader_settings', coalesce((select jsonb_agg(to_jsonb(x)) from personal.reader_settings x where x.user_id = v_uid), '[]'),
      'pen_presets', coalesce((select jsonb_agg(to_jsonb(x)) from personal.pen_presets x where x.user_id = v_uid), '[]'),
      'reading_goals', coalesce((select jsonb_agg(to_jsonb(x)) from personal.reading_goals x where x.user_id = v_uid), '[]')))
  into v_out;
  return v_out;
end $$;

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
revoke execute on function private.rc_begin_event(jsonb), private.rc_finish_event(text, text),
  private.rc_apply_subscriber(uuid, jsonb, timestamptz), public.entitlement_of(uuid),
  private.ebook_upload_slot(uuid, uuid, text, bigint), private.claim_emails(integer), private.finish_email(uuid, text),
  private.claim_storage_purges(integer), private.finish_storage_purge(uuid, text), private.claim_pushes(integer),
  private.drop_device_token(text), public.export_my_data() from public, anon, authenticated;
grant execute on function public.export_my_data() to authenticated;
grant execute on function private.rc_begin_event(jsonb), private.rc_finish_event(text, text),
  private.rc_apply_subscriber(uuid, jsonb, timestamptz), public.entitlement_of(uuid),
  private.ebook_upload_slot(uuid, uuid, text, bigint), private.claim_emails(integer), private.finish_email(uuid, text),
  private.claim_storage_purges(integer), private.finish_storage_purge(uuid, text), private.claim_pushes(integer),
  private.drop_device_token(text), public.export_my_data() to service_role;

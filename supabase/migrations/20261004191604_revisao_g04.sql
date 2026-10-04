-- =====================================================================================
-- BookNest · migration 15 — correções da revisão independente da G04 (RELATORIO_G04.md).
-- Cada bloco cita o achado; os testes estão em supabase/tests/database/13_revisao_g04.test.sql.
--   #1  moderação que o autor desfazia · ocultar perfil incompleto
--   #2  transferência de compra no RevenueCat · chave de assinatura que colidia entre usuários
--   #3  seguidor alternando pendente/aceito · notificações repetidas em laço
--   #4  cadastro derrubado por termo proibido no e-mail
--   #5  cota de 2 GiB burlável com o tamanho informado pelo cliente
--   #6  purge sem o aviso de 30 dias ENTREGUE
--   #8  limpeza do Storage de quem voltou a ser Pro · #9 partições sem RLS/privilégios
--   #10 estado do RevenueCat buscado antes sobrescrevendo o mais novo
--   #11 agrupamento de push engolindo o lembrete de encontro · #12 token de push preso à conta
--   #13 código de convite escolhido pelo cliente; bloqueado entrando no clube
--   #14 pedidos pendentes visíveis a terceiros · #15 payload do webhook guardado demais
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- #1 Moderação: "ocultar" marca moderated_at (coluna só do servidor) e o autor não edita nem
-- restaura conteúdo moderado. Só a equipe (service_role/postgres, por moderate_report) mexe.
-- -------------------------------------------------------------------------------------
alter table public.posts             add column moderated_at timestamptz;
alter table public.post_comments     add column moderated_at timestamptz;
alter table public.club_posts        add column moderated_at timestamptz;
alter table public.club_post_replies add column moderated_at timestamptz;

-- SECURITY INVOKER de propósito: current_user é quem fez o UPDATE (o app = authenticated; a
-- moderação e a exclusão de conta rodam como o dono das funções).
create or replace function private.moderation_guard() returns trigger
language plpgsql set search_path = '' as $$
begin
  if old.moderated_at is not null and current_user in ('authenticated', 'anon') then
    raise exception 'content_moderated' using errcode = 'P0001',
      hint = 'Conteúdo ocultado pela moderação não pode ser editado nem restaurado.';
  end if;
  return new;
end $$;
create trigger posts_moderation_guard before update on public.posts
  for each row execute function private.moderation_guard();
create trigger post_comments_moderation_guard before update on public.post_comments
  for each row execute function private.moderation_guard();
create trigger club_posts_moderation_guard before update on public.club_posts
  for each row execute function private.moderation_guard();
create trigger club_post_replies_moderation_guard before update on public.club_post_replies
  for each row execute function private.moderation_guard();

-- Ocultar perfil: nome volta a "Leitor" e o @ ao provisório (além de bio e foto). Como o nome novo
-- passa no filtro de termos, a moderação não falha mais quando o nome ATUAL tem um termo proibido.
create or replace function private.moderate_report(p_report uuid, p_decision text, p_moderator text,
  p_note text default null) returns void
language plpgsql security definer set search_path = '' as $$
declare r public.content_reports; v_hex text; v_handle text;
begin
  if p_decision not in ('hide', 'dismiss') then
    raise exception 'invalid_decision' using errcode = '22023';
  end if;
  select * into r from public.content_reports where id = p_report for update;
  if r.id is null or r.status <> 'open' then
    raise exception 'report_not_open' using errcode = 'P0001';
  end if;
  if p_decision = 'dismiss' then
    update public.content_reports set status = 'dismissed', resolved_at = now(), resolved_by = p_moderator,
           resolution_note = p_note where id = p_report;
    return;
  end if;
  case r.target_type
    when 'post' then
      update public.posts set deleted_at = coalesce(deleted_at, now()), moderated_at = now() where id = r.target_id;
    when 'post_comment' then
      update public.post_comments set deleted_at = coalesce(deleted_at, now()), moderated_at = now() where id = r.target_id;
    when 'club_post' then
      update public.club_posts set deleted_at = coalesce(deleted_at, now()), moderated_at = now() where id = r.target_id;
    when 'club_post_reply' then
      update public.club_post_replies set deleted_at = coalesce(deleted_at, now()), moderated_at = now() where id = r.target_id;
    when 'profile' then
      v_hex := replace(r.target_id::text, '-', '');
      v_handle := 'leitor_' || right(v_hex, 12);
      if exists (select 1 from public.profiles p where p.handle = v_handle and p.id <> r.target_id) then
        v_handle := 'leitor_' || right(v_hex, 23);        -- o curto foi tomado por outra conta
      end if;
      update public.profiles set display_name = 'Leitor', handle = v_handle, bio = null, avatar_path = null
       where id = r.target_id;
    else null;   -- 'club': decisão manual da equipe (sem ação automática)
  end case;
  update public.content_reports set status = 'actioned', resolved_at = now(), resolved_by = p_moderator,
         resolution_note = p_note
   where target_type = r.target_type and target_id = r.target_id and status = 'open';
end $$;

-- O filtro de termos do perfil passa a olhar também o @ ("caio.feio" → "caio feio").
create or replace function private.reject_blocked_terms() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v jsonb := to_jsonb(new); v_texto text;
begin
  -- (to_jsonb: a mesma função serve a tabelas com colunas diferentes)
  v_texto := case tg_table_name
    when 'profiles' then concat_ws(' ', v ->> 'display_name', v ->> 'bio', translate(v ->> 'handle', '_.', '  '))
    when 'clubs'    then v ->> 'name'
    else v ->> 'body'                                -- quote_text é trecho do livro: não filtra
  end;
  if private.has_blocked_term(v_texto) then
    raise exception 'content_blocked' using errcode = 'P0001',
      hint = 'O texto tem um termo que não é permitido nas regras da comunidade.';
  end if;
  return new;
end $$;
drop trigger profiles_blocked_terms on public.profiles;
create trigger profiles_blocked_terms before insert or update of display_name, bio, handle on public.profiles
  for each row execute function private.reject_blocked_terms();

-- -------------------------------------------------------------------------------------
-- #4 Cadastro: nome provisório com termo proibido vira "Leitor" (antes o gatilho do Auth falhava
-- com content_blocked e o GoTrue respondia "Database error saving new user").
-- -------------------------------------------------------------------------------------
create or replace function private.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_nome text;
begin
  -- nome provisório = parte local do e-mail, cortada em 60 (CHECK do display_name); sem e-mail
  -- (telefone, Apple sem e-mail), vazio ou com termo proibido → "Leitor"
  v_nome := coalesce(nullif(left(split_part(coalesce(new.email, ''), '@', 1), 60), ''), 'Leitor');
  if private.has_blocked_term(v_nome) then v_nome := 'Leitor'; end if;
  insert into public.profiles (id, handle, display_name)
  values (new.id,
          'leitor_' || right(replace(new.id::text, '-', ''), 12),   -- parte aleatória do uuid; o app pede o @ no onboarding
          v_nome);
  insert into public.profile_stats (user_id) values (new.id);
  return new;
end $$;

-- -------------------------------------------------------------------------------------
-- #3 Seguidores: o dono do perfil só ACEITA (pendente → aceito); #14 a lista de alguém mostra a
-- terceiros só os aceitos (pedido pendente para conta fechada é assunto das duas pessoas).
-- -------------------------------------------------------------------------------------
drop policy follows_accept on public.follows;
create policy follows_accept on public.follows for update to authenticated
  using (followee_id = (select auth.uid()) and status = 'pending')
  with check (followee_id = (select auth.uid()) and status = 'accepted');
drop policy follows_read on public.follows;
create policy follows_read on public.follows for select to authenticated
  using (follower_id = (select auth.uid()) or followee_id = (select auth.uid())
         or (status = 'accepted'
             and (private.can_view_profile_content(follower_id)        -- lista "seguindo" de alguém
                  or private.can_view_profile_content(followee_id))));  -- lista "seguidores" de alguém

-- Notificações que um laço (curtir/descurtir, pedir/desfazer) repetiria: no máximo 1 por dia
-- para a mesma pessoa, tipo, autor e post.
create or replace function private.notify(p_user uuid, p_type text, p_actor uuid default null,
  p_club uuid default null, p_post uuid default null, p_payload jsonb default '{}'::jsonb) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if p_user is null or p_user = p_actor then return; end if;
  if p_actor is not null and private.is_blocked_between(p_user, p_actor) then return; end if;
  if p_type in ('follow', 'follow_request', 'post_like') and exists (
       select 1 from public.notifications n
        where n.user_id = p_user and n.type = p_type and n.actor_id is not distinct from p_actor
          and n.post_id is not distinct from p_post and n.created_at > now() - interval '24 hours') then
    return;
  end if;
  insert into public.notifications (user_id, type, actor_id, club_id, post_id, payload)
  values (p_user, p_type, p_actor, p_club, p_post, coalesce(p_payload, '{}'::jsonb));
end $$;

-- -------------------------------------------------------------------------------------
-- #12 Aparelho: o token de push é de quem está no aparelho AGORA (troca de conta no mesmo
-- aparelho). Só pela RPC — o upsert direto falhava pela RLS (a linha era da conta anterior).
-- -------------------------------------------------------------------------------------
create or replace function public.register_device_token(p_token text, p_platform text, p_app_version text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid());
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if coalesce(char_length(p_token), 0) not between 1 and 4096 or coalesce(p_platform, '') not in ('android', 'ios')
     or char_length(coalesce(p_app_version, '')) > 50 then
    raise exception 'invalid_device' using errcode = '22023';
  end if;
  insert into public.device_tokens as t (token, user_id, platform, app_version, updated_at)
  values (p_token, v_uid, p_platform, p_app_version, now())
  on conflict (token) do update set user_id = excluded.user_id, platform = excluded.platform,
    app_version = excluded.app_version, updated_at = now();
end $$;

-- -------------------------------------------------------------------------------------
-- #13 Convites: o código é gerado pelo servidor (12 caracteres aleatórios, ~71 bits); quem foi
-- bloqueado pelo dono do clube não entra (nem por convite nem em clube público).
-- -------------------------------------------------------------------------------------
create or replace function private.new_invite_code() returns text
language sql volatile set search_path = '' as $$
  select string_agg(substr('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', get_byte(x.b, i) % 62 + 1, 1), '' order by i)
    from (select extensions.gen_random_bytes(12) as b) x, generate_series(0, 11) i
$$;
create or replace function private.club_invites_code() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.code is null then new.code := private.new_invite_code(); end if;   -- o cliente não tem GRANT em code
  return new;
end $$;
create trigger club_invites_code before insert on public.club_invites
  for each row execute function private.club_invites_code();

create or replace function public.join_club(p_code text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_club uuid; v_owner uuid; v_uid uuid := (select auth.uid());
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select i.club_id, c.owner_id into v_club, v_owner
    from public.club_invites i join public.clubs c on c.id = i.club_id
   where i.code = p_code and i.expires_at > now() and i.uses < i.max_uses
     for update of i;
  if v_club is null then raise exception 'invalid_invite' using errcode = 'P0001'; end if;
  if private.is_blocked_between(v_owner, v_uid) then raise exception 'blocked' using errcode = 'P0001'; end if;
  update public.club_invites set uses = uses + 1 where code = p_code;
  insert into public.club_members (club_id, user_id) values (v_club, v_uid)
  on conflict do nothing;
  return v_club;
end $$;

create or replace function public.join_public_club(p_club uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare v_uid uuid := (select auth.uid()); v_owner uuid;
begin
  if v_uid is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select c.owner_id into v_owner from public.clubs c where c.id = p_club and c.privacy = 'public';
  if v_owner is null then
    raise exception 'club_not_public' using errcode = 'P0001';
  end if;
  if private.is_blocked_between(v_owner, v_uid) then raise exception 'blocked' using errcode = 'P0001'; end if;
  insert into public.club_members (club_id, user_id) values (p_club, v_uid) on conflict do nothing;
end $$;

-- -------------------------------------------------------------------------------------
-- #2 / #10 RevenueCat
--  * a chave da cadeia SEM id da loja ("produto@data da compra original" — API v1) é por usuário:
--    duas pessoas comprando o mesmo produto no mesmo segundo não disputam a mesma linha;
--  * o id de verdade da loja (Play "GPA.…") continua único no banco: se a compra for restaurada
--    em outra conta, a linha muda de dono e o dono anterior é recalculado NA HORA;
--  * o estado do RevenueCat é a verdade: assinatura que sumiu dele (transferida) sai do banco;
--  * p_fetched_at = quando a Edge Function buscou o estado: um estado buscado antes do último já
--    aplicado (webhooks do mesmo usuário em paralelo) é ignorado.
-- -------------------------------------------------------------------------------------
create index webhook_events_app_user_idx on billing.webhook_events (app_user_id);   -- exclusão de conta (#15)

create table billing.rc_fetch_state (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  fetched_at  timestamptz not null
);
alter table billing.rc_fetch_state enable row level security;   -- sem política: só service_role

create or replace function private.rc_recompute_entitlement(p_user uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare v_until timestamptz; v_env text; v_source uuid;
begin
  select greatest(x.current_period_ends_at, coalesce(x.grace_period_ends_at, x.current_period_ends_at)),
         x.environment, x.id
    into v_until, v_env, v_source
    from billing.subscriptions x
   where x.user_id = p_user and x.entitlement = 'pro' and x.status <> 'refunded'
   order by 1 desc limit 1;

  if v_until is null then
    -- sem assinatura válida (reembolso, transferência): o Pro termina agora
    update billing.entitlements set active_until = least(active_until, now()), updated_at = now()
     where user_id = p_user and entitlement = 'pro';
  else
    insert into billing.entitlements as e (user_id, entitlement, active_until, environment, source_subscription_id, updated_at)
    values (p_user, 'pro', v_until, v_env, v_source, now())
    on conflict (user_id, entitlement) do update set active_until = excluded.active_until,
      environment = excluded.environment, source_subscription_id = excluded.source_subscription_id, updated_at = now();
  end if;

  -- acesso ao sync na hora (o refresh_sync_access de 15 em 15 min cobre o resto)
  insert into billing.sync_access as a (user_id, granted, updated_at)
  select e.user_id, e.active_until + interval '7 days' > now(), now()
    from billing.entitlements e where e.user_id = p_user and e.entitlement = 'pro'
  on conflict (user_id) do update set granted = excluded.granted, updated_at = now();
end $$;

drop function private.rc_apply_subscriber(uuid, jsonb, timestamptz);
create or replace function private.rc_apply_subscriber(p_user uuid, p_subs jsonb, p_event_at timestamptz default now(),
  p_fetched_at timestamptz default null)
returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_last timestamptz; v_prev uuid[]; v_keys text[]; v_u uuid;
begin
  if jsonb_typeof(p_subs) <> 'array' then raise exception 'invalid_subscriptions' using errcode = '22023'; end if;
  if not exists (select 1 from auth.users u where u.id = p_user) then
    raise exception 'unknown_user' using errcode = 'P0001';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('rc_user:' || p_user::text, 0));
  if p_fetched_at is not null then
    select f.fetched_at into v_last from billing.rc_fetch_state f where f.user_id = p_user;
    if v_last is not null and p_fetched_at < v_last then
      return public.entitlement_of(p_user) || '{"stale": true}'::jsonb;
    end if;
    insert into billing.rc_fetch_state as f (user_id, fetched_at) values (p_user, p_fetched_at)
    on conflict (user_id) do update set fetched_at = excluded.fetched_at;
  end if;

  -- chave de cada assinatura do estado atual (store + id; sem id da loja → por usuário)
  select coalesce(array_agg((s ->> 'store') || '|' || k.chave), '{}') into v_keys
    from jsonb_array_elements(p_subs) s
   cross join lateral (select case when s ->> 'original_transaction_id' like '%@%'
                                   then (s ->> 'original_transaction_id') || '#' || p_user::text
                                   else s ->> 'original_transaction_id' end as chave) k;

  -- donos anteriores das compras que mudam de conta (recalculados no fim)
  select coalesce(array_agg(distinct t.user_id), '{}') into v_prev
    from billing.subscriptions t
   where t.user_id <> p_user and (t.store || '|' || t.original_transaction_id) = any (v_keys);

  insert into billing.subscriptions as t (user_id, store, product_id, period_type, status, will_renew,
    current_period_starts_at, current_period_ends_at, grace_period_ends_at, original_transaction_id,
    environment, last_event_at, updated_at)
  select p_user, s ->> 'store', s ->> 'product_id', s ->> 'period_type', s ->> 'status',
    (s ->> 'will_renew')::boolean, (s ->> 'starts_at')::timestamptz, (s ->> 'ends_at')::timestamptz,
    (s ->> 'grace_ends_at')::timestamptz,
    case when s ->> 'original_transaction_id' like '%@%'
         then (s ->> 'original_transaction_id') || '#' || p_user::text else s ->> 'original_transaction_id' end,
    s ->> 'environment', p_event_at, now()
    from jsonb_array_elements(p_subs) s
  on conflict (store, original_transaction_id) do update set
    user_id = excluded.user_id, product_id = excluded.product_id, period_type = excluded.period_type,
    status = excluded.status, will_renew = excluded.will_renew,
    current_period_starts_at = excluded.current_period_starts_at,
    current_period_ends_at = excluded.current_period_ends_at,
    grace_period_ends_at = excluded.grace_period_ends_at, environment = excluded.environment,
    last_event_at = greatest(t.last_event_at, excluded.last_event_at), updated_at = now();

  -- o que não está mais no estado do RevenueCat (transferido para outra conta) sai
  delete from billing.subscriptions t
   where t.user_id = p_user and not ((t.store || '|' || t.original_transaction_id) = any (v_keys));

  perform private.rc_recompute_entitlement(p_user);
  foreach v_u in array v_prev loop
    perform private.rc_recompute_entitlement(v_u);
  end loop;
  return public.entitlement_of(p_user);
end $$;

-- #15 o evento guarda o mínimo (sem atributos do assinante — e-mail, nome, aparelho — nem apelidos)
create or replace function private.rc_begin_event(p_event jsonb) returns text
language plpgsql security definer set search_path = '' as $$
declare v_id text := p_event ->> 'id'; v_processed timestamptz; v_inserted boolean;
begin
  if v_id is null or v_id = '' then raise exception 'event_without_id' using errcode = '22023'; end if;
  insert into billing.webhook_events (event_id, event_type, app_user_id, payload)
  values (v_id, coalesce(p_event ->> 'type', 'UNKNOWN'), p_event ->> 'app_user_id',
          p_event - 'subscriber_attributes' - 'aliases' - 'original_app_user_id')
  on conflict (event_id) do nothing
  returning true into v_inserted;
  if v_inserted then return 'new'; end if;
  select processed_at into v_processed from billing.webhook_events where event_id = v_id;
  return case when v_processed is null then 'retry' else 'done' end;
end $$;

-- Conta excluída → e-books na fila do Storage e eventos do webhook apagados (LGPD)
create or replace function private.on_auth_user_deleted() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  perform private.queue_storage_purge(old.id, 'account_deleted');
  delete from billing.webhook_events w
   where w.app_user_id = old.id::text
      or coalesce(w.payload -> 'transferred_from', '[]'::jsonb) ? old.id::text
      or coalesce(w.payload -> 'transferred_to', '[]'::jsonb) ? old.id::text;
  return old;
end $$;

-- -------------------------------------------------------------------------------------
-- #5 Cota de e-books: a URL assinada vale 2 h e aceita até o limite do bucket (200 MiB) qualquer
-- que seja o tamanho informado. Cada reserva ativa conta 200 MiB; perto do limite, UM último
-- upload por vez vale pelo tamanho informado (o excesso possível fica em 200 MiB).
-- -------------------------------------------------------------------------------------
create table private.ebook_upload_reservations (
  path        text primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  bytes       bigint not null check (bytes > 0),
  last_slot   boolean not null default false,
  expires_at  timestamptz not null
);
create index ebook_upload_reservations_user_idx on private.ebook_upload_reservations (user_id, expires_at);
alter table private.ebook_upload_reservations enable row level security;   -- sem política: só service_role

create or replace function private.ebook_upload_slot(p_user uuid, p_user_book uuid, p_sha256 text, p_bytes bigint)
returns text
language plpgsql security definer set search_path = '' as $$
declare
  c_quota constant bigint := 2147483648;     -- 2 GiB por pessoa
  c_max   constant bigint := 209715200;      -- 200 MiB (file_size_limit do bucket "ebooks")
  v_book personal.user_books; v_used bigint; v_reserved bigint; v_others integer; v_path text; v_last boolean;
begin
  if not private.can_sync(p_user) then raise exception 'pro_required' using errcode = 'P0001'; end if;
  if p_sha256 !~ '^[0-9a-f]{64}$' or p_bytes is null or p_bytes <= 0 or p_bytes > c_max then
    raise exception 'invalid_file' using errcode = '22023';
  end if;
  select * into v_book from personal.user_books b where b.id = p_user_book and b.user_id = p_user and b.deleted_at is null;
  if v_book.id is null or v_book.format not in ('epub', 'pdf') then
    raise exception 'book_not_found' using errcode = 'P0001';
  end if;
  if v_book.content_sha256 is distinct from p_sha256 then
    raise exception 'sha_mismatch' using errcode = 'P0001';
  end if;
  v_path := format('%s/%s/%s.%s', p_user, p_user_book, p_sha256, v_book.format);

  perform pg_advisory_xact_lock(hashtextextended('ebook_quota:' || p_user::text, 0));
  delete from private.ebook_upload_reservations r
   where r.user_id = p_user and (r.expires_at <= now() or r.path = v_path);
  select count(*)::integer, coalesce(sum(case when r.last_slot then r.bytes else c_max end), 0)
    into v_others, v_reserved
    from private.ebook_upload_reservations r where r.user_id = p_user;
  -- no Storage: tudo da pessoa, menos o próprio caminho e os caminhos com reserva ativa (já contados)
  select coalesce(sum((o.metadata ->> 'size')::bigint), 0) into v_used
    from storage.objects o
   where o.bucket_id = 'ebooks' and o.name like p_user::text || '/%' and o.name <> v_path
     and not exists (select 1 from private.ebook_upload_reservations r where r.path = o.name);

  if v_used + v_reserved + c_max <= c_quota then
    v_last := false;
  elsif v_others = 0 and v_used + p_bytes <= c_quota then
    v_last := true;
  else
    raise exception 'quota_exceeded' using errcode = 'P0001',
      hint = format('usado %s + reservado %s de %s bytes', v_used, v_reserved, c_quota);
  end if;
  insert into private.ebook_upload_reservations (path, user_id, bytes, last_slot, expires_at)
  values (v_path, p_user, p_bytes, v_last, now() + interval '2 hours 5 minutes');
  return v_path;
end $$;

-- -------------------------------------------------------------------------------------
-- #6 Retenção: o prazo de 30 dias conta do aviso ENTREGUE — e-mail enviado (finish_email) ou, sem
-- e-mail (Apple/telefone) ou com o e-mail falhando 5 vezes, a notificação no app (+ push). Sem o
-- provedor de e-mail configurado o purge fica parado (seguro: nada é apagado sem aviso).
-- -------------------------------------------------------------------------------------
alter table private.account_lifecycle add column warning_queued_at timestamptz;

create or replace function private.run_retention() returns void
language plpgsql security definer set search_path = '' as $$
declare v_due uuid[];
begin
  -- 1. quem perdeu o Pro entra no ciclo
  insert into private.account_lifecycle (user_id, pro_ended_at, purge_after)
  select e.user_id, e.active_until, e.active_until + interval '12 months'
    from billing.entitlements e
   where e.entitlement = 'pro' and e.active_until <= now()
  on conflict (user_id) do update
     set pro_ended_at = excluded.pro_ended_at, purge_after = excluded.purge_after,
         warning_queued_at = null, warning_sent_at = null, purged_at = null
   where private.account_lifecycle.pro_ended_at is distinct from excluded.pro_ended_at;

  -- 2. quem voltou a ser Pro sai do ciclo (e o aviso que ainda não saiu também)
  delete from private.account_lifecycle l where private.user_is_pro(l.user_id);
  delete from private.email_outbox o
   where o.template = 'retention_warning' and o.sent_at is null and private.user_is_pro(o.user_id);

  -- 3a. aviso devido (30 dias antes do purge previsto): e-mail, se houver endereço, e notificação
  insert into private.email_outbox (user_id, template, payload)
  select l.user_id, 'retention_warning',
         jsonb_build_object('purge_after', greatest(l.purge_after, now() + interval '30 days'))
    from private.account_lifecycle l join auth.users u on u.id = l.user_id
   where l.purged_at is null and l.warning_queued_at is null and l.purge_after <= now() + interval '30 days'
     and nullif(u.email, '') is not null;
  perform private.notify(l.user_id, 'retention_warning', null, null, null,
            jsonb_build_object('purge_after', greatest(l.purge_after, now() + interval '30 days')))
     from private.account_lifecycle l
    where l.purged_at is null and l.warning_queued_at is null and l.purge_after <= now() + interval '30 days';
  update private.account_lifecycle l
     set warning_queued_at = now(),
         warning_sent_at = case when nullif(u.email, '') is null then now() end   -- sem e-mail: o aviso é o do app
    from auth.users u
   where u.id = l.user_id and l.purged_at is null and l.warning_queued_at is null
     and l.purge_after <= now() + interval '30 days';

  -- 3b. e-mail que desistiu (5 tentativas): vale a notificação, com 30 dias a partir de agora
  update private.account_lifecycle l set warning_sent_at = now()
   where l.purged_at is null and l.warning_sent_at is null and l.warning_queued_at is not null
     and exists (select 1 from private.email_outbox o
                  where o.user_id = l.user_id and o.template = 'retention_warning'
                    and o.sent_at is null and o.attempts >= 5);

  -- 4. purge: vencido E avisado há ≥ 30 dias. user_books leva junto (ON DELETE CASCADE)
  --    posições, sessões, marcadores, camadas de tinta e anotações; os e-books vão para a fila
  --    do Storage.
  select coalesce(array_agg(user_id), '{}') into v_due
    from private.account_lifecycle
   where purged_at is null and purge_after <= now()
     and warning_sent_at is not null and warning_sent_at <= now() - interval '30 days';
  if cardinality(v_due) = 0 then return; end if;

  delete from personal.user_books       where user_id = any (v_due);
  delete from personal.highlight_labels where user_id = any (v_due);
  delete from personal.reader_settings  where user_id = any (v_due);
  delete from personal.pen_presets      where user_id = any (v_due);
  delete from personal.reading_goals    where user_id = any (v_due);

  insert into private.email_outbox (user_id, template) select u, 'retention_purged' from unnest(v_due) u;
  perform private.queue_storage_purge(u, 'retention') from unnest(v_due) u;
  update private.account_lifecycle set purged_at = now() where user_id = any (v_due);
end $$;

-- e-mail entregue → aviso de retenção dado
create or replace function private.finish_email(p_id uuid, p_error text default null) returns void
language sql security definer set search_path = '' as $$
  with e as (
    update private.email_outbox set sent_at = case when p_error is null then now() end, last_error = p_error
     where id = p_id
    returning user_id, template, sent_at)
  update private.account_lifecycle l set warning_sent_at = coalesce(l.warning_sent_at, e.sent_at)
    from e
   where e.template = 'retention_warning' and e.sent_at is not null and l.user_id = e.user_id and l.purged_at is null
$$;

-- não envia aviso de retenção a quem voltou a ser Pro (a rotina diária ainda não passou)
create or replace function private.claim_emails(p_limit integer default 50)
returns table (id uuid, user_id uuid, email text, template text, payload jsonb)
language sql security definer set search_path = '' as $$
  with fila as (
    select o.id from private.email_outbox o
     where o.sent_at is null and o.attempts < 5
       and not (o.template = 'retention_warning' and private.user_is_pro(o.user_id))
     order by o.created_at
     limit least(greatest(p_limit, 1), 500)
     for update skip locked)
  update private.email_outbox o set attempts = o.attempts + 1
    from fila where o.id = fila.id
  returning o.id, o.user_id, (select u.email from auth.users u where u.id = o.user_id)::text, o.template, o.payload
$$;

-- #8 limpeza do Storage pela retenção de quem voltou a ser Pro: descartada (o app reenvia os
-- e-books na volta e eles ficariam apontando para arquivos apagados)
create or replace function private.claim_storage_purges(p_limit integer default 20)
returns table (user_id uuid, reason text)
language sql security definer set search_path = '' as $$
  delete from private.storage_purge_queue q
   where q.done_at is null and q.reason = 'retention' and private.user_is_pro(q.user_id);
  with fila as (
    select q.user_id from private.storage_purge_queue q
     where q.done_at is null and q.attempts < 10
     order by q.requested_at
     limit least(greatest(p_limit, 1), 200)
     for update skip locked)
  update private.storage_purge_queue q set attempts = q.attempts + 1
    from fila where q.user_id = fila.user_id
  returning q.user_id, q.reason;
$$;

-- -------------------------------------------------------------------------------------
-- #9 Partições das sessões: RLS ligada (sem política: acesso direto só do service_role) e
-- privilégios explícitos — partição NÃO herda RLS nem GRANT da tabela particionada.
-- (G06: o papel próprio do PowerSync, se houver, entra aqui com SELECT.)
-- -------------------------------------------------------------------------------------
create or replace function private.secure_session_partition(p_name text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  execute format('alter table personal.%I enable row level security', p_name);
  execute format('revoke all on personal.%I from public, anon, authenticated', p_name);
  execute format('grant all on personal.%I to service_role', p_name);
end $$;

create or replace function private.ensure_session_partition_for(p_ts timestamptz)
returns void language plpgsql security definer set search_path = '' as $$
declare v_start date := date_trunc('month', p_ts)::date; v_name text;
begin
  if v_start < date '2026-01-01' then return; end if;            -- 2024–2025: partição histórica
  v_name := format('reading_sessions_%s', to_char(v_start, 'YYYY_MM'));
  if to_regclass(format('personal.%I', v_name)) is null then
    perform pg_advisory_xact_lock(hashtextextended('sessions_partition:' || v_name, 0));
    if to_regclass(format('personal.%I', v_name)) is null then
      execute format('create table personal.%I partition of personal.reading_sessions
                        for values from (%L) to (%L)',
                     v_name, v_start, (v_start + interval '1 month')::date);
      perform private.secure_session_partition(v_name);
    end if;
  end if;
end $$;

create or replace function private.ensure_session_partitions(p_months_ahead integer default 3)
returns void language plpgsql security definer set search_path = '' as $$
declare v_start date := date '2026-01-01'; v_end date; v_name text;
begin
  v_end := (date_trunc('month', now()) + make_interval(months => p_months_ahead))::date;
  while v_start <= v_end loop
    v_name := format('reading_sessions_%s', to_char(v_start, 'YYYY_MM'));
    if to_regclass(format('personal.%I', v_name)) is null then
      execute format('create table personal.%I partition of personal.reading_sessions
                        for values from (%L) to (%L)',
                     v_name, v_start, (v_start + interval '1 month')::date);
      perform private.secure_session_partition(v_name);
    end if;
    v_start := (v_start + interval '1 month')::date;
  end loop;
end $$;

-- as que já existem (histórica + mensais)
select private.secure_session_partition(c.relname)
  from pg_inherits i join pg_class c on c.oid = i.inhrelid
 where i.inhparent = 'personal.reading_sessions'::regclass;

-- -------------------------------------------------------------------------------------
-- #11 Push: só respostas do clube se agrupam (1 push por clube a cada 10 min); lembrete de
-- encontro e o resto saem sempre.
-- -------------------------------------------------------------------------------------
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
    select n.id, n.user_id, n.club_id, n.type,
           row_number() over (partition by n.user_id, n.club_id, n.type order by n.created_at) as ordem
      from public.notifications n join travadas t on t.id = n.id),
  decisao as (
    select f.id, f.user_id,
           f.club_id is null or f.type <> 'club_reply' or (f.ordem = 1 and not exists (
             select 1 from public.notifications x
              where x.user_id = f.user_id and x.club_id = f.club_id and x.type = 'club_reply' and x.id <> f.id
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

-- -------------------------------------------------------------------------------------
-- Permissões
-- -------------------------------------------------------------------------------------
-- colunas novas: moderated_at e warning_queued_at não ganham GRANT (só servidor)
revoke all on billing.rc_fetch_state, private.ebook_upload_reservations from public, anon, authenticated;
grant all on billing.rc_fetch_state, private.ebook_upload_reservations to service_role;

-- #12 aparelhos só pela RPC; #13 o cliente não escolhe o código do convite
revoke insert, update on public.device_tokens from authenticated;
revoke insert on public.club_invites from authenticated;
grant insert (club_id, created_by, expires_at, max_uses) on public.club_invites to authenticated;

revoke execute on function private.moderation_guard(), private.moderate_report(uuid, text, text, text),
  private.reject_blocked_terms(), private.handle_new_user(), private.notify(uuid, text, uuid, uuid, uuid, jsonb),
  public.register_device_token(text, text, text), private.new_invite_code(), private.club_invites_code(),
  public.join_club(text), public.join_public_club(uuid), private.rc_recompute_entitlement(uuid),
  private.rc_apply_subscriber(uuid, jsonb, timestamptz, timestamptz), private.rc_begin_event(jsonb),
  private.on_auth_user_deleted(), private.ebook_upload_slot(uuid, uuid, text, bigint), private.run_retention(),
  private.finish_email(uuid, text), private.claim_emails(integer), private.claim_storage_purges(integer),
  private.secure_session_partition(text), private.ensure_session_partition_for(timestamptz),
  private.ensure_session_partitions(integer), private.claim_pushes(integer)
  from public, anon, authenticated;
grant execute on function public.register_device_token(text, text, text), public.join_club(text),
  public.join_public_club(uuid) to authenticated;
grant execute on function private.moderate_report(uuid, text, text, text), private.notify(uuid, text, uuid, uuid, uuid, jsonb),
  public.register_device_token(text, text, text), public.join_club(text), public.join_public_club(uuid),
  private.rc_recompute_entitlement(uuid), private.rc_apply_subscriber(uuid, jsonb, timestamptz, timestamptz),
  private.rc_begin_event(jsonb), private.ebook_upload_slot(uuid, uuid, text, bigint), private.run_retention(),
  private.finish_email(uuid, text), private.claim_emails(integer), private.claim_storage_purges(integer),
  private.ensure_session_partition_for(timestamptz), private.ensure_session_partitions(integer),
  private.claim_pushes(integer) to service_role;

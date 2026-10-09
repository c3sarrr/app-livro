-- =====================================================================================
-- BookNest · G21.1 — o núcleo do clube (docs/progresso/G21.md §1; D-211, D-213, D-214, D-218, D-219;
-- R4–R6, R11, R12).
-- - O livro do clube em semanas (club_readings, club_weeks). A meta do clube (goal_chapter) sai: passa a
--   ser a semana do próximo encontro.
-- - Um encontro por semana: club_meetings ganha a leitura, a semana, o fim e o modo. Presença
--   (meeting_rsvps) e recado (meeting_notes: "Só a Ana" / "O clube todo").
-- - Perguntas (club_posts 'question') na ordem da anfitriã; respostas em um nível; curtidas (club_likes);
--   a cor de cada leitora; o spoiler de cada post e resposta (D-218); a chave do trecho (D-219).
-- - As RPCs de escrita (quando a regra cruza tabelas) e os 6 resumos (uma ida por tela).
-- - O progresso e o "lido" passam a ser só pelas RPCs (publish_progress, mark_club_read).
-- =====================================================================================

-- 1. O livro do clube em semanas --------------------------------------------------------

create table public.club_readings (
  id          uuid primary key default private.uuid_generate_v7(),
  club_id     uuid not null references public.clubs(id) on delete cascade,
  work_id     uuid references catalog.works(id) on delete set null,
  edition_id  uuid references catalog.editions(id) on delete set null,
  status      text not null default 'current' check (status in ('current','next','done')),
  starts_on   date not null,
  weeks       integer not null check (weeks between 1 and 12),
  created_at  timestamptz not null default now()
);
create unique index club_readings_current_uq on public.club_readings (club_id) where status = 'current';
create index club_readings_club_idx on public.club_readings (club_id);
create index club_readings_work_idx on public.club_readings (work_id);
create index club_readings_edition_idx on public.club_readings (edition_id);

-- cap. N do clube = o N-º capítulo numerado do livro (D-214); os rótulos valem para livro sem numeração
create table public.club_weeks (
  reading_id    uuid not null references public.club_readings(id) on delete cascade,
  club_id       uuid not null references public.clubs(id) on delete cascade,   -- desnormalizado p/ RLS
  week_no       integer not null check (week_no between 1 and 12),
  from_chapter  integer not null check (from_chapter > 0),
  to_chapter    integer not null,
  from_label    text check (char_length(from_label) between 1 and 12),
  to_label      text check (char_length(to_label) between 1 and 12),
  primary key (reading_id, week_no),
  check (to_chapter >= from_chapter)
);
create index club_weeks_club_idx on public.club_weeks (club_id);

-- 2. O clube e a cor de cada leitora -------------------------------------------------------

alter table public.clubs
  drop column goal_chapter,
  drop column goal_chapter_label,
  add column category           text check (char_length(category) between 1 and 40),
  add column color              text not null default '#B6ACE4' check (color ~ '^#[0-9A-F]{6}$'),
  add column progress_colors    text not null default 'club' check (progress_colors in ('club','member')),
  add column spoiler_protection boolean not null default true,
  add column meeting_weekday    smallint check (meeting_weekday between 0 and 6),   -- 0 = domingo, como extract(dow)
  add column meeting_time       time,
  add column meeting_minutes    smallint check (meeting_minutes between 15 and 600),
  add column meeting_mode       text check (meeting_mode in ('online','presencial')),
  add column timezone           text not null default 'America/Sao_Paulo';
create trigger clubs_timezone before insert or update of timezone on public.clubs
  for each row execute function private.check_timezone();

alter table public.club_members add column color text check (color ~ '^#[0-9A-F]{6}$');

-- A cor da leitora (pranchas 04, 31 e 70): a 1ª da paleta que ninguém do clube usa; acabou a paleta,
-- recomeça pela ordem de chegada. O cliente não escolhe (sem GRANT).
create or replace function private.club_member_color() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_palette constant text[] := array['#B6ACE4','#ABCF82','#FED170','#FFC1C6','#FFFAF1','#058CD7','#F2A815'];
  v_count integer;
begin
  if new.color is not null then return new; end if;
  select u.p into new.color from unnest(v_palette) with ordinality as u(p, i)
   where not exists (select 1 from public.club_members m where m.club_id = new.club_id and m.color = u.p)
   order by u.i limit 1;
  if new.color is null then
    select count(*) into v_count from public.club_members m where m.club_id = new.club_id;
    new.color := v_palette[(v_count % array_length(v_palette, 1)) + 1];
  end if;
  return new;
end $$;
create trigger club_members_color before insert on public.club_members
  for each row execute function private.club_member_color();

-- 3. Encontros, presença e recado -----------------------------------------------------------

alter table public.club_meetings
  add column reading_id uuid,
  add column week_no    integer check (week_no between 1 and 12),
  add column ends_at    timestamptz,
  add column mode       text check (mode in ('online','presencial')),
  add constraint club_meetings_week_fk foreign key (reading_id, week_no)
    references public.club_weeks (reading_id, week_no) on delete cascade,
  add constraint club_meetings_ends_check check (ends_at is null or ends_at > starts_at);
create index club_meetings_week_idx on public.club_meetings (reading_id, week_no);

-- O encontro da semana vai até o fim dela (o lembrete que já existe continua igual) e é do mesmo clube.
create or replace function private.meeting_from_week() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.reading_id is not null then
    if not exists (select 1 from public.club_readings r where r.id = new.reading_id and r.club_id = new.club_id) then
      raise exception 'invalid_reading' using errcode = '22023';
    end if;
    select w.to_chapter into new.until_chapter from public.club_weeks w
     where w.reading_id = new.reading_id and w.week_no = new.week_no;
  end if;
  return new;
end $$;
create trigger club_meetings_from_week before insert or update of reading_id, week_no on public.club_meetings
  for each row execute function private.meeting_from_week();

create table public.meeting_rsvps (
  meeting_id  uuid not null references public.club_meetings(id) on delete cascade,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  club_id     uuid not null references public.clubs(id) on delete cascade,   -- desnormalizado p/ RLS
  answer      text not null check (answer in ('vou','talvez','nao_vou')),
  updated_at  timestamptz not null default now(),
  primary key (meeting_id, user_id)
);
create index meeting_rsvps_user_idx on public.meeting_rsvps (user_id);
create index meeting_rsvps_club_idx on public.meeting_rsvps (club_id, user_id);

-- O recado fica à parte: quem lê é diferente (o "Só a Ana" não pode vazar pela leitura das presenças).
create table public.meeting_notes (
  meeting_id  uuid not null references public.club_meetings(id) on delete cascade,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  club_id     uuid not null references public.clubs(id) on delete cascade,
  body        text not null check (char_length(body) between 1 and 140),
  visibility  text not null default 'host' check (visibility in ('host','club')),
  updated_at  timestamptz not null default now(),
  primary key (meeting_id, user_id)
);
create index meeting_notes_user_idx on public.meeting_notes (user_id);
create index meeting_notes_club_idx on public.meeting_notes (club_id, user_id);

-- Quem sai do clube leva a presença e o recado junto (as contagens são das leitoras atuais).
create or replace function private.club_member_left() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  delete from public.meeting_rsvps where club_id = old.club_id and user_id = old.user_id;
  delete from public.meeting_notes where club_id = old.club_id and user_id = old.user_id;
  return null;
end $$;
create trigger club_members_left after delete on public.club_members
  for each row execute function private.club_member_left();

-- 4. Discussão: perguntas, respostas em um nível, spoiler e o mesmo trecho --------------------

-- Chave do trecho (D-219): o mesmo trecho com outra pontuação, maiúscula ou acento dá a mesma chave.
-- security definer: a coluna gerada roda como quem insere, e o f_unaccent não é dele.
create or replace function private.quote_key(p_text text) returns text
language sql immutable parallel safe security definer set search_path = '' as $$
  select case when p_text is null then null
              else md5(btrim(regexp_replace(lower(private.f_unaccent(p_text)), '[^a-z0-9]+', ' ', 'g'))) end
$$;

alter table public.club_posts drop constraint club_posts_kind_check;
alter table public.club_posts add constraint club_posts_kind_check
  check (kind in ('discussion','shared_highlight','question'));
alter table public.club_posts
  add column reading_id    uuid references public.club_readings(id) on delete cascade,
  add column week_no       integer check (week_no between 1 and 12),
  add column position      integer check (position > 0),
  add column status        text check (status in ('open','discussed','postponed')),
  add column host_note     text check (char_length(host_note) <= 280),
  add column likes_count   integer not null default 0,
  add column spoiler_ratio numeric(5,4) check (spoiler_ratio between 0 and 1),
  add column spoiler_page  integer check (spoiler_page > 0),
  add column quote_key     text generated always as (private.quote_key(quote_text)) stored,
  add constraint club_posts_question_check check (kind <> 'question' or deleted_at is not null
    or (body is not null and reading_id is not null and week_no is not null and status is not null));
create index club_posts_reading_week_idx on public.club_posts (reading_id, week_no) where deleted_at is null;
create index club_posts_same_passage_idx on public.club_posts (reading_id, quote_key)
  where kind = 'shared_highlight' and deleted_at is null;

-- A leitura do post é do mesmo clube.
create or replace function private.club_post_reading_check() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.reading_id is not null and not exists (
       select 1 from public.club_readings r where r.id = new.reading_id and r.club_id = new.club_id) then
    raise exception 'invalid_reading' using errcode = '22023';
  end if;
  return new;
end $$;
create trigger club_posts_reading_check before insert or update of reading_id on public.club_posts
  for each row execute function private.club_post_reading_check();

alter table public.club_post_replies
  add column parent_reply_id uuid references public.club_post_replies(id) on delete cascade,
  add column replies_count   integer not null default 0,
  add column likes_count     integer not null default 0,
  add column spoiler_ratio   numeric(5,4) check (spoiler_ratio between 0 and 1),
  add column spoiler_page    integer check (spoiler_page > 0),
  add column quote_text      text check (char_length(quote_text) <= 1200),
  add column quote_color     text check (quote_color ~ '^#[0-9A-F]{6}$'),
  add column quote_page      integer check (quote_page > 0);
create index club_post_replies_parent_idx on public.club_post_replies (parent_reply_id);
drop index public.club_post_replies_club_idx;
create index club_post_replies_club_idx on public.club_post_replies (club_id, created_at desc);

-- A resposta herda o club_id do post e vai a um nível só (a resposta de uma resposta, no mesmo post).
create or replace function private.club_reply_set_club() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_post uuid; v_grand uuid;
begin
  select p.club_id into new.club_id from public.club_posts p where p.id = new.post_id;
  if new.club_id is null then raise exception 'post_not_found' using errcode = 'P0001'; end if;
  if new.parent_reply_id is not null then
    select r.post_id, r.parent_reply_id into v_post, v_grand from public.club_post_replies r
     where r.id = new.parent_reply_id;
    if v_post is distinct from new.post_id or v_grand is not null then
      raise exception 'reply_depth' using errcode = 'P0001';
    end if;
  end if;
  return new;
end $$;

-- Os contadores de respostas: o post conta todas; a resposta, as filhas.
create or replace function private.club_replies_counter() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_delta integer; v_parent uuid := coalesce(new.parent_reply_id, old.parent_reply_id);
begin
  v_delta := (case when tg_op <> 'DELETE' and new.deleted_at is null then 1 else 0 end)
           - (case when tg_op <> 'INSERT' and old.deleted_at is null then 1 else 0 end);
  if v_delta <> 0 then
    update public.club_posts set replies_count = greatest(replies_count + v_delta, 0)
     where id = coalesce(new.post_id, old.post_id);
    if v_parent is not null then
      update public.club_post_replies set replies_count = greatest(replies_count + v_delta, 0) where id = v_parent;
    end if;
  end if;
  return null;
end $$;

-- 5. Curtidas ---------------------------------------------------------------------------

create table public.club_likes (
  target_type  text not null check (target_type in ('post','reply')),
  target_id    uuid not null,
  user_id      uuid not null references public.profiles(id) on delete cascade,
  club_id      uuid not null references public.clubs(id) on delete cascade,   -- vem do alvo (gatilho)
  created_at   timestamptz not null default now(),
  primary key (target_type, target_id, user_id)
);
create index club_likes_user_idx on public.club_likes (user_id);
create index club_likes_club_idx on public.club_likes (club_id);

create or replace function private.club_like_set_club() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.target_type = 'post' then
    select p.club_id into new.club_id from public.club_posts p where p.id = new.target_id and p.deleted_at is null;
  else
    select r.club_id into new.club_id from public.club_post_replies r
     where r.id = new.target_id and r.deleted_at is null;
  end if;
  if new.club_id is null then raise exception 'target_not_found' using errcode = 'P0001'; end if;
  return new;
end $$;
create trigger club_likes_set_club before insert on public.club_likes
  for each row execute function private.club_like_set_club();

create or replace function private.club_likes_counter() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_delta integer := case when tg_op = 'INSERT' then 1 else -1 end;
begin
  if coalesce(new.target_type, old.target_type) = 'post' then
    update public.club_posts set likes_count = greatest(likes_count + v_delta, 0)
     where id = coalesce(new.target_id, old.target_id);
  else
    update public.club_post_replies set likes_count = greatest(likes_count + v_delta, 0)
     where id = coalesce(new.target_id, old.target_id);
  end if;
  return null;
end $$;
create trigger club_likes_counter after insert or delete on public.club_likes
  for each row execute function private.club_likes_counter();

-- 6. Faixa etária e filtro de palavras nas tabelas novas ----------------------------------------

create trigger club_likes_require_age before insert on public.club_likes
  for each row execute function private.require_age_band();
create trigger meeting_rsvps_require_age before insert on public.meeting_rsvps
  for each row execute function private.require_age_band();
create trigger meeting_notes_require_age before insert on public.meeting_notes
  for each row execute function private.require_age_band();
create trigger meeting_notes_blocked_terms before insert or update of body on public.meeting_notes
  for each row execute function private.reject_blocked_terms();

-- O filtro de palavras passa a olhar a categoria do clube e a anotação da anfitriã (o resto como na revisão da G04).
create or replace function private.reject_blocked_terms() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v jsonb := to_jsonb(new); v_texto text;
begin
  -- (to_jsonb: a mesma função serve a tabelas com colunas diferentes)
  v_texto := case tg_table_name
    when 'profiles'   then concat_ws(' ', v ->> 'display_name', v ->> 'bio', translate(v ->> 'handle', '_.', '  '))
    when 'clubs'      then concat_ws(' ', v ->> 'name', v ->> 'category')
    when 'club_posts' then concat_ws(' ', v ->> 'body', v ->> 'host_note')
    else v ->> 'body'                                -- quote_text é trecho do livro: não filtra
  end;
  if private.has_blocked_term(v_texto) then
    raise exception 'content_blocked' using errcode = 'P0001',
      hint = 'O texto tem um termo que não é permitido nas regras da comunidade.';
  end if;
  return new;
end $$;
drop trigger clubs_blocked_terms on public.clubs;
create trigger clubs_blocked_terms before insert or update of name, category on public.clubs
  for each row execute function private.reject_blocked_terms();
drop trigger club_posts_blocked_terms on public.club_posts;
create trigger club_posts_blocked_terms before insert or update of body, host_note on public.club_posts
  for each row execute function private.reject_blocked_terms();

-- 7. Políticas -----------------------------------------------------------------------------

alter table public.club_readings enable row level security;
alter table public.club_weeks enable row level security;
alter table public.meeting_rsvps enable row level security;
alter table public.meeting_notes enable row level security;
alter table public.club_likes enable row level security;

create policy club_readings_read on public.club_readings for select to authenticated
  using (private.is_club_member(club_id));
create policy club_weeks_read on public.club_weeks for select to authenticated
  using (private.is_club_member(club_id));
create policy meeting_rsvps_read on public.meeting_rsvps for select to authenticated
  using (private.is_club_member(club_id));
-- o recado: quem escreveu e a anfitriã leem sempre; o resto do clube, só os de "O clube todo"
create policy meeting_notes_read on public.meeting_notes for select to authenticated
  using (user_id = (select auth.uid()) or private.is_club_admin(club_id)
         or (visibility = 'club' and private.is_club_member(club_id)));
create policy club_likes_read on public.club_likes for select to authenticated
  using (private.is_club_member(club_id));
create policy club_likes_insert on public.club_likes for insert to authenticated
  with check (user_id = (select auth.uid()) and private.is_club_member(club_id));
create policy club_likes_delete on public.club_likes for delete to authenticated
  using (user_id = (select auth.uid()));

-- post direto: só discussão e grifo; a pergunta vem pela RPC (a posição e o estado são da anfitriã)
drop policy club_posts_insert on public.club_posts;
create policy club_posts_insert on public.club_posts for insert to authenticated
  with check (author_id = (select auth.uid()) and private.is_club_member(club_id)
              and kind in ('discussion','shared_highlight'));

-- o progresso e o lido passam a ser só pelas RPCs (com a validação e o limite)
drop policy club_members_update_self on public.club_members;

-- 8. Resumos (uma ida por tela) ----------------------------------------------------------------

create or replace function private.initial_of(p_name text) returns text
language sql immutable parallel safe set search_path = '' as $$
  select upper(left(btrim(coalesce(p_name, '')), 1))
$$;

-- Quem eu bloqueei e quem me bloqueou (D-223): some dos resumos.
create or replace function private.block_set(p_me uuid) returns uuid[]
language sql stable security definer set search_path = '' as $$
  select coalesce(array_agg(s.x), '{}') from (
    select b.blocked_id as x from public.user_blocks b where b.blocker_id = p_me
    union
    select b.blocker_id from public.user_blocks b where b.blocked_id = p_me) s
$$;

-- O próximo encontro da leitura: o primeiro que ainda não acabou (sem fim marcado, vale 2 h).
create or replace function private.next_meeting_id(p_reading uuid) returns uuid
language sql stable security definer set search_path = '' as $$
  select m.id from public.club_meetings m
   where m.reading_id = p_reading and coalesce(m.ends_at, m.starts_at + interval '2 hours') > now()
   order by m.starts_at limit 1
$$;

-- A semana atual (R4): a do próximo encontro; sem encontro à frente, a última.
create or replace function private.current_week_no(p_reading uuid) returns integer
language sql stable security definer set search_path = '' as $$
  select coalesce(
    (select m.week_no from public.club_meetings m where m.id = private.next_meeting_id(p_reading)),
    (select max(w.week_no) from public.club_weeks w where w.reading_id = p_reading))
$$;

create or replace function private.week_range_json(w public.club_weeks) returns jsonb
language sql stable set search_path = '' as $$
  select jsonb_build_object('no', w.week_no, 'from', w.from_chapter, 'to', w.to_chapter,
                            'from_label', w.from_label, 'to_label', w.to_label)
$$;

-- Uma leitora nos resumos. Conta excluída: só {"deleted": true}.
create or replace function private.person_json(p_user uuid, p_club uuid, p_me uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select case when p_user is null then '{"deleted": true}'::jsonb else (
    select jsonb_build_object('id', pr.id, 'name', pr.display_name, 'initial', private.initial_of(pr.display_name),
                              'color', m.color, 'host', coalesce(m.role = 'owner', false), 'me', pr.id = p_me)
      from public.profiles pr
      left join public.club_members m on m.club_id = p_club and m.user_id = pr.id
     where pr.id = p_user) end
$$;

-- Respostas visíveis (R12): o contador menos as de quem está bloqueado.
create or replace function private.visible_replies(p_post uuid, p_count integer, p_blocks uuid[]) returns integer
language sql stable security definer set search_path = '' as $$
  select case when cardinality(p_blocks) = 0 then p_count else p_count - (
    select count(*)::integer from public.club_post_replies r
     where r.post_id = p_post and r.deleted_at is null and r.author_id = any(p_blocks)) end
$$;
create or replace function private.visible_children(p_reply uuid, p_count integer, p_blocks uuid[]) returns integer
language sql stable security definer set search_path = '' as $$
  select case when cardinality(p_blocks) = 0 then p_count else p_count - (
    select count(*)::integer from public.club_post_replies r
     where r.parent_reply_id = p_reply and r.deleted_at is null and r.author_id = any(p_blocks)) end
$$;

-- Não lidas (R6): posts e respostas de outras pessoas, não apagados nem bloqueados, depois de p_since.
-- Com p_reading e p_week: só os da semana.
create or replace function private.club_unread(p_club uuid, p_me uuid, p_since timestamptz, p_blocks uuid[],
  p_reading uuid default null, p_week integer default null) returns integer
language sql stable security definer set search_path = '' as $$
  select ((select count(*) from public.club_posts p
            where p.club_id = p_club and p.deleted_at is null and p.created_at > p_since
              and p.author_id is distinct from p_me and coalesce(p.author_id <> all(p_blocks), true)
              and (p_week is null or (p.reading_id = p_reading and p.week_no = p_week)))
        + (select count(*) from public.club_post_replies r join public.club_posts p on p.id = r.post_id
            where r.club_id = p_club and r.deleted_at is null and p.deleted_at is null and r.created_at > p_since
              and r.author_id <> p_me and r.author_id <> all(p_blocks)
              and coalesce(p.author_id <> all(p_blocks), true)
              and (p_week is null or (p.reading_id = p_reading and p.week_no = p_week))))::integer
$$;

-- % do grupo (R5): a média das frações publicadas.
create or replace function private.group_progress(p_club uuid) returns numeric
language sql stable security definer set search_path = '' as $$
  select round(avg(m.progress_ratio), 4) from public.club_members m
   where m.club_id = p_club and m.progress_ratio is not null
$$;

create or replace function private.rsvp_counts(p_meeting uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('vou', count(*) filter (where x.answer = 'vou'),
                            'talvez', count(*) filter (where x.answer = 'talvez'),
                            'nao_vou', count(*) filter (where x.answer = 'nao_vou'))
    from public.meeting_rsvps x
    join public.club_members cm on cm.club_id = x.club_id and cm.user_id = x.user_id
   where x.meeting_id = p_meeting
$$;

-- O livro da leitura (D-213: a obra, a edição e os ISBN-13 das edições da obra, até 50) e a semana atual.
create or replace function private.reading_json(p_reading uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', r.id, 'work_id', r.work_id, 'edition_id', r.edition_id,
    'isbns', coalesce((select jsonb_agg(x.isbn13 order by x.isbn13) from (
                         select e2.isbn13 from catalog.editions e2
                          where e2.isbn13 is not null
                            and (e2.id = r.edition_id or (r.work_id is not null and e2.work_id = r.work_id))
                          order by (e2.id = r.edition_id) desc, e2.isbn13 limit 50) x), '[]'::jsonb),
    'title', coalesce(e.title, w.title),
    'author', (select a.name from catalog.work_authors wa join catalog.authors a on a.id = wa.author_id
                where wa.work_id = r.work_id order by wa.position, a.name limit 1),
    'cover_ref', e.cover_ref, 'isbn13', e.isbn13, 'pages', e.pages, 'weeks', r.weeks,
    'current_week', (select private.week_range_json(cw) from public.club_weeks cw
                      where cw.reading_id = r.id and cw.week_no = private.current_week_no(r.id)))
    from public.club_readings r
    left join catalog.editions e on e.id = r.edition_id
    left join catalog.works w on w.id = r.work_id
   where r.id = p_reading
$$;

-- Um encontro: quando, o modo, a pauta (a semana), as contagens e a minha presença.
create or replace function private.meeting_json(p_meeting uuid, p_me uuid) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object(
    'id', m.id, 'starts_at', m.starts_at, 'ends_at', m.ends_at, 'mode', m.mode, 'timezone', m.timezone,
    'location', m.location, 'week_no', m.week_no, 'weeks', r.weeks,
    'agenda', (select private.week_range_json(w) from public.club_weeks w
                where w.reading_id = m.reading_id and w.week_no = m.week_no),
    'counts', private.rsvp_counts(m.id),
    'mine', (select x.answer from public.meeting_rsvps x where x.meeting_id = m.id and x.user_id = p_me))
    from public.club_meetings m left join public.club_readings r on r.id = m.reading_id
   where m.id = p_meeting
$$;

create or replace function private.question_json(q public.club_posts, p_me uuid, p_blocks uuid[],
  p_since timestamptz) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('id', q.id, 'body', q.body, 'position', q.position, 'status', q.status,
    'host_note', q.host_note, 'week_no', q.week_no, 'author', private.person_json(q.author_id, q.club_id, p_me),
    'likes', q.likes_count, 'replies', private.visible_replies(q.id, q.replies_count, p_blocks),
    'new', (select count(*)::integer from public.club_post_replies r
             where r.post_id = q.id and r.deleted_at is null and r.created_at > p_since
               and r.author_id <> p_me and r.author_id <> all(p_blocks)))
$$;

create or replace function private.spoiler_json(p_ratio numeric, p_page integer) returns jsonb
language sql immutable set search_path = '' as $$
  select case when p_ratio is null then null else jsonb_build_object('ratio', p_ratio, 'page', p_page) end
$$;

create or replace function private.shared_json(p public.club_posts, p_me uuid, p_blocks uuid[]) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('id', p.id, 'author', private.person_json(p.author_id, p.club_id, p_me),
    'quote_text', p.quote_text, 'quote_color', p.quote_color, 'ref_page', p.ref_page,
    'chapter', p.chapter_index + 1, 'week_no', p.week_no, 'created_at', p.created_at,
    'same_passage', (select count(distinct s.author_id)::integer from public.club_posts s
                      where s.reading_id = p.reading_id and s.quote_key = p.quote_key and s.kind = 'shared_highlight'
                        and s.deleted_at is null and s.author_id <> all(p_blocks)),
    'likes', p.likes_count,
    'liked', exists (select 1 from public.club_likes l
                      where l.target_type = 'post' and l.target_id = p.id and l.user_id = p_me),
    'replies', private.visible_replies(p.id, p.replies_count, p_blocks),
    'spoiler', private.spoiler_json(p.spoiler_ratio, p.spoiler_page))
$$;

create or replace function private.reply_json(r public.club_post_replies, p_me uuid, p_blocks uuid[]) returns jsonb
language sql stable security definer set search_path = '' as $$
  select jsonb_build_object('id', r.id, 'parent_id', r.parent_reply_id,
    'author', private.person_json(r.author_id, r.club_id, p_me), 'created_at', r.created_at, 'body', r.body,
    'likes', r.likes_count,
    'liked', exists (select 1 from public.club_likes l
                      where l.target_type = 'reply' and l.target_id = r.id and l.user_id = p_me),
    'replies', private.visible_children(r.id, r.replies_count, p_blocks),
    'quote', case when r.quote_text is null then null
                  else jsonb_build_object('text', r.quote_text, 'color', r.quote_color, 'page', r.quote_page) end,
    'spoiler', private.spoiler_json(r.spoiler_ratio, r.spoiler_page))
$$;

create or replace function private.week_card_json(w public.club_weeks, p_me uuid, p_blocks uuid[],
  p_since timestamptz) returns jsonb
language sql stable security definer set search_path = '' as $$
  select private.week_range_json(w) || jsonb_build_object(
    'comments', (select count(*)::integer from public.club_post_replies r join public.club_posts p on p.id = r.post_id
                  where p.reading_id = w.reading_id and p.week_no = w.week_no and p.deleted_at is null
                    and r.deleted_at is null and r.author_id <> all(p_blocks)
                    and coalesce(p.author_id <> all(p_blocks), true)),
    'new', private.club_unread(w.club_id, p_me, p_since, p_blocks, w.reading_id, w.week_no),
    'question', (select private.question_json(q, p_me, p_blocks, p_since) from public.club_posts q
                  where q.reading_id = w.reading_id and q.week_no = w.week_no and q.kind = 'question'
                    and q.deleted_at is null and coalesce(q.author_id <> all(p_blocks), true)
                  order by q.position nulls last, q.created_at, q.id limit 1))
$$;

-- Os meus clubes (o ticket da Início, a faixa do sumário, a folha "Compartilhar em…").
create or replace function public.my_clubs() returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_blocks uuid[];
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  v_blocks := private.block_set(v_me);
  return coalesce((
    select jsonb_agg(s.card order by s.activity desc nulls last, s.name)
      from (
        select c.name, la.activity, jsonb_build_object(
          'id', c.id, 'name', c.name, 'name_highlight', c.name_highlight, 'category', c.category, 'color', c.color,
          'role', mi.role, 'privacy', c.privacy, 'spoiler_protection', c.spoiler_protection,
          'members_count', (select count(*) from public.club_members x where x.club_id = c.id),
          'participants', coalesce((
             select jsonb_agg(jsonb_build_object('initial', private.initial_of(pr.display_name), 'color', p.color)
                              order by p.ord)
               from (select x.user_id, x.color,
                            row_number() over (order by (x.role = 'owner') desc, x.joined_at, x.user_id) as ord
                       from public.club_members x
                      where x.club_id = c.id and x.user_id <> v_me and x.user_id <> all(v_blocks)
                      order by ord limit 3) p
               join public.profiles pr on pr.id = p.user_id), '[]'::jsonb),
          'me', (select jsonb_build_object('initial', private.initial_of(pr.display_name), 'color', mi.color)
                   from public.profiles pr where pr.id = v_me),
          'reading', (select private.reading_json(r.id) from public.club_readings r
                       where r.club_id = c.id and r.status = 'current'),
          'next_meeting', (select private.meeting_json(private.next_meeting_id(r.id), v_me)
                            from public.club_readings r where r.club_id = c.id and r.status = 'current'),
          'my_progress', mi.progress_ratio,
          'group_progress', private.group_progress(c.id),
          'unread', private.club_unread(c.id, v_me, coalesce(mi.last_read_post_at, mi.joined_at), v_blocks),
          'last_activity_at', la.activity) as card
          from public.club_members mi
          join public.clubs c on c.id = mi.club_id
          left join lateral (
            select greatest(
              (select max(p.created_at) from public.club_posts p where p.club_id = c.id and p.deleted_at is null),
              (select max(r.created_at) from public.club_post_replies r
                where r.club_id = c.id and r.deleted_at is null)) as activity) la on true
         where mi.user_id = v_me) s), '[]'::jsonb);
end $$;

-- A 04.
create or replace function public.club_overview(p_club uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_blocks uuid[]; v_m public.club_members; v_reading uuid;
        v_since timestamptz;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select * into v_m from public.club_members where club_id = p_club and user_id = v_me;
  if not found then raise exception 'not_member' using errcode = '42501'; end if;
  v_blocks := private.block_set(v_me);
  v_since := coalesce(v_m.last_read_post_at, v_m.joined_at);
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  return jsonb_build_object(
    'club', (select jsonb_build_object('id', c.id, 'name', c.name, 'name_highlight', c.name_highlight,
               'category', c.category, 'color', c.color, 'privacy', c.privacy, 'progress_colors', c.progress_colors,
               'spoiler_protection', c.spoiler_protection, 'role', v_m.role,
               'members_count', (select count(*) from public.club_members x where x.club_id = c.id))
               from public.clubs c where c.id = p_club),
    'reading', case when v_reading is not null then private.reading_json(v_reading) || jsonb_build_object(
      'weeks_list', (select jsonb_agg(private.week_card_json(w, v_me, v_blocks, v_since) order by w.week_no)
                       from public.club_weeks w where w.reading_id = v_reading)) end,
    'next_meeting', case when v_reading is not null then private.meeting_json(private.next_meeting_id(v_reading), v_me) end,
    'members', (select jsonb_agg(jsonb_build_object('user_id', x.user_id, 'initial', private.initial_of(pr.display_name),
                  'color', x.color, 'ratio', x.progress_ratio, 'me', x.user_id = v_me)
                  order by x.progress_ratio desc nulls last, x.joined_at)
                  from public.club_members x join public.profiles pr on pr.id = x.user_id where x.club_id = p_club),
    'my_progress', v_m.progress_ratio,
    'group_progress', private.group_progress(p_club),
    'unread', private.club_unread(p_club, v_me, v_since, v_blocks),
    'shared', coalesce((select jsonb_agg(private.shared_json(p, v_me, v_blocks) order by p.created_at desc, p.id desc)
                 from (select * from public.club_posts p
                        where p.club_id = p_club and p.kind = 'shared_highlight' and p.deleted_at is null
                          and coalesce(p.author_id <> all(v_blocks), true)
                        order by p.created_at desc, p.id desc limit 5) p), '[]'::jsonb));
end $$;

-- A 31: a pergunta da semana e as respostas (p_parent: as filhas de uma resposta), por keyset.
create or replace function public.week_thread(p_club uuid, p_week integer, p_order text default 'likes',
  p_parent uuid default null, p_cursor jsonb default null, p_limit integer default 30) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_blocks uuid[]; v_m public.club_members; v_reading uuid;
        v_q public.club_posts; v_rows jsonb; v_next jsonb;
        v_limit integer := least(greatest(coalesce(p_limit, 30), 1), 100);
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select * into v_m from public.club_members where club_id = p_club and user_id = v_me;
  if not found then raise exception 'not_member' using errcode = '42501'; end if;
  if p_order is null or p_order not in ('likes','recent') then
    raise exception 'invalid_order' using errcode = '22023';
  end if;
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  if not exists (select 1 from public.club_weeks w where w.reading_id = v_reading and w.week_no = p_week) then
    raise exception 'invalid_week' using errcode = '22023';
  end if;
  v_blocks := private.block_set(v_me);
  select * into v_q from public.club_posts q
   where q.reading_id = v_reading and q.week_no = p_week and q.kind = 'question' and q.deleted_at is null
     and coalesce(q.author_id <> all(v_blocks), true)
   order by q.position nulls last, q.created_at, q.id limit 1;
  if v_q.id is not null then
    with page as (
      select r, row_number() over (order by case when p_order = 'likes' then r.likes_count end desc nulls last,
                                            r.created_at desc, r.id desc) as n
        from public.club_post_replies r
       where r.post_id = v_q.id and r.deleted_at is null and r.author_id <> all(v_blocks)
         and r.parent_reply_id is not distinct from p_parent
         and (p_cursor is null or case when p_order = 'likes'
               then (r.likes_count, r.created_at, r.id) < ((p_cursor ->> 'likes')::integer,
                     (p_cursor ->> 'created_at')::timestamptz, (p_cursor ->> 'id')::uuid)
               else (r.created_at, r.id) < ((p_cursor ->> 'created_at')::timestamptz, (p_cursor ->> 'id')::uuid) end)
       order by n limit v_limit + 1)
    select coalesce(jsonb_agg(private.reply_json(p.r, v_me, v_blocks) order by p.n) filter (where p.n <= v_limit),
                    '[]'::jsonb),
           case when max(p.n) > v_limit then (
             select jsonb_build_object('likes', (q.r).likes_count, 'created_at', (q.r).created_at, 'id', (q.r).id)
               from page q where q.n = v_limit) end
      into v_rows, v_next
      from page p;
  end if;
  return jsonb_build_object(
    'week', (select private.week_range_json(w) from public.club_weeks w
              where w.reading_id = v_reading and w.week_no = p_week),
    'question', case when v_q.id is not null then
      private.question_json(v_q, v_me, v_blocks, coalesce(v_m.last_read_post_at, v_m.joined_at)) end,
    'replies', coalesce(v_rows, '[]'::jsonb),
    'next_cursor', v_next);
end $$;

-- As 70, 72 e 73.
create or replace function public.meeting_overview(p_meeting uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_blocks uuid[]; v_mt public.club_meetings; v_host boolean;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select * into v_mt from public.club_meetings where id = p_meeting;
  if not found or not private.is_club_member(v_mt.club_id) then
    raise exception 'not_member' using errcode = '42501';
  end if;
  v_blocks := private.block_set(v_me);
  v_host := private.is_club_admin(v_mt.club_id);
  return jsonb_build_object(
    'meeting', private.meeting_json(p_meeting, v_me) || jsonb_build_object(
       'club_id', v_mt.club_id,
       'club_name', (select c.name from public.clubs c where c.id = v_mt.club_id),
       'book_title', (select coalesce(e.title, w.title) from public.club_readings r
                        left join catalog.editions e on e.id = r.edition_id
                        left join catalog.works w on w.id = r.work_id where r.id = v_mt.reading_id)),
    'host', (select private.person_json(c.owner_id, c.id, v_me) from public.clubs c where c.id = v_mt.club_id),
    'mine', jsonb_build_object(
       'answer', (select x.answer from public.meeting_rsvps x where x.meeting_id = p_meeting and x.user_id = v_me),
       'note', (select jsonb_build_object('body', n.body, 'visibility', n.visibility) from public.meeting_notes n
                 where n.meeting_id = p_meeting and n.user_id = v_me)),
    'people', coalesce((select jsonb_object_agg(a.answer, a.people) from (
       select x.answer, jsonb_agg(private.person_json(x.user_id, x.club_id, v_me)
                                  || jsonb_build_object('ratio', cm.progress_ratio)
                                  order by cm.progress_ratio desc nulls last, cm.joined_at) as people
         from public.meeting_rsvps x
         join public.club_members cm on cm.club_id = x.club_id and cm.user_id = x.user_id
        where x.meeting_id = p_meeting group by x.answer) a), '{}'::jsonb),
    'questions', coalesce((select jsonb_agg(private.question_json(q, v_me, v_blocks, null)
                                            order by q.position nulls last, q.created_at, q.id)
       from public.club_posts q
      where q.reading_id = v_mt.reading_id and q.week_no = v_mt.week_no and q.kind = 'question'
        and q.deleted_at is null and coalesce(q.author_id <> all(v_blocks), true)), '[]'::jsonb),
    'notes', coalesce((select jsonb_agg(jsonb_build_object('author', private.person_json(n.user_id, n.club_id, v_me),
                                          'body', n.body, 'visibility', n.visibility) order by n.updated_at)
       from public.meeting_notes n
      where n.meeting_id = p_meeting and n.user_id <> v_me and n.user_id <> all(v_blocks)
        and (v_host or n.visibility = 'club')), '[]'::jsonb));
end $$;

-- A 32.
create or replace function public.club_members_overview(p_club uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_reading uuid; v_next uuid;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_member(p_club) then raise exception 'not_member' using errcode = '42501'; end if;
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  v_next := private.next_meeting_id(v_reading);
  return jsonb_build_object(
    'next_meeting', private.meeting_json(v_next, v_me),
    'members', coalesce((select jsonb_agg(private.person_json(x.user_id, p_club, v_me) || jsonb_build_object(
         'role', x.role, 'ratio', x.progress_ratio,
         'rsvp', (select y.answer from public.meeting_rsvps y where y.meeting_id = v_next and y.user_id = x.user_id))
         order by x.progress_ratio desc nulls last, x.joined_at)
       from public.club_members x where x.club_id = p_club), '[]'::jsonb));
end $$;

-- O chip da 25: o clube e as respostas visíveis de cada post compartilhado (até 200 por ida).
create or replace function public.club_post_summaries(p_ids uuid[]) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_blocks uuid[];
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if cardinality(p_ids) > 200 then raise exception 'too_many' using errcode = '22023'; end if;
  v_blocks := private.block_set(v_me);
  return coalesce((select jsonb_agg(jsonb_build_object('id', p.id, 'club_id', p.club_id, 'club_name', c.name,
                     'replies', private.visible_replies(p.id, p.replies_count, v_blocks)) order by p.id)
     from public.club_posts p
     join public.clubs c on c.id = p.club_id
     join public.club_members m on m.club_id = p.club_id and m.user_id = v_me
    where p.id = any(p_ids) and p.deleted_at is null), '[]'::jsonb);
end $$;

-- 9. Escrita -------------------------------------------------------------------------------

-- Cria o clube com a leitura, as semanas e um encontro por semana (prancha 33), numa transação.
-- p: {"name", "name_highlight", "category", "color", "progress_colors", "privacy", "spoiler_protection",
--     "meeting": {"weekday", "time", "minutes", "mode", "timezone"},
--     "reading": {"work_id", "edition_id", "starts_on", "weeks": [{"from", "to", "from_label", "to_label"}]}}
-- As semanas vêm prontas do app (até 12, contíguas desde o cap. 1). O limite do Grátis, a faixa etária,
-- o filtro de palavras e os termos continuam nos gatilhos de clubs.
create or replace function public.create_club(p jsonb) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  v_me uuid := (select auth.uid());
  v_r jsonb := p -> 'reading';
  v_mt jsonb := coalesce(p -> 'meeting', '{}'::jsonb);
  v_weeks jsonb := v_r -> 'weeks';
  v_edition uuid := (v_r ->> 'edition_id')::uuid;
  v_work uuid := (v_r ->> 'work_id')::uuid;
  v_starts date := coalesce((v_r ->> 'starts_on')::date, current_date);
  v_tz text := coalesce(v_mt ->> 'timezone', 'America/Sao_Paulo');
  v_dow integer := (v_mt ->> 'weekday')::integer;
  v_time time := (v_mt ->> 'time')::time;
  v_minutes integer := coalesce((v_mt ->> 'minutes')::integer, 90);
  v_n integer; v_prev integer := 0; v_w jsonb; v_club uuid; v_reading uuid; v_first date; v_start timestamptz;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if v_r is null or jsonb_typeof(v_weeks) is distinct from 'array' then
    raise exception 'invalid_weeks' using errcode = '22023';
  end if;
  v_n := jsonb_array_length(v_weeks);
  if v_n not between 1 and 12 then raise exception 'invalid_weeks' using errcode = '22023'; end if;
  for v_w in select x from jsonb_array_elements(v_weeks) x loop
    if (v_w ->> 'from')::integer is distinct from v_prev + 1
       or (v_w ->> 'to')::integer is null or (v_w ->> 'to')::integer < v_prev + 1 then
      raise exception 'invalid_weeks' using errcode = '22023';
    end if;
    v_prev := (v_w ->> 'to')::integer;
  end loop;
  if v_edition is null and v_work is null then raise exception 'invalid_book' using errcode = '22023'; end if;
  if v_work is null then select e.work_id into v_work from catalog.editions e where e.id = v_edition; end if;

  insert into public.clubs (owner_id, name, name_highlight, category, color, progress_colors, privacy,
                            spoiler_protection, work_id, edition_id, meeting_weekday, meeting_time,
                            meeting_minutes, meeting_mode, timezone)
  values (v_me, p ->> 'name', p ->> 'name_highlight', p ->> 'category', coalesce(p ->> 'color', '#B6ACE4'),
          coalesce(p ->> 'progress_colors', 'club'), coalesce(p ->> 'privacy', 'invite'),
          coalesce((p ->> 'spoiler_protection')::boolean, true), v_work, v_edition, v_dow, v_time, v_minutes,
          v_mt ->> 'mode', v_tz)
  returning id into v_club;

  insert into public.club_readings (club_id, work_id, edition_id, status, starts_on, weeks)
  values (v_club, v_work, v_edition, 'current', v_starts, v_n)
  returning id into v_reading;

  insert into public.club_weeks (reading_id, club_id, week_no, from_chapter, to_chapter, from_label, to_label)
  select v_reading, v_club, w.n::integer, (w.v ->> 'from')::integer, (w.v ->> 'to')::integer,
         w.v ->> 'from_label', w.v ->> 'to_label'
    from jsonb_array_elements(v_weeks) with ordinality as w(v, n);

  -- um encontro por semana: o 1º dia do encontro a partir do início, na hora do clube, no fuso dele
  if v_dow is not null and v_time is not null then
    v_first := v_starts + ((v_dow - extract(dow from v_starts)::integer + 7) % 7);
    for i in 1 .. v_n loop
      v_start := ((v_first + (i - 1) * 7) + v_time) at time zone v_tz;
      insert into public.club_meetings (club_id, starts_at, ends_at, mode, timezone, reading_id, week_no, created_by)
      values (v_club, v_start, v_start + make_interval(mins => v_minutes), v_mt ->> 'mode', v_tz, v_reading, i, v_me);
    end loop;
  end if;
  return v_club;
end $$;

-- Convite da anfitriã: "vale por 7 dias · até 12 pessoas · dá para desativar" (prancha 34).
create or replace function public.create_invite(p_club uuid, p_days integer default 7, p_max_uses integer default 12)
returns text language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_code text;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_admin(p_club) then raise exception 'not_allowed' using errcode = '42501'; end if;
  if p_days is null or p_days not between 1 and 30 or p_max_uses is null or p_max_uses not between 1 and 100 then
    raise exception 'invalid_invite' using errcode = '22023';
  end if;
  insert into public.club_invites (club_id, created_by, expires_at, max_uses)
  values (p_club, v_me, now() + make_interval(days => p_days), p_max_uses)
  returning code into v_code;
  return v_code;
end $$;

create or replace function public.revoke_invite(p_code text) returns void
language plpgsql security definer set search_path = '' as $$
begin
  if (select auth.uid()) is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  update public.club_invites i set expires_at = least(i.expires_at, now())
   where i.code = p_code and private.is_club_admin(i.club_id);
  if not found then raise exception 'not_allowed' using errcode = '42501'; end if;
end $$;

-- O progresso no clube (R9): a fração e o capítulo do clube; até 1 vez por minuto (a 2ª no mesmo minuto
-- não muda nada).
create or replace function public.publish_progress(p_club uuid, p_ratio numeric, p_chapter integer) returns void
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid());
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_member(p_club) then raise exception 'not_member' using errcode = '42501'; end if;
  if p_ratio is null or p_ratio < 0 or p_ratio > 1 or (p_chapter is not null and p_chapter < 0) then
    raise exception 'invalid_progress' using errcode = '22023';
  end if;
  update public.club_members
     set progress_ratio = round(p_ratio, 4), progress_chapter = p_chapter, progress_updated_at = now()
   where club_id = p_club and user_id = v_me
     and (progress_updated_at is null or progress_updated_at < now() - interval '1 minute');
end $$;

create or replace function public.mark_club_read(p_club uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid());
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  update public.club_members set last_read_post_at = now() where club_id = p_club and user_id = v_me;
  if not found then raise exception 'not_member' using errcode = '42501'; end if;
end $$;

-- Presença (pranchas 70 e 72). p_note: null = não mexe; '' = apaga; texto = grava.
-- p_visibility: null = não mexe (recado novo: "Só a Ana"). Devolve as contagens das leitoras atuais.
create or replace function public.set_rsvp(p_meeting uuid, p_answer text, p_note text default null,
  p_visibility text default null) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_mt public.club_meetings;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select * into v_mt from public.club_meetings where id = p_meeting;
  if not found or not private.is_club_member(v_mt.club_id) then
    raise exception 'not_member' using errcode = '42501';
  end if;
  if p_answer is null or p_answer not in ('vou','talvez','nao_vou')
     or (p_visibility is not null and p_visibility not in ('host','club')) then
    raise exception 'invalid_rsvp' using errcode = '22023';
  end if;
  if coalesce(v_mt.ends_at, v_mt.starts_at + interval '2 hours') <= now() then
    raise exception 'meeting_over' using errcode = 'P0001';
  end if;
  insert into public.meeting_rsvps (meeting_id, user_id, club_id, answer)
  values (p_meeting, v_me, v_mt.club_id, p_answer)
  on conflict (meeting_id, user_id) do update set answer = excluded.answer, updated_at = now();
  if p_note is not null and btrim(p_note) = '' then
    delete from public.meeting_notes where meeting_id = p_meeting and user_id = v_me;
  elsif p_note is not null then
    insert into public.meeting_notes as n (meeting_id, user_id, club_id, body, visibility)
    values (p_meeting, v_me, v_mt.club_id, btrim(p_note), coalesce(p_visibility, 'host'))
    on conflict (meeting_id, user_id) do update
      set body = excluded.body, visibility = coalesce(p_visibility, n.visibility), updated_at = now();
  elsif p_visibility is not null then
    update public.meeting_notes set visibility = p_visibility, updated_at = now()
     where meeting_id = p_meeting and user_id = v_me;
  end if;
  return private.rsvp_counts(p_meeting);
end $$;

-- Sugerir uma pergunta para a semana (prancha 70, "Sugerir uma pergunta"): entra no fim da fila, aberta.
create or replace function public.suggest_question(p_club uuid, p_week integer, p_body text) returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_reading uuid; v_to integer; v_pos integer; v_id uuid;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_member(p_club) then raise exception 'not_member' using errcode = '42501'; end if;
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  select w.to_chapter into v_to from public.club_weeks w where w.reading_id = v_reading and w.week_no = p_week;
  if v_to is null then raise exception 'invalid_week' using errcode = '22023'; end if;
  if p_body is null or char_length(btrim(p_body)) not between 3 and 300 then
    raise exception 'invalid_question' using errcode = '22023';
  end if;
  perform pg_advisory_xact_lock(hashtextextended('club_questions:' || v_reading::text || ':' || p_week, 0));
  select coalesce(max(q.position), 0) + 1 into v_pos from public.club_posts q
   where q.reading_id = v_reading and q.week_no = p_week and q.kind = 'question' and q.deleted_at is null;
  insert into public.club_posts (club_id, author_id, kind, chapter_index, reading_id, week_no, position, status, body)
  values (p_club, v_me, 'question', v_to - 1, v_reading, p_week, v_pos, 'open', btrim(p_body))
  returning id into v_id;
  return v_id;
end $$;

-- A ordem da anfitriã: a lista tem que trazer exatamente as perguntas da semana.
create or replace function public.order_questions(p_club uuid, p_week integer, p_ids uuid[]) returns void
language plpgsql security definer set search_path = '' as $$
declare v_reading uuid;
begin
  if (select auth.uid()) is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_admin(p_club) then raise exception 'not_allowed' using errcode = '42501'; end if;
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  if (select coalesce(array_agg(q.id order by q.id), '{}') from public.club_posts q
       where q.reading_id = v_reading and q.week_no = p_week and q.kind = 'question' and q.deleted_at is null)
     is distinct from (select coalesce(array_agg(x order by x), '{}') from unnest(p_ids) x) then
    raise exception 'invalid_order' using errcode = '22023';
  end if;
  update public.club_posts q set position = o.n from unnest(p_ids) with ordinality as o(id, n) where q.id = o.id;
end $$;

-- Conversada, adiada ou aberta, com a anotação da anfitriã (prancha 73).
create or replace function public.set_question_status(p_question uuid, p_status text, p_note text default null)
returns void language plpgsql security definer set search_path = '' as $$
declare v_club uuid;
begin
  if (select auth.uid()) is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  select q.club_id into v_club from public.club_posts q
   where q.id = p_question and q.kind = 'question' and q.deleted_at is null;
  if v_club is null or not private.is_club_admin(v_club) then raise exception 'not_allowed' using errcode = '42501'; end if;
  if p_status is null or p_status not in ('open','discussed','postponed') then
    raise exception 'invalid_status' using errcode = '22023';
  end if;
  update public.club_posts set status = p_status, host_note = nullif(btrim(coalesce(p_note, '')), '')
   where id = p_question;
end $$;

-- Compartilhar um grifo (D-217): o trecho, a cor, a página e o capítulo do clube; a fração é o spoiler
-- (D-218). A nota fica no aparelho. Devolve o id, que o app guarda em shared_club_post_id.
create or replace function public.share_highlight(p_club uuid, p_quote text, p_color text, p_page integer,
  p_chapter integer, p_ratio numeric) returns uuid
language plpgsql security definer set search_path = '' as $$
declare v_me uuid := (select auth.uid()); v_reading uuid; v_week integer; v_id uuid;
begin
  if v_me is null then raise exception 'unauthenticated' using errcode = '28000'; end if;
  if not private.is_club_member(p_club) then raise exception 'not_member' using errcode = '42501'; end if;
  if p_quote is null or char_length(btrim(p_quote)) not between 1 and 1200
     or p_color is null or upper(p_color) !~ '^#[0-9A-F]{6}$'
     or p_chapter is null or p_chapter < 1 or (p_page is not null and p_page < 1)
     or p_ratio is null or p_ratio < 0 or p_ratio > 1 then
    raise exception 'invalid_share' using errcode = '22023';
  end if;
  select r.id into v_reading from public.club_readings r where r.club_id = p_club and r.status = 'current';
  if v_reading is null then raise exception 'no_reading' using errcode = 'P0001'; end if;
  select w.week_no into v_week from public.club_weeks w
   where w.reading_id = v_reading and p_chapter between w.from_chapter and w.to_chapter;
  insert into public.club_posts (club_id, author_id, kind, chapter_index, ref_page, quote_text, quote_color,
                                 reading_id, week_no, spoiler_ratio, spoiler_page)
  values (p_club, v_me, 'shared_highlight', p_chapter - 1, p_page, btrim(p_quote), upper(p_color),
          v_reading, v_week, round(p_ratio, 4), p_page)
  returning id into v_id;
  return v_id;
end $$;

-- 10. Privilégios -------------------------------------------------------------------------
revoke all on public.club_readings, public.club_weeks, public.meeting_rsvps, public.meeting_notes,
  public.club_likes from public, anon, authenticated;
grant select on public.club_readings, public.club_weeks, public.meeting_rsvps, public.meeting_notes,
  public.club_likes to authenticated;
grant insert (target_type, target_id, user_id) on public.club_likes to authenticated;
grant delete on public.club_likes to authenticated;
grant insert (category, color, progress_colors, spoiler_protection, meeting_weekday, meeting_time, meeting_minutes,
  meeting_mode, timezone) on public.clubs to authenticated;
grant update (category, color, progress_colors, spoiler_protection, meeting_weekday, meeting_time, meeting_minutes,
  meeting_mode, timezone) on public.clubs to authenticated;
revoke update on public.club_members from authenticated;
grant insert (reading_id, week_no, spoiler_ratio, spoiler_page) on public.club_posts to authenticated;
grant insert (parent_reply_id, spoiler_ratio, spoiler_page, quote_text, quote_color, quote_page)
  on public.club_post_replies to authenticated;
grant all on public.club_readings, public.club_weeks, public.meeting_rsvps, public.meeting_notes,
  public.club_likes to service_role;

revoke execute on function
  private.club_member_color(), private.meeting_from_week(), private.club_member_left(),
  private.club_post_reading_check(), private.club_like_set_club(), private.club_likes_counter(),
  private.initial_of(text), private.block_set(uuid), private.next_meeting_id(uuid), private.current_week_no(uuid),
  private.week_range_json(public.club_weeks), private.person_json(uuid, uuid, uuid),
  private.visible_replies(uuid, integer, uuid[]), private.visible_children(uuid, integer, uuid[]),
  private.club_unread(uuid, uuid, timestamptz, uuid[], uuid, integer), private.group_progress(uuid),
  private.rsvp_counts(uuid), private.reading_json(uuid), private.meeting_json(uuid, uuid),
  private.question_json(public.club_posts, uuid, uuid[], timestamptz), private.spoiler_json(numeric, integer),
  private.shared_json(public.club_posts, uuid, uuid[]), private.reply_json(public.club_post_replies, uuid, uuid[]),
  private.week_card_json(public.club_weeks, uuid, uuid[], timestamptz),
  public.create_club(jsonb), public.create_invite(uuid, integer, integer), public.revoke_invite(text),
  public.publish_progress(uuid, numeric, integer), public.mark_club_read(uuid),
  public.set_rsvp(uuid, text, text, text), public.suggest_question(uuid, integer, text),
  public.order_questions(uuid, integer, uuid[]), public.set_question_status(uuid, text, text),
  public.share_highlight(uuid, text, text, integer, integer, numeric),
  public.my_clubs(), public.club_overview(uuid), public.week_thread(uuid, integer, text, uuid, jsonb, integer),
  public.meeting_overview(uuid), public.club_members_overview(uuid), public.club_post_summaries(uuid[])
  from public, anon, authenticated;
-- a coluna gerada quote_key roda como quem insere
revoke execute on function private.quote_key(text) from public, anon;
grant execute on function private.quote_key(text) to authenticated, service_role;
grant execute on function
  public.create_club(jsonb), public.create_invite(uuid, integer, integer), public.revoke_invite(text),
  public.publish_progress(uuid, numeric, integer), public.mark_club_read(uuid),
  public.set_rsvp(uuid, text, text, text), public.suggest_question(uuid, integer, text),
  public.order_questions(uuid, integer, uuid[]), public.set_question_status(uuid, text, text),
  public.share_highlight(uuid, text, text, integer, integer, numeric),
  public.my_clubs(), public.club_overview(uuid), public.week_thread(uuid, integer, text, uuid, jsonb, integer),
  public.meeting_overview(uuid), public.club_members_overview(uuid), public.club_post_summaries(uuid[])
  to authenticated, service_role;

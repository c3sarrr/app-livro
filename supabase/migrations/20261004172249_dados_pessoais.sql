-- =====================================================================================
-- BookNest · migration 05 — dados pessoais (Pro). Mesmas colunas das tabelas do SQLite do
-- aparelho (teste de contrato test/core/data/contracts/personal_columns_contract_test.dart).
-- Origem: SQL §4 + §7 (parte pessoal).
-- Toda referência entre tabelas pessoais é por chave COMPOSTA (id, user_id): FKs não passam
-- por RLS, então sem isso um usuário poderia apontar para a linha de outro.
-- Grátis: NUNCA chega aqui (só SQLite no aparelho). Escrita só pela RPC sync_apply_changes.
-- =====================================================================================

create table personal.user_books (
  id                    uuid primary key,
  user_id               uuid not null references auth.users(id) on delete cascade,
  edition_id            uuid references catalog.editions(id) on delete set null,
  title                 text not null check (char_length(title) between 1 and 500),
  author_display        text not null check (char_length(author_display) between 1 and 500),
  format                text not null check (format in ('epub','pdf','physical')),
  status                text not null check (status in ('want_to_read','reading','finished','abandoned')),
  content_sha256        text check (content_sha256 ~ '^[0-9a-f]{64}$'),
  file_bytes            bigint check (file_bytes >= 0),
  storage_object_path   text,                         -- e-book na nuvem (Pro, opcional, cota 2 GB)
  ref_pages_total       integer check (ref_pages_total > 0),
  ref_page_version      smallint,
  chapters_total        integer check (chapters_total > 0),
  cover_ref             text,
  rating                smallint check (rating between 1 and 5),
  added_at              timestamptz not null,
  started_at            timestamptz,
  finished_at           timestamptz,
  last_opened_at        timestamptz,
  created_at            timestamptz not null,
  updated_at            timestamptz not null,
  deleted_at            timestamptz,
  version_hlc           text not null,
  unique (id, user_id)
);
create index user_books_user_idx on personal.user_books (user_id, updated_at);
create unique index user_books_user_sha_uq on personal.user_books (user_id, content_sha256)
  where content_sha256 is not null and deleted_at is null;
create index user_books_edition_idx on personal.user_books (edition_id);

-- id = user_book_id (1 posição por livro)
create table personal.reading_positions (
  id            uuid primary key,
  user_id       uuid not null references auth.users(id) on delete cascade,
  locator       jsonb not null check (jsonb_typeof(locator) = 'object'),   -- Anexo 03 §5
  ref_page      integer not null check (ref_page > 0),
  chapter_index integer not null check (chapter_index >= 0),
  progression   numeric(6,5) not null check (progression between 0 and 1),
  device_id     text,
  created_at    timestamptz not null,
  updated_at    timestamptz not null,
  deleted_at    timestamptz,
  version_hlc   text not null,
  foreign key (id, user_id) references personal.user_books (id, user_id) on delete cascade
);
create index reading_positions_user_idx on personal.reading_positions (user_id, updated_at);

-- Particionada por mês. SEM partição default: sessão fora das partições existentes é
-- recusada pela RPC (que valida o intervalo antes). Partições: histórica 2024–2025 + mensais
-- a partir de 2026-01, sempre com 3 meses de folga (private.ensure_session_partitions).
create table personal.reading_sessions (
  id              uuid not null,
  user_id         uuid not null references auth.users(id) on delete cascade,
  user_book_id    uuid not null,
  started_at      timestamptz not null,
  ended_at        timestamptz not null,
  active_seconds  integer not null check (active_seconds between 0 and 86400),
  ref_page_from   integer,
  ref_page_to     integer,
  pages_viewed    integer check (pages_viewed >= 0),
  source          text not null check (source in ('auto','timer','manual')),
  device_id       text,
  created_at      timestamptz not null,
  updated_at      timestamptz not null,
  deleted_at      timestamptz,
  version_hlc     text not null,
  primary key (id, started_at),
  check (ended_at >= started_at),
  foreign key (user_book_id, user_id) references personal.user_books (id, user_id) on delete cascade
) partition by range (started_at);
create index reading_sessions_user_idx on personal.reading_sessions (user_id, started_at desc);
create index reading_sessions_id_idx on personal.reading_sessions (id);
create index reading_sessions_book_idx on personal.reading_sessions (user_book_id, user_id);
create table personal.reading_sessions_hist partition of personal.reading_sessions
  for values from ('2024-01-01') to ('2026-01-01');

create table personal.bookmarks (
  id             uuid primary key,
  user_id        uuid not null references auth.users(id) on delete cascade,
  user_book_id   uuid not null,
  locator        jsonb not null check (jsonb_typeof(locator) = 'object'),
  ref_page       integer not null check (ref_page > 0),
  chapter_index  integer not null check (chapter_index >= 0),
  excerpt        text check (char_length(excerpt) <= 280),
  created_at     timestamptz not null,
  updated_at     timestamptz not null,
  deleted_at     timestamptz,
  version_hlc    text not null,
  foreign key (user_book_id, user_id) references personal.user_books (id, user_id) on delete cascade
);
create index bookmarks_user_idx on personal.bookmarks (user_id, updated_at);
create index bookmarks_book_idx on personal.bookmarks (user_book_id, user_id, ref_page) where deleted_at is null;

-- Camadas de tinta: traços sobre o texto (ancorados em palavras) ou dentro de um espaço aberto
create table personal.ink_layers (
  id             uuid primary key,
  user_id        uuid not null references auth.users(id) on delete cascade,
  user_book_id   uuid not null,
  kind           text not null check (kind in ('over_text','space')),
  anchor         jsonb not null check (jsonb_typeof(anchor) = 'object'),
  space_lines    smallint check (space_lines between 1 and 12),          -- D-41
  collapsed      boolean not null default false,
  strokes_b64    text not null,                       -- codec BNK1 em base64 (Anexo 03 §9.6)
  stroke_count   integer not null check (stroke_count >= 0),
  codec_version  smallint not null default 1,
  created_at     timestamptz not null,
  updated_at     timestamptz not null,
  deleted_at     timestamptz,
  version_hlc    text not null,
  unique (id, user_id),
  foreign key (user_book_id, user_id) references personal.user_books (id, user_id) on delete cascade,
  check ((kind = 'space') = (space_lines is not null)),
  check (octet_length(strokes_b64) <= 349528)          -- ≈ 256 KiB binários
);
create index ink_layers_user_idx on personal.ink_layers (user_id, updated_at);
create index ink_layers_book_idx on personal.ink_layers (user_book_id, user_id) where deleted_at is null;

-- Grifos, notas, notas à mão e desenhos (cada item conta 1 no "Tudo 12" da tela 25)
create table personal.annotations (
  id                   uuid primary key,
  user_id              uuid not null references auth.users(id) on delete cascade,
  user_book_id         uuid not null,
  kind                 text not null check (kind in ('highlight','note','handwriting','drawing')),
  parent_id            uuid,
  group_id             uuid not null,                  -- um cartão da tela 25 = um grupo
  source               text not null default 'selection' check (source in ('selection','ink')),
  anchor               jsonb not null check (jsonb_typeof(anchor) = 'object'),
  ref_page             integer not null check (ref_page > 0),
  chapter_index        integer not null check (chapter_index >= 0),
  color                text check (color ~ '^#[0-9A-F]{6}$'),
  style                text check (style in ('fill','underline','wavy')),
  fill_height          text check (fill_height in ('low','medium','high')),
  note_text            text check (char_length(note_text) <= 10000),
  ink_layer_id         uuid,
  shared_club_post_id  uuid references public.club_posts(id) on delete set null,
  created_at           timestamptz not null,
  updated_at           timestamptz not null,
  deleted_at           timestamptz,
  version_hlc          text not null,
  unique (id, user_id),
  foreign key (user_book_id, user_id) references personal.user_books (id, user_id) on delete cascade,
  foreign key (parent_id, user_id) references personal.annotations (id, user_id) on delete cascade,
  foreign key (ink_layer_id, user_id) references personal.ink_layers (id, user_id) on delete cascade,
  check ((kind = 'note') = (note_text is not null)),
  check (kind not in ('handwriting','drawing') or ink_layer_id is not null),
  check (kind <> 'highlight' or (color is not null and style is not null))
);
create index annotations_user_idx on personal.annotations (user_id, updated_at);
create index annotations_book_page_idx on personal.annotations (user_book_id, user_id, ref_page) where deleted_at is null;
create index annotations_parent_idx on personal.annotations (parent_id, user_id);
create index annotations_ink_idx on personal.annotations (ink_layer_id, user_id);
create index annotations_shared_idx on personal.annotations (shared_club_post_id);

-- Rótulos das cores do marca-texto ("lindo", "personagem", "ideia", "pro clube")
create table personal.highlight_labels (
  id           uuid primary key,
  user_id      uuid not null references auth.users(id) on delete cascade,
  color        text not null check (color ~ '^#[0-9A-F]{6}$'),
  label        text not null check (char_length(label) between 1 and 24),
  sort         smallint not null default 0,
  created_at   timestamptz not null,
  updated_at   timestamptz not null,
  deleted_at   timestamptz,
  version_hlc  text not null
);
create unique index highlight_labels_user_color_uq on personal.highlight_labels (user_id, color) where deleted_at is null;

-- 1 linha por usuário (id = user_id)
create table personal.reader_settings (
  id            uuid primary key references auth.users(id) on delete cascade,
  user_id       uuid not null references auth.users(id) on delete cascade,
  font_step     smallint not null default 4 check (font_step between 1 and 7),
  font_family   text not null default 'literata' check (font_family in ('literata','lora','figtree','atkinson')),
  paper         text not null default 'creme' check (paper in ('creme','branco','sepia','noite')),
  line_spacing  text not null default 'medio' check (line_spacing in ('justo','medio','solto')),
  margins       text not null default 'media' check (margins in ('estreita','media','larga')),
  created_at    timestamptz not null,
  updated_at    timestamptz not null,
  deleted_at    timestamptz,
  version_hlc   text not null,
  check (id = user_id)
);

create table personal.pen_presets (
  id                   uuid primary key references auth.users(id) on delete cascade,
  user_id              uuid not null references auth.users(id) on delete cascade,
  pen_tip              text not null default 'ballpoint' check (pen_tip in ('ballpoint','fountain','brush')),
  pen_width_mm         numeric(3,1) not null default 1.2 check (pen_width_mm between 0.3 and 4.0),  -- slider do arquivo
  pen_color            text not null default '#FF552E' check (pen_color ~ '^#[0-9A-F]{6}$'),
  favorite_colors      jsonb not null default '["#FF552E","#552CB7","#058CD7","#00995E","#F2A815","#1A1714"]',
  stroke_size          text not null default 'medium' check (stroke_size in ('thin','medium','thick')),
  highlighter_style    text not null default 'fill' check (highlighter_style in ('fill','underline','wavy')),
  highlighter_height   text not null default 'medium' check (highlighter_height in ('low','medium','high')),
  highlighter_color    text not null default '#FED170' check (highlighter_color ~ '^#[0-9A-F]{6}$'),
  created_at           timestamptz not null,
  updated_at           timestamptz not null,
  deleted_at           timestamptz,
  version_hlc          text not null,
  check (id = user_id),
  check (jsonb_typeof(favorite_colors) = 'array' and jsonb_array_length(favorite_colors) <= 12)
);

create table personal.reading_goals (
  id                  uuid primary key references auth.users(id) on delete cascade,
  user_id             uuid not null references auth.users(id) on delete cascade,
  daily_minutes       smallint not null default 30 check (daily_minutes between 5 and 600),
  badge_target_days   smallint not null default 7 check (badge_target_days between 1 and 365),
  created_at          timestamptz not null,
  updated_at          timestamptz not null,
  deleted_at          timestamptz,
  version_hlc         text not null,
  check (id = user_id)
);

-- índices das chaves estrangeiras que o rascunho não tinha (G04 — teste 01_estrutura): o
-- DELETE em cascata de um usuário do Auth procura por user_id nestas tabelas.
create index reading_positions_fk_idx on personal.reading_positions (id, user_id);
create unique index reader_settings_user_uq on personal.reader_settings (user_id);
create unique index pen_presets_user_uq on personal.pen_presets (user_id);
create unique index reading_goals_user_uq on personal.reading_goals (user_id);

-- RLS ---------------------------------------------------------------------------------
alter table personal.user_books        enable row level security;
alter table personal.reading_positions enable row level security;
alter table personal.reading_sessions  enable row level security;
alter table personal.bookmarks         enable row level security;
alter table personal.ink_layers        enable row level security;
alter table personal.annotations       enable row level security;
alter table personal.highlight_labels  enable row level security;
alter table personal.reader_settings   enable row level security;
alter table personal.pen_presets       enable row level security;
alter table personal.reading_goals     enable row level security;

-- Dados pessoais: o dono LÊ (defesa em profundidade; o caminho normal é o PowerSync).
-- ESCRITA direta proibida: só pela RPC public.sync_apply_changes (LWW + exige Pro).
create policy own_read on personal.user_books        for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.reading_positions for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.reading_sessions  for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.bookmarks         for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.ink_layers        for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.annotations       for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.highlight_labels  for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.reader_settings   for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.pen_presets       for select to authenticated using (user_id = (select auth.uid()));
create policy own_read on personal.reading_goals     for select to authenticated using (user_id = (select auth.uid()));

-- -------------------------------------------------------------------------------------
-- Permissões (as partições criadas depois — private.ensure_session_partition_for — herdam a
-- RLS e os privilégios pela tabela particionada; consultas diretas numa partição são do
-- service_role)
-- -------------------------------------------------------------------------------------
revoke all on personal.user_books, personal.reading_positions, personal.reading_sessions,
  personal.reading_sessions_hist, personal.bookmarks, personal.ink_layers, personal.annotations,
  personal.highlight_labels, personal.reader_settings, personal.pen_presets, personal.reading_goals
  from public, anon, authenticated;
grant select on personal.user_books, personal.reading_positions, personal.reading_sessions,
  personal.bookmarks, personal.ink_layers, personal.annotations, personal.highlight_labels,
  personal.reader_settings, personal.pen_presets, personal.reading_goals to authenticated;   -- RLS limita ao dono
grant all on personal.user_books, personal.reading_positions, personal.reading_sessions,
  personal.reading_sessions_hist, personal.bookmarks, personal.ink_layers, personal.annotations,
  personal.highlight_labels, personal.reader_settings, personal.pen_presets, personal.reading_goals
  to service_role;

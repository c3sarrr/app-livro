// G02 · S2 — esquema local (espelho de personal.* — Anexo 02 §3.2) e o padrão "local-only → synced"
// do PowerSync: cada tabela existe duas vezes (sincronizada e localOnly) e a troca de esquema só
// troca os NOMES DAS VIEWS, então o app sempre lê/escreve em `user_books`, `annotations`…
//   Grátis (e Pro desconectado): view `t` = localOnly; a sincronizada fica como `inativa_sinc_t`.
//   Pro conectado:              view `t` = sincronizada; a localOnly fica como `inativa_local_t`.
import { Schema, Table, column } from '@powersync/node';

const T = column.text;
const I = column.integer;

// Colunas = SQL de referência (handoff_v2/sql/01_schema_booknest.sql §4), sem `id`.
// uuid/timestamptz/jsonb → TEXT (ISO-8601 UTC; JSON em texto); numeric → TEXT (sem perder precisão);
// boolean/smallint/integer/bigint → INTEGER.
export const COLUNAS = {
  user_books: { user_id: T, edition_id: T, title: T, author_display: T, format: T, status: T,
    content_sha256: T, file_bytes: I, storage_object_path: T, ref_pages_total: I, ref_page_version: I,
    chapters_total: I, cover_ref: T, rating: I, added_at: T, started_at: T, finished_at: T,
    last_opened_at: T, created_at: T, updated_at: T, deleted_at: T, version_hlc: T },
  reading_positions: { user_id: T, locator: T, ref_page: I, chapter_index: I, progression: T,
    device_id: T, created_at: T, updated_at: T, deleted_at: T, version_hlc: T },
  reading_sessions: { user_id: T, user_book_id: T, started_at: T, ended_at: T, active_seconds: I,
    ref_page_from: I, ref_page_to: I, pages_viewed: I, source: T, device_id: T, created_at: T,
    updated_at: T, deleted_at: T, version_hlc: T },
  bookmarks: { user_id: T, user_book_id: T, locator: T, ref_page: I, chapter_index: I, excerpt: T,
    created_at: T, updated_at: T, deleted_at: T, version_hlc: T },
  ink_layers: { user_id: T, user_book_id: T, kind: T, anchor: T, space_lines: I, collapsed: I,
    strokes_b64: T, stroke_count: I, codec_version: I, created_at: T, updated_at: T, deleted_at: T,
    version_hlc: T },
  annotations: { user_id: T, user_book_id: T, kind: T, parent_id: T, group_id: T, source: T,
    anchor: T, ref_page: I, chapter_index: I, color: T, style: T, fill_height: T, note_text: T,
    ink_layer_id: T, shared_club_post_id: T, created_at: T, updated_at: T, deleted_at: T,
    version_hlc: T },
  highlight_labels: { user_id: T, color: T, label: T, sort: I, created_at: T, updated_at: T,
    deleted_at: T, version_hlc: T },
  reader_settings: { user_id: T, font_step: I, font_family: T, paper: T, line_spacing: T,
    margins: T, created_at: T, updated_at: T, deleted_at: T, version_hlc: T },
  pen_presets: { user_id: T, pen_tip: T, pen_width_mm: T, pen_color: T, favorite_colors: T,
    stroke_size: T, highlighter_style: T, highlighter_height: T, highlighter_color: T,
    created_at: T, updated_at: T, deleted_at: T, version_hlc: T },
  reading_goals: { user_id: T, daily_minutes: I, badge_target_days: I, created_at: T,
    updated_at: T, deleted_at: T, version_hlc: T },
};

export const TABELAS = Object.keys(COLUNAS);

// Só locais (Anexo 02 §3.3) — as que o spike usa.
const SO_LOCAIS = {
  sync_rejections: { tabela: T, linha_id: T, motivo: T, codigo: T, em: T, operacao: T },
  kv: { valor: T },
};

/** @param {boolean} pro true = views apontam para as tabelas sincronizadas */
export function esquema(pro) {
  const tabelas = {};
  for (const [t, cols] of Object.entries(COLUNAS)) {
    tabelas[t] = new Table(cols, {
      viewName: pro ? t : `inativa_sinc_${t}`,
      indexes: { por_usuario: ['user_id', 'updated_at'] },
    });
    tabelas[`${t}_local`] = new Table(cols, {
      localOnly: true,
      viewName: pro ? `inativa_local_${t}` : t,
      indexes: { por_usuario: ['user_id', 'updated_at'] },
    });
  }
  for (const [t, cols] of Object.entries(SO_LOCAIS)) {
    tabelas[t] = new Table(cols, { localOnly: true });
  }
  return new Schema(tabelas);
}

export function listaColunas(t) {
  return ['id', ...Object.keys(COLUNAS[t])];
}

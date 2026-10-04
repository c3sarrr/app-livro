// SQL do banco local que o drift não gera sozinho: busca FTS5, fila de upload do Pro e as
// instruções `put`/`delete` das tabelas próprias do PowerSync (ADR-002/003).

/// Colunas sincronizadas de cada tabela pessoal, sem `id` e sem `_extras` (ordem do SQL).
/// Fonte única para os gatilhos da fila, o esquema do PowerSync e o teste de contrato.
const Map<String, List<String>> personalSyncColumns = {
  'user_books': [
    'user_id', 'edition_id', 'title', 'author_display', 'format', 'status', //
    'content_sha256', 'file_bytes', 'storage_object_path', 'ref_pages_total',
    'ref_page_version', 'chapters_total', 'cover_ref', 'rating', 'added_at',
    'started_at', 'finished_at', 'last_opened_at', 'created_at', 'updated_at',
    'deleted_at', 'version_hlc',
  ],
  'reading_positions': [
    'user_id', 'locator', 'ref_page', 'chapter_index', 'progression', //
    'device_id', 'created_at', 'updated_at', 'deleted_at', 'version_hlc',
  ],
  'reading_sessions': [
    'user_id', 'user_book_id', 'started_at', 'ended_at', 'active_seconds', //
    'ref_page_from', 'ref_page_to', 'pages_viewed', 'source', 'device_id',
    'created_at', 'updated_at', 'deleted_at', 'version_hlc',
  ],
  'bookmarks': [
    'user_id', 'user_book_id', 'locator', 'ref_page', 'chapter_index', //
    'excerpt', 'created_at', 'updated_at', 'deleted_at', 'version_hlc',
  ],
  'ink_layers': [
    'user_id', 'user_book_id', 'kind', 'anchor', 'space_lines', 'collapsed', //
    'strokes_b64', 'stroke_count', 'codec_version', 'created_at', 'updated_at',
    'deleted_at', 'version_hlc',
  ],
  'annotations': [
    'user_id', 'user_book_id', 'kind', 'parent_id', 'group_id', 'source', //
    'anchor', 'ref_page', 'chapter_index', 'color', 'style', 'fill_height',
    'note_text', 'ink_layer_id', 'shared_club_post_id', 'created_at',
    'updated_at', 'deleted_at', 'version_hlc',
  ],
  'highlight_labels': [
    'user_id', 'color', 'label', 'sort', 'created_at', 'updated_at', //
    'deleted_at', 'version_hlc',
  ],
  'reader_settings': [
    'user_id', 'font_step', 'font_family', 'paper', 'line_spacing', //
    'margins', 'created_at', 'updated_at', 'deleted_at', 'version_hlc',
  ],
  'pen_presets': [
    'user_id', 'pen_tip', 'pen_width_mm', 'pen_color', 'favorite_colors', //
    'stroke_size', 'highlighter_style', 'highlighter_height',
    'highlighter_color', 'created_at', 'updated_at', 'deleted_at',
    'version_hlc',
  ],
  'reading_goals': [
    'user_id', 'daily_minutes', 'badge_target_days', 'created_at', //
    'updated_at', 'deleted_at', 'version_hlc',
  ],
};

/// Modo de sincronização guardado no `kv` (ADR-002 §3): a fila só cresce no Pro.
const String syncModeKey = 'sync';
const String syncModeFree = 'gratis';
const String syncModePro = 'pro';

/// Valores iniciais do `kv`.
const List<String> kvDefaults = [
  "INSERT OR IGNORE INTO kv (key, value) VALUES ('$syncModeKey', '$syncModeFree')",
];

/// Busca da tela 25 (texto do grifo + texto da nota), sem acento e sem caixa. Linhas apagadas
/// (tombstone) saem do índice. Mantida por gatilhos — vale também para o que chega do servidor.
const List<String> annotationsFtsStatements = [
  'CREATE VIRTUAL TABLE IF NOT EXISTS annotations_fts USING fts5('
      'annotation_id UNINDEXED, user_book_id UNINDEXED, body, '
      'tokenize = "unicode61 remove_diacritics 2")',
  'CREATE TRIGGER IF NOT EXISTS annotations_fts_ai AFTER INSERT ON annotations '
      'WHEN NEW.deleted_at IS NULL BEGIN '
      'INSERT INTO annotations_fts (annotation_id, user_book_id, body) VALUES '
      '(NEW.id, NEW.user_book_id, $_ftsBody); END',
  'CREATE TRIGGER IF NOT EXISTS annotations_fts_au AFTER UPDATE ON annotations BEGIN '
      'DELETE FROM annotations_fts WHERE annotation_id = OLD.id; '
      'INSERT INTO annotations_fts (annotation_id, user_book_id, body) '
      'SELECT NEW.id, NEW.user_book_id, $_ftsBody WHERE NEW.deleted_at IS NULL; END',
];

const String _ftsBody =
    "trim(coalesce(json_extract(NEW.anchor, '\$.quote.exact'), '') || ' ' || "
    "coalesce(NEW.note_text, ''))";

/// Guarda de versão (ADR-003): nenhuma escrita LOCAL grava um `version_hlc` menor que o da linha —
/// senão a edição seria descartada pela RPC (LWW) e o aparelho ficaria divergente. Versão igual passa
/// (o `put` do PowerSync reaplica a mesma versão sem mudar nada).
List<String> versionGuardTriggers() => [
  for (final t in personalSyncColumns.keys)
    'CREATE TRIGGER IF NOT EXISTS ${t}_version_guard BEFORE UPDATE ON $t FOR EACH ROW '
        'WHEN NEW.version_hlc < OLD.version_hlc '
        "BEGIN SELECT RAISE(ABORT, 'version_hlc_regressed'); END",
];

/// Gatilhos da fila de upload: `PUT` com a linha inteira em `powersync_crud`, só no modo Pro e
/// nunca durante a aplicação da própria sincronização. Exigem a conexão do PowerSync.
List<String> syncQueueTriggers() => [
  for (final MapEntry(key: t, value: cols) in personalSyncColumns.entries)
    for (final ev in const ['INSERT', 'UPDATE'])
      'CREATE TRIGGER IF NOT EXISTS ${t}_queue_${ev.toLowerCase()} '
          'AFTER $ev ON $t FOR EACH ROW '
          'WHEN NOT powersync_in_sync_operation() AND '
          "(SELECT value FROM kv WHERE key = '$syncModeKey') = '$syncModePro' "
          "BEGIN INSERT INTO powersync_crud (op, id, type, data) VALUES ('PUT', NEW.id, '$t', "
          'json_object(${cols.map((c) => "'$c', NEW.$c").join(', ')})); END',
];

/// `put` das tabelas próprias: upsert com last-writer-wins pelo `version_hlc` (nunca volta uma
/// versão mais nova do aparelho); o que o app não conhece vai para `_extras`.
String rawTablePutSql(String table) {
  final cols = personalSyncColumns[table]!;
  return 'INSERT INTO $table (id, ${cols.join(', ')}, _extras) '
      'VALUES (?, ${cols.map((_) => '?').join(', ')}, ?) '
      'ON CONFLICT(id) DO UPDATE SET '
      '${cols.map((c) => '$c = excluded.$c').join(', ')}, '
      '_extras = excluded._extras '
      'WHERE excluded.version_hlc >= $table.version_hlc';
}

/// `delete` das tabelas próprias: NÃO apaga — só registra (ADR-003).
String rawTableDeleteSql(String table) =>
    'INSERT INTO sync_ignored_deletes (entity, row_id, received_at) '
    "VALUES ('$table', ?, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))";

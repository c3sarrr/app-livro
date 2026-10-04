// G02 · S2 — o drift como dono do esquema local (tabelas próprias do plano A' — ADR-002/003).
// Duas das 10 tabelas pessoais, com as mesmas colunas do SQL de referência; o resto segue o mesmo molde.
import 'package:drift/drift.dart';

part 'banco.g.dart';

@DataClassName('LivroLinha')
class UserBooks extends Table {
  @override
  String get tableName => 'user_books';
  @override
  bool get isStrict => true;
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get editionId => text().named('edition_id').nullable()();
  TextColumn get title => text()();
  TextColumn get authorDisplay => text().named('author_display')();
  TextColumn get format => text()();
  TextColumn get status => text()();
  TextColumn get contentSha256 => text().named('content_sha256').nullable()();
  IntColumn get fileBytes => integer().named('file_bytes').nullable()();
  TextColumn get storageObjectPath =>
      text().named('storage_object_path').nullable()();
  IntColumn get refPagesTotal =>
      integer().named('ref_pages_total').nullable()();
  IntColumn get refPageVersion =>
      integer().named('ref_page_version').nullable()();
  IntColumn get chaptersTotal => integer().named('chapters_total').nullable()();
  TextColumn get coverRef => text().named('cover_ref').nullable()();
  IntColumn get rating => integer().nullable()();
  TextColumn get addedAt => text().named('added_at')();
  TextColumn get startedAt => text().named('started_at').nullable()();
  TextColumn get finishedAt => text().named('finished_at').nullable()();
  TextColumn get lastOpenedAt => text().named('last_opened_at').nullable()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();
  TextColumn get deletedAt => text().named('deleted_at').nullable()();
  TextColumn get versionHlc => text().named('version_hlc')();

  /// Colunas que o servidor mandou e este app ainda não conhece (parâmetro "Rest" do put).
  TextColumn get extras => text().named('_extras').nullable()();
}

@DataClassName('AnotacaoLinha')
class Annotations extends Table {
  @override
  String get tableName => 'annotations';
  @override
  bool get isStrict => true;
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get userBookId => text().named('user_book_id')();
  TextColumn get kind => text()();
  TextColumn get parentId => text().named('parent_id').nullable()();
  TextColumn get groupId => text().named('group_id')();
  TextColumn get source => text()();
  TextColumn get anchor => text()();
  IntColumn get refPage => integer().named('ref_page')();
  IntColumn get chapterIndex => integer().named('chapter_index')();
  TextColumn get color => text().nullable()();
  TextColumn get style => text().nullable()();
  TextColumn get fillHeight => text().named('fill_height').nullable()();
  TextColumn get noteText => text().named('note_text').nullable()();
  TextColumn get inkLayerId => text().named('ink_layer_id').nullable()();
  TextColumn get sharedClubPostId =>
      text().named('shared_club_post_id').nullable()();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();
  TextColumn get deletedAt => text().named('deleted_at').nullable()();
  TextColumn get versionHlc => text().named('version_hlc')();

  /// Colunas que o servidor mandou e este app ainda não conhece (parâmetro "Rest" do put).
  TextColumn get extras => text().named('_extras').nullable()();
}

/// Colunas sincronizadas (sem `id`), na ordem do SQL — usadas nos gatilhos e no `put`.
const colunasSync = <String, List<String>>{
  'user_books': [
    'user_id', 'edition_id', 'title', 'author_display', 'format', 'status', //
    'content_sha256', 'file_bytes', 'storage_object_path', 'ref_pages_total',
    'ref_page_version', 'chapters_total', 'cover_ref', 'rating', 'added_at',
    'started_at', 'finished_at', 'last_opened_at', 'created_at', 'updated_at',
    'deleted_at', 'version_hlc',
  ],
  'annotations': [
    'user_id', 'user_book_id', 'kind', 'parent_id', 'group_id', 'source', //
    'anchor', 'ref_page', 'chapter_index', 'color', 'style', 'fill_height',
    'note_text', 'ink_layer_id', 'shared_club_post_id', 'created_at',
    'updated_at', 'deleted_at', 'version_hlc',
  ],
};

/// Gatilhos da fila de upload: só no modo 'pro' e nunca durante a aplicação da sincronização.
List<String> gatilhosFila({List<String> extras = const []}) => [
  for (final MapEntry(key: t, value: cs) in colunasSync.entries) ...[
    for (final ev in ['INSERT', 'UPDATE']) ...[
      'DROP TRIGGER IF EXISTS ${t}_fila_${ev.toLowerCase()}',
      'CREATE TRIGGER ${t}_fila_${ev.toLowerCase()} AFTER $ev ON $t FOR EACH ROW '
          "WHEN NOT powersync_in_sync_operation() AND (SELECT valor FROM app_kv WHERE chave = 'sync') = 'pro' "
          "BEGIN INSERT INTO powersync_crud (op, id, type, data) VALUES ('PUT', NEW.id, '$t', json_object("
          "${[...cs, if (t == 'annotations') ...extras].map((c) => "'$c', NEW.$c").join(', ')})); END",
    ],
  ],
];

const ddlApoio = [
  "CREATE TABLE IF NOT EXISTS app_kv (chave TEXT PRIMARY KEY, valor TEXT) STRICT",
  "INSERT OR IGNORE INTO app_kv VALUES ('sync', 'gratis')",
  "CREATE TABLE IF NOT EXISTS remocoes_ignoradas (tabela TEXT, linha_id TEXT, em TEXT)",
  'CREATE VIRTUAL TABLE IF NOT EXISTS annotations_fts USING fts5(id UNINDEXED, texto, '
      'tokenize = "unicode61 remove_diacritics 2")',
  'CREATE TRIGGER IF NOT EXISTS annotations_fts_ins AFTER INSERT ON annotations BEGIN '
      "INSERT INTO annotations_fts (id, texto) VALUES (NEW.id, coalesce(NEW.note_text, '')); END",
  'CREATE TRIGGER IF NOT EXISTS annotations_fts_upd AFTER UPDATE ON annotations BEGIN '
      'DELETE FROM annotations_fts WHERE id = OLD.id; '
      "INSERT INTO annotations_fts (id, texto) VALUES (NEW.id, coalesce(NEW.note_text, '')); END",
];

@DriftDatabase(tables: [UserBooks, Annotations])
class BancoSpike extends _$BancoSpike {
  BancoSpike(super.e, {this.versao = 1});

  final int versao;

  @override
  int get schemaVersion => versao;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final s in [...ddlApoio, ...gatilhosFila()]) {
        await customStatement(s);
      }
    },
    onUpgrade: (m, de, para) async {
      // v2: coluna nova sincronizada (o servidor pode ainda não ter — a RPC ignora chaves desconhecidas)
      if (de < 2) {
        await customStatement('ALTER TABLE annotations ADD COLUMN lang TEXT');
        // o que já chegou do servidor antes de o app conhecer a coluna está em _extras
        await customStatement(
          "UPDATE annotations SET lang = json_extract(_extras, '\$.lang') WHERE _extras IS NOT NULL",
        );
      }
      for (final s in gatilhosFila(extras: para >= 2 ? ['lang'] : [])) {
        await customStatement(s);
      }
    },
  );
}

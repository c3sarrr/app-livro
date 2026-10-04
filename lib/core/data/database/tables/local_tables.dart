// Tabelas só locais (Anexo 02 §3.3) — nunca sincronizadas, nunca enviadas à rede.
// (A busca `annotations_fts` é uma tabela virtual FTS5 criada em `local_sql.dart`.)
import 'package:drift/drift.dart';

import '../codecs.dart';

/// Preferências e estado do app: modo de sync (`sync` = 'gratis' | 'pro'), último HLC,
/// `device_id`, tema `brand`, onboarding visto, último aviso de Pro…
@DataClassName('KvRow')
class Kv extends Table {
  @override
  String get tableName => 'kv';
  @override
  bool get isStrict => true;
  @override
  Set<Column<Object>> get primaryKey => {key};

  TextColumn get key => text()();
  TextColumn get value => text()();
}

/// Caminho do arquivo do livro, tamanho, sha256 e estado do envio à nuvem (Pro).
@DataClassName('LocalFileRow')
class LocalFiles extends Table {
  @override
  String get tableName => 'local_files';
  @override
  bool get isStrict => true;
  @override
  Set<Column<Object>> get primaryKey => {userBookId};

  TextColumn get userBookId => text().named('user_book_id')();
  TextColumn get path => text()();
  IntColumn get bytes => integer()();
  TextColumn get sha256 => text()();
  TextColumn get uploadState =>
      text().named('upload_state').withDefault(const Constant('none'))();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const InstantConverter())();

  @override
  List<String> get customConstraints => [
    "CHECK (upload_state IN ('none','pending','uploading','uploaded','failed'))",
    'CHECK (bytes >= 0)',
  ];
}

/// Por livro: hash do conteúdo, itens do spine, caracteres por item, sumário e mapa de páginas
/// de referência (versão `ref_page_version` — D-19).
@DataClassName('BookContentIndexRow')
class BookContentIndex extends Table {
  @override
  String get tableName => 'book_content_index';
  @override
  bool get isStrict => true;
  @override
  Set<Column<Object>> get primaryKey => {userBookId};

  TextColumn get userBookId => text().named('user_book_id')();
  TextColumn get contentSha256 => text().named('content_sha256')();
  IntColumn get refPageVersion => integer().named('ref_page_version')();
  TextColumn get spineJson => text().named('spine_json')();
  TextColumn get charCountsJson => text().named('char_counts_json')();
  TextColumn get tocJson => text().named('toc_json')();
  TextColumn get refPagesJson => text().named('ref_pages_json')();
  TextColumn get builtAt =>
      text().named('built_at').map(const InstantConverter())();
}

/// Quebras de página por (livro, hash dos ajustes, tamanho da tela, versão das fontes).
@DataClassName('PageLayoutCacheRow')
class PageLayoutCache extends Table {
  @override
  String get tableName => 'page_layout_cache';
  @override
  bool get isStrict => true;
  @override
  Set<Column<Object>> get primaryKey => {
    userBookId,
    settingsHash,
    viewport,
    fontsVersion,
  };

  TextColumn get userBookId => text().named('user_book_id')();
  TextColumn get settingsHash => text().named('settings_hash')();

  /// `<largura>x<altura>@<dpr>` em px lógicos.
  TextColumn get viewport => text()();
  IntColumn get fontsVersion => integer().named('fonts_version')();
  BlobColumn get breaks => blob()();
  TextColumn get createdAt =>
      text().named('created_at').map(const InstantConverter())();
}

/// Respostas de ISBN/busca já vistas, com origem e licença (o que vem de ISBNdb/Google não vai
/// para o catálogo compartilhado — ADR-008).
@DataClassName('CatalogCacheRow')
class CatalogCache extends Table {
  @override
  String get tableName => 'catalog_cache';
  @override
  bool get isStrict => true;
  @override
  Set<Column<Object>> get primaryKey => {key};

  TextColumn get key => text()();
  TextColumn get kind => text()();
  TextColumn get source => text()();
  TextColumn get license => text().nullable()();
  TextColumn get payload => text()();
  TextColumn get fetchedAt =>
      text().named('fetched_at').map(const InstantConverter())();

  @override
  List<String> get customConstraints => [
    "CHECK (kind IN ('isbn','search'))",
    'CHECK (json_valid(payload))',
  ];
}

/// Perfil, clubes, posts recentes (para abrir offline).
@DataClassName('SocialCacheRow')
class SocialCache extends Table {
  @override
  String get tableName => 'social_cache';
  @override
  bool get isStrict => true;
  @override
  Set<Column<Object>> get primaryKey => {key};

  TextColumn get key => text()();
  TextColumn get payload => text()();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const InstantConverter())();

  @override
  List<String> get customConstraints => ['CHECK (json_valid(payload))'];
}

/// Ações sociais feitas offline (publicar post, responder no clube) — reenvio com idempotência
/// (o `id` UUIDv7 é a chave de idempotência no servidor).
@DataClassName('PendingSocialOpRow')
class PendingSocialOps extends Table {
  @override
  String get tableName => 'pending_social_ops';
  @override
  bool get isStrict => true;
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get op => text()();
  TextColumn get payload => text()();
  TextColumn get createdAt =>
      text().named('created_at').map(const InstantConverter())();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().named('last_error').nullable()();

  @override
  List<String> get customConstraints => [
    'CHECK (json_valid(payload))',
    'CHECK (attempts >= 0)',
  ];
}

/// Operações que o servidor recusou (`rejected` da RPC) — diagnóstico e reparo; nunca reenviadas
/// sem correção (Anexo 02 §6.1).
@DataClassName('SyncRejectionRow')
class SyncRejections extends Table {
  @override
  String get tableName => 'sync_rejections';
  @override
  bool get isStrict => true;
  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get id => text()();

  /// Tabela pessoal da linha (`user_books`, `annotations`…).
  TextColumn get entity => text()();
  TextColumn get rowId => text().named('row_id')();
  TextColumn get reason => text()();
  TextColumn get code => text().nullable()();
  TextColumn get operation => text()();
  TextColumn get rejectedAt =>
      text().named('rejected_at').map(const InstantConverter())();
}

/// Remoções vindas da nuvem que o aparelho NÃO aplicou (o `delete` das tabelas próprias do
/// PowerSync só registra — ADR-003: nada pessoal é apagado do aparelho pela sincronização).
@DataClassName('SyncIgnoredDeleteRow')
class SyncIgnoredDeletes extends Table {
  @override
  String get tableName => 'sync_ignored_deletes';
  @override
  bool get isStrict => true;

  IntColumn get seq => integer().autoIncrement()();

  /// Tabela pessoal da linha (`user_books`, `annotations`…).
  TextColumn get entity => text()();
  TextColumn get rowId => text().named('row_id')();
  TextColumn get receivedAt => text().named('received_at')();
}

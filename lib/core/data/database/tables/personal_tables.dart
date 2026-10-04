// Tabelas pessoais do aparelho = espelho de `personal.*` (Anexo 02 §3.2; ADR-002): mesmas colunas
// e os mesmos CHECKs do SQL (handoff_v2/sql/01_schema_booknest.sql §4), escritos
// em SQLite. Tabelas STRICT, uma por entidade ("raw tables" do PowerSync — ADR-003), com a coluna
// local `_extras` (colunas que o servidor mandou e esta versão do app ainda não conhece).
// Sem chaves estrangeiras: o PowerSync aplica as linhas de um checkpoint em qualquer ordem; a
// integridade entre linhas é garantida pelo servidor (FKs compostas) e pelos DAOs.
import 'package:drift/drift.dart';

import '../../../../features/library/domain/user_book.dart';
import '../../../../features/reader/annotations/domain/annotation.dart';
import '../../../../features/reader/annotations/domain/ink_layer.dart';
import '../../../../features/reader/annotations/domain/pen_presets.dart';
import '../../../../features/reader/domain/reader_settings.dart';
import '../../../../features/reader/domain/reading_session.dart';
import '../codecs.dart';

const String _hexColor =
    "GLOB '#[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]'";

/// Colunas comuns (no fim de toda tabela pessoal, como no SQL) + `_extras`.
mixin _Versioned on Table {
  TextColumn get createdAt =>
      text().named('created_at').map(const InstantConverter())();
  TextColumn get updatedAt =>
      text().named('updated_at').map(const InstantConverter())();
  TextColumn get deletedAt =>
      text().named('deleted_at').map(const InstantConverter()).nullable()();
  TextColumn get versionHlc =>
      text().named('version_hlc').map(const HlcConverter())();

  /// Colunas do servidor ainda desconhecidas por esta versão (parâmetro "Rest" do `put`).
  TextColumn get extras => text().named('_extras').nullable()();

  @override
  bool get isStrict => true;
}

@DataClassName('UserBookRow')
@TableIndex(name: 'user_books_user_idx', columns: {#userId, #updatedAt})
class UserBooks extends Table with _Versioned {
  @override
  String get tableName => 'user_books';

  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get userId => text().named('user_id')();
  TextColumn get editionId => text().named('edition_id').nullable()();
  TextColumn get title => text()();
  TextColumn get authorDisplay => text().named('author_display')();
  TextColumn get format =>
      text().map(const CodeConverter(BookFileFormat.fromCode))();
  TextColumn get status =>
      text().map(const CodeConverter(ShelfStatus.fromCode))();
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
  TextColumn get addedAt =>
      text().named('added_at').map(const InstantConverter())();
  TextColumn get startedAt =>
      text().named('started_at').map(const InstantConverter()).nullable()();
  TextColumn get finishedAt =>
      text().named('finished_at').map(const InstantConverter()).nullable()();
  TextColumn get lastOpenedAt =>
      text().named('last_opened_at').map(const InstantConverter()).nullable()();

  @override
  List<String> get customConstraints => [
    'CHECK (length(title) BETWEEN 1 AND 500)',
    'CHECK (length(author_display) BETWEEN 1 AND 500)',
    "CHECK (format IN ('epub','pdf','physical'))",
    "CHECK (status IN ('want_to_read','reading','finished','abandoned'))",
    "CHECK (content_sha256 IS NULL OR (length(content_sha256) = 64 AND content_sha256 NOT GLOB '*[^0-9a-f]*'))",
    'CHECK (file_bytes >= 0)',
    'CHECK (ref_pages_total > 0)',
    'CHECK (chapters_total > 0)',
    'CHECK (rating BETWEEN 1 AND 5)',
  ];
}

/// id = user_book_id (1 posição por livro).
@DataClassName('ReadingPositionRow')
class ReadingPositions extends Table with _Versioned {
  @override
  String get tableName => 'reading_positions';

  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get userId => text().named('user_id')();
  TextColumn get locator => text().map(const LocatorConverter())();
  IntColumn get refPage => integer().named('ref_page')();
  IntColumn get chapterIndex => integer().named('chapter_index')();
  TextColumn get progression => text().map(const DecimalTextConverter(5))();
  TextColumn get deviceId => text().named('device_id').nullable()();

  @override
  List<String> get customConstraints => [
    "CHECK (json_valid(locator) AND json_type(locator) = 'object')",
    'CHECK (ref_page > 0)',
    'CHECK (chapter_index >= 0)',
    'CHECK (CAST(progression AS REAL) BETWEEN 0 AND 1)',
  ];
}

/// No servidor é particionada por mês (PK `(id, started_at)`); aqui, uma tabela só.
@DataClassName('ReadingSessionRow')
@TableIndex(name: 'reading_sessions_book_idx', columns: {#userBookId})
@TableIndex(name: 'reading_sessions_started_idx', columns: {#startedAt})
class ReadingSessions extends Table with _Versioned {
  @override
  String get tableName => 'reading_sessions';

  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get userId => text().named('user_id')();
  TextColumn get userBookId => text().named('user_book_id')();
  TextColumn get startedAt =>
      text().named('started_at').map(const InstantConverter())();
  TextColumn get endedAt =>
      text().named('ended_at').map(const InstantConverter())();
  IntColumn get activeSeconds => integer().named('active_seconds')();
  IntColumn get refPageFrom => integer().named('ref_page_from').nullable()();
  IntColumn get refPageTo => integer().named('ref_page_to').nullable()();
  IntColumn get pagesViewed => integer().named('pages_viewed').nullable()();
  TextColumn get source =>
      text().map(const CodeConverter(SessionSource.fromCode))();
  TextColumn get deviceId => text().named('device_id').nullable()();

  @override
  List<String> get customConstraints => [
    'CHECK (active_seconds BETWEEN 0 AND 86400)',
    'CHECK (pages_viewed >= 0)',
    "CHECK (source IN ('auto','timer','manual'))",
    'CHECK (julianday(ended_at) >= julianday(started_at))',
  ];
}

@DataClassName('BookmarkRow')
@TableIndex(name: 'bookmarks_book_idx', columns: {#userBookId, #refPage})
class Bookmarks extends Table with _Versioned {
  @override
  String get tableName => 'bookmarks';

  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get userId => text().named('user_id')();
  TextColumn get userBookId => text().named('user_book_id')();
  TextColumn get locator => text().map(const LocatorConverter())();
  IntColumn get refPage => integer().named('ref_page')();
  IntColumn get chapterIndex => integer().named('chapter_index')();
  TextColumn get excerpt => text().nullable()();

  @override
  List<String> get customConstraints => [
    "CHECK (json_valid(locator) AND json_type(locator) = 'object')",
    'CHECK (ref_page > 0)',
    'CHECK (chapter_index >= 0)',
    'CHECK (length(excerpt) <= 280)',
  ];
}

/// Camadas de tinta: traços sobre o texto ou dentro de um espaço aberto.
@DataClassName('InkLayerRow')
@TableIndex(name: 'ink_layers_book_idx', columns: {#userBookId})
class InkLayers extends Table with _Versioned {
  @override
  String get tableName => 'ink_layers';

  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get userId => text().named('user_id')();
  TextColumn get userBookId => text().named('user_book_id')();
  TextColumn get kind =>
      text().map(const CodeConverter(InkLayerKind.fromCode))();
  TextColumn get anchor => text().map(const AnchorConverter())();
  IntColumn get spaceLines => integer().named('space_lines').nullable()();
  BoolColumn get collapsed => boolean().withDefault(const Constant(false))();
  TextColumn get strokesB64 => text().named('strokes_b64')();
  IntColumn get strokeCount => integer().named('stroke_count')();
  IntColumn get codecVersion =>
      integer().named('codec_version').withDefault(const Constant(1))();

  @override
  List<String> get customConstraints => [
    "CHECK (kind IN ('over_text','space'))",
    "CHECK (json_valid(anchor) AND json_type(anchor) = 'object')",
    'CHECK (space_lines BETWEEN 1 AND 12)',
    'CHECK (stroke_count >= 0)',
    "CHECK ((kind = 'space') = (space_lines IS NOT NULL))",
    'CHECK (length(strokes_b64) <= 349528)',
  ];
}

/// Grifos, notas, notas à mão e desenhos (cada item conta 1 no "Tudo 12" da tela 25).
@DataClassName('AnnotationRow')
@TableIndex(name: 'annotations_book_page_idx', columns: {#userBookId, #refPage})
@TableIndex(name: 'annotations_parent_idx', columns: {#parentId})
@TableIndex(name: 'annotations_ink_idx', columns: {#inkLayerId})
class Annotations extends Table with _Versioned {
  @override
  String get tableName => 'annotations';

  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get userId => text().named('user_id')();
  TextColumn get userBookId => text().named('user_book_id')();
  TextColumn get kind =>
      text().map(const CodeConverter(AnnotationKind.fromCode))();
  TextColumn get parentId => text().named('parent_id').nullable()();
  TextColumn get groupId => text().named('group_id')();
  TextColumn get source => text()
      .map(const CodeConverter(AnnotationSource.fromCode))
      .withDefault(const Constant('selection'))();
  TextColumn get anchor => text().map(const AnchorConverter())();
  IntColumn get refPage => integer().named('ref_page')();
  IntColumn get chapterIndex => integer().named('chapter_index')();
  TextColumn get color => text().nullable()();
  TextColumn get style =>
      text().map(const CodeConverter(HighlightStyle.fromCode)).nullable()();
  TextColumn get fillHeight => text()
      .named('fill_height')
      .map(const CodeConverter(FillHeight.fromCode))
      .nullable()();
  TextColumn get noteText => text().named('note_text').nullable()();
  TextColumn get inkLayerId => text().named('ink_layer_id').nullable()();
  TextColumn get sharedClubPostId =>
      text().named('shared_club_post_id').nullable()();

  @override
  List<String> get customConstraints => [
    "CHECK (kind IN ('highlight','note','handwriting','drawing'))",
    "CHECK (source IN ('selection','ink'))",
    "CHECK (json_valid(anchor) AND json_type(anchor) = 'object')",
    'CHECK (ref_page > 0)',
    'CHECK (chapter_index >= 0)',
    'CHECK (color $_hexColor)',
    "CHECK (style IN ('fill','underline','wavy'))",
    "CHECK (fill_height IN ('low','medium','high'))",
    'CHECK (length(note_text) <= 10000)',
    "CHECK ((kind = 'note') = (note_text IS NOT NULL))",
    "CHECK (kind NOT IN ('handwriting','drawing') OR ink_layer_id IS NOT NULL)",
    "CHECK (kind <> 'highlight' OR (color IS NOT NULL AND style IS NOT NULL))",
  ];
}

/// Rótulos das cores do marca-texto ("lindo", "personagem", "ideia", "pro clube").
@DataClassName('HighlightLabelRow')
class HighlightLabels extends Table with _Versioned {
  @override
  String get tableName => 'highlight_labels';

  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get userId => text().named('user_id')();
  TextColumn get color => text()();
  TextColumn get label => text()();
  IntColumn get sort => integer().withDefault(const Constant(0))();

  @override
  List<String> get customConstraints => [
    'CHECK (color $_hexColor)',
    'CHECK (length(label) BETWEEN 1 AND 24)',
  ];
}

/// 1 linha por usuário (id = user_id).
@DataClassName('ReaderSettingsRow')
class ReaderSettingsRows extends Table with _Versioned {
  @override
  String get tableName => 'reader_settings';

  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get userId => text().named('user_id')();
  IntColumn get fontStep =>
      integer().named('font_step').withDefault(const Constant(4))();
  TextColumn get fontFamily => text()
      .named('font_family')
      .map(const CodeConverter(ReaderFontFamily.fromCode))
      .withDefault(const Constant('literata'))();
  TextColumn get paper => text()
      .map(const CodeConverter(ReaderPaper.fromCode))
      .withDefault(const Constant('creme'))();
  TextColumn get lineSpacing => text()
      .named('line_spacing')
      .map(const CodeConverter(ReaderLineSpacing.fromCode))
      .withDefault(const Constant('medio'))();
  TextColumn get margins => text()
      .map(const CodeConverter(ReaderMargins.fromCode))
      .withDefault(const Constant('media'))();

  @override
  List<String> get customConstraints => [
    'CHECK (font_step BETWEEN 1 AND 7)',
    "CHECK (font_family IN ('literata','lora','figtree','atkinson'))",
    "CHECK (paper IN ('creme','branco','sepia','noite'))",
    "CHECK (line_spacing IN ('justo','medio','solto'))",
    "CHECK (margins IN ('estreita','media','larga'))",
    'CHECK (id = user_id)',
  ];
}

/// Predefinições da caneta e do marca-texto — 1 linha por usuário (id = user_id).
@DataClassName('PenPresetsRow')
class PenPresetsRows extends Table with _Versioned {
  @override
  String get tableName => 'pen_presets';

  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get userId => text().named('user_id')();
  TextColumn get penTip => text()
      .named('pen_tip')
      .map(const CodeConverter(PenTip.fromCode))
      .withDefault(const Constant('ballpoint'))();
  TextColumn get penWidthMm => text()
      .named('pen_width_mm')
      .map(const DecimalTextConverter(1))
      .withDefault(const Constant('1.2'))();
  TextColumn get penColor =>
      text().named('pen_color').withDefault(const Constant('#FF552E'))();
  TextColumn get favoriteColors => text()
      .named('favorite_colors')
      .map(const StringListConverter())
      .withDefault(
        const Constant(
          '["#FF552E","#552CB7","#058CD7","#00995E","#F2A815","#1A1714"]',
        ),
      )();
  TextColumn get strokeSize => text()
      .named('stroke_size')
      .map(const CodeConverter(StrokeSize.fromCode))
      .withDefault(const Constant('medium'))();
  TextColumn get highlighterStyle => text()
      .named('highlighter_style')
      .map(const CodeConverter(HighlightStyle.fromCode))
      .withDefault(const Constant('fill'))();
  TextColumn get highlighterHeight => text()
      .named('highlighter_height')
      .map(const CodeConverter(FillHeight.fromCode))
      .withDefault(const Constant('medium'))();
  TextColumn get highlighterColor => text()
      .named('highlighter_color')
      .withDefault(const Constant('#FED170'))();

  @override
  List<String> get customConstraints => [
    "CHECK (pen_tip IN ('ballpoint','fountain','brush'))",
    'CHECK (CAST(pen_width_mm AS REAL) BETWEEN 0.3 AND 4.0)',
    'CHECK (pen_color $_hexColor)',
    "CHECK (json_valid(favorite_colors) AND json_type(favorite_colors) = 'array' AND json_array_length(favorite_colors) <= 12)",
    "CHECK (stroke_size IN ('thin','medium','thick'))",
    "CHECK (highlighter_style IN ('fill','underline','wavy'))",
    "CHECK (highlighter_height IN ('low','medium','high'))",
    'CHECK (highlighter_color $_hexColor)',
    'CHECK (id = user_id)',
  ];
}

/// Metas — 1 linha por usuário (id = user_id).
@DataClassName('ReadingGoalsRow')
class ReadingGoalsRows extends Table with _Versioned {
  @override
  String get tableName => 'reading_goals';

  TextColumn get id => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  TextColumn get userId => text().named('user_id')();
  IntColumn get dailyMinutes =>
      integer().named('daily_minutes').withDefault(const Constant(30))();
  IntColumn get badgeTargetDays =>
      integer().named('badge_target_days').withDefault(const Constant(7))();

  @override
  List<String> get customConstraints => [
    'CHECK (daily_minutes BETWEEN 5 AND 600)',
    'CHECK (badge_target_days BETWEEN 1 AND 365)',
    'CHECK (id = user_id)',
  ];
}

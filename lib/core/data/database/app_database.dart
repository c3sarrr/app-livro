// Banco local do aparelho (ADR-002): drift é o dono do esquema, das migrações e dos gatilhos;
// roda sobre a conexão do SDK do PowerSync (`SqliteAsyncDriftConnection`) no app, ou sobre um
// SQLite em memória nos testes (`withSyncQueue: false` — sem as funções do PowerSync).
import 'package:drift/drift.dart';

// Tipos usados pelo código gerado (`app_database.g.dart` — mesma biblioteca).
import '../../../features/library/domain/user_book.dart';
import '../../../features/reader/annotations/domain/annotation.dart';
import '../../../features/reader/annotations/domain/ink_layer.dart';
import '../../../features/reader/annotations/domain/pen_presets.dart';
import '../../../features/reader/domain/locator.dart';
import '../../../features/reader/domain/reader_settings.dart';
import '../../../features/reader/domain/reading_session.dart';
import '../clock/hlc.dart';
import 'codecs.dart';
import 'local_sql.dart';
import 'tables/local_tables.dart';
import 'tables/personal_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserBooks,
    ReadingPositions,
    ReadingSessions,
    Bookmarks,
    InkLayers,
    Annotations,
    HighlightLabels,
    ReaderSettingsRows,
    PenPresetsRows,
    ReadingGoalsRows,
    Kv,
    LocalFiles,
    BookContentIndex,
    PageLayoutCache,
    CatalogCache,
    SocialCache,
    PendingSocialOps,
    SyncRejections,
    SyncIgnoredDeletes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e, {this.withSyncQueue = true});

  /// `true` no app (conexão do PowerSync): cria os gatilhos da fila de upload do Pro.
  final bool withSyncQueue;

  /// v2 (G07, D-77): `user_books.isbn13` + índice.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final s in [...kvDefaults, ...annotationsFtsStatements]) {
        await customStatement(s);
      }
    },
    // Migrações nunca destrutivas: no Grátis o aparelho guarda a única cópia (§4.3.6).
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(userBooks, userBooks.isbn13);
        await m.createIndex(userBooksUserIsbnIdx);
        // o que o servidor já mandou antes desta versão ficou em `_extras`: vira a coluna
        await customStatement(
          "UPDATE user_books SET isbn13 = json_extract(_extras, '\$.isbn13'), "
          "_extras = nullif(json_remove(_extras, '\$.isbn13'), '{}') "
          "WHERE _extras IS NOT NULL AND json_valid(_extras) "
          "AND json_type(_extras, '\$.isbn13') = 'text'",
        );
      }
    },
    // a guarda de versão e a fila do Pro são recriadas a cada abertura (a regra pode mudar sem nova
    // versão do esquema)
    beforeOpen: (details) async {
      for (final s in [
        ...versionGuardRefresh(),
        if (withSyncQueue) ...syncQueueTriggerRefresh(),
      ]) {
        await customStatement(s);
      }
    },
  );
}

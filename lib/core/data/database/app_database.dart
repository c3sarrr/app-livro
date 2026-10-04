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

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final s in [
        ...kvDefaults,
        ...annotationsFtsStatements,
        ...versionGuardTriggers(),
        if (withSyncQueue) ...syncQueueTriggers(),
      ]) {
        await customStatement(s);
      }
    },
  );
}

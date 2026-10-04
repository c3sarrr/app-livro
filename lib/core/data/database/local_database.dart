// Abre o banco do aparelho (ADR-002): SQLite do SDK do PowerSync + drift por cima, num arquivo da
// pasta de suporte do app (não é a de documentos do usuário). Os testes trocam por um banco em memória.
import 'dart:io' show Platform;

import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart' show PowerSyncDatabase;

import 'app_database.dart';
import 'powersync_schema.dart';

/// Nome do arquivo do banco local.
const String localDatabaseFile = 'booknest.db';

final localDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final dir = await getApplicationSupportDirectory();
  final ps = PowerSyncDatabase(
    schema: buildPowerSyncSchema(),
    path: '${dir.path}${Platform.pathSeparator}$localDatabaseFile',
  );
  await ps.initialize();
  final db = AppDatabase(SqliteAsyncDriftConnection(ps));
  ref.onDispose(() async {
    await db.close();
    await ps.close();
  });
  return db;
});

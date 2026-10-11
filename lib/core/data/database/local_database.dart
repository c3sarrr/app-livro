// Abre o banco do aparelho (ADR-002): SQLite do SDK do PowerSync + drift por cima, num arquivo da
// pasta de suporte do app (não é a de documentos do usuário). Os testes trocam por um banco em memória.
// A mesma conexão do PowerSync é a da sincronização do Pro (G06 — `lib/core/sync`).
import 'dart:io' show Platform;

import 'package:drift_sqlite_async/drift_sqlite_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart' show PowerSyncDatabase;

import 'app_database.dart';
import 'powersync_schema.dart';

/// Nome do arquivo do banco local.
const String localDatabaseFile = 'booknest.db';

/// A conexão do SDK do PowerSync (fila de upload, sincronização e o SQLite do app).
final powerSyncDatabaseProvider = FutureProvider<PowerSyncDatabase>((
  ref,
) async {
  final dir = await getApplicationSupportDirectory();
  final ps = PowerSyncDatabase(
    schema: buildPowerSyncSchema(),
    path: '${dir.path}${Platform.pathSeparator}$localDatabaseFile',
  );
  await ps.initialize();
  ref.onDispose(ps.close);
  return ps;
});

final localDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final ps = await ref.watch(powerSyncDatabaseProvider.future);
  final db = AppDatabase(SqliteAsyncDriftConnection(ps));
  ref.onDispose(db.close);
  return db;
});

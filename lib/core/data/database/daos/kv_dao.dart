import 'package:drift/drift.dart';

import '../app_database.dart';

/// Chave/valor do aparelho (`kv`, só local).
final class KvDao {
  KvDao(this._db);

  final AppDatabase _db;

  Future<String?> get(String key) async {
    final r = await (_db.select(
      _db.kv,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return r?.value;
  }

  Stream<String?> watch(String key) => (_db.select(
    _db.kv,
  )..where((t) => t.key.equals(key))).map((r) => r.value).watchSingleOrNull();

  Future<void> set(String key, String value) => _db
      .into(_db.kv)
      .insertOnConflictUpdate(
        KvCompanion(key: Value(key), value: Value(value)),
      );
}

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

  /// As chaves que começam com [prefix] (o texto exato, sem curinga) e os valores delas, na ordem das chaves.
  Future<List<(String, String)>> withPrefix(String prefix) async {
    final rows = await _db
        .customSelect(
          'SELECT key, value FROM kv WHERE substr(key, 1, ?) = ? ORDER BY key',
          variables: [
            Variable.withInt(prefix.length),
            Variable.withString(prefix),
          ],
          readsFrom: {_db.kv},
        )
        .get();
    return [
      for (final r in rows) (r.read<String>('key'), r.read<String>('value')),
    ];
  }

  /// Apaga a chave [key] (a que não existe não faz nada).
  Future<void> delete(String key) =>
      (_db.delete(_db.kv)..where((t) => t.key.equals(key))).go();
}

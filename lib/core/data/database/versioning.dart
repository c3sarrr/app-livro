import 'package:drift/drift.dart';

import '../clock/hlc.dart';
import 'app_database.dart';
import 'daos/kv_dao.dart';
import 'local_sql.dart';

/// Porta única das versões das escritas locais (ADR-003): `receive` da versão atual da linha
/// (se existir) antes do `send`, e o último HLC fica guardado no `kv` para sobreviver a
/// reinícios e a relógios que voltam.
final class LocalVersioning {
  LocalVersioning(this._db, this.clock);

  static const String lastHlcKey = 'hlc.last';

  final AppDatabase _db;
  final HlcClock clock;

  /// Relógio do aparelho retomado do último HLC salvo.
  static Future<LocalVersioning> open(
    AppDatabase db, {
    required String deviceId,
    int Function()? nowMs,
  }) async {
    final saved = await KvDao(db).get(lastHlcKey);
    return LocalVersioning(
      db,
      HlcClock(
        deviceId: deviceId,
        nowMs: nowMs,
        last: saved == null ? null : Hlc.parse(saved),
      ),
    );
  }

  /// Versão para gravar a linha [id] de [table] (uma das 10 tabelas pessoais).
  Future<Hlc> next(String table, String id) async {
    if (!personalSyncColumns.containsKey(table)) {
      throw ArgumentError.value(table, 'table', 'não é tabela pessoal');
    }
    final row = await _db
        .customSelect(
          'SELECT version_hlc FROM $table WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    final version = clock.sendAfterReading([row?.read<String>('version_hlc')]);
    await KvDao(_db).set(lastHlcKey, version.toString());
    return version;
  }
}

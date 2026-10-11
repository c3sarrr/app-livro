import 'package:drift/drift.dart';

import '../clock/hlc.dart';
import 'app_database.dart';
import 'daos/kv_dao.dart';
import 'local_sql.dart';

/// Porta única das versões das escritas locais (ADR-003): `receive` da versão atual da linha
/// (se existir) antes do `send`, e o último HLC fica guardado no `kv` para sobreviver a
/// reinícios e a relógios que voltam. Use [write]: ler a versão, gerar a nova e gravar acontecem na
/// MESMA transação — o PowerSync não aplica nada do servidor no meio (escritas são serializadas), e o
/// gatilho `<tabela>_version_guard` recusa qualquer versão menor que a gravada.
final class LocalVersioning {
  LocalVersioning(this._db, this.clock);

  static const String lastHlcKey = 'hlc.last';

  /// A RPC recusa HLC mais de 5 min à frente do relógio do servidor (`invalid_hlc`).
  static const int maxFutureMs = 5 * 60 * 1000;

  final AppDatabase _db;
  final HlcClock clock;

  /// Relógio do aparelho retomado do último HLC salvo. Um HLC salvo mais de [maxFutureMs] à frente
  /// do relógio é ignorado (ficou de um período com o relógio adiantado; a RPC recusaria tudo até o
  /// tempo real alcançá-lo) — a ordem por linha continua garantida pelo `receive` da versão lida.
  static Future<LocalVersioning> open(
    AppDatabase db, {
    required String deviceId,
    int Function()? nowMs,
  }) async {
    final agora = (nowMs ?? () => DateTime.now().millisecondsSinceEpoch)();
    final salvo = await KvDao(db).get(lastHlcKey);
    final ultimo = salvo == null ? null : Hlc.parse(salvo);
    return LocalVersioning(
      db,
      HlcClock(
        deviceId: deviceId,
        nowMs: nowMs,
        last: ultimo != null && ultimo.ms <= agora + maxFutureMs
            ? ultimo
            : null,
        maxDriftMs: maxFutureMs,
      ),
    );
  }

  /// Versão para gravar a linha [id] de [table] (uma das 10 tabelas pessoais). Prefira [write].
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
    // guarda o relógio do aparelho (não a versão de uma linha que ficou no futuro)
    await KvDao(_db).set(lastHlcKey, (clock.last ?? version).toString());
    return version;
  }

  /// Lê a versão atual, gera a nova e grava ([save]) numa transação só.
  Future<T> write<T>(
    String table,
    String id,
    Future<T> Function(Hlc version) save,
  ) => _db.transaction(() async => save(await next(table, id)));
}

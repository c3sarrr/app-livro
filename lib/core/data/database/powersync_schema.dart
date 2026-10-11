import 'package:powersync/powersync.dart';

import 'local_sql.dart';

/// Esquema do PowerSync (ADR-003): só tabelas próprias ("raw tables") — o drift é o dono das
/// tabelas; o PowerSync só cuida da fila de upload e de aplicar o que vem do servidor com as
/// instruções `put` (LWW) e `delete` (não apaga) de `local_sql.dart`.
Schema buildPowerSyncSchema() => Schema(
  const [],
  rawTables: [
    for (final MapEntry(key: table, value: cols) in personalSyncColumns.entries)
      RawTable(
        name: table,
        put: PendingStatement(
          sql: rawTablePutSql(table),
          params: [
            const PendingStatementValue.id(),
            for (final c in cols) PendingStatementValue.column(c),
            const PendingStatementValue.rest(),
          ],
        ),
        delete: PendingStatement(
          sql: rawTableDeleteSql(table),
          params: const [PendingStatementValue.id()],
        ),
      ),
  ],
);

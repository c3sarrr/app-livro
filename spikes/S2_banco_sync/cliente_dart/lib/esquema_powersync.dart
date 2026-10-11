// G02 · S2 — esquema PowerSync do plano A': só tabelas próprias ("raw tables").
//   put    = upsert com LWW pelo version_hlc;
//   delete = NÃO apaga (o modelo só usa exclusão lógica): registra a remoção vinda da nuvem;
//   colunas ainda desconhecidas pelo app → `_extras` ("Rest"), recuperadas na migração.
import 'package:powersync/powersync.dart';

import 'banco.dart';

Schema esquemaPowerSync({List<String> extras = const []}) => Schema(
  const [],
  rawTables: [
    for (final MapEntry(key: t, value: cs0) in colunasSync.entries)
      () {
        final cs = [...cs0, if (t == 'annotations') ...extras];
        return RawTable(
          name: t,
          put: PendingStatement(
            sql:
                'INSERT INTO $t (id, ${cs.join(', ')}, _extras) VALUES (?, ${cs.map((_) => '?').join(', ')}, ?) '
                'ON CONFLICT(id) DO UPDATE SET ${cs.map((c) => '$c = excluded.$c').join(', ')}, _extras = excluded._extras '
                'WHERE excluded.version_hlc >= $t.version_hlc',
            params: [
              const PendingStatementValue.id(),
              for (final c in cs) PendingStatementValue.column(c),
              const PendingStatementValue.rest(),
            ],
          ),
          delete: PendingStatement(
            sql:
                "INSERT INTO remocoes_ignoradas (tabela, linha_id, em) VALUES ('$t', ?, datetime('now'))",
            params: const [PendingStatementValue.id()],
          ),
        );
      }(),
  ],
);

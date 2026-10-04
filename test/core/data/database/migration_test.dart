// G03.3 — migrações do banco local (Anexo 02 §3.5): o esquema atual tem de ser exatamente o
// instantâneo da versão corrente em `drift_schemas/` (gerado por `drift_dev schema dump`). Mudou uma
// tabela sem subir `schemaVersion` e sem gravar o novo instantâneo → este teste falha. A cada versão
// nova, os testes de migração de TODAS as versões anteriores entram aqui (`schema generate`).
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('esquema atual = instantâneo da versão 1', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase(schema.newConnection(), withSyncQueue: false);
    expect(db.schemaVersion, 1);
    await verifier.migrateAndValidate(db, 1);
    await db.close();
  });
}

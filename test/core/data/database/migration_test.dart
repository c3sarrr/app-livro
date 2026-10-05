// G03.3 — migrações do banco local (Anexo 02 §3.5): o esquema atual tem de ser exatamente o
// instantâneo da versão corrente em `drift_schemas/` (gerado por `drift_dev schema dump`). Mudou uma
// tabela sem subir `schemaVersion` e sem gravar o novo instantâneo → este teste falha. A cada versão
// nova, os testes de migração de TODAS as versões anteriores entram aqui (`schema generate`).
// G07 (D-77): v2 = `user_books.isbn13` (+ índice); a migração nunca perde dado (§4.3.6).
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

const _livro =
    "INSERT INTO user_books (id, user_id, title, author_display, format, status, added_at, "
    "created_at, updated_at, version_hlc, _extras) VALUES ("
    "'01927a00-0000-7000-8000-000000000b01', '00000000-0000-7000-8000-00000000000a', "
    "'Dom Casmurro', 'Machado de Assis', 'physical', 'reading', '2026-10-01T12:00:00.000Z', "
    "'2026-10-01T12:00:00.000Z', '2026-10-01T12:00:00.000Z', "
    "'0001790000000000-0000-a', ?)";

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('esquema atual = instantâneo da versão 2', () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase(schema.newConnection(), withSyncQueue: false);
    expect(db.schemaVersion, 2);
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test(
    'v1 → v2: esquema igual ao de uma instalação nova, sem perder linhas',
    () async {
      final schema = await verifier.schemaAt(1);
      schema.rawDatabase.execute(_livro, [null]);
      final db = AppDatabase(schema.newConnection(), withSyncQueue: false);
      await verifier.migrateAndValidate(db, 2);
      final r = await db
          .customSelect('SELECT title, isbn13, _extras FROM user_books')
          .getSingle();
      expect(r.read<String>('title'), 'Dom Casmurro');
      expect(r.read<String?>('isbn13'), isNull);
      expect(r.read<String?>('_extras'), isNull);
      await db.close();
    },
  );

  test('v1 → v2: o isbn13 que o servidor já mandou (guardado em `_extras`) vira a coluna', () async {
    final schema = await verifier.schemaAt(1);
    schema.rawDatabase.execute(_livro, ['{"isbn13":"9788535914849","novo":1}']);
    final db = AppDatabase(schema.newConnection(), withSyncQueue: false);
    await verifier.migrateAndValidate(db, 2);
    final r = await db
        .customSelect('SELECT isbn13, _extras FROM user_books')
        .getSingle();
    expect(r.read<String?>('isbn13'), '9788535914849');
    expect(r.read<String?>('_extras'), '{"novo":1}');
    await db.close();
  });

  test(
    'v2: isbn13 fora do formato é recusado pelo CHECK (como no servidor)',
    () async {
      final schema = await verifier.schemaAt(2);
      final db = AppDatabase(schema.newConnection(), withSyncQueue: false);
      await expectLater(
        db.customStatement(
          _livro
              .replaceFirst('_extras)', 'isbn13, _extras)')
              .replaceFirst(', ?)', ", '978-85-359-1484-9', NULL)"),
        ),
        throwsA(anything),
      );
      await db.close();
    },
  );
}

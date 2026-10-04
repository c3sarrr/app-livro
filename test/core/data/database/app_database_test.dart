// G03.3 — esquema local em memória: tabelas, STRICT, `_extras`, CHECKs do SQL e busca FTS5.
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/local_sql.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false));
  tearDown(() => db.close());

  Future<List<String>> nomes(String tipo) async => [
    for (final r
        in await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = ? AND name NOT LIKE 'sqlite_%' ORDER BY name",
              variables: [Variable.withString(tipo)],
            )
            .get())
      r.read<String>('name'),
  ];

  Future<void> sql(String s) => db.customStatement(s);

  test('as 10 tabelas pessoais + as só locais + FTS5 existem', () async {
    final tabelas = await nomes('table');
    expect(tabelas, containsAll(personalSyncColumns.keys));
    expect(
      tabelas,
      containsAll([
        'kv',
        'local_files',
        'book_content_index',
        'page_layout_cache',
        'catalog_cache',
        'social_cache',
        'pending_social_ops',
        'sync_rejections',
        'sync_ignored_deletes',
        'annotations_fts',
      ]),
    );
    final r = await db
        .customSelect(
          "SELECT sqlite_version() v, (SELECT value FROM kv WHERE key = 'sync') m",
        )
        .getSingle();
    expect(
      r.read<String>('m'),
      'gratis',
    ); // Grátis por padrão: a fila nunca cresce
  });

  test('tabelas pessoais: STRICT, colunas do SQL + `_extras`', () async {
    for (final MapEntry(key: t, value: cols) in personalSyncColumns.entries) {
      final info = await db.customSelect('PRAGMA table_info($t)').get();
      final colunas = [for (final c in info) c.read<String>('name')];
      expect(colunas.toSet(), {'id', ...cols, '_extras'}, reason: t);
      final ddl = await db
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = ?",
            variables: [Variable.withString(t)],
          )
          .getSingle();
      expect(ddl.read<String>('sql'), endsWith('STRICT'), reason: t);
    }
  });

  group('CHECKs do SQL valem no aparelho', () {
    const u = usuarioTeste;
    const ts = "'2026-09-20T23:00:00.000000Z'";
    const v = "'0001789945200000-0000-aparelhoA'";
    const comuns = "created_at, updated_at, version_hlc) VALUES";
    const valores = '$ts, $ts, $v)';

    Future<void> recusa(String insert) async {
      await expectLater(sql(insert), throwsA(isA<SqliteException>()));
    }

    test('user_books: título vazio, formato e nota inválidos, sha fora do padrão', () async {
      String livro(String extra, String vals) =>
          "INSERT INTO user_books (id, user_id, title, author_display, format, status$extra, added_at, $comuns "
          "('${idTeste(1)}', '$u', $vals, $ts, $valores";
      await sql(livro('', "'Dom Casmurro', 'Machado', 'epub', 'reading'"));
      await recusa(livro('', "'', 'Machado', 'epub', 'reading'"));
      await recusa(livro('', "'X', 'Machado', 'mobi', 'reading'"));
      await recusa(livro('', "'X', 'Machado', 'epub', 'lendo'"));
      await recusa(livro(', rating', "'X', 'Machado', 'epub', 'reading', 6"));
      await recusa(
        livro(', content_sha256', "'X', 'Machado', 'epub', 'reading', 'ABC'"),
      );
    });

    test('annotations: nota sem texto, grifo sem cor, cor minúscula, tinta sem camada', () async {
      String anotacao(String colunas, String vals) =>
          'INSERT INTO annotations (id, user_id, user_book_id, kind, group_id, anchor, ref_page, chapter_index$colunas, $comuns '
          "('${idTeste(9)}', '$u', '${idTeste(1)}', $vals, $valores";
      const ancora = "'{\"v\":1}'";
      final g = "'${idTeste(5)}'";
      await recusa(anotacao('', "'note', $g, $ancora, 1, 0"));
      await recusa(
        anotacao(', style', "'highlight', $g, $ancora, 1, 0, 'fill'"),
      );
      await recusa(
        anotacao(
          ', color, style',
          "'highlight', $g, $ancora, 1, 0, '#fed170', 'fill'",
        ),
      );
      await recusa(
        anotacao(', color', "'drawing', $g, $ancora, 1, 0, '#FF552E'"),
      );
      await recusa(
        anotacao(
          ', color, style',
          "'highlight', $g, '[]', 1, 0, '#FED170', 'fill'",
        ),
      );
      await sql(
        anotacao(
          ', color, style',
          "'highlight', $g, $ancora, 1, 0, '#FED170', 'fill'",
        ),
      );
    });

    test('ink_layers, reader_settings, pen_presets, reading_goals, reading_sessions', () async {
      await recusa(
        'INSERT INTO ink_layers (id, user_id, user_book_id, kind, anchor, strokes_b64, stroke_count, $comuns '
        "('${idTeste(3)}', '$u', '${idTeste(1)}', 'space', '{}', '', 0, $valores",
      );
      await recusa(
        'INSERT INTO reader_settings (id, user_id, $comuns '
        "('${idTeste(1)}', '$u', $valores",
      );
      await recusa(
        'INSERT INTO pen_presets (id, user_id, pen_width_mm, $comuns '
        "('$u', '$u', '5.0', $valores",
      );
      await recusa(
        'INSERT INTO pen_presets (id, user_id, favorite_colors, $comuns '
        "('$u', '$u', '${List.filled(13, '"#FF552E"')}', $valores",
      );
      await recusa(
        'INSERT INTO reading_goals (id, user_id, daily_minutes, $comuns '
        "('$u', '$u', 4, $valores",
      );
      await recusa(
        'INSERT INTO reading_sessions (id, user_id, user_book_id, started_at, ended_at, active_seconds, source, $comuns '
        "('${idTeste(4)}', '$u', '${idTeste(1)}', '2026-09-20T23:00:00.000000Z', "
        "'2026-09-20T22:59:59.000000Z', 0, 'auto', $valores",
      );
      // os padrões do SQL valem para as linhas de 1 por usuário
      await sql(
        'INSERT INTO reader_settings (id, user_id, $comuns '
        "('$u', '$u', $valores",
      );
      final r = await db
          .customSelect('SELECT * FROM reader_settings')
          .getSingle();
      expect(r.data, containsPair('font_step', 4));
      expect(r.data, containsPair('paper', 'creme'));
    });
  });
}

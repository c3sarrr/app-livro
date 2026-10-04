// Junta duas linhas que o servidor não aceita lado a lado (índices únicos parciais de `personal.*`):
// dois livros ativos com o mesmo arquivo, ou dois rótulos ativos da mesma cor. Acontece quando o
// convidado e a conta têm o mesmo livro neste aparelho (G05 → G06) ou quando outro aparelho já
// mandou o mesmo arquivo/cor para a nuvem (o servidor recusa o 2º com 23505).
//
// A linha que fica ([survivor]) é a que o servidor já tem (ou a da conta); da outra ([loser]) vale
// o que for mais novo (LWW pelo `version_hlc`) e o que pendura nela passa para a que fica. A [loser]
// nunca esteve no servidor, então sai do aparelho de verdade (não é exclusão lógica).
// Chame dentro de uma transação.
import 'package:drift/drift.dart';

import '../data/database/app_database.dart';

/// Colunas do livro que seguem a versão mais nova (estado de leitura e metadados). As do arquivo
/// (`content_sha256`, `file_bytes`, páginas de referência, capítulos) são as mesmas nas duas — mesmo
/// arquivo; `storage_object_path` fica o da que já está no servidor.
const List<String> mergedBookColumns = [
  'edition_id', 'title', 'author_display', 'format', 'status', 'cover_ref', //
  'rating', 'added_at', 'started_at', 'finished_at', 'last_opened_at',
  'updated_at', 'version_hlc',
];

/// Tabelas que apontam para o livro por `user_book_id`.
const List<String> bookChildTables = [
  'annotations',
  'bookmarks',
  'ink_layers',
  'reading_sessions',
];

/// O que a junção mexeu.
final class BookMerge {
  const BookMerge({required this.movedRows, required this.removedFiles});

  /// Linhas pessoais que passaram a apontar para o livro que fica (`tabela` → ids).
  final Map<String, List<String>> movedRows;

  /// Arquivos do livro que saíram (apagar depois da transação).
  final List<String> removedFiles;
}

Future<BookMerge> mergeUserBook(
  AppDatabase db, {
  required String loser,
  required String survivor,
}) async {
  final cols = mergedBookColumns.join(', ');
  await db.customStatement(
    'UPDATE user_books SET ($cols) = (SELECT $cols FROM user_books WHERE id = ?1) '
    'WHERE id = ?2 AND version_hlc < (SELECT version_hlc FROM user_books WHERE id = ?1)',
    [loser, survivor],
  );

  // posição de leitura: id = id do livro; fica a mais nova
  await db.customStatement(
    'DELETE FROM reading_positions WHERE id = ?2 AND version_hlc < '
    '(SELECT version_hlc FROM reading_positions WHERE id = ?1)',
    [loser, survivor],
  );
  await db.customStatement(
    'DELETE FROM reading_positions WHERE id = ?1 AND EXISTS '
    '(SELECT 1 FROM reading_positions WHERE id = ?2)',
    [loser, survivor],
  );
  final moved = <String, List<String>>{};
  final pos = await _ids(db, 'reading_positions', 'id', loser);
  if (pos.isNotEmpty) {
    await db.customStatement(
      'UPDATE reading_positions SET id = ? WHERE id = ?',
      [survivor, loser],
    );
    moved['reading_positions'] = [survivor];
  }

  for (final t in bookChildTables) {
    final ids = await _ids(db, t, 'user_book_id', loser);
    if (ids.isEmpty) continue;
    await db.customStatement(
      'UPDATE $t SET user_book_id = ? WHERE user_book_id = ?',
      [survivor, loser],
    );
    moved[t] = ids;
  }

  // arquivos e caches do aparelho: ficam os do livro que fica; os da outra vão para ele se faltarem
  final removed = <String>[];
  final paths = await db
      .customSelect(
        'SELECT user_book_id, path FROM local_files WHERE user_book_id IN (?, ?)',
        variables: [Variable.withString(loser), Variable.withString(survivor)],
      )
      .get();
  String? pathOf(String id) => paths
      .where((r) => r.read<String>('user_book_id') == id)
      .map((r) => r.read<String>('path'))
      .firstOrNull;
  final mine = pathOf(loser);
  final theirs = pathOf(survivor);
  for (final t in const [
    'local_files',
    'book_content_index',
    'page_layout_cache',
  ]) {
    await db.customStatement(
      'UPDATE OR IGNORE $t SET user_book_id = ? WHERE user_book_id = ?',
      [survivor, loser],
    );
    await db.customStatement('DELETE FROM $t WHERE user_book_id = ?', [loser]);
  }
  if (mine != null && theirs != null && mine != theirs) removed.add(mine);

  await db.customStatement('DELETE FROM user_books WHERE id = ?', [loser]);
  return BookMerge(movedRows: moved, removedFiles: removed);
}

/// Dois rótulos ativos da mesma cor: fica o [survivor], com o nome/ordem mais novos.
Future<void> mergeHighlightLabel(
  AppDatabase db, {
  required String loser,
  required String survivor,
}) async {
  const cols = 'label, sort, updated_at, version_hlc';
  await db.customStatement(
    'UPDATE highlight_labels SET ($cols) = (SELECT $cols FROM highlight_labels WHERE id = ?1) '
    'WHERE id = ?2 AND version_hlc < (SELECT version_hlc FROM highlight_labels WHERE id = ?1)',
    [loser, survivor],
  );
  await db.customStatement('DELETE FROM highlight_labels WHERE id = ?', [
    loser,
  ]);
}

Future<List<String>> _ids(
  AppDatabase db,
  String table,
  String column,
  String value,
) async => [
  for (final r
      in await db
          .customSelect(
            'SELECT id FROM $table WHERE $column = ?',
            variables: [Variable.withString(value)],
          )
          .get())
    r.read<String>('id'),
];

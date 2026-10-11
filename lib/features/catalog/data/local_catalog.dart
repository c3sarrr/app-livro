// Camada do aparelho (Anexo 02 §7.2): `catalog.db` baixado — os livros mais lidos, só leitura no uso
// normal; o delta mensal é aplicado numa transação e conferido pelo hash do conteúdo (mesmo cálculo do
// pipeline `tools/catalog/catalogo/catalogo_db.py::hash_conteudo`).
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../domain/catalog_book.dart';
import '../domain/catalog_failure.dart';

abstract interface class LocalCatalog {
  /// Versão do catálogo no aparelho (`meta.versao`).
  Future<String?> version();

  Future<CatalogBook?> byIsbn(String isbn13);

  /// Busca por título e autores (FTS5, sem acento).
  Future<List<CatalogBook>> search(String text, {int limit = 20});

  /// Edições cujo campo de autores tem todas as palavras de [author] (FTS5 só na coluna de autores, palavra
  /// inteira, sem acento) — "Para você" confere o nome exato depois (G08, D-81). A ordem sai do banco antes
  /// do [limit]: [language] (ISO 639-2/B), com capa, mais nova — autor com muitas edições não perde as da língua
  /// do aparelho para o limite.
  Future<List<CatalogBook>> byAuthor(
    String author, {
    String? language,
    int limit = 200,
  });

  Future<void> close();
}

/// Colunas de `editions` na ordem do hash (pipeline: `COLUNAS_DB`).
const List<String> _hashColumns = [
  'isbn13', 'title', 'subtitle', 'authors', 'publisher', 'year', 'pages', //
  'language', 'cover_ref', 'source', 'source_license',
];

final class SqliteLocalCatalog implements LocalCatalog {
  SqliteLocalCatalog._(this._db);

  /// Diário clássico (DELETE), não WAL: o arquivo é quase só leitura, o delta mensal é uma única
  /// transação e nada de `-wal`/`-shm` fica ao lado do arquivo (a troca da versão é um `rename`).
  static const SqliteOptions options = SqliteOptions(
    journalMode: SqliteJournalMode.delete,
    maxReaders: 1,
  );

  /// Abre o arquivo; falha (`CatalogCorrupted`) se não for um catálogo do formato 1.
  static Future<SqliteLocalCatalog> open(String path) async {
    final db = SqliteDatabase(path: path, options: options);
    try {
      final f = await db.getOptional(
        "SELECT value FROM meta WHERE key = 'formato'",
      );
      if (f == null || f['value'] != '1') {
        throw const CatalogCorrupted('formato');
      }
    } on CatalogFailure {
      await _closeQuietly(db);
      rethrow;
    } on Object {
      await _closeQuietly(db);
      throw const CatalogCorrupted('ilegivel');
    }
    return SqliteLocalCatalog._(db);
  }

  /// Fechar um arquivo que nem abriu (não é SQLite) também falha — o motivo já é o ilegível.
  static Future<void> _closeQuietly(SqliteDatabase db) async {
    try {
      await db.close();
    } on Object {
      // nada a fazer
    }
  }

  final SqliteDatabase _db;

  static CatalogBook _book(Map<String, Object?> r) => CatalogBook(
    isbn13: r['isbn13'] as String,
    title: r['title'] as String,
    subtitle: r['subtitle'] as String?,
    authors: [
      for (final a in jsonDecode(r['authors'] as String) as List<Object?>)
        if (a is String) a,
    ],
    publisher: r['publisher'] as String?,
    year: r['year'] as int?,
    pages: r['pages'] as int?,
    language: r['language'] as String?,
    coverRef: r['cover_ref'] as String?,
    source: r['source'] as String,
    license: r['source_license'] as String?,
  );

  @override
  Future<String?> version() async =>
      (await _db.getOptional(
            "SELECT value FROM meta WHERE key = 'versao'",
          ))?['value']
          as String?;

  Future<Map<String, String>> meta() async => {
    for (final r in await _db.getAll('SELECT key, value FROM meta'))
      r['key'] as String: r['value'] as String,
  };

  @override
  Future<CatalogBook?> byIsbn(String isbn13) async {
    final r = await _db.getOptional('SELECT * FROM editions WHERE isbn13 = ?', [
      isbn13,
    ]);
    return r == null ? null : _book(r);
  }

  /// Termos do usuário → consulta FTS5 segura (cada palavra entre aspas, prefixo, todas exigidas).
  static String? ftsQuery(String text) {
    final words = RegExp(r'[\p{L}\p{N}]+', unicode: true)
        .allMatches(text)
        .map((m) => m[0]!)
        .where((w) => w.isNotEmpty)
        .take(8)
        .toList();
    if (words.isEmpty) return null;
    return words.map((w) => '"$w"*').join(' ');
  }

  @override
  Future<List<CatalogBook>> search(String text, {int limit = 20}) async {
    final q = ftsQuery(text);
    if (q == null) return const [];
    final rows = await _db.getAll(
      'SELECT e.* FROM editions_fts f JOIN editions e ON e.id = f.rowid '
      'WHERE editions_fts MATCH ? ORDER BY rank LIMIT ?',
      [q, limit.clamp(1, 50)],
    );
    return [for (final r in rows) _book(r)];
  }

  /// Nome → consulta FTS5 restrita à coluna `authors` (cada palavra entre aspas, todas exigidas).
  static String? authorQuery(String author) {
    final words = RegExp(
      r'[\p{L}\p{N}]+',
      unicode: true,
    ).allMatches(author).map((m) => m[0]!).take(8).toList();
    if (words.isEmpty) return null;
    return words.map((w) => 'authors : "$w"').join(' AND ');
  }

  @override
  Future<List<CatalogBook>> byAuthor(
    String author, {
    String? language,
    int limit = 200,
  }) async {
    final q = authorQuery(author);
    if (q == null) return const [];
    final rows = await _db.getAll(
      'SELECT e.* FROM editions_fts f JOIN editions e ON e.id = f.rowid '
      'WHERE editions_fts MATCH ? '
      'ORDER BY (e.language = ?) DESC, (e.cover_ref IS NOT NULL) DESC, '
      'coalesce(e.year, -1) DESC, e.isbn13 LIMIT ?',
      [q, language, limit.clamp(1, 500)],
    );
    return [for (final r in rows) _book(r)];
  }

  /// sha256 do conteúdo (o mesmo do manifesto: `db.conteudo_sha256`).
  Future<String> contentSha256() => contentHash(_db);

  /// sha256 do conteúdo em ordem de ISBN (páginas de 5.000 linhas — o banco tem centenas de milhares).
  static Future<String> contentHash(SqliteReadContext db) async {
    final out = _Acumulador<Digest>();
    final input = sha256.startChunkedConversion(out);
    var after = '';
    final cols = _hashColumns.join(', ');
    for (;;) {
      final rows = await db.getAll(
        'SELECT $cols FROM editions WHERE isbn13 > ? ORDER BY isbn13 LIMIT 5000',
        [after],
      );
      if (rows.isEmpty) break;
      for (final r in rows) {
        final line = [for (final c in _hashColumns) r[c]?.toString() ?? '']
            .join('\x1f');
        input.add(utf8.encode('$line\n'));
      }
      after = rows.last['isbn13'] as String;
    }
    input.close();
    return out.events.single.toString();
  }

  /// Aplica um delta (linhas JSON já descomprimidas) numa transação: confere o hash esperado da
  /// versão nova ANTES de gravar — qualquer diferença desfaz tudo.
  Future<void> applyDelta(
    Iterable<String> lines, {
    required String expectedFrom,
    required String expectedTo,
    required String expectedContentSha256,
  }) async {
    await _db.writeTransaction((tx) async {
      final it = lines.iterator;
      if (!it.moveNext()) throw const CatalogCorrupted('delta_vazio');
      final header = jsonDecode(it.current) as Map<String, Object?>;
      final current = (await tx.getOptional(
        "SELECT value FROM meta WHERE key = 'versao'",
      ))?['value'];
      if (header['de'] != expectedFrom ||
          header['para'] != expectedTo ||
          current != expectedFrom) {
        throw const CatalogCorrupted('delta_versao');
      }
      while (it.moveNext()) {
        final line = it.current;
        if (line.isEmpty) continue;
        final op = jsonDecode(line) as Map<String, Object?>;
        if (op['op'] == 'del') {
          await tx.execute('DELETE FROM editions WHERE isbn13 = ?', [op['i']]);
          continue;
        }
        final r = op['r']! as Map<String, Object?>;
        await tx.execute(
          'INSERT INTO editions (isbn13, title, subtitle, authors, publisher, year, pages, language, '
          'cover_ref, source, source_license) VALUES (?,?,?,?,?,?,?,?,?,?,?) '
          'ON CONFLICT(isbn13) DO UPDATE SET title = excluded.title, subtitle = excluded.subtitle, '
          'authors = excluded.authors, publisher = excluded.publisher, year = excluded.year, '
          'pages = excluded.pages, language = excluded.language, cover_ref = excluded.cover_ref, '
          'source = excluded.source, source_license = excluded.source_license',
          [
            r['i'],
            r['t'],
            r['s'],
            jsonEncode(r['a'] ?? const []),
            r['p'],
            r['y'],
            r['n'],
            r['l'],
            r['c'],
            r['f'],
            r['lic'],
          ],
        );
      }
      final hash = await contentHash(tx);
      if (hash != expectedContentSha256) {
        throw const CatalogCorrupted('delta_hash');
      }
      final count = (await tx.get('SELECT count(*) AS n FROM editions'))['n'];
      for (final (k, v) in [
        ('versao', expectedTo),
        ('conteudo_sha256', hash),
        ('registros', '$count'),
      ]) {
        await tx.execute(
          'INSERT OR REPLACE INTO meta (key, value) VALUES (?, ?)',
          [k, v],
        );
      }
    });
  }

  @override
  Future<void> close() => _db.close();
}

/// Junta os resultados de uma conversão em pedaços (sha256 sem guardar o texto inteiro).
final class _Acumulador<T> implements Sink<T> {
  final List<T> events = [];

  @override
  void add(T event) => events.add(event);

  @override
  void close() {}
}

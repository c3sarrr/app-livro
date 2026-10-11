// R00 (D-267, D-269) — o catálogo do aparelho no modo demonstração: um `catalog.db` só do demo, no formato 1 do
// pipeline (`tools/catalog/catalogo/catalogo_db.py`: `meta`, `editions`, o FTS5 de título e autores e os gatilhos), com
// as edições que o "Para você" do mundo sugere, e o atualizador que nunca vai à rede (o demo não liga o serviço do
// catálogo — a rede dele é "nenhuma" e o cliente recusa qualquer pedido). Sem flutter_test.
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/features/catalog/application/catalog_providers.dart'
    show catalogDirProvider, catalogUpdaterProvider;
import 'package:app_leitura/features/catalog/application/catalog_updater.dart';
import 'package:app_leitura/features/catalog/data/local_catalog.dart';
import 'package:app_leitura/features/home/application/home_providers.dart'
    show clockProvider;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:http/http.dart' as http;
import 'package:sqlite_async/sqlite_async.dart';

typedef EdicaoDoDemo = ({
  String isbn13,
  String titulo,
  String editora,
  int ano,
  int paginas,
});

/// O autor das edições do catálogo do demo (o do "Porque você lê…" da prancha 01).
const String autorDoCatalogoDoDemo = 'Machado de Assis';

/// As edições do catálogo do demo: romances de Machado de Assis que a estante do mundo não tem, nas edições da
/// Penguin-Companhia (ISBN, ano e páginas das fichas da editora — um ISBN inventado traria pelo Open Library a capa de
/// outro livro). A prancha 01 sugere Esaú e Jacó, Memorial de Aires e Casa de Pensão; a regra da G08 sugere de um
/// autor só (D-81), então a Casa de Pensão (Aluísio Azevedo) dá lugar ao Quincas Borba.
const List<EdicaoDoDemo> edicoesDoDemo = [
  (
    isbn13: '9788563560544',
    titulo: 'Esaú e Jacó',
    editora: 'Penguin-Companhia',
    ano: 2012,
    paginas: 296,
  ),
  (
    isbn13: '9788582852378',
    titulo: 'Memorial de Aires',
    editora: 'Penguin-Companhia',
    ano: 2022,
    paginas: 256,
  ),
  (
    isbn13: '9788563560520',
    titulo: 'Quincas Borba',
    editora: 'Penguin-Companhia',
    ano: 2012,
    paginas: 360,
  ),
];

/// A versão (`meta.versao`) do catálogo do demo.
const String versaoDoCatalogoDoDemo = 'demonstracao-r00';

/// O esquema do formato 1, na ordem do pipeline (o FTS mantido pelos gatilhos desde o primeiro INSERT).
const List<String> _esquema = [
  'CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL) WITHOUT ROWID',
  'CREATE TABLE editions ('
      'id INTEGER PRIMARY KEY, '
      'isbn13 TEXT NOT NULL UNIQUE CHECK (length(isbn13) = 13), '
      'title TEXT NOT NULL, subtitle TEXT, authors TEXT NOT NULL, publisher TEXT, year INTEGER, pages INTEGER, '
      'language TEXT, cover_ref TEXT, source TEXT NOT NULL, source_license TEXT NOT NULL)',
  "CREATE VIRTUAL TABLE editions_fts USING fts5(title, authors, content='editions', content_rowid='id', "
      "tokenize='unicode61 remove_diacritics 2')",
  'CREATE TRIGGER editions_ai AFTER INSERT ON editions BEGIN '
      'INSERT INTO editions_fts(rowid, title, authors) VALUES (new.id, new.title, new.authors); END',
  'CREATE TRIGGER editions_ad AFTER DELETE ON editions BEGIN '
      "INSERT INTO editions_fts(editions_fts, rowid, title, authors) VALUES ('delete', old.id, old.title, "
      'old.authors); END',
  'CREATE TRIGGER editions_au AFTER UPDATE ON editions BEGIN '
      "INSERT INTO editions_fts(editions_fts, rowid, title, authors) VALUES ('delete', old.id, old.title, "
      'old.authors); '
      'INSERT INTO editions_fts(rowid, title, authors) VALUES (new.id, new.title, new.authors); END',
];

/// O arquivo do catálogo em [dir] (o mesmo nome que o `CatalogUpdater` abre).
File arquivoDoCatalogo(Directory dir) =>
    File('${dir.path}${Platform.pathSeparator}catalog.db');

/// Grava o catálogo do demo em [dir] se ainda não houver um. Escreve ao lado e troca de uma vez (um catálogo pela
/// metade nunca é aberto).
Future<void> semearCatalogoSeFaltar(Directory dir) async {
  final arquivo = arquivoDoCatalogo(dir);
  if (arquivo.existsSync()) return;
  dir.createSync(recursive: true);
  final novo = File('${arquivo.path}.semeando');
  for (final s in ['', '-journal']) {
    final f = File('${novo.path}$s');
    if (f.existsSync()) f.deleteSync();
  }
  final db = SqliteDatabase(
    path: novo.path,
    options: SqliteLocalCatalog.options,
  );
  try {
    await db.writeTransaction((tx) async {
      for (final s in _esquema) {
        await tx.execute(s);
      }
      for (final e in edicoesDoDemo) {
        await tx.execute(
          'INSERT INTO editions (isbn13, title, subtitle, authors, publisher, year, pages, language, cover_ref, '
          'source, source_license) VALUES (?, ?, NULL, ?, ?, ?, ?, ?, NULL, ?, ?)',
          [
            e.isbn13,
            e.titulo,
            jsonEncode([autorDoCatalogoDoDemo]),
            e.editora,
            e.ano,
            e.paginas,
            'por',
            'demonstracao',
            'CC0-1.0',
          ],
        );
      }
      final meta = {
        'formato': '1',
        'versao': versaoDoCatalogoDoDemo,
        'criado_em': '2026-09-20T00:00:00Z',
        'registros': '${edicoesDoDemo.length}',
        'conteudo_sha256': await SqliteLocalCatalog.contentHash(tx),
        'fontes': '[]',
      };
      for (final m in meta.entries) {
        await tx.execute('INSERT INTO meta VALUES (?, ?)', [m.key, m.value]);
      }
    });
  } finally {
    await db.close();
  }
  novo.renameSync(arquivo.path);
}

/// O cliente do catálogo no demo: recusa qualquer pedido (o demo não fala com o serviço do catálogo).
final class SemRedeNoDemo extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(
    http.BaseRequest request,
  ) async => throw StateError(
    'O modo demonstração não vai à rede do catálogo (D-267): ${request.url}',
  );
}

/// O atualizador do catálogo no demo: abre o catálogo semeado na pasta do demo; a rede é sempre "nenhuma", então o
/// `update()` termina em "sem_rede" sem pedir nada.
final Override catalogoDaDemonstracao = catalogUpdaterProvider.overrideWith((
  ref,
) async {
  final db = await ref.watch(localDatabaseProvider.future);
  final dir = await ref.watch(catalogDirProvider.future);
  await semearCatalogoSeFaltar(dir);
  final u = CatalogUpdater(
    client: SemRedeNoDemo(),
    base: Uri.parse('https://catalogo.demonstracao.invalid/'),
    dir: dir,
    network: () async => NetworkKind.none,
    kv: KvDao(db),
    now: ref.watch(clockProvider),
  );
  ref.onDispose(u.close);
  return u;
});

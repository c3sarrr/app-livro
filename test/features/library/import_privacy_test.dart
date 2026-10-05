// G09 — lista branca do Grátis (§4.3.7, D-91) na importação, pela pilha real (importador → resolvedor → Worker
// sobre um cliente HTTP que grava cada pedido): do arquivo, só o ISBN sai do aparelho — título, autor, nome do
// arquivo, conteúdo e o resto da estante não; sem ISBN, nenhum pedido; nunca a comunidade nem a consulta externa.
import 'dart:io';

import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/features/catalog/application/isbn_resolver.dart';
import 'package:app_leitura/features/catalog/data/catalog_cache_dao.dart';
import 'package:app_leitura/features/catalog/data/edge_catalog_api.dart';
import 'package:app_leitura/features/library/application/book_importer.dart';
import 'package:app_leitura/features/library/data/pdf_inspector.dart';
import 'package:app_leitura/features/library/domain/import_outcome.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support/epub_builder.dart';
import '../../support/personal_builders.dart';

final class _Pdf implements PdfInspector {
  @override
  Future<PdfInfo> inspect(String path) async => const PdfInfo(
    pages: 2,
    title: 'Relatório Secreto',
    author: 'Pessoa Real',
  );
}

Future<T> _aqui<T>(T Function() task) async => task();

void main() {
  test(
    'importar manda só o ISBN ao Worker; sem ISBN (ou PDF), nada sai',
    () async {
      final raiz = Directory.systemTemp.createTempSync('booknest_priv_');
      final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
      addTearDown(() async {
        await db.close();
        raiz.deleteSync(recursive: true);
      });
      // a estante já tem um livro que não pode sair do aparelho
      await UserBooksDao(db).upsert(livroTeste(1, title: 'Diário Íntimo'));
      final pedidos = <http.Request>[];
      final worker = MockClient((r) async {
        pedidos.add(r);
        return http.Response('{"encontrado":false}', 404);
      });
      final importador = BookImporter(
        db: db,
        versioning: LocalVersioning(db, HlcClock(deviceId: 'aparelhoA')),
        owner: () async => usuarioTeste,
        booksDir: () async =>
            Directory('${raiz.path}${Platform.pathSeparator}livros'),
        fileCoversDir: () async =>
            Directory('${raiz.path}${Platform.pathSeparator}capas'),
        pdf: _Pdf(),
        catalog: ResolverIsbnLookup(
          IsbnResolver(
            cache: CatalogCacheDao(db),
            localCatalog: () async => null,
            edge: HttpEdgeCatalogApi(
              worker,
              Uri.parse('http://catalogo.teste/'),
            ),
          ),
        ),
        run: _aqui,
      );

      final comIsbn = simpleEpub(
        chapters: const [
          (file: 'c.xhtml', title: 'I', body: '<p>Texto muito pessoal.</p>'),
        ],
        metadata:
            '<dc:title>Minhas Memórias</dc:title><dc:creator>Fulana de Tal</dc:creator>'
            '<dc:identifier>urn:isbn:9788535902778</dc:identifier>',
      );
      expect(
        await importador.importStream(
          Stream.value(comIsbn),
          fileName: 'arquivo-pessoal.epub',
        ),
        isA<Imported>(),
      );
      expect(pedidos.map((r) => '${r.method} ${r.url}'), [
        'GET http://catalogo.teste/v1/isbn/9788535902778',
      ]);
      expect(pedidos.single.body, isEmpty);
      final tudo = '${pedidos.single.url} ${pedidos.single.headers}';
      for (final segredo in [
        'Minhas',
        'Fulana',
        'pessoal',
        'Diário',
        usuarioTeste,
      ]) {
        expect(tudo, isNot(contains(segredo)));
      }

      pedidos.clear();
      await importador.importStream(
        Stream.value(
          simpleEpub(
            title: 'Sem ISBN',
            chapters: const [(file: 'c.xhtml', title: 'I', body: '<p>x</p>')],
          ),
        ),
        fileName: 's.epub',
      );
      await importador.importStream(
        Stream.value(u('%PDF-1.7\n')),
        fileName: 'r.pdf',
      );
      expect(pedidos, isEmpty);
    },
  );
}

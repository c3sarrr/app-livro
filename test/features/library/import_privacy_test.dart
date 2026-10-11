// G09 — lista branca do Grátis (§4.3.7, D-91) na importação, pela montagem real do app (`bookImporterProvider`
// → resolvedor → Worker sobre um cliente HTTP que grava cada pedido), com a comunidade e a consulta externa
// disponíveis e gravando qualquer chamada: do arquivo, só o ISBN sai do aparelho — título, autor, nome do
// arquivo, conteúdo e o resto da estante não; sem ISBN (ou PDF), nenhum pedido; comunidade e consulta externa
// nunca são chamadas.
import 'dart:io';

import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/core/data/clock/hlc.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/core/data/database/versioning.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:app_leitura/features/account/application/account_providers.dart';
import 'package:app_leitura/features/account/data/local_library.dart';
import 'package:app_leitura/features/catalog/application/catalog_providers.dart';
import 'package:app_leitura/features/catalog/data/community_catalog_api.dart';
import 'package:app_leitura/features/catalog/data/external_isbn_api.dart';
import 'package:app_leitura/features/library/application/library_import.dart';
import 'package:app_leitura/features/library/data/pdf_inspector.dart';
import 'package:app_leitura/features/library/domain/import_outcome.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Grava qualquer chamada (e falha): a importação não pode usar nenhuma.
final class _Gravador {
  final List<String> chamadas = [];
}

final class _Comunidade implements CommunityCatalogApi {
  _Comunidade(this._g);

  final _Gravador _g;

  @override
  dynamic noSuchMethod(Invocation i) {
    _g.chamadas.add('comunidade ${i.memberName}');
    return super.noSuchMethod(i);
  }
}

final class _Externa implements ExternalIsbnApi {
  _Externa(this._g);

  final _Gravador _g;

  @override
  dynamic noSuchMethod(Invocation i) {
    _g.chamadas.add('externa ${i.memberName}');
    return super.noSuchMethod(i);
  }
}

void main() {
  test('importar manda só o ISBN ao Worker; sem ISBN (ou PDF), nada sai; comunidade e externa nunca', () async {
    final raiz = Directory.systemTemp.createTempSync('booknest_priv_');
    final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    String pasta(String nome) => '${raiz.path}${Platform.pathSeparator}$nome';
    final pedidos = <http.Request>[];
    final worker = MockClient((r) async {
      pedidos.add(r);
      return http.Response('{"encontrado":false}', 404);
    });
    final gravador = _Gravador();
    final erros = <Object>[];
    final c = ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWith((ref) async => db),
        localLibraryProvider.overrideWith((ref) async => LocalLibrary(db)),
        localVersioningProvider.overrideWith(
          (ref) async => LocalVersioning(db, HlcClock(deviceId: 'aparelhoA')),
        ),
        appEnvProvider.overrideWithValue(
          const AppEnv(catalogUrl: 'http://catalogo.teste/'),
        ),
        catalogHttpClientProvider.overrideWithValue(worker),
        catalogDirProvider.overrideWith(
          (ref) async => Directory(pasta('catalogo')),
        ),
        communityCatalogApiProvider.overrideWithValue(_Comunidade(gravador)),
        externalIsbnApiProvider.overrideWithValue(_Externa(gravador)),
        pdfInspectorProvider.overrideWithValue(_Pdf()),
        booksDirProvider.overrideWithValue(
          () async => Directory(pasta('livros')),
        ),
        fileCoversDirProvider.overrideWithValue(
          () async => Directory(pasta('capas')),
        ),
        libraryErrorReporterProvider.overrideWithValue((e, _) => erros.add(e)),
      ],
    );
    addTearDown(() async {
      c.dispose();
      await db.close();
      raiz.deleteSync(recursive: true);
    });
    await LocalLibrary(db).setActiveOwner(usuarioTeste);
    // a estante já tem um livro que não pode sair do aparelho
    await UserBooksDao(db).upsert(livroTeste(1, title: 'Diário Íntimo'));
    final importador = await c.read(bookImporterProvider.future);

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
    expect(gravador.chamadas, isEmpty);
    expect(erros, isEmpty);
  });
}

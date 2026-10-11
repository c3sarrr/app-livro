// G07 — o catalog.db feito pelo pipeline (Python) lido pelo app: busca, hash do conteúdo e delta.
import 'dart:convert';
import 'dart:io';

import 'package:app_leitura/features/catalog/data/local_catalog.dart';
import 'package:app_leitura/features/catalog/domain/catalog_book.dart';
import 'package:app_leitura/features/catalog/domain/catalog_failure.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/catalog_fakes.dart';

void main() {
  late Directory dir;
  late SqliteLocalCatalog cat;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('booknest_catalogo_');
    cat = await SqliteLocalCatalog.open(await catalogDbFile(dir, v1));
  });
  tearDown(() async {
    await cat.close();
    await dir.delete(recursive: true);
  });

  List<String> deltaLines(String de, String para) =>
      const LineSplitter().convert(
        utf8.decode(
          gzip.decode(fixtureBytes('catalog/v1/$para/delta-$de.jsonl.gz')),
        ),
      );

  test(
    'versão, livro pelo ISBN e busca sem acento (título e autores)',
    () async {
      expect(await cat.version(), v1);
      final dom = await cat.byIsbn('9788535902778');
      expect(
        dom,
        const CatalogBook(
          isbn13: '9788535902778',
          title: 'Dom Casmurro',
          authors: ['Machado de Assis'],
          publisher: 'Penguin-Companhia',
          year: 2016,
          pages: 256,
          language: 'por',
          coverRef: 'ol:8231432',
          source: 'openlibrary',
          license: 'OL-sem-direitos',
        ),
      );
      expect(dom!.shareable, isTrue);
      expect(await cat.byIsbn('9780000000002'), isNull);
      expect((await cat.search('estrela')).map((b) => b.title), [
        'A hora da estrela',
      ]);
      expect((await cat.search('MACHADO')).single.isbn13, '9788535902778');
      expect((await cat.search('ub buch')).single.title, 'Über Bücher!');
      expect(await cat.search('   '), isEmpty);
      // o texto da pessoa nunca vira sintaxe do FTS
      expect(await cat.search('dom: "casmurro*'), hasLength(1));
      expect(
        SqliteLocalCatalog.ftsQuery('dom "casmurro" OR'),
        '"dom"* "casmurro"* "OR"*',
      );
    },
  );

  test('o hash do conteúdo calculado no app = o do pipeline', () async {
    final m = fixtureManifest(v1);
    expect(await cat.contentSha256(), (m['db']! as Map)['conteudo_sha256']);
  });

  test('delta v1 → v2: o resultado é igual ao catálogo v2 (hash do conteúdo); a busca acompanha', () async {
    final m2 = fixtureManifest(v2);
    await cat.applyDelta(
      deltaLines(v1, v2),
      expectedFrom: v1,
      expectedTo: v2,
      expectedContentSha256: (m2['db']! as Map)['conteudo_sha256']! as String,
    );
    expect(await cat.version(), v2);
    expect(await cat.byIsbn('9786555321234'), isNull, reason: 'saiu na v2');
    expect(
      (await cat.byIsbn('9788535910667'))!.title,
      'Memórias póstumas de Brás Cubas',
    );
    expect((await cat.search('oxford')).single.isbn13, '9780199535569');
    expect(await cat.search('estrela'), isEmpty);
    // livro de 2 autores no delta: o JSON da coluna `authors` tem de ser o mesmo do pipeline (o hash
    // acima fecha — achado 1 da revisão)
    final dois = (await cat.byIsbn('9783446236202'))!;
    expect(
      [dois.authors, dois.year],
      [
        ['Anna Müller', 'Bernd Weiß'],
        2011,
      ],
    );
  });

  test('delta com hash errado ou de outra versão: nada muda', () async {
    await expectLater(
      cat.applyDelta(
        deltaLines(v1, v2),
        expectedFrom: v1,
        expectedTo: v2,
        expectedContentSha256: 'f' * 64,
      ),
      throwsA(
        isA<CatalogCorrupted>().having((e) => e.code, 'code', 'delta_hash'),
      ),
    );
    expect(await cat.version(), v1);
    expect(await cat.byIsbn('9786555321234'), isNotNull, reason: 'desfeito');
    await expectLater(
      cat.applyDelta(
        deltaLines(v1, v2),
        expectedFrom: '2026-08-31.1',
        expectedTo: v2,
        expectedContentSha256: 'x',
      ),
      throwsA(
        isA<CatalogCorrupted>().having((e) => e.code, 'code', 'delta_versao'),
      ),
    );
  });

  test('arquivo que não é catálogo: CatalogCorrupted', () async {
    final lixo = File('${dir.path}/lixo.db');
    await lixo.writeAsString('não é sqlite');
    await expectLater(
      SqliteLocalCatalog.open(lixo.path),
      throwsA(isA<CatalogCorrupted>()),
    );
  });
}

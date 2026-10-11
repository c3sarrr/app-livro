// R00 (D-267, D-269) — o catálogo do modo demonstração: o `catalog.db` semeado é um catálogo do formato 1 que o app
// abre (versão, as 3 edições, a busca por autor do "Para você" e o hash do conteúdo igual ao do `meta`); semear de novo
// não regrava; um arquivo pela metade de uma semeadura interrompida é trocado; os ISBN são válidos; e o cliente do
// demo recusa qualquer pedido.
import 'dart:io';

import 'package:app_leitura/features/catalog/data/local_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sqlite_async/sqlite_async.dart';

import 'catalogo_demonstracao.dart';

/// O dígito de controle do ISBN-13 confere.
bool _isbnValido(String isbn) {
  if (!RegExp(r'^97[89]\d{10}$').hasMatch(isbn)) return false;
  var soma = 0;
  for (var i = 0; i < 12; i++) {
    soma += int.parse(isbn[i]) * (i.isEven ? 1 : 3);
  }
  return (10 - soma % 10) % 10 == int.parse(isbn[12]);
}

void main() {
  late Directory pasta;

  setUp(() => pasta = Directory.systemTemp.createTempSync('booknest_r00_cat_'));
  tearDown(() => pasta.deleteSync(recursive: true));

  test('o catálogo semeado é do formato 1: versão, as 3 edições, a busca por autor e o hash do conteúdo', () async {
    await semearCatalogoSeFaltar(pasta);
    expect(
      pasta.listSync().map((e) => e.uri.pathSegments.last),
      ['catalog.db'],
      reason: 'nada da semeadura fica ao lado (nem o arquivo de troca, nem o diário)',
    );
    final c = await SqliteLocalCatalog.open(arquivoDoCatalogo(pasta).path);
    addTearDown(c.close);
    expect(await c.version(), versaoDoCatalogoDoDemo);
    for (final e in edicoesDoDemo) {
      final b = (await c.byIsbn(e.isbn13))!;
      expect(
        (b.title, b.publisher, b.year, b.pages, b.language, b.coverRef),
        (e.titulo, e.editora, e.ano, e.paginas, 'por', null),
        reason: e.titulo,
      );
      // (um registro com lista compara a lista pela identidade: à parte)
      expect(b.authors, [autorDoCatalogoDoDemo], reason: e.titulo);
    }
    expect(
      [
        for (final b in await c.byAuthor('Machado de Assis', language: 'por'))
          b.title,
      ],
      ['Memorial de Aires', 'Quincas Borba', 'Esaú e Jacó'],
      reason: 'a ordem do banco: língua, capa, a mais nova, o ISBN',
    );
    expect(await c.byAuthor('Aluísio Azevedo'), isEmpty);
    expect(await c.search('esau jaco'), hasLength(1));
    final meta = await c.meta();
    expect(meta['conteudo_sha256'], await c.contentSha256());
    expect((meta['formato'], meta['registros']), ('1', '3'));
  });

  test('semear de novo não regrava, e um arquivo pela metade de uma semeadura interrompida é trocado', () async {
    // a semeadura caiu no meio: sobrou o arquivo de troca (lixo), e nenhum catálogo
    final pelaMetade = File('${arquivoDoCatalogo(pasta).path}.semeando')
      ..writeAsStringSync('não é um banco');
    await semearCatalogoSeFaltar(pasta);
    expect(pelaMetade.existsSync(), isFalse);
    final arquivo = arquivoDoCatalogo(pasta);
    final antes = (arquivo.readAsBytesSync(), arquivo.lastModifiedSync());

    await semearCatalogoSeFaltar(pasta);
    expect(arquivo.readAsBytesSync(), antes.$1);
    expect(arquivo.lastModifiedSync(), antes.$2);
    final db = SqliteDatabase(
      path: arquivo.path,
      options: SqliteLocalCatalog.options,
    );
    addTearDown(db.close);
    expect((await db.get('SELECT count(*) n FROM editions'))['n'], 3);
  });

  test('os ISBN das edições são válidos e distintos', () {
    final isbns = [for (final e in edicoesDoDemo) e.isbn13];
    expect(isbns.every(_isbnValido), isTrue, reason: '$isbns');
    expect(isbns.toSet(), hasLength(isbns.length));
    expect(
      _isbnValido('9788563560545'),
      isFalse,
      reason: 'o conferidor acusa um dígito trocado',
    );
  });

  test('o cliente do catálogo no demo recusa qualquer pedido', () async {
    final cliente = SemRedeNoDemo();
    addTearDown(cliente.close);
    await expectLater(
      cliente.get(
        Uri.parse(
          'https://catalogo.demonstracao.invalid/v1/catalog/manifest.json',
        ),
      ),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      cliente.send(
        http.Request('GET', Uri.parse('https://covers.openlibrary.org/')),
      ),
      throwsA(isA<StateError>()),
    );
  });
}

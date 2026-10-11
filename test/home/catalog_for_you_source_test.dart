// G08.2 — "Para você" no aparelho (D-81): autor da estante → catálogo baixado, uma edição por título, sem o
// que já está na estante; some sem catálogo ou sem sugestão.
import 'dart:io';

import 'package:app_leitura/features/catalog/data/local_catalog.dart';
import 'package:app_leitura/features/catalog/domain/catalog_book.dart';
import 'package:app_leitura/features/home/data/catalog_for_you_source.dart';
import 'package:app_leitura/features/home/data/home_sources.dart';
import 'package:app_leitura/features/home/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/catalog/support/catalog_fakes.dart';

CatalogBook _ed(
  String isbn,
  String title,
  List<String> authors, {
  String? lang,
  String? capa,
  int? ano,
}) => CatalogBook(
  isbn13: isbn,
  title: title,
  authors: authors,
  language: lang,
  coverRef: capa,
  year: ano,
  source: 'openlibrary',
);

final class _Catalogo implements LocalCatalog {
  _Catalogo(this.livros);

  final List<CatalogBook> livros;
  String versao = 'v1';
  final List<String> pedidos = [];

  @override
  Future<List<CatalogBook>> byAuthor(
    String author, {
    String? language,
    int limit = 200,
  }) async {
    pedidos.add(author);
    final palavras = author.toLowerCase().split(' ');
    return [
      for (final b in livros)
        if (palavras.every(
          (p) => b.authors.any((a) => a.toLowerCase().contains(p)),
        ))
          b,
    ];
  }

  @override
  Future<String?> version() async => versao;

  @override
  Future<CatalogBook?> byIsbn(String isbn13) => throw UnimplementedError();

  @override
  Future<List<CatalogBook>> search(String text, {int limit = 20}) =>
      throw UnimplementedError();

  @override
  Future<void> close() async {}
}

ForYouRequest _pedido(
  List<String> autores, {
  Set<String> isbns = const {},
  Set<String> titulos = const {},
}) => ForYouRequest(authors: autores, shelfIsbns: isbns, shelfTitles: titulos);

void main() {
  final machado = [
    _ed('9788535902778', 'Dom Casmurro', ['Machado de Assis'], lang: 'por'),
    _ed(
      '9788525406576',
      'Memórias Póstumas de Brás Cubas',
      ['Machado de Assis'],
      lang: 'por',
      capa: 'ol:1',
      ano: 2008,
    ),
    // a mesma obra em outra edição: uma só por título (prefere a língua do aparelho, depois com capa, depois a
    // mais nova)
    _ed(
      '9780195101706',
      'Memorias postumas de Bras Cubas',
      ['Machado de Assis'],
      lang: 'eng',
      capa: 'ol:2',
      ano: 2010,
    ),
    _ed(
      '9788572326971',
      'Memórias Póstumas de Brás Cubas',
      ['Machado de Assis'],
      lang: 'por',
      ano: 2012,
    ),
    _ed('9788508133021', 'Quincas Borba', ['Machado de Assis'], lang: 'por'),
    _ed(
      '9788508133022',
      'Quincas Borba',
      ['Machado de Assis'],
      lang: 'por',
      capa: 'ol:3',
    ),
    // outro autor com as mesmas palavras não conta (conferência exata do nome)
    _ed('9788500000001', 'Contos', ['Machado de Assis Filho'], lang: 'por'),
    _ed('9788500000002', 'Antologia', [
      'Ana Lima',
      'Machado de Assis',
    ], lang: 'por'),
  ];

  test(
    'uma edição por título, sem o que está na estante; o motivo é o autor',
    () async {
      final cat = _Catalogo(machado);
      final s = CatalogForYouSource(() async => cat, language: 'por');
      final r = await s.suggest(
        _pedido(
          ['Machado de Assis'],
          isbns: {'9788535902778'},
          titulos: {'quincas  borba'},
        ),
      );
      expect(r!.reasonAuthor, 'Machado de Assis');
      expect(r.items.map((b) => (b.id, b.title, b.author, b.cover)), [
        (
          '9788525406576',
          'Memórias Póstumas de Brás Cubas',
          'Machado de Assis',
          const PhotoCover(ref: 'ol:1', isbn13: '9788525406576'),
        ),
        (
          '9788500000002',
          'Antologia',
          'Ana Lima · Machado de Assis',
          const PhotoCover(isbn13: '9788500000002'),
        ),
      ]);
    },
  );

  test(
    'ordem: língua do aparelho, com capa, mais nova; no máximo 10',
    () async {
      final muitos = [
        for (var i = 0; i < 14; i++)
          _ed(
            '97885000001${i.toString().padLeft(2, '0')}',
            'Livro $i',
            ['Autora'],
            lang: i.isEven ? 'por' : 'eng',
            capa: i % 3 == 0 ? 'ol:$i' : null,
            ano: 2000 + i,
          ),
      ];
      final s = CatalogForYouSource(
        () async => _Catalogo(muitos),
        language: 'por',
      );
      final r = await s.suggest(_pedido(['Autora']));
      expect(r!.items.map((b) => b.title), [
        'Livro 12', 'Livro 6', 'Livro 0', // por + capa, mais novo primeiro
        'Livro 10', 'Livro 8', 'Livro 4', 'Livro 2', // por sem capa
        'Livro 9', 'Livro 3', // eng + capa
        'Livro 13', // eng sem capa (a 10ª)
      ]);
    },
  );

  test(
    'tenta o próximo autor quando o primeiro não rende; até 3 autores',
    () async {
      final cat = _Catalogo(machado);
      final s = CatalogForYouSource(() async => cat, language: 'por');
      final r = await s.suggest(
        _pedido(['Ninguém', 'Outra Pessoa', 'Machado de Assis', 'Quarto']),
      );
      expect(r!.reasonAuthor, 'Machado de Assis');
      expect(cat.pedidos, ['Ninguém', 'Outra Pessoa', 'Machado de Assis']);
      cat.pedidos.clear();
      expect(
        await CatalogForYouSource(
          () async => cat,
          language: 'por',
        ).suggest(_pedido(['A', 'B', 'C', 'Machado de Assis'])),
        isNull,
      );
      expect(cat.pedidos, ['A', 'B', 'C']);
    },
  );

  test('sem catálogo no aparelho ou sem autores: some (null)', () async {
    expect(
      await CatalogForYouSource(
        () async => null,
        language: 'por',
      ).suggest(_pedido(['Machado de Assis'])),
      isNull,
    );
    expect(
      await CatalogForYouSource(
        () async => _Catalogo(machado),
        language: 'por',
      ).suggest(_pedido(const [])),
      isNull,
    );
  });

  test(
    'o mesmo pedido na mesma versão do catálogo não consulta de novo',
    () async {
      final cat = _Catalogo(machado);
      final s = CatalogForYouSource(() async => cat, language: 'por');
      final a = await s.suggest(_pedido(['Machado de Assis']));
      final b = await s.suggest(_pedido(['Machado de Assis']));
      expect(b, same(a));
      expect(cat.pedidos, hasLength(1));
      cat.versao = 'v2';
      await s.suggest(_pedido(['Machado de Assis']));
      expect(cat.pedidos, hasLength(2));
      await s.suggest(_pedido(['Machado de Assis'], isbns: {'9788508133022'}));
      expect(cat.pedidos, hasLength(3));
    },
  );

  test('língua do aparelho → código do catálogo (ISO 639-2/B)', () {
    expect(catalogLanguageOf('pt'), 'por');
    expect(catalogLanguageOf('en'), 'eng');
    expect(catalogLanguageOf('es'), 'spa');
    expect(catalogLanguageOf('de'), 'ger');
    expect(catalogLanguageOf('fr'), 'fre');
    expect(catalogLanguageOf('it'), 'ita');
    expect(catalogLanguageOf('xx'), isNull);
  });

  group('catalog.db de verdade (fixture do pipeline)', () {
    late Directory dir;
    late SqliteLocalCatalog cat;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('booknest_paravoce_');
      cat = await SqliteLocalCatalog.open(await catalogDbFile(dir, v1));
    });
    tearDown(() async {
      await cat.close();
      await dir.delete(recursive: true);
    });

    test(
      'busca só na coluna de autores, palavra inteira, sem acento',
      () async {
        // a ordem sai do SQL antes do limite: língua do aparelho, com capa, mais nova (revisão da G08)
        expect(
          (await cat.byAuthor(
            'Jane Austen',
            language: 'eng',
          )).map((b) => b.isbn13),
          ['9780141439518', '9780199535569'],
        );
        expect((await cat.byAuthor('Jane Austen')).map((b) => b.isbn13), [
          '9780199535569',
          '9780141439518',
        ]);
        expect(
          (await cat.byAuthor(
            'Jane Austen',
            language: 'eng',
            limit: 1,
          )).single.isbn13,
          '9780141439518',
        );
        expect(
          (await cat.byAuthor('anna muller')).single.title,
          'Über Bücher!',
        );
        // "Dom" está no título, não nos autores; "Mach" não é palavra inteira
        expect(await cat.byAuthor('Dom'), isEmpty);
        expect(await cat.byAuthor('Mach'), isEmpty);
        expect(await cat.byAuthor('  '), isEmpty);
        // o nome da pessoa nunca vira sintaxe do FTS
        expect(await cat.byAuthor('"Austen" OR authors:*'), isEmpty);
      },
    );

    test('a fonte sobre o arquivo: Jane Austen → as duas edições (títulos diferentes)', () async {
      final r = await CatalogForYouSource(
        () async => cat,
        language: 'eng',
      ).suggest(_pedido(['Jane Austen']));
      expect(r!.items.map((b) => b.title), [
        'Pride and Prejudice',
        'Pride & Prejudice',
      ]);
    });
  });
}

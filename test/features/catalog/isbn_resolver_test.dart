// G07 — resolução do ISBN em camadas: aparelho → catalog.db → borda → comunidade → externa (cota).
import 'dart:io';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/features/catalog/application/isbn_resolver.dart';
import 'package:app_leitura/features/catalog/data/catalog_cache_dao.dart';
import 'package:app_leitura/features/catalog/data/local_catalog.dart';
import 'package:app_leitura/features/catalog/domain/catalog_book.dart';
import 'package:app_leitura/features/catalog/domain/catalog_failure.dart';
import 'package:app_leitura/features/catalog/domain/community.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/catalog_fakes.dart';

void main() {
  late Directory dir;
  late AppDatabase db;
  late SqliteLocalCatalog local;
  late FakeEdge edge;
  late FakeCommunity community;
  late FakeExternal external;
  var agora = DateTime.utc(2026, 10, 5, 12);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('booknest_resolver_');
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    local = await SqliteLocalCatalog.open(await catalogDbFile(dir, v1));
    edge = FakeEdge();
    community = FakeCommunity();
    external = FakeExternal();
    agora = DateTime.utc(2026, 10, 5, 12);
  });
  tearDown(() async {
    await local.close();
    await db.close();
    await dir.delete(recursive: true);
  });

  IsbnResolver resolver({bool conta = true, bool semCatalogo = false}) =>
      IsbnResolver(
        cache: CatalogCacheDao(db),
        localCatalog: () async => semCatalogo ? null : local,
        edge: edge,
        community: conta ? community : null,
        external: conta ? external : null,
        now: () => agora,
      );

  test('no catalog.db: responde sem rede e guarda no aparelho', () async {
    final r = await resolver().resolve('9788535902778');
    expect(
      r,
      isA<IsbnFound>().having((f) => (f.book.title, f.layer), 'livro', (
        'Dom Casmurro',
        CatalogLayer.localCatalog,
      )),
    );
    expect(edge.calls, isEmpty);
    final r2 = await resolver(semCatalogo: true).resolve('9788535902778');
    expect(
      r2,
      isA<IsbnFound>().having((f) => f.layer, 'camada', CatalogLayer.device),
    );
  });

  test(
    'ordem: borda → comunidade → externa; para na primeira que acha',
    () async {
      const isbn = '9786586490008';
      external.books[isbn] = livroCatalogo(
        isbn,
        title: 'Da CBL',
        source: 'brasilapi',
      );
      community.books[isbn] = livroCatalogo(
        isbn,
        title: 'Da comunidade',
        source: 'community',
      );
      final r = await resolver().resolve(isbn);
      expect(
        r,
        isA<IsbnFound>().having((f) => (f.book.title, f.layer), 'livro', (
          'Da comunidade',
          CatalogLayer.community,
        )),
      );
      expect(
        [edge.calls, community.calls, external.calls],
        [
          [isbn],
          [isbn],
          <String>[],
        ],
      );
      community.books.clear();
      const outro = '9786586490015';
      external.books[outro] = livroCatalogo(
        outro,
        title: 'Da CBL',
        source: 'brasilapi',
      );
      final x = await resolver().resolve(outro);
      expect(
        x,
        isA<IsbnFound>().having((f) => (f.layer, f.book.shareable), 'externa', (
          CatalogLayer.external,
          false,
        )),
      );
    },
  );

  test('não achou em lugar nenhum: guarda o "não achou" 7 dias (não gasta a cota de novo)', () async {
    const isbn = '9786586490022';
    final r = await resolver().resolve(isbn);
    expect(
      r,
      isA<IsbnNotFound>().having((n) => n.externalTried, 'externa', isTrue),
    );
    expect(external.calls, [isbn]);
    agora = agora.add(const Duration(days: 3));
    await resolver().resolve(isbn);
    expect(external.calls, [isbn], reason: 'dentro de 7 dias');
    expect(edge.calls, [
      isbn,
      isbn,
    ], reason: 'a borda é grátis: consulta de novo');
    agora = agora.add(const Duration(days: 5));
    await resolver().resolve(isbn);
    expect(external.calls, [isbn, isbn]);
  });

  test(
    'convidado (sem conta): só aparelho e borda; sem comunidade nem externa',
    () async {
      const isbn = '9786586490039';
      final r = await resolver(conta: false).resolve(isbn);
      expect(
        r,
        isA<IsbnNotFound>().having((n) => n.externalTried, 'externa', isFalse),
      );
      expect(community.calls, isEmpty);
      expect(external.calls, isEmpty);
    },
  );

  test('sem rede: a falha sobe (a tela oferece tentar de novo) e nada fica guardado como "não achou"', () async {
    const isbn = '9786586490046';
    edge.failure = const CatalogOffline();
    external.failure = const CatalogOffline();
    await expectLater(resolver().resolve(isbn), throwsA(isA<CatalogOffline>()));
    expect(await CatalogCacheDao(db).byIsbn(isbn), isNull);
    edge.failure = null;
    external.failure = const CatalogQuotaExceeded();
    await expectLater(
      resolver().resolve(isbn),
      throwsA(isA<CatalogQuotaExceeded>()),
    );
  });

  test('allowExternal: false não consulta a externa', () async {
    const isbn = '9786586490053';
    final r = await resolver().resolve(isbn, allowExternal: false);
    expect(
      r,
      isA<IsbnNotFound>().having((n) => n.externalTried, 'externa', isFalse),
    );
    expect(external.calls, isEmpty);
  });

  test('não achou, mas a comunidade tem sugestões pendentes: voltam para a pessoa confirmar', () async {
    const isbn = '9786586490060';
    const sugestao = CommunitySuggestion(
      id: '01927a00-0000-7000-8000-0000000000d1',
      title: 'Livro Novo',
      authors: 'Autora',
      confirmations: 1,
      mine: false,
      confirmedByMe: false,
    );
    community.pending[isbn] = [sugestao];
    final r = await resolver().resolve(isbn);
    expect(
      r,
      isA<IsbnNotFound>().having((n) => n.suggestions, 'sugestões', [sugestao]),
    );
    expect(sugestao.canConfirm, isTrue);
  });

  test('erro que não é falha do catálogo (TLS do portal de Wi-Fi, JSON quebrado): vira falha tipada', () async {
    const isbn = '9786586490077';
    edge.failure = StateError('HandshakeException');
    external.books[isbn] = livroCatalogo(
      isbn,
      title: 'Da CBL',
      source: 'brasilapi',
    );
    expect(
      await resolver().resolve(isbn),
      isA<IsbnFound>().having((f) => f.layer, 'camada', CatalogLayer.external),
    );
    await expectLater(
      resolver(conta: false).resolve('9786586490084'),
      throwsA(isA<CatalogUnexpected>()),
    );
  });

  test(
    'catálogo do aparelho que falha (trocando de versão): segue para a borda',
    () async {
      const isbn = '9788535902778';
      edge.books[isbn] = livroCatalogo(isbn, title: 'Da borda');
      final r = await IsbnResolver(
        cache: CatalogCacheDao(db),
        localCatalog: () async => throw StateError('fechado'),
        edge: edge,
        now: () => agora,
      ).resolve(isbn);
      expect(
        r,
        isA<IsbnFound>().having((f) => f.layer, 'camada', CatalogLayer.edge),
      );
    },
  );

  test('convidado: a externa recusa (sem conta) e NÃO conta como consultada (achado 5)', () async {
    const isbn = '9786586490091';
    external.failure = const CatalogNeedsAccount();
    final r = await resolver().resolve(isbn);
    expect(
      r,
      isA<IsbnNotFound>().having((n) => n.externalTried, 'externa', isFalse),
    );
    final c = await CatalogCacheDao(db).byIsbn(isbn);
    expect(
      c,
      isA<CachedMiss>().having((m) => m.externalTried, 'externa', isFalse),
    );
    // entrou na conta: a externa é consultada já
    external.failure = null;
    external.books[isbn] = livroCatalogo(
      isbn,
      title: 'Agora sim',
      source: 'brasilapi',
    );
    expect(await resolver().resolve(isbn), isA<IsbnFound>());
  });

  test('borda fora do ar, mas a externa respondeu "não tem": não achou (sem guardar), não "sem conexão"', () async {
    const isbn = '9786586490107';
    edge.failure = const CatalogOffline();
    final r = await resolver().resolve(isbn);
    expect(
      r,
      isA<IsbnNotFound>().having((n) => n.externalTried, 'externa', isTrue),
    );
    expect(
      await CatalogCacheDao(db).byIsbn(isbn),
      isNull,
      reason: 'a borda não respondeu',
    );
  });
}

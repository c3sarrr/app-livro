// G10.2 — cache das páginas (`page_layout_cache`, Anexo 03 §7.2): grava e lê o início de cada página por
// capítulo; a chave é livro + ajustes + viewport + versão das fontes; conteúdo de outro formato não vale; some
// com o livro.
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/personal_builders.dart';

void main() {
  late AppDatabase db;
  late PageLayoutCacheDao dao;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    dao = PageLayoutCacheDao(db);
  });
  tearDown(() => db.close());

  final livro = idTeste(1);
  final breaks = PageBreaks(
    sha: 'a' * 64,
    chapters: {
      1: [0, 1200, 2405],
      3: [0],
    },
  );

  Future<PageBreaks?> ler({
    String settings = 'h1',
    String viewport = '390x844@3',
    int fonts = 1,
  }) => dao.get(
    userBookId: livro,
    settingsHash: settings,
    viewport: viewport,
    fontsVersion: fonts,
  );

  test(
    'grava e lê; outra chave (ajustes, viewport, fontes) não acha',
    () async {
      await dao.put(
        userBookId: livro,
        settingsHash: 'h1',
        viewport: '390x844@3',
        fontsVersion: 1,
        breaks: breaks,
        now: DateTime.utc(2026, 10, 5),
      );
      final r = (await ler())!;
      expect(r.sha, 'a' * 64);
      expect(r.chapters, {
        1: [0, 1200, 2405],
        3: [0],
      });
      expect(await ler(settings: 'h2'), isNull);
      expect(await ler(viewport: '360x780@3'), isNull);
      expect(await ler(fonts: 2), isNull);
      // gravar de novo troca
      await dao.put(
        userBookId: livro,
        settingsHash: 'h1',
        viewport: '390x844@3',
        fontsVersion: 1,
        breaks: PageBreaks(sha: 'b' * 64, chapters: const {}),
        now: DateTime.utc(2026, 10, 6),
      );
      expect((await ler())!.sha, 'b' * 64);
      await dao.deleteBook(livro);
      expect(await ler(), isNull);
    },
  );

  test(
    'conteúdo quebrado ou de outro formato: como se não houvesse cache',
    () async {
      await db
          .into(db.pageLayoutCache)
          .insert(
            PageLayoutCacheCompanion.insert(
              userBookId: livro,
              settingsHash: 'h1',
              viewport: '390x844@3',
              fontsVersion: 1,
              breaks: Uint8List.fromList('{"x":1}'.codeUnits),
              createdAt: DateTime.utc(2026, 10, 5),
            ),
          );
      expect(await ler(), isNull);
      expect(PageBreaks.decode([0xFF, 0x00]), isNull);
      expect(PageBreaks.decode(breaks.encode())!.chapters[1], [0, 1200, 2405]);
    },
  );

  test('G18: a assinatura dos espaços de cada capítulo vai e volta; o blob antigo (sem ela) vale sem espaços', () async {
    final com = PageBreaks(
      sha: 'a' * 64,
      chapters: const {
        1: [0, 1200],
        3: [0],
      },
      spaces: const {1: '120:206.00'},
    );
    await dao.put(
      userBookId: livro,
      settingsHash: 'h1',
      viewport: '390x844@3',
      fontsVersion: 1,
      breaks: com,
      now: DateTime.utc(2026, 10, 8),
    );
    final r = (await ler())!;
    expect(r.spaces, {1: '120:206.00'});
    expect(r.chapters[1], [0, 1200]);
    final antigo = PageBreaks.decode(
      utf8.encode(
        jsonEncode({
          'sha': 'a' * 64,
          'c': {
            '1': [0, 1200],
          },
        }),
      ),
    )!;
    expect(antigo.spaces, isEmpty);
    expect(antigo.chapters[1], [0, 1200]);
    // o capítulo sem espaços não leva entrada
    expect(
      jsonDecode(utf8.decode(com.encode())),
      containsPair('s', {'1': '120:206.00'}),
    );
  });

  group('R11 (G20): até 4 combinações por livro; a de uso mais antigo sai', () {
    Future<void> gravar(String settings, int dia, {String? outro}) => dao.put(
      userBookId: outro ?? livro,
      settingsHash: settings,
      viewport: '390x844@3',
      fontsVersion: 1,
      breaks: breaks,
      now: DateTime.utc(2026, 10, dia),
    );
    Future<Set<String>> guardadas([String? outro]) async => {
      for (final r in await (db.select(
        db.pageLayoutCache,
      )..where((t) => t.userBookId.equals(outro ?? livro))).get())
        r.settingsHash,
    };

    test('a 5ª combinação tira a mais antiga', () async {
      for (final (i, h) in ['a', 'b', 'c', 'd', 'e'].indexed) {
        await gravar(h, 1 + i);
      }
      expect(await guardadas(), {'b', 'c', 'd', 'e'});
    });

    test('ler marca o uso: a lida fica, sai a seguinte mais antiga', () async {
      for (final (i, h) in ['a', 'b', 'c', 'd'].indexed) {
        await gravar(h, 1 + i);
      }
      expect(
        await dao.get(
          userBookId: livro,
          settingsHash: 'a',
          viewport: '390x844@3',
          fontsVersion: 1,
          now: DateTime.utc(2026, 10, 9),
        ),
        isNotNull,
      );
      await gravar('e', 10);
      expect(await guardadas(), {'a', 'c', 'd', 'e'});
    });

    test('ler sem o relógio não marca o uso', () async {
      for (final (i, h) in ['a', 'b', 'c', 'd'].indexed) {
        await gravar(h, 1 + i);
      }
      await ler(settings: 'a');
      await gravar('e', 10);
      expect(await guardadas(), {'b', 'c', 'd', 'e'});
    });

    test(
      'no mesmo instante, a gravada por último fica (o desempate)',
      () async {
        for (final h in ['a', 'b', 'c', 'd', 'e']) {
          await gravar(h, 1);
        }
        final ficaram = await guardadas();
        expect(ficaram, hasLength(4));
        expect(ficaram, contains('e'), reason: 'a recém-gravada não some');
      },
    );

    test('regravar a mesma combinação não conta como outra', () async {
      for (final (i, h) in ['a', 'b', 'c', 'd'].indexed) {
        await gravar(h, 1 + i);
      }
      await gravar('a', 11);
      expect(await guardadas(), {'a', 'b', 'c', 'd'});
    });

    test('outro livro não conta no teto do primeiro', () async {
      final outro = idTeste(2);
      for (final (i, h) in ['a', 'b', 'c', 'd'].indexed) {
        await gravar(h, 1 + i);
      }
      for (final (i, h) in ['p', 'q', 'r'].indexed) {
        await gravar(h, 5 + i, outro: outro);
      }
      expect(await guardadas(), {'a', 'b', 'c', 'd'});
      expect(await guardadas(outro), {'p', 'q', 'r'});
      expect(PageLayoutCacheDao.perBook, 4);
    });
  });
}

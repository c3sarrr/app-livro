// G10.2 — cache das páginas (`page_layout_cache`, Anexo 03 §7.2): grava e lê o início de cada página por
// capítulo; a chave é livro + ajustes + viewport + versão das fontes; conteúdo de outro formato não vale; some
// com o livro.
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
}

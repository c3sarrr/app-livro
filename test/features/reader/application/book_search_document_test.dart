// G12.4 — a busca no livro aberto (D-120): no Dom Casmurro de verdade, os grupos por capítulo na ordem do livro,
// cada resultado apontando o texto achado (salto e marca), com a página de referência; sem maiúsculas; o limite de
// 501; cancelar para a busca; e a busca num isolate igual à feita na hora.
import 'dart:async';

import 'package:app_leitura/features/reader/application/book_search.dart';
import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/domain/reader_numbers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';
import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await LivroNaEstante.domCasmurro());
  tearDown(() async => livro.close());

  Future<EpubReaderDocument> abrir({EpubSearchRunner? busca}) async {
    final d = await EpubReaderDocument.open(livro.deps(busca: busca));
    addTearDown(d.dispose);
    return d;
  }

  List<SearchHit> todos(List<SearchGroup> g) => [for (final x in g) ...x.hits];

  String achado(SearchHit h) => chapterOf(
    livro.epub,
    h.found.unit,
  ).item.text.substring(h.found.from, h.found.to);

  test('"ressaca": grupos por capítulo na ordem do livro; cada resultado aponta o texto e a página', () async {
    final d = await abrir();
    final grupos = await d.search('ressaca').toList();
    expect(grupos, isNotEmpty);
    final hits = todos(grupos);
    expect(hits.length, greaterThan(3));
    var antes = -1;
    for (final h in hits) {
      expect(foldForSearch(achado(h)).text, 'ressaca');
      expect(h.at, (spine: h.found.unit, offset: h.found.from));
      final g = livro.index.globalOffset(h.at.spine, h.at.offset)!;
      expect(g, greaterThan(antes), reason: 'na ordem do livro');
      antes = g;
      expect(
        h.refPage,
        numbersAt(livro.index, h.at.spine, h.at.offset).refPage,
      );
      expect(
        h.excerpt.substring(h.matchStart, h.matchEnd),
        achado(h).replaceAll('\n', ' '),
      );
    }
    // grupos seguidos nunca repetem o capítulo
    for (var i = 1; i < grupos.length; i++) {
      final a = searchChapterAt(
        livro.index,
        livro.index.globalOffset(
          grupos[i - 1].hits.first.at.spine,
          grupos[i - 1].hits.first.at.offset,
        )!,
      );
      final b = searchChapterAt(
        livro.index,
        livro.index.globalOffset(
          grupos[i].hits.first.at.spine,
          grupos[i].hits.first.at.offset,
        )!,
      );
      expect(b.leaf, isNot(a.leaf));
      expect(grupos[i].title, b.title);
    }
  });

  test(
    'sem acento e sem maiúsculas: "capitu" acha "Capitú" e "capitu"',
    () async {
      final d = await abrir();
      final hits = todos(await d.search('capitu').toList());
      final grafias = hits.map(achado).toSet();
      // o texto do Projeto Gutenberg é da ortografia antiga: "Capitú"
      expect(grafias, containsAll(<String>['Capitú', 'capitu']));
      for (final g in grafias) {
        expect(foldForSearch(g).text, 'capitu');
      }
    },
  );

  test('palavra comum: para em 501 (a tela mostra 500 e o aviso)', () async {
    final d = await abrir();
    final hits = todos(await d.search('de').toList());
    expect(hits, hasLength(searchLimit + 1));
  });

  test('menos de 2 caracteres: nenhum grupo', () async {
    final d = await abrir();
    expect(await d.search('a').toList(), isEmpty);
  });

  test('cancelar a assinatura para a busca: nada mais chega e o buscador é cancelado', () async {
    var cancelado = false;
    var entregues = 0;
    Stream<UnitHits> devagar(String path, List<int> spines, String q) {
      late final StreamController<UnitHits> c;
      c = StreamController<UnitHits>(
        onListen: () async {
          for (final u in searchTexts(
            spines,
            (s) => chapterOf(livro.epub, s).item.text,
            q,
          )) {
            if (cancelado) return;
            await Future<void>.delayed(const Duration(milliseconds: 5));
            if (cancelado) return;
            entregues++;
            c.add(u);
          }
          await c.close();
        },
        onCancel: () => cancelado = true,
      );
      return c.stream;
    }

    final d = await abrir(busca: devagar);
    final recebidos = <SearchGroup>[];
    final sub = d.search('que').listen(recebidos.add);
    while (recebidos.isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 2));
    }
    await sub.cancel();
    final n = recebidos.length;
    final e = entregues;
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(cancelado, isTrue);
    expect(recebidos, hasLength(n));
    expect(entregues, e, reason: 'o buscador parou');
  });

  test(
    'a busca no isolate dá o mesmo que a busca na hora (EPUB pequeno)',
    () async {
      final pequeno = await LivroNaEstante.epubDe(
        simpleEpub(
          chapters: [
            (
              file: 'c1.xhtml',
              title: 'Um',
              body: '<p>Olhos de ressaca, olhos de cigana.</p>',
            ),
            (file: 'c2.xhtml', title: 'Dois', body: '<p>Nada aqui.</p>'),
            (
              file: 'c3.xhtml',
              title: 'Três',
              body: '<p>OLHOS oblíquos e dissimulados.</p>',
            ),
          ],
        ),
      );
      addTearDown(pequeno.close);
      final spines = [for (var i = 0; i < pequeno.index.spine.length; i++) i];
      final noIsolate = await isolateEpubSearch(
        pequeno.path,
        spines,
        'olhos',
      ).toList();
      final naHora = await pequeno
          .buscaNaHora(pequeno.path, spines, 'olhos')
          .toList();
      List<List<Object>> plano(List<UnitHits> us) => [
        for (final u in us)
          [
            u.unit,
            for (final h in u.hits)
              '${h.start}-${h.end}-${h.matchStart}-${h.matchEnd}-${h.excerpt}',
          ],
      ];
      expect(plano(noIsolate), plano(naHora));
      expect([for (final u in noIsolate) ...u.hits], hasLength(3));
      // cancelar logo no começo: o isolate para, fecha o arquivo e nada mais chega
      final depois = <UnitHits>[];
      final sub = isolateEpubSearch(
        pequeno.path,
        spines,
        'olhos',
      ).listen(depois.add);
      await sub.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(depois, isEmpty);
    },
  );

  test('arquivo que não abre: a busca no isolate termina com erro', () async {
    await expectLater(
      isolateEpubSearch('nao/existe.epub', const [0], 'olhos'),
      emitsError(isA<StateError>()),
    );
  });
}

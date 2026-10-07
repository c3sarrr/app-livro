// G09.2 — índice do livro (`book_content_index`, Anexo 02 §3.3) e páginas de referência (D-19/D-89):
// `page-list` da edição quando existe; senão uma página a cada 1.500 caracteres do texto dos itens lineares,
// cortando na fronteira de palavra seguinte; capítulos = entradas do sumário sem subentradas.
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/content_daos.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/content_failure.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:app_leitura/features/reader/content/toc_labels.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';

const String _domCasmurro = 'test/fixtures/livros/pg55752.epub';
const String _sha =
    'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

void main() {
  group('páginas sintéticas (D-89)', () {
    test('a cada N caracteres, cortando no começo da palavra seguinte', () {
      //                0         1         2         3
      //                0123456789012345678901234567890123456
      const t = 'Uma noite destas, vindo da cidade para o Engenho';
      final s = syntheticStarts([t], n: 10);
      // 10 já é começo de palavra ("destas"); 20 cai em "vindo" → "da" (24); 34 = "para"; 44 → fim
      expect(s.first, 0);
      for (final p in s.skip(1)) {
        expect(t[p - 1], ' ', reason: 'página $p começa depois de um espaço');
      }
      expect(s, [0, 10, 24, 34]);
    });

    test('vários itens: o texto global é a soma; \\n, U+2028 e U+FFFC também são fronteira', () {
      final s = syntheticStarts(['abcdefghij\nklm', '\uFFFCxyz uvw'], n: 4);
      // global: "abcdefghij\nklm" (14) + "\uFFFCxyz uvw" (8) = 22; 4 → depois do \n (11);
      // 15 → depois do U+FFFC (15); 19 → depois do espaço (19)
      expect(s, [0, 11, 15, 19]);
    });

    test('o começo de um item também é fronteira (o fim de um capítulo não gruda no título do seguinte)', () {
      // global "abcdefghijkl" + "MNOP qrs": de 10, a próxima fronteira é o começo do 2º item (12)
      expect(syntheticStarts(['abcdefghijkl', 'MNOP qrs'], n: 10), [0, 12]);
    });

    test('livro sem texto: uma página', () {
      expect(syntheticStarts([''], n: 1500), [0]);
      expect(syntheticStarts(const [], n: 1500), [0]);
    });

    test('página de uma posição = última página que começa até ela (busca binária)', () {
      final m = RefPageMap.synthetic(const [0, 18, 34, 46]);
      expect(m.total, 4);
      expect([0, 17, 18, 33, 34, 46, 999].map(m.pageOf), [1, 1, 2, 2, 3, 4, 4]);
      expect(RefPageMap.pdf(312).total, 312);
    });

    test('JSON da coluna ida e volta (os três tipos)', () {
      for (final m in [
        RefPageMap.synthetic(const [0, 1500, 3002]),
        RefPageMap.pageList(const ['i', 'ii', '1'], const [0, 40, 90]),
        RefPageMap.pdf(12),
      ]) {
        final j = jsonEncode(m.toJson());
        final back = RefPageMap.fromJson(jsonDecode(j) as Map<String, Object?>);
        expect(jsonEncode(back.toJson()), j);
        expect(back.total, m.total);
      }
      expect(
        jsonEncode(RefPageMap.synthetic(const [0]).toJson()),
        '{"kind":"synthetic","n":1500,"starts":[0]}',
      );
    });
  });

  group('índice de um EPUB', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('booknest_idx_'));
    tearDown(() => dir.deleteSync(recursive: true));

    BookIndex indexar(List<int> bytes) {
      final b = EpubBook.open(writeTemp(dir, 'i.epub', bytes));
      addTearDown(b.close);
      return buildEpubIndex(b, _sha);
    }

    test(
      'caracteres por item, sumário com (item, posição), capítulos = folhas',
      () {
        final idx = indexar(
          simpleEpub(
            chapters: const [
              (
                file: 'c1.xhtml',
                title: 'I',
                body: '<h1>Um</h1><p>Texto um.</p>',
              ),
              (
                file: 'c2.xhtml',
                title: 'II',
                body: '<p>Antes.</p><h2 id="s">Seção</h2><p>Dois.</p>',
              ),
            ],
            navBody:
                '<nav epub:type="toc"><ol><li><a href="c1.xhtml">Parte</a><ol>'
                '<li><a href="c1.xhtml">I</a></li><li><a href="c2.xhtml#s">II</a></li>'
                '<li><a href="perdido.xhtml">Sem item</a></li></ol></li></ol></nav>',
            manifestExtra: '<item id="n" href="n.xhtml" media-type="application/xhtml+xml"/>',
            spineExtra: '<itemref idref="n" linear="no"/>',
            extra: {'OEBPS/n.xhtml': u(xhtml('<p>Nota fora da ordem.</p>'))},
          ),
        );
        expect(idx.contentSha256, _sha);
        expect(idx.refPageVersion, 1);
        expect(idx.layout, 'reflowable');
        expect(idx.spine.map((s) => (s.path, s.linear, s.chars)), [
          ('OEBPS/c1.xhtml', true, 'Um\nTexto um.'.length),
          ('OEBPS/c2.xhtml', true, 'Antes.\nSeção\nDois.'.length),
          ('OEBPS/n.xhtml', false, 'Nota fora da ordem.'.length),
        ]);
        expect(idx.totalChars, 12 + 18, reason: 'só os itens lineares');
        expect(idx.globalOffset(1, 7), 12 + 7);
        expect(
          idx.globalOffset(2, 0),
          isNull,
          reason: 'item não linear fica fora da régua global',
        );
        expect(
          idx.toc.map((t) => (t.title, t.spine, t.offset, t.depth, t.leaf)),
          [
            ('Parte', 0, 0, 0, false),
            ('I', 0, 0, 1, true),
            ('II', 1, 7, 1, true),
            ('Sem item', null, null, 1, true),
          ],
        );
        expect(idx.chaptersTotal, 3);
        expect(idx.refPages.kind, 'synthetic');
        expect(idx.refPagesTotal, 1);
      },
    );

    test(
      'page-list da edição vale no lugar da sintética (rótulos e posições)',
      () {
        final idx = indexar(
          simpleEpub(
            chapters: const [
              (
                file: 'c1.xhtml',
                title: 'I',
                body: '<p><span id="p1"/>Primeira.</p><p><span id="p2"/>Segunda.</p>',
              ),
              (file: 'c2.xhtml', title: 'II', body: '<p id="p3">Terceira.</p>'),
            ],
            navBody:
                '<nav epub:type="toc"><ol><li><a href="c1.xhtml">I</a></li></ol></nav>'
                '<nav epub:type="page-list"><ol><li><a href="c1.xhtml#p1">1</a></li>'
                '<li><a href="c1.xhtml#p2">2</a></li><li><a href="c2.xhtml#p3">3</a></li>'
                '<li><a href="c2.xhtml#naoexiste">4</a></li></ol></nav>',
          ),
        );
        expect(idx.refPages.kind, 'page_list');
        // "Primeira.\nSegunda." (18) + "Terceira." → p3 = 18; #naoexiste não tem lugar → a página fica fora
        expect(idx.refPages.labels, ['1', '2', '3']);
        expect(idx.refPages.starts, [0, 10, 18]);
        expect(idx.refPagesTotal, 3);
      },
    );

    test(
      'marcador de página escondido (display:none) vale onde está no texto',
      () {
        final idx = indexar(
          simpleEpub(
            chapters: const [
              (
                file: 'c1.xhtml',
                title: 'I',
                body:
                    '<p><span id="p1" style="display:none">[1]</span>Um '
                    '<span id="p2" style="display:none">[2]</span>dois.</p>',
              ),
            ],
            navBody:
                '<nav epub:type="toc"><ol><li><a href="c1.xhtml">I</a></li></ol></nav>'
                '<nav epub:type="page-list"><ol><li><a href="c1.xhtml#p1">1</a></li>'
                '<li><a href="c1.xhtml#p2">2</a></li></ol></nav>',
          ),
        );
        // "Um dois." → p2 no começo de "dois" (3)
        expect(idx.refPages.labels, ['1', '2']);
        expect(idx.refPages.starts, [0, 3]);
      },
    );

    test('livro acima do teto de texto → danificado (protege a memória)', () {
      final dir = Directory.systemTemp.createTempSync('booknest_idx_teto_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final book = EpubBook.open(
        writeTemp(
          dir,
          'g.epub',
          simpleEpub(
            chapters: const [
              (
                file: 'a.xhtml',
                title: 'I',
                body:
                    '<p>Cinquenta caracteres de texto aqui, só para medir.</p>',
              ),
              (
                file: 'b.xhtml',
                title: 'II',
                body: '<p>Mais cinquenta caracteres de texto, para passar.</p>',
              ),
            ],
          ),
        ),
      );
      addTearDown(book.close);
      expect(
        buildEpubIndex(book, _sha, maxChars: 1000).totalChars,
        greaterThan(60),
      );
      expect(
        () => buildEpubIndex(book, _sha, maxChars: 60),
        throwsA(isA<ContentDamaged>()),
      );
    });

    test(
      'G15 (D-150): o numeral do título do capítulo no texto fica na entrada',
      () {
        final idx = indexar(
          simpleEpub(
            chapters: const [
              (
                file: 'c1.xhtml',
                title: 'x',
                body:
                    '<p>Fim do anterior.</p><h5>XXXII</h5>'
                    '<h4 id="t">Olhos de ressaca.</h4><p>Tudo.</p>',
              ),
              (
                file: 'c2.xhtml',
                title: 'x',
                body: '<h5>V</h5><h4>O agregado</h4><p>Era.</p>',
              ),
              (
                file: 'c3.xhtml',
                title: 'x',
                body: '<h4>Prefácio</h4><p>Uma vez.</p>',
              ),
            ],
            navBody:
                '<nav epub:type="toc"><ol><li><a href="c1.xhtml#t">Olhos de ressaca.</a></li>'
                '<li><a href="c2.xhtml">V. O agregado</a></li>'
                '<li><a href="c3.xhtml">Prefácio</a></li>'
                '<li><a href="perdido.xhtml">Sem item</a></li></ol></nav>',
          ),
        );
        expect(idx.toc.map((t) => t.textNumeral), ['XXXII', 'V', null, null]);
        expect(idx.tocUpToDate, isTrue);
        final json = jsonDecode(idx.tocJson) as List;
        expect(
          json.every((t) => (t as Map).containsKey('text_numeral')),
          isTrue,
        );
        final back = BookIndex.fromColumns(
          contentSha256: _sha,
          refPageVersion: 1,
          spineJson: idx.spineJson,
          tocJson: idx.tocJson,
          refPagesJson: idx.refPagesJson,
        );
        expect(back.toc.map((t) => t.textNumeral), ['XXXII', 'V', null, null]);
        expect(back.tocUpToDate, isTrue);
      },
    );

    test('G15 (D-154): sumário gravado antes da G15 (sem text_numeral) não está em dia no EPUB; no PDF e sem sumário, está', () {
      final idx = indexar(
        simpleEpub(
          chapters: const [(file: 'c.xhtml', title: 'I', body: '<p>oi</p>')],
        ),
      );
      const velho =
          '[{"title":"I","spine":0,"offset":0,"depth":0,"leaf":true}]';
      BookIndex ler(String spineJson, String toc) => BookIndex.fromColumns(
        contentSha256: _sha,
        refPageVersion: 1,
        spineJson: spineJson,
        tocJson: toc,
        refPagesJson: idx.refPagesJson,
      );
      final epub = ler(idx.spineJson, velho);
      expect(epub.tocUpToDate, isFalse);
      expect(epub.toc.single.textNumeral, isNull);
      expect(ler(idx.spineJson, '[]').tocUpToDate, isTrue);
      expect(
        ler('{"layout":"pdf","items":[]}', velho).tocUpToDate,
        isTrue,
        reason: 'no PDF o numeral vem só do rótulo',
      );
      expect(idx.tocUpToDate, isTrue);
      expect(
        BookIndex(
          contentSha256: _sha,
          layout: 'reflowable',
          spine: const [],
          toc: const [],
          refPages: RefPageMap.synthetic(const [0]),
        ).tocUpToDate,
        isTrue,
        reason: 'índice montado agora (importação, fixtures) está em dia',
      );
    });

    test(
      'colunas do banco: grava, lê de volta igual, e troca no mesmo livro',
      () async {
        final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
        addTearDown(db.close);
        final idx = indexar(
          simpleEpub(
            chapters: const [(file: 'c.xhtml', title: 'I', body: '<p>oi</p>')],
          ),
        );
        final dao = BookContentIndexDao(db);
        final em = DateTime.utc(2026, 10, 5, 20);
        await dao.upsert('livro-1', idx, builtAt: em);
        final back = await dao.byBook('livro-1');
        expect(back, isNotNull);
        expect(back!.spineJson, idx.spineJson);
        expect(back.charCountsJson, idx.charCountsJson);
        expect(back.tocJson, idx.tocJson);
        expect(back.refPagesJson, idx.refPagesJson);
        expect(back.contentSha256, _sha);
        expect(await dao.builtAt('livro-1'), em);
        await dao.upsert(
          'livro-1',
          idx,
          builtAt: em.add(const Duration(hours: 1)),
        );
        expect(await dao.builtAt('livro-1'), em.add(const Duration(hours: 1)));
        expect(await dao.byBook('outro'), isNull);
        await dao.delete('livro-1');
        expect(await dao.byBook('livro-1'), isNull);
      },
    );
  });

  test('Dom Casmurro real: 153 capítulos no sumário, páginas de 1.500 caracteres, num isolate, rápido', () async {
    final sw = Stopwatch()..start();
    final idx = await Isolate.run(() => indexEpubFile(_domCasmurro, _sha));
    sw.stop();
    expect(idx.spine, hasLength(5));
    expect(idx.chaptersTotal, 153);
    expect(idx.refPages.kind, 'synthetic');
    // a régua inteira (com a licença do Gutenberg): ~1 página a cada 1.500 caracteres
    expect(
      idx.refPagesTotal,
      inInclusiveRange(
        (idx.totalChars / 1520).floor(),
        (idx.totalChars / 1500).ceil(),
      ),
    );
    expect(idx.toc.every((t) => t.spine != null && t.offset != null), isTrue);
    // ignore: avoid_print
    print(
      'G09.2 Dom Casmurro: ${idx.totalChars} caracteres, ${idx.refPagesTotal} páginas, '
      '${sw.elapsedMilliseconds} ms (isolate, JIT)',
    );
    expect(sw.elapsedMilliseconds, lessThan(2000));
  });

  test('o título de cada capítulo do sumário está no texto canônico onde o sumário aponta', () {
    final b = EpubBook.open(_domCasmurro);
    addTearDown(b.close);
    final idx = buildEpubIndex(b, _sha);
    final textos = [
      for (var i = 0; i < b.package.spine.length; i++) b.parseItem(i).text,
    ];
    var batem = 0;
    for (final t in idx.toc) {
      final trecho = textos[t.spine!].substring(t.offset!);
      if (trecho.startsWith(t.title)) batem++;
    }
    // ignore: avoid_print
    print('G09.2 títulos do sumário no lugar: $batem de ${idx.toc.length}');
    expect(batem, greaterThanOrEqualTo(152)); // medido: 152 de 153
  });

  test('G15 (D-150) Dom Casmurro real: os 148 capítulos com I…CXLVIII lidos do texto; rosto, academia, FIM, INDICE e licença sem numeral', () {
    final b = EpubBook.open(_domCasmurro);
    addTearDown(b.close);
    final idx = buildEpubIndex(b, _sha);
    final labels = tocLabels([
      for (final t in idx.toc)
        (title: t.title, textNumeral: t.textNumeral, leaf: t.leaf),
    ]);
    expect(labels, hasLength(153));
    String romano(int n) {
      const v = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
      const s = [
        'M',
        'CM',
        'D',
        'CD',
        'C',
        'XC',
        'L',
        'XL',
        'X',
        'IX',
        'V',
        'IV',
        'I',
      ];
      final out = StringBuffer();
      var r = n;
      for (var i = 0; i < v.length; i++) {
        while (r >= v[i]) {
          out.write(s[i]);
          r -= v[i];
        }
      }
      return out.toString();
    }

    expect(
      [for (final l in labels.sublist(2, 150)) l.numeral],
      [for (var n = 1; n <= 148; n++) romano(n)],
    );
    for (final i in [0, 1, 150, 151, 152]) {
      expect(labels[i].numeral, isNull, reason: idx.toc[i].title);
    }
    expect(labels[2].title, 'Do titulo');
    // "D. Gloria." é Dona Glória, o cap. VII — não o capítulo D
    expect(labels[8], (numeral: 'VII', title: 'D. Gloria'));
    expect(labels[33], (numeral: 'XXXII', title: 'Olhos de ressaca'));
    expect(labels[149].title, 'E bem, e o resto?');
  });
}

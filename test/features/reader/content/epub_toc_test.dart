// G09.1 — sumário e lista de páginas (Anexo 03 §4, D-89): `nav` do EPUB 3 (toc e page-list) e `toc.ncx` do
// EPUB 2 (navMap e pageList), com níveis, entradas com subentradas e `href#fragmento` resolvido.
import 'dart:io';

import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/content/epub_toc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('booknest_toc_'));
  tearDown(() => dir.deleteSync(recursive: true));

  EpubBook abrir(List<int> bytes) {
    final b = EpubBook.open(writeTemp(dir, 't.epub', bytes));
    addTearDown(b.close);
    return b;
  }

  const caps = [
    (file: 'texto/c1.xhtml', title: 'I', body: '<p id="x">um</p>'),
    (file: 'texto/c2.xhtml', title: 'II', body: '<p>dois</p>'),
  ];

  test('EPUB 3: nav aninhado e page-list', () {
    final b = abrir(
      simpleEpub(
        chapters: caps,
        navBody:
            '<nav epub:type="toc"><h1>Sumário</h1><ol>'
            '<li><a href="texto/c1.xhtml">Parte  <b>um</b></a><ol>'
            '<li><a href="texto/c1.xhtml#x">Capítulo I</a></li>'
            '<li><span>Sem link</span><ol><li><a href="texto/c2.xhtml">Capítulo II</a></li></ol></li>'
            '</ol></li></ol></nav>'
            '<nav epub:type="landmarks"><ol><li><a href="texto/c2.xhtml">Não é sumário</a></li></ol></nav>'
            '<nav epub:type="page-list" hidden=""><ol>'
            '<li><a href="texto/c1.xhtml#p1">1</a></li><li><a href="texto/c2.xhtml#p2">ii</a></li>'
            '</ol></nav>',
      ),
    );
    expect(
      b.toc.map((e) => (e.title, e.path, e.fragment, e.depth, e.hasChildren)),
      [
        ('Parte um', 'OEBPS/texto/c1.xhtml', null, 0, true),
        ('Capítulo I', 'OEBPS/texto/c1.xhtml', 'x', 1, false),
        ('Sem link', null, null, 1, true),
        ('Capítulo II', 'OEBPS/texto/c2.xhtml', null, 2, false),
      ],
    );
    expect(b.pageList.map((p) => (p.label, p.path, p.fragment)), [
      ('1', 'OEBPS/texto/c1.xhtml', 'p1'),
      ('ii', 'OEBPS/texto/c2.xhtml', 'p2'),
    ]);
  });

  test('EPUB 2: toc.ncx (navMap aninhado e pageList)', () {
    const ncx = '''<?xml version="1.0" encoding="UTF-8"?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1">
<navMap>
  <navPoint id="n1" playOrder="1"><navLabel><text>Parte I</text></navLabel><content src="texto/c1.xhtml"/>
    <navPoint id="n2" playOrder="2"><navLabel><text> Capítulo
      I </text></navLabel><content src="texto/c1.xhtml#x"/></navPoint>
  </navPoint>
  <navPoint id="n3" playOrder="3"><navLabel><text>Capítulo II</text></navLabel><content src="texto/c2.xhtml"/></navPoint>
</navMap>
<pageList><pageTarget id="p1" type="normal" value="1"><navLabel><text>1</text></navLabel><content src="texto/c1.xhtml#p1"/></pageTarget></pageList>
</ncx>''';
    final b = abrir(
      simpleEpub(
        chapters: caps,
        manifestExtra: '<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>',
        // sem nav de sumário: vale o NCX
        navBody: '<nav epub:type="landmarks"><ol><li><a href="texto/c1.xhtml">x</a></li></ol></nav>',
        extra: {'OEBPS/toc.ncx': u(ncx)},
      ),
    );
    expect(b.toc.map((e) => (e.title, e.fragment, e.depth, e.hasChildren)), [
      ('Parte I', null, 0, true),
      ('Capítulo I', 'x', 1, false),
      ('Capítulo II', null, 0, false),
    ]);
    expect(b.pageList.single.label, '1');
  });

  test('sumário aninhado sem fim (20.000 níveis): abre, com os 32 primeiros níveis', () {
    const n = 20000;
    final b = abrir(
      simpleEpub(
        chapters: caps,
        navBody:
            '<nav epub:type="toc">${'<ol><li><a href="texto/c1.xhtml">x</a>' * n}'
            '${'</li></ol>' * n}</nav>',
      ),
    );
    expect(b.toc, hasLength(maxTocDepth));
    expect(b.toc.last.depth, maxTocDepth - 1);
    expect(b.toc.last.hasChildren, isFalse);
  });

  test('sem sumário nenhum: lista vazia (não é erro)', () {
    final b = abrir(simpleEpub(chapters: caps, navBody: '<p>nada</p>'));
    expect(b.toc, isEmpty);
    expect(b.pageList, isEmpty);
  });
}

// G09.1 — pacote do EPUB (Anexo 03 §3–4): container → OPF → metadados, manifest, spine, capa, sumário,
// layout; EPUB 2 e 3; caminhos relativos e com %; OPF quebrado → danificado.
import 'dart:io';

import 'package:app_leitura/features/reader/content/content_failure.dart';
import 'package:app_leitura/features/reader/content/epub_package.dart';
import 'package:app_leitura/features/reader/content/zip_reader.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('booknest_opf_'));
  tearDown(() => dir.deleteSync(recursive: true));

  EpubPackage ler(List<int> bytes) {
    final z = ZipReader.open(writeTemp(dir, 'l.epub', bytes));
    addTearDown(z.close);
    return EpubPackage.read(z);
  }

  const cap = (file: 'cap1.xhtml', title: 'Capítulo I', body: '<p>Oi.</p>');

  group('EPUB 3', () {
    test('metadados: título principal, autores com papel, língua, ISBN', () {
      final p = ler(
        simpleEpub(
          chapters: [cap],
          metadata:
              '<dc:title id="t1">Coleção Clássicos</dc:title>'
              '<meta refines="#t1" property="title-type">collection</meta>'
              '<dc:title id="t2">Dom Casmurro</dc:title>'
              '<meta refines="#t2" property="title-type">main</meta>'
              '<dc:creator id="a1">Machado de Assis</dc:creator>'
              '<meta refines="#a1" property="role" scheme="marc:relators">aut</meta>'
              '<dc:creator id="a2">Fulano Editor</dc:creator>'
              '<meta refines="#a2" property="role" scheme="marc:relators">edt</meta>'
              '<dc:creator>Sem Papel</dc:creator>'
              '<dc:language>pt-BR</dc:language>'
              '<dc:identifier id="uid">urn:uuid:123</dc:identifier>'
              '<dc:identifier>urn:isbn:978-85-359-0277-8</dc:identifier>',
        ),
      );
      expect(p.version, '3.0');
      expect(p.metadata.title, 'Dom Casmurro');
      expect(p.metadata.authors, ['Machado de Assis', 'Sem Papel']);
      expect(p.metadata.language, 'pt-BR');
      expect(p.metadata.isbn13, '9788535902778');
      expect(p.layout, EpubLayout.reflowable);
      expect(p.navPath, 'OEBPS/nav.xhtml');
      expect(p.spine.single.path, 'OEBPS/cap1.xhtml');
      expect(p.spine.single.linear, isTrue);
    });

    test('ISBN: o primeiro válido entre os identificadores (ISBN-10 vira 13; inválido é ignorado)', () {
      String? isbn(String ids) => ler(
        simpleEpub(chapters: [cap], metadata: '<dc:title>T</dc:title>$ids'),
      ).metadata.isbn13;
      expect(isbn('<dc:identifier>9788535902779</dc:identifier>'), isNull);
      expect(
        isbn('<dc:identifier>isbn:85-359-0277-5</dc:identifier>'),
        '9788535902778',
      );
      expect(
        isbn(
          '<dc:identifier>urn:uuid:1</dc:identifier>'
          '<dc:identifier xmlns:opf="http://www.idpf.org/2007/opf" opf:scheme="ISBN">9786555321235</dc:identifier>',
        ),
        isNull, // dígito errado
      );
      expect(
        isbn(
          '<dc:identifier>http://www.gutenberg.org/55752</dc:identifier>'
          '<dc:identifier>ISBN 978-0-14-143951-8</dc:identifier>',
        ),
        '9780141439518',
      );
    });

    test('capa (cover-image), spine com linear="no", páginas fixas', () {
      final p = ler(
        simpleEpub(
          chapters: [cap],
          fixedLayout: true,
          manifestExtra:
              '<item id="img" href="imagens/capa%20nova.jpg" media-type="image/jpeg" properties="cover-image"/>'
              '<item id="notas" href="../notas.xhtml" media-type="application/xhtml+xml"/>',
          spineExtra: '<itemref idref="notas" linear="no"/>',
        ),
      );
      expect(p.coverPath, 'OEBPS/imagens/capa nova.jpg');
      expect(p.layout, EpubLayout.fixed);
      expect(p.spine.map((s) => (s.path, s.linear)), [
        ('OEBPS/cap1.xhtml', true),
        ('notas.xhtml', false),
      ]);
    });

    test('o mesmo item repetido no spine (OPF-034) entra uma vez só', () {
      final p = ler(
        simpleEpub(
          chapters: [cap],
          spineExtra: '<itemref idref="ch0"/>' * 5000,
        ),
      );
      expect(p.spine.map((s) => s.path), ['OEBPS/cap1.xhtml']);
    });
  });

  group('EPUB 2', () {
    test('meta name=cover, toc.ncx pelo spine, opf:role', () {
      const opf = '''<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="id">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
<dc:title>Senhora</dc:title>
<dc:creator opf:role="aut" opf:file-as="Alencar, José de">José de Alencar</dc:creator>
<dc:creator opf:role="ill">Ilustrador</dc:creator>
<dc:language>pt</dc:language>
<dc:identifier id="id" opf:scheme="ISBN">9788535902778</dc:identifier>
<meta name="cover" content="capa"/>
</metadata>
<manifest>
<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
<item id="capa" href="capa.jpg" media-type="image/jpeg"/>
<item id="c1" href="texto/c1.html" media-type="application/xhtml+xml"/>
</manifest>
<spine toc="ncx"><itemref idref="c1"/></spine>
<guide><reference type="cover" title="Capa" href="texto/c1.html"/></guide>
</package>''';
      final p = ler(
        zipBytes([
          ('mimetype', u('application/epub+zip')),
          (
            'META-INF/container.xml',
            u(containerXml.replaceAll('OEBPS/content.opf', 'livro.opf')),
          ),
          ('livro.opf', u(opf)),
        ]),
      );
      expect(p.version, '2.0');
      expect(p.metadata.title, 'Senhora');
      expect(p.metadata.authors, ['José de Alencar']);
      expect(p.metadata.isbn13, '9788535902778');
      expect(p.coverPath, 'capa.jpg');
      expect(p.ncxPath, 'toc.ncx');
      expect(p.navPath, isNull);
      expect(p.guideCoverPath, 'texto/c1.html');
      expect(p.spine.single.path, 'texto/c1.html');
    });
  });

  group('pacote quebrado → danificado', () {
    test('sem container, container apontando para o vazio, OPF inválido, spine vazio', () {
      final casos = <List<(String, List<int>)>>[
        [('mimetype', u('application/epub+zip'))],
        [
          ('mimetype', u('application/epub+zip')),
          ('META-INF/container.xml', u(containerXml)),
        ],
        [
          ('mimetype', u('application/epub+zip')),
          ('META-INF/container.xml', u(containerXml)),
          ('OEBPS/content.opf', u('<package><metadata>')),
        ],
        [
          ('mimetype', u('application/epub+zip')),
          ('META-INF/container.xml', u(containerXml)),
          (
            'OEBPS/content.opf',
            u(
              '<package version="3.0"><metadata/><manifest/><spine/></package>',
            ),
          ),
        ],
      ];
      for (final c in casos) {
        expect(() => ler(zipBytes(c)), throwsA(isA<ContentDamaged>()));
      }
    });

    test(
      'sem título no OPF: título vazio (quem importa usa o nome do arquivo)',
      () {
        final p = ler(simpleEpub(chapters: [cap], metadata: ''));
        expect(p.metadata.title, isEmpty);
        expect(p.metadata.authors, isEmpty);
        expect(p.metadata.isbn13, isNull);
      },
    );
  });
}

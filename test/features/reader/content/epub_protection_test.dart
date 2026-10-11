// G09.1 — DRM (Anexo 03 §2): Adobe ADEPT e LCP não abrem ("este arquivo tem proteção…"); a ofuscação de
// fonte do EPUB (IDPF/Adobe) não é proteção do texto — o livro abre.
import 'dart:io';

import 'package:app_leitura/features/reader/content/content_failure.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';

String _encryption(List<(String algoritmo, String uri)> itens) =>
    '''<?xml version="1.0"?>
<encryption xmlns="urn:oasis:names:tc:opendocument:xmlns:container"
  xmlns:enc="http://www.w3.org/2001/04/xmlenc#">
${[for (final (a, uri) in itens) '<enc:EncryptedData><enc:EncryptionMethod Algorithm="$a"/><enc:CipherData><enc:CipherReference URI="$uri"/></enc:CipherData></enc:EncryptedData>'].join('\n')}
</encryption>''';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('booknest_drm_'));
  tearDown(() => dir.deleteSync(recursive: true));

  const cap = (file: 'c.xhtml', title: 'I', body: '<p>Texto.</p>');

  Object? abrir(List<(String, List<int>)> metaInf) {
    final path = writeTemp(
      dir,
      'p.epub',
      simpleEpub(chapters: [cap], metaInf: metaInf),
    );
    try {
      EpubBook.open(path).close();
      return null;
    } on ContentFailure catch (e) {
      return e;
    }
  }

  test('sem META-INF extra: abre', () => expect(abrir(const []), isNull));

  test('Adobe ADEPT (rights.xml) → protegido', () {
    final e = abrir([('META-INF/rights.xml', u('<adept:rights/>'))]);
    expect(e, isA<ContentProtected>());
    expect((e! as ContentProtected).reason, 'adobe');
  });

  test('LCP (license.lcpl) → protegido', () {
    final e = abrir([('META-INF/license.lcpl', u('{"id":"x"}'))]);
    expect((e! as ContentProtected).reason, 'lcp');
  });

  test('texto cifrado no encryption.xml → protegido', () {
    final e = abrir([
      (
        'META-INF/encryption.xml',
        u(
          _encryption([
            ('http://www.w3.org/2001/04/xmlenc#aes128-cbc', 'OEBPS/c.xhtml'),
          ]),
        ),
      ),
    ]);
    expect((e! as ContentProtected).reason, 'encrypted');
  });

  test('só fontes ofuscadas (IDPF e Adobe) → abre', () {
    expect(
      abrir([
        (
          'META-INF/encryption.xml',
          u(
            _encryption([
              ('http://www.idpf.org/2008/embedding', 'OEBPS/f/a.otf'),
              ('http://ns.adobe.com/pdf/enc#RC', 'OEBPS/f/b.ttf'),
            ]),
          ),
        ),
      ]),
      isNull,
    );
  });
}

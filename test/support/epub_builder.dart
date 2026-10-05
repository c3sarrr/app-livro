// G09 — EPUBs pequenos e determinísticos para os testes do leitor (sem arquivo binário no repositório).
// O ZIP sai do pacote `archive` com data fixa; `mimetype` primeiro e sem compressão (OCF), salvo pedido.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Data fixa das entradas (o mesmo EPUB dá sempre os mesmos bytes).
final DateTime epubDate = DateTime.utc(2026, 9, 20, 12);

/// Monta um ZIP com as [entries] na ordem dada. [stored] = sem compressão.
Uint8List zipBytes(
  List<(String, List<int>)> entries, {
  Set<String> stored = const {'mimetype'},
}) {
  final a = Archive();
  for (final (name, data) in entries) {
    a.add(
      stored.contains(name)
          ? ArchiveFile.noCompress(name, data.length, data)
          : ArchiveFile.bytes(name, data),
    );
  }
  return ZipEncoder().encodeBytes(a, modified: epubDate);
}

/// Grava [bytes] num arquivo temporário (apagado no fim do teste pelo chamador).
String writeTemp(Directory dir, String name, List<int> bytes) {
  final f = File('${dir.path}${Platform.pathSeparator}$name')
    ..writeAsBytesSync(bytes);
  return f.path;
}

List<int> u(String s) => utf8.encode(s);

const String containerXml = '''<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>''';

/// XHTML com [body] (e [head] opcional).
String xhtml(String body, {String head = '', String lang = 'pt'}) =>
    '''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="$lang">
<head><title>t</title>$head</head>
<body>$body</body>
</html>''';

/// Um capítulo do EPUB de teste: arquivo, título (sumário) e corpo XHTML.
typedef Chapter = ({String file, String title, String body});

/// EPUB 3 completo e válido: OPF, nav (sumário e, se houver, `page-list`), capítulos e arquivos extras.
/// [metadata] substitui o bloco de metadados padrão; [manifestExtra]/[spineExtra] entram como vieram.
Uint8List simpleEpub({
  String title = 'Livro de teste',
  List<String> authors = const ['Autora Um'],
  String language = 'pt',
  String? identifier,
  List<Chapter> chapters = const [],
  String? metadata,
  String manifestExtra = '',
  String spineExtra = '',
  String? navBody,
  String head = '',
  bool fixedLayout = false,
  Map<String, List<int>> extra = const {},
  List<(String, List<int>)> metaInf = const [],
}) {
  final creators = [
    for (var i = 0; i < authors.length; i++)
      '<dc:creator id="c$i">${authors[i]}</dc:creator>'
          '<meta refines="#c$i" property="role" scheme="marc:relators">aut</meta>',
  ].join();
  final meta =
      metadata ??
      '<dc:title>$title</dc:title>$creators<dc:language>$language</dc:language>'
          '<dc:identifier id="uid">${identifier ?? 'urn:uuid:0'}</dc:identifier>'
          '<meta property="dcterms:modified">2026-09-20T12:00:00Z</meta>'
          '${fixedLayout ? '<meta property="rendition:layout">pre-paginated</meta>' : ''}';
  final items = [
    for (var i = 0; i < chapters.length; i++)
      '<item id="ch$i" href="${chapters[i].file}" media-type="application/xhtml+xml"/>',
  ].join();
  final refs = [
    for (var i = 0; i < chapters.length; i++) '<itemref idref="ch$i"/>',
  ].join();
  final nav =
      navBody ??
      '<nav epub:type="toc"><ol>${[for (final c in chapters) '<li><a href="${c.file}">${c.title}</a></li>'].join()}</ol></nav>';
  final opf =
      '''<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="uid">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">$meta</metadata>
<manifest><item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>$items$manifestExtra</manifest>
<spine>$refs$spineExtra</spine>
</package>''';
  return zipBytes([
    ('mimetype', u('application/epub+zip')),
    ('META-INF/container.xml', u(containerXml)),
    ...metaInf,
    ('OEBPS/content.opf', u(opf)),
    ('OEBPS/nav.xhtml', u(xhtml(nav))),
    for (final c in chapters) ('OEBPS/${c.file}', u(xhtml(c.body, head: head))),
    for (final e in extra.entries) (e.key, e.value),
  ]);
}

/// Um JPEG mínimo de [n] bytes (assinatura FF D8 FF).
Uint8List tinyJpeg([int n = 64]) =>
    Uint8List(n)..setAll(0, const [0xFF, 0xD8, 0xFF, 0xE0]);

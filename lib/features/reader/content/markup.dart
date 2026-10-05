// G09.1 — utilidades de marcação do EPUB: bytes → texto (BOM, UTF-16, ISO-8859-1 declarado), XML com
// entidades do HTML5 (`&nbsp;`, `&mdash;`…; nenhuma entidade externa é resolvida) e caminhos do ZIP.
import 'dart:convert';
import 'dart:typed_data';

import 'package:xml/xml.dart';

import 'content_failure.dart';

/// Texto de um documento de marcação. Sem BOM, vale a codificação declarada no `<?xml … ?>` (só a família
/// latin-1 muda algo); o resto é UTF-8 com troca dos bytes inválidos.
String decodeMarkup(List<int> bytes) {
  final b = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  if (b.length >= 3 && b[0] == 0xEF && b[1] == 0xBB && b[2] == 0xBF) {
    return _clean(
      utf8.decode(Uint8List.sublistView(b, 3), allowMalformed: true),
    );
  }
  if (b.length >= 2 && b[0] == 0xFF && b[1] == 0xFE) {
    return _clean(_utf16(b, 2, Endian.little));
  }
  if (b.length >= 2 && b[0] == 0xFE && b[1] == 0xFF) {
    return _clean(_utf16(b, 2, Endian.big));
  }
  final head = latin1.decode(
    Uint8List.sublistView(b, 0, b.length < 200 ? b.length : 200),
  );
  final enc = RegExp(r'''^\s*<\?xml[^>]*encoding\s*=\s*["']([^"']+)["']''')
      .firstMatch(head)?[1]
      ?.toLowerCase();
  if (enc != null &&
      const {
        'iso-8859-1',
        'latin1',
        'latin-1',
        'iso8859-1',
        'windows-1252',
        'cp1252',
      }.contains(enc)) {
    return _clean(latin1.decode(b));
  }
  return _clean(utf8.decode(b, allowMalformed: true));
}

String _utf16(Uint8List b, int start, Endian e) {
  final d = ByteData.sublistView(b);
  final units = <int>[
    for (var i = start; i + 1 < b.length; i += 2) d.getUint16(i, e),
  ];
  return String.fromCharCodes(units);
}

/// O parser de XML não precisa do BOM nem da declaração de codificação (o texto já está decodificado).
String _clean(String s) {
  var t = s.startsWith('\uFEFF') ? s.substring(1) : s;
  t = t.replaceFirst(RegExp(r'^\s*<\?xml[^>]*\?>'), '');
  return t.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
}

/// Documento XML bem formado (OPF, container, NCX, nav). Malformado → [ContentDamaged].
XmlDocument parseXmlDocument(List<int> bytes, {String reason = 'xml'}) {
  try {
    return XmlDocument.parse(
      decodeMarkup(bytes),
      entityMapping: const XmlDefaultEntityMapping.html5(),
    );
  } on XmlException {
    throw ContentDamaged(reason);
  } on FormatException {
    throw ContentDamaged(reason);
  }
}

/// Elementos descendentes pelo nome local (qualquer prefixo/namespace).
Iterable<XmlElement> allNamed(XmlNode root, String local) =>
    root.findAllElements(local, namespaceUri: '*');

/// Filhos diretos pelo nome local.
Iterable<XmlElement> childrenNamed(XmlNode root, String local) =>
    root.findElements(local, namespaceUri: '*');

/// Atributo pelo nome local (`epub:type` → `type`, `opf:role` → `role`).
String? attr(XmlElement e, String local) =>
    e.getAttribute(local, namespaceUri: '*');

/// Texto do elemento com os espaços colapsados.
String collapsedText(XmlNode e) =>
    e.innerText.replaceAll(RegExp(r'[ \t\n\r\f]+'), ' ').trim();

/// Pasta de um caminho do ZIP (`OEBPS/texto/a.xhtml` → `OEBPS/texto/`).
String dirOf(String path) {
  final i = path.lastIndexOf('/');
  return i < 0 ? '' : path.substring(0, i + 1);
}

/// `href` relativo a [baseDir] → caminho no ZIP (sem `#`, `%20` decodificado, `..` resolvido).
/// `null` para URL externa (com esquema) ou vazia.
String? resolveHref(String baseDir, String href) {
  final h = href.trim();
  if (h.isEmpty || h.startsWith('#')) return null;
  final noFrag = h.split('#').first;
  if (RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:').hasMatch(noFrag)) return null;
  final parts = <String>[];
  final raw = noFrag.startsWith('/') ? noFrag.substring(1) : '$baseDir$noFrag';
  for (final seg in raw.split('/')) {
    if (seg.isEmpty || seg == '.') continue;
    if (seg == '..') {
      if (parts.isNotEmpty) parts.removeLast();
      continue;
    }
    String s;
    try {
      s = Uri.decodeComponent(seg);
    } on ArgumentError {
      s = seg;
    } on FormatException {
      s = seg;
    }
    parts.add(s);
  }
  return parts.isEmpty ? null : parts.join('/');
}

/// Fragmento de um `href` (`a.xhtml#x` → `x`), ou `null`.
String? fragmentOf(String href) {
  final i = href.indexOf('#');
  if (i < 0 || i == href.length - 1) return null;
  final f = href.substring(i + 1);
  try {
    return Uri.decodeComponent(f);
  } on ArgumentError {
    return f;
  } on FormatException {
    return f;
  }
}

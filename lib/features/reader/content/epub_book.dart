// G09.1 — o EPUB aberto (Anexo 03 §2–4): ZIP + pacote + proteção + sumário; cada item do spine vira blocos e
// texto canônico sob pedido. Dart puro, síncrono: feito para rodar dentro de `Isolate.run` (sem `dart:ui`).
import 'dart:typed_data';

import 'content_blocks.dart';
import 'content_failure.dart';
import 'epub_package.dart';
import 'epub_toc.dart';
import 'markup.dart';
import 'xhtml_reader.dart';
import 'zip_reader.dart';

/// Algoritmos de ofuscação de fonte do EPUB: não protegem o texto (o livro abre).
const Set<String> fontObfuscation = {
  'http://www.idpf.org/2008/embedding',
  'http://ns.adobe.com/pdf/enc#RC',
};

/// Proteção do EPUB, ou `null`: `adobe` (rights.xml), `lcp` (license.lcpl) ou `encrypted` (algo além de
/// fonte no encryption.xml).
String? epubProtection(ZipReader zip) {
  if (zip.find('META-INF/license.lcpl') != null) return 'lcp';
  if (zip.find('META-INF/rights.xml') != null) return 'adobe';
  final enc = zip.find('META-INF/encryption.xml');
  if (enc == null) return null;
  try {
    final doc = parseXmlDocument(zip.read(enc, maxBytes: 4 * 1024 * 1024));
    for (final data in allNamed(doc, 'EncryptedData')) {
      final alg = allNamed(
        data,
        'EncryptionMethod',
      ).map((m) => attr(m, 'Algorithm')).whereType<String>().firstOrNull;
      if (alg == null || !fontObfuscation.contains(alg.trim())) {
        return 'encrypted';
      }
    }
    return null;
  } on ContentDamaged {
    return 'encrypted';
  }
}

final class EpubBook {
  EpubBook._(this.zip, this.package, this._nav);

  final ZipReader zip;
  final EpubPackage package;
  final ({List<TocEntry> toc, List<PageEntry> pages}) _nav;
  final Map<String, String?> _cssCache = {};
  late final XhtmlReader _reader = XhtmlReader(css: _cssOf);

  /// Teto de uma imagem de capa (D-90).
  static const int maxCoverBytes = 5 * 1024 * 1024;

  /// Abre o EPUB em [path]. Quebrado → [ContentDamaged]; DRM → [ContentProtected].
  static EpubBook open(String path) {
    final zip = ZipReader.open(path);
    try {
      final protection = epubProtection(zip);
      if (protection != null) throw ContentProtected(protection);
      if (!_looksLikeEpub(zip)) throw const ContentUnsupported('nao_epub');
      final pkg = EpubPackage.read(zip);
      final nav = readNavigation(
        zip,
        navPath: pkg.navPath,
        ncxPath: pkg.ncxPath,
      );
      return EpubBook._(zip, pkg, nav);
    } on Object {
      zip.close();
      rethrow;
    }
  }

  List<TocEntry> get toc => _nav.toc;
  List<PageEntry> get pageList => _nav.pages;

  /// Blocos e texto canônico do item [index] do spine. Item ausente no ZIP → item vazio; imagem no spine →
  /// um bloco de imagem.
  ParsedItem parseItem(int index) {
    final item = package.spine[index];
    final name = zip.find(item.path);
    if (name == null) return ParsedItem.empty;
    if (item.mediaType.startsWith('image/')) {
      return ParsedItem(
        blocks: [ImageBlock(path: name)],
        text: objectChar,
        blockStarts: const [0],
        idOffsets: const {},
      );
    }
    return _reader.parse(zip.read(name), path: name);
  }

  /// Bytes da imagem da capa (cover-image / meta cover / 1ª imagem do XHTML de capa do guide), ou `null`.
  Uint8List? coverBytes() {
    final candidates = <String>[
      ?package.coverPath,
      if (package.guideCoverPath case final g?) ...?_firstImageOf(g),
    ];
    for (final c in candidates) {
      final name = zip.find(c);
      if (name == null) continue;
      try {
        final b = zip.read(name, maxBytes: maxCoverBytes);
        if (_isImage(b)) return b;
      } on ContentFailure {
        continue;
      }
    }
    return null;
  }

  List<String>? _firstImageOf(String xhtmlPath) {
    final name = zip.find(xhtmlPath);
    if (name == null) return null;
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png')) {
      return [name];
    }
    try {
      final item = _reader.parse(
        zip.read(name, maxBytes: 4 * 1024 * 1024),
        path: name,
      );
      final img = item.blocks.whereType<ImageBlock>().firstOrNull;
      return img == null ? null : [img.path];
    } on ContentFailure {
      return null;
    }
  }

  String? _cssOf(String path) => _cssCache.putIfAbsent(path, () {
    final name = zip.find(path);
    if (name == null) return null;
    try {
      return zip.readText(name, maxBytes: 2 * 1024 * 1024);
    } on ContentFailure {
      return null;
    }
  });

  void close() => zip.close();
}

/// Um ZIP qualquer não é EPUB: precisa do `container.xml` ou do `mimetype` do EPUB.
bool _looksLikeEpub(ZipReader zip) {
  if (zip.find('META-INF/container.xml') != null) return true;
  final m = zip.find('mimetype');
  if (m == null) return false;
  try {
    return zip.readText(m, maxBytes: 256).trim() == 'application/epub+zip';
  } on ContentFailure {
    return false;
  }
}

/// Assinatura de JPEG, PNG, GIF ou WebP.
bool _isImage(Uint8List b) {
  bool starts(List<int> sig, [int at = 0]) {
    if (b.length < at + sig.length) return false;
    for (var i = 0; i < sig.length; i++) {
      if (b[at + i] != sig[i]) return false;
    }
    return true;
  }

  return starts(const [0xFF, 0xD8, 0xFF]) ||
      starts(const [0x89, 0x50, 0x4E, 0x47]) ||
      starts('GIF8'.codeUnits) ||
      (starts('RIFF'.codeUnits) && starts('WEBP'.codeUnits, 8));
}

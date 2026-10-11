// G09.1 — sumário e lista de páginas do EPUB (Anexo 03 §4, D-89): `nav` do EPUB 3 (`epub:type="toc"` e
// `"page-list"`) ou, sem ele, o `toc.ncx` do EPUB 2 (`navMap` e `pageList`). Caminhos resolvidos para o ZIP.
import 'package:xml/xml.dart';

import 'content_failure.dart';
import 'markup.dart';
import 'zip_reader.dart';

final class TocEntry {
  const TocEntry({
    required this.title,
    required this.depth,
    required this.hasChildren,
    this.path,
    this.fragment,
  });

  final String title;

  /// Caminho no ZIP; `null` = entrada sem link (só agrupa as de baixo).
  final String? path;
  final String? fragment;

  /// 0 = nível de cima.
  final int depth;
  final bool hasChildren;
}

final class PageEntry {
  const PageEntry({required this.label, required this.path, this.fragment});

  /// Rótulo da página impressa ("12", "xii").
  final String label;
  final String path;
  final String? fragment;
}

/// Sumário e lista de páginas. Documento de navegação quebrado → listas vazias (o livro abre do mesmo jeito).
({List<TocEntry> toc, List<PageEntry> pages}) readNavigation(
  ZipReader zip, {
  String? navPath,
  String? ncxPath,
}) {
  var toc = <TocEntry>[];
  var pages = <PageEntry>[];
  if (navPath != null && zip.contains(navPath)) {
    try {
      final doc = parseXmlDocument(
        zip.read(navPath, maxBytes: 8 * 1024 * 1024),
      );
      final base = dirOf(navPath);
      for (final nav in allNamed(doc, 'nav')) {
        final type = (attr(nav, 'type') ?? '').split(RegExp(r'\s+'));
        final ol = childrenOrDescendantOl(nav);
        if (ol == null) continue;
        if (type.contains('toc') && toc.isEmpty) {
          toc = _navList(ol, base, 0);
        } else if (type.contains('page-list') && pages.isEmpty) {
          pages = [
            for (final e in _navList(ol, base, 0))
              if (e.path != null)
                PageEntry(label: e.title, path: e.path!, fragment: e.fragment),
          ];
        }
      }
    } on ContentFailure {
      // segue para o NCX
    }
  }
  if ((toc.isEmpty || pages.isEmpty) &&
      ncxPath != null &&
      zip.contains(ncxPath)) {
    try {
      final doc = parseXmlDocument(
        zip.read(ncxPath, maxBytes: 8 * 1024 * 1024),
      );
      final base = dirOf(ncxPath);
      if (toc.isEmpty) {
        final map = allNamed(doc, 'navMap').firstOrNull;
        if (map != null) toc = _ncxPoints(map, base, 0);
      }
      if (pages.isEmpty) {
        pages = [
          for (final t in allNamed(doc, 'pageTarget'))
            if (_ncxTarget(t, base) case (final p?, final f))
              PageEntry(label: _ncxLabel(t), path: p, fragment: f),
        ];
      }
    } on ContentFailure {
      // sem sumário
    }
  }
  return (toc: List.unmodifiable(toc), pages: List.unmodifiable(pages));
}

/// O `<ol>` do `<nav>` (filho direto; alguns EPUBs embrulham num `div`).
XmlElement? childrenOrDescendantOl(XmlElement nav) =>
    childrenNamed(nav, 'ol').firstOrNull ?? allNamed(nav, 'ol').firstOrNull;

/// Níveis do sumário lidos (livro de verdade usa 3 ou 4; o resto é ignorado — sumário aninhado sem fim não
/// estoura a pilha).
const int maxTocDepth = 32;

List<TocEntry> _navList(XmlElement ol, String base, int depth) {
  final out = <TocEntry>[];
  for (final li in childrenNamed(ol, 'li')) {
    final label =
        childrenNamed(li, 'a').firstOrNull ??
        childrenNamed(li, 'span').firstOrNull;
    final sub = depth + 1 >= maxTocDepth
        ? null
        : childrenNamed(li, 'ol').firstOrNull;
    final children = sub == null
        ? const <TocEntry>[]
        : _navList(sub, base, depth + 1);
    final href = label == null ? null : attr(label, 'href');
    final title = label == null ? '' : collapsedText(label);
    if (title.isNotEmpty || children.isNotEmpty) {
      out.add(
        TocEntry(
          title: title,
          path: href == null ? null : resolveHref(base, href),
          fragment: href == null ? null : fragmentOf(href),
          depth: depth,
          hasChildren: children.isNotEmpty,
        ),
      );
    }
    out.addAll(children);
  }
  return out;
}

List<TocEntry> _ncxPoints(XmlElement parent, String base, int depth) {
  final out = <TocEntry>[];
  for (final np in childrenNamed(parent, 'navPoint')) {
    final children = depth + 1 >= maxTocDepth
        ? const <TocEntry>[]
        : _ncxPoints(np, base, depth + 1);
    final (path, frag) = _ncxTarget(np, base);
    out.add(
      TocEntry(
        title: _ncxLabel(np),
        path: path,
        fragment: frag,
        depth: depth,
        hasChildren: children.isNotEmpty,
      ),
    );
    out.addAll(children);
  }
  return out;
}

String _ncxLabel(XmlElement e) {
  final label = childrenNamed(e, 'navLabel').firstOrNull;
  final text = label == null ? null : childrenNamed(label, 'text').firstOrNull;
  return text == null ? '' : collapsedText(text);
}

(String?, String?) _ncxTarget(XmlElement e, String base) {
  final src = childrenNamed(
    e,
    'content',
  ).map((c) => attr(c, 'src')).whereType<String>().firstOrNull;
  if (src == null) return (null, null);
  return (resolveHref(base, src), fragmentOf(src));
}

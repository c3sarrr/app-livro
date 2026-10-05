// G09.2 — índice do livro (`book_content_index`, Anexo 02 §3.3): itens do spine com os caracteres de cada um,
// sumário com (item, posição no texto canônico), mapa das páginas de referência (D-89) e capítulos (= entradas
// do sumário sem subentradas, D-93). Construído no isolate da importação; guardado em colunas JSON.
import 'dart:convert';

import 'epub_book.dart';
import 'epub_package.dart';
import 'ref_pages.dart';

final class SpineInfo {
  const SpineInfo({
    required this.path,
    required this.linear,
    required this.chars,
  });

  final String path;
  final bool linear;

  /// Tamanho do texto canônico do item (unidades UTF-16).
  final int chars;
}

final class TocPoint {
  const TocPoint({
    required this.title,
    required this.depth,
    required this.leaf,
    this.spine,
    this.offset,
  });

  final String title;

  /// Item do spine e posição no texto canônico dele; `null` = a entrada não aponta para o texto.
  final int? spine;
  final int? offset;
  final int depth;

  /// Sem subentradas: conta como capítulo.
  final bool leaf;
}

final class BookIndex {
  const BookIndex({
    required this.contentSha256,
    required this.layout,
    required this.spine,
    required this.toc,
    required this.refPages,
    this.refPageVersion = 1,
  });

  final String contentSha256;
  final int refPageVersion;

  /// `reflowable`, `fixed` (EPUB de páginas fixas, D-92) ou `pdf`.
  final String layout;
  final List<SpineInfo> spine;
  final List<TocPoint> toc;
  final RefPageMap refPages;

  int get refPagesTotal => refPages.total;

  /// Capítulos (folhas do sumário); sem sumário → `null`.
  int? get chaptersTotal =>
      toc.isEmpty ? null : toc.where((t) => t.leaf).length;

  /// Caracteres dos itens lineares (a régua global).
  int get totalChars =>
      spine.where((s) => s.linear).fold(0, (a, s) => a + s.chars);

  /// Posição global de ([spineIndex], [offset]); item não linear → `null`.
  int? globalOffset(int spineIndex, int offset) {
    if (spineIndex < 0 ||
        spineIndex >= spine.length ||
        !spine[spineIndex].linear) {
      return null;
    }
    var g = 0;
    for (var i = 0; i < spineIndex; i++) {
      if (spine[i].linear) g += spine[i].chars;
    }
    return g + offset;
  }

  String get spineJson => jsonEncode({
    'layout': layout,
    'items': [
      for (final s in spine)
        {'href': s.path, 'linear': s.linear, 'chars': s.chars},
    ],
  });

  String get charCountsJson => jsonEncode([for (final s in spine) s.chars]);

  String get tocJson => jsonEncode([
    for (final t in toc)
      {
        'title': t.title,
        'spine': t.spine,
        'offset': t.offset,
        'depth': t.depth,
        'leaf': t.leaf,
      },
  ]);

  String get refPagesJson => jsonEncode(refPages.toJson());

  static BookIndex fromColumns({
    required String contentSha256,
    required int refPageVersion,
    required String spineJson,
    required String tocJson,
    required String refPagesJson,
  }) {
    final s = jsonDecode(spineJson) as Map<String, Object?>;
    return BookIndex(
      contentSha256: contentSha256,
      refPageVersion: refPageVersion,
      layout: s['layout']! as String,
      spine: [
        for (final i in s['items']! as List)
          SpineInfo(
            path: (i as Map)['href'] as String,
            linear: i['linear'] as bool,
            chars: i['chars'] as int,
          ),
      ],
      toc: [
        for (final t in jsonDecode(tocJson) as List)
          TocPoint(
            title: (t as Map)['title'] as String,
            spine: t['spine'] as int?,
            offset: t['offset'] as int?,
            depth: t['depth'] as int,
            leaf: t['leaf'] as bool,
          ),
      ],
      refPages: RefPageMap.fromJson(
        jsonDecode(refPagesJson) as Map<String, Object?>,
      ),
    );
  }
}

/// Índice completo do EPUB já aberto: abre todos os itens (o texto canônico só existe aqui dentro).
BookIndex buildEpubIndex(EpubBook book, String contentSha256) {
  final items = [
    for (var i = 0; i < book.package.spine.length; i++) book.parseItem(i),
  ];
  final spine = [
    for (var i = 0; i < items.length; i++)
      SpineInfo(
        path: book.package.spine[i].path,
        linear: book.package.spine[i].linear,
        chars: items[i].text.length,
      ),
  ];
  final byPath = <String, int>{};
  for (var i = 0; i < spine.length; i++) {
    byPath.putIfAbsent(spine[i].path, () => i);
  }
  (int, int)? locate(String? path, String? fragment) {
    if (path == null) return null;
    final i = byPath[book.zip.find(path) ?? path];
    if (i == null) return null;
    return (i, fragment == null ? 0 : items[i].idOffsets[fragment] ?? 0);
  }

  final toc = <TocPoint>[];
  for (final e in book.toc) {
    final at = locate(e.path, e.fragment);
    toc.add(
      TocPoint(
        title: e.title,
        spine: at?.$1,
        offset: at?.$2,
        depth: e.depth,
        leaf: !e.hasChildren,
      ),
    );
  }
  final draft = BookIndex(
    contentSha256: contentSha256,
    layout: book.package.layout == EpubLayout.fixed ? 'fixed' : 'reflowable',
    spine: spine,
    toc: toc,
    refPages: RefPageMap.synthetic(const [0]),
  );

  // page-list da edição (só entradas que caem no texto linear), em ordem de posição
  final pages = <(int, int, String)>[];
  for (final p in book.pageList) {
    final at = locate(p.path, p.fragment);
    final g = at == null ? null : draft.globalOffset(at.$1, at.$2);
    if (g != null) pages.add((g, pages.length, p.label));
  }
  final RefPageMap refPages;
  if (pages.isNotEmpty) {
    // por posição; empate → a ordem da lista (sort estável na mão)
    final sorted = [...pages]
      ..sort((a, b) {
        final c = a.$1.compareTo(b.$1);
        return c != 0 ? c : a.$2.compareTo(b.$2);
      });
    refPages = RefPageMap.pageList(
      [for (final p in sorted) p.$3],
      [for (final p in sorted) p.$1],
    );
  } else {
    refPages = RefPageMap.synthetic(
      syntheticStarts([
        for (var i = 0; i < items.length; i++)
          if (spine[i].linear) items[i].text,
      ]),
    );
  }
  return BookIndex(
    contentSha256: contentSha256,
    layout: draft.layout,
    spine: List.unmodifiable(spine),
    toc: List.unmodifiable(toc),
    refPages: refPages,
    refPageVersion: refPageVersion,
  );
}

/// Abre, indexa e fecha (ponto de entrada do isolate).
BookIndex indexEpubFile(String path, String contentSha256) {
  final book = EpubBook.open(path);
  try {
    return buildEpubIndex(book, contentSha256);
  } finally {
    book.close();
  }
}

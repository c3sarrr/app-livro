// G09.2 — índice do livro (`book_content_index`, Anexo 02 §3.3): itens do spine com os caracteres de cada um,
// sumário com (item, posição no texto canônico), mapa das páginas de referência (D-89) e capítulos (= entradas
// do sumário sem subentradas, D-93). Construído no isolate da importação; guardado em colunas JSON.
import 'dart:convert';
import 'dart:math' as math;

import 'content_failure.dart';
import 'epub_book.dart';
import 'epub_package.dart';
import 'ref_pages.dart';
import 'toc_labels.dart' show headingNumeral;

/// Teto do texto canônico de um livro (unidades UTF-16). Os maiores livros reais têm uns 10 milhões; acima
/// disto o arquivo é tratado como danificado (protege a memória do *isolate* contra EPUB montado para isso).
const int maxBookChars = 40 * 1000 * 1000;

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
    this.textNumeral,
  });

  final String title;

  /// O numeral do capítulo lido no texto na importação (G15, D-150): o Gutenberg põe "XXXII" num bloco logo antes de
  /// "Olhos de ressaca.". A tela usa `tocLabels` (o do texto vale antes do número do rótulo).
  final String? textNumeral;

  /// Item do spine e posição no texto canônico dele; `null` = a entrada não aponta para o texto.
  final int? spine;
  final int? offset;
  final int depth;

  /// Sem subentradas: conta como capítulo.
  final bool leaf;
}

/// Início global de cada item do spine (só os lineares contam) e, no fim, o total — um por [BookIndex].
final Expando<List<int>> _rulers = Expando('régua do índice');

List<int> _ruler(BookIndex b) => _rulers[b] ??= () {
  final out = <int>[];
  var g = 0;
  for (final s in b.spine) {
    out.add(g);
    if (s.linear) g += s.chars;
  }
  return out..add(g);
}();

final class BookIndex {
  const BookIndex({
    required this.contentSha256,
    required this.layout,
    required this.spine,
    required this.toc,
    required this.refPages,
    this.refPageVersion = 1,
    this.tocUpToDate = true,
  });

  final String contentSha256;
  final int refPageVersion;

  /// O sumário gravado já tem os numerais do texto (G15). Índice de EPUB gravado antes não tem a chave
  /// `text_numeral` e é refeito uma vez ao abrir (D-154); no PDF o numeral vem só do rótulo.
  final bool tocUpToDate;

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
  int get totalChars => _ruler(this).last;

  /// Posição global de ([spineIndex], [offset]); item não linear → `null`. O(1): a régua (início global de
  /// cada item) é calculada uma vez por índice — o leitor pergunta a cada página virada.
  int? globalOffset(int spineIndex, int offset) {
    if (spineIndex < 0 ||
        spineIndex >= spine.length ||
        !spine[spineIndex].linear) {
      return null;
    }
    return _ruler(this)[spineIndex] + offset;
  }

  /// O contrário de [globalOffset]: (item linear, caractere) da posição global [global] (limitada ao livro);
  /// `null` sem itens lineares.
  (int, int)? spineAt(int global) {
    final r = _ruler(this);
    final g = math.min(math.max(0, global), r.last);
    int? at;
    for (var i = 0; i < spine.length; i++) {
      if (!spine[i].linear) continue;
      if (at != null && r[i] > g) break;
      at = i;
    }
    if (at == null) return null;
    return (at, math.min(g - r[at], spine[at].chars));
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
        'text_numeral': t.textNumeral,
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
    final toc = jsonDecode(tocJson) as List;
    final layout = s['layout']! as String;
    return BookIndex(
      contentSha256: contentSha256,
      refPageVersion: refPageVersion,
      layout: layout,
      spine: [
        for (final i in s['items']! as List)
          SpineInfo(
            path: (i as Map)['href'] as String,
            linear: i['linear'] as bool,
            chars: i['chars'] as int,
          ),
      ],
      toc: [
        for (final t in toc)
          TocPoint(
            title: (t as Map)['title'] as String,
            spine: t['spine'] as int?,
            offset: t['offset'] as int?,
            depth: t['depth'] as int,
            leaf: t['leaf'] as bool,
            textNumeral: t['text_numeral'] as String?,
          ),
      ],
      tocUpToDate:
          layout == 'pdf' ||
          toc.every((t) => (t as Map).containsKey('text_numeral')),
      refPages: RefPageMap.fromJson(
        jsonDecode(refPagesJson) as Map<String, Object?>,
      ),
    );
  }
}

/// Índice completo do EPUB já aberto: abre todos os itens (o texto canônico só existe aqui dentro). Só o
/// texto e os `id` de cada item ficam na memória (os blocos são da tela); acima de [maxChars] → danificado.
BookIndex buildEpubIndex(
  EpubBook book,
  String contentSha256, {
  int maxChars = maxBookChars,
}) {
  final items = <({String text, Map<String, int> idOffsets})>[];
  var total = 0;
  for (var i = 0; i < book.package.spine.length; i++) {
    final parsed = book.parseItem(i);
    total += parsed.text.length;
    if (total > maxChars) throw const ContentDamaged('livro_grande');
    items.add((text: parsed.text, idOffsets: parsed.idOffsets));
  }
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
  // sumário: `#id` que não existe → começo do item; página da edição: sem o `#id`, a página não entra (um
  // começo inventado repetiria ou desordenaria as páginas)
  (int, int)? locate(String? path, String? fragment, {bool strict = false}) {
    if (path == null) return null;
    final i = byPath[book.zip.find(path) ?? path];
    if (i == null) return null;
    if (fragment == null) return (i, 0);
    final at = items[i].idOffsets[fragment];
    if (at == null) return strict ? null : (i, 0);
    return (i, at);
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
        // o numeral do título do capítulo no texto (D-150): vale antes do número do rótulo
        textNumeral: at == null
            ? null
            : headingNumeral(items[at.$1].text, at.$2),
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
    final at = locate(p.path, p.fragment, strict: true);
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

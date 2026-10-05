// G09.2 — páginas de referência ("pág. 159 de 256", D-19/D-89): estáveis entre fontes, tamanhos e telas.
// `page-list` da edição impressa quando o EPUB tem; senão uma página a cada [refPageChars] caracteres do texto
// canônico global (itens lineares do spine, em ordem, sem separador entre eles), cortando na fronteira de
// palavra seguinte. PDF = as páginas do PDF. A versão da regra vai para `user_books.ref_page_version`.

/// Versão da regra das páginas de referência (`ref_page_version`).
const int refPageVersion = 1;

/// Caracteres por página sintética (Q23 → D-89).
const int refPageChars = 1500;

/// Inícios das páginas sintéticas no texto global formado por [texts] (posições UTF-16).
List<int> syntheticStarts(List<String> texts, {int n = refPageChars}) {
  final global = texts.join();
  final starts = <int>[0];
  var next = n;
  while (next < global.length) {
    var p = next;
    while (p < global.length && !_boundaryBefore(global.codeUnitAt(p - 1))) {
      p++;
    }
    if (p >= global.length) break;
    starts.add(p);
    next = p + n;
  }
  return starts;
}

/// Uma página pode começar logo depois destes: espaço, tabulação, `\n` (entre blocos), U+2028 (`<br>`) e
/// U+FFFC (imagem, quebra de cena).
bool _boundaryBefore(int c) =>
    c == 0x20 || c == 0x09 || c == 0x0A || c == 0x2028 || c == 0xFFFC;

final class RefPageMap {
  const RefPageMap._(
    this.kind,
    this.starts, {
    this.n,
    this.labels,
    this.pdfPages,
  });

  factory RefPageMap.synthetic(List<int> starts, {int n = refPageChars}) =>
      RefPageMap._('synthetic', List.unmodifiable(starts), n: n);

  factory RefPageMap.pageList(List<String> labels, List<int> starts) =>
      RefPageMap._(
        'page_list',
        List.unmodifiable(starts),
        labels: List.unmodifiable(labels),
      );

  factory RefPageMap.pdf(int pages) =>
      RefPageMap._('pdf', const [], pdfPages: pages);

  /// `synthetic`, `page_list` ou `pdf`.
  final String kind;

  /// Posição global (texto canônico) do começo de cada página, em ordem.
  final List<int> starts;
  final int? n;
  final List<String>? labels;
  final int? pdfPages;

  int get total => kind == 'pdf' ? pdfPages! : starts.length;

  /// Página (1…[total]) da posição global [offset]: a última que começa até ela.
  int pageOf(int offset) {
    if (starts.isEmpty) return 1;
    var lo = 0;
    var hi = starts.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (starts[mid] <= offset) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo + 1;
  }

  /// Rótulo da página [page] (o da edição impressa no `page_list`; senão o número).
  String labelOf(int page) =>
      labels != null && page >= 1 && page <= labels!.length
      ? labels![page - 1]
      : '$page';

  Map<String, Object?> toJson() => switch (kind) {
    'synthetic' => {'kind': kind, 'n': n, 'starts': starts},
    'page_list' => {'kind': kind, 'labels': labels, 'starts': starts},
    _ => {'kind': kind, 'pages': pdfPages},
  };

  static RefPageMap fromJson(Map<String, Object?> j) {
    List<int> ints(Object? v) => [for (final x in v! as List) x as int];
    return switch (j['kind']) {
      'synthetic' => RefPageMap.synthetic(
        ints(j['starts']),
        n: j['n'] as int? ?? refPageChars,
      ),
      'page_list' => RefPageMap.pageList([
        for (final x in j['labels']! as List) x as String,
      ], ints(j['starts'])),
      'pdf' => RefPageMap.pdf(j['pages']! as int),
      _ => throw FormatException('ref_pages: ${j['kind']}'),
    };
  }
}

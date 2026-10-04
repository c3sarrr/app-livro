// G02 · S3 — páginas de referência (D-19, Anexo 03 §6): página sintética = a cada N caracteres
// do texto canônico global, cortando na fronteira de palavra seguinte. As fronteiras são
// k·N "puxadas" para o início da próxima palavra (sem acumular deriva).
class PaginasReferencia {
  PaginasReferencia._(this.n, this.inicios, this.total);

  factory PaginasReferencia.calcular(String textoGlobal, int n) {
    final inicios = <int>[0];
    for (var alvo = n; alvo < textoGlobal.length; alvo += n) {
      var p = alvo;
      while (p < textoGlobal.length &&
          !_espaco(textoGlobal.codeUnitAt(p - 1))) {
        p++;
      }
      while (p < textoGlobal.length && _espaco(textoGlobal.codeUnitAt(p))) {
        p++;
      }
      if (p < textoGlobal.length && p > inicios.last) inicios.add(p);
    }
    return PaginasReferencia._(n, inicios, textoGlobal.length);
  }

  final int n;
  final List<int> inicios;
  final int total;

  int get paginas => inicios.length;

  /// Página (1…paginas) do offset global.
  int paginaDe(int offset) {
    var lo = 0;
    var hi = inicios.length - 1;
    while (lo < hi) {
      final m = (lo + hi + 1) >> 1;
      if (inicios[m] <= offset) {
        lo = m;
      } else {
        hi = m - 1;
      }
    }
    return lo + 1;
  }

  static bool _espaco(int c) => c == 0x20 || c == 0x0A;
}

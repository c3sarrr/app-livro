// G09.3 — reancoragem (Anexo 03 §5.3, D-44): quando o arquivo do livro muda (outra edição, outra versão), as
// marcações acham o lugar delas no texto canônico novo pelo trecho citado. Em ordem: (1) mesmo arquivo → as
// posições guardadas; (2) o trecho exato perto do lugar antigo (±2.000), desempatado pelo texto em volta e
// pela distância; (3) o trecho exato em qualquer lugar do item; (4) aproximado, até 10 % de diferença
// (alinhamento de Sellers — o `diff_match_patch` não roda no Dart 3); (5) senão, "sem lugar": a marcação
// fica guardada e vai para a lista de grifos sem lugar (nunca é apagada).
import 'dart:math' as math;

import 'locator.dart';

/// Caracteres de contexto antes e depois do trecho (mesma regra da fixture).
const int quoteContext = 32;

/// Janela do passo 2 (Anexo 03 §5.3).
const int nearbyWindow = 2000;

/// Diferença máxima do passo aproximado.
const double fuzzyTolerance = 0.10;

/// Trecho [start, end) de [text] com até [context] caracteres antes e depois.
TextQuote quoteAt(
  String text,
  int start,
  int end, {
  int context = quoteContext,
}) => TextQuote(
  prefix: text.substring(math.max(0, start - context), start),
  exact: text.substring(start, end),
  suffix: text.substring(end, math.min(text.length, end + context)),
);

enum AnchorMethod { sameFile, exactNearby, exactFar, fuzzy, clamped }

sealed class Reanchored {
  const Reanchored();
}

final class Anchored extends Reanchored {
  const Anchored(this.start, this.end, this.method);

  final int start;
  final int end;
  final AnchorMethod method;

  @override
  bool operator ==(Object other) =>
      other is Anchored &&
      other.start == start &&
      other.end == end &&
      other.method == method;

  @override
  int get hashCode => Object.hash(start, end, method);

  @override
  String toString() => 'Anchored($start, $end, ${method.name})';
}

/// "Grifo sem lugar" (D-44): o trecho não existe mais no texto.
final class Orphaned extends Reanchored {
  const Orphaned();

  @override
  bool operator ==(Object other) => other is Orphaned;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'Orphaned()';
}

/// A âncora [a] no texto canônico [text] do item dela, sendo [currentSha] o arquivo de agora.
Reanchored reanchor(EpubAnchor a, String text, {required String currentSha}) =>
    reanchorRange(
      text: text,
      sameFile: a.sha == currentSha,
      start: a.start,
      end: a.end,
      quote: a.quote,
    );

/// A posição de leitura [l] no texto de agora: (posição, como achou). Sem citação, só o deslocamento
/// (limitado ao tamanho do texto).
(int, AnchorMethod) relocate(
  EpubLocator l,
  String text, {
  required String currentSha,
}) {
  final q = l.quote;
  final same = l.sha == currentSha;
  if (q == null || q.exact.isEmpty) {
    if (same && l.offset <= text.length) {
      return (l.offset, AnchorMethod.sameFile);
    }
    return (math.min(l.offset, text.length), AnchorMethod.clamped);
  }
  final r = reanchorRange(
    text: text,
    sameFile: same,
    start: l.offset,
    end: l.offset + q.exact.length,
    quote: q,
  );
  return switch (r) {
    Anchored(:final start, :final method) => (start, method),
    Orphaned() => (math.min(l.offset, text.length), AnchorMethod.clamped),
  };
}

Reanchored reanchorRange({
  required String text,
  required bool sameFile,
  required int start,
  required int end,
  required TextQuote quote,
}) {
  final exact = quote.exact;
  if (sameFile &&
      start >= 0 &&
      start <= end &&
      end <= text.length &&
      text.substring(start, end) == exact) {
    return Anchored(start, end, AnchorMethod.sameFile);
  }
  if (exact.isEmpty) {
    return _emptyAnchor(text, quote, start);
  }

  final all = _occurrences(text, exact);
  if (all.isNotEmpty) {
    final near = [
      for (final p in all)
        if ((p - start).abs() <= nearbyWindow) p,
    ];
    final p = _pick(
      near.isNotEmpty ? near : all,
      text,
      quote,
      exact.length,
      start,
    );
    return Anchored(
      p,
      p + exact.length,
      near.isNotEmpty ? AnchorMethod.exactNearby : AnchorMethod.exactFar,
    );
  }
  return _fuzzy(text, quote, start) ?? const Orphaned();
}

/// Âncora vazia (ponto entre linhas — espaço aberto): o texto em volta dá o ponto.
Reanchored _emptyAnchor(String text, TextQuote q, int start) {
  final ctx = q.prefix + q.suffix;
  if (ctx.isEmpty) {
    return const Orphaned();
  }
  final hits = _occurrences(text, ctx);
  if (hits.isNotEmpty) {
    final p = _nearest(hits, start - q.prefix.length) + q.prefix.length;
    return Anchored(
      p,
      p,
      (p - start).abs() <= nearbyWindow
          ? AnchorMethod.exactNearby
          : AnchorMethod.exactFar,
    );
  }
  if (q.prefix.length >= 8) {
    final h = _occurrences(text, q.prefix);
    if (h.isNotEmpty) {
      final p = _nearest(h, start - q.prefix.length) + q.prefix.length;
      return Anchored(p, p, AnchorMethod.fuzzy);
    }
  }
  if (q.suffix.length >= 8) {
    final h = _occurrences(text, q.suffix);
    if (h.isNotEmpty) {
      final p = _nearest(h, start);
      return Anchored(p, p, AnchorMethod.fuzzy);
    }
  }
  return const Orphaned();
}

List<int> _occurrences(String text, String pattern) {
  final out = <int>[];
  var i = text.indexOf(pattern);
  while (i >= 0 && out.length < 100000) {
    out.add(i);
    i = text.indexOf(pattern, i + 1);
  }
  return out;
}

int _nearest(List<int> hits, int expected) =>
    hits.reduce((a, b) => (b - expected).abs() < (a - expected).abs() ? b : a);

/// Melhor ocorrência: mais texto em volta igual à citação; empate → mais perto do lugar antigo.
int _pick(List<int> hits, String text, TextQuote q, int len, int expected) {
  var best = hits.first;
  var bestScore = -1;
  for (final p in hits) {
    final s = _context(text, q, p, p + len);
    if (s > bestScore ||
        (s == bestScore && (p - expected).abs() < (best - expected).abs())) {
      best = p;
      bestScore = s;
    }
  }
  return best;
}

/// Caracteres iguais entre o texto em volta de [start, end) e o prefixo/sufixo da citação.
int _context(String text, TextQuote q, int start, int end) {
  var a = 0;
  while (a < q.prefix.length &&
      start - 1 - a >= 0 &&
      text.codeUnitAt(start - 1 - a) ==
          q.prefix.codeUnitAt(q.prefix.length - 1 - a)) {
    a++;
  }
  var b = 0;
  while (b < q.suffix.length &&
      end + b < text.length &&
      text.codeUnitAt(end + b) == q.suffix.codeUnitAt(b)) {
    b++;
  }
  return a + b;
}

Anchored? _fuzzy(String text, TextQuote q, int expected) {
  final exact = q.exact;
  final len = exact.length;
  if (len <= 64) {
    final k = (len * fuzzyTolerance).floor();
    if (k == 0) {
      return null;
    }
    final m = _approx(text, exact, k, expected, q);
    return m == null ? null : Anchored(m.$1, m.$2, AnchorMethod.fuzzy);
  }
  // trecho longo: o começo e o fim (32 caracteres cada) acham o intervalo; o tamanho confere (±10 %)
  const piece = 32;
  final k = (piece * fuzzyTolerance).floor();
  final headQuote = TextQuote(
    prefix: q.prefix,
    exact: exact.substring(0, piece),
  );
  final tailQuote = TextQuote(
    exact: exact.substring(len - piece),
    suffix: q.suffix,
  );
  final h = _approx(text, headQuote.exact, k, expected, headQuote);
  if (h == null) {
    return null;
  }
  final t = _approx(
    text,
    tailQuote.exact,
    k,
    h.$1 + len - piece,
    tailQuote,
    from: h.$2,
  );
  if (t == null) {
    return null;
  }
  final span = t.$2 - h.$1;
  if (span < len * (1 - fuzzyTolerance) || span > len * (1 + fuzzyTolerance)) {
    return null;
  }
  return Anchored(h.$1, t.$2, AnchorMethod.fuzzy);
}

/// Melhor trecho de [text] a até [k] edições de [pattern] (Sellers: o casamento pode começar em qualquer
/// ponto). Menos edições; empate → mais texto em volta igual; depois mais perto de [expected]. Procura
/// primeiro numa janela em volta de [expected] e, sem achar, no item inteiro (a partir de [from]).
(int, int)? _approx(
  String text,
  String pattern,
  int k,
  int expected,
  TextQuote q, {
  int from = 0,
}) {
  final window = 3000 + pattern.length;
  final lo = math.max(from, expected - window);
  final hi = math.min(text.length, expected + window + pattern.length);
  return (lo < hi ? _sellers(text, pattern, k, expected, q, lo, hi) : null) ??
      ((lo > from || hi < text.length)
          ? _sellers(text, pattern, k, expected, q, from, text.length)
          : null);
}

(int, int)? _sellers(
  String text,
  String pattern,
  int k,
  int expected,
  TextQuote q,
  int lo,
  int hi,
) {
  final m = pattern.length;
  var cost = List<int>.generate(m + 1, (i) => i);
  var start = List<int>.filled(m + 1, lo);
  var nCost = List<int>.filled(m + 1, 0);
  var nStart = List<int>.filled(m + 1, 0);
  (int, int)? best;
  var bestCost = k + 1;
  var bestCtx = -1;
  for (var j = lo; j < hi; j++) {
    final c = text.codeUnitAt(j);
    nCost[0] = 0;
    nStart[0] = j + 1;
    for (var i = 1; i <= m; i++) {
      var v = cost[i - 1] + (pattern.codeUnitAt(i - 1) == c ? 0 : 1);
      var s = start[i - 1];
      final del = nCost[i - 1] + 1;
      if (del < v) {
        v = del;
        s = nStart[i - 1];
      }
      final ins = cost[i] + 1;
      if (ins < v) {
        v = ins;
        s = start[i];
      }
      nCost[i] = v;
      nStart[i] = s;
    }
    final v = nCost[m];
    if (v <= k && v <= bestCost) {
      final s = nStart[m];
      final e = j + 1;
      final ctx = _context(text, q, s, e);
      final better =
          v < bestCost ||
          ctx > bestCtx ||
          (ctx == bestCtx &&
              (s - expected).abs() < (best!.$1 - expected).abs());
      if (better) {
        best = (s, e);
        bestCost = v;
        bestCtx = ctx;
      }
    }
    final tc = cost;
    cost = nCost;
    nCost = tc;
    final ts = start;
    start = nStart;
    nStart = ts;
  }
  return best;
}

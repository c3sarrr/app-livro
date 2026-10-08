// G17 (D-171) — a frase da prévia do painel do marca-texto (tela 23b): uma linha real da página. As frases que
// começam na página (no começo do item, depois de um parágrafo ou de um fim de frase) vão até `.`, `?`, `!` ou `…`
// (com as aspas e os parênteses que fecham logo depois) seguidos de espaço, ou até o fim do parágrafo. Fica a 1ª que
// cabe sozinha na linha útil da prévia, mais as seguintes enquanto couberem; o grifo vai na palavra mais longa da 1ª
// (letras e números; empate: a 1ª). Nenhuma cabe: as primeiras palavras da 1ª frase que cabem, com "…". Sem frase
// na página: a frase do arquivo. O espaço inseparável (D-160) sai como o comum. Dart puro: a medida vem de fora (o
// `TextPainter` do painel, em Literata 17); a `MarkerPreviewCache` guarda a última (o painel reconstrói com a sessão).
import 'package:flutter/foundation.dart' show immutable;

/// A frase do arquivo (`mk.markerPanel.preview`), para a página sem texto.
const String markerPreviewFallback = 'Olhos de ressaca? Vá, de ressaca.';

@immutable
final class MarkerPreview {
  const MarkerPreview({
    required this.text,
    required this.from,
    required this.to,
    required this.firstSentence,
  });

  /// O que a prévia mostra.
  final String text;

  /// A palavra grifada: [from]…[to) de [text].
  final int from;
  final int to;

  /// A 1ª frase sem a pontuação final (o rótulo do leitor de tela).
  final String firstSentence;

  @override
  bool operator ==(Object other) =>
      other is MarkerPreview &&
      other.text == text &&
      other.from == from &&
      other.to == to &&
      other.firstSentence == firstSentence;

  @override
  int get hashCode => Object.hash(text, from, to, firstSentence);

  @override
  String toString() => 'MarkerPreview($text, $from…$to)';
}

const MarkerPreview _fallback = MarkerPreview(
  text: markerPreviewFallback,
  from: 9,
  to: 16,
  firstSentence: 'Olhos de ressaca',
);

final RegExp _end = RegExp(r'''[.?!…]+["'”’»)\]]*(?=\s|$)''');
final RegExp _closing = RegExp(r'''[.?!…"'”’»)\]\s]+$''');
final RegExp _word = RegExp(r'[\p{L}\p{N}]+', unicode: true);

/// A prévia do trecho [start]…[end) do texto [text] do item, na largura [maxWidth] medida por [width].
MarkerPreview markerPreviewOf(
  String text, {
  required int start,
  required int end,
  required double maxWidth,
  required double Function(String) width,
}) {
  // a prévia é uma linha só: o espaço inseparável (D-160) vira o comum (o mesmo tamanho: os índices ficam)
  final sentences = [
    for (final s in _sentencesFrom(text, start, end))
      s.replaceAll('\u00A0', ' '),
  ];
  if (sentences.isEmpty) return _fallback;
  bool fits(String s) => width(s) <= maxWidth;
  for (var i = 0; i < sentences.length; i++) {
    if (!fits(sentences[i])) continue;
    var shown = sentences[i];
    for (final next in sentences.skip(i + 1)) {
      final joined = '$shown $next';
      if (!fits(joined)) break;
      shown = joined;
    }
    final (a, z) = _longestWord(sentences[i]);
    return MarkerPreview(
      text: shown,
      from: a,
      to: z,
      firstSentence: sentences[i].replaceFirst(_closing, ''),
    );
  }
  return _cut(sentences.first, fits);
}

/// Nenhuma frase cabe: as primeiras palavras de [s] que cabem com "…" (nem a 1ª: ela cortada).
MarkerPreview _cut(String s, bool Function(String) fits) {
  final words = s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  var shown = '';
  for (final w in words) {
    final next = shown.isEmpty ? w : '$shown $w';
    if (!fits('$next…')) break;
    shown = next;
  }
  if (shown.isEmpty) {
    final first = words.first;
    var n = first.length;
    while (n > 1 && !fits('${first.substring(0, n)}…')) {
      n--;
    }
    shown = first.substring(0, n);
  }
  final (a, z) = _longestWord(shown);
  return MarkerPreview(
    text: '$shown…',
    from: a,
    to: z,
    firstSentence: shown.replaceFirst(_closing, ''),
  );
}

/// A última prévia (G17): o painel reconstrói com a sessão, mas a prévia só muda com o texto, o trecho, a largura e a
/// letra ([style] — o que [markerPreviewOf] mede).
final class MarkerPreviewCache {
  ({
    String text,
    int start,
    int end,
    double maxWidth,
    Object style,
    MarkerPreview value,
  })?
  _last;

  MarkerPreview of(
    String text, {
    required int start,
    required int end,
    required double maxWidth,
    required Object style,
    required double Function(String) width,
  }) {
    final l = _last;
    if (l != null &&
        l.text == text &&
        l.start == start &&
        l.end == end &&
        l.maxWidth == maxWidth &&
        l.style == style) {
      return l.value;
    }
    final v = markerPreviewOf(
      text,
      start: start,
      end: end,
      maxWidth: maxWidth,
      width: width,
    );
    _last = (
      text: text,
      start: start,
      end: end,
      maxWidth: maxWidth,
      style: style,
      value: v,
    );
    return v;
  }
}

/// A palavra mais longa de [s] (a 1ª, no empate).
(int, int) _longestWord(String s) {
  var best = (0, 0);
  for (final m in _word.allMatches(s)) {
    if (m.end - m.start > best.$2 - best.$1) best = (m.start, m.end);
  }
  return best;
}

/// As frases que começam em [start]…[end) do item, inteiras (podem acabar depois de [end]), sem os espaços das pontas.
List<String> _sentencesFrom(String text, int start, int end) {
  final out = <String>[];
  var i = _startsSentence(text, start) ? start : _sentenceEnd(text, start);
  while (i < end) {
    var a = i;
    while (a < text.length && _isSpace(text.codeUnitAt(a))) {
      a++;
    }
    if (a >= end || a >= text.length) break;
    final z = _sentenceEnd(text, a);
    final s = text.substring(a, z).trim();
    if (s.isNotEmpty) out.add(s);
    i = z > a ? z : a + 1;
  }
  return out;
}

/// Onde acaba a frase que começa em [a]: depois da pontuação final (e das aspas e parênteses que fecham), ou no fim do
/// parágrafo.
int _sentenceEnd(String text, int a) {
  final nl = text.indexOf('\n', a);
  final para = nl < 0 ? text.length : nl;
  for (final m in _end.allMatches(text, a)) {
    return m.end < para ? m.end : para;
  }
  return para;
}

/// Se [i] começa uma frase: o começo do item, depois de uma quebra de parágrafo ou de um fim de frase.
bool _startsSentence(String text, int i) {
  if (i <= 0) return true;
  var j = i;
  var spaced = false;
  while (j > 0 && _isSpace(text.codeUnitAt(j - 1))) {
    if (text.codeUnitAt(j - 1) == 0x0A) return true;
    spaced = true;
    j--;
  }
  if (j == 0) return true;
  if (!spaced) return false;
  while (j > 0 && '"\'”’»)]'.contains(text[j - 1])) {
    j--;
  }
  return j > 0 && '.?!…'.contains(text[j - 1]);
}

bool _isSpace(int c) =>
    c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D || c == 0xA0;

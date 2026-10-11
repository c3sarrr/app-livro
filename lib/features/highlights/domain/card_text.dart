// G19.1 — o texto de um cartão da tela 25 (D-49 + R3). O cartão mostra um trecho contínuo do capítulo:
// - o contexto cinza, até 55 caracteres antes do 1º trecho, desde o começo da frase, cortado em palavra, com "…" no
//   começo quando cortado;
// - os trechos marcados e o texto entre eles;
// - depois do último: nada se ele já acaba a frase (ou o parágrafo); senão, até a próxima pontuação, em no máximo 40
//   caracteres (ponto final fica; vírgula, ponto e vírgula e dois-pontos viram "…"; sem pontuação, corte em palavra e
//   "…").
// Sem o arquivo do livro, o recuo usa a citação guardada na âncora (32 caracteres de cada lado). Dart puro.
import '../../reader/domain/anchoring.dart' show quoteContext;

/// Um pedaço do texto do cartão: de um item ([annotationId]) ou cinza/simples (`null`).
typedef CardSpan = ({String text, String? annotationId});

/// Um trecho marcado no texto do capítulo; `start == end` = um ponto (a nota à mão).
typedef CardMark = ({String id, int start, int end});

/// A citação guardada de um item (o recuo).
typedef CardQuote = ({String id, String prefix, String exact, String suffix});

/// Caracteres do contexto antes do 1º trecho (D-49).
const int contextMax = 55;

/// Caracteres que o texto segue depois do último trecho (R3).
const int tailMax = 40;

const String _ends = '.?!…';
const String _soft = ',;:';
const String _closers = '"”’»)]';

bool _isSpace(String c) => c == ' ' || c == ' ' || c == '\t';

/// O começo da frase que contém [at]: depois de um fim de frase (com a aspa ou o parêntese que fecham) e do branco,
/// depois de "\n", ou 0.
int sentenceStart(String text, int at) {
  for (var i = at - 1; i >= 0; i--) {
    final c = text[i];
    if (c == '\n') return i + 1;
    if (_isSpace(c) && i > 0) {
      var j = i - 1;
      while (j > 0 && _closers.contains(text[j])) {
        j--;
      }
      if (_ends.contains(text[j])) {
        var s = i + 1;
        while (s < at && _isSpace(text[s])) {
          s++;
        }
        return s;
      }
    }
  }
  return 0;
}

/// O contexto cinza antes de [start] (D-49).
String contextBefore(String text, int start) {
  final s = sentenceStart(text, start);
  if (start - s <= contextMax) return text.substring(s, start);
  var k = start - contextMax;
  if (k > 0 && !_isSpace(text[k - 1])) {
    final sp = text.indexOf(' ', k);
    if (sp < 0 || sp >= start) return '…';
    k = sp + 1;
  }
  return '…${text.substring(k, start)}';
}

/// O que vem depois do último trecho, que acaba em [end] (R3). [cut] = o texto acaba por corte (o sufixo guardado
/// da âncora), não no fim do item: sem pontuação, corta na palavra com "…".
String tailAfter(String text, int end, {bool cut = false}) {
  if (end >= text.length || text[end] == '\n') return '';
  var k = end - 1;
  while (k >= 0 && _closers.contains(text[k])) {
    k--;
  }
  if (k >= 0 && _ends.contains(text[k])) return '';
  final stop = end + tailMax < text.length ? end + tailMax : text.length;
  for (var i = end; i < stop; i++) {
    final c = text[i];
    if (c == '\n') return text.substring(end, i);
    if (_ends.contains(c)) {
      var j = i + 1;
      while (j < text.length && _closers.contains(text[j])) {
        j++;
      }
      return text.substring(end, j);
    }
    if (_soft.contains(c)) return '${text.substring(end, i)}…';
  }
  if (stop == text.length && !cut) return text.substring(end);
  final window = text.substring(end, stop);
  final w = window.lastIndexOf(' ');
  return '${w > 0 ? window.substring(0, w) : window}…';
}

/// Os trechos do cartão sobre o texto canônico [text] do item, com as [marks] (em qualquer ordem).
List<CardSpan> cardSpans(String text, List<CardMark> marks) {
  if (marks.isEmpty) return const [];
  final ms = [...marks]..sort((a, b) => a.start.compareTo(b.start));
  final out = <CardSpan>[];
  void add(String t, String? id) {
    if (t.isNotEmpty) out.add((text: t, annotationId: id));
  }

  add(contextBefore(text, ms.first.start), null);
  var pos = ms.first.start;
  for (final m in ms) {
    if (m.start > pos) add(text.substring(pos, m.start), null);
    final s = m.start > pos ? m.start : pos;
    if (m.end > s) add(text.substring(s, m.end), m.id);
    if (m.end > pos) pos = m.end;
  }
  add(tailAfter(text, pos), null);
  return out;
}

/// O contexto que a citação guardada dá: desde a frase, se ela começa dentro do prefixo; o prefixo inteiro, se ele é
/// mais curto que o guardado (o começo do item); senão, "…" e o que vem depois do 1º branco.
String _quotedContext(String p) {
  final s = sentenceStart(p, p.length);
  if (s > 0 || p.length < quoteContext) return p.substring(s);
  final k = p.indexOf(' ');
  return k < 0 ? '…' : '…${p.substring(k + 1)}';
}

/// O recuo sem o texto: o contexto sai do prefixo do 1º item; os exatos, separados por " … "; o fim, do sufixo do
/// último.
List<CardSpan> spansFromQuotes(List<CardQuote> quotes) {
  if (quotes.isEmpty) return const [];
  final out = <CardSpan>[];
  final ctx = _quotedContext(quotes.first.prefix);
  if (ctx.isNotEmpty) out.add((text: ctx, annotationId: null));
  for (var i = 0; i < quotes.length; i++) {
    if (i > 0) out.add((text: ' … ', annotationId: null));
    out.add((text: quotes[i].exact, annotationId: quotes[i].id));
  }
  final last = quotes.last;
  final tail = tailAfter(
    '${last.exact}${last.suffix}',
    last.exact.length,
    cut: last.suffix.length >= quoteContext,
  );
  if (tail.isNotEmpty) out.add((text: tail, annotationId: null));
  return out;
}

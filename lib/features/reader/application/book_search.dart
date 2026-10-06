// G12.4 — busca no livro (D-120): sem acento e sem maiúsculas, com as posições no texto original (a marca na
// página e o salto usam elas); o trecho de cada resultado (até 40 caracteres antes e 60 depois, cortados em
// palavra, com "…"); a busca de vários textos que para no limite; e, no EPUB, a busca num isolate que abre o
// arquivo uma vez (cancelar a assinatura mata o isolate).
import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;

import '../content/book_index.dart';
import '../content/chapter_content.dart';
import '../content/epub_book.dart';

/// A busca começa com 2 caracteres (D-120).
const int searchMinChars = 2;

/// Mais que isso: "Mais de 500 resultados. Refine a busca." (D-120).
const int searchLimit = 500;

/// Caracteres do trecho antes e depois da palavra achada.
const int excerptBefore = 40;
const int excerptAfter = 60;

/// Texto dobrado para busca (sem acento, sem maiúsculas) e, para cada unidade dobrada, a posição no original.
typedef FoldedText = ({String text, List<int> map});

/// Um resultado num texto: o intervalo no original e o trecho, com a palavra em [matchStart, matchEnd).
typedef FoundText = ({
  int start,
  int end,
  String excerpt,
  int matchStart,
  int matchEnd,
});

/// Os resultados de um texto (um item do EPUB, uma página do PDF).
typedef UnitHits = ({int unit, List<FoundText> hits});

/// Busca nos itens [spines] do EPUB em [path] (padrão: [isolateEpubSearch]; os testes buscam na hora).
typedef EpubSearchRunner = Stream<UnitHits> Function(
  String path,
  List<int> spines,
  String query,
);

// Letras de U+00C0 a U+017F sem o acento ('_' = fica como está: Æ, Ð de outra forma, ß, Œ, ligaduras).
const String _latin =
    'AAAAAA_CEEEEIIII' // C0
    'DNOOOOO_OUUUUY__' // D0
    'aaaaaa_ceeeeiiii' // E0
    'dnooooo_ouuuuy_y' // F0
    'AaAaAaCcCcCcCcDd' // 100
    'DdEeEeEeEeEeGgGg' // 110
    'GgGgHhHhIiIiIiIi' // 120
    'Ii__JjKk_LlLlLlL' // 130
    'lLlNnNnNn___OoOo' // 140
    'Oo__RrRrRrSsSsSs' // 150
    'SsTtTtTtUuUuUuUu' // 160
    'UuUuWwYyYZzZzZzs'; // 170

bool _combining(int c) => c >= 0x0300 && c <= 0x036F;

/// Some do texto dobrado: marcas combinantes, hífen discreto (U+00AD) e os caracteres de largura zero.
bool _ignored(int c) =>
    _combining(c) ||
    c == 0x00AD ||
    (c >= 0x200B && c <= 0x200D) ||
    c == 0x2060 ||
    c == 0xFEFF;

/// Espaços que contam como espaço comum (sem quebra, finos, ideográfico).
bool _isSpace(int c) =>
    c == 0x00A0 ||
    (c >= 0x2000 && c <= 0x200A) ||
    c == 0x202F ||
    c == 0x205F ||
    c == 0x3000;

/// Uma unidade: sem acento (Latin-1 e Latin Extended-A) e em caixa baixa.
int _fold(int c) {
  if (_isSpace(c)) return 0x20;
  var x = c;
  if (c >= 0xC0 && c <= 0x17F) {
    final b = _latin.codeUnitAt(c - 0xC0);
    if (b != 0x5F) x = b; // '_'
  }
  if (x < 0x80) {
    return x >= 0x41 && x <= 0x5A ? x + 0x20 : x;
  }
  final l = String.fromCharCode(x).toLowerCase();
  return l.length == 1 ? l.codeUnitAt(0) : x;
}

FoldedText foldForSearch(String s) {
  final out = StringBuffer();
  final map = <int>[];
  for (var i = 0; i < s.length; i++) {
    final c = s.codeUnitAt(i);
    // marcas combinantes (texto decomposto), hífen discreto e largura zero: somem do dobrado e ficam dentro do
    // intervalo achado
    if (_ignored(c)) continue;
    out.writeCharCode(_fold(c));
    map.add(i);
  }
  return (text: out.toString(), map: map);
}

/// Ocorrências de [query] em [text] (intervalos no texto original, sem sobrepor), até [limit].
List<(int, int)> findAll(String text, String query, {int limit = 1 << 30}) {
  final q = foldForSearch(query.trim()).text;
  if (q.length < searchMinChars || limit <= 0) return const [];
  final t = foldForSearch(text);
  final out = <(int, int)>[];
  var at = t.text.indexOf(q);
  while (at >= 0 && out.length < limit) {
    var end = t.map[at + q.length - 1] + 1;
    while (end < text.length && _combining(text.codeUnitAt(end))) {
      end++;
    }
    out.add((t.map[at], end));
    at = t.text.indexOf(q, at + q.length);
  }
  return out;
}

final RegExp _space = RegExp(r'[\s￼]+');

String _clean(String s) => s.replaceAll(_space, ' ');

/// Trecho do resultado (D-120): até 40 caracteres antes e 60 depois, cortados em palavra, com "…" de cada lado
/// que cortou; objetos (U+FFFC) e quebras viram espaço. [matchStart]/[matchEnd] = a palavra no trecho.
({String text, int matchStart, int matchEnd}) excerptAround(
  String text,
  int start,
  int end,
) {
  var a = math.max(0, start - excerptBefore);
  var b = math.min(text.length, end + excerptAfter);
  if (a > 0 && _space.matchAsPrefix(text, a - 1) == null) {
    // caiu no meio de uma palavra: começa depois do primeiro espaço (a palavra cortada sai)
    final sp = text.indexOf(_space, a);
    if (sp >= 0 && sp < start) {
      a = sp;
      while (a < start && _space.matchAsPrefix(text, a) != null) {
        a = _space.matchAsPrefix(text, a)!.end;
      }
    }
  }
  if (b < text.length) {
    // termina antes do último espaço (a palavra cortada sai)
    final sp = text.lastIndexOf(_space, b);
    if (sp >= end) b = sp;
  }
  final pre = _clean(text.substring(a, start)).trimLeft();
  final mid = _clean(text.substring(start, end));
  final post = _clean(text.substring(end, b)).trimRight();
  final head = a > 0 ? '…' : '';
  final tail = b < text.length ? '…' : '';
  final s = head.length + pre.length;
  return (
    text: '$head$pre$mid$post$tail',
    matchStart: s,
    matchEnd: s + mid.length,
  );
}

/// Busca [query] em cada texto de [units] (na ordem), parando quando o total chega a [limit] (por padrão 501: a
/// tela mostra 500 e o aviso de refinar).
Iterable<UnitHits> searchTexts(
  Iterable<int> units,
  String Function(int unit) textOf,
  String query, {
  int limit = searchLimit + 1,
}) sync* {
  if (foldForSearch(query.trim()).text.length < searchMinChars) return;
  var left = limit;
  for (final u in units) {
    if (left <= 0) return;
    final text = textOf(u);
    final found = findAll(text, query, limit: left);
    if (found.isEmpty) continue;
    left -= found.length;
    yield (
      unit: u,
      hits: [
        for (final (s, e) in found)
          () {
            final x = excerptAround(text, s, e);
            return (
              start: s,
              end: e,
              excerpt: x.text,
              matchStart: x.matchStart,
              matchEnd: x.matchEnd,
            );
          }(),
      ],
    );
  }
}

/// O capítulo do sumário (folha) onde fica a posição global [global]: a folha que começa mais perto antes dela (o
/// número da folha e o título); antes da 1ª folha, "Começo do livro" (-1); livro sem sumário: [withoutToc] (o
/// título do livro), um grupo só.
({int leaf, String title}) searchChapterAt(
  BookIndex index,
  int global, {
  String? withoutToc,
}) {
  var out = (leaf: -1, title: 'Começo do livro');
  var best = -1;
  var leaf = -1;
  var any = false;
  for (final t in index.toc) {
    if (!t.leaf) continue;
    leaf++;
    final s = t.spine;
    if (s == null) continue;
    final g = index.globalOffset(s, t.offset ?? 0);
    if (g == null) continue;
    any = true;
    if (g <= global && g >= best) {
      best = g;
      out = (leaf: leaf, title: t.title);
    }
  }
  if (!any && withoutToc != null) return (leaf: -1, title: withoutToc);
  return out;
}

/// Busca no EPUB num isolate que abre o arquivo uma vez; cada item com resultado chega pela porta. Cancelar a
/// assinatura pede ao isolate que pare no próximo capítulo: ele fecha o arquivo e termina sozinho (matar o
/// isolate deixaria o arquivo aberto).
Stream<UnitHits> isolateEpubSearch(
  String path,
  List<int> spines,
  String query,
) {
  ReceivePort? port;
  SendPort? control;
  var cancelled = false;
  late final StreamController<UnitHits> out;
  void finish() {
    port?.close();
    port = null;
    if (!out.isClosed) unawaited(out.close());
  }

  out = StreamController<UnitHits>(
    onListen: () async {
      final p = port = ReceivePort();
      p.listen((m) {
        switch (m) {
          case final SendPort c:
            control = c;
            if (cancelled) c.send(true);
          case final UnitHits u:
            if (!cancelled) out.add(u);
          case (final String kind, final String message) when kind == 'erro':
            if (!cancelled) out.addError(StateError(message));
          case [final Object? error, _]:
            // o isolate morreu fora do `finally` (falta de memória): a busca termina com erro
            if (!cancelled) out.addError(StateError('$error'));
            finish();
          default:
            // `null`: fim da busca (ou o aviso de saída do isolate)
            finish();
        }
      });
      try {
        await Isolate.spawn(
          _searchMain,
          (p.sendPort, path, spines, query),
          onExit: p.sendPort,
          onError: p.sendPort,
        );
      } on Object catch (e, st) {
        out.addError(e, st);
        finish();
      }
    },
    onCancel: () {
      cancelled = true;
      control?.send(true);
    },
  );
  return out.stream;
}

Future<void> _searchMain((SendPort, String, List<int>, String) args) async {
  final (send, path, spines, query) = args;
  final control = ReceivePort();
  var stop = false;
  control.listen((_) => stop = true);
  send.send(control.sendPort);
  EpubBook? book;
  try {
    final b = book = EpubBook.open(path);
    var left = searchLimit + 1;
    for (final s in spines) {
      // devolve a vez: o pedido de parar chega entre um capítulo e outro
      await Future<void>.delayed(Duration.zero);
      if (stop || left <= 0) break;
      for (final u in searchTexts(
        [s],
        (x) => chapterOf(b, x).item.text,
        query,
        limit: left,
      )) {
        left -= u.hits.length;
        send.send(u);
      }
    }
  } on Object catch (e) {
    send.send(('erro', '$e'));
  } finally {
    book?.close();
    control.close();
    send.send(null);
  }
}

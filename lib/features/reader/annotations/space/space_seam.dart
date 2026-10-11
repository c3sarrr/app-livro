// G18 — a costura do Espaço (R1, D-181; Anexo 03 §9.5): o dedo escolhe a fresta entre linhas mais perto dele, e a
// âncora do espaço é o fim da última frase que termina na linha de cima — o resto da linha desce com o texto de
// baixo, sem recuo (prancha 24: logo depois de "Vá, de ressaca."). Sem frase na linha, o fim dela (ou o último
// branco, se ela quebra no hífen); na linha que fecha o parágrafo, o fim dele, sem partir nada.
import '../ink/ink_geometry.dart';

/// O que fecha uma frase.
const String _enders = '.?!…';

/// O que pode vir colado depois do fecho e ainda é da frase (aspas, parêntese, colchete).
const String _closers = '"\'”’»)]';

bool _blank(int c) => c == 0x20 || c == 0x0A || c == 0x09 || c == 0x2028;

/// R1: a âncora do espaço aberto depois da linha [from]…[to) do texto [text] (`to` = o fim da última palavra da
/// linha). `null` = a linha não tem onde partir (uma palavra só, quebrada no meio).
int? anchorAfterLine(String text, int from, int to) {
  int? last;
  for (var i = from; i < to && i < text.length; i++) {
    if (!_enders.contains(text[i])) continue;
    var j = i + 1;
    while (j < text.length && _closers.contains(text[j])) {
      j++;
    }
    if (j == text.length || _blank(text.codeUnitAt(j))) last = j;
  }
  if (last != null && last <= to) return last;
  // sem frase: o fim da linha, se ela quebra num branco (ou fecha o parágrafo)
  if (to >= text.length || _blank(text.codeUnitAt(to))) return to;
  // quebrada no meio de uma palavra (no hífen): o último branco da linha
  for (var i = to - 1; i > from; i--) {
    if (_blank(text.codeUnitAt(i))) return i;
  }
  return null;
}

/// R13: a frase que termina em [at] — desde o fim da frase anterior ou o começo do parágrafo; sem frase (o fim da
/// linha), as últimas palavras, até 6.
String sentenceBefore(String text, int at) {
  var start = 0;
  for (var i = at - 2; i > 0; i--) {
    final c = text.codeUnitAt(i);
    if (c == 0x0A) {
      start = i + 1;
      break;
    }
    if (!_blank(c)) continue;
    var k = i - 1;
    while (k >= 0 && _closers.contains(text[k])) {
      k--;
    }
    if (k >= 0 && _enders.contains(text[k])) {
      start = i + 1;
      break;
    }
  }
  final s = text.substring(start, at).trim();
  final last = s.isEmpty ? '' : s[s.length - 1];
  if (last.isNotEmpty && (_enders.contains(last) || _closers.contains(last))) {
    return s;
  }
  final words = s.split(RegExp(r'\s+'));
  return words.length <= 6 ? s : words.sublist(words.length - 6).join(' ');
}

/// A fresta escolhida: o item, a âncora, a linha de cima (índice na geometria) e a base dela (y da página).
typedef SpaceSeam = ({int unit, int at, int line, double y});

/// R1: a fresta entre linhas mais perto de [y] (coordenadas da página) e a âncora dela; `null` acima da 1ª linha,
/// sem linhas ou sem o texto do item.
SpaceSeam? seamAt(
  InkPageGeometry g,
  double y,
  String? Function(int unit) textOf,
) {
  final lines = g.lines;
  if (lines.isEmpty || y < lines.first.top) return null;
  var best = 0;
  for (var i = 1; i < lines.length; i++) {
    if ((lines[i].bottom - y).abs() < (lines[best].bottom - y).abs()) {
      best = i;
    }
  }
  final line = lines[best];
  final text = textOf(line.unit);
  final at = text == null ? null : anchorAfterLine(text, line.from, line.to);
  if (at == null) return null;
  return (unit: line.unit, at: at, line: best, y: line.bottom);
}

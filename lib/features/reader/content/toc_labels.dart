// G15.1 (D-150, D-155, D-156) — o numeral do capítulo como no livro: do rótulo do sumário ("XXXII. Olhos de ressaca",
// "Capítulo 32 — Olhos de ressaca") quando pelo menos metade dos capítulos tem número no rótulo (num sumário sem
// números, "D. Gloria." — Dona Glória, cap. VII — não é o capítulo D); senão, ou quando o rótulo não tem número, do
// título do capítulo no texto quando ele é só um número (o Gutenberg põe "XXXII" num bloco logo antes de "Olhos de
// ressaca."). O rótulo que é só o número ("XXXII", "Capítulo 1") fica como título, sem numeral. Romano só em
// maiúsculas e válido ("CIVIL" não é número). O título perde um ponto final. Puro: roda no isolate da importação.

/// O numeral (ou nada) e o título de uma entrada do sumário, como a tela 27 mostra.
typedef TocLabel = ({String? numeral, String title});

/// Romano válido (I…MMMCMXCIX), não vazio.
const String _roman =
    '(?=[MDCLXVI])M{0,3}(?:CM|CD|D?C{0,3})(?:XC|XL|L?X{0,3})(?:IX|IV|V?I{0,3})';
const String _number = '(?:$_roman|[0-9]{1,4})';
const String _prefix =
    r'(?:[Cc]ap[íi]tulo|CAP[ÍI]TULO|[Cc]ap\.|CAP\.|[Cc]hapter|CHAPTER)';

/// "Capítulo 32 — Título", "CAPÍTULO XXXII. Título", "Chapter 4: Título".
final RegExp _prefixed = RegExp('^$_prefix\\s+($_number)\\s*[.:—–-]\\s*(.+)\$');

/// "XXXII. Título", "32) Título", "IV: Título", "XXXII — Título", "1 - Título".
final RegExp _numbered = RegExp('^($_number)(?:[.):]|\\s+[—–-])\\s+(.+)\$');

/// Um bloco que é só o número: "XXXII", "32.", "Capítulo 32", "CAPITULO XXXII".
final RegExp _alone = RegExp('^(?:$_prefix\\s+)?($_number)\\.?\$');

final RegExp _spaces = RegExp(r'\s+');

/// O numeral e o título da entrada de rótulo [label]. [fromLabel] = o número do rótulo vale neste livro (ver
/// [tocLabels]) e vem primeiro (D-155); [textNumeral] = o numeral lido no texto na importação, que vale quando o rótulo
/// não tem (ou não vale); o rótulo que começa por ele não o repete no título. O rótulo que é só o número fica como
/// título, sem numeral (D-156).
TocLabel tocLabel(String label, {String? textNumeral, bool fromLabel = true}) {
  final t = label.replaceAll(_spaces, ' ').trim();
  if (_alone.hasMatch(t)) return (numeral: null, title: tocTitle(t));
  final m = _labelMatch(t);
  if (m != null && fromLabel) {
    return (numeral: m.group(1), title: tocTitle(m.group(2)!));
  }
  if (textNumeral != null) {
    if (m != null && m.group(1) == textNumeral) {
      return (numeral: textNumeral, title: tocTitle(m.group(2)!));
    }
    final rest = t.startsWith('$textNumeral ')
        ? t.substring(textNumeral.length + 1)
        : t;
    return (numeral: textNumeral, title: tocTitle(rest));
  }
  return (numeral: null, title: tocTitle(t));
}

RegExpMatch? _labelMatch(String t) =>
    _prefixed.firstMatch(t) ?? _numbered.firstMatch(t);

/// Uma entrada do sumário para [tocLabels]: o rótulo, o numeral lido no texto e se é capítulo (folha — D-93).
typedef TocLabelEntry = ({String title, String? textNumeral, bool leaf});

/// Os numerais e os títulos de um sumário inteiro: o número do rótulo só vale quando pelo menos metade dos capítulos
/// tem número no rótulo.
List<TocLabel> tocLabels(List<TocLabelEntry> entries) {
  var leaves = 0;
  var numbered = 0;
  for (final e in entries) {
    if (!e.leaf) continue;
    leaves++;
    if (_labelMatch(e.title.replaceAll(_spaces, ' ').trim()) != null) {
      numbered++;
    }
  }
  final fromLabel = leaves > 0 && numbered * 2 >= leaves;
  return [
    for (final e in entries)
      tocLabel(e.title, textNumeral: e.textNumeral, fromLabel: fromLabel),
  ];
}

/// O título como a folha mostra: espaços juntados e um ponto final a menos ("…", "!" e "?" ficam).
String tocTitle(String label) {
  final s = label.replaceAll(_spaces, ' ').trim();
  if (s.endsWith('.') && !s.endsWith('..')) {
    final c = s.substring(0, s.length - 1).trimRight();
    if (c.isNotEmpty) return c;
  }
  return s;
}

/// O numeral do capítulo no texto canônico [text] de um item, perto da entrada que começa em [offset]: o bloco dela
/// ou, se ele não é número, o bloco logo antes (blocos separados por `\n`, D-93; os vazios e os U+FFFC — imagem,
/// quebra de cena — são pulados), quando ele é só um número.
String? headingNumeral(String text, int offset) {
  if (offset < 0 || offset > text.length || text.isEmpty) return null;
  final start = offset == 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;
  // o bloco da entrada, pulando os vazios para a frente
  var at = start;
  while (true) {
    final end = _endOf(text, at);
    final b = text.substring(at, end);
    if (!_blank(b)) {
      final n = _numeralOf(b);
      if (n != null) return n;
      break;
    }
    if (end >= text.length) break;
    at = end + 1;
  }
  // o bloco antes, pulando os vazios para trás
  var end = start - 1;
  while (end > 0) {
    final s = text.lastIndexOf('\n', end - 1) + 1;
    final b = text.substring(s, end);
    if (!_blank(b)) return _numeralOf(b);
    end = s - 1;
  }
  return null;
}

int _endOf(String text, int from) {
  final e = text.indexOf('\n', from);
  return e < 0 ? text.length : e;
}

bool _blank(String b) => b.replaceAll('￼', '').trim().isEmpty;

/// O número que é o bloco inteiro (só a 1ª linha, se o título tem `<br>`); longo demais não é título de capítulo.
String? _numeralOf(String block) {
  final line = block.split(' ').first.replaceAll(_spaces, ' ').trim();
  if (line.length > 24) return null;
  return _alone.firstMatch(line)?.group(1);
}

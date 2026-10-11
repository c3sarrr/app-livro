// ISBN (Anexo 02 §7.1): dígito verificador, ISBN-10 → ISBN-13 e a região do grupo de registro
// (D-73: o grupo decide a ordem das fontes). Mesma regra do pipeline (tools/catalog), do Worker e da
// Edge Function `isbn-lookup`.

final RegExp _separadores = RegExp(r'[\s\-‐‑‒–—.]');

/// ISBN-10 ou ISBN-13 (com ou sem hífens) → ISBN-13 válido, ou null.
String? normalizeIsbn(String input) {
  final s = input.replaceAll(_separadores, '').toUpperCase();
  if (s.length == 10 && RegExp(r'^\d{9}[\dX]$').hasMatch(s)) {
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += (10 - i) * (s.codeUnitAt(i) - 48);
    }
    sum += s[9] == 'X' ? 10 : s.codeUnitAt(9) - 48;
    if (sum % 11 != 0) return null;
    final twelve = '978${s.substring(0, 9)}';
    return '$twelve${_check13(twelve)}';
  }
  if (s.length == 13 && RegExp(r'^97[89]\d{10}$').hasMatch(s)) {
    return _check13(s.substring(0, 12)) == s[12] ? s : null;
  }
  return null;
}

String _check13(String twelve) {
  var sum = 0;
  for (var i = 0; i < 12; i++) {
    sum += (twelve.codeUnitAt(i) - 48) * (i.isEven ? 1 : 3);
  }
  return '${(10 - sum % 10) % 10}';
}

/// ISBN-13 do prefixo 978 → ISBN-10 (979 não tem).
String? isbn10Of(String isbn13) {
  if (!isbn13.startsWith('978')) return null;
  final nine = isbn13.substring(3, 12);
  var sum = 0;
  for (var i = 0; i < 9; i++) {
    sum += (10 - i) * (nine.codeUnitAt(i) - 48);
  }
  final d = (11 - sum % 11) % 11;
  return '$nine${d == 10 ? 'X' : d}';
}

/// Grupo de registro do Brasil: 978-85 e 978-65 (editoras novas, desde ~2020).
bool isBrazilianIsbn(String isbn13) =>
    isbn13.startsWith('97885') || isbn13.startsWith('97865');

/// O que o leitor do código de barras entregou é um ISBN de livro (EAN-13 978/979 ou ISBN-10)?
/// O código de preço (EAN-5) e outros EAN-13 (produtos, revistas 977) não são.
String? isbnFromBarcode(String raw) {
  final s = raw.trim();
  if (!RegExp(r'^[\dXx\- ]{10,17}$').hasMatch(s)) return null;
  return normalizeIsbn(s);
}

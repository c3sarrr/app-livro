// G17.1 — os nomes das cores das telas 23 e 23b: as 6 favoritas da caneta (os rótulos do arquivo, usados pelo leitor
// de tela e, em minúsculas, no subtítulo — R8, R12) e as 4 cores do marca-texto (as mesmas da barra da tela 21 —
// R15, R17). Cor sem nome = `null` (quem chama mostra o hex).

/// As 6 favoritas da tela 23, na ordem do arquivo.
const Map<String, String> _pen = {
  '#FF552E': 'Coral',
  '#552CB7': 'Roxo',
  '#058CD7': 'Azul',
  '#00995E': 'Verde',
  '#F2A815': 'Dourado',
  '#1A1714': 'Tinta preta',
};

/// As 4 cores do marca-texto (tela 23b), na ordem do arquivo.
const Map<String, String> _marker = {
  '#FED170': 'amarelo',
  '#FFC1C6': 'rosa',
  '#ABCF82': 'verde',
  '#B6ACE4': 'lavanda',
};

/// As 4 cores do marca-texto, na ordem do arquivo (amarelo, rosa, verde, lavanda).
final List<String> markerColors = List.unmodifiable(_marker.keys);

/// O nome de uma favorita da caneta ("Coral"…"Tinta preta"); `null` se a cor não tem nome.
String? penColorName(String hex) => _pen[hex.toUpperCase()];

/// O nome de uma cor do marca-texto ("amarelo", "rosa", "verde", "lavanda"); `null` se não for uma delas.
String? markerColorName(String hex) => _marker[hex.toUpperCase()];

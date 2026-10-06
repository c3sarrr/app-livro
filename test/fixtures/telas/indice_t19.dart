// G11.5 — o índice do Dom Casmurro do mundo de referência para a tela 19 (D-34: mapa injetado, como no teste de
// números da G10). O EPUB do mundo (completo: os 148 capítulos, só alguns com os trechos de fixture) é curto,
// então as contagens de caracteres dos itens são as de um livro inteiro, escolhidas para que o 1º caractere do
// cap. XXXII (item 32 — o parágrafo da tela 19) caia na pág. 159 de 256 pela regra de 1.500 caracteres (D-89) e
// em 62 % do total. Os números da tela continuam CALCULADOS (`numbersAt`) — só as contagens são da fixture.
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';

/// Caracteres antes do cap. XXXII e no livro todo: 237.893 ÷ 383.000 = 0,62113 → "62%"; 237.893 ÷ 1.500 → pág.
/// 159; 383.000 ÷ 1.500 → 256 páginas.
const int caracteresAntesDaPagina159 = 237893;
const int caracteresDoLivro = 383000;

/// Item do spine do parágrafo da tela 19 (o item 0 é a folha de título; o item c + 1 é o capítulo c).
const int itemDaPagina159 = 32;

/// O [real] (índice do EPUB do mundo, com os caminhos e a ordem de leitura de verdade) com as contagens de um
/// livro inteiro e páginas de referência de 1.500 caracteres.
BookIndex indiceDaTela19(BookIndex real) {
  final n = real.spine.length;
  final antes = itemDaPagina159;
  final depois = n - itemDaPagina159 - 1;
  final noItem = real.spine[itemDaPagina159].chars;
  final resto = caracteresDoLivro - caracteresAntesDaPagina159 - noItem;
  int parte(int total, int partes, int i) =>
      total ~/ partes + (i < total % partes ? 1 : 0);
  final spine = [
    for (var i = 0; i < n; i++)
      SpineInfo(
        path: real.spine[i].path,
        linear: real.spine[i].linear,
        chars: i < itemDaPagina159
            ? parte(caracteresAntesDaPagina159, antes, i)
            : i == itemDaPagina159
            ? noItem
            : parte(resto, depois, i - itemDaPagina159 - 1),
      ),
  ];
  return BookIndex(
    contentSha256: real.contentSha256,
    layout: real.layout,
    spine: spine,
    toc: real.toc,
    refPages: RefPageMap.synthetic([
      for (var at = 0; at < caracteresDoLivro; at += refPageChars) at,
    ]),
    refPageVersion: real.refPageVersion,
  );
}

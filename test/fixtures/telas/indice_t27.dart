// G15 — o índice do Dom Casmurro do mundo de referência para as telas 27 e 27b (D-34: mapa injetado): a régua e as
// páginas da tela 19 (pág. 159 de 256, 62 %) com o sumário posto nas páginas de início do arquivo (121, 126, …, 179 —
// ilustrativas, D-51f, Anexo 03 §6). O cap. XXXII começa de modo que a pág. 159 (o 1º caractere do item 32) fique a
// 18/44 dele: o anel da prancha (44 de perímetro, offset 26). Os números da tela continuam CALCULADOS
// (`buildTocView`) — só os começos dos capítulos são da fixture.
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';

import '../sumario_dom_casmurro.dart';
import 'indice_t19.dart';

/// O capítulo atual da tela 27 (XXXII, a folha 31).
const int capituloDaTela27 = 31;

/// Onde o cap. XXXII começa dentro da pág. 157: (237.893 − 234.357) ÷ (243.000 − 234.357) = 0,40912 ≈ 18/44.
const int inicioDoCapituloDaTela27NaPagina = 357;

/// O [real] (índice do EPUB do mundo completo) com a régua da tela 19 e o sumário nas páginas do arquivo: o capítulo
/// c começa no início da pág. do sumário (+ 300 por capítulo anterior na mesma página — XXXVIII e XXXIX, pág. 180).
BookIndex indiceDaTela27(BookIndex real) {
  if (real.toc.length != sumarioDomCasmurro.length) {
    throw StateError('o EPUB do mundo precisa ser o completo (148 capítulos)');
  }
  final base = indiceDaTela19(real);
  final toc = <TocPoint>[];
  var anterior = -1;
  var k = 0;
  for (var c = 0; c < sumarioDomCasmurro.length; c++) {
    final p = sumarioDomCasmurro[c].pagina;
    k = p == anterior ? k + 1 : 0;
    anterior = p;
    final g =
        (p - 1) * refPageChars +
        (c == capituloDaTela27 ? inicioDoCapituloDaTela27NaPagina : 300 * k);
    final (spine, offset) = base.spineAt(g)!;
    toc.add(
      TocPoint(
        title: real.toc[c].title,
        spine: spine,
        offset: offset,
        depth: 0,
        leaf: true,
        textNumeral: real.toc[c].textNumeral,
      ),
    );
  }
  return BookIndex(
    contentSha256: base.contentSha256,
    layout: base.layout,
    spine: base.spine,
    toc: toc,
    refPages: base.refPages,
    refPageVersion: base.refPageVersion,
  );
}

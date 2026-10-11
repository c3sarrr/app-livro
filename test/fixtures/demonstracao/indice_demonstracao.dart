// R00 (D-267) — o índice do Dom Casmurro no modo demonstração: o EPUB do mundo é curto (os 148 capítulos, só alguns
// com os trechos de fixture), então as contagens de caracteres são as de um livro inteiro, como na tela 19 (G11.5):
// o 1º caractere do item 32 (o parágrafo da tela 19) na pág. 159 de 256 e em 62 % (`indice_t19.dart`). Aqui, além
// disso, cada capítulo começa na página do sumário do mundo (`sumario_dom_casmurro.dart`, o da prancha 27): o
// sumário mostra as páginas da prancha (121, 126, …) e um marcador ou grifo do começo de um capítulo (pág. 3, pág. 6)
// leva o leitor a essa mesma página. O cap. XXXII começa dentro da pág. 157 (o anel da prancha, 18/44 — como no
// `indice_t27.dart`): o ponto do sumário dele fica no fim do item anterior, porque o item 32 começa no parágrafo da
// tela 19. Os números da tela continuam calculados pelo leitor; só as contagens e os começos são da fixture.
import 'dart:math' as math;

import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';

import '../sumario_dom_casmurro.dart';
import '../telas/indice_t19.dart'
    show caracteresAntesDaPagina159, caracteresDoLivro, itemDaPagina159;
import '../telas/indice_t27.dart'
    show capituloDaTela27, inicioDoCapituloDaTela27NaPagina;

/// Onde o capítulo [c] (índice do sumário) começa no texto global: no início da página dele, + 300 por capítulo
/// anterior que começa na mesma página (LXXXII e LXXXIII, pág. 214) — na última página, que tem só 500 caracteres e
/// três capítulos, o passo encolhe para caber. O cap. XXXII, dentro da pág. 157.
int inicioDoCapituloNoDemo(int c) {
  final p = sumarioDomCasmurro[c].pagina;
  final inicioDaPagina = (p - 1) * refPageChars;
  if (c == capituloDaTela27) {
    return inicioDaPagina + inicioDoCapituloDaTela27NaPagina;
  }
  final naPagina = [
    for (var i = 0; i < sumarioDomCasmurro.length; i++)
      if (sumarioDomCasmurro[i].pagina == p) i,
  ];
  final espaco = math.min(refPageChars, caracteresDoLivro - inicioDaPagina);
  final passo = math.min(300, espaco ~/ naPagina.length);
  return inicioDaPagina + passo * naPagina.indexOf(c);
}

/// Onde o item [i] do spine começa: o item 0 é a folha de título; o item c + 1 é o capítulo c; o item 32 começa no
/// parágrafo da tela 19 (pág. 159).
int _inicioDoItem(int i) {
  if (i == 0) return 0;
  if (i == itemDaPagina159) return caracteresAntesDaPagina159;
  return inicioDoCapituloNoDemo(i - 1);
}

/// O [real] (índice do EPUB do mundo completo, com os caminhos e a ordem de leitura de verdade) com as contagens de
/// um livro inteiro, os capítulos nas páginas do sumário e páginas de referência de 1.500 caracteres.
BookIndex indiceDoDemo(BookIndex real) {
  final n = real.spine.length;
  if (n != sumarioDomCasmurro.length + 1 ||
      real.toc.length != sumarioDomCasmurro.length) {
    throw StateError('o EPUB do mundo precisa ser o completo (148 capítulos)');
  }
  final inicios = [for (var i = 0; i < n; i++) _inicioDoItem(i)];
  for (var i = 1; i < n; i++) {
    if (inicios[i] <= inicios[i - 1]) {
      throw StateError('o item $i começa antes do anterior');
    }
  }
  final spine = [
    for (var i = 0; i < n; i++)
      SpineInfo(
        path: real.spine[i].path,
        linear: real.spine[i].linear,
        chars: (i + 1 < n ? inicios[i + 1] : caracteresDoLivro) - inicios[i],
      ),
  ];
  final base = BookIndex(
    contentSha256: real.contentSha256,
    layout: real.layout,
    spine: spine,
    toc: real.toc,
    refPages: RefPageMap.synthetic([
      for (var at = 0; at < caracteresDoLivro; at += refPageChars) at,
    ]),
    refPageVersion: real.refPageVersion,
  );
  final toc = <TocPoint>[
    for (var c = 0; c < sumarioDomCasmurro.length; c++)
      () {
        final (item, offset) = base.spineAt(inicioDoCapituloNoDemo(c))!;
        return TocPoint(
          title: real.toc[c].title,
          spine: item,
          offset: offset,
          depth: 0,
          leaf: true,
          textNumeral: real.toc[c].textNumeral,
        );
      }(),
  ];
  return BookIndex(
    contentSha256: base.contentSha256,
    layout: base.layout,
    spine: base.spine,
    toc: toc,
    refPages: base.refPages,
    refPageVersion: base.refPageVersion,
  );
}

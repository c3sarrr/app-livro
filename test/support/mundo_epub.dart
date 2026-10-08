// G09.3 — o EPUB de fixture do mundo de referência (contrato da G03, `mundo_2026_09_20.dart`): montado com os
// mesmos `textosDosCapitulos` que deram as âncoras; item do spine = índice do capítulo + 1 (o item 0 é a
// página de título); capítulos sem texto de fixture ficam vazios. Cada `\n` do texto vira um `<p>`. G15: o sumário
// (`nav`) tem só os capítulos — sem a folha de rosto, como num EPUB de editora —, e no Dom Casmurro com os rótulos do
// livro, "XXXII. Olhos de ressaca" (o numeral do rótulo — D-150); a folha c do sumário é o capítulo c das anotações.
// G16 (D-160): [nbsp] troca os espaços de dentro de cada trecho por U+00A0 — o `white-space: nowrap` dos trechos
// anotados da prancha 22 (só no EPUB da tela 22; o leitor de verdade quebra como a 19). Os deslocamentos não mudam.
import 'dart:typed_data';

import '../fixtures/mundo_2026_09_20.dart';
import '../fixtures/sumario_dom_casmurro.dart';
import 'epub_builder.dart';

String _escape(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// EPUB do livro [slug] do mundo de referência. [completo] = com todos os capítulos do livro
/// (`chaptersTotal`), vazios depois do último que tem texto de fixture — para as contagens do índice
/// injetado da tela 19 terem onde ficar depois do cap. XXXII (G11, D-34).
Uint8List mundoEpub(
  String slug, {
  bool completo = false,
  Set<String> nbsp = const {},
}) {
  final textos = {
    for (final e in mundoReferencia.textosDosCapitulos[slug]!.entries)
      e.key: semQuebraNos(e.value, nbsp),
  };
  final livro = mundoReferencia.livro(slug);
  final ultimo = completo
      ? livro.chaptersTotal! - 1
      : textos.keys.reduce((a, b) => a > b ? a : b);
  String rotulo(int c) =>
      slug == Slugs.domCasmurro && c < sumarioDomCasmurro.length
      ? '${sumarioDomCasmurro[c].numeral}. ${sumarioDomCasmurro[c].titulo}'
      : 'Capítulo ${c + 1}';
  return simpleEpub(
    title: livro.title,
    authors: [livro.authorDisplay],
    navBody:
        '<nav epub:type="toc"><ol>${[for (var c = 0; c <= ultimo; c++) '<li><a href="cap${c + 1}.xhtml">${_escape(rotulo(c))}</a></li>'].join()}</ol></nav>',
    chapters: [
      (file: 'titulo.xhtml', title: livro.title, body: ''),
      for (var c = 0; c <= ultimo; c++)
        (
          file: 'cap${c + 1}.xhtml',
          title: 'Capítulo ${c + 1}',
          body: [
            for (final p in (textos[c] ?? '').split('\n'))
              if (p.isNotEmpty) '<p>${_escape(p)}</p>',
          ].join(),
        ),
    ],
  );
}

/// [texto] com os espaços de dentro de cada trecho de [trechos] trocados por U+00A0 (D-160).
String semQuebraNos(String texto, Set<String> trechos) {
  var t = texto;
  for (final trecho in trechos) {
    t = t.replaceAll(trecho, trecho.replaceAll(' ', '\u00A0'));
  }
  return t;
}

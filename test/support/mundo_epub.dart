// G09.3 — o EPUB de fixture do mundo de referência (contrato da G03, `mundo_2026_09_20.dart`): montado com os
// mesmos `textosDosCapitulos` que deram as âncoras; item do spine = índice do capítulo + 1 (o item 0 é a
// página de título); capítulos sem texto de fixture ficam vazios. Cada `\n` do texto vira um `<p>`.
import 'dart:typed_data';

import '../fixtures/mundo_2026_09_20.dart';
import 'epub_builder.dart';

String _escape(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// EPUB do livro [slug] do mundo de referência. [completo] = com todos os capítulos do livro
/// (`chaptersTotal`), vazios depois do último que tem texto de fixture — para as contagens do índice
/// injetado da tela 19 terem onde ficar depois do cap. XXXII (G11, D-34).
Uint8List mundoEpub(String slug, {bool completo = false}) {
  final textos = mundoReferencia.textosDosCapitulos[slug]!;
  final livro = mundoReferencia.livro(slug);
  final ultimo = completo
      ? livro.chaptersTotal! - 1
      : textos.keys.reduce((a, b) => a > b ? a : b);
  return simpleEpub(
    title: livro.title,
    authors: [livro.authorDisplay],
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

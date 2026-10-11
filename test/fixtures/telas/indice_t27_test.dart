// G15 — o índice injetado das telas 27/27b (D-34): as páginas de início do sumário do arquivo, 159 de 256, o cap.
// XXXII como o atual e a pág. 159 a 18/44 dele (o anel da prancha).
import 'dart:io';

import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/domain/reader_numbers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/epub_builder.dart';
import '../../support/mundo_epub.dart';
import '../mundo_2026_09_20.dart';
import '../sumario_dom_casmurro.dart';
import 'indice_t19.dart';
import 'indice_t27.dart';

void main() {
  test('páginas do sumário, 159 de 256, cap. XXXII atual a 18/44', () {
    final dir = Directory.systemTemp.createTempSync('booknest_t27_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final livro = EpubBook.open(
      writeTemp(dir, 'm.epub', mundoEpub(Slugs.domCasmurro, completo: true)),
    );
    addTearDown(livro.close);
    final real = buildEpubIndex(livro, 'a' * 64);
    final i = indiceDaTela27(real);
    expect(tocStartPages(i), [for (final s in sumarioDomCasmurro) s.pagina]);
    expect(i.refPagesTotal, 256);
    expect(
      [for (final t in i.toc) t.title],
      [for (final t in real.toc) t.title],
    );
    expect(i.toc.every((t) => t.leaf && t.depth == 0), isTrue);
    final n = numbersAt(i, itemDaPagina159, 0);
    expect(n.refPage, 159);
    expect(n.chapterIndex, 31);
    int inicio(int c) => i.globalOffset(i.toc[c].spine!, i.toc[c].offset!)!;
    final g = i.globalOffset(itemDaPagina159, 0)!;
    expect(
      (g - inicio(31)) / (inicio(32) - inicio(31)),
      closeTo(18 / 44, 0.001),
    );
    // XXXVIII e XXXIX na mesma página (180), em lugares diferentes
    expect(inicio(38), greaterThan(inicio(37)));
  });
}

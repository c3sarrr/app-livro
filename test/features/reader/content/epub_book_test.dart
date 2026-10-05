// G09.1 — o EPUB real de domínio público (Dom Casmurro, Projeto Gutenberg 55752, Anexo 03 §13): abre por
// inteiro, fora da linha principal (isolate — sem `dart:ui`), com o texto canônico em NFC.
import 'dart:isolate';

import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/content/epub_package.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

const String domCasmurro = 'test/fixtures/livros/pg55752.epub';

void main() {
  test('Dom Casmurro: metadados, capa, spine, sumário de 153 entradas', () {
    final b = EpubBook.open(domCasmurro);
    addTearDown(b.close);
    final p = b.package;
    expect(p.metadata.title, 'Dom Casmurro');
    expect(p.metadata.authors, ['Machado de Assis']);
    expect(p.metadata.language, 'pt');
    expect(p.metadata.isbn13, isNull);
    expect(p.layout, EpubLayout.reflowable);
    expect(p.spine, hasLength(5));
    final capa = b.coverBytes()!;
    expect(capa, hasLength(40980));
    expect(capa.sublist(0, 3), [0xFF, 0xD8, 0xFF]);
    expect(b.toc, hasLength(153));
    expect(b.toc.first.title, 'DOM CASMURRO POR MACHADO DE ASSIS');
    expect(b.toc.last.title, 'THE FULL PROJECT GUTENBERG™ LICENSE');
    expect(b.toc.every((e) => e.depth == 0 && !e.hasChildren), isTrue);
    expect(b.pageList, isEmpty);
  });

  test('texto canônico de cada item: NFC, sem \\r, a pág. 159 inteira num item; tudo num isolate', () async {
    final r = await Isolate.run(() {
      final b = EpubBook.open(domCasmurro);
      try {
        return [
          for (var i = 0; i < b.package.spine.length; i++) b.parseItem(i).text,
        ];
      } finally {
        b.close();
      }
    });
    expect(r, hasLength(5));
    expect(r[0], '\uFFFC', reason: 'o item 0 é só a capa (imagem)');
    for (final t in r) {
      expect(unorm.nfc(t), t);
      expect(t, isNot(contains('\r')));
    }
    final todos = r.join();
    // ortografia de 1899 no Gutenberg; as quebras de linha do HTML viram espaço
    expect(
      todos,
      contains(
        'Rhetorica dos namorados, dá-me uma comparação exacta e poetica',
      ),
    );
    expect(
      todos,
      contains('\uFFFC\nXXXII\nOlhos de ressaca.\nTudo era materia'),
    );
  });
}

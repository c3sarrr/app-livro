// R00 (D-267) — o índice do modo demonstração: o sumário nas páginas do mundo (as da prancha 27), a pág. 159 de 256 e
// os 62 % da tela 19, e as páginas guardadas no mundo batendo com as calculadas — o marcador ou o grifo da pág. 3 leva
// o leitor à pág. 3. A única que não bate é a do grifo da pág. 41: o trecho da fixture abre o cap. IX (pág. 39), e o
// EPUB curto não tem as duas páginas de texto antes dele.
import 'dart:io';

import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/mundo_epub.dart';
import '../mundo_2026_09_20.dart';
import '../sumario_dom_casmurro.dart';
import 'indice_demonstracao.dart';

void main() {
  final m = mundoReferencia;
  late BookIndex indice;

  setUpAll(() {
    final pasta = Directory.systemTemp.createTempSync('booknest_r00_indice_');
    addTearDown(() => pasta.deleteSync(recursive: true));
    final arquivo = File('${pasta.path}${Platform.pathSeparator}dc.epub')
      ..writeAsBytesSync(mundoEpub(Slugs.domCasmurro, completo: true));
    indice = indiceDoDemo(
      indexEpubFile(arquivo.path, m.domCasmurro.contentSha256!),
    );
  });

  int pagina(int item, int offset) =>
      indice.refPages.pageOf(indice.globalOffset(item, offset)!);

  test(
    'o sumário: cada capítulo na página do sumário do mundo (a prancha 27)',
    () {
      expect(indice.toc, hasLength(sumarioDomCasmurro.length));
      expect(
        [for (final p in indice.toc) pagina(p.spine!, p.offset!)],
        [for (final c in sumarioDomCasmurro) c.pagina],
      );
      // os capítulos começam no começo do item deles, menos o XXXII (o item 32 começa no parágrafo da tela 19)
      for (var c = 0; c < indice.toc.length; c++) {
        final p = indice.toc[c];
        expect(
          (p.spine, p.offset == 0),
          c == 31 ? (31, false) : (c + 1, true),
          reason: sumarioDomCasmurro[c].numeral,
        );
      }
    },
  );

  test('a tela 19: o item 32 na pág. 159 de 256, em 62 %', () {
    expect(indice.refPages.total, 256);
    expect(indice.totalChars, 383000);
    final g = indice.globalOffset(32, 0)!;
    expect(indice.refPages.pageOf(g), 159);
    expect((g / indice.totalChars * 100).round(), 62);
  });

  test('as páginas guardadas no mundo batem com as calculadas (menos a do grifo da pág. 41)', () {
    final dc = m.domCasmurro.id;
    final diferentes = <String>[];
    for (final b in m.marcadores.where((b) => b.userBookId == dc)) {
      final l = b.locator as EpubLocator;
      final calculada = pagina(l.spine, l.offset);
      if (calculada != b.refPage) {
        diferentes.add('marcador pág. ${b.refPage} → $calculada');
      }
    }
    for (final a in m.anotacoes.where((a) => a.userBookId == dc)) {
      final anc = a.anchor;
      if (anc is! EpubAnchor) continue;
      final calculada = pagina(anc.spine, anc.start);
      if (calculada != a.refPage) {
        diferentes.add('anotação pág. ${a.refPage} → $calculada');
      }
    }
    expect(diferentes, ['anotação pág. 41 → 39']);
    // e há marcadores e anotações nas páginas 3, 6 e 159 (a 27b, a 25 e a tela 19)
    expect({
      for (final b in m.marcadores.where((b) => b.userBookId == dc)) b.refPage,
    }, containsAll([3, 6, 159]));
  });
}

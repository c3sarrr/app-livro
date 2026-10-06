// G10.3 — os números do leitor (Anexo 03 §6, D-19/D-89, D-34): com o mapa de páginas injetado da fixture, a
// posição do mundo de referência dá exatamente "pág. 159 de 256 · 62%", o capítulo XXXII e as páginas de início
// do sumário (121, 126, …), mesmo com dois capítulos na mesma página; e as regras de itens fora da leitura.
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:app_leitura/features/reader/domain/reader_numbers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../fixtures/sumario_dom_casmurro.dart';

void main() {
  group('mundo de referência (mapa injetado — D-34)', () {
    // folha de rosto (100 caracteres: págs. 1 e 2) + um item por capítulo (147), 1.000 caracteres cada; a
    // página p começa no 1º capítulo que começa nela (há páginas com dois começos) ou, se nenhum começa
    // nela, 50 caracteres por página depois do começo do capítulo que a contém
    const rosto = 100;
    const porCapitulo = 1000;
    final n = sumarioDomCasmurro.length;
    final spine = [
      const SpineInfo(path: 'rosto.xhtml', linear: true, chars: rosto),
      for (var i = 0; i < n; i++)
        SpineInfo(path: 'c$i.xhtml', linear: true, chars: porCapitulo),
    ];
    final toc = [
      for (var i = 0; i < n; i++)
        TocPoint(
          title: sumarioDomCasmurro[i].titulo,
          spine: i + 1,
          offset: 0,
          depth: 0,
          leaf: true,
        ),
    ];
    final starts = <int>[];
    final labels = <String>[];
    for (var p = 1; p <= 256; p++) {
      if (p < sumarioDomCasmurro.first.pagina) {
        starts.add((p - 1) * 50);
      } else {
        final primeiro = sumarioDomCasmurro.indexWhere((c) => c.pagina == p);
        final c = primeiro >= 0 ? primeiro : Mundo.capituloDaPagina(p);
        final dentro =
            p -
            sumarioDomCasmurro[c]
                .pagina; // páginas depois do começo do capítulo
        starts.add(rosto + c * porCapitulo + dentro * 50);
      }
      labels.add('$p');
    }
    final index = BookIndex(
      contentSha256: 'e' * 64,
      layout: 'reflowable',
      spine: spine,
      toc: toc,
      refPages: RefPageMap.pageList(labels, starts),
      refPageVersion: refPageVersion,
    );

    test('a posição do mundo: pág. 159 de 256, no capítulo XXXII (31); 0,62113 → "62%"', () {
      final xxxii = sumarioDomCasmurro.indexWhere((c) => c.numeral == 'XXXII');
      expect(xxxii, 31);
      expect(Mundo.capituloDaPagina(159), xxxii);
      // começo da pág. 159 = 2 páginas depois do começo do capítulo (pág. 157)
      final dentro = (159 - sumarioDomCasmurro[xxxii].pagina) * 50;
      final r = numbersAt(index, xxxii + 1, dentro);
      expect((r.refPage, r.refTotal, r.chapterIndex), (159, 256, 31));
      expect(numbersAt(index, xxxii + 1, dentro - 1).refPage, 158);
      expect(
        numbersAt(index, xxxii + 1, 0).refPage,
        sumarioDomCasmurro[xxxii].pagina,
      );
      expect(percentOf(0.62113), '62%');
      expect(percentOf(0), '0%');
      expect(percentOf(1), '100%');
      // no meio do capítulo: ainda o capítulo 31
      expect(numbersAt(index, xxxii + 1, 999).chapterIndex, 31);
    });

    test('sumário com as páginas de início do arquivo (121, 126, …)', () {
      final paginas = tocStartPages(index);
      expect(paginas, [for (final c in sumarioDomCasmurro) c.pagina]);
      expect(paginas.where((p) => p == 121), isNotEmpty);
      expect(paginas.where((p) => p == 126), isNotEmpty);
      // dois capítulos que começam na mesma página (XXXVIII e XXXIX, pág. 180)
      expect(paginas.where((p) => p == 180), hasLength(2));
    });
  });

  group('regras', () {
    final index = BookIndex(
      contentSha256: 'e' * 64,
      layout: 'reflowable',
      spine: const [
        SpineInfo(path: 'a.xhtml', linear: true, chars: 3000),
        SpineInfo(path: 'notas.xhtml', linear: false, chars: 500),
        SpineInfo(path: 'b.xhtml', linear: true, chars: 1000),
      ],
      toc: const [
        TocPoint(title: 'Um', spine: 0, offset: 0, depth: 0, leaf: true),
        TocPoint(title: 'Sem lugar', depth: 0, leaf: true),
        TocPoint(title: 'Dois', spine: 2, offset: 0, depth: 0, leaf: true),
      ],
      refPages: RefPageMap.synthetic(const [0, 1500, 3000]),
      refPageVersion: refPageVersion,
    );

    test(
      'global só dos itens lineares; % com 5 casas; página do 1º caractere',
      () {
        final r = numbersAt(index, 2, 500);
        expect(r.progression, 0.875); // (3.000 + 500) ÷ 4.000
        expect(r.refPage, 3);
        expect(r.chapterIndex, 2);
        final a = numbersAt(index, 0, 1);
        expect((a.refPage, a.progression, a.chapterIndex), (1, 0.00025, 0));
        // a nota (fora da ordem de leitura) conta como o começo do próximo item linear
        final nota = numbersAt(index, 1, 200);
        expect((nota.refPage, nota.progression), (3, 0.75));
        // fim e além
        expect(numbersAt(index, 2, 99999).progression, 1);
        expect(tocStartPages(index), [1, null, 3]);
      },
    );

    test('sumário com partes: o capítulo conta só as folhas (como o total — "Cap. 4 de 4")', () {
      final partes = BookIndex(
        contentSha256: 'e' * 64,
        layout: 'reflowable',
        spine: [
          for (var i = 0; i < 4; i++)
            SpineInfo(path: 'c$i.xhtml', linear: true, chars: 1000),
        ],
        toc: const [
          TocPoint(
            title: 'Parte I',
            spine: 0,
            offset: 0,
            depth: 0,
            leaf: false,
          ),
          TocPoint(title: 'c1', spine: 0, offset: 0, depth: 1, leaf: true),
          TocPoint(title: 'c2', spine: 1, offset: 0, depth: 1, leaf: true),
          TocPoint(
            title: 'Parte II',
            spine: 2,
            offset: 0,
            depth: 0,
            leaf: false,
          ),
          TocPoint(title: 'c3', spine: 2, offset: 0, depth: 1, leaf: true),
          TocPoint(title: 'c4', spine: 3, offset: 0, depth: 1, leaf: true),
        ],
        refPages: RefPageMap.synthetic(const [0, 1500, 3000]),
        refPageVersion: refPageVersion,
      );
      expect(partes.chaptersTotal, 4);
      expect(numbersAt(partes, 3, 10).chapterIndex, 3);
      expect(numbersAt(partes, 2, 0).chapterIndex, 2);
      expect(numbersAt(partes, 0, 0).chapterIndex, 0);
      // a régua global é a mesma de antes (O(1) por consulta)
      expect(partes.globalOffset(3, 10), 3010);
      expect(partes.totalChars, 4000);
    });

    test('livro sem sumário: capítulo 0; sem texto: 0 %', () {
      final vazio = BookIndex(
        contentSha256: 'e' * 64,
        layout: 'reflowable',
        spine: const [SpineInfo(path: 'a.xhtml', linear: true, chars: 0)],
        toc: const [],
        refPages: RefPageMap.synthetic(const [0]),
        refPageVersion: refPageVersion,
      );
      final r = numbersAt(vazio, 0, 0);
      expect(
        (r.refPage, r.refTotal, r.progression, r.chapterIndex),
        (1, 1, 0.0, 0),
      );
    });
  });
}

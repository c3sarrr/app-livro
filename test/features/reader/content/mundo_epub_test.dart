// G09.3 — o mundo de referência dentro de um EPUB de verdade (contrato da G03): o texto canônico que o leitor
// tira do EPUB de fixture é IGUAL ao "texto canônico de fixture" de cada capítulo, e todas as marcações do
// Dom Casmurro (12 anotações, tinta, posição de leitura, 3 marcadores) caem no lugar delas. O sha da fixture é
// sintético: a reancoragem passa pelo passo 2 (trecho exato perto) e precisa dar as mesmas posições.
import 'dart:io';

import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/domain/anchoring.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../support/epub_builder.dart';
import '../../../support/mundo_epub.dart';

void main() {
  late Directory dir;
  late EpubBook livro;
  const shaDoArquivo = 'sha-do-epub-de-fixture';

  setUp(() {
    dir = Directory.systemTemp.createTempSync('booknest_mundo_');
    livro = EpubBook.open(
      writeTemp(dir, 'dom.epub', mundoEpub(Slugs.domCasmurro)),
    );
  });
  tearDown(() {
    livro.close();
    dir.deleteSync(recursive: true);
  });

  test('texto canônico de cada capítulo = o da fixture (item do spine = capítulo + 1)', () {
    final textos = mundoReferencia.textosDosCapitulos[Slugs.domCasmurro]!;
    expect(
      livro.package.spine,
      hasLength(textos.keys.reduce((a, b) => a > b ? a : b) + 2),
    );
    for (var c = 0; c + 1 < livro.package.spine.length; c++) {
      expect(
        livro.parseItem(c + 1).text,
        textos[c] ?? '',
        reason: 'capítulo $c',
      );
    }
  });

  test(
    'anotações, tinta, posição e marcadores do Dom Casmurro caem no lugar',
    () {
      final id = mundoReferencia.slugs[Slugs.domCasmurro];
      final ancoras = <EpubAnchor>[
        for (final a in mundoReferencia.anotacoesDo(Slugs.domCasmurro))
          if (a.anchor case final EpubAnchor e) e,
        for (final c in mundoReferencia.camadas)
          if (c.userBookId == id && c.anchor is EpubAnchor)
            c.anchor as EpubAnchor,
      ];
      expect(ancoras.length, greaterThanOrEqualTo(12));
      for (final a in ancoras) {
        final r = reanchor(
          a,
          livro.parseItem(a.spine).text,
          currentSha: shaDoArquivo,
        );
        expect(
          r,
          Anchored(a.start, a.end, AnchorMethod.exactNearby),
          reason: a.quote.exact,
        );
      }

      final pos =
          mundoReferencia.posicao(Slugs.domCasmurro).locator as EpubLocator;
      expect(pos.spine, 32);
      expect(
        relocate(
          pos,
          livro.parseItem(pos.spine).text,
          currentSha: shaDoArquivo,
        ),
        (pos.offset, AnchorMethod.exactNearby),
      );
      final marcadores = mundoReferencia.marcadoresDo(Slugs.domCasmurro);
      expect(marcadores, hasLength(3));
      for (final m in marcadores) {
        final l = m.locator as EpubLocator;
        final (offset, _) = relocate(
          l,
          livro.parseItem(l.spine).text,
          currentSha: shaDoArquivo,
        );
        expect(offset, l.offset);
      }
    },
  );
}

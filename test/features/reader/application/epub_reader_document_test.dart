// G11.2 — o livro EPUB aberto para a tela (Dom Casmurro real): abre onde a pessoa parou, os números saem da 1ª
// letra visível, virar grava a posição e avisa a tela, a vizinha aparece sem virar, e os links internos levam
// ao destino — o "Indice" da folha de rosto vai ao índice no fim (D-108).
import 'package:app_leitura/core/data/database/daos/reader_daos.dart';
import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/content/book_index.dart';
import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/content/ref_pages.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/domain/reader_numbers.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await LivroNaEstante.domCasmurro());
  tearDown(() async => livro.close());

  Future<EpubReaderDocument> abrir() async {
    final d = await EpubReaderDocument.open(livro.deps());
    addTearDown(d.dispose);
    return d;
  }

  test('abre onde a pessoa parou; números pela 1ª letra visível', () async {
    final meio = livro.index.spine[2].chars ~/ 2;
    await livro.guardarPosicao(2, meio);
    final d = await abrir();
    expect(d.title, 'Dom Casmurro');
    expect(d.mark.spine, 2);
    expect(d.mark.offset, lessThanOrEqualTo(meio));
    final n = numbersAt(livro.index, 2, d.mark.offset);
    expect(
      d.numbers,
      ReaderNumbersView(
        refPage: n.refPage,
        refTotal: livro.index.refPagesTotal,
        progression: n.progression,
      ),
    );
    expect(
      d.numbers.pageLabel,
      'pág. ${n.refPage} de ${livro.index.refPagesTotal}',
    );
    expect(d.shownRange.fromRef, n.refPage);
    expect(d.shownRange.toRef, greaterThanOrEqualTo(n.refPage));
  });

  test('sem posição: o começo do livro; voltar no começo = false', () async {
    final d = await abrir();
    expect(d.mark, (
      spine: livro.index.spine.indexWhere((s) => s.linear),
      offset: 0,
    ));
    expect(await d.turn(PageDirection.backward), isFalse);
    expect(await d.peek(PageDirection.backward), isNull);
  });

  test('virar: a vizinha vista antes é a página nova; a tela é avisada; a posição grava', () async {
    final d = await abrir();
    final antes = d.mark;
    var avisos = 0;
    d.changes.addListener(() => avisos++);
    final vizinha = (await d.peek(PageDirection.forward))!;
    expect(await d.turn(PageDirection.forward), isTrue);
    expect(avisos, greaterThan(0));
    expect(d.mark, isNot(antes));
    expect(d.current.spokenText, vizinha.spokenText);
    await d.flush();
    final pos = await ReadingPositionsDao(livro.db).forBook(livro.userBookId);
    final l = pos!.locator as EpubLocator;
    expect((l.spine, l.offset), (d.mark.spine, d.mark.offset));
  });

  test(
    'o "Indice" da folha de rosto leva ao índice no fim do livro (D-108)',
    () async {
      final rosto = livro.index.spine.indexWhere(
        (s) => s.path.endsWith('55752-h-0.htm.xhtml'),
      );
      final item = chapterOf(livro.epub, rosto).item;
      final run = [
        for (final b in item.blocks)
          if (b is TextBlock)
            for (final r in b.runs)
              if (r.link != null && r.text.trim() == 'Indice') r,
      ].single;
      expect(run.link, endsWith('55752-h-2.htm.xhtml#INDICE'));
      await livro.guardarPosicao(rosto, 0);
      final d = await abrir();
      final origem = d.mark;
      expect(
        await d.follow((target: run.link!, spine: rosto, offset: 0)),
        isTrue,
      );
      final alvo = livro.index.spine.indexWhere(
        (s) => s.path.endsWith('55752-h-2.htm.xhtml'),
      );
      final c = chapterOf(livro.epub, alvo);
      expect(d.mark.spine, alvo);
      expect(d.mark.offset, lessThanOrEqualTo(c.item.idOffsets['INDICE']!));
      expect(d.current.spokenText.toUpperCase(), contains('INDICE'));
      await d.goTo(origem);
      expect(d.mark, origem);
      expect(
        await d.follow((
          target: 'OEBPS/nao_existe.xhtml#x',
          spine: rosto,
          offset: 0,
        )),
        isFalse,
      );
      expect(d.mark, origem);
    },
  );

  test('resolveEpubLink: item + id; sem fragmento ou id desconhecido → começo; caminho fora → null', () async {
    final index = BookIndex(
      contentSha256: 's' * 64,
      layout: 'reflowable',
      spine: const [
        SpineInfo(path: 'OEBPS/a.xhtml', linear: true, chars: 10),
        SpineInfo(path: 'OEBPS/n.xhtml', linear: false, chars: 50),
      ],
      toc: const [],
      refPages: RefPageMap.synthetic(const [0]),
    );
    final lidos = <int>[];
    Future<ChapterContent> conteudo(int s) async {
      lidos.add(s);
      return ChapterContent(
        spineIndex: s,
        item: ParsedItem(
          blocks: const [],
          text: 'x' * 50,
          blockStarts: const [],
          idOffsets: const {'n7': 31},
        ),
        imageSizes: const {},
      );
    }

    expect(await resolveEpubLink(index, 'OEBPS/n.xhtml#n7', conteudo), (
      spine: 1,
      offset: 31,
    ));
    expect(await resolveEpubLink(index, 'OEBPS/n.xhtml', conteudo), (
      spine: 1,
      offset: 0,
    ));
    expect(await resolveEpubLink(index, 'OEBPS/n.xhtml#', conteudo), (
      spine: 1,
      offset: 0,
    ));
    expect(await resolveEpubLink(index, 'OEBPS/n.xhtml#sumiu', conteudo), (
      spine: 1,
      offset: 0,
    ));
    expect(
      await resolveEpubLink(index, 'OEBPS/fora.xhtml#x', conteudo),
      isNull,
    );
    expect(lidos, [1, 1], reason: 'só lê o item quando há fragmento');
  });

  test('números do rodapé: rótulos, igualdade e texto', () {
    const n = ReaderNumbersView(
      refPage: 159,
      refTotal: 256,
      progression: 0.62113,
    );
    expect((n.pageLabel, n.percentLabel), ('pág. 159 de 256', '62%'));
    expect(
      n,
      const ReaderNumbersView(
        refPage: 159,
        refTotal: 256,
        progression: 0.62113,
      ),
    );
    expect(
      n.hashCode,
      const ReaderNumbersView(
        refPage: 159,
        refTotal: 256,
        progression: 0.62113,
      ).hashCode,
    );
    expect(
      n,
      isNot(
        const ReaderNumbersView(
          refPage: 160,
          refTotal: 256,
          progression: 0.62113,
        ),
      ),
    );
    expect(n.toString(), 'pág. 159 de 256 · 62%');
  });

  group('G14 — retypeset', () {
    test('repagina na página do caractere que a pessoa lia; voltar aos ajustes de antes volta à mesma página', () async {
      await livro.guardarPosicao(2, 0);
      final doc = await EpubReaderDocument.open(livro.deps());
      addTearDown(doc.dispose);
      for (var i = 0; i < 3; i++) {
        expect(await doc.turn(PageDirection.forward), isTrue);
      }
      final lendo = doc.mark;
      final avisos = <ReaderMark>[];
      doc.changes.addListener(() => avisos.add(doc.mark));
      await doc.retypeset(
        const ReaderTypography(
          fontSize: 26,
          font: ReaderFontFamily.atkinson,
          sideMargin: 40,
        ),
      );
      final p = doc.current as PageSnapshot;
      expect(
        (p.typography.font, p.typography.fontSize),
        (ReaderFontFamily.atkinson, 26.0),
      );
      final s = p.shown!;
      expect(s.unit, lendo.spine);
      expect(
        lendo.offset,
        inInclusiveRange(s.from, s.to - 1),
        reason: 'o caractere que a pessoa lia está na página',
      );
      expect(avisos, isNotEmpty, reason: 'a tela é avisada');
      await doc.retypeset(const ReaderTypography());
      expect(
        doc.mark,
        lendo,
        reason: 'de volta aos ajustes de antes, a mesma página',
      );
    });
  });
}

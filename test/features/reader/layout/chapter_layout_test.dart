// G10.2 — layout de um capítulo em passos (Anexo 03 §7.2 e §12): o job em fatias dá as mesmas páginas do
// layout de uma vez; cada passo é pequeno; a página montada sozinha a partir de um início guardado no cache é
// igual à do capítulo inteiro (e um início que não é começo de linha não vale).
import 'dart:io';

import 'package:app_leitura/features/reader/content/chapter_content.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/layout/chapter_layout.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:app_leitura/features/reader/layout/space_cut.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';
import '../../../support/image_headers.dart';
import '../../../support/load_fonts.dart';
import '../../../support/medida.dart';

const String _domCasmurro = 'test/fixtures/livros/pg55752.epub';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  const t = ReaderTypography();

  late EpubBook livro;
  setUpAll(() => livro = EpubBook.open(_domCasmurro));
  tearDownAll(() => livro.close());

  String paginas(List<ReaderPage> ps) => ps
      .map(
        (p) =>
            '${p.start}-${p.end}:${p.slices.map((s) => '${s.block}@${s.y.toStringAsFixed(3)}').join(',')}',
      )
      .join('|');

  test('em fatias de tempo: as mesmas páginas do layout de uma vez; passos pequenos', () {
    final content = chapterOf(livro, 2);
    ChapterLayoutJob(
      chapterOf(livro, 4),
      t,
    ).runAll().dispose(); // aquece a fonte
    final sw = Stopwatch()..start();
    final inteiro = ChapterLayoutJob(content, t).runAll();
    final ms = sw.elapsedMicroseconds / 1000;
    addTearDown(inteiro.dispose);
    final job = ChapterLayoutJob(content, t);
    addTearDown(job.dispose);
    var fatias = 0;
    while (!job.runFor(layoutSliceBudget)) {
      fatias++;
      // as páginas já fechadas não mudam depois
      expect(job.pagesSoFar.length, lessThanOrEqualTo(inteiro.pages.length));
    }
    expect(fatias, greaterThan(3));
    expect(paginas(job.result.pages), paginas(inteiro.pages));
    expect(job.result.pages.length, greaterThan(40));
    // ignore: avoid_print
    print(
      'G10.2 capítulo 2 do Dom Casmurro: ${inteiro.pages.length} páginas em '
      '${ms.toStringAsFixed(1)} ms (${(ms / inteiro.pages.length * 40).toStringAsFixed(1)} ms '
      'por 40 páginas), $fatias fatias, maior passo ${job.maxStepMicros} µs',
    );
    expect(
      ms / inteiro.pages.length * 40,
      lessThan(orcamento(120, folga: 600)),
      reason: 'Anexo 03 §12',
    );
    // páginas cobrem o capítulo: começa no 1º bloco e termina no fim do último
    expect(inteiro.pages.first.start, 0);
    final ultimo = inteiro.blocks.last;
    expect(inteiro.pages.last.end, ultimo.start + ultimo.length);
    // página de um caractere
    final meio = inteiro.pages[20];
    expect(inteiro.pageAt(meio.start), 20);
    expect(inteiro.pageAt(meio.start - 1), 19);
    expect(inteiro.pageAt(-5), 0);
    expect(inteiro.pageAt(1 << 30), inteiro.pages.length - 1);
  });

  test('páginas em ordem e sem sobreposição, com outras letras e telas', () {
    for (final tt in const [
      ReaderTypography(),
      ReaderTypography(fontSize: 26),
      ReaderTypography(fontSize: 16, lineSpacing: 1.5, sideMargin: 20),
      ReaderTypography(viewportWidth: 360, viewportHeight: 780),
    ]) {
      for (final spine in [1, 2, 3]) {
        final layout = ChapterLayoutJob(chapterOf(livro, spine), tt).runAll();
        final ps = layout.pages;
        for (var k = 0; k < ps.length; k++) {
          final onde = 'item $spine, ${tt.layoutKey}, página $k';
          expect(ps[k].start, lessThan(ps[k].end), reason: onde);
          if (k + 1 < ps.length) {
            expect(
              ps[k].end,
              lessThanOrEqualTo(ps[k + 1].start),
              reason: '$onde: ${ps[k].end} > ${ps[k + 1].start}',
            );
          }
        }
        layout.dispose();
      }
    }
  });

  test('página a partir de um início do cache = a mesma página do capítulo inteiro', () {
    final content = chapterOf(livro, 1);
    final inteiro = ChapterLayoutJob(content, t).runAll();
    addTearDown(inteiro.dispose);
    for (final k in [
      0,
      1,
      7,
      inteiro.pages.length ~/ 2,
      inteiro.pages.length - 1,
    ]) {
      final r = layoutPageFrom(content, t, inteiro.pages[k].start)!;
      addTearDown(() {
        for (final b in r.blocks) {
          b.dispose();
        }
      });
      expect(
        paginas([r.page]),
        paginas([inteiro.pages[k]]),
        reason: 'página $k',
      );
      // os blocos da página montada vêm a partir do 1º dela
      final s = r.page.slices.first;
      expect(r.blocks.first.start, inteiro.blocks[s.block].start);
    }
    // início no meio de uma linha: o cache não vale para este layout
    final linha = (inteiro.blocks.whereType<LaidText>().first.lines);
    expect(layoutPageFrom(content, t, linha.first.start + 3), isNull);
  });

  test('capítulo com imagem: o tamanho vem do arquivo (lido no isolate), não dos atributos', () {
    final dir = Directory.systemTemp.createTempSync('booknest_g10_img_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final book = EpubBook.open(
      writeTemp(
        dir,
        'i.epub',
        simpleEpub(
          chapters: const [
            (
              file: 'c.xhtml',
              title: 'I',
              body: '<p>Antes.</p><img src="img/f.png" width="999" height="10"/><p>Depois.</p>',
            ),
          ],
          extra: {'OEBPS/img/f.png': pngHeader(40, 20)},
        ),
      ),
    );
    addTearDown(book.close);
    final c = chapterOf(book, 0);
    expect(c.imageSizes, {'OEBPS/img/f.png': (40, 20)});
    final layout = ChapterLayoutJob(c, t).runAll();
    addTearDown(layout.dispose);
    final img = layout.blocks.whereType<LaidImage>().single;
    expect((img.drawWidth, img.drawHeight), (40.0, 20.0));
  });

  group('espaço aberto (G18)', () {
    String fatias(ReaderPage p) =>
        '${p.start}-${p.end}:${p.slices.map((s) => '${s is SpaceSlice ? 'S' : s.block}@${s.y.toStringAsFixed(3)}').join(',')}';

    test('o job e a página avulsa com o espaço: a página que começa nele, a seguinte e a do modo', () {
      final content = chapterOf(livro, 1);
      final sem = ChapterLayoutJob(content, t).runAll();
      addTearDown(sem.dispose);
      // a âncora no fim da última linha da página 5 (antes do branco): o espaço não cabe mais nela
      final ultima = sem.pages[5].slices.last as TextSlice;
      final linha =
          (sem.blocks[ultima.block] as LaidText).lines[ultima.lastLine];
      final texto = content.item.text;
      var ancora = linha.end;
      while (texto.codeUnitAt(ancora - 1) == 0x20) {
        ancora--;
      }
      final cortes = [SpaceCut(at: ancora, height: 206, id: 'n')];
      final com = ChapterLayoutJob(content, t, cuts: cortes).runAll();
      addTearDown(com.dispose);
      expect(com.pages[5].start, sem.pages[5].start);
      expect(com.pages[5].slices.whereType<SpaceSlice>(), isEmpty);
      expect(com.pages[6].slices.first, isA<SpaceSlice>());
      expect(com.pages[6].start, ancora);
      expect(com.pages.length, greaterThanOrEqualTo(sem.pages.length));
      for (final k in [5, 6, 7]) {
        final r = layoutPageFrom(content, t, com.pages[k].start, cuts: cortes)!;
        addTearDown(() {
          for (final b in r.blocks) {
            b.dispose();
          }
        });
        expect(fatias(r.page), fatias(com.pages[k]), reason: 'página $k');
      }
      // sem os cortes, o começo na âncora não é começo de linha
      expect(layoutPageFrom(content, t, ancora), isNull);
      // a página do modo: o mesmo começo, mais alta, com mais linhas
      final alta = layoutPageFrom(
        content,
        t,
        com.pages[6].start,
        cuts: cortes,
        contentHeight: t.contentHeight + 300,
      )!;
      addTearDown(() {
        for (final b in alta.blocks) {
          b.dispose();
        }
      });
      expect(alta.page.start, com.pages[6].start);
      expect(alta.page.slices.first, isA<SpaceSlice>());
      expect(alta.page.end, greaterThan(com.pages[6].end));
    });
  });
}

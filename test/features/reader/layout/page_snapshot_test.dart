// G11.2 — a página do EPUB pronta para a tela: pinta o que a G10 pintava, dá o texto da página ao leitor de tela
// e acha o link sob o dedo no desenho das letras (D-108), não na palavra mais próxima.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/epub_builder.dart';
import '../../../support/load_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  const t = ReaderTypography();
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('booknest_g11_snap_'));
  tearDown(() => dir.deleteSync(recursive: true));

  ParsedItem parse(String corpo) {
    final book = EpubBook.open(
      writeTemp(
        dir,
        'l.epub',
        simpleEpub(
          chapters: [
            (file: 'c1.xhtml', title: 'I', body: corpo),
            (file: 'c2.xhtml', title: 'II', body: '<p id="n1">Nota.</p>'),
          ],
        ),
      ),
    );
    addTearDown(book.close);
    return book.parseItem(0);
  }

  ({PageSnapshot snap, List<LaidBlock> blocks}) montar(ParsedItem item) {
    final blocks = BlockLayouter(t).layoutAll(item.blocks, item.blockStarts);
    addTearDown(() {
      for (final b in blocks) {
        b.dispose();
      }
    });
    final page = paginateChapter(blocks, t.contentHeight).first;
    return (
      snap: PageSnapshot(
        spine: 0,
        page: page,
        blockOf: (b) => blocks[b],
        typography: t,
        item: item,
      ),
      blocks: blocks,
    );
  }

  /// Centro (na tela) do caractere [canonical] do bloco de texto [b] na 1ª página.
  ui.Offset centroDe(LaidText b, int canonical) {
    final (pa, pi) = b.toParagraph(canonical);
    final box = b.pieces[pa].paragraph.getBoxesForRange(pi, pi + 1).single;
    final line = b.lines[b.lineAt(canonical)];
    return ui.Offset(
      t.sideMargin + b.left + (box.left + box.right) / 2,
      t.topInset + line.top + line.height / 2,
    );
  }

  test(
    'linkAt: o toque no desenho do link acha o destino; ao lado e abaixo, nada',
    () {
      final item = parse(
        '<p>Antes do <a href="c2.xhtml#n1">link aqui</a> e depois.</p>',
      );
      final (:snap, :blocks) = montar(item);
      final b = blocks.single as LaidText;
      final a = item.text.indexOf('link aqui');
      final hit = snap.linkAt(centroDe(b, a + 2));
      expect(hit, (target: 'OEBPS/c2.xhtml#n1', spine: 0, offset: a));
      // a última letra do link ainda é link; o espaço depois dele, não
      expect(snap.linkAt(centroDe(b, a + 'link aqui'.length - 1)), isNotNull);
      expect(snap.linkAt(centroDe(b, a + 'link aqui'.length + 2)), isNull);
      expect(snap.linkAt(centroDe(b, 1)), isNull);
      final c = centroDe(b, a + 2);
      expect(snap.linkAt(ui.Offset(c.dx, c.dy + 3 * t.lineHeight)), isNull);
    },
  );

  test('linkAt: link que quebra a linha vale nas duas linhas', () {
    final longo = 'palavra ' * 6;
    final item = parse(
      '<p>${'abc ' * 9}<a href="c2.xhtml#n1">$longo</a>fim.</p>',
    );
    final (:snap, :blocks) = montar(item);
    final b = blocks.single as LaidText;
    final a = item.text.indexOf('palavra');
    final z = a + longo.trimRight().length - 1;
    expect(b.lineAt(a), isNot(b.lineAt(z)), reason: 'o link precisa quebrar');
    expect(snap.linkAt(centroDe(b, a))?.offset, a);
    expect(snap.linkAt(centroDe(b, z))?.offset, b.lines[b.lineAt(z)].start);
  });

  test(
    'texto da página para o leitor de tela = o trecho canônico da página',
    () {
      final item = parse('<p>Primeiro.</p><hr/><p>Segundo.</p>');
      final (:snap, blocks: _) = montar(item);
      expect(snap.spokenText, 'Primeiro.\n\nSegundo.');
    },
  );

  test('página que deixou de valer: não pinta e não acha link', () {
    final item = parse('<p><a href="c2.xhtml#n1">tudo link</a></p>');
    final blocks = BlockLayouter(t).layoutAll(item.blocks, item.blockStarts);
    addTearDown(() {
      for (final b in blocks) {
        b.dispose();
      }
    });
    var vivo = true;
    final snap = PageSnapshot(
      spine: 0,
      page: paginateChapter(blocks, t.contentHeight).first,
      blockOf: (b) => blocks[b],
      typography: t,
      item: item,
      alive: () => vivo,
    );
    final c = centroDe(blocks.single as LaidText, 1);
    expect(snap.linkAt(c), isNotNull);
    vivo = false;
    expect(snap.linkAt(c), isNull);
    final rec = ui.PictureRecorder();
    snap.paint(ui.Canvas(rec)); // não pinta (nem quebra)
    rec.endRecording().dispose();
  });
}

// G11.2 — a página do EPUB pronta para a tela: pinta o que a G10 pintava, dá o texto da página ao leitor de tela
// e acha o link sob o dedo no desenho das letras (D-108), não na palavra mais próxima.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:app_leitura/features/reader/layout/space_cut.dart';
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

  ({PageSnapshot snap, List<LaidBlock> blocks}) montar(
    ParsedItem item, {
    int? pieceChars,
  }) {
    final layouter = pieceChars == null
        ? BlockLayouter(t)
        : BlockLayouter(t, pieceChars: pieceChars);
    final blocks = layouter.layoutAll(item.blocks, item.blockStarts);
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

  test('G13: parágrafo em pedaços — caixas, ponto e palavra sob o dedo iguais aos do parágrafo inteiro', () {
    final item = parse('<p>${'Capitu olhava a vaga, sem pressa; ' * 40}</p>');
    final inteiro = montar(item, pieceChars: 1 << 30);
    final pedacos = montar(item, pieceChars: 120);
    expect((inteiro.blocks.single as LaidText).pieces, hasLength(1));
    expect((pedacos.blocks.single as LaidText).pieces.length, greaterThan(3));
    final a = inteiro.snap;
    final b = pedacos.snap;
    final s = a.shown!;
    expect(b.shown, s);
    var conferidas = 0;
    for (final m in RegExp(r'\p{L}+', unicode: true).allMatches(item.text)) {
      if (m.end > s.to) break;
      final ca = a.boxesOf(0, m.start, m.end);
      final cb = b.boxesOf(0, m.start, m.end);
      expect(cb, hasLength(ca.length), reason: m[0]);
      for (var i = 0; i < ca.length; i++) {
        expect(cb[i].rect, rectMoreOrLessEquals(ca[i].rect, epsilon: 0.01));
        expect(cb[i].baseline, moreOrLessEquals(ca[i].baseline, epsilon: 0.01));
      }
      // o ponto sob o dedo no começo da 1ª letra e no fim da última (no meio de uma letra os dois lados valem)
      final ini = ca.first.rect;
      final fim = ca.last.rect;
      for (final snap in [a, b]) {
        expect(snap.spotAt(ui.Offset(ini.left + 2, ini.center.dy)), (
          unit: 0,
          offset: m.start,
        ));
        expect(snap.spotAt(ui.Offset(fim.right - 2, fim.center.dy)), (
          unit: 0,
          offset: m.end,
        ));
      }
      expect(b.wordAt(ini.center), (unit: 0, from: m.start, to: m.end));
      expect(b.wordAround((unit: 0, offset: m.start)), (
        unit: 0,
        from: m.start,
        to: m.end,
      ));
      conferidas++;
    }
    expect(conferidas, greaterThan(100));
  });

  test('G18: a página diz onde está cada espaço (lado, largura e altura do texto); o texto de baixo já desce', () {
    final item = parse(
      '<p>Primeira frase da página. Segunda frase dela, um pouco mais longa.</p><p>Outro parágrafo.</p>',
    );
    final at = item.text.indexOf('página.') + 'página.'.length;
    final cortes = [SpaceCut(at: at, height: 206, id: 'n1')];
    final semCorte = montar(item).snap;
    final blocks = BlockLayouter(t)
        .layoutAll(item.blocks, item.blockStarts, cuts: cortes);
    addTearDown(() {
      for (final b in blocks) {
        b.dispose();
      }
    });
    final page = paginateChapter(blocks, t.contentHeight).first;
    final snap = PageSnapshot(
      spine: 0,
      page: page,
      blockOf: (b) => blocks[b],
      typography: t,
      item: item,
    );
    final s = page.slices.whereType<SpaceSlice>().single;
    expect(spacesOf(snap), [
      (
        id: 'n1',
        rect: ui.Rect.fromLTWH(
          t.sideMargin,
          t.topInset + s.y,
          t.contentWidth,
          206,
        ),
      ),
    ]);
    expect(spacesOf(semCorte), isEmpty);
    // "Outro" desce a altura do espaço e mais o que o 2º segmento ocupar
    final outro = item.text.indexOf('Outro');
    final antes = semCorte.boxesOf(0, outro, outro + 5).single.rect.top;
    final depois = snap.boxesOf(0, outro, outro + 5).single.rect.top;
    expect(depois - antes, greaterThanOrEqualTo(206 - 0.01));
    // o texto falado não muda
    expect(snap.spokenText, semCorte.spokenText);
    // a página do PDF (e as que não são do EPUB) não têm espaços
    expect(spacesOf(_SemEspacos()), isEmpty);
  });
}

final class _SemEspacos implements DisplayPage {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

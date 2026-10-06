// G10.1 — gate de fidelidade da paginação (Anexo 03 §7.2, ADR-005, D-94): um EPUB de fixture com o texto
// EXATO da tela 19, aberto pelo leitor de conteúdo da G09 e paginado no estado padrão (390×844, Literata 20,5,
// Médio 1,72, Média 28), dá as MESMAS 19 linhas da tela 19 e a página seguinte começa pelas 3 linhas que a
// prancha esconde; baselines e bordas ±0,5 px da medição; os "fios de navalha" com a folga do Chromium.
// Com BOOKNEST_CAPTURAS=<pasta>, grava a página pintada @3x (comparada com o PNG de referência fora do teste).
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/content/epub_book.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_19_leitor_limpo.dart';
import '../../../support/epub_builder.dart';
import '../../../support/load_fonts.dart';

const double _gate = 0.5;

String _esc(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  final ref = kRef19.elements['r19.page.text']!.lines;
  final texto = ref.map((l) => l.text).join(' ');
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('booknest_g10_gate_'));
  tearDown(() => dir.deleteSync(recursive: true));

  /// O cap. XXXII partido como no Gutenberg: o item começa no parágrafo da página (que tem recuo).
  ParsedItem abrir() {
    final book = EpubBook.open(
      writeTemp(
        dir,
        'tela19.epub',
        simpleEpub(
          chapters: [
            (
              file: 'cap32b.xhtml',
              title: 'XXXII',
              body: '<p>${_esc(texto)}</p>',
            ),
          ],
        ),
      ),
    );
    addTearDown(book.close);
    return book.parseItem(0);
  }

  test(
    'a fixture tem as 22 linhas da referência (19 visíveis + 3 escondidas)',
    () {
      expect(ref, hasLength(22));
      expect(ref.where((l) => l.hidden), hasLength(3));
      expect(abrir().text, texto);
    },
  );

  test('tela 19: as mesmas 19 linhas, baselines e bordas ±0,5 px; a página seguinte começa pelas 3 escondidas', () {
    const t = ReaderTypography();
    final item = abrir();
    final blocks = BlockLayouter(t).layoutAll(item.blocks, item.blockStarts);
    addTearDown(() {
      for (final b in blocks) {
        b.dispose();
      }
    });
    final pages = paginateChapter(blocks, t.contentHeight);
    final b = blocks.single as LaidText;
    expect(t.lineHeight, closeTo(35.26, 1e-9));
    expect(pages, hasLength(2));
    expect(pages.map((p) => (p.slices.single as TextSlice).firstLine), [0, 19]);
    expect(pages.map((p) => (p.slices.single as TextSlice).lastLine), [18, 21]);
    expect(pages.first.start, 0);
    expect(pages.last.start, b.lines[19].start);

    var maxBase = 0.0;
    var maxRight = 0.0;
    for (final (ip, page) in pages.indexed) {
      final s = page.slices.single as TextSlice;
      for (var l = s.firstLine; l <= s.lastLine; l++) {
        final line = b.lines[l];
        final txt = item.text.substring(line.start, line.end).trimRight();
        expect(txt, ref[l].text, reason: 'linha ${l + 1}');
        // a linha l da página ip ocupa o lugar da linha de referência l − 19·ip (a 2ª página começa no topo)
        final baseline =
            t.topInset + s.y + (line.baseline - b.lines[s.firstLine].top);
        final dBase = baseline - ref[l - 19 * ip].baseline;
        maxBase = math.max(maxBase, dBase.abs());
        final (pa, a) = b.toParagraph(line.start);
        final (_, z) = b.toParagraph(line.start + txt.length);
        final boxes = b.pieces[pa].paragraph.getBoxesForRange(a, z);
        final right =
            t.sideMargin + b.left + boxes.map((x) => x.right).reduce(math.max);
        final left =
            t.sideMargin + b.left + boxes.map((x) => x.left).reduce(math.min);
        maxRight = math.max(maxRight, (right - ref[l].right).abs());
        expect(
          left,
          closeTo(ref[l].left, _gate),
          reason: 'esquerda da linha ${l + 1}',
        );
      }
    }
    // ignore: avoid_print
    print(
      'G10.1 tela 19: 22/22 linhas iguais · baseline máx ${maxBase.toStringAsFixed(4)} px · '
      'borda direita máx ${maxRight.toStringAsFixed(4)} px · 19 linhas = '
      '${b.lines[18].bottom.toStringAsFixed(4)} de ${t.contentHeight}',
    );
    expect(maxBase, lessThanOrEqualTo(_gate));
    expect(maxRight, lessThanOrEqualTo(_gate));
  });

  test('fios de navalha (linhas 7 e 19): a próxima palavra estoura com a folga do Chromium', () {
    const t = ReaderTypography();
    final palavras = texto.split(' ');
    for (final k in kRef19.knifeEdges) {
      final antes = ref
          .take(k.line - 1)
          .map((l) => l.text.split(' ').length)
          .fold(0, (a, n) => a + n);
      final proxima = palavras[antes + k.text.split(' ').length];
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(maxLines: 1))
        ..pushStyle(t.runStyle(RunStyle.plain))
        ..addText('${k.text} $proxima');
      final p = pb.build()
        ..layout(const ui.ParagraphConstraints(width: double.infinity));
      final estouro = p.maxIntrinsicWidth - t.contentWidth;
      p.dispose();
      expect(
        estouro,
        closeTo(k.joinOverflow!, 0.01),
        reason: 'linha ${k.line}',
      );
      expect(estouro, greaterThan(0));
    }
  });

  test(
    'pintura da página @3x (captura para comparar com a referência)',
    () async {
      final pasta = Platform.environment['BOOKNEST_CAPTURAS'];
      const t = ReaderTypography();
      final item = abrir();
      final blocks = BlockLayouter(t).layoutAll(item.blocks, item.blockStarts);
      addTearDown(() {
        for (final b in blocks) {
          b.dispose();
        }
      });
      final page = paginateChapter(blocks, t.contentHeight).first;
      const escala = 3.0;
      final rec = ui.PictureRecorder();
      final c = ui.Canvas(rec)
        ..scale(escala)
        ..drawRect(
          const ui.Rect.fromLTWH(0, 0, 390, 844),
          ui.Paint()..color = const ui.Color(0xFFF8F1E4),
        );
      for (final s in page.slices.cast<TextSlice>()) {
        paintTextLines(
          c,
          blocks[s.block] as LaidText,
          s.firstLine,
          s.lastLine,
          left: t.sideMargin,
          top: t.topInset + s.y,
        );
      }
      final img = await rec.endRecording().toImage(1170, 2532);
      final png = await img.toByteData(format: ui.ImageByteFormat.png);
      img.dispose();
      expect(png!.lengthInBytes, greaterThan(10000));
      if (pasta != null) {
        Directory(pasta).createSync(recursive: true);
        File('$pasta${Platform.pathSeparator}g10_tela19_pagina_390x844@3x.png')
            .writeAsBytesSync(png.buffer.asUint8List());
      }
    },
  );
}

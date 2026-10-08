// G16.2 — a geometria da tinta tirada da página mostrada: a pág. 159 do mundo (o livro da tela 19) dá as 19 linhas
// nas linhas de base da prancha 19, com as palavras de cada uma (a pontuação é uma "palavra", como no
// `getWordBoundary`); o PDF, sem texto selecionável (D-134), não tem linhas.
import 'dart:ui';

import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/application/ink_page_geometry.dart';
import 'package:app_leitura/features/reader/application/pdf_reader_document.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_19_leitor_limpo.dart';
import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  late EpubReaderDocument doc;
  setUp(() async {
    livro = await livroDaTela19();
    doc = await EpubReaderDocument.open(livro.deps());
  });
  tearDown(() async {
    doc.dispose();
    await livro.close();
  });

  test('a pág. 159: as 19 linhas da prancha 19, nas linhas de base dela', () {
    final page = doc.current as PageSnapshot;
    final g = inkGeometryOf(page);
    final ref = kRef19.elements['r19.page.text']!.lines
        .where((l) => !l.hidden)
        .toList();
    expect(g.lines, hasLength(19));
    for (var i = 0; i < 19; i++) {
      final l = g.lines[i];
      final text = page.textOf(l.unit, l.from, l.to);
      expect(text, ref[i].text, reason: 'linha ${i + 1}');
      expect(
        l.baseline,
        closeTo(ref[i].baseline, 0.5),
        reason: 'linha ${i + 1}',
      );
      expect(l.left, closeTo(ref[i].left, 1), reason: 'linha ${i + 1}');
      expect(l.right, closeTo(ref[i].right, 1), reason: 'linha ${i + 1}');
      expect(l.em, closeTo(20.5, 0.01));
      expect(l.unit, page.spine);
      expect(l.bottom - l.top, closeTo(35.26, 0.01));
    }
    expect(g.lineHeight, closeTo(35.26, 0.01));
    expect(g.lines.first.refY, closeTo(118.54 - 5.125, 0.5));
  });

  test('as palavras da linha 8: a pontuação conta; "Olhos de ressaca?" vai de 28 a 196,54', () {
    final page = doc.current as PageSnapshot;
    final line = inkGeometryOf(page).lines[7];
    expect(
      [for (final w in line.words) page.textOf(line.unit, w.from, w.to)],
      ['Olhos', 'de', 'ressaca', '?', 'Vá', ',', 'de', 'ressaca', '.', 'É'],
    );
    // as medidas da 22 sem os 30 px do modo (ann.page.text.circled)
    expect(line.words.first.left, closeTo(28, 1));
    expect(line.words[3].right, closeTo(196.54, 1));
    for (var i = 1; i < line.words.length; i++) {
      expect(line.words[i].from, greaterThanOrEqualTo(line.words[i - 1].to));
      expect(
        line.words[i].left,
        greaterThanOrEqualTo(line.words[i - 1].right - 0.01),
      );
    }
    expect((line.from, line.to), (line.words.first.from, line.words.last.to));
  });

  test('PDF: sem texto selecionável, sem linhas', () {
    final pdf = PdfDisplayPage.forTest(
      index: 0,
      rect: const Rect.fromLTWH(0, 0, 390, 844),
      pageSize: const Size(612, 792),
      text: 'Texto de uma página',
      charRects: const [],
    );
    expect(inkGeometryOf(pdf).lines, isEmpty);
    expect(inkGeometryOf(pdf).lineHeight, 0);
  });
}

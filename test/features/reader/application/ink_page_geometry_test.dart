// G16.2 — a geometria da tinta tirada da página mostrada: a pág. 159 do mundo (o livro da tela 19) dá as 19 linhas
// nas linhas de base da prancha 19, com as palavras de cada uma (a pontuação é uma "palavra", como no
// `getWordBoundary`); o PDF, sem texto selecionável (D-134), não tem linhas.
import 'dart:ui';

import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/application/ink_page_geometry.dart';
import 'package:app_leitura/features/reader/application/pdf_reader_document.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_19_leitor_limpo.dart';
import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

/// 'abc defghi jkl' em 2 linhas, com "defghi" quebrada no hífen discreto: "abc def" na linha de base 100 e
/// "ghi jkl" na 135; cada letra 10 px a partir de x = 28. [de] = o começo do trecho mostrado.
final class _Quebrada implements DisplayPage {
  _Quebrada({this.de = 0});

  final int de;
  static const _texto = 'abc defghi jkl';

  double _base(int i) => i < 7 ? 100 : 135;
  double _x(int i) => 28 + 10.0 * (i < 7 ? i : i - 7);

  @override
  ReaderRange? get shown => (unit: 1, from: de, to: _texto.length);

  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) {
    final out = <TextLineBox>[];
    var i = from < de ? de : from;
    while (i < to) {
      final b = _base(i);
      var j = i;
      while (j < to && _base(j) == b) {
        j++;
      }
      out.add((
        rect: Rect.fromLTRB(_x(i), b - 26, _x(j - 1) + 10, b + 9),
        baseline: b,
        textTop: b - 26,
        textBottom: b + 9,
        em: 20.5,
      ));
      i = j;
    }
    return out;
  }

  @override
  ReaderRange? wordAround(ReaderSpot s) {
    if (_texto[s.offset] == ' ') return null;
    var a = s.offset;
    var z = s.offset;
    while (a > 0 && _texto[a - 1] != ' ') {
      a--;
    }
    while (z < _texto.length && _texto[z] != ' ') {
      z++;
    }
    return (unit: 1, from: a, to: z);
  }

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 'um meio fim' numa linha só, com "meio" em itálico pela metade ("me" normal, "io" itálico): o trecho mostrado vem
/// em 3 caixas (estilos), e a palavra "meio", em 2.
final class _Estilos implements DisplayPage {
  static const _texto = 'um meio fim';

  @override
  ReaderRange? get shown => (unit: 1, from: 0, to: _texto.length);

  /// As caixas de cada estilo: [0, 5) normal, [5, 7) itálico, [7, 11) normal.
  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) => [
    for (final (a, z) in const [(0, 5), (5, 7), (7, 11)])
      if (from < z && to > a)
        (
          rect: Rect.fromLTRB(
            28 + 10.0 * (from > a ? from : a),
            74,
            28 + 10.0 * (to < z ? to : z),
            109,
          ),
          baseline: 100,
          textTop: 74,
          textBottom: 109,
          em: 20.5,
        ),
  ];

  @override
  ReaderRange? wordAround(ReaderSpot s) {
    if (_texto[s.offset] == ' ') return null;
    var a = s.offset;
    var z = s.offset;
    while (a > 0 && _texto[a - 1] != ' ') {
      a--;
    }
    while (z < _texto.length && _texto[z] != ' ') {
      z++;
    }
    return (unit: 1, from: a, to: z);
  }

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a linha em várias caixas (estilos) é uma; a palavra em 2 caixas, uma palavra', () {
    final g = inkGeometryOf(_Estilos());
    expect(g.lines, hasLength(1));
    final l = g.lines.single;
    expect((l.left, l.right), (28.0, 138.0));
    expect(l.words, [
      (from: 0, to: 2, left: 28.0, right: 48.0),
      (from: 3, to: 7, left: 58.0, right: 98.0),
      (from: 8, to: 11, left: 108.0, right: 138.0),
    ]);
  });

  test(
    'a palavra quebrada entre linhas: cada linha fica só com o pedaço dela',
    () {
      final g = inkGeometryOf(_Quebrada());
      expect(g.lines, hasLength(2));
      expect(g.lines[0].words, [
        (from: 0, to: 3, left: 28.0, right: 58.0),
        (from: 4, to: 7, left: 68.0, right: 98.0),
      ]);
      expect(g.lines[1].words, [
        (from: 7, to: 10, left: 28.0, right: 58.0),
        (from: 11, to: 14, left: 68.0, right: 98.0),
      ]);
      expect((g.lines[1].from, g.lines[1].to), (7, 14));
    },
  );

  test(
    'a palavra que começou na página anterior entra só com o que está nesta',
    () {
      final g = inkGeometryOf(_Quebrada(de: 5));
      expect(g.lines.first.words.first, (
        from: 5,
        to: 7,
        left: 78.0,
        right: 98.0,
      ));
      // numa linha só: "abc" começou antes de 1
      expect(inkGeometryOf(_Quebrada(de: 1)).lines.first.words.first, (
        from: 1,
        to: 3,
        left: 38.0,
        right: 58.0,
      ));
    },
  );

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

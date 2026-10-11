// G12.2 — os retângulos das letras de um trecho na página (a marca da busca — D-120): no EPUB, as caixas do
// `getBoxesForRange` (o mesmo cálculo do toque no link — G11), só do item e da parte que estão na página; no
// PDF, os `charRects` do PDFium (origem embaixo, em pontos) levados para o retângulo da página na tela. E a
// cor do texto troca sem mudar a chave de paginação (Tema — D-121).
import 'dart:ui';

import 'package:app_leitura/features/reader/application/epub_reader_document.dart';
import 'package:app_leitura/features/reader/application/pdf_reader_document.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdfrx/pdfrx.dart' show PdfRect;

import '../../../support/load_fonts.dart';
import '../../../support/reader_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);

  test('EPUB: os retângulos de "olhos de Capitu" na página do cap. XXXII; outro item ou fora da página → nada', () async {
    // o Dom Casmurro do mundo: o cap. XXXII é o item 32
    final livro = await livroDaTela19();
    addTearDown(livro.close);
    final d = await EpubReaderDocument.open(livro.deps());
    addTearDown(d.dispose);
    await d.goTo((spine: 32, offset: 0));
    final p = d.current as PageSnapshot;
    final texto = p.item.text;
    const busca = 'olhos de Capitu';
    final a = texto.indexOf(busca, p.page.start);
    expect(a, inInclusiveRange(p.page.start, p.page.end - busca.length));
    final r = p.rectsOf(32, a, a + busca.length);
    expect(r, isNotEmpty);
    final u = r.reduce((x, y) => x.expandToInclude(y));
    final t = p.typography;
    expect(u.left, greaterThanOrEqualTo(t.sideMargin - 0.01));
    expect(u.right, lessThanOrEqualTo(t.sideMargin + t.contentWidth + 0.01));
    expect(u.top, greaterThanOrEqualTo(t.topInset - 0.01));
    expect(u.bottom, lessThanOrEqualTo(t.topInset + t.contentHeight + 0.01));
    // cada caixa tem a altura de uma linha do texto
    for (final x in r) {
      expect(x.height, closeTo(t.lineHeight, 0.01));
    }
    // o toque no meio da primeira caixa não é link (não há link aqui), mas o cálculo é o mesmo do linkAt
    expect(p.linkAt(r.first.center), isNull);
    expect(p.rectsOf(31, a, a + busca.length), isEmpty, reason: 'outro item');
    expect(
      p.rectsOf(32, p.page.end + 10, p.page.end + 20),
      isEmpty,
      reason: 'depois da página',
    );
    expect(p.rectsOf(32, a, a), isEmpty, reason: 'trecho vazio');
  });

  test('withInk troca só a cor: a chave de paginação e as medidas ficam', () {
    const t = ReaderTypography(fontSize: 22, sideMargin: 40, topInset: 100);
    final n = t.withInk(const Color(0xFFE3D9C6));
    expect(n.ink, const Color(0xFFE3D9C6));
    expect(n.layoutKey, t.layoutKey);
    expect(
      (
        n.fontSize,
        n.lineSpacing,
        n.sideMargin,
        n.viewportWidth,
        n.viewportHeight,
        n.topInset,
        n.bottomInset,
      ),
      (
        t.fontSize,
        t.lineSpacing,
        t.sideMargin,
        t.viewportWidth,
        t.viewportHeight,
        t.topInset,
        t.bottomInset,
      ),
    );
  });

  test('PDF: os charRects (origem embaixo) vão para a tela, unidos por linha; outra página → nada', () {
    final page = PdfDisplayPage.forTest(
      index: 2,
      rect: const Rect.fromLTWH(8, 100, 374, 529),
      pageSize: const Size(595, 842),
      text: 'ab c\nde',
      charRects: const [
        PdfRect(100, 742, 110, 730), // a
        PdfRect(110, 742, 120, 730), // b
        PdfRect(120, 742, 120, 730), // espaço sem largura
        PdfRect(124, 742, 130, 730), // c
        PdfRect(130, 742, 130, 730), // \n
        PdfRect(100, 722, 110, 710), // d (outra linha)
        PdfRect(110, 722, 118, 710), // e
      ],
    );
    final r = page.rectsOf(2, 0, 8);
    expect(r, hasLength(2));
    const sx = 374 / 595, sy = 529 / 842;
    expect(r[0].left, closeTo(8 + 100 * sx, 1e-9));
    expect(r[0].right, closeTo(8 + 130 * sx, 1e-9));
    expect(r[0].top, closeTo(100 + (842 - 742) * sy, 1e-9));
    expect(r[0].bottom, closeTo(100 + (842 - 730) * sy, 1e-9));
    expect(r[1].top, closeTo(100 + (842 - 722) * sy, 1e-9));
    expect(page.rectsOf(2, 1, 2).single.left, closeTo(8 + 110 * sx, 1e-9));
    expect(page.rectsOf(1, 0, 2), isEmpty);
    expect(
      page.rectsOf(2, 5, 99).length,
      1,
      reason: 'o fim é limitado ao texto',
    );
    expect(page.spokenText, 'ab c\nde');
  });
}

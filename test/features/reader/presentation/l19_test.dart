// G11.5 — FASE L19 (handoff_v2/fases/L19_leitor_limpo.md): a tela 19 pela rota real, no mundo de referência
// (D-34: o EPUB do mundo, a posição da pág. 159 e o índice injetado da tela 19), contra as medidas do arquivo:
// - geometria dos 5 ids da `kRef19` (±0,5; ±1,0 em x/w nos que dependem do texto);
// - texto: as 19 linhas da página MOSTRADA (texto exato, baseline e bordas ±0,5); as 3 seguintes não estão nela;
// - estilo: papel Creme, texto #2A2520 em Literata variável 20,5/35,26, rodapé Figtree 11,5/600 #A89D8B tabular;
// - semântica: "Dom Casmurro, página 159 de 256";
// - dados: "pág. 159 de 256" e "62%" calculados (`numbersAt`), nunca escritos.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/features/reader/domain/reader_numbers.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/telas/indice_t19.dart';
import '../../../reference/leitor/reference_layout_19_leitor_limpo.dart';
import '../../../support/canvas.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

void main() {
  setUpAll(loadAppFonts);
  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela19());
  tearDown(() async => livro.close());

  PageSnapshot pagina(WidgetTester tester) =>
      tester
              .widget<ReaderPageView>(find.byType(ReaderPageView))
              .document
              .current
          as PageSnapshot;

  /// O parágrafo da página (o 1º bloco dela) e a fatia.
  (LaidText, TextSlice) paragrafo(WidgetTester tester) {
    final p = pagina(tester);
    final s = p.page.slices.first as TextSlice;
    return (p.block(s.block) as LaidText, s);
  }

  Future<void> tela19(WidgetTester tester) async {
    setCanvasView(tester, logical: const Size(390, 844));
    await abrirLeitor(tester, livro);
  }

  testWidgets(
    'dados: pág. 159 de 256 e 62% saem dos cálculos (D-19, D-89, D-34)',
    (tester) async {
      await tela19(tester);
      final n = numbersAt(
        livro.index,
        itemDaPagina159,
        pagina(tester).page.start,
      );
      expect((n.refPage, n.refTotal, n.percentLabel), (159, 256, '62%'));
      String texto(String id) =>
          tester.widget<AppText>(_key(id)).span.toPlainText();
      expect(
        texto('r19.footer.pageLabel'),
        'pág. ${n.refPage} de ${n.refTotal}',
      );
      expect(texto('r19.footer.percent'), n.percentLabel);
      expect(
        pagina(tester).page.start,
        0,
        reason: 'a página começa no parágrafo',
      );
    },
  );

  testWidgets('geometria: os 5 ids da kRef19', (tester) async {
    await tela19(tester);
    final (b, s) = paragrafo(tester);
    // a tipografia com que a tela montou a página (margem e topo de verdade, não os padrões)
    final t = pagina(tester).typography;
    final medido = <String, Rect>{
      'r19.page': tester.getRect(_key('r19.page')),
      // o parágrafo inteiro (22 linhas), cortado pela página
      'r19.page.text': Rect.fromLTWH(
        t.sideMargin + b.left,
        t.topInset + s.y,
        b.width,
        b.lines.last.bottom,
      ),
      'r19.footer': tester.getRect(_key('r19.footer')),
      'r19.footer.pageLabel': tester.getRect(_key('r19.footer.pageLabel')),
      'r19.footer.percent': tester.getRect(_key('r19.footer.percent')),
    };
    final ids = [
      ...kRef19.idsOfSection('r19.page'),
      ...kRef19.idsOfSection('r19.footer'),
    ];
    expect(ids.toSet(), medido.keys.toSet());
    for (final id in ids) {
      final ref = kRef19.elements[id]!.rect;
      final m = medido[id]!;
      final tolX = kRef19.textDependentX.contains(id) ? 1.0 : 0.5;
      expect(m.left, closeTo(ref.left, tolX), reason: '$id x');
      expect(m.width, closeTo(ref.width, tolX), reason: '$id w');
      expect(m.top, closeTo(ref.top, 0.5), reason: '$id y');
      expect(m.height, closeTo(ref.height, 0.5), reason: '$id h');
    }
  });

  testWidgets(
    'texto: as 19 linhas da página mostrada = as do arquivo; as 3 seguintes não estão nela',
    (tester) async {
      await tela19(tester);
      final p = pagina(tester);
      final (b, s) = paragrafo(tester);
      final ref = kRef19.elements['r19.page.text']!.lines;
      expect(p.page.slices, hasLength(1));
      expect((s.firstLine, s.lastLine), (0, 18));
      expect(ref.where((l) => !l.hidden), hasLength(19));
      expect(ref.skip(19).every((l) => l.hidden), isTrue);
      expect(b.lines, hasLength(22));
      final t = p.typography;
      var maxBase = 0.0;
      var maxRight = 0.0;
      for (var l = s.firstLine; l <= s.lastLine; l++) {
        final line = b.lines[l];
        final txt = p.item.text.substring(line.start, line.end).trimRight();
        expect(txt, ref[l].text, reason: 'linha ${l + 1}');
        final baseline =
            t.topInset + s.y + (line.baseline - b.lines[s.firstLine].top);
        maxBase = math.max(maxBase, (baseline - ref[l].baseline).abs());
        final (pa, a) = b.toParagraph(line.start);
        final (_, z) = b.toParagraph(line.start + txt.length);
        final boxes = b.pieces[pa].paragraph.getBoxesForRange(a, z);
        final left =
            t.sideMargin + b.left + boxes.map((x) => x.left).reduce(math.min);
        final right =
            t.sideMargin + b.left + boxes.map((x) => x.right).reduce(math.max);
        expect(left, closeTo(ref[l].left, 0.5), reason: 'linha ${l + 1} x');
        maxRight = math.max(maxRight, (right - ref[l].right).abs());
      }
      expect(maxBase, lessThanOrEqualTo(0.5));
      expect(maxRight, lessThanOrEqualTo(0.5));
      // a página seguinte começa pela linha 20 ("saía delas vinha crescendo, cava e")
      expect(p.page.end, b.lines[19].start);
    },
  );

  testWidgets('estilo: papel, texto do livro e rodapé', (tester) async {
    await tela19(tester);
    final papel = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(ReaderScreen),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(papel.color, const Color(0xFFF8F1E4));
    final t = pagina(tester).typography;
    expect(t.ink, const ui.Color(0xFF2A2520));
    expect(t.fontSize, 20.5);
    expect(t.lineHeight, closeTo(35.26, 1e-9));
    expect(readerFontFamily, 'LiterataVF');
    for (final id in ['r19.footer.pageLabel', 'r19.footer.percent']) {
      final style = tester.widget<AppText>(_key(id)).span.style!;
      expect(
        (style.fontFamily, style.fontSize, style.fontWeight, style.color),
        ('Figtree', 11.5, FontWeight.w600, const Color(0xFFA89D8B)),
        reason: id,
      );
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    }
  });

  testWidgets('semântica: "Dom Casmurro, página 159 de 256"', (tester) async {
    final h = tester.ensureSemantics();
    await tela19(tester);
    final data = tester.getSemantics(_key('r19.page')).getSemanticsData();
    expect(data.label, 'Dom Casmurro, página 159 de 256');
    expect(data.value, startsWith('Retórica dos namorados, dá-me'));
    h.dispose();
  });

  test(
    'o índice injetado da tela 19 dá os números do arquivo pelas regras do app',
    () async {
      final i = livro.index;
      expect(i.refPagesTotal, 256);
      expect(i.totalChars, caracteresDoLivro);
      expect(i.globalOffset(itemDaPagina159, 0), caracteresAntesDaPagina159);
      final n = numbersAt(i, itemDaPagina159, 0);
      expect((n.refPage, n.progression), (159, 0.62113));
      expect(i.spine.every((s) => s.linear), isTrue);
    },
  );
}

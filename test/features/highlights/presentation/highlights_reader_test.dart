// G19.8 — a tela 25 com o leitor (R13, D-195, D-199), no mundo de referência com o livro aberto na pág. 159: o botão
// Grifos abre a 25; tocar num cartão fecha os controles e salta para o trecho, com "Voltar à pág. 159"; "Continuar
// lendo" só fecha os controles; o grifo sem lugar vai à página dele com o aviso; e o `?ir=` (a 25 aberta pela
// Início) salta logo depois de abrir, com a volta para a posição de leitura.
import 'package:app_leitura/core/data/database/daos/annotation_daos.dart';
import 'package:app_leitura/features/highlights/presentation/highlights_screen.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/domain/locator.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/reader_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart';
import '../../../support/app_text_finder.dart';
import '../../../support/canvas.dart';
import '../../../support/dados_t25.dart';
import '../../../support/fase_l25.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pump_reader.dart';
import '../../../support/reader_harness.dart';

Future<void> _quadros(WidgetTester tester, [int n = 40]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

ReaderDocument _doc(WidgetTester tester) =>
    tester.widget<ReaderPageView>(find.byType(ReaderPageView)).document;

int _pagina(WidgetTester tester) => _doc(tester).numbers.refPage;

/// A página de referência do trecho da anotação [a] no livro de teste (o EPUB do mundo tem as páginas do índice da
/// tela 19, não as do arquivo).
int _paginaDe(WidgetTester tester, Annotation a) {
  final ancora = a.anchor as EpubAnchor;
  return _doc(tester).anchors!.placeOf(ancora.spine, ancora.start).refPage;
}

/// A página na tela começa antes do trecho de [a] e é a de referência dele (ou a de antes: a página da tela pode
/// começar no fim da página de referência anterior).
void _naPaginaDoTrecho(WidgetTester tester, Annotation a) {
  final ancora = a.anchor as EpubAnchor;
  final inicio = _doc(tester).mark;
  expect(inicio.spine, ancora.spine);
  expect(inicio.offset, lessThanOrEqualTo(ancora.start));
  expect(
    _pagina(tester),
    inInclusiveRange(_paginaDe(tester, a) - 1, _paginaDe(tester, a)),
  );
  expect(_pagina(tester), isNot(159));
}

Future<void> _ate(WidgetTester tester, String id) async {
  await tester.dragUntilVisible(hl(id), hl('hl.scroll'), const Offset(0, -300));
  await _quadros(tester, 10);
}

Future<void> _grifos(WidgetTester tester) async {
  await tester.tapAt(const Offset(195, 420));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await _quadros(tester, 6);
  await tester.tap(hl('r20.bottomIsland.tools.notes'));
  await esperarTela25(tester, assentar: false);
}

void main() {
  setUpAll(loadAppFonts);

  late LivroNaEstante livro;
  setUp(() async => livro = await livroDaTela25());
  tearDown(() async => livro.close());

  testWidgets(
    'tocar num cartão: o leitor salta para o trecho (pág. 3) com "Voltar à pág. 159"',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro, destaques: depsDaTela25(livro));
      expect(_pagina(tester), 159);
      await _grifos(tester);
      expect(find.byType(HighlightsScreen), findsOneWidget);
      final p3 = cartoes25(tester).first.card.items.first;
      await tester.tap(hl('hl.list.card1.body.quote'));
      await _quadros(tester, 60);
      expect(find.byType(HighlightsScreen), findsNothing);
      _naPaginaDoTrecho(tester, p3);
      expect(hl('r20.topIsland'), findsNothing, reason: 'os controles fecham');
      expect(findAppText('Voltar à pág. 159'), findsOneWidget);
    },
  );

  testWidgets(
    '"Continuar lendo": a mesma página, sem a volta, com os controles fechados',
    (tester) async {
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro, destaques: depsDaTela25(livro));
      await _grifos(tester);
      await _ate(tester, 'hl.end.cta');
      await tester.tap(hl('hl.end.cta'));
      await _quadros(tester, 60);
      expect(find.byType(HighlightsScreen), findsNothing);
      expect(_pagina(tester), 159);
      expect(hl('r20.topIsland'), findsNothing);
      expect(findAppText('Voltar à pág. 159'), findsNothing);
    },
  );

  testWidgets(
    'D-199: o grifo que não volta ao texto leva à página dele com o aviso',
    (tester) async {
      final p121 = mundoReferencia.anotacoes.firstWhere(
        (a) => a.refPage == 121,
      );
      final ancora = p121.anchor as EpubAnchor;
      await tester.runAsync(
        () => AnnotationsDao(livro.db).upsert(
          p121.copyWith(
            anchor: EpubAnchor(
              sha: 'f' * 64,
              spine: ancora.spine,
              start: ancora.start,
              end: ancora.end,
              quote: const TextQuote(
                exact: 'uma frase que nunca esteve neste livro',
              ),
              refPage: 121,
            ),
          ),
        ),
      );
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro, destaques: depsDaTela25(livro));
      await _grifos(tester);
      await _ate(tester, 'hl.list.card4.body.quote');
      await tester.tap(hl('hl.list.card4.body.quote'));
      await _quadros(tester, 60);
      // a página do grifo (pela barra de posição — D-119), longe da 159
      expect(_pagina(tester), lessThan(159));
      expect(findAppText(readerOrphanText), findsOneWidget);
    },
  );

  testWidgets(
    'outra edição do arquivo (outro sha), com o trecho no texto: vai à página, acha e salta sem o aviso',
    (tester) async {
      final p121 = mundoReferencia.anotacoes.firstWhere(
        (a) => a.refPage == 121,
      );
      final ancora = p121.anchor as EpubAnchor;
      await tester.runAsync(
        () => AnnotationsDao(livro.db).upsert(
          p121.copyWith(
            anchor: EpubAnchor(
              sha: 'f' * 64,
              spine: ancora.spine,
              start: ancora.start,
              end: ancora.end,
              quote: ancora.quote,
              refPage: 121,
            ),
          ),
        ),
      );
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro, destaques: depsDaTela25(livro));
      await _grifos(tester);
      await _ate(tester, 'hl.list.card4.body.quote');
      await tester.tap(hl('hl.list.card4.body.quote'));
      await _quadros(tester, 60);
      _naPaginaDoTrecho(tester, p121);
      expect(findAppText(readerOrphanText), findsNothing);
    },
  );

  testWidgets(
    '?ir= (pela Início): o leitor abre e salta para a anotação, com a volta para a posição',
    (tester) async {
      final p41 = mundoReferencia.anotacoes.firstWhere((a) => a.refPage == 41);
      setCanvasView(tester, logical: const Size(390, 844));
      await abrirLeitor(tester, livro, ir: p41.id);
      await _quadros(tester, 60);
      expect(find.byType(ReaderScreen), findsOneWidget);
      _naPaginaDoTrecho(tester, p41);
      expect(findAppText('Voltar à pág. 159'), findsOneWidget);
    },
  );
}

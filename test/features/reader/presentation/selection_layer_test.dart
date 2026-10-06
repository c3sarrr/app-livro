// G13.3 — a camada da seleção (tela 21): o lugar da barra (em cima como no arquivo, senão embaixo, senão presa —
// D-136), as alças medidas da caixa de 1 em do arquivo, a âncora da barra, o nó "Trecho selecionado" (D-57), o
// arrasto das alças (a barra some; parado 300 ms, a lupa e o passo por letra — D-45) e a lupa do app (D-135).
import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/selection_controller.dart';
import 'package:app_leitura/features/reader/presentation/selection_layer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pagina_de_texto.dart';

/// Só o que o pintor da página usa: a página atual e o aviso de mudança.
final class _Doc implements ReaderDocument {
  _Doc(this.current);

  @override
  final DisplayPage current;

  @override
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  @override
  FoundRange? get found => null;

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('lugar da barra (D-136)', () {
    test('em cima quando cabe: topo = fim da 1ª linha − 162 (o arquivo)', () {
      final at = toolbarPlacement(
        firstLineBottom: 92 + 425.53,
        endKnobBottom: 600,
        minTop: 55,
        maxBottom: 802,
      );
      expect(at.place, ToolbarPlace.above);
      expect(at.top, moreOrLessEquals(92 + 425.53 - 162, epsilon: 1e-9));
    });

    test('embaixo quando não cabe em cima: 7,4 abaixo da bolinha final', () {
      final at = toolbarPlacement(
        firstLineBottom: 200,
        endKnobBottom: 300,
        minTop: 55,
        maxBottom: 802,
      );
      expect((at.place, at.top), (ToolbarPlace.below, 307.4));
      // exatamente no limite de cima ainda é em cima
      expect(
        toolbarPlacement(
          firstLineBottom: 217,
          endKnobBottom: 300,
          minTop: 55,
          maxBottom: 802,
        ).place,
        ToolbarPlace.above,
      );
    });

    test('presa em cima quando não cabe nos dois', () {
      final at = toolbarPlacement(
        firstLineBottom: 200,
        endKnobBottom: 700,
        minTop: 55,
        maxBottom: 802,
      );
      expect((at.place, at.top), (ToolbarPlace.pinned, 55.0));
    });
  });

  test('alça: a caixa de 1 em com vertical-align −0,2em, haste e bolinha', () {
    final s = handleGeometry(SelectionHandle.start, 100, 149.6, 20.5);
    expect(s.stem.left, 99);
    expect(s.stem.top, moreOrLessEquals(149.6 - 16.4 - 2, epsilon: 1e-9));
    expect((s.stem.width, s.stem.height), (2.0, 28.5));
    expect(s.knob.left, 93);
    expect(s.knob.top, moreOrLessEquals(149.6 - 16.4 - 13, epsilon: 1e-9));
    expect(s.knob.size, const Size(12, 12));
    final e = handleGeometry(SelectionHandle.end, 100, 149.6, 20.5);
    expect(e.stem, s.stem);
    expect(e.knob.left, 94);
    expect(e.knob.top, moreOrLessEquals(149.6 + 4.1 + 5, epsilon: 1e-9));
  });

  group('camada', () {
    late SelectionController c;
    late PaginaDeTexto pagina;
    var toquesNaBarra = 0;

    Future<void> montar(
      WidgetTester tester, {
      double topo = 300,
      ReaderRange? selecao,
    }) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      c = SelectionController();
      addTearDown(c.dispose);
      toquesNaBarra = 0;
      pagina = PaginaDeTexto('aa bb, cc dd ee ff', x0: 30, topo: topo);
      c.selectWord(selecao ?? (unit: 0, from: 3, to: 5));
      final doc = _Doc(pagina);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              padding: EdgeInsets.only(top: 47, bottom: 34),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: SelectionLayer(
                    page: pagina,
                    controller: c,
                    palette: ReaderChromePalette.of(ReaderPaper.creme),
                    paper: AppColors.paperCream,
                    sideMargin: 28,
                    contentWidth: 334,
                    safeTop: 47,
                    safeBottom: 34,
                    pages: () => ReaderPagesPainter(
                      document: doc,
                      dx: 0,
                      dir: null,
                      neighbor: null,
                    ),
                    toolbar: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => toquesNaBarra++,
                      child: const SizedBox(
                        key: ValueKey('barra'),
                        height: 116.5,
                      ),
                    ),
                    startTimer: Timer.new,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Rect retangulo(WidgetTester tester, String k) =>
        tester.getRect(find.byKey(ValueKey(k)));

    testWidgets('alças, âncora da barra e a barra em cima da seleção (cabe)', (
      tester,
    ) async {
      await montar(tester);
      // "bb" = letras 3–5: x 60…80; linha de 300 a 335,26, base 329,6
      expect(
        retangulo(tester, 'r21.page.text.handleStart'),
        rectMoreOrLessEquals(
          const Rect.fromLTWH(60, 329.6 - 16.4, 0, 20.5),
          epsilon: 1e-6,
        ),
      );
      expect(
        retangulo(tester, 'r21.page.text.handleEnd'),
        rectMoreOrLessEquals(
          const Rect.fromLTWH(80, 329.6 - 16.4, 0, 20.5),
          epsilon: 1e-6,
        ),
      );
      expect(
        retangulo(tester, 'r21.page.text.handleStart.stem'),
        rectMoreOrLessEquals(
          const Rect.fromLTWH(59, 329.6 - 18.4, 2, 28.5),
          epsilon: 1e-6,
        ),
      );
      expect(
        retangulo(tester, 'r21.page.text.handleStart.knob'),
        rectMoreOrLessEquals(
          const Rect.fromLTWH(53, 329.6 - 29.4, 12, 12),
          epsilon: 1e-6,
        ),
      );
      expect(
        retangulo(tester, 'r21.page.text.handleEnd.knob'),
        rectMoreOrLessEquals(
          const Rect.fromLTWH(74, 329.6 + 9.1, 12, 12),
          epsilon: 1e-6,
        ),
      );
      expect(
        retangulo(tester, 'r21.page.text.toolbarAnchor'),
        rectMoreOrLessEquals(
          const Rect.fromLTWH(60, 302.41, 0, 30.44),
          epsilon: 1e-6,
        ),
      );
      // em cima: 335,26 − 162 = 173,26 ≥ 55 → cabe
      expect(
        retangulo(tester, 'barra'),
        rectMoreOrLessEquals(
          const Rect.fromLTWH(22, 335.26 - 162, 346, 116.5),
          epsilon: 1e-6,
        ),
      );
      final alca = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byKey(const ValueKey('r21.page.text.handleEnd.stem')),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(alca.color, AppColors.violet);
    });

    testWidgets('perto do topo a barra vai para baixo da bolinha final', (
      tester,
    ) async {
      await montar(tester, topo: 120);
      expect(
        retangulo(tester, 'barra').top,
        moreOrLessEquals(120 + 29.6 + 4.1 + 5 + 12 + 7.4, epsilon: 1e-6),
      );
    });

    testWidgets(
      'leitor de tela: um nó "Trecho selecionado" com o texto (D-57); as alças ficam de fora',
      (tester) async {
        final semantica = tester.ensureSemantics();
        await montar(tester, selecao: (unit: 0, from: 3, to: 9));
        expect(find.bySemanticsLabel('Trecho selecionado'), findsOneWidget);
        final no = tester.getSemantics(
          find.byKey(const ValueKey('r21.page.text.selection')),
        );
        expect(no.label, 'Trecho selecionado');
        expect(no.value, 'bb, cc');
        semantica.dispose();
      },
    );

    testWidgets(
      'arrastar a alça final: por palavra; a barra some; parado 300 ms, a lupa e o passo por letra',
      (tester) async {
        await montar(tester);
        final bolinha = retangulo(
          tester,
          'r21.page.text.handleEnd.knob',
        ).center;
        final g = await tester.startGesture(bolinha);
        await tester.pump();
        await g.moveBy(const Offset(20, 0));
        await tester.pump();
        await g.moveBy(const Offset(22, 0));
        await tester.pump();
        // o dedo foi de 80 a 122 no x da alça: "cc" (7–9) → fim 9
        expect(c.value, (unit: 0, from: 3, to: 9));
        expect(c.selection!.dragging, SelectionHandle.end);
        expect(find.byKey(const ValueKey('barra')), findsNothing);
        expect(find.byKey(const ValueKey('leitor.lupa')), findsNothing);
        await tester.pump(const Duration(milliseconds: 310));
        expect(c.selection!.byChar, isTrue);
        expect(find.byKey(const ValueKey('leitor.lupa')), findsOneWidget);
        // a lupa: 132 × 48 (mais a sombra), o centro 60 acima do meio da linha da alça
        final lupa = retangulo(tester, 'leitor.lupa').deflate(3);
        expect(lupa.size, const Size(132, 48));
        expect(
          lupa.center.dy,
          moreOrLessEquals(300 + 17.63 - 60, epsilon: 0.01),
        );
        expect(lupa.center.dx, moreOrLessEquals(122, epsilon: 0.01));
        // por letra: o ponto entre as letras
        await g.moveBy(const Offset(11, 0));
        await tester.pump();
        expect(c.value, (unit: 0, from: 3, to: 10));
        await g.up();
        await tester.pump();
        expect(c.selection!.dragging, isNull);
        expect(c.selection!.byChar, isFalse);
        expect(find.byKey(const ValueKey('leitor.lupa')), findsNothing);
        expect(find.byKey(const ValueKey('barra')), findsOneWidget);
      },
    );

    testWidgets(
      'a alça inicial anda pelo começo da palavra e nunca passa da final',
      (tester) async {
        await montar(tester, selecao: (unit: 0, from: 7, to: 9));
        final bolinha = retangulo(
          tester,
          'r21.page.text.handleStart.knob',
        ).center;
        await tester.dragFrom(bolinha, const Offset(-35, 0));
        await tester.pump();
        expect(c.value, (unit: 0, from: 3, to: 9));
        final de = retangulo(tester, 'r21.page.text.handleStart.knob').center;
        await tester.dragFrom(de, const Offset(200, 0));
        await tester.pump();
        expect(c.value, (unit: 0, from: 8, to: 9));
      },
    );

    testWidgets('a lupa fica dentro da tela perto da borda', (tester) async {
      await montar(tester, selecao: (unit: 0, from: 0, to: 2));
      final bolinha = retangulo(
        tester,
        'r21.page.text.handleStart.knob',
      ).center;
      final g = await tester.startGesture(bolinha);
      await g.moveBy(const Offset(-2, 0));
      await tester.pump();
      await g.moveBy(const Offset(-2, 0));
      await tester.pump(const Duration(milliseconds: 310));
      final lupa = retangulo(tester, 'leitor.lupa').deflate(3);
      expect(lupa.left, greaterThanOrEqualTo(8));
      await g.up();
    });

    testWidgets(
      'D-137: no grifo existente, só a barra — sem alças; embaixo, a 7,4 do fim da última linha',
      (tester) async {
        await montar(tester, topo: 120);
        c.showHighlight('g', (unit: 0, from: 3, to: 9));
        await tester.pump();
        for (final k in const [
          'r21.page.text.handleStart',
          'r21.page.text.handleEnd.knob',
          'r21.page.text.handleStart.stem',
          'leitor.selecao.area.start',
          'leitor.selecao.area.end',
        ]) {
          expect(find.byKey(ValueKey(k)), findsNothing, reason: k);
        }
        // a linha vai de 120 a 155,26; em cima não cabe (155,26 − 162 < 55)
        expect(
          retangulo(tester, 'barra').top,
          moreOrLessEquals(120 + 35.26 + 7.4, epsilon: 1e-6),
        );
        expect(
          find.byKey(const ValueKey('r21.page.text.selection')),
          findsOneWidget,
        );
      },
    );

    testWidgets('a barra fica por cima da área da alça: o toque é dela', (
      tester,
    ) async {
      await montar(tester, topo: 120);
      final bolinha = retangulo(tester, 'r21.page.text.handleEnd.knob');
      final barra = retangulo(tester, 'barra');
      // a área da alça (44 × 44 em volta da bolinha) entra 8,6 na barra
      expect(barra.top, lessThan(bolinha.center.dy + handleTouch / 2));
      await tester.tapAt(Offset(bolinha.center.dx, barra.top + 4));
      await tester.pump();
      expect(toquesNaBarra, 1);
      expect(c.selection!.dragging, isNull);
    });

    testWidgets('a lupa não entra na barra de status', (tester) async {
      await montar(tester, topo: 60, selecao: (unit: 0, from: 3, to: 5));
      final bolinha = retangulo(tester, 'r21.page.text.handleEnd.knob').center;
      final g = await tester.startGesture(bolinha);
      await g.moveBy(const Offset(2, 0));
      await tester.pump();
      await g.moveBy(const Offset(2, 0));
      await tester.pump(const Duration(milliseconds: 310));
      final lupa = retangulo(tester, 'leitor.lupa').deflate(3);
      // o meio da linha (77,63) − 60 ficaria em 17,63: sobe até 47 + 24 + 8
      expect(lupa.center.dy, moreOrLessEquals(47 + 24 + 8, epsilon: 1e-6));
      await g.up();
    });

    testWidgets('sem seleção (ou fora da página), nada', (tester) async {
      await montar(tester);
      c.clear();
      await tester.pump();
      expect(find.byKey(const ValueKey('barra')), findsNothing);
      expect(
        find.byKey(const ValueKey('r21.page.text.handleEnd')),
        findsNothing,
      );
    });
  });

  group('lupa (D-135)', () {
    Future<ui.Image> pintar(MagnifierPainter p) async {
      final g = ui.PictureRecorder();
      final canvas = Canvas(g)
        ..drawRect(
          const Rect.fromLTWH(0, 0, 138, 54),
          Paint()..color = const Color(0xFF00FF00),
        );
      p.paint(canvas, const Size(138, 54));
      return g.endRecording().toImage(138, 54);
    }

    test(
      'sombra dura 3/3, papel, a página ampliada 1,25× no foco e a borda 1,5',
      () async {
        final pagina = PaginaDeTexto('aa', x0: 30, topo: 300);
        final img = await pintar(
          MagnifierPainter(
            pages: ReaderPagesPainter(
              document: _Doc(pagina),
              dx: 0,
              dir: null,
              neighbor: null,
            ),
            // o centro da 1ª letra (32…38, 308…328)
            focus: const Offset(35, 318),
            paper: AppColors.paperCream,
            border: AppColors.ink,
            shadow: AppColors.ink,
            screen: const Size(390, 844),
          ),
        );
        final bytes = (await img.toByteData())!;
        Color px(int x, int y) {
          final i = (y * 138 + x) * 4;
          return Color.fromARGB(
            bytes.getUint8(i + 3),
            bytes.getUint8(i),
            bytes.getUint8(i + 1),
            bytes.getUint8(i + 2),
          );
        }

        // a caixa vai de (3, 3) a (135, 51); centro (69, 27)
        expect(px(69, 27), PaginaDeTexto.tinta, reason: 'a letra no foco');
        // a letra (32…38) ampliada 1,25× em volta do foco: 65,25…72,75
        expect(px(66, 27), PaginaDeTexto.tinta);
        expect(px(71, 27), PaginaDeTexto.tinta);
        expect(px(63, 27), AppColors.paperCream);
        expect(px(74, 27), AppColors.paperCream);
        expect(px(30, 10), AppColors.paperCream, reason: 'o papel');
        expect(px(3, 27), AppColors.ink, reason: 'a borda de 1,5');
        expect(px(136, 27), AppColors.ink, reason: 'a sombra 3/3');
        expect(
          px(136, 2),
          const Color(0xFF00FF00),
          reason: 'a sombra começa 3 abaixo',
        );
        expect(px(1, 1), const Color(0xFF00FF00), reason: 'fora da caixa');
        img.dispose();
      },
    );
  });
}

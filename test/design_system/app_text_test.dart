import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_typography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/capture.dart';
import '../support/load_fonts.dart';

const _white = Color(0xFFFFFFFF);

Widget _ltr(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: Align(alignment: Alignment.topLeft, child: child),
);

RenderAppText _render(WidgetTester tester, Key key) =>
    tester.renderObject<RenderAppText>(find.byKey(key));

/// Parágrafo "cru" (sem as correções do AppText), para comparar com o que o AppText pinta.
ui.Paragraph _rawParagraph(TextStyle style, String text, double width) {
  final builder =
      ui.ParagraphBuilder(
          style.getParagraphStyle(
            textHeightBehavior: const TextHeightBehavior(
              leadingDistribution: TextLeadingDistribution.even,
            ),
          ),
        )
        ..pushStyle(style.getTextStyle())
        ..addText(text);
  return builder.build()..layout(ui.ParagraphConstraints(width: width));
}

class _RawParagraphPainter extends CustomPainter {
  _RawParagraphPainter(this.paragraph);
  final ui.Paragraph paragraph;
  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawParagraph(paragraph, Offset.zero);
  @override
  bool shouldRepaint(_RawParagraphPainter old) => false;
}

/// Cobertura de tinta [0, 1] a partir do canal vermelho (fundo branco, tinta de vermelho [inkR]).
/// O pixel é composto sobre branco antes (a borda da captura, arredondada para cima, pode ter
/// pixels transparentes).
double _coverage(Uint8List rgba, int i, int inkR) {
  final alpha = rgba[i * 4 + 3] / 255;
  final red = rgba[i * 4] * alpha + 255 * (1 - alpha);
  return ((255 - red) / (255 - inkR)).clamp(0.0, 1.0);
}

/// Borda inferior (px lógicos, a partir do topo da imagem) de cada faixa horizontal de tinta:
/// última linha de pixels totalmente coberta + a cobertura parcial da linha seguinte.
/// Com "H" (base reta) a borda inferior é a baseline em que os glifos foram pintados.
List<double> _inkBottoms(
  Uint8List rgba,
  int width,
  int height,
  double pixelRatio, {
  int inkR = 0x1A,
}) {
  final rows = List<double>.generate(height, (y) {
    var m = 0.0;
    for (var x = 0; x < width; x++) {
      final c = _coverage(rgba, y * width + x, inkR);
      if (c > m) m = c;
    }
    return m;
  });
  final bottoms = <double>[];
  var y = 0;
  while (y < height) {
    if (rows[y] < 0.02) {
      y++;
      continue;
    }
    var end = y;
    while (end < height && rows[end] >= 0.02) {
      end++;
    }
    var lastFull = end - 1;
    while (lastFull > y && rows[lastFull] < 0.98) {
      lastFull--;
    }
    final next = lastFull + 1 < height ? rows[lastFull + 1] : 0.0;
    bottoms.add((lastFull + 1 + (next < 0.98 ? next : 0.0)) / pixelRatio);
    y = end;
  }
  return bottoms;
}

/// Borda esquerda (px lógicos) da tinta: primeira coluna com tinta, descontada a cobertura parcial.
double _inkLeft(
  Uint8List rgba,
  int width,
  int height,
  double pixelRatio, {
  int inkR = 0x1A,
}) {
  for (var x = 0; x < width; x++) {
    var m = 0.0;
    for (var y = 0; y < height; y++) {
      final c = _coverage(rgba, y * width + x, inkR);
      if (c > m) m = c;
    }
    if (m >= 0.02) return (x + 1 - m) / pixelRatio;
  }
  return double.nan;
}

Future<(Uint8List, int, int)> _pixels(
  WidgetTester tester,
  Key key,
  double pixelRatio,
) async {
  final image = await captureAt(
    tester,
    find.byKey(key),
    pixelRatio: pixelRatio,
  );
  final rgba = await rgbaOf(tester, image);
  final result = (rgba, image.width, image.height);
  image.dispose();
  return result;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('(a) Text vs AppText (prova do arredondamento)', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Boa noite,',
                key: const Key('text'),
                style: AppTextStyles.body13Muted,
              ),
              AppText(
                'Boa noite,',
                key: const Key('app'),
                style: AppTextStyles.body13Muted,
              ),
            ],
          ),
        ),
      ),
    );
    final t = tester.getSize(find.byKey(const Key('text')));
    final a = tester.getSize(find.byKey(const Key('app')));
    debugPrint(
      'Text=$t | AppText=$a',
    ); // registre no relatório (historicamente Text = 59.0 × 16.0)
    debugPrint(
      'Text=${t.width.toStringAsFixed(3)} × ${t.height.toStringAsFixed(3)} | '
      'AppText=${a.width.toStringAsFixed(3)} × ${a.height.toStringAsFixed(3)}',
    );
    expect(a.height, moreOrLessEquals(15.6, epsilon: 0.01));
    expect(a.width, moreOrLessEquals(58.43, epsilon: 0.10));
  });

  testWidgets('(b) shrink-wrap: dentro de Row mede a largura intrínseca exata', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ltr(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              'Boa noite,',
              key: const Key('a'),
              style: AppTextStyles.body13Muted,
            ),
            AppText('Marina', key: const Key('b'), style: AppTextStyles.name16),
          ],
        ),
      ),
    );
    final exactA = _rawParagraph(
      AppTextStyles.body13Muted,
      'Boa noite,',
      double.infinity,
    ).maxIntrinsicWidth;
    final exactB = _rawParagraph(
      AppTextStyles.name16,
      'Marina',
      double.infinity,
    ).maxIntrinsicWidth;
    final a = tester.getRect(find.byKey(const Key('a')));
    final b = tester.getRect(find.byKey(const Key('b')));
    debugPrint(
      'shrink: Boa noite, = ${a.width} (intrínseca $exactA) | Marina = ${b.width} (intrínseca $exactB)',
    );
    expect(a.width, moreOrLessEquals(exactA, epsilon: 1e-9));
    expect(b.width, moreOrLessEquals(exactB, epsilon: 1e-9));
    expect(a.width, moreOrLessEquals(58.43, epsilon: 0.10));
    expect(b.width, moreOrLessEquals(49.51, epsilon: 0.10));
    expect(
      b.left,
      moreOrLessEquals(a.width, epsilon: 1e-9),
      reason: 'sem arredondamento acumulado',
    );
    expect(a.height, moreOrLessEquals(15.6, epsilon: 0.01));
    expect(b.height, moreOrLessEquals(19.2, epsilon: 0.01));
  });

  testWidgets(
    '(c) tight: "Orgulho e Preconceito" em 138 px → "Orgulho e Precon…"',
    (tester) async {
      tester.view.devicePixelRatio = 3;
      await tester.pumpWidget(
        _ltr(
          RepaintBoundary(
            key: const Key('golden'),
            child: ColoredBox(
              color: AppColors.surface,
              child: SizedBox(
                width: 138,
                child: AppText(
                  'Orgulho e Preconceito',
                  key: const Key('t'),
                  style: AppTextStyles.title15,
                  maxLines: 1,
                  ellipsis: true,
                ),
              ),
            ),
          ),
        ),
      );
      final render = _render(tester, const Key('t'));
      expect(render.debugDidExceedMaxLines, isTrue);
      expect(tester.getSize(find.byKey(const Key('t'))), const Size(138, 18));
      // Largura da linha truncada (inclui o "…"): no arquivo, 347,02 − 216,5 = 130,52.
      final paragraph = _rawParagraph(
        AppTextStyles.title15,
        'Orgulho e Preconceito',
        138,
      );
      expect(
        paragraph.computeLineMetrics(),
        hasLength(2),
        reason: 'sem reticências quebraria em 2 linhas',
      );
      final lines = render.debugLines();
      debugPrint(
        'reticências: ${lines.map((l) => '"${l.text}" ${l.left.toStringAsFixed(2)}–${l.right.toStringAsFixed(2)}').join(' | ')}',
      );
      await expectLater(
        await captureAt(tester, find.byKey(const Key('golden'))),
        matchesGoldenFile('../golden/goldens/ds_apptext_reticencias@3x.png'),
      );
    },
  );

  testWidgets('(d) baseline: Row baseline "62%" + "~2h 10min" → 12,78 px', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ltr(
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AppText(
              '62%',
              key: const Key('p'),
              style: AppTextStyles.heroPercent,
            ),
            AppText(
              '~2h 10min',
              key: const Key('t'),
              style: AppTextStyles.caption12Plum,
            ),
          ],
        ),
      ),
    );
    final p = tester.getRect(find.byKey(const Key('p')));
    final t = tester.getRect(find.byKey(const Key('t')));
    debugPrint('baseline: topo "~2h 10min" − topo "62%" = ${t.top - p.top}');
    // Valor do arquivo: 391,24 − 378,46 (= 143,08 − 130,30).
    expect(t.top - p.top, moreOrLessEquals(12.78, epsilon: 0.01));
    expect(p.height, moreOrLessEquals(31.2, epsilon: 0.01));
    expect(t.height, moreOrLessEquals(14.4, epsilon: 0.01));
  });

  testWidgets('(e) coluna "Continue" + "sua história." → 90,16 / 34,44 / 82,66', (
    tester,
  ) async {
    await tester.pumpWidget(
      _ltr(
        Column(
          key: const Key('col'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Continue',
              key: const Key('l1'),
              style: AppTextStyles.displayXL,
            ),
            AppText(
              'sua história.',
              key: const Key('l2'),
              style: AppTextStyles.displaySerifXL,
            ),
          ],
        ),
      ),
    );
    final col = tester.getRect(find.byKey(const Key('col')));
    final l1 = _render(tester, const Key('l1')).debugLines().single;
    final l2 = _render(tester, const Key('l2')).debugLines().single;
    debugPrint(
      'coluna: altura ${col.height} | baselines ${l1.baseline - col.top} e ${l2.baseline - col.top}',
    );
    expect(col.height, moreOrLessEquals(90.16, epsilon: 0.01));
    expect(l1.baseline - col.top, moreOrLessEquals(34.44, epsilon: 0.01));
    expect(l2.baseline - col.top, moreOrLessEquals(82.66, epsilon: 0.01));
    expect(
      tester.getRect(find.byKey(const Key('l2'))).top - col.top,
      moreOrLessEquals(41.16, epsilon: 0.01),
    );
  });

  group('(f) correção de meio letter-spacing', () {
    testWidgets('debugLines começa em 0,00 (sem a correção: −0,70 e +0,50)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _ltr(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Continue',
                key: const Key('c'),
                style: AppTextStyles.displayXL,
              ),
              AppText(
                'ENCONTRO',
                key: const Key('e'),
                style: AppTextStyles.stubLabel,
              ),
            ],
          ),
        ),
      );
      final c = _render(tester, const Key('c')).debugLines().single;
      final e = _render(tester, const Key('e')).debugLines().single;
      final rawC = _rawParagraph(
        AppTextStyles.displayXL,
        'Continue',
        double.infinity,
      ).computeLineMetrics().single.left;
      final rawE = _rawParagraph(
        AppTextStyles.stubLabel,
        'ENCONTRO',
        double.infinity,
      ).computeLineMetrics().single.left;
      debugPrint(
        'meio letter-spacing: Continue ${c.left} (cru $rawC) | ENCONTRO ${e.left} (cru $rawE)',
      );
      expect(c.left, moreOrLessEquals(0, epsilon: 0.05));
      expect(e.left, moreOrLessEquals(0, epsilon: 0.05));
      expect(
        rawC,
        moreOrLessEquals(-0.70, epsilon: 0.001),
        reason: 'deslocamento do SkParagraph',
      );
      expect(
        rawE,
        moreOrLessEquals(0.50, epsilon: 0.001),
        reason: 'deslocamento do SkParagraph',
      );
      expect(c.right, moreOrLessEquals(170.69, epsilon: 0.10));
      expect(e.right, moreOrLessEquals(64.63, epsilon: 0.10));
    });

    testWidgets(
      'pixels (10×): a tinta do AppText começa 0,50 px à esquerda do parágrafo cru',
      (tester) async {
        final raw = _rawParagraph(
          AppTextStyles.stubLabel,
          'ENCONTRO',
          double.infinity,
        );
        Widget box(Key key, Widget child) => RepaintBoundary(
          key: key,
          child: ColoredBox(
            color: _white,
            child: Padding(padding: const EdgeInsets.all(3), child: child),
          ),
        );
        await tester.pumpWidget(
          _ltr(
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                box(
                  const Key('app'),
                  AppText('ENCONTRO', style: AppTextStyles.stubLabel),
                ),
                box(
                  const Key('raw'),
                  SizedBox(
                    width: raw.maxIntrinsicWidth,
                    height: 12,
                    child: CustomPaint(painter: _RawParagraphPainter(raw)),
                  ),
                ),
              ],
            ),
          ),
        );
        final (a, aw, ah) = await _pixels(tester, const Key('app'), 10);
        final (r, rw, rh) = await _pixels(tester, const Key('raw'), 10);
        final appLeft = _inkLeft(a, aw, ah, 10, inkR: 0x4A);
        final rawLeft = _inkLeft(r, rw, rh, 10, inkR: 0x4A);
        debugPrint(
          'pixels ENCONTRO: borda esquerda AppText $appLeft | cru $rawLeft | Δ ${appLeft - rawLeft}',
        );
        expect(appLeft - rawLeft, moreOrLessEquals(-0.50, epsilon: 0.1));
      },
    );
  });

  group('baseline de pintura exata (pixels 10×; o SkParagraph pinta em floor(baseline + 0,5))', () {
    testWidgets('linha única: "H" de Figtree 13 pousa em 12,35 (cru: 12,00)', (
      tester,
    ) async {
      const pad = 3.0;
      final style = AppTextStyles.body13Semi;
      final raw = _rawParagraph(style, 'HHH', double.infinity);
      Widget box(Key key, Widget child) => RepaintBoundary(
        key: key,
        child: ColoredBox(
          color: _white,
          child: Padding(padding: const EdgeInsets.all(pad), child: child),
        ),
      );
      await tester.pumpWidget(
        _ltr(
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              box(
                const Key('app'),
                AppText('HHH', key: const Key('t'), style: style),
              ),
              box(
                const Key('raw'),
                SizedBox(
                  width: raw.maxIntrinsicWidth,
                  height: 15.6,
                  child: CustomPaint(painter: _RawParagraphPainter(raw)),
                ),
              ),
            ],
          ),
        ),
      );
      final expected =
          _render(tester, const Key('t')).debugLines().single.baseline -
          tester.getRect(find.byKey(const Key('t'))).top;
      final (a, aw, ah) = await _pixels(tester, const Key('app'), 10);
      final (r, rw, rh) = await _pixels(tester, const Key('raw'), 10);
      final app = _inkBottoms(a, aw, ah, 10).single - pad;
      final cru = _inkBottoms(r, rw, rh, 10).single - pad;
      debugPrint(
        'pixels HHH (Figtree 13): baseline esperada $expected | tinta AppText $app | tinta crua $cru',
      );
      expect(expected, moreOrLessEquals(12.35, epsilon: 0.005));
      expect(app, moreOrLessEquals(12.35, epsilon: 0.1));
      expect(
        cru,
        moreOrLessEquals(12.0, epsilon: 0.1),
        reason: 'confirma o arredondamento do SkParagraph',
      );
    });

    testWidgets(
      'várias linhas: "HH HH HH" em Instrument Serif 11 (0,95) → baselines i × 10,45 + ascent',
      (tester) async {
        const pad = 3.0;
        final style = AppTextStyles.coverTitle11;
        final raw = _rawParagraph(style, 'HH HH HH', double.infinity);
        final lineWidth = _rawParagraph(
          style,
          'HH',
          double.infinity,
        ).maxIntrinsicWidth;
        await tester.pumpWidget(
          _ltr(
            RepaintBoundary(
              key: const Key('app'),
              child: ColoredBox(
                color: _white,
                child: Padding(
                  padding: const EdgeInsets.all(pad),
                  child: SizedBox(
                    width: lineWidth + 2,
                    child: AppText(
                      'HH HH HH',
                      key: const Key('t'),
                      style: style,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        final render = _render(tester, const Key('t'));
        final top = tester.getRect(find.byKey(const Key('t'))).top;
        final ascent = raw.computeLineMetrics().single.ascent;
        final lines = render.debugLines();
        expect(lines.map((l) => l.text).toList(), ['HH', 'HH', 'HH']);
        expect(
          tester.getSize(find.byKey(const Key('t'))).height,
          moreOrLessEquals(3 * 10.45, epsilon: 0.01),
        );
        for (var i = 0; i < 3; i++) {
          expect(
            lines[i].baseline - top,
            moreOrLessEquals(i * 10.45 + ascent, epsilon: 0.005),
            reason: 'debugLines L${i + 1}',
          );
        }
        final (a, aw, ah) = await _pixels(tester, const Key('app'), 10);
        final ink = _inkBottoms(a, aw, ah, 10).map((b) => b - pad).toList();
        final skia = [
          for (var i = 0; i < 3; i++) i * 10.0 + (ascent + 0.5).floorToDouble(),
        ];
        debugPrint(
          'pixels 3 linhas: esperado ${[for (final l in lines) (l.baseline - top).toStringAsFixed(3)]} | tinta AppText ${ink.map((v) => v.toStringAsFixed(3)).toList()} | SkParagraph sem correção ${skia.map((v) => v.toStringAsFixed(3)).toList()}',
        );
        expect(ink, hasLength(3));
        for (var i = 0; i < 3; i++) {
          expect(
            ink[i],
            moreOrLessEquals(lines[i].baseline - top, epsilon: 0.1),
            reason: 'tinta L${i + 1}',
          );
        }
      },
    );
  });

  testWidgets(
    'várias linhas: "MACHADO DE ASSIS" em 78 px → 2 linhas, baselines 6,18 / 13,99 (hero.cover.author)',
    (tester) async {
      await tester.pumpWidget(
        _ltr(
          SizedBox(
            width: 78,
            child: AppText(
              'MACHADO DE ASSIS',
              key: const Key('t'),
              style: AppTextStyles.coverAuthorPaper,
            ),
          ),
        ),
      );
      final lines = _render(tester, const Key('t')).debugLines();
      final top = tester.getRect(find.byKey(const Key('t'))).top;
      expect(lines.map((l) => l.text).toList(), ['MACHADO DE', 'ASSIS']);
      expect(
        tester.getSize(find.byKey(const Key('t'))).height,
        moreOrLessEquals(15.6, epsilon: 0.01),
      );
      // Arquivo: 404,72 − 398,54 e 412,53 − 398,54 (valores arredondados a 0,01 cada).
      expect(lines[0].baseline - top, moreOrLessEquals(6.18, epsilon: 0.02));
      expect(lines[1].baseline - top, moreOrLessEquals(13.99, epsilon: 0.02));
      expect(
        lines[0].right - lines[0].left,
        moreOrLessEquals(52.96, epsilon: 0.10),
      );
      expect(
        lines[1].right - lines[1].left,
        moreOrLessEquals(22.91, epsilon: 0.10),
      );
    },
  );

  group('(g) medição intrínseca após o layout não altera a pintura', () {
    Widget sample() => RepaintBoundary(
      key: const Key('golden'),
      child: ColoredBox(
        color: AppColors.paper,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Continue',
              key: const Key('t1'),
              style: AppTextStyles.displayXL,
            ),
            SizedBox(
              width: 78,
              child: AppText(
                'MACHADO DE ASSIS',
                key: const Key('t2'),
                style: AppTextStyles.coverAuthorFlame,
              ),
            ),
            SizedBox(
              width: 138,
              child: AppText(
                'Orgulho e Preconceito',
                key: const Key('t3'),
                style: AppTextStyles.title15,
                maxLines: 1,
                ellipsis: true,
              ),
            ),
          ],
        ),
      ),
    );

    testWidgets('consultas intrínsecas/secas depois do layout → mesmo golden', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 3;
      await tester.pumpWidget(_ltr(sample()));
      final before = await captureAt(tester, find.byKey(const Key('golden')));
      final beforeBytes = await rgbaOf(tester, before);
      await expectLater(
        before,
        matchesGoldenFile('../golden/goldens/ds_apptext_intrinseca@3x.png'),
      );
      for (final k in const [Key('t1'), Key('t2'), Key('t3')]) {
        final r = _render(tester, k);
        r.getMinIntrinsicWidth(double.infinity);
        r.getMaxIntrinsicWidth(double.infinity);
        r.getMinIntrinsicHeight(10);
        r.getMaxIntrinsicHeight(1000);
        r.getDryLayout(const BoxConstraints(maxWidth: 20));
        r.getDryBaseline(
          const BoxConstraints(maxWidth: 33),
          TextBaseline.alphabetic,
        );
        r.markNeedsPaint();
      }
      await tester.pump();
      final after = await captureAt(tester, find.byKey(const Key('golden')));
      expect(await rgbaOf(tester, after), beforeBytes);
      await expectLater(
        after,
        matchesGoldenFile('../golden/goldens/ds_apptext_intrinseca@3x.png'),
      );
    });

    testWidgets('dentro de IntrinsicWidth → mesmo golden', (tester) async {
      tester.view.devicePixelRatio = 3;
      await tester.pumpWidget(_ltr(IntrinsicWidth(child: sample())));
      await expectLater(
        await captureAt(tester, find.byKey(const Key('golden'))),
        matchesGoldenFile('../golden/goldens/ds_apptext_intrinseca@3x.png'),
      );
    });
  });

  testWidgets(
    'semântica: rótulo = texto (ou semanticsLabel) e sem fronteira própria',
    (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _ltr(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                key: const Key('merge'),
                container: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText('Boa noite,', style: AppTextStyles.body13Muted),
                    AppText('Marina', style: AppTextStyles.name16),
                  ],
                ),
              ),
              Semantics(
                key: const Key('section'),
                container: true,
                explicitChildNodes: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText('Esta semana', style: AppTextStyles.body13Bold),
                    AppText(
                      '24',
                      style: AppTextStyles.stubDay,
                      semanticsLabel: 'dia 24',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      // Sob um nó sem explicitChildNodes, os rótulos se fundem nele (como RenderParagraph).
      expect(
        tester.getSemantics(find.byKey(const Key('merge'))),
        matchesSemantics(label: 'Boa noite,\nMarina'),
      );
      // Sob uma seção (explicitChildNodes), cada AppText vira um nó de texto próprio.
      expect(find.bySemanticsLabel('Esta semana'), findsOneWidget);
      expect(find.bySemanticsLabel('dia 24'), findsOneWidget);
      expect(find.bySemanticsLabel('24'), findsNothing);
      handle.dispose();
    },
  );

  testWidgets(
    'T01 — sublinhado como o Chromium (text-underline-offset 3, espessura auto = tamanho/10): '
    '"Editar rótulos" da 23b, de baseline + 3 a + 4,25, da primeira à última letra',
    (tester) async {
      const pad = 4.0;
      await tester.pumpWidget(
        _ltr(
          RepaintBoundary(
            key: const Key('caixa'),
            child: ColoredBox(
              color: _white,
              child: Padding(
                padding: const EdgeInsets.all(pad),
                child: AppText(
                  'Editar rótulos',
                  key: const Key('t'),
                  style: AppTextStyles.annPanelLink.copyWith(
                    color: AppColors.ink,
                  ),
                  underline: AppTextStyles.annPanelLinkUnderline,
                ),
              ),
            ),
          ),
        ),
      );
      final r = _render(tester, const Key('t'));
      final topo = tester.getRect(find.byKey(const Key('t'))).top;
      final linha = r.debugLines().single;
      final (px, w, h) = await _pixels(tester, const Key('caixa'), 10);
      // a faixa: as linhas de pixel com tinta em quase toda a largura do texto, abaixo da baseline
      final base = linha.baseline - topo + pad;
      final esquerda =
          ((linha.left - tester.getRect(find.byKey(const Key('caixa'))).left) *
                  10)
              .round();
      final direita =
          ((linha.right - tester.getRect(find.byKey(const Key('caixa'))).left) *
                  10)
              .round();
      double cobertura(int y) {
        var soma = 0.0;
        for (var x = esquerda + 5; x < direita - 5; x++) {
          soma += _coverage(px, y * w + x, 0x1A);
        }
        return soma / (direita - esquerda - 10);
      }

      final faixa = [
        for (var y = ((base + 0.5) * 10).round(); y < h; y++)
          if (cobertura(y) > 0.5) y,
      ];
      expect(faixa, isNotEmpty);
      expect(faixa.first / 10, moreOrLessEquals(base + 3, epsilon: 0.1));
      expect(
        (faixa.last + 1) / 10,
        moreOrLessEquals(base + 4.25, epsilon: 0.1),
      );
      // da primeira à última letra (a caixa das letras, sem os brancos)
      final y = faixa[faixa.length ~/ 2];
      expect(_coverage(px, y * w + esquerda + 2, 0x1A), greaterThan(0.5));
      expect(_coverage(px, y * w + direita - 2, 0x1A), greaterThan(0.5));
      expect(_coverage(px, y * w + esquerda - 3, 0x1A), lessThan(0.5));
      expect(_coverage(px, y * w + direita + 3, 0x1A), lessThan(0.5));
      expect(
        h / 10,
        greaterThan(base + 4.25),
        reason: 'a faixa passa do pé da caixa e não é cortada',
      );
    },
  );
  test('T01 — AppTextUnderline: igualdade e hashCode pelo deslocamento e pela espessura', () {
    const a = AppTextUnderline(offset: 3, thickness: 1.25);
    expect(a, const AppTextUnderline(offset: 3, thickness: 1.25));
    expect(
      a.hashCode,
      const AppTextUnderline(offset: 3, thickness: 1.25).hashCode,
    );
    expect(a, isNot(const AppTextUnderline(offset: 4, thickness: 1.25)));
    expect(a, isNot(const AppTextUnderline(offset: 3, thickness: 2)));
  });

  testWidgets(
    'T01 — trocar o sublinhado de um texto já montado repinta (pôr, mudar e tirar)',
    (tester) async {
      Future<double?> faixa(AppTextUnderline? u) async {
        await tester.pumpWidget(
          _ltr(
            RepaintBoundary(
              key: const Key('caixa'),
              child: ColoredBox(
                color: _white,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: AppText(
                    'Editar rótulos',
                    key: const Key('t'),
                    style: AppTextStyles.annPanelLink.copyWith(
                      color: AppColors.ink,
                    ),
                    underline: u,
                  ),
                ),
              ),
            ),
          ),
        );
        final (px, w, h) = await _pixels(tester, const Key('caixa'), 10);
        // a 1ª linha de pixel, abaixo das letras, com tinta no meio da largura
        final linha = _render(tester, const Key('t')).debugLines().single;
        final base =
            linha.baseline - tester.getRect(find.byKey(const Key('t'))).top + 4;
        final x = (w / 2).round();
        for (var y = ((base + 1) * 10).round(); y < h; y++) {
          if (_coverage(px, y * w + x, 0x1A) > 0.5) return y / 10 - base;
        }
        return null;
      }

      expect(await faixa(null), isNull);
      expect(
        await faixa(const AppTextUnderline(offset: 3, thickness: 1.25)),
        moreOrLessEquals(3, epsilon: 0.1),
      );
      expect(
        await faixa(const AppTextUnderline(offset: 5, thickness: 1.25)),
        moreOrLessEquals(5, epsilon: 0.1),
      );
      expect(await faixa(null), isNull);
    },
  );
}

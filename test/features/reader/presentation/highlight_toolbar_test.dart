// G13.3 — a barra de ações da tela 21 (L21b) montada sozinha no lugar do arquivo (22, 353,12, 346 de largura):
// geometria dos ids da seção (±0,5; ±1 nos que dependem do texto), linhas de texto, estilos, semântica, toques, o
// grifo existente marcado com um anel (D-132), o Noite (cores das ilhas e ícones tingidos), o anel arco-íris e o
// ícone do Sublinhar pintados.
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/painters/chromium_dash.dart';
import 'package:app_leitura/core/design_system/painters/conic_ring_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/highlight_toolbar.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/ref_tipos.dart';
import '../../../reference/leitor/reference_layout_21_selecao_texto.dart';
import '../../../support/load_fonts.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

/// Grava o que os pintores desenham.
final class _Tela implements ui.Canvas {
  final chamadas = <String>[];
  final circulos = <(Offset, double, Paint)>[];

  /// O parágrafo é descartado depois de pintado: guarda as medidas na hora.
  final paragrafos = <({double largura, double base, Offset at})>[];
  final caminhos = <(Path, Paint)>[];

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    chamadas.add('círculo');
    circulos.add((c, radius, paint));
  }

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) {
    chamadas.add('texto');
    paragrafos.add((
      largura: paragraph.longestLine,
      base: paragraph.computeLineMetrics().single.baseline,
      at: offset,
    ));
  }

  @override
  void drawPath(Path path, Paint paint) {
    chamadas.add('caminho');
    caminhos.add((path, paint));
  }

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(loadAppFonts);

  late List<String> eventos;
  Rect? origem;

  Future<void> montar(
    WidgetTester tester, {
    ReaderPaper papel = ReaderPaper.creme,
    ToolbarMark? marcado,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    eventos = [];
    origem = null;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Positioned(
              left: 22,
              top: 353.12,
              width: 346,
              child: HighlightToolbar(
                palette: ReaderChromePalette.of(papel),
                marked: marcado,
                onColor: (c) => eventos.add('cor $c'),
                onOtherColor: () => eventos.add('outra cor'),
                onUnderline: () => eventos.add('sublinhar'),
                onNote: () => eventos.add('nota'),
                onCopy: () => eventos.add('copiar'),
                onShare: (r) {
                  eventos.add('compartilhar');
                  origem = r;
                },
                onSearch: () => eventos.add('buscar'),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'geometria da L21b: caixa, cores, "outra cor", Sublinhar e as 4 ações',
    (tester) async {
      await montar(tester);
      final ids = [
        for (final e in kRef21.elements.entries)
          if (e.value.section == 'r21.toolbar' &&
              e.value.kind != LeitorRefKind.inline)
            e.key,
      ];
      expect(ids, hasLength(22));
      final falhas = <String>[];
      for (final id in ids) {
        final ref = kRef21.elements[id]!.rect;
        final got = tester.getRect(_key(id));
        final tolX = kRef21.textDependentX.contains(id) ? 1.0 : 0.5;
        void confere(String o, double g, double e, double tol) {
          if ((g - e).abs() > tol + 1e-6) {
            falhas.add(
              '$id.$o: ${g.toStringAsFixed(2)} ≠ ${e.toStringAsFixed(2)}',
            );
          }
        }

        confere('x', got.left, ref.left, tolX);
        confere('y', got.top, ref.top, 0.5);
        confere('w', got.width, ref.width, tolX);
        confere('h', got.height, ref.height, 0.5);
      }
      expect(falhas, isEmpty, reason: falhas.join('\n'));
    },
  );

  testWidgets('linhas: "GRIFAR" e os rótulos das ações (baseline e bordas)', (
    tester,
  ) async {
    await montar(tester);
    for (final id in const [
      'r21.toolbar.colors.label',
      'r21.toolbar.actions.note',
      'r21.toolbar.actions.copy',
      'r21.toolbar.actions.share',
      'r21.toolbar.actions.search',
    ]) {
      final ref = kRef21.elements[id]!.lines;
      final r = tester.renderObject<RenderAppText>(
        find
            .descendant(
              of: _key(id),
              matching: find.byType(AppText),
              matchRoot: true,
            )
            .last,
      );
      final got = r.debugLines();
      expect(got.map((l) => l.text), ref.map((l) => l.text), reason: id);
      expect(
        got.single.baseline,
        moreOrLessEquals(ref.single.baseline, epsilon: 0.5),
        reason: id,
      );
      expect(
        got.single.left,
        moreOrLessEquals(ref.single.left, epsilon: 1),
        reason: id,
      );
      expect(
        got.single.right,
        moreOrLessEquals(ref.single.right, epsilon: 1),
        reason: id,
      );
    }
  });

  testWidgets('estilo: caixa, círculos, "GRIFAR", rótulos e o tracejado', (
    tester,
  ) async {
    await montar(tester);
    final caixa = tester.widget<NeoBox>(_key('r21.toolbar'));
    expect(
      (
        caixa.color,
        caixa.border,
        caixa.radius,
        caixa.shadow,
        caixa.shadowColor,
      ),
      (
        AppColors.surface,
        const BorderSide(width: 1.5, color: AppColors.ink),
        BorderRadius.circular(22),
        const Offset(3, 3),
        AppColors.ink,
      ),
    );
    for (final (k, cor) in const [
      ('yellow', Color(0xFFFED170)),
      ('pink', Color(0xFFFFC1C6)),
      ('green', Color(0xFFABCF82)),
      ('lavender', Color(0xFFB6ACE4)),
    ]) {
      final c = tester.widget<NeoBox>(
        find.descendant(
          of: _key('r21.toolbar.colors.$k'),
          matching: find.byType(NeoBox),
        ),
      );
      expect(
        (c.color, c.border),
        (cor, const BorderSide(width: 1.5, color: AppColors.ink)),
        reason: k,
      );
      expect(c.radius, BorderRadius.circular(999));
    }
    final sub = tester.widget<NeoBox>(
      find.descendant(
        of: _key('r21.toolbar.colors.underline'),
        matching: find.byType(NeoBox),
      ),
    );
    expect(sub.color, AppColors.surface);
    final grifar = tester.widget<AppText>(_key('r21.toolbar.colors.label'));
    final s = grifar.span.style!;
    expect(
      (s.fontFamily, s.fontSize, s.fontWeight, s.letterSpacing, s.color),
      ('Figtree', 11.0, FontWeight.w800, 1.2, AppColors.labelReader),
    );
    final nota = tester.widget<AppText>(
      find.descendant(
        of: _key('r21.toolbar.actions.note'),
        matching: find.byType(AppText),
      ),
    );
    expect(
      (
        nota.span.style!.fontSize,
        nota.span.style!.fontWeight,
        nota.span.style!.color,
      ),
      (11.5, FontWeight.w800, AppColors.ink),
    );
    final traco = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: _key('r21.toolbar.colors'),
            matching: find.byType(CustomPaint),
          ),
        )
        .map((c) => c.painter)
        .whereType<ChromiumDashPainter>()
        .single;
    expect(
      (traco.axis, traco.thickness, traco.color),
      (Axis.horizontal, 1.5, AppColors.dashReader),
    );
    expect(
      tester.getRect(
        find.descendant(
          of: _key('r21.toolbar.colors'),
          matching: find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is ChromiumDashPainter,
          ),
        ),
      ),
      const Rect.fromLTWH(33.5, 364.62 + 42, 323, 1.5),
      reason: 'o tracejado no pé da linha das cores',
    );
    // ícones do arquivo, sem tingir no Creme
    for (final k in ['note', 'copy', 'share', 'search']) {
      expect(
        tester.widget<AppSvg>(_key('r21.toolbar.actions.$k.icon')).color,
        isNull,
        reason: k,
      );
    }
  });

  testWidgets(
    'leitor de tela: a barra e os 10 botões com os rótulos do arquivo',
    (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(tester);
      expect(
        find.bySemanticsLabel('Ações para o trecho selecionado'),
        findsOneWidget,
      );
      // seleção nova: as cores não têm estado de escolhida
      expect(
        tester.getSemantics(_key('r21.toolbar.colors.yellow')),
        isSemantics(
          label: 'Grifar em amarelo',
          isButton: true,
          hasSelectedState: false,
        ),
      );
      for (final r in const [
        'Grifar em amarelo',
        'Grifar em rosa',
        'Grifar em verde',
        'Grifar em lavanda',
        'Escolher outra cor',
        'Sublinhar',
        'Nota',
        'Copiar',
        'Compartilhar',
        'Buscar',
      ]) {
        expect(find.bySemanticsLabel(r), findsOneWidget, reason: r);
      }
      expect(
        find.bySemanticsLabel('GRIFAR'),
        findsNothing,
        reason: 'o rótulo da linha não é lido sozinho',
      );
      semantica.dispose();
    },
  );

  testWidgets('toques: cada botão chama o seu (a cor com o hex)', (
    tester,
  ) async {
    await montar(tester);
    for (final k in const [
      'r21.toolbar.colors.yellow',
      'r21.toolbar.colors.pink',
      'r21.toolbar.colors.green',
      'r21.toolbar.colors.lavender',
      'r21.toolbar.colors.other',
      'r21.toolbar.colors.underline',
      'r21.toolbar.actions.note',
      'r21.toolbar.actions.copy',
      'r21.toolbar.actions.share',
      'r21.toolbar.actions.search',
    ]) {
      await tester.tap(_key(k));
      await tester.pumpAndSettle();
    }
    expect(eventos, [
      'cor #FED170',
      'cor #FFC1C6',
      'cor #ABCF82',
      'cor #B6ACE4',
      'outra cor',
      'sublinhar',
      'nota',
      'copiar',
      'compartilhar',
      'buscar',
    ]);
    // no iPad a folha do sistema sai do botão: o retângulo dele na tela
    expect(origem, tester.getRect(_key('r21.toolbar.actions.share')));
  });

  testWidgets(
    'grifo existente (D-132): a cor dele ganha o anel de 40, selecionada; sublinhado → no Sublinhar',
    (tester) async {
      final semantica = tester.ensureSemantics();
      await montar(
        tester,
        marcado: (color: '#FED170', style: HighlightStyle.fill),
      );
      expect(_key('r21.toolbar.colors.yellow.marked'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => '${w.key}'.contains('.marked')),
        findsOneWidget,
      );
      expect(
        tester.getRect(_key('r21.toolbar.colors.yellow.marked')),
        const Rect.fromLTWH(115.5 - 3, 364.62 - 3, 40, 40),
      );
      final anel = tester.widget<DecoratedBox>(
        find.descendant(
          of: _key('r21.toolbar.colors.yellow.marked'),
          matching: find.byType(DecoratedBox),
        ),
      );
      final d = anel.decoration as BoxDecoration;
      expect(
        (d.shape, d.border),
        (BoxShape.circle, Border.all(width: 1.5, color: AppColors.ink)),
      );
      expect(d.color, isNull);
      expect(
        tester.getSemantics(_key('r21.toolbar.colors.yellow')),
        isSemantics(hasSelectedState: true, isSelected: true),
      );
      expect(
        tester.getSemantics(_key('r21.toolbar.colors.pink')),
        isSemantics(hasSelectedState: true, isSelected: false),
      );
      // a marcada apaga: o leitor de tela avisa
      expect(
        tester.getSemantics(_key('r21.toolbar.colors.yellow')).hint,
        toolbarRemoveHint,
      );
      expect(toolbarRemoveHint, 'Apaga o grifo');
      expect(tester.getSemantics(_key('r21.toolbar.colors.pink')).hint, '');
      await montar(
        tester,
        marcado: (color: '#FED170', style: HighlightStyle.underline),
      );
      expect(_key('r21.toolbar.colors.underline.marked'), findsOneWidget);
      expect(_key('r21.toolbar.colors.yellow.marked'), findsNothing);
      expect(
        tester.getSemantics(_key('r21.toolbar.colors.underline')).hint,
        toolbarRemoveHint,
      );
      await montar(
        tester,
        marcado: (color: '#123456', style: HighlightStyle.fill),
      );
      expect(
        find.byWidgetPredicate((w) => '${w.key}'.contains('.marked')),
        findsNothing,
        reason: 'cor de fora da barra',
      );
      semantica.dispose();
    },
  );

  testWidgets(
    'Noite: cores das ilhas, "GRIFAR" no cinza, ícones tingidos com a borda, tracejado escuro',
    (tester) async {
      await montar(
        tester,
        papel: ReaderPaper.noite,
        marcado: (color: '#B6ACE4', style: HighlightStyle.fill),
      );
      final caixa = tester.widget<NeoBox>(_key('r21.toolbar'));
      expect(
        (caixa.color, caixa.border!.color, caixa.shadowColor),
        (AppColors.islandNight, AppColors.inkNight, AppColors.shadowNight),
      );
      expect(
        tester
            .widget<AppText>(_key('r21.toolbar.colors.label'))
            .span
            .style!
            .color,
        AppColors.mutedNight,
      );
      for (final k in ['note', 'copy', 'share', 'search']) {
        expect(
          tester.widget<AppSvg>(_key('r21.toolbar.actions.$k.icon')).color,
          AppColors.inkNight,
          reason: k,
        );
      }
      expect(
        tester.widget<AppSvg>(_key('r21.toolbar.colors.other.icon')).color,
        AppColors.inkNight,
      );
      final nota = tester.widget<AppText>(
        find.descendant(
          of: _key('r21.toolbar.actions.note'),
          matching: find.byType(AppText),
        ),
      );
      expect(nota.span.style!.color, AppColors.inkNight);
      final amarelo = tester.widget<NeoBox>(
        find.descendant(
          of: _key('r21.toolbar.colors.yellow'),
          matching: find.byType(NeoBox),
        ),
      );
      expect(
        amarelo.border!.color,
        AppColors.inkNight,
        reason: 'a borda dos círculos é a da ilha',
      );
      final anel = tester.widget<DecoratedBox>(
        find.descendant(
          of: _key('r21.toolbar.colors.lavender.marked'),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        ((anel.decoration as BoxDecoration).border! as Border).top.color,
        AppColors.inkNight,
      );
      final traco = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: _key('r21.toolbar.colors'),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((c) => c.painter)
          .whereType<ChromiumDashPainter>()
          .single;
      expect(traco.color, AppColors.dashNight);
    },
  );

  test('anel arco-íris: o degradê cônico do arquivo começando no topo, a borda e o miolo de 14', () {
    expect(ConicRingPainter.colors, const [
      Color(0xFFFF552E),
      Color(0xFFF2A815),
      Color(0xFFFED170),
      Color(0xFFABCF82),
      Color(0xFF00995E),
      Color(0xFF058CD7),
      Color(0xFFB6ACE4),
      Color(0xFF552CB7),
      Color(0xFFFFC1C6),
      Color(0xFFFF552E),
    ]);
    final tela = _Tela();
    const ConicRingPainter(
      border: AppColors.ink,
      center: AppColors.surface,
      centerRadius: 7,
    ).paint(tela, const Size(34, 34));
    expect(tela.chamadas, ['círculo', 'círculo', 'círculo', 'círculo']);
    final [(c0, r0, p0), (_, r1, p1), (_, r2, p2), (_, r3, p3)] = tela.circulos;
    expect((c0, r0), (const Offset(17, 17), 17.0));
    expect(p0.shader, isNotNull, reason: 'o degradê');
    expect(
      (r1, p1.style, p1.strokeWidth, p1.color.toARGB32()),
      (16.25, PaintingStyle.stroke, 1.5, AppColors.ink.toARGB32()),
    );
    expect(
      (r2, p2.style, p2.color.toARGB32()),
      (7.0, PaintingStyle.fill, AppColors.surface.toARGB32()),
    );
    expect(
      (r3, p3.style, p3.strokeWidth, p3.color.toARGB32()),
      (6.25, PaintingStyle.stroke, 1.5, AppColors.ink.toARGB32()),
    );
  });

  test('anel arco-íris nos pixels: vermelho no topo, lavanda à esquerda (sentido horário, como o CSS)', () async {
    final g = ui.PictureRecorder();
    const ConicRingPainter(
      border: AppColors.ink,
      center: AppColors.surface,
      centerRadius: 7,
    ).paint(Canvas(g), const Size(34, 34));
    final img = await g.endRecording().toImage(34, 34);
    final b = (await img.toByteData())!;
    img.dispose();
    Color px(int x, int y) {
      final i = (y * 34 + x) * 4;
      return Color.fromARGB(
        b.getUint8(i + 3),
        b.getUint8(i),
        b.getUint8(i + 1),
        b.getUint8(i + 2),
      );
    }

    double perto(Color a, Color e) => [
      (a.r - e.r).abs(),
      (a.g - e.g).abs(),
      (a.b - e.b).abs(),
    ].reduce(math.max);
    // o topo (logo à direita do meio) é o começo: coral
    expect(perto(px(18, 4), AppColors.flame), lessThan(0.12));
    // a 3/4 da volta (à esquerda, no meio): entre a lavanda e o violeta (6,75 de 9 trechos)
    final esquerda = px(4, 17);
    expect(
      perto(esquerda, Color.lerp(AppColors.lavender, AppColors.violet, 0.75)!),
      lessThan(0.15),
    );
    // à direita, no meio (1/4 da volta): entre o amarelo e o verde (2,25 de 9)
    expect(
      perto(px(29, 17), Color.lerp(AppColors.sun, AppColors.leaf, 0.25)!),
      lessThan(0.15),
    );
  });

  test('ícone do Sublinhar: o ondulado coral (traço 2 em 24) e o "a" na Literata do livro, na cor pedida', () {
    final tela = _Tela();
    const UnderlineIconPainter(letter: AppColors.ink)
        .paint(tela, const Size(20, 20));
    expect(tela.chamadas, ['caminho', 'texto']);
    final (onda, tinta) = tela.caminhos.single;
    const k = 20 / 24;
    expect(
      (tinta.style, tinta.strokeCap, tinta.color.toARGB32()),
      (PaintingStyle.stroke, StrokeCap.round, AppColors.flame.toARGB32()),
    );
    expect(tinta.strokeWidth, moreOrLessEquals(2 * k, epsilon: 1e-6));
    final caixa = onda.getBounds();
    expect(caixa.left, moreOrLessEquals(4 * k, epsilon: 1e-6));
    expect(caixa.right, moreOrLessEquals(20 * k, epsilon: 1e-6));
    expect(caixa.top, greaterThanOrEqualTo(17 * k - 1e-6));
    expect(caixa.bottom, lessThanOrEqualTo(21 * k + 1e-6));
    // a onda desce e sobe: o meio do 1º trecho (x = 6) fica acima da linha (y = 18), o do 2º abaixo (y = 20)
    final m = onda.computeMetrics().single;
    final umOitavo = m.getTangentForOffset(m.length / 8)!.position;
    final tresOitavos = m.getTangentForOffset(m.length * 3 / 8)!.position;
    expect(umOitavo.dy, lessThan(19 * k));
    expect(tresOitavos.dy, greaterThan(19 * k));
    final a = tela.paragrafos.single;
    expect(a.largura, greaterThan(4), reason: 'o "a" na Literata');
    expect(
      a.at.dx + a.largura / 2,
      moreOrLessEquals(12 * k, epsilon: 1e-6),
      reason: 'centrado em x 10',
    );
    expect(
      a.at.dy + a.base,
      moreOrLessEquals(14.5 * k, epsilon: 1e-6),
      reason: 'linha de base em 12,08',
    );
  });

  test(
    'ícone do Sublinhar nos pixels: o "a" na cor pedida, em cima do ondulado',
    () async {
      final g = ui.PictureRecorder();
      final canvas = Canvas(g)
        ..drawRect(
          const Rect.fromLTWH(0, 0, 20, 20),
          Paint()..color = const Color(0xFFFFFFFF),
        );
      const UnderlineIconPainter(letter: Color(0xFF0000FF))
          .paint(canvas, const Size(20, 20));
      final img = await g.endRecording().toImage(20, 20);
      final b = (await img.toByteData())!;
      img.dispose();
      var azuis = 0;
      var corais = 0;
      for (var y = 0; y < 20; y++) {
        for (var x = 0; x < 20; x++) {
          final i = (y * 20 + x) * 4;
          final (r, gr, bl) = (
            b.getUint8(i),
            b.getUint8(i + 1),
            b.getUint8(i + 2),
          );
          if (bl > r + 60 && bl > gr + 60) {
            azuis++;
            expect(
              y,
              lessThan(13),
              reason: 'o "a" fica acima da linha de base',
            );
          }
          if (r > 200 && gr < 150 && bl < 120) {
            corais++;
            expect(
              y,
              greaterThanOrEqualTo(13),
              reason: 'o ondulado fica embaixo',
            );
          }
        }
      }
      expect(azuis, greaterThanOrEqualTo(4));
      expect(corais, greaterThan(10));
    },
  );

  test('os pintores repintam só quando as cores mudam', () {
    const a = ConicRingPainter(
      border: AppColors.ink,
      center: AppColors.surface,
      centerRadius: 7,
    );
    expect(
      a.shouldRepaint(
        const ConicRingPainter(
          border: AppColors.ink,
          center: AppColors.surface,
          centerRadius: 7,
        ),
      ),
      isFalse,
    );
    expect(
      a.shouldRepaint(
        const ConicRingPainter(
          border: AppColors.inkNight,
          center: AppColors.surface,
          centerRadius: 7,
        ),
      ),
      isTrue,
    );
    expect(
      a.shouldRepaint(
        const ConicRingPainter(
          border: AppColors.ink,
          center: AppColors.islandNight,
          centerRadius: 7,
        ),
      ),
      isTrue,
    );
    const u = UnderlineIconPainter(letter: AppColors.ink);
    expect(
      u.shouldRepaint(const UnderlineIconPainter(letter: AppColors.ink)),
      isFalse,
    );
    expect(
      u.shouldRepaint(const UnderlineIconPainter(letter: AppColors.inkNight)),
      isTrue,
    );
  });
}

// G12.3 — barra de posição (L20b, D-22, D-119, D-124) montada sozinha no lugar do arquivo (31,5/658,36, 327 de
// largura), na pág. 159 de 256 (62 %): trilho, preenchimento, onda, botão, balão e bico nas medidas da prancha;
// arrastar mostra "pág. N" sem navegar e soltar salta uma vez; tocar no trilho salta; voltar à mesma página não
// salta; para o leitor de tela é um slider com "página X de Y" e passos de 1 % (pelo menos 1).
import 'package:app_leitura/core/design_system/painters/hatch_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_scope.dart';
import 'package:app_leitura/features/reader/presentation/scrubber.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_20_leitor_controles.dart';
import '../../../support/load_fonts.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

void main() {
  setUpAll(loadAppFonts);

  late List<int> saltos;

  Future<void> montar(
    WidgetTester tester, {
    int page = 159,
    int total = 256,
    double progression = 0.62,
    ReaderPaper papel = ReaderPaper.creme,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    saltos = [];
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ReaderChromeScope(
          palette: ReaderChromePalette.of(papel),
          brand: AppColors.lavender,
          a: 1,
          child: Stack(
            children: [
              Positioned(
                left: 31.5,
                top: 658.36,
                width: 327,
                child: Scrubber(
                  page: page,
                  total: total,
                  progression: progression,
                  onJump: saltos.add,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confere(String id, Rect got, {Rect? ref, double tolX = 0.5}) {
    final r = ref ?? kRef20.elements[id]!.rect;
    expect(got.left, moreOrLessEquals(r.left, epsilon: tolX), reason: '$id x');
    expect(got.top, moreOrLessEquals(r.top, epsilon: 0.5), reason: '$id y');
    expect(
      got.width,
      moreOrLessEquals(r.width, epsilon: tolX),
      reason: '$id w',
    );
    expect(
      got.height,
      moreOrLessEquals(r.height, epsilon: 0.5),
      reason: '$id h',
    );
  }

  String balao(WidgetTester tester) => tester
      .widget<AppText>(
        find.descendant(
          of: _key('r20.bottomIsland.scrubber.bubble'),
          matching: find.byType(AppText),
        ),
      )
      .span
      .toPlainText();

  testWidgets('geometria da L20b na pág. 159 de 256 (62 %)', (tester) async {
    await montar(tester);
    for (final id in const [
      'r20.bottomIsland.scrubber',
      'r20.bottomIsland.scrubber.track',
      'r20.bottomIsland.scrubber.fill',
      'r20.bottomIsland.scrubber.fill.wave',
      'r20.bottomIsland.scrubber.knob',
    ]) {
      confere(id, tester.getRect(_key(id)));
    }
    // o balão centraliza com translateX(-50%): a caixa visual
    final b = kRef20.elements['r20.bottomIsland.scrubber.bubble']!;
    confere(
      'r20.bottomIsland.scrubber.bubble',
      tester.getRect(_key('r20.bottomIsland.scrubber.bubble')),
      ref: b.visual,
      tolX: 1,
    );
    // o bico gira 45°: o centro do quadrado é o centro da caixa visual
    final t = kRef20.elements['r20.bottomIsland.scrubber.bubble.tail']!;
    final bico = tester.getRect(_key('r20.bottomIsland.scrubber.bubble.tail'));
    expect(bico.size, const Size(10, 10));
    expect(bico.center.dx, moreOrLessEquals(t.visual!.center.dx, epsilon: 1));
    expect(bico.center.dy, moreOrLessEquals(t.visual!.center.dy, epsilon: 0.5));
    // a linha do balão (as linhas da tabela são de layout: desloca pelo translateX)
    final dx = b.visual!.left - b.rect.left;
    final linha = tester
        .renderObject<RenderAppText>(
          find.descendant(
            of: _key('r20.bottomIsland.scrubber.bubble'),
            matching: find.byType(AppText),
          ),
        )
        .debugLines()
        .single;
    expect(linha.text, 'pág. 159');
    expect(linha.left, moreOrLessEquals(b.lines.single.left + dx, epsilon: 1));
    expect(
      linha.baseline,
      moreOrLessEquals(b.lines.single.baseline, epsilon: 0.5),
    );
  });

  testWidgets(
    'cores claras: trilho com a hachura do leitor, brand, onda, botão e balão',
    (tester) async {
      await montar(tester);
      final trilho = tester.widget<NeoBox>(
        _key('r20.bottomIsland.scrubber.track'),
      );
      expect(trilho.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(trilho.clip, isTrue);
      final hachura = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: _key('r20.bottomIsland.scrubber.track'),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((c) => c.painter)
          .whereType<HatchPainter>()
          .single;
      expect(
        (hachura.stripe, hachura.base),
        (const Color(0xFFE9DFCC), AppColors.surface),
      );
      final onda =
          tester
                  .widget<CustomPaint>(
                    _key('r20.bottomIsland.scrubber.fill.wave'),
                  )
                  .painter!
              as FillWavePainter;
      expect((onda.fill, onda.stroke), (AppColors.lavender, AppColors.ink));
      final cor = tester.widget<ColoredBox>(
        find.descendant(
          of: _key('r20.bottomIsland.scrubber.fill'),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(cor.color, AppColors.lavender);
      final botao = tester.widget<NeoBox>(
        _key('r20.bottomIsland.scrubber.knob'),
      );
      expect(botao.color, AppColors.surface);
      expect(botao.border, const BorderSide(width: 2, color: AppColors.ink));
      expect(
        (botao.shadow, botao.shadowColor),
        (const Offset(2, 2), AppColors.ink),
      );
      final b = tester.widget<NeoBox>(_key('r20.bottomIsland.scrubber.bubble'));
      expect(b.color, AppColors.ink);
      expect(b.radius, BorderRadius.circular(10));
      expect(
        tester
            .widget<AppText>(
              find.descendant(
                of: _key('r20.bottomIsland.scrubber.bubble'),
                matching: find.byType(AppText),
              ),
            )
            .span
            .style!
            .color,
        AppColors.paper,
      );
    },
  );

  testWidgets('Noite (26b): hachura #3A332B/#2A2520, botão e balão do Noite', (
    tester,
  ) async {
    await montar(tester, papel: ReaderPaper.noite);
    final hachura = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<HatchPainter>()
        .single;
    expect(
      (hachura.stripe, hachura.base),
      (AppColors.hatchNight, AppColors.islandNight),
    );
    final botao = tester.widget<NeoBox>(_key('r20.bottomIsland.scrubber.knob'));
    expect(
      (botao.color, botao.border!.color, botao.shadowColor),
      (AppColors.islandNight, AppColors.inkNight, AppColors.shadowNight),
    );
    expect(
      tester.widget<NeoBox>(_key('r20.bottomIsland.scrubber.bubble')).color,
      AppColors.inkNight,
    );
  });

  testWidgets(
    'arrastar mostra "pág. N" sem saltar; soltar salta uma vez para N',
    (tester) async {
      await montar(tester);
      final g = await tester.startGesture(const Offset(234.24, 671.36));
      await g.moveBy(const Offset(30, 0));
      await tester.pump();
      await g.moveBy(const Offset(20, 0));
      await tester.pump();
      // 202,74 + 50 = 252,74 de 327 → 1 + round(0,7729 × 255) = 198
      expect(balao(tester), 'pág. 198');
      expect(saltos, isEmpty);
      expect(
        tester.getRect(_key('r20.bottomIsland.scrubber.fill')).width,
        moreOrLessEquals(252.74 / 327 * 324, epsilon: 0.01),
      );
      expect(
        tester.getRect(_key('r20.bottomIsland.scrubber.knob')).center.dx,
        moreOrLessEquals(31.5 + 252.74, epsilon: 0.01),
      );
      await g.up();
      await tester.pump();
      expect(saltos, [198]);
      expect(balao(tester), 'pág. 159', reason: 'até a sessão mudar a página');
    },
  );

  testWidgets('tocar no trilho salta para a página do toque', (tester) async {
    await montar(tester);
    await tester.tapAt(const Offset(31.5 + 327 * 0.25, 671.36));
    await tester.pump();
    expect(saltos, [65]); // 1 + round(0,25 × 255)
  });

  testWidgets(
    'o botão fica na página (não na % de caracteres): tocar nele não salta',
    (tester) async {
      // 1º caractere visível em 62,25 % do livro: pela fração seria a pág. 160; o botão fica na 159
      await montar(tester, progression: 0.6225);
      final botao = tester.getCenter(_key('r20.bottomIsland.scrubber.knob'));
      expect(botao.dx, moreOrLessEquals(31.5 + 158 / 255 * 327, epsilon: 0.01));
      await tester.tapAt(botao);
      await tester.pump();
      expect(saltos, isEmpty);
      expect(balao(tester), 'pág. 159');
    },
  );

  testWidgets('arrastar e voltar à mesma página não salta', (tester) async {
    await montar(tester);
    final g = await tester.startGesture(const Offset(234.24, 671.36));
    await g.moveBy(const Offset(40, 0));
    await tester.pump();
    await g.moveBy(const Offset(-40, 0));
    await tester.pump();
    expect(balao(tester), 'pág. 159');
    await g.up();
    await tester.pump();
    expect(saltos, isEmpty);
  });

  testWidgets(
    'nas pontas: o dedo além do trilho fica na 1ª e na última página',
    (tester) async {
      await montar(tester);
      final g = await tester.startGesture(const Offset(234.24, 671.36));
      await g.moveBy(const Offset(300, 0));
      await tester.pump();
      expect(balao(tester), 'pág. 256');
      await g.moveBy(const Offset(-600, 0));
      await tester.pump();
      expect(balao(tester), 'pág. 1');
      await g.up();
      await tester.pump();
      expect(saltos, [1]);
    },
  );

  testWidgets(
    'leitor de tela: slider "Posição no livro", "página 159 de 256", passos de 1 %',
    (tester) async {
      final h = tester.ensureSemantics();
      await montar(tester);
      final no = tester.getSemantics(_key('r20.bottomIsland.scrubber.track'));
      expect(
        no,
        isSemantics(
          label: 'Posição no livro',
          value: 'página 159 de 256',
          increasedValue: 'página 162 de 256',
          decreasedValue: 'página 156 de 256',
          isSlider: true,
          hasIncreaseAction: true,
          hasDecreaseAction: true,
        ),
      );
      final slider = find.semantics.byLabel('Posição no livro');
      tester.semantics.performAction(slider, SemanticsAction.increase);
      tester.semantics.performAction(slider, SemanticsAction.decrease);
      expect(saltos, [162, 156]);
      // botão e balão ficam de fora (o rótulo é só "Posição no livro", sem "pág. 159")
      expect(no.label, 'Posição no livro');
      expect(no.mergeAllDescendantsIntoThisNode, isFalse);

      // na última página não aumenta; num livro curto o passo é 1
      await montar(tester, page: 256, progression: 1);
      expect(
        tester.getSemantics(_key('r20.bottomIsland.scrubber.track')),
        isSemantics(
          value: 'página 256 de 256',
          isSlider: true,
          hasIncreaseAction: false,
          hasDecreaseAction: true,
        ),
      );
      await montar(tester, page: 1, total: 50, progression: 0);
      expect(
        tester.getSemantics(_key('r20.bottomIsland.scrubber.track')),
        isSemantics(
          increasedValue: 'página 2 de 50',
          hasIncreaseAction: true,
          hasDecreaseAction: false,
        ),
      );
      h.dispose();
    },
  );

  test('passo do leitor de tela: 1 % do livro, pelo menos 1', () {
    expect(scrubberStep(256), 3);
    expect(scrubberStep(50), 1);
    expect(scrubberStep(1000), 10);
    expect(scrubberStep(1), 1);
  });

  testWidgets('FillWavePainter repinta só quando as cores mudam', (
    tester,
  ) async {
    const a = FillWavePainter(fill: AppColors.lavender, stroke: AppColors.ink);
    expect(
      a.shouldRepaint(
        const FillWavePainter(fill: AppColors.lavender, stroke: AppColors.ink),
      ),
      isFalse,
    );
    expect(
      a.shouldRepaint(
        const FillWavePainter(fill: AppColors.sun, stroke: AppColors.ink),
      ),
      isTrue,
    );
    expect(
      a.shouldRepaint(
        const FillWavePainter(
          fill: AppColors.lavender,
          stroke: AppColors.inkNight,
        ),
      ),
      isTrue,
    );
  });
}

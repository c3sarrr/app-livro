// G12.3 — ilha de baixo (L20b) montada sozinha no lugar do arquivo (left/right 14, bottom 30), na pág. 159 de 256
// (62 %), com "≈ 2 h 10 min" e 12 marcas: geometria dos ids da seção (±0,5; ±1 nos que dependem do texto),
// linhas de texto, estilos, o contador (some com 0, "99+" acima de 99, lido junto de "Grifos"), as ferramentas
// (D-118), a Fonte desabilitada no PDF (D-122), o Noite (26b) e o tracejado de cima.
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/painters/chromium_dash.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/bottom_island.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_palette.dart';
import 'package:app_leitura/features/reader/presentation/reader_chrome_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/ref_tipos.dart';
import '../../../reference/leitor/reference_layout_20_leitor_controles.dart';
import '../../../support/load_fonts.dart';

Finder _key(String k) => find.byKey(ValueKey<String>(k));

/// Grava os retângulos que o pintor desenha.
final class _Tela implements ui.Canvas {
  final rects = <Rect>[];

  @override
  void drawRect(Rect rect, Paint paint) => rects.add(rect);

  @override
  Object? noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUpAll(loadAppFonts);

  late List<Object> eventos;

  Future<void> montar(
    WidgetTester tester, {
    int notes = 12,
    bool isPdf = false,
    String? timeLeft = '≈ 2 h 10 min',
    ReaderPaper papel = ReaderPaper.creme,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    eventos = [];
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
                left: 14,
                right: 14,
                bottom: 30,
                child: BottomIsland(
                  numbers: const ReaderNumbersView(
                    refPage: 159,
                    refTotal: 256,
                    progression: 0.62,
                  ),
                  timeLeftLabel: timeLeft,
                  notes: notes,
                  isPdf: isPdf,
                  onJump: eventos.add,
                  onTool: eventos.add,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Linhas de um AppText: texto, baseline e bordas (as da tabela, ±0,5; o fim ±1).
  void linhas(WidgetTester tester, String id, List<LeitorRefLine> ref) {
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
    for (var i = 0; i < got.length; i++) {
      expect(
        got[i].baseline,
        moreOrLessEquals(ref[i].baseline, epsilon: 0.5),
        reason: '$id baseline',
      );
      expect(
        got[i].left,
        moreOrLessEquals(ref[i].left, epsilon: 1),
        reason: '$id início',
      );
      expect(
        got[i].right,
        moreOrLessEquals(ref[i].right, epsilon: 1),
        reason: '$id fim',
      );
    }
  }

  testWidgets(
    'geometria da L20b: ilha, barra, progresso, ferramentas e contador',
    (tester) async {
      await montar(tester);
      final ids = [
        for (final e in kRef20.elements.entries)
          if (e.value.section == 'r20.bottomIsland' &&
              e.value.kind != LeitorRefKind.inline &&
              !e.key.startsWith('r20.bottomIsland.scrubber.bubble'))
            e.key,
      ];
      expect(ids, hasLength(25));
      final falhas = <String>[];
      for (final id in ids) {
        final ref = kRef20.elements[id]!.rect;
        final got = tester.getRect(_key(id));
        final tolX = kRef20.textDependentX.contains(id) ? 1.0 : 0.5;
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

  testWidgets('linhas: progresso, tempo restante, rótulos, "Aa" e contador', (
    tester,
  ) async {
    await montar(tester);
    final e = kRef20.elements;
    linhas(
      tester,
      'r20.bottomIsland.progressRow.position',
      e['r20.bottomIsland.progressRow.position']!.linesAll,
    );
    for (final id in const [
      'r20.bottomIsland.progressRow.timeLeft',
      'r20.bottomIsland.tools.font',
      'r20.bottomIsland.tools.font.circle',
      'r20.bottomIsland.tools.theme',
      'r20.bottomIsland.tools.notes',
      'r20.bottomIsland.tools.notes.badge',
      'r20.bottomIsland.tools.annotate',
      'r20.bottomIsland.tools.toc',
    ]) {
      linhas(tester, id, e[id]!.lines);
    }
  });

  testWidgets(
    'estilo: "62%" em 800 na tinta, o resto em 700 apagado, tabular; ilha e caixas',
    (tester) async {
      await montar(tester);
      final pos = tester.widget<AppText>(
        _key('r20.bottomIsland.progressRow.position'),
      );
      final spans = (pos.span as TextSpan).children!.cast<TextSpan>();
      expect(spans.map((s) => s.text), ['62%', ' do livro · 256 pág.']);
      expect(
        (spans[0].style!.fontWeight, spans[0].style!.color),
        (FontWeight.w800, AppColors.ink),
      );
      expect(
        (spans[1].style!.fontWeight, spans[1].style!.color),
        (FontWeight.w700, AppColors.inkMuted),
      );
      expect(
        spans[1].style!.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      final ilha = tester.widget<NeoBox>(_key('r20.bottomIsland'));
      expect(
        (ilha.color, ilha.border, ilha.radius, ilha.shadow),
        (
          AppColors.surface,
          const BorderSide(width: 1.5, color: AppColors.ink),
          BorderRadius.circular(28),
          const Offset(3, 3),
        ),
      );
      final caixa = tester.widget<NeoBox>(
        _key('r20.bottomIsland.tools.theme.circle'),
      );
      expect(
        (caixa.color, caixa.border, caixa.radius),
        (
          AppColors.paper,
          const BorderSide(width: 1.5, color: AppColors.ink),
          BorderRadius.circular(16),
        ),
      );
      expect(
        tester.widget<AppSvg>(_key('r20.bottomIsland.tools.theme.icon')).asset,
        AppIconsLeitor.sun,
      );
      final tracejado =
          tester.widget<CustomPaint>(_key('r20.bottomIsland.tools')).painter!
              as ChromiumDashPainter;
      expect(tracejado.color, const Color(0xFFCFC3AE));
    },
  );

  testWidgets(
    'contador: some com 0; "99+" acima de 99; o leitor de tela ouve o número',
    (tester) async {
      final h = tester.ensureSemantics();
      await montar(tester);
      expect(
        tester.getSemantics(_key('r20.bottomIsland.tools.notes')),
        isSemantics(label: 'Grifos, 12 marcas', isButton: true),
      );
      await montar(tester, notes: 0);
      expect(_key('r20.bottomIsland.tools.notes.badge'), findsNothing);
      expect(
        tester.getSemantics(_key('r20.bottomIsland.tools.notes')),
        isSemantics(label: 'Grifos', isButton: true),
      );
      await montar(tester, notes: 1);
      expect(
        tester.getSemantics(_key('r20.bottomIsland.tools.notes')),
        isSemantics(label: 'Grifos, 1 marca', isButton: true),
      );
      await montar(tester, notes: 150);
      final badge = tester.widget<AppText>(
        find.descendant(
          of: _key('r20.bottomIsland.tools.notes.badge'),
          matching: find.byType(AppText),
        ),
      );
      expect(badge.span.toPlainText(), '99+');
      expect(
        tester.getSemantics(_key('r20.bottomIsland.tools.notes')),
        isSemantics(label: 'Grifos, 150 marcas', isButton: true),
      );
      h.dispose();
    },
  );

  testWidgets(
    'cada ferramenta avisa a tela; "Anotar" se chama "Anotar à mão"; a ilha é "Controles de leitura"',
    (tester) async {
      final h = tester.ensureSemantics();
      await montar(tester);
      for (final t in ReaderTool.values) {
        await tester.tap(_key('r20.bottomIsland.tools.${t.name}'));
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(eventos, ReaderTool.values);
      expect(
        tester.getSemantics(_key('r20.bottomIsland.tools.annotate')),
        isSemantics(label: 'Anotar à mão', isButton: true, hasTapAction: true),
      );
      for (final (t, nome) in const [
        (ReaderTool.font, 'Fonte'),
        (ReaderTool.theme, 'Tema'),
        (ReaderTool.toc, 'Sumário'),
      ]) {
        expect(
          tester.getSemantics(_key('r20.bottomIsland.tools.${t.name}')),
          isSemantics(label: nome, isButton: true, hasTapAction: true),
        );
      }
      expect(find.bySemanticsLabel('Controles de leitura'), findsOneWidget);
      h.dispose();
    },
  );

  testWidgets('PDF (D-122): Fonte cinza, sem ação e "indisponível"', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    await montar(tester, isPdf: true);
    await tester.tap(_key('r20.bottomIsland.tools.font'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(eventos, isEmpty);
    expect(
      tester.getSemantics(_key('r20.bottomIsland.tools.font')),
      isSemantics(
        label: 'Fonte',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        hasTapAction: false,
      ),
    );
    final cinza = ReaderChromePalette.of(ReaderPaper.creme).disabled;
    expect(cinza, const Color(0xFFA89D8B));
    expect(
      tester
          .widget<NeoBox>(_key('r20.bottomIsland.tools.font.circle'))
          .border!
          .color,
      cinza,
    );
    for (final t in tester.widgetList<AppText>(
      find.descendant(
        of: _key('r20.bottomIsland.tools.font'),
        matching: find.byType(AppText),
      ),
    )) {
      expect(t.span.style!.color, cinza);
    }
    // as outras continuam
    await tester.tap(_key('r20.bottomIsland.tools.theme'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(eventos, [ReaderTool.theme]);
    h.dispose();
  });

  testWidgets('fim do livro: sem tempo restante', (tester) async {
    await montar(tester, timeLeft: null);
    expect(_key('r20.bottomIsland.progressRow.timeLeft'), findsNothing);
    expect(_key('r20.bottomIsland.progressRow.position'), findsOneWidget);
  });

  testWidgets(
    'Noite (26b): lua no Tema, ícones _noite e as cores da ilha do Noite',
    (tester) async {
      await montar(tester, papel: ReaderPaper.noite);
      String icone(String t) =>
          tester.widget<AppSvg>(_key('r20.bottomIsland.tools.$t.icon')).asset;
      expect(icone('theme'), AppIconsLeitor.moon);
      expect(icone('notes'), AppIconsLeitor.highlighterNight);
      expect(icone('annotate'), AppIconsLeitor.annotateNight);
      expect(icone('toc'), AppIconsLeitor.tocNight);
      final ilha = tester.widget<NeoBox>(_key('r20.bottomIsland'));
      expect(
        (ilha.color, ilha.border!.color, ilha.shadowColor),
        (AppColors.islandNight, AppColors.inkNight, AppColors.shadowNight),
      );
      final caixa = tester.widget<NeoBox>(
        _key('r20.bottomIsland.tools.toc.circle'),
      );
      expect(
        (caixa.color, caixa.border!.color),
        (AppColors.paperNight, AppColors.inkNight),
      );
      // o contador é o mesmo nos dois temas
      final badge = tester.widget<NeoBox>(
        find.descendant(
          of: _key('r20.bottomIsland.tools.notes.badge'),
          matching: find.byType(NeoBox),
        ),
      );
      expect(
        (badge.color, badge.border!.color),
        (AppColors.sun, AppColors.ink),
      );
      final tracejado =
          tester.widget<CustomPaint>(_key('r20.bottomIsland.tools')).painter!
              as ChromiumDashPainter;
      expect(tracejado.color, AppColors.dashNight);
    },
  );

  test('tracejado do Chromium: traço 3 e vão 1,5 em 327 (73 traços, das duas pontas) — o da prancha @3x', () {
    final tela = _Tela();
    const ChromiumDashPainter(
      axis: Axis.horizontal,
      color: AppColors.ink,
    ).paint(tela, const Size(327, 1.5));
    expect(tela.rects, hasLength(73));
    expect(tela.rects.first, const Rect.fromLTWH(0, 0, 3, 1.5));
    expect(tela.rects[1].left, moreOrLessEquals(4.5, epsilon: 1e-9));
    expect(tela.rects.last.right, moreOrLessEquals(327, epsilon: 1e-9));
  });
}

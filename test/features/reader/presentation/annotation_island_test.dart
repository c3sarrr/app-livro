// G16.6 — a ilha do modo anotação (L22d): os 24 ids nos lugares da prancha; os rótulos (o ativo em pílula `brand`,
// Figtree 10/800; os outros Figtree 10/700 `#6F665B`) fora do leitor de tela e o ativo que muda com a ferramenta; o
// separador tracejado; o poço de cor (anel cônico com o miolo na cor da tinta e o aro claro) com o nome da cor; a
// espessura (`radiogroup`, a ativa em `brand`); Desfazer e Refazer (desabilitados a 0,38 e "indisponível"); o Noite
// (D-167 17) e os toques.
import 'package:app_leitura/core/design_system/painters/chromium_dash.dart';
import 'package:app_leitura/core/design_system/painters/conic_ring_painter.dart';
import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/tokens/app_shadows.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart'
    show FillHeight;
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart'
    show AnnotationTool;
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/presentation/annotation_island.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../reference/leitor/reference_layout_22_modo_anotacao.dart';
import '../../../support/load_fonts.dart';
import '../../../support/pecas_l22.dart';

const _brand = Color(0xFFB6ACE4);

void main() {
  setUpAll(loadAppFonts);

  test('R8 (G20): o anúncio da ferramenta e da cor; a Borracha, o Laço e o Espaço só com o nome', () {
    String a(AnnotationTool t, int c) =>
        AnnotationIsland.toolAnnouncement(t, Color(c));
    expect(a(AnnotationTool.marker, 0xFFFED170), 'Marca-texto, amarelo');
    expect(a(AnnotationTool.marker, 0xFFABCF82), 'Marca-texto, verde');
    expect(a(AnnotationTool.pen, 0xFFFF552E), 'Caneta, coral');
    expect(a(AnnotationTool.pen, 0xFF1A1714), 'Caneta, tinta preta');
    expect(
      a(AnnotationTool.pen, 0xFFFED170),
      'Caneta, #FED170',
      reason: 'na caneta, o amarelo do marca-texto é o código',
    );
    expect(a(AnnotationTool.line, 0xFF058CD7), 'Reta, azul');
    expect(a(AnnotationTool.eraser, 0xFFFF552E), 'Borracha');
    expect(a(AnnotationTool.lasso, 0xFFFF552E), 'Laço');
    expect(a(AnnotationTool.space, 0xFFFF552E), 'Espaço');
  });

  Future<List<String>> montar(
    WidgetTester tester, {
    AnnotationTool tool = AnnotationTool.pen,
    Color tinta = AppColors.flame,
    StrokeSize espessura = StrokeSize.medium,
    bool desfazer = true,
    bool refazer = false,
    ReaderPaper papel = ReaderPaper.creme,
    FillHeight? altura,
    bool alturaVale = true,
  }) async {
    final toques = <String>[];
    await montarPecasL22(
      tester,
      [
        Positioned(
          left: 14,
          right: 14,
          top: 724,
          child: AnnotationIsland(
            tool: tool,
            ink: tinta,
            strokeSize: espessura,
            canUndo: desfazer,
            canRedo: refazer,
            onColorWell: () => toques.add('poço'),
            onStrokeSize: (s) => toques.add('espessura ${s.name}'),
            onUndo: () => toques.add('desfazer'),
            onRedo: () => toques.add('refazer'),
            inkTool: tool == AnnotationTool.marker
                ? AnnotationTool.marker
                : AnnotationTool.pen,
            height: altura,
            heightEnabled: alturaVale,
            onHeight: (a) => toques.add('altura ${a.name}'),
          ),
        ),
      ],
      papel: papel,
      brand: _brand,
    );
    return toques;
  }

  NeoBox caixa(WidgetTester tester, String id) => tester.widget<NeoBox>(
    find
        .descendant(
          of: chaveL22(id),
          matching: find.byType(NeoBox),
          matchRoot: true,
        )
        .first,
  );

  testWidgets('L22d — geometria: os 24 ids da ilha', (tester) async {
    await montar(tester);
    final ids = kRef22.idsOfSection('ann.island').toList();
    expect(ids, hasLength(24));
    conferirGeometriaL22(tester, ids);
  });

  testWidgets('L22d — texto: os 6 rótulos nas baselines da prancha', (
    tester,
  ) async {
    await montar(tester);
    for (final id in const [
      'ann.island.labels.pen.pill',
      'ann.island.labels.marker',
      'ann.island.labels.eraser',
      'ann.island.labels.lasso',
      'ann.island.labels.line',
      'ann.island.labels.space',
    ]) {
      conferirLinhasL22(tester, id);
    }
  });

  testWidgets(
    'L22d — estilo: a ilha, o rótulo ativo, o tracejado, a espessura e os botões',
    (tester) async {
      await montar(tester);
      final ilha = caixa(tester, 'ann.island');
      expect(ilha.color, AppColors.surface);
      expect(ilha.border, const BorderSide(width: 1.5, color: AppColors.ink));
      expect(ilha.radius, BorderRadius.circular(26));
      expect(
        (ilha.shadow, ilha.shadowColor),
        (AppShadows.hard3, AppColors.ink),
      );
      final pilula = caixa(tester, 'ann.island.labels.pen.pill');
      expect((pilula.color, pilula.border?.width), (_brand, 1.5));
      AppText rotulo(String id) => tester.widget<AppText>(
        find.descendant(of: chaveL22(id), matching: find.byType(AppText)),
      );
      expect(
        rotulo('ann.island.labels.pen.pill').span.style!.fontWeight,
        FontWeight.w800,
      );
      final outro = rotulo('ann.island.labels.eraser').span.style!;
      expect(
        (outro.fontWeight, outro.color),
        (FontWeight.w700, AppColors.labelReader),
      );
      final tracejado = tester.widget<CustomPaint>(chaveL22('ann.island.row'));
      expect(
        (tracejado.painter! as ChromiumDashPainter).color,
        AppColors.dashReader,
      );
      final anel =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: chaveL22('ann.island.colorWell'),
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .painter!
              as ConicRingPainter;
      expect(
        (anel.center, anel.centerRadius, anel.halo),
        (AppColors.flame, 13.5, (color: AppColors.surface, width: 2.5)),
      );
      final espessura = caixa(tester, 'ann.island.width');
      expect(
        (espessura.color, espessura.border?.width),
        (AppColors.paper, 1.5),
      );
      expect(caixa(tester, 'ann.island.width.medium').color, _brand);
      expect(caixa(tester, 'ann.island.width.thin').color, isNull);
      final desfazer = caixa(tester, 'ann.island.undo');
      expect(
        (desfazer.color, desfazer.border?.color),
        (AppColors.paper, AppColors.ink),
      );
      // Refazer vazio: o botão inteiro a 0,38
      final refazer = caixa(tester, 'ann.island.redo');
      expect(refazer.color!.a, closeTo(0.38, 0.005));
      expect(refazer.border!.color.a, closeTo(0.38, 0.005));
      expect(
        tester.widget<AppSvg>(chaveL22('ann.island.redo.icon')).opacity,
        0.38,
      );
      expect(
        tester.widget<AppSvg>(chaveL22('ann.island.undo.icon')).opacity,
        isNull,
      );
      expect(
        tester.widget<AppSvg>(chaveL22('ann.island.undo.icon')).asset,
        AppIconsLeitor.undo,
      );
    },
  );

  testWidgets(
    'o rótulo ativo e a espessura acompanham a ferramenta e o preset',
    (tester) async {
      await montar(
        tester,
        tool: AnnotationTool.eraser,
        espessura: StrokeSize.thick,
      );
      expect(chaveL22('ann.island.labels.pen.pill'), findsNothing);
      expect(chaveL22('ann.island.labels.eraser.pill'), findsOneWidget);
      expect(
        tester.getRect(chaveL22('ann.island.labels.eraser.pill')).center.dx,
        closeTo(
          kRef22.elements['ann.island.labels.eraser']!.rect.center.dx,
          0.5,
        ),
      );
      expect(caixa(tester, 'ann.island.width.thick').color, _brand);
      expect(caixa(tester, 'ann.island.width.medium').color, isNull);
      // "Borracha" na pílula passa dos 52 do lugar dela e fica inteira, centrada (como no HTML, que transborda)
      final pilula = tester.getRect(chaveL22('ann.island.labels.eraser.pill'));
      expect(pilula.width, greaterThan(52));
      final texto = tester
          .renderObject<RenderAppText>(
            find.descendant(
              of: chaveL22('ann.island.labels.eraser.pill'),
              matching: find.byType(AppText),
            ),
          )
          .debugLines()
          .single;
      expect(texto.text, 'Borracha');
      expect(pilula.width, closeTo(texto.right - texto.left + 2 * 7 + 3, 0.5));
    },
  );

  testWidgets(
    'Noite (D-167 17): a ilha #2A2520 com borda #EDE3D1 e sombra #0B0A08; rótulos e ícones claros',
    (tester) async {
      await montar(tester, papel: ReaderPaper.noite, refazer: true);
      final ilha = caixa(tester, 'ann.island');
      expect(
        (ilha.color, ilha.border?.color, ilha.shadowColor),
        (AppColors.islandNight, AppColors.inkNight, AppColors.shadowNight),
      );
      final outro = tester
          .widget<AppText>(
            find.descendant(
              of: chaveL22('ann.island.labels.eraser'),
              matching: find.byType(AppText),
            ),
          )
          .span
          .style!;
      expect(outro.color, AppColors.mutedNight);
      expect(
        tester.widget<AppSvg>(chaveL22('ann.island.undo.icon')).color,
        AppColors.inkNight,
      );
      conferirGeometriaL22(tester, kRef22.idsOfSection('ann.island'));
    },
  );

  testWidgets(
    'semântica: "Barra de anotação"; rótulos de cima fora; o poço com o nome da cor; espessura; desfazer',
    (tester) async {
      final toques = await montar(tester);
      final h = tester.ensureSemantics();
      expect(
        tester.getSemantics(chaveL22('ann.island')),
        isSemantics(label: 'Barra de anotação'),
      );
      expect(find.bySemanticsLabel('Caneta'), findsNothing);
      expect(find.bySemanticsLabel('Marcador'), findsNothing);
      expect(
        tester.getSemantics(chaveL22('ann.island.colorWell')),
        isSemantics(
          label: 'Cor da caneta: coral. Toque para escolher qualquer cor',
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(chaveL22('ann.island.width')),
        isSemantics(label: 'Espessura do traço'),
      );
      for (final (id, rotulo, marcada) in const [
        ('thin', 'Fina', false),
        ('medium', 'Média', true),
        ('thick', 'Grossa', false),
      ]) {
        expect(
          tester.getSemantics(chaveL22('ann.island.width.$id')),
          isSemantics(
            label: rotulo,
            hasCheckedState: true,
            isChecked: marcada,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
          ),
        );
      }
      expect(
        tester.getSemantics(chaveL22('ann.island.redo')),
        isSemantics(
          label: 'Refazer',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      await tester.tap(chaveL22('ann.island.colorWell'));
      await tester.tap(chaveL22('ann.island.width.thick'));
      await tester.tap(chaveL22('ann.island.undo'));
      await tester.tap(chaveL22('ann.island.redo'), warnIfMissed: false);
      expect(toques, ['poço', 'espessura thick', 'desfazer']);
      h.dispose();
    },
  );

  test('o nome da cor do poço: as 6 da tela 23; outra = o código', () {
    expect(
      [
        for (final c in const [
          Color(0xFFFF552E),
          Color(0xFF552CB7),
          Color(0xFF058CD7),
          Color(0xFF00995E),
          Color(0xFFF2A815),
          Color(0xFF1A1714),
          Color(0xFF12AB34),
        ])
          AnnotationIsland.colorName(c),
      ],
      ['coral', 'roxo', 'azul', 'verde', 'dourado', 'tinta preta', '#12AB34'],
    );
  });

  testWidgets(
    'R18: com o Marca-texto, o poço e os pontos amarelos; os pontos são Baixa/Média/Alta',
    (tester) async {
      final toques = await montar(
        tester,
        tool: AnnotationTool.marker,
        tinta: AppColors.sun,
        altura: FillHeight.medium,
      );
      final h = tester.ensureSemantics();
      expect(
        tester.getSemantics(chaveL22('ann.island.colorWell')),
        isSemantics(
          label:
              'Cor do marca-texto: amarelo. Toque para ajustar o marca-texto',
          isButton: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(chaveL22('ann.island.width')),
        isSemantics(label: 'Altura do fundo'),
      );
      for (final (id, rotulo, marcada) in const [
        ('thin', 'Baixa', false),
        ('medium', 'Média', true),
        ('thick', 'Alta', false),
      ]) {
        expect(
          tester.getSemantics(chaveL22('ann.island.width.$id')),
          isSemantics(
            label: rotulo,
            hasCheckedState: true,
            isChecked: marcada,
            isInMutuallyExclusiveGroup: true,
            hasTapAction: true,
          ),
        );
      }
      await tester.tap(chaveL22('ann.island.width.thick'));
      expect(toques, ['altura high']);
      final ponto = tester.widget<DecoratedBox>(
        find.descendant(
          of: chaveL22('ann.island.width.medium.dot'),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((ponto.decoration as BoxDecoration).color, AppColors.sun);
      h.dispose();
    },
  );

  testWidgets(
    'R18: com Sublinhado ou Ondulado, os pontos ficam a 0,38 e indisponíveis',
    (tester) async {
      final toques = await montar(
        tester,
        tool: AnnotationTool.marker,
        tinta: AppColors.sun,
        altura: FillHeight.medium,
        alturaVale: false,
      );
      final h = tester.ensureSemantics();
      expect(
        tester.getSemantics(chaveL22('ann.island.width.thick')),
        isSemantics(
          label: 'Alta',
          hasCheckedState: true,
          isInMutuallyExclusiveGroup: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      await tester.tap(chaveL22('ann.island.width.thick'), warnIfMissed: false);
      expect(toques, isEmpty);
      final ponto = tester.widget<DecoratedBox>(
        find.descendant(
          of: chaveL22('ann.island.width.medium.dot'),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((ponto.decoration as BoxDecoration).color!.a, closeTo(0.38, 0.01));
      h.dispose();
    },
  );

  test('o nome da cor do poço também para as cores do marca-texto', () {
    expect(AnnotationIsland.colorName(AppColors.sun), 'amarelo');
    expect(AnnotationIsland.colorName(AppColors.blush), 'rosa');
    // na caneta, só os 6 nomes da tela 23 (R8)
    expect(AnnotationIsland.colorName(AppColors.sun, pen: true), '#FED170');
    expect(AnnotationIsland.colorName(AppColors.flame, pen: true), 'coral');
  });

  testWidgets(
    'o poço da caneta com o amarelo do marca-texto: o código, não "amarelo" (R8)',
    (tester) async {
      await montar(tester, tinta: AppColors.sun);
      final h = tester.ensureSemantics();
      expect(
        tester.getSemantics(chaveL22('ann.island.colorWell')),
        isSemantics(
          label: 'Cor da caneta: #FED170. Toque para escolher qualquer cor',
          isButton: true,
          hasTapAction: true,
        ),
      );
      h.dispose();
    },
  );
}

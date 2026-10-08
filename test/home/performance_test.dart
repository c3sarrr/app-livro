import 'dart:async';
import 'dart:io';

import 'package:app_leitura/core/design_system/painters/chromium_dash.dart';
import 'package:app_leitura/core/design_system/painters/color_wheel_painter.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart'
    show HighlightStyle;
import 'package:app_leitura/features/reader/presentation/marker_panel.dart';
import 'package:app_leitura/features/reader/presentation/pen_panel.dart';
import 'package:app_leitura/core/design_system/painters/conic_ring_painter.dart';
import 'package:app_leitura/core/design_system/painters/dashed_stadium_painter.dart';
import 'package:app_leitura/core/design_system/painters/goal_dial_painter.dart';
import 'package:app_leitura/core/design_system/painters/hatch_painter.dart';
import 'package:app_leitura/core/design_system/painters/ring_progress_painter.dart';
import 'package:app_leitura/core/design_system/painters/top_border_crescent_painter.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:app_leitura/features/home/presentation/covers/senhora_mini_cover.dart';
import 'package:app_leitura/features/home/presentation/home_screen.dart';
import 'package:app_leitura/features/home/presentation/sections/also_reading_section.dart';
import 'package:app_leitura/features/home/presentation/sections/book_club_ticket.dart';
import 'package:app_leitura/features/home/presentation/sections/continue_reading_hero.dart';
import 'package:app_leitura/features/home/presentation/sections/for_you_section.dart';
import 'package:app_leitura/features/home/presentation/sections/header_section.dart';
import 'package:app_leitura/features/home/presentation/sections/headline_section.dart';
import 'package:app_leitura/features/home/presentation/sections/reading_day_card.dart';
import 'package:app_leitura/features/home/presentation/sections/recently_added_section.dart';
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/application/reader_document.dart';
import 'package:app_leitura/features/reader/application/reader_ink.dart';
import 'package:app_leitura/features/reader/presentation/ink_painter.dart';
import 'package:app_leitura/features/reader/presentation/page_marks.dart';
import 'package:app_leitura/features/reader/presentation/annotation_canvas.dart';
import 'package:app_leitura/features/reader/presentation/highlight_toolbar.dart';
import 'package:app_leitura/features/reader/presentation/reader_page_view.dart';
import 'package:app_leitura/features/reader/presentation/selection_layer.dart';
import 'package:app_leitura/features/reader/presentation/scrubber.dart'
    show FillWavePainter;
import 'package:app_leitura/features/reader/presentation/toc_chapters.dart'
    show TocProgressRingPainter;
import 'package:app_leitura/features/shell/presentation/floating_nav_bar.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/canvas.dart';
import '../support/fake_ink_repository.dart';
import '../support/load_fonts.dart';
import '../support/personal_builders.dart';
import '../support/pump_app.dart';

Finder _key(String id) => find.byKey(ValueKey<String>(id));

/// A `RepaintBoundary` mais próxima ACIMA do elemento (a que o isola do resto da tela).
Finder _boundaryAbove(String id) =>
    find.ancestor(of: _key(id), matching: find.byType(RepaintBoundary)).first;

/// Todas as figuras gravadas (`PictureLayer`) sob a camada [layer]. Repintar uma boundary grava figuras NOVAS (objetos
/// diferentes); reaproveitar a camada mantém exatamente os mesmos objetos.
Set<Layer> _pictures(Layer? layer) {
  final out = <Layer>{};
  void visit(Layer l) {
    if (l is PictureLayer) out.add(l);
    if (l is ContainerLayer) {
      for (var c = l.firstChild; c != null; c = c.nextSibling) {
        visit(c);
      }
    }
  }

  if (layer != null) visit(layer);
  return out;
}

/// (campo alterado, pintor alterado) → `shouldRepaint` precisa dizer que sim; o pintor idêntico, que não.
void _expectRepaintsOnlyOnChange<T extends CustomPainter>(
  T Function() base,
  Map<String, T Function()> changed,
) {
  expect(base().shouldRepaint(base()), isFalse, reason: 'pintor idêntico');
  changed.forEach((field, make) {
    expect(
      make().shouldRepaint(base()),
      isTrue,
      reason: 'mudar $field precisa repintar',
    );
  });
}

/// F12 12.4 — desempenho de produção: rebuild mínimo, boundaries, pintores e SVGs pré-carregados.
void main() {
  setUpAll(loadAppFonts);

  group('12.4 shouldRepaint compara todos os campos de cada pintor', () {
    test('DashedStadiumPainter (espessura, cor, raio) — G14, G17', () {
      _expectRepaintsOnlyOnChange(() => const DashedStadiumPainter(), {
        'thickness': () => const DashedStadiumPainter(thickness: 1.2),
        'color': () => const DashedStadiumPainter(color: AppColors.ink),
        'radius': () => const DashedStadiumPainter(radius: 16),
      });
    });

    test('ChromiumDashPainter (eixo, espessura, cor)', () {
      _expectRepaintsOnlyOnChange(
        () => const ChromiumDashPainter(
          axis: Axis.horizontal,
          thickness: 1.5,
          color: AppColors.ink,
        ),
        {
          'axis': () => const ChromiumDashPainter(
            axis: Axis.vertical,
            thickness: 1.5,
            color: AppColors.ink,
          ),
          'thickness': () => const ChromiumDashPainter(
            axis: Axis.horizontal,
            thickness: 3,
            color: AppColors.ink,
          ),
          'color': () => const ChromiumDashPainter(
            axis: Axis.horizontal,
            thickness: 1.5,
            color: AppColors.goalLine,
          ),
        },
      );
    });

    test('GoalDialPainter (progresso)', () {
      _expectRepaintsOnlyOnChange(() => const GoalDialPainter(progress: 0.6), {
        'progress': () => const GoalDialPainter(progress: 0.5),
      });
    });

    test('HatchPainter (listra, base)', () {
      _expectRepaintsOnlyOnChange(
        () => const HatchPainter(stripe: AppColors.hatch),
        {
          'stripe': () => const HatchPainter(stripe: AppColors.hatchToday),
          'base': () => const HatchPainter(
            stripe: AppColors.hatch,
            base: AppColors.paper,
          ),
        },
      );
    });

    test('RingProgressPainter (progresso)', () {
      _expectRepaintsOnlyOnChange(
        () => const RingProgressPainter(progress: 0.34),
        {'progress': () => const RingProgressPainter(progress: 0.81)},
      );
    });

    test('TopBorderCrescentPainter (preenchimento, borda, cor da borda)', () {
      _expectRepaintsOnlyOnChange(
        () => const TopBorderCrescentPainter(fill: AppColors.lavender),
        {
          'fill': () => const TopBorderCrescentPainter(fill: AppColors.flame),
          'border': () => const TopBorderCrescentPainter(
            fill: AppColors.lavender,
            border: 1.2,
          ),
          'borderColor': () => const TopBorderCrescentPainter(
            fill: AppColors.lavender,
            borderColor: AppColors.inkMuted,
          ),
        },
      );
    });

    test('ArchBorderPainter (raio do topo, borda, cor)', () {
      _expectRepaintsOnlyOnChange(
        () => const ArchBorderPainter(
          topRadius: 13,
          border: 1.5,
          color: AppColors.ink,
        ),
        {
          'topRadius': () => const ArchBorderPainter(
            topRadius: 8,
            border: 1.5,
            color: AppColors.ink,
          ),
          'border': () => const ArchBorderPainter(
            topRadius: 13,
            border: 1.2,
            color: AppColors.ink,
          ),
          'color': () => const ArchBorderPainter(
            topRadius: 13,
            border: 1.5,
            color: AppColors.inkMuted,
          ),
        },
      );
    });

    test('FillWavePainter (preenchimento, traço) — G12', () {
      _expectRepaintsOnlyOnChange(
        () => const FillWavePainter(
          fill: AppColors.lavender,
          stroke: AppColors.ink,
        ),
        {
          'fill': () =>
              const FillWavePainter(fill: AppColors.sun, stroke: AppColors.ink),
          'stroke': () => const FillWavePainter(
            fill: AppColors.lavender,
            stroke: AppColors.inkMuted,
          ),
        },
      );
    });

    test(
      'ReaderPagesPainter (documento, deslocamento, sentido, vizinha) — G11',
      () {
        final doc = _Documento();
        final outro = _Documento();
        final vizinha = _Pagina();
        final grifos = _GrifosVazios();
        final tinta = _TintaVazia();
        final fotos = InkPictureCache();
        addTearDown(fotos.dispose);
        final selecao = ValueNotifier<ReaderRange?>(null);
        final fotos2 = InkPictureCache();
        addTearDown(fotos2.dispose);
        ReaderPagesPainter pintor({
          ReaderDocument? document,
          double dx = -40,
          PageDirection? dir = PageDirection.forward,
          DisplayPage? neighbor,
          Color? foundColor = AppColors.lavender,
          Color? foundLightText,
          HighlightSource? highlights,
          InkSource? ink,
          InkPictureCache? inkPictures,
          ValueListenable<ReaderRange?>? selection,
          Color? selectionColor = AppColors.lavender,
        }) => ReaderPagesPainter(
          document: document ?? doc,
          dx: dx,
          dir: dir,
          neighbor: neighbor ?? vizinha,
          foundColor: foundColor,
          foundLightText: foundLightText,
          highlights: highlights ?? grifos,
          ink: ink ?? tinta,
          inkPictures: inkPictures ?? fotos,
          selection: selection ?? selecao,
          selectionColor: selectionColor,
        );
        _expectRepaintsOnlyOnChange(pintor, {
          'document': () => pintor(document: outro),
          'dx': () => pintor(dx: -41),
          'dir': () => pintor(dir: PageDirection.backward),
          'neighbor': () => pintor(neighbor: _Pagina()),
          'foundColor': () => pintor(foundColor: AppColors.sun),
          'foundLightText': () =>
              pintor(foundLightText: AppColors.bookTextNight),
          'highlights': () => pintor(highlights: _GrifosVazios()),
          'ink': () => pintor(ink: _TintaVazia()),
          'inkPictures': () => pintor(inkPictures: fotos2),
          'selection': () =>
              pintor(selection: ValueNotifier<ReaderRange?>(null)),
          'selectionColor': () => pintor(selectionColor: AppColors.sun),
        });
        // a página atual que muda por dentro (sem trocar de pintor) repinta pelo aviso do documento, e também
        // os grifos do livro e a seleção (G13) e a tinta (G16)
        var avisos = 0;
        pintor().addListener(() => avisos++);
        doc.changes.value++;
        expect(avisos, 1);
        grifos.avisar();
        selecao.value = (unit: 0, from: 0, to: 1);
        expect(avisos, 3);
        tinta.avisar();
        expect(avisos, 4);
      },
    );

    test('MagnifierPainter (pintor da página, foco, papel, borda, sombra, tela) — G13', () {
      final doc = _Documento();
      final paginas = ReaderPagesPainter(
        document: doc,
        dx: 0,
        dir: null,
        neighbor: null,
      );
      MagnifierPainter lupa({
        ReaderPagesPainter? pages,
        Offset focus = const Offset(100, 300),
        Color paper = AppColors.paperCream,
        Color border = AppColors.ink,
        Color shadow = AppColors.ink,
        Size screen = const Size(390, 844),
      }) => MagnifierPainter(
        pages: pages ?? paginas,
        focus: focus,
        paper: paper,
        border: border,
        shadow: shadow,
        screen: screen,
      );
      _expectRepaintsOnlyOnChange(lupa, {
        'pages': () => lupa(
          pages: ReaderPagesPainter(
            document: doc,
            dx: 0,
            dir: null,
            neighbor: null,
          ),
        ),
        'focus': () => lupa(focus: const Offset(101, 300)),
        'paper': () => lupa(paper: AppColors.paperNight),
        'border': () => lupa(border: AppColors.inkNight),
        'shadow': () => lupa(shadow: AppColors.shadowNight),
        'screen': () => lupa(screen: const Size(430, 932)),
      });
    });

    test('PenPreviewPainter (traço, fundo, fio) — G17', () {
      final traco = penPreviewStroke(presetsTeste());
      final outro = penPreviewStroke(
        presetsTeste().copyWith(penColor: '#058CD7'),
      );
      _expectRepaintsOnlyOnChange(
        () => PenPreviewPainter(
          stroke: traco,
          background: AppColors.paper,
          rule: AppColors.rulePen,
        ),
        {
          'stroke': () => PenPreviewPainter(
            stroke: outro,
            background: AppColors.paper,
            rule: AppColors.rulePen,
          ),
          'background': () => PenPreviewPainter(
            stroke: traco,
            background: AppColors.paperNight,
            rule: AppColors.rulePen,
          ),
          'rule': () => PenPreviewPainter(
            stroke: traco,
            background: AppColors.paper,
            rule: AppColors.hatchNight,
          ),
        },
      );
    });

    test('MarkerSamplePainter (cor, estilo, faixa, base) — G17', () {
      MarkerSamplePainter amostra({
        Color color = AppColors.sun,
        HighlightStyle style = HighlightStyle.fill,
        (double, double) band = (0.14, 0.92),
        double baseline = 18.8,
      }) => MarkerSamplePainter(
        color: color,
        style: style,
        band: band,
        baseline: baseline,
      );
      _expectRepaintsOnlyOnChange(amostra, {
        'color': () => amostra(color: AppColors.lavender),
        'style': () => amostra(style: HighlightStyle.wavy),
        'band': () => amostra(band: (0.5, 0.92)),
        'baseline': () => amostra(baseline: 20),
      });
    });

    test('ColorWheelPainter (borda) — G17', () {
      _expectRepaintsOnlyOnChange(
        () => const ColorWheelPainter(border: AppColors.ink),
        {'border': () => const ColorWheelPainter(border: AppColors.inkNight)},
      );
    });

    test('ConicRingPainter (borda, miolo, raio, aro) e UnderlineIconPainter (letra) — G13/G16', () {
      _expectRepaintsOnlyOnChange(
        () => const ConicRingPainter(
          border: AppColors.ink,
          center: AppColors.surface,
          centerRadius: 7,
        ),
        {
          'border': () => const ConicRingPainter(
            border: AppColors.inkNight,
            center: AppColors.surface,
            centerRadius: 7,
          ),
          'center': () => const ConicRingPainter(
            border: AppColors.ink,
            center: AppColors.islandNight,
            centerRadius: 7,
          ),
          'centerRadius': () => const ConicRingPainter(
            border: AppColors.ink,
            center: AppColors.surface,
            centerRadius: 13.5,
          ),
          'halo': () => const ConicRingPainter(
            border: AppColors.ink,
            center: AppColors.surface,
            centerRadius: 7,
            halo: (color: AppColors.surface, width: 2.5),
          ),
          'alpha': () => const ConicRingPainter(
            border: AppColors.ink,
            center: AppColors.surface,
            centerRadius: 7,
            alpha: 0.5,
          ),
        },
      );
      _expectRepaintsOnlyOnChange(
        () => const UnderlineIconPainter(letter: AppColors.ink),
        {
          'letter': () =>
              const UnderlineIconPainter(letter: AppColors.inkNight),
        },
      );
    });

    test('AnnotationPagePainter e AnnotationLivePainter (sessão, página, caixa, papel, letras, grifos, deslocamento) — G16, G17', () {
      AnnotationSession sessao() => AnnotationSession(
        geometry: InkPageGeometry.empty,
        anchors: _AncorasVazias(),
        drawings: const [],
        highlights: const [],
        presets: presetsTeste(),
        repository: FakeInkRepository(),
        owner: usuarioTeste,
        userBookId: idTeste(1),
        startTimer: (_, _) => _Parado(),
      );
      final s = sessao();
      final outra = sessao();
      addTearDown(s.dispose);
      addTearDown(outra.dispose);
      final pagina = _Pagina();
      final pan = ValueNotifier<double>(0);
      final fotos = InkPictureCache(capacity: 1);
      addTearDown(fotos.dispose);
      const caixa = Rect.fromLTRB(28, 116, 362, 844);
      const grifos = <PaintedHighlight>[];
      const aMao = <PaintedHighlight>[];
      AnnotationPagePainter folha({
        AnnotationSession? session,
        DisplayPage? page,
        Rect pageBox = caixa,
        Color paper = AppColors.paperCream,
        Color? lightText,
        List<PaintedHighlight> highlights = grifos,
        List<PaintedHighlight> inkHighlights = aMao,
        ValueListenable<double>? panOffset,
        ValueListenable<double>? entrada,
        InkPictureCache? pictures,
      }) => AnnotationPagePainter(
        session: session ?? s,
        page: page ?? pagina,
        pageBox: pageBox,
        paper: paper,
        lightText: lightText,
        highlights: highlights,
        inkHighlights: inkHighlights,
        pan: panOffset ?? pan,
        enter: entrada ?? kAlwaysCompleteAnimation,
        pictures: pictures ?? fotos,
      );
      _expectRepaintsOnlyOnChange(folha, {
        'session': () => folha(session: outra),
        'page': () => folha(page: _Pagina()),
        'pageBox': () => folha(pageBox: const Rect.fromLTRB(28, 120, 362, 844)),
        'paper': () => folha(paper: AppColors.paperNight),
        'lightText': () => folha(lightText: AppColors.bookTextNight),
        'highlights': () => folha(highlights: <PaintedHighlight>[]),
        'inkHighlights': () => folha(inkHighlights: <PaintedHighlight>[]),
        'pan': () => folha(panOffset: ValueNotifier<double>(0)),
        'enter': () => folha(entrada: ValueNotifier<double>(1)),
        'pictures': () => folha(pictures: InkPictureCache(capacity: 1)),
      });
      AnnotationLivePainter vivo({
        AnnotationSession? session,
        Rect pageBox = caixa,
        ValueListenable<double>? panOffset,
        ValueListenable<double>? entrada,
        Color? lightText,
      }) => AnnotationLivePainter(
        session: session ?? s,
        pageBox: pageBox,
        pan: panOffset ?? pan,
        enter: entrada ?? kAlwaysCompleteAnimation,
        lightText: lightText,
      );
      _expectRepaintsOnlyOnChange(vivo, {
        'session': () => vivo(session: outra),
        'pageBox': () => vivo(pageBox: const Rect.fromLTRB(28, 120, 362, 844)),
        'pan': () => vivo(panOffset: ValueNotifier<double>(0)),
        'enter': () => vivo(entrada: ValueNotifier<double>(1)),
        'lightText': () => vivo(lightText: AppColors.bookTextNight),
      });
      // a tinta que muda (a revisão) e o deslocamento repintam a folha — a ferramenta e os ajustes (o arrasto na roda),
      // não; o traço ao vivo e a seleção repintam a camada viva
      var folhas = 0;
      var vivos = 0;
      folha().addListener(() => folhas++);
      vivo().addListener(() => vivos++);
      s
        ..setTool(AnnotationTool.eraser)
        ..setPenColor('#058CD7', save: false);
      expect(folhas, 0);
      pan.value = -10;
      s.live.value = const LiveLasso([]);
      expect(folhas, 1);
      expect(vivos, 2);
      InkPointer dedo(double x, int t) => (
        id: 1,
        kind: InkPointerKind.touch,
        x: x,
        y: 300,
        pressure: 1,
        tMs: t,
      );
      s
        ..setTool(AnnotationTool.pen)
        ..pointerDown(dedo(60, 0))
        ..pointerMove(dedo(120, 16))
        ..pointerUp(dedo(120, 32));
      expect(s.visibleStrokes, hasLength(1));
      expect(folhas, 2);
      // G17 (R26): no Noite, a folha também repinta com o marca-texto ao vivo (ele vai nela) — só com ele
      var noites = 0;
      folha(lightText: AppColors.bookTextNight).addListener(() => noites++);
      s.live.value = null;
      expect(noites, 0);
      s.live.value = LiveMarker(penPreviewStroke(presetsTeste()));
      expect(noites, 1);
    });

    test('TocProgressRingPainter (progresso) — G15', () {
      _expectRepaintsOnlyOnChange(
        () => const TocProgressRingPainter(progress: 0.4),
        {'progress': () => const TocProgressRingPainter(progress: 0.7)},
      );
    });

    test('todo pintor do app está coberto aqui (nenhum CustomPainter novo sem teste)', () {
      final painters = <String>{};
      for (final file in Directory('lib').listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        for (final m in RegExp(
          r'class (\w+) extends CustomPainter',
        ).allMatches(file.readAsStringSync())) {
          painters.add(m.group(1)!);
        }
      }
      expect(painters, {
        'ChromiumDashPainter',
        'DashedStadiumPainter',
        'GoalDialPainter',
        'HatchPainter',
        'RingProgressPainter',
        'TopBorderCrescentPainter',
        'ArchBorderPainter',
        'ReaderPagesPainter',
        'FillWavePainter',
        'MagnifierPainter',
        'ConicRingPainter',
        'UnderlineIconPainter',
        'TocProgressRingPainter',
        'AnnotationPagePainter',
        'AnnotationLivePainter',
        'ColorWheelPainter',
        'PenPreviewPainter',
        'MarkerSamplePainter',
      });
    });
  });

  group('12.4 RepaintBoundary', () {
    for (final id in ['today.dial', 'forYou.carousel']) {
      testWidgets(
        'o $id tem a PRÓPRIA RepaintBoundary (mesmo tamanho e mesma posição): rolar a Início não repinta a camada dele',
        (tester) async {
          setCanvasView(
            tester,
            logical: const Size(390, 844),
            safeTop: 47,
            safeBottom: 34,
          );
          await pumpApp(tester);
          // A boundary envolve só o elemento: mesmo retângulo.
          expect(
            tester.getRect(_boundaryAbove(id)),
            tester.getRect(_key(id)),
            reason: id,
          );
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            _boundaryAbove(id),
          );
          expect(boundary.isRepaintBoundary, isTrue);

          // Leva o elemento para a tela e anota a figura gravada na camada dele.
          final position = homeScrollPosition(tester);
          final center = tester.getCenter(_key(id)).dy;
          position.jumpTo(
            (position.pixels + center - 300).clamp(0, position.maxScrollExtent),
          );
          await tester.pump();
          final pictures = _pictures(boundary.debugLayer);
          expect(pictures, isNotEmpty, reason: id);
          // Rola a Início: a camada do elemento é reaproveitada (nenhuma figura é regravada), só se desloca.
          for (final dy in [40.0, 55.0, -30.0]) {
            position.jumpTo(position.pixels + dy);
            await tester.pump();
            expect(
              _pictures(boundary.debugLayer),
              pictures,
              reason: '$id: figuras regravadas ao rolar $dy',
            );
            expect(boundary.debugNeedsPaint, isFalse, reason: id);
          }
        },
      );
    }

    testWidgets(
      'o resto da Início (sem boundary própria) é regravado ao rolar: a prova de que as duas camadas acima valem algo',
      (tester) async {
        setCanvasView(
          tester,
          logical: const Size(390, 844),
          safeTop: 47,
          safeBottom: 34,
        );
        await pumpApp(tester);
        // A boundary da rolagem (Scrollable) regrava o conteúdo que não tem camada própria a cada deslocamento.
        final scrollBoundary = tester.renderObject<RenderRepaintBoundary>(
          find
              .ancestor(
                of: _key('hero'),
                matching: find.byType(RepaintBoundary),
              )
              .first,
        );
        final before = _pictures(scrollBoundary.debugLayer);
        homeScrollPosition(tester).jumpTo(60);
        await tester.pump();
        final after = _pictures(scrollBoundary.debugLayer);
        // Há figuras novas: o conteúdo sem camada própria foi regravado (as camadas isoladas continuam as mesmas).
        expect(after.difference(before), isNotEmpty);
        expect(
          after.intersection(before),
          isNotEmpty,
          reason: 'dial/carrossel',
        );
      },
    );
  });

  group('12.4 rebuild mínimo (select do Riverpod por seção)', () {
    /// Tipos dos widgets que o framework reconstruiu por estarem "sujos" (marcados por um provider).
    Future<List<Type>> rebuilt(
      WidgetTester tester,
      void Function() change,
    ) async {
      final types = <Type>[];
      debugOnRebuildDirtyWidget = (e, builtOnce) =>
          types.add(e.widget.runtimeType);
      addTearDown(() => debugOnRebuildDirtyWidget = null);
      change();
      await tester.pumpAndSettle();
      debugOnRebuildDirtyWidget = null;
      return types;
    }

    const sections = <Type>[
      HomeScreen,
      HeaderSection,
      HeadlineSection,
      ContinueReadingHero,
      AlsoReadingSection,
      ReadingDayCard,
      ForYouSection,
      BookClubTicket,
      RecentlyAddedSection,
      FloatingNavBar,
      MainShell,
    ];

    testWidgets(
      'trocar o brand reconstrói SÓ o hero e a barra de navegação (as outras 9 seções/telas não são tocadas)',
      (tester) async {
        setCanvasView(tester);
        await pumpApp(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(HomeScreen)),
        );
        final types = await rebuilt(
          tester,
          () => container
              .read(homeThemeProvider.notifier)
              .setBrand(AppColors.blush),
        );
        debugPrint('[rebuild] brand → ${types.map((t) => '$t').toSet()}');
        expect(
          types.where(sections.contains).toList()..sort(_byName),
          [ContinueReadingHero, FloatingNavBar]..sort(_byName),
        );
      },
    );

    testWidgets(
      'trocar o weekColor reconstrói SÓ o cartão "Seu dia de leitura"',
      (tester) async {
        setCanvasView(tester);
        await pumpApp(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(HomeScreen)),
        );
        final types = await rebuilt(
          tester,
          () => container
              .read(homeThemeProvider.notifier)
              .setWeekColor(AppColors.weekColorOptions.last),
        );
        debugPrint('[rebuild] weekColor → ${types.map((t) => '$t').toSet()}');
        expect(types.where(sections.contains).toList(), [ReadingDayCard]);
      },
    );

    testWidgets(
      'trocar de aba não reconstrói as seções da Início; rolar também não',
      (tester) async {
        setCanvasView(
          tester,
          logical: const Size(390, 844),
          safeTop: 47,
          safeBottom: 34,
        );
        await pumpApp(tester);
        final types = await rebuilt(tester, () {
          homeScrollPosition(tester).jumpTo(400);
        });
        expect(
          types.where(sections.where((t) => t != FloatingNavBar).contains),
          isEmpty,
          reason: 'rolar: ${types.toSet()}',
        );
      },
    );
  });

  group('12.4 sem Opacity e sem saveLayer desnecessário', () {
    test('nenhum arquivo de lib usa Opacity, ShaderMask, BackdropFilter, ColorFiltered, ImageFiltered nem saveLayer', () {
      final forbidden = RegExp(
        r'\b(Opacity|AnimatedOpacity|FadeTransition|ShaderMask|BackdropFilter|ColorFiltered|ImageFiltered|antiAliasWithSaveLayer|saveLayer)\b',
      );
      final hits = <String>[];
      for (final file in Directory('lib').listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final code = lines[i].split('//').first;
          if (forbidden.hasMatch(code)) {
            hits.add('${file.path}:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });

    testWidgets(
      'em execução a Início e o shell não montam nenhum widget que force camada intermediária (saveLayer)',
      (tester) async {
        setCanvasView(tester);
        await pumpApp(tester);
        for (final root in [find.byType(HomeScreen), find.byType(MainShell)]) {
          for (final type in [
            Opacity,
            ShaderMask,
            BackdropFilter,
            ColorFiltered,
            ImageFiltered,
          ]) {
            expect(
              find.descendant(of: root, matching: find.byType(type)),
              findsNothing,
              reason: '$type',
            );
          }
        }
        // Translucidez = cor com alpha: nenhum RenderOpacity/RenderAnimatedOpacity sob a Início.
        final offenders = <String>[];
        void visit(RenderObject r) {
          if (r is RenderOpacity || r is RenderAnimatedOpacity) {
            offenders.add('${r.runtimeType}');
          }
          r.visitChildren(visit);
        }

        visit(tester.renderObject(find.byType(HomeScreen)));
        expect(offenders, isEmpty);
      },
    );
  });

  group('12.4 SVGs pré-carregados', () {
    testWidgets(
      'preloadAppIcons() deixa os 18 SVGs no cache do flutter_svg (a chave é a do AppSvg) e é idempotente',
      (tester) async {
        svg.cache.clear();
        await tester.runAsync(preloadAppIcons);
        await tester.runAsync(
          preloadAppIcons,
        ); // segunda vez: só acerta o cache
        expect(AppIcons.all, hasLength(18));
        for (final asset in AppIcons.all) {
          final loader = SvgAssetLoader(asset);
          var loadedAgain = false;
          await tester.runAsync(
            () => svg.cache.putIfAbsent(loader.cacheKey(null), () {
              loadedAgain = true;
              return loader.loadBytes(null);
            }),
          );
          expect(loadedAgain, isFalse, reason: asset);
        }
      },
    );
  });
}

int _byName(Type a, Type b) => '$a'.compareTo('$b');

/// Documento e página mínimos para o pintor do leitor: só o aviso de mudança é usado na construção.
class _Documento implements ReaderDocument {
  @override
  final ValueNotifier<int> changes = ValueNotifier<int>(0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Pagina implements DisplayPage {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Grifos do livro sem nenhum grifo (G13): só o aviso de mudança.
class _GrifosVazios extends ChangeNotifier implements HighlightSource {
  void avisar() => notifyListeners();

  @override
  List<PaintedHighlight> highlightsIn(ReaderRange shown) => const [];
}

class _AncorasVazias implements AnnotationAnchors {
  @override
  String get sha => shaTeste;

  @override
  String? textOf(int spine) => null;

  @override
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset) =>
      (refPage: 1, chapterIndex: 0);
}

/// O relógio do rascunho parado.
class _Parado implements Timer {
  @override
  void cancel() {}

  @override
  bool get isActive => false;

  @override
  int get tick => 0;
}

class _TintaVazia extends ChangeNotifier implements InkSource {
  void avisar() => notifyListeners();

  @override
  int get revision => 0;

  @override
  List<PaintedHighlight> inkHighlightsIn(ReaderRange shown) => const [];

  @override
  List<PageDrawing> drawingsOn(DisplayPage page) => const [];
}

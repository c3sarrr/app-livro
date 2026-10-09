// G16.6 — a camada do modo anotação: os lugares da D-167 (3) com a área segura 0, a de um iPhone (47/34, que dá os
// lugares do arquivo) e uma maior; a entrada (o texto desce 30 em 220 ms, a moldura aparece em 150 ms, os toques só
// depois) e a saída ao contrário; o Noite (D-167 17); a pílula da falha ao salvar (D-21) e o aviso da D-163 acima da
// prateleira; as ferramentas (o Espaço avisa); a semântica.
// G17: o 2º toque e o poço abrem os painéis (R1, R2), o véu só fecha (R3), a prateleira e a ilha vivas (R4), 150 ms
// (R5) e o marca-texto na cor dele (R28).
// G18: com a fonte da página, o Espaço fica ativo sem o aviso, com o subtítulo "Arraste entre as linhas" (R4); o
// abridor aparece sobre a página no arrasto (30 px abaixo, com o deslocamento); a página pintada é a da sessão (R3).
import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/annotation_page_source.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/layout/space_cut.dart';
import 'package:app_leitura/features/reader/presentation/annotation_canvas.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/hand_note.dart';
import 'package:app_leitura/features/reader/presentation/ink_latency_meter.dart';
import 'package:app_leitura/features/reader/presentation/space_opener.dart';
import 'package:app_leitura/features/reader/presentation/tool_shelf.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_ink_repository.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';

const _texto = 'Olhos de ressaca a vaga que';

/// A página do teste da privacidade: duas linhas no topo.
InkPageGeometry _geometria() => const InkPageGeometry([
  InkLine(
    unit: 4,
    from: 0,
    to: 16,
    top: 74,
    bottom: 109.25,
    baseline: 100,
    em: 20.5,
    left: 28,
    right: 190,
    words: [
      (from: 0, to: 5, left: 28, right: 83),
      (from: 6, to: 8, left: 89, right: 109),
      (from: 9, to: 16, left: 115, right: 190),
    ],
  ),
  InkLine(
    unit: 4,
    from: 17,
    to: 27,
    top: 109.25,
    bottom: 144.5,
    baseline: 135.25,
    em: 20.5,
    left: 28,
    right: 133,
    words: [
      (from: 17, to: 18, left: 28, right: 39),
      (from: 19, to: 23, left: 45, right: 92),
      (from: 24, to: 27, left: 98, right: 133),
    ],
  ),
]);

final class _Anchors implements AnnotationAnchors {
  @override
  String get sha => shaTeste;
  @override
  String? textOf(int spine) => spine == 4 ? _texto : null;
  @override
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset) =>
      (refPage: 159, chapterIndex: 31);
}

final class _Pagina implements DisplayPage, PageWithSpaces {
  _Pagina([this.spaces = const []]);

  final ty = <double>[];

  @override
  final List<PageSpace> spaces;

  @override
  void paint(ui.Canvas canvas) => ty.add(canvas.getTransform()[13]);

  @override
  bool get alive => true;
  @override
  bool get opaque => false;
  @override
  String get spokenText => '';
  @override
  LinkHit? linkAt(ui.Offset p) => null;
  @override
  List<Rect> rectsOf(int unit, int from, int to) => const [];
  @override
  ReaderRange? get shown => (unit: 4, from: 0, to: 10);
  @override
  ReaderSpot? spotAt(ui.Offset p) => null;
  @override
  ReaderRange? wordAround(ReaderSpot s) => null;
  @override
  ReaderRange? wordAt(ui.Offset p) => null;
  @override
  List<TextLineBox> boxesOf(int unit, int from, int to) => const [];
  @override
  String textOf(int unit, int from, int to) => '';
}

/// A fonte da página do modo: cada espaço vira um bloco logo abaixo da 1ª linha (109,25), da altura dele.
final class _Fonte implements AnnotationPageSource {
  final paginas = <_Pagina>[];
  var descartada = false;

  @override
  DisplayPage pageWith(List<SpaceCut> cuts) {
    final p = _Pagina([
      for (final c in cuts)
        (id: c.id, rect: Rect.fromLTWH(28, 109.25, 334, c.height)),
    ]);
    paginas.add(p);
    return p;
  }

  @override
  ({DisplayPage page, void Function() dispose})? tallPageWith(
    List<SpaceCut> cuts,
    double extra,
  ) => null;

  @override
  List<PageHighlight> highlightsOn(DisplayPage page) => const [];

  @override
  void dispose() => descartada = true;
}

final class _Parado implements Timer {
  @override
  void cancel() {}
  @override
  bool get isActive => false;
  @override
  int get tick => 0;
}

void main() {
  setUpAll(loadAppFonts);

  final vivas = <AnnotationSession>[];
  late AnnotationSession sessao;
  late _Pagina pagina;
  late FakeInkRepository repo;
  late List<String> eventos;
  final erros = <Object>[];

  tearDown(() {
    for (final v in vivas) {
      v.dispose();
    }
    vivas.clear();
  });

  Widget modo({
    bool open = true,
    ReaderPaper papel = ReaderPaper.creme,
    String? aviso,
    InkLatencyMeter? medidor,
  }) => AnnotationMode(
    open: open,
    session: sessao,
    page: pagina,
    paper: papel,
    brand: AppColors.lavender,
    sideMargin: 28,
    semanticsLabel: 'Dom Casmurro, página 159 de 256 — modo anotação',
    onDone: () => eventos.add('concluir'),
    onSoon: () => eventos.add('em breve'),
    toast: aviso,
    onExited: () => eventos.add('saiu'),
    meter: medidor,
  );

  Future<void> montar(
    WidgetTester tester, {
    EdgeInsets seguro = EdgeInsets.zero,
    ReaderPaper papel = ReaderPaper.creme,
    String? aviso,
    bool assentar = true,
    InkLatencyMeter? medidor,
    AnnotationPageSource? fonte,
  }) async {
    tester.view
      ..devicePixelRatio = 3
      ..physicalSize = const Size(390 * 3, 844 * 3)
      ..viewPadding = FakeViewPadding(
        top: seguro.top * 3,
        bottom: seguro.bottom * 3,
      )
      ..padding = FakeViewPadding(
        top: seguro.top * 3,
        bottom: seguro.bottom * 3,
      );
    addTearDown(tester.view.reset);
    repo = FakeInkRepository();
    sessao = AnnotationSession(
      geometry: _geometria(),
      anchors: _Anchors(),
      drawings: const [],
      highlights: const [],
      presets: presetsTeste(),
      repository: repo,
      owner: usuarioTeste,
      userBookId: idTeste(1),
      startTimer: (_, _) => _Parado(),
      // a falha ao salvar vai ao relatório (aqui, uma lista)
      onError: (e, _) => erros.add(e),
      pageSource: fonte,
      page: fonte == null ? null : pagina = _Pagina(),
    );
    vivas.add(sessao);
    if (fonte == null) pagina = _Pagina();
    eventos = [];
    await tester.pumpWidget(
      MediaQuery.fromView(
        view: tester.view,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: modo(papel: papel, aviso: aviso, medidor: medidor),
        ),
      ),
    );
    if (assentar) await tester.pumpAndSettle();
  }

  Finder chave(String k) => find.byKey(ValueKey<String>(k));
  Rect r(WidgetTester tester, String k) => tester.getRect(chave(k));

  testWidgets(
    'enquanto o Concluir grava, a camada não recebe toque (o que viesse não entraria na gravação)',
    (tester) async {
      await montar(tester);
      bool ignorando() => tester
          .widget<IgnorePointer>(find.byKey(const ValueKey('ann.mode')))
          .ignoring;
      expect(ignorando(), isFalse);
      // um traço, para o Concluir ter o que gravar
      InkPointer p(double x, int t) => (
        id: 1,
        kind: InkPointerKind.touch,
        x: x,
        y: 300,
        pressure: 1,
        tMs: t,
      );
      sessao
        ..pointerDown(p(60, 0))
        ..pointerMove(p(120, 16))
        ..pointerUp(p(120, 32));
      final porta = Completer<void>();
      repo.gate = porta.future;
      final gravando = sessao.conclude();
      await tester.pump();
      expect(ignorando(), isTrue);
      porta.complete();
      await gravando;
      await tester.pump();
      expect(ignorando(), isFalse);
    },
  );

  testWidgets(
    'o medidor de latência vai ao canvas; sem ele e sem o define, nenhum (o app normal)',
    (tester) async {
      final m = InkLatencyMeter(
        addTimings: (_) {},
        removeTimings: (_) {},
        log: (_) {},
      );
      await montar(tester, medidor: m);
      expect(
        tester.widget<AnnotationCanvas>(find.byType(AnnotationCanvas)).meter,
        same(m),
      );
      await montar(tester);
      expect(
        tester.widget<AnnotationCanvas>(find.byType(AnnotationCanvas)).meter,
        isNull,
      );
    },
  );

  testWidgets('os lugares no canvas de 390×844 (D-167 3): os da prancha', (
    tester,
  ) async {
    await montar(tester);
    expect(r(tester, 'ann.modePill').topLeft, const Offset(14, 50));
    expect(r(tester, 'ann.done').right, closeTo(376, 1e-6));
    expect(r(tester, 'ann.done').top, 50);
    expect(r(tester, 'ann.island'), const Rect.fromLTWH(14, 724, 362, 90));
    expect(r(tester, 'ann.toolShelf'), const Rect.fromLTWH(39, 676, 312, 70));
    expect(r(tester, 'ann.page'), const Rect.fromLTWH(28, 116, 334, 728));
    expect(r(tester, 'ann.deskEdge'), const Rect.fromLTWH(0, 594, 390, 250));
    expect(pagina.ty.last, 30);
  });

  testWidgets('iPhone (47 em cima, 34 embaixo): os mesmos lugares do arquivo', (
    tester,
  ) async {
    await montar(tester, seguro: const EdgeInsets.only(top: 47, bottom: 34));
    expect(r(tester, 'ann.modePill').top, 50);
    expect(r(tester, 'ann.island').top, 724);
    expect(r(tester, 'ann.toolShelf').top, 676);
    expect(r(tester, 'ann.page').top, 116);
  });

  testWidgets(
    'área segura maior (59/48): o topo em 62, a ilha a 44 da base, a prateleira e a página acompanham',
    (tester) async {
      await montar(tester, seguro: const EdgeInsets.only(top: 59, bottom: 48));
      expect(r(tester, 'ann.modePill').top, 62);
      expect(r(tester, 'ann.island'), const Rect.fromLTWH(14, 710, 362, 90));
      expect(r(tester, 'ann.toolShelf').top, 844 - 44 - 68 - 70);
      expect(r(tester, 'ann.page').top, 62 + 52 + 14);
    },
  );

  testWidgets(
    'entrada: o texto desce 30 em 220 ms e a moldura aparece em 150 ms (os toques só depois); saída ao contrário',
    (tester) async {
      await montar(tester, assentar: false);
      expect(pagina.ty.last, 0);
      NeoBox ilha() => tester.widget<NeoBox>(
        find
            .descendant(of: chave('ann.island'), matching: find.byType(NeoBox))
            .first,
      );
      await tester.pump(const Duration(milliseconds: 75));
      expect(ilha().color!.a, closeTo(0.5, 0.05));
      expect(tester.widget<IgnorePointer>(chave('ann.mode')).ignoring, isTrue);
      await tester.pump(const Duration(milliseconds: 35));
      // easeOutCubic na metade: 87,5 % dos 30
      expect(pagina.ty.last, closeTo(30 * 0.875, 0.5));
      await tester.pump(const Duration(milliseconds: 110));
      // (a animação termina no quadro seguinte aos 220 ms)
      await tester.pump(const Duration(milliseconds: 16));
      expect(pagina.ty.last, 30);
      expect(ilha().color!.a, 1);
      expect(tester.widget<IgnorePointer>(chave('ann.mode')).ignoring, isFalse);
      // saída
      await tester.pumpWidget(
        MediaQuery.fromView(
          view: tester.view,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: modo(open: false),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(ilha().color!.a, 0);
      expect(eventos, isEmpty);
      await tester.pump(const Duration(milliseconds: 80));
      expect(pagina.ty.last, 0);
      expect(eventos, ['saiu']);
    },
  );

  testWidgets(
    'Noite (D-167 17): a ilha e a pílula do Noite; a borda de mesa e o canvas com o papel do Noite',
    (tester) async {
      await montar(tester, papel: ReaderPaper.noite);
      final ilha = tester.widget<NeoBox>(
        find
            .descendant(of: chave('ann.island'), matching: find.byType(NeoBox))
            .first,
      );
      expect(ilha.color, AppColors.islandNight);
      expect(
        tester.widget<AnnotationCanvas>(find.byType(AnnotationCanvas)).paper,
        AppColors.paperNight,
      );
      expect(
        tester
            .widget<AnnotationCanvas>(find.byType(AnnotationCanvas))
            .lightText,
        AppColors.bookTextNight,
      );
      expect(
        tester.widget<DeskEdge>(find.byType(DeskEdge)).paper,
        AppColors.paperNight,
      );
    },
  );

  testWidgets(
    'o aviso (D-163) e a falha ao salvar (D-21) acima da prateleira',
    (tester) async {
      await montar(tester, aviso: 'Chega numa próxima fase');
      String texto() =>
          (tester
                      .widget<AppText>(
                        find.descendant(
                          of: chave('leitor.aviso'),
                          matching: find.byType(AppText),
                        ),
                      )
                      .span
                  as TextSpan)
              .text!;
      expect(texto(), 'Chega numa próxima fase');
      expect(r(tester, 'leitor.aviso').bottom, 844 - (30 + 68 + 70 + 12 + 12));
      repo.failCommit = true;
      InkPointer p(double x, double y, int t) =>
          (id: 1, kind: InkPointerKind.touch, x: x, y: y, pressure: 1, tMs: t);
      sessao
        ..pointerDown(p(86, 105, 0))
        ..pointerMove(p(150, 98, 8))
        ..pointerUp(p(195, 108, 16));
      expect(await sessao.conclude(), isFalse);
      expect(erros, isNotEmpty);
      await tester.pump();
      expect(texto(), 'Não deu para salvar as anotações agora.');
    },
  );

  testWidgets(
    'ferramentas: a Borracha e o Marca-texto trocam; o Espaço avisa; Borracha e Laço sem painel no 2º toque; Concluir',
    (tester) async {
      await montar(tester);
      await tester.tap(chave('ann.toolShelf.eraser'));
      await tester.pump();
      expect(sessao.tool, AnnotationTool.eraser);
      await tester.tap(chave('ann.toolShelf.eraser'));
      await tester.pump();
      expect(sessao.panel.value, isNull);
      await tester.tap(chave('ann.toolShelf.space'));
      await tester.tap(chave('ann.toolShelf.marker'));
      await tester.pump();
      expect(sessao.tool, AnnotationTool.marker);
      await tester.tap(chave('ann.done'));
      await tester.pump();
      expect(eventos, ['em breve', 'concluir']);
      await tester.tap(chave('ann.toolShelf.lasso'));
      await tester.tap(chave('ann.toolShelf.lasso'));
      await tester.pump();
      expect(sessao.panel.value, isNull);
      await tester.tap(chave('ann.island.width.thick'));
      await tester.pump();
      expect(sessao.strokeSize.name, 'thick');
    },
  );

  group('painéis (R1–R5)', () {
    testWidgets(
      '2º toque na Caneta abre a 23 com a seta na Caneta; de novo fecha (R1)',
      (tester) async {
        await montar(tester);
        expect(chave('ann.fade'), findsNothing);
        await tester.tap(chave('ann.toolShelf.pen'));
        await tester.pumpAndSettle();
        expect(sessao.panel.value, (
          kind: PanelKind.pen,
          from: AnnotationTool.pen,
        ));
        expect(chave('ann.fade'), findsOneWidget);
        expect(chave('ann.penPanel'), findsOneWidget);
        expect(r(tester, 'ann.penPanel.arrow').center.dx, closeTo(66.25, 0.5));
        // a base 22 acima do topo da prateleira (676 na prancha)
        expect(r(tester, 'ann.penPanel').bottom, closeTo(654, 0.5));
        await tester.tap(chave('ann.toolShelf.pen'));
        await tester.pumpAndSettle();
        expect(sessao.panel.value, isNull);
        expect(chave('ann.fade'), findsNothing);
        expect(eventos, isEmpty);
      },
    );

    testWidgets(
      'Reta ativa: o 2º toque abre a 23 com a seta na Reta; Marca-texto abre a 23b (R1)',
      (tester) async {
        await montar(tester);
        await tester.tap(chave('ann.toolShelf.line'));
        await tester.pump();
        await tester.tap(chave('ann.toolShelf.line'));
        await tester.pumpAndSettle();
        expect(chave('ann.penPanel'), findsOneWidget);
        // 251 + 1,5 + 14 + 8,75
        expect(r(tester, 'ann.penPanel.arrow').center.dx, closeTo(275.25, 0.5));
        // outra ferramenta fecha e troca (R4)
        await tester.tap(chave('ann.toolShelf.marker'));
        await tester.pumpAndSettle();
        expect(sessao.panel.value, isNull);
        expect(sessao.tool, AnnotationTool.marker);
        await tester.tap(chave('ann.toolShelf.marker'));
        await tester.pumpAndSettle();
        expect(chave('ann.markerPanel'), findsOneWidget);
        expect(
          r(tester, 'ann.markerPanel.arrow').center.dx,
          closeTo(119.25, 0.5),
        );
      },
    );

    testWidgets(
      'o poço: com a Borracha depois do Marca-texto abre a 23b; tocar de novo fecha (R2)',
      (tester) async {
        await montar(tester);
        await tester.tap(chave('ann.toolShelf.marker'));
        await tester.tap(chave('ann.toolShelf.eraser'));
        await tester.pump();
        await tester.tap(chave('ann.island.colorWell'));
        await tester.pumpAndSettle();
        expect(sessao.panel.value, (
          kind: PanelKind.marker,
          from: AnnotationTool.marker,
        ));
        expect(sessao.tool, AnnotationTool.eraser);
        await tester.tap(chave('ann.island.colorWell'));
        await tester.pumpAndSettle();
        expect(sessao.panel.value, isNull);
      },
    );

    testWidgets(
      'o toque no véu só fecha: não desenha nem conclui; o ✕ fecha (R3)',
      (tester) async {
        await montar(tester);
        await tester.tap(chave('ann.toolShelf.pen'));
        await tester.pumpAndSettle();
        // arrastar no véu não desenha (o painel fica)
        await tester.dragFrom(const Offset(100, 300), const Offset(80, 0));
        await tester.pumpAndSettle();
        expect(sessao.panel.value, isNotNull);
        expect(sessao.drawings, isEmpty);
        // tocar no Concluir por baixo do véu só fecha o painel
        await tester.tapAt(const Offset(300, 75));
        await tester.pumpAndSettle();
        expect(sessao.panel.value, isNull);
        expect(eventos, isEmpty);
        await tester.tap(chave('ann.toolShelf.pen'));
        await tester.pumpAndSettle();
        await tester.tap(chave('ann.penPanel.close'));
        await tester.pumpAndSettle();
        expect(sessao.panel.value, isNull);
      },
    );

    testWidgets(
      'com o painel aberto, a ilha funciona: espessura, Desfazer e Refazer (R4)',
      (tester) async {
        await montar(tester);
        await tester.tap(chave('ann.toolShelf.pen'));
        await tester.pumpAndSettle();
        await tester.tap(chave('ann.island.width.thin'));
        await tester.pump();
        expect(sessao.strokeSize.name, 'thin');
        expect(sessao.panel.value, isNotNull);
        // o Espaço com o painel aberto: fecha e avisa (R1)
        await tester.tap(chave('ann.toolShelf.space'));
        await tester.pumpAndSettle();
        expect(sessao.panel.value, isNull);
        expect(eventos, ['em breve']);
      },
    );

    testWidgets(
      'o véu e o painel aparecem em 150 ms; com "reduzir movimento", na hora (R5)',
      (tester) async {
        await montar(tester);
        await tester.tap(chave('ann.toolShelf.pen'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 75));
        final meio = tester.widget<ColoredBox>(chave('ann.fade')).color.a;
        expect(meio, closeTo(0.66 * 0.5, 0.08));
        await tester.pump(const Duration(milliseconds: 80));
        expect(
          tester.widget<ColoredBox>(chave('ann.fade')).color.a,
          closeTo(0.66, 0.01),
        );
        await tester.tap(chave('ann.penPanel.close'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 75));
        expect(chave('ann.fade'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 80));
        expect(chave('ann.fade'), findsNothing);
      },
    );

    testWidgets(
      'com "reduzir movimento", o painel abre e fecha sem animar (R5)',
      (tester) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
        await montar(tester);
        await tester.tap(chave('ann.toolShelf.pen'));
        await tester.pump();
        expect(
          tester.widget<ColoredBox>(chave('ann.fade')).color.a,
          closeTo(0.66, 0.01),
        );
        await tester.tap(chave('ann.penPanel.close'));
        await tester.pump();
        expect(chave('ann.fade'), findsNothing);
      },
    );
  });

  testWidgets(
    'R28: na prateleira, o Marca-texto na cor do marca-texto e a Caneta na da caneta',
    (tester) async {
      await montar(tester);
      sessao.setHighlighterColor('#ABCF82');
      await tester.tap(chave('ann.toolShelf.marker'));
      await tester.pump();
      final shelf = tester.widget<ToolShelf>(find.byType(ToolShelf));
      expect(
        (shelf.ink, shelf.marker),
        (const Color(0xFFFF552E), const Color(0xFFABCF82)),
      );
    },
  );

  testWidgets(
    'semântica: a página, "Ferramentas de anotação" e "Barra de anotação"',
    (tester) async {
      await montar(tester);
      final h = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(
          'Dom Casmurro, página 159 de 256 — modo anotação',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Ferramentas de anotação'), findsOneWidget);
      expect(find.bySemanticsLabel('Barra de anotação'), findsOneWidget);
      h.dispose();
    },
  );

  group('G18: o Espaço (R3, R4)', () {
    InkPointer dedo(double y, int t) => (
      id: 1,
      kind: InkPointerKind.touch,
      x: 221.72,
      y: y,
      pressure: 1,
      tMs: t,
    );

    // a fresta abaixo da 1ª linha (109,25) e o topo da área (14 abaixo); a tela soma os 30 px do modo
    const fresta = 109.25 + 30;
    const topo = 109.25 + 14;

    testWidgets(
      'com a fonte, o Espaço fica ativo sem o aviso e a pílula diz "Arraste entre as linhas"; as outras, "2 dedos…"',
      (tester) async {
        await montar(tester, fonte: _Fonte());
        String subtitulo() => tester
            .widgetList<AppText>(
              find.descendant(
                of: chave('ann.modePill'),
                matching: find.byType(AppText),
              ),
            )
            .map((t) => t.span.toPlainText())
            .last;
        expect(subtitulo(), annotationHint);
        await tester.tap(chave('ann.toolShelf.space'));
        await tester.pump();
        expect(sessao.tool, AnnotationTool.space);
        expect(eventos, isEmpty, reason: 'sem o aviso da D-163');
        expect(subtitulo(), annotationSpaceHint);
        expect(annotationSpaceHint, 'Arraste entre as linhas');
        await tester.tap(chave('ann.toolShelf.pen'));
        await tester.pump();
        expect(subtitulo(), annotationHint);
      },
    );

    testWidgets(
      'o arrasto mostra o abridor sobre a página (30 abaixo, com as linhas); ao soltar, a nota e a Caneta',
      (tester) async {
        final fonte = _Fonte();
        await montar(tester, fonte: fonte);
        await tester.tap(chave('ann.toolShelf.space'));
        await tester.pump();
        expect(find.byType(SpaceOpener), findsNothing);
        sessao
          ..pointerDown(dedo(fresta + 2, 0))
          ..pointerMove(dedo(fresta + 20, 8))
          ..pointerMove(dedo(topo + 3 * 35.25 - 2 + 30, 16));
        await tester.pump();
        final abridor = tester.widget<SpaceOpener>(find.byType(SpaceOpener));
        // o dedo do abridor é o indicador de toque da tela 24: o anel da D-167 (6) não aparece junto
        expect(find.byType(TouchIndicator), findsNothing);
        expect(abridor.lines, 3);
        expect(abridor.fingerX, 221.72);
        expect(abridor.colors, OpenerColors.paper);
        final area = r(tester, 'ann.page.spaceOpener');
        expect(area.left, 28);
        expect(area.top, closeTo(topo + 30, 1e-9));
        expect(area.height, closeTo(3 * 35.25 - 2, 1e-9));
        // a página pintada é a da sessão (com o abridor)
        expect(fonte.paginas.last.ty, isNotEmpty);
        // o dedo andou sem mudar as linhas: o abridor segue o x, a página não é refeita
        final feitas = fonte.paginas.length;
        sessao.pointerMove((
          id: 1,
          kind: InkPointerKind.touch,
          x: 120,
          y: topo + 3 * 35.25 + 30,
          pressure: 1,
          tMs: 24,
        ));
        await tester.pump();
        expect(
          tester.widget<SpaceOpener>(find.byType(SpaceOpener)).fingerX,
          120,
        );
        expect(fonte.paginas, hasLength(feitas));
        sessao.pointerUp(dedo(topo + 3 * 35.25 + 30, 32));
        await tester.pump();
        expect(find.byType(SpaceOpener), findsNothing);
        expect(sessao.notes.single.lines, 3);
        expect(sessao.tool, AnnotationTool.pen);
      },
    );

    testWidgets(
      'com o Espaço ativo, o poço abre o painel da última ferramenta de tinta (§3); o Espaço continua',
      (tester) async {
        await montar(tester, fonte: _Fonte());
        await tester.tap(chave('ann.toolShelf.space'));
        await tester.pump();
        await tester.tap(chave('ann.island.colorWell'));
        await tester.pumpAndSettle();
        expect(sessao.panel.value, (
          kind: PanelKind.pen,
          from: AnnotationTool.pen,
        ));
        expect(sessao.tool, AnnotationTool.space);
      },
    );

    testWidgets(
      'na volta do batente, os controles das notas e o abridor andam com a página pintada (D-165)',
      (tester) async {
        await montar(tester, fonte: _Fonte());
        double dy() =>
            tester.widget<HandNoteLayer>(find.byType(HandNoteLayer)).dy;
        final a = await tester.startGesture(const Offset(100, 400));
        final b = await tester.startGesture(const Offset(200, 400));
        await a.moveBy(const Offset(0, 90));
        await b.moveBy(const Offset(0, 90));
        await tester.pump();
        final puxado = dy();
        expect(puxado, greaterThan(30));
        await a.up();
        await b.up();
        await tester.pump();
        expect(sessao.panOffset, 0);
        expect(
          dy(),
          closeTo(puxado, 1e-9),
          reason: 'a volta começa de onde estava',
        );
        await tester.pump(const Duration(milliseconds: 110));
        expect(dy(), allOf(greaterThan(30), lessThan(puxado)));
        await tester.pump(const Duration(milliseconds: 120));
        expect(dy(), 30);
      },
    );

    testWidgets(
      'a página sobe com 2 dedos até o pé da nota que passa da borda de mesa (D-165, R3)',
      (tester) async {
        await montar(tester, fonte: _Fonte());
        await tester.tap(chave('ann.toolShelf.space'));
        await tester.pump();
        sessao
          ..pointerDown(dedo(fresta + 2, 0))
          ..pointerMove(dedo(fresta + 20, 8))
          ..pointerMove(dedo(topo + 3 * 35.25 - 2 + 30, 16))
          ..pointerUp(dedo(topo + 3 * 35.25 + 30, 32));
        await tester.pump();
        final id = sessao.notes.single.id;
        sessao
          ..dragNoteHandle(id, 42 * 9)
          ..endNoteHandle(id);
        await tester.pump();
        expect(sessao.notes.single.lines, 12);
        expect(sessao.contentBottom, closeTo(109.25 + 42 * 12 + 80, 1e-9));
        expect(
          sessao.panLimit,
          closeTo(109.25 + 42 * 12 + 80 + 30 - (844 - deskEdgeHeight), 1e-9),
        );
      },
    );

    testWidgets('Noite (R14): o abridor com as cores do Noite', (tester) async {
      await montar(tester, fonte: _Fonte(), papel: ReaderPaper.noite);
      await tester.tap(chave('ann.toolShelf.space'));
      await tester.pump();
      sessao
        ..pointerDown(dedo(fresta + 2, 0))
        ..pointerMove(dedo(fresta + 40, 8));
      await tester.pump();
      expect(
        tester.widget<SpaceOpener>(find.byType(SpaceOpener)).colors,
        OpenerColors.night,
      );
    });
  });
}

// G16.6 — a camada do modo anotação: os lugares da D-167 (3) com a área segura 0, a de um iPhone (47/34, que dá os
// lugares do arquivo) e uma maior; a entrada (o texto desce 30 em 220 ms, a moldura aparece em 150 ms, os toques só
// depois) e a saída ao contrário; o Noite (D-167 17); a pílula da falha ao salvar (D-21) e o aviso da D-163 acima da
// prateleira; as ferramentas (as das próximas fases, o poço e o 2º toque na ativa avisam); a semântica.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/widgets/neo_box.dart';
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/presentation/annotation_canvas.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
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

final class _Pagina implements DisplayPage {
  final ty = <double>[];

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
  );

  Future<void> montar(
    WidgetTester tester, {
    EdgeInsets seguro = EdgeInsets.zero,
    ReaderPaper papel = ReaderPaper.creme,
    String? aviso,
    bool assentar = true,
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
    );
    vivas.add(sessao);
    pagina = _Pagina();
    eventos = [];
    await tester.pumpWidget(
      MediaQuery.fromView(
        view: tester.view,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: modo(papel: papel, aviso: aviso),
        ),
      ),
    );
    if (assentar) await tester.pumpAndSettle();
  }

  Finder chave(String k) => find.byKey(ValueKey<String>(k));
  Rect r(WidgetTester tester, String k) => tester.getRect(chave(k));

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
    'ferramentas: a Borracha troca; Marca-texto, Espaço, o poço e o 2º toque na ativa avisam; Concluir',
    (tester) async {
      await montar(tester);
      await tester.tap(chave('ann.toolShelf.eraser'));
      await tester.pump();
      expect(sessao.tool, AnnotationTool.eraser);
      await tester.tap(chave('ann.toolShelf.marker'));
      await tester.tap(chave('ann.toolShelf.space'));
      await tester.tap(chave('ann.toolShelf.eraser'));
      await tester.tap(chave('ann.island.colorWell'));
      await tester.tap(chave('ann.done'));
      await tester.pump();
      expect(sessao.tool, AnnotationTool.eraser);
      expect(eventos, [
        'em breve',
        'em breve',
        'em breve',
        'em breve',
        'concluir',
      ]);
      await tester.tap(chave('ann.island.width.thick'));
      await tester.pump();
      expect(sessao.strokeSize.name, 'thick');
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
}

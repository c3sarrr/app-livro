// G18.4 — a nota à mão no modo anotação (tela 24b, L24b.1–L24b.4, R7–R9): os controles por cima da página, nos
// lugares da prancha relativos à caixa (a etiqueta, as pautas, os botões de 40, a tinta, a dica e a alça); o leitor
// de tela (o grupo "Nota à mão, depois de “…”", a tinta "Nota à mão, ‹dia› de ‹mês›" — D-31 —, os botões e a alça);
// Recolher vira a faixa com "Abrir a nota"; Apagar some com a pílula "Nota apagada · Desfazer" (D-185); a alça muda
// as linhas (D-186); o canvas pinta a caixa; Noite (R14). Sem a fonte da página, nada disso.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_leitura/core/design_system/text/app_text.dart';
import 'package:app_leitura/core/design_system/tokens/app_colors.dart';
import 'package:app_leitura/core/design_system/tokens/app_icons_leitor.dart';
import 'package:app_leitura/core/design_system/widgets/app_svg.dart';
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/annotations/space/hand_note_layout.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/annotation_page_source.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/domain/reader_settings.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/layout/space_cut.dart';
import 'package:app_leitura/features/reader/presentation/annotation_canvas.dart';
import 'package:app_leitura/features/reader/presentation/annotation_mode.dart';
import 'package:app_leitura/features/reader/presentation/hand_note.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_ink_repository.dart';
import '../../../support/load_fonts.dart';
import '../../../support/personal_builders.dart';
import '../../../support/precache_svgs.dart';

const _texto = 'Olhos de ressaca? Vá. E a vaga que';

/// Duas linhas no topo da página (o leitor limpo): a 1ª acaba depois de "Vá.".
InkPageGeometry _geometria() => const InkPageGeometry([
  InkLine(
    unit: 4,
    from: 0,
    to: 21,
    top: 74,
    bottom: 109.25,
    baseline: 100,
    em: 20.5,
    left: 28,
    right: 230,
    words: [],
  ),
  InkLine(
    unit: 4,
    from: 22,
    to: 34,
    top: 109.25,
    bottom: 144.5,
    baseline: 135.25,
    em: 20.5,
    left: 28,
    right: 133,
    words: [],
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

  @override
  final List<PageSpace> spaces;

  @override
  void paint(ui.Canvas canvas) {}
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

/// Cada espaço vira um bloco logo abaixo da 1ª linha (109,25), da altura dele.
final class _Fonte implements AnnotationPageSource {
  @override
  DisplayPage pageWith(List<SpaceCut> cuts) => _Pagina([
    for (final c in cuts)
      (id: c.id, rect: Rect.fromLTWH(28, 109.25, 334, c.height)),
  ]);

  @override
  ({DisplayPage page, void Function() dispose})? tallPageWith(
    List<SpaceCut> cuts,
    double extra,
  ) => null;

  @override
  List<PageHighlight> highlightsOn(DisplayPage page) => const [];

  @override
  void dispose() {}
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

  late AnnotationSession sessao;
  late List<(Duration, void Function())> timers;

  Finder chave(String k) => find.byKey(ValueKey<String>(k));
  Rect r(WidgetTester tester, String k) => tester.getRect(chave(k));

  /// O modo com a fonte da página; [nota] abre uma nota de 3 linhas pela fresta abaixo da 1ª linha (a Caneta volta).
  Future<void> montar(
    WidgetTester tester, {
    ReaderPaper papel = ReaderPaper.creme,
    bool nota = true,
  }) async {
    tester.view
      ..devicePixelRatio = 3
      ..physicalSize = const Size(390 * 3, 844 * 3);
    addTearDown(tester.view.reset);
    timers = [];
    sessao = AnnotationSession(
      geometry: _geometria(),
      anchors: _Anchors(),
      drawings: const [],
      highlights: const [],
      presets: presetsTeste(),
      repository: FakeInkRepository(),
      owner: usuarioTeste,
      userBookId: idTeste(1),
      startTimer: (d, f) {
        timers.add((d, f));
        return _Parado();
      },
      now: () => DateTime(2026, 9, 20, 15),
      pageSource: _Fonte(),
      page: _Pagina(),
    );
    addTearDown(sessao.dispose);
    await precacheSvgs(tester, [
      AppIconsLeitor.pencilBold,
      AppIconsLeitor.chevronUp,
      AppIconsLeitor.trash,
    ]);
    await tester.pumpWidget(
      MediaQuery.fromView(
        view: tester.view,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AnnotationMode(
            open: true,
            session: sessao,
            page: _Pagina(),
            paper: papel,
            brand: AppColors.lavender,
            sideMargin: 28,
            semanticsLabel: 'Dom Casmurro, página 159 de 256 — modo anotação',
            onDone: () {},
            onSoon: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (!nota) return;
    sessao.setTool(AnnotationTool.space);
    InkPointer dedo(double y, int t) => (
      id: 1,
      kind: InkPointerKind.touch,
      x: 221.72,
      y: y,
      pressure: 1,
      tMs: t,
    );
    const fresta = 109.25 + 30;
    sessao
      ..pointerDown(dedo(fresta + 2, 0))
      ..pointerMove(dedo(fresta + 20, 8))
      ..pointerMove(dedo(fresta + 14 + 3 * 35.25 - 2, 16))
      ..pointerUp(dedo(fresta + 14 + 3 * 35.25 - 2, 24));
    await tester.pump();
  }

  /// A caixa da nota na tela (a da sessão, 30 px abaixo).
  Rect caixa() =>
      sessao.noteBox(sessao.notes.single.id)!.shift(const Offset(0, 30));

  testWidgets(
    'os controles nos lugares da 24b, relativos à caixa: etiqueta, pautas, botões, tinta, dica, alça e barras',
    (tester) async {
      await montar(tester);
      final box = caixa();
      expect(box, const Rect.fromLTWH(28, 109.25 + 30 + 30, 334, 150));
      final p = handNoteLayout(box, 3);
      expect(r(tester, 'ann.page.handNote'), box);
      final tag = r(tester, 'ann.page.handNote.tag');
      expect(tag.topLeft, p.tag);
      expect(tag.height, noteTagHeight);
      expect(tag.width, closeTo(98.97, 1.0));
      expect(
        r(tester, 'ann.page.handNote.tag.icon'),
        Rect.fromLTWH(p.tag.dx + 8.5, p.tag.dy + 5.5, 13, 13),
      );
      expect(r(tester, 'ann.page.handNote.rule1'), p.rules[0]);
      expect(r(tester, 'ann.page.handNote.rule2'), p.rules[1]);
      expect(
        r(tester, 'ann.page.handNote.actions'),
        Rect.fromLTRB(
          p.collapse.left,
          p.collapse.top,
          p.delete.right,
          p.delete.bottom,
        ),
      );
      expect(r(tester, 'ann.page.handNote.actions.collapse'), p.collapse);
      expect(r(tester, 'ann.page.handNote.actions.delete'), p.delete);
      expect(
        r(tester, 'ann.page.handNote.actions.collapse.icon'),
        Rect.fromCenter(center: p.collapse.center, width: 18, height: 18),
      );
      expect(
        r(tester, 'ann.page.handNote.actions.delete.icon'),
        Rect.fromCenter(center: p.delete.center, width: 18, height: 18),
      );
      final ink = inkFrame(box);
      expect(
        r(tester, 'ann.page.handNote.ink'),
        Rect.fromLTWH(ink.left, ink.top, ink.width, box.height),
      );
      final hint = r(tester, 'ann.page.handNote.hint');
      expect(hint.left, p.hintBottomLeft.dx);
      expect(hint.bottom, closeTo(p.hintBottomLeft.dy, 0.01));
      expect(hint.width, closeTo(132.33, 1.0));
      expect(r(tester, 'ann.page.handNote.handle'), p.handle);
      expect(r(tester, 'ann.page.handNote.handle.bar1'), p.bar1);
      expect(r(tester, 'ann.page.handNote.handle.bar2'), p.bar2);
    },
  );

  testWidgets(
    'o estilo da 24b: a etiqueta amarela, os botões redondos, a dica e a alça com a sombra 2/2',
    (tester) async {
      await montar(tester);
      final tag =
          tester.widget<Container>(chave('ann.page.handNote.tag')).decoration!
              as BoxDecoration;
      expect(tag.color, AppColors.sun);
      expect(tag.border, Border.all(width: 1.5, color: AppColors.ink));
      expect(tag.borderRadius, BorderRadius.circular(12));
      final texto = tester.widget<AppText>(
        find.descendant(
          of: chave('ann.page.handNote.tag'),
          matching: find.byType(AppText),
        ),
      );
      expect(texto.span.toPlainText(), 'Nota à mão');
      expect(
        (texto.span.style!.fontSize, texto.span.style!.fontWeight),
        (11.5, FontWeight.w800),
      );
      expect(
        tester.widget<AppSvg>(chave('ann.page.handNote.tag.icon')).asset,
        AppIconsLeitor.pencilBold,
      );
      for (final (id, icone) in [
        ('collapse', AppIconsLeitor.chevronUp),
        ('delete', AppIconsLeitor.trash),
      ]) {
        final b =
            tester
                    .widget<Container>(
                      chave('ann.page.handNote.actions.$id.box'),
                    )
                    .decoration!
                as BoxDecoration;
        expect(b.color, AppColors.surface);
        expect(b.shape, BoxShape.circle);
        expect(b.border, Border.all(width: 1.5, color: AppColors.ink));
        final i = tester.widget<AppSvg>(
          chave('ann.page.handNote.actions.$id.icon'),
        );
        expect((i.asset, i.size), (icone, 18.0));
      }
      final dica = tester.widget<AppText>(chave('ann.page.handNote.hint'));
      expect(dica.span.toPlainText(), 'puxe a alça para aumentar');
      expect(
        (
          dica.span.style!.fontSize,
          dica.span.style!.fontWeight,
          dica.span.style!.color,
        ),
        (11.0, FontWeight.w700, AppColors.readerFooter),
      );
      final alca =
          tester
                  .widget<Container>(chave('ann.page.handNote.handle.box'))
                  .decoration!
              as BoxDecoration;
      expect(alca.color, AppColors.surface);
      expect(alca.borderRadius, BorderRadius.circular(11));
      expect(alca.boxShadow, const [
        BoxShadow(color: AppColors.ink, offset: Offset(2, 2)),
      ]);
      final barra =
          tester
                  .widget<Container>(chave('ann.page.handNote.handle.bar1'))
                  .decoration!
              as BoxDecoration;
      expect(
        (barra.color, barra.borderRadius),
        (AppColors.ink, BorderRadius.circular(2)),
      );
    },
  );

  testWidgets('leitor de tela: o grupo, os botões, a alça e a tinta (D-31)', (
    tester,
  ) async {
    final h = tester.ensureSemantics();
    await montar(tester);
    expect(
      find.bySemanticsLabel('Nota à mão, depois de “Vá.”'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Recolher a nota'), findsOneWidget);
    expect(find.bySemanticsLabel('Apagar a nota'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Arrastar para mudar a altura do espaço'),
      findsOneWidget,
    );
    // sem tinta, sem a imagem; com tinta, "Nota à mão, 20 de setembro"
    expect(find.bySemanticsLabel('Nota à mão, 20 de setembro'), findsNothing);
    final box = caixa();
    InkPointer dedo(double x, double y, int t) =>
        (id: 1, kind: InkPointerKind.touch, x: x, y: y, pressure: 1, tMs: t);
    sessao
      ..pointerDown(dedo(80, box.top + 60, 0))
      ..pointerMove(dedo(120, box.top + 62, 8))
      ..pointerUp(dedo(160, box.top + 64, 16));
    await tester.pump();
    expect(sessao.notes.single.strokes, hasLength(1));
    expect(
      tester.getSemantics(chave('ann.page.handNote.ink')),
      matchesSemantics(label: 'Nota à mão, 20 de setembro', isImage: true),
    );
    expect(noteInkLabel(DateTime(2026, 1, 3)), 'Nota à mão, 3 de janeiro');
    // G20 (R8): o desenho no mesmo formato
    expect(
      drawingInkLabel(DateTime(2026, 9, 20, 15)),
      'Desenho, 20 de setembro',
    );
    expect(drawingInkLabel(DateTime(2026, 12, 1)), 'Desenho, 1 de dezembro');
    h.dispose();
  });

  testWidgets(
    'Recolher (R8): a faixa com "Abrir a nota"; abrir volta à caixa; cada um, um passo',
    (tester) async {
      final h = tester.ensureSemantics();
      await montar(tester);
      await tester.tap(chave('ann.page.handNote.actions.collapse'));
      await tester.pump();
      expect(sessao.notes.single.collapsed, isTrue);
      expect(chave('ann.page.handNote.actions'), findsNothing);
      expect(chave('ann.page.handNote.handle'), findsNothing);
      final faixa = sessao
          .noteBox(sessao.notes.single.id)!
          .shift(const Offset(0, 30));
      final s = stripLayout(faixa);
      expect(r(tester, 'ann.page.handNote'), faixa);
      expect(r(tester, 'ann.page.handNote.tag').topLeft, s.tag);
      expect(r(tester, 'ann.page.handNote.open'), s.open);
      expect(find.bySemanticsLabel('Abrir a nota'), findsOneWidget);
      await tester.tap(chave('ann.page.handNote.open'));
      await tester.pump();
      expect(sessao.notes.single.collapsed, isFalse);
      expect(chave('ann.page.handNote.open'), findsNothing);
      sessao.undo();
      await tester.pump();
      expect(sessao.notes.single.collapsed, isTrue);
      h.dispose();
    },
  );

  testWidgets(
    'Apagar (R9, D-185): some na hora; "Nota apagada · Desfazer" volta a nota; a pílula some em 4 s',
    (tester) async {
      await montar(tester);
      await tester.tap(chave('ann.page.handNote.actions.delete'));
      await tester.pump();
      expect(sessao.notes, isEmpty);
      expect(chave('ann.page.handNote'), findsNothing);
      expect(
        find.descendant(
          of: chave('leitor.desfazer'),
          matching: find.byType(AppText),
        ),
        findsWidgets,
      );
      expect(
        tester
            .widgetList<AppText>(
              find.descendant(
                of: chave('leitor.desfazer'),
                matching: find.byType(AppText),
              ),
            )
            .map((t) => t.span.toPlainText()),
        ['Nota apagada', 'Desfazer'],
      );
      await tester.tap(chave('leitor.desfazer.botao'));
      await tester.pump();
      expect(sessao.notes, hasLength(1));
      expect(chave('leitor.desfazer'), findsNothing);
      // de novo, e o tempo da pílula acaba
      await tester.tap(chave('ann.page.handNote.actions.delete'));
      await tester.pump();
      timers.lastWhere((t) => t.$1 == favoriteUndoLife).$2();
      await tester.pump();
      expect(chave('leitor.desfazer'), findsNothing);
      expect(sessao.notes, isEmpty);
    },
  );

  testWidgets(
    'a alça (R7, D-186): arrastar 2 pautas para baixo dá 5 linhas, um passo; a caixa acompanha',
    (tester) async {
      await montar(tester);
      final alca = r(tester, 'ann.page.handNote.handle').center;
      final g = await tester.startGesture(alca);
      await g.moveBy(const Offset(0, 20));
      await g.moveBy(const Offset(0, 64));
      await tester.pump();
      expect(sessao.notes.single.lines, 5);
      expect(r(tester, 'ann.page.handNote').height, 42 * 5 + 24);
      await g.up();
      await tester.pump();
      expect(sessao.notes.single.lines, 5);
      sessao.undo();
      await tester.pump();
      expect(sessao.notes.single.lines, 3);
      // o leitor de tela: aumentar e diminuir de uma linha
      final h = tester.ensureSemantics();
      final alcaNoLeitor = find.semantics.byLabel(noteHandleLabel);
      tester.semantics.increase(alcaNoLeitor);
      await tester.pump();
      expect(sessao.notes.single.lines, 4);
      tester.semantics.decrease(alcaNoLeitor);
      await tester.pump();
      expect(sessao.notes.single.lines, 3);
      h.dispose();
    },
  );

  testWidgets(
    'o canvas pinta a caixa da sessão (fundo, tracejado, pautas) sem a etiqueta, que é um widget',
    (tester) async {
      await montar(tester);
      final painter =
          tester.widget<CustomPaint>(chave('ann.canvas.page')).painter!
              as AnnotationPagePainter;
      final canvas = TestRecordingCanvas();
      painter.paint(canvas, const Size(390, 844));
      final fundos = canvas.invocations.where(
        (c) =>
            c.invocation.memberName == #drawRRect &&
            (c.invocation.positionalArguments[1] as Paint).color.toARGB32() ==
                AppColors.paperWhite.toARGB32(),
      );
      expect(fundos, hasLength(1));
      expect(
        (fundos.single.invocation.positionalArguments[0] as RRect).outerRect,
        sessao.noteBox(sessao.notes.single.id),
      );
      expect(
        canvas.invocations.where(
          (c) =>
              c.invocation.memberName == #drawRRect &&
              (c.invocation.positionalArguments[1] as Paint).color.toARGB32() ==
                  AppColors.sun.toARGB32(),
        ),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Noite (R14): botões e alça no fundo do Noite com a borda clara; a dica no tom do Noite',
    (tester) async {
      await montar(tester, papel: ReaderPaper.noite);
      final b =
          tester
                  .widget<Container>(
                    chave('ann.page.handNote.actions.delete.box'),
                  )
                  .decoration!
              as BoxDecoration;
      expect(b.color, AppColors.islandNight);
      expect(b.border, Border.all(width: 1.5, color: AppColors.inkNight));
      expect(
        tester
            .widget<AppText>(chave('ann.page.handNote.hint'))
            .span
            .style!
            .color,
        AppColors.mutedNight,
      );
      final tag =
          tester.widget<Container>(chave('ann.page.handNote.tag')).decoration!
              as BoxDecoration;
      expect(tag.color, AppColors.sun);
    },
  );

  testWidgets('sem nota, nada', (tester) async {
    await montar(tester, nota: false);
    expect(chave('ann.page.handNote'), findsNothing);
  });
}

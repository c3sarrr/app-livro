// G18.2 — o Espaço e as notas à mão na sessão (R1–R9, D-181, D-185–D-187), sobre a pág. 159 de verdade (o parágrafo
// do arquivo, com os trechos da D-160) e uma fonte de página que refaz o layout com os espaços:
// - o arrasto entre as linhas abre o abridor e conta as linhas; ao soltar nasce a nota e a Caneta volta;
// - a página do modo é refeita (R3): o texto de baixo desce sem recuo, cada desenho anda com as palavras dele, o
//   desfazer volta tudo e o desenho salvo intocado não é regravado;
// - a tinta que começa na caixa é da nota (R6); a alça para na tinta (D-186); recolher; apagar com a pílula (D-185).
import 'dart:async';
import 'dart:ui' as ui;

import 'package:app_leitura/core/data/ids/uuid_v7.dart';
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_commands.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/space/space_metrics.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/annotation_page_source.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:app_leitura/features/reader/application/ink_page_geometry.dart';
import 'package:app_leitura/features/reader/content/content_blocks.dart';
import 'package:app_leitura/features/reader/layout/display_page.dart';
import 'package:app_leitura/features/reader/layout/laid_block.dart';
import 'package:app_leitura/features/reader/layout/page_snapshot.dart';
import 'package:app_leitura/features/reader/layout/paginator.dart';
import 'package:app_leitura/features/reader/layout/reader_typography.dart';
import 'package:app_leitura/features/reader/layout/space_cut.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/mundo_2026_09_20.dart' show paragrafoDaPagina159;
import '../../../support/fake_ink_repository.dart';
import '../../../support/load_fonts.dart';
import '../../../support/mundo_epub.dart' show semQuebraNos;
import '../../../support/personal_builders.dart';

const t = ReaderTypography();
const _unit = 31;
final String _texto = semQuebraNos(paragrafoDaPagina159, const {
  'olhos de Capitu',
  'Olhos de ressaca?',
  'fluido misterioso',
  'a vaga que se retira',
});
final int _ancora =
    _texto.indexOf('Vá, de ressaca.') + 'Vá, de ressaca.'.length;

final class _Ancoras implements AnnotationAnchors {
  @override
  String get sha => shaTeste;
  @override
  String? textOf(int spine) => spine == _unit ? _texto : null;
  @override
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset) =>
      (refPage: 159, chapterIndex: 31);
}

/// A página do modo montada de novo com os espaços (alta: o pé da tela).
final class _Fonte implements AnnotationPageSource {
  final List<List<LaidBlock>> montados = [];
  final List<List<SpaceCut>> pedidos = [];

  @override
  DisplayPage pageWith(List<SpaceCut> cuts) {
    pedidos.add(cuts);
    final blocks = BlockLayouter(t).layoutAll(
      [
        ParagraphBlock([TextRun(_texto)], BlockStyle.none),
      ],
      const [0],
      cuts: cuts,
    );
    montados.add(blocks);
    return PageSnapshot(
      spine: _unit,
      page: paginateChapter(blocks, 2000).first,
      blockOf: (b) => blocks[b],
      typography: t,
      item: ParsedItem(
        blocks: [
          ParagraphBlock([TextRun(_texto)], BlockStyle.none),
        ],
        text: _texto,
        blockStarts: const [0],
        idOffsets: const {},
      ),
    );
  }

  @override
  List<PageHighlight> highlightsOn(DisplayPage page) => const [];

  @override
  void dispose() {
    for (final l in montados) {
      for (final b in l) {
        b.dispose();
      }
    }
  }
}

final class _Timers {
  final List<(Duration, void Function())> pending = [];
  Timer start(Duration d, void Function() f) {
    pending.add((d, f));
    return _NoTimer();
  }
}

final class _NoTimer implements Timer {
  @override
  bool get isActive => false;
  @override
  int get tick => 0;
  @override
  void cancel() {}
}

/// [a] e [b] iguais até o milésimo de px.
void perto(ui.Rect a, ui.Rect b) {
  expect(a.left, closeTo(b.left, 1e-3));
  expect(a.top, closeTo(b.top, 1e-3));
  expect(a.width, closeTo(b.width, 1e-3));
  expect(a.height, closeTo(b.height, 1e-3));
}

InkPointer _touch(int id, double x, double y, int t) =>
    (id: id, kind: InkPointerKind.touch, x: x, y: y, pressure: 1, tMs: t);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadAppFonts);
  late _Fonte fonte;
  late _Timers timers;
  setUp(() {
    fonte = _Fonte();
    timers = _Timers();
  });
  tearDown(() => fonte.dispose());

  /// As caixas de [trecho] na página [p].
  List<TextLineBox> caixas(DisplayPage p, String trecho) {
    final i = _texto.indexOf(trecho);
    return p.boxesOf(_unit, i, i + trecho.length);
  }

  /// Um desenho salvo sobre [trecho]: um traço de 2 pontos, 4 px acima da base, nas pontas do trecho.
  PageDrawing desenho(DisplayPage p, String trecho, int n) {
    final b = caixas(p, trecho).first;
    final i = _texto.indexOf(trecho);
    return (
      saved: (
        layerId: idTeste(n),
        annotationId: idTeste(n + 1),
        createdAt: DateTime.utc(2026, 10, 1),
        groupId: idTeste(n + 1),
      ),
      range: (unit: _unit, from: i, to: i + trecho.length),
      strokes: [
        InkStroke(
          tool: InkTool.pen.code,
          tip: 0,
          argb: 0xFFFF552E,
          widthCentiMm: 120,
          points: [
            InkPoint(b.rect.left, b.baseline - 4, 0.5, 0),
            InkPoint(b.rect.right, b.baseline - 4, 0.5, 8),
          ],
        ),
      ],
    );
  }

  AnnotationSession abrir({
    List<PageDrawing> Function(DisplayPage p)? desenhos,
    List<SessionNote> notas = const [],
  }) {
    final page = fonte.pageWith([
      for (final n in notas)
        SpaceCut(
          at: n.at,
          height: n.collapsed
              ? stripFlowHeight(t.lineHeight)
              : noteFlowHeight(n.lines),
          id: n.id,
        ),
    ]);
    final s = AnnotationSession(
      geometry: inkGeometryOf(page),
      anchors: _Ancoras(),
      drawings: desenhos?.call(page) ?? const [],
      highlights: const [],
      presets: presetsTeste(),
      repository: FakeInkRepository(),
      owner: usuarioTeste,
      userBookId: idTeste(1),
      startTimer: timers.start,
      now: () => DateTime.utc(2026, 10, 8, 12),
      ids: UuidV7Generator(clockMs: () => 1791500000000),
      pageSource: fonte,
      page: page,
      notes: notas,
      lineHeight: t.lineHeight,
    );
    addTearDown(s.dispose);
    return s;
  }

  /// A base da linha que tem "Vá, de ressaca." (a fresta da prancha 24), na página da sessão.
  double fresta(AnnotationSession s) => s.geometry.lines
      .firstWhere((l) => l.from < _ancora && l.to >= _ancora)
      .bottom;

  /// Um arrasto de 1 dedo (coordenadas da página; a tela soma os 30 px do modo) por [ys] em x = [x].
  void arrastar(
    AnnotationSession s,
    List<double> ys, {
    double x = 200,
    bool soltar = true,
  }) {
    s.pointerDown(_touch(1, x, ys.first + 30, 0));
    for (var i = 1; i < ys.length; i++) {
      s.pointerMove(_touch(1, x, ys[i] + 30, 8 * i));
    }
    if (soltar) s.pointerUp(_touch(1, x, ys.last + 30, 8 * ys.length));
  }

  /// Abre uma nota de [n] linhas pela fresta da prancha 24.
  SessionNote abrirNota(AnnotationSession s, {int n = 3}) {
    expect(s.setTool(AnnotationTool.space), isTrue);
    final y = fresta(s);
    final topoDaArea = y + openerMarginTop;
    arrastar(s, [y + 2, y + 20, topoDaArea + n * t.lineHeight - 2]);
    return s.notes.single;
  }

  group('Espaço (R1–R4, D-187)', () {
    test('sem a fonte da página, o Espaço não abre (como antes — D-163)', () {
      final s = AnnotationSession(
        geometry: inkGeometryOf(fonte.pageWith(const [])),
        anchors: _Ancoras(),
        drawings: const [],
        highlights: const [],
        presets: presetsTeste(),
        repository: FakeInkRepository(),
        owner: usuarioTeste,
        userBookId: idTeste(1),
        startTimer: timers.start,
      );
      addTearDown(s.dispose);
      expect(s.setTool(AnnotationTool.space), isFalse);
      expect(s.tool, AnnotationTool.pen);
    });

    test(
      'o arrasto: o abridor conta as linhas (1 a 12) e a página leva o abridor',
      () {
        final s = abrir();
        s.setTool(AnnotationTool.space);
        final y = fresta(s);
        final topo = y + openerMarginTop;
        arrastar(s, [y + 2, topo + t.lineHeight - 2], soltar: false);
        expect(s.opening.value!.lines, 1);
        expect(s.opening.value!.seam.at, _ancora);
        s.pointerMove(_touch(1, 200, topo + 3 * t.lineHeight - 2 + 30, 40));
        expect(s.opening.value!.lines, 3);
        expect(fonte.pedidos.last, [
          SpaceCut(
            at: _ancora,
            height: openerFlowHeight(3, t.lineHeight),
            id: spaceOpenerId,
          ),
        ]);
        expect(s.openerArea!.top, closeTo(y + openerMarginTop, 1e-6));
        expect(
          s.openerArea!.height,
          closeTo(openerAreaHeight(3, t.lineHeight), 1e-6),
        );
        // "É o que…" desceu a altura do abridor, sem recuo
        final e = caixas(s.page!, 'É o que').first;
        expect(e.rect.left, t.sideMargin);
        expect(
          e.rect.top,
          closeTo(y + openerFlowHeight(3, t.lineHeight), 1e-3),
        );
        s.pointerMove(_touch(1, 200, topo + 40 * t.lineHeight + 30, 48));
        expect(s.opening.value!.lines, 12);
      },
    );

    test('ao soltar: a nota aberta com as linhas do arrasto, um passo, e a Caneta volta', () {
      final s = abrir();
      final y = fresta(s);
      final nota = abrirNota(s);
      expect(
        (nota.at, nota.unit, nota.lines, nota.collapsed),
        (_ancora, _unit, 3, false),
      );
      expect(nota.strokes, isEmpty);
      expect(s.tool, AnnotationTool.pen);
      expect(s.opening.value, isNull);
      expect(s.canUndo, isTrue);
      perto(s.noteBox(nota.id)!, ui.Rect.fromLTWH(28, y + 30, 334, 150));
      final e = caixas(s.page!, 'É o que').first;
      expect(e.rect.top, closeTo(y + noteFlowHeight(3), 1e-3));
      s.undo();
      expect(s.notes, isEmpty);
      expect(
        caixas(s.page!, 'É o que').first.rect.top,
        closeTo(
          caixas(fonte.pageWith(const []), 'É o que').first.rect.top,
          1e-6,
        ),
      );
    });

    test('um toque sem arrastar, acima da 1ª linha ou dentro de uma nota não abre nada (R2, R5)', () {
      final s = abrir();
      s.setTool(AnnotationTool.space);
      final y = fresta(s);
      arrastar(s, [y + 2, y + 4]);
      expect(s.notes, isEmpty);
      expect(s.opening.value, isNull);
      arrastar(s, [-20, 200]);
      expect(s.notes, isEmpty);
      final nota = abrirNota(s);
      s.setTool(AnnotationTool.space);
      final caixa = s.noteBox(nota.id)!;
      arrastar(s, [caixa.center.dy, caixa.center.dy + 100]);
      expect(s.notes, hasLength(1));
      // a mesma âncora: a fresta logo acima da caixa leva à mesma frase
      arrastar(s, [y + 1, y + 120]);
      expect(s.notes, hasLength(1));
    });

    test('2 dedos durante o arrasto: o abridor some e a página volta', () {
      final s = abrir();
      s.setTool(AnnotationTool.space);
      final y = fresta(s);
      arrastar(s, [y + 2, y + 80], soltar: false);
      expect(s.opening.value, isNotNull);
      s.pointerDown(_touch(2, 100, y + 200, 50));
      s.pointerMove(_touch(2, 100, y + 220, 58));
      s.pointerMove(_touch(1, 200, y + 130, 58));
      expect(s.opening.value, isNull);
      expect(fonte.pedidos.last, isEmpty);
      s.pointerUp(_touch(1, 200, y + 130, 70));
      s.pointerUp(_touch(2, 100, y + 220, 70));
      expect(s.notes, isEmpty);
    });
  });

  group('a página do modo (R3)', () {
    test('cada desenho anda com as palavras dele; o desfazer volta; o salvo intocado não é regravado', () {
      final s = abrir(
        desenhos: (p) => [
          desenho(p, 'Olhos de ressaca?', 10),
          desenho(p, 'fluido misterioso', 20),
        ],
      );
      final antes = [...s.visibleStrokes];
      abrirNota(s);
      final depois = s.visibleStrokes;
      // a elipse (em cima) fica
      expect(depois[0], antes[0]);
      // a onda (embaixo) anda com "fluido misterioso"
      final nova = caixas(s.page!, 'fluido misterioso').first;
      expect(depois[1].points.first.x, closeTo(nova.rect.left, 1e-6));
      expect(depois[1].points.first.y, closeTo(nova.baseline - 4, 1e-6));
      expect(s.changes().layers, isEmpty);
      s.undo();
      for (var i = 0; i < 2; i++) {
        expect(
          s.visibleStrokes[i].points.first.x,
          closeTo(antes[i].points.first.x, 1e-9),
        );
        expect(
          s.visibleStrokes[i].points.first.y,
          closeTo(antes[i].points.first.y, 1e-9),
        );
      }
      expect(s.changes().layers, isEmpty);
    });

    test('a nota salva da página entra na sessão e no layout dela', () {
      final salva = SessionNote(
        id: 'espaco-1',
        unit: _unit,
        at: _ancora,
        lines: 3,
        collapsed: false,
        strokes: const [],
        createdAt: DateTime.utc(2026, 9, 20),
      );
      final s = abrir(notas: [salva]);
      expect(s.notes.single.id, 'espaco-1');
      expect(s.noteBox('espaco-1')!.height, 150);
      expect(
        fonte.pedidos,
        hasLength(1),
        reason: 'nada mudou: a página não é refeita',
      );
    });
  });

  group('a nota (R6–R9)', () {
    test('o traço que começa na caixa é da nota (unidade dela); o de fora é desenho', () {
      final s = abrir();
      final nota = abrirNota(s);
      final caixa = s.noteBox(nota.id)!;
      arrastar(s, [caixa.top + 30, caixa.top + 40, caixa.top + 60], x: 80);
      expect(s.notes.single.strokes, hasLength(1));
      final p = s.notes.single.strokes.single.stroke.points.first;
      expect(p.x, closeTo((80 - caixa.left) / caixa.width, 1e-9));
      expect(p.y, closeTo(30 / noteLinePx, 1e-9));
      expect(s.drawings, isEmpty);
      arrastar(s, [caixa.bottom + 60, caixa.bottom + 70], x: 80);
      expect(s.drawings, hasLength(1));
      // o Marca-texto na caixa vira tinta translúcida da nota (sem grifo)
      s.setTool(AnnotationTool.marker);
      arrastar(s, [caixa.top + 80, caixa.top + 80.5], x: 60);
      expect(s.notes.single.strokes.last.stroke.tool, InkTool.marker.code);
      expect(s.desk.items, isEmpty);
    });

    test('a Borracha apaga a tinta da nota; o Laço da caixa só pega a dela e move dentro dela', () {
      final s = abrir(desenhos: (p) => [desenho(p, 'fluido misterioso', 20)]);
      final nota = abrirNota(s);
      final caixa = s.noteBox(nota.id)!;
      arrastar(s, [caixa.top + 30, caixa.top + 32], x: 100);
      arrastar(s, [caixa.top + 70, caixa.top + 72], x: 100);
      s.setTool(AnnotationTool.lasso);
      // o contorno em volta do 1º traço, começando dentro da caixa
      s.pointerDown(_touch(1, 90, caixa.top + 20 + 30, 0));
      for (final (x, y) in [(115.0, 20.0), (115.0, 45.0), (90.0, 45.0)]) {
        s.pointerMove(_touch(1, x, caixa.top + y + 30, 8));
      }
      s.pointerUp(_touch(1, 90, caixa.top + 45 + 30, 16));
      expect(s.selection.value!.note, nota.id);
      expect(s.selection.value!.strokes, hasLength(1));
      // arrastar a seleção 21 px para baixo = meia linha da nota
      s.pointerDown(_touch(1, 100, caixa.top + 31 + 30, 20));
      s.pointerMove(_touch(1, 100, caixa.top + 52 + 30, 28));
      s.pointerUp(_touch(1, 100, caixa.top + 52 + 30, 36));
      final movido = s.notes.single.strokes.first.stroke.points.first;
      expect(movido.y, closeTo((30 + 21) / noteLinePx, 1e-9));
      // a Borracha passa no 2º traço
      s.setTool(AnnotationTool.eraser);
      arrastar(s, [caixa.top + 71, caixa.top + 71], x: 100);
      expect(s.notes.single.strokes, hasLength(1));
      s.undo();
      expect(s.notes.single.strokes, hasLength(2));
      expect(
        s.drawings,
        hasLength(1),
        reason: 'a onda fora da caixa não foi tocada',
      );
    });

    test('a alça (R7, D-186): de 42 em 42, de 1 a 12, sem subir além da tinta; um passo ao soltar', () {
      final s = abrir();
      final nota = abrirNota(s);
      final caixa = s.noteBox(nota.id)!;
      // tinta até a 2ª linha (y 100)
      arrastar(s, [caixa.top + 30, caixa.top + 100], x: 80);
      s.dragNoteHandle(nota.id, -42 * 2);
      expect(s.notes.single.lines, 2, reason: 'parou na última linha escrita');
      s.dragNoteHandle(nota.id, 42 * 20);
      expect(s.notes.single.lines, 12);
      expect(s.noteBox(nota.id)!.height, noteBoxHeight(12));
      s.dragNoteHandle(nota.id, 42 * 2);
      s.endNoteHandle(nota.id);
      expect(s.notes.single.lines, 5);
      s.undo();
      expect(s.notes.single.lines, 3);
      // soltar sem mudar não é passo
      s.dragNoteHandle(nota.id, 10);
      s.endNoteHandle(nota.id);
      s.undo();
      expect(
        s.notes.single.strokes,
        isEmpty,
        reason: 'o desfazer foi para o traço',
      );
    });

    test('recolher (R8): a faixa de uma linha no lugar da caixa; um passo', () {
      final s = abrir();
      final nota = abrirNota(s);
      final y = fresta(s);
      s.toggleNote(nota.id);
      expect(s.notes.single.collapsed, isTrue);
      perto(
        s.noteBox(nota.id)!,
        ui.Rect.fromLTWH(28, y + stripMargin, 334, t.lineHeight),
      );
      expect(
        caixas(s.page!, 'É o que').first.rect.top,
        closeTo(y + stripFlowHeight(t.lineHeight), 1e-3),
      );
      s.undo();
      expect(s.notes.single.collapsed, isFalse);
    });

    test('apagar (R9, D-185): some na hora com a pílula; o Desfazer dela volta só se for o último passo', () {
      final s = abrir();
      final nota = abrirNota(s);
      s.deleteNote(nota.id);
      expect(s.notes, isEmpty);
      expect(s.noteDeleted.value, nota.id);
      expect(timers.pending.last.$1, favoriteUndoLife);
      expect(s.undoNoteDeletion(), isTrue);
      expect(s.notes.single.id, nota.id);
      expect(s.noteDeleted.value, isNull);
      s.deleteNote(nota.id);
      s.toggleNote(nota.id); // não existe mais: nada
      final caixaDepois = abrirNota(s);
      expect(s.undoNoteDeletion(), isFalse);
      expect(s.notes.single.id, caixaDepois.id);
      // a pílula some sozinha
      s.deleteNote(caixaDepois.id);
      timers.pending.last.$2();
      expect(s.noteDeleted.value, isNull);
    });
  });
}

// G16.3 — a sessão do modo anotação (§3): a Caneta (pontos do leitor limpo, pressão simulada na captura, toque sem
// arrastar = 1 ponto), o desenho que o traço toca (D-162), a Reta (15°/4°, mínimo de 4 px), a Borracha (passada =
// 1 passo; só tinta — D-168), o Laço (≥ 50 %, arrastar move, tocar fora solta, Borracha com a seleção), 2 dedos
// movem a página com o batente (D-165), as ferramentas das fases seguintes (D-163), a espessura no pen_presets, o
// que o Concluir grava (âncora, moldura em em, página, capítulo, cartões, apagados), o rascunho a cada 5 s e no
// segundo plano (D-166), o Concluir e a falha ao salvar, e a interação a cada toque (D-95).
// G17: os ajustes da caneta e do marca-texto no pen_presets (R6, D-175), a cor de cada ferramenta e o painel aberto
// (R1, R2, R4); o marca-texto (R20–R23, D-173) e o que o Concluir grava dele (R24).
import 'dart:async';

import 'package:app_leitura/core/data/ids/uuid_v7.dart';
import 'package:app_leitura/features/reader/annotations/domain/annotation.dart'
    show AnnotationSource, FillHeight, HighlightStyle;
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_commands.dart';
import 'package:app_leitura/features/reader/annotations/ink/highlight_desk.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_units.dart';
import 'package:app_leitura/features/reader/application/annotation_anchors.dart';
import 'package:app_leitura/features/reader/application/annotation_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_ink_repository.dart';
import '../../../support/personal_builders.dart';

/// Uma página sintética de 4 linhas (bases 100; 135,25; 170,5; 205,75 — em 20,5), nas coordenadas do leitor limpo.
const _lines = [
  [('Olhos', 28.0, 83.0), ('de', 89.0, 109.0), ('ressaca', 115.0, 190.0)],
  [('a', 28.0, 39.0), ('vaga', 45.0, 92.0), ('que', 98.0, 133.0)],
  [('da', 28.0, 50.0), ('praia', 56.0, 105.0), ('nos', 111.0, 140.0)],
  [('dias', 28.0, 70.0), ('de', 76.0, 96.0), ('ressaca', 102.0, 177.0)],
];
const _baselines = [100.0, 135.25, 170.5, 205.75];
const _em = 20.5;
const _unit = 4;

late String _text;

InkPageGeometry _geometry() {
  final text = StringBuffer();
  final lines = <InkLine>[];
  for (var i = 0; i < _lines.length; i++) {
    final words = <InkWord>[];
    for (final (word, left, right) in _lines[i]) {
      if (text.isNotEmpty) text.write(' ');
      words.add((
        from: text.length,
        to: text.length + word.length,
        left: left,
        right: right,
      ));
      text.write(word);
    }
    final top = _baselines[i] - 26;
    lines.add(
      InkLine(
        unit: _unit,
        from: words.first.from,
        to: words.last.to,
        top: top,
        bottom: top + 35.25,
        baseline: _baselines[i],
        em: _em,
        left: words.first.left,
        right: words.last.right,
        words: words,
      ),
    );
  }
  _text = text.toString();
  return InkPageGeometry(lines);
}

/// As âncoras de um capítulo que não abre na hora de gravar (o texto lança).
final class _Quebradas implements AnnotationAnchors {
  @override
  String get sha => shaTeste;

  @override
  String? textOf(int spine) => throw StateError('capítulo ilegível');

  @override
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset) =>
      (refPage: 159, chapterIndex: 31);
}

final class _Anchors implements AnnotationAnchors {
  @override
  String get sha => shaTeste;

  @override
  String? textOf(int spine) => spine == _unit ? _text : null;

  @override
  ({int refPage, int chapterIndex}) placeOf(int spine, int offset) =>
      (refPage: 159, chapterIndex: 31);
}

/// O relógio e os temporizadores do teste.
final class _Timers {
  final List<(Duration, void Function())> pending = [];
  Timer start(Duration d, void Function() f) {
    pending.add((d, f));
    return _NoTimer();
  }

  /// Dispara o temporizador mais antigo (o do rascunho).
  void fire() => pending.removeAt(0).$2();
}

final class _NoTimer implements Timer {
  @override
  bool get isActive => false;
  @override
  int get tick => 0;
  @override
  void cancel() {}
}

InkPointer _touch(int id, double x, double y, int t) =>
    (id: id, kind: InkPointerKind.touch, x: x, y: y, pressure: 1, tMs: t);

InkPointer _pen(int id, double x, double y, int t, {double pressure = 0.7}) => (
  id: id,
  kind: InkPointerKind.stylus,
  x: x,
  y: y,
  pressure: pressure,
  tMs: t,
);

/// Um desenho salvo da página: o traço de [points] (coordenadas do leitor limpo) preso ao trecho [from]…[to).
PageDrawing _saved(
  int n, {
  required int from,
  required int to,
  required List<(double, double)> points,
  int group = 0,
}) => (
  saved: (
    layerId: idTeste(n),
    annotationId: idTeste(n + 1),
    createdAt: DateTime.utc(2026, 10, 1),
    groupId: idTeste(group == 0 ? n + 1 : group),
  ),
  range: (unit: _unit, from: from, to: to),
  strokes: [
    InkStroke(
      tool: InkTool.pen.code,
      tip: 0,
      argb: 0xFF552CB7,
      widthCentiMm: 120,
      points: [for (final (x, y) in points) InkPoint(x, y, 0.5, 0)],
    ),
  ],
);

void main() {
  late FakeInkRepository repo;
  late _Timers timers;
  late List<PenPresets> savedPresets;
  late List<Object> errors;
  late List<InkRefusal> refusals;
  late int interactions;
  var now = DateTime.utc(2026, 10, 8, 10);

  AnnotationSession open({
    List<PageDrawing> drawings = const [],
    List<PageHighlight> highlights = const [],
    PenPresets? presets,
    double panLimit = 100,
    AnnotationAnchors? anchors,
    String draftId = 'sessao-1',
    List<DeskHighlight>? desk,
  }) {
    final s = AnnotationSession(
      geometry: _geometry(),
      anchors: anchors ?? _Anchors(),
      draftId: draftId,
      deskHighlights: desk,
      drawings: drawings,
      highlights: highlights,
      presets: presets ?? presetsTeste(),
      repository: repo,
      owner: usuarioTeste,
      userBookId: idTeste(1),
      startTimer: timers.start,
      now: () => now,
      ids: UuidV7Generator(clockMs: () => now.millisecondsSinceEpoch),
      onError: (e, _) => errors.add(e),
      onInteraction: () => interactions++,
      onRefused: refusals.add,
      savePresets: (p) async => savedPresets.add(p),
    )..panLimit = panLimit;
    addTearDown(s.dispose);
    return s;
  }

  /// Um traço de 1 dedo pelos pontos [pts] (coordenadas da tela), de [t] em 8 ms.
  void draw(
    AnnotationSession s,
    List<(double, double)> pts, {
    int id = 1,
    int t = 0,
  }) {
    s.pointerDown(_touch(id, pts.first.$1, pts.first.$2, t));
    for (var i = 1; i < pts.length; i++) {
      s.pointerMove(_touch(id, pts[i].$1, pts[i].$2, t + 8 * i));
    }
    s.pointerUp(_touch(id, pts.last.$1, pts.last.$2, t + 8 * pts.length));
  }

  setUp(() {
    repo = FakeInkRepository();
    timers = _Timers();
    savedPresets = [];
    errors = [];
    refusals = [];
    interactions = 0;
    now = DateTime.utc(2026, 10, 8, 10);
  });

  group('Caneta', () {
    test('o traço fica em coordenadas do leitor limpo, com a ponta, a cor e a largura do pen_presets', () {
      final s = open();
      expect(s.tool, AnnotationTool.pen);
      draw(s, [(40, 140), (50, 142), (60, 141)]);
      final d = s.drawings.single;
      final st = d.strokes.single.stroke;
      expect(st.tool, InkTool.pen.code);
      expect(st.tip, tipCode(PenTip.ballpoint));
      expect(st.argb, 0xFFFF552E);
      expect(st.widthCentiMm, 120, reason: '1,2 mm na Média (D-159)');
      expect(
        [for (final p in st.points) (p.x, p.y)],
        [(40, 110), (50, 112), (60, 111)],
      );
      expect(st.points.first.tMs, 0);
      expect(st.points.last.tMs, 16);
      expect(s.canUndo, isTrue);
      expect(s.canRedo, isFalse);
      expect(interactions, 1, reason: 'desenhar é interação (D-95)');
    });

    test('o dedo: a pressão é simulada na captura e gravada no ponto; a caneta grava a dela', () {
      final s = open();
      draw(s, [(40, 140), (60, 140), (61, 140)]);
      final p = s.drawings.single.strokes.single.stroke.points;
      expect(p.first.pressure, 0.25);
      expect(p[1].pressure, isNot(0.25));
      s.pointerDown(_pen(9, 200, 230, 0, pressure: 0.8));
      s.pointerMove(_pen(9, 220, 230, 8, pressure: 0.6));
      s.pointerUp(_pen(9, 220, 230, 16, pressure: 0.6));
      final pen = s.drawings.last.strokes.single.stroke.points;
      expect([for (final q in pen) q.pressure], [0.8, 0.6]);
    });

    test(
      'toque sem arrastar = um ponto; o traço ao vivo aparece e some no fim',
      () {
        final s = open();
        s.pointerDown(_touch(1, 40, 140, 0));
        expect(s.live.value, isA<LiveStroke>());
        expect(s.touch.value, (x: 40.0, y: 140.0));
        s.pointerMove(_touch(1, 45, 141, 8));
        expect((s.live.value! as LiveStroke).stroke.points, hasLength(2));
        expect(s.touch.value, (x: 45.0, y: 141.0));
        s.pointerUp(_touch(1, 45, 141, 16));
        expect(s.live.value, isNull);
        expect(s.touch.value, isNull);
        s.pointerDown(_touch(2, 100, 200, 30));
        s.pointerUp(_touch(2, 100, 200, 40));
        expect(s.drawings.last.strokes.single.stroke.points, hasLength(1));
      },
    );

    test('um evento com o tempo voltando não volta o tempo do traço nem quebra o BNK1', () {
      final s = open();
      s.pointerDown(_pen(1, 40, 140, 100));
      s.pointerMove(_pen(1, 50, 140, 120));
      s.pointerMove(_pen(1, 60, 140, 90));
      s.pointerUp(_pen(1, 60, 140, 130));
      expect(
        [for (final p in s.visibleStrokes.single.points) p.tMs],
        [0, 20, 20],
      );
      expect(() => s.changes(), returnsNormally);
      // a Reta também
      s.setTool(AnnotationTool.line);
      s.pointerDown(_pen(1, 40, 200, 500));
      s.pointerMove(_pen(1, 90, 200, 400));
      s.pointerUp(_pen(1, 90, 200, 410));
      expect(s.visibleStrokes.last.points.last.tMs, greaterThanOrEqualTo(0));
      expect(() => s.changes(), returnsNormally);
    });

    test('com a caneta do aparelho, o indicador de toque não aparece', () {
      final s = open();
      s.pointerDown(_pen(9, 40, 140, 0));
      expect(s.touch.value, isNull);
      s.pointerUp(_pen(9, 40, 140, 8));
    });

    test('o traço que toca um desenho (folga de meia linha) entra nele; longe, começa outro (D-162)', () {
      final s = open();
      draw(s, [(30, 120), (80, 120)]);
      draw(s, [(30, 125), (80, 135)], id: 2);
      expect(s.drawings, hasLength(1));
      expect(s.drawings.single.strokes, hasLength(2));
      draw(s, [(30, 220), (80, 220)], id: 3);
      expect(s.drawings, hasLength(2));
    });

    test('o desenho que passaria de 256 KiB fecha e o traço começa outro', () {
      final s = open();
      final long = [for (var i = 0; i < 40000; i++) (40.0 + (i % 7), 140.0)];
      draw(s, long);
      draw(s, long, id: 2);
      expect(s.drawings, hasLength(2));
    });

    test('a espessura muda a largura do próximo traço e grava no pen_presets na hora', () {
      final s = open();
      s.setStrokeSize(StrokeSize.thin);
      expect(s.strokeSize, StrokeSize.thin);
      expect(savedPresets.single.strokeSize, StrokeSize.thin);
      draw(s, [(40, 140), (60, 140)]);
      expect(s.drawings.single.strokes.single.stroke.widthCentiMm, 72);
    });
  });

  group('Reta', () {
    test('gruda em 15° com menos de 4°; com menos de 4 px não cria nada; grava 2 pontos', () {
      final s = open()..setTool(AnnotationTool.line);
      s.pointerDown(_touch(1, 30, 130, 0));
      s.pointerMove(_touch(1, 130, 133, 8));
      final live = s.live.value! as LiveLine;
      expect(live.stroke.points.last.y, closeTo(100, 1e-9));
      s.pointerUp(_touch(1, 130, 133, 16));
      final st = s.drawings.single.strokes.single.stroke;
      expect(st.tool, InkTool.line.code);
      expect(st.points, hasLength(2));
      expect(st.points.first.y, 100);
      expect(st.points.last.y, closeTo(100, 1e-9));
      expect(st.points.last.x, closeTo(130.04, 0.01));
      s.pointerDown(_touch(2, 30, 230, 30));
      s.pointerMove(_touch(2, 33, 230, 38));
      s.pointerUp(_touch(2, 33, 230, 46));
      expect(s.drawings, hasLength(1));
    });
  });

  group('Borracha', () {
    test('apaga o traço inteiro tocado; a passada é um passo do desfazer; o traço some já na passada', () {
      final s = open();
      draw(s, [(30, 130), (80, 130)]);
      draw(s, [(30, 230), (80, 230)], id: 2);
      s.setTool(AnnotationTool.eraser);
      s.pointerDown(_touch(3, 50, 160, 0));
      s.pointerMove(_touch(3, 50, 125, 8));
      expect(s.visibleStrokes, hasLength(1), reason: 'some durante a passada');
      s.pointerMove(_touch(3, 52, 140, 16));
      s.pointerUp(_touch(3, 52, 140, 24));
      expect(s.drawings, hasLength(1));
      s.undo();
      expect(s.drawings, hasLength(2));
      s.redo();
      expect(s.drawings, hasLength(1));
    });

    test(
      'só tinta (D-168): o grifo à mão tocado é apagado; o de seleção fica',
      () {
        final s = open(
          highlights: [
            (
              id: idTeste(70),
              ink: true,
              areas: [const InkRect(28, 80, 109, 105)],
            ),
            (
              id: idTeste(71),
              ink: false,
              areas: [const InkRect(28, 115, 92, 140)],
            ),
          ],
        )..setTool(AnnotationTool.eraser);
        s.pointerDown(_touch(1, 60, 100, 0));
        s.pointerMove(_touch(1, 60, 165, 8));
        expect(s.hiddenHighlights, {idTeste(70)});
        s.pointerUp(_touch(1, 60, 165, 16));
        expect(s.changes().erasedHighlights, {idTeste(70)});
      },
    );

    test('o cancel da passada não apaga nada', () {
      final s = open();
      draw(s, [(30, 130), (80, 130)]);
      s.setTool(AnnotationTool.eraser);
      s.pointerDown(_touch(3, 50, 130, 0));
      expect(s.visibleStrokes, isEmpty, reason: 'tocou o traço');
      s.pointerCancel(_touch(3, 50, 130, 8));
      expect(s.drawings, hasLength(1));
      expect(s.visibleStrokes, hasLength(1));
    });
  });

  group('Laço', () {
    test('seleciona com ≥ 50 % dos pontos dentro; arrastar dentro move; tocar fora solta', () {
      final s = open();
      draw(s, [(30, 130), (80, 130)]);
      draw(s, [(30, 230), (80, 230)], id: 2);
      s.setTool(AnnotationTool.lasso);
      draw(s, [(20, 110), (100, 110), (100, 160), (20, 160)], id: 3);
      final sel = s.selection.value!;
      expect(sel.strokes, hasLength(1));
      expect(s.live.value, isNull);
      // o retângulo da seleção: 6 de folga em volta dos traços (D-21)
      final (f, b) = (sel.frame, sel.bounds);
      expect(
        (
          b.left - f.left,
          f.right - b.right,
          b.top - f.top,
          f.bottom - b.bottom,
        ),
        (6.0, 6.0, 6.0, 6.0),
      );
      // arrastar dentro do retângulo move os traços, ao vivo e depois de soltar
      s.pointerDown(_touch(4, 50, 130, 100));
      s.pointerMove(_touch(4, 50, 190, 108));
      expect(s.selection.value!.dy, 60);
      s.pointerUp(_touch(4, 50, 190, 116));
      expect(s.selection.value!.dy, 0);
      final moved = s.drawings.firstWhere(
        (d) => d.strokes.any((x) => sel.strokes.contains(x.id)),
      );
      expect(moved.strokes.single.stroke.points.first.y, 160);
      // tocar fora solta
      s.pointerDown(_touch(5, 300, 400, 200));
      s.pointerUp(_touch(5, 300, 400, 208));
      expect(s.selection.value, isNull);
    });

    test('trocar de ferramenta ou desfazer no meio do arrasto do Laço não quebra (o arrasto acaba)', () {
      for (final trocar in <void Function(AnnotationSession)>[
        (s) => s.setTool(AnnotationTool.pen),
        (s) => s.undo(),
      ]) {
        final s = open();
        draw(s, [(30, 130), (80, 130)]);
        s.setTool(AnnotationTool.lasso);
        draw(s, [(20, 110), (100, 110), (100, 160), (20, 160)], id: 3);
        expect(s.selection.value, isNotNull);
        s.pointerDown(_touch(4, 50, 130, 100));
        s.pointerMove(_touch(4, 50, 150, 108));
        trocar(s);
        expect(s.selection.value, isNull);
        expect(() => s.pointerMove(_touch(4, 50, 170, 116)), returnsNormally);
        expect(() => s.pointerUp(_touch(4, 50, 170, 124)), returnsNormally);
        expect(s.live.value, isNull);
      }
    });

    test('a seleção que juntaria mais de 256 KiB não se move (os traços ficam onde estavam) e a tela avisa (D-191)', () {
      final s = open();
      // 2 traços longos de zigue-zague, em linhas longe (2 desenhos que cabem sozinhos e não juntos)
      for (final (id, y) in const [(1, 126.0), (2, 232.0)]) {
        s.pointerDown(_pen(id, 30, y, 0));
        for (var i = 1; i <= 30000; i++) {
          s.pointerMove(_pen(id, i.isEven ? 30 : 180, y + (i % 3), 8 * i));
        }
        s.pointerUp(_pen(id, 30, y, 8 * 30001));
      }
      expect(s.drawings, hasLength(2));
      // com a caneta do aparelho na sessão, só ela desenha (o dedo move a página)
      s.setTool(AnnotationTool.lasso);
      s.pointerDown(_pen(3, 20, 110, 0));
      for (final (x, y) in const [
        (200.0, 110.0),
        (200.0, 250.0),
        (20.0, 250.0),
      ]) {
        s.pointerMove(_pen(3, x, y, 8));
      }
      s.pointerUp(_pen(3, 20, 250, 16));
      expect(s.selection.value!.strokes, hasLength(2));
      final antes = s.visibleStrokes;
      expect(refusals, isEmpty);
      s.pointerDown(_pen(4, 100, 180, 100));
      s.pointerMove(_pen(4, 100, 190, 108));
      s.pointerUp(_pen(4, 100, 190, 116));
      expect(s.drawings, hasLength(2));
      expect(s.visibleStrokes, antes);
      expect(s.selection.value!.dy, 0);
      expect(refusals, [InkRefusal.selectionTooBig]);
      // só um dos traços: ele se move, sem aviso
      s.pointerDown(_pen(5, 20, 110, 200));
      for (final (x, y) in const [
        (200.0, 110.0),
        (200.0, 150.0),
        (20.0, 150.0),
      ]) {
        s.pointerMove(_pen(5, x, y, 208));
      }
      s.pointerUp(_pen(5, 20, 150, 216));
      expect(s.selection.value!.strokes, hasLength(1));
      final topo = s.selection.value!.bounds.top;
      s.pointerDown(_pen(6, 100, 130, 300));
      s.pointerMove(_pen(6, 100, 140, 308));
      s.pointerUp(_pen(6, 100, 140, 316));
      expect(s.selection.value!.bounds.top, closeTo(topo + 10, 1e-9));
      expect(refusals, [InkRefusal.selectionTooBig]);
    });

    test('mover uma seleção que cabe não avisa', () {
      final s = open();
      draw(s, [(30, 130), (80, 130)]);
      s.setTool(AnnotationTool.lasso);
      draw(s, [(20, 110), (100, 110), (100, 160), (20, 160)], id: 3);
      draw(s, [(50, 130), (50, 150)], id: 4, t: 100);
      expect(s.visibleStrokes.single.points.first.y, 120);
      expect(refusals, isEmpty);
    });

    test('a Borracha com a seleção apaga os traços selecionados (1 passo) e fica ativa', () {
      final s = open();
      draw(s, [(30, 130), (80, 130)]);
      s.setTool(AnnotationTool.lasso);
      draw(s, [(20, 110), (100, 110), (100, 160), (20, 160)], id: 3);
      expect(s.selection.value, isNotNull);
      s.setTool(AnnotationTool.eraser);
      expect(s.tool, AnnotationTool.eraser);
      expect(s.drawings, isEmpty);
      expect(s.selection.value, isNull);
      s.undo();
      expect(s.drawings, hasLength(1));
    });
  });

  group('página e dedos', () {
    test('2 dedos sobem a página até o limite, com o batente; o traço desenhado depois desconta o deslocamento', () {
      final s = open(panLimit: 50);
      s.pointerDown(_touch(1, 100, 300, 0));
      s.pointerDown(_touch(2, 200, 300, 200));
      // o 2º dedo depois de 150 ms termina o traço (aqui, de 1 ponto) e a página passa a mover
      expect(s.drawings, hasLength(1));
      expect(s.live.value, isNull);
      s.pointerMove(_touch(1, 100, 260, 208));
      s.pointerMove(_touch(2, 200, 260, 208));
      expect(s.panOffset, -40);
      expect(s.panning, isTrue);
      s.pointerMove(_touch(1, 100, 230, 216));
      s.pointerMove(_touch(2, 200, 230, 216));
      expect(s.panOffset, closeTo(-50 - 20 / 3, 1e-9));
      s.pointerUp(_touch(1, 100, 230, 224));
      s.pointerUp(_touch(2, 200, 230, 224));
      expect(s.panOffset, -50, reason: 'volta do batente');
      expect(s.panning, isFalse);
      draw(s, [(40, 140), (60, 140)], id: 3, t: 300);
      expect(s.drawings.last.strokes.single.stroke.points.first.y, 160);
    });

    test('o 2º dedo até 150 ms descarta o traço', () {
      final s = open();
      s.pointerDown(_touch(1, 100, 300, 0));
      s.pointerMove(_touch(1, 110, 300, 8));
      s.pointerDown(_touch(2, 200, 300, 100));
      expect(s.live.value, isNull);
      s.pointerUp(_touch(1, 100, 300, 120));
      s.pointerUp(_touch(2, 200, 300, 120));
      expect(s.drawings, isEmpty);
      expect(s.canUndo, isFalse);
    });
  });

  group('ferramentas', () {
    test('o Espaço é da G18 (D-163): a ferramenta atual continua; o Marca-texto vale (G17)', () {
      final s = open();
      expect(s.setTool(AnnotationTool.space), isFalse);
      expect(s.tool, AnnotationTool.pen);
      expect(s.setTool(AnnotationTool.marker), isTrue);
      expect(s.tool, AnnotationTool.marker);
      expect(s.setTool(AnnotationTool.lasso), isTrue);
      expect(s.tool, AnnotationTool.lasso);
    });
  });

  group('ajustes da G17 (R2, R6, R12)', () {
    test(
      'ponta, espessura e cor da caneta mudam o preset e gravam uma vez cada',
      () {
        final s = open();
        var avisos = 0;
        s.addListener(() => avisos++);
        s.setPenTip(PenTip.fountain);
        s.setPenWidth(2.0);
        s.setPenColor('#058CD7');
        expect(s.presets.penTip, PenTip.fountain);
        expect(s.presets.penWidthMm, 2.0);
        expect(s.presets.penColor, '#058CD7');
        expect(savedPresets, hasLength(3));
        expect(savedPresets.last, s.presets);
        expect(avisos, 3);
        // sem mudança, nada
        s.setPenTip(PenTip.fountain);
        s.setPenWidth(2.0);
        expect(savedPresets, hasLength(3));
      },
    );

    test(
      'o arrasto só muda; ao soltar grava, mesmo com o mesmo valor (R6)',
      () {
        final s = open();
        s.setPenWidth(1.5, save: false);
        s.setPenWidth(1.8, save: false);
        s.setPenColor('#12AB34', save: false);
        expect(savedPresets, isEmpty);
        expect((s.presets.penWidthMm, s.presets.penColor), (1.8, '#12AB34'));
        s.setPenWidth(1.8);
        expect(savedPresets, hasLength(1));
        expect(savedPresets.single.penColor, '#12AB34');
        s.setPenColor('#12AB34');
        expect(savedPresets, hasLength(1));
      },
    );

    test('favoritas: "+" junta a cor atual no fim; nada se ela já está ou com 12 (D-175)', () {
      final s = open();
      expect(s.addFavorite(), isFalse); // o coral já é favorito
      s.setPenColor('#12AB34');
      expect(s.addFavorite(), isTrue);
      expect(s.presets.favoriteColors.last, '#12AB34');
      expect(s.presets.favoriteColors, hasLength(7));
      expect(s.addFavorite(), isFalse);
      for (var i = 0; i < 5; i++) {
        s.setPenColor('#00000$i');
        expect(s.addFavorite(), isTrue);
      }
      expect(s.presets.favoriteColors, hasLength(12));
      s.setPenColor('#ABCDEF');
      expect(s.addFavorite(), isFalse);
      expect(s.presets.favoriteColors, hasLength(12));
    });

    test('D-248: o "+" com a cor já favorita avisa ("Essa cor já está nas favoritas." por 4 s); juntar ou tirar '
        'apaga o aviso; com 12, nada', () {
      final s = open();
      expect(s.favoriteAlready.value, isFalse);
      expect(s.addFavorite(), isFalse); // o coral já é favorito
      expect(s.favoriteAlready.value, isTrue);
      expect(timers.pending.last.$1, favoriteUndoLife);
      timers.pending.removeLast().$2();
      expect(s.favoriteAlready.value, isFalse);
      expect(s.addFavorite(), isFalse);
      s.setPenColor('#12AB34');
      expect(s.addFavorite(), isTrue);
      expect(s.favoriteAlready.value, isFalse, reason: 'juntou: o aviso sai');
      expect(s.addFavorite(), isFalse);
      expect(s.favoriteAlready.value, isTrue);
      s.removeFavorite('#058CD7');
      expect(
        s.favoriteAlready.value,
        isFalse,
        reason: 'a pílula do Desfazer fica no lugar',
      );
      for (var i = 0; i < 5; i++) {
        s.setPenColor('#00000$i');
        s.addFavorite();
      }
      s.setPenColor('#0000AA');
      s.addFavorite();
      expect(s.presets.favoriteColors, hasLength(12));
      s.setPenColor('#ABCDEF');
      expect(s.addFavorite(), isFalse);
      expect(
        s.favoriteAlready.value,
        isFalse,
        reason: 'com 12 o "+" nem aparece',
      );
    });

    test('D-248 (T01): o aviso não fica velho — trocar de cor ou fechar o painel o apaga; com o Desfazer na tela, o '
        '"+" não arma um aviso escondido atrás dele', () {
      final s = open();
      s.openPanel(AnnotationTool.pen);
      expect(s.addFavorite(), isFalse);
      expect(s.favoriteAlready.value, isTrue);
      s.setPenColor('#12AB34');
      expect(s.favoriteAlready.value, isFalse, reason: 'a cor mudou');
      s.setPenColor('#FF552E');
      expect(s.addFavorite(), isFalse);
      s.setPenColor('#FF552E');
      expect(s.favoriteAlready.value, isTrue, reason: 'a mesma cor');
      s.closePanel();
      expect(s.favoriteAlready.value, isFalse, reason: 'o painel fechou');
      // a pílula do Desfazer na tela: o "+" com outra favorita não arma o aviso (ele apareceria sozinho depois)
      s.openPanel(AnnotationTool.pen);
      s.removeFavorite('#058CD7');
      final antes = timers.pending.length;
      expect(s.addFavorite(), isFalse);
      expect(s.favoriteAlready.value, isFalse);
      expect(timers.pending, hasLength(antes));
    });

    test('tirar devolve o lugar; desfazer põe de volta no mesmo lugar; pode ficar sem nenhuma', () {
      final s = open();
      final antes = s.presets.favoriteColors;
      final i = s.removeFavorite('#058cd7');
      expect(i, 2);
      expect(s.presets.favoriteColors, isNot(contains('#058CD7')));
      s.restoreFavorite('#058CD7', i);
      expect(s.presets.favoriteColors, antes);
      expect(s.removeFavorite('#ABCDEF'), -1);
      for (final c in antes) {
        s.removeFavorite(c);
      }
      expect(s.presets.favoriteColors, isEmpty);
      expect(savedPresets, hasLength(2 + antes.length));
    });

    test('tirar mostra a pílula por 4 s; o Desfazer dela devolve ao lugar e some com ela (D-175)', () {
      final s = open();
      final i = s.removeFavorite('#058CD7');
      expect(s.favoriteRemoved.value, (hex: '#058CD7', index: i));
      expect(timers.pending.last.$1, const Duration(seconds: 4));
      s.undoFavoriteRemoval();
      expect(s.favoriteRemoved.value, isNull);
      expect(s.presets.favoriteColors[i], '#058CD7');
      s.removeFavorite('#00995E');
      timers.pending.removeLast().$2();
      expect(s.favoriteRemoved.value, isNull);
      expect(s.presets.favoriteColors, isNot(contains('#00995E')));
      // sem pílula, o Desfazer não faz nada
      s.undoFavoriteRemoval();
      expect(s.presets.favoriteColors, isNot(contains('#00995E')));
    });

    test('marca-texto: estilo, cor e altura gravam', () {
      final s = open();
      s.setHighlighterStyle(HighlightStyle.wavy);
      s.setHighlighterColor('#FFC1C6');
      s.setHighlighterHeight(FillHeight.high);
      expect(
        (
          s.presets.highlighterStyle,
          s.presets.highlighterColor,
          s.presets.highlighterHeight,
        ),
        (HighlightStyle.wavy, '#FFC1C6', FillHeight.high),
      );
      expect(savedPresets, hasLength(3));
    });

    test('a cor da ferramenta: caneta com Caneta e Reta, marca-texto com o Marca-texto, a última com Borracha e Laço (R2)', () {
      final s = open();
      s.setHighlighterColor('#FFC1C6');
      expect(s.color, 0xFFFF552E);
      s.setTool(AnnotationTool.line);
      expect(s.color, 0xFFFF552E);
      s.setTool(AnnotationTool.eraser);
      expect(s.color, 0xFFFF552E);
      s.setTool(AnnotationTool.marker);
      expect(s.color, 0xFFFFC1C6);
      s.setTool(AnnotationTool.lasso);
      expect(s.color, 0xFFFFC1C6);
      expect(s.inkTool, AnnotationTool.marker);
    });

    test('o painel: Caneta e Reta abrem o da caneta; Marca-texto o dele; Borracha e Laço o da última de tinta (R1, R2)', () {
      final s = open();
      s.openPanel(AnnotationTool.pen);
      expect(s.panel.value, (kind: PanelKind.pen, from: AnnotationTool.pen));
      s.closePanel();
      expect(s.panel.value, isNull);
      s.openPanel(AnnotationTool.line);
      expect(s.panel.value, (kind: PanelKind.pen, from: AnnotationTool.line));
      s.openPanel(AnnotationTool.eraser);
      // a última de tinta ainda é a Caneta
      expect(s.panel.value, (kind: PanelKind.pen, from: AnnotationTool.pen));
      s.setTool(AnnotationTool.marker);
      s.openPanel(AnnotationTool.marker);
      expect(s.panel.value, (
        kind: PanelKind.marker,
        from: AnnotationTool.marker,
      ));
      s.setTool(AnnotationTool.eraser);
      // trocar de ferramenta fecha o painel (R4)
      expect(s.panel.value, isNull);
      s.openPanel(AnnotationTool.eraser);
      expect(s.panel.value, (
        kind: PanelKind.marker,
        from: AnnotationTool.marker,
      ));
      // o Espaço recusa e fecha (R1)
      expect(s.setTool(AnnotationTool.space), isFalse);
      expect(s.panel.value, isNull);
      s.openPanel(AnnotationTool.space);
      expect(s.panel.value, isNull);
    });

    test('a falha ao gravar o preset vai ao relatório', () async {
      final s = AnnotationSession(
        geometry: _geometry(),
        anchors: _Anchors(),
        drawings: const [],
        highlights: const [],
        presets: presetsTeste(),
        repository: repo,
        owner: usuarioTeste,
        userBookId: idTeste(1),
        startTimer: timers.start,
        onError: (e, _) => errors.add(e),
        savePresets: (_) async => throw StateError('disco cheio'),
      );
      addTearDown(s.dispose);
      s.setPenTip(PenTip.brush);
      await Future<void>.delayed(Duration.zero);
      expect(errors.single, isA<StateError>());
    });
  });

  group('Marca-texto (R20–R23, D-173)', () {
    // a linha 0 na tela: a página desce 30 (o modo); "de" 89–109 e "ressaca" 115–190
    const y0 = 100 - 8 + 30.0;
    DeskHighlight grifo(
      String id,
      int start,
      int end, {
      bool mao = false,
      String cor = '#FED170',
    }) => DeskHighlight(
      id: id,
      unit: _unit,
      start: start,
      end: end,
      color: cor,
      style: HighlightStyle.fill,
      height: FillHeight.medium,
      ink: mao,
      groupId: 'g-$id',
      createdAt: DateTime.utc(2026, 9, 1),
    );

    test('ao vivo: ferramenta 3, a cor do marca-texto a 90 %, a largura da faixa Média da linha (R20)', () {
      final s = open(desk: const [])..setTool(AnnotationTool.marker);
      s.pointerDown(_touch(1, 90, y0, 0));
      s.pointerMove(_touch(1, 120, y0, 8));
      final live = s.live.value! as LiveMarker;
      expect(live.stroke.tool, InkTool.marker.code);
      expect(live.stroke.argb, 0xE6FED170);
      // 80 % da caixa das letras (a linha inteira, 35,25, no teste)
      expect(dpOfCentiMm(live.stroke.widthCentiMm), closeTo(0.8 * 35.25, 0.02));
      expect(live.stroke.points.map((p) => (p.x, p.y)), [
        (90.0, 92.0),
        (120.0, 92.0),
      ]);
      s.pointerUp(_touch(1, 120, y0, 16));
      expect(s.live.value, isNull);
    });

    test('ao soltar sobre "de ressaca": um grifo à mão nas palavras, um passo no desfazer, nenhum traço (R21, R23)', () {
      final s = open(desk: const [])..setTool(AnnotationTool.marker);
      draw(s, [(90, y0), (140, y0 + 3), (188, y0)]);
      expect(s.drawings, isEmpty);
      final h = s.desk.items.single;
      expect(_text.substring(h.start, h.end), 'de ressaca');
      expect(
        (h.color, h.style, h.height, h.ink, h.groupId),
        ('#FED170', HighlightStyle.fill, FillHeight.medium, true, h.id),
      );
      expect(s.paintedInkHighlights!.single.range, (
        unit: _unit,
        from: h.start,
        to: h.end,
      ));
      expect(s.paintedHighlights, isEmpty);
      expect(s.countDelta, {'#FED170': 1});
      s.undo();
      expect(s.desk.items, isEmpty);
      expect(s.countDelta, isEmpty);
      s.redo();
      expect(s.desk.items.single, h);
    });

    test('D-40: a contagem de cada cor = a do banco (todos os livros) + o que a sessão mudou; os rótulos em maiúsculas', () {
      final s = open(desk: const [])
        ..setLabelData(
          labels: const {'#fed170': 'lindo'},
          counts: const {'#FED170': 5, '#FFC1C6': 3},
        )
        ..setTool(AnnotationTool.marker);
      expect(s.labels, {'#FED170': 'lindo'});
      expect((s.colorCount('#fed170'), s.colorCount('#FFC1C6')), (5, 3));
      expect(s.colorCount('#ABCF82'), 0);
      draw(s, [(90, y0), (140, y0 + 3), (188, y0)]);
      expect(s.colorCount('#FED170'), 6);
      s.undo();
      expect(s.colorCount('#FED170'), 5);
    });

    test('no estilo e na cor do painel; com Alta, o traço mais largo', () {
      final s = open(desk: const [])
        ..setTool(AnnotationTool.marker)
        ..setHighlighterColor('#FFC1C6')
        ..setHighlighterStyle(HighlightStyle.wavy)
        ..setHighlighterHeight(FillHeight.high);
      s.pointerDown(_touch(1, 90, y0, 0));
      expect(
        dpOfCentiMm((s.live.value! as LiveMarker).stroke.widthCentiMm),
        closeTo(35.25, 0.02),
      );
      s.pointerMove(_touch(1, 188, y0, 8));
      s.pointerUp(_touch(1, 188, y0, 16));
      final h = s.desk.items.single;
      expect(
        (h.color, h.style, h.height),
        ('#FFC1C6', HighlightStyle.wavy, null),
      );
    });

    test('na margem (sem palavra): a tinta translúcida num desenho, como a caneta (R22)', () {
      final s = open(desk: const [])..setTool(AnnotationTool.marker);
      draw(s, [(5, y0), (20, y0)]);
      expect(s.desk.items, isEmpty);
      final t = s.drawings.single.strokes.single.stroke;
      expect((t.tool, t.argb), (InkTool.marker.code, 0xE6FED170));
      expect(dpOfCentiMm(t.widthCentiMm), closeTo(0.8 * 35.25, 0.02));
    });

    test('a D-32 com um grifo de seleção amarelo: viram um só, o de seleção (D-173)', () {
      final s = open(desk: [grifo('sel', 9, 16)])
        ..setTool(AnnotationTool.marker);
      draw(s, [(90, y0), (188, y0)]);
      expect(s.desk.items, [grifo('sel', 6, 16)]);
      expect(s.paintedHighlights!.single.range, (unit: _unit, from: 6, to: 16));
      expect(s.paintedInkHighlights, isEmpty);
      expect(s.countDelta, isEmpty);
    });

    test('a Borracha apaga o grifo novo do marca-texto; o desfazer devolve; o de seleção a Borracha não alcança', () {
      final s = open(desk: [grifo('sel', 0, 5)])
        ..setTool(AnnotationTool.marker);
      draw(s, [(90, y0), (188, y0)]);
      final novo = s.desk.items.last.id;
      s.setTool(AnnotationTool.eraser);
      // passa sobre "Olhos" (de seleção) e "ressaca" (o novo)
      draw(s, [(40, y0), (150, y0)]);
      expect(s.desk.items.map((h) => h.id), ['sel']);
      expect(s.hiddenHighlights, contains(novo));
      s.undo();
      expect(s.desk.items.map((h) => h.id), ['sel', novo]);
    });

    test('a Borracha alcança o grifo à mão salvo pelas caixas da tela enquanto ele não muda', () {
      final s = open(
        desk: [grifo('mao', 6, 8, mao: true)],
        highlights: [
          (id: 'mao', ink: true, areas: const [InkRect(200, 80, 240, 100)]),
        ],
      )..setTool(AnnotationTool.eraser);
      // nas palavras ("de"), longe da caixa da tela: nada
      draw(s, [(90, y0), (105, y0)]);
      expect(s.desk.items, hasLength(1));
      draw(s, [(210, 90 + 30.0), (230, 90 + 30.0)]);
      expect(s.desk.items, isEmpty);
    });

    test('o Concluir grava o grifo novo: âncora de 7 chaves, página, capítulo, grupo do traço, cor, estilo, altura e origem (R24)', () async {
      final s = open(desk: const [])..setTool(AnnotationTool.marker);
      draw(s, [(90, y0), (188, y0)]);
      final h = s.desk.items.single;
      final c = s.changes();
      expect(c.layers, isEmpty);
      final r = c.highlights.single;
      expect(r.id, h.id);
      expect(
        (r.range.sha, r.range.spine, r.range.start, r.range.end),
        (shaTeste, _unit, 6, 16),
      );
      expect((r.range.quote.exact, r.range.refPage), ('de ressaca', 159));
      expect(
        (r.refPage, r.chapterIndex, r.groupId, r.color, r.style),
        (159, 31, h.id, '#FED170', HighlightStyle.fill),
      );
      expect(
        (r.fillHeight, r.source, r.createdAt),
        (FillHeight.medium, AnnotationSource.ink, now),
      );
      expect(c.moved, isEmpty);
      expect(c.removed, isEmpty);
      expect(c.erasedHighlights, isEmpty);
      // o rascunho a cada 5 s leva o grifo; o Concluir grava e apaga o rascunho
      timers.fire();
      await pumpEventQueue();
      expect(repo.drafts.values.single.highlights.single.id, h.id);
      expect(await s.conclude(), isTrue);
      expect(repo.commits.single.highlights.single, r);
      expect(repo.drafts, isEmpty);
    });

    test('rosa no meio de um amarelo de seleção: o amarelo encolhe (movido) e o pedaço da direita é novo, com a origem e o grupo dele', () {
      final s = open(desk: [grifo('sel', 0, 16)])
        ..setTool(AnnotationTool.marker)
        ..setHighlighterColor('#FFC1C6');
      // sobre "de"
      draw(s, [(91, y0), (107, y0)]);
      final c = s.changes();
      final m = c.moved.single;
      expect(m.id, 'sel');
      expect((m.range.start, m.range.end), (0, 6));
      expect(m.range.quote.exact, _text.substring(0, 6));
      expect((m.refPage, m.chapterIndex), (159, 31));
      final novos = {for (final r in c.highlights) r.color: r};
      expect(novos.keys, unorderedEquals(['#FFC1C6', '#FED170']));
      final rosa = novos['#FFC1C6']!;
      expect((rosa.range.start, rosa.range.end), (6, 8));
      final direita = novos['#FED170']!;
      expect(
        (direita.range.start, direita.range.end, direita.source),
        (8, 16, AnnotationSource.selection),
      );
      expect(
        (direita.groupId, direita.fillHeight),
        ('g-sel', FillHeight.medium),
      );
      expect(c.removed, isEmpty);
    });

    test('tirados: o à mão salvo coberto vai com o destino; em cadeia, o último; se a Borracha apaga o destino, sem destino', () {
      final s = open(desk: [grifo('a', 6, 8, mao: true)])
        ..setTool(AnnotationTool.marker)
        ..setHighlighterColor('#FFC1C6');
      draw(s, [(30, y0), (188, y0)]);
      final rosa = s.desk.items.single.id;
      var c = s.changes();
      expect(c.removed, {'a': rosa});
      expect(c.highlights.single.id, rosa);
      // o amarelo por cima do rosa (novo): o rosa sai e a nota de "a" segue para o amarelo
      s.setHighlighterColor('#FED170');
      draw(s, [(30, y0), (188, y0)]);
      final amarelo = s.desk.items.single.id;
      c = s.changes();
      expect(c.removed, {
        'a': amarelo,
      }, reason: 'só os salvos; o rosa nunca foi gravado');
      expect(c.highlights.single.id, amarelo);
      // a Borracha apaga o amarelo (novo): as notas de "a" vão junto
      s.setTool(AnnotationTool.eraser);
      draw(s, [(40, y0), (150, y0)]);
      c = s.changes();
      expect(c.removed, {'a': null});
      expect(c.highlights, isEmpty);
      expect(
        c.erasedHighlights,
        isEmpty,
        reason: 'o amarelo nunca foi gravado',
      );
      s.undo();
      expect(s.changes().removed, {'a': amarelo});
    });

    test('o 1º trecho se junta a um grifo mais antigo: os trechos seguintes ficam no grupo dele', () {
      final s = open(desk: [grifo('velho', 0, 5)])
        ..setTool(AnnotationTool.marker);
      // "Olhos" e "ressaca", saindo da linha por cima de "de"
      draw(s, [
        (30, y0),
        (80, y0),
        (80, y0 - 50),
        (120, y0 - 50),
        (120, y0),
        (188, y0),
      ]);
      expect(s.desk.items, hasLength(2));
      final novo = s.desk.items.singleWhere((h) => h.id != 'velho');
      expect(_text.substring(novo.start, novo.end), 'ressaca');
      expect(novo.groupId, 'g-velho');
      expect(s.desk.byId('velho'), grifo('velho', 0, 5));
    });

    test('sem a mesa (a tela não passou os grifos), o grifo do marca-texto também vai no Concluir', () {
      final s = open()..setTool(AnnotationTool.marker);
      draw(s, [(90, y0), (140, y0 + 3), (188, y0)]);
      final c = s.changes();
      final h = c.highlights.single;
      expect(
        (h.range.start, h.range.end, h.source),
        (6, 16, AnnotationSource.ink),
      );
      expect(c.erasedHighlights, isEmpty);
      expect(c.moved, isEmpty);
      expect(c.removed, isEmpty);
    });

    test('a Borracha alcança o grifo à mão salvo sem caixas da tela (Sublinhado ou Ondulado) pelas palavras', () {
      final s = open(
        desk: [
          DeskHighlight(
            id: 'onda',
            unit: _unit,
            start: 6,
            end: 8,
            color: '#FED170',
            style: HighlightStyle.wavy,
            height: null,
            ink: true,
            groupId: 'g-onda',
            createdAt: DateTime.utc(2026, 9, 1),
          ),
        ],
        highlights: const [(id: 'onda', ink: true, areas: <InkRect>[])],
      )..setTool(AnnotationTool.eraser);
      // sobre "de"
      draw(s, [(90, y0), (105, y0)]);
      expect(s.desk.items, isEmpty);
      expect(s.changes().erasedHighlights, {'onda'});
    });

    test('a Borracha num grifo à mão salvo: só nos apagados', () {
      final s = open(
        desk: [grifo('mao', 6, 8, mao: true)],
        highlights: [
          (id: 'mao', ink: true, areas: const [InkRect(200, 80, 240, 100)]),
        ],
      )..setTool(AnnotationTool.eraser);
      draw(s, [(210, 90 + 30.0), (230, 90 + 30.0)]);
      final c = s.changes();
      expect(c.erasedHighlights, {'mao'});
      expect(c.highlights, isEmpty);
      expect(c.moved, isEmpty);
      expect(c.removed, isEmpty);
    });

    test(
      'sem a mesa (a tela não passou os grifos), a pintura fica com a tela',
      () {
        final s = open();
        expect(s.paintedHighlights, isNull);
        expect(s.paintedInkHighlights, isNull);
      },
    );
  });

  group('o que o Concluir grava', () {
    test('desenho novo: âncora nas palavras, moldura em em, página, capítulo, grupo próprio e a cor do 1º traço', () {
      final s = open();
      // uma elipse em volta de "de ressaca" (linha 1), na tela (+30)
      draw(s, [(86, 105), (150, 98), (195, 108), (150, 135), (86, 128)]);
      final c = s.changes();
      final r = c.layers.single;
      expect(r.range.sha, shaTeste);
      expect(r.range.spine, _unit);
      expect(r.range.quote.exact, 'de ressaca');
      expect(_text.substring(r.range.start, r.range.end), 'de ressaca');
      expect((r.refPage, r.chapterIndex), (159, 31));
      expect(
        r.groupId,
        r.annotationId,
        reason: 'sem desenho perto: grupo próprio',
      );
      expect(r.color, '#FF552E');
      expect(r.layerId, s.drawings.single.id);
      expect(r.createdAt, now);
      expect(r.strokeCount, 1);
      final ink = inkAnchorOf(r.anchor)!;
      expect(ink.range, r.range);
      expect(ink.w, closeTo((190 - 89) / _em, 1e-4));
      final strokes = decodeStrokesB64(r.strokesB64, Bnk1Unit.em);
      expect(strokes.single.points.first.x, closeTo((86 - 89) / _em, 0.005));
      expect(strokes.single.points.first.y, closeTo((75 - 100) / _em, 0.005));
    });

    test('desenho novo a até 2 linhas de um salvo entra no grupo dele; o salvo apagado sai inteiro', () {
      final antigo = _saved(
        40,
        from: 0,
        to: 5,
        group: 99,
        points: [(28, 104), (83, 104)],
      );
      final s = open(drawings: [antigo]);
      draw(s, [(28, 196), (90, 196)]);
      var c = s.changes();
      expect(c.layers.single.groupId, idTeste(99));
      s.setTool(AnnotationTool.eraser);
      draw(s, [(50, 120), (50, 145)], id: 2);
      c = s.changes();
      expect(c.deletedLayers, {idTeste(40)});
      expect(c.layers, hasLength(1));
    });

    test('nada mudou: o Concluir não grava e apaga só o rascunho da sessão; o de uma sessão que morreu fica (D-166)', () async {
      final s = open();
      final morta = draftKey(usuarioTeste, idTeste(1), 'sessao-morta');
      final minha = draftKey(usuarioTeste, idTeste(1), 'sessao-1');
      repo.drafts[morta] = const InkChanges(deletedLayers: {'x'});
      repo.drafts[minha] = const InkChanges(deletedLayers: {'y'});
      expect(await s.conclude(), isTrue);
      expect(repo.commits, isEmpty);
      expect(repo.drafts.keys, [morta]);
      // desenhar e o tique dos 5 s guardam na chave da sessão, sem tocar na outra
      draw(s, [(40, 140), (60, 140)]);
      timers.fire();
      await pumpEventQueue();
      expect(repo.drafts.keys, unorderedEquals([morta, minha]));
      expect(repo.drafts[morta], const InkChanges(deletedLayers: {'x'}));
      expect(await s.conclude(), isTrue);
      expect(repo.drafts.keys, [morta]);
    });

    test('enquanto o Concluir grava, a página não aceita tinta nem move; o traço em curso entra no que é gravado', () async {
      final s = open();
      final porta = Completer<void>();
      repo.gate = porta.future;
      s.pointerDown(_pen(1, 40, 140, 0));
      s.pointerMove(_pen(1, 60, 140, 8));
      final gravando = s.conclude();
      expect(s.saving, isTrue);
      expect(s.live.value, isNull, reason: 'o traço em curso fechou');
      expect(s.visibleStrokes, hasLength(1));
      // a caneta segue e outra passada vem durante a gravação: nada disso entra
      s.pointerMove(_pen(1, 90, 140, 16));
      s.pointerUp(_pen(1, 90, 140, 24));
      s.pointerDown(_pen(2, 40, 200, 40));
      s.pointerMove(_pen(2, 90, 200, 48));
      expect(s.live.value, isNull);
      s.pointerUp(_pen(2, 90, 200, 56));
      porta.complete();
      expect(await gravando, isTrue);
      expect(s.saving, isFalse);
      final gravado = repo.commits.single.layers.single;
      expect(gravado.strokeCount, 1);
      expect(s.visibleStrokes, hasLength(1));
      expect(s.visibleStrokes.single.points.last.x, 60);
      expect(repo.drafts, isEmpty);
    });

    test('o que não dá para montar ao gravar (o capítulo que lança) liga a pílula, sem escapar do Concluir', () async {
      final s = open(anchors: _Quebradas());
      draw(s, [(40, 140), (60, 140)]);
      expect(await s.conclude(), isFalse);
      expect(s.failed, isTrue);
      expect(repo.commits, isEmpty);
      expect(errors, isNotEmpty);
    });

    test('editar um desenho salvo mantém a camada, a anotação, a criação e o grupo dele', () {
      final antigo = _saved(
        40,
        from: 0,
        to: 5,
        group: 99,
        points: [(28, 104), (83, 104)],
      );
      final s = open(drawings: [antigo]);
      // um traço que toca o salvo entra nele
      draw(s, [(30, 140), (80, 140)]);
      expect(s.drawings, hasLength(1));
      final r = s.changes().layers.single;
      expect(
        (r.layerId, r.annotationId, r.createdAt, r.groupId, r.strokeCount),
        (idTeste(40), idTeste(41), DateTime.utc(2026, 10, 1), idTeste(99), 2),
      );
    });

    test('mover o salvo inteiro com o Laço: a camada dele sai e entra uma nova, com anotação nova no grupo dele', () {
      final antigo = _saved(
        40,
        from: 0,
        to: 5,
        group: 99,
        points: [(28, 104), (83, 104)],
      );
      final s = open(drawings: [antigo])..setTool(AnnotationTool.lasso);
      draw(s, [(20, 120), (100, 120), (100, 150), (20, 150)], id: 3);
      expect(s.selection.value!.strokes, hasLength(1));
      s.pointerDown(_touch(4, 50, 134, 100));
      s.pointerMove(_touch(4, 50, 204, 108));
      s.pointerUp(_touch(4, 50, 204, 116));
      final c = s.changes();
      expect(c.deletedLayers, {idTeste(40)});
      final novo = c.layers.single;
      expect(novo.layerId, isNot(idTeste(40)));
      expect(novo.annotationId, isNot(idTeste(41)));
      expect(_text.substring(novo.range.start, novo.range.end), 'da praia');
    });

    test('2 desenhos novos a até 2 linhas ficam no mesmo cartão; a 3 linhas, cada um no seu', () {
      // linha 0 à esquerda e linha 1 à direita (longe o bastante para não serem um desenho só)
      var s = open();
      draw(s, [(28, 126), (60, 126)]);
      draw(s, [(100, 161), (133, 161)], id: 2, t: 100);
      expect(s.drawings, hasLength(2));
      var rows = s.changes().layers;
      expect(rows[1].groupId, rows[0].groupId);
      expect(rows[0].groupId, rows[0].annotationId);
      // linha 0 e linha 3
      s = open(draftId: 'sessao-2');
      draw(s, [(28, 126), (60, 126)]);
      draw(s, [(28, 232), (70, 232)], id: 2, t: 100);
      rows = s.changes().layers;
      expect(rows, hasLength(2));
      expect(rows[1].groupId, isNot(rows[0].groupId));
      expect(rows[1].groupId, rows[1].annotationId);
    });

    test('Concluir grava, apaga o rascunho e devolve true; a falha liga a pílula e guarda o rascunho', () async {
      final s = open();
      draw(s, [(40, 140), (60, 140)]);
      repo.failCommit = true;
      expect(await s.conclude(), isFalse);
      expect(s.failed, isTrue);
      expect(repo.drafts.values.single.layers, hasLength(1));
      repo.failCommit = false;
      expect(await s.conclude(), isTrue);
      expect(s.failed, isFalse);
      expect(repo.commits.single.layers, hasLength(1));
      expect(repo.drafts, isEmpty);
    });
  });

  group('rascunho', () {
    test(
      'a cada 5 s com mudanças; sem mudanças não grava; o segundo plano grava',
      () async {
        final s = open();
        expect(timers.pending.single.$1, const Duration(seconds: 5));
        timers.fire();
        await pumpEventQueue();
        expect(repo.draftWrites, 0);
        draw(s, [(40, 140), (60, 140)]);
        timers.fire();
        await pumpEventQueue();
        expect(repo.draftWrites, 1);
        expect(repo.drafts.values.single.layers, hasLength(1));
        timers.fire();
        await pumpEventQueue();
        expect(repo.draftWrites, 1, reason: 'nada novo desde o último');
        s.undo();
        await s.toBackground();
        expect(repo.draftWrites, 2);
        expect(repo.drafts, isEmpty, reason: 'desfeito: o rascunho vazio some');
      },
    );
  });

  test(
    'o desenho salvo entra na cópia de trabalho com os traços na página',
    () {
      final antigo = _saved(40, from: 0, to: 5, points: [(28, 104), (83, 104)]);
      final s = open(drawings: [antigo]);
      expect(s.drawings.single.id, idTeste(40));
      expect(s.drawings.single.saved, antigo.saved);
      expect(s.visibleStrokes.single, antigo.strokes.single);
      expect(s.canUndo, isFalse);
      expect(s.changes().isEmpty, isTrue);
    },
  );

  test('a revisão sobe a cada mudança da tinta (o cache da pintura)', () {
    final s = open();
    final r0 = s.revision;
    draw(s, [(40, 140), (60, 140)]);
    expect(s.revision, greaterThan(r0));
    final r1 = s.revision;
    s.undo();
    expect(s.revision, greaterThan(r1));
  });

  test('os desenhos da sessão não mudam de ordem nem de id no desfazer e no refazer', () {
    final s = open();
    draw(s, [(40, 140), (60, 140)]);
    final id = s.drawings.single.id;
    s
      ..undo()
      ..redo();
    expect(s.drawings.single.id, id);
    expect(s.drawings.single, isA<SessionDrawing>());
  });
}

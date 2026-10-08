// G16.3 — a sessão do modo anotação (§3): a Caneta (pontos do leitor limpo, pressão simulada na captura, toque sem
// arrastar = 1 ponto), o desenho que o traço toca (D-162), a Reta (15°/4°, mínimo de 4 px), a Borracha (passada =
// 1 passo; só tinta — D-168), o Laço (≥ 50 %, arrastar move, tocar fora solta, Borracha com a seleção), 2 dedos
// movem a página com o batente (D-165), as ferramentas das fases seguintes (D-163), a espessura no pen_presets, o
// que o Concluir grava (âncora, moldura em em, página, capítulo, cartões, apagados), o rascunho a cada 5 s e no
// segundo plano (D-166), o Concluir e a falha ao salvar, e a interação a cada toque (D-95).
import 'dart:async';

import 'package:app_leitura/core/data/ids/uuid_v7.dart';
import 'package:app_leitura/features/reader/annotations/domain/pen_presets.dart';
import 'package:app_leitura/features/reader/annotations/ink/bnk1_codec.dart';
import 'package:app_leitura/features/reader/annotations/ink/drawing_anchor.dart';
import 'package:app_leitura/features/reader/annotations/ink/gesture_arbiter.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_changes.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_commands.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_geometry.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
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
  late int interactions;
  var now = DateTime.utc(2026, 10, 8, 10);

  AnnotationSession open({
    List<PageDrawing> drawings = const [],
    List<PageHighlight> highlights = const [],
    PenPresets? presets,
    double panLimit = 100,
  }) {
    final s = AnnotationSession(
      geometry: _geometry(),
      anchors: _Anchors(),
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
    test('Marca-texto e Espaço são das fases seguintes (D-163): a ferramenta atual continua', () {
      final s = open();
      expect(s.setTool(AnnotationTool.marker), isFalse);
      expect(s.setTool(AnnotationTool.space), isFalse);
      expect(s.tool, AnnotationTool.pen);
      expect(s.setTool(AnnotationTool.lasso), isTrue);
      expect(s.tool, AnnotationTool.lasso);
    });
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

    test(
      'nada mudou: o Concluir não grava e apaga um rascunho velho',
      () async {
        final s = open();
        repo.drafts['ink_draft:$usuarioTeste:${idTeste(1)}'] = const InkChanges(
          deletedLayers: {'x'},
        );
        expect(await s.conclude(), isTrue);
        expect(repo.commits, isEmpty);
        expect(repo.drafts, isEmpty);
      },
    );

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

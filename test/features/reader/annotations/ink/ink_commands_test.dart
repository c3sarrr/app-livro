// G16.3 — a cópia de trabalho da página e a pilha de comandos da sessão (§3): cada comando aplicado e desfeito volta
// exatamente ao estado anterior; no máximo 100 passos (o mais antigo sai); uma ação nova limpa o refazer; mover o
// único traço de um desenho apaga o desenho e o desfazer o devolve; os desenhos mexidos ficam marcados.
import 'package:app_leitura/features/reader/annotations/ink/highlight_desk.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_commands.dart';
import 'package:app_leitura/features/reader/annotations/ink/ink_stroke.dart';
import 'package:flutter_test/flutter_test.dart';

final _t0 = DateTime.utc(2026, 9, 20, 10);

SessionStroke _s(int id, {double x = 0, double y = 0}) => SessionStroke(
  id,
  InkStroke(
    tool: InkTool.pen.code,
    tip: 0,
    argb: 0xFFFF552E,
    widthCentiMm: 120,
    points: [InkPoint(x, y, 0.5, 0), InkPoint(x + 10, y + 5, 0.4, 8)],
  ),
);

final _saved = SessionDrawing(
  id: 'camada-elipse',
  order: 0,
  strokes: [_s(1), _s(2, x: 50)],
  saved: (
    layerId: 'camada-elipse',
    annotationId: 'anotacao-elipse',
    createdAt: _t0,
    groupId: 'anotacao-elipse',
  ),
);
final _other = SessionDrawing(
  id: 'camada-onda',
  order: 1,
  strokes: [_s(3, y: 200)],
);

/// O estado comparável da cópia: os desenhos em ordem e os grifos apagados.
(List<SessionDrawing>, Set<String>) _state(InkWorkingCopy w) =>
    (w.drawings.toList(), {...w.erasedHighlights});

/// A cópia voltou ao estado [before] (a lista e o conjunto comparados pelo conteúdo).
void _expectState(
  InkWorkingCopy w,
  (List<SessionDrawing>, Set<String>) before,
) {
  expect(w.drawings.toList(), before.$1);
  expect(w.erasedHighlights, before.$2);
}

void main() {
  late InkWorkingCopy w;
  setUp(() => w = InkWorkingCopy([_saved, _other]));

  test('a cópia: os desenhos em ordem, por id e por traço', () {
    expect(w.drawings.map((d) => d.id), ['camada-elipse', 'camada-onda']);
    expect(w.drawing('camada-onda'), _other);
    expect(w.drawingOfStroke(2), 'camada-elipse');
    expect(w.drawingOfStroke(99), isNull);
    expect(w.stroke(3), _s(3, y: 200));
    expect(w.changedDrawings, isEmpty);
    expect(w.erasedHighlights, isEmpty);
  });

  test('AddStroke num desenho novo: aplica e desfaz', () {
    final before = _state(w);
    final c = AddStroke(
      _s(4, x: 300),
      into: null,
      newDrawingId: 'novo-1',
      order: 2,
    );
    c.apply(w);
    expect(
      w.drawing('novo-1'),
      SessionDrawing(id: 'novo-1', order: 2, strokes: [_s(4, x: 300)]),
    );
    expect(w.drawings.last.id, 'novo-1');
    c.revert(w);
    _expectState(w, before);
    expect(w.changedDrawings, {'novo-1'});
  });

  test('AddStroke num desenho que já existia: entra no fim; desfazer tira', () {
    final before = _state(w);
    final c = AddStroke(
      _s(4),
      into: 'camada-elipse',
      newDrawingId: 'novo-1',
      order: 2,
    );
    c.apply(w);
    expect(w.drawing('camada-elipse')!.strokes.map((s) => s.id), [1, 2, 4]);
    expect(w.drawing('camada-elipse')!.saved, _saved.saved);
    expect(w.drawing('novo-1'), isNull);
    c.revert(w);
    _expectState(w, before);
    expect(w.changedDrawings, {'camada-elipse'});
  });

  test('Erase: traços de vários desenhos e grifos; o desenho vazio some; desfazer devolve', () {
    final before = _state(w);
    final c = Erase(strokeIds: {2, 3}, highlightIds: {'grifo-capitu'});
    c.apply(w);
    expect(w.drawing('camada-elipse')!.strokes.map((s) => s.id), [1]);
    expect(w.drawing('camada-onda'), isNull);
    expect(w.erasedHighlights, {'grifo-capitu'});
    c.revert(w);
    _expectState(w, before);
    expect(w.changedDrawings, {'camada-elipse', 'camada-onda'});
  });

  test('MoveStrokes: os traços saem dos desenhos deles e formam um desenho novo, deslocados', () {
    final before = _state(w);
    final c = MoveStrokes(
      strokeIds: {3, 2},
      dx: 5,
      dy: -3,
      newDrawingId: 'movido-1',
      order: 7,
    );
    c.apply(w);
    expect(w.drawing('camada-elipse')!.strokes.map((s) => s.id), [1]);
    expect(w.drawing('camada-onda'), isNull, reason: 'ficou sem traços');
    final moved = w.drawing('movido-1')!;
    expect(moved.order, 7);
    expect(moved.saved, isNull);
    expect(moved.strokes, [
      SessionStroke(2, _s(2, x: 50).stroke.translated(5, -3)),
      SessionStroke(3, _s(3, y: 200).stroke.translated(5, -3)),
    ]);
    c.revert(w);
    _expectState(w, before);
    expect(w.changedDrawings, {'camada-elipse', 'camada-onda', 'movido-1'});
  });

  test(
    'mover o único traço de um desenho apaga o desenho; o desfazer o devolve',
    () {
      final h = InkHistory(w);
      h.push(
        MoveStrokes(
          strokeIds: {3},
          dx: 0,
          dy: 40,
          newDrawingId: 'movido-1',
          order: 2,
        ),
      );
      expect(w.drawing('camada-onda'), isNull);
      expect(w.drawing('movido-1')!.strokes.single.stroke.points.first.y, 240);
      expect(h.undo(), isTrue);
      expect(w.drawing('camada-onda'), _other);
      expect(w.drawing('movido-1'), isNull);
      expect(h.redo(), isTrue);
      expect(w.drawing('camada-onda'), isNull);
      expect(w.drawing('movido-1'), isNotNull);
    },
  );

  test('no máximo 100 passos: o mais antigo sai', () {
    final h = InkHistory(w);
    expect(InkHistory.maxSteps, 100);
    for (var i = 0; i < 101; i++) {
      h.push(
        AddStroke(
          _s(100 + i, x: i * 3.0),
          into: null,
          newDrawingId: 'd$i',
          order: 10 + i,
        ),
      );
    }
    var undone = 0;
    while (h.undo()) {
      undone++;
    }
    expect(undone, 100);
    expect(h.canUndo, isFalse);
    // o 1º passo ficou: não dá mais para desfazer
    expect(w.drawings.map((d) => d.id), ['camada-elipse', 'camada-onda', 'd0']);
  });

  test(
    'desfazer e refazer ligam e desligam; uma ação nova limpa o refazer',
    () {
      final h = InkHistory(w);
      expect((h.canUndo, h.canRedo), (false, false));
      expect(h.undo(), isFalse);
      expect(h.redo(), isFalse);
      h.push(AddStroke(_s(4), into: null, newDrawingId: 'a', order: 2));
      h.push(AddStroke(_s(5), into: 'a', newDrawingId: 'b', order: 3));
      expect((h.canUndo, h.canRedo), (true, false));
      h.undo();
      expect((h.canUndo, h.canRedo), (true, true));
      expect(w.drawing('a')!.strokes.map((s) => s.id), [4]);
      h.push(Erase(strokeIds: {1}, highlightIds: const {}));
      expect(h.canRedo, isFalse);
      expect(h.redo(), isFalse);
      expect(w.drawing('a')!.strokes.map((s) => s.id), [4]);
    },
  );

  test('o desfazer não desmarca os desenhos mexidos (o Concluir compara com o lido)', () {
    final h = InkHistory(w);
    h.push(Erase(strokeIds: {1}, highlightIds: {'grifo-capitu'}));
    h.undo();
    expect(w.changedDrawings, {'camada-elipse'});
    expect(w.erasedHighlights, isEmpty);
  });

  group('notas à mão (G18)', () {
    SessionStroke n(int id, {double x = 0.1, double y = 0.5}) => SessionStroke(
      id,
      InkStroke(
        tool: InkTool.pen.code,
        tip: 0,
        argb: 0xFFFF552E,
        widthCentiMm: 120,
        points: [InkPoint(x, y, 0.5, 0), InkPoint(x + 0.1, y + 0.2, 0.4, 8)],
      ),
    );
    SessionNote nota(String id, {List<SessionStroke> tracos = const []}) =>
        SessionNote(
          id: id,
          unit: 31,
          at: 120,
          lines: 3,
          collapsed: false,
          strokes: tracos,
          createdAt: _t0,
        );

    late InkWorkingCopy c;
    setUp(
      () => c = InkWorkingCopy(
        [_saved, _other],
        HighlightDesk.empty,
        [
          nota('salva', tracos: [n(10), n(11, y: 1.5)]),
        ],
      ),
    );

    test('a cópia tem as notas, por id e por traço', () {
      expect(c.notes.map((x) => x.id), ['salva']);
      expect(c.note('salva')!.strokes, hasLength(2));
      expect(c.noteOfStroke(11), 'salva');
      expect(c.noteOfStroke(1), isNull);
      expect(c.changedNotes, isEmpty);
    });

    test('OpenNote, ChangeNote e AddNoteStroke: aplicam e desfazem', () {
      final abrir = OpenNote(nota('nova'))..apply(c);
      expect(c.notes.map((x) => x.id), ['salva', 'nova']);
      final antes = c.note('nova')!;
      final mudar = ChangeNote(
        before: antes,
        after: antes.copyWith(lines: 5, collapsed: true),
      )..apply(c);
      expect((c.note('nova')!.lines, c.note('nova')!.collapsed), (5, true));
      // o traço recortado na borda pode virar mais de um pedaço (R6): um passo só
      final escrever = AddNoteStroke('nova', [n(20), n(21)])..apply(c);
      expect(c.note('nova')!.strokes.map((s) => s.id), [20, 21]);
      expect(c.noteOfStroke(20), 'nova');
      escrever.revert(c);
      expect(c.note('nova')!.strokes, isEmpty);
      mudar.revert(c);
      expect(c.note('nova'), antes);
      abrir.revert(c);
      expect(c.notes.map((x) => x.id), ['salva']);
      expect(c.changedNotes, {'nova'});
    });

    test('DeleteNote tira com os traços e devolve no mesmo lugar', () {
      OpenNote(nota('nova')).apply(c);
      final antes = [...c.notes];
      final apagar = DeleteNote('salva')..apply(c);
      expect(c.notes.map((x) => x.id), ['nova']);
      expect(c.noteOfStroke(10), isNull);
      apagar.revert(c);
      expect(c.notes, antes);
      expect(c.changedNotes, {'nova', 'salva'});
    });

    test('Erase alcança os traços da nota (a nota fica, mesmo vazia); desfazer devolve', () {
      final antes = c.note('salva');
      final e = Erase(strokeIds: {10, 11, 2}, highlightIds: const {})..apply(c);
      expect(c.note('salva')!.strokes, isEmpty);
      expect(c.drawing('camada-elipse')!.strokes.map((s) => s.id), [1]);
      e.revert(c);
      expect(c.note('salva'), antes);
      expect(c.changedNotes, {'salva'});
    });

    test(
      'MoveNoteStrokes move dentro da nota (unidade da nota); desfazer volta',
      () {
        final antes = c.note('salva');
        final m = MoveNoteStrokes(
          noteId: 'salva',
          strokeIds: {11},
          dx: 0.25,
          dy: -0.5,
        )..apply(c);
        expect(c.note('salva')!.strokes[0], n(10));
        expect(
          c.note('salva')!.strokes[1],
          SessionStroke(11, n(11, y: 1.5).stroke.translated(0.25, -0.5)),
        );
        m.revert(c);
        expect(c.note('salva'), antes);
      },
    );

    test('remap: cada desenho anda pelo deslocamento dele, na cópia e na pilha; as notas não', () {
      final h = InkHistory(c)
        ..push(
          AddStroke(
            _s(4, y: 200),
            into: 'camada-onda',
            newDrawingId: 'x',
            order: 2,
          ),
        )
        ..push(
          MoveStrokes(
            strokeIds: {2},
            dx: 5,
            dy: 0,
            newDrawingId: 'movido',
            order: 3,
          ),
        )
        ..push(AddNoteStroke('salva', [n(12)]));
      h.undo(); // a nota
      ({double dx, double dy})? desloca(String id, List<SessionStroke> _) =>
          id == 'camada-onda' || id == 'movido' ? (dx: 0, dy: 100) : null;
      c.remap(desloca);
      h.remap(desloca);
      expect(c.drawing('camada-onda')!.strokes, [
        SessionStroke(3, _s(3, y: 200).stroke.translated(0, 100)),
        SessionStroke(4, _s(4, y: 200).stroke.translated(0, 100)),
      ]);
      expect(c.drawing('movido')!.strokes, [
        SessionStroke(2, _s(2, x: 50).stroke.translated(5, 100)),
      ]);
      expect(c.drawing('camada-elipse')!.strokes, [_s(1)]);
      expect(c.changedDrawings, {'camada-onda', 'movido', 'camada-elipse'});
      // desfazer e refazer depois do remap: tudo transladado
      h.undo(); // o Laço
      expect(c.drawing('camada-elipse')!.strokes, [_s(1), _s(2, x: 50)]);
      h.undo(); // o traço
      expect(c.drawing('camada-onda')!.strokes, [
        SessionStroke(3, _s(3, y: 200).stroke.translated(0, 100)),
      ]);
      h.redo();
      expect(
        c.drawing('camada-onda')!.strokes.last,
        SessionStroke(4, _s(4, y: 200).stroke.translated(0, 100)),
      );
      h.redo();
      expect(c.drawing('movido')!.strokes, [
        SessionStroke(2, _s(2, x: 50).stroke.translated(5, 100)),
      ]);
      h.redo(); // a nota: a tinta dela não anda
      expect(c.note('salva')!.strokes.last, n(12));
    });
  });
}

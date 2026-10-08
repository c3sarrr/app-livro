// G16.3 — a cópia de trabalho da página no modo anotação e a pilha de comandos da sessão (§3). Dart puro.
// - A cópia tem os desenhos da página (os salvos e os novos, em coordenadas do leitor limpo), os grifos apagados e os
//   desenhos mexidos. Um desenho que fica sem traços sai da cópia (e volta no desfazer).
// - Cada comando guarda, ao aplicar, o que precisa para voltar exatamente ao estado anterior.
// - Desfazer e refazer valem para a sessão daquela página (D-165), com no máximo 100 passos: o mais antigo sai. Uma
//   ação nova limpa o refazer.
// - Os desenhos mexidos ficam marcados mesmo depois do desfazer: o Concluir compara cada um com o que foi lido.
// - G17: a cópia guarda também a mesa de grifos (D-173); o traço do Marca-texto é um passo (`MarkHighlights`) e a
//   Borracha tira da mesa os grifos à mão que apaga.
// - G18: a cópia guarda as notas à mão da página (a tinta delas na unidade da caixa — `note_ink.dart`); abrir,
//   mudar a altura ou recolher, apagar e escrever nelas são passos; a Borracha alcança os traços delas. Quando a
//   página do modo muda (um espaço abriu ou mudou), [InkWorkingCopy.remap] e [InkHistory.remap] levam cada desenho
//   junto com as palavras dele — na cópia e nos estados guardados dos comandos.
import 'package:flutter/foundation.dart' show immutable, listEquals;

import 'highlight_desk.dart';
import 'ink_stroke.dart';

/// Um traço da sessão: o id dele na sessão e o traço (coordenadas do leitor limpo).
@immutable
final class SessionStroke {
  const SessionStroke(this.id, this.stroke);

  final int id;
  final InkStroke stroke;

  @override
  bool operator ==(Object other) =>
      other is SessionStroke && other.id == id && other.stroke == stroke;

  @override
  int get hashCode => Object.hash(id, stroke);

  @override
  String toString() => 'SessionStroke($id)';
}

/// O que um desenho salvo já tinha no banco: a camada, a anotação, a hora de criação e o grupo (que não mudam).
typedef SavedDrawingRef = ({
  String layerId,
  String annotationId,
  DateTime createdAt,
  String groupId,
});

/// Um desenho da página: o id (o da camada), a ordem de criação, os traços e, se já estava gravado, o que ele tinha.
@immutable
final class SessionDrawing {
  const SessionDrawing({
    required this.id,
    required this.order,
    required this.strokes,
    this.saved,
  });

  final String id;
  final int order;
  final List<SessionStroke> strokes;
  final SavedDrawingRef? saved;

  SessionDrawing withStrokes(List<SessionStroke> strokes) => SessionDrawing(
    id: id,
    order: order,
    strokes: List.unmodifiable(strokes),
    saved: saved,
  );

  @override
  bool operator ==(Object other) =>
      other is SessionDrawing &&
      other.id == id &&
      other.order == order &&
      other.saved == saved &&
      listEquals(other.strokes, strokes);

  @override
  int get hashCode => Object.hash(id, order, saved, Object.hashAll(strokes));

  @override
  String toString() => 'SessionDrawing($id, $order, $strokes)';
}

/// O que uma nota à mão salva já tinha no banco: a camada, a anotação, a hora de criação e o grupo.
typedef SavedNoteRef = SavedDrawingRef;

/// G18 — uma nota à mão da página: a camada `space` ([id]), o item e a âncora, as linhas (1–12), recolhida, os traços
/// (na unidade da nota: x = fração da largura da caixa, y = linhas de 42 px), a hora de criação e o que ela já tinha
/// no banco.
@immutable
final class SessionNote {
  const SessionNote({
    required this.id,
    required this.unit,
    required this.at,
    required this.lines,
    required this.collapsed,
    required this.strokes,
    required this.createdAt,
    this.saved,
  });

  final String id;
  final int unit;
  final int at;
  final int lines;
  final bool collapsed;
  final List<SessionStroke> strokes;
  final DateTime createdAt;
  final SavedNoteRef? saved;

  SessionNote copyWith({
    int? lines,
    bool? collapsed,
    List<SessionStroke>? strokes,
  }) => SessionNote(
    id: id,
    unit: unit,
    at: at,
    lines: lines ?? this.lines,
    collapsed: collapsed ?? this.collapsed,
    strokes: strokes == null ? this.strokes : List.unmodifiable(strokes),
    createdAt: createdAt,
    saved: saved,
  );

  @override
  bool operator ==(Object other) =>
      other is SessionNote &&
      other.id == id &&
      other.unit == unit &&
      other.at == at &&
      other.lines == lines &&
      other.collapsed == collapsed &&
      other.createdAt == createdAt &&
      other.saved == saved &&
      listEquals(other.strokes, strokes);

  @override
  int get hashCode => Object.hash(
    id,
    unit,
    at,
    lines,
    collapsed,
    createdAt,
    saved,
    Object.hashAll(strokes),
  );

  @override
  String toString() =>
      'SessionNote($id, $at, $lines${collapsed ? ', recolhida' : ''}, $strokes)';
}

/// G18 — o deslocamento do desenho [drawingId] (de traços [strokes]) quando a página do modo muda; `null` = fica.
typedef InkShift = ({double dx, double dy})? Function(
  String drawingId,
  List<SessionStroke> strokes,
);

SessionDrawing _shifted(SessionDrawing d, InkShift shift) {
  final s = shift(d.id, d.strokes);
  if (s == null) return d;
  return d.withStrokes([
    for (final x in d.strokes)
      SessionStroke(x.id, x.stroke.translated(s.dx, s.dy)),
  ]);
}

/// A cópia de trabalho da página.
final class InkWorkingCopy {
  InkWorkingCopy(
    Iterable<SessionDrawing> drawings, [
    this._desk = HighlightDesk.empty,
    Iterable<SessionNote> notes = const [],
  ]) : _drawings = {for (final d in drawings) d.id: d},
       _notes = [...notes];

  final Map<String, SessionDrawing> _drawings;

  /// As notas à mão da página, na ordem em que entraram (G18).
  final List<SessionNote> _notes;
  final Set<String> _changedNotes = {};

  List<SessionNote> get notes => List.unmodifiable(_notes);

  SessionNote? note(String id) {
    for (final n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  /// A nota do traço [strokeId].
  String? noteOfStroke(int strokeId) {
    for (final n in _notes) {
      if (n.strokes.any((s) => s.id == strokeId)) return n.id;
    }
    return null;
  }

  /// As notas mexidas nesta sessão (mesmo que desfeitas).
  Set<String> get changedNotes => Set.unmodifiable(_changedNotes);

  void _putNote(SessionNote n) {
    final i = _notes.indexWhere((x) => x.id == n.id);
    if (i < 0) {
      _notes.add(n);
    } else {
      _notes[i] = n;
    }
    _changedNotes.add(n.id);
  }

  int _removeNote(String id) {
    final i = _notes.indexWhere((x) => x.id == id);
    if (i >= 0) _notes.removeAt(i);
    _changedNotes.add(id);
    return i;
  }

  /// G18: a página do modo mudou — cada desenho anda pelo deslocamento dele (sem contar como mexido).
  void remap(InkShift shift) {
    for (final d in _drawings.values.toList()) {
      _drawings[d.id] = _shifted(d, shift);
    }
  }

  /// Os grifos da página (G17, D-173).
  HighlightDesk _desk;
  HighlightDesk get desk => _desk;
  final Set<String> _erasedHighlights = {};
  final Set<String> _changed = {};

  /// Os desenhos, em ordem de criação.
  Iterable<SessionDrawing> get drawings =>
      _drawings.values.toList()..sort((a, b) => a.order.compareTo(b.order));

  SessionDrawing? drawing(String id) => _drawings[id];

  /// Os grifos apagados pela Borracha nesta sessão.
  Set<String> get erasedHighlights => Set.unmodifiable(_erasedHighlights);

  /// Os desenhos mexidos nesta sessão (mesmo que desfeitos).
  Set<String> get changedDrawings => Set.unmodifiable(_changed);

  /// O desenho do traço [strokeId].
  String? drawingOfStroke(int strokeId) {
    for (final d in _drawings.values) {
      if (d.strokes.any((s) => s.id == strokeId)) return d.id;
    }
    return null;
  }

  /// O traço [strokeId].
  SessionStroke? stroke(int strokeId) {
    for (final d in _drawings.values) {
      for (final s in d.strokes) {
        if (s.id == strokeId) return s;
      }
    }
    return null;
  }

  void _put(SessionDrawing d) {
    _drawings[d.id] = d;
    _changed.add(d.id);
  }

  void _remove(String id) {
    _drawings.remove(id);
    _changed.add(id);
  }
}

/// Um passo do desfazer.
sealed class InkCommand {
  void apply(InkWorkingCopy w);
  void revert(InkWorkingCopy w);

  /// G18: leva os traços guardados pelo comando junto com a página que mudou (os das notas não andam).
  void remap(InkShift shift) {}
}

/// Um traço novo: no desenho [into] (o que ele tocou) ou num desenho novo [newDrawingId] de ordem [order].
final class AddStroke extends InkCommand {
  AddStroke(
    this.stroke, {
    required this.into,
    required this.newDrawingId,
    required this.order,
  });

  SessionStroke stroke;
  final String? into;
  final String newDrawingId;
  final int order;

  SessionDrawing? _before;
  bool _created = false;

  @override
  void remap(InkShift shift) {
    final s = shift(into ?? newDrawingId, [stroke]);
    if (s != null) {
      stroke = SessionStroke(stroke.id, stroke.stroke.translated(s.dx, s.dy));
    }
    final b = _before;
    if (b != null) _before = _shifted(b, shift);
  }

  @override
  void apply(InkWorkingCopy w) {
    final target = into == null ? null : w.drawing(into!);
    _before = target;
    _created = target == null;
    if (target == null) {
      w._put(
        SessionDrawing(
          id: newDrawingId,
          order: order,
          strokes: List.unmodifiable([stroke]),
        ),
      );
    } else {
      w._put(target.withStrokes([...target.strokes, stroke]));
    }
  }

  @override
  void revert(InkWorkingCopy w) {
    if (_created) {
      w._remove(newDrawingId);
    } else {
      w._put(_before!);
    }
  }
}

/// Uma passada da Borracha (ou a seleção do Laço apagada): os traços [strokeIds] e os grifos [highlightIds].
final class Erase extends InkCommand {
  Erase({required this.strokeIds, required this.highlightIds});

  final Set<int> strokeIds;
  final Set<String> highlightIds;

  final List<SessionDrawing> _before = [];
  final Set<String> _added = {};
  final List<SessionNote> _notesBefore = [];

  HighlightDesk? _deskBefore;

  @override
  void remap(InkShift shift) {
    for (var i = 0; i < _before.length; i++) {
      _before[i] = _shifted(_before[i], shift);
    }
  }

  @override
  void apply(InkWorkingCopy w) {
    _before.clear();
    _added.clear();
    _notesBefore.clear();
    _deskBefore = w._desk;
    w._desk = w._desk.erase(highlightIds);
    // G18: os traços das notas (a nota fica, mesmo sem nenhum)
    for (final n in w.notes) {
      if (!n.strokes.any((s) => strokeIds.contains(s.id))) continue;
      _notesBefore.add(n);
      w._putNote(
        n.copyWith(
          strokes: [
            for (final s in n.strokes)
              if (!strokeIds.contains(s.id)) s,
          ],
        ),
      );
    }
    for (final d in w.drawings) {
      if (!d.strokes.any((s) => strokeIds.contains(s.id))) continue;
      _before.add(d);
      final left = [
        for (final s in d.strokes)
          if (!strokeIds.contains(s.id)) s,
      ];
      if (left.isEmpty) {
        w._remove(d.id);
      } else {
        w._put(d.withStrokes(left));
      }
    }
    for (final id in highlightIds) {
      if (w._erasedHighlights.add(id)) _added.add(id);
    }
  }

  @override
  void revert(InkWorkingCopy w) {
    for (final d in _before) {
      w._put(d);
    }
    for (final n in _notesBefore) {
      w._putNote(n);
    }
    w._erasedHighlights.removeAll(_added);
    w._desk = _deskBefore ?? w._desk;
  }
}

/// Um traço do Marca-texto que virou grifo (G17, D-173): a mesa de antes e a de depois (o grifo e o que a D-32 cortou
/// ou uniu voltam juntos no desfazer).
final class MarkHighlights extends InkCommand {
  MarkHighlights({required this.before, required this.after});

  final HighlightDesk before;
  final HighlightDesk after;

  @override
  void apply(InkWorkingCopy w) => w._desk = after;

  @override
  void revert(InkWorkingCopy w) => w._desk = before;
}

/// O Laço moveu os traços [strokeIds] de ([dx], [dy]): eles saem dos desenhos deles e formam o desenho novo
/// [newDrawingId] de ordem [order]; o desenho que fica sem traços sai.
final class MoveStrokes extends InkCommand {
  MoveStrokes({
    required this.strokeIds,
    required this.dx,
    required this.dy,
    required this.newDrawingId,
    required this.order,
  });

  final Set<int> strokeIds;
  final double dx;
  final double dy;
  final String newDrawingId;
  final int order;

  final List<SessionDrawing> _before = [];

  /// Os traços já movidos, guardados na 1ª aplicação (o refazer usa os mesmos — G18: eles andam com o `remap`).
  List<SessionStroke>? _moved;

  @override
  void remap(InkShift shift) {
    for (var i = 0; i < _before.length; i++) {
      _before[i] = _shifted(_before[i], shift);
    }
    final m = _moved;
    if (m != null) {
      final s = shift(newDrawingId, m);
      if (s != null) {
        _moved = [
          for (final x in m)
            SessionStroke(x.id, x.stroke.translated(s.dx, s.dy)),
        ];
      }
    }
  }

  @override
  void apply(InkWorkingCopy w) {
    _before.clear();
    final moved = <SessionStroke>[];
    for (final d in w.drawings) {
      if (!d.strokes.any((s) => strokeIds.contains(s.id))) continue;
      _before.add(d);
      final left = <SessionStroke>[];
      for (final s in d.strokes) {
        if (strokeIds.contains(s.id)) {
          moved.add(SessionStroke(s.id, s.stroke.translated(dx, dy)));
        } else {
          left.add(s);
        }
      }
      if (left.isEmpty) {
        w._remove(d.id);
      } else {
        w._put(d.withStrokes(left));
      }
    }
    moved.sort((a, b) => a.id.compareTo(b.id));
    final strokes = _moved ??= List.unmodifiable(moved);
    w._put(
      SessionDrawing(
        id: newDrawingId,
        order: order,
        strokes: List.unmodifiable(strokes),
      ),
    );
  }

  @override
  void revert(InkWorkingCopy w) {
    w._remove(newDrawingId);
    for (final d in _before) {
      w._put(d);
    }
  }
}

/// G18 — uma nota à mão nova na página.
final class OpenNote extends InkCommand {
  OpenNote(this.note);

  final SessionNote note;

  @override
  void apply(InkWorkingCopy w) => w._putNote(note);

  @override
  void revert(InkWorkingCopy w) => w._removeNote(note.id);
}

/// G18 — a nota mudou de altura ou foi recolhida/aberta.
final class ChangeNote extends InkCommand {
  ChangeNote({required this.before, required this.after});

  final SessionNote before;
  final SessionNote after;

  @override
  void apply(InkWorkingCopy w) => w._putNote(after);

  @override
  void revert(InkWorkingCopy w) => w._putNote(before);
}

/// G18 — a nota [id] apagada (com os traços); o desfazer a devolve no mesmo lugar.
final class DeleteNote extends InkCommand {
  DeleteNote(this.id);

  final String id;
  SessionNote? _before;
  int _index = -1;

  @override
  void apply(InkWorkingCopy w) {
    _before = w.note(id);
    _index = w._removeNote(id);
  }

  @override
  void revert(InkWorkingCopy w) {
    final n = _before;
    if (n == null) return;
    w._notes.insert(_index.clamp(0, w._notes.length), n);
    w._changedNotes.add(id);
  }
}

/// G18 — um traço novo na nota [noteId] (na unidade dela).
final class AddNoteStroke extends InkCommand {
  AddNoteStroke(this.noteId, this.stroke);

  final String noteId;
  final SessionStroke stroke;
  SessionNote? _before;

  @override
  void apply(InkWorkingCopy w) {
    final n = w.note(noteId);
    _before = n;
    if (n != null) w._putNote(n.copyWith(strokes: [...n.strokes, stroke]));
  }

  @override
  void revert(InkWorkingCopy w) {
    final n = _before;
    if (n != null) w._putNote(n);
  }
}

/// G18 — o Laço moveu os traços [strokeIds] da nota [noteId] de ([dx], [dy]) na unidade dela.
final class MoveNoteStrokes extends InkCommand {
  MoveNoteStrokes({
    required this.noteId,
    required this.strokeIds,
    required this.dx,
    required this.dy,
  });

  final String noteId;
  final Set<int> strokeIds;
  final double dx;
  final double dy;
  SessionNote? _before;

  @override
  void apply(InkWorkingCopy w) {
    final n = w.note(noteId);
    _before = n;
    if (n == null) return;
    w._putNote(
      n.copyWith(
        strokes: [
          for (final s in n.strokes)
            strokeIds.contains(s.id)
                ? SessionStroke(s.id, s.stroke.translated(dx, dy))
                : s,
        ],
      ),
    );
  }

  @override
  void revert(InkWorkingCopy w) {
    final n = _before;
    if (n != null) w._putNote(n);
  }
}

/// A pilha do desfazer e do refazer da sessão, sobre a cópia [copy].
final class InkHistory {
  InkHistory(this.copy);

  /// O desfazer guarda no máximo estes passos.
  static const int maxSteps = 100;

  final InkWorkingCopy copy;
  final List<InkCommand> _undo = [];
  final List<InkCommand> _redo = [];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  /// Aplica [c] como uma ação nova.
  void push(InkCommand c) {
    c.apply(copy);
    _redo.clear();
    _undo.add(c);
    if (_undo.length > maxSteps) _undo.removeAt(0);
  }

  bool undo() {
    if (_undo.isEmpty) return false;
    final c = _undo.removeLast()..revert(copy);
    _redo.add(c);
    return true;
  }

  bool redo() {
    if (_redo.isEmpty) return false;
    final c = _redo.removeLast()..apply(copy);
    _undo.add(c);
    return true;
  }

  /// O último passo feito (o que o Desfazer desfaz), ou `null`.
  InkCommand? get last => _undo.isEmpty ? null : _undo.last;

  /// G18: a página do modo mudou — os traços guardados em todos os passos (feitos e desfeitos) andam junto.
  void remap(InkShift shift) {
    for (final c in [..._undo, ..._redo]) {
      c.remap(shift);
    }
  }
}

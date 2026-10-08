// G16.3 — a cópia de trabalho da página no modo anotação e a pilha de comandos da sessão (§3). Dart puro.
// - A cópia tem os desenhos da página (os salvos e os novos, em coordenadas do leitor limpo), os grifos apagados e os
//   desenhos mexidos. Um desenho que fica sem traços sai da cópia (e volta no desfazer).
// - Cada comando guarda, ao aplicar, o que precisa para voltar exatamente ao estado anterior.
// - Desfazer e refazer valem para a sessão daquela página (D-165), com no máximo 100 passos: o mais antigo sai. Uma
//   ação nova limpa o refazer.
// - Os desenhos mexidos ficam marcados mesmo depois do desfazer: o Concluir compara cada um com o que foi lido.
import 'package:flutter/foundation.dart' show immutable, listEquals;

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

/// A cópia de trabalho da página.
final class InkWorkingCopy {
  InkWorkingCopy(Iterable<SessionDrawing> drawings)
    : _drawings = {for (final d in drawings) d.id: d};

  final Map<String, SessionDrawing> _drawings;
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
}

/// Um traço novo: no desenho [into] (o que ele tocou) ou num desenho novo [newDrawingId] de ordem [order].
final class AddStroke extends InkCommand {
  AddStroke(
    this.stroke, {
    required this.into,
    required this.newDrawingId,
    required this.order,
  });

  final SessionStroke stroke;
  final String? into;
  final String newDrawingId;
  final int order;

  SessionDrawing? _before;
  bool _created = false;

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

  @override
  void apply(InkWorkingCopy w) {
    _before.clear();
    _added.clear();
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
    w._erasedHighlights.removeAll(_added);
  }
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
    w._put(
      SessionDrawing(
        id: newDrawingId,
        order: order,
        strokes: List.unmodifiable(moved),
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
}

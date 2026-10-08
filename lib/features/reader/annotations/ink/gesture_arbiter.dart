// G16.3 — o árbitro de dedos e caneta do modo anotação (§3, D-167 4 e 5). Puro: recebe os eventos crus do `Listener`
// (id, tipo, posição, pressão, tempo) e devolve o que fazer.
// - 1 dedo (sem caneta na sessão) ou a caneta do aparelho → a ferramenta.
// - O 2º dedo: até 150 ms do 1º, o traço é descartado; depois, o traço termina ali. Nos dois casos a página passa a
//   mover.
// - Depois do 1º evento da caneta do aparelho, só ela desenha: 1 ou 2 dedos movem a página, e um dedo durante o
//   traço dela é palma (ignorado até sair). A caneta chegando com um dedo desenhando termina o traço do dedo; com a
//   página movendo, a página para (o PencilKit faz o mesmo com a política `pencilOnly`).
// - A página move pelo centro dos dedos: quando um dedo entra ou sai, o centro novo vira a referência, sem salto.
//   Termina quando os dedos saem; os dedos além do 2º são ignorados.
// - O `cancel` do traço o descarta.
import 'package:flutter/foundation.dart' show immutable;

/// O tipo do ponteiro: o mouse conta como dedo; a ponta de borracha da caneta (`invertedStylus`) fica fora da G16.
enum InkPointerKind { touch, stylus, ignored }

/// Um evento de ponteiro, nas coordenadas da tela.
typedef InkPointer = ({
  int id,
  InkPointerKind kind,
  double x,
  double y,
  double pressure,
  int tMs,
});

@immutable
sealed class InkGesture {
  const InkGesture();
}

/// A ferramenta começa em [p].
final class DrawStart extends InkGesture {
  const DrawStart(this.p);

  final InkPointer p;

  @override
  bool operator ==(Object other) => other is DrawStart && other.p == p;

  @override
  int get hashCode => Object.hash(DrawStart, p);

  @override
  String toString() => 'DrawStart($p)';
}

/// A ferramenta segue até [p].
final class DrawMove extends InkGesture {
  const DrawMove(this.p);

  final InkPointer p;

  @override
  bool operator ==(Object other) => other is DrawMove && other.p == p;

  @override
  int get hashCode => Object.hash(DrawMove, p);

  @override
  String toString() => 'DrawMove($p)';
}

/// O traço termina e fica.
final class DrawEnd extends InkGesture {
  const DrawEnd();

  @override
  bool operator ==(Object other) => other is DrawEnd;

  @override
  int get hashCode => (DrawEnd).hashCode;

  @override
  String toString() => 'DrawEnd()';
}

/// O traço termina e não fica.
final class DrawDiscard extends InkGesture {
  const DrawDiscard();

  @override
  bool operator ==(Object other) => other is DrawDiscard;

  @override
  int get hashCode => (DrawDiscard).hashCode;

  @override
  String toString() => 'DrawDiscard()';
}

/// A página começa a mover.
final class PanStart extends InkGesture {
  const PanStart();

  @override
  bool operator ==(Object other) => other is PanStart;

  @override
  int get hashCode => (PanStart).hashCode;

  @override
  String toString() => 'PanStart()';
}

/// A página anda [dy] na vertical (o quanto o centro dos dedos andou desde o último evento).
final class PanMove extends InkGesture {
  const PanMove(this.dy);

  final double dy;

  @override
  bool operator ==(Object other) => other is PanMove && other.dy == dy;

  @override
  int get hashCode => Object.hash(PanMove, dy);

  @override
  String toString() => 'PanMove($dy)';
}

/// A página para de mover.
final class PanEnd extends InkGesture {
  const PanEnd();

  @override
  bool operator ==(Object other) => other is PanEnd;

  @override
  int get hashCode => (PanEnd).hashCode;

  @override
  String toString() => 'PanEnd()';
}

final class InkGestureArbiter {
  /// O 2º dedo até este tempo do 1º descarta o traço (era o começo de um gesto de dois dedos).
  static const int discardWindowMs = 150;

  /// Os dedos que movem a página no máximo.
  static const int maxPanFingers = 2;

  bool _stylusSeen = false;

  /// A caneta do aparelho já apareceu nesta sessão: só ela desenha.
  bool get stylusSeen => _stylusSeen;

  /// Quem desenha agora (o id), o tipo e a hora do começo.
  int? _drawer;
  InkPointerKind? _drawerKind;
  int _drawStartMs = 0;

  /// A última altura de cada ponteiro na tela (o que desenha e os que movem a página).
  final Map<int, double> _y = {};

  /// Os dedos que movem a página, e o centro deles no último evento.
  final List<int> _panners = [];
  double _center = 0;

  /// Ponteiros ignorados até saírem (palma, 3º dedo, ponta de borracha).
  final Set<int> _ignored = {};

  bool get _stylusDrawing =>
      _drawer != null && _drawerKind == InkPointerKind.stylus;

  double _centerOf() =>
      _panners.map((id) => _y[id]!).reduce((a, b) => a + b) / _panners.length;

  List<InkGesture> down(InkPointer p) {
    switch (p.kind) {
      case InkPointerKind.ignored:
        _ignored.add(p.id);
        return const [];
      case InkPointerKind.stylus:
        _stylusSeen = true;
        if (_stylusDrawing) {
          _ignored.add(p.id);
          return const [];
        }
        final out = <InkGesture>[];
        if (_drawer case final finger?) {
          // o dedo que desenhava termina o traço e vira palma
          out.add(const DrawEnd());
          _ignored.add(finger);
        }
        if (_panners.isNotEmpty) {
          out.add(const PanEnd());
          _ignored.addAll(_panners);
          _panners.clear();
        }
        _startDrawing(p);
        out.add(DrawStart(p));
        return out;
      case InkPointerKind.touch:
        if (_stylusDrawing) {
          _ignored.add(p.id);
          return const [];
        }
        if (_panners.isNotEmpty || _stylusSeen) return _joinPan(p);
        if (_drawer case final first?) {
          final discard = p.tMs - _drawStartMs <= discardWindowMs;
          _drawer = null;
          _drawerKind = null;
          _panners.add(first);
          final out = _joinPan(p);
          return [
            discard ? const DrawDiscard() : const DrawEnd(),
            const PanStart(),
            ...out,
          ];
        }
        _startDrawing(p);
        return [DrawStart(p)];
    }
  }

  void _startDrawing(InkPointer p) {
    _drawer = p.id;
    _drawerKind = p.kind;
    _drawStartMs = p.tMs;
    _y[p.id] = p.y;
  }

  /// O dedo [p] entra no movimento da página (ou é o 3º e fica ignorado).
  List<InkGesture> _joinPan(InkPointer p) {
    if (_panners.length >= maxPanFingers) {
      _ignored.add(p.id);
      return const [];
    }
    final starting = _panners.isEmpty;
    _panners.add(p.id);
    _y[p.id] = p.y;
    _center = _centerOf();
    return starting ? const [PanStart()] : const [];
  }

  List<InkGesture> move(InkPointer p) {
    if (_ignored.contains(p.id)) return const [];
    if (p.id == _drawer) {
      _y[p.id] = p.y;
      return [DrawMove(p)];
    }
    if (!_panners.contains(p.id)) return const [];
    _y[p.id] = p.y;
    final center = _centerOf();
    final dy = center - _center;
    _center = center;
    return dy == 0 ? const [] : [PanMove(dy)];
  }

  List<InkGesture> up(InkPointer p) => _leave(p, discard: false);

  List<InkGesture> cancel(InkPointer p) => _leave(p, discard: true);

  List<InkGesture> _leave(InkPointer p, {required bool discard}) {
    if (_ignored.remove(p.id)) return const [];
    _y.remove(p.id);
    if (p.id == _drawer) {
      _drawer = null;
      _drawerKind = null;
      return [discard ? const DrawDiscard() : const DrawEnd()];
    }
    if (!_panners.remove(p.id)) return const [];
    if (_panners.isEmpty) return const [PanEnd()];
    _center = _centerOf();
    return const [];
  }
}

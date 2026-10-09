// G19.5 — a citação de um cartão da tela 25 com o que vai por trás e por cima de cada trecho: o fundo do grifo (o
// `mark` do arquivo: gradiente de 14 % a 92 % da caixa da letra, raio 3, uma caixa por linha), a mancha do grifo
// feito à mão (D-161, multiplicada, por cima) e a tinta dos desenhos (R10, por cima). As caixas de cada trecho saem
// do AppText (`rangeBoxes`), na hora de pintar — sem um 2º quadro.
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';

/// Uma linha de um trecho: as letras ([left]–[right]), a linha ([top]–[bottom]) e a baseline, locais à citação.
typedef QuoteBox = ({
  double left,
  double right,
  double top,
  double bottom,
  double baseline,
});

/// Pinta o que vai num trecho; [origin] = o canto da citação no canvas; [content] = a altura da caixa da letra (o
/// `content area` do CSS: ascent + descent da fonte, no meio da linha).
typedef QuotePainter = void Function(
  Canvas canvas,
  Offset origin,
  List<QuoteBox> boxes,
  double content,
);

@immutable
final class QuoteMark {
  const QuoteMark({
    required this.start,
    required this.end,
    this.behind,
    this.front,
  });

  /// O trecho [start, end) no texto puro da citação.
  final int start, end;
  final QuotePainter? behind, front;
}

class MarkedQuote extends SingleChildRenderObjectWidget {
  const MarkedQuote({
    super.key,
    required this.marks,
    required this.signature,
    required this.content,
    required AppText super.child,
  });

  final List<QuoteMark> marks;

  /// O que as [marks] pintam, comparável por valor (elas mesmas são funções novas a cada build): muda → repinta.
  final Object signature;
  final double content;

  @override
  RenderMarkedQuote createRenderObject(BuildContext context) =>
      RenderMarkedQuote(marks, signature, content);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMarkedQuote renderObject,
  ) {
    renderObject
      ..marks = marks
      ..signature = signature
      ..content = content;
  }
}

class RenderMarkedQuote extends RenderProxyBox {
  RenderMarkedQuote(this._marks, this._signature, this._content);

  /// Trocar as marcas sem mudar a [signature] não repinta (as de agora pintam o mesmo).
  List<QuoteMark> _marks;
  set marks(List<QuoteMark> v) => _marks = v;

  Object _signature;
  set signature(Object v) {
    if (v == _signature) return;
    _signature = v;
    markNeedsPaint();
  }

  double _content;
  set content(double v) {
    if (v == _content) return;
    _content = v;
    markNeedsPaint();
  }

  /// As caixas de cada trecho (teste e pintura).
  List<List<QuoteBox>> boxes() {
    final t = child;
    if (t is! RenderAppText) return const [];
    return [for (final m in _marks) t.rangeBoxes(m.start, m.end)];
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final all = boxes();
    for (var i = 0; i < all.length; i++) {
      _marks[i].behind?.call(context.canvas, offset, all[i], _content);
    }
    super.paint(context, offset);
    for (var i = 0; i < all.length; i++) {
      _marks[i].front?.call(context.canvas, offset, all[i], _content);
    }
  }
}

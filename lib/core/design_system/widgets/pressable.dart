import 'package:flutter/widgets.dart';

/// D-04: feedback de toque sem ripple. Sempre um nó semântico PRÓPRIO (container) de botão/link:
/// `semanticsLabel` != null → esse rótulo (= aria-label) e os filhos excluídos;
/// `semanticsLabel` == null → os textos dos filhos se fundem no nó (= nome calculado do conteúdo de um <a>).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.semanticsLabel,
    this.isLink = false,
  });
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final bool isLink;

  /// Liga/desliga o feedback de escala (D-04: "desligável por flag"). O repouso não muda.
  static bool feedbackEnabled = true;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  static const _pressedScale = 0.97;
  static const _pressDuration = Duration(milliseconds: 90);
  static const _releaseDuration = Duration(milliseconds: 120);

  bool _down = false;

  void _setDown(bool down) {
    if (_down == down) return;
    setState(() => _down = down);
  }

  // `container: true` é obrigatório: garante um nó próprio em QUALQUER contexto. Dentro de uma seção
  // (explicitChildNodes: true, que atravessa os render objects sem semântica) um Semantics anotado já formaria nó,
  // mas dentro de um nó sem explicitChildNodes (um link, um cabeçalho, um Semantics(container) qualquer)
  // o flag/rótulo do botão se fundiria nesse pai.
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: !widget.isLink,
    link: widget.isLink,
    label: widget.semanticsLabel,
    excludeSemantics: widget.semanticsLabel != null,
    onTap: widget.onTap,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: widget.onTap,
      onTapDown: (_) => _setDown(true),
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
      child: AnimatedScale(
        scale: Pressable.feedbackEnabled && _down ? _pressedScale : 1.0,
        duration: _down ? _pressDuration : _releaseDuration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    ),
  );
}

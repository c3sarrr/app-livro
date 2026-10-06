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
    this.toggled,
    this.selected,
    this.hint,
    this.enabled = true,
    this.checked,
  });
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final bool isLink;

  /// Botão de alternar (`aria-pressed`): o estado vai para a semântica (a fita do marcador — G12).
  final bool? toggled;

  /// Escolhido num grupo (a cor do grifo existente na barra de ações — G13).
  final bool? selected;

  /// O que o toque faz, quando não é o óbvio do rótulo (a cor do grifo existente apaga — G13).
  final String? hint;

  /// `false` = desabilitado: sem toque e "indisponível" para o leitor de tela (Fonte no PDF — D-122).
  final bool enabled;

  /// Opção de um grupo (radio — a fonte, o papel, a entrelinha e as margens da folha de ajustes, G14): marcada ou
  /// não; o nó vira uma opção num grupo exclusivo, não um botão.
  final bool? checked;

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
  Widget build(BuildContext context) {
    final onTap = widget.enabled ? widget.onTap : null;
    return Semantics(
      container: true,
      button: !widget.isLink && widget.checked == null,
      link: widget.isLink,
      checked: widget.checked,
      inMutuallyExclusiveGroup: widget.checked == null ? null : true,
      label: widget.semanticsLabel,
      toggled: widget.toggled,
      selected: widget.selected,
      hint: widget.hint,
      enabled: widget.enabled ? null : false,
      excludeSemantics: widget.semanticsLabel != null,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        // desabilitado: sem o "afundar" do toque (o resto continua como sempre foi)
        onTapDown: widget.enabled ? (_) => _setDown(true) : null,
        onTapUp: widget.enabled ? (_) => _setDown(false) : null,
        onTapCancel: widget.enabled ? () => _setDown(false) : null,
        child: AnimatedScale(
          scale: Pressable.feedbackEnabled && _down ? _pressedScale : 1.0,
          duration: _down ? _pressDuration : _releaseDuration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import 'neo_box.dart';
import 'pressable.dart';

/// Botão circular: tamanho d, fundo/borda opcionais, ícone centralizado e camadas sobrepostas (ponto/badge).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.size,
    required this.icon,
    this.color,
    this.border,
    this.overlays = const <Widget>[],
    this.onTap,
    required this.semanticsLabel,
  });
  final double size;
  final Widget icon;
  final Color? color;
  final BorderSide? border;

  /// `Positioned(...)` medidos a partir da borda INTERNA (padding box).
  final List<Widget> overlays;
  final VoidCallback? onTap;
  final String semanticsLabel;
  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticsLabel: semanticsLabel,
    child: NeoBox(
      width: size,
      height: size,
      color: color,
      border: border,
      radius: BorderRadius.circular(size / 2),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [icon, ...overlays],
      ),
    ),
  );
}

import 'package:flutter/widgets.dart';

import 'neo_box.dart';

/// Pílula que abraça o conteúdo (raio 999). `border` null = sem borda.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.padding,
    required this.color,
    this.border,
    required this.child,
  });
  final EdgeInsets padding;
  final Color color;
  final BorderSide? border;
  final Widget child;
  @override
  Widget build(BuildContext context) => NeoBox(
    color: color,
    border: border,
    radius: BorderRadius.circular(999),
    padding: padding,
    child: child,
  );
}

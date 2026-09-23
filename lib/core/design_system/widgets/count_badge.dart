import 'package:flutter/widgets.dart';

import '../text/app_text.dart';
import 'neo_box.dart';

/// Contador/badge: min-width, altura fixa, padding horizontal, raio 999, texto centralizado.
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.label,
    required this.style,
    required this.minWidth,
    required this.height,
    required this.horizontalPadding,
    required this.background,
    this.border,
  });
  final String label;
  final TextStyle style;
  final double minWidth, height, horizontalPadding;
  final Color background;
  final BorderSide? border;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minWidth: minWidth),
    child: NeoBox(
      height: height,
      color: background,
      border: border,
      radius: BorderRadius.circular(999),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Center(widthFactor: 1, child: AppText(label, style: style)),
    ),
  );
}

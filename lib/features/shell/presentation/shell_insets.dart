import 'package:flutter/widgets.dart';

/// O que o `MainShell` põe por cima do fim das abas além da barra (D-259): com a mini-barra do cronômetro, mais 96
/// (os 66 dela + os 30 de folga até a barra). Cada aba soma isto à sua folga do fim — a Início, 140 → 236; os blocos
/// mínimos das abas, 116 → 212 —, então nada fica escondido atrás da mini-barra. Fora do shell (as telas empilhadas
/// no navigator raiz: o leitor, o livro, o scanner), não há mini-barra e o valor é 0.
class ShellInsets extends InheritedWidget {
  const ShellInsets({
    super.key,
    required this.extraBottom,
    required super.child,
  });

  /// A folga a mais no fim das abas: 0 ou [miniBar].
  final double extraBottom;

  /// A mini-barra (66) + a folga até a barra (30).
  static const double miniBar = 96;

  /// A folga a mais no fim da aba de [context] (0 fora do shell). Quem lê reconstrói quando ela muda.
  static double extraBottomOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellInsets>()?.extraBottom ??
      0;

  @override
  bool updateShouldNotify(ShellInsets oldWidget) =>
      oldWidget.extraBottom != extraBottom;
}

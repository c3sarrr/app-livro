import 'package:flutter/widgets.dart';

import '../../../core/design_system/tokens/app_colors.dart';

/// Fade inferior (F11 11.1): `linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 55%)` em 150 px na base da
/// tela — transparente no topo e opaco a partir de 82,5 px (55%) até o fim. O início tem o MESMO RGB do papel
/// (alpha 0): assim a interpolação do Skia (sem pré-multiplicar) dá o mesmo resultado da do navegador.
///
/// `aria-hidden` (fora da árvore semântica). O `MainShell` o coloca num `IgnorePointer` (`pointer-events: none`)
/// e o pinta ANTES da barra.
class BottomFade extends StatelessWidget {
  const BottomFade({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.paperTransparent, AppColors.paper],
          stops: [0, 0.55],
        ),
      ),
    ),
  );
}

// G12.3 — a camada dos controles do leitor (telas 20/26b) por cima da página: o véu (`r20.fade`), a ilha de cima,
// o chip de tempo e a ilha de baixo, nos lugares da D-124 com as áreas do aparelho. Abre e fecha em 150 ms pela cor
// (sem `Opacity` — regra do projeto); fechada, nada é montado. O véu não pega toque: o toque fora das ilhas chega à
// página, que fecha os controles (D-117). E as transições do Tema (D-121): papel e ilhas em 220 ms.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'reader_chrome_palette.dart';
import 'reader_chrome_scope.dart';
import 'reader_overlays.dart' show readerFade;
import 'reader_palette.dart';

/// Papel, véu e ilhas trocam de cor em 220 ms ao tocar no Tema (D-121).
const Duration readerThemeDuration = Duration(milliseconds: 220);

/// D-124: ilha de cima em `max(54, área de cima + 7)`, chip 76 abaixo do topo dela e ilha de baixo em
/// `max(30, área de baixo − 4)` (no iPhone 390×844: 54/130/30, como o arquivo).
({double top, double chip, double bottom}) readerControlsLayout(
  EdgeInsets viewPadding,
) {
  final top = math.max(54.0, viewPadding.top + 7);
  return (
    top: top,
    chip: top + 76,
    bottom: math.max(30.0, viewPadding.bottom - 4),
  );
}

class ReaderPaletteTween extends Tween<ReaderPalette> {
  ReaderPaletteTween({super.begin, super.end});

  @override
  ReaderPalette lerp(double t) => ReaderPalette.lerp(begin!, end!, t);
}

class ReaderChromePaletteTween extends Tween<ReaderChromePalette> {
  ReaderChromePaletteTween({super.begin, super.end});

  @override
  ReaderChromePalette lerp(double t) =>
      ReaderChromePalette.lerp(begin!, end!, t);
}

class ReaderControls extends StatelessWidget {
  const ReaderControls({
    super.key,
    required this.open,
    required this.palette,
    required this.brand,
    required this.top,
    required this.chip,
    required this.bottom,
    this.toast,
  });

  final bool open;

  /// As cores do tema (inteiras; a camada esmaece sozinha).
  final ReaderChromePalette palette;
  final Color brand;

  /// A ilha de cima, o chip e a ilha de baixo (montados pela tela, que sabe os dados).
  final Widget top, chip, bottom;

  /// O aviso "Chega numa próxima fase" (D-118), 12 acima da ilha de baixo.
  final Widget? toast;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: open ? 1 : 0),
    duration: readerFade,
    builder: (context, a, _) {
      if (a == 0) return const SizedBox.shrink();
      final at = readerControlsLayout(MediaQuery.viewPaddingOf(context));
      final faded = palette.faded(a);
      final t = toast;
      return IgnorePointer(
        // fechando: os toques já vão para a página
        ignoring: !open,
        child: ExcludeSemantics(
          excluding: !open,
          child: ReaderChromeScope(
            palette: faded,
            brand: brand,
            a: a,
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      key: const ValueKey('r20.fade'),
                      color: faded.veil,
                    ),
                  ),
                ),
                Positioned(left: 14, right: 14, top: at.top, child: top),
                Positioned(
                  left: 0,
                  right: 0,
                  top: at.chip,
                  child: Center(child: chip),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: at.bottom,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (t != null) ...[
                        Center(child: t),
                        const SizedBox(height: 12),
                      ],
                      bottom,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

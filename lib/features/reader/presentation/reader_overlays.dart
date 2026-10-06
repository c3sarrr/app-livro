// G11.3 — o que aparece por cima da página enquanto os controles da tela 20 não chegam (G12):
// - "Fechar o livro" provisório (D-106): o círculo do `r20.topIsland.close` (44 px, papel, borda 1,5, seta) no
//   mesmo lugar (x 23,5, y 63), sem a ilha; aparece com o toque no centro e some com outro toque ou em 4 s
//   (150 ms, pela cor);
// - "← Voltar à pág. N" (D-108): pílula no estilo do app (fundo #FFFAF1, borda 1,5, sombra dura 2/2,
//   Figtree 12,5/800), centralizada na altura do rodapé, entre "pág." e "%".
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';

/// Lugar e tamanho do botão (r20.topIsland.close: ilha em 14,54 + 9,5,9 dentro dela).
const Offset readerCloseAt = Offset(23.5, 63);
const double readerCloseSize = 44;

/// Quanto o botão provisório fica na tela sem toque (D-106).
const Duration readerCloseLife = Duration(seconds: 4);
const Duration readerFade = Duration(milliseconds: 150);

class ReaderCloseButton extends StatelessWidget {
  const ReaderCloseButton({
    super.key,
    required this.visible,
    required this.onTap,
  });

  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Positioned(
    left: readerCloseAt.dx,
    top: readerCloseAt.dy,
    child: IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        // aparece e some em 150 ms pela cor (alpha no papel, na borda e na seta) — o app não usa camada de
        // opacidade (F12 12.4); inteiro, a seta fica com as cores do arquivo
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: visible ? 1 : 0),
          duration: readerFade,
          builder: (context, a, _) => a == 0
              ? const SizedBox.square(dimension: readerCloseSize)
              : CircleIconButton(
                  key: const ValueKey('leitor.fechar'),
                  size: readerCloseSize,
                  color: AppColors.paper.withValues(alpha: a),
                  border: BorderSide(
                    width: AppStrokes.regular,
                    color: AppColors.ink.withValues(alpha: a),
                  ),
                  icon: AppSvg(
                    AppIconsLeitor.arrowLeft,
                    size: 20,
                    color: a == 1 ? null : AppColors.ink.withValues(alpha: a),
                  ),
                  semanticsLabel: 'Fechar o livro',
                  onTap: onTap,
                ),
        ),
      ),
    ),
  );
}

class BackToPagePill extends StatelessWidget {
  const BackToPagePill({super.key, required this.refPage, required this.onTap});

  final int refPage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    semanticsLabel: 'Voltar à pág. $refPage',
    onTap: onTap,
    child: NeoBox(
      key: const ValueKey('leitor.voltarDoLink'),
      color: AppColors.surface,
      border: const BorderSide(width: AppStrokes.regular, color: AppColors.ink),
      radius: BorderRadius.circular(999),
      shadow: AppShadows.hard2,
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          const AppSvg(AppIconsLeitor.arrowLeft, size: 16),
          AppText(
            'Voltar à pág. $refPage',
            style: AppFonts.figtreeReader(12.5, FontWeight.w800),
            maxLines: 1,
          ),
        ],
      ),
    ),
  );
}

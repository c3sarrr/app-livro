// G16.6 — o topo do modo anotação (L22b): à esquerda, a pílula "Modo anotação" com o círculo amarelo do lápis e o
// subtítulo da ferramenta ("2 dedos movem a página" na Caneta); à direita, o botão verde "Concluir" (grava e sai —
// D-42). No Noite (D-167 17), a pílula com as cores das ilhas do Noite; o Concluir e o círculo amarelo ficam, com a
// borda e a sombra do Noite. Quem põe o topo no lugar é a camada do modo (`max(50, área segura de cima + 3)`, 14 de
// cada lado).
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import 'reader_chrome_scope.dart';

class AnnotationTopBar extends StatelessWidget {
  const AnnotationTopBar({
    super.key,
    required this.subtitle,
    required this.onDone,
  });

  /// A dica da ferramenta (L22b nº 6; "Arraste entre as linhas" no Espaço, tela 24).
  final String subtitle;

  /// Concluir: grava e volta ao leitor (D-42).
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final scope = ReaderChromeScope.of(context);
    final p = scope.palette;
    // a moldura aparece e some em 150 ms (as cores fixas e os ícones esmaecem com a paleta)
    final iconAlpha = scope.a < 1 ? scope.a : null;
    final side = BorderSide(width: AppStrokes.regular, color: p.border);
    final round = BorderRadius.circular(26);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeoBox(
          key: const ValueKey('ann.modePill'),
          height: 52,
          color: p.island,
          border: side,
          radius: round,
          shadow: AppShadows.hard3,
          shadowColor: p.shadow,
          padding: const EdgeInsets.only(left: 7, right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 9,
            children: [
              NeoBox(
                key: const ValueKey('ann.modePill.iconCircle'),
                width: 38,
                height: 38,
                color: scope.tint(AppColors.sun),
                border: side,
                radius: BorderRadius.circular(19),
                child: Center(
                  child: AppSvg(
                    AppIconsLeitor.pencil,
                    key: const ValueKey('ann.modePill.icon'),
                    size: 19,
                    opacity: iconAlpha,
                  ),
                ),
              ),
              // os dois textos são blocos: a largura de ambos é a do maior
              IntrinsicWidth(
                child: Column(
                  key: const ValueKey('ann.modePill.texts'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      'Modo anotação',
                      key: const ValueKey('ann.modePill.title'),
                      style: AppTextStyles.annModeTitle.copyWith(
                        color: p.title,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      subtitle,
                      key: const ValueKey('ann.modePill.subtitle'),
                      style: AppTextStyles.annModeSubtitle.copyWith(
                        color: p.muted,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Pressable(
          key: const ValueKey('ann.done'),
          semanticsLabel: 'Concluir',
          onTap: onDone,
          child: NeoBox(
            height: 52,
            color: scope.tint(AppColors.leaf),
            border: side,
            radius: round,
            shadow: AppShadows.hard3,
            shadowColor: p.shadow,
            padding: const EdgeInsets.only(left: 14, right: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 7,
              children: [
                AppSvg(
                  AppIconsLeitor.check,
                  key: const ValueKey('ann.done.icon'),
                  size: 19,
                  opacity: iconAlpha,
                ),
                AppText(
                  'Concluir',
                  style: AppTextStyles.annDone.copyWith(
                    color: scope.tint(AppColors.ink),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_icons.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../application/formatters.dart';
import '../../application/home_providers.dart';

/// Seção 1 — Cabeçalho (F03): avatar, saudação e sino.
/// Linha de 48 com `space-between`; a identidade (44) fica centralizada → começa em y + 2.
class HeaderSection extends ConsumerWidget {
  const HeaderSection({super.key, this.onNotificationsTap});

  /// Toque no sino (ligado à rota na F12).
  final VoidCallback? onNotificationsTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (user, now) = ref.watch(
      homeSnapshotProvider.select((s) => (s.user, s.now)),
    );
    return SizedBox(
      key: const ValueKey('header'),
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            key: const ValueKey('header.identity'),
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              NeoBox(
                key: const ValueKey('header.avatar'),
                width: 44,
                height: 44,
                color: AppColors.sun,
                border: const BorderSide(width: 1.5, color: AppColors.ink),
                radius: BorderRadius.circular(22),
                child: Center(
                  child: AppText(
                    user.initial,
                    style: AppTextStyles.avatarInitial,
                  ),
                ),
              ),
              // Coluna flex do CSS: largura do texto mais largo e os dois textos esticados a ela.
              IntrinsicWidth(
                child: Column(
                  key: const ValueKey('header.greetingColumn'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 1,
                  children: [
                    AppText(
                      HomeFormatters.greeting(now),
                      key: const ValueKey('header.greeting'),
                      style: AppTextStyles.body13Muted,
                    ),
                    AppText(
                      user.firstName,
                      key: const ValueKey('header.name'),
                      style: AppTextStyles.name16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          CircleIconButton(
            key: const ValueKey('header.bell'),
            size: 48,
            color: AppColors.surface,
            border: const BorderSide(width: 1.5, color: AppColors.ink),
            // Centralizado: (13, 13) a partir da borda externa do botão.
            icon: const AppSvg(
              AppIcons.bell,
              size: 22,
              key: ValueKey('header.bell.icon'),
            ),
            // Medidos a partir da borda interna (= position: absolute do CSS). Depois do ícone na
            // lista → pintado por cima dele.
            overlays: const [
              Positioned(
                top: 9,
                right: 11,
                child: NeoBox(
                  key: ValueKey('header.bell.dot'),
                  // 9 + 2 × 1,5 (content-box).
                  width: 12,
                  height: 12,
                  color: AppColors.flame,
                  // Borda da cor da superfície do botão: o "respiro" em volta do ponto.
                  border: BorderSide(width: 1.5, color: AppColors.surface),
                  radius: BorderRadius.all(Radius.circular(6)),
                ),
              ),
            ],
            onTap: onNotificationsTap,
            semanticsLabel: HomeFormatters.notificationsAria(
              user.unreadNotifications,
            ),
          ),
        ],
      ),
    );
  }
}

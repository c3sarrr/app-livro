import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_icons.dart';
import '../../../../core/design_system/tokens/app_icons_inicio.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../application/formatters.dart';
import '../../application/home_providers.dart';
import '../../domain/models.dart';

/// Seção 1 — Cabeçalho (F03; prancha 01, L01a1): avatar, saudação e as ações (lupa e sino, gap 8).
/// Linha de 48 com `space-between`; a identidade (44) fica centralizada → começa em y + 2.
class HeaderSection extends ConsumerWidget {
  const HeaderSection({
    super.key,
    this.onNotificationsTap,
    this.onSearchTap,
    this.user,
    this.now,
  });

  /// Toque no sino (ligado à rota na F12).
  final VoidCallback? onNotificationsTap;

  /// Toque na lupa (prancha 01): a Início passa o "sem ação" até a busca ter prancha (D-243 b, C14).
  final VoidCallback? onSearchTap;

  /// Carregando/erro (D-85): o cabeçalho vem da conta e do relógio, sem esperar os dados.
  final UserSummary? user;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final given = this.user;
    final givenNow = this.now;
    final (user, now) = given != null && givenNow != null
        ? (given, givenNow)
        : ref.watch(homeSnapshotProvider.select((s) => (s.user, s.now)));
    final (firstName, initial) = (user.firstName, user.initial);
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
                // Convidado (D-84): ícone de pessoa no lugar da inicial.
                child: Center(
                  child: initial == null
                      ? const AppSvg(
                          AppIcons.navProfile,
                          size: 22,
                          key: ValueKey('header.avatar.guest'),
                        )
                      : AppText(initial, style: AppTextStyles.avatarInitial),
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
                      HomeFormatters.greeting(now, named: firstName != null),
                      key: const ValueKey('header.greeting'),
                      style: AppTextStyles.body13Muted,
                    ),
                    if (firstName != null)
                      AppText(
                        firstName,
                        key: const ValueKey('header.name'),
                        style: AppTextStyles.name16,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            key: const ValueKey('header.actions'),
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              // `<a aria-label="Buscar livros">`: o mesmo círculo do sino, com o ícone de traço 1,9.
              CircleIconButton(
                key: const ValueKey('header.search'),
                size: 48,
                color: AppColors.surface,
                border: const BorderSide(width: 1.5, color: AppColors.ink),
                isLink: true,
                icon: const AppSvg(
                  AppIconsInicio.search,
                  size: 22,
                  key: ValueKey('header.search.icon'),
                ),
                onTap: onSearchTap,
                semanticsLabel: HomeFormatters.searchAria,
              ),
              _Bell(
                unread: user.unreadNotifications,
                onTap: onNotificationsTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// O sino com o ponto das novidades (F03).
class _Bell extends StatelessWidget {
  const _Bell({required this.unread, required this.onTap});

  final int unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => CircleIconButton(
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
    // Ponto só com novidades (até a G21 não há notificações reais).
    overlays: [
      if (unread > 0)
        const Positioned(
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
    onTap: onTap,
    semanticsLabel: HomeFormatters.notificationsAria(unread),
  );
}

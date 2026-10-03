import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/gallery/design_system_gallery.dart';
import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../../../core/design_system/widgets/pressable.dart';
import '../../application/home_providers.dart';

/// Tela da rota `/_ds` (só em debug): o seletor de tema (D-11) fixo no topo e a galeria do design system
/// (F01) rolando embaixo. A escolha vale para o app inteiro — ao voltar à Início, o hero, a pílula ativa da
/// navegação e as barras da semana já estão com as cores escolhidas. Produção não tem esta rota nem o
/// seletor: usa o padrão `#B6ACE4` (`HomeTheme`).
class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.paper,
    child: SafeArea(
      bottom: false,
      child: Column(
        children: [
          RepaintBoundary(child: HomeThemeSelector()),
          Expanded(child: DesignSystemGallery()),
        ],
      ),
    ),
  );
}

/// Seletor das props do arquivo (D-11): as 4 opções de `brand` (hero + item ativo da navegação) e as 4 de
/// `weekColor` (preenchimentos 0–5 do gráfico). Keys: `ds.theme.brand.0…3` e `ds.theme.weekColor.0…3`.
class HomeThemeSelector extends ConsumerWidget {
  const HomeThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(homeThemeProvider);
    final controller = ref.read(homeThemeProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          AppText('Tema (D-11)', style: AppTextStyles.label14Bold),
          _OptionRow(
            name: 'brand',
            options: AppColors.brandOptions,
            selected: theme.brand,
            onSelect: controller.setBrand,
          ),
          _OptionRow(
            name: 'weekColor',
            options: AppColors.weekColorOptions,
            selected: theme.weekColor,
            onSelect: controller.setWeekColor,
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.name,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String name;
  final List<Color> options;
  final Color selected;
  final ValueChanged<Color> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        SizedBox(
          width: 64,
          child: AppText(name, style: AppTextStyles.caption12Muted),
        ),
        for (final (i, color) in options.indexed)
          // Sem `semanticsLabel`: o nome do botão é o texto do conteúdo (o hex) e o `selected` se funde nele.
          Pressable(
            key: ValueKey('ds.theme.$name.$i'),
            onTap: () => onSelect(color),
            child: Semantics(
              selected: color == selected,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  NeoBox(
                    width: 44,
                    height: 32,
                    color: color,
                    border: BorderSide(
                      width: color == selected ? 3 : 1.5,
                      color: AppColors.ink,
                    ),
                    radius: BorderRadius.circular(10),
                  ),
                  AppText(_hex(color), style: AppTextStyles.navLabel),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';
}

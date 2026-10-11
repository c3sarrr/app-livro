import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons.dart';
import '../../../core/design_system/tokens/app_radii.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../../home/application/home_providers.dart';

/// Aba da barra: `branch` é o índice do ramo do `StatefulShellRoute` (Início 0, Biblioteca 1, Clubes 2, Perfil 3).
/// O Scanner não é aba: é uma ação (push de `/scanner`, D-08) e fica no meio da grade (posição 2).
class _Tab {
  const _Tab(this.id, this.label, this.branch, this.icon, this.iconActive);

  final String id;
  final String label;
  final int branch;

  /// Ícone de repouso (só traço) e o da aba ativa (com preenchimento `#FFFAF1`). Só o ativo da Início e o
  /// repouso das outras abas estão no arquivo; os outros dois são os `_extrapolado_*` da D-07.
  final String icon, iconActive;
}

const _home = _Tab(
  'nav.home',
  'Início',
  0,
  AppIcons.navHome,
  AppIcons.navHomeActive,
);
const _library = _Tab(
  'nav.library',
  'Biblioteca',
  1,
  AppIcons.navLibrary,
  AppIcons.navLibraryActive,
);
const _clubs = _Tab(
  'nav.clubs',
  'Clubes',
  2,
  AppIcons.navClubs,
  AppIcons.navClubsActive,
);
const _profile = _Tab(
  'nav.profile',
  'Perfil',
  3,
  AppIcons.navProfile,
  AppIcons.navProfileActive,
);

/// Navegação inferior flutuante (F11 11.2/11.3): `NeoBox` 358×70 (`#FFFAF1`, borda 1,5, raio 28, sombra dura
/// (0, 4), padding 8) com a grade de 5 colunas iguais e gap 4 (itens de 64,6 × 51): Início, Biblioteca, Scanner,
/// Clubes e Perfil. A cor do item ativo é o `brand` do tema (o mesmo do hero).
///
/// O FAB do Scanner NÃO está aqui: o `MainShell` o pinta depois da barra, para o toque valer no círculo inteiro.
class FloatingNavBar extends ConsumerWidget {
  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.onScanner,
  });

  /// Ramo ativo (`StatefulNavigationShell.currentIndex`).
  final int currentIndex;

  /// Toque numa aba: recebe o índice do ramo.
  final ValueChanged<int>? onSelect;

  /// Toque no item "Scanner" (o FAB chama o mesmo callback).
  final VoidCallback? onScanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(homeThemeProvider.select((t) => t.brand));
    final onSelect = this.onSelect;
    Widget tab(_Tab t) => Expanded(
      child: _TabItem(
        tab: t,
        active: t.branch == currentIndex,
        brand: brand,
        onTap: onSelect == null ? null : () => onSelect(t.branch),
      ),
    );
    // <nav aria-label="Navegação principal"> (convenção §5.1 do prompt mestre).
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Navegação principal',
      child: NeoBox(
        color: AppColors.surface,
        border: const BorderSide(
          width: AppStrokes.regular,
          color: AppColors.ink,
        ),
        radius: BorderRadius.circular(AppRadii.card),
        shadow: AppShadows.drop4,
        padding: const EdgeInsets.all(8),
        // `align-items: stretch` do grid: cada item ocupa a altura toda (51).
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            tab(_home),
            tab(_library),
            Expanded(child: _ScannerItem(onTap: onScanner)),
            tab(_clubs),
            tab(_profile),
          ],
        ),
      ),
    );
  }
}

/// `<a>` de aba: coluna centralizada (gap 3) com o ícone 22 e o rótulo 11. Ativo (`aria-current="page"`): fundo
/// `brand`, borda 1,5, raio 20, ícone com preenchimento e rótulo 700; inativo: sem fundo nem borda, rótulo
/// 600 `#5B544B`. A Key do id fica no `Pressable` (o retângulo do `<a>`, 64,6 × 51).
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.active,
    required this.brand,
    required this.onTap,
  });

  final _Tab tab;
  final bool active;
  final Color brand;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 3,
      children: [
        AppSvg(
          active ? tab.iconActive : tab.icon,
          size: 22,
          key: ValueKey('${tab.id}.icon'),
        ),
        AppText(
          tab.label,
          key: ValueKey('${tab.id}.label'),
          style: active ? AppTextStyles.micro11Bold : AppTextStyles.navLabel,
        ),
      ],
    );
    // <a href>: sem aria-label → o nome do link é o texto do rótulo (o ícone é um SVG sem nome acessível).
    // `aria-current="page"` = `Semantics(selected: true)` DENTRO do Pressable (sem `container`, o flag se funde
    // no nó do link; por fora criaria um nó a mais).
    return Pressable(
      key: ValueKey(tab.id),
      isLink: true,
      onTap: onTap,
      child: active
          ? Semantics(
              selected: true,
              child: NeoBox(
                color: brand,
                border: const BorderSide(
                  width: AppStrokes.regular,
                  color: AppColors.ink,
                ),
                radius: BorderRadius.circular(AppRadii.navItem),
                child: content,
              ),
            )
          : content,
    );
  }
}

/// Item do meio: conteúdo alinhado EMBAIXO (`justify-content: flex-end`), só o rótulo "Scanner" 11/700 com
/// `padding-bottom: 2` (a caixa de 41,3 × 15,2 leva a Key `nav.scanner.label`). O círculo do FAB é o
/// `ScannerFab`, irmão desta barra no `MainShell`. Nome acessível = o `aria-label` do arquivo.
class _ScannerItem extends StatelessWidget {
  const _ScannerItem({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    key: const ValueKey('nav.scanner'),
    isLink: true,
    semanticsLabel: 'Scanner: escanear livro ou página',
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 3,
      children: [
        Padding(
          key: const ValueKey('nav.scanner.label'),
          padding: const EdgeInsets.only(bottom: 2),
          child: AppText('Scanner', style: AppTextStyles.micro11Bold),
        ),
      ],
    ),
  );
}

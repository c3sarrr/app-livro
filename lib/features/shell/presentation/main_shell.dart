import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart' show AppRoutes;
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../library/presentation/incoming_books.dart' show LibraryTabSwitcher;
import 'bottom_fade.dart';
import 'floating_nav_bar.dart';
import 'scanner_fab.dart';

/// Camadas fixas sobre o conteúdo das abas (D-01), na ordem de pintura do HTML:
/// conteúdo da aba → fade inferior → navegação → FAB do Scanner (que sobe 20,5 px acima da barra).
/// Sem `Scaffold` aqui: o da `HomeScreen` é o único tratador do toque na status bar.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  /// D-13: status bar transparente com ícones escuros; Android edge-to-edge.
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
  );

  /// D-02: `bottom` da navegação = max(30, viewPadding.bottom − 4).
  static double navBottom(BuildContext context) => math.max(
    AppSpacing.navBottomMin,
    MediaQuery.viewPaddingOf(context).bottom - 4,
  );

  /// Troca de aba. Tocar na aba já ativa volta à rota inicial dela (comportamento padrão do go_router).
  void _selectTab(int branch) =>
      shell.goBranch(branch, initialLocation: branch == shell.currentIndex);

  /// D-08: o Scanner abre por push no navigator raiz; a aba ativa não muda.
  void _openScanner(BuildContext context) =>
      unawaited(context.push<void>(AppRoutes.scanner));

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final navBottom = MainShell.navBottom(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      // G09 (D-87): o "Abrir com" chegou com outra aba aberta → Biblioteca
      child: LibraryTabSwitcher(
        onRequest: () => _selectTab(1),
        child: Stack(
          children: [
            // Conteúdo da aba.
            Positioned.fill(child: shell),
            // Fade inferior: `pointer-events: none`, pinta antes da barra.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 150,
              child: IgnorePointer(
                child: BottomFade(key: ValueKey('bottomFade')),
              ),
            ),
            // Barra flutuante.
            Positioned(
              left: AppSpacing.navSide,
              right: AppSpacing.navSide,
              bottom: navBottom,
              height: AppSpacing.navHeight,
              child: FloatingNavBar(
                key: const ValueKey('nav'),
                currentIndex: shell.currentIndex,
                onSelect: _selectTab,
                onScanner: () => _openScanner(context),
              ),
            ),
            // FAB: centro horizontal da tela (o item do meio é simétrico) e topo = topo do item − 30. Irmão da barra,
            // depois dela: pinta por cima e o toque vale no círculo inteiro.
            Positioned(
              left: (width - ScannerFab.size) / 2,
              bottom: ScannerFab.bottom(navBottom),
              width: ScannerFab.size,
              height: ScannerFab.size,
              child: ScannerFab(
                key: const ValueKey('nav.scanner.fab'),
                onTap: () => _openScanner(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

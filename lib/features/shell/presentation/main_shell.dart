import 'dart:math' as math;

import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/tokens/app_spacing.dart';

/// Camadas fixas sobre o conteúdo das abas (D-01), na ordem de pintura do HTML:
/// conteúdo da aba → fade inferior → navegação (→ FAB do Scanner, na F11).
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

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: overlayStyle,
    child: Stack(
      children: [
        // Conteúdo da aba.
        Positioned.fill(child: shell),
        // F11 desenha o gradiente.
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 150,
          child: IgnorePointer(
            child: SizedBox.expand(key: ValueKey('bottomFade')),
          ),
        ),
        // F11 desenha a barra.
        Positioned(
          left: AppSpacing.navSide,
          right: AppSpacing.navSide,
          bottom: navBottom(context),
          height: AppSpacing.navHeight,
          child: const SizedBox.expand(key: ValueKey('nav')),
        ),
        // F11: ScannerFab posicionado aqui (acima da barra).
      ],
    ),
  );
}

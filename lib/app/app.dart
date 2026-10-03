import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:go_router/go_router.dart';

import '../core/design_system/tokens/app_colors.dart';
import '../core/design_system/tokens/app_typography.dart';
import '../features/shell/presentation/main_shell.dart' show MainShell;
import 'router.dart';

/// Raiz do app (F02 2.5): `MaterialApp.router` com tema mínimo (sem splash/realce do Material),
/// escala de texto do sistema travada em 1,0 (D-05), distribuição "even" (§6.2) e o corpo do arquivo
/// (Figtree 16/400, cor tinta) como estilo padrão.
class App extends StatefulWidget {
  const App({super.key}) : _forTests = false;

  /// Mesmo app, sempre começando em `/inicio` (ignora a rota inicial da plataforma): goldens e testes.
  const App.forTests({super.key}) : _forTests = true;

  final bool _forTests;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createRouter(
    initialLocation: AppRoutes.inicio,
    overridePlatformDefaultLocation: widget._forTests,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  // O tema é criado aqui (não em campo estático): `ThemeData.platform` é lido de
  // `defaultTargetPlatform` na construção.
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.paper,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    ),
    routerConfig: _router,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: DefaultTextHeightBehavior(
        textHeightBehavior: const TextHeightBehavior(
          leadingDistribution: TextLeadingDistribution.even,
        ),
        // Corpo do arquivo: Figtree 16/400, cor tinta.
        child: DefaultTextStyle(
          style: AppFonts.figtree(16, FontWeight.w400),
          // D-13 (F12 12.5): status bar transparente com ícones escuros e barra de navegação do Android
          // transparente, sem scrim — em TODAS as rotas (as telas cheias fora do shell também), não só nas abas.
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: MainShell.overlayStyle,
            child: child!,
          ),
        ),
      ),
    ),
  );
}

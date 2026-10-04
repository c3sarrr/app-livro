import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/account/presentation/account_block.dart';
import '../features/account/presentation/onboarding_screen.dart';
import '../features/account/presentation/sign_in_screen.dart';
import '../features/home/presentation/debug/design_system_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/placeholder/presentation/placeholder_screen.dart';
import '../features/shell/presentation/main_shell.dart';
import 'routes.dart';

export 'routes.dart';

/// Roteador do app: `StatefulShellRoute.indexedStack` com as 4 abas (cada aba preserva o próprio
/// estado, inclusive a rolagem) e as rotas full screen no navigator raiz.
/// [overridePlatformDefaultLocation] = true ignora a rota inicial da plataforma (deep link) e sempre
/// começa em [initialLocation] — usado por `App.forTests()`.
GoRouter createRouter({
  String initialLocation = AppRoutes.inicio,
  bool overridePlatformDefaultLocation = false,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'raiz');

  GoRoute fullScreen(String path, String title, {bool dialog = false}) =>
      GoRoute(
        path: path,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _page(state, PlaceholderScreen(title), fullscreenDialog: dialog),
      );

  StatefulShellBranch tab(String path, Widget screen) => StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        pageBuilder: (context, state) => _page(state, screen),
      ),
    ],
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    overridePlatformDefaultLocation: overridePlatformDefaultLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        pageBuilder: (context, state, shell) =>
            _page(state, MainShell(shell: shell)),
        branches: [
          tab(AppRoutes.inicio, const HomeScreen()),
          tab(AppRoutes.biblioteca, const PlaceholderScreen('Biblioteca')),
          tab(AppRoutes.clubes, const PlaceholderScreen('Clubes')),
          // D-69: até o design do Perfil, o placeholder ganha o bloco mínimo da conta (D-21).
          tab(
            AppRoutes.perfil,
            const PlaceholderScreen('Perfil', below: AccountBlock()),
          ),
        ],
      ),
      fullScreen(AppRoutes.scanner, 'Scanner', dialog: true),
      fullScreen(AppRoutes.notificacoes, 'Notificações'),
      fullScreen('/leitor/:bookId', 'Leitor'),
      fullScreen('/livro/:bookId', 'Livro'),
      fullScreen('/livro/:bookId/destaques', 'Destaques e notas'),
      fullScreen(AppRoutes.paraVoce, 'Para você'),
      fullScreen('/clube/:clubId/discussao', 'Discussão'),
      GoRoute(
        path: AppRoutes.entrar,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _page(state, const SignInScreen(), fullscreenDialog: true),
      ),
      GoRoute(
        path: AppRoutes.cadastro,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _page(state, const OnboardingScreen()),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.designSystem,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) =>
              _page(state, const DesignSystemScreen()),
        ),
    ],
  );
}

/// Página Material do SDK, com os mesmos parâmetros que o go_router usa por padrão.
/// Motivo: o go_router 18 só reconhece o `MaterialApp` do pacote `material_ui`; com o
/// `MaterialApp.router` do SDK (F02 2.5), rotas com `builder:` virariam `NoTransitionPage`.
Page<void> _page(
  GoRouterState state,
  Widget child, {
  bool fullscreenDialog = false,
}) => MaterialPage<void>(
  key: state.pageKey,
  name: state.name ?? state.path,
  arguments: <String, String>{
    ...state.pathParameters,
    ...state.uri.queryParameters,
  },
  restorationId: state.pageKey.value,
  fullscreenDialog: fullscreenDialog,
  child: child,
);

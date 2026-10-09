import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/account/presentation/account_block.dart';
import '../features/account/presentation/onboarding_screen.dart';
import '../features/account/presentation/sign_in_screen.dart';
import '../features/home/presentation/debug/design_system_screen.dart';
import '../features/highlights/presentation/highlights_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/library_import_block.dart';
import '../features/placeholder/presentation/placeholder_screen.dart';
import '../features/reader/presentation/reader_screen.dart';
import '../features/scanner/presentation/scanner_screen.dart';
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
    restorationScopeId: 'aba$path',
    routes: [
      GoRoute(
        path: path,
        pageBuilder: (context, state) => _page(state, screen),
      ),
    ],
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    // D-207: a pilha de rotas e a aba voltam depois que o sistema fecha o app
    restorationScopeId: 'raiz',
    initialLocation: initialLocation,
    overridePlatformDefaultLocation: overridePlatformDefaultLocation,
    routes: [
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'abas',
        // D-207: a página das abas com o id de restauração fixo — o `pageKey` dela é o hash da rota, que muda a
        // cada abertura do app e perderia o que as abas guardaram (a rolagem da Início)
        pageBuilder: (context, state, shell) =>
            _page(state, MainShell(shell: shell), restorationId: 'abas.pagina'),
        branches: [
          tab(AppRoutes.inicio, const HomeScreen()),
          // G09 (D-87): até o design da Biblioteca, o placeholder ganha o bloco mínimo de importar (D-21).
          tab(
            AppRoutes.biblioteca,
            const PlaceholderScreen('Biblioteca', below: LibraryImportBlock()),
          ),
          tab(AppRoutes.clubes, const PlaceholderScreen('Clubes')),
          // D-69: até o design do Perfil, o placeholder ganha o bloco mínimo da conta (D-21).
          tab(
            AppRoutes.perfil,
            const PlaceholderScreen('Perfil', below: AccountBlock()),
          ),
        ],
      ),
      // G07 (D-76): scanner provisório no estilo do app até o design das telas 01–18
      GoRoute(
        path: AppRoutes.scanner,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _page(state, const ScannerScreen(), fullscreenDialog: true),
      ),
      fullScreen(AppRoutes.notificacoes, 'Notificações'),
      // G11: a tela 19 de verdade (o leitor limpo), aberta pelo id do livro na estante
      GoRoute(
        path: '/leitor/:bookId',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _page(
          state,
          ReaderScreen(
            bookId: state.pathParameters['bookId']!,
            goTo: state.uri.queryParameters['ir'],
          ),
        ),
      ),
      fullScreen('/livro/:bookId', 'Livro'),
      // G19: a tela 25 de verdade (grifos e notas do livro); `?de=leitor` = aberta pelo leitor (R13)
      GoRoute(
        path: '/livro/:bookId/destaques',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => _page(
          state,
          HighlightsScreen(
            bookId: state.pathParameters['bookId']!,
            fromReader: state.uri.queryParameters['de'] == 'leitor',
          ),
        ),
      ),
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
  String? restorationId,
}) => MaterialPage<void>(
  key: state.pageKey,
  name: state.name ?? state.path,
  arguments: <String, String>{
    ...state.pathParameters,
    ...state.uri.queryParameters,
  },
  restorationId: restorationId ?? state.pageKey.value,
  fullscreenDialog: fullscreenDialog,
  child: child,
);

// Separados do roteador (G05) para as telas poderem navegar sem importá-lo.

/// Caminhos das rotas (F02 2.6).
abstract final class AppRoutes {
  // Abas (ramos do StatefulShellRoute).
  static const inicio = '/inicio';
  static const biblioteca = '/biblioteca';
  static const clubes = '/clubes';
  static const perfil = '/perfil';

  /// Full screen, fora do shell (D-08).
  static const scanner = '/scanner';

  // Destinos (placeholders; usados na F12).
  static const notificacoes = '/notificacoes';
  static const paraVoce = '/para-voce';
  static String leitor(String bookId) => '/leitor/$bookId';
  static String livro(String bookId) => '/livro/$bookId';
  static String destaques(String bookId) => '/livro/$bookId/destaques';
  static String discussao(String clubId) => '/clube/$clubId/discussao';

  /// Conta (G05, D-69): login e conclusão do cadastro (idade e @), em tela cheia.
  static const entrar = '/entrar';
  static const cadastro = '/conta/cadastro';

  /// Galeria do design system (F01) — somente em debug.
  static const designSystem = '/_ds';
}

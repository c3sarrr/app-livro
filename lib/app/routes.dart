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

  /// G19 (R13): [goTo] = o id de uma anotação para o leitor saltar logo depois de abrir (`?ir=`).
  static String leitor(String bookId, {String? goTo}) => goTo == null
      ? '/leitor/$bookId'
      : '/leitor/$bookId?ir=${Uri.encodeQueryComponent(goTo)}';
  static String livro(String bookId) => '/livro/$bookId';

  /// G19: a tela 25; [fromReader] = aberta pelo botão Grifos do leitor (`?de=leitor` — as saídas voltam a ele).
  static String destaques(String bookId, {bool fromReader = false}) =>
      '/livro/$bookId/destaques${fromReader ? '?de=leitor' : ''}';
  static String discussao(String clubId) => '/clube/$clubId/discussao';

  /// Conta (G05, D-69): login e conclusão do cadastro (idade e @), em tela cheia.
  static const entrar = '/entrar';
  static const cadastro = '/conta/cadastro';

  /// Galeria do design system (F01) — somente em debug.
  static const designSystem = '/_ds';

  /// G22: a tela técnica do Pro (o paywall ainda sem design — D-230) — somente em debug. [motivo] = o gatilho que
  /// a abriu (`PaywallReason.name`).
  static const proTecnico = '/_pro';
  static String proTecnicoCom(String motivo) =>
      '$proTecnico?motivo=${Uri.encodeQueryComponent(motivo)}';
}

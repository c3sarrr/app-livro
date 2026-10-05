import '../domain/models.dart';

/// Fonte dos dados da tela Início.
///
/// Produção: o banco local do aparelho (`LocalHomeRepository` — G08, D-85). Os testes de fidelidade e o
/// app de desenvolvimento usam a fixture do mundo de referência (`test/fixtures/`, D-34): produção não tem
/// dado de usuário escrito no código (PROMPT MESTRE §4.3.1).
abstract interface class HomeRepository {
  /// Um instantâneo a cada mudança dos dados; o primeiro sai assim que fica pronto. Erro no fluxo = estado
  /// de erro da tela (D-85). [clock] dá o "agora" de cada recálculo.
  Stream<HomeSnapshot> watch(DateTime Function() clock);
}

/// Fonte que já tem o instantâneo na hora (a fixture — D-09): a Início abre sem "carregando".
abstract interface class SyncHomeRepository implements HomeRepository {
  HomeSnapshot snapshot(DateTime now);
}

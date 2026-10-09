// G22.2 — a interface da loja (docs/progresso/G22.md §2), no padrão da G07: a de verdade é o RevenueCat
// (`RevenueCatGateway`); os testes usam um dublê. O provider é nulo sem chave (o app segue sem compra).
import '../domain/billing_models.dart';

abstract interface class BillingGateway {
  /// Configura o RevenueCat com o id do Supabase como `appUserID` (R1). Já configurado: `logIn`.
  Future<void> configure({required String appUserId});

  /// Entrar ou trocar de conta (R1). Devolve o Pro da conta nova.
  Future<ProCustomer> logIn(String appUserId);

  /// Sair (R1): o app volta a não usar o RevenueCat.
  Future<void> logOut();

  /// Os pacotes da offering `default` (`$rc_monthly`, `$rc_annual`), com o teste grátis só se elegível (R4).
  Future<List<ProPackage>> packages();

  /// Compra pelo id do pacote. A pessoa fechar a folha não é falha ([PurchaseCancelled]).
  Future<PurchaseOutcome> purchase(String packageId);

  /// R5: as compras da conta da loja.
  Future<ProCustomer> restore();

  /// O Pro que a loja informa agora (com o cache do SDK).
  Future<ProCustomer> customer();

  /// As mudanças que a loja avisa (renovação, cancelamento, expiração).
  Stream<ProCustomer> customerUpdates();
}

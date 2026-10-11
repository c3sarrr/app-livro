// G22.2 — o domínio da compra do Pro (docs/progresso/G22.md §2): o que a loja vende, o que ela diz da conta, o
// resultado de uma compra e as falhas. Nada aqui conhece o SDK do RevenueCat (o gateway traduz).
import 'package:flutter/foundation.dart' show immutable;

enum ProPeriod { month, year }

/// Um pacote da offering `default` (`$rc_monthly` ou `$rc_annual`). O preço é sempre o da loja (R4).
@immutable
final class ProPackage {
  const ProPackage({
    required this.id,
    required this.period,
    required this.priceString,
    required this.price,
    required this.currencyCode,
    this.trialDays,
  });

  /// O id do pacote no RevenueCat (`$rc_monthly`, `$rc_annual`): é o que a compra recebe.
  final String id;
  final ProPeriod period;

  /// O preço formatado pela loja ("R$ 9,99"): o único que aparece na tela.
  final String priceString;

  /// O preço em número, só para a economia do anual (R4).
  final double price;
  final String currencyCode;

  /// Os dias de teste grátis, só quando a conta da loja é elegível (D-232); nulo sem teste.
  final int? trialDays;

  @override
  bool operator ==(Object other) =>
      other is ProPackage &&
      other.id == id &&
      other.period == period &&
      other.priceString == priceString &&
      other.price == price &&
      other.currencyCode == currencyCode &&
      other.trialDays == trialDays;

  @override
  int get hashCode =>
      Object.hash(id, period, priceString, price, currencyCode, trialDays);

  @override
  String toString() => 'ProPackage($id, $priceString, teste: $trialDays)';
}

/// O que a loja (pelo RevenueCat) diz do Pro desta conta. É o que a tela mostra (R2); o sync segue o servidor.
@immutable
final class ProCustomer {
  const ProCustomer({
    required this.active,
    this.activeUntil,
    this.willRenew = false,
    this.billingIssue = false,
    this.graceUntil,
    this.managementUrl,
    this.store,
    this.sandbox = false,
  });

  static const none = ProCustomer(active: false);

  /// O entitlement `pro` está ativo.
  final bool active;

  /// O fim do período pago (UTC); nulo num Pro sem data de fim.
  final DateTime? activeUntil;
  final bool willRenew;

  /// A loja não conseguiu cobrar (carência ou nova tentativa).
  final bool billingIssue;

  /// O fim da carência, quando a loja informa.
  final DateTime? graceUntil;

  /// A página de gestão da assinatura na loja (R6).
  final String? managementUrl;
  final String? store;
  final bool sandbox;

  @override
  bool operator ==(Object other) =>
      other is ProCustomer &&
      other.active == active &&
      other.activeUntil == activeUntil &&
      other.willRenew == willRenew &&
      other.billingIssue == billingIssue &&
      other.graceUntil == graceUntil &&
      other.managementUrl == managementUrl &&
      other.store == store &&
      other.sandbox == sandbox;

  @override
  int get hashCode => Object.hash(
    active,
    activeUntil,
    willRenew,
    billingIssue,
    graceUntil,
    managementUrl,
    store,
    sandbox,
  );

  @override
  String toString() =>
      'ProCustomer(ativo: $active, até: $activeUntil, renova: $willRenew, cobrança: $billingIssue)';
}

/// O resultado de uma compra que não falhou (R3).
sealed class PurchaseOutcome {
  const PurchaseOutcome();
}

final class Purchased extends PurchaseOutcome {
  const Purchased(this.customer);
  final ProCustomer customer;
}

/// A pessoa fechou a folha da loja: volta sem aviso.
final class PurchaseCancelled extends PurchaseOutcome {
  const PurchaseCancelled();
}

/// A loja aceitou, mas o pagamento ainda está em análise.
final class PurchasePending extends PurchaseOutcome {
  const PurchasePending();
}

/// As falhas da compra (R3, R5). O código é curto e sem conteúdo (telemetria e testes).
sealed class BillingFailure implements Exception {
  const BillingFailure(this.code);
  final String code;

  @override
  String toString() => 'BillingFailure($code)';
}

/// Sem rede ou a loja sem resposta: "Sem conexão. Tente de novo."
final class BillingOffline extends BillingFailure {
  const BillingOffline() : super('rede');
}

/// A loja não está disponível no aparelho (sem Play Store, conta da loja com problema).
final class StoreUnavailable extends BillingFailure {
  const StoreUnavailable() : super('loja');
}

/// A conta da loja já assina: o app restaura (R3 → R5).
final class AlreadySubscribed extends BillingFailure {
  const AlreadySubscribed() : super('ja_assina');
}

/// O aparelho não permite compras (controle dos pais, perfil restrito).
final class PurchaseNotAllowed extends BillingFailure {
  const PurchaseNotAllowed() : super('nao_permitido');
}

/// Comprar exige conta (R1).
final class BillingNeedsAccount extends BillingFailure {
  const BillingNeedsAccount() : super('sem_conta');
}

final class BillingUnknown extends BillingFailure {
  const BillingUnknown(super.code);
}

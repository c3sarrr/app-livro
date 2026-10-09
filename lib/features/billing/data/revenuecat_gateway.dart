// G22.2 — o RevenueCat de verdade (`purchases_flutter` 10.14.0, Anexo 04): traduz o `CustomerInfo` em
// `ProCustomer`, os pacotes da offering `default` em `ProPackage` e o `PlatformException` do SDK em
// `BillingFailure`. As chamadas estáticas do SDK ficam num objeto (`PurchasesApi`) para o teste trocar.
import 'dart:async';

import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

import '../domain/billing_models.dart';
import 'billing_gateway.dart';

/// As chamadas do SDK usadas pelo app (uma por método, sem lógica).
class PurchasesApi {
  const PurchasesApi();

  Future<bool> isConfigured() => Purchases.isConfigured;
  Future<void> configure(PurchasesConfiguration c) => Purchases.configure(c);
  Future<LogInResult> logIn(String appUserId) => Purchases.logIn(appUserId);
  Future<CustomerInfo> logOut() => Purchases.logOut();
  Future<Offerings> getOfferings() => Purchases.getOfferings();
  Future<Map<String, IntroEligibility>>
  checkTrialOrIntroductoryPriceEligibility(List<String> productIds) =>
      Purchases.checkTrialOrIntroductoryPriceEligibility(productIds);
  Future<PurchaseResult> purchase(PurchaseParams params) =>
      Purchases.purchase(params);
  Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();
  Future<CustomerInfo> getCustomerInfo() => Purchases.getCustomerInfo();
  void addCustomerInfoUpdateListener(CustomerInfoUpdateListener l) =>
      Purchases.addCustomerInfoUpdateListener(l);
  void removeCustomerInfoUpdateListener(CustomerInfoUpdateListener l) =>
      Purchases.removeCustomerInfoUpdateListener(l);
}

/// O entitlement que libera o Pro no painel do RevenueCat.
const proEntitlement = 'pro';

DateTime? _instant(String? iso) =>
    iso == null ? null : DateTime.tryParse(iso)?.toUtc();

/// O `CustomerInfo` do SDK → o Pro da tela. Sem o entitlement `pro` ativo: [ProCustomer.none].
ProCustomer customerFromInfo(CustomerInfo info) {
  final e = info.entitlements.active[proEntitlement];
  if (e == null || !e.isActive) return ProCustomer.none;
  final subs = info.subscriptionsByProductIdentifier;
  // no Play a chave é "produto:plano"; nas outras lojas, o produto
  final sub =
      (e.productPlanIdentifier != null
          ? subs['${e.productIdentifier}:${e.productPlanIdentifier}']
          : null) ??
      subs[e.productIdentifier];
  return ProCustomer(
    active: true,
    activeUntil: _instant(e.expirationDate),
    willRenew: e.willRenew,
    billingIssue: e.billingIssueDetectedAt != null,
    graceUntil: _instant(sub?.gracePeriodExpiresDate),
    managementUrl: sub?.managementURL ?? info.managementURL,
    store: e.store.name,
    sandbox: e.isSandbox,
  );
}

/// O erro do SDK → a falha da tela (R3). Cancelar e pagamento pendente não passam por aqui (a compra trata).
PurchasesErrorCode? _codeOf(PlatformException e) {
  try {
    return PurchasesErrorHelper.getErrorCode(e);
  } on FormatException {
    return null; // um código que não é do SDK
  }
}

BillingFailure billingFailureOf(PlatformException e) {
  final code = _codeOf(e);
  if (code == null) return BillingUnknown(e.code);
  return switch (code) {
    PurchasesErrorCode.networkError ||
    PurchasesErrorCode.offlineConnectionError => const BillingOffline(),
    PurchasesErrorCode.storeProblemError => const StoreUnavailable(),
    PurchasesErrorCode.productAlreadyPurchasedError =>
      const AlreadySubscribed(),
    PurchasesErrorCode.purchaseNotAllowedError => const PurchaseNotAllowed(),
    _ => BillingUnknown(code.name),
  };
}

/// Os dias de teste grátis do preço de entrada; um preço de entrada pago não é teste.
int? _trialDays(IntroductoryPrice? intro) {
  if (intro == null || intro.price > 0) return null;
  final porUnidade = switch (intro.periodUnit) {
    PeriodUnit.day => 1,
    PeriodUnit.week => 7,
    PeriodUnit.month => 30,
    PeriodUnit.year => 365,
    PeriodUnit.unknown => 0,
  };
  final dias =
      intro.periodNumberOfUnits *
      porUnidade *
      (intro.cycles < 1 ? 1 : intro.cycles);
  return dias > 0 ? dias : null;
}

final class RevenueCatGateway implements BillingGateway {
  RevenueCatGateway({
    required this.apiKey,
    this.api = const PurchasesApi(),
    required this.platform,
  });

  /// A chave PÚBLICA do RevenueCat (do env).
  final String apiKey;
  final PurchasesApi api;
  final TargetPlatform platform;

  /// Os pacotes da última leitura da offering, pelo id (a compra precisa do objeto do SDK).
  final _packages = <String, Package>{};
  final _updates = StreamController<ProCustomer>.broadcast();
  bool _listening = false;

  void _onCustomerInfo(CustomerInfo info) =>
      _updates.add(customerFromInfo(info));

  Future<T> _call<T>(Future<T> Function() f) async {
    try {
      return await f();
    } on PlatformException catch (e) {
      throw billingFailureOf(e);
    }
  }

  @override
  Future<void> configure({required String appUserId}) => _call(() async {
    if (await api.isConfigured()) {
      await api.logIn(appUserId);
    } else {
      await api.configure(
        PurchasesConfiguration(apiKey)..appUserID = appUserId,
      );
    }
    if (!_listening) {
      api.addCustomerInfoUpdateListener(_onCustomerInfo);
      _listening = true;
    }
  });

  @override
  Future<ProCustomer> logIn(String appUserId) => _call(
    () async => customerFromInfo((await api.logIn(appUserId)).customerInfo),
  );

  @override
  Future<void> logOut() async {
    try {
      await api.logOut();
    } on PlatformException catch (e) {
      final code = billingFailureOf(e);
      // o SDK já estava com o usuário anônimo: nada a sair
      if (code is BillingUnknown &&
          code.code == PurchasesErrorCode.logOutWithAnonymousUserError.name) {
        return;
      }
      throw code;
    }
  }

  @override
  Future<List<ProPackage>> packages() => _call(() async {
    final ofertas = await api.getOfferings();
    final offering = ofertas.current ?? ofertas.all['default'];
    _packages.clear();
    if (offering == null) return const <ProPackage>[];
    final porPeriodo = <ProPeriod, Package>{};
    for (final p in offering.availablePackages) {
      final periodo = switch (p.packageType) {
        PackageType.monthly => ProPeriod.month,
        PackageType.annual => ProPeriod.year,
        _ => null,
      };
      if (periodo != null) porPeriodo.putIfAbsent(periodo, () => p);
    }
    final escolhidos = [
      for (final periodo in ProPeriod.values)
        if (porPeriodo[periodo] case final p?) (periodo, p),
    ];
    var elegibilidade = const <String, IntroEligibility>{};
    // no iOS a loja diz quem é elegível; no Android ela só oferece o teste a quem é
    if (platform == TargetPlatform.iOS &&
        escolhidos.any((e) => e.$2.storeProduct.introductoryPrice != null)) {
      elegibilidade = await api.checkTrialOrIntroductoryPriceEligibility([
        for (final (_, p) in escolhidos) p.storeProduct.identifier,
      ]);
    }
    final lista = <ProPackage>[];
    for (final (periodo, p) in escolhidos) {
      _packages[p.identifier] = p;
      lista.add(
        ProPackage(
          id: p.identifier,
          period: periodo,
          priceString: p.storeProduct.priceString,
          price: p.storeProduct.price,
          currencyCode: p.storeProduct.currencyCode,
          trialDays: _eligible(elegibilidade[p.storeProduct.identifier])
              ? _trialDays(p.storeProduct.introductoryPrice)
              : null,
        ),
      );
    }
    return lista;
  });

  /// Sem resposta (ou "não sei") conta como elegível: a loja recusa o teste na hora da compra se não for.
  static bool _eligible(IntroEligibility? e) => switch (e?.status) {
    IntroEligibilityStatus.introEligibilityStatusIneligible ||
    IntroEligibilityStatus.introEligibilityStatusNoIntroOfferExists => false,
    _ => true,
  };

  @override
  Future<PurchaseOutcome> purchase(String packageId) async {
    var pacote = _packages[packageId];
    if (pacote == null) {
      await packages();
      pacote = _packages[packageId];
    }
    if (pacote == null) throw const BillingUnknown('pacote');
    try {
      final r = await api.purchase(PurchaseParams.package(pacote));
      return Purchased(customerFromInfo(r.customerInfo));
    } on PlatformException catch (e) {
      final code = _codeOf(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return const PurchaseCancelled();
      }
      if (code == PurchasesErrorCode.paymentPendingError) {
        return const PurchasePending();
      }
      throw billingFailureOf(e);
    }
  }

  @override
  Future<ProCustomer> restore() =>
      _call(() async => customerFromInfo(await api.restorePurchases()));

  @override
  Future<ProCustomer> customer() =>
      _call(() async => customerFromInfo(await api.getCustomerInfo()));

  @override
  Stream<ProCustomer> customerUpdates() => _updates.stream;
}

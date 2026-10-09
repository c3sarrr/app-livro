// G22.2 — o gateway do RevenueCat (docs/progresso/G22.md §2): o SDK atrás de um objeto falso (sem plataforma). O que
// se prova: a tradução do CustomerInfo, dos pacotes da offering `default` (com o teste grátis só se elegível) e de
// cada erro do SDK; a configuração com o id do Supabase (R1) e o fluxo das mudanças do CustomerInfo.
import 'package:app_leitura/features/billing/data/revenuecat_gateway.dart';
import 'package:app_leitura/features/billing/domain/billing_models.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const _pro = 'pro';

EntitlementInfo entitlement({
  bool active = true,
  bool willRenew = true,
  String? expiration = '2026-11-12T15:00:00Z',
  String? billingIssue,
  String product = 'booknest_pro_mensal',
  String? plan,
  Store store = Store.testStore,
  bool sandbox = true,
  String id = _pro,
}) => EntitlementInfo(
  id,
  active,
  willRenew,
  '2026-10-12T15:00:00Z',
  '2026-10-12T15:00:00Z',
  product,
  sandbox,
  store: store,
  expirationDate: expiration,
  billingIssueDetectedAt: billingIssue,
  productPlanIdentifier: plan,
);

CustomerInfo info({
  List<EntitlementInfo> entitlements = const [],
  Map<String, SubscriptionInfo> subs = const {},
  String? managementUrl,
}) => CustomerInfo(
  EntitlementInfos(
    {for (final e in entitlements) e.identifier: e},
    {
      for (final e in entitlements)
        if (e.isActive) e.identifier: e,
    },
  ),
  const {},
  const [],
  const [],
  const [],
  '2026-10-01T00:00:00Z',
  'dona',
  const {},
  '2026-10-12T15:00:00Z',
  managementURL: managementUrl,
  subscriptionsByProductIdentifier: subs,
);

Package pacote(
  String id,
  PackageType tipo,
  double preco,
  String texto, {
  IntroductoryPrice? intro,
  String produto = 'booknest_pro_mensal',
}) => Package(
  id,
  tipo,
  StoreProduct(
    produto,
    'BookNest Pro',
    'BookNest Pro',
    preco,
    texto,
    'BRL',
    introductoryPrice: intro,
  ),
  const PresentedOfferingContext('default', null, null),
);

const semanaGratis = IntroductoryPrice(
  0,
  'Grátis',
  'P1W',
  1,
  PeriodUnit.week,
  1,
);

Offerings ofertas(List<Package> pacotes, {bool current = true}) {
  final o = Offering('default', 'Pro', const {}, pacotes);
  return current
      ? Offerings({'default': o}, current: o)
      : Offerings({'default': o});
}

PlatformException erro(PurchasesErrorCode c) =>
    PlatformException(code: '${c.index}', message: c.name);

final class FalsoPurchases implements PurchasesApi {
  final chamadas = <String>[];
  bool configurado = false;
  PurchasesConfiguration? configuracao;
  CustomerInfo cliente = info();
  Offerings? ofertasDaLoja;
  Map<String, IntroEligibility> elegibilidade = const {};
  Object? erroDaCompra;
  Object? erroDoLogout;
  CustomerInfoUpdateListener? ouvinte;

  @override
  Future<bool> isConfigured() async => configurado;

  @override
  Future<void> configure(PurchasesConfiguration c) async {
    chamadas.add('configure:${c.appUserID}');
    configuracao = c;
    configurado = true;
  }

  @override
  Future<LogInResult> logIn(String id) async {
    chamadas.add('logIn:$id');
    return LogInResult(created: false, customerInfo: cliente);
  }

  @override
  Future<CustomerInfo> logOut() async {
    chamadas.add('logOut');
    if (erroDoLogout case final e?) throw e;
    return info();
  }

  @override
  Future<Offerings> getOfferings() async {
    chamadas.add('getOfferings');
    return ofertasDaLoja ?? const Offerings({});
  }

  @override
  Future<Map<String, IntroEligibility>>
  checkTrialOrIntroductoryPriceEligibility(List<String> ids) async {
    chamadas.add('elegibilidade:${ids.join(',')}');
    return elegibilidade;
  }

  @override
  Future<PurchaseResult> purchase(PurchaseParams p) async {
    chamadas.add('purchase:${p.package?.identifier}');
    if (erroDaCompra case final e?) throw e;
    return PurchaseResult(
      cliente,
      const StoreTransaction(
        't1',
        'booknest_pro_mensal',
        '2026-10-12T15:00:00Z',
      ),
    );
  }

  @override
  Future<CustomerInfo> restorePurchases() async {
    chamadas.add('restore');
    if (erroDaCompra case final e?) throw e;
    return cliente;
  }

  @override
  Future<CustomerInfo> getCustomerInfo() async {
    chamadas.add('getCustomerInfo');
    return cliente;
  }

  @override
  void addCustomerInfoUpdateListener(CustomerInfoUpdateListener l) =>
      ouvinte = l;

  @override
  void removeCustomerInfoUpdateListener(CustomerInfoUpdateListener l) =>
      ouvinte = null;
}

IntroEligibility elegivel(IntroEligibilityStatus s) =>
    IntroEligibility.fromJson({'status': s.index, 'description': s.name});

void main() {
  late FalsoPurchases sdk;
  RevenueCatGateway gateway({
    TargetPlatform plataforma = TargetPlatform.android,
  }) => RevenueCatGateway(
    apiKey: 'test_chave_de_mentira',
    api: sdk,
    platform: plataforma,
  );

  setUp(() => sdk = FalsoPurchases());

  group('o CustomerInfo vira o ProCustomer (o entitlement `pro`)', () {
    test('Pro ativo que renova: até quando, a loja, o sandbox e a página de gestão', () {
      final c = customerFromInfo(
        info(
          entitlements: [entitlement()],
          managementUrl: 'https://loja/gerir',
        ),
      );
      expect(
        c,
        ProCustomer(
          active: true,
          activeUntil: DateTime.utc(2026, 11, 12, 15),
          willRenew: true,
          managementUrl: 'https://loja/gerir',
          store: 'testStore',
          sandbox: true,
        ),
      );
    });

    test('renovação desligada: continua ativo, sem renovar', () {
      final c = customerFromInfo(
        info(entitlements: [entitlement(willRenew: false)]),
      );
      expect([c.active, c.willRenew], [true, false]);
    });

    test('carência: o problema de cobrança e o fim da carência da assinatura (produto:plano no Play)', () {
      final c = customerFromInfo(
        info(
          entitlements: [
            entitlement(
              product: 'booknest_pro',
              plan: 'mensal',
              store: Store.playStore,
              billingIssue: '2026-11-12T15:00:00Z',
            ),
          ],
          subs: {
            'booknest_pro:mensal': const SubscriptionInfo(
              'booknest_pro:mensal',
              '2026-10-12T15:00:00Z',
              true,
              true,
              true,
              gracePeriodExpiresDate: '2026-11-15T15:00:00Z',
              managementURL: 'https://play/gerir',
            ),
          },
        ),
      );
      expect(c.billingIssue, isTrue);
      expect(c.graceUntil, DateTime.utc(2026, 11, 15, 15));
      expect(c.managementUrl, 'https://play/gerir');
    });

    test('sem o entitlement `pro` ativo (outro entitlement, vencido ou nenhum): Grátis', () {
      expect(customerFromInfo(info()), ProCustomer.none);
      expect(
        customerFromInfo(info(entitlements: [entitlement(id: 'booknest_pro')])),
        ProCustomer.none,
      );
      expect(
        customerFromInfo(info(entitlements: [entitlement(active: false)])),
        ProCustomer.none,
      );
    });
  });

  group('os erros do SDK', () {
    test('cada código vira a falha da tela (R3)', () {
      final casos = {
        PurchasesErrorCode.networkError: isA<BillingOffline>(),
        PurchasesErrorCode.offlineConnectionError: isA<BillingOffline>(),
        PurchasesErrorCode.storeProblemError: isA<StoreUnavailable>(),
        PurchasesErrorCode.productAlreadyPurchasedError:
            isA<AlreadySubscribed>(),
        PurchasesErrorCode.purchaseNotAllowedError: isA<PurchaseNotAllowed>(),
        PurchasesErrorCode.testStoreSimulatedPurchaseError:
            isA<BillingUnknown>().having(
              (f) => f.code,
              'code',
              'testStoreSimulatedPurchaseError',
            ),
      };
      casos.forEach((codigo, esperado) {
        expect(billingFailureOf(erro(codigo)), esperado, reason: codigo.name);
      });
    });

    test('código que o app não conhece: desconhecida', () {
      expect(
        billingFailureOf(PlatformException(code: '999')),
        isA<BillingUnknown>(),
      );
    });

    test('compra: fechar a folha é cancelar (sem falha); pagamento em análise é pendente', () async {
      sdk.ofertasDaLoja = ofertas([
        pacote(r'$rc_monthly', PackageType.monthly, 9.99, r'R$ 9,99'),
      ]);
      final g = gateway();
      await g.packages();
      sdk.erroDaCompra = erro(PurchasesErrorCode.purchaseCancelledError);
      expect(await g.purchase(r'$rc_monthly'), isA<PurchaseCancelled>());
      sdk.erroDaCompra = erro(PurchasesErrorCode.paymentPendingError);
      expect(await g.purchase(r'$rc_monthly'), isA<PurchasePending>());
      sdk.erroDaCompra = erro(PurchasesErrorCode.networkError);
      await expectLater(
        g.purchase(r'$rc_monthly'),
        throwsA(isA<BillingOffline>()),
      );
    });

    test('restaurar sem rede: a falha traduzida', () async {
      sdk.erroDaCompra = erro(PurchasesErrorCode.networkError);
      await expectLater(gateway().restore(), throwsA(isA<BillingOffline>()));
    });
  });

  group('os pacotes da offering `default`', () {
    test('sem offering: nenhum pacote', () async {
      expect(await gateway().packages(), isEmpty);
    });

    test('só o mensal e o anual, nessa ordem, com o preço da loja; o vitalício fica de fora', () async {
      sdk.ofertasDaLoja = ofertas([
        pacote(
          r'$rc_annual',
          PackageType.annual,
          79.99,
          r'R$ 79,99',
          produto: 'booknest_pro_anual',
        ),
        pacote(
          r'$rc_lifetime',
          PackageType.lifetime,
          199,
          r'R$ 199,00',
          produto: 'vitalicio',
        ),
        pacote(r'$rc_monthly', PackageType.monthly, 9.99, r'R$ 9,99'),
      ]);
      expect(await gateway().packages(), const [
        ProPackage(
          id: r'$rc_monthly',
          period: ProPeriod.month,
          priceString: r'R$ 9,99',
          price: 9.99,
          currencyCode: 'BRL',
        ),
        ProPackage(
          id: r'$rc_annual',
          period: ProPeriod.year,
          priceString: r'R$ 79,99',
          price: 79.99,
          currencyCode: 'BRL',
        ),
      ]);
    });

    test('a offering `default` também serve quando não é a atual', () async {
      sdk.ofertasDaLoja = ofertas([
        pacote(r'$rc_monthly', PackageType.monthly, 9.99, r'R$ 9,99'),
      ], current: false);
      expect(await gateway().packages(), hasLength(1));
    });

    test('o teste grátis: a semana grátis é 7 dias; o preço de entrada pago não é teste', () async {
      sdk.ofertasDaLoja = ofertas([
        pacote(
          r'$rc_monthly',
          PackageType.monthly,
          9.99,
          r'R$ 9,99',
          intro: semanaGratis,
        ),
        pacote(
          r'$rc_annual',
          PackageType.annual,
          79.99,
          r'R$ 79,99',
          produto: 'booknest_pro_anual',
          intro: const IntroductoryPrice(
            4.99,
            r'R$ 4,99',
            'P1M',
            1,
            PeriodUnit.month,
            1,
          ),
        ),
      ]);
      final p = await gateway().packages();
      expect(p.map((e) => e.trialDays), [7, null]);
      // no Android a loja só oferece o teste a quem é elegível: nada a perguntar
      expect(sdk.chamadas.where((c) => c.startsWith('elegibilidade')), isEmpty);
    });

    test(
      'iOS: o teste só fica para quem a loja diz elegível (ou não sabe)',
      () async {
        sdk
          ..ofertasDaLoja = ofertas([
            pacote(
              r'$rc_monthly',
              PackageType.monthly,
              9.99,
              r'R$ 9,99',
              intro: semanaGratis,
            ),
            pacote(
              r'$rc_annual',
              PackageType.annual,
              79.99,
              r'R$ 79,99',
              produto: 'booknest_pro_anual',
              intro: semanaGratis,
            ),
          ])
          ..elegibilidade = {
            'booknest_pro_mensal': elegivel(
              IntroEligibilityStatus.introEligibilityStatusIneligible,
            ),
            'booknest_pro_anual': elegivel(
              IntroEligibilityStatus.introEligibilityStatusUnknown,
            ),
          };
        final p = await gateway(plataforma: TargetPlatform.iOS).packages();
        expect(p.map((e) => e.trialDays), [null, 7]);
        expect(
          sdk.chamadas,
          contains('elegibilidade:booknest_pro_mensal,booknest_pro_anual'),
        );
      },
    );

    test('comprar um pacote que ainda não foi lido busca a offering; um que não existe falha', () async {
      sdk.ofertasDaLoja = ofertas([
        pacote(r'$rc_monthly', PackageType.monthly, 9.99, r'R$ 9,99'),
      ]);
      sdk.cliente = info(entitlements: [entitlement()]);
      final g = gateway();
      final r = await g.purchase(r'$rc_monthly');
      expect(
        r,
        isA<Purchased>().having((p) => p.customer.active, 'ativo', true),
      );
      expect(sdk.chamadas, ['getOfferings', r'purchase:$rc_monthly']);
      await expectLater(
        g.purchase(r'$rc_weekly'),
        throwsA(isA<BillingUnknown>().having((f) => f.code, 'code', 'pacote')),
      );
    });
  });

  group('a conta (R1)', () {
    test('a 1ª vez configura com o id do Supabase; depois é logIn', () async {
      final g = gateway();
      await g.configure(appUserId: 'dona');
      expect(sdk.configuracao?.apiKey, 'test_chave_de_mentira');
      await g.configure(appUserId: 'outra');
      expect(sdk.chamadas, ['configure:dona', 'logIn:outra']);
    });

    test('logIn devolve o Pro da conta', () async {
      sdk.cliente = info(entitlements: [entitlement()]);
      expect((await gateway().logIn('dona')).active, isTrue);
    });

    test('sair com o usuário anônimo do SDK não é falha', () async {
      sdk.erroDoLogout = erro(PurchasesErrorCode.logOutWithAnonymousUserError);
      await gateway().logOut();
      sdk.erroDoLogout = erro(PurchasesErrorCode.networkError);
      await expectLater(gateway().logOut(), throwsA(isA<BillingOffline>()));
    });

    test(
      'as mudanças do CustomerInfo chegam pelo fluxo, já traduzidas',
      () async {
        final g = gateway();
        await g.configure(appUserId: 'dona');
        final recebidos = <ProCustomer>[];
        final sub = g.customerUpdates().listen(recebidos.add);
        sdk.ouvinte!(info(entitlements: [entitlement(willRenew: false)]));
        await pumpEventQueue();
        expect(recebidos.single.willRenew, isFalse);
        await sub.cancel();
      },
    );

    test('o cliente atual', () async {
      sdk.cliente = info(entitlements: [entitlement()]);
      expect((await gateway().customer()).active, isTrue);
    });
  });
}

// G22.7 — o que a cobertura achou sem teste (escrito depois do código, para a medida): a igualdade e os textos de
// diagnóstico dos modelos da compra, os códigos das falhas, as ligações padrão (Riverpod) e o erro do SDK que não é
// número.
import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/core/config/server_providers.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/local_database.dart';
import 'package:app_leitura/features/billing/application/billing_controller.dart';
import 'package:app_leitura/features/billing/application/billing_providers.dart';
import 'package:app_leitura/features/billing/data/revenuecat_gateway.dart';
import 'package:app_leitura/features/billing/domain/billing_models.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/billing_fakes.dart';

void main() {
  group('os modelos', () {
    test('ProPackage: igualdade, hash e o texto de diagnóstico', () {
      const outro = ProPackage(
        id: r'$rc_monthly',
        period: ProPeriod.month,
        priceString: r'R$ 9,99',
        price: 9.99,
        currencyCode: 'BRL',
        trialDays: 7,
      );
      expect(outro, mensal);
      expect(outro.hashCode, mensal.hashCode);
      expect(mensal == anual, isFalse);
      expect(mensal.toString(), contains(r'$rc_monthly'));
    });

    test('ProCustomer: igualdade, hash e o texto de diagnóstico', () {
      final igual = ProCustomer(
        active: true,
        activeUntil: proAte,
        willRenew: true,
        managementUrl: 'https://loja.teste/gerir',
        store: 'testStore',
        sandbox: true,
      );
      expect(igual, proDaLoja);
      expect(igual.hashCode, proDaLoja.hashCode);
      expect(proDaLoja == ProCustomer.none, isFalse);
      expect(proDaLoja.toString(), contains('ativo: true'));
    });

    test('ProReady: igualdade e hash', () {
      final a = ProReady(customer: proDaLoja, serverPro: true);
      expect(a, ProReady(customer: proDaLoja, serverPro: true));
      expect(
        a.hashCode,
        ProReady(customer: proDaLoja, serverPro: true).hashCode,
      );
      expect(a == a.copyWith(activating: true), isFalse);
    });

    test('as falhas: o código de cada uma e o texto de diagnóstico', () {
      expect(
        [
          const BillingOffline(),
          const StoreUnavailable(),
          const AlreadySubscribed(),
          const PurchaseNotAllowed(),
          const BillingNeedsAccount(),
          const BillingUnknown('x'),
        ].map((f) => f.code),
        ['rede', 'loja', 'ja_assina', 'nao_permitido', 'sem_conta', 'x'],
      );
      expect(const BillingOffline().toString(), 'BillingFailure(rede)');
    });

    test(
      'o erro do SDK que não é um código dele vira desconhecida, com o código',
      () {
        expect(
          billingFailureOf(PlatformException(code: 'nao-e-numero')),
          isA<BillingUnknown>().having((f) => f.code, 'code', 'nao-e-numero'),
        );
      },
    );
  });

  group('as ligações padrão', () {
    test(
      'com a chave no env (fora do build de produção): o gateway do RevenueCat',
      () {
        final c = ProviderContainer(
          overrides: [
            appEnvProvider.overrideWithValue(
              const AppEnv(
                revenuecatKeyAndroid: 'goog_chave',
                revenuecatKeyIos: 'appl_chave',
              ),
            ),
          ],
        );
        addTearDown(c.dispose);
        expect(c.read(billingGatewayProvider), isA<RevenueCatGateway>());
      },
    );

    test(
      'a espera, a plataforma, o abridor e o servidor do Pro sem Supabase',
      () async {
        final c = ProviderContainer(
          overrides: [supabaseClientProvider.overrideWithValue(null)],
        );
        addTearDown(c.dispose);
        await c.read(billingSleepProvider)(Duration.zero);
        expect(c.read(billingPlatformProvider), TargetPlatform.android);
        expect(c.read(billingLauncherProvider), isNotNull);
        expect(c.read(proServerApiProvider), isNull);
      },
    );

    test('os pacotes da tela técnica sem conta: nenhum', () async {
      final c = ProviderContainer(
        overrides: [
          billingControllerProvider.overrideWith(
            () => BillingFalso(const ProUnavailable()),
          ),
        ],
      );
      addTearDown(c.dispose);
      expect(await c.read(proPackagesProvider.future), isEmpty);
    });

    test('a lembrança do aparelho pelo banco do app', () async {
      final db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
      addTearDown(db.close);
      final c = ProviderContainer(
        overrides: [localDatabaseProvider.overrideWith((ref) async => db)],
      );
      addTearDown(c.dispose);
      final memoria = c.read(billingStoreMemoryProvider);
      expect(await memoria.used(contaA), isFalse);
      await memoria.markUsed(contaA);
      expect(await memoria.used(contaA), isTrue);
      expect(await memoria.used(contaB), isFalse);
    });
  });
}

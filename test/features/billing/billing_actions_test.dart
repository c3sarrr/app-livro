// G22.3 — comprar, restaurar e gerenciar (docs/progresso/G22.md §3): o que cada resultado da loja faz na tela (R3,
// R5, R6), a ativação depois de comprar ou restaurar (R2) e uma ação por vez.
import 'dart:async';

import 'package:app_leitura/features/account/application/account_controller.dart';
import 'package:app_leitura/features/billing/application/billing_controller.dart';
import 'package:app_leitura/features/billing/application/billing_providers.dart';
import 'package:app_leitura/features/billing/domain/billing_models.dart';
import 'package:app_leitura/features/social/domain/social_failure.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/billing_fakes.dart';

void main() {
  late LojaFalsa loja;
  late ServidorProFalso servidor;
  late ContaFalsa conta;
  late List<Uri> abertas;
  late bool abre;
  late ProviderContainer c;
  late MemoriaFalsa memoria;

  Future<void> iniciar(
    AccountView inicial, {
    TargetPlatform plataforma = TargetPlatform.android,
  }) async {
    conta = ContaFalsa(inicial);
    memoria = MemoriaFalsa();
    c = ProviderContainer(
      overrides: [
        accountControllerProvider.overrideWith(() => conta),
        billingStoreMemoryProvider.overrideWithValue(memoria),
        billingGatewayProvider.overrideWithValue(loja),
        proServerApiProvider.overrideWithValue(servidor),
        billingSleepProvider.overrideWithValue((_) async {}),
        billingPlatformProvider.overrideWithValue(plataforma),
        billingLauncherProvider.overrideWithValue((uri) async {
          abertas.add(uri);
          return abre;
        }),
      ],
    );
    addTearDown(c.dispose);
    c.listen(billingControllerProvider, (_, _) {});
    await pumpEventQueue();
  }

  BillingController ctrl() => c.read(billingControllerProvider.notifier);
  ProReady pronto() => c.read(billingControllerProvider) as ProReady;

  setUp(() {
    loja = LojaFalsa();
    servidor = ServidorProFalso();
    abertas = [];
    abre = true;
  });

  group('comprar (R3)', () {
    test(
      'comprou: o Pro da loja na tela e a ativação no servidor (R2)',
      () async {
        await iniciar(membro(contaA));
        loja.compra = Purchased(proDaLoja);
        servidor.aoConferir = (pro: true, activeUntil: proAte);
        conta.proNoServidor = true;
        await ctrl().purchase(mensal);
        await pumpEventQueue();
        expect(loja.chamadas, contains(r'purchase:$rc_monthly'));
        expect(pronto().customer, proDaLoja);
        expect(servidor.chamadas, ['syncNow']);
        expect(conta.releituras, 1);
        expect(pronto().serverPro, isTrue);
      },
    );

    test('numa conta Grátis que nunca usou a loja: configura o RevenueCat só agora, e o aparelho lembra', () async {
      await iniciar(membro(contaA));
      expect(loja.chamadas, isEmpty);
      await ctrl().purchase(mensal);
      expect(loja.chamadas, [
        'configure:$contaA',
        'customer',
        r'purchase:$rc_monthly',
      ]);
      expect(memoria.usadas, {contaA});
    });

    test('restaurar também configura antes e lembra', () async {
      await iniciar(membro(contaA));
      await ctrl().restore();
      expect(loja.chamadas, ['configure:$contaA', 'customer', 'restore']);
      expect(memoria.usadas, {contaA});
    });

    test('fechou a folha da loja: volta sem aviso', () async {
      await iniciar(membro(contaA));
      loja.compra = const PurchaseCancelled();
      await ctrl().purchase(mensal);
      expect(pronto().notice, isNull);
      expect(servidor.chamadas, isEmpty);
    });

    test('pagamento em análise', () async {
      await iniciar(membro(contaA));
      loja.compra = const PurchasePending();
      await ctrl().purchase(anual);
      expect(
        pronto().notice,
        'Pagamento em análise. O Pro liga quando a loja aprovar.',
      );
    });

    test('sem rede', () async {
      await iniciar(membro(contaA));
      loja.compra = const BillingOffline();
      await ctrl().purchase(mensal);
      expect(pronto().notice, 'Sem conexão. Tente de novo.');
    });

    test('a loja diz que já assina: restaura (R5)', () async {
      await iniciar(membro(contaA));
      loja
        ..compra = const AlreadySubscribed()
        ..cliente = proDaLoja;
      servidor.aoConferir = (pro: true, activeUntil: proAte);
      conta.proNoServidor = true;
      await ctrl().purchase(mensal);
      await pumpEventQueue();
      expect(
        loja.chamadas,
        containsAllInOrder([r'purchase:$rc_monthly', 'restore']),
      );
      expect(pronto().notice, 'Compras restauradas.');
    });

    test(
      'outra falha (a loja fora, a compra que falha na Test Store)',
      () async {
        for (final f in [
          const StoreUnavailable(),
          const PurchaseNotAllowed(),
          const BillingUnknown('testStoreSimulatedPurchaseError'),
        ]) {
          loja = LojaFalsa();
          await iniciar(membro(contaA));
          loja.compra = f;
          await ctrl().purchase(mensal);
          expect(
            pronto().notice,
            'Não deu certo. Tente de novo.',
            reason: f.code,
          );
        }
      },
    );

    test(
      'uma compra por vez: o toque repetido não compra duas vezes',
      () async {
        await iniciar(membro(contaA));
        loja
          ..segurarCompra = Completer<void>()
          ..compra = const PurchaseCancelled();
        final primeira = ctrl().purchase(mensal);
        final segunda = ctrl().purchase(mensal);
        loja.segurarCompra!.complete();
        await Future.wait([primeira, segunda]);
        expect(
          loja.chamadas.where((c) => c.startsWith('purchase')),
          hasLength(1),
        );
      },
    );

    test('convidado (R1): a compra não chega à loja', () async {
      await iniciar(const GuestView(canSignIn: true));
      await ctrl().purchase(mensal);
      expect(loja.chamadas, isEmpty);
    });
  });

  group('restaurar (R5)', () {
    test('com assinatura na conta da loja: o aviso e a ativação', () async {
      await iniciar(membro(contaA));
      loja.cliente = proDaLoja;
      servidor.aoConferir = (pro: true, activeUntil: proAte);
      conta.proNoServidor = true;
      await ctrl().restore();
      await pumpEventQueue();
      expect(pronto().notice, 'Compras restauradas.');
      expect(servidor.chamadas, ['syncNow']);
      expect(pronto().serverPro, isTrue);
    });

    test('D-236: o resumo ainda diz Pro, mas o período venceu e a loja renovou: o restaurar confere no servidor mesmo '
        'assim', () async {
      loja.cliente = proDaLoja;
      await iniciar(membro(contaA, pro: true));
      expect(servidor.chamadas, isEmpty);
      servidor.aoConferir = (pro: true, activeUntil: proAte);
      conta.proNoServidor = true;
      await ctrl().restore();
      await pumpEventQueue();
      expect(pronto().notice, 'Compras restauradas.');
      expect(servidor.chamadas, ['syncNow']);
      expect(conta.releituras, 1);
      expect(pronto().serverPro, isTrue);
    });

    test('sem assinatura na conta da loja', () async {
      await iniciar(membro(contaA));
      await ctrl().restore();
      expect(
        pronto().notice,
        'Nenhuma assinatura encontrada nesta conta da loja.',
      );
      expect(servidor.chamadas, isEmpty);
    });

    test('sem rede e outra falha', () async {
      await iniciar(membro(contaA));
      loja.falhaAoRestaurar = const BillingOffline();
      await ctrl().restore();
      expect(pronto().notice, 'Sem conexão. Tente de novo.');
      loja.falhaAoRestaurar = const StoreUnavailable();
      await ctrl().restore();
      expect(pronto().notice, 'Não deu certo. Tente de novo.');
    });

    test('a tela mostra o aviso e o limpa', () async {
      await iniciar(membro(contaA));
      await ctrl().restore();
      ctrl().clearNotice();
      expect(pronto().notice, isNull);
    });
  });

  group('gerenciar (R6)', () {
    test('abre a página de gestão da loja, fora do app', () async {
      loja.cliente = proDaLoja;
      servidor.aoConferir = (pro: true, activeUntil: proAte);
      await iniciar(membro(contaA, pro: true));
      await ctrl().manage();
      expect(abertas, [Uri.parse('https://loja.teste/gerir')]);
      expect(pronto().notice, isNull);
    });

    test(
      'sem a página (ou ela não abre): onde gerenciar, por plataforma',
      () async {
        loja.cliente = ProCustomer(active: true, activeUntil: proAte);
        await iniciar(membro(contaA, pro: true));
        await ctrl().manage();
        expect(abertas, isEmpty);
        expect(
          pronto().notice,
          'Gerencie a assinatura em Play Store › Pagamentos e assinaturas',
        );

        loja.cliente = proDaLoja;
        abre = false;
        await iniciar(
          membro(contaA, pro: true),
          plataforma: TargetPlatform.iOS,
        );
        await ctrl().manage();
        expect(
          pronto().notice,
          'Gerencie a assinatura em Ajustes › seu nome › Assinaturas',
        );
      },
    );
  });

  group('conferir agora (a tela técnica)', () {
    test('o servidor confirma o Pro: relê o resumo e avisa', () async {
      await iniciar(membro(contaA));
      servidor.aoConferir = (pro: true, activeUntil: proAte);
      conta.proNoServidor = true;
      await ctrl().checkNow();
      await pumpEventQueue();
      expect(servidor.chamadas, ['syncNow']);
      expect(conta.releituras, 1);
      expect(pronto().serverPro, isTrue);
      expect(pronto().notice, 'O servidor confirmou o Pro.');
    });

    test('o servidor diz o mesmo de antes: não relê', () async {
      await iniciar(membro(contaA));
      await ctrl().checkNow();
      expect(conta.releituras, 0);
      expect(pronto().notice, 'O servidor não tem o Pro desta conta.');
    });

    test('sem rede', () async {
      await iniciar(membro(contaA));
      servidor.falhaAoConferir = const SocialOffline();
      await ctrl().checkNow();
      expect(pronto().notice, 'Sem conexão. Tente de novo.');
    });
  });
}

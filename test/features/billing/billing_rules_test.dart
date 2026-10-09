// G22.2 — as regras da compra que não dependem da loja nem do servidor (docs/progresso/G22.md §3): a economia do
// anual e o teste grátis (R4), os textos do estado no Perfil, a validade sem rede (R8) e onde gerenciar (R6).
import 'package:app_leitura/features/billing/domain/billing_models.dart';
import 'package:app_leitura/features/billing/domain/billing_rules.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter_test/flutter_test.dart';

ProPackage pacote(
  ProPeriod periodo,
  double preco,
  String texto, {
  String moeda = 'BRL',
  int? teste,
}) => ProPackage(
  id: periodo == ProPeriod.month ? r'$rc_monthly' : r'$rc_annual',
  period: periodo,
  priceString: texto,
  price: preco,
  currencyCode: moeda,
  trialDays: teste,
);

// o fuso do aparelho nos testes: Brasília
Duration brasilia(DateTime _) => const Duration(hours: -3);

void main() {
  group('R4: a economia do anual sai dos preços da loja', () {
    final mes = pacote(ProPeriod.month, 9.99, r'R$ 9,99');
    final ano = pacote(ProPeriod.year, 79.99, r'R$ 79,99');

    test('R\$ 9,99 por mês e R\$ 79,99 por ano → 33 %', () {
      expect(annualSavingsPercent(mes, ano), 33);
    });

    test('arredonda para baixo, nunca para o mais perto (41,67 % → 41)', () {
      expect(
        annualSavingsPercent(
          pacote(ProPeriod.month, 10, r'R$ 10,00'),
          pacote(ProPeriod.year, 70, r'R$ 70,00'),
        ),
        41,
      );
    });

    test('moedas diferentes: nada', () {
      expect(
        annualSavingsPercent(
          mes,
          pacote(ProPeriod.year, 14.99, r'US$ 14,99', moeda: 'USD'),
        ),
        isNull,
      );
    });

    test('o anual não sai mais barato que 12 meses: nada', () {
      expect(
        annualSavingsPercent(pacote(ProPeriod.month, 4.99, r'US$ 4,99'), ano),
        isNull,
      );
      expect(
        annualSavingsPercent(
          pacote(ProPeriod.month, 10, r'R$ 10,00'),
          pacote(ProPeriod.year, 120, r'R$ 120,00'),
        ),
        isNull,
      );
    });

    test('preço zero ou pacotes trocados: nada', () {
      expect(
        annualSavingsPercent(pacote(ProPeriod.month, 0, r'R$ 0,00'), ano),
        isNull,
      );
      expect(annualSavingsPercent(ano, mes), isNull);
    });
  });

  group('R4: o teste grátis só para quem é elegível', () {
    test('no mensal e no anual, com o preço da loja', () {
      expect(
        trialLine(pacote(ProPeriod.month, 9.99, r'R$ 9,99', teste: 7)),
        r'7 dias grátis, depois R$ 9,99/mês',
      );
      expect(
        trialLine(pacote(ProPeriod.year, 79.99, r'R$ 79,99', teste: 7)),
        r'7 dias grátis, depois R$ 79,99/ano',
      );
    });

    test('1 dia, no singular', () {
      expect(
        trialLine(pacote(ProPeriod.month, 9.99, r'R$ 9,99', teste: 1)),
        r'1 dia grátis, depois R$ 9,99/mês',
      );
    });

    test('sem teste (não elegível): nada', () {
      expect(trialLine(pacote(ProPeriod.month, 9.99, r'R$ 9,99')), isNull);
      expect(
        trialLine(pacote(ProPeriod.month, 9.99, r'R$ 9,99', teste: 0)),
        isNull,
      );
    });
  });

  group('§3: o estado do Pro no Perfil', () {
    // 12/11/2026 ao meio-dia em Brasília
    final ate = DateTime.utc(2026, 11, 12, 15);
    String linha(ProCustomer c, {bool ativando = false}) =>
        proStatusLine(c, activating: ativando, utcOffsetAt: brasilia);

    test('Grátis', () {
      expect(linha(ProCustomer.none), 'Plano: Grátis');
      expect(
        linha(ProCustomer(active: false, activeUntil: ate, willRenew: true)),
        'Plano: Grátis',
      );
    });

    test('Pro que renova', () {
      expect(
        linha(ProCustomer(active: true, activeUntil: ate, willRenew: true)),
        'Pro até 12/11/2026 · renova automaticamente',
      );
    });

    test('Pro com a renovação desligada', () {
      expect(
        linha(ProCustomer(active: true, activeUntil: ate)),
        'Pro até 12/11/2026 · renovação desligada',
      );
    });

    test('carência: o prazo é o fim da carência, só dia e mês', () {
      expect(
        linha(
          ProCustomer(
            active: true,
            activeUntil: ate,
            willRenew: true,
            billingIssue: true,
            graceUntil: DateTime.utc(2026, 11, 15, 15),
          ),
        ),
        'Pro · problema no pagamento. Atualize na loja até 15/11.',
      );
    });

    test(
      'problema no pagamento ainda sem carência: o prazo é o fim do período',
      () {
        expect(
          linha(
            ProCustomer(
              active: true,
              activeUntil: ate,
              willRenew: true,
              billingIssue: true,
            ),
          ),
          'Pro · problema no pagamento. Atualize na loja até 12/11.',
        );
      },
    );

    test('ativando: o texto da ativação, seja qual for o da loja', () {
      expect(linha(ProCustomer.none, ativando: true), 'Ativando o Pro…');
      expect(
        linha(
          ProCustomer(active: true, activeUntil: ate, willRenew: true),
          ativando: true,
        ),
        'Ativando o Pro…',
      );
    });

    test(
      'a data é a do fuso do aparelho (01h UTC do dia 13 é dia 12 em Brasília)',
      () {
        expect(
          linha(
            ProCustomer(
              active: true,
              activeUntil: DateTime.utc(2026, 11, 13, 1),
              willRenew: true,
            ),
          ),
          'Pro até 12/11/2026 · renova automaticamente',
        );
      },
    );

    test('Pro sem data de fim (concedido pela loja): só "Pro"', () {
      expect(linha(const ProCustomer(active: true)), 'Pro');
    });
  });

  group('R8: o Pro da loja sem rede vale até a expiração + 3 dias', () {
    final ate = DateTime.utc(2026, 11, 12, 15);
    final pro = ProCustomer(active: true, activeUntil: ate, willRenew: true);

    test('vale até 3 dias depois da expiração', () {
      expect(localProValid(pro, ate), isTrue);
      expect(
        localProValid(pro, ate.add(const Duration(days: 3, minutes: -1))),
        isTrue,
      );
    });

    test('depois disso, não', () {
      expect(
        localProValid(pro, ate.add(const Duration(days: 3, minutes: 1))),
        isFalse,
      );
    });

    test('Grátis nunca; Pro sem data de fim sempre', () {
      expect(localProValid(ProCustomer.none, ate), isFalse);
      expect(
        localProValid(
          ProCustomer(
            active: false,
            activeUntil: ate.add(const Duration(days: 30)),
          ),
          ate,
        ),
        isFalse,
      );
      expect(localProValid(const ProCustomer(active: true), ate), isTrue);
    });
  });

  group('R6: onde gerenciar sem a página da loja', () {
    test('Android e iOS', () {
      expect(
        manageInstruction(TargetPlatform.android),
        'Gerencie a assinatura em Play Store › Pagamentos e assinaturas',
      );
      expect(
        manageInstruction(TargetPlatform.iOS),
        'Gerencie a assinatura em Ajustes › seu nome › Assinaturas',
      );
    });

    test('fora do celular: nada (não há compra)', () {
      expect(manageInstruction(TargetPlatform.windows), isNull);
    });
  });

  group('o texto das lojas antes do botão (§5)', () {
    test('Android, mensal', () {
      expect(
        storeDisclosure(
          pacote(ProPeriod.month, 9.99, r'R$ 9,99'),
          TargetPlatform.android,
        ),
        r'Assinatura com renovação automática: R$ 9,99 por mês. A cobrança é feita na sua conta da Google Play '
        'e renova até você cancelar, pelo menos 24 horas antes do fim do período, em Gerenciar assinatura.',
      );
    });

    test('iOS, anual', () {
      expect(
        storeDisclosure(
          pacote(ProPeriod.year, 79.99, r'R$ 79,99'),
          TargetPlatform.iOS,
        ),
        r'Assinatura com renovação automática: R$ 79,99 por ano. A cobrança é feita na sua conta da App Store '
        'e renova até você cancelar, pelo menos 24 horas antes do fim do período, em Gerenciar assinatura.',
      );
    });
  });
}

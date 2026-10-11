// G22.5 — o Pro no bloco da conta do Perfil (docs/progresso/G22.md §5, D-231), sem prancha (D-21): o estado (os 5
// textos da §3), "Restaurar compras", "Gerenciar assinatura" só com Pro, "Assinar (tela técnica)" só na depuração e o
// aviso da última ação. Sem compra nesta versão, nada novo.
import 'package:app_leitura/features/account/presentation/account_widgets.dart';
import 'package:app_leitura/features/account/presentation/pro_rows.dart';
import 'package:app_leitura/features/billing/application/billing_controller.dart';
import 'package:app_leitura/features/billing/domain/billing_models.dart';
import 'package:app_leitura/features/billing/presentation/paywall_home_hook.dart';
import 'package:app_leitura/features/home/application/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../billing/support/billing_fakes.dart';
import 'support/account_finders.dart';

void main() {
  late BillingFalso pro;

  Future<void> montar(
    WidgetTester tester,
    ProView estado, {
    bool depuracao = true,
    DateTime? agora,
  }) async {
    // um ProviderScope novo por montagem (os overrides de um escopo montado não trocam)
    await tester.pumpWidget(const SizedBox());
    pro = BillingFalso(estado);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const Scaffold(body: SingleChildScrollView(child: ProRows())),
        ),
        GoRoute(
          path: '/_pro',
          builder: (_, _) => const Scaffold(body: Text('tela técnica')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          billingControllerProvider.overrideWith(() => pro),
          paywallDebugProvider.overrideWithValue(depuracao),
          clockProvider.overrideWithValue(
            () => agora ?? DateTime.utc(2026, 10, 9, 12),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  ProReady pronto(ProCustomer c, {bool ativando = false, String? aviso}) =>
      ProReady(
        customer: c,
        serverPro: c.active,
        activating: ativando,
        notice: aviso,
      );

  testWidgets('Grátis: o plano e "Restaurar compras"; sem "Gerenciar"', (
    tester,
  ) async {
    await montar(tester, pronto(ProCustomer.none));
    expect(texto('Plano: Grátis'), findsOneWidget);
    expect(botao('Restaurar compras'), findsOneWidget);
    expect(botao('Gerenciar assinatura'), findsNothing);
    await tocar(tester, 'Restaurar compras');
    expect(pro.acoes, ['restaurar']);
  });

  testWidgets('Pro que renova, com "Gerenciar assinatura"', (tester) async {
    await montar(tester, pronto(proDaLoja));
    expect(
      texto('Pro até 12/11/2026 · renova automaticamente'),
      findsOneWidget,
    );
    await tocar(tester, 'Gerenciar assinatura');
    expect(pro.acoes, ['gerenciar']);
  });

  testWidgets('renovação desligada e carência', (tester) async {
    await montar(
      tester,
      pronto(ProCustomer(active: true, activeUntil: proAte)),
    );
    expect(texto('Pro até 12/11/2026 · renovação desligada'), findsOneWidget);
    await montar(
      tester,
      pronto(
        ProCustomer(
          active: true,
          activeUntil: proAte,
          billingIssue: true,
          graceUntil: DateTime.utc(2026, 11, 15, 15),
        ),
      ),
    );
    expect(
      texto('Pro · problema no pagamento. Atualize na loja até 15/11.'),
      findsOneWidget,
    );
  });

  testWidgets('ativando: o texto da ativação e os botões esperam', (
    tester,
  ) async {
    await montar(tester, pronto(proDaLoja, ativando: true));
    expect(texto('Ativando o Pro…'), findsOneWidget);
    final restaurar = tester.widget<AccountButton>(botao('Restaurar compras'));
    expect(restaurar.onTap, isNull);
  });

  testWidgets(
    'sem rede, depois da expiração + 3 dias: Grátis para a tela (R8)',
    (tester) async {
      await montar(
        tester,
        pronto(proDaLoja),
        agora: proAte.add(const Duration(days: 3, minutes: 1)),
      );
      expect(texto('Plano: Grátis'), findsOneWidget);
      expect(botao('Gerenciar assinatura'), findsNothing);
    },
  );

  testWidgets('o aviso da última ação', (tester) async {
    await montar(
      tester,
      pronto(ProCustomer.none, aviso: 'Compras restauradas.'),
    );
    expect(texto('Compras restauradas.'), findsOneWidget);
    await montar(
      tester,
      pronto(ProCustomer.none, aviso: 'Sem conexão. Tente de novo.'),
    );
    final aviso = tester.widget<AccountNotice>(find.byType(AccountNotice));
    expect(aviso.error, isTrue);
  });

  testWidgets(
    '"Assinar (tela técnica)" só na depuração, e abre a tela técnica',
    (tester) async {
      await montar(tester, pronto(ProCustomer.none), depuracao: false);
      expect(botao('Assinar (tela técnica)'), findsNothing);
      await montar(tester, pronto(ProCustomer.none));
      await tocar(tester, 'Assinar (tela técnica)');
      expect(find.text('tela técnica'), findsOneWidget);
    },
  );

  testWidgets('sem compra nesta versão (ou configurando): nada novo', (
    tester,
  ) async {
    await montar(tester, const ProUnavailable());
    expect(find.byType(AccountButton), findsNothing);
    await montar(tester, const ProLoading());
    expect(find.byType(AccountButton), findsNothing);
  });
}

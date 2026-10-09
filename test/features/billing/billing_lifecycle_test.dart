// G22.3 — o Pro acompanha o app (R2): o controller fica vivo desde a abertura (a conta Pro configura o RevenueCat
// sem esperar o Perfil) e a ativação que não confirmou tenta de novo ao voltar ao app.
import 'package:app_leitura/features/billing/application/billing_controller.dart';
import 'package:app_leitura/features/billing/presentation/billing_lifecycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/billing_fakes.dart';

void main() {
  testWidgets('abre o controller com o app e avisa a volta ao app', (
    tester,
  ) async {
    var criados = 0;
    late BillingFalso pro;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          billingControllerProvider.overrideWith(() {
            criados++;
            return pro = BillingFalso(const ProUnavailable());
          }),
        ],
        child: const MaterialApp(home: BillingLifecycle(child: Text('app'))),
      ),
    );
    expect(find.text('app'), findsOneWidget);
    expect(criados, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(pro.retomadas, 1);
  });
}

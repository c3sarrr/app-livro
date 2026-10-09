// G22.4 — o gancho da Início (R7, D-230): com a Início montada e a conta Grátis, os marcos; ao entrar na conta, o 2º
// aparelho. Na depuração abre a tela técnica; no build de produção não faz nada (nem consulta o motor). A Início
// não muda: o gancho só a envolve.
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/features/account/application/account_controller.dart';
import 'package:app_leitura/features/billing/application/billing_controller.dart';
import 'package:app_leitura/features/billing/application/paywall_triggers.dart';
import 'package:app_leitura/features/billing/presentation/paywall_home_hook.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/billing_fakes.dart';

void main() {
  late AppDatabase db;
  late DateTime agora;
  late List<PaywallReason> mostrados;
  late ContaFalsa conta;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    agora = DateTime.utc(2026, 10, 9, 12);
    mostrados = [];
  });
  tearDown(() => db.close());

  Future<void> montar(
    WidgetTester tester,
    AccountView inicial, {
    PaywallNumbers numeros = (books: 0, highlights: 0, streakDays: 0),
    bool depuracao = true,
    ProView pro = const ProUnavailable(),
  }) async {
    conta = ContaFalsa(inicial);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountControllerProvider.overrideWith(() => conta),
          billingControllerProvider.overrideWith(() => BillingFalso(pro)),
          paywallTriggersProvider.overrideWithValue(
            PaywallTriggers(kv: () async => KvDao(db), now: () => agora),
          ),
          paywallCountsProvider.overrideWithValue((_) async => numeros),
          paywallDebugProvider.overrideWithValue(depuracao),
          paywallPresenterProvider.overrideWithValue(
            (context, motivo) => mostrados.add(motivo),
          ),
        ],
        child: const MaterialApp(home: PaywallHomeHook(child: Text('Início'))),
      ),
    );
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  testWidgets('a Início aparece igual: o gancho só a envolve', (tester) async {
    await montar(tester, const GuestView(canSignIn: true));
    expect(find.text('Início'), findsOneWidget);
  });

  testWidgets(
    'depuração, conta Grátis com 10 livros: a tela técnica com o marco, uma vez',
    (tester) async {
      await montar(
        tester,
        membro(contaA),
        numeros: (books: 10, highlights: 0, streakDays: 0),
      );
      expect(mostrados, [PaywallReason.books10]);
      // outra montagem da Início no mesmo dia
      await tester.pumpWidget(const SizedBox());
      await montar(
        tester,
        membro(contaA),
        numeros: (books: 10, highlights: 50, streakDays: 0),
      );
      expect(mostrados, [PaywallReason.books10]);
    },
  );

  testWidgets(
    'build de produção: nada aparece e o motor nem é consultado (D-230)',
    (tester) async {
      await montar(
        tester,
        membro(contaA),
        numeros: (books: 10, highlights: 50, streakDays: 30),
        depuracao: false,
      );
      expect(mostrados, isEmpty);
      expect(
        await tester.runAsync(() => KvDao(db).withPrefix('pro.gatilho.')),
        isEmpty,
      );
    },
  );

  testWidgets(
    'convidado e Pro (do servidor ou da loja sem rede, R8) não veem',
    (tester) async {
      const muitos = (books: 10, highlights: 50, streakDays: 30);
      await montar(tester, const GuestView(canSignIn: true), numeros: muitos);
      await tester.pumpWidget(const SizedBox());
      await montar(tester, membro(contaA, pro: true), numeros: muitos);
      await tester.pumpWidget(const SizedBox());
      await montar(
        tester,
        membro(contaB),
        numeros: muitos,
        pro: ProReady(customer: proDaLoja, serverPro: false),
      );
      expect(mostrados, isEmpty);
    },
  );

  testWidgets(
    'a conta chega depois da Início: os marcos são avaliados quando ela chega',
    (tester) async {
      await montar(
        tester,
        const AccountLoading(),
        numeros: (books: 0, highlights: 50, streakDays: 0),
      );
      expect(mostrados, isEmpty);
      conta.mudar(membro(contaA));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(mostrados, [PaywallReason.highlights50]);
    },
  );

  testWidgets('entrar na conta com outra sessão ativa: o 2º aparelho', (
    tester,
  ) async {
    await montar(tester, const GuestView(canSignIn: true));
    // o resumo chega depois do login
    conta.mudar(const MemberView(userId: contaA));
    await tester.pump();
    conta.mudar(membro(contaA, outrasSessoes: 1));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(mostrados, [PaywallReason.secondDevice]);
  });

  testWidgets(
    'abrir o app com a sessão guardada não é "entrar": sem o 2º aparelho',
    (tester) async {
      await montar(tester, const AccountLoading());
      conta.mudar(membro(contaA, outrasSessoes: 1));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(mostrados, isEmpty);
    },
  );
}

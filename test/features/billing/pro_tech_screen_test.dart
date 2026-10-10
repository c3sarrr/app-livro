// G22.5 — a tela técnica do Pro `/_pro` (docs/progresso/G22.md §5; só na depuração, D-230): os pacotes com o preço,
// a economia e o teste (R4), o texto das lojas antes do botão, os links do env, restaurar e gerenciar, o Pro da loja
// e o do servidor, o "conferir agora", o motivo do gatilho com "Agora não" e o simulador dos gatilhos.
import 'package:app_leitura/core/config/app_env.dart';
import 'package:app_leitura/core/config/server_providers.dart';
import 'package:app_leitura/core/data/database/app_database.dart';
import 'package:app_leitura/core/data/database/daos/kv_dao.dart';
import 'package:app_leitura/features/account/application/account_controller.dart';
import 'package:app_leitura/features/billing/application/billing_controller.dart';
import 'package:app_leitura/features/billing/application/billing_providers.dart';
import 'package:app_leitura/features/billing/application/paywall_triggers.dart';
import 'package:app_leitura/features/billing/domain/billing_models.dart';
import 'package:app_leitura/features/billing/domain/billing_rules.dart';
import 'package:app_leitura/features/billing/presentation/paywall_home_hook.dart';
import 'package:app_leitura/features/billing/presentation/pro_tech_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../account/support/account_finders.dart';
import 'support/billing_fakes.dart';

void main() {
  late AppDatabase db;
  late BillingFalso pro;
  late List<Uri> abertas;
  late List<PaywallReason> apresentados;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory(), withSyncQueue: false);
    abertas = [];
    apresentados = [];
  });
  tearDown(() => db.close());

  Future<void> montar(
    WidgetTester tester, {
    AccountView conta = const MemberView(userId: contaA),
    ProView? estado,
    List<ProPackage> pacotes = const [mensal, anual],
    AppEnv env = const AppEnv(),
    String inicial = '/_pro',
    bool apresentadorDeVerdade = false,
    void Function()? aoLerPacotes,
    Object? falhaPacotes,
  }) async {
    pro = BillingFalso(
      estado ?? ProReady(customer: proDaLoja, serverPro: true),
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => context.push(inicial),
                child: const Text('Início'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/_pro',
          builder: (_, state) => ProTechScreen(
            reason: PaywallReason.fromName(state.uri.queryParameters['motivo']),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountControllerProvider.overrideWith(() => ContaFalsa(conta)),
          billingControllerProvider.overrideWith(() => pro),
          proPackagesProvider.overrideWith((ref) async {
            aoLerPacotes?.call();
            final falha = falhaPacotes;
            if (falha != null) throw falha;
            return pacotes;
          }),
          appEnvProvider.overrideWithValue(env),
          billingPlatformProvider.overrideWithValue(TargetPlatform.android),
          billingLauncherProvider.overrideWithValue((uri) async {
            abertas.add(uri);
            return true;
          }),
          paywallTriggersProvider.overrideWithValue(
            PaywallTriggers(
              kv: () async => KvDao(db),
              now: () => DateTime.utc(2026, 10, 9, 12),
            ),
          ),
          if (!apresentadorDeVerdade)
            paywallPresenterProvider.overrideWithValue(
              (_, motivo) => apresentados.add(motivo),
            ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'os dois pacotes: o preço da loja, a economia do anual e o teste grátis',
    (tester) async {
      await montar(tester);
      expect(texto(r'Mensal · R$ 9,99'), findsOneWidget);
      expect(texto(r'7 dias grátis, depois R$ 9,99/mês'), findsOneWidget);
      expect(texto(r'Anual · R$ 79,99'), findsOneWidget);
      expect(texto('Economize 33 %'), findsOneWidget);
      expect(texto(r'7 dias grátis, depois R$ 79,99/ano'), findsOneWidget);
    },
  );

  testWidgets('o texto das lojas vem antes do botão de assinar', (
    tester,
  ) async {
    await montar(tester);
    final aviso = texto(storeDisclosure(mensal, TargetPlatform.android));
    expect(aviso, findsOneWidget);
    expect(
      tester.getTopLeft(aviso).dy,
      lessThan(tester.getTopLeft(botao('Assinar o mensal')).dy),
    );
  });

  testWidgets('assinar, restaurar, gerenciar e conferir chamam o controller', (
    tester,
  ) async {
    await montar(tester);
    await tocar(tester, 'Assinar o mensal');
    await tocar(tester, 'Assinar o anual');
    await tocar(tester, 'Restaurar compras');
    await tocar(tester, 'Gerenciar assinatura');
    await tocar(tester, 'Conferir agora');
    expect(pro.acoes, [
      r'comprar:$rc_monthly',
      r'comprar:$rc_annual',
      'restaurar',
      'gerenciar',
      'conferir',
    ]);
  });

  testWidgets('o Pro da loja e o do servidor lado a lado', (tester) async {
    await montar(
      tester,
      estado: ProReady(customer: proDaLoja, serverPro: false, activating: true),
    );
    expect(
      texto('Loja: Pro até 12/11/2026 · renova automaticamente · sandbox'),
      findsOneWidget,
    );
    expect(texto('Servidor: Grátis · ativando'), findsOneWidget);
  });

  testWidgets('os links do env; vazios, "Publicação pendente (Q9)."', (
    tester,
  ) async {
    await montar(tester);
    expect(texto('Termos de Uso: Publicação pendente (Q9).'), findsOneWidget);
    expect(
      texto('Política de Privacidade: Publicação pendente (Q9).'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
    await montar(
      tester,
      env: const AppEnv(
        termsUrl: 'https://booknest.teste/termos',
        privacyUrl: 'https://booknest.teste/privacidade',
      ),
    );
    await tocar(tester, 'Termos de Uso');
    await tocar(tester, 'Política de Privacidade');
    expect(abertas, [
      Uri.parse('https://booknest.teste/termos'),
      Uri.parse('https://booknest.teste/privacidade'),
    ]);
  });

  testWidgets('aberta por um gatilho: o motivo e "Agora não", que fecha', (
    tester,
  ) async {
    await montar(tester, inicial: '/_pro?motivo=books10');
    expect(texto('Marco: 10 livros'), findsOneWidget);
    await tocar(tester, 'Agora não');
    expect(find.text('Início'), findsOneWidget);
  });

  testWidgets(
    'revisão (m6): aberta por um gatilho, os pacotes (e o RevenueCat) só depois do toque',
    (tester) async {
      var lidos = 0;
      await montar(
        tester,
        inicial: '/_pro?motivo=books10',
        aoLerPacotes: () => lidos++,
      );
      expect(lidos, 0);
      expect(botao('Assinar o mensal'), findsNothing);
      await tocar(tester, 'Ver os planos');
      expect(lidos, 1);
      expect(botao('Assinar o mensal'), findsOneWidget);
    },
  );

  testWidgets('aberta pela pessoa (sem gatilho), os pacotes vêm direto', (
    tester,
  ) async {
    var lidos = 0;
    await montar(tester, aoLerPacotes: () => lidos++);
    expect(lidos, 1);
    expect(botao('Ver os planos'), findsNothing);
  });

  testWidgets('o convidado vê só "Entrar para assinar." (R1)', (tester) async {
    await montar(
      tester,
      conta: const GuestView(canSignIn: true),
      estado: const ProUnavailable(),
    );
    expect(texto('Entrar para assinar.'), findsOneWidget);
    expect(botao('Assinar o mensal'), findsNothing);
    expect(botao('Restaurar compras'), findsNothing);
  });

  testWidgets(
    'o simulador: disparar grava e apresenta o gatilho; zerar esquece a conta',
    (tester) async {
      await montar(tester);
      await tocar(tester, 'Disparar: Marco: 10 livros');
      expect(apresentados, [PaywallReason.books10]);
      expect(
        await tester.runAsync(
          () => KvDao(db).withPrefix('pro.gatilho.$contaA.'),
        ),
        isNotEmpty,
      );
      await tocar(tester, 'Zerar o limite de 7 dias');
      expect(
        await tester.runAsync(
          () => KvDao(db).withPrefix('pro.gatilho.$contaA.'),
        ),
        isEmpty,
      );
    },
  );

  testWidgets('o apresentador de verdade abre /_pro com o motivo', (
    tester,
  ) async {
    await montar(tester, apresentadorDeVerdade: true);
    await tocar(tester, 'Disparar: 2º aparelho');
    expect(texto('2º aparelho'), findsWidgets);
    expect(botao('Agora não'), findsOneWidget);
  });

  testWidgets(
    'os pacotes que não vêm: o código da falha e "Tentar de novo" (G22.7, cobertura)',
    (tester) async {
      var lidos = 0;
      await montar(
        tester,
        falhaPacotes: const BillingOffline(),
        aoLerPacotes: () => lidos++,
      );
      expect(texto('Não deu para ler os pacotes (rede).'), findsOneWidget);
      await tocar(tester, 'Tentar de novo');
      expect(lidos, 2);
    },
  );

  testWidgets('sem pacotes na offering', (tester) async {
    await montar(tester, pacotes: const []);
    expect(texto('Nenhum pacote na offering default.'), findsOneWidget);
  });
}

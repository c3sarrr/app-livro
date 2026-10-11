// D-69 / D-21: o bloco da conta na aba Perfil e as telas de entrar e concluir o cadastro, no app real
// (roteador + shell) com os dublês da conta.
import 'package:app_leitura/app/router.dart';
import 'package:app_leitura/core/data/database/daos/library_daos.dart';
import 'package:app_leitura/core/sync/sync_engine.dart';
import 'package:app_leitura/core/sync/sync_providers.dart';
import 'package:app_leitura/features/account/application/account_controller.dart';
import 'package:app_leitura/features/account/data/store_age_signals.dart';
import 'package:app_leitura/features/account/domain/account_failure.dart';
import 'package:app_leitura/features/account/domain/age.dart';
import 'package:app_leitura/features/account/domain/auth_status.dart';
import 'package:app_leitura/features/account/presentation/account_block.dart';
import 'package:app_leitura/features/account/presentation/onboarding_screen.dart';
import 'package:app_leitura/features/account/presentation/sign_in_screen.dart';
import 'package:app_leitura/features/billing/application/billing_controller.dart';
import 'package:app_leitura/features/shell/presentation/main_shell.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../fixtures/home_mock_repository.dart';
import '../../support/canvas.dart';
import '../../support/load_fonts.dart';
import '../../support/personal_builders.dart';
import '../../support/pump_app.dart';
import '../billing/support/billing_fakes.dart' show BillingFalso, proDaLoja;
import 'support/account_fakes.dart';
import 'support/account_finders.dart';
import 'support/fake_backend.dart';

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(MainShell, skipOffstage: false)));

void main() {
  setUpAll(loadAppFonts);

  late AccountHarness h;

  Future<void> abrirPerfil(
    WidgetTester tester,
    AccountHarness harness, {
    List<Override> extras = const [],
  }) async {
    h = harness;
    addTearDown(h.close);
    setCanvasView(
      tester,
      logical: const Size(390, 844),
      safeTop: 47,
      safeBottom: 34,
    );
    await pumpApp(tester, overrides: [...h.overrides, ...extras]);
    _router(tester).go(AppRoutes.perfil);
    await tester.pumpAndSettle();
    await assentar(tester);
  }

  testWidgets(
    'sem servidor nesta versão: só o convidado; exportar entrega o arquivo',
    (tester) async {
      await abrirPerfil(tester, AccountHarness(servidor: false));
      expect(find.byType(AccountBlock), findsOneWidget);
      expect(texto('Conta indisponível nesta versão.'), findsOneWidget);
      expect(botao('Entrar ou criar conta'), findsNothing);
      await tocar(tester, 'Exportar meus dados');
      await assentar(tester);
      expect(h.sink.entregas, hasLength(1));
      expect(
        h.sink.entregas.single.$1,
        exportFileName(HomeMockRepository.referenceNow),
      );
      expect(texto('Arquivo com os seus dados pronto.'), findsOneWidget);
    },
  );

  testWidgets(
    'entrar por código: idade (data) → e-mail → código → concluir cadastro (@) → volta ao Perfil',
    (tester) async {
      await abrirPerfil(tester, AccountHarness());
      await tocar(tester, 'Entrar ou criar conta');
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(texto('Qual é a sua data de nascimento?'), findsOneWidget);

      await digitar(tester, 'Data de nascimento', '31/02/1990');
      await tocar(tester, 'Continuar');
      expect(texto('Confira a data (DD/MM/AAAA).'), findsOneWidget);

      await digitar(tester, 'Data de nascimento', '01/05/1990');
      await tocar(tester, 'Continuar');
      await assentar(tester);
      expect(campo('E-mail'), findsOneWidget);

      await digitar(tester, 'E-mail', emailTeste);
      await tocar(tester, 'Receber código por e-mail');
      expect(
        texto('Enviamos um código de 6 dígitos para o seu e-mail.'),
        findsOneWidget,
      );

      await digitar(tester, 'Código de 6 dígitos', '123456');
      await tocar(tester, 'Entrar');
      await assentar(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(SignInScreen), findsNothing);
      expect(textoComecando('Escolha o seu @.'), findsOneWidget);

      await digitar(tester, 'Seu @', 'Ana.Lima');
      await tocar(tester, 'Salvar @');
      await assentar(tester);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(_router(tester).state.uri.path, AppRoutes.perfil);
      expect(texto('@ana.lima'), findsOneWidget);
      expect(h.gateway!.calls, ['enviar:$emailTeste', 'conferir:123456']);
      expect(h.api!.faixas, [
        const AgeCheck(AgeBand.adult, AgeSource.birthdate),
      ]);
    },
  );

  testWidgets('menor de 13: não entra (pode seguir sem conta)', (tester) async {
    await abrirPerfil(tester, AccountHarness());
    await tocar(tester, 'Entrar ou criar conta');
    await digitar(tester, 'Data de nascimento', '01/01/2016');
    await tocar(tester, 'Continuar');
    await assentar(tester);
    expect(texto('O BookNest é para 13 anos ou mais'), findsOneWidget);
    expect(campo('E-mail'), findsNothing);
    expect(botao('Entrar com Google'), findsNothing);
  });

  testWidgets(
    'Play Store pede verificação: o app espera a loja (não pede a data)',
    (tester) async {
      await abrirPerfil(
        tester,
        AccountHarness(loja: const StoreAgeVerificationNeeded()),
      );
      await tocar(tester, 'Entrar ou criar conta');
      await assentar(tester);
      expect(texto('Confirme sua idade na Play Store'), findsOneWidget);
      expect(campo('Data de nascimento'), findsNothing);
      h.store.resultado = const StoreAgeRange(
        lower: 18,
        source: AgeSource.playSignal,
      );
      await tocar(tester, 'Conferir de novo');
      await assentar(tester);
      expect(campo('E-mail'), findsOneWidget);
    },
  );

  testWidgets(
    'código errado: o aviso aparece e a pessoa continua na etapa do código',
    (tester) async {
      await abrirPerfil(
        tester,
        AccountHarness(
          loja: const StoreAgeRange(lower: 18, source: AgeSource.playSignal),
        ),
      );
      await tocar(tester, 'Entrar ou criar conta');
      await assentar(tester);
      await digitar(tester, 'E-mail', emailTeste);
      await tocar(tester, 'Receber código por e-mail');
      h.gateway!.falha = const InvalidCode();
      await digitar(tester, 'Código de 6 dígitos', '000000');
      await tocar(tester, 'Entrar');
      await assentar(tester);
      expect(texto(const InvalidCode().message), findsOneWidget);
      expect(campo('Código de 6 dígitos'), findsOneWidget);
      await tocar(tester, 'Trocar e-mail');
      expect(campo('E-mail'), findsOneWidget);
    },
  );

  testWidgets('G22: o convidado não ganha nada do Pro no bloco (R1)', (
    tester,
  ) async {
    await abrirPerfil(
      tester,
      AccountHarness(),
      extras: [
        billingControllerProvider.overrideWith(
          () => BillingFalso(const ProUnavailable()),
        ),
      ],
    );
    expect(botao('Entrar ou criar conta'), findsOneWidget);
    expect(botao('Restaurar compras'), findsNothing);
    expect(textoComecando('Plano'), findsNothing);
  });

  group('com conta', () {
    AccountHarness logado() {
      final x = AccountHarness(
        inicial: const SignedIn(userId: contaTeste, email: emailTeste),
      );
      x.api!.json = contaJson(handle: 'ana.lima', provisorio: false);
      return x;
    }

    testWidgets('sair pede confirmação; "manter" volta a convidado', (
      tester,
    ) async {
      await abrirPerfil(tester, logado());
      expect(texto('@ana.lima'), findsOneWidget);
      expect(botao('Concluir cadastro'), findsNothing);
      await tocar(tester, 'Sair');
      expect(botao('Sair e manter neste aparelho'), findsOneWidget);
      expect(botao('Sair e apagar deste aparelho'), findsOneWidget);
      await tocar(tester, 'Cancelar');
      expect(botao('Sair e manter neste aparelho'), findsNothing);
      await tocar(tester, 'Sair');
      await tocar(tester, 'Sair e manter neste aparelho');
      await assentar(tester);
      expect(h.gateway!.calls, ['sair']);
      expect(botao('Entrar ou criar conta'), findsOneWidget);
    });

    testWidgets('G06: indicador discreto da sincronização abaixo do @', (
      tester,
    ) async {
      await abrirPerfil(
        tester,
        logado(),
        extras: [
          syncStateProvider.overrideWith(
            (ref) => Stream.value(
              const SyncState(pro: true, phase: SyncPhase.offline, pending: 3),
            ),
          ),
        ],
      );
      expect(texto('@ana.lima'), findsOneWidget);
      expect(
        texto('Sem conexão: 3 alterações esperando para ir à nuvem.'),
        findsOneWidget,
      );
    });

    testWidgets('G22 (D-231): o Pro no bloco da conta, abaixo do indicador', (
      tester,
    ) async {
      await abrirPerfil(
        tester,
        logado(),
        extras: [
          billingControllerProvider.overrideWith(
            () => BillingFalso(ProReady(customer: proDaLoja, serverPro: true)),
          ),
        ],
      );
      expect(texto('@ana.lima'), findsOneWidget);
      expect(
        texto('Pro até 12/11/2026 · renova automaticamente'),
        findsOneWidget,
      );
      expect(botao('Restaurar compras'), findsOneWidget);
      expect(botao('Gerenciar assinatura'), findsOneWidget);
    });

    testWidgets('G06: sair com alterações não enviadas avisa antes de apagar', (
      tester,
    ) async {
      final x = logado();
      x.sync.pendentes = 2;
      await abrirPerfil(tester, x);
      expect(texto('Sincronizado'), findsNothing, reason: 'Grátis: nada');
      await tocar(tester, 'Sair');
      expect(
        texto(
          'Há 2 alterações ainda não enviadas à nuvem: se apagar deste aparelho, elas se perdem.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('excluir pede confirmação e avisa quando termina', (
      tester,
    ) async {
      await abrirPerfil(tester, logado());
      await tocar(tester, 'Excluir conta');
      expect(
        textoComecando('Excluir a conta apaga agora, no servidor'),
        findsOneWidget,
      );
      await tocar(tester, 'Excluir e apagar também deste aparelho');
      await assentar(tester);
      expect(h.api!.calls, contains('excluir'));
      expect(texto('Conta excluída.'), findsOneWidget);
      expect(botao('Entrar ou criar conta'), findsOneWidget);
    });

    testWidgets('@ provisório: o Perfil oferece "Concluir cadastro"', (
      tester,
    ) async {
      final x = logado();
      x.api!.json = contaJson();
      await abrirPerfil(tester, x);
      await tocar(tester, 'Concluir cadastro');
      expect(find.byType(OnboardingScreen), findsOneWidget);
      await digitar(tester, 'Seu @', 'tomado');
      await tocar(tester, 'Salvar @');
      expect(texto(const HandleTaken().message), findsOneWidget);
    });

    testWidgets(
      'conta sem faixa e menor de 13 no cadastro: oferece excluir ou sair',
      (tester) async {
        final x = logado();
        x.api!.json = contaJson(faixa: null);
        await abrirPerfil(tester, x);
        await tocar(tester, 'Concluir cadastro');
        await assentar(tester);
        await digitar(tester, 'Data de nascimento', '01/01/2016');
        await tocar(tester, 'Continuar');
        await assentar(tester);
        expect(texto('O BookNest é para 13 anos ou mais'), findsOneWidget);
        expect(botao('Sair da conta'), findsOneWidget);
        await tocar(tester, 'Excluir a conta');
        await assentar(tester);
        expect(x.api!.calls, contains('excluir'));
        expect(find.byType(OnboardingScreen), findsNothing);
        expect(botao('Entrar ou criar conta'), findsOneWidget);
      },
    );

    testWidgets(
      'depois de sair e manter, o convidado vê e pode apagar os dados guardados',
      (tester) async {
        await abrirPerfil(tester, logado());
        await tester.runAsync(
          () => UserBooksDao(h.db).upsert(livroTeste(1, dono: contaTeste)),
        );
        await tocar(tester, 'Sair');
        await tocar(tester, 'Sair e manter neste aparelho');
        await assentar(tester);
        expect(textoComecando('Há 1 item guardado'), findsOneWidget);
        await tocar(tester, 'Apagar dados de contas que saíram');
        await tocar(tester, 'Apagar dados de contas que saíram');
        await assentar(tester);
        expect(texto('Dados apagados deste aparelho.'), findsOneWidget);
        expect(textoComecando('Há 1 item guardado'), findsNothing);
        expect(await tester.runAsync(() => h.library.countRows(contaTeste)), 0);
      },
    );

    testWidgets('sem internet: o motivo aparece e "Tentar de novo" resolve', (
      tester,
    ) async {
      final x = logado();
      x.api!.falhaResumo = const OfflineFailure();
      await abrirPerfil(tester, x);
      expect(texto(const OfflineFailure().message), findsOneWidget);
      x.api!.falhaResumo = null;
      await tocar(tester, 'Tentar de novo');
      await assentar(tester);
      expect(texto('@ana.lima'), findsOneWidget);
    });
  });
}

/// Espera a fila de sessão do controller (o banco do aparelho é de verdade, em memória).
Future<void> assentar(WidgetTester tester) async {
  // um elemento ABAIXO do ProviderScope (o próprio ProviderScope não enxerga o container dele)
  final el = find.byType(MainShell, skipOffstage: false).evaluate().first;
  final ctl = ProviderScope.containerOf(el)
      .read(accountControllerProvider.notifier);
  await tester.runAsync(ctl.settled);
  await tester.pumpAndSettle();
}

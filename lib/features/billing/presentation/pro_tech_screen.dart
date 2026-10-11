// G22.5 — a tela técnica do Pro (`/_pro`, só na depuração): o paywall de trabalho enquanto o paywall não tem design
// (Anexo 04 §7, D-230). Sem prancha (D-21): os primitivos do bloco da conta. Os textos estão em
// `docs/design/estados_sem_design.md` (G22).
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/config/app_env.dart';
import '../../../core/config/server_providers.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../account/application/account_controller.dart';
import '../../account/presentation/account_widgets.dart';
import '../application/billing_controller.dart';
import '../application/billing_providers.dart';
import '../application/paywall_triggers.dart';
import '../domain/billing_models.dart';
import '../domain/billing_rules.dart';
import 'paywall_home_hook.dart' show paywallPresenterProvider;

class ProTechScreen extends ConsumerStatefulWidget {
  const ProTechScreen({super.key, this.reason});

  /// O gatilho que abriu a tela (R7), se foi um.
  final PaywallReason? reason;

  @override
  ConsumerState<ProTechScreen> createState() => _ProTechScreenState();
}

class _ProTechScreenState extends ConsumerState<ProTechScreen> {
  /// Os pacotes são lidos (e o RevenueCat entra) só quando a pessoa age: aberta por ela, direto; aberta por um
  /// gatilho, depois do toque em "Ver os planos" (revisão, m6).
  late bool _plans = widget.reason == null;

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountControllerProvider);
    final view = ref.watch(billingControllerProvider);
    final motivo = widget.reason;
    final children = <Widget>[
      const AccountHeading('Pro (tela técnica)'),
      if (motivo != null) ...[
        AccountText(motivo.label),
        AccountButton('Agora não', onTap: () => context.pop()),
      ],
      ...switch ((account, view)) {
        (MemberView(:final userId), final ProReady ready) => _ready(
          context,
          userId,
          ready,
        ),
        (MemberView(), ProLoading()) => [
          const AccountText('Configurando o RevenueCat…', muted: true),
        ],
        (MemberView(), _) => [
          const AccountText(
            'Sem a chave do RevenueCat nesta versão.',
            muted: true,
          ),
        ],
        _ => [
          const AccountText('Entrar para assinar.'),
          AccountButton(
            'Entrar ou criar conta',
            tone: AccountButtonTone.primary,
            onTap: () => context.push(AppRoutes.entrar),
          ),
        ],
      },
    ];
    return ColoredBox(
      color: AppColors.paper,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: 24,
          ),
          child: AccountColumn(children: children),
        ),
      ),
    );
  }

  List<Widget> _ready(BuildContext context, String owner, ProReady view) {
    final controller = ref.read(billingControllerProvider.notifier);
    final platform = ref.watch(billingPlatformProvider);
    final env = ref.watch(appEnvProvider);
    final customer = view.customer;
    final waiting = view.activating;
    final notice = view.notice;
    return [
      if (!_plans)
        AccountButton(
          'Ver os planos',
          tone: AccountButtonTone.primary,
          onTap: () => setState(() => _plans = true),
        )
      else
        ...ref
            .watch(proPackagesProvider)
            .when(
              data: (pacotes) =>
                  _packages(pacotes, platform, controller, waiting),
              loading: () => const [
                AccountText('Lendo os pacotes…', muted: true),
              ],
              error: (e, _) => [
                AccountText(
                  'Não deu para ler os pacotes (${e is BillingFailure ? e.code : 'erro'}).',
                  muted: true,
                ),
                AccountButton(
                  'Tentar de novo',
                  onTap: () => ref.invalidate(proPackagesProvider),
                ),
              ],
            ),
      ..._link('Termos de Uso', env.termsUrl),
      ..._link('Política de Privacidade', env.privacyUrl),
      AccountButton(
        'Restaurar compras',
        onTap: waiting ? null : controller.restore,
      ),
      if (customer.active)
        AccountButton(
          'Gerenciar assinatura',
          onTap: waiting ? null : controller.manage,
        ),
      AccountText(
        'Loja: ${proStatusLine(customer)}${customer.sandbox ? ' · sandbox' : ''}',
      ),
      AccountText(
        'Servidor: ${view.serverPro ? 'Pro' : 'Grátis'}${waiting ? ' · ativando' : ''}',
      ),
      AccountButton(
        'Conferir agora',
        onTap: waiting ? null : controller.checkNow,
      ),
      if (notice != null) AccountNotice(notice, error: view.noticeIsError),
      const AccountText('Simulador dos gatilhos', muted: true),
      for (final r in PaywallReason.values)
        AccountButton(
          'Disparar: ${r.label}',
          onTap: () => unawaited(_fire(context, owner, r)),
        ),
      AccountButton(
        'Zerar o limite de 7 dias',
        onTap: () =>
            unawaited(ref.read(paywallTriggersProvider).resetForTests(owner)),
      ),
    ];
  }

  List<Widget> _packages(
    List<ProPackage> pacotes,
    TargetPlatform platform,
    BillingController controller,
    bool waiting,
  ) {
    if (pacotes.isEmpty) {
      return const [
        AccountText('Nenhum pacote na offering default.', muted: true),
      ];
    }
    ProPackage? doPeriodo(ProPeriod p) {
      for (final x in pacotes) {
        if (x.period == p) return x;
      }
      return null;
    }

    final mes = doPeriodo(ProPeriod.month);
    final ano = doPeriodo(ProPeriod.year);
    final economia = mes != null && ano != null
        ? annualSavingsPercent(mes, ano)
        : null;
    return [
      for (final p in pacotes) ...[
        AccountText(
          '${p.period == ProPeriod.month ? 'Mensal' : 'Anual'} · ${p.priceString}',
        ),
        if (p.period == ProPeriod.year && economia != null)
          AccountText('Economize $economia %'),
        if (trialLine(p) case final teste?) AccountText(teste),
        AccountText(storeDisclosure(p, platform), muted: true),
        AccountButton(
          p.period == ProPeriod.month ? 'Assinar o mensal' : 'Assinar o anual',
          tone: AccountButtonTone.primary,
          onTap: waiting ? null : () => unawaited(controller.purchase(p)),
        ),
      ],
    ];
  }

  List<Widget> _link(String titulo, String url) {
    final uri = AppEnv.publishedUrl(url);
    if (uri == null) {
      return [AccountText('$titulo: Publicação pendente (Q9).', muted: true)];
    }
    return [
      AccountButton(
        titulo,
        onTap: () => unawaited(ref.read(billingLauncherProvider)(uri)),
      ),
    ];
  }

  Future<void> _fire(
    BuildContext context,
    String owner,
    PaywallReason reason,
  ) async {
    await ref.read(paywallTriggersProvider).shown(owner, reason);
    if (!context.mounted) return;
    ref.read(paywallPresenterProvider)(context, reason);
  }
}

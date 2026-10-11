// G22.5 — o Pro no bloco da conta do Perfil (D-231), sem prancha (D-21): os primitivos do bloco
// (`account_widgets.dart`), como o resto dele. Com a compra disponível e a conta pronta: o estado (§3), "Restaurar
// compras", "Gerenciar assinatura" só com Pro e, na depuração, "Assinar (tela técnica)". Sem compra nesta versão (sem
// chave) ou configurando: nada novo. Os textos estão em `docs/design/estados_sem_design.md`.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../billing/application/billing_controller.dart';
import '../../billing/domain/billing_models.dart';
import '../../billing/domain/billing_rules.dart';
import '../../billing/presentation/paywall_home_hook.dart'
    show paywallDebugProvider;
import '../../home/application/home_providers.dart' show clockProvider;
import 'account_widgets.dart';

class ProRows extends ConsumerWidget {
  const ProRows({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(billingControllerProvider);
    if (view is! ProReady) return const SizedBox.shrink();
    final controller = ref.read(billingControllerProvider.notifier);
    // R8: sem rede, o Pro guardado da loja vale até a expiração + 3 dias
    final now = ref.watch(clockProvider)().toUtc();
    final customer = view.customer.active && !localProValid(view.customer, now)
        ? ProCustomer.none
        : view.customer;
    final waiting = view.activating;
    final notice = view.notice;
    return AccountColumn(
      children: [
        AccountText(proStatusLine(customer, activating: view.activating)),
        AccountButton(
          'Restaurar compras',
          onTap: waiting ? null : controller.restore,
        ),
        if (customer.active)
          AccountButton(
            'Gerenciar assinatura',
            onTap: waiting ? null : controller.manage,
          ),
        if (ref.watch(paywallDebugProvider))
          AccountButton(
            'Assinar (tela técnica)',
            onTap: () => context.push(AppRoutes.proTecnico),
          ),
        if (notice != null) AccountNotice(notice, error: view.noticeIsError),
      ],
    );
  }
}

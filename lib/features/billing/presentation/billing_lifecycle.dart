// G22.3 — o Pro acompanha o app: o controller nasce com ele (a conta Pro configura o RevenueCat sem esperar o Perfil)
// e, ao voltar ao app, a ativação que não confirmou tenta de novo (R2). Como o `SocialAutoSync` (G21), envolve o app
// no `main`.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/billing_controller.dart';

class BillingLifecycle extends ConsumerStatefulWidget {
  const BillingLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<BillingLifecycle> createState() => _BillingLifecycleState();
}

class _BillingLifecycleState extends ConsumerState<BillingLifecycle> {
  AppLifecycleListener? _life;

  @override
  void initState() {
    super.initState();
    // mantém o controller vivo enquanto o app existir
    ref.listenManual(billingControllerProvider, (_, _) {});
    _life = AppLifecycleListener(
      onResume: () => ref.read(billingControllerProvider.notifier).resumed(),
    );
  }

  @override
  void dispose() {
    _life?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
